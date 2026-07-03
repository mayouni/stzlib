load "../../stzBase.ring"
load "../_narrated.ring"

# BoundsXT(:Of = sub, :UpToNChars = caps): per-occurrence bounds, each
# side capped by the matching caps entry (number = both sides, [l, r]
# pair = per side, 0 = NULL side). Archive block #515.

Scenario("Capped bounds per occurrence")
	o1 = new stzString("How many <<many>> are there in (many <<<many>>>): so <many>>!")
	Then("numeric caps",
		ListEq( o1.BoundsXT(:Of = "many", :UpToNChars = [ 0, 2, 0, 3, [1,2] ]),
			[ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ],
			  [ "<<<", ">>>" ], [ "<", ">>" ] ] ), TRUE)
	Then("the pair spelling is equivalent",
		ListEq( o1.BoundsXT(:Of = "many", :UpToNChars = [ [0,0], [2, 2], [0,0], [3,3], [1,2] ]),
			[ [ NULL, NULL ], [ "<<", ">>" ], [ NULL, NULL ],
			  [ "<<<", ">>>" ], [ "<", ">>" ] ] ), TRUE)
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
