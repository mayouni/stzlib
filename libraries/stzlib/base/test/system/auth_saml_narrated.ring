load "../../stzBase.ring"
load "../_narrated.ring"

# SAML 2.0 SINGLE SIGN-ON -- the enterprise SSO protocol.
#
# Where OIDC is what consumer apps use, SAML is what enterprises run (Okta,
# Entra/ADFS, Shibboleth). The identity provider authenticates the employee and
# POSTs back a SIGNED ASSERTION; the service provider -- your app -- decides
# whether to believe it.
#
# SAML's security is NOT really about cryptography. It is about answering "which
# bytes were signed, and is the element I am about to trust the same one the
# signature covers?" Nearly every serious SAML CVE is a wrong answer: signature
# WRAPPING, canonicalization mismatch, XXE. So the dangerous work is the engine's
# (engine/src/xmldsig.zig: a namespace-aware parser that refuses DOCTYPE/ENTITY
# outright, exclusive C14N verified byte-identical to libxml2, and enveloped
# XML-DSig), and the anti-wrapping guarantee is STRUCTURAL: after verifying, the
# engine RE-PARSES ONLY the byte range the signature covered and reads every
# claim from there. A forged assertion beside a genuine one is not ignored -- it
# is not in the bytes we parse.
#
# stzSamlServiceProvider owns the judgement the engine cannot make for you,
# because it depends on YOUR configuration: the issuer must be the IdP you trust,
# the audience must be you, the window must contain now, and an assertion must
# not be replayed.
#
# THE VECTORS ARE REAL. The assertion in fixtures/saml/ was canonicalized by lxml
# (libxml2) and signed by OpenSSL 3.5 -- neither of them ours.

$FX  = CurrentDir() + "/fixtures/saml/"
$N   = read($FX + "RSA_N.txt")
$E   = read($FX + "RSA_E.txt")
$XML = read($FX + "SIGNED.txt")
$BAD = read($FX + "TAMPERED.txt")
$WRP = read($FX + "WRAPPED.txt")

$IDP = "https://idp.acme.com"
$SP  = "https://sp.example.com"

Scenario("a genuine, OpenSSL-signed assertion is accepted")
	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	Then("it trusts nobody until told to", oSp.TrustsAnIdp(), FALSE)
	oSp.TrustIdp($IDP, "RSA", $N, $E)
	Then("...and now trusts one IdP", oSp.TrustsAnIdp(), TRUE)

	nNow = oSp._Epoch("2026-07-24T10:00:00Z")   # inside the assertion's window
	aR = oSp.ConsumeXmlAt($XML, nNow)
	Then("the assertion is accepted", aR[:ok], TRUE)
	Then("...yielding the subject", aR[:nameID], "dana@acme.com")
	Then("...from the expected issuer", aR[:issuer], $IDP)
	Then("...minted for us", aR[:audience], $SP)

	When("the very same assertion is presented again")
	aReplay = oSp.ConsumeXmlAt($XML, nNow)
	Then("it is refused", aReplay[:ok], FALSE)
	Then("...as a replay", StzFindFirst("replay", aReplay[:why]) > 0, TRUE)
EndScenario()

Scenario("a valid signature is NOT enough -- the assertion must be meant for us")
	nNow = 0

	When("the assertion names an issuer we do not trust")
	oWrongIdp = new stzSamlServiceProvider($SP, "acs")
	oWrongIdp.TrustIdp("https://someone-else.com", "RSA", $N, $E)
	nNow = oWrongIdp._Epoch("2026-07-24T10:00:00Z")
	aI = oWrongIdp.ConsumeXmlAt($XML, nNow)
	Then("it is refused", aI[:ok], FALSE)
	Then("...on the issuer (a valid signature from the WRONG IdP is someone else's user)",
	     StzFindFirst("issuer mismatch", aI[:why]) > 0, TRUE)

	When("the assertion was minted for a DIFFERENT service provider")
	oOther = new stzSamlServiceProvider("https://other-sp.example.com", "acs")
	oOther.TrustIdp($IDP, "RSA", $N, $E)
	aA = oOther.ConsumeXmlAt($XML, nNow)
	Then("it is refused", aA[:ok], FALSE)
	Then("...on the audience", StzFindFirst("audience mismatch", aA[:why]) > 0, TRUE)

	When("it is presented after its window closed")
	oLate = new stzSamlServiceProvider($SP, "acs")
	oLate.TrustIdp($IDP, "RSA", $N, $E)
	aE = oLate.ConsumeXmlAt($XML, oLate._Epoch("2026-07-24T11:00:00Z"))
	Then("it is refused as expired", aE[:ok], FALSE)
	Then("...saying so", StzFindFirst("expired", aE[:why]) > 0, TRUE)

	When("it is presented before its window opened")
	oEarly = new stzSamlServiceProvider($SP, "acs")
	oEarly.TrustIdp($IDP, "RSA", $N, $E)
	Then("it is refused as not-yet-valid",
	     oEarly.ConsumeXmlAt($XML, oEarly._Epoch("2026-07-24T08:00:00Z"))[:ok], FALSE)
EndScenario()

Scenario("tampering and SIGNATURE WRAPPING are both defeated")
	oSp = new stzSamlServiceProvider($SP, "acs")
	oSp.TrustIdp($IDP, "RSA", $N, $E)
	nNow = oSp._Epoch("2026-07-24T10:00:00Z")

	When("one claim is altered and the signature left untouched")
	aT = oSp.ConsumeXmlAt($BAD, nNow)
	Then("it is refused", aT[:ok], FALSE)
	Then("...because the digest no longer matches", StzFindFirst("digest", aT[:why]) > 0, TRUE)
	Then("...and no identity leaks out", aT[:nameID], "")

	When("a FORGED assertion is injected beside the genuine one (wrapping)")
	# the signature still verifies -- over the ORIGINAL assertion. This is exactly
	# why "did the signature verify?" cannot be the defense.
	aW = oSp.ConsumeXmlAt($WRP, nNow)
	Then("the attacker's identity NEVER surfaces", aW[:nameID] != "attacker@evil.com", TRUE)
	Then("...only the genuinely signed subject can", aW[:nameID], "dana@acme.com")
EndScenario()

Scenario("XML that cannot be trusted is refused, not parsed")
	oSp = new stzSamlServiceProvider($SP, "acs")
	oSp.TrustIdp($IDP, "RSA", $N, $E)

	Then("a DOCTYPE is refused outright (XXE closed by construction)",
	     oSp.ConsumeXmlAt("<!DOCTYPE x [<!ENTITY e SYSTEM 'file:///etc/passwd'>]><x/>", 0)[:ok], FALSE)
	Then("an unsigned document is refused", oSp.ConsumeXmlAt("<saml:Assertion xmlns:saml='urn:oasis:names:tc:SAML:2.0:assertion'/>", 0)[:ok], FALSE)
	Then("junk is refused", oSp.ConsumeXmlAt("not xml at all", 0)[:ok], FALSE)

	When("the IdP's key is the wrong one")
	oBadKey = new stzSamlServiceProvider($SP, "acs")
	oBadKey.TrustIdp($IDP, "RSA", "AAAA", $E)
	Then("it is refused", oBadKey.ConsumeXmlAt($XML, oBadKey._Epoch("2026-07-24T10:00:00Z"))[:ok], FALSE)

	Given("a service provider that trusts no IdP at all")
	oNone = new stzSamlServiceProvider($SP, "acs")
	bRaised = FALSE
	try
		oNone.ConsumeResponse("anything")
	catch
		bRaised = TRUE
	done
	Then("it refuses to operate", bRaised, TRUE)
EndScenario()

Scenario("an SSO login is a full Softanza citizen")
	oSp = new stzSamlServiceProvider($SP, "acs")
	oSp.TrustIdp($IDP, "RSA", $N, $E)
	oAuth = new stzAuth()
	oAuth.SetSamlServiceProvider(oSp)
	nNow = oSp._Epoch("2026-07-24T10:00:00Z")
	cB64 = StzB64UrlEncode($XML)   # the browser posts base64

	When("the employee arrives with the IdP's response")
	cSess = oAuth.LoginWithSamlAt(cB64, nNow)
	Then("a normal session opens", cSess != "", TRUE)
	Then("...for the asserted identity", oAuth.UserOfSessionAt(cSess, nNow), "dana@acme.com")
	Then("...auto-provisioned with NO usable password", oAuth.LoginAt("dana@acme.com", "", nNow), "")

	When("the app grants that identity a role")
	oAuth.GrantRole("dana@acme.com", "admin")
	Then("the SSO session yields the same governance ACTOR a local login would",
	     oAuth.ActorOfAt(cSess, nNow).Can("effectful"), TRUE)

	When("the same response is replayed")
	Then("it is refused", oAuth.LoginWithSamlAt(cB64, nNow), "")
	Then("...explaining why", StzFindFirst("replay", oAuth.SamlWhy()) > 0, TRUE)

	Given("no service provider bound")
	oBare = new stzAuth()
	bRaised = FALSE
	try
		oBare.LoginWithSaml("x")
	catch
		bRaised = TRUE
	done
	Then("it refuses to silently no-op", bRaised, TRUE)
EndScenario()

Scenario("SP-initiated SSO: the request we send the IdP")
	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	oSp.TrustIdp($IDP, "RSA", $N, $E)
	oSp.SetIdpSsoUrlQ($IDP + "/sso")

	cId = oSp.NewRequestId()
	Then("a request id does not start with a digit (SAML ids may not)", StzLeft(cId, 1), "_")

	cReq = oSp.AuthnRequestAt(cId, 0)
	Then("it is an AuthnRequest", StzFindFirst("AuthnRequest", cReq) > 0, TRUE)
	Then("...naming us as the issuer", StzFindFirst("<saml:Issuer>" + $SP + "</saml:Issuer>", cReq) > 0, TRUE)
	Then("...pointing back at our ACS", StzFindFirst($SP + "/acs", cReq) > 0, TRUE)
	Then("...addressed to the IdP", StzFindFirst($IDP + "/sso", cReq) > 0, TRUE)
EndScenario()

Summary()
