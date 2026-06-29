load "../../stzBase.ring"
load "../_narrated.ring"

# FindAnyBoundedBy / ...AsSections with a SINGLE repeated bound ("aa") -- the
# bounds pair OVERLAPPINGLY so all three regions are kept. Archive block #124.

Scenario("Finding regions bounded by a repeated marker")
	Given('"aa***aa**aa***aa"')
	o1 = new stzString("aa***aa**aa***aa")
	Then("FindAnyBoundedByAsSections('aa') finds all three spans",
		ListEq( o1.FindAnyBoundedByAsSections("aa"), [ [ 3, 5 ], [ 8, 9 ], [ 12, 14 ] ] ), TRUE)
	Then("FindAnyBoundedBy('aa') gives the three start positions",
		ListEq( o1.FindAnyBoundedBy("aa"), [ 3, 8, 12 ] ), TRUE)
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
