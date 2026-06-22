# Narrative
# --------
# Strict list equality with IsStrictlyEqualTo().
#
# Softanza distinguishes "equal" from "strictly equal". Strict equality
# is the conjunction of three independent checks, all of which must hold:
# HasSameTypeAs (the elements share the same Ring type signature),
# HasSameContentAs (the same values are present), and
# HasSameSortingOrderAs (those values appear in the same order).
# Here [ "a", "b", "c" ] matches the host on all three counts, so the
# strict check returns TRUE, and each of the three component predicates
# is shown returning TRUE in turn to explain why.
#
# Extracted from stzlisttest.ring, block #457.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])

? o1.IsStrictlyEqualTo([ "a", "b", "c" ])	#--> TRUE

# Because
? o1.HasSameTypeAs([ "a", "b", "c" ])		#--> TRUE
? o1.HasSameContentAs([ "a", "b", "c" ])	#--> TRUE
? o1.HasSameSortingOrderAs([ "a", "b", "c" ])	#--> TRUE

pf()
# Executed in 0.04 second(s).
