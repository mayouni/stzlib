load "../../stzBase.ring"
load "../_narrated.ring"

# With a single "&" bound, FindAnyBoundedBy gives content START positions,
# ...IB the bound-inclusive starts, ...ZZ the content spans -- all overlapping.
# Archive block #215.

Scenario("Finding all regions bounded by a single & marker")
	Given('"...&^^^&...&vvv&...&..."')
	o1 = new stzString("...&^^^&...&vvv&...&...")
	Then("FindAnyBoundedBy gives the content starts",
		ListEq( o1.FindAnyBoundedBy("&"), [ 5, 9, 13, 17 ] ), TRUE)
	Then("FindAnyBoundedByIB gives the bound-inclusive starts",
		ListEq( o1.FindAnyBoundedByIB("&"), [ 4, 8, 12, 16 ] ), TRUE)
	Then("FindAnyBoundedByZZ gives the content spans",
		ListEq( o1.FindAnyBoundedByZZ("&"), [ [5,7], [9,11], [13,15], [17,19] ] ), TRUE)
	Then("BoundedBy gives the substrings, gaps kept",
		ListEq( o1.BoundedBy("&"), [ "^^^", "...", "vvv", "..." ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
