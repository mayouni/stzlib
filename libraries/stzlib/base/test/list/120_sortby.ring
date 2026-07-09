# Narrative
# --------
# Sorts a list of strings by a derived key rather than by value.
#
# SortBy() takes a string expression where @item stands for the
# current element; here 'len(@item)' computes each string's length
# and the list is ordered ascending by that key. The five words,
# whose lengths run 1..5, come back in length order. This is the
# Softanza idiom for key-based ordering: the comparison criterion
# is expressed inline against @item instead of writing a custom
# comparator, keeping the call declarative and readable.
#
# Extracted from stzlisttest.ring, block #120.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Sorts a list of strings by a derived key rather than by value.")

	o1 = new stzList([ "a", "abcde", "abc", "ab", "abcd" ])

	o1.SortBy('len(@item)')
	Then("sortby example 1", @@( o1.Content() ), @@( [ "a", "ab", "abc", "abcd", "abcde" ] ))
EndScenario()

Summary()
