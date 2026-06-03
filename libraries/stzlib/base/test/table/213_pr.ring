# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #213.

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

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 3 ]) ) + NL # OR FindCellsInSection()
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]

? @@( o1.FindSection([ :INCOME, 3 ], [ :POPULATION, 1 ]) ) + NL
#--> [ [ 2, 3 ], [ 2, 4 ], [ 2, 5 ], [ 3, 1 ] ]

? @@( o1.FindSection([ :INCOME, 2 ], [ :INCOME, 5 ]) ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ] ]

? @@( o1.FindSection([ :POPULATION, 2 ], [ :POPULATION, 4 ]) ) + NL
# [ [ 3, 2 ], [ 3, 3 ], [ 3, 4 ] ]

pf()
# Executed in 0.06 second(s)
