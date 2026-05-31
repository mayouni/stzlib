# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #56.

load "../../../stzBase.ring"


? @@NL( StzTableQ([ 3, 3 ]).Filled(:With = "A") )
#--> [
#	[ "COL1", [ "A", "A", "A" ] ],
#	[ "COL2", [ "A", "A", "A" ] ],
#	[ "COL3", [ "A", "A", "A" ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.20
# Executed in 0.09 second(s) in Ring 1.17
