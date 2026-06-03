# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #917.
#ERR Error (R3) : Calling Function without definition: @@sp

load "../../stzBase.ring"

pr()

? @@SP( Q([ "[...]", "[...]", "[~~~]", "[~~~]" ]).SectionsOfSameItems() )
#--> [
#	[ "[...]", "[...]" ],
#	[ "[~~~]", "[~~~]" ]
# ]

pf()
# Executed in almost 0 second(s).
