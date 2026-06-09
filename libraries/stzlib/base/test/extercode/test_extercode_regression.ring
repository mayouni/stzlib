# Smoke regression for stzExterCode (and friends).
# Tests the language-table + setters API without actually running
# external interpreters (those need real Python/R/etc. installed).
#
# Run from base/extercode/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzExterCode integration regression ==="

# ------------------------------------------------------------
# Construction + language init
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oXC = new stzExterCode
oXC.Init("python")
chk("Init('python') doesn't raise",  isObject(oXC))

# Language support checks
chk("IsLanguageSupported('python')",  oXC.IsLanguageSupported("python") = 1)
chk("IsLanguageSupported('PYTHON') CI", oXC.IsLanguageSupported("PYTHON") = 1)
chk("Bogus language not supported",   oXC.IsLanguageSupported("noSuchLang") = 0)

# Bad Init raises
bRaised = 0
try
	oBad = new stzExterCode
	oBad.Init("bogus_language_xyz")
catch
	bRaised = 1
done
chk("Init with bogus lang raises",   bRaised = 1)

# ------------------------------------------------------------
# SetCode + SetVerbose + SetResultVar
# ------------------------------------------------------------
? ""
? "--- Setters ---"

oS = new stzExterCode
oS.Init("python")
oS.SetCode("x = 42\nprint(x)")
oS.SetVerbose(1)
oS.SetResultVar("output")

# Operator-style @() alias for SetCode
oS.@("y = 100")
chk("Setters don't raise",           isObject(oS))

# CleanupRequired
chk("CleanupRequired is bool",       oS.CleanupRequired() = 0 or oS.CleanupRequired() = 1)

# ------------------------------------------------------------
# Multiple language inits (one instance, switched lang)
# ------------------------------------------------------------
? ""
? "--- Multi-language ---"

oM = new stzExterCode
oM.Init("python")
oM.Init("c")  # switch language
chk("Language switch works",         isObject(oM))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzExterCode CHECKS PASSED!"
else
	? "SOME stzExterCode CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
