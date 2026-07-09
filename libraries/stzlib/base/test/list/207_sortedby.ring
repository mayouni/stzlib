# Narrative
# --------
# SortedBy() orders a list using a computed key rather than the raw items.
#
# The sort criterion is passed as a Softanza expression string in which
# @item stands for the current element. Here 'len(@item)' sorts the two
# strings by their character length, so the shorter "is" comes before the
# longer "programming". This lets you sort by any derived value -- length,
# a field, a transformation -- without writing a comparator function.
#
# Extracted from stzlisttest.ring, block #207.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("SortedBy() orders a list using a computed key rather than the raw items.")

	o1 = new stzList([ "programming", "is" ])
	Then("sortedby example 1", @@( o1.SortedBy('len(@item)') ), @@( [ "is", "programming" ] ))
EndScenario()

Summary()
