load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA AS AN IDENTITY PROVIDER (the OIDC provider surface).
#
# stzOidcClient made Softanza a relying PARTY -- log my users in through Google.
# This is the other side: your app becomes the provider OTHER apps trust. One
# account, one login, many applications.
#
# The authorization-code flow:
#   1. an app sends the user to /authorize -- WE authenticate them (a live
#      stzAuth session) and hand back a short-lived CODE on the registered
#      redirect;
#   2. the app's SERVER calls /token with the code, its client secret and the
#      PKCE verifier, and receives a signed ID TOKEN;
#   3. the app verifies that token against our JWKS.
#
# Each rule below exists because of a real attack: an EXACT redirect_uri match
# (a loose one lets an attacker have the code delivered to their own site), a
# SINGLE-USE code bound to its client / redirect / PKCE challenge, CLIENT
# authentication on the back channel, and PKCE for clients that cannot keep a
# secret. Every refusal carries an OAuth error code.
#
# The suite closes the loop: our own stzOidcClient verifies our own provider's
# tokens -- the RP and the OP were written against the spec, not against each
# other, so agreement is evidence.

$NOW = 1700000000

Scenario("the provider publishes what a relying party needs to find it")
	oOp = new stzOidcProvider("https://id.acme.com")
	Then("discovery is valid JSON", StzJsonIsValid(oOp.DiscoveryJson()), TRUE)
	Then("...naming the issuer", StzFindFirst('"issuer":"https://id.acme.com"', oOp.DiscoveryJson()) > 0, TRUE)
	Then("...the token endpoint", StzFindFirst("token_endpoint", oOp.DiscoveryJson()) > 0, TRUE)
	Then("...and that it signs with ES256", StzFindFirst("ES256", oOp.DiscoveryJson()) > 0, TRUE)

	Then("the JWKS is valid JSON", StzJsonIsValid(oOp.JwksJson()), TRUE)
	Then("...publishing exactly one signing key", oOp.NumberOfPublishedKeys(), 1)
	Then("...as a public EC key (never the private half)", StzFindFirst('"kty":"EC"', oOp.JwksJson()) > 0, TRUE)
	Then("...and the private key is nowhere in it", StzFindFirst('"d":', oOp.JwksJson()), 0)
EndScenario()

Scenario("the happy path: authorize, exchange, and OUR OWN client verifies the token")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])
	Then("the client is registered", oOp.HasClient("shop-app"), TRUE)

	When("an app sends a signed-in user to authorize, with PKCE")
	cVerifier = StzEngineCryptoRandomHex(32)
	aR = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb",
	                       :state = "st-1", :nonce = "n-1",
	                       :codeChallenge = oOp.PkceChallengeOf(cVerifier) ], "dana", $NOW)
	Then("a code is issued", aR[:ok], TRUE)
	Then("...on the REGISTERED redirect", StzFindFirst("https://shop.acme.com/cb?code=", aR[:redirectTo]), 1)
	Then("...carrying the state back (CSRF binding)", StzFindFirst("state=st-1", aR[:redirectTo]) > 0, TRUE)

	When("the app's server exchanges the code")
	aT = oOp.ExchangeCodeAt("shop-app", "s3cret", aR[:code], "https://shop.acme.com/cb", cVerifier, $NOW)
	Then("tokens are returned", aT[:ok], TRUE)
	Then("...for the right subject", aT[:subject], "dana")
	Then("...as a Bearer token", aT[:tokenType], "Bearer")

	When("the app verifies the id-token the way any relying party would")
	oRp = new stzOidcClient("https://id.acme.com", "shop-app")
	oRp.SetJwks( oOp.JwksJson() )
	aV = oRp.VerifyIdTokenAt(aT[:idToken], "n-1", $NOW + 5)
	Then("it VERIFIES against the published JWKS", aV[:ok], TRUE)
	Then("...naming the user", aV[:subject], "dana")
	Then("the access token is a verifiable JWT too", oRp.VerifyIdTokenAt(aT[:accessToken], "", $NOW + 5)[:ok], TRUE)
EndScenario()

Scenario("the redirect_uri must match EXACTLY -- the most abused hole in OAuth")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])

	When("an attacker asks for the code to be delivered to their own site")
	aR = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://evil.example/cb" ], "dana", $NOW)
	Then("it is refused", aR[:ok], FALSE)
	Then("...and NO code was minted", aR[:code], "")
	Then("...naming the reason", StzFindFirst("not registered", aR[:why]) > 0, TRUE)

	When("the redirect merely LOOKS similar (a suffix)")
	aP = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb/../evil" ], "dana", $NOW)
	Then("it is still refused -- matching is exact, never a prefix", aP[:ok], FALSE)

	When("an unknown client asks")
	aU = oOp.AuthorizeAt([ :clientId = "ghost", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	Then("it is refused", aU[:ok], FALSE)
	Then("...as an unauthorized client", aU[:error], "unauthorized_client")

	When("nobody is signed in")
	aN = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "", $NOW)
	Then("it asks for a login instead of issuing anything", aN[:error], "login_required")
EndScenario()

Scenario("a code is single-use, short-lived, and bound to its client and redirect")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])
	oOp.RegisterClient("other-app", "otherpw", [ "https://other.acme.com/cb" ])

	When("a code is redeemed twice (the classic stolen-code replay)")
	aR = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	Then("the first exchange succeeds", oOp.ExchangeCodeAt("shop-app", "s3cret", aR[:code], "https://shop.acme.com/cb", "", $NOW)[:ok], TRUE)
	aSecond = oOp.ExchangeCodeAt("shop-app", "s3cret", aR[:code], "https://shop.acme.com/cb", "", $NOW)
	Then("the second is refused", aSecond[:ok], FALSE)
	Then("...as an invalid grant", aSecond[:error], "invalid_grant")

	When("a code is presented by a DIFFERENT client that knows its own secret")
	aR2 = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	aX = oOp.ExchangeCodeAt("other-app", "otherpw", aR2[:code], "https://shop.acme.com/cb", "", $NOW)
	Then("it is refused -- the code is bound to the client it was issued to", aX[:ok], FALSE)

	When("the redirect_uri at the token endpoint does not match the one used to get the code")
	aR3 = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	Then("it is refused", oOp.ExchangeCodeAt("shop-app", "s3cret", aR3[:code], "https://elsewhere/cb", "", $NOW)[:ok], FALSE)

	When("a code is left too long")
	aR4 = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	Then("it expires (5 minutes)", oOp.ExchangeCodeAt("shop-app", "s3cret", aR4[:code], "https://shop.acme.com/cb", "", $NOW + 400)[:ok], FALSE)
EndScenario()

Scenario("the back channel authenticates the CLIENT, and PKCE protects the public ones")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])

	When("the token endpoint is called with a WRONG client secret")
	aR = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb" ], "dana", $NOW)
	aBad = oOp.ExchangeCodeAt("shop-app", "not-the-secret", aR[:code], "https://shop.acme.com/cb", "", $NOW)
	Then("it is refused", aBad[:ok], FALSE)
	Then("...as an invalid client", aBad[:error], "invalid_client")

	Given("an authorization that carried a PKCE challenge")
	cVerifier = StzEngineCryptoRandomHex(32)
	aP = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb",
	                       :codeChallenge = oOp.PkceChallengeOf(cVerifier) ], "dana", $NOW)
	When("the WRONG verifier is presented")
	aW = oOp.ExchangeCodeAt("shop-app", "s3cret", aP[:code], "https://shop.acme.com/cb", "wrong-verifier", $NOW)
	Then("it is refused", aW[:ok], FALSE)
	Then("...naming PKCE", StzFindFirst("PKCE", aW[:why]) > 0, TRUE)

	When("NO verifier is presented for a code that required one")
	aP2 = oOp.AuthorizeAt([ :clientId = "shop-app", :redirectUri = "https://shop.acme.com/cb",
	                        :codeChallenge = oOp.PkceChallengeOf(cVerifier) ], "dana", $NOW)
	Then("it is refused", oOp.ExchangeCodeAt("shop-app", "s3cret", aP2[:code], "https://shop.acme.com/cb", "", $NOW)[:ok], FALSE)
EndScenario()

Scenario("keys rotate WITHOUT invalidating tokens already in flight")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop-app", "s3cret", [ "https://shop.acme.com/cb" ])
	cOldKid = oOp.SigningKeyId()
	cToken = oOp.IssueIdTokenAt("dana", "shop-app", "n-1", $NOW)

	When("the provider rotates its signing key")
	oOp.RotateKey("")
	Then("a new key signs from now on", oOp.SigningKeyId() != cOldKid, TRUE)
	Then("...and BOTH keys are published", oOp.NumberOfPublishedKeys(), 2)

	oRp = new stzOidcClient("https://id.acme.com", "shop-app")
	oRp.SetJwks( oOp.JwksJson() )
	Then("a token signed by the OLD key still verifies (no outage)",
	     oRp.VerifyIdTokenAt(cToken, "n-1", $NOW + 5)[:ok], TRUE)
	Then("...and one from the NEW key verifies too",
	     oRp.VerifyIdTokenAt(oOp.IssueIdTokenAt("dana", "shop-app", "n-2", $NOW), "n-2", $NOW + 5)[:ok], TRUE)
EndScenario()

Scenario("mounted on the app server, it is a real IdP other apps can reach")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oOp = new stzOidcProvider("https://id.acme.com")
	oOp.RegisterClient("shop", "s3cret", [ "https://shop.acme.com/cb" ])
	oSrv = new stzAppServer()
	oSrv.MountAuth(oAuth)
	oSrv.MountOidcProvider(oOp)
	Then("the provider is mounted", oSrv.OidcProviderIsMounted(), TRUE)

	Then("discovery answers at the STANDARD well-known path",
	     Hit(oSrv, "GET", "/.well-known/openid-configuration", [], "")[:status], 200)
	Then("the JWKS is served", Hit(oSrv, "GET", "/oidc/jwks", [], "")[:status], 200)

	When("a user reaches /authorize with NO session")
	aNo = Hit(oSrv, "GET", "/oidc/authorize?client_id=shop&redirect_uri=https%3A%2F%2Fshop.acme.com%2Fcb", [], "")
	Then("it asks them to sign in first", aNo[:status], 401)
	Then("...with the standard error", StzFindFirst("login_required", aNo[:body]) > 0, TRUE)

	When("they sign in to THIS provider and come back")
	aLogin = Hit(oSrv, "POST", "/auth/login", [], "user=dana&password=pw")
	cCookie = "stzsession=" + CookieOf(aLogin, "stzsession")
	aAuthz = Hit(oSrv, "GET", "/oidc/authorize?client_id=shop&redirect_uri=https%3A%2F%2Fshop.acme.com%2Fcb&state=st&nonce=n1",
	             [ [ "Cookie", cCookie ] ], "")
	Then("they are redirected to the app", aAuthz[:status], 302)
	Then("...with a code and the state", StzFindFirst("code=", HeaderOf(aAuthz, "Location")) > 0, TRUE)

	When("an unregistered redirect is requested over HTTP")
	aEvil = Hit(oSrv, "GET", "/oidc/authorize?client_id=shop&redirect_uri=https%3A%2F%2Fevil.example%2Fcb", [ [ "Cookie", cCookie ] ], "")
	Then("it answers 400 and does NOT redirect (no code leaks)", aEvil[:status], 400)

	When("the app's server exchanges the code at /token")
	aTok = Hit(oSrv, "POST", "/oidc/token", [],
	           "client_id=shop&client_secret=s3cret&code=" + ValueOf(HeaderOf(aAuthz, "Location"), "code") +
	           "&redirect_uri=https%3A%2F%2Fshop.acme.com%2Fcb")
	Then("tokens come back", aTok[:status], 200)
	Then("...including an id_token", StzFindFirst("id_token", aTok[:body]) > 0, TRUE)
	Then("...marked never to be cached", StzFindFirst("no-store", HeaderOf(aTok, "Cache-Control")) > 0, TRUE)
	Then("a wrong client secret is refused over HTTP too",
	     Hit(oSrv, "POST", "/oidc/token", [], "client_id=shop&client_secret=WRONG&code=zz&redirect_uri=x")[:status], 400)

	Then("the auth router is untouched", Hit(oSrv, "GET", "/auth/session", [ [ "Cookie", cCookie ] ], "")[:status], 200)
	Then("...and so is /health", Hit(oSrv, "GET", "/health", [], "")[:status], 200)
EndScenario()

Summary()


func Hit oSrv, cM, cPath, aH, cBody
	oReq = new stzAppRequest(cM, cPath, aH, cBody)
	oResp = new stzAppResponse(NULL)
	oSrv._Dispatch(oReq, oResp)
	return [ :status = oResp.StatusCode(), :body = oResp.Body(), :headers = oResp.Headers() ]

func HeaderOf aR, cName
	aH = aR[:headers]
	n = len(aH)
	for i = 1 to n
		if StzLower(aH[i][1]) = StzLower(cName)
			return aH[i][2]
		ok
	next
	return ""

func CookieOf aR, cName
	aH = aR[:headers]
	n = len(aH)
	for i = 1 to n
		if StzLower(aH[i][1]) = "set-cookie" and StzFindFirst(cName + "=", aH[i][2]) = 1
			aP = StzSplit(aH[i][2], ";")
			aKV = StzSplit(aP[1], "=")
			if len(aKV) >= 2
				return aKV[2]
			ok
		ok
	next
	return ""

func ValueOf cUrl, cKey
	nP = StzFindFirst(cKey + "=", cUrl)
	if nP = 0
		return ""
	ok
	cRest = StzMidToEnd(cUrl, nP + len(cKey) + 1)
	nAmp = StzFindFirst("&", cRest)
	if nAmp > 0
		return StzLeft(cRest, nAmp - 1)
	ok
	return cRest
