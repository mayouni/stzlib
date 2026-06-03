# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #1.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "mohannad", 	100, "hi", "ring" ],
	[ "karim", 	20 , "hi" ],
	[ "salem", 	67 ]
])

? o1.HowManyMissing()
#--> 3

? @@( o1.Sizes() )
#--> [ 4, 2, 2 ]

? o1.MinSize()
#--> 2

? o1.Maxsize()
#--> 4

? @@( o1.FindMissing() ) + NL
#--> [ [ 2, 4 ], [ 3, 3 ], [ 3, 4 ] ]

o1.Extend()

? @@NL( o1.Content() )
#--> [
#	[ "mohannad", 100, "hi", "ring" ],
#	[ "karim",     20, "hi", ""     ],
#	[ "salem",      67,  "", ""     ]
# ]

? o1.HowManyMissing()
#--> 0

pf()
# Executed in 0.02 second(s) in Ring 1.21
