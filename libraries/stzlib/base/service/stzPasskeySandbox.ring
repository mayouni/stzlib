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


class stzPasskeySandbox from stzObject

	@cRpId = ""
	@cPriv = ""        # the private key -- a SANDBOX key, never a real one
	@cCredId = ""
	@cAttObj = ""
	@nCounter = 0

	def init(pcRpId)
		@cRpId = ring_trim("" + pcRpId)
		@nCounter = 0

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	def RpId()
		return @cRpId

	def CredentialId()
		return @cCredId

	def SignCount()
		return @nCounter

	  #-- registration (the "create" ceremony) ----------------------------

	# Make a credential the way a security key would ->
	# [ :attestationObject, :clientData, :credentialId ].
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

	  #-- login (the "get" ceremony) --------------------------------------

	# Sign a challenge -> [ :credentialId, :authenticatorData, :clientData,
	# :signature ]. The counter advances, as a real authenticator's does.
	def Assert(pcChallenge, pcOrigin)
		@nCounter = @nCounter + 1
		return This.AssertAtCount(pcChallenge, pcOrigin, @nCounter)

	# ...at an explicit counter value. Passing one that does NOT advance is how a
	# CLONED authenticator behaves -- the relying party must refuse it.
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

	# an assertion signed for a DIFFERENT origin -- what a phishing site would
	# obtain. The relying party's origin check must reject it.
	def AssertForOrigin(pcChallenge, pcPhishingOrigin)
		@nCounter = @nCounter + 1
		return This.AssertAtCount(pcChallenge, pcPhishingOrigin, @nCounter)

	# the clientDataJSON a browser builds, base64url-encoded.
	def ClientData(pcType, pcChallenge, pcOrigin)
		return StzB64UrlEncode('{"type":"' + pcType + '","challenge":"' + pcChallenge +
		                       '","origin":"' + pcOrigin + '","crossOrigin":false}')

	def Show()
		? "stzPasskeySandbox(rp=" + @cRpId + ", credential=" + @cCredId + ", count=" + @nCounter + ")"

	  #-- internals -------------------------------------------------------

	def _RequireCredential()
		if @cPriv = ""
			StzRaise("stzPasskeySandbox: no credential yet -- call CreateCredential first.")
		ok
