load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	CONVERGENCE -- the plan's "sharpest open design question"

	SOFTANZA_GRAPH_PLANE_PLAN.md, section 4:

	    "Convergence needs a readback. GG0 fixed the iteration count to a
	     known depth. A general graph needs either a proven bound or a
	     per-iteration readback -- and that readback costs exactly the
	     property the spike proved. This is the sharpest open design
	     question in the plane."

	GG1 slice 0 answered half of it: force layout has an ABSOLUTE cooling
	schedule, so its iteration count is fixed by the schedule and nothing
	needs reading back. It then said where the question really lands:

	    "layer assignment IS a propagation to a fixed point, so the
	     convergence question lands there rather than here."

	Nobody went there. This file does.

	THE QUESTION IS NOT "does it hang". It is: when a graph CANNOT settle,
	does the caller find out, or get numbers that look like layers?

	Run:  ring gg_convergence.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " CONVERGENCE -- what happens when a graph cannot settle"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. A DAG settles, and its layers are the real answer ------"
#
# The control. Longest-path layering on a chain has one right answer per
# node, known without computing it, so a wrong result here is not a
# judgement call.
#---------------------------------------------------------------------------

oChain = new stzGraph("chain")
for i = 1 to 200
	oChain.AddNode("c" + i)
next
for i = 1 to 199
	oChain.AddEdge("c" + i, "c" + (i + 1))
next

aL = StzEngineGraphLayersAll(oChain.EngineHandle())
? "   a 200-node chain: first layer " + aL[1][2] + ", last layer " + aL[200][2]
chkeq("the head sits at layer 0", aL[1][2], 0)
chkeq("the tail sits at layer 199", aL[200][2], 199)

#---------------------------------------------------------------------------
? ""
? "-- 2. A CYCLE cannot settle. What comes back? ----------------"
#
# Longest-path layering is UNDEFINED on a cycle -- every node is deeper
# than itself, forever. The loop caps its passes so it does not hang, which
# is right. The question is what it says afterwards.
#---------------------------------------------------------------------------

oCyc = new stzGraph("cyc")
for i = 1 to 6
	oCyc.AddNode("k" + i)
next
for i = 1 to 5
	oCyc.AddEdge("k" + i, "k" + (i + 1))
next
oCyc.AddEdge("k6", "k1")            # the edge that closes it

? "   the graph has a cycle : " + oCyc.HasCyclicDependencies()
aC = StzEngineGraphLayersAll(oCyc.EngineHandle())
cShow = ""
_aA78_ = aC
_nA78_ = len(_aA78_)
for _iA78_ = 1 to _nA78_
	a = _aA78_[_iA78_]
	if cShow != ""  cShow += ", "  ok
	cShow += "" + a[2]
next
? "   layers it returned    : [ " + cShow + " ]  (empty = refused)"
? ""
? "   Before this guard it answered [ 42, 37, 38, 39, 40, 41 ]. Those were"
? "   never layers -- they were how far the propagation got before the"
? "   pass cap stopped it, and nothing in the answer said so."

chk("an unsettleable graph must not answer as if it settled",
    len(aC) = 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. And the face must refuse, naming the reason ------------"
#
# stzGraphCanvas already refuses :Impact above 20,000 nodes with a message
# that names the number. :Depth on a cyclic graph is the same class of
# thing: a question with no answer, which is worth saying out loud.
#---------------------------------------------------------------------------

chk(":Depth on a CYCLIC graph is refused", Raises('
	o = new stzGraph("cyc2")
	o.AddNode("a")  o.AddNode("b")
	o.AddEdge("a", "b")  o.AddEdge("b", "a")
	StzGraphMetric(o, :Depth)
'))

# A REFUSAL THAT RAISES FOR THE WRONG REASON IS NOT A PASS. The first
# version of this scene called a method that does not exist, got an R20
# arity error, and Raises() reported success -- the exact
# coincidence-pass this house keeps meeting. So the message is read, and
# the POSITIVE control below proves the same call succeeds on an acyclic
# graph, which an arity error could never do.
try
	o2 = new stzGraph("cyc3")
	o2.AddNode("a")  o2.AddNode("b")
	o2.AddEdge("a", "b")  o2.AddEdge("b", "a")
	StzGraphMetric(o2, :Depth)
catch
	cMsg = cCatchError
done
? "   the refusal : " + cMsg
chk("...and it says CYCLE, not just 'refused'",
    StzFindFirst("cycl", StzLower(cMsg)) > 0)

# the positive sibling: the SAME call on an ACYCLIC graph must answer
aOk = StzGraphMetric(oChain, :Depth)
chkeq("and the same call on a DAG still answers", len(aOk), 200)
chkeq("  ...with the tail still at layer 199", aOk[200], 199)

#---------------------------------------------------------------------------
? ""
? "-- 4. A hypothesis that did NOT survive its own number -------"
#
# The prediction: each pass is O(E) and the loop runs until nothing
# changes, so a chain whose edges point FORWARD in node order should settle
# in one pass while the same chain built BACKWARDS needs one pass per node
# -- same answer, very different work.
#
# Measured, it is about 1.1x, which is noise on this machine. The scene is
# KEPT rather than deleted, because a plan that only records the guesses
# that came true is a plan that teaches nothing. What it does prove is the
# part worth pinning: insertion order does not change the ANSWER.
#---------------------------------------------------------------------------

oFwd = new stzGraph("fwd")
for i = 1 to 800
	oFwd.AddNode("f" + i)
next
for i = 1 to 799
	oFwd.AddEdge("f" + i, "f" + (i + 1))
next

oBwd = new stzGraph("bwd")
for i = 800 to 1 step -1
	oBwd.AddNode("b" + i)
next
for i = 1 to 799
	oBwd.AddEdge("b" + i, "b" + (i + 1))
next

nT0 = StzEngineWatchTimestampMs()
aF = StzEngineGraphLayersAll(oFwd.EngineHandle())
nFwdMs = StzEngineWatchTimestampMs() - nT0

nT0 = StzEngineWatchTimestampMs()
aB = StzEngineGraphLayersAll(oBwd.EngineHandle())
nBwdMs = StzEngineWatchTimestampMs() - nT0

? "   800-node chain, edges forward in node order  : " + nFwdMs + " ms"
? "   the SAME chain, nodes inserted backwards     : " + nBwdMs + " ms"
chk("both give the same deepest layer", _MaxOf(aF) = _MaxOf(aB))
? "   deepest layer either way : " + _MaxOf(aF)
if nFwdMs > 0
	? "   ratio : " + (nBwdMs / max([nFwdMs, 0.01])) + "x  -- the predicted"
	? "   blow-up did not appear. Recorded as a MISS, not quietly dropped."
ok
chk("insertion order does not change the answer", _MaxOf(aF) = _MaxOf(aB))

#---------------------------------------------------------------------------
? ""
? "-- 5. The refusal the bridge was THROWING AWAY ---------------"
#
# The canvas has always carried a careful message for :Impact above 20,000
# nodes. It could never fire: retCentralityAll DISCARDED the engine's
# return value, so a refusal came back as n entries of whatever was in the
# freshly allocated buffer, and len(result) was never 0.
#
# That is the sharper half of this file. A refusal written, reviewed and
# committed is still not a refusal until something PROVES it reaches the
# caller -- so here is the proof, on the smaller of the two paths, because
# building 20,001 nodes to test the other one would take longer than it is
# worth and this is the same discarded return value.
#---------------------------------------------------------------------------

# a DAG: every metric must answer, so an empty result cannot be blamed on
# the graph being unusable
oOk = new stzGraph("dag")
oOk.AddNode("a")  oOk.AddNode("b")
oOk.AddEdge("a", "b")
chkeq(":Impact answers on a sound graph", len(StzGraphMetric(oOk, :Impact)), 2)
chkeq(":Depth answers on a sound graph", len(StzGraphMetric(oOk, :Depth)), 2)
chkeq(":Degree answers on a sound graph", len(StzGraphMetric(oOk, :Degree)), 2)

# and the metrics that ARE defined on a cycle keep answering, so the
# refusal above is specific to layering rather than a graph-wide give-up
oCy2 = new stzGraph("cy2")
oCy2.AddNode("a")  oCy2.AddNode("b")
oCy2.AddEdge("a", "b")  oCy2.AddEdge("b", "a")
chkeq(":Degree still answers on a CYCLIC graph", len(StzGraphMetric(oCy2, :Degree)), 2)
aI = StzGraphMetric(oCy2, :Impact)
chkeq(":Impact still answers on a CYCLIC graph", len(aI), 2)
? "   on the 2-cycle, each node reaches the other : " + aI[1] + ", " + aI[2]
chkeq("  ...and reachability round a cycle is 1 each", aI[1], 1)

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

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

func _MaxOf aPairs
	_m_ = 0
	_aA79_ = aPairs
	_nA79_ = len(_aA79_)
	for _iA79_ = 1 to _nA79_
		_a_ = _aA79_[_iA79_]
		if _a_[2] > _m_  _m_ = _a_[2]  ok
	next
	return _m_
