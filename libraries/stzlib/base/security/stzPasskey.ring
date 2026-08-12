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


class stzPasskeyServer from stzObject

	@cRpId = ""       # the registrable domain a credential is bound to
	@cOrigin = ""     # the exact origin the browser will report
	@cWhy = ""

	def init(pcRpId, pcOrigin)
		@cRpId = ring_trim("" + pcRpId)
		@cOrigin = ring_trim("" + pcOrigin)

	def RpId()
		return @cRpId

	def Origin()
		return @cOrigin

	def SetOrigin(pcOrigin)
		This.SetOriginQ(pcOrigin)

	def SetOriginQ(pcOrigin)
		@cOrigin = "" + pcOrigin
		return This

	def Why()
		return @cWhy

	# a fresh, unguessable challenge. The app keeps it for the one exchange it
	# belongs to -- that is what stops a captured assertion being replayed.
	def NewChallenge()
		return StzEngineCryptoRandomHex(32)

	  #-- registration ----------------------------------------------------

	# Validate + parse what the authenticator returned ->
	# [ :ok, :credentialId, :keyType, :key1, :key2, :signCount, :why ].
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

	  #-- login -----------------------------------------------------------

	# Verify an assertion against a STORED credential
	# ([ :keyType, :key1, :key2, :signCount ]) -> [ :ok, :signCount, :why ].
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
