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
# target triple -- so For(oSystemProfile) cross-compiles for exactly where a
# part deploys. The build runs through the engine-backed managed child
# (SpawnProcess, Phase 1); the true build work is Zig's, orchestrated here.
#
#   o1 = new stzBuilder("hello")
#   o1.Source("hello.c").ForTarget(:LinuxServer).ReleaseFast()
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


  #===============#
 #  STZBUILDER   #
#===============#

class stzBuilder from stzObject

	@cName = ""
	@aSources = []
	@cLanguage = "c"       # c / cpp / zig
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

	def init(pcName)
		@cName = "" + pcName

	  #-- the declarative spec (fluent) ----------------------

	def Source(pcFile)
		@aSources + ("" + pcFile)
		return This

	def Sources(paFiles)
		if isList(paFiles)
			_n_ = len(paFiles)
			for _i_ = 1 to _n_
				@aSources + ("" + paFiles[_i_])
			next
		ok
		return This

	def Language(pcLang)
		@cLanguage = StzLower(ring_trim("" + pcLang))
		return This

		def AsC()
			return This.Language("c")
		def AsCpp()
			return This.Language("cpp")
		def AsZig()
			return This.Language("zig")

	def AsExe()
		@cKind = "exe"
		return This

	def AsLib()
		@cKind = "lib"
		return This

	# Build FOR a target -- a stzSystemProfile (a deployment system), a friendly
	# name (:LinuxServer, :ESP32), or a raw Zig triple ("x86_64-linux-gnu").
	# (Named ForTarget, not For: `For` is the Ring `for` keyword.)
	def ForTarget(pTarget)
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

	def ForHost()
		@cTriple = ""
		return This

	def Target()
		return @cTriple

	def Optimize(pcMode)
		@cOptimize = StzLower(ring_trim("" + pcMode))
		return This

		def Debug()
			return This.Optimize("debug")
		def ReleaseFast()
			return This.Optimize("fast")
		def ReleaseSmall()
			return This.Optimize("small")
		def ReleaseSafe()
			return This.Optimize("safe")

	def Output(pcPath)
		@cOutput = "" + pcPath
		return This

	def OutputPath()
		if @cOutput != ""
			return @cOutput
		ok
		return @cName + This._DefaultExt()

	def Define(pcName, pcVal)
		@aDefines + [ "" + pcName, "" + pcVal ]
		return This

	def Include(pcDir)
		@aIncludes + ("" + pcDir)
		return This

	def Link(pcLib)
		@aLibs + ("" + pcLib)
		return This

	def SetZig(pcPath)
		@cZig = "" + pcPath
		return This

	def ZigPath()
		if @cZig != ""
			return @cZig
		ok
		return _StzFindZig()

	  #-- the resolved build command -------------------------

	# The zig argument list (data -- display with @@).
	def Args()
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
		_n_ = len(@aSources)
		for _i_ = 1 to _n_
			_a_ + @aSources[_i_]
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
			_nD_ = len(@aDefines)
			for _i_ = 1 to _nD_
				_a_ + ("-D" + @aDefines[_i_][1] + "=" + @aDefines[_i_][2])
			next
			_nI_ = len(@aIncludes)
			for _i_ = 1 to _nI_
				_a_ + ("-I" + @aIncludes[_i_])
			next
			_nL_ = len(@aLibs)
			for _i_ = 1 to _nL_
				_a_ + ("-l" + @aLibs[_i_])
			next
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
