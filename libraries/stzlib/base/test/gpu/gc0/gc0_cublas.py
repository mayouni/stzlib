"""GC0 -- the distance to cuBLAS: NVIDIA's own matrix product, timed on its own clock.

A BENCHMARK, NOT A DEPENDENCY. The product never loads this file or cuBLAS.
It needs the two NVIDIA wheels in a separate venv, outside every repository
(the author ruled the install on 2026-10-28):

    python -m venv D:\\GitHub\\_bench_cublas\\venv
    venv\\Scripts\\python -m pip install nvidia-cublas-cu12==12.6.4.1 nvidia-cuda-runtime-cu12==12.6.77

and is run with that interpreter:

    D:\\GitHub\\_bench_cublas\\venv\\Scripts\\python.exe -I gc0_cublas.py

It calls cudart and cuBLAS through ctypes, so nothing is compiled. For each
shape C(m x n) = A(m x k) B(k x n), row-major, f32 in [0, 1), it times the
product on CUDA events (the GPU's clock, the counterpart of the WebGPU
timestamps the foundry reads), warm, best of REPS, in three modes:

    fp32   cublasSgemm, the default math: strict f32 on the CUDA cores --
           the fair comparison with the foundry's f32 kernels
    tf32   the same call with TF32 tensor-core math: 10-bit mantissas in the
           multiply, the speed WebGPU has no way to ask for
    fp16   cublasGemmEx, f16 inputs, f32 accumulation, tensor cores: the
           hardware's ceiling for a product of this shape

and prints one line per shape and mode: ms, GFLOP/s, and the largest
difference from an f64 product of sampled entries (so a wrong call cannot
pass as a fast one).
"""
import ctypes, os, random, sys, time, array, struct, json

VENV = os.path.dirname(os.path.dirname(sys.executable))
SITE = os.path.join(VENV, "Lib", "site-packages", "nvidia")
for sub in ("cuda_runtime", "cublas"):
    os.add_dll_directory(os.path.join(SITE, sub, "bin"))
cudart = ctypes.CDLL("cudart64_12.dll")
cublas = ctypes.CDLL("cublas64_12.dll")

c_void_pp = ctypes.POINTER(ctypes.c_void_p)


def ck(rc, what):
    if rc != 0:
        raise RuntimeError(f"{what} returned {rc}")


cudart.cudaMalloc.argtypes = [c_void_pp, ctypes.c_size_t]
cudart.cudaMemcpy.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_size_t, ctypes.c_int]
cudart.cudaFree.argtypes = [ctypes.c_void_p]
cudart.cudaEventCreate.argtypes = [c_void_pp]
cudart.cudaEventRecord.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
cudart.cudaEventSynchronize.argtypes = [ctypes.c_void_p]
cudart.cudaEventElapsedTime.argtypes = [ctypes.POINTER(ctypes.c_float), ctypes.c_void_p, ctypes.c_void_p]
cublas.cublasCreate_v2.argtypes = [c_void_pp]
cublas.cublasSetMathMode.argtypes = [ctypes.c_void_p, ctypes.c_int]
cublas.cublasSgemm_v2.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_float), ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_int,
                                  ctypes.POINTER(ctypes.c_float), ctypes.c_void_p, ctypes.c_int]
cublas.cublasGemmEx.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int,
                                ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                                ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int]

H2D, D2H = 1, 2
OP_N = 0
DEFAULT_MATH, TF32_MATH = 0, 3
R_16F, R_32F = 2, 0
COMPUTE_32F = 68
GEMM_DEFAULT = -1

SHAPES = [(130, 384, 384), (130, 384, 1536), (130, 1536, 384),
          (256, 256, 256), (512, 512, 512), (1024, 1024, 1024), (2048, 2048, 2048), (4096, 4096, 4096)]
REPS = int(os.environ.get("GC0_REPS", "7"))


def dmalloc(nbytes):
    p = ctypes.c_void_p()
    ck(cudart.cudaMalloc(ctypes.byref(p), nbytes), "cudaMalloc")
    return p


def upload(p, buf):
    ck(cudart.cudaMemcpy(p, buf.buffer_info()[0], len(buf) * buf.itemsize, H2D), "cudaMemcpy H2D")


def download(p, n, code):
    out = array.array(code, bytes(n * array.array(code).itemsize))
    ck(cudart.cudaMemcpy(out.buffer_info()[0], p, n * out.itemsize, D2H), "cudaMemcpy D2H")
    return out


def f16_array(values):
    out = array.array("H")
    out.frombytes(struct.pack(f"<{len(values)}e", *values))
    return out


def timed(fn, reps):
    e0, e1 = ctypes.c_void_p(), ctypes.c_void_p()
    ck(cudart.cudaEventCreate(ctypes.byref(e0)), "event")
    ck(cudart.cudaEventCreate(ctypes.byref(e1)), "event")
    for _ in range(3):
        fn()
    ck(cudart.cudaDeviceSynchronize(), "sync")
    best = float("inf")
    for _ in range(reps):
        ck(cudart.cudaEventRecord(e0, None), "record")
        fn()
        ck(cudart.cudaEventRecord(e1, None), "record")
        ck(cudart.cudaEventSynchronize(e1), "event sync")
        ms = ctypes.c_float()
        ck(cudart.cudaEventElapsedTime(ctypes.byref(ms), e0, e1), "elapsed")
        best = min(best, ms.value)
    return best


def main():
    rnd = random.Random(20261028)
    h = ctypes.c_void_p()
    ck(cublas.cublasCreate_v2(ctypes.byref(h)), "cublasCreate")
    one, zero = ctypes.c_float(1.0), ctypes.c_float(0.0)
    rows = []
    for (m, k, n) in SHAPES:
        a = array.array("f", (rnd.random() for _ in range(m * k)))
        b = array.array("f", (rnd.random() for _ in range(k * n)))
        dA, dB, dC = dmalloc(m * k * 4), dmalloc(k * n * 4), dmalloc(m * n * 4)
        upload(dA, a)
        upload(dB, b)
        # row-major C = A B is column-major C^T = B^T A^T: hand cuBLAS B first
        def sgemm():
            ck(cublas.cublasSgemm_v2(h, OP_N, OP_N, n, m, k, ctypes.byref(one), dB, n, dA, k, ctypes.byref(zero), dC, n), "sgemm")
        flops = 2.0 * m * k * n
        samples = [(rnd.randrange(m), rnd.randrange(n)) for _ in range(16)]
        def err_of(c):
            worst = 0.0
            for (i, j) in samples:
                ref = sum(float(a[i * k + t]) * float(b[t * n + j]) for t in range(k))
                worst = max(worst, abs(ref - c[i * n + j]) / max(1.0, abs(ref)))
            return worst
        for mode, math in (("fp32", DEFAULT_MATH), ("tf32", TF32_MATH)):
            ck(cublas.cublasSetMathMode(h, math), "math mode")
            ms = timed(sgemm, REPS)
            err = err_of(download(dC, m * n, "f"))
            rows.append({"m": m, "k": k, "n": n, "mode": mode, "ms": ms, "gflops": flops / ms / 1e6, "relerr": err})
        ck(cublas.cublasSetMathMode(h, DEFAULT_MATH), "math mode")
        # fp16 inputs, f32 accumulation and output, tensor cores
        a16, b16 = f16_array(a), f16_array(b)
        dA16, dB16 = dmalloc(m * k * 2), dmalloc(k * n * 2)
        upload(dA16, a16)
        upload(dB16, b16)
        def hgemm():
            ck(cublas.cublasGemmEx(h, OP_N, OP_N, n, m, k, ctypes.byref(one), dB16, R_16F, n, dA16, R_16F, k,
                                   ctypes.byref(zero), dC, R_32F, n, COMPUTE_32F, GEMM_DEFAULT), "gemmEx")
        ms = timed(hgemm, REPS)
        err = err_of(download(dC, m * n, "f"))
        rows.append({"m": m, "k": k, "n": n, "mode": "fp16", "ms": ms, "gflops": flops / ms / 1e6, "relerr": err})
        for p in (dA, dB, dC, dA16, dB16):
            cudart.cudaFree(p)
        for r in rows[-3:]:
            print(f"{r['m']:>5} x {r['k']:>5} x {r['n']:>5}  {r['mode']}  {r['ms']:9.4f} ms  {r['gflops']:9.1f} GFLOP/s  rel.err {r['relerr']:.1e}", flush=True)
    out = os.environ.get("GC0_OUT")
    if out:
        with open(out, "w") as f:
            json.dump(rows, f)


if __name__ == "__main__":
    main()
