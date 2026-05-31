# Integration regression suite for stzScript.
# Accepts script name, code, or abbreviation; exposes
# Script / Name / Number / Abbreviation / DefaultLanguage.
#
# Run from base/i18n/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzScript integration regression ==="

# ------------------------------------------------------------
# Construction by script name
# ------------------------------------------------------------
? ""
? "--- Construction by name ---"

oLat = new stzScript("Latin")
chk("By 'Latin' constructs",         isObject(oLat))
chk("Name non-empty",                isString(oLat.Name()) and len(oLat.Name()) > 0)
chk("Number returns",                isString(oLat.Number()) or isNumber(oLat.Number()))

# ------------------------------------------------------------
# By abbreviation
# ------------------------------------------------------------
? ""
? "--- Construction by abbreviation ---"

oA = new stzScript("Latn")
chk("By 'Latn' constructs",          isObject(oA))

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

chk("Content alias = Script",        oLat.Content() = oLat.Script())
chk("Value alias works",             oLat.Value() = oLat.Script())

# ------------------------------------------------------------
# Bad input
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzScript("NotARealScript12345")
catch
	bRaised = 1
done
chk("Unsupported identifier raises", bRaised = 1)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzScript CHECKS PASSED!"
else
	? "SOME stzScript CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
