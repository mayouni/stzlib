# base/platform/stzPlatform.ring
# -----------------------------------------------------------------------------
# stzPlatform -- THE OPERATIONAL ENVELOPE (5.10, R7).
#
# stzApp models the WORLD and deliberately lacks the operational
# envelope; stzPlatform is that envelope -- ONE construct, FIVE duties:
#
#   1. GENERATION       Generate(:all): declared REACH becomes real
#                       per-platform shells (web/desktop/mobile), each
#                       embedding the one resident engine.
#   2. CAPABILITY SEAM  Admits(:camera).With([...]) -- device/native
#                       capabilities requested by the world, GATED BY
#                       GOVERNANCE (the 5.7 lattice: permission CAN +
#                       authority SHOULD vs the capability's risk tier).
#   3. COMMONS RUNTIME  identity / sessions / messaging / stores over
#                       data/stzDatabase (engine sqlite) -- the
#                       operational counterpart of SuperApp's Commons.
#   4. NETWORKED BODY   the world served multi-user over the wire
#                       through the R7 reactor host (stzAppServer).
#   5. REGISTRY +       worlds pushed/retired in a live registry;
#      ENFORCEMENT      cross-world calls INTERCEPTED by norms.
#
# RING-TRUE DESIGN NOTES (the aliasing doctrine):
# - ForWorld(oApp) HARVESTS the world's declarations into the
#   platform's own plain records at call time (the param is by-ref
#   only during the call; storing the object would keep a dead copy).
# - GovernedBy(oGov) SNAPSHOTS the regime -- fitting, since a .zgov
#   governance is a sealed declarative contract; wire it fully
#   configured.
# - HTTP route handlers are NAMED GLOBAL FUNCS reading prerendered
#   globals (Ring lambdas do not capture locals).
# - The stored stzDatabase is a copy SHARING the engine handle -- live
#   for reads/writes; do not Close() the original while serving.
#
# FLOOR HONESTY: Commons secrets are stored as-received -- wiring a
# real KDF is an engine gap (5.10); deployments must not ship the
# floor as-is for real credentials.
# -----------------------------------------------------------------------------

# Prerendered networked-body payloads (route handlers read these by
# name -- the only live cross-object path Ring gives us).
$cStzPlatformWorldJson = '{"world":"none"}'
$aStzPlatformThingJsons = []   # [ [ name, json ], ... ]

func StzPlatform(pcName)
	return new stzPlatform(pcName)

# -- networked-body route handlers (global by design; see header) ----

func StzPlatformWorldRoute(oReq, oResp)
	oResp.Header("Content-Type", "application/json")
	oResp.Send($cStzPlatformWorldJson)

func StzPlatformThingRoute(oReq, oResp)
	_cName_ = oReq.Query("name")
	_nLen_ = len($aStzPlatformThingJsons)
	for _i_ = 1 to _nLen_
		if $aStzPlatformThingJsons[_i_][1] = _cName_
			oResp.Header("Content-Type", "application/json")
			oResp.Send($aStzPlatformThingJsons[_i_][2])
			return
		ok
	next
	oResp.NotFound('{"error":"no such thing: ' + _cName_ + '"}')


class stzPlatform from stzObject

	@cName = ""
	@cWhy = ""

	# harvested world (plain records -- see header)
	@cWorldName = ""
	@aWorldReaches = []
	@aWorldThings = []      # [ [ name, [fields] ], ... ]
	@aWorldScreens = []     # [ name, ... ]
	@bHasWorld = FALSE

	# capability seam
	@oGov = NULL            # snapshot of the sealed regime
	@aAdmissions = []       # [ [ capability, [purposes] ], ... ]
	@nCurAdmission = 0

	# commons
	@oDb = NULL
	@bCommonsReady = FALSE

	# networked body
	@oHost = NULL
	@bServing = FALSE

	# registry
	@aWorlds = []           # [ [ name, version, active ], ... ]
	@aBonds = []            # [ [ from, to, action ], ... ]

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def Why()
		return @cWhy

	#== 1. GENERATION ========================================================

	# Harvest the world's declarations (see aliasing note in header).
	def ForWorld(poApp)
		@cWorldName = poApp.Name()
		@aWorldReaches = []
		_nLen_ = len(poApp.aReaches)
		for _i_ = 1 to _nLen_
			@aWorldReaches + poApp.aReaches[_i_]
		next
		@aWorldThings = []
		_nLen_ = len(poApp.aThings)
		for _i_ = 1 to _nLen_
			_aFields_ = []
			_nF_ = len(poApp.aThings[_i_][2])
			for _j_ = 1 to _nF_
				_aFields_ + poApp.aThings[_i_][2][_j_]
			next
			@aWorldThings + [ poApp.aThings[_i_][1], _aFields_ ]
		next
		@aWorldScreens = []
		_nLen_ = len(poApp.aScreens)
		for _i_ = 1 to _nLen_
			@aWorldScreens + poApp.aScreens[_i_].cName
		next
		@bHasWorld = TRUE
		return This

	# Generate(:all) or Generate(:web / :desktop / :mobile).
	# Writes REAL shell files (one per declared Reach) and returns the
	# list of written paths. Raises when there is no world, no reach,
	# or an unknown reach surface (LAW 3: refuse, never stub).
	def Generate(pWhat)
		if NOT @bHasWorld
			stzraise("stzPlatform.Generate: no world attached -- ForWorld(oApp) first.")
		ok
		if len(@aWorldReaches) = 0
			stzraise("stzPlatform.Generate: the world '" + @cWorldName +
			         "' declares no Reach -- nothing to generate.")
		ok
		_aTargets_ = []
		if pWhat = :all
			_aTargets_ = @aWorldReaches
		else
			_aTargets_ = [ pWhat ]
		ok
		_cDir_ = ".stzapp/shells"
		StzMakeDir(".stzapp")
		StzMakeDir(_cDir_)
		_aWritten_ = []
		_nLen_ = len(_aTargets_)
		for _i_ = 1 to _nLen_
			_cSurface_ = "" + _aTargets_[_i_]
			if _cSurface_ = "web"
				_cPath_ = _cDir_ + "/" + @cWorldName + "_web.html"
				write(_cPath_, This._WebShell())
			but _cSurface_ = "desktop"
				_cPath_ = _cDir_ + "/" + @cWorldName + "_desktop.ring"
				write(_cPath_, This._DesktopShell())
			but _cSurface_ = "mobile"
				_cPath_ = _cDir_ + "/" + @cWorldName + "_mobile.html"
				write(_cPath_, This._MobileShell())
			else
				stzraise("stzPlatform.Generate: unknown reach surface '" +
				         _cSurface_ + "' (web/desktop/mobile).")
			ok
			_aWritten_ + _cPath_
		next
		return _aWritten_

	def _WebShell()
		_cNL_ = char(10)
		_c_ = "<!-- generated by stzPlatform for world '" + @cWorldName + "' -->" + _cNL_
		_c_ += "<html><head><title>" + @cWorldName + "</title></head><body>" + _cNL_
		_c_ += "<h1>" + @cWorldName + "</h1>" + _cNL_
		_c_ += "<p>A Softanza world served by the resident engine (stzAppServer).</p>" + _cNL_
		_c_ += "<ul>" + _cNL_
		_nLen_ = len(@aWorldScreens)
		for _i_ = 1 to _nLen_
			_c_ += "<li>screen: " + @aWorldScreens[_i_] + "</li>" + _cNL_
		next
		_nLen_ = len(@aWorldThings)
		for _i_ = 1 to _nLen_
			_c_ += "<li>thing: " + @aWorldThings[_i_][1] + "</li>" + _cNL_
		next
		_c_ += "</ul>" + _cNL_
		_c_ += "<script>const WORLD_API = 'http://127.0.0.1:8080/world';</script>" + _cNL_
		_c_ += "</body></html>" + _cNL_
		return _c_

	def _DesktopShell()
		_cNL_ = char(10)
		_c_ = "# generated by stzPlatform for world '" + @cWorldName + "'" + _cNL_
		_c_ += 'load "stzlib.ring"' + _cNL_
		_c_ += "# desktop shell: restore the world body and serve it locally" + _cNL_
		_c_ += 'oApp = StzApp("' + @cWorldName + '")' + _cNL_
		_c_ += "oPlat = StzPlatform('" + @cName + "')" + _cNL_
		_c_ += "oPlat.ForWorld(oApp)" + _cNL_
		_c_ += "oPlat.ServeBody(8080)" + _cNL_
		_c_ += "oPlat.HostQ().Run()" + _cNL_
		return _c_

	def _MobileShell()
		_cNL_ = char(10)
		_c_ = "<!-- generated by stzPlatform for world '" + @cWorldName + "' (mobile/PWA) -->" + _cNL_
		_c_ += "<html><head><title>" + @cWorldName + "</title>" + _cNL_
		_c_ += '<meta name="viewport" content="width=device-width, initial-scale=1">' + _cNL_
		_c_ += "</head><body><h1>" + @cWorldName + "</h1>" + _cNL_
		_c_ += "<p>Mobile shell over the same world API.</p>" + _cNL_
		_c_ += "</body></html>" + _cNL_
		return _c_

	#== 2. THE CAPABILITY SEAM ==============================================

	# Wire the (fully configured, sealed) governance regime. Declares
	# the platform's capability risk tiers into it when undeclared.
	def GovernedBy(poGov)
		@oGov = poGov
		This._EnsureCapabilityRisks()
		return This

	def _EnsureCapabilityRisks()
		_aTiers_ = [ [ "use-storage", 1 ], [ "use-notifications", 1 ],
		             [ "use-offline", 1 ], [ "use-camera", 2 ],
		             [ "use-location", 3 ], [ "use-payments", 4 ] ]
		_nLen_ = len(_aTiers_)
		for _i_ = 1 to _nLen_
			if @oGov.RiskOf(_aTiers_[_i_][1]) = 0
				@oGov.DeclareRisk(_aTiers_[_i_][1], _aTiers_[_i_][2])
			ok
		next

	# Request a capability for the attached world:
	#   oPlat.Admits(:camera).With([ :scan-dish-photo ])
	def Admits(pcCapability)
		_cCap_ = StzLower("" + pcCapability)
		@aAdmissions + [ _cCap_, [] ]
		@nCurAdmission = len(@aAdmissions)
		return This

	def With(paPurposes)
		if @nCurAdmission > 0
			if NOT isList(paPurposes)
				paPurposes = [ paPurposes ]
			ok
			@aAdmissions[@nCurAdmission][2] = paPurposes
		ok
		return This

	# The governed decision: the WORLD is the actor, "use-<cap>" the
	# action; permission CAN + authority SHOULD vs the risk tier.
	def Granted(pcCapability)
		if @oGov = NULL
			stzraise("stzPlatform.Granted: no governance wired -- capabilities are governed by construction (GovernedBy first).")
		ok
		if NOT @bHasWorld
			stzraise("stzPlatform.Granted: no world attached.")
		ok
		_cCap_ = StzLower("" + pcCapability)
		if NOT This._WasAdmitted(_cCap_)
			@cWhy = "capability '" + _cCap_ + "' was never requested via Admits()."
			return FALSE
		ok
		_bOk_ = @oGov.MayProceed(@cWorldName, "use-" + _cCap_)
		@cWhy = @oGov.Why()
		return _bOk_

	def _WasAdmitted(pcCap)
		_nLen_ = len(@aAdmissions)
		for _i_ = 1 to _nLen_
			if @aAdmissions[_i_][1] = pcCap
				return TRUE
			ok
		next
		return FALSE

	def Admissions()
		return @aAdmissions

	#== 3. THE COMMONS RUNTIME ==============================================

	# Identity / sessions / messaging / stores over an OPEN stzDatabase.
	# (The stored object shares the engine handle -- live; keep the
	# original open while the platform runs.)
	def CommonsOn(poDb)
		@oDb = poDb
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_identity(user TEXT PRIMARY KEY, secret TEXT)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_session(token TEXT PRIMARY KEY, user TEXT, opened_ms INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_message(sender TEXT, recipient TEXT, body TEXT, sent_ms INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_store(k TEXT PRIMARY KEY, v TEXT)")
		@bCommonsReady = TRUE
		return This

	def _NeedCommons()
		if NOT @bCommonsReady
			stzraise("stzPlatform: the Commons is not wired -- CommonsOn(oDb) first.")
		ok

	def RegisterIdentity(pcUser, pcSecret)
		This._NeedCommons()
		if @oDb.Value("SELECT user FROM stz_identity WHERE user = '" + This._Sql(pcUser) + "'") != ""
			@cWhy = "identity '" + pcUser + "' already exists."
			return FALSE
		ok
		# FLOOR: secret stored as-received (see header honesty note)
		@oDb.Exec("INSERT INTO stz_identity (user, secret) VALUES ('" +
		          This._Sql(pcUser) + "', '" + This._Sql(pcSecret) + "')")
		return TRUE

	# Returns a session token, or "" (Why() explains) on refusal.
	def OpenSession(pcUser, pcSecret)
		This._NeedCommons()
		_cStored_ = @oDb.Value("SELECT secret FROM stz_identity WHERE user = '" + This._Sql(pcUser) + "'")
		if _cStored_ = "" or _cStored_ != pcSecret
			@cWhy = "identity/secret mismatch for '" + pcUser + "'."
			return ""
		ok
		_cToken_ = "sess_" + random(999999999) + "_" + random(999999999)
		@oDb.Exec("INSERT INTO stz_session (token, user, opened_ms) VALUES ('" +
		          _cToken_ + "', '" + This._Sql(pcUser) + "', " + StzEngineTimeNowMs() + ")")
		return _cToken_

	def SessionUser(pcToken)
		This._NeedCommons()
		return @oDb.Value("SELECT user FROM stz_session WHERE token = '" + This._Sql(pcToken) + "'")

	def PostMessage(pcFrom, pcTo, pcBody)
		This._NeedCommons()
		@oDb.Exec("INSERT INTO stz_message (sender, recipient, body, sent_ms) VALUES ('" +
		          This._Sql(pcFrom) + "', '" + This._Sql(pcTo) + "', '" +
		          This._Sql(pcBody) + "', " + StzEngineTimeNowMs() + ")")
		return This

	def Inbox(pcUser)
		This._NeedCommons()
		return @oDb.Rows("SELECT sender, body FROM stz_message WHERE recipient = '" +
		                 This._Sql(pcUser) + "' ORDER BY sent_ms")

	def StorePut(pcKey, pcValue)
		This._NeedCommons()
		@oDb.Exec("INSERT OR REPLACE INTO stz_store (k, v) VALUES ('" +
		          This._Sql(pcKey) + "', '" + This._Sql(pcValue) + "')")
		return This

	def StoreGet(pcKey)
		This._NeedCommons()
		return @oDb.Value("SELECT v FROM stz_store WHERE k = '" + This._Sql(pcKey) + "'")

	def _Sql(pcVal)
		return StzReplace("" + pcVal, "'", "''")

	#== 4. THE NETWORKED BODY ===============================================

	# Serve the harvested world over the R7 reactor host:
	#   GET /world        -> the world (name, things, screens) as json
	#   GET /thing?name=x -> one thing's fields
	# nPort 0 = ephemeral; the bound port via HostQ().Port().
	def ServeBody(nPort)
		if NOT @bHasWorld
			stzraise("stzPlatform.ServeBody: no world attached -- ForWorld(oApp) first.")
		ok
		This._PrerenderWorld()
		@oHost = new stzAppServer()
		@oHost.Get_("/world", "StzPlatformWorldRoute")
		@oHost.Get_("/thing", "StzPlatformThingRoute")
		@oHost.Start(nPort, "127.0.0.1")
		@bServing = TRUE
		return This

	# The serving host (a chainable stz object -- Q-convention). NB: an
	# accessor returns a handle-sharing copy; use it for Port()/ServeOne.
	def HostQ()
		return @oHost

	def ServeFor(nMs)
		if NOT @bServing
			stzraise("stzPlatform.ServeFor: not serving -- ServeBody first.")
		ok
		@oHost.RunFor(nMs)
		return This

	def ServeOne(nTimeoutMs)
		if NOT @bServing
			stzraise("stzPlatform.ServeOne: not serving -- ServeBody first.")
		ok
		return @oHost.ServeOne(nTimeoutMs)

	def StopServing()
		if @bServing
			@oHost.Stop()
			@bServing = FALSE
		ok
		return This

	def _PrerenderWorld()
		_cJson_ = '{"world":"' + @cWorldName + '","things":['
		_nLen_ = len(@aWorldThings)
		for _i_ = 1 to _nLen_
			if _i_ > 1 _cJson_ += "," ok
			_cJson_ += '"' + @aWorldThings[_i_][1] + '"'
		next
		_cJson_ += '],"screens":['
		_nLen_ = len(@aWorldScreens)
		for _i_ = 1 to _nLen_
			if _i_ > 1 _cJson_ += "," ok
			_cJson_ += '"' + @aWorldScreens[_i_] + '"'
		next
		_cJson_ += ']}'
		$cStzPlatformWorldJson = _cJson_
		$aStzPlatformThingJsons = []
		_nLen_ = len(@aWorldThings)
		for _i_ = 1 to _nLen_
			_cT_ = '{"thing":"' + @aWorldThings[_i_][1] + '","fields":['
			_nF_ = len(@aWorldThings[_i_][2])
			for _j_ = 1 to _nF_
				if _j_ > 1 _cT_ += "," ok
				_cT_ += '"' + @aWorldThings[_i_][2][_j_] + '"'
			next
			_cT_ += ']}'
			$aStzPlatformThingJsons + [ @aWorldThings[_i_][1], _cT_ ]
		next

	#== 5. REGISTRY + ENFORCEMENT ===========================================

	def PushWorld(pcName, pcVersion)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				@aWorlds[_i_][2] = pcVersion
				@aWorlds[_i_][3] = TRUE
				return This
			ok
		next
		@aWorlds + [ pcName, pcVersion, TRUE ]
		return This

	def RetireWorld(pcName)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				@aWorlds[_i_][3] = FALSE
				return This
			ok
		next
		return This

	def IsActiveWorld(pcName)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				return @aWorlds[_i_][3]
			ok
		next
		return FALSE

	def Worlds()
		return @aWorlds

	# Declare a norm-bearing bond: from-world may attempt an action on
	# to-world (still subject to governance at call time).
	def Bond(pcFrom, pcTo, pcAction)
		@aBonds + [ pcFrom, StzLower("" + pcTo), StzLower("" + pcAction) ]
		return This

	# The enforcement seam: a cross-world call goes through ONLY when
	# (a) both worlds are active in the registry, (b) a bond declares
	# the action, and (c) governance lets the calling world proceed.
	# Returns TRUE/FALSE; Why() explains every refusal.
	def CallAcross(pcFrom, pcTo, pcAction)
		if NOT This.IsActiveWorld(pcFrom)
			@cWhy = "calling world '" + pcFrom + "' is not active in the registry."
			return FALSE
		ok
		if NOT This.IsActiveWorld(pcTo)
			@cWhy = "target world '" + pcTo + "' is not active in the registry."
			return FALSE
		ok
		_cTo_ = StzLower("" + pcTo)
		_cAction_ = StzLower("" + pcAction)
		_bBonded_ = FALSE
		_nLen_ = len(@aBonds)
		for _i_ = 1 to _nLen_
			if @aBonds[_i_][1] = pcFrom and @aBonds[_i_][2] = _cTo_ and @aBonds[_i_][3] = _cAction_
				_bBonded_ = TRUE
				exit
			ok
		next
		if NOT _bBonded_
			@cWhy = "no bond declares '" + _cAction_ + "' from '" + pcFrom + "' to '" + pcTo + "'."
			return FALSE
		ok
		if @oGov != NULL
			if NOT @oGov.MayProceed(pcFrom, _cAction_)
				@cWhy = "governance refused: " + @oGov.Why()
				return FALSE
			ok
		ok
		@cWhy = ""
		return TRUE
