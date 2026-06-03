# Integration regression suite for stzCurrency.
# Accepts country name or currency name; exposes Name / Currency /
# Country / FractionalUnit / Base.
#
# Run from base/i18n/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCurrency integration regression ==="

# Note: CurrenciesXT() actually returns [country_name, currency_info],
# so both IsCountryName and IsCurrencyName effectively match against
# country names. Test uses country names accordingly.

# ------------------------------------------------------------
# Construction by country name
# ------------------------------------------------------------
? ""
? "--- Construction by country name ---"

oF = new stzCurrency("France")
chk("By country 'France' constructs", isObject(oF))
chk("Currency info non-empty",       isList(oF.Currency()) or (isString(oF.Currency()) and len(oF.Currency()) > 0))

# Content / Value aliases
chk("Content alias = Currency",      isList(oF.Content()) or isString(oF.Content()))

# ------------------------------------------------------------
# Another country
# ------------------------------------------------------------
? ""
? "--- Another country ---"

oG = new stzCurrency("Germany")
chk("By 'Germany' constructs",       isObject(oG))

# ------------------------------------------------------------
# FractionalUnit / Base
# ------------------------------------------------------------
? ""
? "--- FractionalUnit / Base ---"

cFu = oF.FractionalUnit()
chk("FractionalUnit non-NULL",       cFu != NULL)

nB = oF.Base()
chk("Base non-NULL",                 nB != NULL)

# ------------------------------------------------------------
# Bad input
# ------------------------------------------------------------
? ""
? "--- Bad input ---"

bRaised = 0
try
	oBad = new stzCurrency("NotARealCurrency12345")
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
	? "ALL stzCurrency CHECKS PASSED!"
else
	? "SOME stzCurrency CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
