# Narrative
# --------
# pr()
#
# Extracted from stzList2DTest.ring, block #1.

load "../../stzBase.ring"

pr()

o1 = new stzList2D([
	[ "A", "B", "C" ],
	[  10,  20,  30 ]
])

? @@NL( o1.Content() )
#--> [
#	[ "A", "B", "C" ],
#	[ 10, 20, 30 ]
# ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
