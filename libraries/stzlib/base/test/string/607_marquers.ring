load "../../stzBase.ring"
load "../_narrated.ring"

# Marquers come back in TEXT order, whatever their numbers.
# Archive block #607.

Scenario("Ordered and shuffled marquers")
	Then("1-2-3 in order",
		ListEq( Q("My name is #1, my age is #2, and my job is #3.").Marquers(),
			[ "#1", "#2", "#3" ] ), TRUE)
	Then("2-3-1 as written",
		ListEq( Q("My name is #2, my age is #3, and my job is #1.").Marquers(),
			[ "#2", "#3", "#1" ] ), TRUE)
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
