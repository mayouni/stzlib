load "../../stzBase.ring"
load "../_narrated.ring"

# A fluent dedup pipeline: chars -> remove duplicates -> concatenate.
# Archive block #456.

Scenario("Dedup through a fluent chain")
	Then("Riiiiinngg concatenates back to Ring",
		Q("Riiiiinngg").
			CharsQ().
			RemoveDuplicatesQ().
			ToStzListOfStrings().
			Concatenated(), "Ring")
EndScenario()

Summary()
