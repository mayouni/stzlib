load "../../stzBase.ring"
load "../_narrated.ring"

# PASSKEYS (WebAuthn / FIDO2) -- signing in with a device instead of a secret.
#
# The private key never leaves the user's authenticator, so there is nothing to
# phish, reuse, or steal in a breach. Login is a signature over a fresh challenge.
#
# The engine does the parts Ring cannot: public-key verification, and the BINARY
# parsing a passkey drags along -- CBOR/COSE keys, the attestation object, the
# packed authenticator data (raw bytes cannot cross the UTF-8-validating boundary,
# so it all stays engine-side and only base64url travels).
#
# What is tested here is mostly JUDGEMENT, which is where implementations fail:
# the origin must be ours (this is what makes a passkey unphishable), the
# challenge must be the one we issued (replay), user presence must be reported,
# and the signature counter must ADVANCE (a stalled counter is the documented
# signal of a cloned authenticator).
#
# stzPasskeySandbox is a virtual AUTHENTICATOR -- a real P-256 key emitting real
# CBOR and real signatures, so no hardware or browser is needed. It also does what
# an attacker's device would (sign for the wrong origin, replay a counter), which
# no real security key will do on request -- that is how the negative half of the
# contract gets tested at all.

$RP     = "example.com"
$ORIGIN = "https://example.com"
$NOW    = 1700000000
$cDb    = WorkingDirectory() + "/_authtest_passkey.db"

Scenario("enrolling a device: the relying party stores a public key, never a secret")
	oAuth = new stzAuth()
	oAuth.SetPasskeyRelyingParty($RP, $ORIGIN)
	oAuth.Register("dana", "pw")
	oDev = new stzPasskeySandbox($RP)

	When("the app issues a challenge and the authenticator answers it")
	cCh = oAuth.NewPasskeyChallenge()
	Then("the challenge is unguessable (256-bit)", len(cCh), 64)
	aReg = oDev.CreateCredential(cCh, $ORIGIN)
	Then("the device returned an attestation object", aReg[:attestationObject] != "", TRUE)

	Then("the credential is accepted", oAuth.RegisterPasskey("dana", aReg[:attestationObject], aReg[:clientData], cCh), TRUE)
	Then("...and enrolled for that user", oAuth.NumberOfPasskeys("dana"), 1)
	Then("...keyed by the id the authenticator chose", oAuth.PasskeysOf("dana")[1][:credentialId], aReg[:credentialId])
	Then("...storing an EC public key", oAuth.PasskeysOf("dana")[1][:keyType], "EC")
	Then("...and the user now has a passkey", oAuth.HasPasskey("dana"), TRUE)
EndScenario()

Scenario("logging in: a signature over a fresh challenge")
	oAuth = new stzAuth()
	oAuth.SetPasskeyRelyingParty($RP, $ORIGIN)
	oAuth.Register("dana", "pw")
	oDev = new stzPasskeySandbox($RP)
	cReg = oAuth.NewPasskeyChallenge()
	aReg = oDev.CreateCredential(cReg, $ORIGIN)
	oAuth.RegisterPasskey("dana", aReg[:attestationObject], aReg[:clientData], cReg)

	When("the user signs a login challenge with their device")
	cCh = oAuth.NewPasskeyChallenge()
	aAsr = oDev.Assert(cCh, $ORIGIN)
	cSess = oAuth.LoginWithPasskeyAt(aAsr[:credentialId], aAsr[:authenticatorData],
	                                 aAsr[:clientData], aAsr[:signature], cCh, $NOW)
	Then("a session opens", cSess != "", TRUE)
	Then("...for the right user", oAuth.UserOfSessionAt(cSess, $NOW), "dana")

	When("a second, later login is made")
	cCh2 = oAuth.NewPasskeyChallenge()
	aA2 = oDev.Assert(cCh2, $ORIGIN)
	Then("it also succeeds (the counter advanced)",
	     oAuth.LoginWithPasskeyAt(aA2[:credentialId], aA2[:authenticatorData], aA2[:clientData], aA2[:signature], cCh2, $NOW) != "", TRUE)
EndScenario()

Scenario("the origin check is what makes a passkey UNPHISHABLE")
	oAuth = new stzAuth()
	oAuth.SetPasskeyRelyingParty($RP, $ORIGIN)
	oAuth.Register("dana", "pw")
	oDev = new stzPasskeySandbox($RP)
	cReg = oAuth.NewPasskeyChallenge()
	aReg = oDev.CreateCredential(cReg, $ORIGIN)
	oAuth.RegisterPasskey("dana", aReg[:attestationObject], aReg[:clientData], cReg)

	When("a look-alike site (evi1-example.com) gets the user to sign")
	cCh = oAuth.NewPasskeyChallenge()
	aPh = oDev.AssertForOrigin(cCh, "https://evi1-example.com")
	Then("the login is REFUSED", oAuth.LoginWithPasskeyAt(aPh[:credentialId], aPh[:authenticatorData], aPh[:clientData], aPh[:signature], cCh, $NOW), "")
	Then("...on the origin, not the signature (which was perfectly valid)",
	     StzFindFirst("origin mismatch", oAuth.PasskeyWhy()) > 0, TRUE)
	# a stolen password works anywhere; a passkey simply cannot leave its origin.
EndScenario()

Scenario("replay and cloning are refused")
	oAuth = new stzAuth()
	oAuth.SetPasskeyRelyingParty($RP, $ORIGIN)
	oAuth.Register("dana", "pw")
	oDev = new stzPasskeySandbox($RP)
	cReg = oAuth.NewPasskeyChallenge()
	aReg = oDev.CreateCredential(cReg, $ORIGIN)
	oAuth.RegisterPasskey("dana", aReg[:attestationObject], aReg[:clientData], cReg)

	When("a captured assertion is presented against a DIFFERENT challenge")
	cCh = oAuth.NewPasskeyChallenge()
	aAsr = oDev.Assert(cCh, $ORIGIN)
	Then("it is refused", oAuth.LoginWithPasskeyAt(aAsr[:credentialId], aAsr[:authenticatorData], aAsr[:clientData], aAsr[:signature], "some-other-challenge", $NOW), "")
	Then("...as a challenge mismatch", StzFindFirst("challenge mismatch", oAuth.PasskeyWhy()) > 0, TRUE)

	When("a CLONED authenticator presents a counter that does not advance")
	# first, a genuine login moves the stored counter forward
	cCh2 = oAuth.NewPasskeyChallenge()
	aOk = oDev.Assert(cCh2, $ORIGIN)
	oAuth.LoginWithPasskeyAt(aOk[:credentialId], aOk[:authenticatorData], aOk[:clientData], aOk[:signature], cCh2, $NOW)
	cCh3 = oAuth.NewPasskeyChallenge()
	aClone = oDev.AssertAtCount(cCh3, $ORIGIN, 1)   # a stale counter
	Then("the login is refused", oAuth.LoginWithPasskeyAt(aClone[:credentialId], aClone[:authenticatorData], aClone[:clientData], aClone[:signature], cCh3, $NOW), "")
	Then("...naming the clone signal", StzFindFirst("cloned authenticator", oAuth.PasskeyWhy()) > 0, TRUE)

	When("an unknown credential id is presented")
	Then("it is refused", oAuth.LoginWithPasskeyAt("no-such-credential", aOk[:authenticatorData], aOk[:clientData], aOk[:signature], cCh2, $NOW), "")
	Then("...as unknown", oAuth.PasskeyWhy(), "unknown credential")
EndScenario()

Scenario("a credential belongs to ONE device, and a user may hold several")
	oAuth = new stzAuth()
	oAuth.SetPasskeyRelyingParty($RP, $ORIGIN)
	oAuth.Register("dana", "pw")

	Given("dana enrolls a laptop and a phone")
	oLaptop = new stzPasskeySandbox($RP)
	oPhone = new stzPasskeySandbox($RP)
	c1 = oAuth.NewPasskeyChallenge()
	r1 = oLaptop.CreateCredential(c1, $ORIGIN)
	oAuth.RegisterPasskey("dana", r1[:attestationObject], r1[:clientData], c1)
	c2 = oAuth.NewPasskeyChallenge()
	r2 = oPhone.CreateCredential(c2, $ORIGIN)
	oAuth.RegisterPasskey("dana", r2[:attestationObject], r2[:clientData], c2)
	Then("both devices are enrolled", oAuth.NumberOfPasskeys("dana"), 2)
	Then("...with different credential ids", r1[:credentialId] != r2[:credentialId], TRUE)

	When("either device signs in")
	c3 = oAuth.NewPasskeyChallenge()
	a3 = oPhone.Assert(c3, $ORIGIN)
	Then("it works", oAuth.LoginWithPasskeyAt(a3[:credentialId], a3[:authenticatorData], a3[:clientData], a3[:signature], c3, $NOW) != "", TRUE)

	When("the laptop is lost and un-enrolled")
	oAuth.RemovePasskey(r1[:credentialId])
	Then("only the phone remains", oAuth.NumberOfPasskeys("dana"), 1)
	Then("...and the account is untouched", oAuth.IsRegistered("dana"), TRUE)
	c4 = oAuth.NewPasskeyChallenge()
	a4 = oPhone.Assert(c4, $ORIGIN)
	Then("...the phone still signs in", oAuth.LoginWithPasskeyAt(a4[:credentialId], a4[:authenticatorData], a4[:clientData], a4[:signature], c4, $NOW) != "", TRUE)
EndScenario()

Scenario("a passkey login is a full citizen, and credentials are durable")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.SetPasskeyRelyingParty($RP, $ORIGIN)
	oA1.RegisterPasswordless("dana@corp.com")     # no password at all -- device only
	oA1.GrantRole("dana@corp.com", "admin")
	oDev = new stzPasskeySandbox($RP)
	c1 = oA1.NewPasskeyChallenge()
	r1 = oDev.CreateCredential(c1, $ORIGIN)
	oA1.RegisterPasskey("dana@corp.com", r1[:attestationObject], r1[:clientData], c1)

	When("a SEPARATE stzAuth opens the same database")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	oA2.SetPasskeyRelyingParty($RP, $ORIGIN)
	Then("the credential persisted", oA2.NumberOfPasskeys("dana@corp.com"), 1)

	c2 = oA2.NewPasskeyChallenge()
	a2 = oDev.Assert(c2, $ORIGIN)
	cSess = oA2.LoginWithPasskeyAt(a2[:credentialId], a2[:authenticatorData], a2[:clientData], a2[:signature], c2, $NOW)
	Then("...and it signs in there", cSess != "", TRUE)
	Then("...yielding the governance ACTOR its role grants", oA2.ActorOfAt(cSess, $NOW).Can("effectful"), TRUE)
	Then("...with no password anywhere in the account", oA2.LoginAt("dana@corp.com", "", $NOW), "")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Scenario("a passkey cannot be used before the relying party is declared")
	oBare = new stzAuth()
	bRaised = FALSE
	try
		oBare.NewPasskeyChallenge()
	catch
		bRaised = TRUE
	done
	Then("it refuses to operate without an rp id and origin", bRaised, TRUE)
EndScenario()

Summary()
