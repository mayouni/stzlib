# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #253.

load "../../stzBase.ring"

pr()

aList = [ "A", "B", 1, "A", "A", 1, "C", 1:2, "D", "B", "E", '"1"', 1:2 ]
o1 = new stzList(aList)

? @@( o1.DuplicatesZ() )
#--> [
#	[ "A", 		[ 4, 5 ] ],
#	[ "B", 		[ 10 ]   ],
#	[ 1, 		[ 6 ]    ],
#	[ [ 1, 2 ], 	[ 13 ]   ]
# ]
? ""
? @@( o1.DuplicatesXTZ() )
#--> [
#	[ "A", 		[ 1, 4, 5 ] ],
#	[ "B", 		[ 2, 10 ]   ],
#	[ 1, 		[ 3, 6 ]    ],
#	[ "C",		[ 7 ]	    ],
#	[ [ 1, 2 ], 	[ 8, 13 ]   ],
#	[ "D", 		[ 9 ] 	    ],
#	[ "E", 		[ 11 ]      ],
#	[ '"1"', 	[ 12 ] 	    ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
