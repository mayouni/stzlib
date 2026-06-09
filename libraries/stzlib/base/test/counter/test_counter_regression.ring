# Integration regression suite for stzCounter.
# Sequence generator with StartAt + Step + reset rules
# (WhenYouReach / AfterYouSkip / RestartAt).
#
# Run from base/common/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCounter integration regression ==="

# ------------------------------------------------------------
# Construction with named params
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oC = new stzCounter([ :StartAt = 1, :WhenYouReach = 5, :RestartAt = 1 ])
chk("Object constructed",           isObject(oC))

# ------------------------------------------------------------
# Counting with reset on reach
# ------------------------------------------------------------
? ""
? "--- WhenYouReach + RestartAt ---"

# StartAt=1, WhenYouReach=5, RestartAt=1
# Sequence 1..10 should be: 1,2,3,4,1,2,3,4,1,2  (resets when value = 5)
aR = oC.Counting(10)
chk("Counting returns list",        isList(aR))
chk("Counting len = 10",            len(aR) = 10)
chk("Counting[1] = 1",              aR[1] = 1)
chk("Counting[4] = 4",              aR[4] = 4)
chk("Counting[5] = 1 (reset)",      aR[5] = 1)
chk("Counting[6] = 2",              aR[6] = 2)
chk("Counting[10] = 2",             aR[10] = 2)

# ------------------------------------------------------------
# AfterYouSkip mode
# ------------------------------------------------------------
? ""
? "--- AfterYouSkip + RestartAt ---"

oS = new stzCounter([ :StartAt = 1, :AfterYouSkip = 3, :RestartAt = 1 ])
# Should reset every 4th item (after skipping 3): 1,2,3,1,2,3,1,2 in length-8
aS = oS.Counting(8)
chk("AfterYouSkip mode produces 8", len(aS) = 8)
chk("AfterYouSkip[1] = 1",          aS[1] = 1)
chk("AfterYouSkip[3] = 3",          aS[3] = 3)

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

oA = new stzCounter([ :StartAt = 1, :WhenYouReach = 3, :RestartAt = 1 ])
aA1 = oA.Count(6)
aA2 = oA.CountTo(6)
aA3 = oA.CountingTo(6)
chk("Count alias works",            isList(aA1) and len(aA1) = 6)
chk("CountTo alias same as Counting", aA2[1] = aA1[1])
chk("CountingTo alias same",        aA3[1] = aA1[1])

# ------------------------------------------------------------
# Empty ctor (defaults)
# ------------------------------------------------------------
? ""
? "--- Empty ctor ---"

oE = new stzCounter([])
chk("Empty ctor object created",    isObject(oE))

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Reaching nNumber = 1
oOne = new stzCounter([ :StartAt = 1, :WhenYouReach = 5, :RestartAt = 1 ])
aOne = oOne.Counting(1)
chk("Counting(1) len = 1",          len(aOne) = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzCounter CHECKS PASSED!"
else
	? "SOME stzCounter CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
