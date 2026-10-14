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

# Tells the facts of the running program (identity, uptime, memory, machine) and manages one child process: spawn, stream, wait, kill.
#
# Without a child, an object reads the running program: its id, uptime on a monotonic clock, memory,
# processor time, architecture, operating system and byte order, all delegated to the engine. Spawn
# starts a child through the platform shell and SpawnIn starts one from an argument list with no
# shell; both are effectful and start a real program. The usage contract avoids a pipe deadlock:
# read the child's output to its end, then Wait, then Free. Kill ends the child whose handle the
# object holds and never looks a process up by name. WaitFor, IsRunning and SpawnIn need an engine
# built from the current source; an older stz_system.dll lacks them and raises R3.
#
#   receiver   o1 = new stzProcess()
#   example    ? o1.HasChild()
#              #--> 0
#              ? o1.BitSize()
#              #--> 64
#              o2 = SpawnProcess("echo hello")
#              ? trim(o2.ReadOutputAll())
#              #--> hello
#              ? o2.Wait()
#              #--> 0
#              o2.Free()
#   see        stzEnvironment, stzCurrentSystem, stzSystemCall
class stzProcess from stzObject

	# Only used by the control (child) face; NULL for the introspection face.
	@pChildHandle = ""
	@nCachedExit = -1
	@bWaited = 0
	@bStdoutEnded = 0

	# Creates a handle on the running program, with no child attached; a child comes only from Spawn or SpawnIn.
	#
	#   returns    nothing; the object is built
	#   note       the identity methods work at once; the child methods raise until a child is
	#              attached
	#   see        Spawn, SpawnIn
	def init()
		# Stateless for the introspection face: every fact is read live from
		# the engine. The control face fills @pChildHandle on Spawn().

	  #-----------------------------#
	 #  CHILD PROCESS -- control    #
	 #  (Phase 1: spawn / stream /  #
	 #   wait / kill)               #
	#-----------------------------#
	# Starts a child process from a command line run by the platform shell (cmd.exe /c on Windows), with its output piped back.
	#
	#   pcCommand   the command line to run, a non-empty text
	#   returns     nothing; the object now manages the child
	#   note        run only with echo and an invented word, and with exit 3; the child was waited
	#               for each time
	#   warning     effectful: it starts a real program; an empty or non-text command raises an
	#               error; the shell parses the command, so never build it from untrusted text
	#   see         SpawnIn, ReadOutputAll, Wait, Kill
	#@ aka  EFFECTFUL. Spawning, killing -- the operations a Virtual System twin will later rehearse and gate behind an UpdatePlan. The USAGE CONTRACT (to avoid a pipe deadlock): read the output to EOF, THEN Wait(); keep stderr modest unless you also drain it.
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

	# Starts a program from its argument list with no shell between, in a folder of your choosing.
	#
	#   pcDir      the folder the child works in, an empty text to inherit
	#   pacArgv    the program followed by its arguments, a non-empty list of texts
	#   returns    the process itself, so calls chain
	#   note       run with cmd /c echo and with ring on a scratch script, against the newer engine
	#              build of a sibling worktree
	#   warning    effectful: it starts a real program; an argument with a space or a quote reaches
	#              the program unparsed, and Kill reaches the program itself; a program that cannot
	#              start raises Failed to spawn; needs an engine built from the current source: the
	#              stz_system.dll of this worktree is older than the source and lacks the entry
	#              point, so there the call raises R3 Calling Function without definition
	#   see        Spawn, Kill
	#@ aka  Spawns a program by its ARGV, no shell between, in a working directory of your choosing ("" inherits). The form a RUNNER wants: an argument with a quote or a space reaches the program unparsed, and Kill() reaches the program itself -- through the shell form it reached only cmd.exe and left the program running (measured, Testoor TR1). Each argv item is a string; the first is the program. oP.SpawnIn
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

	# Returns the operating-system process id of the child.
	#
	#   returns    a number
	#   note       run on a child that had just printed one word
	#   warning    raises an error when no child was spawned
	#   see        Id, Spawn
	#@ aka  The OS process id of the spawned child.
	def ChildPid()
		This._RequireChild()
		return StzEngineProcessChildPid(@pChildHandle)

	# Reads the next chunk of the child's standard output, waiting for it; an empty text means the stream ended.
	#
	#   returns    a text
	#   warning    raises an error when no child was spawned; read the output to the end before
	#              Wait, or a child with much output can block on a full pipe
	#   see        ReadOutputAll, ReadAvailable
	#@ aka  Reads the next available chunk of the child's stdout. Blocks until at least one byte arrives, or returns "" at end of stream. This is the STREAMING read -- call it in a loop.
	def ReadOutput()
		This._RequireChild()
		return StzEngineProcessReadStdout(@pChildHandle)

		def ReadStdout()
			return This.ReadOutput()

	# Reads the child's standard output to its end and returns all of it.
	#
	#   returns    a text
	#   note       echo output came back with its trailing newline
	#   warning    raises an error when no child was spawned; it blocks until the child closes its
	#              output
	#   see        ReadOutput, Wait
	#@ aka  Reads the child's stdout to the end, returning all of it.
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

	# Reads the next chunk of the child's error output, waiting for it; an empty text means the stream ended.
	#
	#   returns    a text
	#   warning    raises an error when no child was spawned
	#   see        ReadErrorAll, ReadOutput
	def ReadError()
		This._RequireChild()
		return StzEngineProcessReadStderr(@pChildHandle)

		def ReadStderr()
			return This.ReadError()

	# Reads the child's error output to its end and returns all of it.
	#
	#   returns    a text
	#   note       tested with a command that wrote one word to the error stream
	#   warning    raises an error when no child was spawned; it blocks until the child closes its
	#              error output
	#   see        ReadError, ReadOutputAll
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

	# Reads what the child has printed so far without waiting; an empty text when there is nothing yet or the stream has ended.
	#
	#   returns    a text
	#   note       run on a child that printed two lines over three seconds
	#   warning    raises an error when no child was spawned; the end of the stream is signalled
	#              only through StdoutEnded, so poll until it is TRUE
	#   see        StdoutEnded, ReadOutput
	#@ aka  Reads what the child has ALREADY printed, without waiting: "" when nothing has arrived yet, and "" again once its stdout has closed -- StdoutEnded() tells the two apart. This is the read a RUNNER polls so a tour that prints nothing and never ends cannot hold it (Testoor TR1): while oP.IsRunning() { c = oP.ReadAvailable() ... check the clock }
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

	# TRUE if ReadAvailable has seen the end of the child's output.
	#
	#   returns    TRUE or FALSE
	#   warning    it stays FALSE if you read with ReadOutput or ReadOutputAll only, because only
	#              ReadAvailable sets it
	#   see        ReadAvailable
	def StdoutEnded()
		return @bStdoutEnded = 1

	# Waits up to a number of milliseconds for the child to exit and returns its exit code, or -2 while it still runs.
	#
	#   pnMs       how long to wait at most, in milliseconds, 0 to only look
	#   returns    a number: the exit code, or -2 if still running
	#   note       run against the newer engine build of a sibling worktree: -2 after 100 ms on a
	#              running child, 0 on a finished one
	#   warning    raises an error when no child was spawned; after a Kill the exit code reads -1;
	#              needs an engine built from the current source: the stz_system.dll of this
	#              worktree is older than the source and lacks the entry point, so there the call
	#              raises R3 Calling Function without definition
	#   see        IsRunning, Wait, Kill
	#@ aka  Waits up to pnMs milliseconds for the child to exit: its exit code once it has, -2 while it still runs. WaitFor(0) is a poll.
	def WaitFor(pnMs)
		This._RequireChild()
		if @bWaited  return @nCachedExit  ok
		_n_ = StzEngineProcessWaitFor(@pChildHandle, 0 + pnMs)
		if _n_ != -2
			@nCachedExit = _n_
			@bWaited = 1
		ok
		return _n_

	# TRUE if the child has been spawned and has not exited.
	#
	#   returns    TRUE or FALSE
	#   note       run against the newer engine build of a sibling worktree
	#   warning    FALSE when no child was spawned, instead of an error; needs an engine built from
	#              the current source: the stz_system.dll of this worktree is older than the source
	#              and lacks the entry point, so there the call raises R3 Calling Function without
	#              definition
	#   see        WaitFor, Wait
	def IsRunning()
		if @pChildHandle = "" or @bWaited  return 0  ok
		return This.WaitFor(0) = -2

	# Waits until the child exits and returns its exit code.
	#
	#   returns    a number, the exit code
	#   note       exit code 0 for echo and 3 for exit 3
	#   warning    raises an error when no child was spawned; read the output to the end first
	#   see        WaitFor, ExitCode, ReadOutputAll
	#@ aka  Waits for the child to exit and returns its exit code. Idempotent.
	def Wait()
		This._RequireChild()
		@nCachedExit = StzEngineProcessWait(@pChildHandle)
		@bWaited = 1
		return @nCachedExit

	# Returns the child's exit code, waiting for the child first if it has not been waited for.
	#
	#   returns    a number
	#   note       exit 3 gave 3
	#   warning    a child that was killed reads -1
	#   see        Wait, Succeeded
	#@ aka  The exit code after Wait() (Wait() is called for you if you have not).
	def ExitCode()
		if NOT @bWaited
			return This.Wait()
		ok
		return @nCachedExit

	# TRUE if the child exited with code 0.
	#
	#   returns    TRUE or FALSE
	#   warning    it waits for the child if needed
	#   see        Failed, ExitCode
	def Succeeded()
		return This.ExitCode() = 0

	# TRUE if the child did not exit with code 0, which includes a killed child.
	#
	#   returns    TRUE or FALSE
	#   warning    it waits for the child if needed
	#   see        Succeeded, ExitCode
	def Failed()
		return NOT This.Succeeded()

	# Ends the child's process by force and returns whether the engine did it.
	#
	#   returns    TRUE if the child was killed
	#   note       run on a child of this session that was busy for three seconds
	#   warning    effectful; raises an error when no child was spawned; kills the process whose
	#              handle this object holds, never one found by name; the exit code then reads -1
	#   see        Free, WaitFor
	#@ aka  EFFECTFUL. Terminates the child now. Returns TRUE on success.
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

		# Releases the child handle so the engine can reap it; the object can then spawn again.
		#
		#   returns    nothing
		#   warning    call it after Wait; it does not kill a running child
		#   see        Wait, Spawn
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

	# Returns the id of the running program itself.
	#
	#   returns    a number
	#   see        ChildPid, Uptime
	def Id()
		return StzEngineProcessPid()

		def Pid()
			return This.Id()

		def ProcessId()
			return This.Id()

	# Returns how many seconds the running program has been up.
	#
	#   returns    a number
	#   note       measured on a monotonic clock fixed when the engine was loaded
	#   see        UptimeInMilliseconds, UptimeInNanoseconds
	#@ aka  Seconds since this process started (real monotonic uptime, not epoch wall-clock).
	def Uptime()
		return StzEngineProcessUptimeS()

		def UptimeInSeconds()
			return This.Uptime()

	# Returns how many milliseconds the running program has been up.
	#
	#   returns    a number
	#   see        Uptime, UptimeInNanoseconds
	def UptimeInMilliseconds()
		return StzEngineProcessUptimeMs()

		def UptimeMs()
			return This.UptimeInMilliseconds()

	# Returns how many nanoseconds the running program has been up.
	#
	#   returns    a number
	#   see        Uptime, UptimeInMilliseconds
	def UptimeInNanoseconds()
		return StzEngineProcessUptimeNs()

		def UptimeNs()
			return This.UptimeInNanoseconds()

	# Returns the resident memory of the running program, in bytes.
	#
	#   returns    a number
	#   note       never above the peak
	#   see        PeakMemoryBytes
	#@ aka  The engine senses (perf P1, stz_perf.dll): what THIS process weighs and computes. Sensing-kind reads, no side effects.
	def MemoryBytes()
		return StzEnginePerfMemRss()

		def Rss()
			return This.MemoryBytes()

	# Returns the highest resident memory the running program has reached, in bytes.
	#
	#   returns    a number
	#   see        MemoryBytes
	#@ aka  The high-water mark: the most memory this process EVER held. A crash-sized leak announces itself here first.
	def PeakMemoryBytes()
		return StzEnginePerfMemPeak()

	# Returns the processor time the running program has used, in nanoseconds.
	#
	#   returns    a number
	#   warning    Windows counts processor time in ticks of 15.6 ms, so a short interval is one
	#              tick, not a measurement
	#   see        CpuTimeMs
	#@ aka  CPU time actually computed (user + kernel). Advances only when this process WORKS -- a sleeping process gains uptime but no CPU time. Utilization over a window = delta(cpu) / (delta(uptime) * cores).
	def CpuTimeNs()
		return StzEnginePerfCpuNs()

	# Returns the processor time the running program has used, in milliseconds.
	#
	#   returns    a number
	#   warning    same tick size as CpuTimeNs
	#   see        CpuTimeNs
	def CpuTimeMs()
		return StzEnginePerfCpuNs() / 1000000

	  #-----------------------------#
	 #  MACHINE FACTS (the engine  #
	 #  is the single source)      #
	#-----------------------------#

	# Returns the architecture tag as the engine spells it, such as x86_64 or aarch64.
	#
	#   returns    a text
	#   see        Architecture
	#@ aka  The raw engine architecture tag, as Zig names it: "x86_64", "aarch64"...
	def EngineArchitecture()
		return StzEngineProcessArch()

		def EngineArch()
			return This.EngineArchitecture()

	# Returns the canonical architecture name: x64, arm64, x86 or arm.
	#
	#   returns    a text
	#   warning    an unrecognised tag is returned as the engine gave it
	#   see        EngineArchitecture
	#@ aka  The canonical Softanza architecture name: x64 / arm64 / x86 / arm. THE ONE reconciliation seam between Zig's vocabulary and Softanza's.
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

	# Returns the name of the operating system, such as windows, linux or macos, in lower case.
	#
	#   returns    a text
	#   see        Architecture
	#@ aka  The OS tag as the engine reports it: "windows", "linux", "macos"...
	def OperatingSystem()
		return StzEngineProcessOs()

		def OS()
			return This.OperatingSystem()

		def OSName()
			return This.OperatingSystem()

	# TRUE if the machine stores the low byte of a number first.
	#
	#   returns    TRUE or FALSE
	#   see        IsBigEndian, Endianness
	#@ aka  0 = little-endian, 1 = big-endian.
	def IsLittleEndian()
		return StzEngineProcessEndian() = 0

	# TRUE if the machine stores the high byte of a number first.
	#
	#   returns    TRUE or FALSE
	#   see        IsLittleEndian, Endianness
	def IsBigEndian()
		return StzEngineProcessEndian() = 1

	# Returns little or big, the byte order of the machine.
	#
	#   returns    a text
	#   see        IsLittleEndian
	def Endianness()
		if This.IsLittleEndian()
			return "little"
		ok
		return "big"

	# Returns the size of a pointer on this machine in bytes, 8 on a 64-bit one.
	#
	#   returns    a number
	#   see        BitSize
	#@ aka  Native pointer size in BYTES (4 or 8).
	def PointerSize()
		return StzEngineProcessPtrSize()

		def PointerSizeInBytes()
			return This.PointerSize()

	# Returns the width of the machine word in bits, 64 on a 64-bit machine.
	#
	#   returns    a number
	#   see        PointerSize
	#@ aka  Native word size in BITS (32 or 64) -- pointer size * 8. This is the fact stzOperatingSystem.BitSize() should agree with, because both now read the ONE engine source.
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

	# Returns the facts about the running program as a list of [ name, value ] pairs: pid, uptime_s, architecture, os, endianness and more.
	#
	#   returns    a list of 8 pairs
	#   see        Show, Id
	#@ aka  All the process facts in one named-pair list -- handy for logging or feeding into a knowledge graph.
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

	# Prints the facts of Info, one name = value line each.
	#
	#   returns    nothing; it prints
	#   see        Info
	def Show()
		_aInfo_ = This.Info()
		? "Process:"
		_nLen_ = len(_aInfo_)
		for _i_ = 1 to _nLen_
			? "  " + _aInfo_[_i_][1] + " = " + _aInfo_[_i_][2]
		next
