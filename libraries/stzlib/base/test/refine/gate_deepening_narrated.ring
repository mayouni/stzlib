load "../../stzBase.ring"
load "../_narrated.ring"

# R6 DEEPENING -- the two RESERVED gate stages are now WIRED:
#   STAGE 3 DERIVATION  -> cross-point rules (declared predicates over
#                          the post-change state; a rejection ROLLS BACK)
#   STAGE 4 GOVERNANCE  -> stzGovernance (refining a point is the action
#                          "refine-<point>"; permission CAN + authority
#                          SHOULD vs the point's risk tier, decided
#                          BEFORE any mutation; a decision leaves lineage)
# A rejected proposal at ANY stage never mutates the source (LAW 3).

$cSrc = 'vat   = <R:PARAM name="vat" value="0.20" min="0" max="0.9">' + nl +
        'floor = <R:PARAM name="floor" value="0.10" min="0" max="0.9">' + nl +
        'engine = <R:ALGO name="sort" value="quick" options="quick|merge|heap">'

Scenario("STAGE 3: a cross-point derivation rule rejects and rolls back")
	Given("a refinable config where vat must stay >= floor")
	$o = new stzRefinableCode($cSrc)
	$o.DeclareDerivation("vat-above-floor",
		func oCode { return ring_number(oCode.ValueOf("vat")) >= ring_number(oCode.ValueOf("floor")) },
		"vat must not drop below floor")
	Then("the rule is registered", $o.NumberOfDerivations(), 1)

	When("a proposal keeps vat >= floor")
	r = $o.Refine("vat").To("0.30")
	Then("it is admitted", r[:admitted], 1)
	Then("the value changed", $o.ValueOf("vat"), "0.30")

	When("a proposal would push vat BELOW floor")
	r2 = $o.Refine("vat").To("0.05")
	Then("it is REJECTED at the derivation stage", r2[:admitted], 0)
	Then("the why names the derivation stage", StzFindFirst(r2[:why], "derivation") = 1, TRUE)
	Then("and the source ROLLED BACK to the last good value", $o.ValueOf("vat"), "0.30")
EndScenario()

Scenario("STAGE 4: governance gates the refinement before any mutation")
	Given("a governed config: refining 'sort' is a risk-3 action")
	$o2 = new stzRefinableCode($cSrc)
	$o2.GovernedBy(new stzGovernance("release-ops")).AsActor("release-bot")
	# config THROUGH the code so its one live governance copy is the truth
	$o2.RiskFor("sort", 3).AllowRefine("sort").WithAuthority(:Delegated)

	When("a delegated actor tries a risk-3 refinement")
	r = $o2.Refine("sort").To("merge")
	Then("it is REFUSED (authority 2 < risk 3)", r[:admitted], 0)
	Then("the why names governance", StzFindFirst(r[:why], "governance") = 1, TRUE)
	Then("the source is unchanged", $o2.ValueOf("sort"), "quick")

	When("the actor is escalated to autonomous authority (through the code)")
	$o2.WithAuthority(:Autonomous)                         # level 3
	r2 = $o2.Refine("sort").To("merge")
	Then("the refinement is now admitted", r2[:admitted], 1)
	Then("the value changed", $o2.ValueOf("sort"), "merge")
	Then("the decision left governed lineage",
		$o2.GovernanceQ().NumberOfDecisions() >= 1, TRUE)
EndScenario()

Scenario("an undeclared-risk point cannot be refined under governance")
	Given("a governed config where 'vat' has NO declared risk tier")
	$o3 = new stzRefinableCode($cSrc)
	$o3.GovernedBy(new stzGovernance("release-ops-2")).AsActor("bot")
	$o3.AllowRefine("vat").WithAuthority(:Autonomous)   # but no RiskFor("vat")
	When("a refinement of the undeclared point is attempted")
	r = $o3.Refine("vat").To("0.30")
	Then("it is refused (undeclared risk never proceeds)", r[:admitted], 0)
	Then("the source is unchanged", $o3.ValueOf("vat"), "0.20")
EndScenario()

Scenario("all four stages compose: structural, constraint, derivation, governance")
	Given("a fully-gated config")
	$o4 = new stzRefinableCode($cSrc)
	$o4.GovernedBy(new stzGovernance("full")).AsActor("op")
	$o4.RiskFor("vat", 1).AllowRefine("vat").WithAuthority(:Delegated)
	$o4.DeclareDerivation("vat-cap",
		func oCode { return ring_number(oCode.ValueOf("vat")) <= 0.5 },
		"vat may not exceed 0.5 by policy")

	rGhost = $o4.Refine("ghost").To("1")
	Then("structural failure: unknown point", rGhost[:admitted], 0)
	rMax = $o4.Refine("vat").To("0.95")
	Then("constraint failure: above max", rMax[:admitted], 0)
	rCap = $o4.Refine("vat").To("0.60")
	Then("derivation failure: over policy cap", rCap[:admitted], 0)
	rOk = $o4.Refine("vat").To("0.30")
	Then("all four pass: a clean refinement", rOk[:admitted], 1)
	Then("the admitted value stuck", $o4.ValueOf("vat"), "0.30")
EndScenario()

Summary()
