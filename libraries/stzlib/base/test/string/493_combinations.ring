# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #493.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "V", "T", "M", "S" ])
? @@NL( o1.Combinations() )
#--> [
#	[ "V", "T" ],
#	[ "V", "M" ],
#	[ "V", "S" ],
#	[ "T", "M" ],
#	[ "T", "S" ],
#	[ "M", "S" ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
