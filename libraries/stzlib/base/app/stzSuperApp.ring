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

# Holds several apps as worlds of one governed constellation, with a shared Commons and cross-world calls that must be bonded and cleared.
#
# A world is any app object registered by name, or another constellation, so constellations nest. A
# call from one world to another goes through CallAcross, which allows it only when both worlds are
# active, a bond declares the action and the ambient governance clears the caller; Why gives the
# reason, and Crossings keeps a timed log of every decision. A world can be retired, revived and
# swapped for a new object without losing its bonds. The Commons holds identities, sessions and a
# key-value store in a database you open with OpenCommonsOn. CallAcross decides and records; it does
# not call into the target world. Everything was run offline, with an in-memory database.
#
#   receiver   o1 = new stzSuperApp("acme")
#   example    o1.AddWorld("resto", new stzApp("resto"))
#              o1.AddWorld("supplier", new stzApp("supplier"))
#              o1.Bond("resto", "supplier", "order-produce")
#              o1.GovDeclareRisk("order-produce", 2)
#              o1.GovGrant("resto", "order-produce")
#              o1.GovSetAuthority("resto", :Delegated)
#              ? o1.CallAcross("resto", "supplier", "order-produce")
#              #--> 1
#              ? o1.CallAcross("resto", "supplier", "raid")
#              #--> 0
#              ? o1.Why()
#              #--> no bond declares 'raid' from 'resto' to 'supplier'.
#   see        stzApp, stzGovernance, stzPlatform, stzGraph
class stzSuperApp from stzObject

	@cName    = ""
	@oGraph   = ""       # world nodes + :bond edges
	@aWorlds  = []         # [ name, obj, kind("app"|"super"), active ]
	@oCommons = ""       # world-zero: an stzPlatform (identity/stores)
	@oGov     = ""       # ambient governance
	@aBonds   = []         # [ from, to, action ]
	@cWhy     = ""

	# perf P3: every cross-world crossing carries its cost. Bounded
	# ledger (newest 256): [ from, to, action, allowed, durMs ].
	@aCallLog = []
	@nLastCallMs = 0

	# Builds an empty constellation of worlds with its own graph, its own governance and a shared Commons.
	#
	#   pcName     the constellation's name, kept as text
	#   returns    nothing; the object is built
	#   see        AddWorld, Bond
	def init(pcName)
		@cName = "" + pcName
		@oGraph = new stzGraph("constellation-" + @cName)
		@oCommons = new stzPlatform(@cName + "-commons")
		@oGov = new stzGovernance(@cName)

	# Returns the constellation's name.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Returns the reason given by the last CallAcross, whether it was allowed or refused.
	#
	#   returns    a text; empty before any call
	#   warning    a failure in the Commons, such as a user already registered, is explained by
	#              CommonsQ().Why(), not here
	#   see        CallAcross, Crossings
	def Why()
		return @cWhy

	# Returns the constellation graph: one node per world and one bond edge per bonded pair.
	#
	#   returns    a stzGraph object
	#   see        AddWorld, Bond
	def GraphQ()
		return @oGraph

	# Returns the ambient governance that clears cross-world calls.
	#
	#   returns    a stzGovernance object
	#   warning    configure it through the Gov methods of the constellation, not through this copy
	#   see        GovDeclareRisk, GovGrant, GovSetAuthority
	def GovernanceQ()
		return @oGov

	# Returns the shared Commons, the stzPlatform that holds identities, sessions and the key-value store.
	#
	#   returns    a stzPlatform object
	#   see        OpenCommonsOn, RegisterIdentity
	def CommonsQ()
		return @oCommons

	# Registers an app as a named, active world and adds a node for it to the graph.
	#
	#   pcName     the world's name, which must be new here
	#   poApp      the world object, usually a stzApp
	#   returns    the constellation itself, so calls chain
	#   warning    raises an error when a world of that name is already registered
	#   see        AddConstellation, WorldQ, Retire
	#@ aka  -- the registry: worlds as nodes --------------------------------------
	def AddWorld(pcName, poApp)
		return This._Register(pcName, poApp, "app")

	# Registers another constellation as a named, active world, so constellations nest.
	#
	#   pcName     the world's name, which must be new here
	#   poSuper    the inner stzSuperApp
	#   returns    the constellation itself, so calls chain
	#   note       the world's kind then reads super
	#   warning    raises an error when the name is taken
	#   see        AddWorld, KindOf
	#@ aka  recursion: a constellation may contain another constellation
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
		@aWorlds + [ _cN_, poObj, pcKind, 1 ]
		return This

	# Returns the live object registered under a name.
	#
	#   pcName     the world's name
	#   returns    the world object; an empty text when the name is unknown
	#   warning    the name is matched exactly, letter case included
	#   see        KindOf, Swap
	#@ aka  the LIVE world object (reached via the registry index)
	def WorldQ(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aWorlds[_i_][2]

	# Returns whether a world is a plain app or a nested constellation.
	#
	#   pcName     the world's name
	#   returns    app or super as text; an empty text when the name is unknown
	#   see        WorldQ, AddConstellation
	def KindOf(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return ""  ok
		return @aWorlds[_i_][3]

	# Returns the names of all registered worlds, in the order they joined, retired ones included.
	#
	#   returns    a list of text
	#   see        NumberOfWorlds, HasWorld
	def WorldNames()
		_acOut_ = []
		_n_ = len(@aWorlds)
		for _i_ = 1 to _n_
			_acOut_ + @aWorlds[_i_][1]
		next
		return _acOut_

	# Returns how many worlds are registered, retired ones included.
	#
	#   returns    a number
	#   see        WorldNames
	def NumberOfWorlds()
		return len(@aWorlds)

	# TRUE if a world of that name is registered, active or not.
	#
	#   pcName     the world's name
	#   returns    TRUE or FALSE
	#   see        IsActive, WorldNames
	def HasWorld(pcName)
		return This._IndexOf(pcName) > 0

	# TRUE if the world is registered and not retired.
	#
	#   pcName     the world's name
	#   returns    TRUE or FALSE; FALSE for an unknown name
	#   see        Retire, Revive
	def IsActive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0  return 0  ok
		return @aWorlds[_i_][4]

	# Switches a world off, so that every call to or from it is refused until it is revived.
	#
	#   pcName     the world's name
	#   returns    the constellation itself, so calls chain
	#   note       the world's bonds and node stay
	#   warning    raises an error for an unknown name
	#   see        Revive, IsActive, CallAcross
	def Retire(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Retire: no world '" + pcName + "'.")
		ok
		@aWorlds[_i_][4] = 0
		return This

	# Switches a retired world back on.
	#
	#   pcName     the world's name
	#   returns    the constellation itself, so calls chain
	#   warning    raises an error for an unknown name
	#   see        Retire, IsActive
	def Revive(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Revive: no world '" + pcName + "'.")
		ok
		@aWorlds[_i_][4] = 1
		return This

	# Replaces a world's object with a new one, switches it on and keeps its node and its bonds.
	#
	#   pcName     the name of an existing world
	#   poNewApp   the object that takes its place
	#   returns    the constellation itself, so calls chain
	#   note       the kind recorded for the world is not changed
	#   warning    raises an error for an unknown name
	#   see        WorldQ, Retire
	#@ aka  HOT-SWAP a live world's implementation, keeping its node + bonds.
	def Swap(pcName, poNewApp)
		_i_ = This._IndexOf(pcName)
		if _i_ = 0
			stzraise("stzSuperApp.Swap: no world '" + pcName + "' to swap.")
		ok
		@aWorlds[_i_][2] = poNewApp
		@aWorlds[_i_][4] = 1
		return This

	# Backs the shared Commons with an open database, creating its tables.
	#
	#   poDb       an open stzDatabase, such as one made on :memory:
	#   returns    the constellation itself, so calls chain
	#   warning    keep the database open for as long as the constellation uses the Commons
	#   see        RegisterIdentity, StorePut
	#@ aka  -- the Commons (world zero) -------------------------------------------
	def OpenCommonsOn(poDb)
		@oCommons.OpenCommonsOn(poDb)
		return This

	# Stores a user in the Commons with a salted hash of the secret, never the secret itself.
	#
	#   pcUser     the user name
	#   pcSecret   the secret to hash
	#   returns    TRUE if registered, FALSE when the user already exists
	#   note       the reason for a FALSE is in CommonsQ().Why()
	#   warning    raises an error until OpenCommonsOn has run
	#   see        OpenSession, CommonsQ
	def RegisterIdentity(pcUser, pcSecret)
		return @oCommons.RegisterIdentity(pcUser, pcSecret)

	# Checks a user's secret and, when right, opens a session in the Commons.
	#
	#   pcUser     the user name
	#   pcSecret   the secret to check
	#   returns    a text, the session token beginning with sess_; an empty text when refused
	#   warning    raises an error until OpenCommonsOn has run
	#   see        RegisterIdentity
	def OpenSession(pcUser, pcSecret)
		return @oCommons.OpenSession(pcUser, pcSecret)

	# Saves a text under a key in the Commons' shared store, replacing an older value.
	#
	#   pcKey      the key
	#   pcValue    the text to keep
	#   returns    the constellation itself, so calls chain
	#   warning    raises an error until OpenCommonsOn has run
	#   see        StoreGet
	def StorePut(pcKey, pcValue)
		@oCommons.StorePut(pcKey, pcValue)
		return This

	# Returns the text saved under a key in the Commons' shared store.
	#
	#   pcKey      the key
	#   returns    a text; empty for an unknown key
	#   warning    raises an error until OpenCommonsOn has run
	#   see        StorePut
	def StoreGet(pcKey)
		return @oCommons.StoreGet(pcKey)

	# Declares how risky an action is, on a scale from 1 to 4; an undeclared action is never cleared.
	#
	#   pcAction   the action's name
	#   nTier      the risk, 1 low to 4 critical
	#   returns    the constellation itself, so calls chain
	#   warning    a tier outside 1 to 4 raises an error
	#   see        GovGrant, GovSetAuthority, CallAcross
	#@ aka  -- ambient governance (delegated -> one live @oGov) -------------------
	def GovDeclareRisk(pcAction, nTier)
		@oGov.DeclareRisk(pcAction, nTier)
		return This

	# Gives a world the permission to attempt an action.
	#
	#   pcActor    the name of the calling world
	#   pcAction   the action's name
	#   returns    the constellation itself, so calls chain
	#   see        GovDeclareRisk, GovSetAuthority, CallAcross
	def GovGrant(pcActor, pcAction)
		@oGov.GrantPermission(pcActor, pcAction)
		return This

	# Sets how far a world may act on its own: advisory, delegated, autonomous or emergencyoverride.
	#
	#   pcActor    the name of the calling world
	#   pcType     :Advisory, :Delegated, :Autonomous or :EmergencyOverride
	#   returns    the constellation itself, so calls chain
	#   note       the level must reach the action's risk tier, tier 2 needing :Delegated
	#   warning    any other word raises an error
	#   see        GovGrant, CallAcross
	def GovSetAuthority(pcActor, pcType)
		@oGov.SetAuthority(pcActor, pcType)
		return This

	# Declares that one world may attempt an action on another, and draws a bond edge between them.
	#
	#   pcFrom     the calling world
	#   pcTo       the target world
	#   pcAction   the action's name
	#   returns    the constellation itself, so calls chain
	#   note       a bond runs one way, the target and the action are stored in lower case, and the
	#              graph gets one edge per pair however many actions are bonded
	#   warning    raises an error unless both worlds are registered
	#   see        AreBonded, CallAcross
	#@ aka  -- norm-gated bonds ---------------------------------------------------
	def Bond(pcFrom, pcTo, pcAction)
		if This._IndexOf(pcFrom) = 0 or This._IndexOf(pcTo) = 0
			stzraise("stzSuperApp.Bond: both worlds must be registered first.")
		ok
		@aBonds + [ "" + pcFrom, StzLower("" + pcTo), StzLower("" + pcAction) ]
		if NOT @oGraph.EdgeExists(pcFrom, pcTo)
			@oGraph.AddEdgeXTT(pcFrom, pcTo, "bond", [ :action = StzLower("" + pcAction) ])
		ok
		return This

	# TRUE if a bond declares that action from the first world to the second.
	#
	#   pcFrom     the calling world, matched exactly
	#   pcTo       the target world
	#   pcAction   the action's name
	#   returns    TRUE or FALSE
	#   warning    the target and the action are matched without regard to case, the calling world
	#              exactly
	#   see        Bond, CallAcross
	def AreBonded(pcFrom, pcTo, pcAction)
		_cTo_ = StzLower("" + pcTo)
		_cAction_ = StzLower("" + pcAction)
		_n_ = len(@aBonds)
		for _i_ = 1 to _n_
			if @aBonds[_i_][1] = pcFrom and @aBonds[_i_][2] = _cTo_ and @aBonds[_i_][3] = _cAction_
				return 1
			ok
		next
		return 0

	# Decides whether one world may act on another: both must be active, a bond must declare the action and governance must clear the caller.
	#
	#   pcFrom     the calling world
	#   pcTo       the target world
	#   pcAction   the action's name
	#   returns    TRUE if allowed, FALSE if refused
	#   note       Why says which of the four checks refused
	#   warning    it only decides and records, it calls nothing in the target; every outcome is
	#              timed and logged, and a refusal also enters the incident evidence
	#   see        Why, Crossings, Bond, GovGrant
	#@ aka  THE ENFORCEMENT SEAM: a cross-world call proceeds ONLY when both worlds are active, a bond declares the action, and governance clears the caller. Returns TRUE/FALSE; Why() explains refusals. perf P3: every outcome -- clearance or refusal -- is timed on the monotonic clock and ledgered (Crossings()/LastCallMs()).
	def CallAcross(pcFrom, pcTo, pcAction)
		_nT0_ = StzEngineWatchTimestampNs()
		if NOT This.IsActive(pcFrom)
			@cWhy = "calling world '" + pcFrom + "' is not active."
			return This._CrossingDone(_nT0_, pcFrom, pcTo, pcAction, 0)
		ok
		if NOT This.IsActive(pcTo)
			@cWhy = "target world '" + pcTo + "' is not active."
			return This._CrossingDone(_nT0_, pcFrom, pcTo, pcAction, 0)
		ok
		if NOT This.AreBonded(pcFrom, pcTo, pcAction)
			@cWhy = "no bond declares '" + StzLower("" + pcAction) + "' from '" +
				pcFrom + "' to '" + pcTo + "'."
			return This._CrossingDone(_nT0_, pcFrom, pcTo, pcAction, 0)
		ok
		if @oGov.MayProceed(pcFrom, pcAction) = 0
			@cWhy = "governance refused: " + @oGov.Why()
			return This._CrossingDone(_nT0_, pcFrom, pcTo, pcAction, 0)
		ok
		@oGov.RecordDecision("call-" + pcFrom + "-" + StzLower("" + pcAction) + "-" + len(@aBonds),
			"cross-world call cleared", pcFrom, pcAction)
		@cWhy = "allowed: active + bonded + governed"
		return This._CrossingDone(_nT0_, pcFrom, pcTo, pcAction, 1)

	# Returns the log of decisions made by CallAcross, oldest first, the newest 256 at most.
	#
	#   returns    a list of rows [ from, to, action, allowed, durationMs ], allowed being 1 or 0
	#   warning    the target and the action are in lower case
	#   see        CrossingCount, LastCallMs
	#@ aka  The crossings ledger: [ [ from, to, action, allowed, durMs ], ... ].
	def Crossings()
		return @aCallLog

	# Returns how many decisions the log holds, at most 256.
	#
	#   returns    a number
	#   see        Crossings
	def CrossingCount()
		return len(@aCallLog)

	# Returns how long the last CallAcross took, in milliseconds.
	#
	#   returns    a number, often a fraction; 0 before any call
	#   see        Crossings
	def LastCallMs()
		return @nLastCallMs

	def _CrossingDone(pnT0, pcFrom, pcTo, pcAction, pbOk)
		@nLastCallMs = (StzEngineWatchTimestampNs() - pnT0) / 1000000
		@aCallLog + [ "" + pcFrom, StzLower("" + pcTo), StzLower("" + pcAction),
			pbOk, @nLastCallMs ]
		if len(@aCallLog) > 256
			del(@aCallLog, 1)
		ok
		# Incident I2. The crossings log above IS a memory -- but a bounded,
		# unchained, in-object one that a Ring copy forks and Save() drops.
		# A refused crossing is the moment one world reached for another and
		# was told no; it belongs in the evidence chain with everything else,
		# under the actor that reached (the calling world) so the incident
		# correlation finds it.
		if NOT pbOk
			StzNoteRefusal("crossworld.call.refused", "" + pcFrom,
				"world:" + StzLower("" + pcTo) + "/" + StzLower("" + pcAction), @cWhy)
		ok
		return pbOk

	#-- internals ----------------------------------------------------------

	def _IndexOf(pcName)
		_cN_ = "" + pcName
		_n_ = len(@aWorlds)
		for _i_ = 1 to _n_
			if @aWorlds[_i_][1] = _cN_  return _i_  ok
		next
		return 0
