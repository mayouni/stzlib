load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG1 SLICE 0 -- IS A GPU FORCE LAYOUT REPRODUCIBLE?

	SOFTANZA_GRAPH_PLANE_PLAN.md, GG1 kill criteria, written before any code:

	    "both DETERMINISTIC (a seeded layout must reproduce byte-identically,
	     or no guard can ever assert a picture)"
	    "If a seeded layout is not reproducible run-to-run, STOP -- a
	     non-deterministic layout cannot be guarded, and an unguardable
	     renderer is not shippable here."

	So this is measured BEFORE a layout engine exists, because the answer
	decides whether one gets built at all.

	WHY IT IS A REAL QUESTION. GG0's reachability propagated with integer
	OR -- associative, commutative, exact, and reproducible no matter what
	order the hardware runs in. A force layout accumulates FLOATS, and
	float addition is not associative: (a+b)+c != a+(b+c) in general. If the
	summation order can vary between runs, the layout cannot reproduce, and
	nothing built on it can be guarded.

	THE DESIGN UNDER TEST: one thread per node, each accumulating its own
	forces in INDEX ORDER, with no atomics and no cross-thread reduction.
	If the order is fixed by construction, the sum is fixed. This file asks
	whether that holds in practice on this card -- and asks the opposite
	question too, because a determinism claim with no negative sibling is
	just a claim that the numbers happened to match.

	Run:  ring graph_layout_determinism.ring
	It writes graph_layout_hash.txt on first run and COMPARES on later ones,
	which is how cross-PROCESS reproducibility gets tested at all.
---------------------------------------------------------------------------*/

decimals(6)

if NOT StzGraphicsDevice()
	? "No GPU device -- this probe has nothing to measure."
	return
ok
? "device : " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""

#---------------------------------------------------------------------------
# The graph: built from a FORMULA, never from random(). A seeded layout
# cannot be reproducible if its input is not.
#---------------------------------------------------------------------------

N = 1000
aOff = []
aTgt = []
nEdges = 0
for i = 0 to N - 1
	aOff + nEdges
	# each node links to three others, deterministically
	for k = 1 to 3
		aTgt + ((i * 7 + k * 131 + 17) % N)
		nEdges++
	next
next
aOff + nEdges

? "graph  : " + N + " nodes, " + nEdges + " edges (formula-built, no RNG)"

#---------------------------------------------------------------------------
# One thread per node. Repulsion loops EVERY node in index order; attraction
# loops the node's edges in slot order. No atomics, no shared-memory
# reduction, no subgroup ops -- the accumulation order is a property of the
# source, not of the scheduler.
#---------------------------------------------------------------------------

cStep = 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> posIn : array<f32>;
@group(0) @binding(2) var<storage, read_write> posOut : array<f32>;
@group(0) @binding(3) var<storage, read> off : array<u32>;
@group(0) @binding(4) var<storage, read> tgt : array<u32>;
@group(0) @binding(5) var<storage, read> par : array<f32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let i = gid.x + tile.xoff * 64u;
  let n = u32(par[0]);
  let kk = par[1];
  let temp = par[2];
  if (i >= n) { return; }

  let px = posIn[i * 2u];
  let py = posIn[i * 2u + 1u];
  var dx = 0.0;
  var dy = 0.0;

  // repulsion from every node, in INDEX ORDER
  for (var j = 0u; j < n; j = j + 1u) {
    if (j == i) { continue; }
    let ox = px - posIn[j * 2u];
    let oy = py - posIn[j * 2u + 1u];
    var d2 = ox * ox + oy * oy;
    if (d2 < 0.01) { d2 = 0.01; }
    let f = (kk * kk) / d2;
    dx = dx + ox * f;
    dy = dy + oy * f;
  }

  // attraction along this node edges, in SLOT ORDER
  let s = off[i];
  let e = off[i + 1u];
  for (var q = s; q < e; q = q + 1u) {
    let j = tgt[q];
    let ox = posIn[j * 2u] - px;
    let oy = posIn[j * 2u + 1u] - py;
    let d = sqrt(ox * ox + oy * oy);
    if (d > 0.0001) {
      let f = d / kk;
      dx = dx + ox * f;
      dy = dy + oy * f;
    }
  }

  // cool: cap the step, so the layout settles instead of oscillating
  let mag = sqrt(dx * dx + dy * dy);
  if (mag > 0.0001) {
    let capped = min(mag, temp);
    dx = dx / mag * capped;
    dy = dy / mag * capped;
  }
  posOut[i * 2u] = px + dx;
  posOut[i * 2u + 1u] = py + dy;
}'

hStep = StzEngineGpuKernelCompile(cStep)
if hStep = 0
	? "kernel refused: " + StzEngineGpuLastError()
	return
ok

hOff = StzEngineGpuBufferNew((N + 1) * 4)
StzEngineGpuBufferUploadListU32(hOff, aOff)
hTgt = StzEngineGpuBufferNew(nEdges * 4)
StzEngineGpuBufferUploadListU32(hTgt, aTgt)

#---------------------------------------------------------------------------
# A run: seed positions on a golden-angle spiral (a formula, so the seed is
# reproducible too), then iterate.
#---------------------------------------------------------------------------

aSeed = []
for i = 0 to N - 1
	nA = i * 2.399963229728653          # golden angle, radians
	nR = 12 * sqrt(i + 1)
	aSeed + (nR * cos(nA))
	aSeed + (nR * sin(nA))
next

ITERS = 60

nT0 = clock()
cA = RunLayout(hStep, hOff, hTgt, aSeed, N, ITERS)
nT1 = clock()
cB = RunLayout(hStep, hOff, hTgt, aSeed, N, ITERS)
nT2 = clock()

? "iters  : " + ITERS + "   run A " + ((nT1-nT0)/clockspersecond()*1000) + " ms" +
  "   run B " + ((nT2-nT1)/clockspersecond()*1000) + " ms"
? ""

#---------------------------------------------------------------------------
? "-- 1. Same input, same process: byte-identical? ---------------"
#---------------------------------------------------------------------------

? "   values A : " + len(cA) + "   values B : " + len(cB)
bSame = SameFloats(cA, cB)
? "   BIT-IDENTICAL : " + bSame
if NOT bSame
	? "   differing values : " + CountDiff(cA, cB) + " of " + len(cA)
ok

#---------------------------------------------------------------------------
? ""
? "-- 2. The negative sibling: does the check DISCRIMINATE? ------"
#
# A byte comparison that says "identical" proves nothing unless it can also
# say "different". One extra iteration must change the answer.
#---------------------------------------------------------------------------

cC = RunLayout(hStep, hOff, hTgt, aSeed, N, ITERS + 1)
? "   one more iteration differs : " + (NOT SameFloats(cC, cA))

# and a different SEED must differ too
aSeed2 = []
for i = 0 to N - 1
	nA = i * 2.399963229728653 + 0.5
	nR = 12 * sqrt(i + 1)
	aSeed2 + (nR * cos(nA))
	aSeed2 + (nR * sin(nA))
next
cD = RunLayout(hStep, hOff, hTgt, aSeed2, N, ITERS)
? "   a different seed differs   : " + (NOT SameFloats(cD, cA))

#---------------------------------------------------------------------------
? ""
? "-- 3. Across PROCESSES -- what a guard actually needs ---------"
#
# A guard runs in a fresh process. In-process reproducibility is necessary
# but not sufficient; the shader is recompiled, the device re-created, and
# the buffers re-allocated. That is the real question.
#---------------------------------------------------------------------------

decimals(17)
cHash = "" + len(cA) + ":" + Digest(cA)
decimals(6)
cFile = "graph_layout_hash.txt"
if fexists(cFile)
	cPrev = ring_trim(read(cFile))
	? "   previous run : " + cPrev
	? "   this run     : " + cHash
	? "   REPRODUCED ACROSS PROCESSES : " + (cPrev = cHash)
else
	write(cFile, cHash)
	? "   first run -- wrote " + cFile + " = " + cHash
	? "   run this file AGAIN to test cross-process reproducibility."
ok

? ""
? "-- 4. Scale: what does the kill criterion cost? ---------------"
#
# GG1's other kill line: a 10,000-node layout must converge in under 2 s.
#---------------------------------------------------------------------------

BIG = 10000
aBOff = []
aBTgt = []
nBE = 0
for i = 0 to BIG - 1
	aBOff + nBE
	for k = 1 to 3
		aBTgt + ((i * 7 + k * 131 + 17) % BIG)
		nBE++
	next
next
aBOff + nBE
hBOff = StzEngineGpuBufferNew((BIG + 1) * 4)
StzEngineGpuBufferUploadListU32(hBOff, aBOff)
hBTgt = StzEngineGpuBufferNew(nBE * 4)
StzEngineGpuBufferUploadListU32(hBTgt, aBTgt)

aBSeed = []
for i = 0 to BIG - 1
	nA = i * 2.399963229728653
	nR = 12 * sqrt(i + 1)
	aBSeed + (nR * cos(nA))
	aBSeed + (nR * sin(nA))
next

nT3 = clock()
cBig = RunLayout(hStep, hBOff, hBTgt, aBSeed, BIG, ITERS)
nT4 = clock()
nBigMs = (nT4 - nT3) / clockspersecond() * 1000
? "   " + BIG + " nodes x " + ITERS + " iterations : " + nBigMs + " ms"
? "   kill line is 2000 ms  ->  " + iif(nBigMs < 2000, "PASS", "FAIL")

#---------------------------------------------------------------------------
? ""
? "-- 5. Does it SETTLE, or just stop? ---------------------------"
#
# The kill line says "converge to a stable configuration". A cooling
# schedule guarantees the STEPS reach zero -- that is termination, not
# convergence, and the two are easy to confuse. So measure the residual:
# how far does the furthest node still move at each stage?
#---------------------------------------------------------------------------

aPrev = RunLayout(hStep, hOff, hTgt, aSeed, N, 10)
for nStage in [ 20, 30, 40, 50, 60, 80, 110 ]
	aNow = RunLayout(hStep, hOff, hTgt, aSeed, N, nStage)
	nMax = 0
	for i = 1 to len(aNow) step 2
		nDx = aNow[i] - aPrev[i]
		nDy = aNow[i+1] - aPrev[i+1]
		nD = sqrt(nDx*nDx + nDy*nDy)
		if nD > nMax  nMax = nD  ok
	next
	? "   by iteration " + nStage + " : furthest node still moved " + nMax + " px"
	aPrev = aNow
next

#---------------------------------------------------------------------------
? ""
? "-- 6. And is it a GRAPH DRAWING, or deterministic mush? -------"
#
# A layout that reproduces perfectly and looks like a disc has proved
# nothing worth having. The picture is the check that the numbers are not.
#---------------------------------------------------------------------------

aFinal = RunLayout(hStep, hOff, hTgt, aSeed, N, 80)
nMinX = aFinal[1]  nMaxX = aFinal[1]
nMinY = aFinal[2]  nMaxY = aFinal[2]
for i = 1 to len(aFinal) step 2
	if aFinal[i] < nMinX    nMinX = aFinal[i]    ok
	if aFinal[i] > nMaxX    nMaxX = aFinal[i]    ok
	if aFinal[i+1] < nMinY  nMinY = aFinal[i+1]  ok
	if aFinal[i+1] > nMaxY  nMaxY = aFinal[i+1]  ok
next
? "   extent : x " + nMinX + ".." + nMaxX + "   y " + nMinY + ".." + nMaxY

oC = new stzCanvas(900, 900)
oC.SetBackground("#0B1020")
nSc = 840 / max([ nMaxX - nMinX, nMaxY - nMinY, 1 ])
# edges first, so nodes sit on top
for i = 0 to N - 1
	for q = aOff[i+1] + 1 to aOff[i+2]
		j = aTgt[q]
		oC.AddLineQ(
			30 + (aFinal[i*2+1] - nMinX) * nSc, 30 + (aFinal[i*2+2] - nMinY) * nSc,
			30 + (aFinal[j*2+1] - nMinX) * nSc, 30 + (aFinal[j*2+2] - nMinY) * nSc).
			Stroke("#2E4470", 1)
	next
next
for i = 0 to N - 1
	oC.AddCircleQ(30 + (aFinal[i*2+1] - nMinX) * nSc,
		      30 + (aFinal[i*2+2] - nMinY) * nSc, 3).
		Fill(StzColorFromHSL((i * 360 / N) % 360, 70, 60))
next
cPng = oC.ToPNG("graph_layout_1k.png")
? "   graph_layout_1k.png : " + len(cPng) + " bytes"

#---------------------------------------------------------------------------
? ""
? "-- 7. Does STRUCTURE survive the layout? ----------------------"
#
# Section 6 drew an even blob -- and that is the CORRECT drawing of the
# graph it was given: (i*7 + k*131) % N is a pseudo-random expander with no
# communities, and a force layout of an expander is a disc. So it proved
# the pipeline runs, and nothing about whether the layout is worth having.
#
# This one hands it a graph that HAS structure -- 6 dense clusters, sparse
# links between them -- and measures whether the structure comes out:
# mean distance WITHIN a cluster against mean distance BETWEEN clusters.
# A layout that reveals communities separates them; a broken one does not,
# and the ratio says which without anybody squinting at a picture.
#---------------------------------------------------------------------------

CL = 6
CN = 120                       # nodes per cluster
CTOT = CL * CN
aCOff = []
aCTgt = []
nCE = 0
for i = 0 to CTOT - 1
	aCOff + nCE
	nMine = floor(i / CN)
	# 4 dense links inside my own cluster
	for k = 1 to 4
		aCTgt + (nMine * CN + ((i * 13 + k * 29 + 7) % CN))
		nCE++
	next
	# 1 sparse bridge to the next cluster, from a few nodes only
	if (i % 40) = 0
		aCTgt + (((nMine + 1) % CL) * CN + ((i * 17) % CN))
		nCE++
	ok
next
aCOff + nCE
? "   clustered graph : " + CTOT + " nodes, " + nCE + " edges, " + CL + " communities"

hCOff = StzEngineGpuBufferNew((CTOT + 1) * 4)
StzEngineGpuBufferUploadListU32(hCOff, aCOff)
hCTgt = StzEngineGpuBufferNew(nCE * 4)
StzEngineGpuBufferUploadListU32(hCTgt, aCTgt)

aCSeed = []
for i = 0 to CTOT - 1
	nA = i * 2.399963229728653
	nR = 12 * sqrt(i + 1)
	aCSeed + (nR * cos(nA))
	aCSeed + (nR * sin(nA))
next

aCL = RunLayout(hStep, hCOff, hCTgt, aCSeed, CTOT, 140)

# cluster centroids
aCx = []  aCy = []
for c = 1 to CL
	nSx = 0  nSy = 0
	for i = (c-1)*CN to c*CN - 1
		nSx += aCL[i*2+1]
		nSy += aCL[i*2+2]
	next
	aCx + (nSx / CN)
	aCy + (nSy / CN)
next

# mean radius within a cluster
nWithin = 0
for c = 1 to CL
	nS = 0
	for i = (c-1)*CN to c*CN - 1
		nDx = aCL[i*2+1] - aCx[c]
		nDy = aCL[i*2+2] - aCy[c]
		nS += sqrt(nDx*nDx + nDy*nDy)
	next
	nWithin += nS / CN
next
nWithin = nWithin / CL

# mean distance between cluster centroids
nBetween = 0  nPairs = 0
for a = 1 to CL
	for b = a + 1 to CL
		nDx = aCx[a] - aCx[b]
		nDy = aCy[a] - aCy[b]
		nBetween += sqrt(nDx*nDx + nDy*nDy)
		nPairs++
	next
next
nBetween = nBetween / nPairs

? "   mean radius WITHIN a cluster : " + nWithin
? "   mean distance BETWEEN them   : " + nBetween
? "   separation ratio             : " + (nBetween / nWithin) +
  "   (>1 means the communities came apart)"

# and draw it, coloured BY CLUSTER so the eye can check the number
nMinX = aCL[1]  nMaxX = aCL[1]  nMinY = aCL[2]  nMaxY = aCL[2]
for i = 1 to len(aCL) step 2
	if aCL[i] < nMinX    nMinX = aCL[i]    ok
	if aCL[i] > nMaxX    nMaxX = aCL[i]    ok
	if aCL[i+1] < nMinY  nMinY = aCL[i+1]  ok
	if aCL[i+1] > nMaxY  nMaxY = aCL[i+1]  ok
next
oK = new stzCanvas(900, 900)
oK.SetBackground("#0B1020")
nSc2 = 840 / max([ nMaxX - nMinX, nMaxY - nMinY, 1 ])
for i = 0 to CTOT - 1
	for q = aCOff[i+1] + 1 to aCOff[i+2]
		j = aCTgt[q]
		oK.AddLineQ(
			30 + (aCL[i*2+1] - nMinX) * nSc2, 30 + (aCL[i*2+2] - nMinY) * nSc2,
			30 + (aCL[j*2+1] - nMinX) * nSc2, 30 + (aCL[j*2+2] - nMinY) * nSc2).
			Stroke("#263A63", 1)
	next
next
for i = 0 to CTOT - 1
	oK.AddCircleQ(30 + (aCL[i*2+1] - nMinX) * nSc2,
		      30 + (aCL[i*2+2] - nMinY) * nSc2, 4).
		Fill(StzColorFromHSL(floor(i / CN) * 60, 75, 60))
next
? "   graph_layout_clusters.png : " + len(oK.ToPNG("graph_layout_clusters.png")) + " bytes"

? ""
? "=============================================================="
? " VERDICT"
? "=============================================================="
? " in-process reproducible : " + bSame
? " check discriminates     : " + ((NOT SameFloats(cC,cA)) and (NOT SameFloats(cD,cA)))
? " 10k in " + nBigMs + " ms (limit 2000)"
? "=============================================================="

#---------------------------------------------------------------------------
# Ring runs a file top-down until the first func and never returns, so the
# helper lives below everything.
#---------------------------------------------------------------------------

func RunLayout hK, hO, hT, aSeed, n, nIters
	_hA_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hB_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hP_ = StzEngineGpuBufferNew(16)
	StzEngineGpuBufferUploadList(_hA_, aSeed)

	# Fruchterman-Reingold's k: the ideal edge length for the area
	_k_ = sqrt((1000 * 1000) / n)
	_src_ = _hA_
	_dst_ = _hB_
	_wx_ = ceil(n / 64)
	for _it_ = 1 to nIters
		# Temperature cools on an ABSOLUTE schedule -- a function of the
		# iteration NUMBER, never of the total. Normalising by the total was
		# the first thing written here and it is subtly wrong: it makes
		# run(30) a different schedule from run(20), not run(20) plus ten
		# steps, so "how far did it still move between stage K and K+1"
		# measures two unrelated runs and answers noise. With an absolute
		# schedule, run(K+1) IS run(K) advanced by one step, which is what
		# makes a residual mean anything.
		_t_ = 100 * pow(0.94, _it_ - 1)
		StzEngineGpuBufferUploadList(_hP_, [ n, _k_, _t_, 0 ])
		StzEngineGpuDispatch(hK, [ _src_, _dst_, hO, hT, _hP_ ], _wx_, 1)
		_tmp_ = _src_
		_src_ = _dst_
		_dst_ = _tmp_
	next
	StzEngineGpuSync()
	_out_ = StzEngineGpuBufferDownloadList(_src_, n * 2)
	StzEngineGpuBufferFree(_hA_)
	StzEngineGpuBufferFree(_hB_)
	StzEngineGpuBufferFree(_hP_)
	return _out_

# Ring list `=` is ALWAYS FALSE, even for identical lists, so identity has
# to be checked element by element. The values are f32 promoted to f64 --
# a lossless promotion -- so `=` on each element IS a bit-identity test.
func SameFloats aX, aY
	if len(aX) != len(aY)
		return FALSE
	ok
	_n_ = len(aX)
	for _i_ = 1 to _n_
		if aX[_i_] != aY[_i_]
			return FALSE
		ok
	next
	return TRUE

func CountDiff aX, aY
	_d_ = 0
	_n_ = len(aX)
	for _i_ = 1 to _n_
		if aX[_i_] != aY[_i_]
			_d_++
		ok
	next
	return _d_

# A digest that survives a process boundary. decimals(17) round-trips an
# f32-valued double exactly, so the text carries every bit the GPU produced.
func Digest aX
	_o_ = ""
	_n_ = len(aX)
	for _i_ = 1 to _n_
		_o_ += "" + aX[_i_] + ";"
	next
	return StzEngineCryptoSha256(_o_)
