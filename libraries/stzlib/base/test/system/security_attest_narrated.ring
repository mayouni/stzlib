# Attestation and export -- incident analysis I7
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# I1 made the ledger hash-chained and sealable -- tamper-EVIDENT. I7
# adds what an auditor needs beside the file (who exported it, when,
# over what range, under which key, and how to check it), and the
# handshake that lets the rest of the world read what this system
# knows: OCSF events, an OCSF finding for the incident, and the OTLP
# logs envelope.
#
# GOVERNED: the ledger names actors, subjects, origins and refusals --
# a map of what is worth attacking. Exporting it requires SENSING, so
# an inference-only actor may analyze in-process and may not write the
# evidence out.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nT0 = 1785900000000
cFile = "_tmp_attested.stzledger"

pr()

? "-- Scene 1: a ledger worth exporting --"
StzOpenSecurityLedger(512)
oLed = StzSecurityLedgerQ()
for i = 1 to 5
	oLed.Record(BuildX("auth.login.failed", "billing-agent", "user:admin", nT0 + (i * 4000)))
next
oLed.Record(BuildX("secret.reveal.refused", "billing-agent", "secret:stripe-live", nT0 + 30000))
chk("six events recorded", oLed.Count() = 6)

? ""
? "-- Scene 2: OCSF, the SIEM handshake, in batch --"
cNd = oLed.ToOcsfNdJson()
aLines = StzSplit(ring_trim(cNd), Char(10))
chk("newline-delimited: one OCSF event per line", len(aLines) = 6)
chk("...each a complete OCSF record", StzFindFirst('"class_uid"', aLines[1]) > 0)
chk("...carrying the house facts in unmapped", StzFindFirst('"kind":"auth.login.failed"', aLines[1]) > 0)
cArr = oLed.ToOcsfJson()
chk("the array form is one JSON document", StzLeft(cArr, 1) = "[" and StzRight(cArr, 1) = "]")
chk("no secret VALUE in the export (the redaction law, at the door)", StzFindFirst("sk_live", cArr) = 0)

? ""
? "-- Scene 3: OTLP logs -- security events beside the log lines --"
cOtlp = oLed.ToOtelLogsJson()
chk("the resourceLogs envelope is there", StzFindFirst('"resourceLogs"', cOtlp) > 0)
chk("...named for the security scope", StzFindFirst('"softanza.security"', cOtlp) > 0)
chk("...with OTLP severity numbers (error = 17)", StzFindFirst('"severityNumber":17', cOtlp) > 0)
chk("...and the actor as an attribute", StzFindFirst('{"key":"actor","value":{"stringValue":"billing-agent"}}', cOtlp) > 0)

? ""
? "-- Scene 4: the incident as an OCSF FINDING (class 2001) --"
oSent = StzSecuritySentinel(StzDefaultDetectionSet()).Watching(oLed)
oSent.SetChannels("i7.detect", "i7.clear")
oSent.Check()
oG = new stzSecurityGraph("prod")
oG.AddActor("billing-agent", "external")
oG.AddTool("deploy-tool")
oG.AddCapability("effectful")
oG.Uses("billing-agent", "deploy-tool")
oG.Grants("deploy-tool", "effectful")
oInc = StzIncidentFromCase("INC-7", oSent.LastCase(), oLed)
oInc.WithGraph(oG)
cF = oInc.ToOcsfFindingJson()
chk("it is a Security Finding, not a raw event", StzFindFirst('"category_uid":2,"class_uid":2001', cF) = 2)
chk("...carrying the incident id", StzFindFirst('"uid":"INC-7"', cF) > 0)
chk("...the attack path a reviewer needs", StzFindFirst('"attackPath":["billing-agent"', cF) > 0)
chk("...the implicated secret, by name only", StzFindFirst('"secrets":["stripe-live"]', cF) > 0)
chk("...and the chain head it fired on", StzFindFirst('"headDigest"', cF) > 0)

? ""
? "-- Scene 5: exporting the evidence is GOVERNED --"
oAtt = StzSecurityAttestation("nightly-evidence")
oAtt.Of(oLed).SealedWith("the-evidence-key")
oLlm = LLMActor("advisor")
oHuman = HumanActor("mansour")
chk("the inference-only actor may not export the evidence", NOT oAtt.MayAttest(oLlm))
chk("...and is told why", StzFindFirst("lacks the sensing capability", oAtt.WhyNot(oLlm)) > 0)
chk("a guardian (compute+sensing) MAY -- reading out is sensing, not effect",
	oAtt.MayAttest(GuardianActor("auditor")))
chk("the effectful human may too", oAtt.MayAttest(oHuman))

bWrote = oAtt.WriteTo(cFile, oLlm)
chk("the LLM's export wrote nothing", NOT bWrote and NOT fexists(cFile))
chk("...and the refusal is in the ledger", len(oLed.OfKind("evidence.export_refused")) = 1)

? ""
? "-- Scene 6: the custody statement, beside a file that proves itself --"
bWrote = oAtt.WriteTo(cFile, oHuman)
chk("the human's export wrote the file", bWrote and fexists(cFile))
chk("...and the export is itself an event", len(oLed.OfKind("evidence.exported")) = 1)
oAtt.Show()
cStmt = oAtt.Statement()
chk("the statement names the attestor", StzFindFirst("mansour", cStmt) > 0)
chk("...the entry count and chain head", StzFindFirst("chain head:", cStmt) > 0)
chk("...the seal in words", StzFindFirst("HMAC-SHA256", cStmt) > 0)
chk("...how to verify it", StzFindFirst("StzVerifyAttestation", cStmt) > 0)
chk("...and that no secret value can be in it", StzFindFirst("DESCRIPTORS", cStmt) > 0)

? ""
? "-- Scene 7: the file verifies, and names who attested it --"
aV = StzVerifyAttestation(cFile, "the-evidence-key")
? "  " + aV[:why]
chk("the chain verifies", aV[:ok])
chk("...over the exported entries", aV[:count] >= 6)
chk("the verifier reports the ATTESTOR from the file", aV[:attestor] = "mansour")
chk("...and when it was attested", aV[:attestedAt] > 1577836800000)

aW = StzVerifyAttestation(cFile, "wrong-key")
chk("a wrong key is still caught", NOT aW[:ok] and StzFindFirst("SEAL does not match", aW[:why]) > 0)

cRaw = read(cFile)
write(cFile, StzReplace(cRaw, "billing-agent", "someone-harmless"))
aT = StzVerifyAttestation(cFile, "the-evidence-key")
? "  " + aT[:why]
chk("editing the attested evidence is DETECTED", NOT aT[:ok] and aT[:brokenAt] > 0)
remove(cFile)

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

func BuildX cKind, cActor, cSubject, nWall
	oE = StzSecurityEvent(cKind)
	oE.ByActorNamed(cActor, "external")
	oE.About(cSubject)
	oE.Refused("(scripted for the guard)")
	oE.OccurredAt(nWall)
	return oE
