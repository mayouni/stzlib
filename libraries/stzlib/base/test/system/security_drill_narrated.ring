# The drill -- incident analysis I8, the last phase
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# A detection nobody has ever seen fire is a hypothesis. This guard
# spawns a REAL application -- its own ledger, its own stzAuth, its own
# signed-request gate -- attacks it over REAL HTTP from another
# process, and then learns what happened the way an investigator
# would: from a SEALED, ATTESTED file it must verify before it may
# believe it.
#
# TIMED and heavier than its siblings (real processes, ~10-20s).
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nSuite0 = StzEngineWatchTimestampMs()

pr()

? "-- Scene 1: a real application, spawned and listening --"
oDrill = StzSecurityDrill("nightly")
bUp = oDrill.SpawnTarget(0)
chk("the target came up on its own port", bUp)
? "  target on 127.0.0.1:" + oDrill.Port()

? ""
? "-- Scene 2: three real attacks over real HTTP --"
oDrill.FireCredentialStuffing("victim", 5)
oDrill.FireForgery()
oDrill.FireReplay()
chk("three attacks were fired, each with an expectation", len(oDrill.Expectations()) = 3)

? ""
? "-- Scene 3: the evidence crosses the boundary, sealed --"
bGot = oDrill.CollectEvidence()
? "  " + oDrill.AcquisitionWhy()
chk("the target sealed its ledger and the parent VERIFIED it", bGot)
chk("...the file names who attested it", oDrill.Attestor() = "target-process")
oAcq = oDrill.AcquiredLedger()
chk("...and a working ledger was rebuilt from verified evidence", oAcq.Count() >= 8)
chk("the parent learned this WITHOUT touching the target's memory", fexists(oDrill.EvidencePath()))

? ""
? "-- Scene 4: the detections fired on evidence from another process --"
aFired = oDrill.FiredDetections()
? "  fired: " + len(aFired) + " detection(s)"
chk("credential stuffing was detected", ring_find(aFired, "credential-stuffing") > 0)
chk("the forged signature was detected", ring_find(aFired, "forged-request") > 0)
chk("the replayed nonce was detected", ring_find(aFired, "replayed-request") > 0)
chk("every expected detection fired -- the drill PASSES", oDrill.Passed())
chk("...and nothing was missed", len(oDrill.MissedDetections()) = 0)

? ""
? "-- Scene 5: the acquired evidence still reconstructs an incident --"
oSent = StzSecuritySentinel(StzDefaultDetectionSet()).Watching(oAcq)
oSent.SetChannels("i8.detect", "i8.clear")
oSent.Check()
oInc = StzIncidentFromCase("INC-DRILL", oSent.LastCase(), oAcq)
chk("an incident builds from the acquired ledger", oInc.NumberOfEvents() > 0)
chk("...naming the actor the attack used", oInc.Actor() != "")
? "  " + oInc.Explain()[1]

? ""
? "-- Scene 6: the report an operator reads --"
oDrill.Show()
aL = oDrill.Explain()
chk("the report states the verdict first", StzFindFirst("every expected detection fired", aL[1]) > 0)
chk("...names the evidence and its attestor", StzFindFirst("attested by target-process", aL[2]) > 0)
chk("...and marks each attack fired", StzFindFirst("[fired]", aL[3]) = 3)

? ""
? "-- Scene 7: tampered evidence is NOT believed --"
cPath = oDrill.EvidencePath()
cRaw = read(cPath)
write(cPath, StzReplace(cRaw, "victim", "nobody"))
aBad = StzLedgerFromSealedFile(cPath, "drill-evidence-key")
? "  " + aBad[:why]
chk("acquisition REFUSES edited evidence", NOT aBad[:ok])
chk("...and hands back no ledger to analyse", aBad[:ledger] = NULL)

oDrill.Destroy()
chk("the drill killed its target and removed the evidence file", NOT fexists(cPath))

nSuiteMs = StzEngineWatchTimestampMs() - nSuite0
? ""
? "  (the drill ran real processes for " + nSuiteMs + " ms)"
chk("the whole drill stayed inside its budget (< 60s)", nSuiteMs < 60000)

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
