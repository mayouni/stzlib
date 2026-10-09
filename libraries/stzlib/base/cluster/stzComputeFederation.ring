# base/cluster/stzComputeFederation.ring
# -----------------------------------------------------------------------------
# R8.6 (the SCALE plane, FINALE) -- stzComputeFederation: the GOVERNED
# MULTI-HOST CONSTELLATION. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md
# section 7.)
#
# A cluster spanning MACHINES IS an stzSuperApp constellation: this is
# that idea specialized for compute hosts. Member HOSTS each OFFER some
# facets at an endpoint; a federated compute request is DISCOVERED (which
# host offers the facet), GOVERNED (a bond must permit the caller, and
# the governance capability lattice -- the doc's "SLA/quality guarantees"
# -- must clear it: permission CAN + authority SHOULD vs the facet's risk
# tier), and TRANSPORTED over the wire via the reactor's async curl (R7).
# This closes the 2024 doc's "federated computational marketplace" on
# REAL primitives -- governance (R4b) as the SLA layer, curl as the
# transport, the facet catalog as the offering.
#
#   oFed = new stzComputeFederation("acme-grid")
#   oFed.Join("gpu-farm", "10.0.0.7:8080", [ :neural, :vision ])
#   oFed.Join("math-farm", "10.0.0.8:8080", [ :math ])
#   oFed.GovDeclareRisk("use-neural", 2).GovGrant("web-host", "use-neural")
#        .GovSetAuthority("web-host", :Delegated)
#   oFed.Bond("web-host", :neural)
#   ? oFed.FederatedCall("web-host", :neural, "/work?q=embed", "")  # governed + transported
#
# It is the SuperApp pattern (registry + bonds + governance) plus real
# transport + facet discovery -- the doc's federation, made executable.
# -----------------------------------------------------------------------------

func StzComputeFederationQ(pcName)
	return new stzComputeFederation(pcName)

# Governs a constellation of compute hosts: it discovers who offers a facet, clears the caller by bond and governance, then transports the call.
#
# Member hosts join with an endpoint and the facets they offer. A federated call to a facet is
# discovered (an active host must offer it), governed (a bond must permit the caller, and the
# governance lattice must clear the action use-facet against the caller's permission and authority)
# and only then transported to the first offering host over the reactor, signed when the caller has
# a registered key, and over mutual TLS when SetMutualTls was called. A refusal returns an empty
# text, sets the status to -1, says why in Why and is noted to the security ledger. The receiver
# side checks a signed request with VerifyInbound. The registry, bonds, governance and verification
# read and run in memory; a call that clears all gates contacts the host, so this reference only ran
# the refusal paths.
#
#   receiver   o1 = new stzComputeFederation("acme-grid"); o1.Join("gpu-farm", "10.0.0.7:8080", [
#              :neural, :vision ]) o1.Join("math-farm", "10.0.0.8:8080", [ :math ]); o1.Bond("web-
#              host", :neural)
#   example    ? @@(o1.MembersOffering(:neural))
#              #--> [ "gpu-farm" ]
#              ? o1.AreBonded("web-host", :neural)
#              #--> 1
#              ? len(o1.FederatedCall("stranger", :neural, "/work", ""))
#              #--> 0
#              ? o1.Why()
#              #--> no bond lets 'stranger' request facet 'neural'
#              ? o1.CallLastStatus()
#              #--> -1
#   see        stzGovernance, stzReactor, stzRequestSigner, stzSuperApp
class stzComputeFederation from stzObject

	@cName = ""
	@aMembers = []       # [ name, endpoint(host:port), [facets], active ]
	@oGov = ""         # governance: who may invoke which facet (the SLA layer)
	@aBonds = []         # [ caller, facet ]  a caller may request this facet
	@oReactor = ""     # transport (curl to remote hosts)
	@oSigner = ""      # HMAC request signing (authenticity + integrity)
	@aLastSig = []       # the last outbound signature envelope (observability)
	@nLastStatus = 0
	@nLastCallMs = 0   # duration of the last FederatedCall (ms; perf P3)
	@cWhy = ""
	# wire mTLS: when set, FederatedCall transports over a MUTUALLY
	# authenticated + encrypted mbedTLS channel instead of plain curl
	@bMtls = 0
	@cTlsCert = ""       # this node's client cert (presented to the peer)
	@cTlsKey = ""
	@cTlsCa = ""         # trust anchor for validating the peer server cert

	# Builds an empty federation of compute hosts with its own governance, reactor and request signer.
	#
	#   pcName     the federation name, also the name of its governance and signer
	#   returns    nothing; the object is built
	#   see        Join, FederatedCall
	def init(pcName)
		@cName = "" + pcName
		@oGov = new stzGovernance(@cName)
		@oReactor = new stzReactor()
		@oSigner = new stzRequestSigner(@cName)

	# Returns the name the federation was built with.
	#
	#   returns    a text
	#   see        Join
	def Name_()
		return @cName

	# Returns the reason of the last federated call: why it was allowed, or why it was refused.
	#
	#   returns    a text; empty before the first call
	#   see        FederatedCall, CallLastStatus
	def Why()
		return @cWhy

	# Returns the stzGovernance object that holds the permissions, risk tiers and authorities.
	#
	#   returns    the stzGovernance object
	#   see        GovDeclareRisk, GovGrant
	def GovernanceQ()
		return @oGov

	# Returns the stzReactor object that carries the calls on the wire.
	#
	#   returns    the stzReactor object
	#   see        FederatedCall, Shutdown
	def ReactorQ()
		return @oReactor

	# Registers a member host with its endpoint and the facets it offers; the host starts active.
	#
	#   pcName       the host name
	#   pcEndpoint   the host:port address of the host
	#   paFacets     a list of facet names, or one name, kept in lower case
	#   returns      the federation itself, so calls chain
	#   note         the endpoint is stored, not contacted
	#   warning      raises an error when a host of that name already joined
	#   see          MembersOffering, Retire, EndpointOf
	#@ aka  -- the registry: member hosts + what they offer -----------------------
	def Join(pcName, pcEndpoint, paFacets)
		if This._IndexOf(pcName) > 0
			stzraise("stzComputeFederation: host '" + pcName + "' already joined.")
		ok
		_aF_ = []
		if isList(paFacets)
			_nL_ = len(paFacets)
			for _i_ = 1 to _nL_
				_aF_ + StzLower("" + paFacets[_i_])
			next
		else
			_aF_ + StzLower("" + paFacets)
		ok
		@aMembers + [ "" + pcName, "" + pcEndpoint, _aF_, 1 ]
		return This

	# Returns how many hosts have joined, retired ones included.
	#
	#   returns    a number
	#   see        MemberNames, IsActive
	def NumberOfMembers()
		return len(@aMembers)

	# Returns the names of the joined hosts, in order of joining.
	#
	#   returns    a list of text
	#   see        NumberOfMembers, EndpointOf
	def MemberNames()
		_a_ = []
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			_a_ + @aMembers[_i_][1]
		next
		return _a_

	# TRUE if the host joined and is not retired.
	#
	#   pcName     the host name
	#   returns    TRUE or FALSE; FALSE for an unknown host
	#   see        Retire, Revive
	def IsActive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return 0  ok
		return @aMembers[_i_][4]

	# Takes a host out of discovery without forgetting it.
	#
	#   pcName     the host name
	#   returns    the federation itself, so calls chain
	#   warning    raises an error for a host that never joined
	#   see        Revive, MembersOffering
	def Retire(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  stzraise("No host '" + pcName + "'.")  ok
		@aMembers[_i_][4] = 0
		return This

	# Puts a retired host back into discovery.
	#
	#   pcName     the host name
	#   returns    the federation itself, so calls chain
	#   warning    raises an error for a host that never joined
	#   see        Retire, MembersOffering
	def Revive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  stzraise("No host '" + pcName + "'.")  ok
		@aMembers[_i_][4] = 1
		return This

	# Returns the active hosts that offer a facet, in order of joining.
	#
	#   pcFacet    the facet name, compared without regard to case
	#   returns    a list of host names; [ ] when none
	#   see        Join, FederatedCall
	#@ aka  Every ACTIVE host offering a facet.
	def MembersOffering(pcFacet)
		_cF_ = StzLower("" + pcFacet)
		_a_ = []
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			if @aMembers[_i_][4] and ring_find(@aMembers[_i_][3], _cF_) > 0
				_a_ + @aMembers[_i_][1]
			ok
		next
		return _a_

	# Returns the host:port address a host registered.
	#
	#   pcName     the host name
	#   returns    a text; empty for an unknown host
	#   see        Join, MemberNames
	def EndpointOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aMembers[_i_][2]

	# Declares the risk tier of an action in the governance lattice.
	#
	#   pcAction   the action name, use- followed by the facet
	#   nTier      the risk tier number
	#   returns    the federation itself, so calls chain
	#   note       a federated call is governed as the action use-facet
	#   see        GovGrant, GovSetAuthority, FederatedCall
	#@ aka  -- governance (the SLA layer; delegated -> one live @oGov) -------------
	def GovDeclareRisk(pcAction, nTier)
		@oGov.DeclareRisk(pcAction, nTier)
		return This
	# Grants a caller the permission to perform an action.
	#
	#   pcCaller   the caller name
	#   pcAction   the action name, use- followed by the facet
	#   returns    the federation itself, so calls chain
	#   note       a call also needs a bond: the permission alone does not let it through
	#   see        GovDeclareRisk, GovSetAuthority, Bond
	def GovGrant(pcCaller, pcAction)
		@oGov.GrantPermission(pcCaller, pcAction)
		return This
	# Sets the kind of authority a caller holds, which is weighed against the risk tier.
	#
	#   pcCaller   the caller name
	#   pcType     the authority, such as :Delegated
	#   returns    the federation itself, so calls chain
	#   see        GovDeclareRisk, GovGrant
	def GovSetAuthority(pcCaller, pcType)
		@oGov.SetAuthority(pcCaller, pcType)
		return This

	# Declares that a caller may request a facet across the grid.
	#
	#   pcCaller   the caller name
	#   pcFacet    the facet name, kept in lower case
	#   returns    the federation itself, so calls chain
	#   note       the bond is still checked against governance at call time
	#   see        AreBonded, GovGrant, FederatedCall
	#@ aka  A bond declares that pcCaller MAY request pcFacet across the grid (still governed at call time).
	def Bond(pcCaller, pcFacet)
		@aBonds + [ "" + pcCaller, StzLower("" + pcFacet) ]
		return This

	# TRUE if a bond lets the caller request the facet.
	#
	#   pcCaller   the caller name
	#   pcFacet    the facet name, compared without regard to case
	#   returns    TRUE or FALSE
	#   see        Bond, FederatedCall
	def AreBonded(pcCaller, pcFacet)
		_cF_ = StzLower("" + pcFacet)
		_n_ = len(@aBonds)
		for _i_ = 1 to _n_
			if @aBonds[_i_][1] = pcCaller and @aBonds[_i_][2] = _cF_
				return 1
			ok
		next
		return 0

	# Finds a host that offers a facet, lets the bond and governance clear the caller, then sends the request to the first such host.
	#
	#   pcCaller   the caller name
	#   pcFacet    the facet to request
	#   pcPath     the path on the host, which must start with a slash and hold no line break
	#   pcBody     the request body, or an empty text
	#   returns    the response body, a text; an empty text on refusal, with CallLastStatus below 0
	#              and Why saying why
	#   note       with a registered key the request is signed, and with SetMutualTls it goes over a
	#              mutually authenticated TLS channel instead of plain HTTP
	#   warning    refuses an unsafe path, a facet no active host offers, a caller with no bond and
	#              a caller governance refuses, and notes each refusal to the security ledger as
	#              federation.call.refused; only the refusals were run, since a cleared call
	#              contacts the host
	#   see        Bond, GovGrant, CallLastStatus, Why
	#@ aka  -- the federated compute call -----------------------------------------
	def FederatedCall(pcCaller, pcFacet, pcPath, pcBody)
		# perf P3: the whole crossing -- gates + signing + transport --
		# is timed on the monotonic clock; read it via LastCallMs().
		_nPerfT0_ = StzEngineWatchTimestampNs()
		_cFacet_ = StzLower("" + pcFacet)
		# SAFETY: a caller-controlled path must not override the target
		# host (SSRF) or smuggle via CRLF -- it must be a real path.
		if NOT This._SafePath(pcPath)
			return This._RefuseCall(pcCaller, _cFacet_, _nPerfT0_,
				"unsafe path rejected (must start with '/', no CRLF): " + pcPath)
		ok
		# DISCOVERY
		_aHosts_ = This.MembersOffering(_cFacet_)
		if len(_aHosts_) = 0
			return This._RefuseCall(pcCaller, _cFacet_, _nPerfT0_,
				"no active host offers facet '" + _cFacet_ + "'")
		ok
		# GOVERNANCE: a bond must permit the caller...
		if NOT This.AreBonded(pcCaller, _cFacet_)
			return This._RefuseCall(pcCaller, _cFacet_, _nPerfT0_,
				"no bond lets '" + pcCaller + "' request facet '" + _cFacet_ + "'")
		ok
		# ...and the capability lattice must clear it
		if @oGov.MayProceed(pcCaller, "use-" + _cFacet_) = 0
			return This._RefuseCall(pcCaller, _cFacet_, _nPerfT0_,
				"governance refused: " + @oGov.Why())
		ok
		# SIGN (opt-in): if this caller has a registered shared key, sign the
		# request and carry the envelope on the wire (_caller/_ts/_nonce/_sig).
		# The receiver -- sharing the key -- calls VerifyInbound to prove the
		# request is AUTHENTIC (really from pcCaller) and UNTAMPERED, closing
		# the "trust the asserted caller" gap. Unsigned when no key is set.
		_cEndpoint_ = This.EndpointOf(_aHosts_[1])
		_cWirePath_ = pcPath
		@aLastSig = []
		if @oSigner.HasKey(pcCaller)
			_env_ = @oSigner.SignNow(pcCaller, "GET", pcPath, "" + pcBody)
			@aLastSig = _env_
			_cSep_ = "?"
			if StzFindFirst("?", pcPath) > 0  _cSep_ = "&"  ok
			_cWirePath_ = pcPath + _cSep_ + "_caller=" + pcCaller +
				"&_ts=" + _env_[:ts] + "&_nonce=" + _env_[:nonce] + "&_sig=" + _env_[:sig]
		ok
		# TRANSPORT to the first offering host (round-robin/least-load is a
		# later refinement). Over WIRE mTLS when configured, else plain curl.
		_cResp_ = ""
		if @bMtls
			# mutually-authenticated, encrypted mbedTLS channel
			_cHost_ = This._HostOf(_cEndpoint_)
			_nPort_ = This._PortOf(_cEndpoint_)
			_cRaw_ = @oReactor.TlsGet(_cHost_, _nPort_, _cWirePath_,
				@cTlsCert, @cTlsKey, @cTlsCa, 1)
			_aRB_ = This._SplitHttpResponse(_cRaw_)
			@nLastStatus = _aRB_[1]
			_cResp_ = _aRB_[2]
			if @nLastStatus < 1  @nLastStatus = @oReactor.TlsClientStatus()  ok
		else
			_cUrl_ = "http://" + _cEndpoint_ + _cWirePath_
			_nJob_ = @oReactor.SubmitHttp(0, _cUrl_, "" + pcBody)
			_cResp_ = @oReactor.AwaitHttp(_nJob_, 8000)
			@nLastStatus = @oReactor.HttpLastStatus()
		ok
		@oGov.RecordDecision("fedcall-" + pcCaller + "-" + _cFacet_ + "-" + len(@aBonds),
			"federated compute call cleared + transported", pcCaller, "use-" + _cFacet_)
		@cWhy = "allowed: offered + bonded + governed" +
			iff(@bMtls, " + mTLS", "") + " -> " + _aHosts_[1]
		@nLastCallMs = (StzEngineWatchTimestampNs() - _nPerfT0_) / 1000000
		return _cResp_

	# Returns the status of the last federated call.
	#
	#   returns    a number: the HTTP status of a transported call, -1 for a refusal, 0 before any
	#              call
	#   see        FederatedCall, Why
	def CallLastStatus()
		return @nLastStatus

	# Returns how long the last federated call took, gates and transport included, in milliseconds.
	#
	#   returns    a number
	#   note       a refusal costs only what the gates cost
	#   see        FederatedCall
	#@ aka  Duration of the last FederatedCall, ms (gates + signing + transport; refusals cost what the gates cost).
	def LastCallMs()
		return @nLastCallMs

	# Shares a secret with a caller so that its federated calls are signed.
	#
	#   pcCaller   the caller name
	#   pcSecret   the shared signing secret
	#   returns    the federation itself, so calls chain
	#   note       signing is opt in for each caller; with no key a call goes unsigned
	#   see        LastSignature, VerifyInbound, SignerQ
	#@ aka  -- request signing (authenticity + integrity, under governance) -------
	def RegisterKey(pcCaller, pcSecret)
		@oSigner.AddKey(pcCaller, pcSecret)
		return This

	# Returns the stzRequestSigner object that signs and verifies requests.
	#
	#   returns    the stzRequestSigner object
	#   see        RegisterKey, VerifyInbound
	def SignerQ()
		return @oSigner

	# Makes every federated call run over a mutually authenticated, encrypted TLS channel.
	#
	#   pcCert     the path of this node certificate, presented to the peer
	#   pcKey      the path of its private key
	#   pcCa       the path of the trust anchor that validates the peer certificate
	#   returns    the federation itself, so calls chain
	#   note       the paths are only stored here; they are read when a call is made
	#   see        IsMtls, FederatedCall
	#@ aka  Run the federation transport over WIRE mTLS: every FederatedCall now goes over a mutually-authenticated, encrypted mbedTLS channel -- this node PRESENTS pcCert/pcKey and VALIDATES the peer's server cert against pcCa (slices 2-3). Combined with governance (SLA) + request signing (per-request auth), this is the full node-to-node security stack: encrypted + mutually cert-authenticated + signed + gove
	def SetMutualTls(pcCert, pcKey, pcCa)
		@bMtls = 1
		@cTlsCert = "" + pcCert
		@cTlsKey = "" + pcKey
		@cTlsCa = "" + pcCa
		return This

	# TRUE if calls are set to run over mutual TLS.
	#
	#   returns    TRUE or FALSE
	#   see        SetMutualTls
	def IsMtls()
		return @bMtls

	# Returns the signature envelope of the last signed call.
	#
	#   returns    a hash-list [ :kid, :ts, :nonce, :sig ]; [ ] when the last call was unsigned or
	#              none was made
	#   see        RegisterKey, VerifyInboundEnvelope
	#@ aka  The envelope [ :kid, :ts, :nonce, :sig ] of the most recent SIGNED FederatedCall (empty [] if the last call was unsigned).
	def LastSignature()
		return @aLastSig

	# TRUE if an inbound request is authentic, untampered, fresh and not a replay, as the receiving side checks it.
	#
	#   pcCaller      the caller the request claims to be from
	#   pcMethod      the HTTP method, such as GET
	#   pcPath        the request path
	#   pcBody        the request body
	#   pnTs          the timestamp from the envelope
	#   pcNonce       the nonce from the envelope
	#   pcSig         the signature from the envelope
	#   pnMaxSkewMs   the clock skew and replay window in milliseconds
	#   returns       TRUE or FALSE
	#   note          a changed path or body gives FALSE
	#   see           VerifyInboundEnvelope, RegisterKey
	#@ aka  The RECEIVER side: prove an inbound request is authentic + untampered + fresh + not replayed, before honoring it. pnMaxSkewMs bounds clock skew / replay window. Why() (via SignerQ) explains a rejection.
	def VerifyInbound(pcCaller, pcMethod, pcPath, pcBody, pnTs, pcNonce, pcSig, pnMaxSkewMs)
		return @oSigner.VerifyNow(pcCaller, pcMethod, pcPath, pcBody,
			pnTs, pcNonce, pcSig, pnMaxSkewMs)

	# TRUE if an inbound request is authentic, untampered, fresh and not a replay, judged from its whole envelope.
	#
	#   pcMethod      the HTTP method
	#   pcPath        the request path
	#   pcBody        the request body
	#   paEnvelope    the envelope as LastSignature gives it
	#   pnMaxSkewMs   the clock skew and replay window in milliseconds
	#   returns       TRUE or FALSE
	#   note          verifying the same envelope a second time gives FALSE, since its nonce was
	#                 used
	#   see           VerifyInbound, LastSignature
	#@ aka  Convenience: verify a whole envelope (as produced by LastSignature).
	def VerifyInboundEnvelope(pcMethod, pcPath, pcBody, paEnvelope, pnMaxSkewMs)
		return @oSigner.VerifyEnvelope(pcMethod, pcPath, pcBody, paEnvelope, pnMaxSkewMs)

	# Destroys the reactor that carries the calls.
	#
	#   returns    the federation itself, so calls chain
	#   note       calling it again changes nothing
	#   see        ReactorQ
	#@ aka  -- teardown -----------------------------------------------------------
	def Shutdown()
		if @oReactor != ""
			@oReactor.Destroy()
			@oReactor = ""
		ok
		return This

	#-- internals ----------------------------------------------------------

	# The ONE refusal door for a federated call (incident I2). Four checks
	# refuse here -- an SSRF-shaped path, a facet nobody offers, a missing
	# bond, and the capability lattice -- and each used to write @cWhy and
	# vanish. The first is an ATTACK signature rather than a
	# misconfiguration, so it deserves to survive the next call more than
	# any of them. Collapsing the four into one door also removed four
	# copies of the timing bookkeeping.
	def _RefuseCall(pcCaller, pcFacet, pnT0, pcWhy)
		@cWhy = "" + pcWhy
		@nLastStatus = -1
		@nLastCallMs = (StzEngineWatchTimestampNs() - pnT0) / 1000000
		StzNoteRefusal("federation.call.refused", "" + pcCaller,
			"facet:" + pcFacet, @cWhy)
		return ""

	# A federated path is safe only if it starts with "/" (so a bare host
	# / "@host" can never land in the URL authority -> no SSRF to an
	# arbitrary host; the endpoint stays operator-controlled) and carries
	# no CR/LF (no request smuggling).
	def _SafePath(pcPath)
		_c_ = "" + pcPath
		if _c_ = "" or StzLeft(_c_, 1) != "/"
			return 0
		ok
		if StzFindFirst(char(13), _c_) > 0 or StzFindFirst(char(10), _c_) > 0
			return 0
		ok
		return 1

	def _IndexOf(pcName)
		_c_ = "" + pcName
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			if @aMembers[_i_][1] = _c_  return _i_  ok
		next
		return 0

	#-- mTLS transport helpers (host:port split + HTTP response parse) ------

	def _HostOf(pcEndpoint)
		_a_ = StzSplit("" + pcEndpoint, ":")
		if len(_a_) >= 1  return _a_[1]  ok
		return "127.0.0.1"

	def _PortOf(pcEndpoint)
		_a_ = StzSplit("" + pcEndpoint, ":")
		if len(_a_) >= 2  return number(_a_[2])  ok
		return 0

	# Split a raw HTTP response into [ statusCode, body ]. TlsGet returns the
	# full response (status line + headers + body); the curl path returned
	# just the body, so this restores that contract for the mTLS branch.
	def _SplitHttpResponse(pcRaw)
		_c_ = "" + pcRaw
		if _c_ = ""  return [ -1, "" ]  ok
		_nCode_ = This._HttpStatusCode(_c_)
		_cSep_ = char(13) + char(10) + char(13) + char(10)
		_nHdrEnd_ = StzFindFirst(_cSep_, _c_)
		if _nHdrEnd_ = 0  return [ _nCode_, _c_ ]  ok
		return [ _nCode_, StzMidToEnd(_c_, _nHdrEnd_ + 4) ]

	def _HttpStatusCode(pcRaw)
		_nEol_ = StzFindFirst(char(13), "" + pcRaw)
		_cLine_ = "" + pcRaw
		if _nEol_ > 0  _cLine_ = StzLeft("" + pcRaw, _nEol_ - 1)  ok
		_a_ = StzSplit(_cLine_, " ")   # [ "HTTP/1.1", "200", "OK" ]
		if len(_a_) >= 2  return number(_a_[2])  ok
		return -1
