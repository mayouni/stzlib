# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #917.

load "../../stzBase.ring"

pr()

? @@SP( Q([ "[...]", "[...]", "[~~~]", "[~~~]" ]).SectionsOfSameItems() )
#--> [
#	[ "[...]", "[...]" ],
#	[ "[~~~]", "[~~~]" ]
# ]

pf()
# Executed in almost 0 second(s).
