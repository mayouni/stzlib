load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatedNTimes on strings gives a STRING; on lists a list of copies.
# The named repeaters Five()/Three() are @N forms and return a LIST per
# the settled @N contract (the archive showed their output flattened to
# a string; the string spelling is Q(x).RepeatedNTimes(n)).
# Archive block #434.

Scenario("Repeating hearts and stars")
	Then("a heart", Heart(), "♥")
	Then("three hearts as a string", Q(Heart()).RepeatedNTimes(3), "♥♥♥")
	Then("GoGoGo", Q("Go").RepeatedNTimes(3), "GoGoGo")
	Then("a repeated list",
		ListEq( Q([ "A", "B" ]).RepeatedNTimes(3),
			[ [ "A", "B" ], [ "A", "B" ], [ "A", "B" ] ] ), TRUE)
	Then("Five(Star()) is a list of five stars",
		ListEq( Five(Star()), [ "★", "★", "★", "★", "★" ] ), TRUE)
	Then("Three(Heart()) is a list of three hearts",
		ListEq( Three(Heart()), [ "♥", "♥", "♥" ] ), TRUE)
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
