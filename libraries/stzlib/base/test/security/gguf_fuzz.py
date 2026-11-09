"""SECURITY-MODELDATA-01b, the discovery fuzzer behind model_file_is_data_narrated.ring (2026-11-08).

Mutates a real GGUF -- the header's counts, cuts, every key given every wrong type, arrays emptied, shortened or
overcounted, tensors renamed, reshaped, retyped and moved -- and drives stz_neural's exported text path (load, sizes,
tokenize, embed, NER, rerank, generate) on each mutant in a CHILD process capped at 2 GB by a job object, so a mutant
that asks for a huge allocation cannot press this machine. Anything but a clean return or a refusal is logged BAD with
the step it reached and the tail of its stderr. The guard is the gate; this is the deep sweep, minutes per seed.

usage:  python -I gguf_fuzz.py <dll_dir> <seed.gguf> <work_dir> <log> [regex over case names]
          dll_dir   the folder holding the stz_neural.dll to test (and the DLLs it loads)
          work_dir  where each mutant is written, with a SHA256SUMS line so the digest gate admits it
        FUZZ_GRAPH=w,h,ids: a graph model (OCR, vision), run once by stz_graph_probe on zeros of its declared inputs,
        or ids 0..ids-1, or a w x h image -- and its PROGRAM (stz.ocr.program) mutated line by line too: every
        number, the operation, the first input, the line dropped (FUZZ_EVERY=<k>: every k-th line, default 3)
        FUZZ_VLM=1: a picture projector (mmproj), loaded and run once by stz_vlm_probe
        FUZZ_SPARSE=1 FUZZ_LAST=<n>: tensor cases only for blk.0, blk.<n> and the tensors outside the blocks
        (for a big seed: each 145 MB mutant costs about a second to write)
child:  python -I gguf_fuzz.py --child <dll_dir> <mutant.gguf>

Measured 2026-11-08 on the engine before the fix: 149 of 714 MiniLM mutants ended the process. After: 0 of 714,
0 of 844 on jina-reranker, and on SmolLM2 (sparse, the keys it reads) 0 of 565 where 12 had ended it.
"""
import ctypes, hashlib, math, os, re, struct, subprocess, sys, time, zlib

T_U8, T_I8, T_U16, T_I16, T_U32, T_I32, T_F32, T_BOOL, T_STR, T_ARR, T_U64, T_I64, T_F64 = range(13)
SCALAR = {T_U8: '<B', T_I8: '<b', T_U16: '<H', T_I16: '<h', T_U32: '<I', T_I32: '<i', T_F32: '<f', T_BOOL: '<B',
          T_U64: '<Q', T_I64: '<q', T_F64: '<d'}


# ---------------------------------------------------------------- the GGUF model (kept as raw bytes per part)
class Gguf:
    def __init__(self, b):
        self.b = b
        o = 0
        assert b[:4] == b'GGUF'
        self.version, self.nt, self.nkv = struct.unpack_from('<IQQ', b, 4)
        o = 24
        self.kvs = []  # [key(str), type, raw value bytes]
        for _ in range(self.nkv):
            k, o = rstr(b, o)
            t = struct.unpack_from('<I', b, o)[0]; o += 4
            o2 = skipval(b, o, t)
            self.kvs.append([k, t, b[o:o2]])
            o = o2
        self.tis = []  # [name, raw rest: n_dims dims type offset]
        for _ in range(self.nt):
            n, o = rstr(b, o)
            nd = struct.unpack_from('<I', b, o)[0]
            o2 = o + 4 + 8 * nd + 4 + 8
            self.tis.append([n, b[o:o2]])
            o = o2
        self.align = 32
        for k, t, v in self.kvs:
            if k == 'general.alignment' and t == T_U32: self.align = struct.unpack('<I', v)[0]
        self.meta_end = o
        self.data_start = (o + self.align - 1) // self.align * self.align
        self.data = b[self.data_start:]

    def emit(self, kvs=None, tis=None, nt=None, nkv=None, version=None, data=None):
        kvs = self.kvs if kvs is None else kvs
        tis = self.tis if tis is None else tis
        out = bytearray(b'GGUF')
        out += struct.pack('<IQQ', self.version if version is None else version,
                           len(tis) if nt is None else nt, len(kvs) if nkv is None else nkv)
        for k, t, v in kvs:
            out += wstr(k) + struct.pack('<I', t) + v
        for n, rest in tis:
            out += wstr(n) + rest
        pad = (-len(out)) % self.align
        out += b'\0' * pad
        out += self.data if data is None else data
        return bytes(out)


def rstr(b, o):
    n = struct.unpack_from('<Q', b, o)[0]
    return b[o + 8:o + 8 + n].decode('utf-8', 'replace'), o + 8 + n


def wstr(s):
    e = s.encode() if isinstance(s, str) else s
    return struct.pack('<Q', len(e)) + e


def skipval(b, o, t):
    if t in SCALAR: return o + struct.calcsize(SCALAR[t])
    if t == T_STR: return o + 8 + struct.unpack_from('<Q', b, o)[0]
    if t == T_ARR:
        et, n = struct.unpack_from('<IQ', b, o); o += 12
        if et in SCALAR: return o + n * struct.calcsize(SCALAR[et])
        for _ in range(n): o = skipval(b, o, et)
        return o
    raise ValueError(t)


def val(t, x):  # encode one value of type t
    if t in SCALAR: return struct.pack(SCALAR[t], x)
    if t == T_STR: return wstr(x)
    raise ValueError(t)


def arr(et, items):
    return struct.pack('<IQ', et, len(items)) + b''.join(val(et, x) for x in items)


# ---------------------------------------------------------------- the cases
def cases(g):
    b = g.b
    yield ('identity (re-emitted seed)', g.emit())
    # 1. the header: counts and version
    for nt in [0, 1, len(g.tis) + 1, 2**31, 2**63 - 1, 2**64 - 1]:
        yield ('hdr n_tensors=%d' % nt, g.emit(nt=nt))
    for nkv in [0, len(g.kvs) + 1, 2**31, 2**63 - 1, 2**64 - 1]:
        yield ('hdr n_kv=%d' % nkv, g.emit(nkv=nkv))
    for v in [0, 1, 2, 4, 2**32 - 1]:
        yield ('hdr version=%d' % v, g.emit(version=v))
    yield ('hdr magic', b'GGUX' + b[4:])
    # 2. truncation, through the header, the metadata and into the data
    for cut in [0, 3, 4, 8, 16, 23, 24, 30, 40, 64, 128, 1000, g.meta_end // 4, g.meta_end // 2, g.meta_end - 1,
                g.meta_end, g.data_start + 1, len(b) // 2, len(b) - 1]:
        yield ('trunc %d' % cut, b[:cut])
    # 3. a key's string length lies
    o = 24
    k0 = g.kvs[0]
    for L in [2**64 - 1, 2**63, 2**40, len(b), 0]:
        yield ('key0 len=%d' % L, b[:24] + struct.pack('<Q', L) + b[32:])
    # 4. every key: wrong types, empty and huge values, removed
    wrongs = [('u8', T_U8, 7), ('i32 -1', T_I32, -1), ('u32 max', T_U32, 2**32 - 1), ('i64 min', T_I64, -2**63),
              ('u64 max', T_U64, 2**64 - 1), ('f32', T_F32, 1.5), ('bool', T_BOOL, 1), ('str', T_STR, 'x'),
              ('str empty', T_STR, ''), ('f64 nan', T_F64, float('nan'))]
    for i, (k, t, v) in enumerate(g.kvs):
        for wn, wt, wv in wrongs:
            if wt == t: continue
            kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, wt, val(wt, wv)]
            yield ('kv %s -> %s' % (k, wn), g.emit(kvs=kv2))
        for an, ad in [('arr u32[3]', arr(T_U32, [1, 2, 3])), ('arr str[0]', arr(T_STR, [])),
                       ('arr str[1]', arr(T_STR, ['a'])), ('arr i8[0]', arr(T_I8, []))]:
            kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, ad]
            yield ('kv %s -> %s' % (k, an), g.emit(kvs=kv2))
        kv2 = [list(x) for x in g.kvs if x[0] != k]
        yield ('kv %s removed' % k, g.emit(kvs=kv2))
        if t == T_ARR:
            et, n = struct.unpack_from('<IQ', v, 0)
            kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, struct.pack('<IQ', et, 0)]
            yield ('kv %s emptied' % k, g.emit(kvs=kv2))
            kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, struct.pack('<IQ', et, n + 1) + v[12:]]
            yield ('kv %s count+1' % k, g.emit(kvs=kv2))
            kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, struct.pack('<IQ', et, 2**62) + v[12:]]
            yield ('kv %s count=2^62' % k, g.emit(kvs=kv2))
            if et in SCALAR and n > 1:  # half the items: the array is shorter than its sibling arrays
                sz = struct.calcsize(SCALAR[et]); h = n // 2
                kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, struct.pack('<IQ', et, h) + v[12:12 + h * sz]]
                yield ('kv %s halved' % k, g.emit(kvs=kv2))
            if et == T_STR and n > 1:
                items, o2 = [], 12
                for _ in range(n // 2):
                    s, o2 = rstr(v, o2); items.append(s)
                kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, arr(T_STR, items)]
                yield ('kv %s halved' % k, g.emit(kvs=kv2))
                kv2 = [list(x) for x in g.kvs]; kv2[i] = [k, T_ARR, arr(T_U32, list(range(n)))]
                yield ('kv %s -> arr u32 same n' % k, g.emit(kvs=kv2))
    # 5. tensors: renamed (missing), shapes, types, offsets
    for j, (n, rest) in enumerate(g.tis):
        nd = struct.unpack_from('<I', rest, 0)[0]
        dims = list(struct.unpack_from('<%dQ' % nd, rest, 4))
        tt, off = struct.unpack_from('<IQ', rest, 4 + 8 * nd)
        def ti(nd2=nd, dims2=None, tt2=tt, off2=off, name=n):
            d2 = dims if dims2 is None else dims2
            t2 = [list(x) for x in g.tis]; t2[j] = [name, struct.pack('<I', nd2) + struct.pack('<%dQ' % len(d2), *d2) + struct.pack('<IQ', tt2, off2)]
            return t2
        sparse = os.environ.get('FUZZ_SPARSE')  # a big seed: tensors of the first and last block and the others
        if sparse and ('blk.' in n and not n.startswith('blk.0.') and not n.startswith('blk.%d.' % (int(os.environ.get('FUZZ_LAST', '0'))))):
            continue
        yield ('t %s renamed' % n, g.emit(tis=ti(name=n + '.x')))
        if not sparse and j > 3 and j < len(g.tis) - 3 and j % 7: continue  # the rest only on a sample of tensors
        yield ('t %s dims0=0' % n, g.emit(tis=ti(dims2=[0] + dims[1:])))
        yield ('t %s dims0*2' % n, g.emit(tis=ti(dims2=[dims[0] * 2] + dims[1:])))
        yield ('t %s dims0=2^62' % n, g.emit(tis=ti(dims2=[2**62] + dims[1:])))
        yield ('t %s transposed' % n, g.emit(tis=ti(dims2=list(reversed(dims)))))
        yield ('t %s n_dims=5' % n, g.emit(tis=ti(nd2=5, dims2=dims + [1] * (5 - nd))))
        yield ('t %s n_dims=1 flat' % n, g.emit(tis=ti(nd2=1, dims2=[math.prod(dims)])))
        yield ('t %s type=999' % n, g.emit(tis=ti(tt2=999)))
        yield ('t %s type=f32' % n, g.emit(tis=ti(tt2=0)))
        yield ('t %s type=f16' % n, g.emit(tis=ti(tt2=1)))
        yield ('t %s type=q8_0' % n, g.emit(tis=ti(tt2=8)))
        yield ('t %s offset=2^62' % n, g.emit(tis=ti(off2=2**62)))
        yield ('t %s offset=end' % n, g.emit(tis=ti(off2=len(g.data))))
        yield ('t %s offset+1' % n, g.emit(tis=ti(off2=off + 1)))
    dup = [list(x) for x in g.tis]; dup[1] = [g.tis[0][0], g.tis[1][1]]
    yield ('t duplicate name', g.emit(tis=dup))
    yield ('t none', g.emit(tis=[]))


# ---------------------------------------------------------------- the graph models (OCR, vision): their PROGRAM too
OPS = ['conv', 'convt', 'pad', 'win', 'ln', 'repeat', 'pool', 'resize', 'step2', 'slice', 'embed', 'gap', 'up', 'concat',
       'add', 'mul', 'linear', 'matmul', 'permute', 'reshape', 'heads', 'relu', 'softmax', 'mean']


def program_of(g):
    for i, (k, t, v) in enumerate(g.kvs):
        if k == 'stz.ocr.program':
            n = struct.unpack_from('<Q', v, 4)[0]
            o, lines = 12, []
            for _ in range(n):
                x, o = rstr(v, o); lines.append(x)
            return i, lines
    return None, []


def with_program(g, i, lines):
    kv2 = [list(x) for x in g.kvs]
    kv2[i] = ['stz.ocr.program', T_ARR, arr(T_STR, lines)]
    return g.emit(kvs=kv2)


def graph_cases(g):
    yield ('identity (re-emitted seed)', g.emit())
    # the stz keys: every wrong type, removed
    for c in cases(g):
        name = c[0]
        if name.startswith('kv ') and ('stz.' in name or 'general.architecture' in name):
            yield c
        elif name.startswith('trunc ') or name.startswith('hdr n_'):
            yield c
    i, lines = program_of(g)
    if i is None:
        return
    every = int(os.environ.get('FUZZ_EVERY', '3'))
    for li, line in enumerate(lines):
        if li % every and li != len(lines) - 1:
            continue
        def put(new, why):
            l2 = list(lines); l2[li] = new
            return ('prog %d %s' % (li, why), with_program(g, i, l2))
        out, rest = line.split('=', 1)
        op = rest.split('(', 1)[0]
        # every number in the line: 0, -1, huge, +1, doubled
        nums = list(re.finditer(r'(?<![A-Za-z_])-?\d+', rest))
        for mi, mt in enumerate(nums[:6]):
            for nv, why in [('0', 'zero'), ('-1', 'neg'), ('2147483647', 'huge'), (str(int(mt.group()) + 1), 'plus1'),
                            (str(int(mt.group()) * 2), 'double')]:
                if nv == mt.group():
                    continue
                r2 = rest[:mt.start()] + nv + rest[mt.end():]
                yield put(out + '=' + r2, 'num%d %s' % (mi, why))
        # another operation on the same arguments
        for o2 in OPS:
            if o2 != op and (zlib.crc32(('%d %s' % (li, o2)).encode()) % 4 == 0):
                yield put(out + '=' + o2 + rest[len(op):], 'op %s->%s' % (op, o2))
        # the first input replaced by the image input, and by a name nothing made
        yield put(out + '=' + re.sub(r'\(([^,;)]+)', '(x', rest, count=1), 'input0 x')
        yield put(out + '=' + re.sub(r'\(([^,;)]+)', '(nosuch', rest, count=1), 'input0 missing')
        # the line dropped
        yield ('prog %d dropped' % li, with_program(g, i, lines[:li] + lines[li + 1:]))
    yield ('prog empty', with_program(g, i, []))
    # tensors: a sample
    for c in cases(g):
        if c[0].startswith('t ') and (zlib.crc32(c[0].encode()) % 5 == 0 or 'renamed' in c[0]):
            yield c


def vlm_cases(g):
    yield ('identity (re-emitted seed)', g.emit())
    for c in cases(g):
        name = c[0]
        if name.startswith('kv ') and ('clip.' in name or 'general.architecture' in name):
            yield c
        elif name.startswith('t ') and ('blk.' not in name or '.blk.0.' in name or zlib.crc32(name.encode()) % 7 == 0):
            yield c


def vlm_child(dll_dir, path):
    cap_memory(2 << 30)
    os.add_dll_directory(dll_dir)
    d = ctypes.CDLL(os.path.join(dll_dir, 'stz_neural.dll'))
    sys.stdout.write('vlm|'); sys.stdout.flush()
    print('ok' if d.stz_vlm_probe(path.encode(), 1) == 1 else 'refused')


def graph_child(dll_dir, path, w, h, n_ids):
    cap_memory(2 << 30)
    os.add_dll_directory(dll_dir)
    d = ctypes.CDLL(os.path.join(dll_dir, 'stz_neural.dll'))
    d.stz_graph_probe_error.restype = ctypes.c_char_p
    sys.stdout.write('probe|'); sys.stdout.flush()
    r = d.stz_graph_probe(path.encode(), int(w), int(h), int(n_ids))
    if r == 1:
        print('ok')
    else:
        print('refused: ' + d.stz_graph_probe_error().decode('utf-8', 'replace')[:160])


# ---------------------------------------------------------------- the child: one mutant, the exported text path
def cap_memory(limit):
    k = ctypes.windll.kernel32
    class IO(ctypes.Structure):
        _fields_ = [(f, ctypes.c_ulonglong) for f in ('a', 'b', 'c', 'd', 'e', 'f')]
    class BASIC(ctypes.Structure):
        _fields_ = [('PerProcessUserTimeLimit', ctypes.c_longlong), ('PerJobUserTimeLimit', ctypes.c_longlong),
                    ('LimitFlags', ctypes.c_uint32), ('MinimumWorkingSetSize', ctypes.c_size_t),
                    ('MaximumWorkingSetSize', ctypes.c_size_t), ('ActiveProcessLimit', ctypes.c_uint32),
                    ('Affinity', ctypes.c_size_t), ('PriorityClass', ctypes.c_uint32),
                    ('SchedulingClass', ctypes.c_uint32)]
    class EXT(ctypes.Structure):
        _fields_ = [('Basic', BASIC), ('Io', IO), ('ProcessMemoryLimit', ctypes.c_size_t),
                    ('JobMemoryLimit', ctypes.c_size_t), ('PeakProcessMemoryUsed', ctypes.c_size_t),
                    ('PeakJobMemoryUsed', ctypes.c_size_t)]
    k.CreateJobObjectW.restype = ctypes.c_void_p
    h = k.CreateJobObjectW(None, None)
    e = EXT(); e.Basic.LimitFlags = 0x100  # JOB_OBJECT_LIMIT_PROCESS_MEMORY
    e.ProcessMemoryLimit = limit
    assert k.SetInformationJobObject(ctypes.c_void_p(h), 9, ctypes.byref(e), ctypes.sizeof(e))
    k.GetCurrentProcess.restype = ctypes.c_void_p
    assert k.AssignProcessToJobObject(ctypes.c_void_p(h), ctypes.c_void_p(k.GetCurrentProcess()))


def child(dll_dir, path):
    cap_memory(2 << 30)
    os.add_dll_directory(dll_dir)
    d = ctypes.CDLL(os.path.join(dll_dir, 'stz_neural.dll'))
    d.neural_model_arch.restype = ctypes.c_char_p
    d.neural_rerank.restype = ctypes.c_double
    step = lambda s: (sys.stdout.write(s + '|'), sys.stdout.flush())
    step('load')
    r = d.neural_model_load(path.encode())
    if r != 1:
        print('refused status=%d' % d.neural_model_load_status()); return
    step('meta'); d.neural_model_arch(); d.neural_model_n_embd(); d.neural_model_n_layers(); d.neural_model_n_vocab()
    d.neural_model_n_heads(); d.neural_model_n_ctx(); d.neural_model_kv_count(); d.neural_model_n_tensors()
    t = b'the engine reads a model file as data'
    step('tok'); d.neural_tokenize(t, len(t))
    step('emb'); d.neural_embed_text(t, len(t))
    if d.neural_model_has_ner(): step('ner'); d.neural_ner(t, len(t))
    if d.neural_model_has_reranker(): step('rerank'); d.neural_rerank(t, len(t), t, len(t))
    if d.neural_model_has_generator(): step('gen'); d.neural_generate(t, len(t), 2)
    step('free'); d.neural_model_free()
    print('ok')


def main():
    dll_dir, seed, work, log = sys.argv[1:5]
    flt = sys.argv[5] if len(sys.argv) > 5 else ''
    g = Gguf(open(seed, 'rb').read())
    os.makedirs(work, exist_ok=True)
    mut = os.path.join(work, 'mutant.gguf')
    print('seed %s (%d kv, %d tensors)' % (os.path.basename(seed), len(g.kvs), len(g.tis)), flush=True)
    bad = 0
    n = 0
    with open(log, 'a', encoding='utf-8') as L:
        graph = os.environ.get('FUZZ_GRAPH')  # "w,h,ids": a graph model, run through stz_graph_probe
        vlm = os.environ.get('FUZZ_VLM')  # a picture projector, run through stz_vlm_probe (load, then one encode)
        for name, data in (vlm_cases(g) if vlm else graph_cases(g) if graph else cases(g)):
            if flt and not re.search(flt, name): continue  # a regex over the case names
            n += 1
            open(mut, 'wb').write(data)
            h = hashlib.sha256(data).hexdigest()
            open(os.path.join(work, 'SHA256SUMS'), 'w').write('%s  mutant.gguf\n' % h)
            t0 = time.time()
            try:
                argv = ([sys.executable, '-I', __file__, '--vlm-child', dll_dir, mut] if vlm
                        else [sys.executable, '-I', __file__, '--graph-child', dll_dir, mut] + graph.split(',') if graph
                        else [sys.executable, '-I', __file__, '--child', dll_dir, mut])
                p = subprocess.run(argv, capture_output=True, text=True, timeout=120)
                rc, out = p.returncode, (p.stdout.strip() + ' ' + p.stderr.strip()[-300:]).strip()
            except subprocess.TimeoutExpired as e:
                rc, out = 'TIMEOUT', ''
            dt = time.time() - t0
            clean = rc == 0 and (out.endswith('ok') or 'refused' in out)
            line = '%s|%s|rc=%s|%.1fs|%s' % ('ok ' if clean else 'BAD', name, rc, dt, out.replace('\n', ' ')[-400:])
            L.write(line + '\n'); L.flush()
            if not clean:
                bad += 1; print(line, flush=True)
    print('done: %d cases, %d BAD' % (n, bad), flush=True)


if __name__ == '__main__':
    if sys.argv[1] == '--child': child(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == '--graph-child': graph_child(*sys.argv[2:7])
    elif sys.argv[1] == '--vlm-child': vlm_child(sys.argv[2], sys.argv[3])
    else: main()
