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

	def init()
		# Stateless for the introspection face: every fact is read live from
		# the engine.

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
