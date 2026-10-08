load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzListOfPairs defects fixed on fix/gscl (DEFECTS.md, stzListOfPairs):
# the SortBy family never sorted (stzList.SortBy does not evaluate an expression on a
# list item); the descending forms swapped the items INSIDE each pair (Reverse is
# SwapItems in this class); SortedInDescending answered ascending; ReplacePair raised
# R20 (IsPair reached the inherited method); UpdatePairWith refused n above 2.

aPairs = [ [ "b", 3 ], [ "aaa", 1 ], [ "cc", 2 ] ]

Scenario("SortBy orders the pairs by an evaluated key")
	o = new stzListOfPairs(aPairs)
	o.SortBy('@pair[2]')
	Then("by the second item, ascending", @@(o.Content()), '[ [ "aaa", 1 ], [ "cc", 2 ], [ "b", 3 ] ]')
	o = new stzListOfPairs(aPairs)
	o.SortByInAscending('len(@pair[1])')
	Then("by the length of the first item", @@(o.Content()), '[ [ "b", 3 ], [ "cc", 2 ], [ "aaa", 1 ] ]')
	o = new stzListOfPairs(aPairs)
	o.SortByUp('-@pair[2]')
	Then("a negated key gives the reverse order", @@(o.Content()), '[ [ "b", 3 ], [ "cc", 2 ], [ "aaa", 1 ] ]')
	o = new stzListOfPairs(aPairs)
	Then("SortedBy answers a sorted copy", @@(o.SortedBy('@pair[1]')), '[ [ "aaa", 1 ], [ "b", 3 ], [ "cc", 2 ] ]')
	Then("and leaves the list as it was", @@(o.Content()), @@(aPairs))
EndScenario()

Scenario("Equal keys keep their order")
	o = new stzListOfPairs([ [ "x", 2 ], [ "y", 1 ], [ "z", 2 ], [ "w", 1 ] ])
	Then("ascending: y w before x z, each in input order",
		@@(o.SortedBy('@pair[2]')), '[ [ "y", 1 ], [ "w", 1 ], [ "x", 2 ], [ "z", 2 ] ]')
	Then("descending: x z before y w, each in input order",
		@@(o.SortedByInDescending('@pair[2]')), '[ [ "x", 2 ], [ "z", 2 ], [ "y", 1 ], [ "w", 1 ] ]')
EndScenario()

Scenario("The descending forms order the pairs and keep each pair as it is")
	o = new stzListOfPairs(aPairs)
	o.SortByInDescending('@pair[2]')
	Then("SortByInDescending, by the second item", @@(o.Content()), '[ [ "b", 3 ], [ "cc", 2 ], [ "aaa", 1 ] ]')
	o = new stzListOfPairs(aPairs)
	o.SortByDown('len(@pair[1])')
	Then("SortByDown, by length", @@(o.Content()), '[ [ "aaa", 1 ], [ "cc", 2 ], [ "b", 3 ] ]')
	o = new stzListOfPairs(aPairs)
	Then("SortedByDown answers a copy", @@(o.SortedByDown('@pair[1]')), '[ [ "cc", 2 ], [ "b", 3 ], [ "aaa", 1 ] ]')
	Then("no pair is turned round", o.Content()[1][1], "b")
	Then("SortedInDescending is descending", @@(o.SortedInDescending()), '[ [ "cc", 2 ], [ "b", 3 ], [ "aaa", 1 ] ]')
EndScenario()

Scenario("A bad key expression is refused")
	o = new stzListOfPairs(aPairs)
	Then("an expression without @pair raises", Raises(o, "o.SortBy('len(x)')") != "", 1)
	o = new stzListOfPairs([ [ "a", 1 ], [ "b", "z" ] ])
	Then("keys mixing numbers and texts raise", Raises(o, "o.SortBy('@pair[2]')") != "", 1)
EndScenario()

Scenario("ReplacePair and UpdatePairWith reach every position")
	o = new stzListOfPairs(aPairs)
	o.ReplacePair(2, [ "x", 9 ])
	Then("ReplacePair(2) replaces the second pair", @@(o.Content()), '[ [ "b", 3 ], [ "x", 9 ], [ "cc", 2 ] ]')
	o.UpdatePairWith(3, [ "y", 8 ])
	Then("UpdatePairWith(3) replaces the third pair", @@(o.Content()), '[ [ "b", 3 ], [ "x", 9 ], [ "y", 8 ] ]')
	o = new stzListOfPairs(aPairs)
	Then("PairReplaced answers a copy", @@(o.PairReplaced(3, [ "q", 0 ])), '[ [ "b", 3 ], [ "aaa", 1 ], [ "q", 0 ] ]')
	Then("and leaves the list as it was", @@(o.Content()), @@(aPairs))
	Then("a position past the end raises", Raises(o, "o.ReplacePair(4, [ 1, 2 ])") != "", 1)
	Then("a new pair of three items raises", Raises(o, "o.ReplacePair(1, [ 1, 2, 3 ])") != "", 1)
EndScenario()

Summary()

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
