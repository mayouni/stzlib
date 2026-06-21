# Narrative
# --------
# ContainsOneOfThese (inclusive "any") vs ContainsOnlyOneOfThese (exclusive
# "exactly one").
#
# ContainsOneOfThese is TRUE if AT LEAST one of the given items is present.
# ContainsOnlyOneOfThese is stricter -- TRUE only when EXACTLY one is
# present. The first list holds both "me" and "you" (any: TRUE, only-one:
# FALSE); the second holds just "me" (both TRUE).
#
# Extracted from stzlisttest.ring, block #8.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "me", "you", "all", "the", "others" ])
	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> FALSE

o1 = new stzList([ "me", "and", "all", "the", "others" ])
	? o1.ContainsOnlyOneOfThese([ "me", "you" ])
	#--> TRUE

	? o1.ContainsOneOfThese([ "me", "you" ])
	#--> TRUE

pf()
# Executed in almost 0 second(s)
