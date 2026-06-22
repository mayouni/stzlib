# Narrative
# --------
# Checks that a list is composed entirely of strings.
#
# IsListOfStrings() is a Softanza type-predicate: it returns TRUE
# only when every element of the given list is a string value.
# It is exposed two ways -- as a bare global function for quick
# inline checks, and as the .IsListOfStrings() method on the Q()
# wrapper for the fluent object style. Both forms answer the same
# question and return the same boolean, letting you pick the idiom
# that reads best in context.
#
# Extracted from stzlisttest.ring, block #434.

load "../../stzBase.ring"

pr()

? IsListOfStrings([ "baba", "ommi", "jeddy" ])
#--> TRUE

? Q([ "baba", "ommi", "jeddy" ]).IsListOfStrings()
#--> TRUE

pf()
# Executed in almost 0 second(s).
