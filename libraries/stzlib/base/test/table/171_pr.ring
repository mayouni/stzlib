# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #171.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ 10,	"Ali",		35000	],
	[ 20,	"Dania",	28900	],
	[ 30,	"Ben",		25982	],
	[ 40,	"ali",		"Ali"	]
])

? @@( o1.FindInLists("Ali") )
#--> [ [ 1, 2 ], [ 4, 3 ] ]

? @@( o1.FindInListsCS("ali", :CS = FALSE) )
#--> [ [ 1, 2 ], [ 4, 2 ], [ 4, 3 ] ]

pf()
# Executed in 0.03 second(s)
