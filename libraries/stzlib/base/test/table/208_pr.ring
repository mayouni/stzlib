# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #208.

load "../../stzBase.ring"


o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRowAt([ 2, 4, 5 ] , [ "~~~~~~~~", "~~~~~~~~", "~~~~~~~~" ])
# Or InsertRowAtPositions() or InsertRow() or InsertRowAt() or
# InsertRow( :At = ...) or InsertRow( :AtPositions = ...)

o1.Show()
#-->  COUNTRY     INCOME   POPULATION
#    --------- ---------- -----------
#         USA      25450       340.10
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       China      18150      1430.10
#       Japan       5310       123.20
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#     Germany       4490        83.30
#    ~~~~~~~~   ~~~~~~~~     ~~~~~~~~
#       India       3370      1430.20

pf()
# Executed in 0.13 second(s)
