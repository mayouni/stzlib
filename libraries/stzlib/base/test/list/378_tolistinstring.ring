# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #378.
#ERR Error (R14) : Calling Method without definition: tolistinstring

load "../../stzBase.ring"

pr()

? StzListQ( 4:8 ).ToListInString()
#--> "[ 4, 5, 6, 7, 8 ]"

? StzListQ( 4:8 ).ToListInStringInShortForm()
#--> "4:8"

pf()
# Executed in 0.06 second(s).
