load "../../stzBase.ring"
load "../_narrated.ring"

# stzOrgChart governance rules over a graph projection (graph-rules plan, P2b).
#
# Phase 2 unified stzOrgChart's SOX/GDPR/... compliance stubs as rule sets but
# left them EMPTY: an stzOrgChart is a POSITIONS model, not a graph. Phase 2b
# gives it AsRuleGraph() -- positions to nodes, reportsTo to "supervises" edges,
# level/department/roles to node properties -- and real rules over it: the
# universal org-integrity tier every compliance base carries, plus the SOX
# separation-of-duties exemplar. Findings are unified [ :rule, :subject=orgchart,
# :where, :severity, :message ], so an org chart joins the one CI gate.

Scenario("AsRuleGraph projects positions into a colored graph")
	oOrg = new stzOrgChart("acme")
	oOrg.AddExecutivePosition("ceo")
	oOrg.AddManagementPosition("cfo")
	oOrg.AddStaffPosition("clerk")
	oOrg.ReportsTo("cfo", "ceo")
	oOrg.ReportsTo("clerk", "cfo")
	g = oOrg.AsRuleGraph()
	Then("one node per position", len(g.NodesIds()), 3)
	Then("...carrying the level property", g.NodeProperty("ceo", "level"), "executive")
	Then("...a supervises edge exists ceo -> cfo", g.EdgeExists("ceo", "cfo"), TRUE)
	Then("...and the reporting chain is acyclic (a chain is NOT a cycle)",
	     oOrg.GovernanceIsSound(), TRUE)
EndScenario()

Scenario("no-self-report and no-cyclic-reporting")
	Given("a position reporting to itself")
	oS = new stzOrgChart("s")
	oS.AddExecutivePosition("boss")
	oS.AddStaffPosition("rogue")
	oS.ReportsTo("rogue", "rogue")
	aF = oS.GovernanceFindings()
	Then("no-self-report fires on it", HasAt(aF, "no-self-report", "rogue"), TRUE)
	Then("...and it is the only integrity error (no false cycle)",
	     CountRule(aF, "no-cyclic-reporting"), 0)

	Given("a real reporting cycle a <-> b")
	oC = new stzOrgChart("c")
	oC.AddExecutivePosition("top")
	oC.AddManagementPosition("a")
	oC.AddManagementPosition("b")
	oC.ReportsTo("a", "b")
	oC.ReportsTo("b", "a")
	aC = oC.GovernanceFindings()
	Then("no-cyclic-reporting flags both a and b",
	     HasAt(aC, "no-cyclic-reporting", "a") and HasAt(aC, "no-cyclic-reporting", "b"), TRUE)
EndScenario()

Scenario("no-orphan-position and span-of-control")
	Given("a non-executive position with no supervisor")
	oO = new stzOrgChart("o")
	oO.AddExecutivePosition("ceo")
	oO.AddStaffPosition("lonely")
	Then("no-orphan-position warns on the orphan", HasAt(oO.GovernanceFindings(), "no-orphan-position", "lonely"), TRUE)
	Then("...but not on the executive (a root legitimately has no supervisor)",
	     HasAt(oO.GovernanceFindings(), "no-orphan-position", "ceo"), FALSE)

	Given("a manager with 9 direct reports")
	oB = new stzOrgChart("b")
	oB.AddExecutivePosition("mgr")
	for i = 1 to 9
		oB.AddStaffPosition("r" + i)
		oB.ReportsTo("r" + i, "mgr")
	next
	Then("span-of-control warns (> 8 reports)", HasAt(oB.GovernanceFindings(), "span-of-control", "mgr"), TRUE)
EndScenario()

Scenario("SOX carries the universal tier PLUS separation-of-duties")
	Given("the SOX compliance base")
	oSOX = new stzSOXRuleBase()
	Then("it carries 5 rules (4 universal + SOD)", oSOX.NumberOfRules(), 5)
	Then("...including separation-of-duties", isObject(oSOX.RuleNamed("separation-of-duties")), TRUE)

	Given("a position holding both approver and executor roles")
	oOrg = new stzOrgChart("acme")
	oOrg.AddExecutivePosition("ceo")
	oOrg.AddStaffPositionXTT("dealer", "Dealer", [ :roles = [ "approver", "executor" ] ])
	oOrg.ReportsTo("dealer", "ceo")
	aF = oOrg.CheckCompliance(oSOX)
	Then("separation-of-duties fires on the dealer", HasAt(aF, "separation-of-duties", "dealer"), TRUE)
	Then("...as an error", SevOf(aF, "separation-of-duties"), "error")

	Given("a dealer holding only ONE of the conflicting roles")
	oOK = new stzOrgChart("ok")
	oOK.AddExecutivePosition("ceo")
	oOK.AddStaffPositionXTT("checker", "Checker", [ :roles = [ "approver" ] ])
	oOK.ReportsTo("checker", "ceo")
	Then("no separation-of-duties finding", HasRule(oOK.CheckCompliance(oSOX), "separation-of-duties"), FALSE)
EndScenario()

Scenario("the other compliance bases are real rule sets carrying the universal tier")
	Then("GDPR carries the universal rules", (new stzGDPRRuleBase()).NumberOfRules(), 4)
	Then("...HIPAA too", (new stzHIPAARuleBase()).NumberOfRules(), 4)
	# regime-specific rules (GDPR data-owner, HIPAA access, ...) are domain
	# follow-up -- the mechanism is real and the bases are ready to carry them.
EndScenario()

Scenario("an org chart joins the ONE CI gate, subject = orgchart")
	oOrg = new stzOrgChart("acme")
	oOrg.AddExecutivePosition("ceo")
	oOrg.AddStaffPosition("rogue")
	oOrg.ReportsTo("rogue", "rogue")
	oRep = new stzRuleReport("acme")
	oRep.Run(new stzSOXRuleBase(), oOrg.AsRuleGraph())
	Then("the gate collected orgchart findings", len(oRep.FindingsOfSubject("orgchart")) >= 1, TRUE)
	Then("...tagged with :subject = orgchart", oRep.Findings()[1][:subject], "orgchart")
	Then("...and the gate is unsound", oRep.IsSound(), FALSE)
EndScenario()

Scenario("backward-compat: bases still construct and LoadRuleBase still works")
	Given("an org chart and the compliance bases used as in the isvalid test")
	oOrg = new stzOrgChart("acme")
	oOrg.LoadRuleBase(new stzSOXRuleBase())
	Then("LoadRuleBase records the base", len(oOrg.RuleBases()) >= 1, TRUE)
	Then("...the base kept its name", (new stzSOXRuleBase()).Name(), "SOX")
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func HasRule aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return TRUE ok
	next
	return FALSE

func HasAt aF, cRule, cWhere
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule and aF[i][:where] = cWhere return TRUE ok
	next
	return FALSE

func CountRule aF, cRule
	c = 0
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule c++ ok
	next
	return c

func SevOf aF, cRule
	n = len(aF)
	for i = 1 to n
		if aF[i][:rule] = cRule return "" + aF[i][:severity] ok
	next
	return ""
