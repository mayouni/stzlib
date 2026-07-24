load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 6 -- the auth ROUTER: everything phases 1-5 built, mounted on
# stzAppServer as HTTP endpoints.
#
#   POST /auth/login          user=&password=[&code=]  -> session cookie
#   POST /auth/2fa/verify     user=&password=&code=    -> session cookie
#   POST /auth/logout                                  -> cookie cleared (CSRF-checked)
#   GET  /auth/session                                 -> who + capabilities (phase 5)
#   POST /auth/magic-link     email=                   -> 202 (always)
#   GET  /auth/magic-link/redeem?token=                -> session cookie
#   POST /auth/otp / /auth/otp/verify                  -> session cookie
#
# The session token travels as an HttpOnly + SameSite=Strict cookie (script cannot
# read it; a cross-site form cannot ride it), alongside a READABLE csrf cookie that
# a cookie-authenticated POST must echo in X-CSRF-Token.
#
# Most scenarios drive the server's real dispatch chain in-process, because the
# curl-backed client has no custom-header channel (so cookies/CSRF cannot be
# exercised over the wire); the last scenario proves the same route really answers
# over a socket.

$cDb = WorkingDirectory() + "/_authtest_router.db"

Scenario("a password login over HTTP returns a hardened session cookie")
	oAuth = new stzAuth()
	oAuth.Register("dana@corp.com", "pw")
	oAuth.GrantRole("dana@corp.com", "admin")
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)
	Then("the router is mounted at /auth", oSrv.AuthPrefix(), "/auth")

	When("credentials are POSTed (form-encoded, %40 for @)")
	aR = Hit(oSrv, "POST", "/auth/login", [], "user=dana%40corp.com&password=pw")
	Then("it answers 200", aR[:status], 200)
	Then("...naming the user (percent-decoding worked)", StzFindFirst('"user":"dana@corp.com"', aR[:body]) > 0, TRUE)
	Then("...setting a 256-bit session cookie", len(CookieOf(aR, "stzsession")), 64)
	Then("...HttpOnly, so script cannot read it", StzFindFirst("HttpOnly", RawCookie(aR, "stzsession")) > 0, TRUE)
	Then("...SameSite=Strict, so a cross-site form cannot ride it", StzFindFirst("SameSite=Strict", RawCookie(aR, "stzsession")) > 0, TRUE)
	Then("...plus a READABLE csrf cookie (script must echo it)", StzFindFirst("HttpOnly", RawCookie(aR, "stzcsrf")) = 0, TRUE)

	When("the password is wrong")
	aB = Hit(oSrv, "POST", "/auth/login", [], "user=dana%40corp.com&password=WRONG")
	Then("it answers 401", aB[:status], 401)
	Then("...and sets no session cookie", CookieOf(aB, "stzsession"), "")
EndScenario()

Scenario("GET /auth/session is the AUTHZ surface (phase 5 over HTTP)")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oAuth.GrantRole("dana", "admin")
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)
	cTok = CookieOf(Hit(oSrv, "POST", "/auth/login", [], "user=dana&password=pw"), "stzsession")

	aR = Hit(oSrv, "GET", "/auth/session", [ [ "Cookie", "stzsession=" + cTok ] ], "")
	Then("it answers 200", aR[:status], 200)
	Then("...naming the user", StzFindFirst('"user":"dana"', aR[:body]) > 0, TRUE)
	Then("...reporting the actor's capabilities", StzFindFirst("effectful", aR[:body]) > 0, TRUE)
	Then("...its posture", StzFindFirst('"posture":"trusted"', aR[:body]) > 0, TRUE)
	Then("...and its roles", StzFindFirst('"roles":"admin"', aR[:body]) > 0, TRUE)

	Then("without a cookie it is 401", Hit(oSrv, "GET", "/auth/session", [], "")[:status], 401)
	Then("with a bogus cookie it is 401", Hit(oSrv, "GET", "/auth/session", [ [ "Cookie", "stzsession=deadbeef" ] ], "")[:status], 401)
EndScenario()

Scenario("logout is CSRF-protected, because a cookie is AMBIENT authority")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)
	aL = Hit(oSrv, "POST", "/auth/login", [], "user=dana&password=pw")
	cTok = CookieOf(aL, "stzsession")
	cCsrf = CookieOf(aL, "stzcsrf")
	cCookies = "stzsession=" + cTok + "; stzcsrf=" + cCsrf

	When("a cross-site POST rides the cookie WITHOUT the csrf header")
	Then("it is refused with 403", Hit(oSrv, "POST", "/auth/logout", [ [ "Cookie", cCookies ] ], "")[:status], 403)
	Then("...and the session is still alive", Hit(oSrv, "GET", "/auth/session", [ [ "Cookie", cCookies ] ], "")[:status], 200)

	When("the real page echoes the csrf token it read")
	Then("logout succeeds", Hit(oSrv, "POST", "/auth/logout", [ [ "Cookie", cCookies ], [ "X-CSRF-Token", cCsrf ] ], "")[:status], 200)
	Then("...and the session is dead", Hit(oSrv, "GET", "/auth/session", [ [ "Cookie", cCookies ] ], "")[:status], 401)
EndScenario()

Scenario("two-factor is enforced at the HTTP door")
	Given("a 2FA user configured BEFORE the mount")
	oAuth = new stzAuth()
	oAuth.Register("sec@corp.com", "pw")
	oDev = StzTotpFromSecretQ( oAuth.EnableTotp("sec@corp.com", "App")[:secret] )
	oAuth.ConfirmTotp("sec@corp.com", oDev.Code())
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)

	When("the password alone is POSTed")
	aR = Hit(oSrv, "POST", "/auth/login", [], "user=sec%40corp.com&password=pw")
	Then("it is refused with 401", aR[:status], 401)
	Then("...telling an honest client WHICH door it needs", StzFindFirst('"twofactor":1', aR[:body]) > 0, TRUE)
	Then("...and no session cookie is set", CookieOf(aR, "stzsession"), "")

	When("the authenticator code is supplied")
	aOk = Hit(oSrv, "POST", "/auth/2fa/verify", [], "user=sec%40corp.com&password=pw&code=" + oDev.Code())
	Then("a session opens", aOk[:status], 200)
	Then("...with a real cookie", len(CookieOf(aOk, "stzsession")), 64)
	Then("a WRONG code is refused", Hit(oSrv, "POST", "/auth/2fa/verify", [], "user=sec%40corp.com&password=pw&code=000000")[:status], 401)
EndScenario()

Scenario("passwordless works over HTTP, and stays enumeration-safe there too")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.Register("dana@corp.com", "pw")
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)

	When("a magic link is requested over HTTP")
	aR = Hit(oSrv, "POST", "/auth/magic-link", [], "email=dana%40corp.com")
	Then("it answers 202", aR[:status], 202)
	Then("...and the sandbox captured the mail", oMail.Count(), 1)

	When("the emailed link is followed")
	aOk = Hit(oSrv, "GET", "/auth/magic-link/redeem?token=" + TokenFrom(oMail.LastBody()), [], "")
	Then("a session opens", aOk[:status], 200)
	Then("...with a real cookie", len(CookieOf(aOk, "stzsession")), 64)

	When("a link is requested for an UNKNOWN email")
	oMail.ClearQ()
	aG = Hit(oSrv, "POST", "/auth/magic-link", [], "email=ghost%40nowhere.com")
	Then("the HTTP answer is identical", aG[:status], 202)
	Then("...but nothing was sent (no enumeration over HTTP either)", oMail.Count(), 0)

	When("an email OTP is requested and entered")
	oMail.ClearQ()
	Hit(oSrv, "POST", "/auth/otp", [], "email=dana%40corp.com")
	aO = Hit(oSrv, "POST", "/auth/otp/verify", [], "email=dana%40corp.com&code=" + CodeFrom(oMail.LastBody()))
	Then("a session opens", aO[:status], 200)
	Then("...and a wrong code does not", Hit(oSrv, "POST", "/auth/otp/verify", [], "email=dana%40corp.com&code=000000")[:status], 401)
EndScenario()

Scenario("mounting does not disturb the rest of the server")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oSrv = new stzAppServer()
	oSrv.Get_("/ping", func oReq, oResp { oResp.Text("pong") })
	oSrv.MountAuth(oAuth)

	Then("an ordinary route still answers", Hit(oSrv, "GET", "/ping", [], "")[:body], "pong")
	Then("/health still answers", Hit(oSrv, "GET", "/health", [], "")[:status], 200)
	Then("an unknown path under the prefix is a 404", Hit(oSrv, "GET", "/auth/nope", [], "")[:status], 404)
	Then("a GET on a POST-only endpoint is a 404", Hit(oSrv, "GET", "/auth/login", [], "")[:status], 404)

	Given("a server with NOTHING mounted")
	oBare = new stzAppServer()
	Then("the auth paths are simply not there", Hit(oBare, "POST", "/auth/login", [], "user=x&password=y")[:status], 404)
	Then("...and it reports so", oBare.AuthIsMounted(), FALSE)
EndScenario()

Scenario("a DB-backed auth gives the server and the caller ONE shared view")
	# Ring COPIES an object on `=`, so the server holds its own stzAuth: configure
	# before mounting. Give it a stzAuthDbStore and that stops mattering -- sqlite is
	# an engine handle, so both sides read and write the same database.
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oAuth = new stzAuth()
	oAuth.SetStore(StzAuthDbStoreQ($cDb))
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)

	When("a user is registered AFTER the mount")
	oAuth.Register("late@corp.com", "pw")
	aR = Hit(oSrv, "POST", "/auth/login", [], "user=late%40corp.com&password=pw")
	Then("the server sees them and signs them in", aR[:status], 200)

	When("the caller inspects the session HTTP just created")
	Then("it is live on the caller's own object too", oAuth.IsValidSession(CookieOf(aR, "stzsession")), TRUE)
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Scenario("the same route really answers over a socket")
	$oAuthW = new stzAuth()
	$oAuthW.Register("dana@corp.com", "pw")
	$oSrvW = new stzAppServer()
	$oSrvW.MountAuth($oAuthW)
	$oSrvW.Start(0, "127.0.0.1")
	Then("the listener bound a port", $oSrvW.Port() > 0, TRUE)

	When("a real HTTP client POSTs credentials to the bound port")
	$oRsW = new stzReactive()
	$cGotW = ""
	$nPumpW = 0
	$oRsW.HttpPost("http://127.0.0.1:" + $oSrvW.Port() + "/auth/login",
		"user=dana%40corp.com&password=pw",
		func cBody { $cGotW = cBody },
		func cErr  { $cGotW = "ERR:" + cErr })
	$oRsW.RunEvery(10, func {
		$nPumpW++
		$oSrvW.ServeOne(1)
		if $cGotW != "" or $nPumpW > 300
			$oRsW.StopAllTimers()
		ok
	})
	$oRsW.RunLoop()
	Then("the wire response reports success", StzFindFirst('"ok":1', $cGotW) > 0, TRUE)
	Then("...for the right user", StzFindFirst('"user":"dana@corp.com"', $cGotW) > 0, TRUE)
	$oSrvW.Stop()
	$oRsW.Stop()
EndScenario()

Summary()


# drive the server's REAL dispatch chain in-process (the auth gate, the router,
# the MBaaS floor and /health all run exactly as they do for a socket request).
func Hit oSrv, cM, cPath, aH, cBody
	oReq = new stzAppRequest(cM, cPath, aH, cBody)
	oResp = new stzAppResponse(NULL)
	oSrv._Dispatch(oReq, oResp)
	return [ :status = oResp.StatusCode(), :body = oResp.Body(), :headers = oResp.Headers() ]

func RawCookie aR, cName
	aH = aR[:headers]
	n = len(aH)
	for i = 1 to n
		if StzLower(aH[i][1]) = "set-cookie" and StzFindFirst(cName + "=", aH[i][2]) = 1
			return aH[i][2]
		ok
	next
	return ""

func CookieOf aR, cName
	c = RawCookie(aR, cName)
	if c = ""  return ""  ok
	aP = StzSplit(c, ";")
	aKV = StzSplit(aP[1], "=")
	if len(aKV) < 2  return ""  ok
	return aKV[2]

func TokenFrom cBody
	nP = StzFindFirst("token=", cBody)
	if nP = 0  return ""  ok
	cRest = StzMidToEnd(cBody, nP + 6)
	nNl = StzFindFirst(nl, cRest)
	if nNl > 0  return StzLeft(cRest, nNl - 1) ok
	return cRest

func CodeFrom cBody
	nP = StzFindFirst("code is: ", cBody)
	if nP = 0  return ""  ok
	cRest = StzMidToEnd(cBody, nP + 9)
	nNl = StzFindFirst(nl, cRest)
	if nNl > 0  return StzLeft(cRest, nNl - 1) ok
	return cRest
