#================================================================#
#  STZAMOUNT -- money that knows its currency (payments plane, PY1)  #
#================================================================#

/*--- An amount is minor units plus a currency, and nothing else.

    StzAmountQ("5000", "XOF")     5,000 francs CFA, exponent 0
    StzAmountQ("12.50", "EUR")    12.50 euros, 1250 minor units
    StzAmountQ("1.234", "TND")    1.234 dinars, exponent 3

THE EXPONENT IS ISO 4217'S, not the country table's. stzCurrency says the
franc CFA has a "Centime" of base 100 -- a historical subunit that has not
circulated for decades -- where ISO 4217 gives XOF and XAF exponent 0. An amount
asked to carry 50.5 XOF REFUSES, because the hub's `montant` for XOF is a whole
number of francs and a fraction of a franc cannot be paid. It is never rounded:
rounding money on the way to a payment is how a platform pays 51 and records 50.

THREE THINGS ARE REFUSED, each by a guard (money_currency_narrated):
  * an amount with no currency, or a currency that is not an ISO 4217 code
  * a fraction finer than the currency's minor unit, and a fractional NUMBER:
    money is spelled as text ("12.50"), never computed as a float, because a
    double cannot hold 12.10 and the drift surfaces at a rounding boundary
  * arithmetic or ordering across two currencies

Trailing zeros beyond the exponent are the same amount ("5000.00" XOF is 5000),
since they change no value. Anything beyond 2^53 - 1 minor units is refused: the
minor unit is held as a Ring number, and above that a number stops being exact.

StzMoneyQ is a numeric REGIME (two places, banker's rounding) and is untouched;
this is a different thing, and the payments port does not call StzMoneyQ.

AMOUNTS ARE IMMUTABLE. Plus, Minus and TimesInteger answer a new amount, so Ring's
copy-on-assign can never fork a balance.

THE ISO TABLE is the codes of ISO 4217 list one that a payment can name, grouped by
exponent, read 2026-10-04. It is data with a date, not a claim to be the registry:
a code missing here is refused, and adding it is one word in one string.
*/

# ISO 4217, grouped by minor-unit exponent. Space-padded so a code is found whole.
$cStzIsoExp0 = " BIF CLP DJF GNF ISK JPY KMF KRW PYG RWF UGX VND VUV XAF XOF XPF "
$cStzIsoExp2 = " AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BMD BND BOB BRL BSD BTN BWP BYN BZD CAD CDF CHF CNY COP CRC CUP CZK DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GHS GIP GMD GTQ GYD HKD HNL HTG HUF IDR ILS INR IRR JMD KES KGS KHR KYD KZT LAK LBP LKR LRD LSL MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MYR MZN NAD NGN NIO NOK NPR NZD PAB PEN PGK PHP PKR PLN QAR RON RSD RUB SAR SBD SCR SDG SEK SGD SHP SLE SOS SRD SSP STN SVC SYP SZL THB TJS TMT TOP TRY TTD TWD TZS UAH USD UYU UZS VES WST XCD YER ZAR ZMW ZWL "
$cStzIsoExp3 = " BHD IQD JOD KWD LYD OMR TND "
$cStzIsoExp4 = " CLF "

# The largest minor-unit count a Ring number holds exactly: 2^53 - 1.
$cStzAmountMax = "9007199254740991"

# The exponent of an ISO 4217 code, or -1 when the code is not in the table.
func StzCurrencyExponent(pcCode)
	if NOT isString(pcCode)
		return -1
	ok
	_cCode_ = StzUpper(StzTrim(pcCode))
	if StzLen(_cCode_) != 3
		return -1
	ok
	_cKey_ = " " + _cCode_ + " "
	if StzFindFirst(_cKey_, $cStzIsoExp0) > 0   return 0   ok
	if StzFindFirst(_cKey_, $cStzIsoExp2) > 0   return 2   ok
	if StzFindFirst(_cKey_, $cStzIsoExp3) > 0   return 3   ok
	if StzFindFirst(_cKey_, $cStzIsoExp4) > 0   return 4   ok
	return -1

func StzIsCurrencyCode(pcCode)
	return StzCurrencyExponent(pcCode) >= 0

func StzAmountQ(pValue, pcCurrency)
	return new stzAmount(pValue, pcCurrency)

	func StzAmount(pValue, pcCurrency)
		return StzAmountQ(pValue, pcCurrency)

class stzAmount from stzObject

	@cCur = ""
	@nExp = 0
	@nMinor = 0

	def init(pValue, pcCurrency)
		if NOT isString(pcCurrency) or StzTrim(pcCurrency) = ""
			StzRaise("An amount needs a currency: an ISO 4217 code such as XOF or EUR.")
		ok
		_cCur_ = StzUpper(StzTrim(pcCurrency))
		_nExp_ = StzCurrencyExponent(_cCur_)
		if _nExp_ < 0
			StzRaise("Unknown currency '" + _cCur_ + "': it is not an ISO 4217 code this table knows.")
		ok
		@cCur = _cCur_
		@nExp = _nExp_

		if isNumber(pValue)
			@nMinor = This._MinorFromNumber(pValue)
		but isString(pValue)
			@nMinor = This._MinorFromText(pValue)
		else
			StzRaise('An amount is spelled as text ("12.50") or a whole number, not a ' +
				'value of another type.')
		ok

	  #-- what it is --------------------------------------------------

	def Currency()
		return @cCur

	def Exponent()
		return @nExp

	def MinorUnits()
		return @nMinor

	def IsZero()
		return @nMinor = 0

	def IsPositive()
		return @nMinor > 0

	def IsNegative()
		return @nMinor < 0

	# The canonical decimal text: the currency's own number of places, signed.
	def Content()
		_cDig_ = ""+This._AbsMinor()
		_cSign_ = ""
		if @nMinor < 0
			_cSign_ = "-"
		ok
		if @nExp = 0
			return _cSign_ + _cDig_
		ok
		# pad on the left so there is at least one digit before the point
		while ring_len(_cDig_) < @nExp + 1
			_cDig_ = "0" + _cDig_
		end
		_nCut_ = ring_len(_cDig_) - @nExp
		_cInt_ = ""
		_cFrac_ = ""
		for _i_ = 1 to ring_len(_cDig_)
			if _i_ <= _nCut_
				_cInt_ += _cDig_[_i_]
			else
				_cFrac_ += _cDig_[_i_]
			ok
		next
		return _cSign_ + _cInt_ + "." + _cFrac_

	# How a reader of the UEMOA reads it: grouped thousands, FCFA for both francs.
	def Display()
		_cC_ = This.Content()
		_cSign_ = ""
		if @nMinor < 0
			_cSign_ = "-"
			_cC_ = ""
			_cDigAll_ = This.Content()
			for _i_ = 2 to ring_len(_cDigAll_)
				_cC_ += _cDigAll_[_i_]
			next
		ok
		_cInt_ = ""
		_cFrac_ = ""
		_bPoint_ = 0
		for _i_ = 1 to ring_len(_cC_)
			if _cC_[_i_] = "."
				_bPoint_ = 1
			but _bPoint_ = 0
				_cInt_ += _cC_[_i_]
			else
				_cFrac_ += _cC_[_i_]
			ok
		next
		# group the integer part in threes from the right
		_cGrouped_ = ""
		_nL_ = ring_len(_cInt_)
		for _i_ = 1 to _nL_
			_cGrouped_ += _cInt_[_i_]
			_nLeft_ = _nL_ - _i_
			if _nLeft_ > 0 and _nLeft_ % 3 = 0
				_cGrouped_ += " "
			ok
		next
		if _bPoint_ = 1
			_cGrouped_ += "." + _cFrac_
		ok
		_cName_ = @cCur
		if @cCur = "XOF" or @cCur = "XAF"
			_cName_ = "FCFA"
		ok
		return _cSign_ + _cGrouped_ + " " + _cName_

	  #-- arithmetic inside one currency ----------------------------------

	def Plus(poOther)
		This._RequireSameCurrency(poOther, "add")
		return This._Make(@nMinor + poOther.MinorUnits())

	def Minus(poOther)
		This._RequireSameCurrency(poOther, "subtract")
		return This._Make(@nMinor - poOther.MinorUnits())

	# A rate would need a rounding rule, and a payment has none to give, so the
	# only multiplier is a whole number.
	def TimesInteger(pn)
		if NOT isNumber(pn) or pn != floor(pn)
			StzRaise("TimesInteger needs a whole number: an amount is never multiplied by a fraction.")
		ok
		return This._Make(@nMinor * pn)

	def Negated()
		return This._Make(0 - @nMinor)

	def Equals(poOther)
		if NOT isObject(poOther)
			return 0
		ok
		return @cCur = poOther.Currency() and @nMinor = poOther.MinorUnits()

	def IsGreaterThan(poOther)
		This._RequireSameCurrency(poOther, "compare")
		return @nMinor > poOther.MinorUnits()

	def IsLessThan(poOther)
		This._RequireSameCurrency(poOther, "compare")
		return @nMinor < poOther.MinorUnits()

	# `oA + oB`, `oA - oB`. The `=` operator is deliberately not here.
	def operator(pOp, pValue)
		if pOp = "+"
			return This.Plus(pValue)
		but pOp = "-"
			return This.Minus(pValue)
		ok
		StzRaise("An amount supports + and - with another amount of the same currency; " +
			"use TimesInteger for a multiple.")

	PRIVATE

	def _AbsMinor()
		if @nMinor < 0
			return 0 - @nMinor
		ok
		return @nMinor

	def _RequireSameCurrency(poOther, pcWhat)
		if NOT isObject(poOther)
			StzRaise("Cannot " + pcWhat + " an amount and something that is not an amount.")
		ok
		if @cCur != poOther.Currency()
			StzRaise("Cannot " + pcWhat + " " + @cCur + " and " + poOther.Currency() +
				": an amount is never converted between currencies implicitly.")
		ok

	def _Make(pnMinor)
		if pnMinor > 9007199254740991 or pnMinor < -9007199254740991
			StzRaise("The result is beyond the exact integer range of an amount (2^53 - 1 minor units).")
		ok
		# rebuild through the one parser, so every amount passes the same door
		_o_ = new stzAmount("0", @cCur)
		_o_._SetMinor(pnMinor)
		return _o_

	def _SetMinor(pn)
		@nMinor = pn

	def _MinorFromNumber(pn)
		if pn != floor(pn)
			StzRaise('A fractional number is refused as an amount: spell it as text, ' +
				'for example "12.50". A float cannot hold most decimal fractions exactly.')
		ok
		_nMinor_ = pn
		for _i_ = 1 to @nExp
			_nMinor_ = _nMinor_ * 10
		next
		if _nMinor_ > 9007199254740991 or _nMinor_ < -9007199254740991
			StzRaise("The amount is beyond the exact integer range (2^53 - 1 minor units).")
		ok
		return _nMinor_

	def _MinorFromText(pc)
		_c_ = StzTrim(pc)
		_nL_ = ring_len(_c_)
		_bNeg_ = 0
		_nStart_ = 1
		if _nL_ > 0 and _c_[1] = "-"
			_bNeg_ = 1
			_nStart_ = 2
		ok
		_cInt_ = ""
		_cFrac_ = ""
		_bPoint_ = 0
		_nDigits_ = 0
		for _i_ = _nStart_ to _nL_
			_ch_ = _c_[_i_]
			if _ch_ = "."
				if _bPoint_ = 1 or _nDigits_ = 0
					This._RefuseText(pc)
				ok
				_bPoint_ = 1
			but _ch_ >= "0" and _ch_ <= "9"
				_nDigits_++
				if _bPoint_ = 0
					_cInt_ += _ch_
				else
					_cFrac_ += _ch_
				ok
			else
				This._RefuseText(pc)
			ok
		next
		if _cInt_ = ""
			This._RefuseText(pc)
		ok
		if _bPoint_ = 1 and _cFrac_ = ""
			This._RefuseText(pc)
		ok

		# digits beyond the exponent are allowed only when they are all zero
		_nFrac_ = ring_len(_cFrac_)
		if _nFrac_ > @nExp
			for _i_ = @nExp + 1 to _nFrac_
				if _cFrac_[_i_] != "0"
					StzRaise("" + @cCur + " has " + @nExp + " decimals: '" + pc +
						"' cannot be represented, and an amount is never rounded.")
				ok
			next
		ok

		# minor digits = integer part + exactly @nExp fraction digits
		_cDig_ = _cInt_
		for _i_ = 1 to @nExp
			if _i_ <= _nFrac_
				_cDig_ += _cFrac_[_i_]
			else
				_cDig_ += "0"
			ok
		next
		# strip leading zeros, keep one
		while ring_len(_cDig_) > 1 and _cDig_[1] = "0"
			_cShort_ = ""
			for _i_ = 2 to ring_len(_cDig_)
				_cShort_ += _cDig_[_i_]
			next
			_cDig_ = _cShort_
		end
		if ring_len(_cDig_) > 16 or ( ring_len(_cDig_) = 16 and _cDig_ > $cStzAmountMax )
			StzRaise("The amount '" + pc + "' is beyond the exact integer range (2^53 - 1 minor units).")
		ok
		_nMinor_ = ring_number(_cDig_)
		if _bNeg_ = 1
			_nMinor_ = 0 - _nMinor_
		ok
		return _nMinor_

	def _RefuseText(pc)
		StzRaise("'" + pc + "' is not a decimal amount: digits, at most one point, an optional " +
			"leading minus, and no spaces or thousands separators.")
