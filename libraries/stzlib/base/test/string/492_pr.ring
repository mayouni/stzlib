# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #492.

load "../../stzBase.ring"


? @@NL( Combinations([ "A", "B", "C" ], 2) )
#--> [
#	[ "A", "B" ],
#	[ "A", "C" ],
#	[ "B", "C" ]
# ]

? NL@@NL( CombinationsXT([ "A", "B", "C" ], 2) )
#--> [
#	[ "A", "A" ],
#	[ "A", "B" ],
#	[ "A", "C" ],

#	[ "B", "A" ],
#	[ "B", "B" ],
#	[ "B", "C" ],

#	[ "C", "A" ],
#	[ "C", "B" ],
#	[ "C", "C" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
