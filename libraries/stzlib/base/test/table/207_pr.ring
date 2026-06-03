# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #207.

load "../../stzBase.ring"


o1 = new stzTable([
	[ :NAME, :HOBBIES		],
	[ "kim", [ "Sport", "Music" ]	],
	[ "Dan", [ "Gaming" ]		],
	[ "Sam", [ "Music", "Travel" ]	]
])

o1.Show()
#--> NAME                HOBBIES
#   ----- ----------------------
#    kim    [ "Sport", "Music" ]
#    Dan            [ "Gaming" ]
#    Sam   [ "Music", "Travel" ]

pf()
# Executed in 0.11 second(s)

#============

pr()

o1 = new stzTable([

	[ "COUNTRY",	"INCOME",	"POPULATION" 	],
	#-----------------------------------------------#
	[ "USA",	   25450,	        340.1	],
	[ "China",	   18150,	       1430.1	],
	[ "Japan",	    5310,		123.2	],
	[ "Germany",	    4490,	         83.3	],
	[ "India",	    3370,	       1430.2	]

])

o1.InsertRow(3, [ "Niger", 3616, 26.21 ])
o1.Show()

#--> COUNTRY   INCOME   POPULATION
#    -------- -------- -----------
#        USA    25450       340.10
#      China    18150      1430.10
#      Niger     3616        26.21
#      Japan     5310       123.20
#    Germany     4490        83.30
#      India     3370      1430.20

pf()
# Executed in 0.02 second(s) without the Show() function
# Executed in 0.10 second(s) with the Show() function
