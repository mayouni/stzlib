load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE GRAPH PLANE -- GG1, GG2, GG3 in one guard

	Everything the graph plane has shipped was proven by SPIKES: standalone
	files that print numbers and are run by hand. None of it ran in a sweep,
	so a change to gpu_scene3d.zig or graph_layout.zig would have broken it
	silently. This file is the sweep.

	It asserts the PROPERTIES the phases were built on, not their pixels:

	  GG1  the layered sweep reduces crossings, never raises them, and
	       reproduces exactly -- on several topologies, because one graph
	       proves one graph
	  GG2  a picture is bound to a COMPUTED property: change the graph and
	       the picture changes, with nothing else touched
	  GG3  a child follows its parent, a detached child stops following,
	       and a cycle is refused rather than hung on

	Headless-safe: the parts needing a device announce themselves and skip.
---------------------------------------------------------------------------*/

decimals(3)
nOk = 0  nBad = 0

? "=============================================================="
? " THE GRAPH PLANE -- GG1 layout, GG2 face, GG3 hierarchy"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- GG1: the layered sweep ------------------------------------"
#---------------------------------------------------------------------------

# a band graph: a near-crossing-free order EXISTS, so a working sweep must
# find most of it. Started scrambled on purpose.
LAY = 14  WID = 16
N1 = LAY * WID
aU = []  aV = []
for L = 0 to LAY - 2
	for w = 0 to WID - 1
		for k = -1 to 1
			nT = w + k
			if nT >= 0 and nT < WID
				aU + (L * WID + w)
				aV + ((L + 1) * WID + nT)
			ok
		next
	next
next
aLayer = []
for i = 1 to N1  aLayer + floor((i - 1) / WID)  next
aStarts = []
for L = 0 to LAY  aStarts + (L * WID)  next

aOrder = []
for L = 0 to LAY - 1
	for w = 0 to WID - 1
		aOrder + (L * WID + ((w * 7 + L * 3) % WID))
	next
next
aCsr = InCsr(aU, aV, N1)
nBefore = StzEngineGraphLayoutCrossings(aU, aV, aLayer, PosOf(aOrder, aStarts, N1), aStarts)

aAfter = StzEngineGraphLayoutSweep(aCsr[1], aCsr[2], aLayer, aOrder, aStarts, 12, aU, aV)
nAfter = StzEngineGraphLayoutCrossings(aU, aV, aLayer, PosOf(aAfter, aStarts, N1), aStarts)

chk("a scrambled band has crossings to remove", nBefore > 0)
chk("the sweep REMOVES them  (" + nBefore + " -> " + nAfter + ")", nAfter < nBefore)

# NEVER WORSE, on a topology that once broke exactly this: wraparound
# adjacency, where a barycentre is meaningless and the sweep used to make
# the picture worse until best-keeping went in.
DL = 30  DW = 6
N2 = DL * DW
aU2 = []  aV2 = []
for L = 0 to DL - 2
	for w = 0 to DW - 1
		for k = 1 to 2
			aU2 + (L * DW + w)
			aV2 + ((L + 1) * DW + ((w + k) % DW))
		next
	next
next
aLayer2 = []
for i = 1 to N2  aLayer2 + floor((i - 1) / DW)  next
aStarts2 = []
for L = 0 to DL  aStarts2 + (L * DW)  next
aOrder2 = []
for L = 0 to DL - 1
	for w = 0 to DW - 1
		aOrder2 + (L * DW + ((w * 5 + L) % DW))
	next
next
aCsr2 = InCsr(aU2, aV2, N2)
nB2 = StzEngineGraphLayoutCrossings(aU2, aV2, aLayer2, PosOf(aOrder2, aStarts2, N2), aStarts2)
aAf2 = StzEngineGraphLayoutSweep(aCsr2[1], aCsr2[2], aLayer2, aOrder2, aStarts2, 12, aU2, aV2)
nA2 = StzEngineGraphLayoutCrossings(aU2, aV2, aLayer2, PosOf(aAf2, aStarts2, N2), aStarts2)
chk("on WRAPAROUND adjacency it is never worse  (" + nB2 + " -> " + nA2 + ")",
    nA2 <= nB2)

# reproducible, and the check discriminates
aOrderB = []
for L = 0 to LAY - 1
	for w = 0 to WID - 1
		aOrderB + (L * WID + ((w * 7 + L * 3) % WID))
	next
next
aAfterB = StzEngineGraphLayoutSweep(aCsr[1], aCsr[2], aLayer, aOrderB, aStarts, 12, aU, aV)
chk("the same input gives the same order", SameList(aAfter, aAfterB))

aOrderC = []
for L = 0 to LAY - 1
	for w = 0 to WID - 1
		aOrderC + (L * WID + ((w * 7 + L * 3) % WID))
	next
next
aAfterC = StzEngineGraphLayoutSweep(aCsr[1], aCsr[2], aLayer, aOrderC, aStarts, 3, aU, aV)
chk("  ...and a DIFFERENT sweep count differs", NOT SameList(aAfter, aAfterC))

# the force tier, in the engine
aSeed = []
for i = 1 to 60
	aSeed + (12 * sqrt(i) * cos(i * 2.39996))
	aSeed + (12 * sqrt(i) * sin(i * 2.39996))
next
aFOff = []  aFSrc = []
for i = 0 to 59  aFOff + i  aFSrc + ((i + 1) % 60)  next
aFOff + 60
aF1 = StzEngineGraphLayoutForce(aFOff, aFSrc, aSeed, 60, 130)
aSeed2 = []
for i = 1 to 60
	aSeed2 + (12 * sqrt(i) * cos(i * 2.39996))
	aSeed2 + (12 * sqrt(i) * sin(i * 2.39996))
next
aF2 = StzEngineGraphLayoutForce(aFOff, aFSrc, aSeed2, 60, 130)
chk("the force tier reproduces bit for bit", SameList(aF1, aF2))
chk("  ...and it actually MOVED the seed", NOT SameList(aF1, aSeed2))

#---------------------------------------------------------------------------
? ""
? "-- GG2: the picture is bound to a COMPUTED property ----------"
#---------------------------------------------------------------------------

oG = new stzGraph("supply")
oG.AddNodes([ "mine","smelt","chip","board","ecu","line","car" ])
oG.AddEdge("mine","smelt")   oG.AddEdge("smelt","chip")
oG.AddEdge("chip","board")   oG.AddEdge("board","ecu")
oG.AddEdge("ecu","line")     oG.AddEdge("line","car")

oGC = oG.GraphCanvas([ :Layout = :Hierarchical, :SizeBy = :Impact ])
aImp = oGC.MetricValues(:Impact)
chkeq("the root reaches every other node", aImp[1], 6)
chkeq("the sink reaches nothing", aImp[7], 0)
chkeq("depth counts the layers", oGC.MetricValues(:Depth)[7], 6)

# THE BINDING: change the GRAPH and the metric moves, nothing else touched
oG2 = new stzGraph("cut")
oG2.AddNodes([ "mine","smelt","chip","board","ecu","line","car" ])
oG2.AddEdge("mine","smelt")   oG2.AddEdge("chip","board")
oG2.AddEdge("board","ecu")    oG2.AddEdge("ecu","line")
oG2.AddEdge("line","car")
nCut = oG2.GraphCanvas([ :SizeBy = :Impact ]).MetricValues(:Impact)[1]
chk("cutting an edge REDUCES the root's impact  (6 -> " + nCut + ")", nCut < 6)

# an unknown metric is refused, not silently defaulted
chk("an unknown metric is REFUSED", Raises('
	oX = new stzGraph("x")
	oX.AddNode("a")
	oX.GraphCanvas([ :SizeBy = :Nonsense ])
'))

# a zero-area canvas is refused AT THE DOOR (a minimised window reports 0x0)
chk("a zero-size canvas is refused", Raises('
	oY = new stzGraph("y")
	oY.AddNode("a")
	oY.AddNode("b")
	oY.AddEdge("a","b")
	oZ = oY.GraphCanvas([])
	oZ.SetSize(0, 400)
'))

cSvg = oGC.ToSVG()
chk("the SVG tier answers with no device at all", len(cSvg) > 200)

aP1 = oG.GraphCanvas([ :Layout = :Hierarchical ]).Positions()
aP2 = oG.GraphCanvas([ :Layout = :Hierarchical ]).Positions()
bSame = TRUE
for i = 1 to len(aP1)
	if aP1[i][2] != aP2[i][2] or aP1[i][3] != aP2[i][3]  bSame = FALSE  exit  ok
next
chk("two builds of the same graph agree", bSame)

#---------------------------------------------------------------------------
? ""
? "-- GG3: a child follows its parent ---------------------------"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no GPU device -- the 3D scene scenes are skipped)"
else
	oBall = new stzMesh([ :Sphere, 0.5 ])
	oS = new stzScene(400, 300)
	oS.SetCamera(0, 5, 12, 0, 0, 0)
	oS.AddMesh(oBall, 0, 0, 0)     nSun = oS.LastIndex()
	oS.AddMesh(oBall, 4, 0, 0)     nEarth = oS.LastIndex()
	oS.AddMesh(oBall, 1.5, 0, 0)   nMoon = oS.LastIndex()

	chkeq("a flat scene has depth 0", oS.HierarchyDepth(), 0)
	oS.SetParent(nEarth, nSun)
	oS.SetParent(nMoon, nEarth)
	chkeq("two links make depth 2", oS.HierarchyDepth(), 2)

	chkeq("the moon sits at 4 + 1.5", oS.WorldPosition(nMoon)[1], 5.5)
	oS.MoveTo(nSun, 10, 0, 0)
	chkeq("move the SUN and the earth follows", oS.WorldPosition(nEarth)[1], 14)
	chkeq("  ...and the moon follows the earth", oS.WorldPosition(nMoon)[1], 15.5)

	oS.ClearParent(nMoon)
	chkeq("DETACHED, the moon keeps its own local transform",
	      oS.WorldPosition(nMoon)[1], 1.5)

	# order-independence: the resolver must not care who was added first
	oR2 = new stzScene(400, 300)
	oR2.SetCamera(0, 5, 12, 0, 0, 0)
	oR2.AddMesh(oBall, 1.5, 0, 0)   nChild = oR2.LastIndex()
	oR2.AddMesh(oBall, 4, 0, 0)     nMid   = oR2.LastIndex()
	oR2.AddMesh(oBall, 0, 0, 0)     nRoot  = oR2.LastIndex()
	oR2.SetParent(nChild, nMid)
	oR2.SetParent(nMid, nRoot)
	chkeq("a child added BEFORE its parent still resolves",
	      oR2.WorldPosition(nChild)[1], 5.5)
	chkeq("  ...with the same depth", oR2.HierarchyDepth(), 2)

	# a cycle answers rather than hanging
	oCy = new stzScene(300, 200)
	oCy.SetCamera(0, 5, 10, 0, 0, 0)
	oCy.AddMesh(oBall, 0, 0, 0)   nA = oCy.LastIndex()
	oCy.AddMesh(oBall, 2, 0, 0)   nB = oCy.LastIndex()
	oCy.SetParent(nA, nB)
	oCy.SetParent(nB, nA)
	chkeq("a parent CYCLE still answers", len(oCy.WorldPosition(nA)), 3)
	chk("  ...and the refusal is COUNTED", oCy.CyclesRefused() > 0)
	chk("parenting a node to itself is refused", oCy.SetParent(nA, nA) = FALSE)
	chk("an out-of-range parent is refused", oCy.SetParent(nA, 999) = FALSE)
ok

#---------------------------------------------------------------------------
? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------
# Ring runs a file top-down to the first func and never returns, so every
# helper lives below the last line of the guard.
#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func SameList aX, aY
	if len(aX) != len(aY)  return FALSE  ok
	_n_ = len(aX)
	for _i_ = 1 to _n_
		if aX[_i_] != aY[_i_]  return FALSE  ok
	next
	return TRUE

func PosOf aOrder, aStarts, n
	_p_ = []
	for _i_ = 1 to n  _p_ + 0  next
	_nl_ = len(aStarts) - 1
	for _L_ = 1 to _nl_
		_pp_ = 1
		for _i_ = aStarts[_L_] + 1 to aStarts[_L_ + 1]
			_p_[aOrder[_i_] + 1] = _pp_
			_pp_++
		next
	next
	return _p_

func InCsr aU, aV, n
	_cnt_ = []
	for _i_ = 1 to n  _cnt_ + 0  next
	_ne_ = len(aU)
	for _e_ = 1 to _ne_  _cnt_[aV[_e_] + 1]++  next
	_off_ = []  _acc_ = 0
	for _i_ = 1 to n  _off_ + _acc_  _acc_ += _cnt_[_i_]  next
	_off_ + _acc_
	_src_ = []
	for _i_ = 1 to _acc_  _src_ + 0  next
	_fill_ = []
	for _i_ = 1 to n  _fill_ + 0  next
	for _e_ = 1 to _ne_
		_v_ = aV[_e_]
		_src_[_off_[_v_ + 1] + _fill_[_v_ + 1] + 1] = aU[_e_]
		_fill_[_v_ + 1]++
	next
	return [ _off_, _src_ ]
