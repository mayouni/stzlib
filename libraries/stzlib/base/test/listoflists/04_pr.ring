# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #4.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "mohannad", 	100, "him", "ring" ],
	[ "karim", 	20 , ["hi"] ],
	[ "salem", 	67 ]
])

o1.Sort()

? @@NL( o1.Content() )
#--> [
#	[ "karim", 20, [ "hi" ] ],
#	[ "mohannad", 100, "him", "ring" ],
#	[ "salem", 67 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.24
# Executed in 0.02 second(s) in Ring 1.21
