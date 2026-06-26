load "../../stzBase.ring"
load "../_narrated.ring"

# AntiFind(item) -- the positions of everything OTHER than `item`; AntiFindZZ
# groups them into [from,to] runs. Archive block #202.

Scenario("Finding the positions NOT matching an item")
	Given('[ 1, 2, 3, "ring", 5, 6, 7 ]')
	o1 = new stzList([ 1, 2, 3, "ring", 5, 6, 7 ])
	Then("AntiFind('ring') is everything but position 4",
		ListEq( o1.AntiFind("ring"), [ 1, 2, 3, 5, 6, 7 ] ), TRUE)
	Then("AntiFindZZ groups them into runs",
		ListEq( o1.AntiFindZZ("ring"), [ [ 1, 3 ], [ 5, 7 ] ] ), TRUE)
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
