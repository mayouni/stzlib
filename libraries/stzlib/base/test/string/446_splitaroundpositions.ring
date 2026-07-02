load "../../stzBase.ring"
load "../_narrated.ring"

# SplitAroundPositions -- the pieces AROUND the given positions (the chars
# at the positions are dropped), consistent with the whole SplitAround
# family (SplitAround / SplitAroundSections / archive block #363). An
# earlier version of this test (authored as the SplitWXT(:AroundPositions)
# replacement) asserted isolate-the-anchors semantics; the monolith's own
# SplitAroundPositions block (#363) drops them.

Scenario("SplitAroundPositions drops the chars at 4 and 8")
	Given('the string "---4---8---"')
	Then("the pieces between the positions remain",
		@@( Q("---4---8---").SplitAroundPositions([ 4, 8 ]) ), @@([ "---", "---", "---" ]))
EndScenario()

Summary()
