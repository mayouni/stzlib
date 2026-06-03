# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #404.
#ERR Error (R3) : Calling Function without definition: @@sp

load "../../stzBase.ring"

pr()

? @@SP( Q([ "VALUE1", "VALUE2", "VALUE3" ]) * [ 1001, 1002, 1003 ] )
#--> [
#	[  "VALUE1", [ 1001, 1002, 1003 ] ],
#	[  "VALUE2", [ 1001, 1002, 1003 ] ],
#	[  "VALUE3", [ 1001, 1002, 1003 ] ]
# ]

? @@NL( Q([ 15, 25, 70]) * [ 2, 4, 6 ] )
#--> [
#	[ 15, [ 2, 4, 6 ] ],
#	[ 25, [ 2, 4, 6 ] ],
#	[ 70, [ 2, 4, 6 ] ]
# ]

pf()
# Executed in almost 0 second(s).
