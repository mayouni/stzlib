#================================================================#
#  STZPASSKEYSANDBOX -- a virtual AUTHENTICATOR (a device double)  #
#================================================================#

/*--- Develop and test passkeys with no hardware and no browser.

The service-virtualization plane's device double. A passkey normally requires a
real authenticator -- Touch ID, Windows Hello, a security key -- driven by a real
browser through a user gesture. None of that fits in a test suite, which is why
passkey support so often ships under-tested exactly where it matters.

This class IS an authenticator, in software:

    oDev = new stzPasskeySandbox("example.com")
    aReg = oDev.CreateCredential(cChallenge, "https://example.com")
    #   -> [ :attestationObject, :clientData, :credentialId ]
    aAsr = oDev.Assert(cChallenge2, "https://example.com")
    #   -> [ :credentialId, :authenticatorData, :clientData, :signature ]

It is not a mock that returns "ok": it generates a real P-256 key, emits real
CBOR (a genuine attestation object with a COSE key inside), and produces real
ECDSA signatures over the 1 WebAuthn message. The relying party therefore runs
its genuine parse and verification against genuine artefacts -- and the code you
exercised here is the code that runs against a real security key.

It also does the things an ATTACKER's device would, which is the half no real
authenticator will perform on request: sign for the wrong origin, answer a
different challenge, or replay a stale signature counter (the documented
cloned-authenticator signal). That is how the negative contract gets tested.

The key is deterministic from a seed, so suites are reproducible.
*/

func StzPasskeySandboxQ(pcRpId)
	return new stzPasskeySandbox(pcRpId)


# Acts as a virtual passkey authenticator in software, with real keys and real signatures, so passkey flows are tested with no hardware or browser.
#
# It is not a mock that answers ok. It generates a real P-256 key, emits a genuine attestation
# object with a COSE key inside, and produces real ECDSA signatures over the WebAuthn message, so
# the relying party runs its true parsing and verification. It also does what an attacker's device
# would do and no real authenticator will do on request: sign for the wrong origin, or write a
# counter that does not advance, so the refusals can be tested. The key comes from the engine's
# generator, or from a seed given to CreateCredentialXT for a reproducible suite. Its keys are
# sandbox keys and never real ones.
#
#   receiver   o1 = new stzPasskeySandbox("example.com")
#   example    ? o1.IsSandbox()
#              #--> 1
#              a1 = o1.CreateCredential("challenge-1", "https://example.com")
#              ? len(a1[:credentialId]) > 0
#              #--> 1
#              a2 = o1.Assert("challenge-2", "https://example.com")
#              ? o1.SignCount()
#              #--> 1
#              ? len(a2[:signature]) > 0
#              #--> 1
#   see        stzPasskeyServer, stzServiceRegistry
class stzPasskeySandbox from stzObject

	@cRpId = ""
	@cPriv = ""        # the private key -- a SANDBOX key, never a real one
	@cCredId = ""
	@cAttObj = ""
	@nCounter = 0

	# Builds a virtual authenticator for a domain, with no credential yet and its counter at 0.
	#
	#   pcRpId     the domain its credentials are bound to
	#   returns    nothing; the object is built
	#   see        CreateCredential, IsSandbox
	def init(pcRpId)
		@cRpId = ring_trim("" + pcRpId)
		@nCounter = 0

	# TRUE if the object is a test double; here it always is, so it never passes for a real device.
	#
	#   returns    TRUE
	#   see        stzServiceRegistry
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Returns the domain the authenticator is bound to, trimmed.
	#
	#   returns    a text
	#   see        init
	def RpId()
		return @cRpId

	# Returns the id of the credential made last.
	#
	#   returns    a text; empty before CreateCredential
	#   see        CreateCredential
	def CredentialId()
		return @cCredId

	# Returns the signature counter, which each Assert advances.
	#
	#   returns    a number
	#   note       an Assert that raises for lack of a credential has already advanced it
	#   see        Assert, AssertAtCount
	def SignCount()
		return @nCounter

	# Makes a credential as a security key would, with a real P-256 key and attestation object, and returns what the browser passes on.
	#
	#   pcChallenge   the challenge the server issued
	#   pcOrigin      the origin the browser would report
	#   returns       a hash list [ :attestationObject, :clientData, :credentialId ]; the first two
	#                 are base64url
	#   note          a new key is generated each time unless the XT form is given a 32-byte hex
	#                 seed; it replaces the earlier credential and resets the counter to 0; only
	#                 invented sandbox keys, never real ones
	#   see           Assert, ClientData
	#@ aka  -- registration (the "create" ceremony) ----------------------------
	def CreateCredential(pcChallenge, pcOrigin)
		return This.CreateCredentialXT(pcChallenge, pcOrigin, "")

	# ...with a fixed 32-byte hex seed, so the credential is reproducible.
	def CreateCredentialXT(pcChallenge, pcOrigin, pcSeedHex)
		_t_ = StzEngineWebAuthnMakeCredential(@cRpId, "" + pcSeedHex)
		if _t_ = ""
			StzRaise("stzPasskeySandbox: the authenticator could not create a credential.")
		ok
		_a_ = StzSplit(_t_, "|")
		if len(_a_) != 3
			StzRaise("stzPasskeySandbox: malformed credential material from the engine.")
		ok
		@cAttObj = _a_[1]
		@cPriv = _a_[2]
		@cCredId = _a_[3]
		@nCounter = 0
		return [ :attestationObject = @cAttObj,
		         :clientData = This.ClientData("webauthn.create", pcChallenge, pcOrigin),
		         :credentialId = @cCredId ]

	# Signs a challenge as the login ceremony does, advancing the counter by one.
	#
	#   pcChallenge   the challenge the server issued
	#   pcOrigin      the origin the browser would report
	#   returns       a hash list [ :credentialId, :authenticatorData, :clientData, :signature ]
	#   warning       raises an error telling to call CreateCredential first when there is no
	#                 credential
	#   see           AssertAtCount, AssertForOrigin
	#@ aka  -- login (the "get" ceremony) --------------------------------------
	def Assert(pcChallenge, pcOrigin)
		@nCounter = @nCounter + 1
		return This.AssertAtCount(pcChallenge, pcOrigin, @nCounter)

	# Signs a challenge with a chosen counter value, which is how a cloned authenticator behaves when it does not advance.
	#
	#   pcChallenge   the challenge the server issued
	#   pcOrigin      the origin to report
	#   pnCount       the counter to write into the authenticator data
	#   returns       a hash list [ :credentialId, :authenticatorData, :clientData, :signature ]
	#   note          the stored counter is not changed
	#   warning       raises the no-credential error when there is no credential
	#   see           Assert
	#@ aka  ...at an explicit counter value. Passing one that does NOT advance is how a CLONED authenticator behaves -- the relying party must refuse it.
	def AssertAtCount(pcChallenge, pcOrigin, pnCount)
		This._RequireCredential()
		_cd_ = This.ClientData("webauthn.get", pcChallenge, pcOrigin)
		_t_ = StzEngineWebAuthnMakeAssertion(@cRpId, _cd_, @cPriv, pnCount)
		if _t_ = ""
			StzRaise("stzPasskeySandbox: the authenticator could not sign.")
		ok
		_a_ = StzSplit(_t_, "|")
		return [ :credentialId = @cCredId, :authenticatorData = _a_[1],
		         :clientData = _cd_, :signature = _a_[2] ]

	# Signs for another origin, as a phishing site would obtain, and advances the counter.
	#
	#   pcChallenge        the challenge the server issued
	#   pcPhishingOrigin   the origin to report in its place
	#   returns            a hash list [ :credentialId, :authenticatorData, :clientData, :signature
	#                      ]
	#   note               the relying party's origin check must refuse the result
	#   warning            raises the no-credential error when there is no credential
	#   see                Assert
	#@ aka  an assertion signed for a DIFFERENT origin -- what a phishing site would obtain. The relying party's origin check must reject it.
	def AssertForOrigin(pcChallenge, pcPhishingOrigin)
		@nCounter = @nCounter + 1
		return This.AssertAtCount(pcChallenge, pcPhishingOrigin, @nCounter)

	# Builds the client data JSON a browser would build, base64url-encoded.
	#
	#   pcType        webauthn.create or webauthn.get
	#   pcChallenge   the challenge
	#   pcOrigin      the origin
	#   returns       a text, base64url
	#   note          it is a test double: real client data comes from the browser
	#   warning       the challenge and the origin are written into the JSON without escaping, so a
	#                 value holding a quote can add keys or break the JSON, which is useful for
	#                 testing and wrong for real input
	#   see           CreateCredential, Assert
	#@ aka  the clientDataJSON a browser builds, base64url-encoded.
	def ClientData(pcType, pcChallenge, pcOrigin)
		return StzB64UrlEncode('{"type":"' + pcType + '","challenge":"' + pcChallenge +
		                       '","origin":"' + pcOrigin + '","crossOrigin":false}')

	# Prints one line with the domain, the credential id and the counter.
	#
	#   returns    nothing; it prints
	#   see        CredentialId
	def Show()
		? "stzPasskeySandbox(rp=" + @cRpId + ", credential=" + @cCredId + ", count=" + @nCounter + ")"

	  #-- internals -------------------------------------------------------

	def _RequireCredential()
		if @cPriv = ""
			StzRaise("stzPasskeySandbox: no credential yet -- call CreateCredential first.")
		ok
