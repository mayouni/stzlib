# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #48.

load "../../stzBase.ring"


o1 = new stzListOfLists([
	[ "A", "B" ],
	[ "C", "D", "E", "F"],
	[ "I" ]
])

? @@( o1.Shrinked() ) + NL
#--> [ [ "A" ], [ "C" ], [ "I" ] ]

? @@( o1.Extended() )
#--> [
#	[ "A", "B", "", "" ],
#	[ "C", "D", "E", "F" ],
#	[ "I", "", "", "" ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.20
