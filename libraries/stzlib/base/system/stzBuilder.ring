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
	but _c_ = "gpukernels"
		return "gpu"
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

# Describes what to build and for which system, then compiles it with Zig's drop-in C compiler, cross-compiling with one target flag.
#
# Declare sources, language (C, C++, Zig or Ring), executable or library, target, optimisation,
# definitions, includes and libraries, with the fluent Q forms. The target can be a
# stzSystemProfile, a friendly name such as :LinuxServer or :ESP32, or a raw Zig triple. Args and
# ToCommand show the command before anything runs, which is the rehearsal. Build then runs the
# compiler in a managed child process and keeps the output, the error output and the exit code.
# TargetWeb builds a freestanding wasm module for stzWebBundle. Build starts the Zig compiler and
# writes the output and the compiler cache: the documentation run declared and read builders only
# and did not run any Build.
#
#   receiver   o1 = new stzBuilder("hello") o1.AddSource("hello.c") o1.SetTarget("x86_64-linux-gnu")
#              o1.OptimizeFast()
#   example    ? @@( o1.Args() )
#              #--> [ "cc", "hello.c", "-o", "hello", "-target", "x86_64-linux-gnu", "-O3" ]
#              ? o1.Target()
#              #--> x86_64-linux-gnu
#              ? o1.IsWeb()
#              #--> 0
#              ? o1.Failed()
#              #--> 1
#   see        stzWebBundle, stzDeployment, stzSystemProfile
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
	@bBuilt = 0

	# Ring lowering state: a Ring part is `ring -geo`'d into a C unit and compiled
	# with the Ring VM source through the same Zig backend.
	@cRingRoot = ""
	@bLowered = 0
	@aLoweredSources = []
	@aLoweredIncludes = []
	@aLoweredLibs = []

	# Web target: a freestanding wasm module with a bridge ABI (imports come from
	# stz.js, listed exports are callable from JS). No WASI -- a real bridge.
	@bWeb = 0
	@aExports = []

	# Creates a build description with a name, which also names the default output file.
	#
	#   pcName     the name of the thing to build
	#   returns    nothing; the object is built
	#   note       nothing is compiled until Build
	#   see        AddSource, Build
	def init(pcName)
		@cName = "" + pcName

	# Adds a source file to compile.
	#
	#   pcFile     the path of a source file
	#   returns    nothing; use AddSourceQ to chain
	#   warning    the order given is the order on the command line; the file is not checked
	#   see        AddSources, Args
	#@ aka  -- the declarative spec (fluent) ----------------------
	def AddSource(pcFile)
		This.AddSourceQ(pcFile)

	def AddSourceQ(pcFile)
		@aSources + ("" + pcFile)
		return This

	# Adds several source files at once.
	#
	#   paFiles    a list of source file paths
	#   returns    nothing; use AddSourcesQ to chain
	#   warning    a value that is not a list changes nothing
	#   see        AddSource
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

	# Sets the language of the sources: c, cpp, zig or ring; c is the default.
	#
	#   pcLang     c, cpp, zig or ring
	#   returns    nothing; use SetLanguageQ to chain
	#   warning    c, cpp and ring use zig cc and zig takes build-exe or build-lib; any other word
	#              is treated as c; ring lowers the first source to C with ring -geo when Args or
	#              Build is called
	#   see        InC, InZig, Args
	def SetLanguage(pcLang)
		This.SetLanguageQ(pcLang)

	def SetLanguageQ(pcLang)
		@cLanguage = StzLower(ring_trim("" + pcLang))
		return This

		# Sets the language to C, the default.
		#
		#   returns    nothing; use InCQ to chain
		#   see        SetLanguage, InCpp
		def InC()
			This.InCQ()

		def InCQ()
			return This.SetLanguageQ("c")
		# Sets the language to C++.
		#
		#   returns    nothing; use InCppQ to chain
		#   warning    the command line is the same as for C
		#   see        SetLanguage, InC
		def InCpp()
			This.InCppQ()

		def InCppQ()
			return This.SetLanguageQ("cpp")
		# Sets the language to Zig, built with build-exe or build-lib.
		#
		#   returns    nothing; use InZigQ to chain
		#   see        SetLanguage, InC
		def InZig()
			This.InZigQ()

		def InZigQ()
			return This.SetLanguageQ("zig")
		# Sets the language to Ring, which is lowered to C and compiled with the Ring VM sources.
		#
		#   returns    nothing; use InRingQ to chain
		#   warning    Args and Build then run ring -geo on the first source and write a generated C
		#              file beside it
		#   see        SetLanguage, SetRingRoot
		def InRing()
			This.InRingQ()

		def InRingQ()
			return This.SetLanguageQ("ring")

	# Asks for an executable, the default.
	#
	#   returns    nothing; use EmitExeQ to chain
	#   see        EmitLib, OutputPath
	def EmitExe()
		This.EmitExeQ()

	def EmitExeQ()
		@cKind = "exe"
		return This

	# Asks for a shared library instead of an executable.
	#
	#   returns    nothing; use EmitLibQ to chain
	#   warning    the default output name then has no extension, not .dll: set one with SetOutput
	#   see        EmitExe, OutputPath
	def EmitLib()
		This.EmitLibQ()

	def EmitLibQ()
		@cKind = "lib"
		return This

	# Sets what to build for: a stzSystemProfile, a friendly name such as :LinuxServer or :ESP32, or a raw Zig triple such as x86_64-linux-gnu.
	#
	#   pTarget    a system profile object, a name, or a triple (any text with a dash)
	#   returns    nothing; use SetTargetQ to chain
	#   warning    a value that is neither an object nor a text is ignored; setting a target does
	#              not undo TargetWeb
	#   see        Target, TargetHost, TargetWeb
	#@ aka  Set the build target -- a stzSystemProfile (a deployment system), a friendly name (:LinuxServer, :ESP32), or a raw Zig triple ("x86_64-linux-gnu").
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

	# Clears the target so that the build is for this machine.
	#
	#   returns    nothing; use TargetHostQ to chain
	#   warning    it clears only the triple: if TargetWeb was called, IsWeb stays TRUE and the
	#              freestanding flags and the small optimisation stay
	#   see        SetTarget, Target
	def TargetHost()
		This.TargetHostQ()

	def TargetHostQ()
		@cTriple = ""
		return This

	# Builds for the web: the triple wasm32-freestanding, optimised small, with no libc and no start function.
	#
	#   returns    nothing; use TargetWebQ to chain
	#   warning    use AddExport to name the functions JavaScript may call; pair with stzWebBundle
	#              to assemble the page
	#   see        AddExport, IsWeb
	#@ aka  Build FOR the web: a freestanding wasm module that stz.js instantiates. JS owns the memory (imported); listed exports are callable from JS; small by default. Pair with stzWebBundle to assemble the page.
	def TargetWeb()
		This.TargetWebQ()

	def TargetWebQ()
		@cTriple = "wasm32-freestanding"
		@bWeb = 1
		@cOptimize = "small"
		return This

	# Adds a function that a web build exports to JavaScript.
	#
	#   pcName     the name of the function to export
	#   returns    nothing; use AddExportQ to chain
	#   warning    exports are passed to the linker only for a web build
	#   see        AddExports, TargetWeb
	def AddExport(pcName)
		This.AddExportQ(pcName)

	def AddExportQ(pcName)
		@aExports + ("" + pcName)
		return This

	# Adds several exported functions at once.
	#
	#   paNames    a list of function names
	#   returns    nothing; use AddExportsQ to chain
	#   warning    a value that is not a list changes nothing
	#   see        AddExport
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

	# TRUE if the build is for the web.
	#
	#   returns    TRUE or FALSE
	#   see        TargetWeb, Target
	def IsWeb()
		return @bWeb

	# Returns the Zig target triple, or an empty text for this machine.
	#
	#   returns    a text
	#   see        SetTarget, TargetHost
	def Target()
		return @cTriple

	# Sets the optimisation mode: debug, safe, fast or small.
	#
	#   pcMode     debug, safe, fast or small, matched without regard to case
	#   returns    nothing; use SetOptimizationQ to chain
	#   warning    any other word acts as debug; for cc the flags are -O0, -O2, -O3 and -Os, for zig
	#              Debug, ReleaseSafe, ReleaseFast and ReleaseSmall
	#   see        OptimizeFast, Args
	def SetOptimization(pcMode)
		This.SetOptimizationQ(pcMode)

	def SetOptimizationQ(pcMode)
		@cOptimize = StzLower(ring_trim("" + pcMode))
		return This

		# Sets the mode to debug, the default.
		#
		#   returns    nothing; use OptimizeDebugQ to chain
		#   see        SetOptimization
		def OptimizeDebug()
			This.OptimizeDebugQ()

		def OptimizeDebugQ()
			return This.SetOptimizationQ("debug")
		# Sets the mode to fast, for speed.
		#
		#   returns    nothing; use OptimizeFastQ to chain
		#   see        SetOptimization
		def OptimizeFast()
			This.OptimizeFastQ()

		def OptimizeFastQ()
			return This.SetOptimizationQ("fast")
		# Sets the mode to small, for size.
		#
		#   returns    nothing; use OptimizeSmallQ to chain
		#   see        SetOptimization
		def OptimizeSmall()
			This.OptimizeSmallQ()

		def OptimizeSmallQ()
			return This.SetOptimizationQ("small")
		# Sets the mode to safe, optimised with checks kept.
		#
		#   returns    nothing; use OptimizeSafeQ to chain
		#   see        SetOptimization
		def OptimizeSafe()
			This.OptimizeSafeQ()

		def OptimizeSafeQ()
			return This.SetOptimizationQ("safe")

	# Sets the path of the file to produce, in place of the default name.
	#
	#   pcPath     the path of the output file
	#   returns    nothing; use SetOutputQ to chain
	#   warning    the folder is not created
	#   see        OutputPath, Build
	def SetOutput(pcPath)
		This.SetOutputQ(pcPath)

	def SetOutputQ(pcPath)
		@cOutput = "" + pcPath
		return This

	# Returns the path of the file the build produces: the one set, or the name plus .exe, .wasm or nothing by target.
	#
	#   returns    a text
	#   warning    the default adds .exe for an executable for Windows, .wasm for wasm32 and nothing
	#              otherwise
	#   see        SetOutput, OutputExists
	def OutputPath()
		if @cOutput != ""
			return @cOutput
		ok
		return @cName + This._DefaultExt()

	# Adds a preprocessor definition NAME=value for a C or C++ build.
	#
	#   pcName     the macro's name
	#   pcVal      its value
	#   returns    nothing; use AddDefineQ to chain
	#   warning    ignored for a Zig build
	#   see        AddInclude, Args
	def AddDefine(pcName, pcVal)
		This.AddDefineQ(pcName, pcVal)

	def AddDefineQ(pcName, pcVal)
		@aDefines + [ "" + pcName, "" + pcVal ]
		return This

	# Adds a folder to the C include path.
	#
	#   pcDir      the include folder
	#   returns    nothing; use AddIncludeQ to chain
	#   warning    ignored for a Zig build
	#   see        AddDefine, Args
	def AddInclude(pcDir)
		This.AddIncludeQ(pcDir)

	def AddIncludeQ(pcDir)
		@aIncludes + ("" + pcDir)
		return This

	# Adds a library to link, as -l<name>.
	#
	#   pcLib      the library's name, without the -l
	#   returns    nothing; use AddLinkQ to chain
	#   warning    ignored for a Zig build
	#   see        AddInclude, Args
	def AddLink(pcLib)
		This.AddLinkQ(pcLib)

	def AddLinkQ(pcLib)
		@aLibs + ("" + pcLib)
		return This

	# Sets the path of the zig executable, in place of the one found by the search.
	#
	#   pcPath     the path of zig
	#   returns    nothing; use SetZigQ to chain
	#   warning    the path is not checked
	#   see        ZigPath
	def SetZig(pcPath)
		This.SetZigQ(pcPath)

	def SetZigQ(pcPath)
		@cZig = "" + pcPath
		return This

	# Returns the zig executable: the one set, else the file named by the ZIG variable, else a known install path, else the name zig.
	#
	#   returns    a text
	#   warning    the search reads the environment and the file system and starts nothing
	#   see        SetZig, ToCommand
	def ZigPath()
		if @cZig != ""
			return @cZig
		ok
		return _StzFindZig()

	# Sets the folder of the Ring installation that a Ring build compiles the VM from.
	#
	#   pcPath     the Ring root, the folder holding language/include/ring.h
	#   returns    nothing; use SetRingRootQ to chain
	#   warning    the path is not checked
	#   see        RingRoot, InRing
	#@ aka  -- Ring parts: lower to C, then compile through Zig ---
	def SetRingRoot(pcPath)
		This.SetRingRootQ(pcPath)

	def SetRingRootQ(pcPath)
		@cRingRoot = "" + pcPath
		return This

	# Returns the Ring root: the one set, else the RING variable, else a known install folder, else an empty text.
	#
	#   returns    a text
	#   warning    reads the environment and the file system and starts nothing
	#   see        SetRingRoot
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
			@bLowered = 1
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

	# Returns the compiler arguments as a list: the zig command, sources, output, target, optimisation, definitions, includes and libraries.
	#
	#   returns    a list of texts
	#   warning    pure for the C, C++ and Zig languages; for ring it first runs ring -geo on the
	#              first source, which writes a C file, so it was not run for ring
	#   see        ToCommand, Build
	#@ aka  -- the resolved build command -------------------------
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

	# Returns the full command line as one text, so that it can be read before it is run.
	#
	#   returns    a text
	#   warning    uses backslashes in the zig path on Windows; it starts nothing
	#   see        Args, Build
	#@ aka  The full command line, as one string (rehearsable -- see it before you run it, the way the twin shows a plan before it commits).
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

	# Runs the compiler on the description in a managed child process and keeps its output and exit code.
	#
	#   returns    the builder itself, so calls chain
	#   note       not run: it starts the Zig compiler, which this documentation pass did not do
	#   warning    effectful: it starts the zig compiler, which writes the output file and fills the
	#              zig cache; a failure shows in ExitCode and the log, not as an error
	#   see        Succeeded, BuildLog, ToCommand
	#@ aka  -- the build (through the engine-backed managed child) --
	def Build()
		_oChild_ = SpawnProcess(This.ToCommand())
		@cStdout = _oChild_.ReadOutputAll()
		@cStderr = _oChild_.ReadErrorAll()
		@nExit = _oChild_.Wait()
		_oChild_.Close()
		@bBuilt = 1
		return This

		def BuildQ()
			This.Build()
			return This

	# Returns the exit code of the last Build; -1 before any Build.
	#
	#   returns    a number
	#   see        Succeeded, Build
	def ExitCode()
		return @nExit

	# TRUE if the output file exists on disk.
	#
	#   returns    TRUE or FALSE
	#   warning    true also for a file left by an earlier build
	#   see        OutputPath, Succeeded
	def OutputExists()
		return StzEngineFileExists(This.OutputPath()) = 1

	# TRUE if Build ran, exited with 0 and left the output file.
	#
	#   returns    TRUE or FALSE
	#   warning    FALSE before any Build
	#   see        Failed, Build
	def Succeeded()
		return @bBuilt and @nExit = 0 and This.OutputExists()

	# TRUE if the build did not succeed, which is also so before any Build.
	#
	#   returns    TRUE or FALSE
	#   see        Succeeded
	def Failed()
		return NOT This.Succeeded()

	# Returns what the compiler printed on its standard output during the last Build; empty before a Build.
	#
	#   returns    a text
	#   see        Stderr, BuildLog
	def Stdout()
		return @cStdout

	# Returns what the compiler printed on its error output during the last Build; empty before a Build.
	#
	#   returns    a text
	#   see        Stdout, BuildLog
	def Stderr()
		return @cStderr

	# Returns the standard output of the last Build followed by its error output.
	#
	#   returns    a text
	#   see        Stdout, Stderr
	#@ aka  Everything the compiler said (zig writes diagnostics to stderr).
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
		_bWin_ = 0
		if @cTriple = ""
			_oOS_ = new stzOperatingSystem()
			_bWin_ = _oOS_.IsWindows()
		but StzFindFirst("windows", @cTriple) > 0
			_bWin_ = 1
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

	# Prints the builder's name, target, output path and command line.
	#
	#   returns    nothing; it prints
	#   warning    for the ring language it would lower the first source, so use it on c or zig
	#              builders
	#   see        ToCommand, Args
	def Show()
		? "Builder '" + @cName + "'"
		if @cTriple = ""
			? "  target:  host (native)"
		else
			? "  target:  " + @cTriple
		ok
		? "  output:  " + This.OutputPath()
		? "  command: " + This.ToCommand()
