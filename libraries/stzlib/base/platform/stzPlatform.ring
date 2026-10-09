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
#   2. CAPABILITY SEAM  AddCapabilityQ(:camera).SetPurposes([...]) -- device/native
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
# - SetWorld(oApp) HARVESTS the world's declarations into the
#   platform's own plain records at call time (the param is by-ref
#   only during the call; storing the object would keep a dead copy).
# - SetGovernedBy(oGov) SNAPSHOTS the regime -- fitting, since a .zgov
#   governance is a sealed declarative contract; wire it fully
#   configured.
# - HTTP route handlers are NAMED GLOBAL FUNCS reading prerendered
#   globals (Ring lambdas do not capture locals).
# - The stored stzDatabase is a copy SHARING the engine handle -- live
#   for reads/writes; do not Close() the original while serving.
#
# IDENTITY SECURITY: Commons secrets are stored as a per-user random
# SALT + a PBKDF2-HMAC-SHA256 hash (engine KDF), never plaintext;
# verification re-derives and compares in constant time. Rounds default
# to 100k and are tunable via SetKdfRounds() (lower them only in tests).
# -----------------------------------------------------------------------------

# Prerendered networked-body payloads (route handlers read these by
# name -- the only live cross-object path Ring gives us).
$cStzPlatformWorldJson = '{"world":"none"}'
$aStzPlatformThingJsons = []   # [ [ name, json ], ... ]

# The live platform whose Commons the networked routes act on. Declared
# here at top scope so the global route handlers can see it; ServeBody
# points it at the serving instance (its shared sqlite handle means
# mutations through a route persist in the same store).
$oStzPlatformActive = ""

func StzPlatformQ(pcName)
	return new stzPlatform(pcName)

# The public KDF helpers (StzHashSecret / StzVerifySecret / StzRandomToken) moved
# to base/security/stzCryptoFuncs.ring -- the security concern's home. They are
# global funcs, loaded earlier now, so every consumer here still resolves them.

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

# -- networked COMMONS route handlers (duty 4: the world served multi-user).
# Global by design (the reactor handler cannot capture instance state; Ring
# lambdas don't close over locals). They reach the LIVE platform through
# $oStzPlatformActive -- set in ServeBody -- and its shared sqlite handle, so
# every mutation persists. Sessions are the auth: a token proves identity;
# messaging/inbox/store require one, and a sender/reader must match the token.

func StzPlatformFormValue(cBody, cKey)
	_a_ = StzSplit("" + cBody, "&")
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_nEq_ = StzFindFirst("=", _a_[_i_])
		if _nEq_ > 0 and StzLeft(_a_[_i_], _nEq_ - 1) = cKey
			return StzMidToEnd(_a_[_i_], _nEq_ + 1)
		ok
	next
	return ""

func StzPlatformRowsJson(aRows)
	_c_ = "["
	_n_ = len(aRows)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += "["
		_m_ = len(aRows[_i_])
		for _j_ = 1 to _m_
			if _j_ > 1  _c_ += ","  ok
			_c_ += '"' + StzReplace("" + aRows[_i_][_j_], '"', '\"') + '"'
		next
		_c_ += "]"
	next
	return _c_ + "]"

# POST /session  (user=&secret=)  -> {"token":"..."} or 401
func StzPlatformSessionRoute(oReq, oResp)
	_t_ = $oStzPlatformActive.OpenSession(
		StzPlatformFormValue(oReq.Body(), "user"),
		StzPlatformFormValue(oReq.Body(), "secret"))
	if _t_ = ""
		oResp.Status(401, "Unauthorized").Json([ "error", "bad credentials" ])
		return
	ok
	oResp.Header("Content-Type", "application/json")
	oResp.Send('{"token":"' + _t_ + '"}')

# GET /whoami?token=  -> {"user":"..."} or 401
func StzPlatformWhoamiRoute(oReq, oResp)
	_u_ = $oStzPlatformActive.SessionUser(oReq.Query("token"))
	if _u_ = ""
		oResp.Status(401, "Unauthorized").Json([ "error", "invalid or expired token" ])
		return
	ok
	oResp.Header("Content-Type", "application/json")
	oResp.Send('{"user":"' + _u_ + '"}')

# POST /message  (from=&to=&body=&token=)  -> 201, token must authorize `from`
func StzPlatformMessageRoute(oReq, oResp)
	_from_ = StzPlatformFormValue(oReq.Body(), "from")
	_authed_ = $oStzPlatformActive.SessionUser(StzPlatformFormValue(oReq.Body(), "token"))
	if _authed_ = "" or _authed_ != _from_
		oResp.Status(401, "Unauthorized").Json([ "error", "token does not authorize this sender" ])
		return
	ok
	$oStzPlatformActive.PostMessage(_from_,
		StzPlatformFormValue(oReq.Body(), "to"),
		StzPlatformFormValue(oReq.Body(), "body"))
	oResp.Status(201, "Created").Json([ "posted", 1 ])

# GET /inbox?user=&token=  -> {"inbox":[[sender,body],...]}, token must match
func StzPlatformInboxRoute(oReq, oResp)
	_user_ = oReq.Query("user")
	_authed_ = $oStzPlatformActive.SessionUser(oReq.Query("token"))
	if _authed_ = "" or _authed_ != _user_
		oResp.Status(401, "Unauthorized").Json([ "error", "token does not authorize this inbox" ])
		return
	ok
	oResp.Header("Content-Type", "application/json")
	oResp.Send('{"inbox":' + StzPlatformRowsJson($oStzPlatformActive.Inbox(_user_)) + '}')

# POST /store  (key=&value=&token=)  -> 201 (auth required)
func StzPlatformStorePutRoute(oReq, oResp)
	if $oStzPlatformActive.SessionUser(StzPlatformFormValue(oReq.Body(), "token")) = ""
		oResp.Status(401, "Unauthorized").Json([ "error", "authentication required" ])
		return
	ok
	$oStzPlatformActive.StorePut(
		StzPlatformFormValue(oReq.Body(), "key"),
		StzPlatformFormValue(oReq.Body(), "value"))
	oResp.Status(201, "Created").Json([ "stored", 1 ])

# GET /store?key=&token=  -> {"value":"..."} (auth required)
func StzPlatformStoreGetRoute(oReq, oResp)
	if $oStzPlatformActive.SessionUser(oReq.Query("token")) = ""
		oResp.Status(401, "Unauthorized").Json([ "error", "authentication required" ])
		return
	ok
	oResp.Header("Content-Type", "application/json")
	oResp.Send('{"value":"' + StzReplace("" + $oStzPlatformActive.StoreGet(oReq.Query("key")), '"', '\"') + '"}')


# Wraps a stzApp world in what makes it operable: build and deploy of its parts, governed capabilities, a Commons of identities and messages, and a world registry.
#
# A stzApp models the world and lacks the operational envelope; the platform is that envelope, in
# five duties. It owns a deployment profile whose parts Build and then Deploy (Build records the
# compiler command of each part and Deploy lowers it to an artifact text, neither runs anything).
# SetWorld takes a world, and Generate writes a shell file for each of its reaches. A capability
# such as the camera is requested with AddCapability and decided by Granted against a governance
# regime. OpenCommonsOn turns an open database into identities (salted PBKDF2 hashes, never the
# secret), sessions, messages and a key-value store. ServeBody serves the world and the Commons over
# HTTP on 127.0.0.1. PushWorld, Bond and CallAcross keep a registry in which a call between worlds
# goes through only if both are active, a bond names the action and governance agrees. The runs
# behind this reference were in memory only: no shell file was written and no port was opened.
#
#   receiver   o1 = new stzPlatform("demo")
#   example    o1.PushWorld("resto", "1.0")
#              ? o1.IsActiveWorld("resto")
#              #--> 1
#              o1.RetireWorld("resto")
#              ? o1.IsActiveWorld("resto")
#              #--> 0
#              ? o1.KdfRounds()
#              #--> 100000
#   see        StzPlatformQ, stzApp, stzPlatformProfile, stzGovernance, stzAppServer
class stzPlatform from stzObject

	@cName = ""
	@cWhy = ""

	# harvested world (plain records -- see header)
	@cWorldName = ""
	@aWorldReaches = []
	@aWorldThings = []      # [ [ name, [fields] ], ... ]
	@aWorldScreens = []     # [ name, ... ]
	@bHasWorld = 0

	# capability seam
	@oGov = ""            # snapshot of the sealed regime
	@aAdmissions = []       # [ [ capability, [purposes] ], ... ]
	@nCurAdmission = 0

	# commons
	@oDb = ""
	@bCommonsReady = 0
	@nKdfRounds = 100000    # PBKDF2 iterations for identity secrets

	# networked body
	@oHost = ""
	@bServing = 0

	# registry
	@aWorlds = []           # [ [ name, version, active ], ... ]
	@aBonds = []            # [ [ from, to, action ], ... ]

	# deployment architecture (the solution's constituents, declared in a
	# stzPlatformProfile the platform OWNS) + its lifecycle state
	@oProfile = ""
	@bBuilt = 0
	@bDeployed = 0
	@aBuildReport = []      # [ [ name, kind, target, status ], ... ]
	@aDeployReport = []
	@oLog = ""            # a structured stzLog of Build() + Deploy()

	# Builds a platform named for one solution, with an empty profile, no world, no governance, no Commons and a trace-level log.
	#
	#   pcName     the platform's name
	#   returns    nothing; the object is built
	#   see        SetProfile, SetWorld, Log
	def init(pcName)
		@cName = "" + pcName
		@oLog = new stzLog("platform")
		@oLog.SetLevel(:trace)

	# Returns the structured log in which Build and Deploy record each phase.
	#
	#   returns    a stzLog; its AsText, CountOfLevel and Where read it
	#   note       a refused build or deploy is logged at level error before it raises
	#   see        Build, Deploy
	#@ aka  the structured log of the platform's Build() + Deploy() phases -- queryable and renderable: oPlat.Log().EntriesOfLevel(:error), oPlat.Log().AsJson().
	def Log()
		return @oLog

	# Returns the name the platform was given.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Returns the reason of the last refusal by Granted, RegisterIdentity, OpenSession or CallAcross.
	#
	#   returns    a text, empty before any refusal and emptied by a successful CallAcross
	#   see        Granted, CallAcross, OpenSession
	def Why()
		return @cWhy

	# Gives the platform the deployment profile whose parts it will build and deploy.
	#
	#   poProfile   a stzPlatformProfile, fully configured
	#   returns     the platform itself, so calls chain
	#   note        the platform keeps a copy, so configure the profile before this call
	#   see         Profile, Build
	#@ aka  == 0. DEPLOYMENT ARCHITECTURE (own a profile; BUILD then DEPLOY) ========
	def SetProfile(poProfile)
		@oProfile = poProfile
		return This

	# Returns the deployment profile the platform owns.
	#
	#   returns    a stzPlatformProfile; an empty text before SetProfile
	#   see        SetProfile, HasProfile
	def Profile()
		return @oProfile

	# TRUE if a deployment profile was set.
	#
	#   returns    TRUE or FALSE
	#   see        SetProfile
	def HasProfile()
		return @oProfile != ""

	# Checks that the profile is sound and records, for each part, its language and the compiler command that would build it.
	#
	#   returns    the platform itself, so calls chain
	#   note       it does not run any compiler: only the commands are recorded, and a part with no
	#              language is recorded as no language declared
	#   warning    it raises an error with no profile and when the profile is unsound, such as no
	#              development system or no apps
	#   see        Deploy, BuildReport, BuildCommandFor
	#@ aka  BUILD the platform and its constituents. Refuses an unsound solution (LAW 3). Must precede Deploy().
	def Build()
		if @oProfile = ""
			stzraise("stzPlatform.Build: no deployment profile -- SetProfile(oProfile) first.")
		ok
		_aIssues_ = @oProfile.Validate()
		if len(_aIssues_) > 0
			@oLog.Record(:error, "build refused -- solution not sound", [ [ :issues, len(_aIssues_) ] ])
			stzraise("stzPlatform.Build: the solution is not sound -- " + JoinXT(_aIssues_, "; "))
		ok
		@aBuildReport = []
		_aApps_ = @oProfile.Apps()
		_n_ = len(_aApps_)
		@oLog.Record(:info, "build started", [ [ :parts, _n_ ] ])
		for _i_ = 1 to _n_
			_app_ = _aApps_[_i_]
			# wire stzBuilder: a part that declares a LANGUAGE is compiled by it,
			# for its deployment target (its OS+arch ARE a Zig triple). We capture
			# the real build COMMAND; running it (invoking Zig) is a separate step.
			_cLang_ = ""
			_cCmd_ = "(no language declared)"
			if _app_.HasLanguage()
				_oB_ = new stzBuilder(_app_.Name())
				_oB_.SetLanguage(_app_.Language())
				_aSrc_ = _app_.Sources()
				_ns_ = len(_aSrc_)
				for _k_ = 1 to _ns_
					_oB_.AddSource(_aSrc_[_k_])
				next
				if isObject(_app_.DeploymentSystem())
					_oB_.SetTarget(_app_.DeploymentSystem())
				ok
				_cLang_ = _app_.Language()
				_cCmd_ = _oB_.ToCommand()
			ok
			@aBuildReport + [ _app_.Name(), _app_.Kind(),
			                  _app_.DeploymentOSName(), _cLang_, _cCmd_ ]
			@oLog.Record(:info, "part built", [ [ :part, _app_.Name() ], [ :kind, _app_.Kind() ],
			                  [ :language, _cLang_ ], [ :os, _app_.DeploymentOSName() ] ])
		next
		@oLog.Record(:info, "build complete", [ [ :parts, _n_ ] ])
		@bBuilt = 1
		return This

		def BuildQ()
			return This.Build()

	# TRUE if Build has completed.
	#
	#   returns    TRUE or FALSE
	#   see        Build, IsDeployed
	def IsBuilt()
		return @bBuilt

	# Lowers each built part to a target artifact, firmware source for a microcontroller or a manifest otherwise, and records it.
	#
	#   returns    the platform itself, so calls chain
	#   note       the artifact is a text kept in the report: nothing is flashed or uploaded
	#   warning    it raises an error until Build has run
	#   see        Build, DeployReport, ArtifactFor, DeployAs
	#@ aka  DEPLOY the built parts to their target systems. Refuses if the platform was not built first -- Build() and Deploy() are separate. For each part, the deploy-time LOWERING bridge turns its rehearsed (up-enable) feature ops into a real target ARTIFACT (firmware source for an MCU, a manifest otherwise) -- the flash/upload of that artifact to the device is the one remaining external step.
	def Deploy()
		return This._DeployWith("")

		def DeployQ()
			return This.Deploy()

	# Governed deploy: deployment is an EFFECTFUL crossing, so an actor that
	# cannot effect reality (an LLM) may PROPOSE it but not perform it (Phase 4).
	def DeployAs(poActor)
		return This._DeployWith(poActor)

	def _DeployWith(poActor)
		if NOT @bBuilt
			@oLog.Record(:error, "deploy refused -- platform not built (Build() first)", [])
			stzraise("stzPlatform.Deploy: the platform must be Build() before it can be deployed.")
		ok
		if poActor != ""
			if NOT poActor.IsEffectful()
				@oLog.Record(:error, "deploy refused -- actor may propose but not perform (not effectful)", [ [ :actor, poActor.Name() ] ])
				stzraise("stzPlatform.Deploy: actor '" + poActor.Name() +
				         "' lacks the 'effectful' capability -- it may propose a deploy, not perform it.")
			ok
		ok
		@aDeployReport = []
		_oBridge_ = new stzLoweringBridge()
		_aApps_ = @oProfile.Apps()
		_n_ = len(_aApps_)
		_who_ = "(none)"
		if isObject(poActor)
			_who_ = poActor.Name()
		ok
		@oLog.Record(:info, "deploy started", [ [ :actor, _who_ ], [ :parts, _n_ ] ])
		for _i_ = 1 to _n_
			_cName_ = _aApps_[_i_].Name()
			_cOs_ = _aApps_[_i_].DeploymentOSName()
			_aOps_ = @oProfile.RehearsedFeatureOpsFor(_cName_)
			_cArtifact_ = _oBridge_.LowerOps(_aOps_, _cOs_)
			@aDeployReport + [ _cName_, _aApps_[_i_].Kind(), _cOs_,
			                   len(_aOps_), _cArtifact_ ]
			@oLog.Record(:info, "part deployed", [ [ :part, _cName_ ], [ :os, _cOs_ ],
			                   [ :ops, len(_aOps_) ], [ :artifact, _cArtifact_ ] ])
		next
		@oLog.Record(:info, "deploy complete", [ [ :parts, _n_ ] ])
		@bDeployed = 1
		return This

	# TRUE if Deploy has completed.
	#
	#   returns    TRUE or FALSE
	#   see        Deploy, IsBuilt
	def IsDeployed()
		return @bDeployed

	# Returns what Build recorded for each part.
	#
	#   returns    a list of lists, each with the part's name, kind, target system, language and
	#              compiler command; empty before Build
	#   see        Build, LanguageOf, BuildCommandFor
	def BuildReport()
		return @aBuildReport

	# Returns the language in which a part is built.
	#
	#   pcName     the part's name, in any case
	#   returns    a text such as c or ring; empty for a part with no language and for an unknown
	#              part
	#   note       the name is matched without regard to case
	#   see        BuildReport, BuildCommandFor
	#@ aka  the language a part was compiled in (from the build report).
	def LanguageOf(pcName)
		return This._BuildField(pcName, 4)

	# Returns the compiler command recorded for a part.
	#
	#   pcName     the part's name, in any case
	#   returns    a text; no language declared for a part without a language, and empty for an
	#              unknown part
	#   note       the command names the compiler found on the machine of the run, so the text
	#              differs between machines
	#   see        BuildReport, LanguageOf
	#@ aka  the stzBuilder command that compiles a part (from the build report).
	def BuildCommandFor(pcName)
		return This._BuildField(pcName, 5)

	def _BuildField(pcName, nCol)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aBuildReport)
		for _i_ = 1 to _n_
			if @aBuildReport[_i_][1] = _c_
				return @aBuildReport[_i_][nCol]
			ok
		next
		return ""

	# Returns what Deploy recorded for each part.
	#
	#   returns    a list of lists, each with the part's name, kind, target system, the number of
	#              rehearsed operations lowered and the artifact text; empty before Deploy
	#   see        Deploy, ArtifactFor
	def DeployReport()
		return @aDeployReport

	# Returns the artifact that Deploy produced for a part.
	#
	#   pcName     the part's name, in any case
	#   returns    a text; empty for an unknown part or before Deploy
	#   note       the firmware artifact of an ESP32 part was a small C source with an empty setup
	#              and loop
	#   see        DeployReport, Deploy
	#@ aka  The lowered artifact (firmware / manifest) for a part, after Deploy().
	def ArtifactFor(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aDeployReport)
		for _i_ = 1 to _n_
			if @aDeployReport[_i_][1] = _c_
				return @aDeployReport[_i_][5]
			ok
		next
		return ""

	# Returns the parts of the profile.
	#
	#   returns    a list of stzAppProfile objects; empty with no profile
	#   see        NumberOfParts, App
	#@ aka  -- delegating reads into the owned profile --
	def Parts()
		if @oProfile = ""
			return []
		ok
		return @oProfile.Apps()

	# Returns how many parts the profile holds.
	#
	#   returns    a number; 0 with no profile
	#   see        Parts
	def NumberOfParts()
		if @oProfile = ""
			return 0
		ok
		return @oProfile.NumberOfApps()

	# Returns one part of the profile by name.
	#
	#   pcName     the part's name
	#   returns    a stzAppProfile
	#   warning    it raises an error when no profile was set
	#   see        Parts
	def App(pcName)
		if @oProfile = ""
			stzraise("stzPlatform.App: no profile -- SetProfile(oProfile) first.")
		ok
		return @oProfile.App(pcName)

	# Returns the system on which the solution is developed.
	#
	#   returns    a stzSystemProfile; an empty text with no profile
	#   see        SetProfile
	def DevelopmentSystem()
		if @oProfile = ""
			return ""
		ok
		return @oProfile.DevelopmentSystem()

	# Reads a world's name, reaches, things and screens into the platform, which keeps no reference to the world.
	#
	#   poApp      the stzApp to envelop, already declared
	#   returns    the platform itself, so calls chain
	#   note       call it after the world is declared: later changes to the world do not reach the
	#              platform
	#   see        Generate, ServeBody
	#@ aka  == 1. GENERATION ========================================================
	def SetWorld(poApp)
		@cWorldName = poApp.Name()
		@aWorldReaches = poApp.Surfaces()
		@aWorldThings = poApp.Things()
		@aWorldScreens = poApp.ScreenNames()
		@bHasWorld = 1
		return This

	# Writes one shell file per declared reach of the world and returns their paths: a web page, a desktop launcher or a mobile page.
	#
	#   pWhat      :all for every reach of the world, or one of web, desktop or mobile
	#   returns    a list of the written file paths
	#   note       the files go under .stzapp/shells in the current folder, which is created before
	#              an unknown surface is refused, and only the two error cases were run because the
	#              write is a change on disk
	#   warning    it raises an error with no world, with a world that declares no reach, and for an
	#              unknown surface
	#   see        SetWorld, ServeBody
	#@ aka  Generate(:all) or Generate(:web / :desktop / :mobile). Writes REAL shell files (one per declared Reach) and returns the list of written paths. Raises when there is no world, no reach, or an unknown reach surface (LAW 3: refuse, never stub).
	def Generate(pWhat)
		if NOT @bHasWorld
			stzraise("stzPlatform.Generate: no world attached -- SetWorld(oApp) first.")
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
		_c_ += 'oApp = StzAppQ("' + @cWorldName + '")' + _cNL_
		_c_ += "oPlat = StzPlatformQ('" + @cName + "')" + _cNL_
		_c_ += "oPlat.SetWorld(oApp)" + _cNL_
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

	# Returns the name of the governance regime that decides capabilities.
	#
	#   returns    a text; empty when none was set
	#   see        SetGovernedBy, Granted
	#@ aka  == 2. THE CAPABILITY SEAM ==============================================
	def GovernedBy()
		if @oGov = ""
			return ""
		ok
		return @oGov.Name_()

	# Wires a sealed governance regime and declares the risk tiers of the platform's capabilities into it where it has none.
	#
	#   poGov      the stzGovernance, fully configured, of which the platform keeps a copy
	#   returns    the platform itself, so calls chain
	#   note       the tiers are storage, notifications and offline 1, camera 2, location 3 and
	#              payments 4
	#   see        Granted, AddCapability
	def SetGovernedBy(poGov)
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

	# Requests a device capability for the world and makes it the one SetPurposes fills.
	#
	#   pcCapability   the capability, such as camera or payments, kept in lower case
	#   returns        nothing; use AddCapabilityQ to chain
	#   note           AddCapabilityQ is the same call and returns the platform
	#   see            SetPurposes, Granted, Admissions
	#@ aka  Request a capability for the attached world: oPlat.AddCapabilityQ(:camera).SetPurposes([ :scan-dish-photo ])
	def AddCapability(pcCapability)
		_cCap_ = StzLower("" + pcCapability)
		@aAdmissions + [ _cCap_, [] ]
		@nCurAdmission = len(@aAdmissions)

	# fills the purposes of the capability just added (cursor)

		def AddCapabilityQ(pcCapability)
			This.AddCapability(pcCapability)
			return This

	# Records the purposes of the capability added last, as a list.
	#
	#   paPurposes   a list of purposes
	#   returns      the platform itself, so calls chain
	#   note         with no capability added yet it does nothing
	#   warning      a single text, symbol or number is not wrapped: Admissions then shows [ [ [ ] ]
	#                ] for it today, so pass a list
	#   see          AddCapability, Admissions
	def SetPurposes(paPurposes)
		if @nCurAdmission > 0
			if NOT isList(paPurposes)
				paPurposes = [ paPurposes ]
			ok
			@aAdmissions[@nCurAdmission][2] = paPurposes
		ok
		return This

	# TRUE if governance lets the world use a requested capability, a decision of permission against the capability's risk tier.
	#
	#   pcCapability   the capability, in any case
	#   returns        TRUE or FALSE; Why gives the reason
	#   note           a capability never requested is refused with that reason, and a world without
	#                  the use-<capability> permission is refused too
	#   warning        it raises an error with no governance wired or no world attached
	#   see            AddCapability, SetGovernedBy, Why
	#@ aka  The governed decision: the WORLD is the actor, "use-<cap>" the action; permission CAN + authority SHOULD vs the risk tier.
	def Granted(pcCapability)
		if @oGov = ""
			stzraise("stzPlatform.Granted: no governance wired -- capabilities are governed by construction (SetGovernedBy first).")
		ok
		if NOT @bHasWorld
			stzraise("stzPlatform.Granted: no world attached.")
		ok
		_cCap_ = StzLower("" + pcCapability)
		if NOT This._WasAdmitted(_cCap_)
			@cWhy = "capability '" + _cCap_ + "' was never requested via AddCapabilityQ()."
			return 0
		ok
		_bOk_ = @oGov.MayProceed(@cWorldName, "use-" + _cCap_)
		@cWhy = @oGov.Why()
		return _bOk_

	def _WasAdmitted(pcCap)
		_nLen_ = len(@aAdmissions)
		for _i_ = 1 to _nLen_
			if @aAdmissions[_i_][1] = pcCap
				return 1
			ok
		next
		return 0

	# Returns the capabilities requested so far with their purposes.
	#
	#   returns    a list of lists, each a capability and its list of purposes
	#   see        AddCapability, SetPurposes
	def Admissions()
		return @aAdmissions

	# Wires an open database as the store of identities, sessions, messages and key-value pairs, creating its four tables if absent.
	#
	#   poDb       an open stzDatabase
	#   returns    the platform itself, so calls chain
	#   note       the platform shares the database's handle, so keep the original open while the
	#              platform runs, and an in-memory database lasts only as long as it does
	#   see        RegisterIdentity, OpenSession
	#@ aka  == 3. THE COMMONS RUNTIME ==============================================
	def OpenCommonsOn(poDb)
		@oDb = poDb
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_identity(user TEXT PRIMARY KEY, secret TEXT)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_session(token TEXT PRIMARY KEY, user TEXT, opened_ms INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_message(sender TEXT, recipient TEXT, body TEXT, sent_ms INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS stz_store(k TEXT PRIMARY KEY, v TEXT)")
		@bCommonsReady = 1
		return This

	def _NeedCommons()
		if NOT @bCommonsReady
			stzraise("stzPlatform: the Commons is not wired -- OpenCommonsOn(oDb) first.")
		ok

	# Sets how many iterations the password hash uses for identities registered afterwards; it starts at 100000.
	#
	#   nRounds    the iteration count, at least 1
	#   returns    the platform itself, so calls chain
	#   note       lower it only in tests: each identity keeps the rounds it was made with, so
	#              raising it later does not lock anyone out
	#   warning    it raises an error below 1
	#   see        KdfRounds, RegisterIdentity
	#@ aka  Tune the KDF cost. Default 100k; lower ONLY in tests. Must be set before RegisterIdentity (a stored hash is bound to the rounds used).
	def SetKdfRounds(nRounds)
		if nRounds < 1
			stzraise("KDF rounds must be >= 1.")
		ok
		@nKdfRounds = nRounds
		return This

	# Returns the iteration count that new identities are hashed with.
	#
	#   returns    a number, 100000 by default
	#   see        SetKdfRounds
	def KdfRounds()
		return @nKdfRounds

	# Stores a user with a random salt and a PBKDF2 hash of the secret, never the secret itself.
	#
	#   pcUser     the user name
	#   pcSecret   the secret to hash
	#   returns    TRUE if registered, FALSE if the user already exists (Why says so)
	#   note       the stored value reads rounds, salt and hash separated by colons
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        OpenSession, SetKdfRounds
	#@ aka  KDF-BACKED IDENTITY (the engine KDF closes the plaintext gap): each identity stores a per-user random SALT + a PBKDF2-HMAC-SHA256 hash of the secret over @nKdfRounds iterations -- never the secret itself.
	def RegisterIdentity(pcUser, pcSecret)
		This._NeedCommons()
		if @oDb.Value("SELECT user FROM stz_identity WHERE user = '" + This._Sql(pcUser) + "'") != ""
			@cWhy = "identity '" + pcUser + "' already exists."
			return 0
		ok
		# THE ROUNDS ARE STORED WITH THE RECORD, not read from the platform at
		# verification time. They were not, and the consequence was silent: raise
		# SetKdfRounds -- which this class's own header invites -- and every
		# identity already registered could no longer log in, refused with
		# "identity/secret mismatch", which reads as a wrong password.
		#
		# A KDF cost is a property of the hash that was made, not of the machine
		# checking it later. Storing it is also what lets the cost be raised over
		# time without locking anyone out.
		_cSalt_ = StzEngineCryptoRandomHex(16)
		_cHash_ = StzEngineCryptoPbkdf2("" + pcSecret, _cSalt_, @nKdfRounds, 32)
		@oDb.Exec("INSERT INTO stz_identity (user, secret) VALUES ('" +
		          This._Sql(pcUser) + "', '" + @nKdfRounds + ":" + _cSalt_ + ":" + _cHash_ + "')")
		return 1

	# Checks a user's secret in constant time and opens a session.
	#
	#   pcUser     the user name
	#   pcSecret   the secret to check
	#   returns    a text, the session token beginning with sess_; empty when refused (Why says so)
	#   note       an unknown user and a wrong secret give the same reason
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        SessionUser, RegisterIdentity
	#@ aka  Returns a session token, or "" (Why() explains) on refusal. The secret is verified by re-deriving with the stored salt + rounds and a CONSTANT-TIME compare (StzEngineCryptoConstEqual).
	def OpenSession(pcUser, pcSecret)
		This._NeedCommons()
		_cStored_ = @oDb.Value("SELECT secret FROM stz_identity WHERE user = '" + This._Sql(pcUser) + "'")
		if _cStored_ = "" or NOT This._SecretMatches(_cStored_, pcSecret)
			@cWhy = "identity/secret mismatch for '" + pcUser + "'."
			return ""
		ok
		_cToken_ = "sess_" + StzEngineCryptoRandomHex(24)
		@oDb.Exec("INSERT INTO stz_session (token, user, opened_ms) VALUES ('" +
		          _cToken_ + "', '" + This._Sql(pcUser) + "', " + StzEngineTimeNowMs() + ")")
		return _cToken_

	# stored = "rounds:salt:hash"; re-derive at THOSE rounds and compare in
	# constant time.
	#
	# A two-part "salt:hash" is a record written before the rounds were stored:
	# it is verified at the platform's current setting, which is exactly what
	# used to happen to every record. So nothing that works today stops working,
	# and everything written from now on survives a change of cost.
	def _SecretMatches(pcStored, pcSecret)
		_aParts_ = StzSplit("" + pcStored, ":")
		_nParts_ = len(_aParts_)

		_nRounds_ = @nKdfRounds
		_cSalt_ = ""
		_cHash_ = ""

		if _nParts_ = 3
			_nRounds_ = 0 + _aParts_[1]
			_cSalt_ = _aParts_[2]
			_cHash_ = _aParts_[3]
		but _nParts_ = 2
			_cSalt_ = _aParts_[1]
			_cHash_ = _aParts_[2]
		else
			return 0
		ok

		if _nRounds_ < 1
			return 0
		ok

		_cTry_ = StzEngineCryptoPbkdf2("" + pcSecret, _cSalt_, _nRounds_, 32)
		return StzEngineCryptoConstEqual(_cTry_, _cHash_) = 1

	# Returns the user to whom a session token belongs.
	#
	#   pcToken    a token returned by OpenSession
	#   returns    a text; empty for an unknown token
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        OpenSession
	def SessionUser(pcToken)
		This._NeedCommons()
		return @oDb.Value("SELECT user FROM stz_session WHERE token = '" + This._Sql(pcToken) + "'")

	# Stores a message from one user to another.
	#
	#   pcFrom     the sender
	#   pcTo       the recipient
	#   pcBody     the message text
	#   returns    the platform itself, so calls chain
	#   note       quotes in the text are stored correctly, and the sender is not checked against
	#              the identities
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        Inbox
	def PostMessage(pcFrom, pcTo, pcBody)
		This._NeedCommons()
		@oDb.Exec("INSERT INTO stz_message (sender, recipient, body, sent_ms) VALUES ('" +
		          This._Sql(pcFrom) + "', '" + This._Sql(pcTo) + "', '" +
		          This._Sql(pcBody) + "', " + StzEngineTimeNowMs() + ")")
		return This

	# Returns the messages sent to a user, oldest first.
	#
	#   pcUser     the recipient
	#   returns    a list of lists, each with the sender and the body; empty when there are none
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        PostMessage
	def Inbox(pcUser)
		This._NeedCommons()
		return @oDb.Rows("SELECT sender, body FROM stz_message WHERE recipient = '" +
		                 This._Sql(pcUser) + "' ORDER BY sent_ms")

	# Stores a value under a key, replacing any earlier value.
	#
	#   pcKey      the key
	#   pcValue    the value text
	#   returns    the platform itself, so calls chain
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        StoreGet
	def StorePut(pcKey, pcValue)
		This._NeedCommons()
		@oDb.Exec("INSERT OR REPLACE INTO stz_store (k, v) VALUES ('" +
		          This._Sql(pcKey) + "', '" + This._Sql(pcValue) + "')")
		return This

	# Returns the value stored under a key.
	#
	#   pcKey      the key
	#   returns    a text; empty for an unknown key
	#   warning    it raises an error until OpenCommonsOn has run
	#   see        StorePut
	def StoreGet(pcKey)
		This._NeedCommons()
		return @oDb.Value("SELECT v FROM stz_store WHERE k = '" + This._Sql(pcKey) + "'")

	def _Sql(pcVal)
		return StzReplace("" + pcVal, "'", "''")

	# Starts the reactor host on 127.0.0.1 to serve the world and, when a Commons is wired, its sessions, messages and store over HTTP.
	#
	#   nPort      the port to listen on, 0 for any free one
	#   returns    the platform itself, so calls chain
	#   note       the routes are /world and /thing for the world, and /session, /whoami, /message,
	#              /inbox and /store for the Commons
	#   warning    it opens a listening port, so only the refusal with nothing to serve was run: it
	#              raises an error with neither a world nor a Commons
	#   see        HostQ, ServeOne, ServeFor, StopServing
	#@ aka  == 4. THE NETWORKED BODY ===============================================
	def ServeBody(nPort)
		if NOT @bHasWorld and @oDb = ""
			stzraise("stzPlatform.ServeBody: nothing to serve -- attach a world " +
			         "(ForWorld) and/or Commons (CommonsOn) first.")
		ok
		@oHost = new stzAppServer()
		# the read-only WORLD view (duty 4a)
		if @bHasWorld
			This._PrerenderWorld()
			@oHost.Get_("/world", "StzPlatformWorldRoute")
			@oHost.Get_("/thing", "StzPlatformThingRoute")
		ok
		# the interactive, session-authed COMMONS (duty 4b): identity /
		# sessions / messaging / store served MULTI-USER over the wire.
		if @oDb != ""
			$oStzPlatformActive = This
			@oHost.Post("/session", "StzPlatformSessionRoute")
			@oHost.Get_("/whoami", "StzPlatformWhoamiRoute")
			@oHost.Post("/message", "StzPlatformMessageRoute")
			@oHost.Get_("/inbox", "StzPlatformInboxRoute")
			@oHost.Post("/store", "StzPlatformStorePutRoute")
			@oHost.Get_("/store", "StzPlatformStoreGetRoute")
		ok
		@oHost.Start(nPort, "127.0.0.1")
		@bServing = 1
		return This

	# Returns the serving host, from which the port is read.
	#
	#   returns    a stzAppServer; an empty text before ServeBody
	#   note       only the answer before serving was run
	#   see        ServeBody
	#@ aka  The serving host (a chainable stz object -- Q-convention). NB: an accessor returns a handle-sharing copy; use it for Port()/ServeOne.
	def HostQ()
		return @oHost

	# Serves requests for a number of milliseconds.
	#
	#   nMs        how long to serve in milliseconds
	#   returns    the platform itself, so calls chain
	#   note       it occupies the thread while it serves
	#   warning    it raises an error before ServeBody, which is the only case run
	#   see        ServeBody, ServeOne
	def ServeFor(nMs)
		if NOT @bServing
			stzraise("stzPlatform.ServeFor: not serving -- ServeBody first.")
		ok
		@oHost.RunFor(nMs)
		return This

	# Serves at most one request, waiting up to the given time.
	#
	#   nTimeoutMs   how long to wait for a request in milliseconds
	#   returns      the result of the host's ServeOne
	#   warning      it raises an error before ServeBody, which is the only case run
	#   see          ServeBody, ServeFor
	def ServeOne(nTimeoutMs)
		if NOT @bServing
			stzraise("stzPlatform.ServeOne: not serving -- ServeBody first.")
		ok
		return @oHost.ServeOne(nTimeoutMs)

	# Stops the serving host; it does nothing when not serving.
	#
	#   returns    the platform itself, so calls chain
	#   note       only the not-serving case was run
	#   see        ServeBody
	def StopServing()
		if @bServing
			@oHost.Stop()
			@bServing = 0
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

	# Registers a world and its version as active, or updates the version and reactivates it if it is already registered.
	#
	#   pcName      the world's name, matched exactly
	#   pcVersion   its version text
	#   returns     the platform itself, so calls chain
	#   see         RetireWorld, Worlds
	#@ aka  == 5. REGISTRY + ENFORCEMENT ===========================================
	def PushWorld(pcName, pcVersion)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				@aWorlds[_i_][2] = pcVersion
				@aWorlds[_i_][3] = 1
				return This
			ok
		next
		@aWorlds + [ pcName, pcVersion, 1 ]
		return This

	# Marks a registered world as inactive; an unknown name changes nothing.
	#
	#   pcName     the world's name
	#   returns    the platform itself, so calls chain
	#   see        PushWorld, IsActiveWorld
	def RetireWorld(pcName)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				@aWorlds[_i_][3] = 0
				return This
			ok
		next
		return This

	# TRUE if the world is registered and not retired.
	#
	#   pcName     the world's name, matched exactly
	#   returns    1 or 0
	#   see        PushWorld, RetireWorld
	def IsActiveWorld(pcName)
		_nLen_ = len(@aWorlds)
		for _i_ = 1 to _nLen_
			if @aWorlds[_i_][1] = pcName
				return @aWorlds[_i_][3]
			ok
		next
		return 0

	# Returns the registry as a list of lists, each with a world's name, its version and 1 when active or 0 when retired.
	#
	#   returns    a list of lists
	#   see        PushWorld
	def Worlds()
		return @aWorlds

	# Declares that one world may attempt an action on another, subject to governance at call time.
	#
	#   pcFrom     the calling world's name, matched exactly
	#   pcTo       the target world, lowered
	#   pcAction   the action, lowered
	#   returns    the platform itself, so calls chain
	#   note       a bond is not a permission: CallAcross still asks governance
	#   see        CallAcross, PushWorld
	#@ aka  Declare a norm-bearing bond: from-world may attempt an action on to-world (still subject to governance at call time).
	def Bond(pcFrom, pcTo, pcAction)
		@aBonds + [ pcFrom, StzLower("" + pcTo), StzLower("" + pcAction) ]
		return This

	# TRUE if a call from one world to another may go through: both active, a bond naming the action, and governance agreeing.
	#
	#   pcFrom     the calling world
	#   pcTo       the target world
	#   pcAction   the action
	#   returns    1 if allowed, 0 if refused with Why giving the reason
	#   note       the world names are matched exactly in the registry, while the action and the
	#              target are compared in lower case in the bonds
	#   warning    with governance wired, an action that has no declared risk tier is refused, so
	#              declare the risk of the action in the regime
	#   see        Bond, PushWorld, Why
	#@ aka  The enforcement seam: a cross-world call goes through ONLY when (a) both worlds are active in the registry, (b) a bond declares the action, and (c) governance lets the calling world proceed. Returns TRUE/FALSE; Why() explains every refusal.
	def CallAcross(pcFrom, pcTo, pcAction)
		if NOT This.IsActiveWorld(pcFrom)
			@cWhy = "calling world '" + pcFrom + "' is not active in the registry."
			return 0
		ok
		if NOT This.IsActiveWorld(pcTo)
			@cWhy = "target world '" + pcTo + "' is not active in the registry."
			return 0
		ok
		_cTo_ = StzLower("" + pcTo)
		_cAction_ = StzLower("" + pcAction)
		_bBonded_ = 0
		_nLen_ = len(@aBonds)
		for _i_ = 1 to _nLen_
			if @aBonds[_i_][1] = pcFrom and @aBonds[_i_][2] = _cTo_ and @aBonds[_i_][3] = _cAction_
				_bBonded_ = 1
				exit
			ok
		next
		if NOT _bBonded_
			@cWhy = "no bond declares '" + _cAction_ + "' from '" + pcFrom + "' to '" + pcTo + "'."
			return 0
		ok
		if @oGov != ""
			if NOT @oGov.MayProceed(pcFrom, _cAction_)
				@cWhy = "governance refused: " + @oGov.Why()
				return 0
			ok
		ok
		@cWhy = ""
		return 1
