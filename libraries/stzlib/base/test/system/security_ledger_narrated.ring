# The security ledger -- incident analysis I1
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# I0 gave refusals a shape; I1 gives them a memory that is EVIDENCE
# rather than logging: a bounded, hash-chained engine ring where each
# digest includes the previous one, so a retroactive edit breaks the
# chain and Verify() names the first broken link. The chain is computed
# IN THE ENGINE -- a caller able to hand in its own digest could forge
# history. Plus the analyst's pivots, and a keyed export that survives
# the process (evidence-grade means EXPORTED).
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no oR / nL / Try / Show locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

cSealPath = "_tmp_ledger_seal.txt"

pr()

? "-- Scene 1: events go in; the ledger counts and keeps --"
oLed = StzSecurityLedger(64)
oLlm = LLMActor("advisor")
oLed.Record(StzSecurityRefusal("secret.reveal.refused", oLlm, "secret:stripe-live", "actor is not effectful"))
oLed.Record(StzSecurityRefusal("sig.nonce.replayed", HumanActor("peer-3"), "key:billing", "nonce already used"))
oLed.Record(StzSecurityGrant("secret.reveal.granted", HumanActor("mansour"), "secret:stripe-live"))
chk("three events recorded", oLed.Count() = 3)
chk("three retained (capacity 64)", oLed.Size() = 3)
aFirst = oLed.At(1)
chk("the record round-trips its kind", aFirst[:kind] = "secret.reveal.refused")
chk("...its actor and posture", aFirst[:actor] = "advisor" and aFirst[:posture] = "sandboxed")
chk("...its reason, the gate's own words", aFirst[:reason] = "actor is not effectful")
chk("...and its wall clock", aFirst[:atWall] > 1577836800000)

? ""
? "-- Scene 2: every entry carries a digest that includes the last --"
c1 = oLed.DigestAt(1)
c2 = oLed.DigestAt(2)
chk("digests are sha256 hex (64 chars)", len(c1) = 64 and len(c2) = 64)
chk("consecutive digests differ", c1 != c2)
chk("the head digest is the newest entry's", oLed.Digest() = oLed.DigestAt(3))
aV = oLed.Verify()
chk("a freshly built chain verifies intact", aV[:intact] and aV[:brokenAt] = 0)

? ""
? "-- Scene 3: the chain commits to HISTORY, not just to entries --"
# Two ledgers whose LAST event is identical but whose past differs must
# not agree -- that is what makes the head digest a commitment.
oA = StzSecurityLedger(16)
oB = StzSecurityLedger(16)
oA.Record(StzSecurityRefusal("auth.login.failed", HumanActor("admin"), "user:admin", "bad password"))
oB.Record(StzSecurityRefusal("auth.login.failed", HumanActor("admin"), "user:admin", "bad PASSWORD"))
oSame = StzSecurityRefusal("sig.signature.forged", HumanActor("peer-9"), "key:x", "mismatch")
oA.Record(oSame)
oB.Record(oSame)
chk("same last event, different history -> different head digest", oA.Digest() != oB.Digest())
oA.Destroy()
oB.Destroy()

? ""
? "-- Scene 4: the analyst's pivots --"
chk("OfActor finds the sandboxed actor's refusal", len(oLed.OfActor("advisor")) = 1)
chk("OfSubject gathers everything about one secret", len(oLed.OfSubject("secret:stripe-live")) = 2)
chk("OfKind selects by catalog kind", len(oLed.OfKind("sig.nonce.replayed")) = 1)
chk("OfOutcome separates grants from refusals", len(oLed.OfOutcome("granted")) = 1)
chk("Refusals() is the signal to watch", len(oLed.Refusals()) = 2)
# the catalog decides severity: two refusals are errors, the GRANT is info
chk("OfSeverity picks the errors, and a grant is not one", len(oLed.OfSeverity("error")) = 2 and len(oLed.OfSeverity("info")) = 1)
chk("Since() takes a time window", len(oLed.Since(1577836800000)) = 3 and len(oLed.Since(4102444800000)) = 0)

? ""
? "-- Scene 5: correlation -- the trace id ties events to logs --"
StzOpenTraceScope("")
cTid = StzCurrentTraceId()
oLog = new stzLog("api")
oLed.Record(StzSecurityRefusal("http.request.unauthorized", HumanActor("peer-3"), "route:/pay", "signature envelope missing"))
oLog.Warn("rejected an unsigned request")
StzCloseTraceScope()
chk("the event carried the scope's trace id into the ledger", len(oLed.OfTrace(cTid)) = 1)
chk("...the same id the log line carries (one story, two stores)", len(oLog.OfTrace(cTid)) = 1)

? ""
? "-- Scene 6: bounded means forgetting, and it says so --"
oSmall = StzSecurityLedger(3)
for i = 1 to 5
	oSmall.Record(StzSecurityRefusal("auth.login.failed", HumanActor("u" + i), "user:u" + i, "bad password"))
next
chk("Count() remembers all five", oSmall.Count() = 5)
chk("Size() retains only three", oSmall.Size() = 3)
chk("the survivors are the newest", oSmall.At(1)[:actor] = "u3")
chk("the evicted window still verifies (a window property)", oSmall.Verify()[:intact])
chk("...and the head digest still commits to ALL five", len(oSmall.Digest()) = 64)
oSmall.Destroy()

? ""
? "-- Scene 7: a Ring COPY records into the SAME evidence --"
oCopy = oLed
oCopy.Record(StzSecurityRefusal("capability.refused", oLlm, "op:write", "actor is not effectful"))
chk("the original face sees the copy's event (engine truth)", oLed.Count() = 5)
chk("...and the chain is still intact across faces", oLed.Verify()[:intact])

? ""
? "-- Scene 8: SEALED EXPORT -- and what happens when someone edits it --"
oLed.SealTo(cSealPath, "the-evidence-key")
chk("the sealed file exists", fexists(cSealPath))
aVer = StzVerifySealedLedger(cSealPath, "the-evidence-key")
? "  " + aVer[:why]
chk("a fresh export verifies", aVer[:ok] and aVer[:count] = 5)

# an auditor with the wrong key: the chain is fine, the seal is not
aWrong = StzVerifySealedLedger(cSealPath, "not-the-key")
chk("a wrong key is caught by the seal", NOT aWrong[:ok] and StzFindFirst("SEAL does not match", aWrong[:why]) > 0)

# now EDIT the evidence, the way an attacker would
cRaw = read(cSealPath)
cEdited = StzReplace(cRaw, "actor is not effectful", "routine maintenance")
write(cSealPath, cEdited)
aTamp = StzVerifySealedLedger(cSealPath, "the-evidence-key")
? "  " + aTamp[:why]
chk("the edit is DETECTED", NOT aTamp[:ok])
chk("...and the broken link is named", aTamp[:brokenAt] > 0)
remove(cSealPath)

? ""
? "-- Scene 9: a pipe in a reason cannot shift the fields --"
oPipe = StzSecurityLedger(8)
oPipe.Record(StzSecurityRefusal("sso.token.rejected", HumanActor("idp"), "token:abc",
	"issuer mismatch: got a|b|c wanted d"))
aP = oPipe.At(1)
chk("the reason survived (pipes folded, fields intact)", aP[:kind] = "sso.token.rejected" and aP[:outcome] = "refused")
chk("...and the wall clock is still a number, not a fragment", aP[:atWall] > 1577836800000)
oPipe.Destroy()

? ""
? "-- Scene 10: it explains itself --"
oLed.Show()
aL = oLed.Explain()
chk("the header states count, retention and chain state", StzFindFirst("chain intact", aL[1]) > 0)
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
