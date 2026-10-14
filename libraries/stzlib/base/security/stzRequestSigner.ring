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

# Signs and verifies requests between nodes and webhook bodies with HMAC-SHA256, refusing forged, stale and replayed ones.
#
# Governance decides whether a caller may proceed; signing proves the request is from that caller
# and was not altered. Each caller key id shares a secret with the receiver. Sign computes an HMAC-
# SHA256 over a length-prefixed canonical form of the method, path, body, timestamp and nonce;
# Verify recomputes it and also demands a fresh timestamp and a nonce not used before, remembered
# for the freshness window. The comparison is constant-time through a double HMAC. A second form,
# SignBody, VerifyBody and VerifyWebhook, covers a webhook that signs only its raw body, and tries
# every held key so that an old and a new secret can overlap. Every refusal returns a reason and is
# noted in the process security ledger when one is open, with the caveats written on Verify. Secrets
# in examples here are invented.
#
#   receiver   o1 = new stzRequestSigner("grid") o1.AddKey("web-host", "invented-secret-A")
#   example    a1 = o1.Sign("web-host", "GET", "/work?q=x", "", 1000000, "n-1")
#              ? len(a1[:sig])
#              #--> 64
#              ? o1.Verify("web-host", "GET", "/work?q=x", "", 1000000, "n-1", a1[:sig], 30000, 1010000)
#              #--> 1
#              ? o1.Verify("web-host", "GET", "/work?q=x", "", 1000000, "n-1", a1[:sig], 30000, 1010000)
#              #--> 0
#              ? o1.Why()
#              #--> replay detected (nonce already used for this key)
#   see        stzSecurityLedger, stzSecretStore, stzTotp
class stzRequestSigner from stzObject

	@cName = ""
	@aKeys = []          # [ keyId, secret ]
	@aSeen = []          # replay cache: [ kidNonce, ts ]
	@nMaxSeen = 4096
	@cWhy = ""

	# Builds a request signer with a name and an empty keyring and replay cache.
	#
	#   pcName     the signer's name, recorded as the actor of webhook refusals
	#   returns    nothing; the object is built
	#   see        AddKey, Sign
	def init(pcName)
		@cName = "" + pcName
		@aKeys = []
		@aSeen = []

	# Returns the name the signer was built with.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName
	# Returns the reason for the last refusal, or an empty text after a success.
	#
	#   returns    a text
	#   warning    the reason quotes the key id of an unknown caller as it arrived, without
	#              escaping, so show it as text and never as markup
	#   see        Verify, VerifyBody, VerifyWebhook
	def Why()
		return @cWhy

	# Registers a caller's shared secret under a key id, replacing the secret when the id is already there.
	#
	#   pcKeyId    the caller's key id
	#   pcSecret   the shared secret, held in memory as given
	#   returns    the signer itself, so calls chain
	#   note       use an invented or generated secret in examples and tests, and keep real ones in
	#              a secret store
	#   see        HasKey, RemoveKey, Sign
	#@ aka  -- the keyring --------------------------------------------------------
	def AddKey(pcKeyId, pcSecret)
		_c_ = "" + pcKeyId
		_i_ = This._KeyIndex(_c_)
		if _i_ > 0
			@aKeys[_i_][2] = "" + pcSecret
			return This
		ok
		@aKeys + [ _c_, "" + pcSecret ]
		return This

	# TRUE if a secret is registered under that key id.
	#
	#   pcKeyId    the key id to look for
	#   returns    TRUE or FALSE
	#   see        AddKey, Keys
	def HasKey(pcKeyId)
		return This._KeyIndex("" + pcKeyId) > 0

	# Removes a caller's secret from the keyring; an unknown key id changes nothing.
	#
	#   pcKeyId    the key id to remove
	#   returns    the signer itself, so calls chain
	#   see        AddKey, Keys
	def RemoveKey(pcKeyId)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ > 0  del(@aKeys, _i_)  ok
		return This

	# Returns the registered key ids; never the secrets.
	#
	#   returns    a list of text
	#   see        HasKey, AddKey
	def Keys()
		_a_ = []
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			_a_ + @aKeys[_i_][1]
		next
		return _a_

	# Makes the HMAC-SHA256 envelope of a request from an explicit timestamp and nonce, the deterministic form for tests.
	#
	#   pcKeyId    the caller's key id
	#   pcMethod   the HTTP method
	#   pcPath     the path with its query
	#   pcBody     the body text
	#   pnTs       the time in milliseconds
	#   pcNonce    a value never used before for this key
	#   returns    a hash list [ :kid, :ts, :nonce, :sig ]; sig is 64 hexadecimal characters
	#   note       the signed text is length-prefixed, so two different requests never produce the
	#              same bytes
	#   warning    raises an error naming the key id when no secret is held for it
	#   see        SignNow, Verify
	#@ aka  -- signing ------------------------------------------------------------
	def Sign(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			stzraise("stzRequestSigner.Sign: unknown key '" + pcKeyId + "'.")
		ok
		_cCanon_ = This._Canonical(pcMethod, pcPath, pcBody, pnTs, pcNonce)
		_cSig_ = This._Hmac(_cCanon_, @aKeys[_i_][2])
		return [ :kid = "" + pcKeyId, :ts = pnTs, :nonce = "" + pcNonce, :sig = _cSig_ ]

	# Signs a request with the engine clock and a fresh 32-character random nonce.
	#
	#   pcKeyId    the caller's key id
	#   pcMethod   the HTTP method
	#   pcPath     the path with its query
	#   pcBody     the body text
	#   returns    a hash list [ :kid, :ts, :nonce, :sig ]
	#   warning    raises an error naming the key id when no secret is held for it
	#   see        Sign, VerifyEnvelope
	#@ aka  Sign NOW: a fresh timestamp (engine clock) and a CSPRNG nonce.
	def SignNow(pcKeyId, pcMethod, pcPath, pcBody)
		return This.Sign(pcKeyId, pcMethod, pcPath, pcBody,
			StzEngineTimeNowMs(), StzEngineCryptoRandomHex(16))

	# Judges a signed request against an explicit current time: known key, fresh timestamp, matching signature, and a nonce not seen before.
	#
	#   pcKeyId       the caller's key id
	#   pcMethod      the HTTP method
	#   pcPath        the path with its query
	#   pcBody        the body text
	#   pnTs          the signed time
	#   pcNonce       the signed nonce
	#   pcSig         the signature received
	#   pnMaxSkewMs   the freshness window in milliseconds, both ways
	#   pnNowMs       the current time in milliseconds
	#   returns       TRUE if every check passed, else FALSE with the reason in Why
	#   note          a valid request is accepted once: its nonce is remembered for the window; the
	#                 signature is compared in constant time
	#   warning       every refusal is noted in the process security ledger when one is open, as
	#                 sig.key.unknown, sig.timestamp.stale, sig.signature.forged or
	#                 sig.nonce.replayed; the note holds the path with its query string, so a token
	#                 placed in a query string reaches the ledger, and an unknown key id is written
	#                 as received, line breaks included, which a text view of the ledger shows as a
	#                 forged extra line
	#   see           VerifyNow, VerifyEnvelope, Sign
	#@ aka  -- verifying ----------------------------------------------------------
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

	# Judges a signed request as Verify does, taking the current time from the engine clock.
	#
	#   pcKeyId       the caller's key id
	#   pcMethod      the HTTP method
	#   pcPath        the path with its query
	#   pcBody        the body text
	#   pnTs          the signed time
	#   pcNonce       the signed nonce
	#   pcSig         the signature received
	#   pnMaxSkewMs   the freshness window in milliseconds
	#   returns       TRUE or FALSE, with the reason in Why
	#   warning       the notes written to the ledger are those of Verify
	#   see           Verify, VerifyEnvelope
	#@ aka  Verify against the engine clock.
	def VerifyNow(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig, pnMaxSkewMs)
		return This.Verify(pcKeyId, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig,
			pnMaxSkewMs, StzEngineTimeNowMs())

	# Judges a request together with the envelope that Sign or SignNow made for it, against the engine clock.
	#
	#   pcMethod      the HTTP method
	#   pcPath        the path with its query
	#   pcBody        the body text
	#   paEnvelope    the hash list [ :kid, :ts, :nonce, :sig ]
	#   pnMaxSkewMs   the freshness window in milliseconds
	#   returns       TRUE or FALSE, with the reason in Why
	#   note          a second use of the same envelope is refused as a replay
	#   see           Verify, SignNow
	#@ aka  Verify an envelope produced by Sign()/SignNow(), against the engine clock.
	def VerifyEnvelope(pcMethod, pcPath, pcBody, paEnvelope, pnMaxSkewMs)
		return This.VerifyNow(paEnvelope[:kid], pcMethod, pcPath, pcBody,
			paEnvelope[:ts], paEnvelope[:nonce], paEnvelope[:sig], pnMaxSkewMs)

	# Signs the raw body of a webhook delivery alone, with no method, path, time or nonce.
	#
	#   pcKeyId    the key id whose secret signs
	#   pcBody     the body text
	#   returns    a text, the HMAC-SHA256 in 64 hexadecimal characters
	#   note       without a time or a nonce the signature alone does not prevent a replay: use
	#              VerifyWebhook for that
	#   warning    raises an error naming the key id when no secret is held for it
	#   see        VerifyBody, VerifyWebhook
	#@ aka  -- the body-only form: a WEBHOOK's X-Signature -------------------------
	def SignBody(pcKeyId, pcBody)
		_i_ = This._KeyIndex("" + pcKeyId)
		if _i_ = 0
			stzraise("stzRequestSigner.SignBody: unknown key '" + pcKeyId + "'.")
		ok
		return This._Hmac("" + pcBody, @aKeys[_i_][2])

	# Judges a webhook body against the signature a given key would give it, with no replay check.
	#
	#   pcKeyId    the key id to verify with
	#   pcBody     the body text
	#   pcSig      the signature received
	#   returns    TRUE or FALSE, with the reason in Why
	#   note       an unknown key id is refused without a ledger note
	#   warning    a missing signature is noted as webhook.unsigned and a mismatch as
	#              webhook.signature.forged
	#   see        SignBody, VerifyWebhook
	#@ aka  Does this body carry the signature this key would give it? No replay check: one body, one key. Why() explains a refusal, and the ledger hears it.
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

	# Finds which registered key signed a webhook body, refusing a forged, missing or repeated delivery; the key may be the old or the new one.
	#
	#   pcBody       the raw body
	#   pcSig        the signature received
	#   pnNowMs      the current time in milliseconds
	#   pnWindowMs   how long a believed body counts as a replay
	#   returns      a text, the key id that signed it; an empty text when refused, with the reason
	#                in Why
	#   note         outside the window the same body is accepted again as a fresh delivery
	#   warning      a refusal is one ledger note, webhook.unsigned, webhook.signature.forged or
	#                webhook.replayed
	#   see          VerifyBody, SignBody
	#@ aka  THE WEBHOOK VERIFIER. A hub renews a webhook's secret on a date, so a receiver may hold the old and the new at once: try every key, and answer WHICH one signed it ("" when none). A refusal is ONE ledger line, not one per key tried: unsigned no signature at all forged no key recomputes it replayed a body already believed, inside the window (pnWindowMs from pnNowMs) Outside the window the same body 
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
