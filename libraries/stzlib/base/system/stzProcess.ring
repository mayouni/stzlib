#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZPROCESS                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : THE PROCESS -- this running process         #
#                  (identity, uptime, machine facts) and, in   #
#                  Phase 1, a managed CHILD process (spawn,    #
#                  stream, wait, kill). Engine-backed          #
#                  (stz_process.dll / stz_system.dll).         #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Part of the Softanza System Foundation
# (base/doc/design/SOFTANZA_SYSTEM_FOUNDATION.md). This is the KEYSTONE the
# foundation was missing: a Ring face over the engine's process module, whose
# facts were previously computed a second time in stzOperatingSystem (Ring's
# getarch()). Here every fact is a one-line delegate to the engine -- the
# ONE source of truth, reusable by any future language binding.
#
# ARCHITECTURE VOCABULARY: the engine reports Zig's own arch tag ("x86_64",
# "aarch64"); Softanza's canonical names are "x64"/"arm64"/"x86"/"arm". The
# reconciliation lives HERE, once, so the two vocabularies never disagree in
# the wild. EngineArchitecture() exposes the raw tag; Architecture() the
# canonical name.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzProcessQ()
	return new stzProcess()

	func ThisProcess()
		return new stzProcess()

# Spawn a MANAGED CHILD process: started, streamable, waitable, killable.
# Returns a stzProcess whose control face is live. The command runs through
# the platform shell (cmd.exe /c on Windows, /bin/sh -c elsewhere).
#
#   oChild = SpawnProcess("mytool --flag")
#   while TRUE
#       cChunk = oChild.ReadOutput()
#       if cChunk = "" exit ok       # "" == end of stream
#       ? cChunk
#   end
#   nExit = oChild.Wait()
#   oChild.Close()                   # frees the child handle
#
func SpawnProcess(pcCommand)
	_oP_ = new stzProcess()
	_oP_.Spawn(pcCommand)
	return _oP_

	func StzSpawn(pcCommand)
		return SpawnProcess(pcCommand)

# Sugar over a default instance.

func ProcessId()
	_oP_ = new stzProcess()
	return _oP_.Id()

func ProcessUptime()
	_oP_ = new stzProcess()
	return _oP_.Uptime()


  #===============#
 #  STZPROCESS   #
#===============#

class stzProcess from stzObject

	# Only used by the control (child) face; NULL for the introspection face.
	@pChildHandle = ""
	@nCachedExit = -1
	@bWaited = 0
	@bStdoutEnded = 0

	def init()
		# Stateless for the introspection face: every fact is read live from
		# the engine. The control face fills @pChildHandle on Spawn().

	  #-----------------------------#
	 #  CHILD PROCESS -- control    #
	 #  (Phase 1: spawn / stream /  #
	 #   wait / kill)               #
	#-----------------------------#
	#
	# EFFECTFUL. Spawning, killing -- the operations a Virtual System twin
	# will later rehearse and gate behind an UpdatePlan. The USAGE CONTRACT
	# (to avoid a pipe deadlock): read the output to EOF, THEN Wait(); keep
	# stderr modest unless you also drain it.

	def Spawn(pcCommand)
		if NOT isString(pcCommand)
			StzRaise("Incorrect param type! pcCommand must be a string.")
		ok
		if @trim(pcCommand) = ""
			StzRaise("Can't spawn: the command is empty.")
		ok
		@pChildHandle = StzEngineProcessSpawn(pcCommand)
		@bWaited = 0
		@nCachedExit = -1
		if @pChildHandle = ""
			StzRaise("Failed to spawn the process: " + pcCommand)
		ok
		return This

		def SpawnQ(pcCommand)
			This.Spawn(pcCommand)
			return This

	# Spawns a program by its ARGV, no shell between, in a working directory
	# of your choosing ("" inherits). The form a RUNNER wants: an argument
	# with a quote or a space reaches the program unparsed, and Kill() reaches
	# the program itself -- through the shell form it reached only cmd.exe and
	# left the program running (measured, Testoor TR1). Each argv item is a
	# string; the first is the program.
	#   oP.SpawnIn("D:/work/uuid", [ "ring", "00_uuid_narrated.ring" ])
	def SpawnIn(pcDir, pacArgv)
		if NOT isList(pacArgv) or ring_len(pacArgv) = 0
			StzRaise("Incorrect param type! pacArgv must be a non-empty list of strings.")
		ok
		_cPacked_ = "" + pacArgv[1]
		_n_ = ring_len(pacArgv)
		for _k_ = 2 to _n_
			_cPacked_ += char(0) + pacArgv[_k_]
		next
		@pChildHandle = StzEngineProcessSpawnArgv(_cPacked_, "" + pcDir)
		@bWaited = 0
		@nCachedExit = -1
		@bStdoutEnded = 0
		if @pChildHandle = ""
			StzRaise("Failed to spawn: " + pacArgv[1] + " in " + pcDir)
		ok
		return This

		def SpawnInQ(pcDir, pacArgv)
			return This.SpawnIn(pcDir, pacArgv)

	# TRUE if this object is managing a spawned child.
	def HasChild()
		return @pChildHandle != ""

		def IsChild()
			return This.HasChild()

	# The OS process id of the spawned child.
	def ChildPid()
		This._RequireChild()
		return StzEngineProcessChildPid(@pChildHandle)

	# Reads the next available chunk of the child's stdout. Blocks until at
	# least one byte arrives, or returns "" at end of stream. This is the
	# STREAMING read -- call it in a loop.
	def ReadOutput()
		This._RequireChild()
		return StzEngineProcessReadStdout(@pChildHandle)

		def ReadStdout()
			return This.ReadOutput()

	# Reads the child's stdout to the end, returning all of it.
	def ReadOutputAll()
		This._RequireChild()
		_cAll_ = ""
		_cChunk_ = StzEngineProcessReadStdout(@pChildHandle)
		while _cChunk_ != ""
			_cAll_ += _cChunk_
			_cChunk_ = StzEngineProcessReadStdout(@pChildHandle)
		end
		return _cAll_

		def Output()
			return This.ReadOutputAll()

	def ReadError()
		This._RequireChild()
		return StzEngineProcessReadStderr(@pChildHandle)

		def ReadStderr()
			return This.ReadError()

	def ReadErrorAll()
		This._RequireChild()
		_cAll_ = ""
		_cChunk_ = StzEngineProcessReadStderr(@pChildHandle)
		while _cChunk_ != ""
			_cAll_ += _cChunk_
			_cChunk_ = StzEngineProcessReadStderr(@pChildHandle)
		end
		return _cAll_

		def Error()
			return This.ReadErrorAll()

	# Reads what the child has ALREADY printed, without waiting: "" when
	# nothing has arrived yet, and "" again once its stdout has closed --
	# StdoutEnded() tells the two apart. This is the read a RUNNER polls so a
	# tour that prints nothing and never ends cannot hold it (Testoor TR1):
	#   while oP.IsRunning() { c = oP.ReadAvailable() ... check the clock }
	def ReadAvailable()
		This._RequireChild()
		_x_ = StzEngineProcessReadStdoutAvailable(@pChildHandle)
		if isNumber(_x_)
			# -2: the child closed its stdout and it is drained; -1: there is
			# no pipe any more (std's wait() or kill() closed it). Either way
			# nothing more will come.
			if _x_ = -2 or _x_ = -1  @bStdoutEnded = 1  ok
			return ""
		ok
		return _x_

		def ReadStdoutAvailable()
			return This.ReadAvailable()

	def StdoutEnded()
		return @bStdoutEnded = 1

	# Waits up to pnMs milliseconds for the child to exit: its exit code once
	# it has, -2 while it still runs. WaitFor(0) is a poll.
	def WaitFor(pnMs)
		This._RequireChild()
		if @bWaited  return @nCachedExit  ok
		_n_ = StzEngineProcessWaitFor(@pChildHandle, 0 + pnMs)
		if _n_ != -2
			@nCachedExit = _n_
			@bWaited = 1
		ok
		return _n_

	def IsRunning()
		if @pChildHandle = "" or @bWaited  return 0  ok
		return This.WaitFor(0) = -2

	# Waits for the child to exit and returns its exit code. Idempotent.
	def Wait()
		This._RequireChild()
		@nCachedExit = StzEngineProcessWait(@pChildHandle)
		@bWaited = 1
		return @nCachedExit

	# The exit code after Wait() (Wait() is called for you if you have not).
	def ExitCode()
		if NOT @bWaited
			return This.Wait()
		ok
		return @nCachedExit

	def Succeeded()
		return This.ExitCode() = 0

	def Failed()
		return NOT This.Succeeded()

	# EFFECTFUL. Terminates the child now. Returns TRUE on success.
	def Kill()
		This._RequireChild()
		_n_ = StzEngineProcessKill(@pChildHandle)
		@bWaited = 1
		return _n_ = 1

		def Terminate()
			return This.Kill()

	# Frees the child handle. If the child is still running it is killed
	# first, so a dropped handle never leaks a process. Ring has no
	# destructors -- call this when done with a child.
	def Close()
		if @pChildHandle != ""
			StzEngineProcessSpawnFree(@pChildHandle)
			@pChildHandle = ""
		ok

		def Free()
			This.Close()

		def CloseQ()
			This.Close()
			return This

	def _RequireChild()
		if @pChildHandle = ""
			StzRaise("This stzProcess has no spawned child. Use Spawn() or SpawnProcess() first.")
		ok

	  #---------------------------#
	 #  THIS PROCESS -- identity #
	#---------------------------#

	def Id()
		return StzEngineProcessPid()

		def Pid()
			return This.Id()

		def ProcessId()
			return This.Id()

	# Seconds since this process started (real monotonic uptime, not epoch
	# wall-clock).
	def Uptime()
		return StzEngineProcessUptimeS()

		def UptimeInSeconds()
			return This.Uptime()

	def UptimeInMilliseconds()
		return StzEngineProcessUptimeMs()

		def UptimeMs()
			return This.UptimeInMilliseconds()

	def UptimeInNanoseconds()
		return StzEngineProcessUptimeNs()

		def UptimeNs()
			return This.UptimeInNanoseconds()

	# The engine senses (perf P1, stz_perf.dll): what THIS process
	# weighs and computes. Sensing-kind reads, no side effects.

	# Current resident memory (working set), in bytes.
	def MemoryBytes()
		return StzEnginePerfMemRss()

		def Rss()
			return This.MemoryBytes()

	# The high-water mark: the most memory this process EVER held.
	# A crash-sized leak announces itself here first.
	def PeakMemoryBytes()
		return StzEnginePerfMemPeak()

	# CPU time actually computed (user + kernel). Advances only when
	# this process WORKS -- a sleeping process gains uptime but no CPU
	# time. Utilization over a window = delta(cpu) / (delta(uptime) * cores).
	def CpuTimeNs()
		return StzEnginePerfCpuNs()

	def CpuTimeMs()
		return StzEnginePerfCpuNs() / 1000000

	  #-----------------------------#
	 #  MACHINE FACTS (the engine  #
	 #  is the single source)      #
	#-----------------------------#

	# The raw engine architecture tag, as Zig names it: "x86_64", "aarch64"...
	def EngineArchitecture()
		return StzEngineProcessArch()

		def EngineArch()
			return This.EngineArchitecture()

	# The canonical Softanza architecture name: x64 / arm64 / x86 / arm.
	# THE ONE reconciliation seam between Zig's vocabulary and Softanza's.
	def Architecture()
		_cRaw_ = StzLower(StzEngineProcessArch())
		if _cRaw_ = "x86_64" or _cRaw_ = "amd64"
			return "x64"
		but _cRaw_ = "aarch64" or _cRaw_ = "arm64"
			return "arm64"
		but _cRaw_ = "x86" or _cRaw_ = "i386" or _cRaw_ = "i686"
			return "x86"
		but _cRaw_ = "arm" or StzFindFirst("arm", _cRaw_) = 1
			return "arm"
		ok
		# Unknown arch: return the raw tag rather than guess.
		return _cRaw_

		def Arch()
			return This.Architecture()

	# The OS tag as the engine reports it: "windows", "linux", "macos"...
	def OperatingSystem()
		return StzEngineProcessOs()

		def OS()
			return This.OperatingSystem()

		def OSName()
			return This.OperatingSystem()

	# 0 = little-endian, 1 = big-endian.
	def IsLittleEndian()
		return StzEngineProcessEndian() = 0

	def IsBigEndian()
		return StzEngineProcessEndian() = 1

	def Endianness()
		if This.IsLittleEndian()
			return "little"
		ok
		return "big"

	# Native pointer size in BYTES (4 or 8).
	def PointerSize()
		return StzEngineProcessPtrSize()

		def PointerSizeInBytes()
			return This.PointerSize()

	# Native word size in BITS (32 or 64) -- pointer size * 8. This is the
	# fact stzOperatingSystem.BitSize() should agree with, because both now
	# read the ONE engine source.
	def BitSize()
		return This.PointerSize() * 8

		def WordSize()
			return This.BitSize()

	def Is64Bit()
		return This.PointerSize() = 8

	def Is32Bit()
		return This.PointerSize() = 4

	  #-----------------------------#
	 #  SNAPSHOT                    #
	#-----------------------------#

	# All the process facts in one named-pair list -- handy for logging or
	# feeding into a knowledge graph.
	def Info()
		return [
			[ "pid", This.Id() ],
			[ "uptime_s", This.Uptime() ],
			[ "architecture", This.Architecture() ],
			[ "engine_arch", This.EngineArchitecture() ],
			[ "os", This.OperatingSystem() ],
			[ "endianness", This.Endianness() ],
			[ "pointer_size", This.PointerSize() ],
			[ "bit_size", This.BitSize() ]
		]

	def Show()
		_aInfo_ = This.Info()
		? "Process:"
		_nLen_ = len(_aInfo_)
		for _i_ = 1 to _nLen_
			? "  " + _aInfo_[_i_][1] + " = " + _aInfo_[_i_][2]
		next
