load "../../stzBase.ring"
load "../_narrated.ring"

# stzGraphRuleSet + the repaired rule bases (graph-rules plan, phase 2).
#
# Phase 1 gave a rule an OBJECT. Phase 2 gives a NAMED SET of rules you run over
# a graph in one call (stzGraphRuleSet: AddRule / Check / IsSound), and repairs
# the two things that already assumed exactly that:
#
#  - stzWorkflow's stzBPMRuleBase / stzSLARuleBase called `new stzGraphRule(...)`
#    (R11 until phase 1) AND `This.AddRule(...)` against a method that did not
#    exist, with a DSL richer than phase 1 built (Then + greaterthan). They
#    NEVER ran. They construct and run now.
#  - stzOrgChart's SOX/GDPR/... compliance bases were name-only stubs; they are
#    real (empty) rule sets now, of the same type as the workflow bases.
#
# The DSL grew a Then(prop,op,value) REQUIREMENT clause + comparison operators,
# turning a rule from a prohibition ("no node should match") into an implication
# ("every node matching When must satisfy Then").

  #-- a small workflow graph: one start, an unassigned step, a thin decision,
  #   and a disconnected orphan --------------------------------------------------
$oWF = new stzGraph("wf")
$oWF.AddNode("start")
$oWF.SetNodeProperty("start", "nodeType", "start")
$oWF.AddNode("s1")
$oWF.SetNodeProperty("s1", "nodeType", "step")
$oWF.SetNodeProperty("s1", "assignedTo", "ops")
$oWF.AddNode("d1")
$oWF.SetNodeProperty("d1", "nodeType", "decision")
$oWF.AddNode("s2")
$oWF.SetNodeProperty("s2", "nodeType", "step")
$oWF.AddNode("orphan")
$oWF.SetNodeProperty("orphan", "nodeType", "step")
$oWF.SetNodeProperty("orphan", "assignedTo", "ops")
$oWF.AddEdge("start", "s1")
$oWF.AddEdge("s1", "d1")
$oWF.AddEdge("d1", "s2")

Scenario("Then() turns a rule into an implication with a comparison")
	Given("a graph with critical nodes, one with an SLA and one without")
	oG = new stzGraph("sla")
	oG.AddNode("ok")
	oG.SetNodeProperty("ok", "critical", TRUE)
	oG.SetNodeProperty("ok", "sla", 10)
	oG.AddNode("bad")
	oG.SetNodeProperty("bad", "critical", TRUE)
	oG.AddNode("nc")
	oG.SetNodeProperty("nc", "critical", FALSE)

	oRule = new stzGraphRule("sla-defined")
	oRule.WhenQ("critical", "equals", TRUE)
	oRule.ThenQ("sla", "greaterthan", 0)
	oRule.ThenViolationQ("critical node without an SLA")
	Then("the rule knows it is an implication", oRule.IsImplication(), TRUE)
	Then("...with one requirement", oRule.NumberOfRequirements(), 1)

	aF = oRule.Check(oG)
	Then("only the critical node LACKING an sla is flagged", len(aF), 1)
	Then("...it is 'bad' (not 'ok', not the non-critical 'nc')", aF[1][:where], "bad")
	# the comparison reads an unset property as 0, so a missing sla fails > 0.
EndScenario()

Scenario("a rule set runs every rule and aggregates findings")
	Given("a set with two rules")
	oSet = new stzGraphRuleSet("sla")
	oSet.SetDomainQ("sla")
	oR1 = new stzGraphRule("must-have-sla")
	oR1.WhenQ("critical", "equals", TRUE)
	oR1.ThenQ("sla", "greaterthan", 0)
	oR1.ThenViolationQ("no sla")
	oSet.AddRule(oR1)
	oR2 = new stzGraphRule("no-negative-sla")
	oR2.WhenQ("sla", "lessthan", 0)
	oR2.ThenViolationQ("negative sla")
	oSet.AddRule(oR2)
	Then("the set holds both rules", oSet.NumberOfRules(), 2)
	Then("...listable by name", StzFindFirst("must-have-sla", @@(oSet.RuleNames())) > 0, TRUE)
	Then("...a rule is reachable by name", oSet.RuleNamed("no-negative-sla").Name(), "no-negative-sla")

	When("a rule with no domain is added, it inherits the set's")
	oR3 = new stzGraphRule("plain-one")
	oSet.AddRule(oR3)
	Then("the added rule took the set's domain", oR3.Domain(), "sla")
EndScenario()

Scenario("REPAIRED: stzBPMRuleBase constructs and finds real problems")
	Given("the BPM rule base (which raised R11, then R14, and never ran)")
	oBPM = new stzBPMRuleBase()
	Then("it constructs as a rule set", oBPM.NumberOfRules(), 4)
	Then("...in the bpm domain", oBPM.Domain(), "bpm")

	When("it checks the workflow graph")
	aF = oBPM.Check($oWF)
	Then("it finds the four distinct problems", len(aF), 4)
	Then("...the orphan step", HasFinding(aF, "bpm_no_orphans", "orphan"), TRUE)
	Then("...the unassigned step s2", HasFinding(aF, "bpm_assignment_required", "s2"), TRUE)
	Then("...the thin decision d1", HasFinding(aF, "bpm_decision_branches", "d1"), TRUE)
	Then("...and that there is more than one start (orphan has no incoming either)",
	     HasRule(aF, "bpm_single_start"), TRUE)
	Then("the base is NOT sound (errors present)", oBPM.IsSound($oWF), FALSE)
EndScenario()

Scenario("REPAIRED: stzSLARuleBase constructs and enforces SLAs")
	Given("a graph with SLA data")
	oG = new stzGraph("sla2")
	oG.AddNode("ok")
	oG.SetNodeProperty("ok", "critical", TRUE)
	oG.SetNodeProperty("ok", "sla", 10)
	oG.SetNodeProperty("ok", "duration", 8)
	oG.AddNode("nosla")
	oG.SetNodeProperty("nosla", "critical", TRUE)
	oG.AddNode("over")
	oG.SetNodeProperty("over", "sla", 5)
	oG.SetNodeProperty("over", "duration", 9)

	oSLA = new stzSLARuleBase()
	Then("it constructs with two rules", oSLA.NumberOfRules(), 2)
	aF = oSLA.Check(oG)
	Then("it flags the critical step with no SLA", HasFinding(aF, "sla_defined", "nosla"), TRUE)
	Then("...and the step whose duration exceeds its SLA", HasFinding(aF, "sla_compliance", "over"), TRUE)
	Then("...but not the compliant one", HasWhere(aF, "ok"), FALSE)
EndScenario()

Scenario("the rule sets compile down into the shared registry")
	Given("the BPM base registered wholesale")
	oBPM = new stzBPMRuleBase()
	oBPM.RegisterAll()
	Then("each rule is now in the registry under its domain",
	     isList(StzGetRule("bpm", "bpm_assignment_required")), TRUE)
EndScenario()

Scenario("stzOrgChart compliance bases are real rule sets now, not stubs")
	Given("the SOX compliance base (a documented stub before phase 2)")
	oSOX = new stzSOXRuleBase()
	Then("it still constructs and keeps its name", oSOX.Name(), "SOX")
	Then("...but is now a rule set (Check exists)", oSOX.NumberOfRules(), 0)
	Then("...that can run over a graph", oSOX.NumberOfFindings($oWF), 0)
	# the mechanism is real; the per-regime rule CONTENT + a graph projection of
	# the position model are phase 2b (domain work, not fabricated here).
	Then("the GDPR base too", (new stzGDPRRuleBase()).Name(), "GDPR")
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func HasFinding aFindings, cRule, cWhere
	n = len(aFindings)
	for i = 1 to n
		if aFindings[i][:rule] = cRule and aFindings[i][:where] = cWhere
			return TRUE
		ok
	next
	return FALSE

func HasRule aFindings, cRule
	n = len(aFindings)
	for i = 1 to n
		if aFindings[i][:rule] = cRule
			return TRUE
		ok
	next
	return FALSE

func HasWhere aFindings, cWhere
	n = len(aFindings)
	for i = 1 to n
		if aFindings[i][:where] = cWhere
			return TRUE
		ok
	next
	return FALSE
