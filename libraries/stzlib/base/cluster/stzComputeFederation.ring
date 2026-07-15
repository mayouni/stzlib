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

func StzComputeFederation(pcName)
	return new stzComputeFederation(pcName)

class stzComputeFederation from stzObject

	@cName = ""
	@aMembers = []       # [ name, endpoint(host:port), [facets], active ]
	@oGov = NULL         # governance: who may invoke which facet (the SLA layer)
	@aBonds = []         # [ caller, facet ]  a caller may request this facet
	@oReactor = NULL     # transport (curl to remote hosts)
	@nLastStatus = 0
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName
		@oGov = new stzGovernance(@cName)
		@oReactor = new stzReactor()

	def Name_()
		return @cName

	def Why()
		return @cWhy

	def GovernanceQ()
		return @oGov

	def ReactorQ()
		return @oReactor

	#-- the registry: member hosts + what they offer -----------------------

	# Register a host: its endpoint (host:port) and the facets it offers.
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
		@aMembers + [ "" + pcName, "" + pcEndpoint, _aF_, TRUE ]
		return This

	def NumberOfMembers()
		return len(@aMembers)

	def MemberNames()
		_a_ = []
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			_a_ + @aMembers[_i_][1]
		next
		return _a_

	def IsActive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return FALSE  ok
		return @aMembers[_i_][4]

	def Retire(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  stzraise("No host '" + pcName + "'.")  ok
		@aMembers[_i_][4] = FALSE
		return This

	def Revive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  stzraise("No host '" + pcName + "'.")  ok
		@aMembers[_i_][4] = TRUE
		return This

	# Every ACTIVE host offering a facet.
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

	def EndpointOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aMembers[_i_][2]

	#-- governance (the SLA layer; delegated -> one live @oGov) -------------

	def GovDeclareRisk(pcAction, nTier)
		@oGov.DeclareRisk(pcAction, nTier)
		return This
	def GovGrant(pcCaller, pcAction)
		@oGov.GrantPermission(pcCaller, pcAction)
		return This
	def GovSetAuthority(pcCaller, pcType)
		@oGov.SetAuthority(pcCaller, pcType)
		return This

	# A bond declares that pcCaller MAY request pcFacet across the grid
	# (still governed at call time).
	def Bond(pcCaller, pcFacet)
		@aBonds + [ "" + pcCaller, StzLower("" + pcFacet) ]
		return This

	def AreBonded(pcCaller, pcFacet)
		_cF_ = StzLower("" + pcFacet)
		_n_ = len(@aBonds)
		for _i_ = 1 to _n_
			if @aBonds[_i_][1] = pcCaller and @aBonds[_i_][2] = _cF_
				return TRUE
			ok
		next
		return FALSE

	#-- the federated compute call -----------------------------------------

	# Discover a host offering pcFacet, gate the call (bond + governance
	# capability lattice), and transport pcPath/pcBody to it via curl.
	# Returns the remote response body; "" (with CallLastStatus < 0 and
	# Why()) on refusal. The governed action is "use-<facet>".
	def FederatedCall(pcCaller, pcFacet, pcPath, pcBody)
		_cFacet_ = StzLower("" + pcFacet)
		# SAFETY: a caller-controlled path must not override the target
		# host (SSRF) or smuggle via CRLF -- it must be a real path.
		if NOT This._SafePath(pcPath)
			@cWhy = "unsafe path rejected (must start with '/', no CRLF): " + pcPath
			@nLastStatus = -1
			return ""
		ok
		# DISCOVERY
		_aHosts_ = This.MembersOffering(_cFacet_)
		if len(_aHosts_) = 0
			@cWhy = "no active host offers facet '" + _cFacet_ + "'"
			@nLastStatus = -1
			return ""
		ok
		# GOVERNANCE: a bond must permit the caller...
		if NOT This.AreBonded(pcCaller, _cFacet_)
			@cWhy = "no bond lets '" + pcCaller + "' request facet '" + _cFacet_ + "'"
			@nLastStatus = -1
			return ""
		ok
		# ...and the capability lattice must clear it
		if @oGov.MayProceed(pcCaller, "use-" + _cFacet_) = 0
			@cWhy = "governance refused: " + @oGov.Why()
			@nLastStatus = -1
			return ""
		ok
		# TRANSPORT: curl to the first offering host (round-robin/least-load
		# is a later refinement)
		_cEndpoint_ = This.EndpointOf(_aHosts_[1])
		_cUrl_ = "http://" + _cEndpoint_ + pcPath
		_nJob_ = @oReactor.SubmitHttp(0, _cUrl_, "" + pcBody)
		_cResp_ = @oReactor.AwaitHttp(_nJob_, 8000)
		@nLastStatus = @oReactor.HttpLastStatus()
		@oGov.RecordDecision("fedcall-" + pcCaller + "-" + _cFacet_ + "-" + len(@aBonds),
			"federated compute call cleared + transported", pcCaller, "use-" + _cFacet_)
		@cWhy = "allowed: offered + bonded + governed -> " + _aHosts_[1]
		return _cResp_

	def CallLastStatus()
		return @nLastStatus

	#-- teardown -----------------------------------------------------------

	def Shutdown()
		if @oReactor != NULL
			@oReactor.Destroy()
			@oReactor = NULL
		ok
		return This

	#-- internals ----------------------------------------------------------

	# A federated path is safe only if it starts with "/" (so a bare host
	# / "@host" can never land in the URL authority -> no SSRF to an
	# arbitrary host; the endpoint stays operator-controlled) and carries
	# no CR/LF (no request smuggling).
	def _SafePath(pcPath)
		_c_ = "" + pcPath
		if _c_ = "" or StzLeft(_c_, 1) != "/"
			return FALSE
		ok
		if StzFindFirst(_c_, char(13)) > 0 or StzFindFirst(_c_, char(10)) > 0
			return FALSE
		ok
		return TRUE

	def _IndexOf(pcName)
		_c_ = "" + pcName
		_n_ = len(@aMembers)
		for _i_ = 1 to _n_
			if @aMembers[_i_][1] = _c_  return _i_  ok
		next
		return 0
