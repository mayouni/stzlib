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
