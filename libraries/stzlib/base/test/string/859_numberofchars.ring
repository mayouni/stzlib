load "../../stzBase.ring"
load "../_narrated.ring"

# Chars vs bytes: the koala is ONE char and four bytes.
# Archive block #859.

Scenario("Counting a koala")
	Then("M is one char", Q("M").NumberOfChars(), 1)
	Then("the koala too", Q("🐨").NumberOfChars(), 1)
	Then("but four bytes", len("🐨"), 4)
EndScenario()

Summary()
