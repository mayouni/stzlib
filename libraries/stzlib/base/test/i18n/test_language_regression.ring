# Integration regression suite for stzLanguage.
# Accepts language code, name, abbreviation, or country-name;
# exposes Name / NativeName / Abbreviation / DefaultCountry.
#
# Run from base/i18n/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzLanguage integration regression ==="

# ------------------------------------------------------------
# Construction by name
# ------------------------------------------------------------
? ""
? "--- Construction by name ---"

oE = new stzLanguage("English")
chk("Name() non-empty",             isString(oE.Name()) and len(oE.Name()) > 0)
chk("Number() returns string",      isString(oE.Number()))
chk("Abbreviation non-empty",       isString(oE.Abbreviation()) and len(oE.Abbreviation()) > 0)

# ------------------------------------------------------------
# By abbreviation
# ------------------------------------------------------------
? ""
? "--- Construction by abbreviation ---"

oF = new stzLanguage("fr")
chk("By 'fr' constructs",            isObject(oF))
chk("French has a name",             isString(oF.Name()) and len(oF.Name()) > 0)

# ------------------------------------------------------------
# Aliases
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

chk("Language alias = Name",        oE.Language() = oE.Name())
chk("Content alias = Name",         oE.Content() = oE.Name())

# ------------------------------------------------------------
# DefaultCountry
# ------------------------------------------------------------
? ""
? "--- DefaultCountry ---"

cC = oE.DefaultCountry()
chk("DefaultCountry returns string", isString(cC) and len(cC) > 0)

cCNum = oE.DefaultCountryNumber()
chk("DefaultCountryNumber returns",  isString(cCNum) or isNumber(cCNum))

# ------------------------------------------------------------
# Bad input
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzLanguage("NotARealLanguage12345")
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
	? "ALL stzLanguage CHECKS PASSED!"
else
	? "SOME stzLanguage CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
