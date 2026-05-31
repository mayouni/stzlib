# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #63.

load "../../../stzBase.ring"


o1 = new stzLocale("ar_TN")
? o1.Currency()
#--> Tunisian Dinar

? o1.CurrencyXT(:NativeName) #--> دينار تونسي
? o1.CurrencyXT(:Fraction)	 #--> Millime

? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Tunisian Dinar" ],
	[ "nativename", "دينار تونسي" ],
	[ "abbreviation", "TND" ],
	[ "symbol", "د.ت.‏" ],
	[ "nativesymbol", "د.ت.‏" ],
	[ "isosymbol", "TND" ],
	[ "fractionalunit", "Millime" ],
	[ "fraction", "Millime" ],
	[ "base", 1000 ]
]
'

pf()
# Executed in 0.02 second(s) in Ring 1.23
