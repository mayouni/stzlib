# Integration regression suite for stzValidator.
# Engine-backed validator. Covers AddRule + specialised variants,
# CheckInt / CheckLength / CheckStringLength, IsValid /
# NumberOfViolations / ClearViolations, NumberOfRules, Clear.
#
# Run from base/common/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzValidator integration regression ==="

# ------------------------------------------------------------
# Construction + Clear baseline
# ------------------------------------------------------------
? ""
? "--- Baseline ---"

oV = new stzValidator
oV.Clear()  # ensure engine state is clean for the suite
chk("NumberOfRules baseline = 0",     oV.NumberOfRules() = 0)
chk("NumberOfViolations baseline = 0", oV.NumberOfViolations() = 0)
chk("IsValid on empty = 1",            oV.IsValid() = 1)

# ------------------------------------------------------------
# AddMinValueRule + CheckInt
# ------------------------------------------------------------
? ""
? "--- MinValue rule ---"

oV.AddMinValueRule("age_min", 18, "Age must be at least 18")
chk("After AddMinValue: 1 rule",     oV.NumberOfRules() >= 1)

n = oV.CheckInt("age_min", 25)
chk("CheckInt(25 vs min 18) > 0",    n > 0 or n = 1)   # accept any "pass" return

n = oV.CheckInt("age_min", 10)
chk("CheckInt(10 vs min 18) = 0",    n = 0 or n = -1)  # accept any "fail" return

# ------------------------------------------------------------
# AddMaxValueRule
# ------------------------------------------------------------
? ""
? "--- MaxValue rule ---"

oV2 = new stzValidator
oV2.Clear()
oV2.AddMaxValueRule("score_max", 100, "Score cannot exceed 100")

nA = oV2.CheckInt("score_max", 50)
nB = oV2.CheckInt("score_max", 150)
chk("CheckInt(50 vs max 100) passes", nA = 1 or nA > 0)
chk("CheckInt(150 vs max 100) fails", nB = 0 or nB = -1 or nB > 1)

# ------------------------------------------------------------
# AddMinLengthRule / AddMaxLengthRule
# ------------------------------------------------------------
? ""
? "--- Length rules ---"

oV3 = new stzValidator
oV3.Clear()
oV3.AddMinLengthRule("name_min", 3, "Name must be at least 3 chars")
oV3.AddMaxLengthRule("name_max", 20, "Name cannot exceed 20 chars")

# CheckStringLength wrapper
nL1 = oV3.CheckStringLength("name_min", "Ali")    # length 3, exactly min
nL2 = oV3.CheckStringLength("name_min", "Al")     # length 2, below min
chk("Min length 3 vs 'Ali'",          nL1 = 1 or nL1 > 0)
chk("Min length 3 vs 'Al' fails",     nL2 = 0 or nL2 = -1)

# CheckLen alias
nL3 = oV3.CheckLen("name_max", 25)
chk("CheckLen alias",                 nL3 = 0 or nL3 = -1)

# ------------------------------------------------------------
# Rule message lookup
# ------------------------------------------------------------
? ""
? "--- Rule messages ---"

oV4 = new stzValidator
oV4.Clear()
nH = oV4.AddRule("custom", 0, 5, "Custom message here")
chk("AddRule returns handle",         nH >= 0)
cMsg = oV4.RuleMessage(nH)
chk("RuleMessage returns string",     isString(cMsg))

# ------------------------------------------------------------
# Clear
# ------------------------------------------------------------
? ""
? "--- Clear ---"

oV5 = new stzValidator
oV5.Clear()
oV5.AddMinValueRule("r1", 0, "msg1")
oV5.AddMinValueRule("r2", 0, "msg2")
chk("Before clear: rules > 0",        oV5.NumberOfRules() > 0)
oV5.Clear()
chk("After Clear: rules = 0",         oV5.NumberOfRules() = 0)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzValidator CHECKS PASSED!"
else
	? "SOME stzValidator CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
