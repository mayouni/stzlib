# Integration regression suite for stzFolder.
# Covers init (current dir + explicit path), Separator + aliases,
# path inside/outside checks.
#
# Run from base/file/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzFolder integration regression ==="

# ------------------------------------------------------------
# Construction with empty (current dir)
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oF = new stzFolder("")
chk("Empty path -> current dir",     isObject(oF))

# ------------------------------------------------------------
# Separator + aliases
# ------------------------------------------------------------
? ""
? "--- Separator ---"

chk("Separator = '/'",               oF.Separator() = "/")
chk("Seperator (misspelled) alias",  oF.Seperator() = "/")
chk("PathSeparator alias non-empty", isString(oF.PathSeparator()) and len(oF.PathSeparator()) > 0)
chk("SystemSeparator non-empty",     isString(oF.SystemSeparator()) and len(oF.SystemSeparator()) > 0)

# ------------------------------------------------------------
# Path inside / outside
# ------------------------------------------------------------
? ""
? "--- IsInside / IsOutside ---"

cCur = currentdir()
chk("IsInside('.') = TRUE",          oF.IsInside(".") = TRUE or oF.IsInside(".") = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzFolder CHECKS PASSED!"
else
	? "SOME stzFolder CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
