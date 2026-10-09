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

func StzLoweringBridgeQ()
	return new stzLoweringBridge()

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

# Checks feature code written for a deployment target: forbidden operations raise, operations the live machine lacks are rehearsed.
#
# A scope is the context feature code is written in. Each capability-tagged operation (ReadPin,
# Spawn, Connect, UseOp and the others) is compared with the target profile and with the live
# machine: the target forbids it, so an error is raised during development; the machine can do it,
# so it is native; the machine cannot, so it is rehearsed and kept for the lowering bridge. Nothing
# is performed: the scope classifies and records, it never runs the operation.
#
#   receiver   p = new stzPlatformProfile("sol") p.WithApp(:firmware, :ESP32) o1 =
#              p.App(:firmware).System()
#   example    ? o1.OSName()
#              #--> espidf
#              ? o1.Can("gpio")
#              #--> 1
#              ? o1.Forbids("process")
#              #--> 1
#              ? o1.NumberOfChecked()
#              #--> 0
#   see        stzPlatformProfile, stzAppProfile, stzLoweringBridge
class stzSystemScope from stzObject

	@oProfile = ""     # the system this scope resolves to (the target)
	@oHost = ""        # the live dev machine (for the two-worlds decision)
	@aChecked = []       # [ capability, description, status ]

	# Builds a scope over a target system profile and reads the live machine to compare it with.
	#
	#   poProfile   the stzSystemProfile of the deployment target the feature code is written for
	#   returns     nothing; the object is built
	#   note        build it from a part: App(:x).System() in a chain
	#   see         UseOp, System
	def init(poProfile)
		@oProfile = poProfile
		@oHost = DevelopmentSystem()

	# Returns the target system profile this scope resolves to.
	#
	#   returns    a stzSystemProfile
	#   see        OSName, Can
	def System()
		return @oProfile

	# Returns the operating-system name of the target.
	#
	#   returns    a text such as espidf or linux
	#   see        System
	def OSName()
		return @oProfile.OSName()

	# TRUE if the target has the capability.
	#
	#   pCap       the capability name, such as gpio, process, filesystem, network, environment,
	#              dynamic_load, threads or clock
	#   returns    TRUE or FALSE
	#   see        Lacks, Allows
	def Can(pCap)
		return @oProfile.Can(pCap)

	# TRUE if the target does not have the capability.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   see        Can, Forbids
	def Lacks(pCap)
		return @oProfile.Lacks(pCap)

	# Checks one capability-tagged operation against the target and the live machine, and records it.
	#
	#   pcCap      the capability the operation needs, matched without regard to case
	#   pcVerb     the operation's verb, such as read_pin, kept for lowering
	#   paArgs     the arguments, or a single value turned into a list
	#   pcDesc     what it does, in words
	#   returns    a text: native when the live machine can do it, rehearsed when only the target
	#              can
	#   note       the record is [ capability, verb, arguments, description, status ]
	#   warning    raises an error when the target lacks the capability; the operation is not
	#              performed, only classified and recorded
	#   see        Use, WouldRehearse, RehearsedOperations
	#@ aka  THE CORE. A capability-tagged, STRUCTURED operation (verb + args, so it can be lowered to target code later) in this scope. Three outcomes: forbidden by the scope -> RAISE (down-constrain, caught in dev) allowed, host can do it -> "native" (runs directly) allowed, host cannot -> "rehearsed" (up-enable, captured to deploy) A record is [ capability, verb, args, description, status ].
	def UseOp(pcCap, pcVerb, paArgs, pcDesc)
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
		_aArgs_ = paArgs
		if NOT isList(_aArgs_)
			_aArgs_ = [ _aArgs_ ]
		ok
		@aChecked + [ _c_, "" + pcVerb, _aArgs_, "" + pcDesc, _cStatus_ ]
		return _cStatus_

	# Checks and records the use of a capability with no structured verb.
	#
	#   pcCap      the capability name
	#   pcDesc     what it is used for
	#   returns    a text: native or rehearsed
	#   note       lowered later as a comment
	#   warning    the same error as UseOp
	#   see        UseOp
	#@ aka  Generic capability use (no structured verb -- lowered as a comment).
	def Use(pcCap, pcDesc)
		return This.UseOp(pcCap, "use", [], pcDesc)

	# TRUE if the target allows the capability.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   see        Can, Forbids
	#@ aka  A non-raising check: does this scope ALLOW the capability?
	def Allows(pCap)
		return @oProfile.Can(pCap)

	# TRUE if the target forbids the capability.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   see        Allows, Lacks
	def Forbids(pCap)
		return @oProfile.Lacks(pCap)

	# TRUE if using the capability would be rehearsed: the target has it and the live machine does not.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   note       the answer depends on the machine the code runs on
	#   see        UseOp, Allows
	#@ aka  Would using it be UP-ENABLED (allowed by the target, absent on the host)?
	def WouldRehearse(pCap)
		return @oProfile.Can(pCap) and @oHost.Lacks(pCap)

	# Checks and records the start of a process, which needs the process capability.
	#
	#   pcCmd      the command to start
	#   returns    a text: native or rehearsed
	#   note       nothing is started
	#   warning    a target without processes, such as an ESP32, raises an error
	#   see        UseOp
	#@ aka  -- capability-tagged verbs (the design's ergonomic surface) --
	def Spawn(pcCmd)
		return This.UseOp("process", "spawn", [ "" + pcCmd ], "spawn '" + pcCmd + "'")

	# Checks and records the reading of a pin, which needs the gpio capability.
	#
	#   pnPin      the pin number
	#   returns    a text: native or rehearsed
	#   note       a desktop has no gpio, so the operation is rehearsed there
	#   warning    a target without gpio raises an error
	#   see        WritePin, UseOp
	def ReadPin(pnPin)
		return This.UseOp("gpio", "read_pin", [ pnPin ], "read pin " + pnPin)

	# Checks and records the writing of a value to a pin, which needs the gpio capability.
	#
	#   pnPin      the pin number
	#   pnVal      the value to write
	#   returns    a text: native or rehearsed
	#   warning    a target without gpio raises an error
	#   see        ReadPin
	def WritePin(pnPin, pnVal)
		return This.UseOp("gpio", "write_pin", [ pnPin, pnVal ], "write pin " + pnPin + " = " + pnVal)

	# Checks and records the writing of a file, which needs the filesystem capability.
	#
	#   pcPath      the file path
	#   pcContent   the content, accepted and not recorded
	#   returns     a text: native or rehearsed
	#   note        no file is written
	#   warning     a target without a filesystem raises an error
	#   see         ReadFile
	def WriteFile(pcPath, pcContent)
		return This.UseOp("filesystem", "write_file", [ "" + pcPath ], "write file '" + pcPath + "'")

	# Checks and records the reading of a file, which needs the filesystem capability.
	#
	#   pcPath     the file path
	#   returns    a text: native or rehearsed
	#   note       no file is read
	#   warning    a target without a filesystem raises an error
	#   see        WriteFile
	def ReadFile(pcPath)
		return This.UseOp("filesystem", "read_file", [ "" + pcPath ], "read file '" + pcPath + "'")

	# Checks and records a network connection, which needs the network capability.
	#
	#   pcHost     the host to connect to
	#   returns    a text: native or rehearsed
	#   note       no connection is made
	#   warning    a target without network raises an error
	#   see        UseOp
	def Connect(pcHost)
		return This.UseOp("network", "connect", [ "" + pcHost ], "connect to '" + pcHost + "'")

	# Checks and records the setting of an environment variable, which needs the environment capability.
	#
	#   pcName     the variable's name
	#   pcVal      its value
	#   returns    a text: native or rehearsed
	#   note       nothing is set
	#   warning    a target without an environment raises an error
	#   see        UseOp
	def SetEnv(pcName, pcVal)
		return This.UseOp("environment", "set_env", [ "" + pcName, "" + pcVal ], "set env '" + pcName + "'")

	# Checks and records the loading of a dynamic library, which needs the dynamic_load capability.
	#
	#   pcName     the library's name
	#   returns    a text: native or rehearsed
	#   note       nothing is loaded
	#   warning    a target without dynamic loading raises an error
	#   see        UseOp
	def LoadLibrary(pcName)
		return This.UseOp("dynamic_load", "load_library", [ "" + pcName ], "load library '" + pcName + "'")

	# Checks and records the use of threads, which needs the threads capability.
	#
	#   returns    a text: native or rehearsed
	#   see        UseOp
	def UseThreads()
		return This.UseOp("threads", "use_threads", [], "use threads")

	# Returns every operation recorded so far, in order.
	#
	#   returns    a list of [ capability, verb, arguments, description, status ] rows
	#   see        NativeOperations, RehearsedOperations
	#@ aka  -- the two-worlds report ------------------------------
	def CheckedOperations()
		return @aChecked

	# Returns how many operations were recorded.
	#
	#   returns    a number
	#   see        CheckedOperations
	def NumberOfChecked()
		return len(@aChecked)

	def _ByStatus(pcStatus)
		_a_ = []
		_n_ = len(@aChecked)
		for _i_ = 1 to _n_
			if @aChecked[_i_][5] = pcStatus
				_a_ + @aChecked[_i_]
			ok
		next
		return _a_

	# Returns the recorded operations the live machine can perform.
	#
	#   returns    a list of rows
	#   see        RehearsedOperations
	#@ aka  The operations that RUN natively on the dev host.
	def NativeOperations()
		return This._ByStatus("native")

	# Returns the recorded operations only the target can perform, the candidates for deploy-time lowering.
	#
	#   returns    a list of rows
	#   see        NativeOperations, stzLoweringBridge
	#@ aka  The operations UP-ENABLED -- rehearsed for the target because the dev host cannot perform them. These are the deploy-time lowering candidates.
	def RehearsedOperations()
		return This._ByStatus("rehearsed")

	# Prints the scope's target and one line per recorded operation with its status.
	#
	#   returns    nothing; it prints
	#   see        CheckedOperations
	def Show()
		? "Scope: " + @oProfile.Name() + " (" + @oProfile.OSName() + ")"
		_n_ = len(@aChecked)
		for _i_ = 1 to _n_
			? "  [" + @aChecked[_i_][5] + "] " + @aChecked[_i_][4]
		next


  #=====================#
 #  STZLOWERINGBRIDGE  #
#=====================#
#
# The DEPLOY-TIME LOWERING bridge -- the up-enable half of the two worlds made
# real. It turns a scope's REHEARSED operations (the target ops the dev host
# could not perform) into a real target ARTIFACT: firmware source for an MCU, a
# manifest otherwise. The artifact is real, generated code; the final step --
# flashing / uploading it to the device -- is the one reality touch that remains
# a PLANNED external action (it needs the device). This is the same shape as the
# VSF reality bridge: the twin rehearses, the bridge lowers, one crossing.

# Turns the operations a target alone can perform into the artifact of that target: firmware source for a microcontroller, a manifest otherwise.
#
# The bridge is the deploy-time half of the two worlds: the scope rehearses what the development
# machine cannot do, and the bridge lowers those operations to real text for the target, such as
# digitalRead(4) for a pin read. Flashing or uploading the result is a separate act that needs the
# device. It holds no state.
#
#   receiver   o1 = new stzLoweringBridge()
#   example    ? o1.ExtensionFor("esp32")
#              #--> .ino
#              ? o1.ExtensionFor("linux")
#              #--> .txt
#              ? len(StzFind("digitalRead(4)", o1.LowerOps([ [ "gpio", "read_pin", [ 4 ], "read pin 4" ] ], "espidf"))) > 0
#              #--> 1
#   see        stzSystemScope, stzPlatformProfile
class stzLoweringBridge from stzObject

	# Builds the bridge, which holds no state.
	#
	#   returns    nothing; the object is built
	#   see        LowerOps, Lower
	def init()

	# Turns rehearsed operations into the artifact text of a target: firmware source for a microcontroller, else a manifest.
	#
	#   paOps      a list of [ capability, verb, arguments, description ] rows
	#   pcOs       the target's operating-system name
	#   returns    a text; for espidf, esp32, arduino and rtos a firmware sketch where read_pin
	#              gives digitalRead and write_pin gives digitalWrite, else a manifest line per
	#              operation
	#   note       it takes plain data and builds nothing on the device: flashing is a separate act
	#   warning    in firmware, an operation other than the two pin verbs becomes a comment
	#   see        Lower, ExtensionFor, stzSystemScope
	#@ aka  Lower a list of rehearsed operations to the target's artifact (source text). Each op is [ capability, verb, args, description ]. This is the copy-safe core: it takes PLAIN DATA, not a live object.
	def LowerOps(paOps, pcOs)
		if This._IsMcu(pcOs)
			return This._FirmwareFor(paOps, pcOs)
		ok
		return This._ManifestFor(paOps, pcOs)

	# Lowers the rehearsed operations of a scope straight into its target's artifact.
	#
	#   poScope    the stzSystemScope whose rehearsed operations are lowered
	#   returns    a text, as LowerOps returns; a header with no operations when none was rehearsed
	#   note       the target is read from the scope's operating-system name
	#   warning    operations done on a copy of a scope are not in the scope the part retains
	#   see        LowerOps, RehearsedOperations
	#@ aka  Convenience: lower a scope's rehearsed operations directly.
	def Lower(poScope)
		_aOps_ = []
		_aR_ = poScope.RehearsedOperations()
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			_aOps_ + [ _aR_[_i_][1], _aR_[_i_][2], _aR_[_i_][3], _aR_[_i_][4] ]
		next
		return This.LowerOps(_aOps_, poScope.OSName())

	# Returns the file extension the artifact of a target takes.
	#
	#   pcOs       the target's operating-system name, matched without regard to case
	#   returns    a text: .ino for espidf, esp32, arduino and rtos, else .txt
	#   see        LowerOps
	#@ aka  The file extension a target's lowered artifact takes.
	def ExtensionFor(pcOs)
		if This._IsMcu(pcOs)
			return ".ino"
		ok
		return ".txt"

	def _IsMcu(pcOs)
		_c_ = StzLower(ring_trim("" + pcOs))
		return _c_ = "espidf" or _c_ = "esp32" or _c_ = "arduino" or _c_ = "rtos"

	# MCU firmware: a gpio ReadPin(4) lowers to digitalRead(4); WritePin(2,1) to
	# digitalWrite(2, 1). The rehearsal becomes real firmware.
	def _FirmwareFor(paOps, pcOs)
		_nl_ = char(10)
		_c_ = "// firmware generated by the Softanza lowering bridge" + _nl_
		_c_ += "// target: " + pcOs + _nl_
		_c_ += "void setup() {}" + _nl_
		_c_ += "void loop() {" + _nl_
		_n_ = len(paOps)
		for _i_ = 1 to _n_
			_cVerb_ = paOps[_i_][2]
			_aArgs_ = paOps[_i_][3]
			if _cVerb_ = "read_pin"
				_c_ += "  digitalRead(" + _aArgs_[1] + ");" + _nl_
			but _cVerb_ = "write_pin"
				_c_ += "  digitalWrite(" + _aArgs_[1] + ", " + _aArgs_[2] + ");" + _nl_
			else
				_c_ += "  // " + paOps[_i_][4] + _nl_
			ok
		next
		_c_ += "}" + _nl_
		return _c_

	# Any other target: a manifest of the operations to be provided there.
	def _ManifestFor(paOps, pcOs)
		_nl_ = char(10)
		_c_ = "# deploy manifest (Softanza lowering bridge)" + _nl_
		_c_ += "# target: " + pcOs + _nl_
		_n_ = len(paOps)
		for _i_ = 1 to _n_
			_c_ += "- " + paOps[_i_][1] + ": " + paOps[_i_][4] + _nl_
		next
		return _c_


  #==================#
 #  STZAPPPROFILE   #
#==================#
#
# One part of the solution (a backend, a superapp, an app, a firmware image),
# and the system it deploys to.

# Describes one part of a solution: its name, kind, language, sources and the system it deploys to.
#
# A part is declared by the profile that owns it (WithApp, WithServer, WithPart), or built alone and
# added with AddApp. To names the deployment target, and System gives the scope its feature code is
# written in, kept so that operations accumulate. The part only describes: stzPlatform compiles the
# sources with the language set here.
#
#   receiver   o1 = new stzAppProfile("backend") o1.SetKind(:server) o1.To(:LinuxServer)
#   example    ? o1.Name()
#              #--> backend
#              ? o1.Kind()
#              #--> server
#              ? o1.DeploymentOSName()
#              #--> linux
#              ? o1.HasScope()
#              #--> 0
#   see        stzPlatformProfile, stzSystemScope
class stzAppProfile from stzObject

	@cName = ""
	@cKind = "app"        # app / server / superapp / ...
	@oDeploySystem = ""
	@oScope = ""        # the scope its feature code is written in (retained,
	                      # so the rehearsed operations survive to deploy-time)
	@cLanguage = ""       # c / cpp / zig / ring -- so Build() compiles it via stzBuilder
	@aSources = []        # the part's source files

	# Builds a part of a solution with a name, the kind app, no language, no source and no deployment target.
	#
	#   pcName     the part's name, kept in lower case
	#   returns    nothing; the object is built
	#   note       usually made by WithPart of the profile that owns it
	#   see        To, SetKind, stzPlatformProfile
	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	# Returns the part's name, in lower case.
	#
	#   returns    a text
	#   see        SetName
	def Name()
		return @cName

	# Sets the part's name, kept in lower case.
	#
	#   pcName     the new name
	#   returns    the part itself, so calls chain
	#   see        Name
	def SetName(pcName)
		@cName = StzLower(ring_trim("" + pcName))
		return This

	# Returns the kind of part: app, server, superapp or another word.
	#
	#   returns    a text, app by default
	#   see        SetKind
	#@ aka  The kind of constituent this is (app / server / superapp / ...).
	def Kind()
		return @cKind

	# Sets the kind of part, kept in lower case.
	#
	#   pcKind     the kind, such as server or superapp
	#   returns    the part itself, so calls chain
	#   see        Kind
	def SetKind(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	# Sets the language the part's code is written in, so a platform build can compile it.
	#
	#   pcLang     the language, such as c, cpp, zig or ring, kept in lower case
	#   returns    the part itself, so calls chain
	#   see        Language, AddSource
	#@ aka  the LANGUAGE this part's code is written in + its source files, so stzPlatform.Build() compiles it via stzBuilder for its deployment target.
	def SetLanguage(pcLang)
		@cLanguage = StzLower(ring_trim("" + pcLang))
		return This

	# Returns the language of the part's code.
	#
	#   returns    a text; the empty text when none is set
	#   see        SetLanguage, HasLanguage
	def Language()
		return @cLanguage

	# TRUE if a language is set.
	#
	#   returns    TRUE or FALSE
	#   see        SetLanguage
	def HasLanguage()
		return @cLanguage != ""

	# Adds one source file to the part.
	#
	#   pcFile     the source file path
	#   returns    the part itself, so calls chain
	#   see        AddSources, Sources
	def AddSource(pcFile)
		@aSources + ("" + pcFile)
		return This

	# Adds several source files to the part.
	#
	#   paFiles    a list of file paths
	#   returns    the part itself, so calls chain
	#   see        AddSource, Sources
	def AddSources(paFiles)
		if isList(paFiles)
			_n_ = len(paFiles)
			for _i_ = 1 to _n_
				@aSources + ("" + paFiles[_i_])
			next
		ok
		return This

	# Returns the part's source files, in the order added.
	#
	#   returns    a list of text
	#   see        AddSource
	def Sources()
		return @aSources

	# Declares the system the part deploys to.
	#
	#   pTarget    a token such as :ESP32, :Android, :iOS, :LinuxServer or :Windows, or a
	#              stzSystemProfile
	#   returns    the part itself, so calls chain
	#   note       DeployedTo is the same call
	#   warning    an unknown token is taken as an operating-system name with default capabilities
	#   see        DeploymentSystem, DeploymentOSName
	#@ aka  Declare the deployment target (a friendly token or a stzSystemProfile).
	def To(pTarget)
		@oDeploySystem = _StzSystemProfileForTarget(pTarget)
		return This

		def DeployedTo(pTarget)
			return This.To(pTarget)

	# Returns the system profile the part deploys to.
	#
	#   returns    a stzSystemProfile; the empty text before To
	#   see        To
	def DeploymentSystem()
		return @oDeploySystem

	# Returns the operating-system name of the deployment target.
	#
	#   returns    a text; unknown before To
	#   see        To
	def DeploymentOSName()
		if @oDeploySystem = ""
			return "unknown"
		ok
		return @oDeploySystem.OSName()

	# Returns the scope the part's feature code is written in, creating it on first use.
	#
	#   returns    a stzSystemScope
	#   note       call To first: without a target the scope has no profile to check against
	#   warning    assigning the result to a variable gives a copy: operations recorded on the
	#              variable never reach the retained scope, so Scope and the lowering bridge do not
	#              see them; chain the call instead, as in System().ReadPin(4)
	#   see        Scope, HasScope, stzSystemScope
	#@ aka  The scope feature code for this constituent is written in -- RETAINED, so operations accumulate and survive to deploy-time lowering.
	def System()
		if @oScope = ""
			@oScope = new stzSystemScope(@oDeploySystem)
		ok
		return @oScope

	# Returns the retained scope, or the empty text before System was called.
	#
	#   returns    a stzSystemScope or the empty text
	#   see        System, HasScope
	def Scope()
		return @oScope

	# TRUE if the scope was created.
	#
	#   returns    TRUE or FALSE
	#   see        System, Scope
	def HasScope()
		return @oScope != ""

	# Prints one line: the kind, the name and the deployment operating system.
	#
	#   returns    nothing; it prints
	#   see        DeploymentOSName
	def Show()
		? @cKind + " '" + @cName + "' deploys to " + This.DeploymentOSName()


  #=====================#
 #  STZPLATFORMPROFILE #
#=====================#
#
# The common ground: the whole solution -- the development system and the apps,
# each with its deployment system. The three scopes are reachable from here:
# DevelopmentSystem() (declared dev), App(:x).System() (a deployment scope), and
# the global CurrentSystem() (the live runtime).

# Describes a whole solution: its development system and its parts, each with the system it deploys to.
#
# The architect's common ground. Declare the solution with DevelopedOn and WithApp, WithServer,
# WithSuperApp or WithPart, then check it with Validate. Feature code is authored per part
# (ReadPinIn, SpawnIn, ConnectIn and the others) and checked at once against that part's target: an
# operation the target forbids raises an error, one the live machine cannot perform is rehearsed and
# recorded for deploy-time lowering. The profile only describes: it builds and deploys nothing, and
# it is saved as a small .stzplatform text. A part obtained with App and assigned to a variable is a
# copy; chain the calls instead.
#
#   receiver   o1 = new stzPlatformProfile("my-iot-product") o1.DevelopedOn(:Windows)
#              o1.WithServer(:backend, :LinuxServer) o1.WithApp(:firmware, :ESP32)
#   example    ? o1.NumberOfApps()
#              #--> 2
#              ? o1.App(:firmware).DeploymentOSName()
#              #--> espidf
#              ? o1.HasApp("BACKEND")
#              #--> 1
#              ? o1.IsSound()
#              #--> 1
#              ? @@( o1.Validate() )
#              #--> [ ]
#   see        stzAppProfile, stzSystemScope, stzLoweringBridge, stzPlatform
class stzPlatformProfile from stzObject

	@cName = ""
	@oDevSystem = ""
	@aApps = []
	@aFeatureOps = []     # PLAIN-DATA feature operations authored per constituent
	# Builds a solution profile with a name, no development system and no part.
	#
	#   pcName     the solution's name, kept as given
	#   returns    nothing; the object is built
	#   note       the profile only describes the solution; building and deploying belong to the
	#              platform that owns it
	#   see        DevelopedOn, WithApp, WithServer
	#@ aka  [ appName, cap, verb, args, desc, status ] -- plain data so they survive the profile being copied into a stzPlatform, and can be lowered at deploy time.
	def init(pcName)
		@cName = "" + pcName

	# Returns the solution's name.
	#
	#   returns    a text
	#   see        SetName
	def Name()
		return @cName

	# Sets the solution's name.
	#
	#   pcName     the new name
	#   returns    the profile itself, so calls chain
	#   see        Name
	def SetName(pcName)
		@cName = "" + pcName
		return This

	# Declares the development system, from a friendly token or a system profile, and gives it the role development.
	#
	#   pTarget    a token such as :Windows, :LinuxServer, :Android, :ESP32, or a stzSystemProfile
	#   returns    the profile itself, so calls chain
	#   note       tokens map to a known operating system with its default capabilities: ESP32 gives
	#              espidf
	#   warning    an unknown token is taken as an operating-system name with default capabilities
	#   see        DevelopmentSystem, WithPart
	#@ aka  -- the development scope -------------------------------
	def DevelopedOn(pTarget)
		@oDevSystem = _StzSystemProfileForTarget(pTarget)
		@oDevSystem.SetRole("development")
		return This

	# Returns the declared development system.
	#
	#   returns    a stzSystemProfile; the empty text before DevelopedOn
	#   note       the declared system and the live machine should agree, but up-enabling is judged
	#              against the live one
	#   see        DevelopedOn, CurrentSystem
	#@ aka  The DECLARED development system. (The LIVE machine is the global DevelopmentSystem(); the two should agree, and up-enable is decided against the live one.)
	def DevelopmentSystem()
		return @oDevSystem

	# Returns a profile of the machine running this code now, with the role runtime.
	#
	#   returns    a stzSystemProfile
	#   note       it reads the live machine, so its capabilities depend on where it runs
	#   see        DevelopmentSystem
	#@ aka  The live runtime scope -- resolves to wherever this code runs now. Calls the global helper directly: a bare CurrentSystem() here would resolve to THIS method (Ring name resolution) and recurse.
	def CurrentSystem()
		return _StzLiveSystemProfile("runtime")

	# Adds a ready-made part to the solution.
	#
	#   poApp      the stzAppProfile to add
	#   returns    the profile itself, so calls chain
	#   note       AddAppQ is the same call
	#   warning    the profile keeps a copy: change the part through App afterwards, or before
	#              adding
	#   see        WithPart, App
	#@ aka  -- the apps -------------------------------------------
	def AddApp(poApp)
		@aApps + poApp
		return This

		def AddAppQ(poApp)
			This.AddApp(poApp)
			return This

	# Declares a part of the solution of a given kind and the system it deploys to.
	#
	#   pcKind     the kind, such as app, server or superapp, kept in lower case
	#   pcName     the part's name, kept in lower case
	#   pTarget    a deployment token such as :ESP32, or a stzSystemProfile
	#   returns    the profile itself, so calls chain
	#   note       a modelling act only: nothing is built
	#   see        WithApp, WithServer, WithSuperApp, WithParts
	#@ aka  DECLARE a constituent (a part of the solution) of a given kind, named pcName, whose deployment target is pTarget. This is a MODELLING act -- the profile only DESCRIBES the solution. Building and deploying are lifecycle operations on the stzPlatform that OWNS this profile, not on the profile.
	def WithPart(pcKind, pcName, pTarget)
		_oApp_ = new stzAppProfile(pcName)
		_oApp_.SetKind(pcKind)
		_oApp_.To(pTarget)
		This.AddApp(_oApp_)
		return This

	# Declares a part of the kind app and the system it deploys to.
	#
	#   pcName     the part's name
	#   pTarget    the deployment token or system profile
	#   returns    the profile itself, so calls chain
	#   see        WithPart
	def WithApp(pcName, pTarget)
		return This.WithPart("app", pcName, pTarget)

	# Declares a part of the kind server and the system it deploys to.
	#
	#   pcName     the part's name
	#   pTarget    the deployment token or system profile
	#   returns    the profile itself, so calls chain
	#   see        WithPart
	def WithServer(pcName, pTarget)
		return This.WithPart("server", pcName, pTarget)

	# Declares a part of the kind superapp and the system it deploys to.
	#
	#   pcName     the part's name
	#   pTarget    the deployment token or system profile
	#   returns    the profile itself, so calls chain
	#   see        WithPart
	def WithSuperApp(pcName, pTarget)
		return This.WithPart("superapp", pcName, pTarget)

	# Declares several parts at once from a list of triples.
	#
	#   paTriples   a list of [ kind, name, target ] triples
	#   returns     the profile itself, so calls chain
	#   warning     a triple with fewer than three items is skipped without a message
	#   see         WithPart
	#@ aka  Declare several constituents at once: [ [ kind, name, target ], ... ].
	def WithParts(paTriples)
		if isList(paTriples)
			_n_ = len(paTriples)
			for _i_ = 1 to _n_
				if isList(paTriples[_i_]) and len(paTriples[_i_]) >= 3
					This.WithPart(paTriples[_i_][1], paTriples[_i_][2], paTriples[_i_][3])
				ok
			next
		ok
		return This

	# Returns the parts of the solution, in the order declared.
	#
	#   returns    a list of stzAppProfile objects
	#   see        App, NumberOfApps
	def Apps()
		return @aApps

		# Returns the parts of the solution, in the order declared.
		#
		#   returns    a list of stzAppProfile objects
		#   see        Apps
		def Parts()
			return @aApps

	# Returns how many parts the solution declares.
	#
	#   returns    a number
	#   see        Apps, HasApp
	def NumberOfApps()
		return len(@aApps)

		# Returns how many parts the solution declares.
		#
		#   returns    a number
		#   see        NumberOfApps
		def NumberOfParts()
			return len(@aApps)

	# TRUE if a part of that name is declared.
	#
	#   pcName     the part's name, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        App, Apps
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

	# Returns the part of that name, the receiver of a deployment scope.
	#
	#   pcName     the part's name, matched without regard to case
	#   returns    a stzAppProfile
	#   note       call System on the result in a chain: App(:x).System().ReadPin(4)
	#   warning    an unknown name raises an error
	#   see        HasApp, Apps
	#@ aka  A constituent by name -- the receiver of a deployment scope: App(:x).System().
	def App(pcName)
		_i_ = This._IndexOfApp(pcName)
		if _i_ = 0
			StzRaise("No part '" + pcName + "' in platform '" + @cName + "'.")
		ok
		return @aApps[_i_]

		def Part(pcName)
			return This.App(pcName)

	  #-- feature code, authored per part (persisted as PLAIN DATA so it
	  #   survives to deploy-time lowering) -------------------

	# Author a capability-tagged operation for a part's feature code. It is
	# CHECKED against the part's target here (raises on down-constrain), its
	# up-enable status is recorded, and it is persisted as plain data. The
	# rehearsed ones are what the deploy-time lowering bridge turns into real
	# target artifacts.
	def _RecordFeature(pcName, pcCap, pcVerb, paArgs, pcDesc)
		_i_ = This._IndexOfApp(pcName)
		if _i_ = 0
			StzRaise("No part '" + pcName + "' in platform '" + @cName + "'.")
		ok
		_oScope_ = new stzSystemScope(@aApps[_i_].DeploymentSystem())
		_cStatus_ = _oScope_.UseOp(pcCap, pcVerb, paArgs, pcDesc)
		@aFeatureOps + [ StzLower(ring_trim("" + pcName)), pcCap, pcVerb,
				 paArgs, pcDesc, _cStatus_ ]
		return _cStatus_

	# Authors a read of a pin in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pnPin      the pin number
	#   returns    a text: native when the live machine can do it, rehearsed when only the target
	#              can
	#   note       the operation is recorded as plain data and nothing runs
	#   warning    a target without gpio raises an error naming the capability; an unknown part
	#              raises an error
	#   see        WritePinIn, FeatureOpsFor, RehearsedFeatureOpsFor
	def ReadPinIn(pcName, pnPin)
		return This._RecordFeature(pcName, "gpio", "read_pin", [ pnPin ], "read pin " + pnPin)

	# Authors a write of a value to a pin in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pnPin      the pin number
	#   pnVal      the value to write
	#   returns    a text: native or rehearsed
	#   note       recorded as plain data
	#   warning    the same errors as ReadPinIn
	#   see        ReadPinIn, FeatureOpsFor
	def WritePinIn(pcName, pnPin, pnVal)
		return This._RecordFeature(pcName, "gpio", "write_pin", [ pnPin, pnVal ], "write pin " + pnPin + " = " + pnVal)

	# Authors the start of a process in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pcCmd      the command, as text
	#   returns    a text: native or rehearsed
	#   note       recorded as plain data and never run
	#   warning    a target without processes, such as an ESP32, raises an error; an unknown part
	#              raises an error
	#   see        ReadPinIn, FeatureOpsFor
	def SpawnIn(pcName, pcCmd)
		return This._RecordFeature(pcName, "process", "spawn", [ "" + pcCmd ], "spawn '" + pcCmd + "'")

	# Authors the writing of a file in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pcPath     the file path, as text
	#   returns    a text: native or rehearsed
	#   note       recorded as plain data and never run
	#   warning    a target without a filesystem raises an error; an unknown part raises an error
	#   see        ReadPinIn, FeatureOpsFor
	def WriteFileIn(pcName, pcPath)
		return This._RecordFeature(pcName, "filesystem", "write_file", [ "" + pcPath ], "write file '" + pcPath + "'")

	# Authors a network connection in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pcHost     the host to connect to, as text
	#   returns    a text: native or rehearsed
	#   note       recorded as plain data; no connection is made
	#   warning    a target without network raises an error; an unknown part raises an error
	#   see        ReadPinIn, FeatureOpsFor
	def ConnectIn(pcName, pcHost)
		return This._RecordFeature(pcName, "network", "connect", [ "" + pcHost ], "connect to '" + pcHost + "'")

	# Authors the use of any named capability in a part's feature code, checked against that part's target.
	#
	#   pcName     the part to author it in
	#   pcCap      the capability name, such as threads or clock
	#   pcDesc     what it is used for
	#   returns    a text: native or rehearsed
	#   note       the operation is recorded with the verb use
	#   warning    a capability the target lacks raises an error; an unknown part raises an error
	#   see        ReadPinIn, FeatureOpsFor
	def UseIn(pcName, pcCap, pcDesc)
		return This._RecordFeature(pcName, pcCap, "use", [], pcDesc)

	# Returns the feature operations authored for a part.
	#
	#   pcName     the part's name, matched without regard to case
	#   returns    a list of [ capability, verb, arguments, description, status ] rows; [ ] for an
	#              unknown part
	#   see        RehearsedFeatureOpsFor, ReadPinIn
	#@ aka  All feature ops recorded for a part: [ cap, verb, args, desc, status ].
	def FeatureOpsFor(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_a_ = []
		_n_ = len(@aFeatureOps)
		for _i_ = 1 to _n_
			if @aFeatureOps[_i_][1] = _c_
				_a_ + [ @aFeatureOps[_i_][2], @aFeatureOps[_i_][3],
					@aFeatureOps[_i_][4], @aFeatureOps[_i_][5], @aFeatureOps[_i_][6] ]
			ok
		next
		return _a_

	# Returns the operations of a part that only the target can do, the ones a lowering bridge turns into artifacts.
	#
	#   pcName     the part's name
	#   returns    a list of [ capability, verb, arguments, description ] rows
	#   see        FeatureOpsFor, stzLoweringBridge
	#@ aka  The UP-ENABLED (rehearsed) ops for a part -- exactly what the bridge lowers into a target artifact. Each is [ cap, verb, args, desc ].
	def RehearsedFeatureOpsFor(pcName)
		_a_ = []
		_aAll_ = This.FeatureOpsFor(pcName)
		_n_ = len(_aAll_)
		for _i_ = 1 to _n_
			if _aAll_[_i_][5] = "rehearsed"
				_a_ + [ _aAll_[_i_][1], _aAll_[_i_][2], _aAll_[_i_][3], _aAll_[_i_][4] ]
			ok
		next
		return _a_

	# Checks the solution as a whole: a development system, at least one part, and a deployment target for every part.
	#
	#   returns    a list of issue texts; [ ] when sound
	#   see        IsSound
	#@ aka  -- structural validation ------------------------------
	def Validate()
		_a_ = []
		if @oDevSystem = ""
			_a_ + "no development system declared (use DevelopedOn)"
		ok
		_n_ = len(@aApps)
		if _n_ = 0
			_a_ + "the solution deploys no apps"
		ok
		for _i_ = 1 to _n_
			if @aApps[_i_].DeploymentSystem() = ""
				_a_ + ("app '" + @aApps[_i_].Name() + "' has no deployment target")
			ok
		next
		return _a_

	# TRUE if Validate finds no issue.
	#
	#   returns    TRUE or FALSE
	#   see        Validate
	def IsSound()
		return len(This.Validate()) = 0

	# Returns the solution in the .stzplatform text format.
	#
	#   returns    a text: a header line, platform, developed_on and one line "kind: name -> target"
	#              per part
	#   see        Save, FromString
	#@ aka  -- the .stzplatform format ----------------------------
	def ToStzPlatform()
		_nl_ = char(10)
		_c_ = "# .stzplatform -- a Softanza solution profile" + _nl_
		_c_ += "platform: " + @cName + _nl_
		if @oDevSystem != ""
			_c_ += "developed_on: " + @oDevSystem.OSName() + _nl_
		ok
		_n_ = len(@aApps)
		for _i_ = 1 to _n_
			_c_ += @aApps[_i_].Kind() + ": " + @aApps[_i_].Name() + " -> " +
			       @aApps[_i_].DeploymentOSName() + _nl_
		next
		return _c_

	# Writes the .stzplatform text to a file.
	#
	#   pcPath     the file to write
	#   returns    the profile itself, so calls chain
	#   warning    the feature operations are not part of the format and are not saved
	#   see        LoadFrom, ToStzPlatform
	def Save(pcPath)
		_StzWriteTextFile(pcPath, This.ToStzPlatform())
		return This

	# Reads a .stzplatform file into this profile.
	#
	#   pcPath     the file to read
	#   returns    the profile itself, so calls chain
	#   warning    it adds the parts to those already declared
	#   see        FromString, Save
	#@ aka  Read a .stzplatform file INTO this profile (the mirror of Save).
	def LoadFrom(pcPath)
		return This.FromString(_StzReadTextFile(pcPath))

	# Reads .stzplatform text into this profile: the name, the development system and the parts.
	#
	#   pcText     the text to read
	#   returns    the profile itself, so calls chain
	#   warning    it adds the parts to those already declared; comment lines and lines it does not
	#              understand are skipped
	#   see        LoadFrom, ToStzPlatform
	#@ aka  Parse .stzplatform text into this profile.
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
				This.WithPart(_cKey_, _cAppName_, _cTarget_)
			ok
		next
		return This

	# Prints the solution: its name, development system and one line per part.
	#
	#   returns    nothing; it prints
	#   see        ToStzPlatform
	def Show()
		? "Platform: " + @cName
		if @oDevSystem != ""
			? "  developed on: " + @oDevSystem.OSName()
		ok
		_n_ = len(@aApps)
		for _i_ = 1 to _n_
			? "  " + @aApps[_i_].Kind() + " '" + @aApps[_i_].Name() + "' -> " +
			  @aApps[_i_].DeploymentOSName()
		next
