/*
	Softanza request signer -- HMAC-SHA256 authentication for node-to-node
	requests. Governance decides whether a caller MAY proceed; signing proves
	the request actually IS from that caller and was not tampered in transit.

	Each caller (key id) shares a SECRET with the grid. Sign() computes an
	HMAC-SHA256 over a canonical (method, path, body, timestamp, nonce), and
	Verify() on the receiver recomputes it. A forged or tampered request fails
	the MAC; a stale one fails the freshness window; a captured-and-replayed
	one fails the nonce check. All crypto is engine-backed (crypto.zig:
	HMAC-SHA256 + CSPRNG).

		oS = new stzRequestSigner("grid")
		oS.AddKey("web-host", "shared-secret-abc")
		env = oS.SignNow("web-host", "GET", "/work?q=x", "")   # [:kid,:ts,:nonce,:sig]
		# ... transported to the receiver, which shares the same key ...
		? oS.VerifyEnvelope("GET", "/work?q=x", "", env, 30000) # TRUE within 30s

	Replay protection: a verified (kid, nonce) is remembered for the skew
	window; a second use is rejected. Signature comparison is constant-time
	via double-HMAC (no byte-by-byte compare -- avoids both timing leaks and
	the Ring in-class char-index VM trap).
*/

func StzRequestSigner(pcName)
	return new stzRequestSigner(pcName)

class stzRequestSigner from stzObject

	@cName = ""
	@aKeys = []          # [ keyId, secret ]
	@aSeen = []          # replay cache: [ kidNonce, ts ]
	@nMaxSeen = 4096
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName
		@aKeys = []
		@aSeen = []

	def Name_()
		return @cName
	def Why()
		return @cWhy

	#-- the keyring --------------------------------------------------------

	# Register (or replace) a caller's shared secret.
	def AddKey(pcKeyId, pcSecret)
		_c_ = "" + pcKeyId
		_i_ = This._KeyIndex(_c_)
		if _i_ > 0
			@aKeys[_i_][2] = "" + pcSecret
			return This
		ok
		@aKeys + [ _c_, "" + pcSecret ]
		return This

	def HasKey(pcKeyId)
		return This._KeyIndex("" + pcKeyId) > 0

	def RemoveKey(pcKeyId)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ > 0  del(@aKeys, _i_)  ok
		return This

	def Keys()
		_a_ = []
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			_a_ + @aKeys[_i_][1]
		next
		return _a_

	#-- signing ------------------------------------------------------------

	# Sign with an EXPLICIT timestamp + nonce (deterministic; the testable
	# form). Returns the envelope [ :kid, :ts, :nonce, :sig ]. Raises if the
	# key is unknown (you cannot sign as a caller you hold no secret for).
	def Sign(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			stzraise("stzRequestSigner.Sign: unknown key '" + pcKeyId + "'.")
		ok
		_cCanon_ = This._Canonical(pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_cSig_ = This._Hmac(_cCanon_, @aKeys[_i_][2])
		return [ :kid = "" + pcKeyId, :ts = pnTs, :nonce = "" + pcNonce, :sig = _cSig_ ]

	# Sign NOW: a fresh timestamp (engine clock) and a CSPRNG nonce.
	def SignNow(pcKeyId, pcMethod, pcPath, pcBody)
		return This.Sign(pcKeyId, pcMethod, pcPath, pcBody,
			StzEngineTimeNowMs(), StzEngineCryptoRandomHex(16))

	#-- verifying ----------------------------------------------------------

	# Verify against an EXPLICIT now (deterministic form). Returns TRUE only
	# if: the key is known, the timestamp is within pnMaxSkewMs of now, the
	# signature recomputes, AND the (kid,nonce) has not been used before.
	# Why() explains a failure.
	def Verify(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig, pnMaxSkewMs, pnNowMs)
		@cWhy = ""
		# Each refusal below is also NOTED (incident I2): these four are
		# active-attacker signals -- an unknown key, a stale envelope, a
		# forged MAC, a replayed nonce -- and until now each lived only
		# in @cWhy until the next call overwrote it.
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			@cWhy = "unknown key '" + pcKeyId + "'"
			StzNoteRefusal("sig.key.unknown", "" + pcKeyId, "path:" + pcPath, @cWhy)
			return 0
		ok
		# FRESHNESS: reject stale OR future-dated (clock-skew both ways)
		_nDelta_ = pnNowMs - pnTs
		if _nDelta_ < 0  _nDelta_ = -_nDelta_  ok
		if _nDelta_ > pnMaxSkewMs
			@cWhy = "timestamp outside the freshness window (|skew| " + _nDelta_ +
				"ms > " + pnMaxSkewMs + "ms)"
			StzNoteRefusal("sig.timestamp.stale", "" + pcKeyId, "path:" + pcPath, @cWhy)
			return 0
		ok
		# INTEGRITY + AUTHENTICITY: recompute the MAC and constant-time compare
		_cCanon_ = This._Canonical(pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_cExpect_ = This._Hmac(_cCanon_, @aKeys[_i_][2])
		if NOT This._SecureEq(_cExpect_, "" + pcSig)
			@cWhy = "signature mismatch (forged, tampered, or wrong key)"
			StzNoteRefusal("sig.signature.forged", "" + pcKeyId, "path:" + pcPath, @cWhy)
			return 0
		ok
		# REPLAY: a valid signature is only accepted ONCE per nonce
		This._EvictSeen(pnNowMs, pnMaxSkewMs)
		_cMark_ = "" + pcKeyId + ":" + pcNonce
		if This._SeenIndex(_cMark_) > 0
			@cWhy = "replay detected (nonce already used for this key)"
			StzNoteRefusal("sig.nonce.replayed", "" + pcKeyId, "path:" + pcPath, @cWhy)
			return 0
		ok
		@aSeen + [ _cMark_, pnTs ]
		if len(@aSeen) > @nMaxSeen  del(@aSeen, 1)  ok
		return 1

	# Verify against the engine clock.
	def VerifyNow(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig, pnMaxSkewMs)
		return This.Verify(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig,
			pnMaxSkewMs, StzEngineTimeNowMs())

	# Verify an envelope produced by Sign()/SignNow(), against the engine clock.
	def VerifyEnvelope(pcMethod, pcPath, pcBody, paEnvelope, pnMaxSkewMs)
		return This.VerifyNow(paEnvelope[:kid], pcMethod, pcPath, pcBody,
			paEnvelope[:ts], paEnvelope[:nonce], paEnvelope[:sig], pnMaxSkewMs)

	#-- the body-only form: a WEBHOOK's X-Signature -------------------------
	#
	# A participant signs the RAW BODY it POSTs, nothing else: no method, no path, no
	# timestamp, no nonce. That is a different message from the canonical string above and
	# the same job: a keyed MAC, compared in constant time, with a replay cache and a
	# ledger line for every refusal. The HMAC runs in the engine.

	# The signature of a body under a key's secret, as hex. Raises on an unknown key.
	def SignBody(pcKeyId, pcBody)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			stzraise("stzRequestSigner.SignBody: unknown key '" + pcKeyId + "'.")
		ok
		return This._Hmac("" + pcBody, @aKeys[_i_][2])

	# Does this body carry the signature this key would give it? No replay check: one body,
	# one key. Why() explains a refusal, and the ledger hears it.
	def VerifyBody(pcKeyId, pcBody, pcSig)
		@cWhy = ""
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			@cWhy = "unknown key '" + pcKeyId + "'"
			return 0
		ok
		if NOT isString(pcSig) or pcSig = ""
			@cWhy = "unsigned"
			StzNoteRefusal("webhook.unsigned", @cName, "body:" + StzLen("" + pcBody) + " bytes", @cWhy)
			return 0
		ok
		_cExpect_ = This._Hmac("" + pcBody, @aKeys[_i_][2])
		if NOT This._SecureEq(_cExpect_, "" + pcSig)
			@cWhy = "signature mismatch (tampered body, or the wrong key)"
			StzNoteRefusal("webhook.signature.forged", @cName, "key:" + pcKeyId, @cWhy)
			return 0
		ok
		return 1

	# THE WEBHOOK VERIFIER. A hub renews a webhook's secret on a date, so a receiver may hold
	# the old and the new at once: try every key, and answer WHICH one signed it ("" when none).
	# A refusal is ONE ledger line, not one per key tried:
	#   unsigned  no signature at all
	#   forged    no key recomputes it
	#   replayed  a body already believed, inside the window (pnWindowMs from pnNowMs)
	# Outside the window the same body is a fresh delivery again: the cache is bounded by the
	# window, not by traffic. Why() explains.
	def VerifyWebhook(pcBody, pcSig, pnNowMs, pnWindowMs)
		@cWhy = ""
		if NOT isString(pcSig) or pcSig = ""
			@cWhy = "unsigned"
			StzNoteRefusal("webhook.unsigned", @cName, "body:" + StzLen("" + pcBody) + " bytes", @cWhy)
			return ""
		ok
		_cKid_ = ""
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			_cExpect_ = This._Hmac("" + pcBody, @aKeys[_i_][2])
			if This._SecureEq(_cExpect_, "" + pcSig)
				_cKid_ = @aKeys[_i_][1]
				exit
			ok
		next
		if _cKid_ = ""
			@cWhy = "signature mismatch (tampered body, or a secret this receiver does not hold)"
			StzNoteRefusal("webhook.signature.forged", @cName, "body:" + StzLen("" + pcBody) + " bytes", @cWhy)
			return ""
		ok
		This._EvictSeen(pnNowMs, pnWindowMs)
		_cMark_ = "webhook:" + _cKid_ + ":" + pcSig
		if This._SeenIndex(_cMark_) > 0
			@cWhy = "replay detected (this body was already believed inside the window)"
			StzNoteRefusal("webhook.replayed", @cName, "key:" + _cKid_, @cWhy)
			return ""
		ok
		@aSeen + [ _cMark_, pnNowMs ]
		if len(@aSeen) > @nMaxSeen  del(@aSeen, 1)  ok
		return _cKid_

	#-- internals ----------------------------------------------------------

	# An INJECTIVE canonical string: length-prefixing method/path/body means
	# no two distinct requests can collide into the same signed bytes.
	def _Canonical(pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_cM_ = "" + pcMethod  _cP_ = "" + pcPath  _cB_ = "" + pcBody
		return "" + StzLen(_cM_) + ":" + _cM_ + "|" +
		       StzLen(_cP_) + ":" + _cP_ + "|" +
		       StzLen(_cB_) + ":" + _cB_ + "|" +
		       "" + pnTs + "|" + "" + pcNonce

	# HMAC-SHA256 via the engine-backed string crypto (the canonical path:
	# it builds a real stzString whose engine handle carries the content --
	# the low-level StzEngineStringNew handle reads back EMPTY, so the MAC
	# would silently ignore the message).
	def _Hmac(pcMsg, pcSecret)
		_oC_ = new stzStringCrypto("" + pcMsg)
		return _oC_.HmacSha256("" + pcSecret)

	# Constant-time equality via DOUBLE-HMAC: re-key both sides with a fresh
	# random secret and compare the results. Equal inputs always match; for
	# unequal inputs the compared values are unpredictable, so the (possibly
	# early-exiting) '=' leaks no positional information about where they
	# differ. Avoids a byte-by-byte loop (Ring in-class char-index VM trap).
	def _SecureEq(pcA, pcB)
		if StzLen("" + pcA) != StzLen("" + pcB)  return 0  ok
		_k_ = StzEngineCryptoRandomHex(16)
		return This._Hmac(pcA, _k_) = This._Hmac(pcB, _k_)

	def _KeyIndex(pcKeyId)
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			if @aKeys[_i_][1] = pcKeyId  return _i_  ok
		next
		return 0

	def _SeenIndex(pcMark)
		_n_ = len(@aSeen)
		for _i_ = 1 to _n_
			if @aSeen[_i_][1] = pcMark  return _i_  ok
		next
		return 0

	# Drop replay-cache entries older than the freshness window -- they can
	# no longer be replayed (they'd fail the freshness check), so the cache
	# stays bounded by the window, not by total traffic.
	def _EvictSeen(pnNowMs, pnMaxSkewMs)
		_aKeep_ = []
		_n_ = len(@aSeen)
		for _i_ = 1 to _n_
			if (pnNowMs - @aSeen[_i_][2]) <= pnMaxSkewMs
				_aKeep_ + @aSeen[_i_]
			ok
		next
		@aSeen = _aKeep_
