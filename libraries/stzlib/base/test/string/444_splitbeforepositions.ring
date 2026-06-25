load "../../stzBase.ring"
load "../_narrated.ring"

# SplitBeforePositions -- split the string just before each given position.
# (Replaces the convoluted SplitWXT(:BeforePositions = position-predicate),
# which reduced to exactly this direct call.)

Scenario("SplitBeforePositions splits before positions 4 and 8")
	Given('the string "---4---8---"')
	Then("the pieces start at 4 and 8", @@( Q("---4---8---").SplitBeforePositions([ 4, 8 ]) ), @@([ "---", "4---", "8---" ]))
EndScenario()

Summary()
