# Integration regression suite for stzGraph.
# stzGraph has no domain-local test dir; the narrative tutorial at
# base/test/stzgraphtest.ring uses pr()/pf() profiler markers that
# raise STOPPED via stkProfiler. This suite is profiler-free and
# focuses on the core surface: create, AddNode, Connect, query
# (Neighbors, HasNode, HasEdge), counts, lifecycle.
#
# Run from base/graph/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzGraph integration regression ==="

# ------------------------------------------------------------
# Construction + basic counts
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oG = new stzGraph("G1")
# stzGraph deliberately lowercases ids at init (graph ids are case-insensitive)
chk("Name() canonicalized to 'g1'",  oG.Name() = "g1")
chk("Empty NumberOfNodes = 0",       oG.NumberOfNodes() = 0)
chk("Empty NumberOfEdges = 0",       oG.NumberOfEdges() = 0)

# ------------------------------------------------------------
# AddNode / HasNode
# ------------------------------------------------------------
? ""
? "--- Nodes ---"

oG.AddNode("a")
oG.AddNode("b")
oG.AddNode("c")
chk("After 3 AddNode: count = 3",    oG.NumberOfNodes() = 3)
chk("HasNode('a') = 1",              oG.HasNode("a") = 1)
chk("HasNode('z') = 0",              oG.HasNode("z") = 0)

aNodes = oG.Nodes()
chk("Nodes() len = 3",               isList(aNodes) and len(aNodes) = 3)

# ------------------------------------------------------------
# Connect (AddEdge) / HasEdge
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oG.Connect("a", "b")
oG.Connect("b", "c")
chk("After 2 Connect: edges = 2",    oG.NumberOfEdges() = 2)
chk("HasEdge(a,b) = 1",              oG.HasEdge("a", "b") = 1)
chk("HasEdge(a,c) = 0",              oG.HasEdge("a", "c") = 0)

# ------------------------------------------------------------
# Neighbors
# ------------------------------------------------------------
? ""
? "--- Neighbors ---"

aN_b = oG.Neighbors("b")
chk("Neighbors(b) is list",          isList(aN_b))
# b is connected to a (in) and c (out); semantics vary by impl but
# the result must be non-empty and contain at least one of a or c
chk("Neighbors(b) non-empty",        len(aN_b) > 0)

# ------------------------------------------------------------
# Edges() listing
# ------------------------------------------------------------
? ""
? "--- Edges() ---"

aE = oG.Edges()
chk("Edges() is list",               isList(aE))
chk("Edges() len = 2",               len(aE) = 2)

# ------------------------------------------------------------
# Edge case: solo node, self-loop attempt
# ------------------------------------------------------------
? ""
? "--- Edge cases ---"

oGs = new stzGraph("Solo")
oGs.AddNode("only")
chk("Solo: 1 node, 0 edges",         oGs.NumberOfNodes() = 1 and oGs.NumberOfEdges() = 0)
chk("Solo HasNode('only')",          oGs.HasNode("only") = 1)
aNS = oGs.Neighbors("only")
chk("Solo Neighbors = empty list",   isList(aNS) and len(aNS) = 0)

# ------------------------------------------------------------
# Independence of separate graph instances
# ------------------------------------------------------------
? ""
? "--- Instance isolation ---"

oA = new stzGraph("A")
oB = new stzGraph("B")
oA.AddNode("x")
oA.AddNode("y")
oA.Connect("x", "y")
chk("oA has 2 nodes",                oA.NumberOfNodes() = 2)
chk("oB still empty (no leak)",      oB.NumberOfNodes() = 0)
chk("oA Name preserved (lower)",     oA.Name() = "a")
chk("oB Name preserved (lower)",     oB.Name() = "b")

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzGraph CHECKS PASSED!"
else
	? "SOME stzGraph CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
