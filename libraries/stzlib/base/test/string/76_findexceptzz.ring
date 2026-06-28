load "../../stzBase.ring"
load "../_narrated.ring"

# FindExceptZZ(sep) -- the sections (as [from,to] pairs) of everything that is
# NOT the separator; Except(sep) -- the same content as SUBSTRINGS. Archive #76.

Scenario("Finding the non-separator sections")
	Given('"--ring--&--softanza--"')
	o1 = new stzString("--ring--&--softanza--")
	Then("FindExceptZZ('--') gives the spans between the dashes",
		ListEq( o1.FindExceptZZ("--"), [ [ 3, 6 ], [ 9, 9 ], [ 12, 19 ] ] ), TRUE)
	Then("Except('--') gives those substrings",
		ListEq( o1.Except("--"), [ "ring", "&", "softanza" ] ), TRUE)
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
