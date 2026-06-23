# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #63.
#ERR Error (R14) : Calling Method without definition: tolistinastring

load "../../stzBase.ring"

pr()

? @@( StzListQ( 4:8 ).ToListInAString() )
#--> "[ 4, 5, 6, 7, 8 ]"

? @@( StzListQ( 4:8 ).ToListInAStringInShortForm() )
#--> "4:8"

pf()
# Executed in 0.50 second(s)
