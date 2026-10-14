#================================================================#
#  STZPASSKEY -- WebAuthn / FIDO2 passkeys (the relying party)     #
#================================================================#

/*--- Signing in with a device instead of a secret.

A passkey replaces the password with a key pair the user's device holds: the
private half never leaves the authenticator (Touch ID, Windows Hello, a YubiKey,
a phone), so there is nothing to phish, reuse, or leak in a breach. Login is a
signature over a fresh challenge.

The cryptography is the engine's (public-key verification), and so is the BINARY
parsing -- CBOR/COSE keys, the attestation object, the packed authenticator data
(see engine/src/webauthn.zig). What lives here is the RELYING PARTY's judgement,
which is where implementations actually go wrong:

  REGISTER  parse the attestation -> credential id + public key, but first check
            the clientDataJSON: its type must be "webauthn.create", its challenge
            must be the one WE issued, and its origin must be ours.
  LOGIN     the same clientData checks (type "webauthn.get"), then verify the
            signature over authData || SHA256(clientDataJSON) under the stored
            key, then require USER PRESENCE and a signature counter that has not
            gone backwards (a stalled or rewound counter is the documented signal
            of a CLONED authenticator).

The origin check is what makes a passkey unphishable: a credential minted for
example.com simply cannot be used by a look-alike site, because the browser puts
the real origin in clientDataJSON and it will not match.

Every refusal returns a reason. For development there is a virtual authenticator
-- stzPasskeySandbox in base/service/ -- that generates real keys and real
signatures, so the whole flow is exercised with no hardware.
*/

func StzPasskeyServerQ(pcRpId, pcOrigin)
	return new stzPasskeyServer(pcRpId, pcOrigin)


# Judges passkey registrations and logins as the relying party: the ceremony, the challenge, the origin, the signature, user presence and the counter.
#
# A passkey replaces the password with a key pair that the user's device holds. The cryptography and
# the parsing of the binary formats are the engine's; this class makes the relying party's
# decisions, which is where implementations fail. Registration and login both check the browser's
# client data: the ceremony type, the challenge this server issued and the origin, which is what
# makes a passkey unphishable. Login then verifies the signature under the stored key, requires user
# presence, and refuses a signature counter that did not advance, noted as a suspected clone. Two
# settings fail open and must never be empty: an empty expected challenge and an empty server origin
# each switch their check off. Every refusal returns a reason and is noted. Use stzPasskeySandbox as
# the virtual authenticator for development.
#
#   receiver   o1 = new stzPasskeyServer("example.com", "https://example.com") o2 = new
#              stzPasskeySandbox("example.com")
#   example    c1 = o1.NewChallenge()
#              a1 = o2.CreateCredential(c1, "https://example.com")
#              a2 = o1.RegisterCredential(a1[:attestationObject], a1[:clientData], c1)
#              ? a2[:ok]
#              #--> 1
#              c2 = o1.NewChallenge()
#              a3 = o2.Assert(c2, "https://example.com")
#              a4 = [ :keyType = a2[:keyType], :key1 = a2[:key1], :key2 = a2[:key2], :signCount = 0 ]
#              ? o1.VerifyAssertion(a4, a3[:authenticatorData], a3[:clientData], a3[:signature], c2)[:ok]
#              #--> 1
#              a5 = o2.AssertForOrigin(c2, "https://evil.example")
#              a6 = o1.VerifyAssertion(a4, a5[:authenticatorData], a5[:clientData], a5[:signature], c2)
#              ? a6[:ok]
#              #--> 0
#   see        stzPasskeySandbox, stzSecurityLedger, stzTotp
class stzPasskeyServer from stzObject

	@cRpId = ""       # the registrable domain a credential is bound to
	@cOrigin = ""     # the exact origin the browser will report
	@cWhy = ""

	# Builds the relying party for passkeys, bound to a domain and to the exact origin a browser will report.
	#
	#   pcRpId     the registrable domain the credentials are bound to, such as example.com
	#   pcOrigin   the exact origin, such as https://example.com
	#   returns    nothing; the object is built
	#   warning    an empty origin switches the origin check off, so any site's response is
	#              accepted: always give one
	#   see        RegisterCredential, VerifyAssertion
	def init(pcRpId, pcOrigin)
		@cRpId = ring_trim("" + pcRpId)
		@cOrigin = ring_trim("" + pcOrigin)

	# Returns the domain the credentials are bound to, trimmed.
	#
	#   returns    a text
	#   see        Origin
	def RpId()
		return @cRpId

	# Returns the origin the server demands from the browser, trimmed.
	#
	#   returns    a text
	#   see        SetOrigin, RpId
	def Origin()
		return @cOrigin

	# Replaces the origin the server demands.
	#
	#   pcOrigin   the exact origin, such as https://example.com
	#   returns    nothing; use SetOriginQ to chain
	#   note       the text is kept as given, without trimming
	#   warning    setting an empty origin switches the origin check off
	#   see        Origin
	def SetOrigin(pcOrigin)
		This.SetOriginQ(pcOrigin)

	def SetOriginQ(pcOrigin)
		@cOrigin = "" + pcOrigin
		return This

	# Returns the reason for the last refusal, or an empty text after a success.
	#
	#   returns    a text
	#   warning    the reason can quote the origin the browser reported, without escaping, so show
	#              it as text and never as markup
	#   see        RegisterCredential, VerifyAssertion
	def Why()
		return @cWhy

	# Returns a fresh random challenge of 64 hexadecimal characters from the engine's secure generator.
	#
	#   returns    a text
	#   note       keep it for the one exchange it belongs to and refuse a second use: that is what
	#              stops a replay
	#   see        RegisterCredential, VerifyAssertion
	#@ aka  a fresh, unguessable challenge. The app keeps it for the one exchange it belongs to -- that is what stops a captured assertion being replayed.
	def NewChallenge()
		return StzEngineCryptoRandomHex(32)

	# Judges the response of a device that creates a credential, and returns the credential to store.
	#
	#   pcAttObjB64           the attestation object, base64url
	#   pcClientDataB64       the client data JSON, base64url
	#   pcExpectedChallenge   the challenge this server issued for this exchange
	#   returns               a hash list [ :ok, :credentialId, :keyType, :key1, :key2, :signCount,
	#                         :why ]; :ok is 1 only when every check passed, and :why says what
	#                         failed
	#   note                  the checks are the ceremony type webauthn.create, the challenge, the
	#                         origin and the user-presence flag
	#   warning               an empty expected challenge skips the challenge check, so a response
	#                         to any earlier challenge is accepted; an empty server origin skips the
	#                         origin check; it never raises, a refusal is returned
	#   see                   VerifyAssertion, NewChallenge
	#@ aka  -- registration ----------------------------------------------------
	def RegisterCredential(pcAttObjB64, pcClientDataB64, pcExpectedChallenge)
		if NOT This._ClientDataIsSound(pcClientDataB64, "webauthn.create", pcExpectedChallenge)
			return [ :ok = 0, :credentialId = "", :keyType = "", :key1 = "",
			         :key2 = "", :signCount = 0, :why = @cWhy ]
		ok
		_p_ = StzEngineWebAuthnParseAttestation("" + pcAttObjB64)
		if _p_ = ""
			return This._RefuseReg("the attestation object could not be parsed")
		ok
		_a_ = StzSplit(_p_, "|")
		if len(_a_) < 6
			return This._RefuseReg("the attestation object is incomplete")
		ok
		# flags bit 0x40 (AT) must be set for a registration, and 0x01 (UP) means
		# the human actually touched the device.
		_flags_ = 0 + _a_[6]
		if (_flags_ & 1) = 0
			return This._RefuseReg("the authenticator did not report user presence")
		ok
		@cWhy = ""
		return [ :ok = 1, :credentialId = _a_[1], :keyType = _a_[2],
		         :key1 = _a_[3], :key2 = _a_[4], :signCount = 0 + _a_[5], :why = "" ]

	# Judges a login response against a stored credential: client data, signature, user presence and the signature counter.
	#
	#   paCredential          the stored credential as a hash list [ :keyType, :key1, :key2,
	#                         :signCount ]
	#   pcAuthDataB64         the authenticator data, base64url
	#   pcClientDataB64       the client data JSON, base64url
	#   pcSigB64              the signature, base64url
	#   pcExpectedChallenge   the challenge issued for this login
	#   returns               a hash list [ :ok, :signCount, :why ]; :signCount is the new counter
	#                         to store
	#   note                  every refusal is noted as auth.passkey.failed; a refusal returns, it
	#                         never raises
	#   warning               an empty expected challenge skips the challenge check, so a captured
	#                         assertion could be replayed; an empty server origin skips the origin
	#                         check; a counter that does not advance past the stored one is refused
	#                         and noted as a suspected clone, while a counter of 0 is allowed
	#   see                   RegisterCredential, NewChallenge
	#@ aka  -- login -----------------------------------------------------------
	def VerifyAssertion(paCredential, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge)
		# A clientData failure is an origin or challenge mismatch -- the
		# anti-phishing check. It used to return before the refusal
		# helper, so it noted nothing; it goes through it now (I2).
		if NOT This._ClientDataIsSound(pcClientDataB64, "webauthn.get", pcExpectedChallenge)
			return This._RefuseAssert(@cWhy)
		ok
		_v_ = StzEngineWebAuthnVerify("" + pcAuthDataB64, "" + pcClientDataB64, "" + pcSigB64,
		          "" + paCredential[:keyType], "" + paCredential[:key1], "" + paCredential[:key2])
		if _v_ != 1
			return This._RefuseAssert("the signature does not verify for this credential")
		ok
		_m_ = StzEngineWebAuthnParseAuthData("" + pcAuthDataB64)
		if _m_ = ""
			return This._RefuseAssert("the authenticator data could not be parsed")
		ok
		_a_ = StzSplit(_m_, "|")
		if len(_a_) < 2
			return This._RefuseAssert("the authenticator data is incomplete")
		ok
		_flags_ = 0 + _a_[1]
		_count_ = 0 + _a_[2]
		if (_flags_ & 1) = 0
			return This._RefuseAssert("the authenticator did not report user presence")
		ok
		# A counter that fails to advance is the documented signal of a cloned
		# authenticator. Zero means the device does not keep one at all (allowed).
		# It is also the one indicator in this module worth waking someone for,
		# so it is NOTED as an error-severity event (incident I2), not merely
		# returned to the caller who asked.
		_stored_ = 0 + paCredential[:signCount]
		if _count_ > 0 and _count_ <= _stored_
			StzNoteRefusal("auth.passkey.clone_suspected", @cRpId, "credential:signCount=" + _count_,
				"the signature counter did not advance (stored " + _stored_ + ", presented " + _count_ + ")")
			return This._RefuseAssert("the signature counter did not advance -- a cloned authenticator is possible")
		ok
		@cWhy = ""
		return [ :ok = 1, :signCount = _count_, :why = "" ]

	# Prints one line with the domain and the origin.
	#
	#   returns    nothing; it prints
	#   see        Origin
	def Show()
		? "stzPasskeyServer(rp=" + @cRpId + ", origin=" + @cOrigin + ")"

	  #-- internals -------------------------------------------------------

	# clientDataJSON is what the BROWSER attests to: the ceremony type, the
	# challenge it was answering, and the true origin it ran on.
	def _ClientDataIsSound(pcClientDataB64, pcExpectedType, pcExpectedChallenge)
		_j_ = StzEngineCryptoB64UrlDecode("" + pcClientDataB64)
		if _j_ = "" or NOT StzJsonIsValid(_j_)
			@cWhy = "the client data is not valid JSON"
			return 0
		ok
		if StzJsonGet(_j_, "type") != ("" + pcExpectedType)
			@cWhy = "wrong ceremony type (expected " + pcExpectedType + ")"
			return 0
		ok
		if ("" + pcExpectedChallenge) != ""
			if StzJsonGet(_j_, "challenge") != ("" + pcExpectedChallenge)
				@cWhy = "challenge mismatch -- this response does not answer this request"
				return 0
			ok
		ok
		if @cOrigin != ""
			if StzJsonGet(_j_, "origin") != @cOrigin
				@cWhy = "origin mismatch: '" + StzJsonGet(_j_, "origin") +
				        "' is not '" + @cOrigin + "' (this is what makes a passkey unphishable)"
				return 0
			ok
		ok
		@cWhy = ""
		return 1

	def _RefuseReg(pcWhy)
		@cWhy = "" + pcWhy
		return [ :ok = 0, :credentialId = "", :keyType = "", :key1 = "",
		         :key2 = "", :signCount = 0, :why = @cWhy ]

	def _RefuseAssert(pcWhy)
		@cWhy = "" + pcWhy
		# every assertion refusal is noted (I2); the clone signal above
		# notes its own, more specific kind first
		StzNoteRefusal("auth.passkey.failed", @cRpId, "origin:" + @cOrigin, @cWhy)
		return [ :ok = 0, :signCount = 0, :why = @cWhy ]
