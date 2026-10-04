load "../../stzBase.ring"
load "../_narrated.ring"

# PY1 of the payments plane: MONEY THAT KNOWS ITS CURRENCY.
#
# StzMoneyQ("19.99") is a numeric REGIME: two places, banker's rounding. It is
# right for a price and says nothing about WHICH money. The franc CFA has no
# fraction, the dinar has three places, the euro has two -- and a payments port
# that takes "5000" cannot tell 5,000 francs from 50.00 euros. So the port speaks
# a different thing:
#
#     StzAmountQ("5000", "XOF")      5,000 francs CFA, zero decimals
#     StzAmountQ("12.50", "EUR")     12.50 euros, minor units 1250
#
# The exponent comes from ISO 4217, and an amount that cannot be represented in
# its currency's minor unit is REFUSED, never rounded: 50.5 XOF does not exist.
#
# StzMoneyQ keeps its two places and its 27 checks (numeric_regime_narrated).

Scenario("a franc has no fraction")
	oXof = StzAmountQ("5000", "XOF")
	Then("it knows its currency", oXof.Currency(), "XOF")
	Then("...and the exponent ISO 4217 gives it", oXof.Exponent(), 0)
	Then("...so the minor unit IS the franc", oXof.MinorUnits(), 5000)
	Then("...and its canonical content has no decimal point", oXof.Content(), "5000")
	Then("...and it displays the way a Nigerien reads it", oXof.Display(), "5 000 FCFA")

	bRaised = FALSE
	cWhy = ""
	try
		oHalf = StzAmountQ("50.5", "XOF")
	catch
		bRaised = TRUE
		cWhy = cCatchError
	done
	Then("50.5 francs is REFUSED, not rounded to 50 or 51", bRaised, TRUE)
	Then("...and the refusal names the currency and its exponent",
		StzFindFirst("XOF has 0 decimals", cWhy) > 0, TRUE)

	Then("5000.00 is the same franc spelled with trailing zeros",
		StzAmountQ("5000.00", "XOF").MinorUnits(), 5000)
	Then("a whole number is accepted as a number",
		StzAmountQ(5000, "XOF").MinorUnits(), 5000)
EndScenario()

Scenario("a euro has two places, a dinar three")
	oEur = StzAmountQ("12.50", "EUR")
	Then("12.50 euros is 1250 minor units", oEur.MinorUnits(), 1250)
	Then("...with the exponent 2", oEur.Exponent(), 2)
	Then("...and its canonical content keeps both places", oEur.Content(), "12.50")
	Then("12.5 is padded, not misread as 12 euros 5 cents",
		StzAmountQ("12.5", "EUR").MinorUnits(), 1250)
	Then("12 is 1200 minor units", StzAmountQ("12", "EUR").MinorUnits(), 1200)
	Then("a dinar has three places",
		StzAmountQ("1.234", "TND").MinorUnits(), 1234)
	Then("...and a yen none", StzAmountQ("500", "JPY").MinorUnits(), 500)

	bRaised = FALSE
	try
		o3 = StzAmountQ("12.505", "EUR")
	catch
		bRaised = TRUE
	done
	Then("a third euro decimal is refused", bRaised, TRUE)
EndScenario()

Scenario("an amount cannot exist without a currency")
	bNone = FALSE
	cWhy = ""
	try
		oNo = StzAmountQ("5000", "")
	catch
		bNone = TRUE
		cWhy = cCatchError
	done
	Then("an empty currency is refused", bNone, TRUE)
	Then("...saying a currency is required", StzFindFirst("currency", cWhy) > 0, TRUE)

	bUnknown = FALSE
	try
		oXyz = StzAmountQ("5000", "XYZ")
	catch
		bUnknown = TRUE
	done
	Then("a code that is not in ISO 4217 is refused", bUnknown, TRUE)

	bNum = FALSE
	try
		oFlt = StzAmountQ(50.5, "XOF")
	catch
		bNum = TRUE
	done
	Then("a FRACTIONAL NUMBER is refused too: money is spelled as text, never as a float",
		bNum, TRUE)

	bNotMoney = FALSE
	try
		oWord = StzAmountQ("five thousand", "XOF")
	catch
		bNotMoney = TRUE
	done
	Then("text that is not a decimal amount is refused", bNotMoney, TRUE)

	Then("a lower-case code is the same currency", StzAmountQ("5000", "xof").Currency(), "XOF")
EndScenario()

Scenario("arithmetic stays inside one currency")
	oA = StzAmountQ("5000", "XOF")
	oB = StzAmountQ("2500", "XOF")
	Then("amounts of one currency add", oA.Plus(oB).MinorUnits(), 7500)
	Then("...and subtract", oA.Minus(oB).MinorUnits(), 2500)
	Then("...and the sum is still XOF", oA.Plus(oB).Currency(), "XOF")
	Then("an integer multiple is exact", oB.TimesInteger(3).MinorUnits(), 7500)
	Then("the operator form adds too", (oA + oB).MinorUnits(), 7500)

	oEur = StzAmountQ("12.50", "EUR")
	bMix = FALSE
	cWhy = ""
	try
		oBad = oA.Plus(oEur)
	catch
		bMix = TRUE
		cWhy = cCatchError
	done
	Then("francs plus euros is REFUSED", bMix, TRUE)
	Then("...naming both currencies", StzFindFirst("XOF", cWhy) > 0 and StzFindFirst("EUR", cWhy) > 0, TRUE)

	Then("5000 francs is not equal to 5000 euros",
		StzAmountQ("5000", "XOF").Equals(StzAmountQ("5000", "EUR")), FALSE)
	Then("...but equal to itself", oA.Equals(StzAmountQ("5000", "XOF")), TRUE)
	Then("comparison inside a currency orders", oA.IsGreaterThan(oB), TRUE)

	bCmp = FALSE
	try
		oX = oA.IsGreaterThan(oEur)
	catch
		bCmp = TRUE
	done
	Then("ordering across currencies is refused", bCmp, TRUE)
EndScenario()

Scenario("sign and size")
	Then("a positive amount says so", StzAmountQ("1", "XOF").IsPositive(), TRUE)
	Then("zero is zero", StzAmountQ("0", "XOF").IsZero(), TRUE)
	Then("a debit is negative", StzAmountQ("-250", "XOF").IsNegative(), TRUE)
	Then("...with its minor units signed", StzAmountQ("-250", "XOF").MinorUnits(), -250)
	Then("a negative amount displays its sign", StzAmountQ("-250", "XOF").Display(), "-250 FCFA")
	Then("a hundred millions displays grouped",
		StzAmountQ("100000000", "XOF").Display(), "100 000 000 FCFA")
	Then("a euro displays its code", StzAmountQ("12.50", "EUR").Display(), "12.50 EUR")

	bBig = FALSE
	try
		oHuge = StzAmountQ("99999999999999999999", "XOF")
	catch
		bBig = TRUE
	done
	Then("an amount beyond the exact integer range is refused, not silently rounded", bBig, TRUE)
EndScenario()

Scenario("the ISO table answers for itself")
	Then("XOF has exponent 0", StzCurrencyExponent("XOF"), 0)
	Then("XAF, the other franc CFA, has exponent 0", StzCurrencyExponent("XAF"), 0)
	Then("EUR has exponent 2", StzCurrencyExponent("EUR"), 2)
	Then("KWD has exponent 3", StzCurrencyExponent("KWD"), 3)
	Then("XOF is known", StzIsCurrencyCode("XOF"), TRUE)
	Then("XYZ is not", StzIsCurrencyCode("XYZ"), FALSE)
EndScenario()

Scenario("StzMoneyQ is untouched")
	oPrice = StzMoneyQ("19.99")
	oPrice.MultiplyBy("0.15")
	Then("it still keeps two places and banker's rounding", oPrice.Content(), "3.00")
	Then("...and is a regime, not a currency", oPrice.Regime(), :money)
EndScenario()

Summary()
