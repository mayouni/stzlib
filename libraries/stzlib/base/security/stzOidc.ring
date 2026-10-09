#================================================================#
#  STZOIDC -- signing in with an EXTERNAL identity provider        #
#================================================================#

/*--- OpenID Connect login (the relying-party side).

"Sign in with Google / Okta / Entra / Auth0" is, underneath, one question: the
provider hands back an **id-token** (a JWT), and the app must decide whether to
believe it. That decision is entirely local -- verify the signature against a
PUBLIC key the provider publishes (its JWKS), then check the claims -- which is
why this became possible the moment the engine grew public-key verification
(StzEngineCryptoVerifyEs256 / ...Rs256).

Two classes:

  stzJwt         one token: split it, read its header/claims, verify its
                 signature against a JWK. Useful on its own (any JWS).

  stzOidcClient  the relying party: build the authorization URL (with state,
                 nonce and PKCE), then VERIFY the id-token that comes back and
                 turn it into an identity. Holds the provider's issuer, the
                 client id, and its JWKS keys.

A TOKEN IS NOT TRUSTED UNTIL BOTH HALVES PASS. Verifying the signature only
proves the provider signed *something*; the claims decide it was signed FOR US,
RECENTLY, and IN ANSWER TO THIS LOGIN:
  * alg      -- must be one we accept, and taken from OUR key, never from the
                token's own header (that is the classic "alg:none" / algorithm-
                confusion forgery);
  * iss      -- exactly the configured issuer;
  * aud      -- must contain our client id (a token minted for another app is
                not a login here);
  * exp/nbf  -- inside its validity window (with a small clock-skew allowance);
  * nonce    -- equals the one WE generated for this login, which is what makes
                a replayed id-token useless.

Every failure returns a REASON (:why) rather than a bare 0, because "the
login failed" is unactionable when a clock or an audience is misconfigured.

For development there is a fee-free provider double -- stzOidcSandbox in
base/service/ -- that mints genuinely ES256-signed tokens offline, so the whole
flow is exercised without a real IdP account. See the service-virtualization
plane.
*/

func StzJwtQ(pcToken)
	return new stzJwt(pcToken)

func StzOidcClientQ(pcIssuer, pcClientId)
	return new stzOidcClient(pcIssuer, pcClientId)

# base64url-encode a string's BYTES (no padding). ASCII-safe by construction:
# the output alphabet is ASCII, and we read the input byte-wise, so UTF-8 JSON
# survives intact.
func StzB64UrlEncode(pcData)
	_cAlpha_ = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	_s_ = "" + pcData
	_n_ = len(_s_)
	_out_ = ""
	_i_ = 1
	while _i_ <= _n_
		_b1_ = ascii(_s_[_i_])
		_b2_ = 0
		_b3_ = 0
		_have_ = 1
		if _i_ + 1 <= _n_
			_b2_ = ascii(_s_[_i_ + 1])
			_have_ = 2
		ok
		if _i_ + 2 <= _n_
			_b3_ = ascii(_s_[_i_ + 2])
			_have_ = 3
		ok
		_out_ += _cAlpha_[((_b1_ >> 2) & 63) + 1]
		_out_ += _cAlpha_[((((_b1_ & 3) << 4) | ((_b2_ >> 4) & 15)) & 63) + 1]
		if _have_ > 1
			_out_ += _cAlpha_[((((_b2_ & 15) << 2) | ((_b3_ >> 6) & 3)) & 63) + 1]
		ok
		if _have_ > 2
			_out_ += _cAlpha_[(_b3_ & 63) + 1]
		ok
		_i_ += 3
	end
	return _out_

func StzB64UrlDecode(pcData)
	return StzEngineCryptoB64UrlDecode("" + pcData)


  #=========================================================#
 #  STZJWT -- one JSON Web Token                             #
#=========================================================#

# Reads one JSON Web Token: its header, its claims and its signature, and checks the signature against a public key.
#
# Use it on its own for any signed token with three parts. Reading a claim proves nothing: the token
# is only data until SignatureIsValidWith has passed against a key you hold, and a token meant for
# you must also carry your audience and an unexpired exp, which stzOidcClient checks. A malformed
# token is accepted at construction and simply reads as empty.
#
#   receiver   o1 = new stzJwt("eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InNhbmRib3gta2V5LTEifQ.e
#              yJpc3MiOiJodHRwczovL2lkcC5pbnZlbnRlZC50ZXN0Iiwic3ViIjoiYWxpY2UiLCJhdWQiOiJjbGllbnQtZG
#              VtbyIsImV4cCI6MTgwMDAwMzYwMCwiaWF0IjoxODAwMDAwMDAwLCJlbWFpbCI6ImFsaWNlQGlkcC5pbnZlbnR
#              lZC50ZXN0Iiwibm9uY2UiOiJuLTEifQ.x-227z0Avx-
#              r1tKhwqLnt3CAkCMEX3Zq4jj3zzHPVYpMMP5Z9lgLSy_R5iGQSOFm5WdFJ649b_tg6An7mhqE5Q")
#   example    ? o1.IsWellFormed()
#              #--> 1
#              ? o1.Algorithm()
#              #--> ES256
#              ? o1.Subject()
#              #--> alice
#              ? o1.ClaimInt("exp")
#              #--> 1800003600
#              ? o1.Audience()
#              #--> client-demo
#              ? o1.SignatureIsValidWith([ [ "kty", "EC" ], [ "x", "t006lKtxiQpobDOpWwzGDVKazORGwZWNLbK206XQuHc" ], [ "y", "KGMvZoXXlU8YdR3KS-6Q6A8bqVqlwpoZy0Udq9TPUy4" ] ])
#              #--> 1
#   see        stzOidcClient, stzOidcSandbox
class stzJwt from stzObject

	@cToken = ""
	@aParts = []

	# Wraps one JSON Web Token given as text and cuts it at its dots into header, payload and signature.
	#
	#   pcToken    the token, three base64url parts joined by dots
	#   returns    nothing; the object is built
	#   warning    nothing is checked at construction: a malformed token is accepted and reads as
	#              empty
	#   see        IsWellFormed, SignatureIsValidWith
	def init(pcToken)
		@cToken = ring_trim("" + pcToken)
		@aParts = StzSplit(@cToken, ".")

	# Returns the token text this object wraps, trimmed.
	#
	#   returns    a text
	#   see        init, SigningInput
	def Token()
		return @cToken

	# TRUE if the token has exactly three dot-separated parts and the first two are not empty.
	#
	#   returns    TRUE or FALSE
	#   note       it checks the shape only, not that the parts decode
	#   see        SigningInput, SignatureIsValidWith
	#@ aka  a JWS is exactly three dot-separated parts.
	def IsWellFormed()
		if len(@aParts) != 3
			return 0
		ok
		return @aParts[1] != "" and @aParts[2] != ""

	# Returns the text the signature covers, the header part and the payload part joined by a dot.
	#
	#   returns    a text; the empty text when the token is not well formed
	#   see        SignatureB64, SignatureIsValidWith
	#@ aka  the part the signature actually covers: "<header>.<payload>".
	def SigningInput()
		if NOT This.IsWellFormed()
			return ""
		ok
		return @aParts[1] + "." + @aParts[2]

	# Returns the third part, the signature, still base64url encoded.
	#
	#   returns    a text; the empty text when the token has fewer than three parts
	#   see        SigningInput, SignatureIsValidWith
	def SignatureB64()
		if len(@aParts) < 3
			return ""
		ok
		return @aParts[3]

	# Returns the decoded header of the token, normally a JSON text such as {"alg":"ES256","typ":"JWT","kid":"..."}.
	#
	#   returns    a text; the empty text when there is no first part
	#   note       the part is decoded whatever it holds, so a part that is not base64url gives
	#              bytes that are not JSON
	#   see        Payload, Algorithm, KeyId
	def Header()
		if len(@aParts) < 1
			return ""
		ok
		return StzB64UrlDecode(@aParts[1])

	# Returns the decoded payload of the token, normally the JSON text of its claims.
	#
	#   returns    a text; the empty text when there is no second part
	#   note       the claims are only data until SignatureIsValidWith has passed against a key you
	#              hold
	#   see        Header, Claim, ClaimInt
	def Payload()
		if len(@aParts) < 2
			return ""
		ok
		return StzB64UrlDecode(@aParts[2])

	# Returns the algorithm the header declares, such as ES256.
	#
	#   returns    a text; the empty text when the header is missing or not JSON
	#   note       for information only: verify with the algorithm of the key you hold, never with
	#              this one
	#   see        KeyId, SignatureIsValidWith
	#@ aka  the header's declared algorithm. INFORMATIONAL ONLY -- never verify with it; verification uses the algorithm of the key WE hold.
	def Algorithm()
		return This._HeaderField("alg")

	# Returns the kid the header names, the key that signed the token.
	#
	#   returns    a text; the empty text when there is none
	#   see        Algorithm, Header
	def KeyId()
		return This._HeaderField("kid")

	# Returns the value of a claim of the payload as text.
	#
	#   pcName     the claim name, such as "sub" or "email"
	#   returns    a text; the empty text when the claim is absent or the payload is not JSON
	#   see        ClaimInt, HasClaim, Subject
	def Claim(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return ""
		ok
		return StzJsonGet(_p_, "" + pcName)

	# Returns the value of a numeric claim of the payload, such as exp.
	#
	#   pcName     the claim name, such as "exp"
	#   returns    a number; 0 when the claim is absent or the payload is not JSON
	#   see        Claim, HasClaim
	def ClaimInt(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return 0
		ok
		return StzJsonGetInt(_p_, "" + pcName)

	# TRUE if the payload carries a claim of that name.
	#
	#   pcName     the claim name to look for
	#   returns    TRUE or FALSE; FALSE when the payload is not JSON
	#   see        Claim, ClaimInt
	def HasClaim(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return 0
		ok
		return StzJsonHasKey(_p_, "" + pcName)

	# Returns the sub claim, the identity the token is about.
	#
	#   returns    a text; the empty text when absent
	#   see        Claim, Issuer
	def Subject()
		return This.Claim("sub")

	# Returns the iss claim, the party that issued the token.
	#
	#   returns    a text; the empty text when absent
	#   see        Claim, Subject, Audience
	def Issuer()
		return This.Claim("iss")

	# Returns the aud claim, the party the token was issued for.
	#
	#   returns    a text; the empty text when absent
	#   see        Claim, Issuer
	def Audience()
		return This.Claim("aud")

	# TRUE if the token's signature verifies against one public key given as a JWK, EC with ES256 or RSA with RS256.
	#
	#   paJwk      the public key as a list of [ name, value ] pairs: [ :kty, :x, :y ] for EC or [
	#              :kty, :n, :e ] for RSA
	#   returns    TRUE or FALSE; FALSE for a malformed token, a foreign key, an unknown key type or
	#              a malformed key
	#   note       the key type picks the algorithm; the alg of the header is ignored
	#   warning    a TRUE proves only that the key's owner signed the token, not that it is meant
	#              for you, nor recent: check iss, aud and exp too, as VerifyIdToken does
	#   see        stzOidcClient, Algorithm
	#@ aka  verify the signature against ONE JWK -- [ :kty, :x, :y ] for EC (ES256) or [ :kty, :n, :e ] for RSA (RS256). TRUE only on a definite 1 from the engine (a malformed key answers -1, which is NOT a pass).
	def SignatureIsValidWith(paJwk)
		if NOT This.IsWellFormed()
			return 0
		ok
		_in_ = This.SigningInput()
		_sig_ = This.SignatureB64()
		_kty_ = "" + This._JwkField(paJwk, :kty)
		if _kty_ = "EC"
			return StzEngineCryptoVerifyEs256(_in_, _sig_,
			           "" + This._JwkField(paJwk, :x),
			           "" + This._JwkField(paJwk, :y)) = 1
		but _kty_ = "RSA"
			return StzEngineCryptoVerifyRs256(_in_, _sig_,
			           "" + This._JwkField(paJwk, :n),
			           "" + This._JwkField(paJwk, :e)) = 1
		ok
		return 0

	# Prints a one-line summary: the declared algorithm, the subject and the issuer.
	#
	#   returns    nothing; it prints
	#   see        Algorithm, Subject, Issuer
	def Show()
		? "stzJwt(" + This.Algorithm() + ") sub=" + This.Subject() + " iss=" + This.Issuer()

	  #-- internals -------------------------------------------------------

	def _HeaderField(pcName)
		_h_ = This.Header()
		if _h_ = "" or NOT StzJsonIsValid(_h_)
			return ""
		ok
		return StzJsonGet(_h_, "" + pcName)

	def _JwkField(paJwk, pcKey)
		if NOT isList(paJwk)
			return ""
		ok
		_n_ = len(paJwk)
		for _i_ = 1 to _n_
			if isList(paJwk[_i_]) and len(paJwk[_i_]) >= 2
				if ("" + paJwk[_i_][1]) = ("" + pcKey)
					return paJwk[_i_][2]
				ok
			ok
		next
		return ""


  #=========================================================#
 #  STZOIDCCLIENT -- the relying party                       #
#=========================================================#

# Acts as the application side of a sign-in with an external identity provider: builds the sign-in address and decides whether the returned id-token may be believed.
#
# Give it the issuer, the client id and the provider's public keys (AddKey, or SetJwks with the
# provider's JWKS document). AuthorizationUrl sends the user to the provider with a state and a
# nonce, and PKCE when you pass a challenge. VerifyIdToken then checks, in order, the shape, the
# key, the signature, the issuer, the audience, the expiry, the not-before time and the nonce, and
# answers a list whose why names the first failure instead of a bare 0. The algorithm is taken from
# the key the client holds, never from the token. In tests, use stzOidcSandbox to mint tokens
# offline.
#
#   receiver   o1 = new stzOidcClient("https://idp.invented.test", "client-demo")
#              o1.SetRedirectUri("https://app.invented.test/cb")
#   example    ? o1.AuthorizationUrl("https://idp.invented.test/authorize", "s1", "n-1")
#              #--> https://idp.invented.test/authorize?response_type=code&client_id=client-demo&redirect_uri=https%3A%2F%2Fapp.invented.test%2Fcb&scope=openid%20profile%20email&state=s1&nonce=n-1
#              ? o1.PkceChallengeOf("dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
#              #--> E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
#              ? o1.VerifyIdToken("junk", "n-1")[:ok]
#              #--> 0
#              ? o1.Why()
#              #--> the token is not a well-formed JWT
#   see        stzJwt, stzOidcSandbox
class stzOidcClient from stzObject

	@cIssuer = ""
	@cClientId = ""
	@cRedirectUri = ""
	@aKeys = []           # the provider's JWKS: [ [ kid, jwk ], ... ]
	@nSkewSecs = 120      # clock-skew allowance on exp / nbf
	@cLastWhy = ""

	# Builds a relying party for one identity provider and one client, with no key and no redirect address yet.
	#
	#   pcIssuer     the provider's issuer address, which tokens must carry in iss
	#   pcClientId   this application's client id, which tokens must carry in aud
	#   returns      nothing; the object is built
	#   note         the clock allowance starts at 120 seconds
	#   see          AddKey, SetJwks, SetRedirectUri
	def init(pcIssuer, pcClientId)
		@cIssuer = ring_trim("" + pcIssuer)
		@cClientId = ring_trim("" + pcClientId)
		@aKeys = []

	# Returns the issuer the client trusts.
	#
	#   returns    a text
	#   see        ClientId, VerifyIdToken
	#@ aka  -- configuration (plain + Q twins) ---------------------------------
	def Issuer()
		return @cIssuer

	# Returns the client id this application presents to the provider.
	#
	#   returns    a text
	#   see        Issuer, VerifyIdToken
	def ClientId()
		return @cClientId

	# Sets the address the provider sends the user back to after sign-in.
	#
	#   pcUri      the redirect address, as text
	#   returns    nothing; use SetRedirectUriQ to chain
	#   warning    without it the authorization URL carries an empty redirect_uri
	#   see        RedirectUri, AuthorizationUrl
	def SetRedirectUri(pcUri)
		This.SetRedirectUriQ(pcUri)

	def SetRedirectUriQ(pcUri)
		@cRedirectUri = "" + pcUri
		return This

	# Returns the redirect address, or the empty text when none was set.
	#
	#   returns    a text
	#   see        SetRedirectUri
	def RedirectUri()
		return @cRedirectUri

	# Sets the allowance, in seconds, applied around the exp and nbf times when a token is checked.
	#
	#   pnSecs     the number of seconds of tolerance
	#   returns    nothing; use SetClockSkewQ to chain
	#   see        ClockSkew, VerifyIdTokenAt
	def SetClockSkew(pnSecs)
		This.SetClockSkewQ(pnSecs)

	def SetClockSkewQ(pnSecs)
		@nSkewSecs = pnSecs
		return This

	# Returns the clock allowance in seconds, 120 until it is set.
	#
	#   returns    a number
	#   see        SetClockSkew
	def ClockSkew()
		return @nSkewSecs

	# Adds one public key of the provider, so that tokens naming its kid can be verified.
	#
	#   paJwk      the key as a list of [ name, value ] pairs: [ :kid, :kty, :x, :y ] for EC or [
	#              :kid, :kty, :n, :e ] for RSA
	#   returns    nothing; use AddKeyQ to chain
	#   note       keys are not checked when added
	#   warning    adding a key with a kid already present adds a second entry; the first one found
	#              wins
	#   see        SetJwks, KeyIds
	#@ aka  -- the provider's signing keys (its JWKS) --------------------------
	def AddKey(paJwk)
		This.AddKeyQ(paJwk)

	def AddKeyQ(paJwk)
		_kid_ = "" + This._Field(paJwk, :kid)
		@aKeys + [ _kid_, paJwk ]
		return This

	# Replaces all keys by those of a JWKS document, the JSON {"keys":[ ... ]} a provider publishes.
	#
	#   pcJson     the JWKS document, as JSON text
	#   returns    nothing; use SetJwksQ to chain
	#   note       a document without a keys member leaves the client with no key
	#   warning    text that is not valid JSON raises an error, after the previous keys were dropped
	#   see        AddKey, NumberOfKeys
	#@ aka  load a whole JWKS document ({"keys":[ {...}, ... ]}), as fetched from the provider's jwks_uri.
	def SetJwks(pcJson)
		This.SetJwksQ(pcJson)

	def SetJwksQ(pcJson)
		@aKeys = []
		if NOT StzJsonIsValid("" + pcJson)
			StzRaise("stzOidcClient.SetJwks: not valid JSON.")
		ok
		_l_ = JsonToList("" + pcJson)
		_keys_ = []
		_n_ = len(_l_)
		for _i_ = 1 to _n_
			if isList(_l_[_i_]) and len(_l_[_i_]) >= 2 and ("" + _l_[_i_][1]) = "keys"
				_keys_ = _l_[_i_][2]
				exit
			ok
		next
		_m_ = len(_keys_)
		for _i_ = 1 to _m_
			This.AddKeyQ(_keys_[_i_])
		next
		return This

	# Returns how many keys are held.
	#
	#   returns    a number
	#   see        KeyIds, AddKey
	def NumberOfKeys()
		return len(@aKeys)

	# Returns the kid of each held key, in the order added.
	#
	#   returns    a list of text
	#   see        NumberOfKeys, AddKey
	def KeyIds()
		_out_ = []
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			_out_ + @aKeys[_i_][1]
		next
		return _out_

	# Builds the sign-in address to send the user to at the provider, with client id, redirect address, scope, state and nonce.
	#
	#   pcAuthEndpoint   the provider's authorization endpoint
	#   pcState          a random value to match when the user returns, against forged redirects
	#   pcNonce          a random value the id-token must echo, against replay
	#   returns          a text, the endpoint followed by the query string; every value is percent-
	#                    encoded
	#   note             the query holds response_type=code and the scope "openid profile email"; an
	#                    endpoint that already holds a ? gets the parameters after an &;
	#                    AuthorizationUrlXT adds a scope and a PKCE code challenge
	#                    (code_challenge_method=S256)
	#   see              VerifyIdToken, NewPkce, SetRedirectUri
	#@ aka  -- step 1: send the user to the provider ---------------------------
	def AuthorizationUrl(pcAuthEndpoint, pcState, pcNonce)
		return This.AuthorizationUrlXT(pcAuthEndpoint, pcState, pcNonce, "openid profile email", "")

	def AuthorizationUrlXT(pcAuthEndpoint, pcState, pcNonce, pcScope, pcCodeChallenge)
		_u_ = "" + pcAuthEndpoint
		_sep_ = "?"
		if StzFindFirst("?", _u_) > 0
			_sep_ = "&"
		ok
		_u_ += _sep_ + "response_type=code" +
		       "&client_id=" + This._UriEnc(@cClientId) +
		       "&redirect_uri=" + This._UriEnc(@cRedirectUri) +
		       "&scope=" + This._UriEnc("" + pcScope) +
		       "&state=" + This._UriEnc("" + pcState) +
		       "&nonce=" + This._UriEnc("" + pcNonce)
		if "" + pcCodeChallenge != ""
			_u_ += "&code_challenge=" + This._UriEnc("" + pcCodeChallenge) +
			       "&code_challenge_method=S256"
		ok
		return _u_

	# Returns a fresh PKCE pair: a random verifier to keep and its S256 challenge to send.
	#
	#   returns    a list [ [ "verifier", 64 hex characters ], [ "challenge", 43 characters ] ]
	#   note       the verifier is random, so two calls differ; keep it until the code is exchanged
	#   see        PkceChallengeOf, AuthorizationUrl
	#@ aka  a fresh PKCE verifier (kept by the app) and its S256 challenge (sent to the provider) -> [ :verifier, :challenge ].
	def NewPkce()
		_v_ = StzEngineCryptoRandomHex(32)
		return [ :verifier = _v_, :challenge = This._S256Challenge(_v_) ]

	# Returns the S256 challenge of a verifier, the base64url of its SHA-256.
	#
	#   pcVerifier   the PKCE verifier to derive the challenge from
	#   returns      a text of 43 characters
	#   note         for the verifier dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk of RFC 7636 it
	#                gives E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
	#   see          NewPkce
	def PkceChallengeOf(pcVerifier)
		return This._S256Challenge("" + pcVerifier)

	# Decides whether an id-token may be believed, at the present time: signature, issuer, audience, expiry, not-before and nonce.
	#
	#   pcToken           the id-token returned by the provider
	#   pcExpectedNonce   the nonce this login sent
	#   returns           a list [ :ok, :subject, :email, :claims, :why ]: ok is 1 with the
	#                     identity, or 0 with why naming the first check that failed
	#   note              the key is chosen by the token's kid (the only key when the token names
	#                     none) and the algorithm comes from that key, never from the token
	#   warning           a refusal is returned, never raised, and each one is also noted in the
	#                     security ledger by issuer and reason, never with the token
	#   see               VerifyIdTokenAt, Why, AuthorizationUrl
	#@ aka  -- step 2: believe (or refuse) the id-token ------------------------
	def VerifyIdToken(pcToken, pcExpectedNonce)
		return This.VerifyIdTokenAt(pcToken, pcExpectedNonce, This._NowSecs())

	# Decides whether an id-token may be believed at a given time, so that expiry can be tested without waiting.
	#
	#   pcToken           the id-token to check
	#   pcExpectedNonce   the nonce this login sent
	#   pnNow             the time to judge by, in seconds since 1970
	#   returns           a list [ :ok, :subject, :email, :claims, :why ], as for VerifyIdToken
	#   note              the token is expired when pnNow is past exp plus the clock allowance
	#   warning           the checks run in order and stop at the first failure: shape, key,
	#                     signature, issuer, audience, exp, nbf, nonce; a token with no exp is
	#                     refused
	#   see               VerifyIdToken, SetClockSkew
	def VerifyIdTokenAt(pcToken, pcExpectedNonce, pnNow)
		_o_ = new stzJwt(pcToken)
		if NOT _o_.IsWellFormed()
			return This._Refuse("the token is not a well-formed JWT")
		ok

		# resolve the key by kid FIRST -- the algorithm comes from OUR key, never
		# from the token's own header (defeats alg-confusion / "alg":"none").
		_jwk_ = This._KeyFor(_o_.KeyId())
		if len(_jwk_) = 0
			return This._Refuse("no configured key matches the token's kid '" + _o_.KeyId() + "'")
		ok
		if NOT _o_.SignatureIsValidWith(_jwk_)
			return This._Refuse("the signature does not verify against the provider's key")
		ok

		# ---- the signature is real; now decide it was meant for US ----
		if _o_.Issuer() != @cIssuer
			return This._Refuse("issuer mismatch: '" + _o_.Issuer() + "' is not '" + @cIssuer + "'")
		ok
		if NOT This._AudienceMatches(_o_)
			return This._Refuse("audience mismatch: the token was not issued for client '" + @cClientId + "'")
		ok
		_exp_ = _o_.ClaimInt("exp")
		if _exp_ = 0
			return This._Refuse("the token carries no exp claim")
		ok
		if pnNow > (_exp_ + @nSkewSecs)
			return This._Refuse("the token expired")
		ok
		if _o_.HasClaim("nbf") and pnNow < (_o_.ClaimInt("nbf") - @nSkewSecs)
			return This._Refuse("the token is not valid yet (nbf)")
		ok
		if ("" + pcExpectedNonce) != ""
			if _o_.Claim("nonce") != ("" + pcExpectedNonce)
				return This._Refuse("nonce mismatch -- this token does not answer this login")
			ok
		ok
		@cLastWhy = ""
		return [ :ok = 1, :subject = _o_.Subject(),
		         :email = _o_.Claim("email"), :claims = _o_.Payload(), :why = "" ]

	# Returns why the last verification was refused, or the empty text when it passed.
	#
	#   returns    a text
	#   see        VerifyIdToken
	#@ aka  why the last verification was refused ("" when it passed).
	def Why()
		return @cLastWhy

	# Prints a one-line summary: the issuer, the client id and the number of keys.
	#
	#   returns    nothing; it prints
	#   see        NumberOfKeys, Issuer
	def Show()
		? "stzOidcClient(" + @cIssuer + ", client=" + @cClientId + ", " +
		  len(@aKeys) + " key(s))"

	  #-- internals -------------------------------------------------------

	def _Refuse(pcWhy)
		@cLastWhy = "" + pcWhy
		# Incident I2, the same move stzSaml._Refuse makes: @cLastWhy is ONE
		# slot the next verification overwrites, so a token that failed its
		# signature check is forgotten the moment the next one is checked.
		# A run of rejected id-tokens from one issuer is how a broken key
		# rotation -- or a forged-token campaign -- announces itself, and
		# neither is visible from a single Why(). The token itself is a
		# CREDENTIAL and never enters the ledger; only the issuer it claims
		# and the reason it failed do.
		StzNoteRefusal("sso.token.rejected", @cIssuer, "idp:" + @cIssuer, @cLastWhy)
		return [ :ok = 0, :subject = "", :email = "", :claims = "", :why = @cLastWhy ]

	# the JWK for a kid. A JWKS with exactly ONE key resolves even when the token
	# names no kid (common for small providers).
	def _KeyFor(pcKid)
		_k_ = "" + pcKid
		_n_ = len(@aKeys)
		if _k_ = "" and _n_ = 1
			return @aKeys[1][2]
		ok
		for _i_ = 1 to _n_
			if @aKeys[_i_][1] = _k_
				return @aKeys[_i_][2]
			ok
		next
		return []

	# aud may be a single string or a list of them.
	def _AudienceMatches(poJwt)
		_a_ = poJwt.Audience()
		if isList(_a_)
			_n_ = len(_a_)
			for _i_ = 1 to _n_
				if ("" + _a_[_i_]) = @cClientId
					return 1
				ok
			next
			return 0
		ok
		return ("" + _a_) = @cClientId

	def _Field(paJwk, pcKey)
		if NOT isList(paJwk)
			return ""
		ok
		_n_ = len(paJwk)
		for _i_ = 1 to _n_
			if isList(paJwk[_i_]) and len(paJwk[_i_]) >= 2
				if ("" + paJwk[_i_][1]) = ("" + pcKey)
					return paJwk[_i_][2]
				ok
			ok
		next
		return ""

	# PKCE S256: base64url( sha256(verifier) ). The engine returns hex, so the
	# digest is rebuilt byte-wise before encoding.
	def _S256Challenge(pcVerifier)
		_hex_ = StzEngineCryptoSha256("" + pcVerifier)
		_raw_ = ""
		_n_ = len(_hex_)
		_i_ = 1
		while _i_ + 1 <= _n_
			_raw_ += char(This._HexPair(_hex_[_i_], _hex_[_i_ + 1]))
			_i_ += 2
		end
		return StzB64UrlEncode(_raw_)

	def _HexPair(pcHi, pcLo)
		return This._HexDigit(pcHi) * 16 + This._HexDigit(pcLo)

	def _HexDigit(pcC)
		_a_ = ascii(pcC)
		if _a_ >= 48 and _a_ <= 57    return _a_ - 48 ok
		if _a_ >= 97 and _a_ <= 102   return _a_ - 87 ok
		if _a_ >= 65 and _a_ <= 70    return _a_ - 55 ok
		return 0

	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)

	def _UriEnc(pcS)
		_out_ = ""
		_s_ = "" + pcS
		_n_ = len(_s_)
		for _i_ = 1 to _n_
			_c_ = _s_[_i_]
			_a_ = ascii(_c_)
			if (_a_ >= 48 and _a_ <= 57) or (_a_ >= 65 and _a_ <= 90) or
			   (_a_ >= 97 and _a_ <= 122) or _c_ = "-" or _c_ = "." or _c_ = "_" or _c_ = "~"
				_out_ += _c_
			else
				_h_ = "0123456789ABCDEF"
				_out_ += "%" + _h_[((_a_ >> 4) & 15) + 1] + _h_[(_a_ & 15) + 1]
			ok
		next
		return _out_
