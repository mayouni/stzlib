# Narrative
# --------
# */
#
# Extracted from stzcurrencytest.ring, block #4.

load "../../stzBase.ring"

pr()

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

pf()
