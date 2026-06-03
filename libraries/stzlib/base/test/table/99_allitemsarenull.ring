# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #99.
#ERR Error (R14) : Calling Method without definition: allitemsarenull

load "../../stzBase.ring"

pr()

? Q(["", "", ""]).AllItemsAreNull()
#--> TRUE

pf()
# Executed in 0.02 second(s)
