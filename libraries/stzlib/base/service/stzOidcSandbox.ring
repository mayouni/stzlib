#================================================================#
#  STZOIDCSANDBOX -- a fee-free IDENTITY PROVIDER double           #
#================================================================#

/*--- Develop "sign in with <provider>" without a provider account.

The service-virtualization plane's identity port. Wiring OIDC normally means
registering an app with Google/Okta/Entra, holding real client secrets, and
round-tripping a browser -- none of which belongs in a test suite. This sandbox
IS an identity provider, locally:

    oIdp = new stzOidcSandbox("https://idp.local", "my-app")
    oRp  = new stzOidcClient("https://idp.local", "my-app")
    oRp.SetJwks( oIdp.JwksJson() )               # exactly what jwks_uri returns
    cTok = oIdp.IssueIdToken("dana", cNonce)     # a REAL signed id-token
    aId  = oRp.VerifyIdToken(cTok, cNonce)       # ... and it really verifies

It is not a stub that returns "true". It holds an ES256 keypair and SIGNS every
token with the engine (StzEngineCryptoSignEs256), so the relying party runs its
genuine signature check against a genuine JWKS. Swap in a real provider at
deploy and nothing about the verification path changes -- which is the whole
point of the plane: what you exercised in development is what runs in production.

Because it can also mint DELIBERATELY BAD tokens (expired, wrong audience,
foreign issuer, wrong nonce, signed by another key), the negative half of the
security contract is testable too -- normally the hard part, since a real
provider will not issue you a broken token on request.

The key is deterministic from a seed, so a suite is reproducible.
*/

func StzOidcSandboxQ(pcIssuer, pcClientId)
	return new stzOidcSandbox(pcIssuer, pcClientId)


class stzOidcSandbox from stzObject

	@cIssuer = ""
	@cClientId = ""
	@cKid = "sandbox-key-1"
	@cD = ""          # the private key (base64url) -- a SANDBOX key, never real
	@cX = ""
	@cY = ""
	@nTokenTTL = 3600

	# pcIssuer is the "iss" every token carries; pcClientId the "aud".
	def init(pcIssuer, pcClientId)
		@cIssuer = ring_trim("" + pcIssuer)
		@cClientId = ring_trim("" + pcClientId)
		This.UseSeedQ("")     # random key by default

	  #-- the provider's identity -----------------------------------------

	# a deterministic key from a 32-byte hex seed ("" = random). Same seed ->
	# same key, so a test that pins a token can be reproduced.
	def UseSeed(pcSeedHex)
		This.UseSeedQ(pcSeedHex)

	def UseSeedQ(pcSeedHex)
		_t_ = StzEngineCryptoEs256KeyPair("" + pcSeedHex)
		if _t_ = ""
			StzRaise("stzOidcSandbox: could not generate a signing key (seed must be 32 bytes of hex, or empty).")
		ok
		_a_ = StzSplit(_t_, "|")
		if len(_a_) != 3
			StzRaise("stzOidcSandbox: malformed key material from the engine.")
		ok
		@cD = _a_[1]
		@cX = _a_[2]
		@cY = _a_[3]
		return This

	def SetKeyId(pcKid)
		This.SetKeyIdQ(pcKid)

	def SetKeyIdQ(pcKid)
		@cKid = "" + pcKid
		return This

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	def KeyId()
		return @cKid

	def Issuer()
		return @cIssuer

	def ClientId()
		return @cClientId

	def SetTokenTTL(pnSecs)
		This.SetTokenTTLQ(pnSecs)

	def SetTokenTTLQ(pnSecs)
		@nTokenTTL = pnSecs
		return This

	def TokenTTL()
		return @nTokenTTL

	# the PUBLIC half, as a JWK -- what a relying party is given.
	def PublicJwk()
		return [ :kid = @cKid, :kty = "EC", :crv = "P-256",
		         :alg = "ES256", :use = "sig", :x = @cX, :y = @cY ]

	# the JWKS document a provider serves at its jwks_uri.
	def JwksJson()
		return '{"keys":[{"kid":"' + @cKid + '","kty":"EC","crv":"P-256","alg":"ES256",' +
		       '"use":"sig","x":"' + @cX + '","y":"' + @cY + '"}]}'

	# the discovery document (the well-known endpoint an RP reads first).
	def DiscoveryJson()
		return '{"issuer":"' + @cIssuer + '",' +
		       '"authorization_endpoint":"' + @cIssuer + '/authorize",' +
		       '"token_endpoint":"' + @cIssuer + '/token",' +
		       '"jwks_uri":"' + @cIssuer + '/jwks",' +
		       '"id_token_signing_alg_values_supported":["ES256"]}'

	def AuthorizationEndpoint()
		return @cIssuer + "/authorize"

	def TokenEndpoint()
		return @cIssuer + "/token"

	  #-- issuing tokens --------------------------------------------------

	# a well-formed, correctly-signed id-token for a subject.
	def IssueIdToken(pcSubject, pcNonce)
		return This.IssueIdTokenAt(pcSubject, pcNonce, This._NowSecs())

	def IssueIdTokenAt(pcSubject, pcNonce, pnNow)
		return This.IssueIdTokenXT(pcSubject, pcNonce, pnNow,
		           [ :iss = @cIssuer, :aud = @cClientId,
		             :email = "" + pcSubject + "@" + This._Domain() ])

	# full control, for the negative cases: paOver may override :iss, :aud,
	# :email, :exp, :nbf -- and :signWith may hand in a FOREIGN private key.
	def IssueIdTokenXT(pcSubject, pcNonce, pnNow, paOver)
		_iss_ = This._Or(paOver, :iss, @cIssuer)
		_aud_ = This._Or(paOver, :aud, @cClientId)
		_email_ = This._Or(paOver, :email, "" + pcSubject + "@" + This._Domain())
		_exp_ = This._Or(paOver, :exp, pnNow + @nTokenTTL)
		_key_ = This._Or(paOver, :signWith, @cD)

		_hdr_ = '{"alg":"ES256","typ":"JWT","kid":"' + @cKid + '"}'
		_pay_ = '{"iss":"' + _iss_ + '","sub":"' + pcSubject + '","aud":"' + _aud_ +
		        '","exp":' + _exp_ + ',"iat":' + pnNow + ',"email":"' + _email_ + '"'
		if ("" + pcNonce) != ""
			_pay_ += ',"nonce":"' + pcNonce + '"'
		ok
		if This._Has(paOver, :nbf)
			_pay_ += ',"nbf":' + This._Or(paOver, :nbf, pnNow)
		ok
		_pay_ += "}"

		_input_ = StzB64UrlEncode(_hdr_) + "." + StzB64UrlEncode(_pay_)
		return _input_ + "." + StzEngineCryptoSignEs256(_input_, "" + _key_)

	# an ALREADY-EXPIRED token (issued in the past) -- for the negative path.
	def IssueExpiredIdTokenAt(pcSubject, pcNonce, pnNow)
		return This.IssueIdTokenXT(pcSubject, pcNonce, pnNow - 7200,
		           [ :iss = @cIssuer, :aud = @cClientId, :exp = pnNow - 3600 ])

	# a token signed by a DIFFERENT key -- an impostor provider.
	def IssueForgedIdTokenAt(pcSubject, pcNonce, pnNow)
		_t_ = StzEngineCryptoEs256KeyPair("")
		_a_ = StzSplit(_t_, "|")
		return This.IssueIdTokenXT(pcSubject, pcNonce, pnNow,
		           [ :iss = @cIssuer, :aud = @cClientId, :signWith = _a_[1] ])

	def Show()
		? "stzOidcSandbox(" + @cIssuer + ", aud=" + @cClientId + ", kid=" + @cKid + ")"

	  #-- internals -------------------------------------------------------

	def _Domain()
		_h_ = StzReplace(StzReplace(@cIssuer, "https://", ""), "http://", "")
		_a_ = StzSplit(_h_, "/")
		if len(_a_) = 0
			return "example"
		ok
		return _a_[1]

	def _Has(paList, pcKey)
		if NOT isList(paList)
			return 0
		ok
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if isList(paList[_i_]) and len(paList[_i_]) >= 2
				if ("" + paList[_i_][1]) = ("" + pcKey)
					return 1
				ok
			ok
		next
		return 0

	def _Or(paList, pcKey, pDefault)
		if NOT isList(paList)
			return pDefault
		ok
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if isList(paList[_i_]) and len(paList[_i_]) >= 2
				if ("" + paList[_i_][1]) = ("" + pcKey)
					return paList[_i_][2]
				ok
			ok
		next
		return pDefault

	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)
