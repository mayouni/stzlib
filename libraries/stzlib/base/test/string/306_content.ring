load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyTheseSubStrings segments the string around ALL the given tokens at
# once: their sections are found together, occurrences strictly included in
# a previous section are dropped (the "in" inside "Ring" stays part of
# "Ring"), and ONE space goes before each kept token plus one after the
# last -- so adjacent tokens never double-space. Archive block #306.

Scenario("Spacifying the words of a concatenated sentence")
	Given('"IbelieveinRingfutureandengageforit!"')
	o1 = new stzString("IbelieveinRingfutureandengageforit!")
	o1.SpacifyTheseSubStrings([
		"believe", "in", "Ring", "future", "and", "engage", "for"
	])
	Then("the sentence reads with single spaces",
		o1.Content(), "I believe in Ring future and engage for it!")
EndScenario()

Summary()
