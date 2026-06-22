# Narrative
# --------
# Demonstrates stzList.IsStrictlyEqualTo() and how it decomposes into
# three weaker comparisons.
#
# Strict equality is the conjunction of three conditions: the other
# operand must have the same type (HasSameTypeAs), the same content
# (IsEqualTo), and the same sorting order (HasSameSortingOrderAs).
# Here [ "a", "b", "c" ] and [ "a", "b" ] share type and trivially the
# same ordering, but differ in content, so IsEqualTo is FALSE and the
# strict check fails. The example shows that a single failing facet --
# content equality -- is enough to make the strict result FALSE even
# when the other two facets pass.
#
# Extracted from stzlisttest.ring, block #463.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c" ])
? o1.IsStrictlyEqualTo([ "a", "b" ])	#--> FALSE

# Because
? o1.HasSameTypeAs([ "a", "b" ])		#--> TRUE
? o1.IsEqualTo([ "a", "b" ])			#--> FALSE
? o1.HasSameSortingOrderAs([ "a", "b" ])#--> TRUE

pf()
# Executed in almost 0 second(s).
