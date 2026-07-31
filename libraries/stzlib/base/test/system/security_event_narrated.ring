# The typed security event -- incident analysis I0
# (SOFTANZA_INCIDENT_ANALYSIS.md).
#
# The library detects more than it remembers: a cloned authenticator, a
# replayed nonce, a forged signature -- each detected perfectly, then
# dropped into a one-slot Why() the next call overwrites. I0 fixes the
# vocabulary that makes remembering possible: a closed kind catalog, the
# six questions as closed fields, BOTH clocks (forensic wall + ordering
# monotonic), the active trace id for free -- and the REDACTION LAW
# enforced at construction: an event carries a secret's DESCRIPTOR,
# never its value. An incident record must never become the breach.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no keyword-bearing names.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the catalog is closed, and it teaches --"
chk("a known kind is known", StzSecurityEventKindIsKnown("sig.nonce.replayed"))
chk("an invented kind is not", NOT StzSecurityEventKindIsKnown("something.made.up"))
aInfo = StzSecurityEventKindInfo("auth.passkey.clone_suspected")
chk("the catalog carries a default severity", aInfo[2] = "error")
chk("...an ATT&CK technique", aInfo[3] = "T1550")
chk("...and a meaning in words", StzFindFirst("counter did not advance", aInfo[4]) > 0)
chk("the catalog covers the seams (>= 25 kinds)", len(StzSecurityEventKinds()) >= 25)

bRaised = FALSE
try
	oBad = StzSecurityEvent("attacker.did.something")
catch
	bRaised = TRUE
done
chk("an unknown kind refuses at construction", bRaised)

? ""
? "-- Scene 2: an event is stamped with BOTH clocks, at detection time --"
oE = StzSecurityEvent("sig.nonce.replayed")
? "  wall = " + oE.AtWall() + " ; mono = " + oE.AtMono()
chk("the wall stamp is a real epoch (after 2020)", oE.AtWall() > 1577836800000)
chk("the monotonic stamp is since-load, not the epoch", oE.AtMono() < 3600000)
chk("severity defaulted from the catalog", oE.Severity() = "error")
chk("technique defaulted from the catalog", oE.Technique() = "T1550")
chk("outcome defaults to refused (the honest default)", oE.Outcome() = "refused" and oE.IsRefusal())

? ""
? "-- Scene 3: the actor contributes its OWN facts --"
oLlm = LLMActor("advisor")
oE2 = StzSecurityEvent("secret.reveal.refused")
oE2.ByActor(oLlm).Doing("reveal").AtRisk(4).FromOrigin("10.0.0.7")
oE2.Refused("actor is not effectful")
chk("the actor's name was taken, not invented", oE2.Actor() = "advisor")
chk("...its posture too", oE2.Posture() = "sandboxed")
chk("...and its capability kinds", len(oE2.ActorKinds()) = 1 and oE2.ActorKinds()[1] = "inference")
chk("the action and risk tier are carried", oE2.Action() = "reveal" and oE2.Risk() = 4)
chk("the origin is carried", oE2.Origin() = "10.0.0.7")
chk("the gate's own words are the reason", oE2.Reason() = "actor is not effectful")

oE3 = StzSecurityEvent("auth.login.failed")
oE3.ByActorNamed("admin", "external")
chk("a nameless caller at the login door still records", oE3.Actor() = "admin" and oE3.Posture() = "external")

? ""
? "-- Scene 4: THE REDACTION LAW -- descriptors, never values --"
oSecret = new stzSecret("stripe-live")
oSecret.FromLiteralQ("sk_live_51H8xQeSUPERSECRETVALUE")
oE2.About(oSecret)
? "  subject recorded as: " + oE2.Subject()
chk("the subject is the secret's DESCRIPTOR", StzFindFirst("<secret 'stripe-live'", oE2.Subject()) > 0)
chk("the VALUE never entered the event", StzFindFirst("sk_live", oE2.Subject()) = 0)
chk("...nor its canonical (hashable) form", StzFindFirst("sk_live", oE2.CanonicalString()) = 0)
chk("...nor the line a human reads", StzFindFirst("sk_live", oE2.AsLine()) = 0)
chk("...nor the JSON that leaves the process", StzFindFirst("sk_live", oE2.ToOcsfJson()) = 0)
oE4 = StzSecurityEvent("auth.login.failed").About("user:admin")
chk("a plain string subject is taken as already-safe", oE4.Subject() = "user:admin")

? ""
? "-- Scene 5: correlation is free inside a trace scope --"
oOut = StzSecurityEvent("ratelimit.shed")
chk("outside a scope the trace id is empty, honestly", oOut.TraceId() = "")
StzOpenTraceScope("")
cId = StzCurrentTraceId()
oIn = StzSecurityEvent("http.request.unauthorized")
oLog = new stzLog("api")
oLog.Warn("rejected an unsigned request")
StzCloseTraceScope()
chk("inside a scope the event carries the trace id", oIn.TraceId() = cId)
chk("...the SAME id the log line carries (one story)", len(oLog.OfTrace(cId)) = 1)

? ""
? "-- Scene 6: the native record, all fifteen fields --"
aR = oE2.Record()
chk("the record carries the kind", aR[:kind] = "secret.reveal.refused")
chk("...the actor triple", aR[:actor] = "advisor" and aR[:posture] = "sandboxed" and len(aR[:actorKinds]) = 1)
chk("...both clocks", aR[:atWall] > 1577836800000 and aR[:atMono] >= 0)
chk("...the outcome and reason", aR[:outcome] = "refused" and aR[:reason] != "")
chk("...and the severity/technique from the catalog", aR[:severity] = "error" and aR[:technique] = "T1552")

? ""
? "-- Scene 7: the canonical form is the I1 chain's input --"
oA = StzSecurityEvent("sig.signature.forged").ByActorNamed("peer-7", "external").About("key:billing")
cCanon = oA.CanonicalString()
chk("the canonical string is stable for one event", cCanon = oA.CanonicalString())
oB = StzSecurityEvent("sig.signature.forged").ByActorNamed("peer-8", "external").About("key:billing")
chk("a different actor produces a different string", oB.CanonicalString() != cCanon)
chk("it carries every field, pipe-separated", len(StzSplit(cCanon, "|")) = 12)

? ""
? "-- Scene 8: OCSF -- the SIEM handshake, from day one --"
cJ = oE2.ToOcsfJson()
? "  " + left(cJ, 96) + "..."
chk("IAM-class events map to category 3 / class 6003 by prefix rule", StzFindFirst('"class_uid":6003', cJ) > 0)
oAuth = StzSecurityEvent("auth.login.failed").ByActorNamed("admin", "external").Refused("bad password")
chk("auth.* maps to Authentication (3 / 3002)", StzFindFirst('"category_uid":3,"class_uid":3002', oAuth.ToOcsfJson()) > 0)
oHttp = StzSecurityEvent("http.request.forbidden")
chk("http.* maps to HTTP Activity (4 / 4002)", StzFindFirst('"category_uid":4,"class_uid":4002', oHttp.ToOcsfJson()) > 0)
chk("severity_id: error -> 4 (High)", StzFindFirst('"severity_id":4', cJ) > 0)
chk("status_id: a refusal -> 2 (Failure)", StzFindFirst('"status_id":2', cJ) > 0)
oG = StzSecurityGrant("secret.reveal.granted", HumanActor("mansour"), "secret:stripe-live")
chk("...and a grant -> 1 (Success)", StzFindFirst('"status_id":1', oG.ToOcsfJson()) > 0)
chk("unmapped carries the house facts (kind/outcome/reason)", StzFindFirst('"unmapped":{"kind":"secret.reveal.refused"', cJ) > 0)
chk("...and the ATT&CK technique for the receiving tool", StzFindFirst('"attack_technique":"T1552"', cJ) > 0)

? ""
? "-- Scene 9: the one-line seam forms (what I2 will call) --"
oNonce = StzSecurityRefusal("sig.nonce.replayed", HumanActor("peer-3"), "key:billing", "nonce already used for this key")
chk("StzSecurityRefusal builds a complete refusal", oNonce.IsRefusal() and oNonce.Actor() = "peer-3" and oNonce.Reason() != "")
chk("StzSecurityGrant builds a grant", NOT oG.IsRefusal() and oG.Outcome() = "granted")

? ""
? "-- Scene 10: it explains itself --"
oNonce.Show()
aL = oNonce.Explain()
chk("Explain() names the meaning from the catalog", StzFindFirst("nonce was reused", aL[2]) > 0)
chk("...and quotes ATT&CK for the analyst", StzFindFirst("T1550", aL[len(aL)]) > 0)
chk("AsLine() reads as a sentence", StzFindFirst("REFUSED sig.nonce.replayed by peer-3", oNonce.AsLine()) = 1)

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
