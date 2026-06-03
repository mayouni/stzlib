# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #2.
#ERR Error (R14) : Calling Method without definition: sortby

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "a", "abcde", "abc", "ab", "abcd" ])
o1.SortBy('len(@string)')

? o1.Content()
#--> [ "a", "ab", "abc", "abcd", "abcde" ]

pf()
#--> Executed in 0.28 second(s)
