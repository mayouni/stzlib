

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

class stzCurrency from stzObject

	#NOTE: the class have a @cCurrencyInfo@ attribute in PRIVATE section
	# We put it there, because we use it just for initializing the object.
	#--> it does not necesarilay contain all the information the class
	# could provide about the currency.

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

	def NativeSymbol()
		return StzLocaleQ(This.CountryLocaleAbbreviation()).CurrencyNativeSymbol()

		def NativeSymbolName()
			return This.NativeSymbol()

	def Currency()
		return @aCurrencyInfo@[1]

		def Name()
			return This.Currency()
	
	def NativeName()
		return StzLocaleQ(This.CountryLocaleAbbreviation()).CurrencyNativeName()

	def Content()
		return This.Currency()

		def Value()
			return Content()

	def FractionalUnit()
		return @aCurrencyInfo@[2]

	def Base()
		return @aCurrencyInfo@[3]

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

	def CountryLocaleAbbreviation()
		return StzLocaleAbbreviationsXT()[ This.Country() ][1][1][2]


	PRIVATE

	@aCurrencyInfo@
	@cCountry@ = ""


