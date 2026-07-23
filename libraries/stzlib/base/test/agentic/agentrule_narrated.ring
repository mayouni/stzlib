load "../../stzBase.ring"
load "../_narrated.ring"

# stzAgentRule / stzAgentRuleSet -- the guardrails as declared rules (P4).
#
# meta/stzGovernanceChecks.ring's four invariants (no-llm-effectful,
# effects-guarded, open-text-contained, effects-traced) are hand-written walks
# over an agent graph -- literally graph rules written out by hand. Phase 4
# redeclares them as an stzAgentRuleSet (stzAgentRule IS-A stzGraphRule), adds
# the strengthening the library's own comment asked for (effects-dominated: the
# DOMINATOR form, not just the direct-guard form), and -- the load-bearing
# upgrade -- makes no-llm-effectful a CONSTRAINT: stzAgentGraph.Grant() refuses
# granting 'effectful' to an llm actor at CONSTRUCTION. Audit -> gate.

Scenario("an agent rule IS a graph rule; the set carries the guardrails")
	oRule = new stzAgentRule("no-llm-effectful")
	Then("stzAgentRule constructs", isObject(oRule), TRUE)
	Then("...in the agentic domain", oRule.Domain(), "agentic")
	oSet = StzAgentRuleSetQ()
	Then("the set carries the 4 guardrails + the dominator rule", oSet.NumberOfRules(), 5)
	Then("...effects-dominated is among them", oSet.RuleNamed("effects-dominated").Name(), "effects-dominated")
EndScenario()

Scenario("the rule set reproduces StzCheckAgentGraph exactly")
	Given("the ungoverned bad graph (llm proposes straight to an effect)")
	oBad = new stzAgentGraph("bad")
	oBad.AddLLMActor("writer")
	oBad.AddEffect("send")
	oBad.Proposes("writer", "send")

	aHand  = StzCheckAgentGraph(oBad.GraphQ())
	aRules = oBad.ViolationsViaRules()
	Then("both find the same three invariants firing", CountRule(aRules, "effects-guarded") +
	     CountRule(aRules, "open-text-contained") + CountRule(aRules, "effects-traced"), len(aHand))
	Then("...effects-guarded is in both",
	     HasRuleName(aHand, :invariant, "effects-guarded") and HasRuleName(aRules, :rule, "effects-guarded"), TRUE)
	Then("...open-text-contained is in both",
	     HasRuleName(aHand, :invariant, "open-text-contained") and HasRuleName(aRules, :rule, "open-text-contained"), TRUE)
	Then("...on the SAME nodes (send / writer / send)",
	     WhereOf(aRules, "effects-guarded"), NodeOf(aHand, "effects-guarded"))
EndScenario()

Scenario("THE UPGRADE: no-llm-effectful is refused at CONSTRUCTION, not just audited")
	Given("an llm actor and an effect")
	oAG = new stzAgentGraph("mailer")
	oAG.AddLLMActor("writer")
	oAG.AddPIActor("committer")

	When("granting 'effectful' to the llm actor is attempted")
	Then("MayGrant reports it is not allowed", oAG.MayGrant("writer", "effectful"), FALSE)
	bRaised = FALSE
	try
		oAG.Grant("writer", "effectful")
	catch
		bRaised = TRUE
	done
	Then("...the grant is REFUSED (gate, not audit)", bRaised, TRUE)
	Then("...and the llm never gained the capability",
	     ring_find(oAG.GraphQ().NodeProperty("writer", "capabilities"), "effectful"), 0)

	When("a benign capability is granted to the llm")
	oAG.Grant("writer", "sensing")
	Then("it is applied", ring_find(oAG.GraphQ().NodeProperty("writer", "capabilities"), "sensing") > 0, TRUE)

	When("'effectful' is granted to a PI actor (not an llm)")
	Then("MayGrant allows it", oAG.MayGrant("committer", "effectful"), TRUE)
	oAG.Grant("committer", "effectful")
	Then("...it is applied -- only the LLM is refused",
	     ring_find(oAG.GraphQ().NodeProperty("committer", "capabilities"), "effectful") > 0, TRUE)
EndScenario()

Scenario("the audit backstop: a RAW-injected effectful llm is still caught")
	Given("an llm whose capabilities are set raw, bypassing the gate")
	oAG = new stzAgentGraph("rogue")
	oAG.AddLLMActor("writer")
	oAG.GraphQ().SetNodeProperty("writer", "capabilities", [ "inference", "effectful" ])

	oRule = StzAgentRuleSetQ().RuleNamed("no-llm-effectful")
	aF = oRule.Check(oAG.GraphQ())
	Then("the no-llm-effectful rule flags it", len(aF), 1)
	Then("...on the writer node", aF[1][:where], "writer")
	# the gate refuses at the sanctioned door; the rule remains the backstop for
	# anything that reaches the graph another way.
EndScenario()

Scenario("THE STRENGTHENING: effects-dominated catches a bypass the direct form misses")
	Given("an effect with a guardian edge, BUT also a direct input->effect bypass")
	oAG = new stzAgentGraph("bypass")
	oAG.AddInput("req")
	oAG.AddGuardian("gate")
	oAG.AddEffect("send")
	oAG.AddTraceSink("audit")
	oAG.Guards("gate", "send")
	oAG.Feeds("req", "send")
	oAG.Traces("send", "audit")

	g = oAG.GraphQ()
	oSet = StzAgentRuleSetQ()
	Then("the direct-guard form PASSES (a guardian edge into send exists)",
	     len(oSet.RuleNamed("effects-guarded").Check(g)), 0)
	Then("but the DOMINATOR form catches the bypass",
	     len(oSet.RuleNamed("effects-dominated").Check(g)), 1)

	When("the bypass is removed (input -> gate -> send)")
	oOk = new stzAgentGraph("ok")
	oOk.AddInput("req")
	oOk.AddGuardian("gate")
	oOk.AddEffect("send")
	oOk.AddTraceSink("audit")
	oOk.Feeds("req", "gate")
	oOk.Guards("gate", "send")
	oOk.Traces("send", "audit")
	Then("effects-dominated is clean", len(oSet.RuleNamed("effects-dominated").Check(oOk.GraphQ())), 0)
EndScenario()

Scenario("a fully governed composition is sound by the rule set")
	oOk = new stzAgentGraph("governed")
	oOk.AddLLMActor("writer")
	oOk.AddGuardian("gate")
	oOk.AddEffect("send")
	oOk.AddTraceSink("audit")
	oOk.Proposes("writer", "gate")
	oOk.Guards("gate", "send")
	oOk.Feeds("gate", "send")
	oOk.Traces("send", "audit")
	Then("the rule set finds no violation", len(oOk.ViolationsViaRules()), 0)
	Then("...matching the classic audit verdict", oOk.IsSound(), TRUE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func CountRule aF, cName
	c = 0
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cName c++ ok
	next
	return c

func HasRuleName aF, key, cName
	n = len(aF)
	for i = 1 to n
		if aF[i][key] = cName return TRUE ok
	next
	return FALSE

func WhereOf aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return aF[i][:where] ok
	next
	return ""

func NodeOf aF, cInv
	n = len(aF)
	for i = 1 to n
		if aF[i][:invariant] = cInv return aF[i][:node] ok
	next
	return ""
