load "../../stzBase.ring"
load "../_narrated.ring"

# The global equality helpers. Archive block #712.

Scenario("Equal strings, four spellings of the check")
	Then("StringsAreEqualCS",
		StringsAreEqualCS([ "abc", "abc" ], TRUE), TRUE)
	Then("StringsAreEqual on three",
		StringsAreEqual([ "cbad", "cbad", "cbad" ]), TRUE)
	Then("BothStringsAreEqualCS",
		BothStringsAreEqualCS("abc", "abc", TRUE), TRUE)
	Then("BothStringsAreEqual",
		BothStringsAreEqual("abc", "abc"), TRUE)
EndScenario()

Summary()
