# SPIKE -- can a graph compute its own picture on the GPU?
# Exact transitive reachability by BITSET PROPAGATION: reach[u] |= reach[v]
# for every edge u->v, iterated to the DAG's depth. impact = popcount - 1.
load "../../stzBase.ring"

C_BYTES = 2
StzGraphicsDevice()
? "device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())

cSeed = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read_write> reach : array<u32>;
@group(0) @binding(2) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];
  if (i >= n) { return; }
  reach[i * w + (i / 32u)] = reach[i * w + (i / 32u)] | (1u << (i % 32u));
}'

cProp = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> src : array<u32>;
@group(0) @binding(2) var<storage, read_write> dst : array<u32>;
@group(0) @binding(3) var<storage, read> off : array<u32>;
@group(0) @binding(4) var<storage, read> tgt : array<u32>;
@group(0) @binding(5) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];
  if (i >= n) { return; }
  let s = off[i];  let e = off[i + 1u];
  for (var k = 0u; k < w; k = k + 1u) {
    var acc = src[i * w + k];
    for (var q = s; q < e; q = q + 1u) { acc = acc | src[tgt[q] * w + k]; }
    dst[i * w + k] = acc;
  }
}'

cFinal = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> reach : array<u32>;
@group(0) @binding(2) var<storage, read_write> impact : array<f32>;
@group(0) @binding(3) var<storage, read> par : array<u32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = par[0];  let w = par[1];
  if (i >= n) { return; }
  var c = 0u;
  for (var k = 0u; k < w; k = k + 1u) { c = c + countOneBits(reach[i * w + k]); }
  impact[i] = f32(c) - 1.0;
}'

hSeed = StzEngineGpuKernelCompile(cSeed)
hProp = StzEngineGpuKernelCompile(cProp)
hFin  = StzEngineGpuKernelCompile(cFinal)
? "kernels: " + hSeed + " " + hProp + " " + hFin

aSizes = [ 512, 1024, 10000 ]
nLayers = 20

_aNN119_ = aSizes
_nNN119_ = len(_aNN119_)
for _iNN119_ = 1 to _nNN119_
	nN = _aNN119_[_iNN119_]
    # --- a deterministic layered DAG: every edge goes to a later layer
    aOff = []  aTgt = []
    nPerL = ceil(nN / nLayers)
    nSeedV = 12345
    for i = 0 to nN - 1
        aOff + len(aTgt)
        nLayer = floor(i / nPerL)
        if nLayer < nLayers - 1
            for d = 1 to 3
                nSeedV = (nSeedV * 1103515245 + 12345) % 2147483648
                nOff2 = nPerL + (nSeedV % nPerL)
                nT = i + nOff2
                if nT < nN  aTgt + nT  ok
            next
        ok
    next
    aOff + len(aTgt)
    nW = ceil(nN / 32)

    # --- the CURRENT path: the same algorithm, in Ring
    nT0 = clock()
    aR = list(nN * nW)
    for i = 1 to nN * nW  aR[i] = 0  next
    for i = 0 to nN - 1
        aR[i * nW + floor(i/32) + 1] = aR[i * nW + floor(i/32) + 1] | (1 << (i % 32))
    next
    for it = 1 to nLayers
        for i = 0 to nN - 1
            nS = aOff[i+1]  nE = aOff[i+2]
            for k = 0 to nW - 1
                nAcc = aR[i * nW + k + 1]
                for q = nS to nE - 1
                    nAcc = nAcc | aR[aTgt[q+1] * nW + k + 1]
                next
                aR[i * nW + k + 1] = nAcc
            next
        next
    next
    aRingImpact = []
    for i = 0 to nN - 1
        nC = 0
        for k = 0 to nW - 1
            nV = aR[i * nW + k + 1]
            while nV != 0
                nC += (nV & 1)
                nV = (nV >> 1) & 2147483647
            end
        next
        aRingImpact + (nC - 1)
    next
    nRingMs = (clock() - nT0) / clocksPerSecond() * 1000

    # --- the GPU path
    hOff = StzEngineGpuBufferNew(len(aOff) * 4)
    hTgt = StzEngineGpuBufferNew(_AtLeast4(len(aTgt) * 4))
    hPar = StzEngineGpuBufferNew(16)
    hA   = StzEngineGpuBufferNew(nN * nW * 4)
    hB   = StzEngineGpuBufferNew(nN * nW * 4)
    hImp = StzEngineGpuBufferNew(nN * 4)
    StzEngineGpuBufferUploadListU32(hOff, aOff)
    if len(aTgt) > 0  StzEngineGpuBufferUploadListU32(hTgt, aTgt)  ok
    StzEngineGpuBufferUploadListU32(hPar, [ nN, nW, 0, 0 ])
    StzEngineGpuSync()

    StzEngineGpuCountersReset()
    nT1 = clock()
    nWX = ceil(nN / 64)
    StzEngineGpuDispatch(hSeed, [ hA, hPar ], nWX, 1)
    bSrcIsA = TRUE
    for it = 1 to nLayers
        if bSrcIsA
            StzEngineGpuDispatch(hProp, [ hA, hB, hOff, hTgt, hPar ], nWX, 1)
        else
            StzEngineGpuDispatch(hProp, [ hB, hA, hOff, hTgt, hPar ], nWX, 1)
        ok
        bSrcIsA = NOT bSrcIsA
    next
    if bSrcIsA
        StzEngineGpuDispatch(hFin, [ hA, hImp, hPar ], nWX, 1)
    else
        StzEngineGpuDispatch(hFin, [ hB, hImp, hPar ], nWX, 1)
    ok
    StzEngineGpuSync()
    nGpuMs = (clock() - nT1) / clocksPerSecond() * 1000
    nBytesDuringCompute = StzEngineGpuCounter(C_BYTES)

    aGpuImpact = StzEngineGpuBufferDownloadList(hImp, nN)
    nBad = 0
    for i = 1 to nN
        if aGpuImpact[i] != aRingImpact[i]  nBad++  ok
    next

    ? ""
    ? "n=" + nN + " edges=" + len(aTgt) + " words/node=" + nW
    ? "  ring : " + nRingMs + " ms"
    ? "  gpu  : " + nGpuMs + " ms   speedup " + (nRingMs / _AtLeastTiny(nGpuMs)) + "x"
    ? "  mismatches vs ring: " + nBad + "   bytes on the bus DURING compute: " +
      nBytesDuringCompute
    ? "  max impact: " + max(aGpuImpact)

    StzEngineGpuBufferFree(hOff)  StzEngineGpuBufferFree(hTgt)
    StzEngineGpuBufferFree(hPar)  StzEngineGpuBufferFree(hA)
    StzEngineGpuBufferFree(hB)    StzEngineGpuBufferFree(hImp)
next

func _AtLeast4 pn
	if pn < 4  return 4  ok
	return pn

func _AtLeastTiny pn
	if pn < 0.001  return 0.001  ok
	return pn
