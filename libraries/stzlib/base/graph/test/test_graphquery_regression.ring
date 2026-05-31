# Integration regression for stzGraphQuery.
# Builder-pattern query over stzGraph: define, configure, execute.
#
# Run from base/graph/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzGraphQuery integration regression ==="

# Build a graph to query against
oG = new stzGraph("g")
oG.AddNode("a")
oG.AddNode("b")
oG.Connect("a", "b")

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oQ = new stzGraphQuery(oG)
chk("Query constructs",              isObject(oQ))

# Bad input
bRaised = 0
try
	oBadQ = new stzGraphQuery("not a graph")
catch
	bRaised = 1
done
chk("Non-graph ctor raises",         bRaised = 1)

# ------------------------------------------------------------
# Definition access
# ------------------------------------------------------------
? ""
? "--- Definition ---"

aDef = oQ.Query()
chk("Query() returns",               isList(aDef) or aDef = NULL)

# Aliases (they should at least return non-NULL when Query is set)
chk("Definition alias non-NULL",     oQ.Definition() != NULL)
chk("AST alias non-NULL",            oQ.AST() != NULL)

# SetDefinition with bad input raises
bRaisedSet = 0
try
	oQ.SetDefinition("not a list")
catch
	bRaisedSet = 1
done
chk("SetDefinition non-list raises", bRaisedSet = 1)

# ResetDefinition / ClearDefinition
oQ.ResetDefinition()
chk("After Reset: no crash",         isObject(oQ))

oQ.ClearDefinition()
chk("After Clear: no crash",         isObject(oQ))

# ------------------------------------------------------------
# Graph accessor
# ------------------------------------------------------------
? ""
? "--- Graph accessor ---"

oG2 = oQ.GraphObject()
chk("GraphObject returns",           isObject(oG2))

oG3 = oQ.GraphQ()
chk("GraphQ alias",                  isObject(oG3))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzGraphQuery CHECKS PASSED!"
else
	? "SOME stzGraphQuery CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
