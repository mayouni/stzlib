# The seams -- incident analysis I2 (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# The phase that makes the library stop forgetting. Six classes that
# already DETECTED and then discarded now note what they saw: the
# request signer's four attacker signals, the passkey clone indicator,
# SAML replay, the secret store's governed door, the auth failure
# path, and the two gaps that were never audited at all -- scope and
# posture refusals.
#
# The ledger is a PROCESS resource: closed by default, and closed costs
# one boolean test at each seam (the event is not even built). Scene 1
# proves the off state; everything after opens it.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# Try / Show locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: with no ledger open, nothing changes --"
chk("no ledger is open by default", NOT StzSecurityLedgerIsOpen())
chk("the accessor says so honestly", StzSecurityLedgerQ() = NULL)
oSignerOff = new stzRequestSigner("off")
oSignerOff.AddKey("k1", "s3cr3t")
bOff = oSignerOff.VerifyNow("nope", "GET", "/x", "", StzEngineTimeNowMs(), "n1", "sig", 30000)
chk("a refusal still refuses (and still explains)", NOT bOff and oSignerOff.Why() != "")
chk("...and nothing was recorded, because nobody is listening", NOT StzSecurityLedgerIsOpen())

? ""
? "-- Scene 2: open the ledger; the signer's four signals land --"
StzOpenSecurityLedger(512)
chk("the process ledger is open", StzSecurityLedgerIsOpen())
oLed = StzSecurityLedgerQ()

oSigner = new stzRequestSigner("gateway")
oSigner.AddKey("billing", "shared-secret")
nNow = StzEngineTimeNowMs()

# (a) unknown key
oSigner.Verify("ghost", "GET", "/pay", "", nNow, "n1", "deadbeef", 30000, nNow)
# (b) stale timestamp
aEnv = oSigner.Sign("billing", "GET", "/pay", "", nNow - 500000, "n2")
oSigner.Verify("billing", "GET", "/pay", "", nNow - 500000, "n2", aEnv[:sig], 30000, nNow)
# (c) forged signature
oSigner.Verify("billing", "GET", "/pay", "", nNow, "n3", "0000forged0000", 30000, nNow)
# (d) replayed nonce -- sign properly, verify twice
aGood = oSigner.Sign("billing", "GET", "/pay", "", nNow, "n4")
bFirst = oSigner.Verify("billing", "GET", "/pay", "", nNow, "n4", aGood[:sig], 30000, nNow)
bSecond = oSigner.Verify("billing", "GET", "/pay", "", nNow, "n4", aGood[:sig], 30000, nNow)
chk("the honest request passed, its replay did not", bFirst and NOT bSecond)
chk("unknown key noted", len(oLed.OfKind("sig.key.unknown")) = 1)
chk("stale timestamp noted", len(oLed.OfKind("sig.timestamp.stale")) = 1)
chk("FORGED SIGNATURE noted", len(oLed.OfKind("sig.signature.forged")) = 1)
chk("REPLAYED NONCE noted", len(oLed.OfKind("sig.nonce.replayed")) = 1)
aForged = oLed.OfKind("sig.signature.forged")
chk("...the event names the key it was signed for", aForged[1][:actor] = "billing")
chk("...and carries the gate's own words", StzFindFirst("forged, tampered", aForged[1][:reason]) > 0)

? ""
? "-- Scene 3: passkey assertion refusals are noted --"
# The anti-phishing check (origin + challenge) used to return BEFORE the
# refusal helper and so noted nothing; it goes through it now.
# NOTE, honestly: the clone-suspected kind is wired at the signature-
# counter check, which is only reachable with a valid assertion whose
# counter stalled -- real authenticator fixtures. This guard exercises
# the refusal path it can reach; the clone line is one call at that site.
oPk = new stzPasskeyServer("softanza.dev", "https://softanza.dev")
aCred = [ :keyType = "ec2", :key1 = "x", :key2 = "y", :signCount = 99 ]
oPk.VerifyAssertion(aCred, "", "", "", "chal")
chk("the assertion was refused, and the refusal was noted", len(oLed.OfKind("auth.passkey.failed")) >= 1)
aPk = oLed.OfKind("auth.passkey.failed")
chk("...with the gate's reason", aPk[1][:reason] != "")
chk("...and the relying party as the actor", aPk[1][:actor] = "softanza.dev")

? ""
? "-- Scene 4: the secret store's governed door, both ways --"
oStore = new stzSecretStore("project")
oSec = new stzSecret("stripe-live")
oSec.FromLiteralQ("sk_live_NEVER_IN_AN_EVENT")
oStore.Register(oSec)
oStore.Reveal("stripe-live", HumanActor("mansour"))
bRaised = FALSE
try
	oStore.Reveal("stripe-live", LLMActor("advisor"))
catch
	bRaised = TRUE
done
chk("the sandboxed actor was refused (unchanged behaviour)", bRaised)
chk("the GRANT reached the ledger", len(oLed.OfKind("secret.reveal.granted")) = 1)
chk("the REFUSAL reached the ledger", len(oLed.OfKind("secret.reveal.refused")) = 1)
aRef = oLed.OfKind("secret.reveal.refused")
chk("...naming the actor", aRef[1][:actor] = "advisor")
chk("...and its posture, from the actor itself", aRef[1][:posture] = "sandboxed")
cJoined = ""
aEvery = oLed.All()
for i = 1 to len(aEvery)
	cJoined += (aEvery[i][:subject] + " " + aEvery[i][:reason] + " ")
next
chk("THE REDACTION LAW HOLDS ACROSS THE WHOLE LEDGER", StzFindFirst("sk_live", cJoined) = 0)

? ""
? "-- Scene 5: auth failures become countable history --"
oAuth = new stzAuth()
oAuth.Register("admin", "correct-horse")
for i = 1 to 3
	oAuth.Login("admin", "wrong-guess")
next
aFails = oLed.OfKind("auth.login.failed")
? "  three bad attempts -> " + len(aFails) + " event(s)"
chk("each failure is its own timestamped event", len(aFails) = 3)
chk("...naming the user", aFails[1][:actor] = "admin")
chk("the in-memory counter still works too", oAuth.FailedAttempts("admin") = 3)
oAuth.Login("admin", "correct-horse")
chk("a success clears the COUNTER (as before)", oAuth.FailedAttempts("admin") = 0)
chk("...but the ledger still remembers the three failures", len(oLed.OfKind("auth.login.failed")) = 3)

? ""
? "-- Scene 6: the two gaps that were never audited at all --"
# Everything here is REHEARSED and then refused, so reality is never
# touched: the scope allows a prefix this plan never uses.
oTwin = new stzVirtualFileSystem()
oTwin.CreateFile("_tmp_seam_probe.txt", "rehearsed, never committed")
oPlan = oTwin.GenerateUpdatePlan()
oScope = new stzCommitScope()
oScope.AllowUnder("/nowhere")
oPlan.SetScope(oScope)
oPlan.SetExecutor(HumanActor("mansour"))
aRes = oPlan.Execute()
chk("nothing crossed into reality", aRes[1][2] = 0 and StzEngineFileExists("_tmp_seam_probe.txt") = 0)
chk("the out-of-scope operation was noted (was: no audit at all)", len(oLed.OfKind("scope.refused")) >= 1)
aScope = oLed.OfKind("scope.refused")
chk("...with the scope's own reason", aScope[1][:reason] != "")

oTwin2 = new stzVirtualFileSystem()
oTwin2.CreateFile("_tmp_seam_probe2.txt", "rehearsed, never committed")
oGov = new stzGovernance("hq")
oPlan2 = oTwin2.GenerateUpdatePlan()
oPlan2.SetExecutor(HumanActor("nobody"))
oPlan2.SetGovernance(oGov)
oPlan2.Execute()
chk("the undeclared posture was noted (was: no audit at all)", len(oLed.OfKind("posture.refused")) >= 1)
chk("...and that plan touched nothing either", StzEngineFileExists("_tmp_seam_probe2.txt") = 0)

? ""
? "-- Scene 7: one ledger, one chain, one story --"
? "  the ledger now holds " + oLed.Count() + " event(s) from six classes"
chk("events accumulated from every wired seam", oLed.Count() >= 12)
chk("the chain over all of them is intact", oLed.Verify()[:intact])
chk("refusals dominate, as they should", len(oLed.Refusals()) >= 11)
aKinds = []
aAll2 = oLed.All()
for i = 1 to len(aAll2)
	if ring_find(aKinds, aAll2[i][:kind]) = 0
		aKinds + aAll2[i][:kind]
	ok
next
? "  distinct kinds seen: " + len(aKinds)
chk("at least eight distinct kinds fired", len(aKinds) >= 8)

StzCloseSecurityLedger()
chk("closing releases the process ledger", NOT StzSecurityLedgerIsOpen())
oAfter = new stzRequestSigner("after")
oAfter.AddKey("k", "s")
oAfter.VerifyNow("ghost", "GET", "/x", "", StzEngineTimeNowMs(), "n", "s", 30000)
chk("...and the seams go quiet again, harmlessly", NOT StzSecurityLedgerIsOpen())

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
