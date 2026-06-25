load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceCharsW with the isArabic char-class predicate -- replace the Arabic
# letters of a mixed string. Engine-backed (the W-DSL now has the script
# predicate isArabic/isLatin), no eval(). Migrated from the retired
# ReplaceCharsWXT (whose StzCharQ(@Char).IsArabicLetter() sugar maps to isArabic).

Scenario("ReplaceCharsW replaces the Arabic letters of a mixed string")
	Given("a sentence mixing Latin words with two Arabic letters")
	Then("replacing isArabic(@char) with a star leaves the Latin text",
		Q("Use these two letters: س and ص.").ReplaceCharsWQ(:Where = '{ isArabic(@char) }', :With = "*").Content(),
		"Use these two letters: * and *.")
EndScenario()

Summary()
