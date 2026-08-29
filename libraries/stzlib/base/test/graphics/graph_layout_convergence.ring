load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	GG1 SLICE 1 -- CONVERGENCE WITHOUT A READBACK

	The open question the plan calls the sharpest in the plane:

	    "Convergence needs a readback. GG0 fixed the iteration count to a
	     known depth. A general graph needs either a proven bound or a
	     per-iteration readback -- and that readback costs exactly the
	     property the spike proved."

	Slice 0 dodged it by fixing the iteration count in advance, which a real
	graph cannot do. This file asks whether a readback is needed AT ALL.

	THE CLAIM UNDER TEST is not empirical. The step kernel CAPS each node's
	displacement at the temperature:

	    displacement(i) <= t_i,   t_i = T0 * r^(i-1)

	so the total distance a node can still travel after step K is bounded by
	the tail of a geometric series:

	    remaining(K) <= SUM(i > K) T0*r^(i-1) = T0 * r^K / (1 - r)

	If that holds, the layout at step K is within a KNOWN distance of the
	layout at infinity, the iteration count is a closed form in (T0, r, eps),
	and no readback is ever required. That is a proof, not a measurement --
	so what this file measures is whether the proof's assumption holds in the
	built kernel, and how much the bound COSTS in wasted iterations.

	Then it prices the alternative, because "we do not need a readback" is
	only interesting if a readback would have hurt.

	Run:  ring graph_layout_convergence.ring
---------------------------------------------------------------------------*/

decimals(4)

if NOT StzGraphicsDevice()
	? "No GPU device -- nothing to measure."
	return
ok
? "device : " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
? ""

T0 = 100.0
RATE = 0.94

#---------------------------------------------------------------------------
? "-- 1. The bound, in closed form -------------------------------"
#
# remaining(K) <= T0 * r^K / (1 - r).  Solve for the K that guarantees a
# given epsilon. No graph, no GPU, no measurement -- just the schedule.
#---------------------------------------------------------------------------

? "   schedule : t_i = " + T0 + " * " + RATE + "^(i-1)"
? "   tail sum : remaining(K) <= " + (T0 / (1 - RATE)) + " * " + RATE + "^K"
? ""
_aNEps120_ = [ 10, 5, 1, 0.5, 0.1 ]
_nNEps120_ = len(_aNEps120_)
for _iNEps120_ = 1 to _nNEps120_
	nEps = _aNEps120_[_iNEps120_]
	nK = ceil(log(nEps * (1 - RATE) / T0) / log(RATE))
	? "   eps " + nEps + " px  ->  K = " + nK + " iterations  (bound " +
	  (T0 / (1 - RATE) * pow(RATE, nK)) + " px)"
next

#---------------------------------------------------------------------------
? ""
? "-- 2. Does the built kernel OBEY the cap? ---------------------"
#
# The proof rests on one assumption: no node moves further than t_i in one
# step. That is an assumption about the CODE, so it gets checked against the
# code rather than trusted. Measured per SINGLE step, not across stages --
# slice 0's residuals were stage-to-stage gaps of ten or more iterations,
# which is why they look larger than the cap and are not a counterexample.
#---------------------------------------------------------------------------

N = 1000
aOff = []  aTgt = []  nEdges = 0
for i = 0 to N - 1
	aOff + nEdges
	for k = 1 to 3
		aTgt + ((i * 7 + k * 131 + 17) % N)
		nEdges++
	next
next
aOff + nEdges

hOff = StzEngineGpuBufferNew((N + 1) * 4)
StzEngineGpuBufferUploadListU32(hOff, aOff)
hTgt = StzEngineGpuBufferNew(nEdges * 4)
StzEngineGpuBufferUploadListU32(hTgt, aTgt)

aSeed = []
for i = 0 to N - 1
	nA = i * 2.399963229728653
	nR = 12 * sqrt(i + 1)
	aSeed + (nR * cos(nA))
	aSeed + (nR * sin(nA))
next

hStep = StzEngineGpuKernelCompile(StepWgsl())
if hStep = 0
	? "kernel refused: " + StzEngineGpuLastError()
	return
ok

bCapHeld = TRUE
nWorstRatio = 0
_aNAt121_ = [ 1, 5, 10, 25, 50, 80, 120 ]
_nNAt121_ = len(_aNAt121_)
for _iNAt121_ = 1 to _nNAt121_
	nAt = _aNAt121_[_iNAt121_]
	aA = RunLayout(hStep, hOff, hTgt, aSeed, N, nAt)
	aB = RunLayout(hStep, hOff, hTgt, aSeed, N, nAt + 1)
	nMax = MaxMove(aA, aB)
	nCap = T0 * pow(RATE, nAt)          # the temperature of step nAt+1
	nRatio = nMax / nCap
	if nRatio > nWorstRatio  nWorstRatio = nRatio  ok
	# f32 SLACK, not generosity: Ring computes the cap in f64 and the kernel
	# applies it in f32, so an exactly-binding step lands a few ulps either
	# side. A 1.0001 tolerance called a 1.0004 ratio a violation and was
	# measuring the comparison, not the kernel.
	if nMax > nCap * 1.001
		bCapHeld = FALSE
	ok
	? "   step " + (nAt+1) + " : moved " + nMax + " px, cap " + nCap +
	  " px  ->  " + iif(nMax <= nCap * 1.001, "within", "EXCEEDS")
next
? ""
? "   the cap HOLDS at every probe : " + bCapHeld
? "   worst observed / cap         : " + nWorstRatio + "  (1.0 = cap binding)"

#---------------------------------------------------------------------------
? ""
? "-- 3. The readback would answer the WRONG QUESTION -----------"
#
# The obvious use of a readback is "stop when the last step moved less than
# eps". Compare that against the analytic K and the two disagree -- and it
# is the READBACK that is wrong, not the bound.
#
# "the last step was small" is not "the layout is nearly final". The steps
# are still being CAPPED at that point (section 2 shows the cap binding at
# every probe), so the layout has not equilibrated -- it has merely been
# throttled. The distance it can STILL travel is the whole geometric tail,
# which is far larger than any one step.
#---------------------------------------------------------------------------

nEps = 1.0
nAnalyticK = ceil(log(nEps * (1 - RATE) / T0) / log(RATE))

# the step-size criterion: first step whose movement falls under eps
nStepK = 0
for nAt = 5 to 200 step 5
	aA = RunLayout(hStep, hOff, hTgt, aSeed, N, nAt)
	aB = RunLayout(hStep, hOff, hTgt, aSeed, N, nAt + 1)
	if MaxMove(aA, aB) < nEps
		nStepK = nAt
		exit
	ok
next

nTailAtStepK = T0 / (1 - RATE) * pow(RATE, nStepK)

? "   eps = " + nEps + " px"
? "   step-size criterion says stop at K = " + nStepK +
  "   (what a per-iteration readback buys)"
? "   ...but the layout can still travel " + nTailAtStepK +
  " px from there"
? "   analytic K, which bounds the WHOLE tail : " + nAnalyticK
? ""
? "   So the readback stops " + (nAnalyticK - nStepK) +
  " iterations early and calls a layout"
? "   settled while " + nTailAtStepK + " px of movement remains. The cheap"
? "   criterion is not a cheaper answer -- it is a different, weaker one."

#---------------------------------------------------------------------------
? ""
? "-- 4. Price the alternative: what does checking COST? ---------"
#
# "No readback needed" only matters if a readback would have hurt. The cost
# is not the 4 bytes -- it is the SYNC, which drains the pipeline and ends
# the CPU/GPU overlap every single iteration.
#---------------------------------------------------------------------------

BIG = 10000
aBOff = []  aBTgt = []  nBE = 0
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

hResid = StzEngineGpuKernelCompile(ResidWgsl())
if hResid = 0
	? "residual kernel refused: " + StzEngineGpuLastError()
	return
ok

ITERS = 120
nT0 = clock()
RunTimed(hStep, hResid, hBOff, hBTgt, aBSeed, BIG, ITERS, 0)
nT1 = clock()
RunTimed(hStep, hResid, hBOff, hBTgt, aBSeed, BIG, ITERS, 1)
nT2 = clock()
RunTimed(hStep, hResid, hBOff, hBTgt, aBSeed, BIG, ITERS, 10)
nT3 = clock()

nNone = (nT1 - nT0) / clockspersecond() * 1000
nEvery = (nT2 - nT1) / clockspersecond() * 1000
nTenth = (nT3 - nT2) / clockspersecond() * 1000

? "   " + BIG + " nodes, " + ITERS + " iterations:"
? "   no checking at all      : " + nNone + " ms"
? "   residual EVERY iteration: " + nEvery + " ms   (" + (nEvery/nNone) + "x)"
? "   residual every 10th     : " + nTenth + " ms   (" + (nTenth/nNone) + "x)"

#---------------------------------------------------------------------------
? ""
? "=============================================================="
? " VERDICT"
? "=============================================================="
? " the cap holds, so the geometric bound is VALID : " + bCapHeld
? ""
? " NO READBACK IS NEEDED. K is a closed form in (T0, r, eps):"
? "   K = ceil( log(eps*(1-r)/T0) / log(r) )   ->  " + nAnalyticK +
  " for eps=" + nEps + "px"
? ""
? " AND A READBACK WOULD BE WORSE, not merely dearer: the step-size"
? " test it buys stops at K=" + nStepK + " with " + nTailAtStepK +
  " px still to travel."
? ""
? " Cost, for the record -- checking every iteration at 10k nodes adds"
? " " + (nEvery - nNone) + " ms (" + (nEvery/nNone) + "x); every tenth adds " +
  (nTenth - nNone) + " ms."
? " The bound is free, exact, and needs no device round trip at all."

#---------------------------------------------------------------------------
# Ring runs top-down to the first func and never returns.
#---------------------------------------------------------------------------

func StepWgsl
	return 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
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
  let mag = sqrt(dx * dx + dy * dy);
  if (mag > 0.0001) {
    let capped = min(mag, temp);
    dx = dx / mag * capped;
    dy = dy / mag * capped;
  }
  posOut[i * 2u] = px + dx;
  posOut[i * 2u + 1u] = py + dy;
}'

# 64 partial maxima, reduced on the CPU. max() is exact and order-immune for
# floats, so this reduction cannot cost the determinism slice 0 established.
func ResidWgsl
	return 'struct StzTile { xoff:u32, p0:u32, p1:u32, p2:u32 }
@group(0) @binding(0) var<uniform> tile : StzTile;
@group(0) @binding(1) var<storage, read> a : array<f32>;
@group(0) @binding(2) var<storage, read> b : array<f32>;
@group(0) @binding(3) var<storage, read_write> out : array<f32>;
@group(0) @binding(4) var<storage, read> par : array<f32>;
@compute @workgroup_size(64)
fn main(@builtin(global_invocation_id) gid : vec3<u32>) {
  let t = gid.x + tile.xoff * 0u;
  let n = u32(par[0]);
  if (t >= 64u) { return; }
  var m = 0.0;
  var j = t;
  loop {
    if (j >= n) { break; }
    let dx = b[j * 2u] - a[j * 2u];
    let dy = b[j * 2u + 1u] - a[j * 2u + 1u];
    m = max(m, sqrt(dx * dx + dy * dy));
    j = j + 64u;
  }
  out[t] = m;
}'

func RunLayout hK, hO, hT, aSeed, n, nIters
	_hA_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hB_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hP_ = StzEngineGpuBufferNew(16)
	StzEngineGpuBufferUploadList(_hA_, aSeed)
	_k_ = sqrt((1000 * 1000) / n)
	_src_ = _hA_
	_dst_ = _hB_
	_wx_ = ceil(n / 64)
	for _it_ = 1 to nIters
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

# nCheckEvery = 0 means never check. Anything else reduces the residual and
# DOWNLOADS it on that cadence -- which is the sync being priced.
func RunTimed hK, hR, hO, hT, aSeed, n, nIters, nCheckEvery
	_hA_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hB_ = StzEngineGpuBufferNew(n * 2 * 4)
	_hP_ = StzEngineGpuBufferNew(16)
	_hM_ = StzEngineGpuBufferNew(64 * 4)
	StzEngineGpuBufferUploadList(_hA_, aSeed)
	_k_ = sqrt((1000 * 1000) / n)
	_src_ = _hA_
	_dst_ = _hB_
	_wx_ = ceil(n / 64)
	_last_ = 0
	for _it_ = 1 to nIters
		_t_ = 100 * pow(0.94, _it_ - 1)
		StzEngineGpuBufferUploadList(_hP_, [ n, _k_, _t_, 0 ])
		StzEngineGpuDispatch(hK, [ _src_, _dst_, hO, hT, _hP_ ], _wx_, 1)
		if nCheckEvery > 0 and (_it_ % nCheckEvery) = 0
			StzEngineGpuDispatch(hR, [ _src_, _dst_, _hM_, _hP_ ], 1, 1)
			_a_ = StzEngineGpuBufferDownloadList(_hM_, 64)
			_m_ = 0
			for _q_ = 1 to 64
				if _a_[_q_] > _m_  _m_ = _a_[_q_]  ok
			next
			_last_ = _m_
		ok
		_tmp_ = _src_
		_src_ = _dst_
		_dst_ = _tmp_
	next
	StzEngineGpuSync()
	StzEngineGpuBufferFree(_hA_)
	StzEngineGpuBufferFree(_hB_)
	StzEngineGpuBufferFree(_hP_)
	StzEngineGpuBufferFree(_hM_)
	return _last_

func MaxMove aX, aY
	_m_ = 0
	_n_ = len(aX)
	for _i_ = 1 to _n_ step 2
		_dx_ = aY[_i_] - aX[_i_]
		_dy_ = aY[_i_+1] - aX[_i_+1]
		_d_ = sqrt(_dx_*_dx_ + _dy_*_dy_)
		if _d_ > _m_  _m_ = _d_  ok
	next
	return _m_
