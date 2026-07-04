load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsLetters / ContainsLetter / IsALetterOf -- all case-blind,
# because a LETTER is an abstraction over its two cases.
# Archive block #714.

Scenario("Letters in a decorated string")
	Then("contains letters", Q("--A--B--").ContainsLetters(), TRUE)
	Then("contains the letter A", Q("--A--B--").ContainsLetter("A"), TRUE)
	Then("... asked in lowercase too", Q("--A--B--").ContainsLetter("a"), TRUE)
	Then("but no M", Q("--A--B--").ContainsLetter("M"), FALSE)
	Then("H is a letter of HUSSEIN", Q("H").IsALetterOf("HUSSEIN"), TRUE)
	Then("... and so is h", Q("h").IsALetterOf("HUSSEIN"), TRUE)
EndScenario()

Summary()
