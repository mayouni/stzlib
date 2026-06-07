# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #917.
#ERR Error (R14) : Calling Method without definition: sectionsofsameitems

load "../../stzBase.ring"

pr()

? @@SP( Q([ "[...]", "[...]", "[~~~]", "[~~~]" ]).SectionsOfSameItems() )
#--> [
#	[ "[...]", "[...]" ],
#	[ "[~~~]", "[~~~]" ]
# ]

pf()
# Executed in almost 0 second(s).
