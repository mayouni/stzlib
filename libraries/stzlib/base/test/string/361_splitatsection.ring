load "../../stzBase.ring"
load "../_narrated.ring"

# stzSplitter.SplitAtSection(n1, n2): the complement spans around one
# section; the IB form keeps the boundary positions inside the pieces.
# Edge sections drop the vanishing side. Archive block #361.

Scenario("Splitting a 1..10 range at one section")
	Given('a stzSplitter(10)')
	o1 = new stzSplitter(10)
	Then("interior section",
		ListEq( o1.SplitAtSection(3, 5), [ [1, 2], [6, 10] ] ), TRUE)
	Then("... IB keeps the boundary positions",
		ListEq( o1.SplitAtSectionIB(3, 5), [ [1, 3], [5, 10] ] ), TRUE)
	Then("section starting at 1",
		ListEq( o1.SplitAtSection(1, 5), [ [6, 10] ] ), TRUE)
	Then("... IB", ListEq( o1.SplitAtSectionIB(1, 5), [ [5, 10] ] ), TRUE)
	Then("section ending at 10",
		ListEq( o1.SplitAtSection(5, 10), [ [1, 4] ] ), TRUE)
	Then("... IB", ListEq( o1.SplitAtSectionIB(5, 10), [ [1, 5] ] ), TRUE)
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
