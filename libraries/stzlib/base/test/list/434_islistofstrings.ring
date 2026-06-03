# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #434.

load "../../stzBase.ring"

pr()

? IsListOfStrings([ "baba", "ommi", "jeddy" ])
#--> TRUE

? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()
#--> TRUE

pf()
# Executed in almost 0 second(s).
