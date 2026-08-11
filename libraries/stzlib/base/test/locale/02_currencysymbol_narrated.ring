load "../../stzBase.ring"
load "../_narrated.ring"

# stzLocale -- A CURRENCY SYMBOL IS NOT ITS ISO CODE.
#
# Found by running the library's own recorded expectations:
#
#     ? o1.CurrencySymbol()   #--> ریال
#
# answered "IRR" -- which is exactly what CurrencyISOSymbol() answers. Two
# methods, one result.
#
# The lookup was never the problem. CurrencySymbol() asks pvtCurrencyXT for
# :NativeSymbol, which reads column 3 of $_aCurrencyISOData, and THIRTY-SIX of
# the 143 rows carried the ISO code in that column -- the euro among them, so
# every euro locale in the library reported "EUR" where the world writes a
# currency sign.
#
# One further row, the Bulgarian lev, was double-encoded source: the bytes for
# "лв" had been read as Latin-1 and re-encoded, leaving "Ð»Ð²". Its neighbour
# Chinese_yuan held a correct "¥" the whole time, which is what proved the file
# itself was sound and only that row was damaged.

pr()

Scenario("The symbol and the code are different answers")

	Given("a rial locale")
	oIr = new stzLocale("fa_IR")
	Then("the ISO code is the ISO code", oIr.CurrencyISOSymbol(), "IRR")
	Then("...and the symbol is a symbol", oIr.CurrencySymbol() != "IRR", TRUE)

	Given("a euro locale")
	oFr = new stzLocale("fr_FR")
	Then("the ISO code is the ISO code", oFr.CurrencyISOSymbol(), "EUR")
	Then("...and the symbol is the euro sign", oFr.CurrencySymbol(), "€")

	# THE NEGATIVE SIBLING: they must not have become the same thing the other
	# way round. The ISO accessor still answers the code.
	Then("the two accessors disagree, as they should", oFr.CurrencySymbol() != oFr.CurrencyISOSymbol(), TRUE)
	Then("...and CurrencyAbbreviation is still the code", oFr.CurrencyAbbreviation(), "EUR")
EndScenario()

Scenario("No row in the table answers its own ISO code")

	# The property, over all 143 rows rather than the handful above. This is what
	# stops the gap reopening one row at a time: a new currency added with its
	# code copied into the symbol column fails here immediately.

	Given("the whole currency table")
	Then("every row carries a real symbol", NRowsWhereSymbolIsTheCode(), 0)
	Then("...and none of them is blank", NRowsWithNoSymbol(), 0)

	# THE NEGATIVE SIBLING, and the reason the rule is "different from the code"
	# rather than "not a Latin word": some currencies genuinely use letters. The
	# Swiss franc writes Fr., the Moldovan leu writes L. Both are allowed, and
	# both are still distinct from CHF and MDL.
	Then("a currency written in letters is fine", SymbolOf("CHF"), "Fr.")
	Then("...as long as it is not the code", SymbolOf("CHF") != "CHF", TRUE)
EndScenario()

Scenario("No symbol is double-encoded")

	# "Ð»Ð²" is what "лв" becomes when UTF-8 bytes are read as Latin-1 and
	# written back out. The signature is a leading Ã or Ð followed by another
	# Latin-1 supplement character, and it is worth checking the whole column:
	# one row had it, and nothing would have said so.

	Given("the currency symbols")
	Then("the Bulgarian lev reads as two letters", StzLen(SymbolOf("BGN")), 2)
	Then("...and it is the lev", SymbolOf("BGN"), "лв")
	Then("no symbol carries the mojibake signature", NMojibakeSymbols(), 0)

	# THE NEGATIVE SIBLING: a correctly encoded non-ASCII symbol must NOT be
	# reported as damaged. The yen was right all along.
	Then("the yen is untouched", SymbolOf("CNY"), "CN¥")
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------
#
# These used to walk $_aCurrencyISOData directly. The table moved into the
# engine (locale plan L1), so they ASK ITS OWNER instead -- which is why
# CurrencyNameAt/CurrencyCount exist: a caller can walk the whole table without
# holding a copy of it, and a property asserted here is asserted against the
# rows that actually ship.

func SymbolOf(pcIso)
	return StzEngineLocaleCurrencySymbolByIso("" + pcIso)

func NRowsWhereSymbolIsTheCode()
	_n_ = 0
	for _i_ = 1 to StzEngineLocaleCurrencyCount()
		_cName_ = StzEngineLocaleCurrencyNameAt(_i_)
		_cIso_ = StzEngineLocaleCurrencyIso(_cName_)
		_cSym_ = StzEngineLocaleCurrencySymbol(_cName_)
		if StzUpper(_cSym_) = StzUpper(_cIso_)
			_n_++
		ok
	next
	return _n_

func NRowsWithNoSymbol()
	_n_ = 0
	for _i_ = 1 to StzEngineLocaleCurrencyCount()
		_cSym_ = StzEngineLocaleCurrencySymbol(StzEngineLocaleCurrencyNameAt(_i_))
		if ring_trim("" + _cSym_) = ""
			_n_++
		ok
	next
	return _n_

# A symbol is suspect when it opens with the Latin-1 supplement characters that
# UTF-8 bytes turn into when misread -- the two that the Bulgarian lev carried.
func NMojibakeSymbols()
	_n_ = 0
	for _i_ = 1 to StzEngineLocaleCurrencyCount()
		_c_ = "" + StzEngineLocaleCurrencySymbol(StzEngineLocaleCurrencyNameAt(_i_))
		if StzLen(_c_) < 2
			loop
		ok
		_cFirst_ = StzMid(_c_, 1, 1)
		if _cFirst_ = "Ã" or _cFirst_ = "Ð"
			_n_++
		ok
	next
	return _n_
