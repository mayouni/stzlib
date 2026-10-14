

func StzCurrencyQ(pcCurrencyIdentifier)
	return new stzCurrency(pcCurrencyIdentifier)

func CurrenciesXT()
	return CountriesOrRegionsAndTheirCurrenciesXT()

func LocaleCurrenciesXT()
	return CurrenciesXT()

func NumberOfCurrencies()
	return StzEngineRefCountryCount()

func Currencies()
	_aResult_ = []
	_aLocaleCountriesXT6_ = LocaleCountriesXT()
	_nLocaleCountriesXT6Len_ = len(_aLocaleCountriesXT6_)
	for _iLoopLocaleCountriesXT6_ = 1 to _nLocaleCountriesXT6Len_
		_aCountryInfo_ = _aLocaleCountriesXT6_[_iLoopLocaleCountriesXT6_]
		# Column layout: [7]=currency name, [8]=fractional unit, [9]=base.
		_aResult_ + _aCountryInfo_[7]
	next

	return _aResult_
	
func LocaleCurrencies()
	return Currencies()

func CountriesOrRegionsAndTheirCurrenciesXT()
	_aResult_ = []
	_aLocaleCountriesXT5_ = LocaleCountriesXT()
	_nLocaleCountriesXT5Len_ = len(_aLocaleCountriesXT5_)
	for _iLoopLocaleCountriesXT5_ = 1 to _nLocaleCountriesXT5Len_
		_aCountryInfo_ = _aLocaleCountriesXT5_[_iLoopLocaleCountriesXT5_]
		# Currency info is the triple [ name, fractional unit, base ]
		# built from columns [7],[8],[9] of the country row.
		_aResult_ + [ _aCountryInfo_[2], [ _aCountryInfo_[7], _aCountryInfo_[8], _aCountryInfo_[9] ] ]
	next
	
	return _aResult_

func CountriesOrRegionsAndTheirCurrencies()
		_aResult_ = []
		_aLocaleCountriesXT4_ = LocaleCountriesXT()
		_nLocaleCountriesXT4Len_ = len(_aLocaleCountriesXT4_)
		for _iLoopLocaleCountriesXT4_ = 1 to _nLocaleCountriesXT4Len_
			_aCountryInfo_ = _aLocaleCountriesXT4_[_iLoopLocaleCountriesXT4_]
			_aResult_ + [ _aCountryInfo_[2], _aCountryInfo_[7] ]
		next
	
		return _aResult_

func CurrenciesAndTheirCountriesOrRegionsXT()
	_aResult_ = []
	_aLocaleCountriesXT3_ = LocaleCountriesXT()
	_nLocaleCountriesXT3Len_ = len(_aLocaleCountriesXT3_)
	for _iLoopLocaleCountriesXT3_ = 1 to _nLocaleCountriesXT3Len_
		_aCountryInfo_ = _aLocaleCountriesXT3_[_iLoopLocaleCountriesXT3_]
		_aResult_ + [ [ _aCountryInfo_[7], _aCountryInfo_[8], _aCountryInfo_[9] ], _aCountryInfo_[2] ]
	next
	
	return _aResult_

func CurrenciesAndTheirCountriesOrRegions()
	_aResult_ = []
	_aLocaleCountriesXT2_ = LocaleCountriesXT()
	_nLocaleCountriesXT2Len_ = len(_aLocaleCountriesXT2_)
	for _iLoopLocaleCountriesXT2_ = 1 to _nLocaleCountriesXT2Len_
		_aCountryInfo_ = _aLocaleCountriesXT2_[_iLoopLocaleCountriesXT2_]
		_aResult_ + [ _aCountryInfo_[7], _aCountryInfo_[2] ]
	next
	
	return _aResult_

# Holds the currency of one country, with its codes, its names and its fractional unit, read from the locale data.
#
# The object is built from a country name, spelled as the locale data spells it (lower case, with
# underscores for spaces), and answers the currency that country uses: its name, its three-letter
# code, its native symbol, its fractional unit and the number of those units in one. Because it
# starts from a country, the country stays exact even for a currency many countries share. Building
# it from a currency name, a symbol or a locale abbreviation is not supported today.
#
#   receiver   o1 = new stzCurrency("niger")
#   example    ? o1.Currency()
#              #--> west_african_cfa_franc
#              ? o1.ISOSymbol()
#              #--> XOF
#              ? o1.FractionalUnit()
#              #--> Centime
#              ? o1.CountryLocaleAbbreviation()
#              #--> fr-NE
#   see        stzCountry, stzLocale, stzLanguage
class stzCurrency from stzObject

	# Builds a currency object from the name of a country, written as in the locale data: lower case with underscores.
	#
	#   pcCurrencyIdentifier   a country name such as niger or united_states
	#   returns                nothing; the object is built
	#   note                   spelling and case are free for a country that is in the data, so
	#                          Niger and niger are the same
	#   warning                a currency name such as euro, a symbol such as XOF or a locale
	#                          abbreviation such as fr-NE is not understood today: the currency-name
	#                          test compares against country names, so the name is refused with
	#                          error R3 (the error function stzCurrencyError is not loaded), and a
	#                          locale abbreviation is accepted but builds an empty object whose
	#                          Currency answers N
	#   see                    Currency, Country
	#@ aka  NOTE: the class have a @cCurrencyInfo@ attribute in PRIVATE section We put it there, because we use it just for initializing the object. --> it does not necesarilay contain all the information the class could provide about the currency.
	def init(pcCurrencyIdentifier)

		# Was `IsCountryName(...)` -- no global func with that name
		# exists. Switched to the stzString-method form, which is
		# consistent with the other branches below.
		if StzStringQ(pcCurrencyIdentifier).IsCountryName()

			_aCountriesOrRegionsAndThe1_ = CountriesOrRegionsAndTheirCurrenciesXT()
			_nCountriesOrRegionsAndThe1Len_ = len(_aCountriesOrRegionsAndThe1_)
			for _iLoopCountriesOrRegionsAndThe1_ = 1 to _nCountriesOrRegionsAndThe1Len_
				_aCountryInfo_ = _aCountriesOrRegionsAndThe1_[_iLoopCountriesOrRegionsAndThe1_]
				if StzLower(_aCountryInfo_[1]) = StzLower(pcCurrencyIdentifier)

					@aCurrencyInfo@ = _aCountryInfo_[2]
					# Remember the originating country so Country() and the
					# locale-abbreviation lookup stay exact. Without this,
					# Country() reverse-maps currency->country, which is
					# ambiguous for shared currencies (e.g. euro -> many
					# countries) and crashed Abbreviation() with R2.
					@cCountry@ = StzLower(_aCountryInfo_[1])
					exit
				ok
			next

		but StzStringQ(pcCurrencyIdentifier).IsCurrencyName()

			# Match on the currency name (column [7]) directly and build
			# the [ name, fractional unit, base ] triple from [7],[8],[9].
			_aLocaleCountriesXTCur_ = LocaleCountriesXT()
			_nLocaleCountriesXTCurLen_ = len(_aLocaleCountriesXTCur_)
			for _iLoopCur_ = 1 to _nLocaleCountriesXTCurLen_
				_aCountryInfo_ = _aLocaleCountriesXTCur_[_iLoopCur_]
				if StzLower(_aCountryInfo_[7]) = StzLower(pcCurrencyIdentifier)
					@aCurrencyInfo@ = [ _aCountryInfo_[7], _aCountryInfo_[8], _aCountryInfo_[9] ]
					exit
				ok
			next

		but StzStringQ(pcCurrencyIdentifier).IsCurrencySymbol()
			// TODO

		but StzStringQ(pcCurrencyIdentifier).IsLocaleAbbreviation()
			// TODO

		else
			StzRaise(stzCurrencyError(:UnsupportedCurrencyIdentifier))
		ok

	# Returns the international three-letter code of the currency, as the country's locale spells it.
	#
	#   returns    a text such as XOF
	#   see        NativeSymbol, Currency
	def ISOSymbol()
		return StzLocaleQ(This.CountryLocaleAbbreviation()).CurrencyISOSymbol()

		# Abbreviation / NativeAbbreviation: short-form aliases that
		# narrative tests reach for. Both currently route through
		# the ISO/native symbol resolvers since the underlying
		# data table only carries the symbol shape.
		def Abbreviation()
			return This.ISOSymbol()

		def NativeAbbreviation()
			return This.NativeSymbol()

		def ISOSymbolName()
			return This.ISOSymbol()
		def Symbol()
			return This.ISOSymbol()

		def SymbolName()
			return This.ISOSymbol()

	# Returns the symbol the country's locale writes for the currency.
	#
	#   returns    a text such as CFA or the pound sign
	#   see        ISOSymbol, NativeName
	def NativeSymbol()
		return StzLocaleQ(This.CountryLocaleAbbreviation()).CurrencyNativeSymbol()

		def NativeSymbolName()
			return This.NativeSymbol()

	# Returns the currency's name in the library's spelling, lower case joined by underscores.
	#
	#   returns    a text such as west_african_cfa_franc
	#   see        NativeName, Value
	def Currency()
		return @aCurrencyInfo@[1]

		def Name()
			return This.Currency()
	
	# Returns the currency's name as the country's own locale words it, with spaces.
	#
	#   returns    a text such as west african cfa franc
	#   see        Currency, ISOSymbol
	def NativeName()
		return StzLocaleQ(This.CountryLocaleAbbreviation()).CurrencyNativeName()

	def Content()
		return This.Currency()

		# Returns the currency name, the value of the object.
		#
		#   returns    a text, as Currency answers
		#   see        Currency
		def Value()
			return Content()

	# Returns the name of the currency's fractional unit.
	#
	#   returns    a text such as Centime
	#   see        Base
	def FractionalUnit()
		return @aCurrencyInfo@[2]

	# Returns how many fractional units make one unit of the currency.
	#
	#   returns    a number, such as 100
	#   see        FractionalUnit
	def Base()
		return @aCurrencyInfo@[3]

	# Returns the country the object was built from.
	#
	#   returns    a text in lower case
	#   note       a country name is exact; for a currency shared by many countries, such as the
	#              euro, this is why the object remembers the country it started from
	#   see        CountryLocaleAbbreviation, Currency
	def Country()
		# Exact when the object was built from a country name.
		if @cCountry@ != ""
			return @cCountry@
		ok
		# Otherwise reverse-map currency -> first matching country.
		_aLocaleCountriesXT1_ = LocaleCountriesXT()
		_nLocaleCountriesXT1Len_ = len(_aLocaleCountriesXT1_)
		for _iLoopLocaleCountriesXT1_ = 1 to _nLocaleCountriesXT1Len_
			_aCountryInfo_ = _aLocaleCountriesXT1_[_iLoopLocaleCountriesXT1_]
			if StzLower(_aCountryInfo_[7]) = StzLower(This.Currency())
				return _aCountryInfo_[2]
			ok
		next
		StzRaise(stzCurrencyError(:UnknowanCountry))

	# Returns the locale code of the country, language and region joined by a hyphen.
	#
	#   returns    a text such as fr-NE
	#   see        Country, ISOSymbol
	def CountryLocaleAbbreviation()
		return StzLocaleAbbreviationsXT()[ This.Country() ][1][1][2]


	PRIVATE

	@aCurrencyInfo@
	@cCountry@ = ""


