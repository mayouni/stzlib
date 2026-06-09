# Narrative
# --------
# */
#
# Extracted from stzcurrencytest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

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
