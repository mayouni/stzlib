load "../../stzBase.ring"
load "../_narrated.ring"

# stzSecurityGraph + stzSecurityRule -- security invariants that see PATHS (P5).
#
# stzSecurityPosture checks FLAGS ON SINGLE OBJECTS: is THIS actor both sandboxed
# and effectful. It is structurally blind to a sandboxed actor that reaches an
# effect THROUGH a tool or a delegation -- because that is a PATH. Phase 5 makes
# the security surface an explicit graph, so the escalation question becomes a
# REACHABILITY query: can any sandboxed node reach the effectful capability by
# ANY path? Plus the construction-time constraint (no live secret to a sandboxed
# actor) and the blast-radius query (who reaches a secret -- rotation planning).

Scenario("a security rule IS a graph rule; the set carries the invariants")
	oRule = new stzSecurityRule("sandboxed-reaches-effectful")
	Then("it constructs", isObject(oRule), TRUE)
	Then("...in the security domain", oRule.Domain(), "security")
	oSet = StzSecurityRuleSetQ()
	Then("the set carries the three invariants", oSet.NumberOfRules(), 3)
EndScenario()

Scenario("THE HEADLINE: multi-hop escalation the flag check cannot see")
	Given("a sandboxed actor that holds NO effectful, but uses a tool that grants it")
	oSG = new stzSecurityGraph("resto")
	oSG.AddActor("llm", "sandboxed")
	oSG.AddTool("shell")
	oSG.Uses("llm", "shell")
	oSG.Grants("shell", "effectful")
	Then("the graph says the llm REACHES effectful (multi-hop)", oSG.ReachesEffectful("llm"), TRUE)

	When("the same actor is checked by the posture (flag) validator")
	oP = new stzSecurityPosture("resto")
	oA = SystemActor("llm", [ "inference" ])
	oA.SetPosture("sandboxed")
	oP.AddActor(oA)
	Then("no-sandboxed-effectful does NOT fire -- the flag check is blind to the path",
	     HasInv(oP.Findings(), "no-sandboxed-effectful"), FALSE)

	When("the graph rule set runs")
	Then("sandboxed-reaches-effectful DOES fire", HasRule(oSG.Violations(), "sandboxed-reaches-effectful"), TRUE)
	Then("...on the llm node", WhereOf(oSG.Violations(), "sandboxed-reaches-effectful"), "llm")
	Then("...and the surface is not sound", oSG.IsSound(), FALSE)
EndScenario()

Scenario("escalation through DELEGATION, and the direct case, both caught")
	Given("a sandboxed actor delegating to a trusted actor that holds effectful")
	oSG = new stzSecurityGraph("deleg")
	oSG.AddActor("llm", "sandboxed")
	oSG.AddActor("admin", "trusted")
	oSG.Holds("admin", "effectful")
	oSG.Delegates("llm", "admin")
	Then("the llm reaches effectful via delegation", oSG.ReachesEffectful("llm"), TRUE)
	Then("...and the rule fires", HasRule(oSG.Violations(), "sandboxed-reaches-effectful"), TRUE)

	Given("a sandboxed actor holding effectful DIRECTLY (the flag case)")
	oD = new stzSecurityGraph("direct")
	oD.AddActor("bot", "sandboxed")
	oD.Holds("bot", "effectful")
	Then("the reachability rule subsumes the direct case too",
	     HasRule(oD.Violations(), "sandboxed-reaches-effectful"), TRUE)
EndScenario()

Scenario("a trusted actor reaching effectful is fine")
	oSG = new stzSecurityGraph("ok")
	oSG.AddActor("ops", "trusted")
	oSG.AddTool("deploy")
	oSG.Uses("ops", "deploy")
	oSG.Grants("deploy", "effectful")
	Then("a trusted actor may reach effectful -- no finding",
	     HasRule(oSG.Violations(), "sandboxed-reaches-effectful"), FALSE)
	Then("...the surface is sound", oSG.IsSound(), TRUE)
EndScenario()

Scenario("THE CONSTRAINT: no live secret to a sandboxed actor, refused at construction")
	oSG = new stzSecurityGraph("sec")
	oSG.AddActor("llm", "sandboxed")
	oSG.AddActor("ops", "trusted")
	oSG.AddSecret("db-key")
	Then("MayAttach is false for the sandboxed actor", oSG.MayAttach("llm", "db-key"), FALSE)
	bRaised = FALSE
	try
		oSG.AttachSecret("llm", "db-key")
	catch
		bRaised = TRUE
	done
	Then("...the attach is REFUSED", bRaised, TRUE)

	When("the same secret is attached to a TRUSTED actor")
	Then("MayAttach allows it", oSG.MayAttach("ops", "db-key"), TRUE)
	oSG.AttachSecret("ops", "db-key")
	Then("...it is applied -- only the sandboxed actor is refused",
	     oSG.GraphQ().PathExists("ops", "db-key"), TRUE)
EndScenario()

Scenario("blast radius: who reaches a secret (rotation planning)")
	oSG = new stzSecurityGraph("blast")
	oSG.AddSecret("stripe-key")
	oSG.AddStore("vault")
	oSG.StoredIn("stripe-key", "vault")
	oSG.AddSite("prod")
	oSG.AddSite("staging")
	oSG.References("prod", "stripe-key")
	oSG.References("staging", "stripe-key")
	aB = oSG.BlastRadius("stripe-key")
	Then("both sites are in the blast radius", len(aB) >= 2, TRUE)
	Then("...prod reaches it", StzFindFirst("prod", @@(aB)) > 0, TRUE)
	Then("...staging reaches it", StzFindFirst("staging", @@(aB)) > 0, TRUE)
EndScenario()

Scenario("unstored-secret: a referenced secret that lives in no store")
	oSG = new stzSecurityGraph("audit")
	oSG.AddSecret("inline")
	oSG.AddSite("prod")
	oSG.References("prod", "inline")
	Then("the warning fires (its reveals are uncaudited)",
	     HasRule(oSG.Violations(), "unstored-secret"), TRUE)

	When("the secret is placed in a store")
	oSG.AddStore("vault")
	oSG.StoredIn("inline", "vault")
	Then("the warning clears", HasRule(oSG.Violations(), "unstored-secret"), FALSE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func HasRule aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return TRUE ok
	next
	return FALSE

func HasInv aF, cInv
	n = len(aF)
	for i = 1 to n
		if aF[i][:invariant] = cInv return TRUE ok
	next
	return FALSE

func WhereOf aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return aF[i][:where] ok
	next
	return ""
