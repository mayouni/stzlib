load "../../stzBase.ring"
load "../_narrated.ring"

# FindAll gives every underscore position; the made-of forms group them
# into maximal runs. Archive block #427.

Scenario("Underscore runs")
	Given('"..._...__...___..."')
	o1 = new stzString("..._...__...___...")
	Then("every underscore position",
		ListEq( o1.FindALL("_"), [ 4, 8, 9, 13, 14, 15 ] ), TRUE)
	Then("the run spans",
		ListEq( o1.FindSubstringsMadeOfZZ("_"), [ [4, 4], [8, 9], [13, 15] ] ), TRUE)
	Then("the run substrings",
		ListEq( o1.SubStringsMadeOf("_"), [ "_", "__", "___" ] ), TRUE)
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
