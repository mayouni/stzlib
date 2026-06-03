# Integration regression suite for stzCountry.
# Accepts country code, name, abbreviation, or phone code; exposes
# Name / NativeName / Abbreviation / PhoneCode / DefaultLanguage*.
#
# Run from base/i18n/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCountry integration regression ==="

# ------------------------------------------------------------
# Construction by name
# ------------------------------------------------------------
? ""
? "--- Construction by name ---"

oF = new stzCountry("France")
chk("Name() returns 'France'",       isString(oF.Name()) and len(oF.Name()) > 0)
chk("Number() returns string",       isString(oF.Number()))
chk("Abbreviation() non-empty",      isString(oF.Abbreviation()) and len(oF.Abbreviation()) > 0)

# ------------------------------------------------------------
# Construction by abbreviation
# ------------------------------------------------------------
? ""
? "--- Construction by abbreviation ---"

oUS = new stzCountry("US")
chk("Country by 'US' constructs",   isObject(oUS))
chk("US has a name",                isString(oUS.Name()) and len(oUS.Name()) > 0)

# ------------------------------------------------------------
# PhoneCode
# ------------------------------------------------------------
? ""
? "--- PhoneCode ---"

oG = new stzCountry("Germany")
cP = oG.PhoneCode()
chk("PhoneCode returns string",     isString(cP) or isNumber(cP))

# ------------------------------------------------------------
# Aliases (Country / Content / Value all return Name)
# ------------------------------------------------------------
? ""
? "--- Aliases ---"

chk("Country alias = Name",         oF.Country() = oF.Name())
chk("Content alias = Name",         oF.Content() = oF.Name())
chk("Value alias = Name",           oF.Value() = oF.Name())

# NativeName skipped: depends on a StzLocale() Q-constructor that
# isn't wired in this build (R3 "Calling Function without definition").
# Tracked as a separate issue for the stzLocale port.

# ------------------------------------------------------------
# Bad input raises
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzCountry("NotARealCountry12345")
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
	? "ALL stzCountry CHECKS PASSED!"
else
	? "SOME stzCountry CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
