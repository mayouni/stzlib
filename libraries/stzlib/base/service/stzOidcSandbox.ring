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


# Acts as a local OpenID Connect identity provider with a real signing key, so sign-in is developed without a provider account.
#
# It is not a stub that answers true. It holds an ES256 key pair, publishes the public half as a key
# set and a discovery document, and signs every token in the engine, so the relying party,
# stzOidcClient, runs its genuine signature check against a genuine key set. It also mints
# deliberately bad tokens, expired, forged, or with another audience, issuer or nonce, through
# IssueIdTokenXT, so the refusals can be tested, which a real provider will not do on request. The
# key comes from the engine's generator or from a seed for a reproducible suite, and is a sandbox
# key, never a real one. Token claims are joined into the JSON without escaping, so it must not be
# fed untrusted values.
#
#   receiver   o1 = new stzOidcSandbox("https://idp.local", "my-app") o2 = new
#              stzOidcClient("https://idp.local", "my-app")
#   example    o2.SetJwks(o1.JwksJson())
#              c1 = o1.IssueIdToken("dana", "nonce-1")
#              ? o2.VerifyIdToken(c1, "nonce-1")[:ok]
#              #--> 1
#              ? o2.VerifyIdToken(c1, "another-nonce")[:ok]
#              #--> 0
#              c2 = o1.IssueForgedIdTokenAt("dana", "n", floor(StzEngineTimeNowMs() / 1000))
#              ? o2.VerifyIdToken(c2, "n")[:ok]
#              #--> 0
#              ? o1.TokenEndpoint()
#              #--> https://idp.local/token
#   see        stzOidcClient, stzServiceRegistry, stzPasskeySandbox
class stzOidcSandbox from stzObject

	@cIssuer = ""
	@cClientId = ""
	@cKid = "sandbox-key-1"
	@cD = ""          # the private key (base64url) -- a SANDBOX key, never real
	@cX = ""
	@cY = ""
	@nTokenTTL = 3600

	# Builds a fee-free OpenID Connect identity provider in memory, with a fresh random signing key.
	#
	#   pcIssuer     the iss claim every token carries, such as https://idp.local
	#   pcClientId   the aud claim, the client the tokens are for
	#   returns      nothing; the object is built
	#   warning      the issuer and client id are written into JSON as given, with no escaping, so
	#                values holding a quote can add or duplicate claims
	#   see          IssueIdToken, JwksJson
	#@ aka  pcIssuer is the "iss" every token carries; pcClientId the "aud".
	def init(pcIssuer, pcClientId)
		@cIssuer = ring_trim("" + pcIssuer)
		@cClientId = ring_trim("" + pcClientId)
		This.UseSeedQ("")     # random key by default

	# Replaces the signing key with one derived from a 32-byte hex seed, so the same seed gives the same key and a suite is reproducible.
	#
	#   pcSeedHex   64 hexadecimal characters, or an empty text for a random key
	#   returns     nothing; use UseSeedQ to chain
	#   note        only invented sandbox keys, never real ones; tokens made earlier no longer
	#               verify against the new key
	#   warning     raises an error unless the seed is 32 bytes of hex or empty
	#   see         PublicJwk, IssueIdToken
	#@ aka  -- the provider's identity -----------------------------------------
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

	# Sets the key id carried in the token header and in the key set.
	#
	#   pcKid      the key id, sandbox-key-1 by default
	#   returns    nothing; use SetKeyIdQ to chain
	#   note       the id is written into JSON as given, so a quote in it breaks or extends the key
	#              set
	#   see        KeyId, JwksJson
	def SetKeyId(pcKid)
		This.SetKeyIdQ(pcKid)

	def SetKeyIdQ(pcKid)
		@cKid = "" + pcKid
		return This

	# TRUE if the object is a test double; here it always is, so the registry can refuse it in production.
	#
	#   returns    TRUE
	#   see        stzServiceRegistry
	#@ aka  a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	# Returns the key id used in token headers and the key set.
	#
	#   returns    a text
	#   see        SetKeyId
	def KeyId()
		return @cKid

	# Returns the issuer every token carries, trimmed.
	#
	#   returns    a text
	#   see        ClientId
	def Issuer()
		return @cIssuer

	# Returns the client id every token is issued for, trimmed.
	#
	#   returns    a text
	#   see        Issuer
	def ClientId()
		return @cClientId

	# Sets how long a token issued afterwards stays valid, in seconds.
	#
	#   pnSecs     the lifetime in seconds
	#   returns    nothing; use SetTokenTTLQ to chain
	#   note       the value is not checked
	#   see        TokenTTL, IssueIdToken
	def SetTokenTTL(pnSecs)
		This.SetTokenTTLQ(pnSecs)

	def SetTokenTTLQ(pnSecs)
		@nTokenTTL = pnSecs
		return This

	# Returns the lifetime of the tokens issued, in seconds.
	#
	#   returns    a number
	#   see        SetTokenTTL
	def TokenTTL()
		return @nTokenTTL

	# Returns the public half of the signing key as a JSON Web Key, which is what a relying party is given.
	#
	#   returns    a hash list [ :kid, :kty, :crv, :alg, :use, :x, :y ]
	#   see        JwksJson, UseSeed
	#@ aka  the PUBLIC half, as a JWK -- what a relying party is given.
	def PublicJwk()
		return [ :kid = @cKid, :kty = "EC", :crv = "P-256",
		         :alg = "ES256", :use = "sig", :x = @cX, :y = @cY ]

	# Returns the key set document that a provider serves at its jwks_uri, holding the public key.
	#
	#   returns    a text of JSON
	#   note       built by joining text, so a key id holding a quote can add a key
	#   see        PublicJwk, DiscoveryJson
	#@ aka  the JWKS document a provider serves at its jwks_uri.
	def JwksJson()
		return '{"keys":[{"kid":"' + @cKid + '","kty":"EC","crv":"P-256","alg":"ES256",' +
		       '"use":"sig","x":"' + @cX + '","y":"' + @cY + '"}]}'

	# Returns the discovery document that a relying party reads first: issuer, endpoints, key set address and signing algorithm.
	#
	#   returns    a text of JSON
	#   note       built by joining text, so an issuer holding a quote can add members
	#   see        AuthorizationEndpoint, TokenEndpoint
	#@ aka  the discovery document (the well-known endpoint an RP reads first).
	def DiscoveryJson()
		return '{"issuer":"' + @cIssuer + '",' +
		       '"authorization_endpoint":"' + @cIssuer + '/authorize",' +
		       '"token_endpoint":"' + @cIssuer + '/token",' +
		       '"jwks_uri":"' + @cIssuer + '/jwks",' +
		       '"id_token_signing_alg_values_supported":["ES256"]}'

	# Returns the issuer's authorize address.
	#
	#   returns    a text, the issuer followed by /authorize
	#   see        TokenEndpoint
	def AuthorizationEndpoint()
		return @cIssuer + "/authorize"

	# Returns the issuer's token address.
	#
	#   returns    a text, the issuer followed by /token
	#   see        AuthorizationEndpoint
	def TokenEndpoint()
		return @cIssuer + "/token"

	# Returns a well-formed ES256-signed id token for a subject, valid from now for the token lifetime.
	#
	#   pcSubject   the sub claim, also the local part of the email
	#   pcNonce     the nonce claim, left out when empty
	#   returns     a text of three dot-separated parts
	#   note        a real signature over those bytes: the relying party's check passes on the
	#               injected claims
	#   warning     the subject and the nonce are written into the signed JSON with no escaping, so
	#               a value holding quotes injects extra claims, such as a subject ending in
	#               ","admin":true,"x":" ; this is a test double, and a real token must be built
	#               with escaped values
	#   see         IssueIdTokenAt, UseSeed
	#@ aka  -- issuing tokens --------------------------------------------------
	def IssueIdToken(pcSubject, pcNonce)
		return This.IssueIdTokenAt(pcSubject, pcNonce, This._NowSecs())

	# Returns an id token as IssueIdToken does, issued at a given instant, which makes a pinned token reproducible.
	#
	#   pcSubject   the sub claim
	#   pcNonce     the nonce claim
	#   pnNow       the issue time in epoch seconds
	#   returns     a text of three dot-separated parts
	#   note        a token issued at a time in the past is already expired when verified against
	#               the current clock
	#   warning     the same unescaped writing of the subject and the nonce
	#   see         IssueIdToken, IssueExpiredIdTokenAt
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

	# Returns a correctly signed token that expired an hour before the given instant, for testing refusal of an expired token.
	#
	#   pcSubject   the sub claim
	#   pcNonce     the nonce claim
	#   pnNow       the reference instant in epoch seconds
	#   returns     a text of three dot-separated parts
	#   note        issued two hours before the instant and expired one hour before it
	#   see         IssueForgedIdTokenAt
	#@ aka  an ALREADY-EXPIRED token (issued in the past) -- for the negative path.
	def IssueExpiredIdTokenAt(pcSubject, pcNonce, pnNow)
		return This.IssueIdTokenXT(pcSubject, pcNonce, pnNow - 7200,
		           [ :iss = @cIssuer, :aud = @cClientId, :exp = pnNow - 3600 ])

	# Returns a token signed by a different key from the provider's, as an impostor would, for testing refusal of a forged signature.
	#
	#   pcSubject   the sub claim
	#   pcNonce     the nonce claim
	#   pnNow       the issue time in epoch seconds
	#   returns     a text of three dot-separated parts
	#   note        the relying party must refuse it against the provider's key set
	#   see         IssueExpiredIdTokenAt
	#@ aka  a token signed by a DIFFERENT key -- an impostor provider.
	def IssueForgedIdTokenAt(pcSubject, pcNonce, pnNow)
		_t_ = StzEngineCryptoEs256KeyPair("")
		_a_ = StzSplit(_t_, "|")
		return This.IssueIdTokenXT(pcSubject, pcNonce, pnNow,
		           [ :iss = @cIssuer, :aud = @cClientId, :signWith = _a_[1] ])

	# Prints one line with the issuer, the client id and the key id.
	#
	#   returns    nothing; it prints
	#   see        Issuer
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
