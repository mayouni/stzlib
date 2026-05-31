# Narrative
# --------
# Currency
#
# Extracted from stzlocaletest.ring, block #62.

load "../../../stzBase.ring"


pr()

o1 = new stzLocale("iran")

? o1.CurrencySymbol()		#--> ریال
? o1.CurrencySymbol()		#--> ریال
? o1.CurrencyISOSymbol() 	#--> IRR

? o1.CurrencyNativeName()	#--> ریال ایران
? o1.CurrencyName()			#--> Iranian Rial
? o1.CurrencyFraction()		#--> Rial
? o1.CurrencyBase()			#--> 100

? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Iranian Rial" ],
	[ "nativename", "ریال ایران" ],
	[ "abbreviation", "IRR" ],
	[ "symbol", "ریال" ],
	[ "nativesymbol", "ریال" ],
	[ "isosymbol", "IRR" ],
	[ "fractionalunit", "Rial" ],
	[ "fraction", "Rial" ],
	[ "base", 100 ]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
