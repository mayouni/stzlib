# Narrative
# --------
# Shows that Softanza distinguishes set-equality from strict equality on lists.
#
# IsEqualTo([ "c","b","a" ]) is TRUE: the two lists hold the same items,
# regardless of order. IsStrictlyEqualTo is FALSE because strict equality
# additionally requires identical sorting order. The why is spelled out by
# the three component predicates: HasSameTypeAs (TRUE, both are lists),
# HasSameContentAs (TRUE, same items) and HasSameSortingOrderAs (FALSE, the
# order differs). Strict equality is the conjunction of all three, so the
# differing order alone flips it to FALSE.
#
# Extracted from stzlisttest.ring, block #462.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])

? o1.IsEqualTo([ "c", "b", "a" ])		#--> TRUE

? o1.IsStrictlyEqualTo([ "c", "b", "a" ])	#--> FALSE
# Because
? o1.HasSameTypeAs([ "c", "b", "a" ])		#--> TRUE
? o1.HasSameContentAs([ "c", "b", "a" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "c", "b", "a" ])	#--> FALSE

pf()
# Executed in 0.05 second(s).
