# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? AreEqual([1, 1, 1])
#--> TRUE

? AreEqual([1, "1", 1])
#--> FALSE

? AreEqual([ "ring", "Ring", "RING" ])
#--> FALSE

? AreEqualCS([ "ring", "Ring", "RING" ], FALSE)
#--> TRUE

pf()
