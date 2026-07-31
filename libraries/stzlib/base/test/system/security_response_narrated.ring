# The governed response -- incident analysis I6
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# The last verb, and the only one that touches reality. Containment is
# a PLAN: anyone may compose it -- including the inference-only agent
# that just finished the investigation -- and only an effectful,
# non-sandboxed actor may commit it. Every outcome is audited AND
# recorded in the ledger, so the response sits beside the attack in
# the same hash chain.
#
# The plan executes against a rehearsal DOUBLE (the
# service-virtualization pattern): the crossing is provable without
# revoking anything real.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS; class defined after the funcs.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nT0 = 1785800000000

pr()

? "-- Scene 1: the catalog is closed --"
oPlan = StzResponsePlan("contain-1")
oPlan.Propose(:LockAccount, "billing-agent", "five failed logins")
chk("a catalogued action is accepted", oPlan.NumberOfActions() = 1)
bRaised = FALSE
try
	oPlan.Propose(:DeleteAllTheirData, "billing-agent", "revenge")
catch
	bRaised = TRUE
done
chk("an action outside the catalog refuses, with the catalog", bRaised)

? ""
? "-- Scene 2: an incident PROPOSES its own containment --"
StzOpenSecurityLedger(512)
oLed = StzSecurityLedgerQ()
for i = 1 to 5
	oLed.Record(BuildE("auth.login.failed", "billing-agent", "user:admin", nT0 + (i * 4000)))
next
oLed.Record(BuildE("secret.reveal.refused", "billing-agent", "secret:stripe-live", nT0 + 30000))
oSent = StzSecuritySentinel(StzDefaultDetectionSet()).Watching(oLed)
oSent.SetChannels("i6.detect", "i6.clear")
oSent.Check()

oG = new stzSecurityGraph("prod")
oG.AddActor("billing-agent", "external")
oG.AddTool("deploy-tool")
oG.AddCapability("effectful")
oG.AddSecret("stripe-live")
oG.Uses("billing-agent", "deploy-tool")
oG.Grants("deploy-tool", "effectful")

oInc = StzIncidentFromCase("INC-9", oSent.LastCase(), oLed)
oInc.WithGraph(oG)

oResp = StzResponsePlan("contain-INC-9")
oResp.ProposeForIncident(oInc)
oResp.Show()
chk("the plan derived actions from the incident's own facts", oResp.NumberOfActions() = 4)
aA = oResp.Actions()
chk("...locking the account it names", aA[1][1] = "lockaccount" and aA[1][2] = "billing-agent")
chk("...revoking its sessions", aA[2][1] = "revokesession")
chk("...revoking the capability, because the graph says it can reach effectful", aA[3][1] = "revokecapability")
chk("...and rotating the secret it reached for", aA[4][1] = "rotatesecret" and aA[4][2] = "stripe-live")
chk("every action carries the incident's own rationale", StzFindFirst("INC-9", aA[1][3]) > 0)

? ""
? "-- Scene 3: the LLM may propose -- and may NEVER commit --"
oLlm = LLMActor("advisor")
oHuman = HumanActor("mansour")
oFake = new FakeResponder
chk("preflight refuses the inference-only actor", NOT oResp.MayCommit(oLlm))
chk("...and says why in words", StzFindFirst("not effectful", oResp.WhyNot(oLlm)) > 0)
chk("preflight admits the effectful human", oResp.MayCommit(oHuman))

nDone = oResp.ExecuteOn(oFake, oLlm)
chk("the LLM's execution commits NOTHING", nDone = 0)
chk("...the responder was never touched", oFake.CallCount() = 0)
chk("...and all four actions were audited REFUSED", oResp.RefusedCount() = 4)
chk("the refusals reached the LEDGER too", len(oLed.OfKind("response.action.refused")) = 4)

? ""
? "-- Scene 4: the effectful actor commits -- in order, audited --"
nDone = oResp.ExecuteOn(oFake, oHuman)
chk("all four actions committed", nDone = 4)
chk("the responder received them in the proposed order",
	oFake.Calls()[1][1] = "lockaccount" and oFake.Calls()[4][1] = "rotatesecret")
chk("...naming the right targets", oFake.Calls()[4][2] = "stripe-live")
chk("the audit holds both verdicts (4 refused + 4 committed)",
	oResp.RefusedCount() = 4 and oResp.CommittedCount() = 4)
chk("the plan knows it crossed", oResp.WasExecuted())

? ""
? "-- Scene 5: the response is IN the story, not beside it --"
chk("each committed action became a ledger event", len(oLed.OfKind("response.action.committed")) = 4)
chk("...naming the actor who committed it", oLed.OfKind("response.action.committed")[1][:actor] = "mansour")
chk("the chain covers attack AND response", oLed.Verify()[:intact])
? "  the ledger now holds " + oLed.Count() + " event(s): the attack, the refusals, the containment"
chk("no detection watches response kinds (no feedback loop)",
	ring_find(StzDefaultDetectionSet().Names(), "response.action.committed") = 0)

? ""
? "-- Scene 6: the incident records that it was contained --"
oInc.Contain("locked, revoked, rotated (plan contain-INC-9)")
chk("the incident moved forward", oInc.Status() = "contained")
oInc.Close("no data left the process; the reach was refused at the gate")
chk("...and closed", oInc.IsClosed())

? ""
? "-- Scene 7: the full circle, in one sentence each --"
? "  1. the seams witnessed  : " + len(oLed.Refusals()) + " refusal(s) recorded"
? "  2. a detection judged   : " + oInc.Rule()
? "  3. the incident said HOW: " + oInc.AttackPath()[1] + " -> ... -> " + oInc.AttackPath()[len(oInc.AttackPath())]
? "  4. the machine proposed : " + oResp.NumberOfActions() + " containment action(s)"
? "  5. a human committed    : " + oResp.CommittedCount() + ", audited and ledgered"
chk("the circle closed with the LLM never committing anything", oResp.RefusedCount() = 4 and oFake.CallCount() = 4)

StzCloseSecurityLedger()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func BuildE cKind, cActor, cSubject, nWall
	oE = StzSecurityEvent(cKind)
	oE.ByActorNamed(cActor, "external")
	oE.About(cSubject)
	oE.Refused("(scripted for the guard)")
	oE.OccurredAt(nWall)
	return oE

# The rehearsal double: any object answering the catalog's verbs
# qualifies (the service-virtualization pattern).
class FakeResponder
	aRespCalls = []

	def RevokeSession(pcTarget)
		aRespCalls + [ "revokesession", pcTarget ]

	def LockAccount(pcTarget)
		aRespCalls + [ "lockaccount", pcTarget ]

	def RotateSecret(pcTarget)
		aRespCalls + [ "rotatesecret", pcTarget ]

	def RevokeCapability(pcTarget)
		aRespCalls + [ "revokecapability", pcTarget ]

	def ShedSource(pcTarget)
		aRespCalls + [ "shedsource", pcTarget ]

	def QuarantinePart(pcTarget)
		aRespCalls + [ "quarantinepart", pcTarget ]

	def Calls()
		return aRespCalls

	def CallCount()
		return ring_len(aRespCalls)
