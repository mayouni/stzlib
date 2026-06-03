# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #639.
#ERR Error (R14) : Calling Method without definition: issortedinascending

load "../../stzBase.ring"

pr()

? Q("01233445679").IsSortedInAscending()
#--> TRUE

? Q("01233445679").IsSortedInDescending()
#--> FALSE

pf()
# Executed in 0.08 second(s)
