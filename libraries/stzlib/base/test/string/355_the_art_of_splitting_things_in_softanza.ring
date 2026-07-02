load "../../stzBase.ring"
load "../_narrated.ring"

# THE ART OF SPLITTING THINGS IN SOFTANZA -- the archive block was a
# narrative summary table of the split families (at / before / after,
# by substring / position / section / condition), whose Unicode check
# marks Ring's lexer rejects. Blocks #356, #358 and #359 exercise the
# families in detail; here three representative one-liners stand in for
# the table. Archive block #355.

Scenario("The three split flavors at a glance")
	Given('"__a__A__"')
	Then("splitting AT drops the separator",
		ListEq( Q("__a__A__").Split("a"), [ "__", "__A__" ] ), TRUE)
	Then("splitting BEFORE keeps it ahead",
		ListEq( Q("__a__A__").SplitBefore("a"), [ "__", "a__A__" ] ), TRUE)
	Then("splitting AFTER keeps it behind",
		ListEq( Q("__a__A__").SplitAfter("a"), [ "__a", "__A__" ] ), TRUE)
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
