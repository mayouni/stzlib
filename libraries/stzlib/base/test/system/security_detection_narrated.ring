# Detection over sequences -- incident analysis I3
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# Every rule the library owns judges STRUCTURE AT ONE INSTANT. An
# incident is a STORY: five failures inside a minute, or a failure
# followed by a reach for a secret. I3 adds the missing shape -- three
# of them, deliberately few: BURST, SEQUENCE, ANY -- and their verdicts
# are findings in the unified rule shape, so a detection can fail the
# same CI gate as a capability violation.
#
# Events are recorded with EXPLICIT wall clocks (RecordAt-style through
# a crafted event) so the windows are exact and the guard cannot flake
# on machine speed.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nT0 = 1785500000000    # a fixed wall base, so windows are deterministic

pr()

? "-- Scene 1: the grammar reads like the story it looks for --"
oD = StzDetection("credential-stuffing")
oD.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)
oD.Explaining("repeated authentication failures against one account")
chk("the detection knows its shape", oD.Shape() = "burst")
chk("...and what it watches", oD.Kind() = "auth.login.failed")
oD.Show()
bRaised = FALSE
try
	oBad = StzDetection("empty")
	oBad.CheckAgainst(StzSecurityLedger(8))
catch
	bRaised = TRUE
done
chk("a detection that watches nothing refuses to judge", bRaised)

? ""
? "-- Scene 2: BURST -- five failures in a minute, per account --"
oLed = StzSecurityLedger(256)
# four failures for 'admin' spread over 90s: NOT a burst
for i = 1 to 4
	oLed.Record(BuildEvent("auth.login.failed", "admin", "user:admin", nT0 + (i * 30000)))
next
aF = oD.CheckAgainst(oLed)
chk("four failures spread over 90s do not fire", len(aF) = 0)

# five for 'victim' inside 20s: a burst
for i = 1 to 5
	oLed.Record(BuildEvent("auth.login.failed", "victim", "user:victim", nT0 + 200000 + (i * 4000)))
next
aF = oD.CheckAgainst(oLed)
chk("five failures inside 20s fire exactly one finding", len(aF) = 1)
chk("...naming the account, not the installation", StzFindFirst("victim", aF[1][:where]) > 0)
chk("...in the unified rule shape", aF[1][:subject] = "security" and aF[1][:rule] = "credential-stuffing")
chk("...at error severity", aF[1][:severity] = "error")
? "  " + aF[1][:message]
chk("...with the meaning attached", StzFindFirst("repeated authentication failures", aF[1][:message]) > 0)
chk("the evidence is kept for the incident to come", len(oD.LastEvidence()) = 5)

? ""
? "-- Scene 3: PER ACTOR really means per actor --"
oNoGroup = StzDetection("any-five-failures")
oNoGroup.WhenKind("auth.login.failed").Repeats(5).Within(600000)
aF2 = oNoGroup.CheckAgainst(oLed)
chk("ungrouped, the nine failures across two accounts fire once", len(aF2) = 1)
chk("...and the grouped one still separates them", len(oD.CheckAgainst(oLed)) = 1)

? ""
? "-- Scene 4: SEQUENCE -- a failure THEN a reach for a secret --"
oSeq = StzDetection("guess-then-reach")
oSeq.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
oSeq.BySameActor().Within(300000)
oSeq.Explaining("the classic shape of a stolen-credential attempt")
aF3 = oSeq.CheckAgainst(oLed)
chk("no reach yet, so no story", len(aF3) = 0)
oLed.Record(BuildEvent("secret.reveal.refused", "victim", "secret:stripe-live", nT0 + 260000))
aF3 = oSeq.CheckAgainst(oLed)
chk("the sequence fires once the second act arrives", len(aF3) >= 1)
? "  " + aF3[1][:message]
chk("...naming the actor that did both", StzFindFirst("victim", aF3[1][:where]) > 0)

# a different actor doing the second act does NOT complete the story
oLed.Record(BuildEvent("secret.reveal.refused", "someone-else", "secret:other", nT0 + 270000))
nBefore = len(aF3)
aF4 = oSeq.CheckAgainst(oLed)
chk("BySameActor() refuses to join two unrelated actors", len(aF4) = nBefore)

? ""
? "-- Scene 4b: one story, one finding (alert fatigue is a defect) --"
# 'victim' has FIVE failed logins before the secret reach, so five
# pairs match -- but that is one story. The detection reports it once
# per actor. (The first cut reported five; the demo caught it.)
aF3b = oSeq.CheckAgainst(oLed)
nForVictim = 0
for i = 1 to len(aF3b)
	if StzFindFirst("victim", aF3b[i][:where]) > 0
		nForVictim++
	ok
next
chk("five matching pairs report ONE finding for that actor", nForVictim = 1)

? ""
? "-- Scene 5: the window is a real boundary --"
oTight = StzDetection("tight-window")
oTight.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
oTight.BySameActor().Within(1000)
chk("the same two acts, 40s apart, fall outside a 1s window", len(oTight.CheckAgainst(oLed)) = 0)

? ""
? "-- Scene 6: ANY -- one occurrence is already the story --"
oAny = StzDetection("cloned-authenticator")
oAny.WhenKind("auth.passkey.clone_suspected").OnAnyOccurrence()
oAny.Explaining("a signature counter that did not advance")
chk("nothing yet", len(oAny.CheckAgainst(oLed)) = 0)
oLed.Record(BuildEvent("auth.passkey.clone_suspected", "softanza.dev", "credential:7", nT0 + 300000))
aF5 = oAny.CheckAgainst(oLed)
chk("one occurrence fires", len(aF5) = 1)
chk("...at the severity the detection declares", aF5[1][:severity] = "error")

? ""
? "-- Scene 7: THE CORROBORATION LAW -- one signal is a rumor --"
oCorr = StzDetection("lonely-signal")
oCorr.WhenKind("auth.passkey.clone_suspected").OnAnyOccurrence().Corroborated()
aF6 = oCorr.CheckAgainst(oLed)
chk("a single-kind match is DOWNGRADED to warning", aF6[1][:severity] = "warning")
chk("...and says why, instead of pretending", StzFindFirst("single signal", aF6[1][:message]) > 0)

oCorr2 = StzDetection("two-signals")
oCorr2.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
oCorr2.BySameActor().Within(300000).Corroborated()
aF7 = oCorr2.CheckAgainst(oLed)
chk("a match spanning two kinds keeps error severity", aF7[1][:severity] = "error")

? ""
? "-- Scene 8: the set, and the house detection content --"
oSet = StzDefaultDetectionSet()
? "  the library ships " + oSet.NumberOfDetections() + " detections over its own catalog"
chk("the default set is real content, not a placeholder", oSet.NumberOfDetections() >= 8)
chk("...and each is retrievable by name", oSet.DetectionQ("credential-stuffing").Kind() = "auth.login.failed")
aFired = oSet.FiredNames(oLed)
? "  fired on this ledger: " + len(aFired) + " -- " + aFired[1]
chk("the set fires on the ledger we built", len(aFired) >= 3)
chk("...including the sequence one", ring_find(aFired, "guess-then-reach") > 0)

? ""
? "-- Scene 9: a detection can fail the SAME CI gate as a security rule --"
oRep = new stzRuleReport("ci")
oRep.Ingest(oSet.CheckAgainst(oLed))
chk("the report took the findings without an adapter", oRep.NumberOfFindings() >= 3)
chk("they arrive under the security subject", len(oRep.FindingsOfSubject("security")) >= 3)
chk("the gate is UNSOUND -- a detection fails the build", NOT oRep.IsSound())
? "  " + oRep.Explain()[1]

? ""
? "-- Scene 10: judging a quiet ledger says nothing, loudly --"
oQuiet = StzSecurityLedger(16)
oQuiet.Record(BuildEvent("secret.reveal.granted", "mansour", "secret:stripe-live", nT0))
chk("a quiet ledger produces no findings", len(oSet.CheckAgainst(oQuiet)) = 0)
oRep2 = new stzRuleReport("ci-quiet")
oRep2.Ingest(oSet.CheckAgainst(oQuiet))
chk("...and the gate stays sound", oRep2.IsSound())
oQuiet.Destroy()
oLed.Destroy()

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

# An event with an EXPLICIT wall clock, so window arithmetic in the
# guard is exact rather than dependent on how fast the machine runs.
func BuildEvent cKind, cActor, cSubject, nWall
	oE = StzSecurityEvent(cKind)
	oE.ByActorNamed(cActor, "external")
	oE.About(cSubject)
	oE.Refused("(scripted for the guard)")
	oE.OccurredAt(nWall)
	return oE
