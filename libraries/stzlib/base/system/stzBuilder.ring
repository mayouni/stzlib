#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZBUILDER                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Softanzifies the BUILD. Zig is not only a   #
#                  language -- `zig cc` is a drop-in C/C++     #
#                  compiler that CROSS-compiles to any target  #
#                  with one -target flag, no per-target        #
#                  toolchain. stzBuilder wraps that in a       #
#                  declarative object: say what to build and   #
#                  FOR which system, and it builds it.         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# The build engine BEHIND the deploy: the lowering bridge (stzPlatformProfile)
# GENERATES a part's target source; stzBuilder COMPILES it for the target. A
# deployment target is a stzSystemProfile whose OS + architecture ARE a Zig
# target triple -- so SetTargetQ(oSystemProfile) cross-compiles for exactly where
# a part deploys. The build runs through the engine-backed managed child
# (SpawnProcess, Phase 1); the true build work is Zig's, orchestrated here.
#
#   o1 = new stzBuilder("hello")
#   o1.AddSourceQ("hello.c").SetTargetQ(:LinuxServer).OptimizeFastQ()
#   ? @@( o1.Args() )
#   o1.Build()
#   ? o1.Succeeded()

  #=============#
 #  FUNCTIONS  #
#=============#

func StzBuilderQ(pcName)
	return new stzBuilder(pcName)

# A Softanza OS + architecture -> a Zig target triple (<arch>-<os>-<abi>).
func _StzZigTripleFor(pcOs, pcArch)
	_cA_ = StzLower(ring_trim("" + pcArch))
	if _cA_ = "x64" or _cA_ = "amd64" or _cA_ = "x86_64"
		_cA_ = "x86_64"
	but _cA_ = "arm64" or _cA_ = "aarch64"
		_cA_ = "aarch64"
	but _cA_ = "x86" or _cA_ = "i386" or _cA_ = "i686"
		_cA_ = "x86"
	ok
	_cOs_ = StzLower(ring_trim("" + pcOs))
	if _cOs_ = "windows"
		return _cA_ + "-windows-gnu"
	but _cOs_ = "linux"
		return _cA_ + "-linux-gnu"
	but _cOs_ = "macos"
		return _cA_ + "-macos-none"
	but _cOs_ = "freebsd"
		return _cA_ + "-freebsd-none"
	but _cOs_ = "android"
		return _cA_ + "-linux-android"
	but _cOs_ = "wasm" or _cOs_ = "wasi"
		return "wasm32-wasi"
	but _cOs_ = "espidf" or _cOs_ = "esp32" or _cOs_ = "rtos" or _cOs_ = "freertos"
		# an ESP32-C3-class MCU is riscv32; xtensa is not a stable Zig target
		return "riscv32-freestanding-none"
	ok
	return _cA_ + "-" + _cOs_ + "-none"

# Locate the zig executable: $ZIG, then common install paths, then PATH.
func _StzFindZig()
	_oE_ = new stzEnvironment()
	_cZ_ = _oE_.Var("ZIG")
	if _cZ_ != "" and StzEngineFileExists(_cZ_) = 1
		return _cZ_
	ok
	_aCand_ = [ "D:/Zig/zig.exe", "C:/Zig/zig.exe", "/usr/local/bin/zig", "/usr/bin/zig" ]
	_n_ = len(_aCand_)
	for _i_ = 1 to _n_
		if StzEngineFileExists(_aCand_[_i_]) = 1
			return _aCand_[_i_]
		ok
	next
	return "zig"

# Locate the Ring installation root (the folder holding language/include/ring.h
# and language/src/*.c). $RING, then common roots. Ring's VM is pure C, so once
# located it cross-compiles with Zig like any C part -- this is what lets a Ring
# app become a native binary for ANY target, no ring.dll on the machine.
func _StzFindRing()
	_oE_ = new stzEnvironment()
	_cR_ = _oE_.Var("RING")
	if _cR_ != "" and StzEngineFileExists(_cR_ + "/language/include/ring.h") = 1
		return _cR_
	ok
	_aCand_ = [ "D:/ring127", "D:/ring", "C:/ring", "/usr/local/ring", "/usr/lib/ring" ]
	_n_ = len(_aCand_)
	for _i_ = 1 to _n_
		if StzEngineFileExists(_aCand_[_i_] + "/language/include/ring.h") = 1
			return _aCand_[_i_]
		ok
	next
	return ""

# Directory portion of a path (codepoint-safe; separators normalized to /).
func _StzDirOf(pcPath)
	_c_ = StzReplace("" + pcPath, "\", "/")
	_a_ = StzSplit(_c_, "/")
	_n_ = len(_a_)
	if _n_ <= 1
		return "."
	ok
	_cDir_ = _a_[1]
	for _i_ = 2 to _n_ - 1
		_cDir_ += "/" + _a_[_i_]
	next
	if _cDir_ = ""
		return "/"
	ok
	return _cDir_

# File basename without its extension.
func _StzBaseNoExt(pcPath)
	_c_ = StzReplace("" + pcPath, "\", "/")
	_a_ = StzSplit(_c_, "/")
	_cFile_ = _a_[len(_a_)]
	_aP_ = StzSplit(_cFile_, ".")
	if len(_aP_) <= 1
		return _cFile_
	ok
	_cB_ = _aP_[1]
	for _i_ = 2 to len(_aP_) - 1
		_cB_ += "." + _aP_[_i_]
	next
	return _cB_

# The Ring VM C sources to compile with a Ring app: every language/src/*.c EXCEPT
# ring.c (the CLI's own main -- we supply ours via -geo) and, for a non-Windows
# target, ringw.c (a Windows-only unit). This IS Ring's own per-platform file
# split -- the small pragmatic table that lets one VM source tree cross-compile.
func _StzRingVMSources(pcRoot, pbWindowsTarget)
	_cDir_ = pcRoot + "/language/src"
	_aAll_ = StzListFiles(_cDir_)
	_aOut_ = []
	_n_ = len(_aAll_)
	for _i_ = 1 to _n_
		_cLow_ = StzLower("" + _aAll_[_i_])
		_nDotC_ = StzFindLast(".c", _cLow_)
		if _nDotC_ = 0 or _nDotC_ != (len(_cLow_) - 1)
			loop   # keep only names ending in .c
		ok
		if _cLow_ = "ring.c"
			loop
		ok
		if _cLow_ = "ringw.c" and NOT pbWindowsTarget
			loop
		ok
		_aOut_ + (_cDir_ + "/" + _aAll_[_i_])
	next
	return _aOut_

# -- the web EDGE: the differential engine subset, as stz.wasm ---------------
# "Compile the engine, not the interpreter." The engine's build.zig has a `wasm`
# step that compiles src/stz_wasm_entry.zig (real numtheory.zig / solver.zig
# logic, re-exported) to a freestanding wasm module. These wrap that step so a
# Ring caller can PRODUCE the edge artifact and know WHERE it lands.

# Where `zig build wasm` writes stz.wasm (the engine's install dir).
func StzEngineWasmPath()
	return $cEngineDir + "/zig-out/bin/stz.wasm"

# A plan capability KEY -> the engine wasm GROUP that backs it on the edge, or
# "" when no wasm logic exists for it yet (so it is simply not shipped). This is
# the map the delivery planner's [stz.wasm]-placed capabilities travel through to become a
# build subset -- emit ONLY what the part actually uses.
func _StzWasmGroupFor(pcCapKey)
	_c_ = StzLower(ring_trim("" + pcCapKey))
	if _c_ = "constraintsolver"
		return "solver"
	but _c_ = "pivottable"
		return "aggregation"
	but _c_ = "bignumber"
		return "numtheory"
	but _c_ = "pattern"
		return "pattern"
	but _c_ = "graph"
		return "graph"
	ok
	return ""

# A list of capability keys -> the deduped engine GROUP set (drops keys with no
# wasm group). This IS a part's on-device engine subset, expressed as build groups.
func StzWasmGroupsFor(paCapKeys)
	_out_ = []
	if NOT isList(paCapKeys)
		return _out_
	ok
	_n_ = len(paCapKeys)
	for _i_ = 1 to _n_
		_g_ = _StzWasmGroupFor(paCapKeys[_i_])
		if _g_ != "" and StzFindFirst(_g_, _out_) = 0
			_out_ + _g_
		ok
	next
	return _out_

# Build stz.wasm carrying ONLY the given engine groups (a part's subset), writing
# the artifact to pcDestPath. paGroups e.g. [ "solver", "aggregation" ]. Returns
# pcDestPath on success, "" on failure. This is the per-part emission: `zig build
# wasm -Dwasm-groups=<subset>` then copy the result to the part's own file.
func StzBuildEngineWasmSubset(paGroups, pcDestPath)
	if NOT (isList(paGroups) and len(paGroups) > 0)
		return ""
	ok
	_cGroups_ = "" + paGroups[1]
	for _i_ = 2 to len(paGroups)
		_cGroups_ += "," + paGroups[_i_]
	next
	_cZig_ = _StzFindZig()
	_cEng_ = $cEngineDir
	if NOT (isString(_cEng_) and _cEng_ != "")
		return ""
	ok
	_oEnv_ = new stzEnvironment()
	_cSaved_ = _oEnv_.WorkingDirectory()
	_oEnv_.ChangeWorkingDirectory(_cEng_)
	_cCmd_ = _cZig_ + " build wasm -Dwasm-groups=" + _cGroups_
	_oOS_ = new stzOperatingSystem()
	if _oOS_.IsWindows()
		_cCmd_ = StzReplace(_cCmd_, "/", "\")
	ok
	_oChild_ = SpawnProcess(_cCmd_)
	_oChild_.ReadOutputAll()
	_oChild_.ReadErrorAll()
	_nExit_ = _oChild_.Wait()
	_oChild_.Close()
	_oEnv_.ChangeWorkingDirectory(_cSaved_)
	if _nExit_ = 0 and StzEngineFileExists(StzEngineWasmPath()) = 1
		write("" + pcDestPath, read(StzEngineWasmPath()))
		if StzEngineFileExists("" + pcDestPath) = 1
			return "" + pcDestPath
		ok
	ok
	return ""

# Build stz.wasm through the engine's build.zig wasm target (TargetWebQ, for the
# ENGINE/Zig path -- the DLLs' Zig source, lowered to wasm instead of a .dll).
# Returns the artifact path on success, "" on failure. Needs Zig on the machine.
func StzBuildEngineWasm()
	_cZig_ = _StzFindZig()
	_cEng_ = $cEngineDir
	if NOT (isString(_cEng_) and _cEng_ != "")
		return ""
	ok
	_oEnv_ = new stzEnvironment()
	_cSaved_ = _oEnv_.WorkingDirectory()
	_oEnv_.ChangeWorkingDirectory(_cEng_)
	_cCmd_ = _cZig_ + " build wasm"
	_oOS_ = new stzOperatingSystem()
	if _oOS_.IsWindows()
		_cCmd_ = StzReplace(_cCmd_, "/", "\")
	ok
	_oChild_ = SpawnProcess(_cCmd_)
	_oChild_.ReadOutputAll()
	_oChild_.ReadErrorAll()
	_nExit_ = _oChild_.Wait()
	_oChild_.Close()
	_oEnv_.ChangeWorkingDirectory(_cSaved_)
	if _nExit_ = 0 and StzEngineFileExists(StzEngineWasmPath()) = 1
		return StzEngineWasmPath()
	ok
	return ""

  #===============#
 #  STZBUILDER   #
#===============#

class stzBuilder from stzObject

	@cName = ""
	@aSources = []
	@cLanguage = "c"       # c / cpp / zig / ring
	@cKind = "exe"         # exe / lib
	@cTriple = ""          # "" = host (native)
	@cOptimize = "debug"   # debug / safe / fast / small
	@cOutput = ""
	@aDefines = []
	@aIncludes = []
	@aLibs = []
	@cZig = ""
	@cStdout = ""
	@cStderr = ""
	@nExit = -1
	@bBuilt = FALSE

	# Ring lowering state: a Ring part is `ring -geo`'d into a C unit and compiled
	# with the Ring VM source through the same Zig backend.
	@cRingRoot = ""
	@bLowered = FALSE
	@aLoweredSources = []
	@aLoweredIncludes = []
	@aLoweredLibs = []

	# Web target: a freestanding wasm module with a bridge ABI (imports come from
	# stz.js, listed exports are callable from JS). No WASI -- a real bridge.
	@bWeb = FALSE
	@aExports = []

	def init(pcName)
		@cName = "" + pcName

	  #-- the declarative spec (fluent) ----------------------

	def AddSource(pcFile)
		This.AddSourceQ(pcFile)

	def AddSourceQ(pcFile)
		@aSources + ("" + pcFile)
		return This

	def AddSources(paFiles)
		This.AddSourcesQ(paFiles)

	def AddSourcesQ(paFiles)
		if isList(paFiles)
			_n_ = len(paFiles)
			for _i_ = 1 to _n_
				@aSources + ("" + paFiles[_i_])
			next
		ok
		return This

	def SetLanguage(pcLang)
		This.SetLanguageQ(pcLang)

	def SetLanguageQ(pcLang)
		@cLanguage = StzLower(ring_trim("" + pcLang))
		return This

		def InC()
			This.InCQ()

		def InCQ()
			return This.SetLanguageQ("c")
		def InCpp()
			This.InCppQ()

		def InCppQ()
			return This.SetLanguageQ("cpp")
		def InZig()
			This.InZigQ()

		def InZigQ()
			return This.SetLanguageQ("zig")
		def InRing()
			This.InRingQ()

		def InRingQ()
			return This.SetLanguageQ("ring")

	def EmitExe()
		This.EmitExeQ()

	def EmitExeQ()
		@cKind = "exe"
		return This

	def EmitLib()
		This.EmitLibQ()

	def EmitLibQ()
		@cKind = "lib"
		return This

	# Set the build target -- a stzSystemProfile (a deployment system), a friendly
	# name (:LinuxServer, :ESP32), or a raw Zig triple ("x86_64-linux-gnu").
	def SetTarget(pTarget)
		This.SetTargetQ(pTarget)

	def SetTargetQ(pTarget)
		if isObject(pTarget)
			@cTriple = _StzZigTripleFor(pTarget.OSName(), pTarget.Architecture())
		but isString(pTarget)
			_c_ = StzLower(ring_trim("" + pTarget))
			# A Zig triple always carries a dash (arch-os at least:
			# wasm32-wasi, x86_64-linux-gnu). A friendly name never does
			# (:LinuxServer, :ESP32, :Windows) -- so a dash is the tell.
			if len(StzFind("-", _c_)) >= 1
				@cTriple = _c_
			else
				_oP_ = _StzSystemProfileForTarget(_c_)
				@cTriple = _StzZigTripleFor(_oP_.OSName(), _oP_.Architecture())
			ok
		ok
		return This

	def TargetHost()
		This.TargetHostQ()

	def TargetHostQ()
		@cTriple = ""
		return This

	# Build FOR the web: a freestanding wasm module that stz.js instantiates.
	# JS owns the memory (imported); listed exports are callable from JS; small
	# by default. Pair with stzWebBundle to assemble the page.
	def TargetWeb()
		This.TargetWebQ()

	def TargetWebQ()
		@cTriple = "wasm32-freestanding"
		@bWeb = TRUE
		@cOptimize = "small"
		return This

	def AddExport(pcName)
		This.AddExportQ(pcName)

	def AddExportQ(pcName)
		@aExports + ("" + pcName)
		return This

	def AddExports(paNames)
		This.AddExportsQ(paNames)

	def AddExportsQ(paNames)
		if isList(paNames)
			_n_ = len(paNames)
			for _i_ = 1 to _n_
				@aExports + ("" + paNames[_i_])
			next
		ok
		return This

	def IsWeb()
		return @bWeb

	def Target()
		return @cTriple

	def SetOptimization(pcMode)
		This.SetOptimizationQ(pcMode)

	def SetOptimizationQ(pcMode)
		@cOptimize = StzLower(ring_trim("" + pcMode))
		return This

		def OptimizeDebug()
			This.OptimizeDebugQ()

		def OptimizeDebugQ()
			return This.SetOptimizationQ("debug")
		def OptimizeFast()
			This.OptimizeFastQ()

		def OptimizeFastQ()
			return This.SetOptimizationQ("fast")
		def OptimizeSmall()
			This.OptimizeSmallQ()

		def OptimizeSmallQ()
			return This.SetOptimizationQ("small")
		def OptimizeSafe()
			This.OptimizeSafeQ()

		def OptimizeSafeQ()
			return This.SetOptimizationQ("safe")

	def SetOutput(pcPath)
		This.SetOutputQ(pcPath)

	def SetOutputQ(pcPath)
		@cOutput = "" + pcPath
		return This

	def OutputPath()
		if @cOutput != ""
			return @cOutput
		ok
		return @cName + This._DefaultExt()

	def AddDefine(pcName, pcVal)
		This.AddDefineQ(pcName, pcVal)

	def AddDefineQ(pcName, pcVal)
		@aDefines + [ "" + pcName, "" + pcVal ]
		return This

	def AddInclude(pcDir)
		This.AddIncludeQ(pcDir)

	def AddIncludeQ(pcDir)
		@aIncludes + ("" + pcDir)
		return This

	def AddLink(pcLib)
		This.AddLinkQ(pcLib)

	def AddLinkQ(pcLib)
		@aLibs + ("" + pcLib)
		return This

	def SetZig(pcPath)
		This.SetZigQ(pcPath)

	def SetZigQ(pcPath)
		@cZig = "" + pcPath
		return This

	def ZigPath()
		if @cZig != ""
			return @cZig
		ok
		return _StzFindZig()

	  #-- Ring parts: lower to C, then compile through Zig ---

	def SetRingRoot(pcPath)
		This.SetRingRootQ(pcPath)

	def SetRingRootQ(pcPath)
		@cRingRoot = "" + pcPath
		return This

	def RingRoot()
		if @cRingRoot != ""
			return @cRingRoot
		ok
		return _StzFindRing()

	def _RingExe()
		_cB_ = This.RingRoot() + "/bin/ring"
		_oOS_ = new stzOperatingSystem()
		if _oOS_.IsWindows()
			return _cB_ + ".exe"
		ok
		return _cB_

	def _IsWindowsTarget()
		if @cTriple = ""
			_oOS_ = new stzOperatingSystem()
			return _oOS_.IsWindows()
		ok
		return StzFindFirst("windows", @cTriple) > 0

	# Lower a Ring part exactly once (idempotent); called before the args/command
	# are resolved. Running `ring -geo` here is a real side effect, so it is
	# guarded -- displaying the command or building both resolve to one lowering.
	def _EnsureLowered()
		if @bLowered
			return
		ok
		if @cLanguage = "ring"
			This._LowerRing()
			@bLowered = TRUE
		ok

	def _LowerRing()
		if len(@aSources) = 0
			return
		ok
		_cSrc_ = @aSources[1]
		_cDir_ = _StzDirOf(_cSrc_)
		_cBase_ = _StzBaseNoExt(_cSrc_)

		# Ring's -geo writes <base>.c next to the source but ringappcode.c/.h to
		# the process cwd -- so cd into the source dir first to co-locate them.
		_oEnv_ = new stzEnvironment()
		_cSaved_ = _oEnv_.WorkingDirectory()
		_oEnv_.ChangeWorkingDirectory(_cDir_)
		_cCmd_ = This._RingExe() + " " + _cBase_ + ".ring -geo"
		_oOS_ = new stzOperatingSystem()
		if _oOS_.IsWindows()
			_cCmd_ = StzReplace(_cCmd_, "/", "\")
		ok
		_oChild_ = SpawnProcess(_cCmd_)
		_oChild_.ReadOutputAll()
		_oChild_.ReadErrorAll()
		_oChild_.Wait()
		_oChild_.Close()
		_oEnv_.ChangeWorkingDirectory(_cSaved_)

		# the C compilation unit: generated app C + embedded bytecode + the VM
		_aLS_ = [ _cDir_ + "/" + _cBase_ + ".c", _cDir_ + "/ringappcode.c" ]
		_cRoot_ = This.RingRoot()
		_bWin_ = This._IsWindowsTarget()
		_aVM_ = _StzRingVMSources(_cRoot_, _bWin_)
		_nV_ = len(_aVM_)
		for _i_ = 1 to _nV_
			_aLS_ + _aVM_[_i_]
		next
		@aLoweredSources = _aLS_
		@aLoweredIncludes = [ _cRoot_ + "/language/include", _cRoot_ + "/language/src" ]
		if _bWin_
			@aLoweredLibs = [ "m", "advapi32", "shell32" ]
		else
			@aLoweredLibs = [ "m" ]
		ok

	  #-- the resolved build command -------------------------

	# The zig argument list (data -- display with @@). For a Ring part this
	# resolves the -geo lowering first, so the args reflect the REAL compile:
	# the generated C + the Ring VM source, cc-compiled by Zig.
	def Args()
		This._EnsureLowered()
		_a_ = []
		if @cLanguage = "zig"
			if @cKind = "lib"
				_a_ + "build-lib"
			else
				_a_ + "build-exe"
			ok
		else
			_a_ + "cc"
			if @cKind = "lib"
				_a_ + "-shared"
			ok
		ok
		if @cLanguage = "ring"
			_aSrc_ = @aLoweredSources
		else
			_aSrc_ = @aSources
		ok
		_n_ = len(_aSrc_)
		for _i_ = 1 to _n_
			_a_ + _aSrc_[_i_]
		next
		if @cLanguage = "zig"
			_a_ + ("-femit-bin=" + This.OutputPath())
		else
			_a_ + "-o"
			_a_ + This.OutputPath()
		ok
		if @cTriple != ""
			_a_ + "-target"
			_a_ + @cTriple
		ok
		if @cLanguage = "zig"
			_a_ + "-O"
			_a_ + This._ZigOptMode()
		else
			_a_ + This._CcOptFlag()
			# The generated C + the Ring VM source warn a lot; silence it. Beyond
			# noise, a large warning stream can fill the managed child's stderr
			# pipe and deadlock the drain, so this keeps lowered builds safe.
			if @cLanguage = "ring"
				_a_ + "-w"
			ok
			if @bWeb
				# freestanding wasm + the stz.js bridge ABI: no libc, no _start,
				# JS owns the memory, and the named functions are exported.
				_a_ + "-nostdlib"
				_a_ + "-Wl,--no-entry"
				_a_ + "-Wl,--import-memory"
				_a_ + "-Wl,--strip-all"
				_nE_ = len(@aExports)
				for _i_ = 1 to _nE_
					_a_ + ("-Wl,--export=" + @aExports[_i_])
				next
			ok
			_nD_ = len(@aDefines)
			for _i_ = 1 to _nD_
				_a_ + ("-D" + @aDefines[_i_][1] + "=" + @aDefines[_i_][2])
			next
			_nI_ = len(@aIncludes)
			for _i_ = 1 to _nI_
				_a_ + ("-I" + @aIncludes[_i_])
			next
			if @cLanguage = "ring"
				_nLI_ = len(@aLoweredIncludes)
				for _i_ = 1 to _nLI_
					_a_ + ("-I" + @aLoweredIncludes[_i_])
				next
			ok
			_nL_ = len(@aLibs)
			for _i_ = 1 to _nL_
				_a_ + ("-l" + @aLibs[_i_])
			next
			if @cLanguage = "ring"
				_nLL_ = len(@aLoweredLibs)
				for _i_ = 1 to _nLL_
					_a_ + ("-l" + @aLoweredLibs[_i_])
				next
			ok
		ok
		return _a_

	# The full command line, as one string (rehearsable -- see it before you run
	# it, the way the twin shows a plan before it commits).
	def ToCommand()
		_cZig_ = This.ZigPath()
		_oOS_ = new stzOperatingSystem()
		if _oOS_.IsWindows()
			_cZig_ = StzReplace(_cZig_, "/", "\")
		ok
		_c_ = _cZig_
		_aArgs_ = This.Args()
		_n_ = len(_aArgs_)
		for _i_ = 1 to _n_
			_c_ += " " + _aArgs_[_i_]
		next
		return _c_

	  #-- the build (through the engine-backed managed child) --

	def Build()
		_oChild_ = SpawnProcess(This.ToCommand())
		@cStdout = _oChild_.ReadOutputAll()
		@cStderr = _oChild_.ReadErrorAll()
		@nExit = _oChild_.Wait()
		_oChild_.Close()
		@bBuilt = TRUE
		return This

		def BuildQ()
			This.Build()
			return This

	def ExitCode()
		return @nExit

	def OutputExists()
		return StzEngineFileExists(This.OutputPath()) = 1

	def Succeeded()
		return @bBuilt and @nExit = 0 and This.OutputExists()

	def Failed()
		return NOT This.Succeeded()

	def Stdout()
		return @cStdout

	def Stderr()
		return @cStderr

	# Everything the compiler said (zig writes diagnostics to stderr).
	def BuildLog()
		_c_ = @cStdout
		if @cStderr != ""
			_c_ += @cStderr
		ok
		return _c_

	  #-- helpers --------------------------------------------

	def _DefaultExt()
		if StzFind("wasm", @cTriple) != [] and StzFindFirst("wasm", @cTriple) = 1
			return ".wasm"
		ok
		_bWin_ = FALSE
		if @cTriple = ""
			_oOS_ = new stzOperatingSystem()
			_bWin_ = _oOS_.IsWindows()
		but StzFindFirst("windows", @cTriple) > 0
			_bWin_ = TRUE
		ok
		if @cKind = "exe" and _bWin_
			return ".exe"
		ok
		return ""

	def _CcOptFlag()
		if @cOptimize = "fast"
			return "-O3"
		but @cOptimize = "small"
			return "-Os"
		but @cOptimize = "safe"
			return "-O2"
		ok
		return "-O0"

	def _ZigOptMode()
		if @cOptimize = "fast"
			return "ReleaseFast"
		but @cOptimize = "small"
			return "ReleaseSmall"
		but @cOptimize = "safe"
			return "ReleaseSafe"
		ok
		return "Debug"

	def Show()
		? "Builder '" + @cName + "'"
		if @cTriple = ""
			? "  target:  host (native)"
		else
			? "  target:  " + @cTriple
		ok
		? "  output:  " + This.OutputPath()
		? "  command: " + This.ToCommand()
