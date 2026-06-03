# Integration regression suite for stzLocale.
# Accepts locale abbreviation ("en-US"), :System, :Default, country
# name, or language name. Exposes Abbreviation / Country* /
# Language* / various locale-derived getters.
#
# Run from base/i18n/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzLocale integration regression ==="

# ------------------------------------------------------------
# Construction :System
# ------------------------------------------------------------
? ""
? "--- :System ---"

oS = new stzLocale(:System)
chk(":System constructs",            isObject(oS))
chk(":System Abbreviation",          isString(oS.Abbreviation()))

# ------------------------------------------------------------
# Construction by country name
# ------------------------------------------------------------
? ""
? "--- Country name ---"

oF = new stzLocale("France")
chk("By 'France' constructs",        isObject(oF))
chk("Abbreviation non-empty",        isString(oF.Abbreviation()) and len(oF.Abbreviation()) > 0)

# ------------------------------------------------------------
# Construction by language name
# ------------------------------------------------------------
? ""
? "--- Language name ---"

oL = new stzLocale("English")
chk("By 'English' constructs",       isObject(oL))

# ------------------------------------------------------------
# Construction by abbreviation
# ------------------------------------------------------------
? ""
? "--- Abbreviation ---"

oA = new stzLocale("fr-FR")
chk("By 'fr-FR' constructs",         isObject(oA))
chk("Abbreviation normalized",       isString(oA.Abbreviation()))

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzLocale CHECKS PASSED!"
else
	? "SOME stzLocale CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
