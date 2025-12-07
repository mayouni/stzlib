load "../stzmax.ring"

/*--------------------------

? LocaleCurrenciesXT()[:europe]
? CountriesOrRegionsAndTheirCurrenciesXT()[:united_states]

/*--------------------------

? StzCurrencyQ(:United_States).Currency()

/*--------------------------

o1 = new stzCurrency(:United_States)
? o1.Currency()

/*--------------------------
*/
StzCurrencyQ(:Russia) {

	? "Currency name:"
	? "--------------"
	? Name()
	? NativeName()
	? Currency()
	
 	? "Currency abbreviation:"
	? "--------------------"
	? Abbreviation()

	? "Currency native abbreviation:"
	? "--------------------"
	? NativeAbbreviation()

	? "Currency Fractional unit and base:"
	? "----------------------------------"
	? FractionalUnit()
	? Base()

}
