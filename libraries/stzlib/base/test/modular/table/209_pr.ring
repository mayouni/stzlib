# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #209.

load "../../../stzBase.ring"


# Income in million dollars per year
# Population in million people
# Percapiat (calculated) in thousand dollars per year
# Source: WolframAlpha

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",        4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.AddCalculatedCol(:PERCAPITA, '@(:INCOME) / @(:POPULATION)')
? o1.Show()
#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450          340       74.85
#      China    18150         1430       12.69
#      Japan     5310          123       43.17
#    Germany     4490        83.30       53.90
#      India     3370         1430        2.36

o1.InsertCalculatedCol(2, :CURRENCY, 'StzCountryQ(@(:COUNTRY)).CurrencyAbbreviation()')
? o1.Show()
#-->
# COUNTRY   CURRENCY   INCOME   POPULATION   PERCAPITA
# -------- ---------- -------- ------------ ----------
#     USA        USD    25450       340.10       74.83
#   China        CNY    18150      1430.10       12.69
#   Japan        JPY     5310       123.20       43.10
# Germany        EUR     4490        83.30       53.90
#   India        INR     3370      1430.20        2.36

? @@( o1.FindCalculatedCols() ) + NL
#--> [ 2, 4 ]

? o1.CalculatedColNames()
#--> [ "currency", "population" ]

? @@NL( o1.CalculatedCols() ) + NL
#--> [
#	[ "USD", "CNY", "JPY", "EUR", "INR" ],
#	[ 340.10, 1430.10, 123.20, 83.30, 1430.20 ]
# ]

#--

o1.AddCalculatedRow([
'', '', '@Sum( @(:INCOME) )', '@Sum( @(:POPULATION) )', '@Average( @(:PERCAPITA) )'
])

? o1.Show()

#--> COUNTRY   INCOME   POPULATION   PERCAPITA
#    -------- -------- ------------ ----------
#        USA    25450       340.10       74.83
#      China    18150      1430.10       12.69
#      Japan     5310       123.20       43.10
#    Germany     4490        83.30       53.90
#      India     3370      1430.20        2.36
#               56770      3406.90       37.38

? @@( o1.FindCalculatedRows() ) + NL
#--> [ 6 ]

? @@( o1.CalculatedRows() ) + NL
#--> [ [ " ", " ", 56770, 3406.90, 37.38 ] ]

pf()
# Executed in 0.52 second(s)
