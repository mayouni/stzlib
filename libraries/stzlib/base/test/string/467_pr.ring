# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #467.
#ERR Error (R14) : Calling Method without definition: removewxtq

load "../../stzBase.ring"

pr()

? @@( Q([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
	RemoveWXTQ('isNumber(@item)').
	RemoveSpacesQ().
	RemoveDuplicatedItemsQ().
	Content() ) + NL

#--> [ "A", "B", "C", "D" ]

? @@NL( QH([ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ]).
	RemoveWXTQ('isNumber(@item)').
	RemoveSpacesQ().
	RemoveDuplicatedItemsQ().
	History() ) 

#--> [
#	[ " ", 1, " ", "A", "A", 2, "B", 3, "C", "C", "C", 4, "D", "D" ],
#	[ " ", " ", "A", "A", "B", "C", "C", "C", "D", "D" ],
#	[ "A", "A", "B", "C", "C", "C", "D", "D" ],
#	[ "A", "B", "C", "D" ]
# ]

pf()
# Executed in 0.17 second(s) in Ring 1.22
