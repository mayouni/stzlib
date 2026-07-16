# base/app/stzSuperApp.ring
# -----------------------------------------------------------------------------
# stzSuperApp -- "a living CONSTELLATION of worlds."
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10: worlds composed, commons,
#  norms.) A GOVERNED GRAPH whose nodes are stzApps (and, recursively,
#  other stzSuperApps -- a graph-of-graphs), sharing a COMMONS ("world
#  zero": identity/data/services), bound by NORM-GATED BONDS under an
#  ambient GOVERNANCE, with HOT-SWAPPABLE worlds via the registry graph.
#
#   oCon = new stzSuperApp("acme")
#   oCon.AddWorld("resto", oRestoApp)
#   oCon.AddWorld("supplier", oSupplierApp)
#   oCon.OpenCommonsOn(oDb)                       # world-zero backing store
#   oCon.GovDeclareRisk("order-produce", 2)
#   oCon.GovGrant("resto", "order-produce")
#   oCon.GovSetAuthority("resto", :Delegated)
#   oCon.Bond("resto", "supplier", "order-produce")
#   ? oCon.CallAcross("resto", "supplier", "order-produce")   # governed
#   oCon.Swap("supplier", oNewSupplierApp)    # hot-swap a live world
#
# WHAT IT ADDS OVER stzPlatform's registry floor: the nodes are REAL
# world objects (not name/version records), composition is RECURSIVE (a
# node may be another constellation), and the Commons is a first-class
# shared runtime. Cross-world calls proceed ONLY when both worlds are
# active AND a bond declares the action AND governance clears the
# caller -- every refusal narrates (LAW 3).
#
# RING-TRUE: governance is pure Ring lists (no shared handle) so its
# config is delegated THROUGH the constellation (GovDeclareRisk/GovGrant/
# GovSetAuthority) -- one live @oGov, never a stale caller copy. The
# Commons (an stzPlatform) shares its sqlite handle, so commons ops
# through @oCommons persist. World objects are reached via the registry
# index (the live path).
# -----------------------------------------------------------------------------

func StzSuperAppQ(pcName)
	return new stzSuperApp(pcName)

class stzSuperApp from stzObject

	@cName    = ""
	@oGraph   = NULL       # world nodes + :bond edges
	@aWorlds  = []         # [ name, obj, kind("app"|"super"), active ]
	@oCommons = NULL       # world-zero: an stzPlatform (identity/stores)
	@oGov     = NULL       # ambient governance
	@aBonds   = []         # [ from, to, action ]
	@cWhy     = ""

	def init(pcName)
		@cName = "" + pcName
		@oGraph = new stzGraph("constellation-" + @cName)
		@oCommons = new stzPlatform(@cName + "-commons")
		@oGov = new stzGovernance(@cName)

	def Name_()
		return @cName

	def Why()
		return @cWhy

	def GraphQ()
		return @oGraph

	def GovernanceQ()
		return @oGov

	def CommonsQ()
		return @oCommons

	#-- the registry: worlds as nodes --------------------------------------

	def AddWorld(pcName, poApp)
		return This._Register(pcName, poApp, "app")

	# recursion: a constellation may contain another constellation
	def AddConstellation(pcName, poSuper)
		return This._Register(pcName, poSuper, "super")

	def _Register(pcName, poObj, pcKind)
		_cN_ = "" + pcName
		if This._IndexOf(_cN_) > 0
			stzraise("stzSuperApp: world '" + _cN_ + "' already in the constellation.")
		ok
		if NOT @oGraph.NodeExists(_cN_)
			@oGraph.AddNode(_cN_)
		ok
		@aWorlds + [ _cN_, poObj, pcKind, TRUE ]
		return This

	# the LIVE world object (reached via the registry index)
	def WorldQ(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return NULL  ok
		return @aWorlds[_i_][2]

	def KindOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aWorlds[_i_][3]

	def WorldNames()
		_acOut_ = []
		_n_ = len(@aWorlds)
		for _i_ = 1 to _n_
			_acOut_ + @aWorlds[_i_][1]
		next
		return _acOut_

	def NumberOfWorlds()
		return len(@aWorlds)

	def HasWorld(pcName)
		return This._IndexOf(pcName) > 0

	def IsActive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return FALSE  ok
		return @aWorlds[_i_][4]

	def Retire(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Retire: no world '" + pcName + "'.")
		ok
		@aWorlds[_i_][4] = FALSE
		return This

	def Revive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Revive: no world '" + pcName + "'.")
		ok
		@aWorlds[_i_][4] = TRUE
		return This

	# HOT-SWAP a live world's implementation, keeping its node + bonds.
	def Swap(pcName, poNewApp)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Swap: no world '" + pcName + "' to swap.")
		ok
		@aWorlds[_i_][2] = poNewApp
		@aWorlds[_i_][4] = TRUE
		return This

	#-- the Commons (world zero) -------------------------------------------

	# Back the shared Commons with an open stzDatabase.
	def OpenCommonsOn(poDb)
		@oCommons.OpenCommonsOn(poDb)
		return This

	def RegisterIdentity(pcUser, pcSecret)
		return @oCommons.RegisterIdentity(pcUser, pcSecret)

	def OpenSession(pcUser, pcSecret)
		return @oCommons.OpenSession(pcUser, pcSecret)

	def StorePut(pcKey, pcValue)
		@oCommons.StorePut(pcKey, pcValue)
		return This

	def StoreGet(pcKey)
		return @oCommons.StoreGet(pcKey)

	#-- ambient governance (delegated -> one live @oGov) -------------------

	def GovDeclareRisk(pcAction, nTier)
		@oGov.DeclareRisk(pcAction, nTier)
		return This

	def GovGrant(pcActor, pcAction)
		@oGov.GrantPermission(pcActor, pcAction)
		return This

	def GovSetAuthority(pcActor, pcType)
		@oGov.SetAuthority(pcActor, pcType)
		return This

	#-- norm-gated bonds ---------------------------------------------------

	# Declare that pcFrom MAY attempt pcAction on pcTo (still governed at
	# call time). Records a :bond edge in the constellation graph.
	def Bond(pcFrom, pcTo, pcAction)
		if This._IndexOf(pcFrom) = 0 or This._IndexOf(pcTo) = 0
			stzraise("stzSuperApp.Bond: both worlds must be registered first.")
		ok
		@aBonds + [ "" + pcFrom, StzLower("" + pcTo), StzLower("" + pcAction) ]
		if NOT @oGraph.EdgeExists(pcFrom, pcTo)
			@oGraph.AddEdgeXTT(pcFrom, pcTo, "bond", [ :action = StzLower("" + pcAction) ])
		ok
		return This

	def AreBonded(pcFrom, pcTo, pcAction)
		_cTo_ = StzLower("" + pcTo)
		_cAction_ = StzLower("" + pcAction)
		_n_ = len(@aBonds)
		for _i_ = 1 to _n_
			if @aBonds[_i_][1] = pcFrom and @aBonds[_i_][2] = _cTo_ and @aBonds[_i_][3] = _cAction_
				return TRUE
			ok
		next
		return FALSE

	# THE ENFORCEMENT SEAM: a cross-world call proceeds ONLY when both
	# worlds are active, a bond declares the action, and governance
	# clears the caller. Returns TRUE/FALSE; Why() explains refusals.
	def CallAcross(pcFrom, pcTo, pcAction)
		if NOT This.IsActive(pcFrom)
			@cWhy = "calling world '" + pcFrom + "' is not active."
			return FALSE
		ok
		if NOT This.IsActive(pcTo)
			@cWhy = "target world '" + pcTo + "' is not active."
			return FALSE
		ok
		if NOT This.AreBonded(pcFrom, pcTo, pcAction)
			@cWhy = "no bond declares '" + StzLower("" + pcAction) + "' from '" +
				pcFrom + "' to '" + pcTo + "'."
			return FALSE
		ok
		if @oGov.MayProceed(pcFrom, pcAction) = 0
			@cWhy = "governance refused: " + @oGov.Why()
			return FALSE
		ok
		@oGov.RecordDecision("call-" + pcFrom + "-" + StzLower("" + pcAction) + "-" + len(@aBonds),
			"cross-world call cleared", pcFrom, pcAction)
		@cWhy = "allowed: active + bonded + governed"
		return TRUE

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcName)
		_cN_ = "" + pcName
		_n_ = len(@aWorlds)
		for _i_ = 1 to _n_
			if @aWorlds[_i_][1] = _cN_  return _i_  ok
		next
		return 0
