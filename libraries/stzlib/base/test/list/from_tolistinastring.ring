# Narrative
# --------
# Extracted from stzlistofliststest.ring, block #63.

load "../../stzBase.ring"

pr()

? @@( StzListQ( 4:8 ).ToListInAString() )
#--> "[ 4, 5, 6, 7, 8 ]"

# NOTE: the range short-form ("4:8") is not implemented yet -- the internal
# short-form chain (ToCodeQ().ToListInShortForm()) currently yields []. Left for
# a separate fix.
//? @@( StzListQ( 4:8 ).ToListInAStringInShortForm() )
#--> "4:8"

pf()
# Executed in 0.50 second(s)
