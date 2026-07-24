load "../../stzBase.ring"
load "../_narrated.ring"

# OIDC LOGIN -- "sign in with an external provider", verified locally.
#
# The auth plan deferred this on one missing primitive: public-key signature
# verification. With that in the engine, OIDC is finally buildable -- and it is
# mostly NOT cryptography, it is judgement: a signature only proves the provider
# signed SOMETHING. The claims decide it was signed FOR US, RECENTLY, and IN
# ANSWER TO THIS LOGIN. Both halves must pass.
#
#   stzOidcSandbox   a fee-free IDENTITY PROVIDER double (service-virtualization
#                    plane). Not a stub that answers "true": it holds an ES256
#                    keypair and really SIGNS every token with the engine, so the
#                    relying party runs its genuine check against a genuine JWKS.
#                    It can also mint deliberately BAD tokens -- which is how the
#                    negative half gets tested at all, since no real provider
#                    will issue you a broken token on request.
#   stzOidcClient    the relying party: authorization URL (state + nonce + PKCE),
#                    then verify the id-token and turn it into an identity.
#   stzAuth          LoginWithOidc -- a verified external identity opens a normal
#                    Softanza session, and yields the same governance ACTOR a
#                    local login does.
#
# The sandbox key is seeded, so this suite is reproducible.

$NOW  = 1700000000
$SEED = "00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff"

Scenario("the provider double really signs, and the relying party really verifies")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oIdp.UseSeedQ($SEED)
	Then("it publishes a JWKS, as a provider's jwks_uri would", StzJsonIsValid(oIdp.JwksJson()), TRUE)

	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetJwks( oIdp.JwksJson() )
	Then("the relying party loaded the key", oRp.NumberOfKeys(), 1)
	Then("...by its key id", oRp.KeyIds()[1], "sandbox-key-1")

	When("the provider issues an id-token for dana")
	cTok = oIdp.IssueIdTokenAt("dana", "n-abc", $NOW)
	oJwt = new stzJwt(cTok)
	Then("it is a well-formed JWT", oJwt.IsWellFormed(), TRUE)
	Then("...signed with ES256", oJwt.Algorithm(), "ES256")
	Then("...naming the subject", oJwt.Subject(), "dana")
	Then("...from the right issuer", oJwt.Issuer(), "https://idp.local")

	When("the relying party verifies it")
	aId = oRp.VerifyIdTokenAt(cTok, "n-abc", $NOW + 10)
	Then("it is accepted", aId[:ok], TRUE)
	Then("...yielding the subject", aId[:subject], "dana")
	Then("...and the asserted email", aId[:email], "dana@idp.local")
EndScenario()

Scenario("a signature that does not verify is refused -- with a REASON")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetJwks( oIdp.JwksJson() )

	When("an impostor signs a token with a DIFFERENT key")
	aR = oRp.VerifyIdTokenAt( oIdp.IssueForgedIdTokenAt("dana", "n", $NOW), "n", $NOW )
	Then("it is refused", aR[:ok], FALSE)
	Then("...because the signature fails", StzFindFirst("signature", aR[:why]) > 0, TRUE)

	When("the PAYLOAD is swapped for one claiming to be admin")
	cTok = oIdp.IssueIdTokenAt("dana", "n", $NOW)
	aParts = StzSplit(cTok, ".")
	cForged = aParts[1] + "." +
	          StzB64UrlEncode('{"iss":"https://idp.local","sub":"admin","aud":"my-app","exp":9999999999}') +
	          "." + aParts[3]
	aF = oRp.VerifyIdTokenAt(cForged, "", $NOW)
	Then("the tampering is caught", aF[:ok], FALSE)
	Then("...by the signature check, before any claim is believed", StzFindFirst("signature", aF[:why]) > 0, TRUE)

	When("the token names a key id we do not have")
	oOther = new stzOidcSandbox("https://idp.local", "my-app")
	oOther.SetKeyIdQ("some-other-key")
	aK = oRp.VerifyIdTokenAt( oOther.IssueIdTokenAt("dana", "n", $NOW), "n", $NOW )
	Then("it is refused rather than guessed at", aK[:ok], FALSE)
	Then("...naming the unknown kid", StzFindFirst("kid", aK[:why]) > 0, TRUE)
EndScenario()

Scenario("a REAL signature is still not enough -- the claims must fit this login")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetJwks( oIdp.JwksJson() )

	When("the token was minted for a DIFFERENT application")
	aA = oRp.VerifyIdTokenAt( oIdp.IssueIdTokenXT("dana", "n", $NOW, [ :aud = "another-app" ]), "n", $NOW )
	Then("it is refused (audience)", aA[:ok], FALSE)
	Then("...saying so", StzFindFirst("audience", aA[:why]) > 0, TRUE)

	When("the token comes from a DIFFERENT issuer")
	aI = oRp.VerifyIdTokenAt( oIdp.IssueIdTokenXT("dana", "n", $NOW, [ :iss = "https://evil.example" ]), "n", $NOW )
	Then("it is refused (issuer)", aI[:ok], FALSE)
	Then("...saying so", StzFindFirst("issuer", aI[:why]) > 0, TRUE)

	When("the token has expired")
	aE = oRp.VerifyIdTokenAt( oIdp.IssueExpiredIdTokenAt("dana", "n", $NOW), "n", $NOW )
	Then("it is refused (expiry)", aE[:ok], FALSE)
	Then("...saying so", StzFindFirst("expired", aE[:why]) > 0, TRUE)

	When("a VALID token is replayed against a different login's nonce")
	aN = oRp.VerifyIdTokenAt( oIdp.IssueIdTokenAt("dana", "nonce-of-login-A", $NOW), "nonce-of-login-B", $NOW )
	Then("the replay is refused (nonce)", aN[:ok], FALSE)
	Then("...which is exactly what makes a stolen id-token useless", StzFindFirst("nonce", aN[:why]) > 0, TRUE)
EndScenario()

Scenario("step 1 of the flow: sending the user to the provider, safely")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetRedirectUriQ("https://app.example/cb")

	aPkce = oRp.NewPkce()
	cUrl = oRp.AuthorizationUrlXT(oIdp.AuthorizationEndpoint(), "state-1", "nonce-1",
	                              "openid email", aPkce[:challenge])
	Then("it asks for an authorization code", StzFindFirst("response_type=code", cUrl) > 0, TRUE)
	Then("...identifying this client", StzFindFirst("client_id=my-app", cUrl) > 0, TRUE)
	Then("...with the redirect percent-encoded", StzFindFirst("redirect_uri=https%3A%2F%2Fapp.example%2Fcb", cUrl) > 0, TRUE)
	Then("...carrying state (redirect CSRF defense)", StzFindFirst("state=state-1", cUrl) > 0, TRUE)
	Then("...and nonce (replay defense)", StzFindFirst("nonce=nonce-1", cUrl) > 0, TRUE)
	Then("...plus a PKCE S256 challenge", StzFindFirst("code_challenge_method=S256", cUrl) > 0, TRUE)
	Then("the challenge is the verifier's S256 hash, so only WE can redeem the code",
	     oRp.PkceChallengeOf(aPkce[:verifier]), aPkce[:challenge])
EndScenario()

Scenario("an external identity becomes a full Softanza citizen (the phase-5 tie-in)")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetJwks( oIdp.JwksJson() )
	oAuth = new stzAuth()
	oAuth.SetOidcClient(oRp)

	When("dana signs in through the provider for the first time")
	cSess = oAuth.LoginWithOidcAt( oIdp.IssueIdTokenAt("dana", "n-1", $NOW), "n-1", $NOW )
	Then("a normal session opens", cSess != "", TRUE)
	Then("...for the identity the provider asserted", oAuth.UserOfSessionAt(cSess, $NOW), "dana@idp.local")
	Then("...the account was provisioned", oAuth.IsRegistered("dana@idp.local"), TRUE)
	Then("...holding NO usable password (the provider is the only way in)",
	     oAuth.LoginAt("dana@idp.local", "", $NOW), "")

	When("the app grants that identity a role")
	oAuth.GrantRole("dana@idp.local", "admin")
	cS2 = oAuth.LoginWithOidcAt( oIdp.IssueIdTokenAt("dana", "n-2", $NOW), "n-2", $NOW )
	oActor = oAuth.ActorOfAt(cS2, $NOW)
	Then("the external login yields a governance ACTOR", oActor.Name(), "dana@idp.local")
	Then("...carrying the role's capabilities", oActor.Can("effectful"), TRUE)
	Then("...so it is effectful like any local admin", oAuth.SessionIsEffectfulAt(cS2, $NOW), TRUE)
	# an external identity is a way IN, not a separate kind of citizen.
EndScenario()

Scenario("the local rules still apply to an external login")
	oIdp = new stzOidcSandbox("https://idp.local", "my-app")
	oRp = new stzOidcClient("https://idp.local", "my-app")
	oRp.SetJwks( oIdp.JwksJson() )

	Given("an app that admits only pre-provisioned users")
	oClosed = new stzAuth()
	oClosed.SetOidcClient(oRp)
	oClosed.SetOidcAutoProvision(FALSE)
	Then("an unknown identity is refused", oClosed.LoginWithOidcAt( oIdp.IssueIdTokenAt("newguy", "n", $NOW), "n", $NOW ), "")
	Then("...explaining why", StzFindFirst("auto-provisioning is off", oClosed.OidcWhy()) > 0, TRUE)

	Given("a user who enrolled a LOCAL second factor")
	oAuth = new stzAuth()
	oAuth.SetOidcClient(oRp)
	oAuth.RegisterPasswordless("sec@idp.local")
	oDev = StzTotpFromSecretQ( oAuth.EnableTotp("sec@idp.local", "App")[:secret] )
	oAuth.ConfirmTotp("sec@idp.local", oDev.Code())
	Then("the provider cannot bypass it", oAuth.LoginWithOidcAt( oIdp.IssueIdTokenAt("sec", "n", $NOW), "n", $NOW ), "")
	Then("...because it proved the identity, not possession of OUR factor",
	     StzFindFirst("local second factor", oAuth.OidcWhy()) > 0, TRUE)

	Given("no OIDC client bound at all")
	oBare = new stzAuth()
	bRaised = FALSE
	try
		oBare.LoginWithOidc("x", "y")
	catch
		bRaised = TRUE
	done
	Then("it refuses to silently no-op", bRaised, TRUE)
EndScenario()

Summary()
