# Narrative
# --------
# Rendering a list as a string -- full form and short (range) form.
# ToListInAString() gives the literal "[ 4, 5, 6, 7, 8 ]"; the short form
# detects the contiguous integer run and collapses it to the range "4:8".
#
# Extracted from stzlistofliststest.ring, block #63.

load "../../stzBase.ring"

pr()

? @@( StzListQ( 4:8 ).ToListInAString() )
#--> "[ 4, 5, 6, 7, 8 ]"

? @@( StzListQ( 4:8 ).ToListInAStringInShortForm() )
#--> "4:8"

pf()
# Executed in 0.50 second(s)
