load "../../stzBase.ring"
load "../_narrated.ring"

# The "made of" family treats its argument as a POOL of chars ("12" =
# the chars 1 and 2) and finds the maximal runs made only of them:
# start positions, spans, substrings, and the [sub, span] grouping.
# Archive block #421.

Scenario("Runs made of the chars 1 and 2")
	Given('"...12..1212..121212..12."')
	o1 = new stzString("...12..1212..121212..12.")
	Then("the run starts", ListEq( o1.FindMadeOf("12"), [ 4, 8, 14, 22 ] ), TRUE)
	Then("the run spans",
		ListEq( o1.FindMadeOfZZ("12"), [ [4, 5], [8, 11], [14, 19], [22, 23] ] ), TRUE)
	Then("the run substrings",
		ListEq( o1.SubStringsMadeOf("12"), [ "12", "1212", "121212", "12" ] ), TRUE)
	Then("each run paired with its span",
		ListEq( o1.SubStringsMadeOfZZ("12"),
			[ [ "12", [4, 5] ], [ "1212", [8, 11] ],
			  [ "121212", [14, 19] ], [ "12", [22, 23] ] ] ), TRUE)
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
