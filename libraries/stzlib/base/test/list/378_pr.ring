# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #378.

load "../../stzBase.ring"


? StzListQ( 4:8 ).ToListInString()
#--> "[ 4, 5, 6, 7, 8 ]"

? StzListQ( 4:8 ).ToListInStringInShortForm()
#--> "4:8"

pf()
# Executed in 0.06 second(s).
