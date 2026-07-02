load "../../stzBase.ring"
load "../_narrated.ring"

# Five use cases of the / operator on a string: split into N equal parts,
# split by a char, split at chars satisfying a W condition (the WXT()
# marker routes to SplitW -- no eval), distribute equally among named
# stakeholders, and allocate named portions of given sizes (with
# :RemainingChars for the tail). Archive block #447.

Scenario("Dividing a string five ways")
	Then("into 3 equal parts",
		ListEq( Q("RingRingRing") / 3, [ "Ring", "Ring", "Ring" ] ), TRUE)
	Then("by a separator char",
		ListEq( Q("Ring;Python;Ruby") / ";", [ "Ring", "Python", "Ruby" ] ), TRUE)
	Then("at the chars satisfying a condition",
		ListEq( Q("Ring:Python;Ruby") / WXT('Q(@Char).IsNotLetter()'),
			[ "Ring", "Python", "Ruby" ] ), TRUE)
	Then("equally among three stakeholders",
		ListEq( Q("RingRubyJava") / [ "Qute", "Nice", "Good" ],
			[ [ "Qute", "Ring" ], [ "Nice", "Ruby" ], [ "Good", "Java" ] ] ), TRUE)
	Then("in named portions of given sizes",
		ListEq( Q("IAmRingDeveloper") / [
				:Subject = 1,
				:Verb    = 2,
				:Noun1   = 4,
				:Noun2   = :RemainingChars ],
			[ [ "subject", "I" ], [ "verb", "Am" ],
			  [ "noun1", "Ring" ], [ "noun2", "Developer" ] ] ), TRUE)
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
