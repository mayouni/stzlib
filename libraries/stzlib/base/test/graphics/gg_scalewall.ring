load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE SCALE WALL -- the risk the plan NAMED and never measured

	SOFTANZA_GRAPH_PLANE_PLAN.md, section 4:

	    "Scale wall. Bitset reachability is O(n^2/8) -- fine at 10k, dead at
	     100k. Any claim past ~30k nodes needs a different algorithm, and the
	     plan says so rather than implying the 133x scales forever."

	Every other prediction in this plane got measured, and several named the
	wrong line. This one was still folklore. So: grow the graph until
	reachability stops telling the truth, and record WHERE.

	The answer is not 30,000. It is far lower, and it is not the bitset.

	Run:  ring gg_scalewall.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " THE SCALE WALL -- measured, not predicted"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. A star: one hub, N spokes. The hub reaches ALL of them -"
#
# The simplest graph whose answer is known without computing it. If
# ReachableFrom(hub) does not return exactly N, the engine is lying, and
# the size where it starts lying is the wall.
#---------------------------------------------------------------------------

? "     N     expected   ReachableFrom   ImpactOf   verdict"
? "   -----   --------   -------------   --------   -------"

aSizes = [ 100, 1000, 2000, 2500, 3000, 5000 ]
nFirstBad = 0

for nN in aSizes
	oS = new stzGraph("star" + nN)
	oS.AddNode("hub")
	for i = 1 to nN
		oS.AddNode("n" + i)
		oS.AddEdge("hub", "n" + i)
	next

	nGot = len(oS.ReachableFrom("hub"))
	nImp = oS.ImpactOf("hub")
	cV = "ok"
	if nGot != nN
		cV = "TRUNCATED"
		if nFirstBad = 0  nFirstBad = nN  ok
	ok
	? "   " + PadL("" + nN, 5) + "   " + PadL("" + nN, 8) + "   " +
	  PadL("" + nGot, 13) + "   " + PadL("" + nImp, 8) + "   " + cV
next

? ""
if nFirstBad > 0
	? "   THE WALL IS BETWEEN " + nFirstBad/2 + " AND " + nFirstBad + " NODES."
	? "   Not 30,000. And it is not the bitset -- it is a fixed 16 KB"
	? "   buffer in the bridge, filled with node NAMES."
ok
chkeq("a 5,000-spoke hub reaches all 5,000", _StarReach(5000), 5000)

#---------------------------------------------------------------------------
? ""
? "-- 2. Truncation must never invent a node -------------------"
#
# Worse than a short list: the last name can be cut mid-way, so the caller
# receives an id that is not a node in the graph. A short answer is wrong;
# a fabricated node is wrong in a way that survives into whatever consumes
# it.
#---------------------------------------------------------------------------

oT = new stzGraph("trunc")
oT.AddNode("hub")
for i = 1 to 5000
	oT.AddNode("node" + i)
	oT.AddEdge("hub", "node" + i)
next

aR = oT.ReachableFrom("hub")
nGhosts = 0
cGhost = ""
for c in aR
	if NOT oT.NodeExists(c)
		nGhosts++
		if cGhost = ""  cGhost = "" + c  ok
	ok
next
? "   returned " + len(aR) + " names, of which " + nGhosts + " are NOT nodes"
if cGhost != ""
	? "   first fabricated id : '" + cGhost + "'"
ok
chkeq("every name it returns is a real node", nGhosts, 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. The SAME wall stood behind six other calls -------------"
#
# Reachability was not special. BFS, DFS, shortest path, Dijkstra and A*
# all shared one writeNames helper with the same silent cut, and Neighbors
# had its own copy of it. Fixing the helper fixed them together -- which is
# why the guard has to check them together, or the next one to regress does
# it quietly.
#---------------------------------------------------------------------------

oW = new stzGraph("wide")
oW.AddNode("root")
for i = 1 to 4000
	oW.AddNode("member" + i)
	oW.AddEdge("root", "member" + i)
next

? "   a hub with 4,000 neighbours (well past the old 8 KB buffer):"
aN = oW.Neighbors("root")
chkeq("Neighbors returns all 4,000", len(aN), 4000)

aB = oW.BFS("root")
chkeq("BFS visits root + 4,000", len(aB), 4001)

aD = oW.DFS("root")
chkeq("DFS visits root + 4,000", len(aD), 4001)

# and none of them may invent a name
nBad2 = 0
for aList in [ aN, aB, aD ]
	for c in aList
		if NOT oW.NodeExists(c)  nBad2++  ok
	next
next
chkeq("no call fabricated a node id", nBad2, 0)

# a LONG path, so the path-returning calls cross the buffer too
oP = new stzGraph("long")
for i = 1 to 2000
	oP.AddNode("p" + i)
next
for i = 1 to 1999
	oP.AddEdge("p" + i, "p" + (i + 1))
next
aSP = oP.ShortestPath("p1", "p2000")
? "   a 2,000-node path, end to end : " + len(aSP) + " hops"
chkeq("ShortestPath returns the WHOLE path", len(aSP), 2000)
chk("its last hop is the destination", aSP[len(aSP)] = "p2000")

#---------------------------------------------------------------------------
? ""
? "-- 4. Where the bitset ACTUALLY stops -----------------------"
#
# The plan's number, tested on the primitive it was written about. This one
# REFUSES rather than truncating, which is the behaviour the other path
# should have had.
#---------------------------------------------------------------------------

oB = new stzGraph("chain")
for i = 1 to 3000
	oB.AddNode("c" + i)
next
for i = 1 to 2999
	oB.AddEdge("c" + i, "c" + (i + 1))
next

nT0 = StzEngineWatchTimestampMs()
aImp = StzEngineGraphImpactAll(oB.EngineHandle())
nMs = StzEngineWatchTimestampMs() - nT0
? "   3,000-node chain, impact for EVERY node : " + nMs + " ms"
chk("the bitset answered at 3,000 nodes", len(aImp) = 3000)
if len(aImp) = 3000
	? "   head of the chain reaches " + aImp[1][2] + ", tail reaches " + aImp[3000][2]
	chkeq("the head reaches every other node", aImp[1][2], 2999)
	chkeq("the tail reaches nothing", aImp[3000][2], 0)
ok

# and the REFUSAL above the cap is a refusal, not a zero-filled answer
? ""
? "   (the bitset refuses above 20,000 nodes by design, and the canvas"
? "    turns that refusal into a message naming the number -- checked in"
? "    gg2_graphcanvas. That is the behaviour scene 1 did NOT have.)"

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

func PadL c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ = " " + _s_  end
	return _s_

func _StarReach nN
	_o_ = new stzGraph("sr" + nN)
	_o_.AddNode("hub")
	for _i_ = 1 to nN
		_o_.AddNode("n" + _i_)
		_o_.AddEdge("hub", "n" + _i_)
	next
	return len(_o_.ReachableFrom("hub"))
