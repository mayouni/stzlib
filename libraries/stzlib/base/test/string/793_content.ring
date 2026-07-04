load "../../stzBase.ring"
load "../_narrated.ring"

# A Section tour: numeric bounds (normalized when inverted), and the
# :EndOfWord / :EndOfSentence / :EndOfString anchors -- a word runs to
# the next space (punctuation included), a sentence to the next full
# stop. Archive block #793.

Scenario("Sections of a comeback")
	o1 = new stzString("Tunisia is back! People united.")
	o1.ReplaceAll("People", "Tunisians")
	Then("crowd renamed", o1.Content(),
		"Tunisia is back! Tunisians united.")
	Then("3 to 7", o1.Section(3, 7), "nisia")
	Then("7 to 3, normalized", o1.Section(7, 3), "nisia")
	Then("3 to the end of its word",
		o1.Section(:From = 3, :To = :EndOfWord), "nisia")
	Then("12 to the end of its word (bang included)",
		o1.Section(:From = 12, :To = :EndOfWord), "back!")
	Then("9 to the end of the sentence",
		o1.Section(:From = 9, :To = :EndOfSentence),
		"is back! Tunisians united.")
	Then("first char to end of string",
		o1.Section(:From = :FirstChar, :To = :EndOfString),
		"Tunisia is back! Tunisians united.")
	o1.ReplaceFirst("Tunisia", :With = "Egypt")
	o1.Replace("Tunisians", :With = "Egyptians")
	Then("and a whole new country", o1.Content(),
		"Egypt is back! Egyptians united.")
EndScenario()

Summary()
