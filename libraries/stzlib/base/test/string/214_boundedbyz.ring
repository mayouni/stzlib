load "../../stzBase.ring"
load "../_narrated.ring"

# BoundedByZ / BoundedByZZ widen the single "&" bound and group each bounded
# substring with its start position / [from,to] span. Archive block #214.

Scenario("Bounded substrings grouped with positions, single & bound")
	Given('"..&^^^&..&^^^&..&---&..&---&.."')
	o1 = new stzString("..&^^^&..&^^^&..&---&..&---&..")
	Then("BoundedByZ pairs each substring with its start",
		ListEq( o1.BoundedByZ("&"),
			[ [ "^^^", 4 ], [ "..", 8 ], [ "^^^", 11 ], [ "..", 15 ], [ "---", 18 ], [ "..", 22 ], [ "---", 25 ] ] ), TRUE)
	Then("BoundedByZZ pairs each substring with its span",
		ListEq( o1.BoundedByZZ("&"),
			[ [ "^^^", [4,6] ], [ "..", [8,9] ], [ "^^^", [11,13] ], [ "..", [15,16] ], [ "---", [18,20] ], [ "..", [22,23] ], [ "---", [25,27] ] ] ), TRUE)
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
