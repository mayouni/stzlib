load "../../stzBase.ring"
load "../_narrated.ring"

# AllCharsAre(:CircledNumbers) over ①②③ (the archive source had the
# first char double-encoded; rebuilt with the real glyphs).
# Archive block #480.

Scenario("All chars are circled numbers")
	Then("the plural kind", Q("①②③").AllCharsAre(:CircledNumbers), TRUE)
	Then("the XT list of kinds",
		Q("①②③").AllCharsAreXT([:CircledNumber, :Chars], []), TRUE)
EndScenario()

Summary()
