load "../../stzBase.ring"
load "../_narrated.ring"

# SplitToPartsOfSizes([...]) splits the string into consecutive parts of the given
# sizes; the (/) operator with a list of sizes is the same. Archive block #274.

Scenario("Splitting into parts of given sizes")
	Given('"123456789"')
	o1 = new stzString("123456789")
	Then("SplitToPartsOfSizes([3,4,2]) gives the three parts",
		ListEq( o1.SplitToPartsOfSizes([ 3, 4, 2 ]), [ "123", "4567", "89" ] ), TRUE)
	Then("the (/) operator with sizes agrees",
		ListEq( o1 / [ 3, 4, 2 ], [ "123", "4567", "89" ] ), TRUE)
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
