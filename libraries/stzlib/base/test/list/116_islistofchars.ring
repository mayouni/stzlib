# Narrative
# --------
# IsListOfChars() reports whether a list holds only single-character items.
#
# A list of single-letter strings ["a","b","c"] is a list of chars, so the
# predicate is TRUE. The second case shows that Softanza treats single-digit
# numbers [1,2,3] as chars too: each is a one-character value, so the answer
# is also TRUE. The check is about character-width, not about the string-vs-
# number type, which is why a numeric list still qualifies here.
#
# Extracted from stzlisttest.ring, block #116.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("IsListOfChars() reports whether a list holds only single-character items.")

	Then("islistofchars example 1", @@( Q([ "a", "b", "c" ]).IsListOfChars() ), @@( TRUE ))

	Then("islistofchars example 2", @@( Q([ 1, 2, 3 ]).IsListOfChars() ), @@( TRUE ))
EndScenario()

Summary()
