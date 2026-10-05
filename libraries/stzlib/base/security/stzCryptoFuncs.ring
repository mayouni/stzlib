#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZCRYPTOFUNCS            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The library's public cryptographic helpers -- engine-backed, never hand-rolled.
# They live in base/security/ (the security concern's home) and are reusable
# anywhere: secrets, auth, the platform's identities, request signing.
#
#   * StzHashSecret(s)        -> "salt:hash"  (PBKDF2-HMAC-SHA256, 100k rounds)
#   * StzHashSecretXT(s, n)   -> same, n rounds
#   * StzVerifySecret(s, st)  -> re-derive with the stored salt, CONSTANT-TIME compare
#   * StzVerifySecretXT(...)  -> same, n rounds
#   * StzRandomToken(nBytes)  -> nBytes of CSPRNG, as hex
#
#   PASSWORDS are a different thing, and get a different hash (R3, 2026-09-29):
#   * StzHashPassword(pw)          -> "$argon2id$v=19$m=19456,t=2,p=1$..." (Argon2id)
#   * StzVerifyPassword(pw, st)    -> accepts Argon2id AND the older PBKDF2 "salt:hash"
#   * StzPasswordNeedsRehash(st)   -> 1 for a PBKDF2 hash (upgrade it on the next login)
#
#   WHY TWO. A human password is LOW-entropy: an offline attacker guesses it,
#   and only a MEMORY-hard hash makes each guess cost them real hardware.
#   StzHashSecret is for HIGH-entropy values -- random recovery codes, client
#   secrets, short-lived one-time codes -- where memory-hardness buys nothing,
#   and whose "salt:hash" form is comma-free ON PURPOSE: recovery-code hashes
#   are stored comma-joined in one column. An Argon2id string holds commas.
#
#   DATA AT REST (XChaCha20-Poly1305, authenticated):
#   * StzNewSealKey()              -> a fresh 32-byte key, as 64 hex characters
#   * StzSeal(key, plain, aad)     -> a hex blob: secret AND tamper-evident
#   * StzOpen(key, blob, aad)      -> the plaintext; RAISES on a wrong key, an
#                                     altered blob or a different aad
#
# All delegate to the Zig engine (StzEngineCryptoPbkdf2 / RandomHex / ConstEqual),
# so the cryptography is the engine's, uniform across every consumer. Loaded early
# in the security block (before stzSecret / stzAuth, which use these at runtime).

func StzHashSecret(pcSecret)
	return StzHashSecretXT(pcSecret, 100000)

func StzHashSecretXT(pcSecret, nRounds)
	_cSalt_ = StzEngineCryptoRandomHex(16)
	_cHash_ = StzEngineCryptoPbkdf2("" + pcSecret, _cSalt_, nRounds, 32)
	return _cSalt_ + ":" + _cHash_

func StzVerifySecret(pcSecret, pcStored)
	return StzVerifySecretXT(pcSecret, pcStored, 100000)

func StzVerifySecretXT(pcSecret, pcStored, nRounds)
	# a password hash handed to the older verifier still verifies
	if StzLeft("" + pcStored, 10) = "$argon2id$"
		return StzEngineCryptoArgon2idVerify("" + pcStored, "" + pcSecret) = 1
	ok
	_nSep_ = StzFindFirst(":", pcStored)
	if _nSep_ = 0
		return 0
	ok
	_cSalt_ = StzLeft(pcStored, _nSep_ - 1)
	_cHash_ = StzMidToEnd(pcStored, _nSep_ + 1)
	_cTry_ = StzEngineCryptoPbkdf2("" + pcSecret, _cSalt_, nRounds, 32)
	return StzEngineCryptoConstEqual(_cTry_, _cHash_) = 1

func StzRandomToken(nBytes)
	return StzEngineCryptoRandomHex(nBytes)

# ---- passwords: Argon2id ---------------------------------------------

func StzHashPassword(pcPassword)
	_c_ = StzEngineCryptoArgon2idHash("" + pcPassword)
	if _c_ = ""
		stzraise("StzHashPassword: the engine could not hash the password.")
	ok
	return _c_

func StzVerifyPassword(pcPassword, pcStored)
	_s_ = "" + pcStored
	if StzLeft(_s_, 10) = "$argon2id$"
		return StzEngineCryptoArgon2idVerify(_s_, "" + pcPassword) = 1
	ok
	# a hash stored before 2026-09-29: PBKDF2 "salt:hash", still accepted
	return StzVerifySecret(pcPassword, _s_)

func StzPasswordNeedsRehash(pcStored)
	if StzLeft("" + pcStored, 10) = "$argon2id$"
		return 0
	ok
	return 1

# ---- data at rest: XChaCha20-Poly1305 --------------------------------

func StzNewSealKey()
	return StzEngineCryptoRandomHex(32)

# pcAad is bound to the blob without being hidden: open it under another
# aad and it is refused. Use it to say WHAT the blob is ("store:billing").
func StzSeal(pcKeyHex, pcPlain, pcAad)
	return StzEngineCryptoSeal("" + pcKeyHex, "" + pcPlain, "" + pcAad)

func StzOpen(pcKeyHex, pcBlobHex, pcAad)
	return StzEngineCryptoOpen("" + pcKeyHex, "" + pcBlobHex, "" + pcAad)

# ---- X.509 certificates -------------------------------------------------
#
# Real federation hands you CERTIFICATES, not key components: a SAML IdP's
# metadata carries <ds:X509Certificate>, a JWKS entry may carry x5c. These open
# one (through the already-vendored mbedTLS, never hand-rolled ASN.1) and give
# back what the verifiers take.
#
# Accepts PEM or the BARE base64 DER that XML actually carries, with whitespace.

# -> [ :keyType, :key1, :key2 ] ("RSA" -> n,e ; "EC" -> x,y), or [] if unreadable.
func StzCertificateKey(pcCert)
	_r_ = StzEngineCertificateKey("" + pcCert)
	if _r_ = ""
		return []
	ok
	_a_ = StzSplit(_r_, "|")
	if len(_a_) < 3
		return []
	ok
	return [ :keyType = _a_[1], :key1 = _a_[2], :key2 = _a_[3] ]

# the SHA-256 fingerprint (hex) -- what you PIN when you cannot validate a chain,
# and what IdP documentation publishes for an out-of-band check.
func StzCertificateFingerprint(pcCert)
	return StzEngineCertificateFingerprint("" + pcCert)

# -> [ :subject, :notBefore, :notAfter ] so an operator can SEE what they trust.
func StzCertificateInfo(pcCert)
	_r_ = StzEngineCertificateDescribe("" + pcCert)
	if _r_ = ""
		return []
	ok
	_a_ = StzSplit(_r_, "|")
	if len(_a_) < 3
		return []
	ok
	return [ :subject = _a_[1], :notBefore = _a_[2], :notAfter = _a_[3] ]

func StzCertificateIsReadable(pcCert)
	return StzEngineCertificateKey("" + pcCert) != ""

# ---- RSA keys + RS256 signatures ---------------------------------------
#
# Our issuers could sign ES256 only, because Ring's engine verifies RSA but Zig's
# standard library cannot GENERATE or SIGN with it. That left Softanza able to
# consume identity from anyone yet unable to issue to everyone: plenty of
# enterprise SAML service providers and older OIDC clients take RS256 and nothing
# else. mbedTLS (already vendored for TLS) closes it.
#
# The private key travels as PEM -- ASCII, so it crosses safely -- and a real
# deployment LOADS its existing PEM rather than generating one.

# a fresh key -> [ :privateKey (PEM), :n, :e ]. 2048..4096 bits. For development
# and first runs; production supplies its own PEM.
func StzRsaKeyPair(nBits)
	_r_ = StzEngineRsaKeyPair(nBits)
	if _r_ = ""
		StzRaise("StzRsaKeyPair: could not generate a key (bits must be 2048..4096).")
	ok
	# "pem|n|e" -- a PEM contains no '|', so split from the RIGHT
	_e_ = StzFindLast("|", _r_)
	_n_ = StzFindLast("|", StzLeft(_r_, _e_ - 1))
	return [ :privateKey = StzLeft(_r_, _n_ - 1),
	         :n = StzMid(_r_, _n_ + 1, _e_ - _n_ - 1),
	         :e = StzMidToEnd(_r_, _e_ + 1) ]

# the PUBLIC parts of a private-key PEM -> [ :n, :e ], so an issuer publishes a
# JWKS from the very key it signs with.
func StzRsaPublicKey(pcPem)
	_r_ = StzEngineRsaPublicKey("" + pcPem)
	if _r_ = ""
		return []
	ok
	_a_ = StzSplit(_r_, "|")
	if len(_a_) < 2
		return []
	ok
	return [ :n = _a_[1], :e = _a_[2] ]

# RS256: sign a message with a PEM private key -> the base64url signature.
func StzRsaSign(pcMessage, pcPem)
	return StzEngineRsaSign("" + pcMessage, "" + pcPem)

func StzRsaKeyIsUsable(pcPem)
	return StzEngineRsaPublicKey("" + pcPem) != ""
