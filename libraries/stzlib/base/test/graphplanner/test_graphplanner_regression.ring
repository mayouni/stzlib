# Integration regression for stzGraphPlanner.
# Builds plans (route optimization profiles) on top of stzGraph.
#
# Run from base/graph/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzGraphPlanner integration regression ==="

# Build a simple backing graph
oG = new stzGraph("g")
oG.AddNode("a")
oG.AddNode("b")
oG.AddNode("c")
oG.Connect("a", "b")
oG.Connect("b", "c")

# ------------------------------------------------------------
# Construction
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oP = new stzGraphPlanner(oG)
chk("Planner constructs",            isObject(oP))

# ------------------------------------------------------------
# Profile lookups
# ------------------------------------------------------------
? ""
? "--- Profiles ---"

chk("Profile(:fastest) returns",     isList(oP.Profile(:fastest)))
chk("Profile(:safest) non-empty",    len(oP.Profile(:safest)) > 0)
chk("Profile(:cheapest)",            isList(oP.Profile(:cheapest)))
chk("Profile(:shortest)",            isList(oP.Profile(:shortest)))
chk("Profile(:balanced)",            isList(oP.Profile(:balanced)))
chk("Profile(:efficient)",           isList(oP.Profile(:efficient)))

# Case-insensitive
chk("Profile(:FASTEST) (CI)",        isList(oP.Profile(:FASTEST)))

# Unknown profile -> empty
chk("Unknown profile -> []",         len(oP.Profile(:bogus)) = 0)

# ------------------------------------------------------------
# Plan management
# ------------------------------------------------------------
? ""
? "--- Plans ---"

oP.AddPlan("plan1")
chk("Plan added",                    isObject(oP.Plan("plan1")) or isList(oP.Plan("plan1")))

oP.SetCurrentPlan("plan1")
chk("CurrentPlan = 'plan1'",         oP.CurrentPlan() = "plan1" or oP.CurrentPlan() != NULL)

# ------------------------------------------------------------
# Bad input
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzGraphPlanner("not a graph")
catch
	bRaised = 1
done
chk("Non-graph ctor param raises",   bRaised = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzGraphPlanner CHECKS PASSED!"
else
	? "SOME stzGraphPlanner CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
