load "../../stzBase.ring"
load "../_narrated.ring"

# SplitW does the find-and-split of block #423 in one move: the matching
# items become break points and are dropped. Archive block #424.

Scenario("Splitting a list by condition")
	Given('[ 4, 8, 10, "*", 14, 16, "*", 18 ]')
	o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
	o1.SplitW('This[@i] = "*"')
	Then("the content becomes the parts",
		ListEq( o1.Content(), [ [ 4, 8, 10 ], [ 14, 16 ], [ 18 ] ] ), TRUE)
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
