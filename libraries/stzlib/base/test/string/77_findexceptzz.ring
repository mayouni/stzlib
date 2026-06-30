load "../../stzBase.ring"
load "../_narrated.ring"

# FindExceptZZ gives the [from,to] spans of the runs that are NOT one of the given
# separators; Except returns those runs as substrings. Archive block #77.

Scenario("Finding the runs between separators")
	Given('"--ring--&__softanza__"')
	o1 = new stzString("--ring--&__softanza__")
	Then("FindExceptZZ gives the non-separator spans",
		ListEq( o1.FindExceptZZ([ "--", "__" ]), [ [3,6], [9,9], [12,19] ] ), TRUE)
	Then("Except returns those runs as substrings",
		ListEq( o1.Except([ "--", "__" ]), [ "ring", "&", "softanza" ] ), TRUE)
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
