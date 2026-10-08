#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZSYSTEMPROFILE           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The SCOPE-MODEL FLOOR (Phase 1b) of the     #
#                  System Foundation. A stzSystemProfile is a  #
#                  named SCOPE the programmer writes system    #
#                  code in -- one system, as a facet bundle    #
#                  (OS / Runtime / Capabilities / Resources).  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Part of the Softanza System Foundation
# (base/doc/design/SOFTANZA_SYSTEM_FOUNDATION.md, section 2 -- the programmer's
# model). Three roles, three scopes, never confused:
#
#   DevelopmentSystem() -- role "development" -- the dev machine, read LIVE.
#   CurrentSystem()     -- role "runtime"     -- wherever this code runs NOW
#                          (== the dev machine during development; on a
#                          deployed app it is the deployment system).
#   a declared profile  -- role "deployment"  -- a target the dev box is NOT,
#                          built with DeclareSystem() or read from a .stzsystem
#                          file. Its facts are STORED VALUES, never read from
#                          the live machine -- an Android profile answers
#                          "android" on a Windows box.
#
# THE KEYSTONE is stzSystemCapabilities -- the capability envelope. It is the
# SAME construct as the agentic capability lattice (base/agentic/stzAgentGraph):
# every concrete system capability is classified into one of the abstract kinds
# effectful / sensing / compute / inference. That shared vocabulary is what lets
# BOTH "what does the target forbid / require vs my machine" (the two worlds,
# section 2.4) AND "which of this system's capabilities may an actor of these
# kinds exercise" (the system <-> agent bridge) be answered by ONE lattice --
# the unification the reactive + system + agentic review converged on.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSystemProfileQ()
	return new stzSystemProfile("")

func StzSystemCapabilitiesQ()
	return new stzSystemCapabilities([])

# The two LIVE scopes are objects you instantiate: `new stzDevSystem()` and
# `new stzCurrentSystem()` (defined below). These resolver globals are thin
# sugar over them -- handy when you want the answer inline rather than a held
# object.

# The DEVELOPMENT scope: the machine the architect codes on, read live.
func DevelopmentSystem()
	return new stzDevSystem()

	func DevSystem()
		return new stzDevSystem()

# The RUNTIME-CURRENT scope: whatever system this code runs on right now. During
# development it is the dev machine; after deployment it is the target -- so it
# always agrees, by construction, with the profile the code was written against.
func CurrentSystem()
	return new stzCurrentSystem()

	func RuntimeSystem()
		return new stzCurrentSystem()

# Start a DEPLOYMENT scope for a target the dev machine is not. Fill it with the
# fluent setters, or read one from a .stzsystem file.
func DeclareSystem(pcName)
	_oP_ = new stzSystemProfile(pcName)
	_oP_.SetRole("deployment")
	return _oP_

# --- private helpers (file scope, so no class-scope builtin traps) ---

# Fill a system profile with the LIVE facts of the machine this code runs on.
func _StzPopulateLive(poProfile, pcRole)
	_oOS_ = new stzOperatingSystem()
	_oEnv_ = new stzEnvironment()
	poProfile.SetRole(pcRole)
	poProfile.SetOSName(_oOS_.Name())
	poProfile.SetArchitecture(_oOS_.Architecture())
	poProfile.SetBitSize(_oOS_.BitSize())
	poProfile.SetEndianness(_oOS_.Endianness())
	poProfile.SetCpuCount(_oEnv_.CpuCount())
	# The engine senses (perf P1): physical memory facts, live.
	poProfile.SetMemTotalBytes(StzEnginePerfSysMemTotal())
	poProfile.SetMemFreeBytes(StzEnginePerfSysMemFree())
	poProfile.SetLanguageVersion(_StzHostLangVersion())
	poProfile.SetCapabilityList(_StzDefaultCapsForClass(_StzSystemClassOf(_oOS_.Name())))

func _StzLiveSystemProfile(pcRole)
	_oP_ = new stzSystemProfile("this-machine")
	_StzPopulateLive(_oP_, pcRole)
	return _oP_

func _StzHostLangVersion()
	return version()

func _StzSystemClassOf(pcOS)
	_c_ = StzLower(ring_trim("" + pcOS))
	if _c_ = "windows" or _c_ = "linux" or _c_ = "macos" or
	   _c_ = "freebsd" or _c_ = "unix" or _c_ = "msdos"
		return "desktop"
	but _c_ = "android" or _c_ = "ios"
		return "mobile"
	but _c_ = "rtos" or _c_ = "freertos" or _c_ = "bare" or
	   _c_ = "espidf" or _c_ = "zephyr"
		return "embedded"
	else
		return "unknown"
	ok

func _StzDefaultCapsForClass(pcClass)
	_c_ = StzLower(ring_trim("" + pcClass))
	if _c_ = "desktop"
		return [ "filesystem", "process", "network", "environment",
			 "dynamic_load", "threads", "clock" ]
	but _c_ = "mobile"
		return [ "filesystem", "network", "threads", "clock" ]
	but _c_ = "embedded"
		return [ "gpio", "clock" ]
	else
		return [ "clock" ]
	ok

func _StzParseCapList(pcVal)
	_a_ = []
	_aParts_ = StzSplit(pcVal, ",")
	_nParts_ = len(_aParts_)
	for _i_ = 1 to _nParts_
		_c_ = StzLower(ring_trim(_aParts_[_i_]))
		if _c_ != ""
			_a_ + _c_
		ok
	next
	return _a_

func _StzJoinComma(paList)
	_c_ = ""
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += "" + paList[_i_]
	next
	return _c_

func _StzWriteTextFile(pcPath, pcContent)
	write(pcPath, pcContent)

func _StzReadTextFile(pcPath)
	return read(pcPath)


  #=========================#
 #  STZSYSTEMCAPABILITIES  #
#=========================#
#
# The capability ENVELOPE: a closed, named set of concrete system capabilities,
# each classified into an abstract lattice kind shared with stzAgentGraph. The
# closed set IS the M2 discipline of Scope-Oriented Programming -- granting an
# unknown capability is refused.

class stzSystemCapabilities from stzObject

	@aCaps = []

	def init(paInit)
		This.SetList(paInit)

	# The closed catalog: concrete capability -> abstract lattice kind.
	def Catalog()
		return [
			[ "filesystem",   "effectful" ],
			[ "process",      "effectful" ],
			[ "network",      "effectful" ],
			[ "environment",  "effectful" ],
			[ "dynamic_load", "effectful" ],
			[ "gpio",         "effectful" ],
			[ "threads",      "compute"   ],
			[ "clock",        "sensing"   ],
			[ "inference",    "inference" ]
		]

	def KnownCapabilities()
		_a_ = []
		_aCat_ = This.Catalog()
		_n_ = len(_aCat_)
		for _i_ = 1 to _n_
			_a_ + _aCat_[_i_][1]
		next
		return _a_

	def IsKnown(pCap)
		return This._InList(This._Norm(pCap), This.KnownCapabilities()) > 0

	def SetList(paCaps)
		@aCaps = []
		if isList(paCaps)
			_n_ = len(paCaps)
			for _i_ = 1 to _n_
				This.Grant(paCaps[_i_])
			next
		ok
		return This

	# EFFECTFUL on the envelope (a builder verb). Refuses an unknown capability
	# -- the closed set is the contract.
	def Grant(pCap)
		_c_ = This._Norm(pCap)
		if NOT This.IsKnown(_c_)
			StzRaise("Unknown system capability: '" + _c_ +
				 "'. Known: " + _StzJoinComma(This.KnownCapabilities()))
		ok
		if This._InList(_c_, @aCaps) = 0
			@aCaps + _c_
		ok
		return This

		def GrantQ(pCap)
			This.Grant(pCap)
			return This

	def Revoke(pCap)
		_c_ = This._Norm(pCap)
		_aNew_ = []
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			if @aCaps[_i_] != _c_
				_aNew_ + @aCaps[_i_]
			ok
		next
		@aCaps = _aNew_
		return This

	def Can(pCap)
		return This._InList(This._Norm(pCap), @aCaps) > 0

		def Has(pCap)
			return This.Can(pCap)

		def Supports(pCap)
			return This.Can(pCap)

	def Lacks(pCap)
		return NOT This.Can(pCap)

		def Cannot(pCap)
			return This.Lacks(pCap)

	def List()
		return @aCaps

	def NumberOfCapabilities()
		return len(@aCaps)

		def Count()
			return This.NumberOfCapabilities()

	# The abstract lattice kind (effectful / sensing / compute / inference) of a
	# concrete capability -- the word stzAgentGraph speaks.
	def KindOf(pCap)
		_c_ = This._Norm(pCap)
		_aCat_ = This.Catalog()
		_n_ = len(_aCat_)
		for _i_ = 1 to _n_
			if _aCat_[_i_][1] = _c_
				return _aCat_[_i_][2]
			ok
		next
		return "unknown"

	# The distinct kinds this envelope spans -- its "authority shape".
	def Kinds()
		_a_ = []
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			_k_ = This.KindOf(@aCaps[_i_])
			if This._InList(_k_, _a_) = 0
				_a_ + _k_
			ok
		next
		return _a_

	def IsEffectful()
		return This._InList("effectful", This.Kinds()) > 0

	# Capabilities in THIS envelope that are NOT in the other.
	def Minus(poOther)
		_a_ = []
		_aOther_ = poOther.List()
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			if This._InList(@aCaps[_i_], _aOther_) = 0
				_a_ + @aCaps[_i_]
			ok
		next
		return _a_

	# The subset of THESE capabilities an actor holding paActorKinds may
	# exercise -- the system-envelope <-> agentic-authority bridge. An LLM actor
	# (kinds = [ "inference" ]) may exercise NO effectful/sensing capability:
	# the empty effect set, realised against a system.
	def ForActorKinds(paActorKinds)
		_a_ = []
		_n_ = len(@aCaps)
		for _i_ = 1 to _n_
			_k_ = This.KindOf(@aCaps[_i_])
			if This._InList(_k_, paActorKinds) > 0
				_a_ + @aCaps[_i_]
			ok
		next
		return _a_

	def _Norm(pCap)
		return StzLower(ring_trim("" + pCap))

	def _InList(pItem, paList)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pItem
				return _i_
			ok
		next
		return 0

	def Show()
		? "Capabilities (" + This.NumberOfCapabilities() + "): " + _StzJoinComma(@aCaps)
		? "  kinds: " + _StzJoinComma(This.Kinds())


  #====================#
 #  STZSYSTEMPROFILE  #
#====================#

# Describes one system as a bundle of facts: its operating system, runtime, resources and capabilities.
#
# A profile is a named scope the code is written against. A live one (stzDevSystem,
# stzCurrentSystem) is filled from the machine; a declared one, made with DeclareSystem, holds only
# the values it was given, so a profile for Android answers android on a Windows machine. The
# capabilities are drawn from a closed list, and Forbids, Requires and CompareTo set a target
# against this system. A profile is saved to and read from a .stzsystem text file.
#
#   receiver   o1 = new stzSystemProfile("phone")
#   example    o1.SetOSName("android")
#              ? o1.SystemClass()
#              #--> mobile
#              o1.SetCapabilityList([ "filesystem", "network", "clock" ])
#              ? o1.Can("network")
#              #--> 1
#              ? @@( o1.CapabilityKinds() )
#              #--> [ "effectful", "sensing" ]
#   see        DeclareSystem, stzDevSystem, stzCurrentSystem, stzOperatingSystem
class stzSystemProfile from stzObject

	@cName = ""
	@cRole = "declared"
	@cOSName = "unknown"
	@cArch = "unknown"
	@nBits = 0
	@cEndianness = "unknown"
	@nCpuCount = 0
	@nMemTotalBytes = 0	# 0 = not populated (declared profile); live = engine fact
	@nMemFreeBytes = 0	# snapshot at populate time, not a live gauge
	@cLangVersion = ""
	@oCaps = ""

	# Builds a profile with a name and nothing else known: role declared, operating system, architecture and byte order unknown, no capability.
	#
	#   pcName     the profile's name, as text
	#   returns    nothing; the object is built
	#   see        DeclareSystem, SetOSName, SetCapabilityList
	def init(pcName)
		if isString(pcName)
			@cName = pcName
		ok
		@oCaps = new stzSystemCapabilities([])

	# Returns the name this profile carries, such as "this-machine" or the name of a target.
	#
	#   returns    a text
	#   see        SetName, Role
	#@ aka  -- identity / role ------------------------------------
	def Name()
		return @cName

	# Sets the profile's name.
	#
	#   pcName     the new name
	#   returns    the profile itself, so calls chain
	#   see        Name
	def SetName(pcName)
		@cName = "" + pcName
		return This

	# Returns the role of this scope: development, runtime, deployment, or declared when none was set.
	#
	#   returns    a text
	#   see        SetRole, IsDeclared
	def Role()
		return @cRole

	# Sets the role of this scope, trimmed and put in lower case.
	#
	#   pcRole     the role word, usually development, runtime or deployment
	#   returns    the profile itself, so calls chain
	#   note       any word is accepted; only development and runtime make a profile live
	#   see        Role, IsLive
	def SetRole(pcRole)
		@cRole = StzLower(ring_trim("" + pcRole))
		return This

	# TRUE if the role is development, the machine the code is written on.
	#
	#   returns    TRUE or FALSE
	#   see        IsRuntime, IsDeployment, Role
	def IsDevelopment()
		return @cRole = "development"

	# TRUE if the role is runtime, the machine the code runs on now.
	#
	#   returns    TRUE or FALSE
	#   see        IsDevelopment, Role
	def IsRuntime()
		return @cRole = "runtime"

	# TRUE if the role is deployment, a target the dev machine is not.
	#
	#   returns    TRUE or FALSE
	#   see        IsDeclared, Role
	def IsDeployment()
		return @cRole = "deployment"

	# TRUE if the profile is a declared target and not a live reading of this machine.
	#
	#   returns    TRUE or FALSE
	#   note       a profile with the default role declared is declared too; only development and
	#              runtime are live
	#   see        IsLive, IsDeployment
	#@ aka  A declared profile is any scope that is NOT the live machine.
	def IsDeclared()
		return NOT (This.IsDevelopment() or This.IsRuntime())

	# TRUE if the role is development or runtime, so the facts came from this machine.
	#
	#   returns    TRUE or FALSE
	#   note       the role is a label: setting it to development on a hand-filled profile makes it
	#              answer TRUE
	#   see        IsDeclared, Role
	def IsLive()
		return This.IsDevelopment() or This.IsRuntime()

	# Returns the stored operating system name, in lower case; unknown until set.
	#
	#   returns    a text such as "windows" or "android"
	#   note       OperatingSystem and OS are the same call; a declared profile never reads the live
	#              machine
	#   see        SetOSName, SystemClass
	#@ aka  -- OS facet (STORED values -- a declared target never leaks its facts from the live machine) --------------------
	def OSName()
		return @cOSName

		# Returns the stored operating system name, in lower case; unknown until set.
		#
		#   returns    a text such as "windows" or "android"
		#   see        OSName, SystemClass
		def OperatingSystem()
			return @cOSName

		# Returns the stored operating system name, in lower case; unknown until set.
		#
		#   returns    a text such as "windows" or "android"
		#   see        OSName, SystemClass
		def OS()
			return @cOSName

	# Stores the operating system name, trimmed and put in lower case.
	#
	#   pc         the operating system name, such as windows, linux, macos, android
	#   returns    the profile itself, so calls chain
	#   note       the name decides SystemClass and the IsWindows family
	#   see        OSName, SystemClass
	def SetOSName(pc)
		@cOSName = StzLower(ring_trim("" + pc))
		return This

	# Returns the stored processor family, in lower case; unknown until set.
	#
	#   returns    a text such as "x64" or "arm64"
	#   note       Arch is the same call
	#   see        SetArchitecture, BitSize
	def Architecture()
		return @cArch

		# Returns the stored processor family, in lower case; unknown until set.
		#
		#   returns    a text such as "x64" or "arm64"
		#   see        Architecture, BitSize
		def Arch()
			return @cArch

	# Stores the processor family, trimmed and put in lower case.
	#
	#   pc         the architecture, such as x64 or arm64
	#   returns    the profile itself, so calls chain
	#   see        Architecture
	def SetArchitecture(pc)
		@cArch = StzLower(ring_trim("" + pc))
		return This

	# Returns the stored word width, in bits; 0 until set.
	#
	#   returns    a number such as 32 or 64
	#   note       Bits is the same call
	#   see        SetBitSize, AddressBits
	def BitSize()
		return @nBits

		# Returns the stored word width, in bits; 0 until set.
		#
		#   returns    a number such as 32 or 64
		#   see        BitSize, AddressBits
		def Bits()
			return @nBits

	# Stores the word width, in bits.
	#
	#   pn         the width in bits, such as 32 or 64
	#   returns    the profile itself, so calls chain
	#   see        BitSize, Is64Bit
	def SetBitSize(pn)
		@nBits = pn
		return This

	# Returns the stored byte order; unknown until set.
	#
	#   returns    a text, usually "little" or "big"
	#   see        SetEndianness
	def Endianness()
		return @cEndianness

	# Stores the byte order, trimmed and put in lower case.
	#
	#   pc         the byte order, little or big
	#   returns    the profile itself, so calls chain
	#   see        Endianness
	def SetEndianness(pc)
		@cEndianness = StzLower(ring_trim("" + pc))
		return This

	def Is64Bit()
		return @nBits = 64

	def Is32Bit()
		return @nBits = 32

	# Returns the class of the stored operating system: desktop, mobile, embedded or unknown.
	#
	#   returns    a text
	#   note       windows, linux, macos, freebsd, unix and msdos are desktop; android and ios
	#              mobile; rtos, freertos, bare, espidf and zephyr embedded
	#   see        IsDesktop, IsMobile, IsEmbedded
	#@ aka  -- OS class (from the STORED os name) ------------------
	def SystemClass()
		return _StzSystemClassOf(@cOSName)

	# TRUE if the stored operating system is a desktop one.
	#
	#   returns    TRUE or FALSE
	#   see        SystemClass, IsMobile
	def IsDesktop()
		return This.SystemClass() = "desktop"

	# TRUE if the stored operating system is a mobile one.
	#
	#   returns    TRUE or FALSE
	#   see        SystemClass, IsDesktop
	def IsMobile()
		return This.SystemClass() = "mobile"

	# TRUE if the stored operating system is an embedded one.
	#
	#   returns    TRUE or FALSE
	#   see        SystemClass, IsDesktop
	def IsEmbedded()
		return This.SystemClass() = "embedded"

	# TRUE if the stored operating system name is windows.
	#
	#   returns    TRUE or FALSE
	#   see        OSName, IsLinux
	def IsWindows()
		return @cOSName = "windows"

	# TRUE if the stored operating system name is linux.
	#
	#   returns    TRUE or FALSE
	#   see        OSName, IsWindows
	def IsLinux()
		return @cOSName = "linux"

	# TRUE if the stored operating system name is macos.
	#
	#   returns    TRUE or FALSE
	#   see        OSName, IsWindows
	def IsMacOS()
		return @cOSName = "macos"

	# TRUE if the stored operating system name is android.
	#
	#   returns    TRUE or FALSE
	#   see        OSName, IsMobile
	def IsAndroid()
		return @cOSName = "android"

	# Returns the language the code runs in, which is always "ring".
	#
	#   returns    a text, "ring"
	#   see        LanguageVersion, Runtime
	#@ aka  -- Runtime facet --------------------------------------
	def Language()
		return "ring"

	# Returns the stored version of the language; an empty text until set.
	#
	#   returns    a text such as "1.27"
	#   see        SetLanguageVersion, Runtime
	def LanguageVersion()
		return @cLangVersion

	# Stores the language version.
	#
	#   pc         the version, as text
	#   returns    the profile itself, so calls chain
	#   see        LanguageVersion
	def SetLanguageVersion(pc)
		@cLangVersion = "" + pc
		return This

	# Returns the runtime facts together: language, its version, architecture, bits, byte order and operating system.
	#
	#   returns    a list of [ key, value ] pairs
	#   see        Language, Resources
	def Runtime()
		return [
			[ "language", "ring" ],
			[ "language_version", @cLangVersion ],
			[ "architecture", @cArch ],
			[ "bits", @nBits ],
			[ "endianness", @cEndianness ],
			[ "os", @cOSName ]
		]

	# Returns the stored number of processors; 0 until set.
	#
	#   returns    a number
	#   see        SetCpuCount, Resources
	#@ aka  -- Resources facet ------------------------------------
	def CpuCount()
		return @nCpuCount

	# Stores the number of processors.
	#
	#   pn         the number of processors
	#   returns    the profile itself, so calls chain
	#   see        CpuCount
	def SetCpuCount(pn)
		@nCpuCount = pn
		return This

	# Returns the width of an address in bits, which is the stored word width.
	#
	#   returns    a number such as 32 or 64
	#   see        BitSize, Resources
	#@ aka  The maximum address width -- a real resource ceiling.
	def AddressBits()
		return @nBits

	# Returns the stored total memory, in bytes; 0 for a declared profile.
	#
	#   returns    a number
	#   see        SetMemTotalBytes, MemFreeBytes
	def MemTotalBytes()
		return @nMemTotalBytes

	# Stores the total memory.
	#
	#   pn         the total memory, in bytes
	#   returns    the profile itself, so calls chain
	#   see        MemTotalBytes
	def SetMemTotalBytes(pn)
		@nMemTotalBytes = pn
		return This

	# Returns the free memory stored when the profile was filled, in bytes.
	#
	#   returns    a number
	#   note       a snapshot taken at that moment, not a live gauge; 0 for a declared profile
	#   see        SetMemFreeBytes, MemTotalBytes
	def MemFreeBytes()
		return @nMemFreeBytes

	# Stores the free memory.
	#
	#   pn         the free memory, in bytes
	#   returns    the profile itself, so calls chain
	#   see        MemFreeBytes
	def SetMemFreeBytes(pn)
		@nMemFreeBytes = pn
		return This

	# Returns the resource facts together: processors, address width, total memory and free memory.
	#
	#   returns    a list of [ key, value ] pairs: cpu_count, address_bits, mem_total, mem_free
	#   see        CpuCount, MemTotalBytes
	def Resources()
		# memory arrived with the perf P1 engine senses (stz_perf.dll,
		# SOFTANZA_PERF_SYSTEM.md): populated for LIVE profiles
		# (DevelopmentSystem/CurrentSystem); 0 on a declared target, where
		# the machine has not been observed. mem_free is a snapshot taken
		# at populate time, not a live gauge -- sample StzEnginePerfSysMemFree()
		# for the moving value.
		return [
			[ "cpu_count", @nCpuCount ],
			[ "address_bits", @nBits ],
			[ "mem_total", @nMemTotalBytes ],
			[ "mem_free", @nMemFreeBytes ]
		]

	# Returns the capabilities this system offers, as a plain list.
	#
	#   returns    a list of text; empty until some are set or granted
	#   note       CapabilityList is the same call; CapabilitiesQ answers the chainable envelope
	#   see        CapabilityList, Can, Grant
	#@ aka  -- Capabilities facet (the KEYSTONE) ------------------
	def Capabilities()
		return @oCaps.List()

		# Returns the capabilities this system offers, as a plain list.
		#
		#   returns    a list of text; empty until some are set or granted
		#   see        Capabilities, SetCapabilityList
		def CapabilityList()
			return @oCaps.List()

	# The capability ENVELOPE as a chainable object (Q-convention).
	def CapabilitiesQ()
		return @oCaps

	# Replaces all the capabilities with the given list.
	#
	#   paCaps     a list of capability names such as filesystem, network, clock
	#   returns    the profile itself, so calls chain
	#   note       an unknown capability raises an error naming the known ones, and the profile then
	#              keeps its previous list; names are lower-cased and a repeated name is kept once
	#   warning    an unknown capability raises an error naming the known ones, but the list is then
	#              left holding the names before the unknown one (the previous list is lost, tried
	#              with [ network, foo, clock ] and with [ gpio, teleport ]); names are lower-cased
	#              and a repeated name is kept once
	#   see        Grant, Capabilities
	def SetCapabilityList(paCaps)
		@oCaps = new stzSystemCapabilities(paCaps)
		return This

	# Adds one capability to the system.
	#
	#   pCap       the capability name, such as network
	#   returns    the profile itself, so calls chain
	#   note       an unknown capability raises an error naming the known ones: filesystem, process,
	#              network, environment, dynamic_load, gpio, threads, clock, inference; granting it
	#              twice changes nothing
	#   see        Revoke, Can
	def Grant(pCap)
		@oCaps.Grant(pCap)
		return This

		def GrantQ(pCap)
			This.Grant(pCap)
			return This

	# Removes one capability from the system; one it does not have changes nothing.
	#
	#   pCap       the capability name to remove
	#   returns    the profile itself, so calls chain
	#   see        Grant, Lacks
	def Revoke(pCap)
		@oCaps.Revoke(pCap)
		return This

	# TRUE if the system offers the capability.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   see        Lacks, Grant
	def Can(pCap)
		return @oCaps.Can(pCap)

	# TRUE if the system does not offer the capability.
	#
	#   pCap       the capability name
	#   returns    TRUE or FALSE
	#   see        Can, Revoke
	def Lacks(pCap)
		return @oCaps.Lacks(pCap)

	# Returns the kinds of authority the capabilities span: effectful, sensing, compute or inference.
	#
	#   returns    a list of text, each kind once
	#   note       filesystem, process, network, environment, dynamic_load and gpio are effectful;
	#              threads is compute; clock is sensing
	#   see        Capabilities, CapabilitiesForActorKinds
	def CapabilityKinds()
		return @oCaps.Kinds()

	# Returns the capabilities this system has that a target lacks: code that runs here but that the target forbids.
	#
	#   poTarget   the other profile, usually a declared target
	#   returns    a list of capability names
	#   see        Requires, CompareTo
	#@ aka  -- the TWO WORLDS (section 2.4): THIS (host/dev) vs a target
	def Forbids(poTarget)
		return @oCaps.Minus(poTarget.CapabilitiesQ())

	# Returns the capabilities a target has that this system lacks: what the target needs and this machine cannot do.
	#
	#   poTarget   the other profile, usually a declared target
	#   returns    a list of capability names
	#   see        Forbids, CompareTo
	#@ aka  Capabilities the TARGET has that THIS scope lacks -- what the target REQUIRES that this machine cannot do (up-enable candidates; the Virtual System twin rehearses these later).
	def Requires(poTarget)
		return poTarget.CapabilitiesQ().Minus(@oCaps)

	# Returns what a target forbids and requires, compared with this system, in one list.
	#
	#   poTarget   the other profile, usually a declared target
	#   returns    a list of two pairs: [ "forbids", list ] then [ "requires", list ]
	#   see        Forbids, Requires
	def CompareTo(poTarget)
		return [
			[ "forbids", This.Forbids(poTarget) ],
			[ "requires", This.Requires(poTarget) ]
		]

	# Returns the capabilities an actor holding the given kinds of authority may use.
	#
	#   paActorKinds   a list of kinds, such as [ "sensing", "compute" ]
	#   returns        a list of capability names; empty when no capability has a kind the actor
	#                  holds
	#   see            CapabilityKinds, Can
	#@ aka  -- the system <-> agent bridge ------------------------
	def CapabilitiesForActorKinds(paActorKinds)
		return @oCaps.ForActorKinds(paActorKinds)

	# Returns the profile as the text of a .stzsystem file: one key and value per line.
	#
	#   returns    a text with name, role, os, arch, bits, endianness, cpu_count, memory,
	#              language_version and capabilities lines
	#   note       the free memory line carries a comment saying it is a snapshot
	#   see        Save, FromString
	#@ aka  -- the .stzsystem format (Law 1: a domain has a format)
	def ToStzSystem()
		_nl_ = char(10)
		_c_ = "# .stzsystem -- a Softanza system profile" + _nl_
		_c_ += "name: " + @cName + _nl_
		_c_ += "role: " + @cRole + _nl_
		_c_ += "os: " + @cOSName + _nl_
		_c_ += "arch: " + @cArch + _nl_
		_c_ += "bits: " + @nBits + _nl_
		_c_ += "endianness: " + @cEndianness + _nl_
		_c_ += "cpu_count: " + @nCpuCount + _nl_

		# MEMORY BELONGS IN THE FORMAT TOO. _StzPopulateLive() observes cpu count,
		# memory and language version the same way and by the same call; the format
		# carried the first and the third and dropped the second, so a profile saved
		# from a live system came back claiming a machine with no memory at all.
		#
		# mem_free is a SNAPSHOT taken when the profile was populated, not a live
		# gauge -- it is written because Resources() presents it beside mem_total
		# and a reader who gets one without the other cannot tell which. The note
		# below travels with it; FromString() skips comment lines.
		_c_ += "# mem_free is a snapshot from when this profile was taken" + _nl_
		_c_ += "mem_total: " + @nMemTotalBytes + _nl_
		_c_ += "mem_free: " + @nMemFreeBytes + _nl_

		_c_ += "language_version: " + @cLangVersion + _nl_
		_c_ += "capabilities: " + _StzJoinComma(@oCaps.List()) + _nl_
		return _c_

	# Writes the profile to a file in the .stzsystem format, replacing the file.
	#
	#   pcPath     the file to write
	#   returns    the profile itself, so calls chain
	#   note       SaveQ is the same call
	#   see        LoadFrom, ToStzSystem
	def Save(pcPath)
		_StzWriteTextFile(pcPath, This.ToStzSystem())
		return This

		def SaveQ(pcPath)
			This.Save(pcPath)
			return This

	# Reads a .stzsystem file into this profile, replacing the facts the file names.
	#
	#   pcPath     the .stzsystem file to read
	#   returns    the profile itself, so calls chain
	#   note       the role becomes deployment unless the file names one
	#   see        FromString, Save
	#@ aka  Read a .stzsystem file INTO this profile (the mirror of Save).
	def LoadFrom(pcPath)
		return This.FromString(_StzReadTextFile(pcPath))

	# Reads .stzsystem text into this profile, setting each fact a line names; the role defaults to deployment.
	#
	#   pcText     the .stzsystem text, one key: value per line
	#   returns    the profile itself, so calls chain
	#   note       facts the text does not name keep their value
	#   warning    an unknown capability in the capabilities line raises an error, and the
	#              capabilities are then left holding the names before it; without a capabilities
	#              line, the capabilities become the default of the system class
	#   see        LoadFrom, ToStzSystem
	#@ aka  Parse .stzsystem text into this profile. Defaults the role to deployment (a declared target) unless the text says otherwise, and fills class-default capabilities when no capabilities line is present.
	def FromString(pcText)
		This.SetRole("deployment")
		_cText_ = StzReplace(pcText, char(13), "")
		_aLines_ = StzSplit(_cText_, char(10))
		_bCapsSet_ = 0
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
			if _cKey_ = "name"
				This.SetName(_cVal_)
			but _cKey_ = "role"
				This.SetRole(_cVal_)
			but _cKey_ = "os"
				This.SetOSName(_cVal_)
			but _cKey_ = "arch"
				This.SetArchitecture(_cVal_)
			but _cKey_ = "bits"
				This.SetBitSize(number(_cVal_))
			but _cKey_ = "endianness"
				This.SetEndianness(_cVal_)
			but _cKey_ = "cpu_count"
				This.SetCpuCount(number(_cVal_))
			but _cKey_ = "mem_total"
				This.SetMemTotalBytes(number(_cVal_))
			but _cKey_ = "mem_free"
				This.SetMemFreeBytes(number(_cVal_))
			but _cKey_ = "language_version"
				This.SetLanguageVersion(_cVal_)
			but _cKey_ = "capabilities"
				This.SetCapabilityList(_StzParseCapList(_cVal_))
				_bCapsSet_ = 1
			ok
		next
		if NOT _bCapsSet_
			This.SetCapabilityList(_StzDefaultCapsForClass(_StzSystemClassOf(This.OSName())))
		ok
		return This

	# Returns the profile's main facts as a list of [ key, value ] pairs.
	#
	#   returns    a list of pairs: name, role, os, arch, bits, endianness, cpu_count, class,
	#              capabilities
	#   note       the memory and the language version are not in it; Resources and Runtime carry
	#              them
	#   see        Show, Resources
	#@ aka  -- info / show ----------------------------------------
	def Info()
		return [
			[ "name", @cName ],
			[ "role", @cRole ],
			[ "os", @cOSName ],
			[ "arch", @cArch ],
			[ "bits", @nBits ],
			[ "endianness", @cEndianness ],
			[ "cpu_count", @nCpuCount ],
			[ "class", This.SystemClass() ],
			[ "capabilities", @oCaps.List() ]
		]

	# Prints the profile on five lines: name and role, system, processors, capabilities and their kinds.
	#
	#   returns    nothing; it prints
	#   see        Info
	def Show()
		? "System Profile: " + @cName + "  [role: " + @cRole + "]"
		? "  os:    " + @cOSName + " (" + This.SystemClass() + "), " +
		  @cArch + ", " + @nBits + "-bit, " + @cEndianness
		? "  cpu:   " + @nCpuCount
		? "  caps:  " + _StzJoinComma(@oCaps.List())
		? "  kinds: " + _StzJoinComma(@oCaps.Kinds())


  #=================#
 #  STZDEVSYSTEM   #
#=================#
#
# The DEVELOPMENT system as a first-class object: the machine the architect codes
# on, read LIVE from the engine at construction. It IS a system profile (role
# "development"), so it answers every stzSystemProfile question -- OSName(),
# Architecture(), Capabilities(), Can(), Lacks(), ... :
#
#   o1 = new stzDevSystem()
#   ? @@( o1.Capabilities() )
#   #--> [ "filesystem", "process", "network", "environment", "dynamic_load", "threads", "clock" ]

class stzDevSystem from stzSystemProfile

	def init()
		This.SetName("this-machine")
		_StzPopulateLive(This, "development")


  #=====================#
 #  STZCURRENTSYSTEM   #
#=====================#
#
# The RUNTIME-CURRENT system as a first-class object: whatever machine this code
# runs on right now, read LIVE. During development it is the dev machine; on a
# deployed app it is the deployment system -- and it agrees, by construction,
# with the scope the code was written against.

class stzCurrentSystem from stzSystemProfile

	def init()
		This.SetName("this-machine")
		_StzPopulateLive(This, "runtime")
