# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #46.

load "../../../stzBase.ring"


o1 = new stzLists([
	[ "A", "B", "C" ],
	[ "D", "E", "F", "G" ],
	[ "H", "I" ]
])

o1.ShrinkTo(1)

? @@( o1.Content() )
#--> [ [ "A" ], [ "D" ], [ "H" ] ]

pf()
# Executed in 0.12 second(s)
