load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAroundPositions -- isolate the chars at the given positions as their own
# pieces. (Replaces SplitWXT(:AroundPositions = position-predicate).)

Scenario("SplitAroundPositions isolates positions 4 and 8")
	Given('the string "---4---8---"')
	Then("the chars at 4 and 8 become their own pieces",
		@@( Q("---4---8---").SplitAroundPositions([ 4, 8 ]) ), @@([ "---", "4", "---", "8", "---" ]))
EndScenario()

Summary()
