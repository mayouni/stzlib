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

class stzSystemProfile from stzObject

	@cName = ""
	@cRole = "declared"
	@cOSName = "unknown"
	@cArch = "unknown"
	@nBits = 0
	@cEndianness = "unknown"
	@nCpuCount = 0
	@cLangVersion = ""
	@oCaps = NULL

	def init(pcName)
		if isString(pcName)
			@cName = pcName
		ok
		@oCaps = new stzSystemCapabilities([])

	  #-- identity / role ------------------------------------

	def Name()
		return @cName

	def SetName(pcName)
		@cName = "" + pcName
		return This

	def Role()
		return @cRole

	def SetRole(pcRole)
		@cRole = StzLower(ring_trim("" + pcRole))
		return This

	def IsDevelopment()
		return @cRole = "development"

	def IsRuntime()
		return @cRole = "runtime"

	def IsDeployment()
		return @cRole = "deployment"

	# A declared profile is any scope that is NOT the live machine.
	def IsDeclared()
		return NOT (This.IsDevelopment() or This.IsRuntime())

	def IsLive()
		return This.IsDevelopment() or This.IsRuntime()

	  #-- OS facet (STORED values -- a declared target never leaks
	  #   its facts from the live machine) --------------------

	def OSName()
		return @cOSName

		def OperatingSystem()
			return @cOSName

		def OS()
			return @cOSName

	def SetOSName(pc)
		@cOSName = StzLower(ring_trim("" + pc))
		return This

	def Architecture()
		return @cArch

		def Arch()
			return @cArch

	def SetArchitecture(pc)
		@cArch = StzLower(ring_trim("" + pc))
		return This

	def BitSize()
		return @nBits

		def Bits()
			return @nBits

	def SetBitSize(pn)
		@nBits = pn
		return This

	def Endianness()
		return @cEndianness

	def SetEndianness(pc)
		@cEndianness = StzLower(ring_trim("" + pc))
		return This

	def Is64Bit()
		return @nBits = 64

	def Is32Bit()
		return @nBits = 32

	  #-- OS class (from the STORED os name) ------------------

	def SystemClass()
		return _StzSystemClassOf(@cOSName)

	def IsDesktop()
		return This.SystemClass() = "desktop"

	def IsMobile()
		return This.SystemClass() = "mobile"

	def IsEmbedded()
		return This.SystemClass() = "embedded"

	def IsWindows()
		return @cOSName = "windows"

	def IsLinux()
		return @cOSName = "linux"

	def IsMacOS()
		return @cOSName = "macos"

	def IsAndroid()
		return @cOSName = "android"

	  #-- Runtime facet --------------------------------------

	def Language()
		return "ring"

	def LanguageVersion()
		return @cLangVersion

	def SetLanguageVersion(pc)
		@cLangVersion = "" + pc
		return This

	def Runtime()
		return [
			[ "language", "ring" ],
			[ "language_version", @cLangVersion ],
			[ "architecture", @cArch ],
			[ "bits", @nBits ],
			[ "endianness", @cEndianness ],
			[ "os", @cOSName ]
		]

	  #-- Resources facet ------------------------------------

	def CpuCount()
		return @nCpuCount

	def SetCpuCount(pn)
		@nCpuCount = pn
		return This

	# The maximum address width -- a real resource ceiling.
	def AddressBits()
		return @nBits

	def Resources()
		# memory (mem_total / mem_free) is a PLANNED engine add
		# (SOFTANZA_SYSTEM_FOUNDATION.md section 4.2); cpu + address width are
		# the honest live facts today.
		return [
			[ "cpu_count", @nCpuCount ],
			[ "address_bits", @nBits ]
		]

	  #-- Capabilities facet (the KEYSTONE) ------------------

	# The capabilities as DATA (the plain list) -- display with @@().
	def Capabilities()
		return @oCaps.List()

		def CapabilityList()
			return @oCaps.List()

	# The capability ENVELOPE as a chainable object (Q-convention).
	def CapabilitiesQ()
		return @oCaps

	def SetCapabilityList(paCaps)
		@oCaps = new stzSystemCapabilities(paCaps)
		return This

	def Grant(pCap)
		@oCaps.Grant(pCap)
		return This

		def GrantQ(pCap)
			This.Grant(pCap)
			return This

	def Revoke(pCap)
		@oCaps.Revoke(pCap)
		return This

	def Can(pCap)
		return @oCaps.Can(pCap)

	def Lacks(pCap)
		return @oCaps.Lacks(pCap)

	def CapabilityKinds()
		return @oCaps.Kinds()

	  #-- the TWO WORLDS (section 2.4): THIS (host/dev) vs a target

	# Capabilities THIS scope has that the TARGET lacks -- code you can run here
	# but that the target FORBIDS (down-constrain candidates).
	def Forbids(poTarget)
		return @oCaps.Minus(poTarget.CapabilitiesQ())

	# Capabilities the TARGET has that THIS scope lacks -- what the target
	# REQUIRES that this machine cannot do (up-enable candidates; the Virtual
	# System twin rehearses these later).
	def Requires(poTarget)
		return poTarget.CapabilitiesQ().Minus(@oCaps)

	def CompareTo(poTarget)
		return [
			[ "forbids", This.Forbids(poTarget) ],
			[ "requires", This.Requires(poTarget) ]
		]

	  #-- the system <-> agent bridge ------------------------

	# Which of THIS system's capabilities an actor holding these lattice kinds
	# (from stzAgentGraph) may exercise.
	def CapabilitiesForActorKinds(paActorKinds)
		return @oCaps.ForActorKinds(paActorKinds)

	  #-- the .stzsystem format (Law 1: a domain has a format)

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
		_c_ += "language_version: " + @cLangVersion + _nl_
		_c_ += "capabilities: " + _StzJoinComma(@oCaps.List()) + _nl_
		return _c_

	def Save(pcPath)
		_StzWriteTextFile(pcPath, This.ToStzSystem())
		return This

		def SaveQ(pcPath)
			This.Save(pcPath)
			return This

	# Read a .stzsystem file INTO this profile (the mirror of Save).
	def LoadFrom(pcPath)
		return This.FromString(_StzReadTextFile(pcPath))

	# Parse .stzsystem text into this profile. Defaults the role to deployment
	# (a declared target) unless the text says otherwise, and fills class-default
	# capabilities when no capabilities line is present.
	def FromString(pcText)
		This.SetRole("deployment")
		_cText_ = StzReplace(pcText, char(13), "")
		_aLines_ = StzSplit(_cText_, char(10))
		_bCapsSet_ = FALSE
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
			but _cKey_ = "language_version"
				This.SetLanguageVersion(_cVal_)
			but _cKey_ = "capabilities"
				This.SetCapabilityList(_StzParseCapList(_cVal_))
				_bCapsSet_ = TRUE
			ok
		next
		if NOT _bCapsSet_
			This.SetCapabilityList(_StzDefaultCapsForClass(_StzSystemClassOf(This.OSName())))
		ok
		return This

	  #-- info / show ----------------------------------------

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
