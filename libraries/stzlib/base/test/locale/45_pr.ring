# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #45.

load "../../stzBase.ring"


StzLocaleQ([ :Country = :Qatar ]) {

	? CurrencyName()			#--> Qatari Riyal
	? CurrencyNativeName()		#--> ريال قطري
	? CurrencySymbol()			#--> ر.ق.‏
	? CurrencyAbbreviation()	#--> QAR
	? CurrencyFraction()		#--> Dirham
	? CurrencyBase()			#--> 100

}

pf()
# Executed in 0.01 second(s) in Ring 1.23
