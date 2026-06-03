# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #3.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([
	[ "mohannad", 	100, "him", "ring" ],
	[ "karim", 	20 , "hi" ],
	[ "salem", 	67 ]
])

? @@( o1.NthList(3) ) + NL
#--> [ "salem", 67 ]

? @@( o1.NthCol(3) )
#--> [ "him", "hi" ]

? @@( o1.NthCol(4) )
#--> [ "ring"]

pf()
# Executed in 0.02 second(s) in Ring 1.21
