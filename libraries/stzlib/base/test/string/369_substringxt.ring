load "../../stzBase.ring"
load "../_narrated.ring"

# SubStringXT bound predicates: is a substring the bound (both sides), the
# first/left bound, or the last/right bound of another substring?
# Archive block #369.

Scenario("Bound predicates")
	Then("hearts bound ring on both sides",
		Q(".. ♥♥ring♥♥ ..").SubStringXT("♥♥", :IsBoundOf = "ring"), TRUE)
	Then("<< is the first bound",
		Q(".. <<ring>> ..").SubStringXT("<<", :IsFirstBoundOf = "ring"), TRUE)
	Then(">> is the last bound",
		Q(".. <<ring>> ..").SubStringXT(">>", :IsLastBoundOf = "ring"), TRUE)
	Then("... left spelling",
		Q(".. <<ring>> ..").SubStringXT("<<", :IsLeftBoundOf = "ring"), TRUE)
	Then("... right spelling",
		Q(".. <<ring>> ..").SubStringXT(">>", :IsRightBoundOf = "ring"), TRUE)
EndScenario()

Summary()
