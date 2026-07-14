load "../../stzBase.ring"
load "../_narrated.ring"

# R7 -- stzApp PURPOSE MADE REAL: Pursue() measures, it no longer narrates.
#
# A goal is a WANTED GRAPH STATE (stzGraphGoal): "every :Client
# Has(:visited)" compiles to a pattern; the GAP is the set of instances
# breaking it, measured on the live world graph; each gap item becomes
# a proposal through the matching Whenever/Propose reaction. Schema
# declares; INSTANCES (Is_/Relate: isa-edges + labeled edges) live.
# The old Pursue() returned a hardcoded empty gap -- retired today.

$oApp = StzApp("visitsworld")
$oApp.Thing(:Client) { Has([ :code, :name ]) }
$oApp.Thing(:Visit)  { Of(:Client) }
$oApp.Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }
$oApp.Want(:EveryClientVisited) {
	Means     = "every :Client Has(:visited)"
	ReachedBy = :planning
}

Scenario("a goal is a wanted graph state; the gap is measured, not scripted")
	Given("two client instances, one already visited")
	$oApp.Is_("anna", :Client)
	$oApp.Is_("bilal", :Client)
	$oApp.Relate("anna", :visited, "visit1")

	When("the world pursues the goal")
	aProps = $oApp.Pursue(:EveryClientVisited)
	Then("exactly one proposal comes back", len(aProps), 1)
	Then("it proposes a visit (via the declared reaction)", aProps[1][2], "visit")
	Then("for the unvisited client", aProps[1][4], "bilal")
	Then("the goal is not yet satisfied", $oApp.GoalSatisfied(:EveryClientVisited), FALSE)

	When("bilal gets visited too")
	$oApp.Relate("bilal", :visited, "visit2")
	aProps = $oApp.Pursue(:EveryClientVisited)
	Then("no proposals remain", len(aProps), 0)
	Then("the goal is satisfied on the live graph",
		$oApp.GoalSatisfied(:EveryClientVisited), TRUE)
EndScenario()

Scenario("an unevaluable Means is refused, never faked (LAW 3)")
	Given("a goal whose Means carries no evaluable pattern")
	$oApp.Want(:Vague) { Means = "make things nice" }
	bRaised = FALSE
	try
		$oApp.Pursue(:Vague)
	catch
		bRaised = TRUE
	done
	Then("pursuing it raises instead of pretending", bRaised, TRUE)
EndScenario()

Scenario("the goal object is a readable snapshot")
	Given("the visits goal")
	oG = $oApp.Goal(:EveryClientVisited)
	Then("it carries its Means", oG.Means, "every :Client Has(:visited)")
	Then("and its profile", oG.Profile(), "planning")
	Then("and narrates canonically",
		oG.Narrate(), "wants everyclientvisited -> reached by planning")
EndScenario()

Scenario("the platform generates this world's shells (Generate is real)")
	Given("the world reaching :web, enveloped")
	$oApp.Reaches([ :web ])
	oPlat = StzPlatform("visits-envelope")
	oPlat.ForWorld($oApp)
	When("Generate(:all) runs")
	aShells = oPlat.Generate(:all)
	Then("the web shell was written to disk", fexists(aShells[1]), TRUE)
EndScenario()

Summary()
