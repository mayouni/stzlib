#================================================================#
#  STZOIDCPROVIDER -- Softanza AS an identity provider             #
#================================================================#

/*--- Be the "sign in with ..." button, instead of only consuming one.

stzOidcClient made Softanza a relying PARTY (log my users in through Google).
This is the other side: your Softanza app becomes the PROVIDER other apps trust.
One account, one login, many applications -- the same thing Google, Okta and
Entra sell, running on your own issuer.

The authorization-code flow, end to end:

  1. an app sends the user to  /authorize?client_id=..&redirect_uri=..&state=..
     &nonce=..&code_challenge=..   -- WE authenticate the user (a live stzAuth
     session) and hand back a short-lived CODE on the registered redirect;
  2. the app calls  /token  from its server with the code, its client secret and
     the PKCE verifier -- and receives a signed ID TOKEN (plus an access token);
  3. the app verifies that token against our JWKS, exactly as stzOidcClient does.

WHAT MAKES THIS SAFE (each rule exists because of a real attack):

  * the redirect_uri must EXACTLY match one registered for that client -- the
    single most abused hole in OAuth, because a loose match lets an attacker
    have the code delivered to their own site;
  * a code is SINGLE-USE, short-lived, and BOUND to the client, the redirect,
    the nonce and the PKCE challenge it was issued under -- so a stolen code is
    useless to anyone else, and replay is caught;
  * the token endpoint authenticates the CLIENT (its secret, compared in
    constant time), because it is a back-channel call;
  * PKCE (S256) is verified when the authorization asked for it, which is what
    protects a public client that cannot keep a secret at all;
  * the id-token carries iss / aud / exp / iat and echoes the nonce, so the
    relying party can bind it to its own login.

Every refusal returns a REASON, and an OAuth error CODE (invalid_client,
invalid_grant, ...) for the wire.

The signing key is ES256 (engine-generated and engine-signed). Keys carry a kid
and can be ROTATED: the new key signs, while the previous one stays published in
the JWKS so tokens already in flight keep verifying.
*/

func StzOidcProviderQ(pcIssuer)
	return new stzOidcProvider(pcIssuer)


class stzOidcProvider from stzObject

	@cIssuer = ""
	@cKid = ""
	@cAlg = "ES256"       # ES256 (an engine key) or RS256 (a PEM you supply)
	@cPem = ""            # the RSA private key, when signing RS256
	@cN = ""              # its public modulus / exponent, for the JWKS
	@cE = ""
	@cD = ""              # the CURRENT signing key (private) -- never published
	@cX = ""
	@cY = ""
	@aOldKeys = []        # [ [ kid, alg, k1, k2 ], ... ] -- published, not signing
	@aClients = []        # [ [ id, secretHash, [ redirectUris ], name ], ... ]
	@aCodes = []          # [ [ code, client, user, redirect, nonce, challenge, expires ] ]
	@nCodeTTL = 300       # an authorization code lives 5 minutes
	@nTokenTTL = 3600
	@bKeyUsed = 0     # has the CURRENT key actually signed anything?
	@cWhy = ""
	@cError = ""
	# Incident I2. @aSpent holds the codes this provider has already
	# CONSUMED, so a second redemption is identifiable as a REPLAY rather
	# than as an unknown code. Without it the provider can only say "unknown
	# or already-used", and the catalog's oauth.code.replayed kind would be
	# a claim it cannot back -- a stolen-code replay and a random guess
	# would arrive as the same event. Bounded: the codes are single-use and
	# short-lived, so an old entry has nothing left to protect.
	@aSpent = []
	@nSpentMax = 64
	@cLastClientId = ""

	def init(pcIssuer)
		@cIssuer = ring_trim("" + pcIssuer)
		if @cIssuer = ""
			StzRaise("stzOidcProvider: an issuer URL is required.")
		ok
		@aClients = []
		@aCodes = []
		@aOldKeys = []
		This.RotateKeyQ("")

	  #-- identity + keys --------------------------------------------------

	def Issuer()
		return @cIssuer

	def SigningKeyId()
		return @cKid

	def SigningAlgorithm()
		return @cAlg

	# Sign with RS256 instead, using an RSA private key you already have. Plenty of
	# older clients accept RS256 and nothing else, so an ES256-only issuer cannot
	# serve them. The key stays here; only its public parts reach the JWKS.
	def UseRsaKey(pcPem)
		This.UseRsaKeyQ(pcPem)

	def UseRsaKeyQ(pcPem)
		_p_ = StzRsaPublicKey(pcPem)
		if len(_p_) = 0
			StzRaise("stzOidcProvider.UseRsaKey: the private key could not be read (PEM expected).")
		ok
		This._RetireCurrentKey()
		@cPem = "" + pcPem
		@cN = _p_[:n]
		@cE = _p_[:e]
		@cAlg = "RS256"
		@cX = ""
		@cY = ""
		@cD = ""
		@cKid = "stz-" + StzLeft(StzEngineCryptoSha256(@cN), 16)
		return This

	# generate one, for development
	def UseNewRsaKey(nBits)
		This.UseNewRsaKeyQ(nBits)

	def UseNewRsaKeyQ(nBits)
		return This.UseRsaKeyQ( StzRsaKeyPair(nBits)[:privateKey] )

	# Start signing with a NEW key. The previous public key stays in the JWKS, so
	# tokens already issued keep verifying until they expire -- rotation without
	# an outage. A 32-byte hex seed makes it deterministic ("" = random).
	def RotateKey(pcSeedHex)
		This.RotateKeyQ(pcSeedHex)

	def RotateKeyQ(pcSeedHex)
		This._RetireCurrentKey()
		_t_ = StzEngineCryptoEs256KeyPair("" + pcSeedHex)
		if _t_ = ""
			StzRaise("stzOidcProvider: could not generate a signing key.")
		ok
		_a_ = StzSplit(_t_, "|")
		if len(_a_) != 3
			StzRaise("stzOidcProvider: malformed key material from the engine.")
		ok
		@cD = _a_[1]
		@cX = _a_[2]
		@cY = _a_[3]
		@cKid = "stz-" + StzLeft(StzEngineCryptoSha256(@cX), 16)
		@cAlg = "ES256"
		@cPem = ""
		return This

	# Keep the OUTGOING key's public half in the JWKS, so tokens already in flight
	# keep verifying -- rotation without an outage, whichever algorithm it used.
	# A key that never SIGNED anything is simply dropped: publishing it would add a
	# key no token can possibly reference.
	def _RetireCurrentKey()
		if NOT @bKeyUsed
			return
		ok
		@bKeyUsed = 0
		if @cAlg = "RS256" and @cN != ""
			@aOldKeys + [ @cKid, "RS256", @cN, @cE ]
		but @cX != ""
			@aOldKeys + [ @cKid, "ES256", @cX, @cY ]
		ok

	def NumberOfPublishedKeys()
		return 1 + len(@aOldKeys)

	# what a relying party fetches from jwks_uri: the CURRENT key plus any
	# still-valid previous ones.
	def JwksJson()
		_out_ = '{"keys":['
		if @cAlg = "RS256"
			_out_ += This._RsaJwkJson(@cKid, @cN, @cE)
		else
			_out_ += This._JwkJson(@cKid, @cX, @cY)
		ok
		_n_ = len(@aOldKeys)
		for _i_ = 1 to _n_
			if @aOldKeys[_i_][2] = "RS256"
				_out_ += "," + This._RsaJwkJson(@aOldKeys[_i_][1], @aOldKeys[_i_][3], @aOldKeys[_i_][4])
			else
				_out_ += "," + This._JwkJson(@aOldKeys[_i_][1], @aOldKeys[_i_][3], @aOldKeys[_i_][4])
			ok
		next
		return _out_ + "]}"

	# the discovery document served at /.well-known/openid-configuration.
	def DiscoveryJson()
		return '{"issuer":"' + @cIssuer + '",' +
		       '"authorization_endpoint":"' + @cIssuer + '/authorize",' +
		       '"token_endpoint":"' + @cIssuer + '/token",' +
		       '"jwks_uri":"' + @cIssuer + '/jwks",' +
		       '"response_types_supported":["code"],' +
		       '"grant_types_supported":["authorization_code"],' +
		       '"subject_types_supported":["public"],' +
		       '"id_token_signing_alg_values_supported":["' + @cAlg + '"],' +
		       '"code_challenge_methods_supported":["S256"],' +
		       '"scopes_supported":["openid","profile","email"]}'

	  #-- the client registry ---------------------------------------------

	# Register an application. The secret is stored HASHED (a leak of our store
	# must not yield working client credentials). paRedirectUris is the exact set
	# a code may be delivered to.
	def RegisterClient(pcClientId, pcSecret, paRedirectUris)
		This.RegisterClientXT(pcClientId, pcSecret, paRedirectUris, "")

	def RegisterClientXT(pcClientId, pcSecret, paRedirectUris, pcName)
		_id_ = ring_trim("" + pcClientId)
		if _id_ = ""
			StzRaise("stzOidcProvider.RegisterClient: a client id is required.")
		ok
		if len(paRedirectUris) = 0
			StzRaise("stzOidcProvider.RegisterClient: at least one redirect URI is required.")
		ok
		if This.HasClient(_id_)
			StzRaise("stzOidcProvider.RegisterClient: client '" + _id_ + "' already exists.")
		ok
		@aClients + [ _id_, StzHashSecret("" + pcSecret), paRedirectUris, "" + pcName ]
		return This

	def HasClient(pcClientId)
		return This._ClientIndex(ring_trim("" + pcClientId)) > 0

	def ClientIds()
		_out_ = []
		_n_ = len(@aClients)
		for _i_ = 1 to _n_
			_out_ + @aClients[_i_][1]
		next
		return _out_

	def RedirectUrisOf(pcClientId)
		_i_ = This._ClientIndex(ring_trim("" + pcClientId))
		if _i_ = 0
			return []
		ok
		return @aClients[_i_][3]

	def RemoveClient(pcClientId)
		_id_ = ring_trim("" + pcClientId)
		_aNew_ = []
		_n_ = len(@aClients)
		for _i_ = 1 to _n_
			if @aClients[_i_][1] != _id_
				_aNew_ + @aClients[_i_]
			ok
		next
		@aClients = _aNew_
		return This

	  #-- step 1: authorize (the user is already signed in to US) ----------

	# Issue an authorization code for an authenticated user.
	# paReq: [ :clientId, :redirectUri, :state, :nonce, :codeChallenge, :scope ]
	# -> [ :ok, :code, :redirectTo, :state, :why, :error ]
	def Authorize(paReq, pcUser)
		return This.AuthorizeAt(paReq, pcUser, This._NowSecs())

	def AuthorizeAt(paReq, pcUser, pnNow)
		_cid_ = ring_trim("" + This._Get(paReq, :clientId))
		@cLastClientId = _cid_
		_ci_ = This._ClientIndex(_cid_)
		if _ci_ = 0
			return This._RefuseAuth("unknown client '" + _cid_ + "'", "unauthorized_client")
		ok
		_redir_ = "" + This._Get(paReq, :redirectUri)
		# EXACT match against the registered set -- never a prefix or a wildcard.
		if NOT This._RedirectIsRegistered(_ci_, _redir_)
			return This._RefuseAuth("redirect_uri '" + _redir_ + "' is not registered for this client",
			                        "invalid_request")
		ok
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			return This._RefuseAuth("no authenticated user -- sign in first", "login_required")
		ok
		_code_ = StzEngineCryptoRandomHex(32)
		@aCodes + [ _code_, _cid_, _u_, _redir_,
		            "" + This._Get(paReq, :nonce),
		            "" + This._Get(paReq, :codeChallenge),
		            pnNow + @nCodeTTL ]
		@cWhy = ""
		@cError = ""
		_state_ = "" + This._Get(paReq, :state)
		_sep_ = "?"
		if StzFindFirst("?", _redir_) > 0
			_sep_ = "&"
		ok
		_to_ = _redir_ + _sep_ + "code=" + _code_
		if _state_ != ""
			_to_ += "&state=" + _state_
		ok
		return [ :ok = 1, :code = _code_, :redirectTo = _to_, :state = _state_,
		         :why = "", :error = "" ]

	  #-- step 2: token (a back-channel call from the app's server) --------

	# Exchange a code for tokens -> [ :ok, :idToken, :accessToken, :tokenType,
	# :expiresIn, :subject, :why, :error ].
	def ExchangeCode(pcClientId, pcClientSecret, pcCode, pcRedirectUri, pcCodeVerifier)
		return This.ExchangeCodeAt(pcClientId, pcClientSecret, pcCode, pcRedirectUri,
		           pcCodeVerifier, This._NowSecs())

	def ExchangeCodeAt(pcClientId, pcClientSecret, pcCode, pcRedirectUri, pcCodeVerifier, pnNow)
		_cid_ = ring_trim("" + pcClientId)
		@cLastClientId = _cid_
		_ci_ = This._ClientIndex(_cid_)
		if _ci_ = 0
			return This._RefuseToken("unknown client", "invalid_client")
		ok
		# the token endpoint is a back channel: the CLIENT must authenticate.
		if NOT StzVerifySecret("" + pcClientSecret, @aClients[_ci_][2])
			return This._RefuseToken("the client secret is wrong", "invalid_client")
		ok
		_i_ = This._CodeIndex("" + pcCode)
		if _i_ = 0
			# Incident I2: a code we have SEEN and spent is a replay -- the
			# classic stolen-code attack, and an error. A code we have never
			# seen is a guess, and only a warning. The refusal ANSWER stays
			# identical (an attacker learns nothing either way); it is the
			# ledger that keeps the distinction.
			if This._WasSpent("" + pcCode)
				StzNoteRefusal("oauth.code.replayed", @cLastClientId,
					"client:" + @cLastClientId,
					"an authorization code already redeemed was presented again")
			ok
			return This._RefuseToken("unknown or already-used authorization code", "invalid_grant")
		ok
		_rec_ = @aCodes[_i_]
		# A code is SINGLE-USE: consume it now, whatever happens next. Replaying it
		# (the classic stolen-code attack) then finds nothing.
		This._DeleteCode("" + pcCode)
		This._RememberSpent("" + pcCode)
		if pnNow >= _rec_[7]
			return This._RefuseToken("the authorization code expired", "invalid_grant")
		ok
		if _rec_[2] != _cid_
			return This._RefuseToken("this code was issued to a different client", "invalid_grant")
		ok
		if _rec_[4] != ("" + pcRedirectUri)
			return This._RefuseToken("redirect_uri does not match the one the code was issued for",
			                         "invalid_grant")
		ok
		# PKCE: if the authorization carried a challenge, the verifier must produce it.
		if _rec_[6] != ""
			if ("" + pcCodeVerifier) = ""
				return This._RefuseToken("this code requires a PKCE code_verifier", "invalid_grant")
			ok
			if This.PkceChallengeOf(pcCodeVerifier) != _rec_[6]
				return This._RefuseToken("the PKCE verifier does not match the challenge", "invalid_grant")
			ok
		ok
		_u_ = _rec_[3]
		@cWhy = ""
		@cError = ""
		return [ :ok = 1,
		         :idToken = This.IssueIdTokenAt(_u_, _cid_, _rec_[5], pnNow),
		         :accessToken = This._IssueAccessTokenAt(_u_, _cid_, pnNow),
		         :tokenType = "Bearer", :expiresIn = @nTokenTTL,
		         :subject = _u_, :why = "", :error = "" ]

	  #-- token minting ----------------------------------------------------

	# a signed id-token for a subject + audience (used by the flow above, and
	# directly when an app trusts this provider in-process).
	def IssueIdToken(pcSubject, pcAudience, pcNonce)
		return This.IssueIdTokenAt(pcSubject, pcAudience, pcNonce, This._NowSecs())

	def IssueIdTokenAt(pcSubject, pcAudience, pcNonce, pnNow)
		_pay_ = '{"iss":"' + @cIssuer + '","sub":"' + pcSubject + '","aud":"' + pcAudience +
		        '","exp":' + (pnNow + @nTokenTTL) + ',"iat":' + pnNow
		if ("" + pcNonce) != ""
			_pay_ += ',"nonce":"' + pcNonce + '"'
		ok
		_pay_ += "}"
		return This._Sign(_pay_)

	def SetTokenTTL(pnSecs)
		This.SetTokenTTLQ(pnSecs)

	def SetTokenTTLQ(pnSecs)
		@nTokenTTL = pnSecs
		return This

	def TokenTTL()
		return @nTokenTTL

	def SetCodeTTL(pnSecs)
		This.SetCodeTTLQ(pnSecs)

	def SetCodeTTLQ(pnSecs)
		@nCodeTTL = pnSecs
		return This

	def CodeTTL()
		return @nCodeTTL

	  #-- housekeeping + introspection -------------------------------------

	def NumberOfPendingCodes()
		return len(@aCodes)

	def PurgeExpiredCodesAt(pnNow)
		_aNew_ = []
		_n_ = 0
		_len_ = len(@aCodes)
		for _i_ = 1 to _len_
			if pnNow < @aCodes[_i_][7]
				_aNew_ + @aCodes[_i_]
			else
				_n_++
			ok
		next
		@aCodes = _aNew_
		return _n_

	def PurgeExpiredCodes()
		return This.PurgeExpiredCodesAt(This._NowSecs())

	# the S256 challenge for a verifier (the same computation a client makes).
	def PkceChallengeOf(pcVerifier)
		_hex_ = StzEngineCryptoSha256("" + pcVerifier)
		_raw_ = ""
		_n_ = len(_hex_)
		_i_ = 1
		while _i_ + 1 <= _n_
			_raw_ += char(This._HexPair(_hex_[_i_], _hex_[_i_ + 1]))
			_i_ += 2
		end
		return StzB64UrlEncode(_raw_)

	def Why()
		return @cWhy

	def ErrorCode()
		return @cError

	def Show()
		? "stzOidcProvider(" + @cIssuer + ", kid=" + @cKid + ", " +
		  len(@aClients) + " client(s))"

	  #==== internals ======================================================

	def _Sign(pcPayloadJson)
		@bKeyUsed = 1
		_hdr_ = '{"alg":"' + @cAlg + '","typ":"JWT","kid":"' + @cKid + '"}'
		_in_ = StzB64UrlEncode(_hdr_) + "." + StzB64UrlEncode(pcPayloadJson)
		if @cAlg = "RS256"
			return _in_ + "." + StzRsaSign(_in_, @cPem)
		ok
		return _in_ + "." + StzEngineCryptoSignEs256(_in_, @cD)

	# an access token is a signed JWT too, so a resource server can validate it
	# with the same JWKS -- no introspection round-trip.
	def _IssueAccessTokenAt(pcUser, pcClientId, pnNow)
		return This._Sign('{"iss":"' + @cIssuer + '","sub":"' + pcUser +
		                  '","aud":"' + pcClientId + '","exp":' + (pnNow + @nTokenTTL) +
		                  ',"iat":' + pnNow + ',"typ":"access"}')

	def _RsaJwkJson(pcKid, pcN, pcE)
		return '{"kid":"' + pcKid + '","kty":"RSA","alg":"RS256",' +
		       '"use":"sig","n":"' + pcN + '","e":"' + pcE + '"}'

	def _JwkJson(pcKid, pcX, pcY)
		return '{"kid":"' + pcKid + '","kty":"EC","crv":"P-256","alg":"ES256",' +
		       '"use":"sig","x":"' + pcX + '","y":"' + pcY + '"}'

	def _ClientIndex(pcId)
		_n_ = len(@aClients)
		for _i_ = 1 to _n_
			if @aClients[_i_][1] = pcId
				return _i_
			ok
		next
		return 0

	def _RedirectIsRegistered(pnClientIndex, pcRedirect)
		_a_ = @aClients[pnClientIndex][3]
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if ("" + _a_[_i_]) = ("" + pcRedirect)
				return 1
			ok
		next
		return 0

	def _CodeIndex(pcCode)
		_n_ = len(@aCodes)
		for _i_ = 1 to _n_
			if @aCodes[_i_][1] = pcCode
				return _i_
			ok
		next
		return 0

	def _DeleteCode(pcCode)
		_aNew_ = []
		_n_ = len(@aCodes)
		for _i_ = 1 to _n_
			if @aCodes[_i_][1] != pcCode
				_aNew_ + @aCodes[_i_]
			ok
		next
		@aCodes = _aNew_

	def _Get(paList, pcKey)
		if NOT isList(paList)
			return ""
		ok
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if isList(paList[_i_]) and len(paList[_i_]) >= 2
				if ("" + paList[_i_][1]) = ("" + pcKey)
					return paList[_i_][2]
				ok
			ok
		next
		return ""

	# Both refusal doors are seams (incident I2). @cWhy is one slot; a client
	# that fails its secret ten times running, or walks a list of redirect
	# URIs looking for one that is registered, is invisible from any single
	# read of it. Neither the client secret nor the code is ever written --
	# the client ID is a name, and names are what an investigation needs.
	def _RefuseAuth(pcWhy, pcError)
		@cWhy = "" + pcWhy
		@cError = "" + pcError
		StzNoteRefusal("oauth.client.rejected", @cLastClientId,
			"client:" + @cLastClientId, @cWhy)
		return [ :ok = 0, :code = "", :redirectTo = "", :state = "",
		         :why = @cWhy, :error = @cError ]

	def _RefuseToken(pcWhy, pcError)
		@cWhy = "" + pcWhy
		@cError = "" + pcError
		StzNoteRefusal("oauth.client.rejected", @cLastClientId,
			"client:" + @cLastClientId, @cWhy)
		return [ :ok = 0, :idToken = "", :accessToken = "", :tokenType = "",
		         :expiresIn = 0, :subject = "", :why = @cWhy, :error = @cError ]

	# the spent-code memory the replay distinction rests on
	def _RememberSpent(pcCode)
		@aSpent + ("" + pcCode)
		if len(@aSpent) > @nSpentMax
			del(@aSpent, 1)
		ok

	def _WasSpent(pcCode)
		_c_ = "" + pcCode
		_n_ = len(@aSpent)
		for _i_ = 1 to _n_
			if @aSpent[_i_] = _c_
				return 1
			ok
		next
		return 0

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
