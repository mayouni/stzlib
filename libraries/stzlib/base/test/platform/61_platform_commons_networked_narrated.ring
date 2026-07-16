load "../../stzBase.ring"
load "../_narrated.ring"

# stzPlatform DEEPENING -- the NETWORKED BODY (duty #4).
#
# The floor gave ServeBody() a read-only window on the world (GET /world,
# GET /thing). This deepens it into the live Commons runtime over HTTP:
# identity + sessions + messaging + a per-user key/value store, every
# mutation session-authed and landing in the SAME sqlite the platform
# owns. One stzPlatform is both the auth authority and the data floor;
# the routes are just its Commons methods behind a session token.
#
# Offline by construction: a second stzReactor plays the HTTP client
# (submit -> serve one -> await), so a single process holds both ends
# with no public network and no deadlock -- the same shape as the
# appserver reactor suite.

$CRLF = char(13) + char(10)

oDb = new stzDatabase(":memory:")
oP = new stzPlatform("acme")
oP.OpenCommonsOn(oDb)
oP.RegisterIdentity("alice", "pw123")
oP.RegisterIdentity("bob", "pw456")
oP.ServeBody(0)
oClient = new stzReactor()
nPort = oP.HostQ().Port()

Scenario("the body binds and exposes the Commons over HTTP")
	Given("a platform with a Commons store and two identities, serving")
	Then("a real bound port is known", nPort > 0, TRUE)
EndScenario()

Scenario("POST /session mints a token for good credentials only")
	When("alice posts her real secret")
	r = HttpPost(oClient, nPort, oP, "/session", "user=alice&secret=pw123")
	$cTok = ExtractField(r, "token")
	Then("a session token comes back", len($cTok) > 0, TRUE)
	When("she posts a WRONG secret")
	r2 = HttpPost(oClient, nPort, oP, "/session", "user=alice&secret=WRONG")
	Then("the body refuses with 401", StzFindFirst(r2, "401") > 0, TRUE)
EndScenario()

Scenario("GET /whoami resolves the caller behind a token")
	When("alice presents her token to /whoami")
	r = HttpGet(oClient, nPort, oP, "/whoami?token=" + $cTok)
	Then("the body names her", StzFindFirst(r, "alice") > 0, TRUE)
	When("an unknown token is presented")
	r2 = HttpGet(oClient, nPort, oP, "/whoami?token=sess_bogus")
	Then("it is refused with 401", StzFindFirst(r2, "401") > 0, TRUE)
EndScenario()

Scenario("POST /message carries mail, authed as the sender")
	When("alice (token-authed) messages bob")
	r = HttpPost(oClient, nPort, oP, "/message",
		"from=alice&to=bob&body=hi&token=" + $cTok)
	Then("the message is accepted", StzFindFirst(r, "posted") > 0, TRUE)
	When("bob opens his own session")
	tb = HttpPost(oClient, nPort, oP, "/session", "user=bob&secret=pw456")
	$cTokB = ExtractField(tb, "token")
	When("bob GETs his inbox with his token")
	r2 = HttpGet(oClient, nPort, oP, "/inbox?user=bob&token=" + $cTokB)
	Then("alice's message is really there",
		StzFindFirst(r2, "alice") > 0 and StzFindFirst(r2, "hi") > 0, TRUE)
EndScenario()

Scenario("an inbox is private -- the token must match the owner")
	When("alice tries to read bob's inbox with HER token")
	r = HttpGet(oClient, nPort, oP, "/inbox?user=bob&token=" + $cTok)
	Then("the body refuses with 401", StzFindFirst(r, "401") > 0, TRUE)
EndScenario()

Scenario("the key/value store is session-gated and shared")
	When("alice stores a preference")
	HttpPost(oClient, nPort, oP, "/store", "key=theme&value=dark&token=" + $cTok)
	When("bob reads the same key with HIS token")
	r = HttpGet(oClient, nPort, oP, "/store?key=theme&token=" + $cTokB)
	Then("the value persisted in the shared store", StzFindFirst(r, "dark") > 0, TRUE)
	When("someone reads the store with NO token")
	r2 = HttpGet(oClient, nPort, oP, "/store?key=theme")
	Then("the body refuses with 401", StzFindFirst(r2, "401") > 0, TRUE)
EndScenario()

Scenario("lifecycle: the body stops cleanly")
	When("StopServing() runs")
	oP.StopServing()
	oDb.Close()
	oClient.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

func HttpPost oC, nPort, oP, cPath, cForm
	cR = "POST " + cPath + " HTTP/1.1" + $CRLF + "Host: l" + $CRLF +
	     "Content-Length: " + len(cForm) + $CRLF + "Connection: close" + $CRLF + $CRLF + cForm
	n = oC.SubmitTcp("127.0.0.1", nPort, cR)
	oP.ServeOne(3000)
	return oC.AwaitTcp(n, 5000)

func HttpGet oC, nPort, oP, cPath
	cR = "GET " + cPath + " HTTP/1.1" + $CRLF + "Host: l" + $CRLF +
	     "Connection: close" + $CRLF + $CRLF
	n = oC.SubmitTcp("127.0.0.1", nPort, cR)
	oP.ServeOne(3000)
	return oC.AwaitTcp(n, 5000)

func ExtractField cResp, cKey
	nT = StzFindFirst(cResp, cKey + '":"')
	if nT = 0  return ""  ok
	cTail = StzMidToEnd(cResp, nT + len(cKey) + 3)
	return StzLeft(cTail, StzFindFirst(cTail, '"') - 1)
