# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #455.

load "../../stzBase.ring"

pr()

? StzListQ([ "A", "A", "A", "B", "B", "C" ]).DuplicatesRemoved()
#--> [ "A", "B", "C" ]

pf()
# Executed in almost 0 second(s).
