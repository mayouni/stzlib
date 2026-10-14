#================================================================#
#  STZSAMLPROVIDER -- Softanza AS a SAML identity provider         #
#================================================================#

/*--- Issuing assertions, not just consuming them.

stzSamlServiceProvider made Softanza a SAML *service* provider: log my users in
through the corporate IdP. This is the other side -- your Softanza app BECOMES
the identity provider that other services trust. It is what an enterprise SSO
portal does: authenticate the employee once, then vouch for them to every
application that has registered with you.

It is also the piece that makes SAML developable at all. Wiring a service
provider normally means an Okta or ADFS tenant and a browser round-trip; with
this you can issue a genuine, correctly-signed assertion locally and feed it
straight to your SP. The assertion is real -- signed by the engine with ECDSA-
SHA256 over exclusive-canonical bytes, verified by the same canonicalizer the SP
uses -- so what you exercise in development is what runs in production.

    oIdp = new stzSamlIdentityProvider("https://idp.local")
    oIdp.RegisterServiceProvider("https://sp.example.com", "https://sp.example.com/acs")
    cXml = oIdp.IssueAssertion("dana@acme.com", "https://sp.example.com")
    #   -> a signed <saml:Assertion> the SP will accept

WHAT IT REFUSES, and why:
  * an unregistered audience -- an IdP that will vouch for a user to ANY service
    that asks is an open redirect for identity;
  * an empty subject or audience, which would produce an assertion no SP can
    safely consume.

The signing key never leaves the provider; only PublicKey()/its (x, y) go to a
service provider, which is all it needs to verify.
*/

func StzSamlIdentityProviderQ(pcEntityId)
	return new stzSamlIdentityProvider(pcEntityId)


# Issues signed SAML assertions for registered services, so a service provider can be developed and tested without an external identity provider.
#
# Assertions are signed by the engine with ECDSA-SHA256 over a P-256 key (random, or derived from a
# seed for repeatable tests) or with RSA-SHA256 over a key you supply or generate. Only a registered
# service can be the audience: an identity provider that vouches for any service that asks is an
# open redirect for identity. Subject and audience are escaped for & < and > before they enter the
# XML, so a subject holding markup cannot inject elements (checked with a quote, angle brackets and
# an ampersand); the issuer entity id, set by the operator, is written as given. The private key
# never leaves the object: PublicKey and TrustMeOn hand over only what a service provider needs. Use
# invented identities and keys in tests.
#
#   receiver   o1 = new stzSamlIdentityProvider("https://idp.invented.test")
#   example    o1.RegisterServiceProvider("https://sp.invented.test", "https://sp.invented.test/acs")
#              ? o1.SigningAlgorithm()
#              #--> ES256
#              ? o1.ServiceProviderIds()[1]
#              #--> https://sp.invented.test
#              cXml = o1.UnsignedAssertion("a<b", "https://sp.invented.test", 1790000000, 300)
#              ? len(StzFind("<saml:NameID>a&lt;b</saml:NameID>", cXml)) > 0
#              #--> 1
#   see        stzSamlServiceProvider
class stzSamlIdentityProvider from stzObject

	@cEntityId = ""
	@cAlg = "ES256"       # ES256 (an engine key) or RS256 (a PEM you supply)
	@cPem = ""            # the RSA private key, when signing RSA-SHA256
	@cN = ""              # its public parts, for a service provider to verify with
	@cE = ""
	@cD = ""              # the private signing key -- never published
	@cX = ""
	@cY = ""
	@aSps = []            # [ [ entityId, acsUrl ], ... ] the services we vouch to
	@nLifetimeSecs = 300  # how long an assertion stays valid (SAML windows are short)

	# Builds an identity provider with a fresh random P-256 signing key.
	#
	#   pcEntityId   this provider's entity id, written as the issuer of every assertion
	#   returns      nothing; the object is built
	#   note         the issuer is written into the assertion as given, without XML escaping
	#   warning      raises an error when pcEntityId is empty or only spaces
	#   see          RegisterServiceProvider, TrustMeOn
	def init(pcEntityId)
		@cEntityId = ring_trim("" + pcEntityId)
		if @cEntityId = ""
			StzRaise("stzSamlIdentityProvider: an issuer entity id is required.")
		ok
		@aSps = []
		This.UseSeedQ("")

	# Returns this provider's entity id, the issuer of its assertions.
	#
	#   returns    a text
	#   see        init
	#@ aka  -- identity + key ---------------------------------------------------
	def EntityId()
		return @cEntityId

	# Replaces the signing key with an ES256 key derived from a seed, so assertions can be reproduced in a test.
	#
	#   pcSeedHex   the 32-byte seed as 64 hex characters, or an empty text for a random key
	#   returns     nothing; use UseSeedQ to chain
	#   note        the same seed always gives the same public key
	#   warning     raises an error when the seed is not valid hex
	#   see         UseRsaKey, PublicKey
	#@ aka  a deterministic key from a 32-byte hex seed ("" = random), so a test suite can pin an IdP and reproduce its assertions.
	def UseSeed(pcSeedHex)
		This.UseSeedQ(pcSeedHex)

	def UseSeedQ(pcSeedHex)
		_t_ = StzEngineCryptoEs256KeyPair("" + pcSeedHex)
		if _t_ = ""
			StzRaise("stzSamlIdentityProvider: could not generate a signing key.")
		ok
		_a_ = StzSplit(_t_, "|")
		if len(_a_) != 3
			StzRaise("stzSamlIdentityProvider: malformed key material from the engine.")
		ok
		@cD = _a_[1]
		@cX = _a_[2]
		@cY = _a_[3]
		return This

	# Returns the signature algorithm in use.
	#
	#   returns    the text ES256, or RS256 after an RSA key was set
	#   see        UseSeed, UseRsaKey
	def SigningAlgorithm()
		return @cAlg

	# Signs assertions RSA-SHA256 with a private key you supply, for service providers that accept RSA only.
	#
	#   pcPem      the RSA private key as PEM text
	#   returns    nothing; use UseRsaKeyQ to chain
	#   note       the EC key material is cleared, so KeyX and KeyY answer an empty text afterwards
	#   warning    raises an error when the PEM cannot be read
	#   see        UseNewRsaKey, SigningAlgorithm
	#@ aka  Sign assertions RSA-SHA256 with a key you already have. This is the one that matters in practice: a good number of enterprise service providers accept RSA only, so an ECDSA-only IdP simply cannot federate with them.
	def UseRsaKey(pcPem)
		This.UseRsaKeyQ(pcPem)

	def UseRsaKeyQ(pcPem)
		_p_ = StzRsaPublicKey(pcPem)
		if len(_p_) = 0
			StzRaise("stzSamlIdentityProvider.UseRsaKey: the private key could not be read (PEM expected).")
		ok
		@cPem = "" + pcPem
		@cN = _p_[:n]
		@cE = _p_[:e]
		@cAlg = "RS256"
		@cX = ""
		@cY = ""
		@cD = ""
		return This

	# Generates a fresh RSA key and signs with it from now on.
	#
	#   nBits      the key size in bits, from 2048 to 4096
	#   returns    nothing; use UseNewRsaKeyQ to chain
	#   note       for development and first runs
	#   warning    raises an error for a size outside 2048 to 4096; generating a key takes a moment
	#   see        UseRsaKey, PublicKey
	def UseNewRsaKey(nBits)
		This.UseNewRsaKeyQ(nBits)

	def UseNewRsaKeyQ(nBits)
		return This.UseRsaKeyQ( StzRsaKeyPair(nBits)[:privateKey] )

	# Returns the public half of the signing key, which is all a service provider needs to verify.
	#
	#   returns    a hash list with kty EC and crv, x, y, or kty RSA and n, e
	#   see        TrustMeOn, KeyX
	#@ aka  the PUBLIC half -- what a service provider needs to verify us.
	def PublicKey()
		if @cAlg = "RS256"
			return [ :kty = "RSA", :n = @cN, :e = @cE ]
		ok
		return [ :kty = "EC", :crv = "P-256", :x = @cX, :y = @cY ]

	# Returns the x coordinate of the public EC key in base64url, or an empty text under RSA.
	#
	#   returns    a text
	#   see        KeyY, PublicKey
	def KeyX()
		return @cX

	# Returns the y coordinate of the public EC key in base64url, or an empty text under RSA.
	#
	#   returns    a text
	#   see        KeyX, PublicKey
	def KeyY()
		return @cY

	# Makes a service provider trust this identity provider, passing it the entity id and the public key.
	#
	#   poServiceProvider   the stzSamlServiceProvider that is to trust this issuer
	#   returns             the identity provider itself, so calls chain
	#   note                the key handed over is the one in use at the call: change the key and
	#                       call it again to follow; the service provider's earlier trust is
	#                       replaced
	#   see                 PublicKey, RegisterServiceProvider
	#@ aka  hand a service provider everything it needs to trust us, in one call.
	def TrustMeOn(poServiceProvider)
		if @cAlg = "RS256"
			poServiceProvider.TrustIdpQ(@cEntityId, "RSA", @cN, @cE)
		else
			poServiceProvider.TrustIdpQ(@cEntityId, "EC", @cX, @cY)
		ok
		return This

	# Sets, in seconds, how long a new assertion stays valid.
	#
	#   pnSecs     the validity of each assertion in seconds
	#   returns    nothing; use SetLifetimeQ to chain
	#   note       the default is 300 seconds
	#   see        Lifetime, IssueAssertionXT
	def SetLifetime(pnSecs)
		This.SetLifetimeQ(pnSecs)

	def SetLifetimeQ(pnSecs)
		@nLifetimeSecs = pnSecs
		return This

	# Returns how long a new assertion stays valid, in seconds.
	#
	#   returns    a number
	#   see        SetLifetime
	def Lifetime()
		return @nLifetimeSecs

	# Registers a service this provider may vouch for.
	#
	#   pcEntityId   the service provider's entity id, trimmed
	#   pcAcsUrl     its assertion consumer URL
	#   returns      the identity provider itself, so calls chain
	#   note         only a registered entity id can be the audience of an assertion
	#   warning      raises an error for an empty entity id and for one already registered
	#   see          HasServiceProvider, IssueAssertion
	#@ aka  -- the services we vouch for ----------------------------------------
	def RegisterServiceProvider(pcEntityId, pcAcsUrl)
		_id_ = ring_trim("" + pcEntityId)
		if _id_ = ""
			StzRaise("stzSamlIdentityProvider.RegisterServiceProvider: an entity id is required.")
		ok
		if This.HasServiceProvider(_id_)
			StzRaise("stzSamlIdentityProvider: service provider '" + _id_ + "' is already registered.")
		ok
		@aSps + [ _id_, "" + pcAcsUrl ]
		return This

	# TRUE if a service of that entity id is registered.
	#
	#   pcEntityId   the service provider's entity id, trimmed before the comparison
	#   returns      TRUE or FALSE
	#   see          RegisterServiceProvider, ServiceProviderIds
	def HasServiceProvider(pcEntityId)
		_id_ = ring_trim("" + pcEntityId)
		_n_ = len(@aSps)
		for _i_ = 1 to _n_
			if @aSps[_i_][1] = _id_
				return 1
			ok
		next
		return 0

	# Returns the entity ids of the registered services, in registration order.
	#
	#   returns    a list of texts
	#   see        RegisterServiceProvider, AcsUrlOf
	def ServiceProviderIds()
		_out_ = []
		_n_ = len(@aSps)
		for _i_ = 1 to _n_
			_out_ + @aSps[_i_][1]
		next
		return _out_

	# Returns the consumer URL a service was registered with, or an empty text for an unknown service.
	#
	#   pcEntityId   the service provider's entity id
	#   returns      a text
	#   see          RegisterServiceProvider
	def AcsUrlOf(pcEntityId)
		_id_ = ring_trim("" + pcEntityId)
		_n_ = len(@aSps)
		for _i_ = 1 to _n_
			if @aSps[_i_][1] = _id_
				return @aSps[_i_][2]
			ok
		next
		return ""

	# Returns a signed assertion XML vouching for a subject to a registered service, valid from now.
	#
	#   pcSubject    the subject name, trimmed
	#   pcAudience   the entity id of a registered service
	#   returns      a text holding the signed XML
	#   note         the subject is escaped for & < and > in the XML; a quote is left as it is,
	#                which element content allows
	#   warning      raises an error for an empty subject, an empty audience, and an audience that
	#                is not registered
	#   see          IssueAssertionAt, IssueAssertionXT, IssueResponse
	#@ aka  -- issuing ----------------------------------------------------------
	def IssueAssertion(pcSubject, pcAudience)
		return This.IssueAssertionAt(pcSubject, pcAudience, This._NowSecs())

	# Returns a signed assertion XML whose validity starts at a given moment.
	#
	#   pcSubject    the subject name
	#   pcAudience   the entity id of a registered service
	#   pnNow        the start of validity in epoch seconds
	#   returns      a text holding the signed XML
	#   note         the window ends Lifetime seconds after pnNow
	#   warning      raises the same errors as IssueAssertion
	#   see          IssueAssertion, IssueAssertionXT
	def IssueAssertionAt(pcSubject, pcAudience, pnNow)
		return This.IssueAssertionXT(pcSubject, pcAudience, pnNow, @nLifetimeSecs)

	# ...with an explicit validity window, so a test can mint an already-expired
	# assertion and prove the service provider refuses it.
	def IssueAssertionXT(pcSubject, pcAudience, pnNow, pnLifetime)
		_sub_ = ring_trim("" + pcSubject)
		_aud_ = ring_trim("" + pcAudience)
		if _sub_ = ""
			StzRaise("stzSamlIdentityProvider: an assertion needs a subject.")
		ok
		if _aud_ = ""
			StzRaise("stzSamlIdentityProvider: an assertion needs an audience.")
		ok
		# An IdP that vouches for a user to ANY service that asks is an open
		# redirect for identity. Only registered services get an assertion.
		if NOT This.HasServiceProvider(_aud_)
			StzRaise("stzSamlIdentityProvider: '" + _aud_ + "' is not a registered service provider.")
		ok
		_xml_ = This.UnsignedAssertion(_sub_, _aud_, pnNow, pnLifetime)
		if @cAlg = "RS256"
			_signed_ = StzEngineSamlSignRsa(_xml_, @cPem)
		else
			_signed_ = StzEngineSamlSign(_xml_, @cD)
		ok
		if _signed_ = ""
			StzRaise("stzSamlIdentityProvider: the assertion could not be signed.")
		ok
		return _signed_

	# Returns the assertion XML before it is signed, with the subject and audience escaped for & < and >.
	#
	#   pcSubject    the subject name
	#   pcAudience   the audience entity id
	#   pnNow        the start of validity in epoch seconds
	#   pnLifetime   the length of validity in seconds
	#   returns      a text holding the XML, with no signature
	#   note         the registration of the audience is not checked here; a subject such as
	#                a"b<c>&d gives a"b&lt;c&gt;&amp;d in the NameID element, so markup cannot be
	#                injected through the subject
	#   see          IssueAssertionXT
	#@ aka  the assertion before signing -- exposed because seeing it makes the shape obvious, and because a test can sign a deliberately odd one.
	def UnsignedAssertion(pcSubject, pcAudience, pnNow, pnLifetime)
		_id_ = "_" + StzEngineCryptoRandomHex(16)
		return '<saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ' +
		       'ID="' + _id_ + '" Version="2.0" IssueInstant="' + This._Iso(pnNow) + '">' +
		       '<saml:Issuer>' + @cEntityId + '</saml:Issuer>' +
		       '<saml:Subject><saml:NameID>' + This._Esc(pcSubject) + '</saml:NameID></saml:Subject>' +
		       '<saml:Conditions NotBefore="' + This._Iso(pnNow) + '" ' +
		       'NotOnOrAfter="' + This._Iso(pnNow + pnLifetime) + '">' +
		       '<saml:AudienceRestriction><saml:Audience>' + This._Esc(pcAudience) +
		       '</saml:Audience></saml:AudienceRestriction></saml:Conditions>' +
		       '<saml:AuthnStatement AuthnInstant="' + This._Iso(pnNow) + '" ' +
		       'SessionIndex="' + StzEngineCryptoRandomHex(8) + '"/>' +
		       '</saml:Assertion>'

	# Returns a signed assertion encoded in base64url, ready to post to the service provider.
	#
	#   pcSubject    the subject name
	#   pcAudience   the entity id of a registered service
	#   returns      a text
	#   note         the encoding is url-safe base64, which stzSamlServiceProvider accepts
	#   warning      raises the same errors as IssueAssertion
	#   see          IssueResponseAt, IssueAssertion
	#@ aka  the same, base64'd the way a browser would POST it to the SP.
	def IssueResponse(pcSubject, pcAudience)
		return StzB64UrlEncode(This.IssueAssertion(pcSubject, pcAudience))

	# Returns a signed assertion in base64url whose validity starts at a given moment.
	#
	#   pcSubject    the subject name
	#   pcAudience   the entity id of a registered service
	#   pnNow        the start of validity in epoch seconds
	#   returns      a text
	#   warning      raises the same errors as IssueAssertion
	#   see          IssueResponse, IssueAssertionAt
	def IssueResponseAt(pcSubject, pcAudience, pnNow)
		return StzB64UrlEncode(This.IssueAssertionAt(pcSubject, pcAudience, pnNow))

	# Prints the provider's entity id and how many services are registered.
	#
	#   returns    nothing; it prints a line
	#   see        RegisterServiceProvider
	def Show()
		? "stzSamlIdentityProvider(" + @cEntityId + ", " + len(@aSps) + " service(s))"

	  #==== internals ======================================================

	# epoch seconds -> the UTC stamp SAML uses. Civil-from-days, so the value the
	# service provider parses back is exactly the one we meant.
	def _Iso(pnEpoch)
		_days_ = floor(pnEpoch / 86400)
		_rem_ = pnEpoch - _days_ * 86400
		_z_ = _days_ + 719468
		_era_ = floor(_z_ / 146097)
		_doe_ = _z_ - _era_ * 146097
		_yoe_ = floor((_doe_ - floor(_doe_/1460) + floor(_doe_/36524) - floor(_doe_/146096)) / 365)
		_y_ = _yoe_ + _era_ * 400
		_doy_ = _doe_ - (365 * _yoe_ + floor(_yoe_/4) - floor(_yoe_/100))
		_mp_ = floor((5 * _doy_ + 2) / 153)
		_d_ = _doy_ - floor((153 * _mp_ + 2) / 5) + 1
		_m_ = _mp_ + 3
		if _mp_ >= 10
			_m_ = _mp_ - 9
		ok
		if _m_ <= 2
			_y_ = _y_ + 1
		ok
		_h_ = floor(_rem_ / 3600)
		_mi_ = floor((_rem_ - _h_ * 3600) / 60)
		_se_ = _rem_ - _h_ * 3600 - _mi_ * 60
		return "" + _y_ + "-" + This._Pad(_m_) + "-" + This._Pad(_d_) + "T" +
		       This._Pad(_h_) + ":" + This._Pad(_mi_) + ":" + This._Pad(_se_) + "Z"

	def _Pad(pn)
		if pn < 10
			return "0" + pn
		ok
		return "" + pn

	# XML-escape a value we place into element content
	def _Esc(pcVal)
		_s_ = StzReplace("" + pcVal, "&", "&amp;")
		_s_ = StzReplace(_s_, "<", "&lt;")
		return StzReplace(_s_, ">", "&gt;")

	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)
