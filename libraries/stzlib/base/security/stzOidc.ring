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

class stzJwt from stzObject

	@cToken = ""
	@aParts = []

	def init(pcToken)
		@cToken = ring_trim("" + pcToken)
		@aParts = StzSplit(@cToken, ".")

	def Token()
		return @cToken

	# a JWS is exactly three dot-separated parts.
	def IsWellFormed()
		if len(@aParts) != 3
			return 0
		ok
		return @aParts[1] != "" and @aParts[2] != ""

	# the part the signature actually covers: "<header>.<payload>".
	def SigningInput()
		if NOT This.IsWellFormed()
			return ""
		ok
		return @aParts[1] + "." + @aParts[2]

	def SignatureB64()
		if len(@aParts) < 3
			return ""
		ok
		return @aParts[3]

	def Header()
		if len(@aParts) < 1
			return ""
		ok
		return StzB64UrlDecode(@aParts[1])

	def Payload()
		if len(@aParts) < 2
			return ""
		ok
		return StzB64UrlDecode(@aParts[2])

	# the header's declared algorithm. INFORMATIONAL ONLY -- never verify with
	# it; verification uses the algorithm of the key WE hold.
	def Algorithm()
		return This._HeaderField("alg")

	def KeyId()
		return This._HeaderField("kid")

	def Claim(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return ""
		ok
		return StzJsonGet(_p_, "" + pcName)

	def ClaimInt(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return 0
		ok
		return StzJsonGetInt(_p_, "" + pcName)

	def HasClaim(pcName)
		_p_ = This.Payload()
		if _p_ = "" or NOT StzJsonIsValid(_p_)
			return 0
		ok
		return StzJsonHasKey(_p_, "" + pcName)

	def Subject()
		return This.Claim("sub")

	def Issuer()
		return This.Claim("iss")

	def Audience()
		return This.Claim("aud")

	# verify the signature against ONE JWK -- [ :kty, :x, :y ] for EC (ES256) or
	# [ :kty, :n, :e ] for RSA (RS256). TRUE only on a definite 1 from the engine
	# (a malformed key answers -1, which is NOT a pass).
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

class stzOidcClient from stzObject

	@cIssuer = ""
	@cClientId = ""
	@cRedirectUri = ""
	@aKeys = []           # the provider's JWKS: [ [ kid, jwk ], ... ]
	@nSkewSecs = 120      # clock-skew allowance on exp / nbf
	@cLastWhy = ""

	def init(pcIssuer, pcClientId)
		@cIssuer = ring_trim("" + pcIssuer)
		@cClientId = ring_trim("" + pcClientId)
		@aKeys = []

	  #-- configuration (plain + Q twins) ---------------------------------

	def Issuer()
		return @cIssuer

	def ClientId()
		return @cClientId

	def SetRedirectUri(pcUri)
		This.SetRedirectUriQ(pcUri)

	def SetRedirectUriQ(pcUri)
		@cRedirectUri = "" + pcUri
		return This

	def RedirectUri()
		return @cRedirectUri

	def SetClockSkew(pnSecs)
		This.SetClockSkewQ(pnSecs)

	def SetClockSkewQ(pnSecs)
		@nSkewSecs = pnSecs
		return This

	def ClockSkew()
		return @nSkewSecs

	  #-- the provider's signing keys (its JWKS) --------------------------

	# add one key: [ :kid, :kty, :x, :y ] (EC) or [ :kid, :kty, :n, :e ] (RSA).
	def AddKey(paJwk)
		This.AddKeyQ(paJwk)

	def AddKeyQ(paJwk)
		_kid_ = "" + This._Field(paJwk, :kid)
		@aKeys + [ _kid_, paJwk ]
		return This

	# load a whole JWKS document ({"keys":[ {...}, ... ]}), as fetched from the
	# provider's jwks_uri.
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

	def NumberOfKeys()
		return len(@aKeys)

	def KeyIds()
		_out_ = []
		_n_ = len(@aKeys)
		for _i_ = 1 to _n_
			_out_ + @aKeys[_i_][1]
		next
		return _out_

	  #-- step 1: send the user to the provider ---------------------------

	# The authorization URL. state defends the redirect against CSRF; nonce binds
	# the id-token to THIS login (replay defense); PKCE (S256) stops an
	# intercepted authorization code from being redeemed by anyone else.
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

	# a fresh PKCE verifier (kept by the app) and its S256 challenge (sent to the
	# provider) -> [ :verifier, :challenge ].
	def NewPkce()
		_v_ = StzEngineCryptoRandomHex(32)
		return [ :verifier = _v_, :challenge = This._S256Challenge(_v_) ]

	def PkceChallengeOf(pcVerifier)
		return This._S256Challenge("" + pcVerifier)

	  #-- step 2: believe (or refuse) the id-token ------------------------

	# Verify an id-token end to end -> [ :ok, :subject, :email, :claims, :why ].
	# pcExpectedNonce is the nonce this login sent ("" skips that check, which is
	# only sound for a flow that carried no nonce).
	def VerifyIdToken(pcToken, pcExpectedNonce)
		return This.VerifyIdTokenAt(pcToken, pcExpectedNonce, This._NowSecs())

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

	# why the last verification was refused ("" when it passed).
	def Why()
		return @cLastWhy

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
