# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #64.

load "../../stzBase.ring"

pr()

o1 = new stzLocale("ru_RU")
? @@NL( o1.CurrencyInfo() )
#-->
'
[
	[ "name", "Russian Ruble" ],
	[ "nativename", "российский рубль" ],
	[ "abbreviation", "RUB" ],
	[ "symbol", "₽" ],
	[ "nativesymbol", "₽" ],
	[ "isosymbol", "RUB" ],
	[ "fractionalunit", "Kopek" ],
	[ "fraction", "Kopek" ],
	[ "base", 100 ]
]
'

? o1.CurrencyXT(:Name)			#--> Russian Ruble
? o1.CurrencyXT(:ISOSymbol)		#--> RUB
? o1.CurrencyXT(:NativeSymbol)	#--> ₽
? o1.CurrencyXT(:NativeName)	#--> российский рубль

pf()
# Executed in 0.03 second(s) in Ring 1.23
