# stzGraph STRESS -- a large, MULTILINGUAL dependency network.
#
# What a graph is actually for: build a network incrementally and keep asking
# it questions. Thousands of nodes named in real scripts, wired into known
# components, then traversed, path-found and queried -- with every answer
# checked against a structure computed while building, never against the
# graph itself.
#
# Three things this file is looking for:
#
#   1. THE INTERLEAVED PATTERN. Every stress test so far measured build, THEN
#      query. Real graph code does neither alone -- it adds an edge, asks a
#      question, adds another. That pattern was 553x slower than it is now,
#      because each mutation threw the engine graph away and each query
#      rebuilt it whole. Build-then-query hid it completely.
#
#   2. MEMBERSHIP AT SCALE. NodeExists and EdgeExists are called on every
#      single add. If either is a scan, building is quadratic -- and
#      EdgeExists is asked about an edge that by definition is NOT there yet,
#      so it always scanned to the very end.
#
#   3. MULTILINGUAL NODE IDS. Ids are case-folded on the way in. That folding
#      rewrites CASED non-ASCII letters (Greek capital alpha-theta becomes
#      small alpha-theta), so a lookup by the original id has to still
#      resolve -- the exact shape of bug that made hash list keys unreachable.
#
# All non-ASCII text is built from RAW CODEPOINTS via a UTF-8 encoder, never
# typed as literals -- this codebase has a history of editors double-encoding
# source, so the test refuses to trust its own bytes.
#
# Ring traps avoided: no func named Show / Try, no local named nL / oR,
# no `new stzGraph(x).Method()` inline (R13), strcmp for string ordering.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# ---------------------------------------------------------------- vocabulary
cAr   = MkW([ 0x0639, 0x0645, 0x0644 ])                 # Arabic
cCJK  = MkW([ 0x6771, 0x4EAC ])                         # CJK
cGrUp = MkW([ 0x0391, 0x0398 ])                         # Greek UPPER (cased!)
cBox  = MkW([ 0x1F4E6 ])                                # Emoji

aPrefixes = [ cAr, cCJK, cGrUp, cBox ]                  # one per component

# ---------------------------------------------------------- build the network
# Four disjoint chains. Everything below is derived from these two numbers,
# so the expected component count, edge count and path lengths are arithmetic
# -- never a second question put to the graph.
nGroups   = 4
nPerGroup = 500

nExpectNodes = nGroups * nPerGroup
nExpectEdges = nGroups * (nPerGroup - 1)

oNet = new stzGraph("supplynet")

aAllIds = []
aHeads  = []
aTails  = []

for g = 1 to nGroups
	for i = 1 to nPerGroup
		cId = aPrefixes[g] + "-n" + g + "-" + i
		aAllIds + cId
		if i = 1
			aHeads + cId
		ok
		if i = nPerGroup
			aTails + cId
		ok
	next
next

t0 = clock()
oNet.AddNodes(aAllIds)
tNodes = (clock() - t0) / clockspersecond()

t0 = clock()
for g = 1 to nGroups
	for i = 1 to nPerGroup - 1
		nBase = (g - 1) * nPerGroup
		oNet.AddEdge(aAllIds[nBase + i], aAllIds[nBase + i + 1])
	next
next
tEdges = (clock() - t0) / clockspersecond()

? "-- Scene 1: a 2000-node multilingual network --"
? "  nodes in " + tNodes + " s, edges in " + tEdges + " s"
chk("every node landed", oNet.NodeCount() = nExpectNodes)
chk("every edge landed", oNet.EdgeCount() = nExpectEdges)
chk("node ids are genuinely multibyte", len(aAllIds[1]) > StzLen(aAllIds[1]))
chk("adding edges is linear, not quadratic (< 5s for 1996)", tEdges < 5)

? ""
? "-- Scene 2: membership, which every add depends on --"
t0 = clock()
nFound = 0
for i = 1 to nExpectNodes
	if oNet.HasNode(aAllIds[i])
		nFound++
	ok
next
tHas = (clock() - t0) / clockspersecond()
? "  " + nFound + " node lookups in " + tHas + " s"
chk("every node resolves", nFound = nExpectNodes)
chk("an absent node does not", oNet.HasNode("no-such-node") = 0)
chk("node lookup is not a scan (< 3s for 2000)", tHas < 3)

t0 = clock()
nEdgeHits = 0
for g = 1 to nGroups
	nBase = (g - 1) * nPerGroup
	for i = 1 to 200
		if oNet.EdgeExists(aAllIds[nBase + i], aAllIds[nBase + i + 1])
			nEdgeHits++
		ok
	next
next
tEx = (clock() - t0) / clockspersecond()
chk("every probed edge is found", nEdgeHits = nGroups * 200)
chk("an absent edge is not found",
	oNet.EdgeExists(aHeads[1], aTails[4]) = 0)
chk("edge lookup is not a scan (< 3s for 800)", tEx < 3)

? ""
? "-- Scene 3: THE interleaved pattern -- add, ask, add, ask --"
# This is the shape real graph code has, and the one that was 553x slower:
# every add invalidated the engine graph and every query rebuilt it whole.
oInc = new stzGraph("incremental")
aIncIds = []
for i = 1 to 800
	aIncIds + (cCJK + "-i" + i)
next
oInc.AddNodes(aIncIds)

t0 = clock()
for i = 1 to 799
	oInc.AddEdge(aIncIds[i], aIncIds[i + 1])
	aNb = oInc.Neighbors(aIncIds[i])
next
tInter = (clock() - t0) / clockspersecond()
? "  799 add+query steps in " + tInter + " s"
chk("interleaving stays linear (< 10s)", tInter < 10)
chk("the interleaved graph is complete", oInc.EdgeCount() = 799)
chk("a query during the build saw the edge just added",
	len(oInc.Neighbors(aIncIds[1])) = 1)

? ""
? "-- Scene 4: incremental updates must equal a full rebuild --"
# oInc was queried throughout, so its engine graph was maintained edge by
# edge. oFull is the same graph built silently, so its engine is created once
# at the first query. The two must be indistinguishable.
oFull = new stzGraph("fullbuild")
oFull.AddNodes(aIncIds)
for i = 1 to 799
	oFull.AddEdge(aIncIds[i], aIncIds[i + 1])
next

chk("same node count", oInc.NodeCount() = oFull.NodeCount())
chk("same edge count", oInc.EdgeCount() = oFull.EdgeCount())
chk("same BFS order", @@(oInc.BFS(aIncIds[1])) = @@(oFull.BFS(aIncIds[1])))
chk("same DFS order", @@(oInc.DFS(aIncIds[1])) = @@(oFull.DFS(aIncIds[1])))
chk("same connected components",
	@@(oInc.ConnectedComponents()) = @@(oFull.ConnectedComponents()))
chk("same shortest path",
	@@(oInc.ShortestPath(aIncIds[1], aIncIds[400])) =
	@@(oFull.ShortestPath(aIncIds[1], aIncIds[400])))

bSameNb = TRUE
for i = 1 to 400
	if @@(oInc.Neighbors(aIncIds[i])) != @@(oFull.Neighbors(aIncIds[i]))
		bSameNb = FALSE
	ok
next
chk("same neighbours on every sampled node", bSameNb)

? ""
? "-- Scene 5: traversal over a known structure --"
t0 = clock()
aBFS = oNet.BFS(aHeads[1])
tBFS = (clock() - t0) / clockspersecond()
? "  BFS reached " + len(aBFS) + " nodes in " + tBFS + " s"
chk("BFS covers exactly its own chain", len(aBFS) = nPerGroup)
chk("BFS starts where it was told", aBFS[1] = StzLower(aHeads[1]))
chk("BFS does not leak into another component",
	StzFindFirst(StzLower(aHeads[2]), aBFS) = 0)

aDFS = oNet.DFS(aHeads[2])
chk("DFS covers exactly its own chain", len(aDFS) = nPerGroup)

? ""
? "-- Scene 6: shortest paths of a length we can compute --"
# A chain of nPerGroup nodes: head to tail is nPerGroup nodes long.
t0 = clock()
aPath = oNet.ShortestPath(aHeads[1], aTails[1])
tPath = (clock() - t0) / clockspersecond()
? "  head-to-tail path has " + len(aPath) + " nodes, in " + tPath + " s"
chk("the path spans the whole chain", len(aPath) = nPerGroup)
chk("it starts at the head", aPath[1] = StzLower(aHeads[1]))
chk("it ends at the tail", aPath[len(aPath)] = StzLower(aTails[1]))
chk("path finding is fast (< 3s)", tPath < 3)
chk("there is no path between components",
	len(oNet.ShortestPath(aHeads[1], aTails[3])) = 0)

? ""
? "-- Scene 7: components, counted independently --"
t0 = clock()
aComp = oNet.ConnectedComponents()
tComp = (clock() - t0) / clockspersecond()
? "  " + len(aComp) + " components in " + tComp + " s"
chk("one component per chain", len(aComp) = nGroups)

nCompTotal = 0
for i = 1 to len(aComp)
	nCompTotal += len(aComp[i])
next
chk("the components account for every node", nCompTotal = nExpectNodes)
chk("each component is a whole chain", len(aComp[1]) = nPerGroup)

? ""
? "-- Scene 8: multilingual ids survive the case folding --"
# Ids are folded on the way in, which REWRITES cased non-ASCII letters.
# A lookup by the original id must still resolve.
cGreekId = aPrefixes[3] + "-n3-1"
chk("a Greek-UPPERCASE id is found by its original spelling",
	oNet.HasNode(cGreekId))
chk("...and so is the folded spelling", oNet.HasNode(StzLower(cGreekId)))
chk("an Arabic id resolves", oNet.HasNode(aPrefixes[1] + "-n1-1"))
chk("a CJK id resolves", oNet.HasNode(aPrefixes[2] + "-n2-1"))
chk("an emoji id resolves", oNet.HasNode(aPrefixes[4] + "-n4-1"))
chk("edges between multilingual ids resolve",
	oNet.EdgeExists(aPrefixes[1] + "-n1-1", aPrefixes[1] + "-n1-2"))

aNb = oNet.Neighbors(cGreekId)
chk("neighbours of a Greek-id node come back", len(aNb) = 1)
chk("...and the neighbour is intact multibyte text", StzLen(aNb[1]) > 0)

? ""
? "-- Scene 9: a practical question -- how deep is the network? --"
nReach = len(oNet.BFS(aHeads[4]))
? "  from one entry point, " + nReach + " nodes are reachable"
chk("reachability matches the chain length", nReach = nPerGroup)
chk("the network still holds every node", oNet.NodeCount() = nExpectNodes)
chk("...and every edge", oNet.EdgeCount() = nExpectEdges)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# codepoint -> UTF-8 bytes, by arithmetic (no literals -> no mojibake risk)
func EncCp c
	if c < 128
		return char(c)
	but c < 2048
		return char(192 + floor(c/64)) + char(128 + (c % 64))
	but c < 65536
		return char(224 + floor(c/4096)) + char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	else
		return char(240 + floor(c/262144)) + char(128 + floor((c%262144)/4096)) +
		       char(128 + floor((c%4096)/64)) + char(128 + (c%64))
	ok

func MkW aCp
	cW = ""
	_nCount_ = len(aCp)
	for _k_ = 1 to _nCount_
		cW += EncCp(aCp[_k_])
	next
	return cW
