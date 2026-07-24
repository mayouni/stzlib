load "../../stzBase.ring"
load "../_narrated.ring"

# stzRuleReport -- one CI gate over every rule domain (graph-rules plan, P6).
#
# Phases 1-5 gave code, agents, and security each an stzGraphRuleSet. Phase 6
# unifies their finding shape to [ :rule, :subject, :where, :severity, :message ]
# (:subject = the rule's domain) and adds ONE gate that runs them all and gives
# one Findings()/IsSound()/Report() -- instead of three parallel APIs. The
# legacy hand-written checkers keep their own frozen shapes (they are the
# adapters); IngestLegacy normalizes their output so they can join the one gate.

Scenario("the unified finding shape carries :subject")
	Given("a code rule set run over a code graph")
	oCG = new stzRingCodeGraph("")
	oCG.ScanSource("class Bag" + nl + "def Len()" + nl + "	return 1" + nl, "s")
	aF = StzCodeRuleSetQ().Check(oCG)
	Then("a finding carries all five unified keys",
	     HasKey(aF[1], :rule) and HasKey(aF[1], :subject) and HasKey(aF[1], :where) and
	     HasKey(aF[1], :severity) and HasKey(aF[1], :message), TRUE)
	Then("...with :subject = the rule's domain", aF[1][:subject], "code")

	Given("the frozen StzCheckCode adapter")
	aC = StzCheckCode("class Bag" + nl + "def Len()" + nl + "	return 1" + nl)
	Then("it keeps :line (not :where)", HasKey(aC[1], :line), TRUE)
	Then("...and does NOT leak :subject -- its shape is frozen", HasKey(aC[1], :subject), FALSE)
EndScenario()

Scenario("THE ONE GATE: code + agents + security in a single pass")
	Given("a project with a violation in each of three domains")
	oRep = new stzRuleReport("restolean")

	oCG = new stzRingCodeGraph("")
	oCG.ScanSource("class Bag" + nl + "def Len()" + nl + "	return 1" + nl, "s")
	oRep.Run(StzCodeRuleSetQ(), oCG)

	oAG = new stzAgentGraph("mailer")
	oAG.AddLLMActor("writer")
	oAG.AddEffect("send")
	oAG.Proposes("writer", "send")
	oRep.Run(StzAgentRuleSetQ(), oAG.GraphQ())

	oSG = new stzSecurityGraph("sec")
	oSG.AddActor("llm", "sandboxed")
	oSG.AddTool("shell")
	oSG.Uses("llm", "shell")
	oSG.Grants("shell", "effectful")
	oRep.Run(StzSecurityRuleSetQ(), oSG.GraphQ())

	Then("all three subjects are present", len(oRep.Subjects()), 3)
	Then("...code has a finding", len(oRep.FindingsOfSubject("code")) >= 1, TRUE)
	Then("...agentic has findings", len(oRep.FindingsOfSubject("agentic")) >= 3, TRUE)
	Then("...security has a finding", len(oRep.FindingsOfSubject("security")) >= 1, TRUE)
	Then("ONE verdict spans all three", oRep.IsSound(), FALSE)
	Then("...every finding is error-severity here", len(oRep.Errors()), oRep.NumberOfFindings())
EndScenario()

Scenario("the gate renders one report grouped by subject")
	oRep = new stzRuleReport("proj")
	oSG = new stzSecurityGraph("s")
	oSG.AddActor("llm", "sandboxed")
	oSG.Holds("llm", "effectful")
	oRep.Run(StzSecurityRuleSetQ(), oSG.GraphQ())
	cNar = ReportText(oRep)
	Then("the report names the project and the verdict",
	     StzFindFirst("Rule report 'proj'", cNar) > 0 and StzFindFirst("UNSOUND", cNar) > 0, TRUE)
	Then("...groups findings under their subject", StzFindFirst("[security]", cNar) > 0, TRUE)
	Then("...and names the rule", StzFindFirst("sandboxed-reaches-effectful", cNar) > 0, TRUE)
EndScenario()

Scenario("a clean project is sound across all domains")
	oRep = new stzRuleReport("clean")
	oAG = new stzAgentGraph("ok")
	oAG.AddLLMActor("writer")
	oAG.AddGuardian("gate")
	oAG.AddEffect("send")
	oAG.AddTraceSink("audit")
	oAG.Proposes("writer", "gate")
	oAG.Guards("gate", "send")
	oAG.Feeds("gate", "send")
	oAG.Traces("send", "audit")
	oRep.Run(StzAgentRuleSetQ(), oAG.GraphQ())

	oCG = new stzRingCodeGraph("")
	oCG.ScanSource("class Bag" + nl + "def Count()" + nl + "	return 1" + nl, "s")
	oRep.Run(StzCodeRuleSetQ(), oCG)
	Then("no findings", oRep.NumberOfFindings(), 0)
	Then("...the gate is sound", oRep.IsSound(), TRUE)
EndScenario()

Scenario("IngestLegacy: the hand-written checkers join the one gate")
	Given("legacy findings from StzCheckAgentGraph and StzCheckCode")
	oAG = new stzAgentGraph("bad")
	oAG.AddLLMActor("writer")
	oAG.AddEffect("send")
	oAG.Proposes("writer", "send")
	aLegacyAgent = StzCheckAgentGraph(oAG.GraphQ())     # [ :invariant, :node, ... ]
	aLegacyCode  = StzCheckCode("class Bag" + nl + "def Len()" + nl + "	return 1" + nl)  # [ :line, ... ]

	oRep = new stzRuleReport("mixed")
	oRep.IngestLegacy(aLegacyAgent, "agentic")
	oRep.IngestLegacy(aLegacyCode, "code")
	Then("legacy findings are normalized into the unified shape",
	     HasKey(oRep.Findings()[1], :rule) and HasKey(oRep.Findings()[1], :subject) and
	     HasKey(oRep.Findings()[1], :where), TRUE)
	Then("...the invariant name became :rule",
	     len(oRep.Findings()[1][:rule]) > 0, TRUE)
	Then("...tagged with the given subject", len(oRep.FindingsOfSubject("agentic")) >= 1, TRUE)
	Then("...and the code line landed in :where", len(oRep.FindingsOfSubject("code")) >= 1, TRUE)
	Then("the one gate spans legacy sources too", oRep.IsSound(), FALSE)
EndScenario()

Scenario("severity filters + warnings advise, errors gate")
	oRep = new stzRuleReport("sev")
	oSG = new stzSecurityGraph("s")
	oSG.AddSecret("inline")
	oSG.AddSite("prod")
	oSG.References("prod", "inline")     # unstored-secret -> WARNING only
	oRep.Run(StzSecurityRuleSetQ(), oSG.GraphQ())
	Then("there is a warning", len(oRep.Warnings()) >= 1, TRUE)
	Then("...no error", len(oRep.Errors()), 0)
	Then("...so the gate is SOUND (warnings advise)", oRep.IsSound(), TRUE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func ReportText oRep
	aLines = oRep.Explain()
	cT = ""
	n = len(aLines)
	for i = 1 to n
		cT += aLines[i] + nl
	next
	return cT
