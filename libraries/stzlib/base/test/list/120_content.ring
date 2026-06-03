# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #120.
#ERR Error (R14) : Calling Method without definition: sortby

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])

o1.SortBy('len(@item)')
? o1.Content()
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

pf()
# Executed in 0.11 second(s)
