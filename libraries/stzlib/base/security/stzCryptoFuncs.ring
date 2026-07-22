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
		return FALSE
	ok
	_cSalt_ = StzLeft(pcStored, _nSep_ - 1)
	_cHash_ = StzMidToEnd(pcStored, _nSep_ + 1)
	_cTry_ = StzEngineCryptoPbkdf2("" + pcSecret, _cSalt_, nRounds, 32)
	return StzEngineCryptoConstEqual(_cTry_, _cHash_) = 1

func StzRandomToken(nBytes)
	return StzEngineCryptoRandomHex(nBytes)
