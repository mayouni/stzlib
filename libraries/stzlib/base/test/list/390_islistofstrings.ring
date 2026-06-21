# Narrative
# --------
# Edge case: how IsListOfStrings() and IsListOfNumbers() answer for an empty list.
#
# Softanza does NOT use vacuous truth here: an empty list is not considered a
# "list of strings" nor a "list of numbers", because there is no element that
# establishes the type. So both predicates return FALSE for [] (the monolith
# contract -- empty short-circuits to 0 before the per-item scan). Callers that
# want "all items are strings OR the list is empty" must OR-in an emptiness
# check themselves.
#
# Extracted from stzlisttest.ring, block #390.

load "../../stzBase.ring"

pr()

? IsListOfStrings([])
#--> FALSE

? IsListOfNumbers([])
#--> FALSE

pf()
