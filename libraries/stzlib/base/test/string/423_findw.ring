load "../../stzBase.ring"
load "../_narrated.ring"

# FindW locates the star markers; SplitAtPositions then MUTATES the list
# into its parts, dropping the markers. Archive block #423.

Scenario("Find the stars, split the list at them")
	Given('[ 4, 8, 10, "*", 14, 16, "*", 18 ]')
	o1 = new stzList([ 4, 8, 10, "*", 14, 16, "*", 18 ])
	Then("the stars sit at 4 and 7",
		ListEq( o1.FindW('This[@i] = "*"'), [ 4, 7 ] ), TRUE)
	o1.SplitAtPositions([ 4, 7])
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
