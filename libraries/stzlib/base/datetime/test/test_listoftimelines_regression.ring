# Integration regression suite for stzListOfTimeLines.
# Multi-lane timeline; ctor expects hashlist with :Lanes, :Start
# (or :From), :End (or :To). Manages lanes + per-lane points/spans.
#
# Run from base/datetime/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzListOfTimeLines integration regression ==="

# ------------------------------------------------------------
# Construction (canonical key names :Start :End)
# ------------------------------------------------------------
? ""
? "--- Construction (:Start / :End) ---"

oLt = new stzListOfTimeLines([
	:Lanes = [ "alpha", "beta", "gamma" ],
	:Start = "2026-01-01 00:00:00",
	:End   = "2026-12-31 23:59:59"
])
chk("Constructed",                  isObject(oLt))
chk("NumberOfLanes = 3",            oLt.NumberOfLanes() = 3)
chk("Lanes list correct (upper)",   oLt.Lanes()[1] = "ALPHA")
chk("GlobalStart non-empty",        isString(oLt.GlobalStart()) and len(oLt.GlobalStart()) > 0)
chk("GlobalEnd non-empty",          isString(oLt.GlobalEnd()) and len(oLt.GlobalEnd()) > 0)

# ------------------------------------------------------------
# Construction (alternative keys :From / :To)
# ------------------------------------------------------------
? ""
? "--- Construction (:From / :To) ---"

oLt2 = new stzListOfTimeLines([
	:Lanes = [ "single" ],
	:From  = "2026-06-01 00:00:00",
	:To    = "2026-06-30 23:59:59"
])
chk(":From / :To ctor works",       isObject(oLt2))
chk("NumberOfLanes = 1",            oLt2.NumberOfLanes() = 1)

# ------------------------------------------------------------
# Lane access
# ------------------------------------------------------------
? ""
? "--- Lane access ---"

chk("HasLane(alpha) = 1",           oLt.HasLane("alpha") = 1)
chk("HasLane(missing) = 0",         oLt.HasLane("missing") = 0)

oL1 = oLt.Lane("alpha")
chk("Lane returns stzTimeLine",     ring_classname(oL1) = "stztimeline")

# ------------------------------------------------------------
# AddLane / RemoveLane
# ------------------------------------------------------------
? ""
? "--- AddLane / RemoveLane ---"

oLt.AddLane("delta")
chk("After AddLane: 4 lanes",       oLt.NumberOfLanes() = 4)
chk("HasLane(delta) = 1",           oLt.HasLane("delta") = 1)

oLt.RemoveLane("delta")
chk("After RemoveLane: 3 lanes",    oLt.NumberOfLanes() = 3)
chk("HasLane(delta) = 0",           oLt.HasLane("delta") = 0)

# ------------------------------------------------------------
# AddPointToLane
# ------------------------------------------------------------
? ""
? "--- AddPointToLane ---"

oLt.AddPointToLane("alpha", "kickoff", "2026-03-15 09:00:00")
oLt.AddMomentToLane("beta", "checkpoint", "2026-06-15 12:00:00")
oLa = oLt.Lane("alpha")
chk("Point added to alpha",         len(oLa.Content()[:Points]) = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzListOfTimeLines CHECKS PASSED!"
else
	? "SOME stzListOfTimeLines CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
