# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #88.
#ERR Error (R14) : Calling Method without definition: allitemsareemptylists

load "../../stzBase.ring"

pr()

? Q([ [], [] ]).AllItemsAreEmptyLists()
#--> TRUE

? @@( Association([ [], [] ]) )
#--> Error: Can't associate empty lists!

pf()
