load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-REVOKE-CAP-01 -- threat-model risk R10: :RevokeCapability, for real.
#
# When an incident's actor can REACH the effectful capability (the security
# graph answers it), the plan proposes :RevokeCapability -- and nothing could
# perform it. stzSecurityGraph.CutCapability removes every path by which THAT
# actor reaches the capability (its own first-hop edges: a capability held
# directly, a tool that grants it, a delegation to an actor who has it), and
# stzCapabilityResponder also revokes the kind from the live stzSystemActor --
# the graph is what audits ask, the live actor is what the runtime gates ask.
#
# The graph: a compromised billing-agent reaches 'effectful' TWO ways --
# through deploy-tool, and by delegating to ops-bot. release-bot, a
# colleague, uses the same deploy-tool.

$oHuman = HumanActor("oncall")

Scenario("the incident proposes revoking the capability, from the graph's own answer")
	g = BuildGraph()
	Then("billing-agent reaches effectful before", g.ReachesEffectful("billing-agent"), 1)
	oPlan = StzResponsePlan("contain-INC-7")
	oPlan.ProposeForIncident(IncidentOn(g))
	Then("the plan proposes :RevokeCapability", HasAction(oPlan, "revokecapability"), 1)
EndScenario()

Scenario("committed, it cuts every path -- and only that actor's")
	g = BuildGraph()
	oBilling = HumanActor("billing-agent")
	oRelease = HumanActor("release-bot")
	oAuth = new stzAuth()
	oAuth.Register("billing-agent", "pw")
	oCap = StzCapabilityResponder(g)
	oCap.AddLiveActor(oBilling)
	oCap.AddLiveActor(oRelease)
	oSet = StzResponderSet([ StzAuthResponder(oAuth) ])
	oSet.Add(oCap)
	oPlan = StzResponsePlan("contain-INC-7")
	oPlan.ProposeForIncident(IncidentOn(g))
	nDone = oPlan.ExecuteOn(oSet, $oHuman)
	Then("lock, session revocation and capability revocation were committed", nDone, 3)
	Then("billing-agent no longer reaches effectful", g.ReachesEffectful("billing-agent"), 0)
	Then("no path is left", len(g.PathToEffectful("billing-agent")), 0)
	Then("BOTH of its paths were cut (the tool and the delegation)", len(oCap.LastCut()), 2)
	Then("release-bot, using the same tool, keeps it", g.ReachesEffectful("release-bot"), 1)
	Then("ops-bot keeps its own capability", g.ReachesEffectful("ops-bot"), 1)
	Then("billing-agent keeps what it did not misuse (sensing)", g.ReachesCapability("billing-agent", "sensing"), 1)
	Then("the LIVE billing-agent is no longer effectful", oBilling.IsEffectful(), 0)
	Then("so it can no longer commit a plan", StzResponsePlan("p").MayCommit(oBilling), 0)
	Then("the live release-bot is untouched", oRelease.IsEffectful(), 1)
	Then("and the account is locked too", oAuth.IsAccountLocked("billing-agent"), 1)
EndScenario()

Scenario("an LLM can propose the revocation and cannot commit it")
	g = BuildGraph()
	oBilling = HumanActor("billing-agent")
	oPlan = StzResponsePlan("llm-proposal")
	oPlan.Propose(:RevokeCapability, "billing-agent", "the model concluded it was compromised")
	oCap = StzCapabilityResponder(g)
	oCap.AddLiveActor(oBilling)
	nDone = oPlan.ExecuteOn(oCap, LLMActor("investigator"))
	Then("nothing committed", nDone, 0)
	Then("the path is intact", g.ReachesEffectful("billing-agent"), 1)
	Then("the live actor is intact", oBilling.IsEffectful(), 1)
EndScenario()

Summary()

# -- helpers (after the main code: a func swallows what follows it) ---

func BuildGraph
	g = StzSecurityGraphQ("prod")
	g.AddActor("billing-agent", "trusted")
	g.AddActor("release-bot", "trusted")
	g.AddActor("ops-bot", "trusted")
	g.AddTool("deploy-tool")
	g.AddCapability("effectful")
	g.AddCapability("sensing")
	g.Uses("billing-agent", "deploy-tool")
	g.Grants("deploy-tool", "effectful")
	g.Uses("release-bot", "deploy-tool")
	g.Delegates("billing-agent", "ops-bot")
	g.Holds("ops-bot", "effectful")
	g.Holds("billing-agent", "sensing")
	return g

func IncidentOn oGraph
	oInc = new stzIncident("INC-7")
	oInc.FromCase([ :at = StzEngineTimeWallMs(), :where = "stolen-credential/billing-agent",
		:rule = "stolen-credential", :severity = "error",
		:message = "a failed sign-in followed by a reach for a secret",
		:headDigest = "", :ledgerCount = 0, :recent = [] ], StzSecurityLedger(8))
	oInc.WithGraph(oGraph)
	return oInc

func HasAction oPlan, cVerb
	a = oPlan.Actions()
	for i = 1 to len(a)
		if a[i][1] = cVerb  return 1  ok
	next
	return 0
