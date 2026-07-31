# The REMAINING seams -- incident analysis I2, second pass
# (SOFTANZA_INCIDENT_ANALYSIS.md section 7).
#
# I2's first pass wired six classes and left the rest of the table
# listed-but-unwired: the design doc said so plainly, because a
# detection can only ever see what a seam emits. This guard covers the
# rest of the table -- OIDC on both sides, the transport gate, the rate
# limiter, cross-world and federated crossings, the production door,
# the bare secret, the escalation audit, and the session lifecycle.
#
# It also pins the one thing this pass added to the vocabulary: an
# OBSERVED outcome, for facts that are neither granted nor refused.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals; kinds are STRINGS.

load "../../stzBase.ring"

nPass = 0
nFail = 0
$CRLF = char(13) + char(10)
$NOW = 1750000000

pr()

StzOpenSecurityLedger(512)

? "-- Scene 1: an id-token this client will not accept --"
oCli = new stzOidcClient("https://id.acme.com", "shop-app")
aTok = oCli.VerifyIdTokenAt("not-a-jwt", "", $NOW)
chk("the client refuses it", NOT aTok[:ok])
oLed = StzSecurityLedgerQ()
chk("...and the refusal is now REMEMBERED, not just returned",
	len(oLed.OfKind("sso.token.rejected")) = 1)
chk("...naming the issuer that claimed to have signed it",
	oLed.OfKind("sso.token.rejected")[1][:actor] = "https://id.acme.com")
? "  " + oLed.OfKind("sso.token.rejected")[1][:reason]
# @cLastWhy holds exactly one of these. Ten of them in a row -- a
# broken key rotation, or a forged-token campaign -- looked identical
# to one from any single read of it.

? ""
? "-- Scene 2: a stolen authorization code, redeemed twice --"
oOp = new stzOidcProvider("https://id.acme.com")
oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])
aAuth = oOp.AuthorizeAt([ :clientId = "shop-app",
	:redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
chk("the first redemption succeeds",
	oOp.ExchangeCodeAt("shop-app", "s3cret", aAuth[:code], "https://shop.acme.com/cb", "", $NOW)[:ok])
aAgain = oOp.ExchangeCodeAt("shop-app", "s3cret", aAuth[:code], "https://shop.acme.com/cb", "", $NOW)
chk("the second is refused", NOT aAgain[:ok])
chk("...and recorded as a REPLAY, the error it is",
	len(oLed.OfKind("oauth.code.replayed")) = 1)

# The distinction the provider could not previously make.
oOp.ExchangeCodeAt("shop-app", "s3cret", "a-code-nobody-issued", "https://shop.acme.com/cb", "", $NOW)
chk("a code that was never issued is NOT called a replay",
	len(oLed.OfKind("oauth.code.replayed")) = 1)
chk("...it is a rejected client, the warning it is",
	len(oLed.OfKind("oauth.client.rejected")) >= 1)
? "  the answer to both is identical -- only the ledger tells them apart"

? ""
? "-- Scene 3: the transport gate, seen once for every route --"
oSrv = new stzAppServer()
oSrv.Get_("/open", func oReq, oResp { oResp.Text("fine") })
oSrv.Get_("/vault", func oReq, oResp {
	oResp.Status(403, "Forbidden").Json([ "error", "not yours" ]) })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()

cReq = "GET /vault HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cBody = oClient.AwaitTcp(nJob, 5000)
chk("a real 403 came back over a real socket", StzFindFirst("403", cBody) > 0)
chk("...and the refusal reached the ledger from a USER's route",
	len(oLed.OfKind("http.request.forbidden")) = 1)
chk("...naming the method and path, and nothing from the headers",
	oLed.OfKind("http.request.forbidden")[1][:subject] = "GET /vault")
? "  " + oLed.OfKind("http.request.forbidden")[1][:subject]
# Read once where the response is FINAL, not at each Status(401) site:
# there are nine of those in stzAppServer alone, and a seam that saw
# only the library's own refusals would miss every route an app adds.

cReq = "GET /open HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cBody = oClient.AwaitTcp(nJob, 5000)
chk("a 200 writes nothing -- a 404 is a typo and a 500 is a bug",
	len(oLed.OfKind("http.request.forbidden")) = 1)
oSrv.Stop()

? ""
? "-- Scene 4: the rate limiter sheds, and says WHEN --"
oRl = new stzRateLimiter("front")
oRl.SetLimit("scraper", 1, 1)
oRl.Allow("scraper")
oRl.Allow("scraper")
oRl.Allow("scraper")
chk("the counter says how many were shed", oRl.RejectedCount("scraper") = 2)
chk("...the ledger says when each one was", len(oLed.OfKind("ratelimit.shed")) = 2)
chk("a shed is INFO -- the limiter working, not a failure",
	oLed.OfKind("ratelimit.shed")[1][:severity] = "info")
oRl.Destroy()
# A steady trickle and a sudden flood read the same from a counter.
# The times are what a burst detection needs.

? ""
? "-- Scene 5: a world reaching for a world it is not bonded to --"
oCon = new stzSuperApp("acme")
oCon.AddWorld("resto", StzAppQ("resto"))
oCon.AddWorld("supplier", StzAppQ("supplier"))
chk("the crossing is refused", NOT oCon.CallAcross("resto", "supplier", "order-produce"))
chk("...and remembered under the world that REACHED",
	len(oLed.OfKind("crossworld.call.refused")) = 1)
chk("...naming the caller, so incident correlation finds it",
	oLed.OfKind("crossworld.call.refused")[1][:actor] = "resto")

? ""
? "-- Scene 6: a federated call refused before it touches the wire --"
oFed = new stzComputeFederation("grid")
oFed.Join("gpu-1", "127.0.0.1:9", [ "embed" ])
oFed.FederatedCall("stranger", "embed", "/run", "{}")
chk("an unbonded caller is refused", len(oLed.OfKind("federation.call.refused")) = 1)
oFed.FederatedCall("stranger", "embed", "http://evil.example/x", "{}")
chk("...and so is an SSRF-shaped path -- the same door",
	len(oLed.OfKind("federation.call.refused")) = 2)
? "  " + oLed.OfKind("federation.call.refused")[2][:reason]
# Four checks refused here and each wrote @cWhy and vanished. The
# unsafe path is an ATTACK signature, not a misconfiguration.

? ""
? "-- Scene 7: the production door refuses a surface that is still fake --"
oReg = new stzServiceRegistry("shop")
oReg.DeclareMany([ :payments, :cache ])
oReg.BindSandbox(:payments, new stzPaymentsSandbox())
oReg.BindLocal(:cache, StzMemoryBlobStoreQ())
oDel = new stzDelivery("shop")
oDel.AddBackend("api", "linux")
oDel.UseServicesQ(oReg)
oDel.NeedsServiceInQ("api", [ :payments, :cache ])
oDel.DeployTo(StzDeploymentSiteQ("host1"), "api")
oDel.SetActor( HumanActor("dana") )
oDep = oDel.Deploy(:Production)
chk("nothing was committed", NOT oDep.WasRun())
aFake = oLed.OfKind("service.production_fake_refused")
chk("one event per UNSOUND SERVICE, not one per refused deploy", len(aFake) = 2)
chk("...naming the entitled actor who asked", aFake[1][:actor] = "dana")
? "  " + aFake[1][:subject] + " -- " + aFake[1][:reason]
# Recorded at the REFUSAL, never inside MayGoLive: that one is a
# preflight anyone may ask, and a predicate that writes evidence fills
# the ledger with questions instead of events.

? ""
? "-- Scene 8: a reveal refused by a raise nobody may swallow --"
oSec = StzSecretQ("stripe-key").FromLiteralQ("sk_live_xxx")
oBot = LLMActor("assistant")
bRaised = FALSE
try
	oSec.Reveal(oBot)
catch
	bRaised = TRUE
done
chk("the raise still fires", bRaised)
chk("...and the attempt survives it", len(oLed.OfKind("secret.reveal.refused")) = 1)
chk("the secret's NAME is written -- never its value",
	oLed.OfKind("secret.reveal.refused")[1][:subject] = "secret:stripe-key")
chk("...and the value appears nowhere in the exported chain",
	StzFindFirst("sk_live_xxx", oLed.ToOcsfNdJson()) = 0)
# A raise reaches whoever wrote the try/catch and nobody else. This
# guard's own empty catch is exactly the caller that used to erase it.

? ""
? "-- Scene 9: the escalation audit -- a verb, not a side effect --"
oGr = new stzSecurityGraph("surface")
oGr.AddActor("billing-agent", "sandboxed")
oGr.AddTool("deploy-tool")
oGr.Uses("billing-agent", "deploy-tool")
oGr.Grants("deploy-tool", "effectful")
chk("the query alone writes NOTHING -- an investigator may ask freely",
	oGr.ReachesEffectful("billing-agent") and len(oLed.OfKind("graph.escalation_path_found")) = 0)
aEsc = oGr.AuditEscalations()
chk("the audit finds the sandboxed actor that reaches effectful", len(aEsc) = 1)
chk("...and records it", len(oLed.OfKind("graph.escalation_path_found")) = 1)
chk("the PATH is named, not merely the risk",
	StzFindFirst("deploy-tool", oLed.OfKind("graph.escalation_path_found")[1][:reason]) > 0)
? "  " + oLed.OfKind("graph.escalation_path_found")[1][:reason]

? ""
? "-- Scene 10: sessions end, and the row that proved it is deleted --"
oAuth = new stzAuth()
oAuth.Register("dana", "correct-horse-battery")
cTok = oAuth.Login("dana", "correct-horse-battery")
chk("a session exists", cTok != "")
oAuth.RevokeSession(cTok)
chk("revoking it is remembered", len(oLed.OfKind("auth.session.revoked")) = 1)
chk("the TOKEN is never written -- it is a bearer credential",
	len(oLed.OfSubject(cTok)) = 0)
chk("...the user is, because that is what an investigation asks",
	oLed.OfKind("auth.session.revoked")[1][:subject] = "user:dana")

? ""
? "-- Scene 11: an ending session is not a refusal --"
aRev = oLed.OfKind("auth.session.revoked")[1]
chk("its outcome is OBSERVED -- no gate ran, nobody was told no",
	aRev[:outcome] = "observed")
chk("...so the ledger's own refusal pivot skips it",
	len(oLed.OfOutcome("observed")) = 1 and len(oLed.Refusals()) = oLed.Count() - 1)
oProbe = new stzSecurityEvent("auth.session.expired")
oProbe.Observed("the session reached its expiry")
chk("an observed event reports itself as no refusal", NOT oProbe.IsRefusal())
oProbe2 = new stzSecurityEvent("auth.login.failed")
oProbe2.Failed("the bridge broke")
chk("...while a failure still is", oProbe2.IsRefusal())
# Forcing a housekeeping fact into "refused" would have over-counted
# every pivot, and taught an investigator that routine was an attack.

? ""
? "-- Scene 12: the whole chain still verifies --"
aV = oLed.Verify()
chk("every event this guard wrote is chained", aV[:intact])
? "  " + oLed.Count() + " events across ten newly-wired seams"
chk("the ledger holds events from all ten", oLed.Count() >= 15)

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
