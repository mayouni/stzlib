load "../../stzBase.ring"
load "../_narrated.ring"

# stzGraphRule -- THE OBJECT FACE of the rule engine (graph-rules plan, phase 1).
#
# base/graph/stzGraphRule.ring was a FUNCTION registry: StzRegisterRule(group,
# name, def) with param-driven closures. It worked, but a rule had no IDENTITY --
# no object to name, inherit from, or carry per-rule state -- and stzWorkflow
# already wrote `new stzGraphRule(...)` against a class that DID NOT EXIST
# (new stzGraphRule("x") raised R11). Five hand-rolled checkers across the
# library each re-implemented "walk a structure, test a predicate, emit a
# finding" in their own shape.
#
# This phase builds the class as the OBJECT FACE over the SAME registry: you
# declare a rule fluently, it compiles DOWN to a registered rule function, and
# -- the property this phase must earn -- the registered function and the
# object's own Check() share ONE matcher, so they cannot disagree.
#
# The load-bearing proof is Scene 4: the object rule reproduces the existing
# hand-written invariant StzCheckNoLLMEffectful EXACTLY, on the same graph --
# which is what makes phase 4 (the agent guardrails as declared rules) real.

  #-- a small graph carrying the agent-graph shape (kind + capabilities) ----

$oG = new stzGraph("agents")
$oG.AddNode("writer")
$oG.SetNodeProperty("writer", "kind", "llm_actor")
$oG.SetNodeProperty("writer", "capabilities", [ "inference", "effectful" ])
$oG.AddNode("planner")
$oG.SetNodeProperty("planner", "kind", "llm_actor")
$oG.SetNodeProperty("planner", "capabilities", [ "inference" ])
$oG.AddNode("gate")
$oG.SetNodeProperty("gate", "kind", "pi_actor")
$oG.SetNodeProperty("gate", "capabilities", [ "effectful" ])

Scenario("a rule is a first-class object -- the class stzWorkflow already assumed")
	Given("a fluently-declared graph rule")
	oRule = new stzGraphRule("no-llm-effectful")
	oRule.SetDomainQ("agentic")
	oRule.SetSeverityQ("error")
	oRule.SetMessageQ("an llm actor must not hold the effectful capability")
	oRule.WhenQ("kind", "equals", "llm_actor")
	oRule.WhenQ("capabilities", "contains", "effectful")
	oRule.ThenViolationQ("llm actor holds effectful -- an LLM proposes, a gate commits")
	Then("it carries its identity", oRule.Name(), "no-llm-effectful")
	Then("...its domain (registry group)", oRule.Domain(), "agentic")
	Then("...its type defaults to validation", oRule.RuleType(), "validation")
	Then("...and its two clauses", oRule.NumberOfClauses(), 2)
EndScenario()

Scenario("Check() finds every node matching ALL clauses")
	oRule = new stzGraphRule("no-llm-effectful")
	oRule.SetDomainQ("agentic")
	oRule.WhenQ("kind", "equals", "llm_actor")
	oRule.WhenQ("capabilities", "contains", "effectful")
	oRule.ThenViolationQ("llm holds effectful")
	aF = oRule.Check($oG)
	Then("only the llm_actor WITH effectful is flagged", len(aF), 1)
	Then("...it is the writer (not planner, not the pi gate)", aF[1][:where], "writer")
	Then("the finding carries the rule name", aF[1][:rule], "no-llm-effectful")
	Then("...the severity", aF[1][:severity], "error")
	Then("...and the violation message", aF[1][:message], "llm holds effectful")
	Then("Holds() is false when there is a finding", oRule.Holds($oG), FALSE)
EndScenario()

Scenario("THE PROOF: the object reproduces the hand-written invariant exactly")
	Given("the object rule and stzGovernanceChecks' StzCheckNoLLMEffectful")
	oRule = new stzGraphRule("no-llm-effectful")
	oRule.WhenQ("kind", "equals", "llm_actor")
	oRule.WhenQ("capabilities", "contains", "effectful")
	oRule.ThenViolationQ("x")
	aObj  = oRule.Check($oG)
	aHand = StzCheckNoLLMEffectful($oG)
	Then("both find exactly one violation", len(aObj), len(aHand))
	Then("...on the very same node", aObj[1][:where], aHand[1][:node])
	# so a hand-written graph walk becomes a DECLARED rule with no loss --
	# which is exactly what phase 4 turns the four agent guardrails into.
EndScenario()

Scenario("the registered function and the object cannot diverge")
	Given("a rule registered into the shared $aGraphRules registry")
	oRule = new stzGraphRule("no-llm-effectful-reg")
	oRule.SetDomainQ("agentic")
	oRule.WhenQ("kind", "equals", "llm_actor")
	oRule.WhenQ("capabilities", "contains", "effectful")
	oRule.ThenViolationQ("x")
	oRule.Register()
	Then("the registry now knows it", isList(StzGetRule("agentic", "no-llm-effectful-reg")), TRUE)

	When("the registered function is run directly")
	e = StzGetRule("agentic", "no-llm-effectful-reg")
	fn = e[:function]
	res = call fn($oG, e[:params])
	Then("its ok-flag is FALSE (violations present)", res[1], FALSE)
	Then("...which is exactly what the object's Holds() says", res[1], oRule.Holds($oG))
	# both faces call StzGraphRuleFindings -- ONE matcher, so they agree by
	# construction, not by luck.
EndScenario()

Scenario("plain form does the act; Q form chains")
	Given("a rule configured through the PLAIN mutators")
	oRule = new stzGraphRule("plain")
	oRule.SetDomain("bpm")
	oRule.SetSeverity("warning")
	Then("the plain SetDomain took effect", oRule.Domain(), "bpm")
	Then("...and plain SetSeverity too", oRule.Severity(), "warning")

	When("the Q form is chained off the StzGraphRuleQ() constructor")
	# chaining goes through the Q constructor (Ring cannot chain a method off a
	# bare `new`); StzGraphRuleQ(name) IS the chainable door, by convention.
	oChained = StzGraphRuleQ("chained").SetDomainQ("bpm").WhenQ("kind", "equals", "step")
	Then("the one-line chain built the whole rule", oChained.NumberOfClauses(), 1)
	Then("...with the domain set along the way", oChained.Domain(), "bpm")
EndScenario()

Scenario("the stzWorkflow brace-block style is supported (phase-2 compatibility)")
	Given("a rule declared in the exact shape stzWorkflow's BPM rule base uses")
	oRule = new stzGraphRule("bpm_no_orphans")
	oRule {
		SetRuleType("validation")
		SetDomain("bpm")
		SetMessage("Step has no incoming or outgoing connections")
		When("nodeType", "equals", "step")
		ThenViolation("Orphan step detected")
	}
	Then("the brace block configured the type", oRule.RuleType(), "validation")
	Then("...the domain", oRule.Domain(), "bpm")
	Then("...and the clause", oRule.NumberOfClauses(), 1)
	# so phase 2 can construct stzBPMRuleBase / stzSLARuleBase unchanged.
EndScenario()

Scenario("the operator set covers what the code/agent phases need")
	Given("a graph with a mix of node shapes")
	oG2 = new stzGraph("mix")
	oG2.AddNode("a")
	oG2.SetNodeProperty("a", "kind", "step")
	oG2.AddNode("b")
	oG2.SetNodeProperty("b", "kind", "decision")
	oG2.SetNodeProperty("b", "assignee", "ops")
	oG2.AddNode("c")
	oG2.SetNodeProperty("c", "kind", "step")

	When("not-equals selects the complement")
	oNE = new stzGraphRule("not-step")
	oNE.WhenQ("kind", "not-equals", "step")
	oNE.ThenViolationQ("x")
	Then("only the decision node matches", len(oNE.Check(oG2)), 1)

	When("missing flags nodes lacking a property")
	oMiss = new stzGraphRule("no-assignee")
	oMiss.WhenQ("assignee", "missing", "")
	oMiss.ThenViolationQ("x")
	Then("the two nodes with no assignee are flagged", len(oMiss.Check(oG2)), 2)

	When("exists flags nodes that have it")
	oHas = new stzGraphRule("has-assignee")
	oHas.WhenQ("assignee", "exists", "")
	oHas.ThenViolationQ("x")
	Then("only the assigned node matches", len(oHas.Check(oG2)), 1)

	When("equals is case-insensitive (matching the governance idiom)")
	oCase = new stzGraphRule("STEP-upper")
	oCase.WhenQ("kind", "equals", "STEP")
	oCase.ThenViolationQ("x")
	Then("STEP matches step", len(oCase.Check(oG2)), 2)
EndScenario()

Scenario("an explicit checker is the escape hatch for richer rules")
	Given("a whole-graph checker (the shape phase 4/5 reachability rules use)")
	oRule = new stzGraphRule("too-many-actors")
	oRule.SetSeverityQ("warning")
	oRule.UseCheckerQ(func oGraph {
		if oGraph.NodeCount() > 2
			return [ [ :where = "", :message = "graph has " + oGraph.NodeCount() + " nodes" ] ]
		ok
		return []
	})
	aF = oRule.Check($oG)
	Then("the checker produced a graph-wide finding", len(aF), 1)
	Then("...with an empty node locus (whole-graph)", aF[1][:where], "")
	Then("...carrying the checker's message", StzFindFirst("3 nodes", aF[1][:message]) > 0, TRUE)
	Then("HasChecker reports it", oRule.HasChecker(), TRUE)
EndScenario()

Scenario("a rule with no clauses holds vacuously; bad inputs are refused early")
	oEmpty = new stzGraphRule("empty")
	Then("no clauses => no findings", len(oEmpty.Check($oG)), 0)

	When("an unknown operator is declared")
	bRaised = FALSE
	try
		oBad = new stzGraphRule("bad")
		oBad.WhenQ("kind", "sortof-equals", "x")
	catch
		bRaised = TRUE
	done
	Then("the typo is caught at declaration, not silently never-matching", bRaised, TRUE)

	When("an unknown rule type is set")
	bRaised2 = FALSE
	try
		new stzGraphRule("bad2").SetRuleTypeQ("guardrail")
	catch
		bRaised2 = TRUE
	done
	Then("it is refused", bRaised2, TRUE)

	When("a nameless rule is constructed")
	bRaised3 = FALSE
	try
		new stzGraphRule("")
	catch
		bRaised3 = TRUE
	done
	Then("a rule must have a name", bRaised3, TRUE)
EndScenario()

Summary()
