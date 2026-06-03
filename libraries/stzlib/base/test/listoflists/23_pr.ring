# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #23.

load "../../stzBase.ring"


? Intersection([
	[ "A", "A", "X", "B", "C" ],
	[ "B", "A", "C", "B", "A", "X" ],
	[ "C", "X", "Z", "A" ]
])
#--> [ "A", "X", "C" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
