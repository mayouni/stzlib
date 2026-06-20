# Narrative
# --------
# ToListInString vs ToListInStringInShortForm: two textual renderings of
# a list.
#
# ToListInString returns the full Ring source form of the list, e.g.
# "[ 4, 5, 6, 7, 8 ]". ToListInStringInShortForm recognises a contiguous
# run of integers and compresses it to its range notation "4:8" --
# falling back to the full form when the items are not a clean ascending
# sequence. Handy for compact display of index/range lists.
#
# Extracted from stzlisttest.ring, block #378.

load "../../stzBase.ring"

pr()

? StzListQ( 4:8 ).ToListInString()
#--> "[ 4, 5, 6, 7, 8 ]"

? StzListQ( 4:8 ).ToListInStringInShortForm()
#--> "4:8"

pf()
# Executed in 0.06 second(s)
