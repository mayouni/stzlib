load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-QUARANTINE-01 -- threat-model risk R10, closed: :QuarantinePart for
# real, and every verb of the response catalogue performed by a real owner.
#
# stzAgentHost could Cancel an agent (a pause anyone can Resume) or Retire it
# (permanent, obligation-gated). QUARANTINE is the containment act between:
# the agent stops being run, the reason is kept, Resume() refuses, and only
# an effectful actor can Release it. stzAgentHostResponder performs it.
#
# The last scenario is the catalogue whole: one plan, six verbs, five real
# responders, each doing its own part.

$oHuman = HumanActor("oncall")

Scenario("a rogue agent is quarantined by a governed plan, and stops running")
	oHost = new stzAgentHost()
	oHost.Supervise(new probeAgent("rogue"), 1)
	oHost.Supervise(new probeAgent("steady"), 1)
	Pump(oHost)
	Then("both agents run before", oHost.TicksOf("rogue") > 0 and oHost.TicksOf("steady") > 0, 1)
	oPlan = StzResponsePlan("contain-rogue")
	oPlan.Propose(:QuarantinePart, "agent:rogue", "it reached for a secret it was never granted")
	Then("the action was committed", oPlan.ExecuteOn(StzAgentHostResponder(oHost), $oHuman), 1)
	Then("the agent is quarantined", oHost.IsQuarantined("rogue"), 1)
	Then("the reason is kept", oHost.QuarantineOf("rogue")[:reason], "quarantined by a containment plan")
	nRogue = oHost.TicksOf("rogue")
	nSteady = oHost.TicksOf("steady")
	Pump(oHost)
	Then("the quarantined agent does not run", oHost.TicksOf("rogue"), nRogue)
	Then("the other agent keeps running", oHost.TicksOf("steady") > nSteady, 1)
EndScenario()

Scenario("a quarantine holds until an effectful actor releases it")
	oHost = new stzAgentHost()
	oHost.Supervise(new probeAgent("rogue"), 1)
	oHost.Quarantine("rogue", "under investigation")
	bRaised = 0
	try  oHost.Resume("rogue")  catch  bRaised = 1  done
	Then("Resume() refuses while quarantined", bRaised, 1)
	bRaised = 0
	try  oHost.Release("rogue", LLMActor("assistant"))  catch  bRaised = 1  done
	Then("an LLM cannot release it", bRaised, 1)
	Then("...so it is still quarantined", oHost.IsQuarantined("rogue"), 1)
	oHost.Release("rogue", $oHuman)
	Then("a human releases it", oHost.IsQuarantined("rogue"), 0)
	n0 = oHost.TicksOf("rogue")
	Pump(oHost)
	Then("and it runs again (negative sibling)", oHost.TicksOf("rogue") > n0, 1)
EndScenario()

Scenario("an LLM can propose a quarantine and cannot commit it")
	oHost = new stzAgentHost()
	oHost.Supervise(new probeAgent("rogue"), 1)
	oPlan = StzResponsePlan("llm")
	oPlan.Propose(:QuarantinePart, "rogue", "the model is suspicious of it")
	Then("nothing committed", oPlan.ExecuteOn(StzAgentHostResponder(oHost), LLMActor("assistant")), 0)
	Then("the agent is not quarantined", oHost.IsQuarantined("rogue"), 0)
EndScenario()

Scenario("THE CATALOGUE WHOLE: one plan, six verbs, five real responders")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "pw")
	cTok = oAuth.Login("mallory", "pw")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("webhook").FromLiteralQ("whsec_old"))
	g = StzSecurityGraphQ("prod")
	g.AddActor("mallory", "trusted")
	g.AddCapability("effectful")
	g.Holds("mallory", "effectful")
	oMallory = HumanActor("mallory")
	oRL = StzRateLimiter("front")
	oHost = new stzAgentHost()
	oHost.Supervise(new probeAgent("mallory-bot"), 1)

	oCap = StzCapabilityResponder(g)
	oCap.AddLiveActor(oMallory)
	oSet = StzResponderSet([])
	oSet.Add(StzAuthResponder(oAuth))
	oSet.Add(StzSecretStoreResponder(oStore, HumanActor("secrets-service")))
	oSet.Add(oCap)
	oSet.Add(StzRateLimiterResponder(oRL, 0))
	oSet.Add(StzAgentHostResponder(oHost))

	oPlan = StzResponsePlan("contain-everything")
	oPlan.Propose(:LockAccount, "mallory", "stolen credentials")
	oPlan.Propose(:RevokeSession, "mallory", "stolen credentials")
	oPlan.Propose(:RotateSecret, "webhook", "read by the intruder")
	oPlan.Propose(:RevokeCapability, "mallory", "reaches effectful")
	oPlan.Propose(:ShedSource, "203.0.113.7", "the intruder's address")
	oPlan.Propose(:QuarantinePart, "mallory-bot", "the intruder's agent")
	Then("all six actions were committed", oPlan.ExecuteOn(oSet, $oHuman), 6)
	Then(":LockAccount -- the account is locked", oAuth.IsAccountLocked("mallory"), 1)
	Then(":RevokeSession -- the old token is dead", oAuth.IsValidSession(cTok), 0)
	Then(":RotateSecret -- the secret has a new value", oStore.Reveal("webhook", $oHuman) != "whsec_old", 1)
	Then(":RevokeCapability -- no path to effectful, and the live actor lost it",
		g.ReachesEffectful("mallory") = 0 and oMallory.IsEffectful() = 0, 1)
	Then(":ShedSource -- the address is refused", oRL.Allow("203.0.113.7"), 0)
	Then(":QuarantinePart -- the agent is quarantined", oHost.IsQuarantined("mallory-bot"), 1)
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

# a few passes of the host's loop, far apart enough for 1 ms ticks
func Pump oHost
	for i = 1 to 5
		StzEngineTimeSleepMs(3)
		oHost.TickDue()
	next

# the smallest thing a host can supervise: a name and a Cycle()
class probeAgent from stzObject
	@cName = ""
	def init(pcName)
		@cName = "" + pcName
	def Name_()
		return @cName
	def Cycle()
		return 0
