load "../../stzBase.ring"
load "../_narrated.ring"

# Splits() gives the parts; SplitsZ() zips each part with its start
# position; SplitsZZ() zips it with its whole section. Archive block #662.

Scenario("Splitting on semicolons, three depths")
	o1 = new stzString("one;two;three;four;five")
	Then("the parts",
		ListEq( o1.Splits(";"),
			[ "one", "two", "three", "four", "five" ] ), TRUE)
	Then("parts zipped with positions",
		ListEq( o1.SplitsZ(";"),
			[ [ "one", 1 ], [ "two", 5 ], [ "three", 9 ],
			  [ "four", 15 ], [ "five", 20 ] ] ), TRUE)
	Then("parts zipped with sections",
		ListEq( o1.SplitsZZ(";"),
			[ [ "one", [ 1, 3 ] ], [ "two", [ 5, 7 ] ], [ "three", [ 9, 13 ] ],
			  [ "four", [ 15, 18 ] ], [ "five", [ 20, 23 ] ] ] ), TRUE)
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
