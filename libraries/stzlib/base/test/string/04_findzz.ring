load "../../stzBase.ring"
load "../_narrated.ring"

# FindZZ gives the [from,to] span of each substring; ReplaceInSections replaces
# a substring ONLY within the given position sections. Archive block #4.

Scenario("Finding spans and replacing within them")
	Given('"Programming for programmers"')
	o1 = new stzString("Programming for programmers")
	Then("FindZZ gives both spans",
		ListEq( o1.FindZZ([ "Programming", "programmers" ]), [ [ 1, 11 ], [ 17, 27 ] ] ), TRUE)
	o1.ReplaceInSections("m", "M", [ [ 1, 11 ], [ 17, 27 ] ])
	Then("ReplaceInSections capitalises 'm' only inside the spans",
		o1.Content(), "PrograMMing for prograMMers")
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
