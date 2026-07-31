# The incident -- incident analysis I5 (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# A sentinel case says WHAT fired. An incident is what an investigator
# reads: the correlated story in wall order, the actors and subjects,
# the PATH the actor could have taken (from the security graph, which
# has answered reachability since the graph-rules plan), the blast
# radius of any secret named, the trace ids that fetch the log lines,
# and a forward-only status as the response happens.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nT0 = 1785700000000

pr()

? "-- Scene 1: an attack, then a reach for a secret --"
oLed = StzSecurityLedger(256)
for i = 1 to 5
	oLed.Record(BuildEv("auth.login.failed", "billing-agent", "user:admin", nT0 + (i * 4000), ""))
next
oLed.Record(BuildEv("secret.reveal.refused", "billing-agent", "secret:stripe-live", nT0 + 30000, ""))
oSet = StzDefaultDetectionSet()
oSent = StzSecuritySentinel(oSet).Watching(oLed).SetChannels("i5.detect", "i5.clear")
nFired = oSent.Check()
? "  the sentinel fired " + nFired + " time(s)"
chk("both stories fired (the burst and the sequence)", nFired = 2)

? ""
? "-- Scene 2: a case becomes a case FILE --"
oInc = StzIncidentFromCase("INC-1", oSent.LastCase(), oLed)
chk("the incident carries its id and rule", oInc.Id() = "INC-1" and oInc.Rule() != "")
chk("...the actor the story is about", oInc.Actor() = "billing-agent")
chk("...and its severity", oInc.Severity() = "error")
chk("it correlated the actor's whole story, not just the trigger", oInc.NumberOfEvents() = 6)
chk("the timeline is wall-ordered", oInc.Timeline()[1][1] <= oInc.Timeline()[6][1])
chk("...and starts at the first failure", oInc.Timeline()[1][2] = "auth.login.failed")
chk("...and ends at the secret reach", oInc.Timeline()[6][2] = "secret.reveal.refused")
chk("the subjects name what was touched", len(oInc.Subjects()) = 2)
chk("the implicated secret is identified by DESCRIPTOR", len(oInc.SecretsInvolved()) = 1 and oInc.SecretsInvolved()[1] = "stripe-live")
chk("it kept the chain head from the moment of firing", len(oInc.HeadDigest()) = 64)

? ""
? "-- Scene 3: correlation follows the TRACE, not just the actor --"
oLed2 = StzSecurityLedger(64)
StzOpenTraceScope("")
cTid = StzCurrentTraceId()
oLed2.Record(BuildEv("http.request.unauthorized", "peer-9", "route:/pay", nT0, cTid))
oLed2.Record(BuildEv("sig.nonce.replayed", "someone-else", "key:billing", nT0 + 100, cTid))
StzCloseTraceScope()
for i = 1 to 5
	oLed2.Record(BuildEv("auth.login.failed", "peer-9", "user:root", nT0 + 1000 + (i * 1000), ""))
next
oSent2 = StzSecuritySentinel(StzDefaultDetectionSet()).Watching(oLed2)
oSent2.SetChannels("i5b.detect", "i5b.clear")
oSent2.Check()
oInc2 = StzIncidentFromCase("INC-2", oSent2.LastCase(), oLed2)
chk("a DIFFERENT actor's event joined the story via the shared trace", ring_find(oInc2.Actors(), "someone-else") > 0)
chk("...and the trace id is reported for the log query", len(oInc2.TraceIds()) = 1 and oInc2.TraceIds()[1] = cTid)

? ""
? "-- Scene 4: the graph answers HOW FAR the actor could reach --"
oG = new stzSecurityGraph("prod")
oG.AddActor("billing-agent", "external")
oG.AddTool("deploy-tool")
oG.AddCapability("effectful")
oG.AddSecret("stripe-live")
oG.AddStore("keyring")
oG.AddSite("checkout-site")
oG.Uses("billing-agent", "deploy-tool")
oG.Grants("deploy-tool", "effectful")
oG.StoredIn("stripe-live", "keyring")
oG.References("checkout-site", "stripe-live")
oInc.WithGraph(oG)
chk("the actor DOES reach an effectful capability", oInc.ReachesEffectful())
aPath = oInc.AttackPath()
? "  path: " + aPath[1] + " -> " + aPath[2] + " -> " + aPath[3]
chk("the PATH itself is reported, not just a yes", len(aPath) = 3)
chk("...starting at the actor and ending at the capability", aPath[1] = "billing-agent" and aPath[3] = "effectful")

aBlast = oInc.BlastRadius()
chk("the implicated secret's blast radius is computed", len(aBlast) = 1)
? "  blast radius of " + aBlast[1][1] + ": " + len(aBlast[1][2]) + " node(s)"
chk("...and it names the site that references the secret", ring_find(aBlast[1][2], "checkout-site") > 0)

oQuiet = new stzSecurityGraph("quiet")
oQuiet.AddActor("billing-agent", "external")
oQuiet.AddCapability("effectful")
oInc3 = StzIncidentFromCase("INC-3", oSent.LastCase(), oLed)
oInc3.WithGraph(oQuiet)
chk("an actor with no route reports NO path (not a false alarm)", len(oInc3.AttackPath()) = 0)

? ""
? "-- Scene 5: status moves forward, and only forward --"
chk("a fresh incident is open", oInc.IsOpen() and oInc.Status() = "open")
oInc.Contain("revoked the agent's session and rotated the key")
chk("containment is recorded", oInc.Status() = "contained")
bRaised = FALSE
try
	oInc.Contain("again")
catch
	bRaised = TRUE
done
chk("...and cannot be repeated (forward-only)", bRaised)
oInc.Close("credentials rotated; the reach was refused, nothing left the process")
chk("closing lands", oInc.IsClosed())
bRaised = FALSE
try
	oInc.Close("reopen")
catch
	bRaised = TRUE
done
chk("a closed incident refuses to reopen (that is a NEW incident)", bRaised)
chk("both notes were kept", len(oInc.Notes()) = 2)

? ""
? "-- Scene 6: the file a person reads --"
oInc.Show()
aL = oInc.Explain()
chk("the header states id, severity, status and actor", StzFindFirst("INC-1", aL[1]) > 0 and StzFindFirst("billing-agent", aL[1]) > 0)
cJoinedText = ""
for i = 1 to len(aL)
	cJoinedText += (aL[i] + " ")
next
chk("the account includes the attack path", StzFindFirst("Attack path:", cJoinedText) > 0)
chk("...the blast radius", StzFindFirst("Blast radius", cJoinedText) > 0)
chk("...and the response notes", StzFindFirst("rotated", cJoinedText) > 0)
chk("no secret VALUE anywhere in the account", StzFindFirst("sk_live", cJoinedText) = 0)

? ""
? "-- Scene 7: the incident detects a rewritten history --"
cHeadThen = oInc.HeadDigest()
oLed.Record(BuildEv("auth.login.failed", "billing-agent", "user:admin", nT0 + 90000, ""))
chk("the ledger moved on, so its head differs from the incident's", oLed.Digest() != cHeadThen)
chk("...but the incident still holds the head it fired on", oInc.HeadDigest() = cHeadThen)
oLed.Destroy()
oLed2.Destroy()

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

func BuildEv cKind, cActor, cSubject, nWall, cTrace
	oE = StzSecurityEvent(cKind)
	oE.ByActorNamed(cActor, "external")
	oE.About(cSubject)
	oE.Refused("(scripted for the guard)")
	oE.OccurredAt(nWall)
	return oE
