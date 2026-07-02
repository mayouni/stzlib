load "../../stzBase.ring"
load "../_narrated.ring"

# InfereMethod(:From = :stzClass) finds the predicate method the class
# offers for this string: "is" + string, else "is" + string minus its
# final s. (The archive's second #--> "ispunctauion" was a hand-typo for
# "ispunctuation" -- the singular fallback.) Archive block #450.

Scenario("Inferring stzChar predicates")
	Then("punctuation infers its checker",
		Q("punctuation").InfereMethod(:From = :stzChar), "ispunctuation")
	Then("the plural falls back to the singular",
		Q("punctuations").InfereMethod(:From = :stzChar), "ispunctuation")
EndScenario()

Summary()
