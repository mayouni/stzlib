#================================================================#
#  STZSAML -- SAML 2.0 single sign-on (the SERVICE PROVIDER side)  #
#================================================================#

/*--- The enterprise SSO protocol: log users in through the company IdP.

Where OIDC is what consumer apps use, SAML is what enterprises run -- Okta,
Entra/ADFS, Shibboleth, OneLogin. An employee clicks "log in", the identity
provider authenticates them and POSTs back a SIGNED ASSERTION; the service
provider (this class, your app) decides whether to believe it.

The dangerous work -- XML parsing, exclusive canonicalization, signature
verification, and the anti-wrapping guarantee -- is the ENGINE's (see
engine/src/xmldsig.zig). Raw XML cannot cross the Ring<->engine text boundary
safely anyway, and canonicalization is where SAML implementations get quietly
broken. The engine returns claims read ONLY from the bytes the signature
actually covered.

What this class owns is the SP's judgement, which the engine cannot make for you
because it depends on YOUR configuration:

  * the assertion's ISSUER must be the IdP we trust (not merely a valid
    signature -- a signature from the wrong IdP is someone else's user);
  * the AUDIENCE must be this SP's entity id (an assertion minted for another
    service is not a login here);
  * the time window (NotBefore / NotOnOrAfter) must contain now, with a small
    clock-skew allowance -- an expired assertion is a replay;
  * the assertion must not have been seen before (replay protection over its
    validity window).

Every refusal returns a REASON. Nothing is trusted on a partial check.

    oSp = new stzSamlServiceProvider("https://sp.example.com", "https://sp.example.com/acs")
    oSp.TrustIdp("https://idp.acme.com", "RSA", cModulusB64Url, cExponentB64Url)
    aId = oSp.ConsumeResponse(cBase64FromTheBrowser)
    #   -> [ :ok, :nameID, :issuer, :audience, :why ]
*/

func StzSamlServiceProviderQ(pcEntityId, pcAcsUrl)
	return new stzSamlServiceProvider(pcEntityId, pcAcsUrl)


class stzSamlServiceProvider from stzObject

	@cEntityId = ""       # who WE are, as the IdP knows us (the Audience)
	@cAcsUrl = ""         # our assertion consumer service URL
	@cIdpEntityId = ""    # the IdP we trust (the expected Issuer)
	@cIdpSsoUrl = ""
	@cKty = ""            # the IdP's signing key: "RSA" (n,e) or "EC" (x,y)
	@cK1 = ""
	@cK2 = ""
	@cIdpCert = ""        # the certificate trust came from, when it did
	@nSkewSecs = 120
	@aSeen = []           # [ [ nameId+window, expiresEpoch ], ... ] replay guard
	@cWhy = ""

	def init(pcEntityId, pcAcsUrl)
		@cEntityId = ring_trim("" + pcEntityId)
		if @cEntityId = ""
			StzRaise("stzSamlServiceProvider: an entity id is required (it is the Audience the IdP mints for).")
		ok
		@cAcsUrl = "" + pcAcsUrl
		@cIdpCert = ""
		@aSeen = []

	  #-- configuration ---------------------------------------------------

	def EntityId()
		return @cEntityId

	def AcsUrl()
		return @cAcsUrl

	# Trust exactly ONE identity provider, by entity id AND signing key. Both
	# matter: the key proves the assertion is authentic, the entity id proves it
	# came from the IdP we mean.
	def TrustIdp(pcIdpEntityId, pcKty, pcK1, pcK2)
		This.TrustIdpQ(pcIdpEntityId, pcKty, pcK1, pcK2)

	def TrustIdpQ(pcIdpEntityId, pcKty, pcK1, pcK2)
		@cIdpEntityId = ring_trim("" + pcIdpEntityId)
		@cKty = "" + pcKty
		@cK1 = "" + pcK1
		@cK2 = "" + pcK2
		return This

	# Trust an IdP by its CERTIFICATE -- which is what its metadata actually
	# publishes. Accepts PEM or the bare base64 DER carried inside XML.
	def TrustIdpFromCertificate(pcIdpEntityId, pcCert)
		This.TrustIdpFromCertificateQ(pcIdpEntityId, pcCert)

	def TrustIdpFromCertificateQ(pcIdpEntityId, pcCert)
		_k_ = StzCertificateKey(pcCert)
		if len(_k_) = 0
			StzRaise("stzSamlServiceProvider.TrustIdpFromCertificate: the certificate could not be read.")
		ok
		@cIdpCert = "" + pcCert
		return This.TrustIdpQ(pcIdpEntityId, _k_[:keyType], _k_[:key1], _k_[:key2])

	# Trust an IdP from the METADATA document it publishes: entityID, SSO endpoint
	# and signing certificate all come from the one paste. This is how a real
	# service provider is configured.
	def TrustIdpFromMetadata(pcXml)
		This.TrustIdpFromMetadataQ(pcXml)

	def TrustIdpFromMetadataQ(pcXml)
		_r_ = StzEngineSamlMetadata("" + pcXml)
		if _r_ = ""
			StzRaise("stzSamlServiceProvider.TrustIdpFromMetadata: no entityID + signing certificate found.")
		ok
		_a_ = StzSplit(_r_, "|")
		if len(_a_) < 3
			StzRaise("stzSamlServiceProvider.TrustIdpFromMetadata: the metadata is incomplete.")
		ok
		This.SetIdpSsoUrlQ(_a_[2])
		return This.TrustIdpFromCertificateQ(_a_[1], _a_[3])

	# the certificate we were configured with ("" when trust was set by raw key).
	def IdpCertificate()
		return @cIdpCert

	# its fingerprint, for an operator to compare against what the IdP published.
	def IdpCertificateFingerprint()
		if @cIdpCert = ""
			return ""
		ok
		return StzCertificateFingerprint(@cIdpCert)

	def IdpCertificateInfo()
		if @cIdpCert = ""
			return []
		ok
		return StzCertificateInfo(@cIdpCert)

	def SetIdpSsoUrl(pcUrl)
		This.SetIdpSsoUrlQ(pcUrl)

	def SetIdpSsoUrlQ(pcUrl)
		@cIdpSsoUrl = "" + pcUrl
		return This

	def IdpEntityId()
		return @cIdpEntityId

	def IdpSsoUrl()
		return @cIdpSsoUrl

	def TrustsAnIdp()
		return @cIdpEntityId != "" and @cKty != ""

	def SetClockSkew(pnSecs)
		This.SetClockSkewQ(pnSecs)

	def SetClockSkewQ(pnSecs)
		@nSkewSecs = pnSecs
		return This

	def ClockSkew()
		return @nSkewSecs

	def Why()
		return @cWhy

	  #-- step 1: send the user to the IdP (SP-initiated SSO) --------------

	# The AuthnRequest XML. The caller base64s it into an HTTP-POST form (or
	# deflates + base64s it for the Redirect binding).
	def AuthnRequest(pcRequestId)
		return This.AuthnRequestAt(pcRequestId, This._NowSecs())

	def AuthnRequestAt(pcRequestId, pnNow)
		return '<samlp:AuthnRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" ' +
		       'xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ' +
		       'ID="' + pcRequestId + '" Version="2.0" IssueInstant="' + This._Iso(pnNow) + '" ' +
		       'Destination="' + @cIdpSsoUrl + '" ' +
		       'AssertionConsumerServiceURL="' + @cAcsUrl + '" ' +
		       'ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST">' +
		       '<saml:Issuer>' + @cEntityId + '</saml:Issuer>' +
		       '</samlp:AuthnRequest>'

	# a fresh request id (SAML ids must not start with a digit).
	def NewRequestId()
		return "_" + StzEngineCryptoRandomHex(16)

	  #-- step 2: believe (or refuse) what the IdP POSTed back -------------

	# pcBase64 is the SAMLResponse form field exactly as the browser posted it.
	def ConsumeResponse(pcBase64)
		return This.ConsumeResponseAt(pcBase64, This._NowSecs())

	def ConsumeResponseAt(pcBase64, pnNow)
		if NOT This.TrustsAnIdp()
			StzRaise("stzSamlServiceProvider: no IdP trusted -- call TrustIdp(entityId, kty, k1, k2).")
		ok
		_xml_ = This._DecodeB64(pcBase64)
		if _xml_ = ""
			return This._Refuse("the SAMLResponse is not valid base64")
		ok
		return This.ConsumeXmlAt(_xml_, pnNow)

	# the same, given the raw XML (already decoded).
	def ConsumeXml(pcXml)
		return This.ConsumeXmlAt(pcXml, This._NowSecs())

	def ConsumeXmlAt(pcXml, pnNow)
		# the ENGINE verifies the signature and returns claims read ONLY from the
		# bytes that signature covered (its anti-wrapping guarantee).
		_rec_ = StzEngineSamlVerify("" + pcXml, @cKty, @cK1, @cK2)
		if _rec_ = ""
			return This._Refuse("the response could not be processed")
		ok
		_a_ = StzSplit(_rec_, "|")
		if len(_a_) < 2
			return This._Refuse("the engine returned an unreadable verdict")
		ok
		if _a_[1] != "1"
			return This._Refuse(_a_[2])
		ok
		if len(_a_) < 7
			return This._Refuse("the assertion is missing required fields")
		ok
		_issuer_ = _a_[3]
		_nameid_ = _a_[4]
		_aud_ = _a_[5]
		_nb_ = _a_[6]
		_na_ = _a_[7]

		# ---- the signature is genuine; now decide it was meant for US ----
		if _issuer_ != @cIdpEntityId
			return This._Refuse("issuer mismatch: '" + _issuer_ + "' is not the trusted IdP '" +
			                    @cIdpEntityId + "'")
		ok
		if _aud_ != @cEntityId
			return This._Refuse("audience mismatch: the assertion was minted for '" + _aud_ +
			                    "', not for '" + @cEntityId + "'")
		ok
		if _nameid_ = ""
			return This._Refuse("the assertion carries no subject")
		ok
		if _nb_ != ""
			if pnNow < (This._Epoch(_nb_) - @nSkewSecs)
				return This._Refuse("the assertion is not valid yet (NotBefore)")
			ok
		ok
		if _na_ != ""
			if pnNow >= (This._Epoch(_na_) + @nSkewSecs)
				return This._Refuse("the assertion has expired (NotOnOrAfter)")
			ok
		ok
		# replay: the same subject + window must not be consumed twice
		_key_ = _nameid_ + "|" + _nb_ + "|" + _na_
		if This._SeenIndex(_key_) > 0
			# a replayed assertion is an attack, not a mistake: note it
			# under its own kind before the generic refusal path (I2)
			StzNoteRefusal("sso.assertion.replayed", _nameid_, "assertion:" + _nameid_,
				"this assertion has already been consumed (replay)")
			return This._Refuse("this assertion has already been consumed (replay)")
		ok
		This._Remember(_key_, pnNow)
		@cWhy = ""
		return [ :ok = 1, :nameID = _nameid_, :issuer = _issuer_,
		         :audience = _aud_, :notBefore = _nb_, :notOnOrAfter = _na_, :why = "" ]

	def NumberOfConsumedAssertions()
		return len(@aSeen)

	# drop replay records whose window has passed (housekeeping).
	def PurgeSeenAt(pnNow)
		_aNew_ = []
		_n_ = len(@aSeen)
		_k_ = 0
		for _i_ = 1 to _n_
			if pnNow < @aSeen[_i_][2]
				_aNew_ + @aSeen[_i_]
			else
				_k_++
			ok
		next
		@aSeen = _aNew_
		return _k_

	def Show()
		? "stzSamlServiceProvider(" + @cEntityId + ", idp=" + @cIdpEntityId + ")"

	  #==== internals ======================================================

	def _Refuse(pcWhy)
		@cWhy = "" + pcWhy
		# every rejected assertion is noted (I2) -- issuer/audience/window
		# failures are how a misconfigured or hostile IdP announces itself
		StzNoteRefusal("sso.assertion.rejected", @cIdpEntityId, "idp:" + @cIdpEntityId, @cWhy)
		return [ :ok = 0, :nameID = "", :issuer = "", :audience = "",
		         :notBefore = "", :notOnOrAfter = "", :why = @cWhy ]

	def _SeenIndex(pcKey)
		_n_ = len(@aSeen)
		for _i_ = 1 to _n_
			if @aSeen[_i_][1] = pcKey
				return _i_
			ok
		next
		return 0

	def _Remember(pcKey, pnNow)
		@aSeen + [ "" + pcKey, pnNow + 600 ]

	# base64 (standard, possibly with whitespace/newlines from a form post).
	def _DecodeB64(pcB64)
		_s_ = ""
		_in_ = "" + pcB64
		_n_ = len(_in_)
		for _i_ = 1 to _n_
			_c_ = _in_[_i_]
			if _c_ != " " and _c_ != nl and _c_ != char(13) and _c_ != char(9)
				_s_ += _c_
			ok
		next
		# the engine decodes base64url; standard base64 differs only in two chars
		_s_ = StzReplace(StzReplace(_s_, "+", "-"), "/", "_")
		_s_ = StzReplace(_s_, "=", "")
		return StzEngineCryptoB64UrlDecode(_s_)

	# "2026-07-24T10:05:00Z" -> epoch seconds (UTC; the only form SAML uses).
	def _Epoch(pcIso)
		_s_ = "" + pcIso
		if len(_s_) < 19
			return 0
		ok
		_y_ = 0 + StzLeft(_s_, 4)
		# StzMid takes a COUNT, not an end index
		_mo_ = 0 + StzMid(_s_, 6, 2)
		_d_ = 0 + StzMid(_s_, 9, 2)
		_h_ = 0 + StzMid(_s_, 12, 2)
		_mi_ = 0 + StzMid(_s_, 15, 2)
		_se_ = 0 + StzMid(_s_, 18, 2)
		return This._DaysFromCivil(_y_, _mo_, _d_) * 86400 + _h_ * 3600 + _mi_ * 60 + _se_

	# days since 1970-01-01 (Howard Hinnant's civil-from-days, inverted).
	def _DaysFromCivil(pnY, pnM, pnD)
		_y_ = pnY
		if pnM <= 2
			_y_ = _y_ - 1
		ok
		_era_ = floor(_y_ / 400)
		if _y_ < 0
			_era_ = floor((_y_ - 399) / 400)
		ok
		_yoe_ = _y_ - _era_ * 400
		_mp_ = pnM + 9
		if pnM > 2
			_mp_ = pnM - 3
		ok
		_doy_ = floor((153 * _mp_ + 2) / 5) + pnD - 1
		_doe_ = _yoe_ * 365 + floor(_yoe_ / 4) - floor(_yoe_ / 100) + _doy_
		return _era_ * 146097 + _doe_ - 719468

	def _Iso(pnEpoch)
		# a minimal UTC stamp for an outgoing AuthnRequest
		return "" + StzEngineTimeNowMs()

	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)
