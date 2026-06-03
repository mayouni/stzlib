# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #88.

load "../../stzBase.ring"


? Q([ [], [] ]).AllItemsAreEmptyLists()
#--> TRUE

? @@( Association([ [], [] ]) )
#--> Error: Can't associate empty lists!

pf()
