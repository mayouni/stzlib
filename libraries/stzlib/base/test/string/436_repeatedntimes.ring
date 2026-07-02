load "../../stzBase.ring"
load "../_narrated.ring"

# RepeatedNTimes' dual behavior: a STRING duplicates into a string; every
# other type repeats inside a LIST. RepeatedNTimesXT names the output
# format explicitly. (The archive's XT(0, :InAList) line was a typo for
# n = 3 -- with n = 0 the list is empty.) Archive block #436.

Scenario("Repeating by type")
	Then("a string repeats into a string",
		Q("Hi!").RepeatedNTimes(3), "Hi!Hi!Hi!")
	Then("a number repeats into a list",
		ListEq( Q(5).RepeatedNTimes(3), [ 5, 5, 5 ] ), TRUE)
	Then("a list repeats into a list of lists",
		ListEq( Q(1:3).RepeatedNTimes(3), [ 1:3, 1:3, 1:3 ] ), TRUE)
EndScenario()

Scenario("Naming the output format with XT")
	Then("explicitly in a string",
		Q("Hi!").RepeatedNTimesXT(3, :InAString), "Hi!Hi!Hi!")
	Then("explicitly in a list",
		ListEq( Q("Hi!").RepeatedNTimesXT(3, :InAList), [ "Hi!", "Hi!", "Hi!" ] ), TRUE)
	Then("zero repetitions give an empty list",
		ListEq( Q("Hi!").RepeatedNTimesXT(0, :InAList), [ ] ), TRUE)
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
