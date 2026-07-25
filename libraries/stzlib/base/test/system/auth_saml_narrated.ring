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

$CERT = read($FX + "IDP_CERT.pem")        # a real certificate over the SAME key
$BARE = read($FX + "IDP_CERT_BARE.txt")  # ...as metadata carries it: bare base64

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

Scenario("Softanza AS the identity provider: it issues assertions its own SP accepts")
	# The mirror of everything above -- and the piece that makes SAML developable
	# at all: no Okta tenant, no browser round-trip, yet a GENUINELY signed
	# assertion (ECDSA-SHA256 over exclusive-canonical bytes, produced by the same
	# canonicalizer the verifier uses).
	oIdp = new stzSamlIdentityProvider("https://idp.local")
	oIdp.UseSeedQ("00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff")
	oIdp.RegisterServiceProvider($SP, $SP + "/acs")
	Then("the service is registered", oIdp.HasServiceProvider($SP), TRUE)
	Then("its public key is EC", oIdp.PublicKey()[:kty], "EC")

	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	oIdp.TrustMeOn(oSp)
	Then("the SP now trusts it", oSp.IdpEntityId(), "https://idp.local")

	nNow = 1784894400
	cXml = oIdp.IssueAssertionAt("dana@acme.com", $SP, nNow)
	Then("the assertion carries a signature", StzFindFirst("<ds:SignatureValue>", cXml) > 0, TRUE)

	aR = oSp.ConsumeXmlAt(cXml, nNow + 10)
	Then("our SP accepts our IdP", aR[:ok], TRUE)
	Then("...with the right subject", aR[:nameID], "dana@acme.com")
	Then("...issuer and audience", aR[:issuer] + " -> " + aR[:audience], "https://idp.local -> " + $SP)
	# the issuer writes the timestamps and the verifier parses them back: both
	# sides agree, which is a real interop hazard when they do not.
	Then("...inside the window the IdP wrote", aR[:notOnOrAfter] != "", TRUE)
EndScenario()

Scenario("the IdP refuses to vouch carelessly, and its assertions cannot be edited")
	oIdp = new stzSamlIdentityProvider("https://idp.local")
	oIdp.RegisterServiceProvider($SP, $SP + "/acs")
	nNow = 1784894400

	When("an assertion is asked for an UNREGISTERED service")
	bRaised = FALSE
	try
		oIdp.IssueAssertionAt("dana@acme.com", "https://whoever.example", nNow)
	catch
		bRaised = TRUE
	done
	Then("it refuses at issue time", bRaised, TRUE)
	# an IdP that vouches for a user to any service that asks is an open redirect
	# for identity.

	When("a signed assertion is edited afterwards")
	oSp = new stzSamlServiceProvider($SP, "acs")
	oIdp.TrustMeOn(oSp)
	cXml = oIdp.IssueAssertionAt("dana@acme.com", $SP, nNow)
	cBad = StzReplace(cXml, "dana@acme.com", "evil@acme.com")
	Then("the SP refuses it", oSp.ConsumeXmlAt(cBad, nNow + 10)[:ok], FALSE)

	When("it is presented to an SP that trusts a DIFFERENT IdP key")
	oOtherIdp = new stzSamlIdentityProvider("https://idp.local")
	oOtherIdp.RegisterServiceProvider($SP, "acs")
	oSp2 = new stzSamlServiceProvider($SP, "acs")
	oOtherIdp.TrustMeOn(oSp2)
	Then("it is refused -- same issuer name, wrong key", oSp2.ConsumeXmlAt(cXml, nNow + 10)[:ok], FALSE)

	When("the IdP mints an assertion whose window has already closed")
	oSp3 = new stzSamlServiceProvider($SP, "acs")
	oIdp.TrustMeOn(oSp3)
	cOld = oIdp.IssueAssertionXT("dana@acme.com", $SP, nNow - 7200, 300)
	Then("the SP refuses it as expired", oSp3.ConsumeXmlAt(cOld, nNow)[:ok], FALSE)
EndScenario()

Scenario("the whole enterprise round trip, with no IdP account anywhere")
	oIdp = new stzSamlIdentityProvider("https://idp.local")
	oIdp.RegisterServiceProvider($SP, $SP + "/acs")
	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	oIdp.TrustMeOn(oSp)
	oAuth = new stzAuth()
	oAuth.SetSamlServiceProvider(oSp)
	nNow = 1784894400

	When("the IdP signs an employee in and POSTs the response")
	cB64 = oIdp.IssueResponseAt("bob@acme.com", $SP, nNow)
	cSess = oAuth.LoginWithSamlAt(cB64, nNow + 10)
	Then("a session opens", cSess != "", TRUE)
	Then("...for that employee", oAuth.UserOfSessionAt(cSess, nNow + 10), "bob@acme.com")

	When("the app gives them a role")
	oAuth.GrantRole("bob@acme.com", "member")
	Then("the SSO session yields the governance actor", oAuth.ActorOfAt(cSess, nNow + 10).Can("compute"), TRUE)
	Then("...and the same response cannot be replayed", oAuth.LoginWithSamlAt(cB64, nNow + 10), "")
EndScenario()

Scenario("trust configured from a CERTIFICATE, which is what an IdP publishes")
	# Nobody configures a real service provider by typing key components. The IdP
	# hands you a certificate; opening it is the difference between "SAML works"
	# and "SAML works with Okta". The certificate below wraps the SAME key that
	# signed the fixture assertion, so this closes the loop: cert -> key -> verify.
	aK = StzCertificateKey($CERT)
	Then("the certificate yields an RSA key", aK[:keyType], "RSA")
	aI = StzCertificateInfo($CERT)
	Then("...and says who it is for", aI[:subject], "CN=idp.acme.com")
	Then("...with a validity window", StzFindFirst("T", aI[:notAfter]) > 0, TRUE)
	Then("a fingerprint is available for out-of-band pinning", len(StzCertificateFingerprint($CERT)), 64)
	Then("garbage is not readable", StzCertificateIsReadable("not a certificate"), FALSE)

	When("a service provider trusts the IdP by that certificate")
	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	oSp.TrustIdpFromCertificate($IDP, $CERT)
	Then("it trusts an IdP", oSp.TrustsAnIdp(), TRUE)

	aR = oSp.ConsumeXmlAt($XML, oSp._Epoch("2026-07-24T10:00:00Z"))
	Then("the REAL signed assertion verifies against the certificate's key", aR[:ok], TRUE)
	Then("...yielding the subject", aR[:nameID], "dana@acme.com")

	When("the certificate arrives as BARE base64, the way XML carries it")
	oSp2 = new stzSamlServiceProvider($SP, "acs")
	oSp2.TrustIdpFromCertificate($IDP, $BARE)
	Then("it works identically", oSp2.ConsumeXmlAt($XML, oSp2._Epoch("2026-07-24T10:00:00Z"))[:ok], TRUE)
EndScenario()

Scenario("the whole SP configured from ONE paste of IdP metadata")
	cMeta = '<?xml version="1.0"?>' +
	  '<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="' + $IDP + '">' +
	  '<md:IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">' +
	  '<md:KeyDescriptor use="signing"><ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">' +
	  '<ds:X509Data><ds:X509Certificate>' + $BARE + '</ds:X509Certificate></ds:X509Data>' +
	  '</ds:KeyInfo></md:KeyDescriptor>' +
	  '<md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" ' +
	  'Location="' + $IDP + '/sso"/>' +
	  '</md:IDPSSODescriptor></md:EntityDescriptor>'

	oSp = new stzSamlServiceProvider($SP, $SP + "/acs")
	oSp.TrustIdpFromMetadata(cMeta)
	Then("the entityID came from the metadata", oSp.IdpEntityId(), $IDP)
	Then("...so did the SSO endpoint", oSp.IdpSsoUrl(), $IDP + "/sso")
	Then("...and the signing certificate", oSp.IdpCertificateInfo()[:subject], "CN=idp.acme.com")
	Then("one paste is enough to trust it", oSp.TrustsAnIdp(), TRUE)

	Then("and a real assertion from that IdP verifies",
	     oSp.ConsumeXmlAt($XML, oSp._Epoch("2026-07-24T10:00:00Z"))[:ok], TRUE)

	When("the metadata carries an ENCRYPTION certificate as well")
	# a real document usually has two; the SIGNING one is the one that matters
	cTwo = StzReplace(cMeta, '<md:KeyDescriptor use="signing">',
	    '<md:KeyDescriptor use="encryption"><ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">' +
	    '<ds:X509Data><ds:X509Certificate>' + $BARE + '</ds:X509Certificate></ds:X509Data>' +
	    '</ds:KeyInfo></md:KeyDescriptor><md:KeyDescriptor use="signing">')
	oSp2 = new stzSamlServiceProvider($SP, "acs")
	oSp2.TrustIdpFromMetadata(cTwo)
	Then("it still resolves and verifies", oSp2.ConsumeXmlAt($XML, oSp2._Epoch("2026-07-24T10:00:00Z"))[:ok], TRUE)

	When("the metadata has no certificate at all")
	oBad = new stzSamlServiceProvider($SP, "acs")
	bRaised = FALSE
	try
		oBad.TrustIdpFromMetadata('<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="x"/>')
	catch
		bRaised = TRUE
	done
	Then("it refuses rather than trusting nothing", bRaised, TRUE)

	When("the certificate in it is unreadable")
	bRaised2 = FALSE
	try
		oBad.TrustIdpFromCertificate($IDP, "-----BEGIN CERTIFICATE-----\nnonsense\n-----END CERTIFICATE-----")
	catch
		bRaised2 = TRUE
	done
	Then("it refuses", bRaised2, TRUE)
EndScenario()

Scenario("the IdP can sign RSA-SHA256, which is what many enterprise SPs require")
	# The practical gap: a good number of service providers accept RSA only, so an
	# ECDSA-only IdP cannot federate with them at all.
	cPem = StzRsaKeyPair(2048)[:privateKey]

	oIdp = new stzSamlIdentityProvider("https://idp.local")
	oIdp.UseRsaKey(cPem)
	oIdp.RegisterServiceProvider($SP, $SP + "/acs")
	Then("it signs RSA-SHA256", oIdp.SigningAlgorithm(), "RS256")
	Then("...and publishes an RSA public key", oIdp.PublicKey()[:kty], "RSA")

	oSp = new stzSamlServiceProvider($SP, "acs")
	oIdp.TrustMeOn(oSp)
	nNow = 1784894400
	cXml = oIdp.IssueAssertionAt("dana@acme.com", $SP, nNow)
	Then("the assertion declares the RSA signature method", StzFindFirst("rsa-sha256", cXml) > 0, TRUE)

	aR = oSp.ConsumeXmlAt(cXml, nNow + 10)
	Then("our SP verifies it", aR[:ok], TRUE)
	Then("...with the right subject", aR[:nameID], "dana@acme.com")

	When("an RSA-signed assertion is edited after signing")
	oSp2 = new stzSamlServiceProvider($SP, "acs")
	oIdp.TrustMeOn(oSp2)
	Then("the digest catches it",
	     oSp2.ConsumeXmlAt(StzReplace(cXml, "dana@acme.com", "evil@acme.com"), nNow + 10)[:ok], FALSE)

	Given("an ES256 IdP alongside it")
	oEc = new stzSamlIdentityProvider("https://idp.local")
	oEc.RegisterServiceProvider($SP, "acs")
	oSp3 = new stzSamlServiceProvider($SP, "acs")
	oEc.TrustMeOn(oSp3)
	Then("the ECDSA path is unaffected",
	     oSp3.ConsumeXmlAt(oEc.IssueAssertionAt("bob@acme.com", $SP, nNow), nNow + 10)[:ok], TRUE)
EndScenario()

Summary()
