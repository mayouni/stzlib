# Integration regression suite for stzKnowledgeGraph.
# Triple-based interface on top of stzGraph: AddFact / RemoveFact /
# Facts / Query / QueryPath / Predicates / Relations / SimilarTo /
# DefineClass / DefineProperty / Ontology.
#
# Run from base/graph/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzKnowledgeGraph integration regression ==="

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oKg = new stzKnowledgeGraph("kg1")
chk("IsKnowledgeGraph = 1",         oKg.IsKnowledgeGraph() = TRUE)
chk("Name preserved (lowercased)",  oKg.Name() = "kg1")

# ------------------------------------------------------------
# AddFact + Facts
# ------------------------------------------------------------
? ""
? "--- AddFact ---"

oKg.AddFact("alice", "knows", "bob")
oKg.AddFact("alice", "likes", "coffee")
oKg.AddFact("bob",   "knows", "alice")

aF = oKg.Facts()
chk("Facts returns list",           isList(aF))
chk("Facts has 3 triples",          len(aF) = 3)

# Each fact is [subject, predicate, object]
chk("Fact[1] is 3-element list",    isList(aF[1]) and len(aF[1]) = 3)
chk("Fact[1] = [alice, knows, bob]", aF[1][1] = "alice" and aF[1][2] = "knows" and aF[1][3] = "bob")

# Triples alias
aT = oKg.Triples()
chk("Triples alias = Facts",        len(aT) = 3)

# Node side-effects: AddFact should have created the entity nodes
chk("Node 'alice' exists",          oKg.NodeExists("alice") = 1)
chk("Node 'bob' exists",            oKg.NodeExists("bob") = 1)
chk("Node 'coffee' exists",         oKg.NodeExists("coffee") = 1)

# ------------------------------------------------------------
# AddTriple alias
# ------------------------------------------------------------
? ""
? "--- AddTriple alias ---"

oKg.AddTriple("carol", "likes", "tea")
chk("After AddTriple: 4 facts",     len(oKg.Facts()) = 4)
chk("Node carol exists",            oKg.NodeExists("carol") = 1)

# ------------------------------------------------------------
# Query
# ------------------------------------------------------------
? ""
? "--- Query ---"

# Pattern: "?x knows bob" -> find all subjects who know bob
oKgQ = new stzKnowledgeGraph("q1")
oKgQ.AddFact("alice", "knows", "bob")
oKgQ.AddFact("carol", "knows", "bob")
oKgQ.AddFact("alice", "likes", "tea")

aR = oKgQ.Query([ "?x", "knows", "bob" ])
chk("Query returns list",           isList(aR))
chk("Query found 2 matches",        len(aR) = 2)

# Pattern: "alice ?p ?o" -> all predicates+objects for alice (both vars)
aR2 = oKgQ.Query([ "alice", "knows", "?y" ])
chk("Query alice knows ?y",         isList(aR2) and len(aR2) = 1)
chk("Query result is 'bob'",        aR2[1] = "bob" or (isList(aR2[1]) and aR2[1] = "bob"))

# ------------------------------------------------------------
# RemoveFact
# ------------------------------------------------------------
? ""
? "--- RemoveFact ---"

oKgR = new stzKnowledgeGraph("r1")
oKgR.AddFact("a", "likes", "b")
oKgR.AddFact("c", "likes", "d")
chk("Before remove: 2 facts",       len(oKgR.Facts()) = 2)

oKgR.RemoveFact("a", "likes", "b")
chk("After remove: 1 fact",         len(oKgR.Facts()) = 1)

# Other fact preserved
aRem = oKgR.Facts()
chk("Other fact still c-likes-d",   aRem[1][1] = "c" and aRem[1][3] = "d")

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Empty graph
oEm = new stzKnowledgeGraph("empty")
chk("Empty Facts len = 0",          len(oEm.Facts()) = 0)
chk("Empty NumberOfNodes = 0",      oEm.NumberOfNodes() = 0)

# Single fact
oOne = new stzKnowledgeGraph("one")
oOne.AddFact("x", "is", "y")
chk("Single fact added",            len(oOne.Facts()) = 1)
chk("Single fact: 2 nodes",         oOne.NumberOfNodes() = 2)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzKnowledgeGraph CHECKS PASSED!"
else
	? "SOME stzKnowledgeGraph CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
