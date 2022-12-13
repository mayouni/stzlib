

func StzCurrencyQ(pcCurrencyIdentifier)
	return new stzCurrency(pcCurrencyIdentifier)

func CurrenciesXT()
	return CountriesOrRegionsAndTheirCurrenciesXT()

func LocaleCurrenciesXT()
	return CurrenciesXT()

func Currencies()
	aResult = []
	for aCountryInfo in LocaleCountriesXT()
		aResult + aCountryInfo[7][1]
	next
	
	return aResult
	
func LocaleCurrencies()
	return Currencies()

func CountriesOrRegionsAndTheirCurrenciesXT()
	aResult = []
	for aCountryInfo in LocaleCountriesXT()
		aResult + [ aCountryInfo[2], aCountryInfo[7] ]
	next
	
	return aResult

func CountriesOrRegionsAndTheirCurrencies()
		aResult = []
		for aCountryInfo in LocaleCountriesXT()
			aResult + [ aCountryInfo[2], aCountryInfo[7][1] ]
		next
	
		return aResult

func CurrenciesAndTheirCountriesOrRegionsXT()
	aResult = []
	for aCountryInfo in LocaleCountriesXT()
		aResult + [ aCountryInfo[7], aCountryInfo[2] ]
	next
	
	return aResult

func CurrenciesAndTheirCountriesOrRegions()
	aResult = []
	for aCountryInfo in LocaleCountriesXT()
		aResult + [ aCountryInfo[7][1], aCountryInfo[2] ]
	next
	
	return aResult

class stzCurrency

	# NOTE: the class have a @cCurrencyInfo@ attribute in PRIVATE section
	# We put it there, because we use it just for initializing the object.
	# --> it does not necesarilay contain all the information the class
	# could provide about the currency.

	def init(pcCurrencyIdentifier)

		if StzStringQ(pcCurrencyIdentifier).IsCountryName()

			for aCountryInfo in CountriesOrRegionsAndTheirCurrenciesXT()
				if lower(aCountryInfo[1]) = lower(pcCurrencyIdentifier)

					@aCurrencyInfo@ = aCountryInfo[2]
					exit
				ok
			next

		but StzStringQ(pcCurrencyIdentifier).IsCurrencyName()

			for aCurrencyInfo in CurrenciesXT()
				if lower(aCurrencyInfo[1]) = lower(pcCurrencyIdentifier)
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
		return StzLocaleQ([ :Country = This.Country() ]).CurrencyISOSymbol()

		def ISOSymbolName()
			return This.ISOSymbol()
		def Symbol()
			return This.ISOSymbol()

		def SymbolName()
			return This.ISOSymbol()

	def NativeSymbol()
		return StzLocaleQ([ :Country = This.Country() ]).CurrencyNativeSymbol()

		def NativeSymbolName()
			return This.NativeSymbol()

	def Currency()
		return @aCurrencyInfo@[1]

		def Name()
			return This.Currency()
	
	def NativeName()
		return StzLocaleQ([ :Country = This.Country() ]).CurrencyNativeName()

	def Content()
		return This.Currency()

	def FractionalUnit()
		return @aCurrencyInfo@[2]

	def Base()
		return @aCurrencyInfo@[3]

	def Country()
		for aCountryInfo in LocaleCountriesXT()
			if lower(aCountryInfo[7][1]) = lower(This.Currency())
				return aCountryInfo[2]
			ok
		next
		StzRaise(stzCurrencyError(:UnknowanCountry))

	PRIVATE

	@aCurrencyInfo@


