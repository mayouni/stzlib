load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAfterPositions -- split the string just after each given position.
# (Replaces SplitWXT(:AfterPositions = position-predicate).)

Scenario("SplitAfterPositions splits after positions 4 and 8")
	Given('the string "---4---8---"')
	Then("the pieces end at 4 and 8", @@( Q("---4---8---").SplitAfterPositions([ 4, 8 ]) ), @@([ "---4", "---8", "---" ]))
EndScenario()

Summary()
