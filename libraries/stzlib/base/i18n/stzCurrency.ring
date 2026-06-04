

func StzCurrencyQ(pcCurrencyIdentifier)
	return new stzCurrency(pcCurrencyIdentifier)

func CurrenciesXT()
	return CountriesOrRegionsAndTheirCurrenciesXT()

func LocaleCurrenciesXT()
	return CurrenciesXT()

func NumberOfCurrencies()
	return StzEngineRefCountryCount()

func Currencies()
	aResult = []
	_aLocaleCountriesXT6_ = LocaleCountriesXT()
	_nLocaleCountriesXT6Len_ = ring_len(_aLocaleCountriesXT6_)
	for _iLoopLocaleCountriesXT6_ = 1 to _nLocaleCountriesXT6Len_
		aCountryInfo = _aLocaleCountriesXT6_[_iLoopLocaleCountriesXT6_]
		aResult + aCountryInfo[7][1]
	next

	return aResult
	
func LocaleCurrencies()
	return Currencies()

func CountriesOrRegionsAndTheirCurrenciesXT()
	aResult = []
	_aLocaleCountriesXT5_ = LocaleCountriesXT()
	_nLocaleCountriesXT5Len_ = ring_len(_aLocaleCountriesXT5_)
	for _iLoopLocaleCountriesXT5_ = 1 to _nLocaleCountriesXT5Len_
		aCountryInfo = _aLocaleCountriesXT5_[_iLoopLocaleCountriesXT5_]
		aResult + [ aCountryInfo[2], aCountryInfo[7] ]
	next
	
	return aResult

func CountriesOrRegionsAndTheirCurrencies()
		aResult = []
		_aLocaleCountriesXT4_ = LocaleCountriesXT()
		_nLocaleCountriesXT4Len_ = ring_len(_aLocaleCountriesXT4_)
		for _iLoopLocaleCountriesXT4_ = 1 to _nLocaleCountriesXT4Len_
			aCountryInfo = _aLocaleCountriesXT4_[_iLoopLocaleCountriesXT4_]
			aResult + [ aCountryInfo[2], aCountryInfo[7][1] ]
		next
	
		return aResult

func CurrenciesAndTheirCountriesOrRegionsXT()
	aResult = []
	_aLocaleCountriesXT3_ = LocaleCountriesXT()
	_nLocaleCountriesXT3Len_ = ring_len(_aLocaleCountriesXT3_)
	for _iLoopLocaleCountriesXT3_ = 1 to _nLocaleCountriesXT3Len_
		aCountryInfo = _aLocaleCountriesXT3_[_iLoopLocaleCountriesXT3_]
		aResult + [ aCountryInfo[7], aCountryInfo[2] ]
	next
	
	return aResult

func CurrenciesAndTheirCountriesOrRegions()
	aResult = []
	_aLocaleCountriesXT2_ = LocaleCountriesXT()
	_nLocaleCountriesXT2Len_ = ring_len(_aLocaleCountriesXT2_)
	for _iLoopLocaleCountriesXT2_ = 1 to _nLocaleCountriesXT2Len_
		aCountryInfo = _aLocaleCountriesXT2_[_iLoopLocaleCountriesXT2_]
		aResult + [ aCountryInfo[7][1], aCountryInfo[2] ]
	next
	
	return aResult

class stzCurrency

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
			_nCountriesOrRegionsAndThe1Len_ = ring_len(_aCountriesOrRegionsAndThe1_)
			for _iLoopCountriesOrRegionsAndThe1_ = 1 to _nCountriesOrRegionsAndThe1Len_
				aCountryInfo = _aCountriesOrRegionsAndThe1_[_iLoopCountriesOrRegionsAndThe1_]
				if StzLower(aCountryInfo[1]) = StzLower(pcCurrencyIdentifier)

					@aCurrencyInfo@ = aCountryInfo[2]
					exit
				ok
			next

		but StzStringQ(pcCurrencyIdentifier).IsCurrencyName()

			_aCurrenciesXT1_ = CurrenciesXT()
			_nCurrenciesXT1Len_ = ring_len(_aCurrenciesXT1_)
			for _iLoopCurrenciesXT1_ = 1 to _nCurrenciesXT1Len_
				aCurrencyInfo = _aCurrenciesXT1_[_iLoopCurrenciesXT1_]
				if StzLower(aCurrencyInfo[1]) = StzLower(pcCurrencyIdentifier)
					@aCurrencyInfo@ = aCurrencyInfo
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
		_aLocaleCountriesXT1_ = LocaleCountriesXT()
		_nLocaleCountriesXT1Len_ = ring_len(_aLocaleCountriesXT1_)
		for _iLoopLocaleCountriesXT1_ = 1 to _nLocaleCountriesXT1Len_
			aCountryInfo = _aLocaleCountriesXT1_[_iLoopLocaleCountriesXT1_]
			if StzLower(aCountryInfo[7][1]) = StzLower(This.Currency())
				return aCountryInfo[2]
			ok
		next
		StzRaise(stzCurrencyError(:UnknowanCountry))

	def CountryLocaleAbbreviation()
		return StzLocaleAbbreviationsXT()[ This.Country() ][1][1][2]


	PRIVATE

	@aCurrencyInfo@


