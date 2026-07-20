#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZPLATFORMPROFILE         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Phase 3b -- the FULL scope model. The       #
#                  architect's common ground: a solution is a  #
#                  stzPlatformProfile (the dev system + the    #
#                  apps), each stzAppProfile deploys to a      #
#                  stzSystemProfile, and feature code is       #
#                  written in a NAMED scope (App(:x).System()) #
#                  that down-constrains what the target        #
#                  forbids and up-enables what the host lacks. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# SOFTANZA_SYSTEM_FOUNDATION.md section 2, the architect's model. This file is
# the DECLARATION layer: a stzPlatformProfile only DESCRIBES a solution -- its
# development system and its constituents (a server, a superapp, an app, ...),
# each with its deployment system. It does NOT build or deploy: those are
# lifecycle operations on the stzPlatform that OWNS the profile.
#
#   # 1. MODEL the solution (declaration)
#   oProfile = new stzPlatformProfile("my-iot-product")
#   oProfile.DevelopedOn(:Windows)
#   oProfile.WithServer(:backend,  :LinuxServer)
#   oProfile.WithSuperApp(:superapp, :Android)
#   oProfile.WithApp(:firmware, :ESP32)
#
#   # 2. write feature code in a scope (checked against the target)
#   oScope = oProfile.App(:firmware).System()  # the ESP32 scope, on THIS box
#   oScope.ReadPin(4)                          # up-enabled: rehearsed (no gpio here)
#   oScope.Spawn("worker")                     # REFUSED: an MCU has no processes
#
#   # 3. the PLATFORM owns the profile and BUILDS, then DEPLOYS (separate ops)
#   oPlatform = StzPlatformQ("my-iot-product").SetProfile(oProfile)
#   oPlatform.Build()      # build the platform + its constituents
#   oPlatform.Deploy()     # then deploy them (raises if Build() did not run)
#
# The scope check runs on the DEV machine against the TARGET's profile, so a
# forbidden operation is caught during development. The up-enable rehearsal is
# captured for the deploy-time lowering (a PLANNED bridge: cross-compile / flash).
# Builds on the Phase 1b capability envelope; no new engine work.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzPlatformProfileQ()
	return new stzPlatformProfile("")

func StzAppProfileQ()
	return new stzAppProfile("")

# Map a friendly deployment target to a declared stzSystemProfile, reusing the
# Phase 1b class-default capability sets. An already-built profile passes through.
func _StzSystemProfileForTarget(pTarget)
	if isObject(pTarget)
		return pTarget
	ok
	_c_ = StzLower(ring_trim("" + pTarget))
	_oP_ = new stzSystemProfile("" + pTarget)
	_oP_.SetRole("deployment")
	if _c_ = "esp32" or _c_ = "espidf" or _c_ = "esp-idf"
		_oP_.SetOSName("espidf")
		_oP_.SetArchitecture("arm")
		_oP_.SetBitSize(32)
		_oP_.SetCapabilityList([ "gpio", "network", "clock", "threads" ])
	but _c_ = "android"
		_oP_.SetOSName("android")
		_oP_.SetArchitecture("arm64")
		_oP_.SetBitSize(64)
		_oP_.SetCapabilityList(_StzDefaultCapsForClass("mobile"))
	but _c_ = "ios"
		_oP_.SetOSName("ios")
		_oP_.SetArchitecture("arm64")
		_oP_.SetBitSize(64)
		_oP_.SetCapabilityList(_StzDefaultCapsForClass("mobile"))
	but _c_ = "linuxserver" or _c_ = "linux-server" or _c_ = "linux"
		_oP_.SetOSName("linux")
		_oP_.SetArchitecture("x64")
		_oP_.SetBitSize(64)
		_oP_.SetCapabilityList(_StzDefaultCapsForClass("desktop"))
	but _c_ = "windows"
		_oP_.SetOSName("windows")
		_oP_.SetArchitecture("x64")
		_oP_.SetBitSize(64)
		_oP_.SetCapabilityList(_StzDefaultCapsForClass("desktop"))
	else
		# unknown: treat the token as an OS name and default by class
		_oP_.SetOSName(_c_)
		_oP_.SetCapabilityList(_StzDefaultCapsForClass(_StzSystemClassOf(_c_)))
	ok
	return _oP_


  #==================#
 #  STZSYSTEMSCOPE  #
#==================#
#
# A named scope over a system profile -- the context feature code is written in.
# Each capability-tagged operation is checked against the target profile (does
# it forbid it -> REFUSE) and against the live dev host (does the host lack it
# -> UP-ENABLE by rehearsal). Reading the twin, not reality.

class stzSystemScope from stzObject

	@oProfile = NULL     # the system this scope resolves to (the target)
	@oHost = NULL        # the live dev machine (for the two-worlds decision)
	@aChecked = []       # [ capability, description, status ]

	def init(poProfile)
		@oProfile = poProfile
		@oHost = DevelopmentSystem()

	def System()
		return @oProfile

	def OSName()
		return @oProfile.OSName()

	def Can(pCap)
		return @oProfile.Can(pCap)

	def Lacks(pCap)
		return @oProfile.Lacks(pCap)

	# THE CORE. A capability-tagged operation in this scope. Three outcomes:
	#   forbidden by the scope     -> RAISE (down-constrain, caught in dev)
	#   allowed, host can do it     -> "native" (runs directly)
	#   allowed, host cannot         -> "rehearsed" (up-enable, captured to deploy)
	def Use(pcCap, pcDesc)
		_c_ = StzLower(ring_trim("" + pcCap))
		if @oProfile.Lacks(_c_)
			StzRaise("scope '" + @oProfile.Name() + "' (" + @oProfile.OSName() +
				") forbids '" + _c_ + "' -- " + pcDesc +
				". This target has no such capability.")
		ok
		_cStatus_ = "native"
		if @oHost.Lacks(_c_)
			_cStatus_ = "rehearsed"
		ok
		@aChecked + [ _c_, "" + pcDesc, _cStatus_ ]
		return _cStatus_

	# A non-raising check: does this scope ALLOW the capability?
	def Allows(pCap)
		return @oProfile.Can(pCap)

	def Forbids(pCap)
		return @oProfile.Lacks(pCap)

	# Would using it be UP-ENABLED (allowed by the target, absent on the host)?
	def WouldRehearse(pCap)
		return @oProfile.Can(pCap) and @oHost.Lacks(pCap)

	  #-- capability-tagged verbs (the design's ergonomic surface) --

	def Spawn(pcCmd)
		return This.Use("process", "spawn '" + pcCmd + "'")

	def ReadPin(pnPin)
		return This.Use("gpio", "read pin " + pnPin)

	def WritePin(pnPin, pnVal)
		return This.Use("gpio", "write pin " + pnPin + " = " + pnVal)

	def WriteFile(pcPath, pcContent)
		return This.Use("filesystem", "write file '" + pcPath + "'")

	def ReadFile(pcPath)
		return This.Use("filesystem", "read file '" + pcPath + "'")

	def Connect(pcHost)
		return This.Use("network", "connect to '" + pcHost + "'")

	def SetEnv(pcName, pcVal)
		return This.Use("environment", "set env '" + pcName + "'")

	def LoadLibrary(pcName)
		return This.Use("dynamic_load", "load library '" + pcName + "'")

	def UseThreads()
		return This.Use("threads", "use threads")

	  #-- the two-worlds report ------------------------------

	def CheckedOperations()
		return @aChecked

	def NumberOfChecked()
		return len(@aChecked)

	def _ByStatus(pcStatus)
		_a_ = []
		_n_ = len(@aChecked)
		for _i_ = 1 to _n_
			if @aChecked[_i_][3] = pcStatus
				_a_ + @aChecked[_i_]
			ok
		next
		return _a_

	# The operations that RUN natively on the dev host.
	def NativeOperations()
		return This._ByStatus("native")

	# The operations UP-ENABLED -- rehearsed for the target because the dev host
	# cannot perform them. These are the deploy-time lowering candidates.
	def RehearsedOperations()
		return This._ByStatus("rehearsed")

	def Show()
		? "Scope: " + @oProfile.Name() + " (" + @oProfile.OSName() + ")"
		_n_ = len(@aChecked)
		for _i_ = 1 to _n_
			? "  [" + @aChecked[_i_][3] + "] " + @aChecked[_i_][2]
		next


  #==================#
 #  STZAPPPROFILE   #
#==================#
#
# One part of the solution (a backend, a superapp, an app, a firmware image),
# and the system it deploys to.

class stzAppProfile from stzObject

	@cName = ""
	@cKind = "app"        # app / server / superapp / ...
	@oDeploySystem = NULL

	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	def Name()
		return @cName

	def SetName(pcName)
		@cName = StzLower(ring_trim("" + pcName))
		return This

	# The kind of constituent this is (app / server / superapp / ...).
	def Kind()
		return @cKind

	def SetKind(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	# Declare the deployment target (a friendly token or a stzSystemProfile).
	def To(pTarget)
		@oDeploySystem = _StzSystemProfileForTarget(pTarget)
		return This

		def DeployedTo(pTarget)
			return This.To(pTarget)

	def DeploymentSystem()
		return @oDeploySystem

	def DeploymentOSName()
		if @oDeploySystem = NULL
			return "unknown"
		ok
		return @oDeploySystem.OSName()

	# The scope feature code for this app is written in.
	def System()
		return new stzSystemScope(@oDeploySystem)

	def Show()
		? "App '" + @cName + "' deploys to " + This.DeploymentOSName()


  #=====================#
 #  STZPLATFORMPROFILE #
#=====================#
#
# The common ground: the whole solution -- the development system and the apps,
# each with its deployment system. The three scopes are reachable from here:
# DevelopmentSystem() (declared dev), App(:x).System() (a deployment scope), and
# the global CurrentSystem() (the live runtime).

class stzPlatformProfile from stzObject

	@cName = ""
	@oDevSystem = NULL
	@aApps = []

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	def SetName(pcName)
		@cName = "" + pcName
		return This

	  #-- the development scope -------------------------------

	def DevelopedOn(pTarget)
		@oDevSystem = _StzSystemProfileForTarget(pTarget)
		@oDevSystem.SetRole("development")
		return This

	# The DECLARED development system. (The LIVE machine is the global
	# DevelopmentSystem(); the two should agree, and up-enable is decided
	# against the live one.)
	def DevelopmentSystem()
		return @oDevSystem

	# The live runtime scope -- resolves to wherever this code runs now. Calls
	# the global helper directly: a bare CurrentSystem() here would resolve to
	# THIS method (Ring name resolution) and recurse.
	def CurrentSystem()
		return _StzLiveSystemProfile("runtime")

	  #-- the apps -------------------------------------------

	def AddApp(poApp)
		@aApps + poApp
		return This

		def AddAppQ(poApp)
			This.AddApp(poApp)
			return This

	# DECLARE a constituent (a part of the solution) of a given kind, named
	# pcName, whose deployment target is pTarget. This is a MODELLING act -- the
	# profile only DESCRIBES the solution. Building and deploying are lifecycle
	# operations on the stzPlatform that OWNS this profile, not on the profile.
	def WithConstituent(pcKind, pcName, pTarget)
		_oApp_ = new stzAppProfile(pcName)
		_oApp_.SetKind(pcKind)
		_oApp_.To(pTarget)
		This.AddApp(_oApp_)
		return This

	def WithApp(pcName, pTarget)
		return This.WithConstituent("app", pcName, pTarget)

	def WithServer(pcName, pTarget)
		return This.WithConstituent("server", pcName, pTarget)

	def WithSuperApp(pcName, pTarget)
		return This.WithConstituent("superapp", pcName, pTarget)

	# Declare several constituents at once: [ [ kind, name, target ], ... ].
	def WithConstituents(paTriples)
		if isList(paTriples)
			_n_ = len(paTriples)
			for _i_ = 1 to _n_
				if isList(paTriples[_i_]) and len(paTriples[_i_]) >= 3
					This.WithConstituent(paTriples[_i_][1], paTriples[_i_][2], paTriples[_i_][3])
				ok
			next
		ok
		return This

	def Apps()
		return @aApps

		def Constituents()
			return @aApps

	def NumberOfApps()
		return len(@aApps)

		def NumberOfConstituents()
			return len(@aApps)

	def HasApp(pcName)
		return This._IndexOfApp(pcName) > 0

	def _IndexOfApp(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aApps)
		for _i_ = 1 to _n_
			if @aApps[_i_].Name() = _c_
				return _i_
			ok
		next
		return 0

	# A constituent by name -- the receiver of a deployment scope:
	# App(:x).System().
	def App(pcName)
		_i_ = This._IndexOfApp(pcName)
		if _i_ = 0
			StzRaise("No constituent '" + pcName + "' in platform '" + @cName + "'.")
		ok
		return @aApps[_i_]

		def Constituent(pcName)
			return This.App(pcName)

	  #-- structural validation ------------------------------

	# Solution-level checks: a dev system is declared and every app has a
	# deployment target. Returns a list of issue strings ([] = sound).
	def Validate()
		_a_ = []
		if @oDevSystem = NULL
			_a_ + "no development system declared (use DevelopedOn)"
		ok
		_n_ = len(@aApps)
		if _n_ = 0
			_a_ + "the solution deploys no apps"
		ok
		for _i_ = 1 to _n_
			if @aApps[_i_].DeploymentSystem() = NULL
				_a_ + ("app '" + @aApps[_i_].Name() + "' has no deployment target")
			ok
		next
		return _a_

	def IsSound()
		return len(This.Validate()) = 0

	  #-- the .stzplatform format ----------------------------

	def ToStzPlatform()
		_nl_ = char(10)
		_c_ = "# .stzplatform -- a Softanza solution profile" + _nl_
		_c_ += "platform: " + @cName + _nl_
		if @oDevSystem != NULL
			_c_ += "developed_on: " + @oDevSystem.OSName() + _nl_
		ok
		_n_ = len(@aApps)
		for _i_ = 1 to _n_
			_c_ += @aApps[_i_].Kind() + ": " + @aApps[_i_].Name() + " -> " +
			       @aApps[_i_].DeploymentOSName() + _nl_
		next
		return _c_

	def Save(pcPath)
		_StzWriteTextFile(pcPath, This.ToStzPlatform())
		return This

	# Read a .stzplatform file INTO this profile (the mirror of Save).
	def LoadFrom(pcPath)
		return This.FromString(_StzReadTextFile(pcPath))

	# Parse .stzplatform text into this profile.
	def FromString(pcText)
		_cText_ = StzReplace(pcText, char(13), "")
		_aLines_ = StzSplit(_cText_, char(10))
		_nLines_ = len(_aLines_)
		for _i_ = 1 to _nLines_
			_cLine_ = ring_trim(_aLines_[_i_])
			if _cLine_ = "" or StzLeft(_cLine_, 1) = "#"
				loop
			ok
			_nColon_ = StzFindFirst(":", _cLine_)
			if _nColon_ = 0
				loop
			ok
			_cKey_ = StzLower(ring_trim(StzLeft(_cLine_, _nColon_ - 1)))
			_cVal_ = ring_trim(StzMidToEnd(_cLine_, _nColon_ + 1))
			if _cKey_ = "platform"
				This.SetName(_cVal_)
			but _cKey_ = "developed_on"
				This.DevelopedOn(_cVal_)
			but StzFindFirst("->", _cVal_) > 0
				# a constituent line: "<kind>: <name> -> <target>"
				_nArrow_ = StzFindFirst("->", _cVal_)
				_cAppName_ = ring_trim(StzLeft(_cVal_, _nArrow_ - 1))
				_cTarget_ = ring_trim(StzMidToEnd(_cVal_, _nArrow_ + 2))
				This.WithConstituent(_cKey_, _cAppName_, _cTarget_)
			ok
		next
		return This

	def Show()
		? "Platform: " + @cName
		if @oDevSystem != NULL
			? "  developed on: " + @oDevSystem.OSName()
		ok
		_n_ = len(@aApps)
		for _i_ = 1 to _n_
			? "  app '" + @aApps[_i_].Name() + "' -> " + @aApps[_i_].DeploymentOSName()
		next
