#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZENVIRONMENT             #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The process ENVIRONMENT -- variables, the   #
#                  working directory, host and user identity.  #
#                  Engine-backed (stz_system.dll); the true    #
#                  work lives in Zig, reusable by any binding. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Part of the Softanza System Foundation (see
# base/doc/design/SOFTANZA_SYSTEM_FOUNDATION.md). Reading the environment is
# free SENSING; the three mutating verbs -- SetVar, UnsetVar,
# ChangeDirectory -- are EFFECTFUL, and are the operations a Virtual System
# twin will later rehearse and gate behind an UpdatePlan. They are named to
# read the same whether performed directly or rehearsed.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzEnvironmentQ()
	return new stzEnvironment()

	func Env()
		return new stzEnvironment()

# Sugar over a default instance (Law 1: globals are sugar, not naked state).

func EnvVar(pcName)
	_oE_ = new stzEnvironment()
	return _oE_.Var(pcName)

func SetEnvVar(pcName, pcValue)
	_oE_ = new stzEnvironment()
	_oE_.SetVar(pcName, pcValue)

func WorkingDirectory()
	_oE_ = new stzEnvironment()
	return _oE_.WorkingDirectory()

func HostName()
	_oE_ = new stzEnvironment()
	return _oE_.HostName()

func UserName()
	_oE_ = new stzEnvironment()
	return _oE_.UserName()


  #===================#
 #  STZENVIRONMENT   #
#===================#

class stzEnvironment from stzObject

	def init()
		# Stateless: every method reads or writes the live OS environment
		# through the engine. There is nothing to hold.

	  #-----------------------#
	 #  VARIABLES (sensing)  #
	#-----------------------#

	# The value of an environment variable, or "" if it is not set.
	def Var(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok
		return StzEngineSystemEnvGet(pcName)

		def GetVar(pcName)
			return This.Var(pcName)

		def ValueOf(pcName)
			return This.Var(pcName)

	# TRUE if the variable is set (even to an empty string is reported as
	# unset by the OS get, which returns "" for both -- so Has means
	# "get returns a non-empty value").
	def HasVar(pcName)
		return StzEngineSystemEnvGet(pcName) != ""

		def Has(pcName)
			return This.HasVar(pcName)

	# The whole environment as a list of [ name, value ] pairs.
	def Variables()
		_aRaw_ = StzEngineSystemEnvList()
		_aResult_ = []
		_nLen_ = len(_aRaw_)
		for _i_ = 1 to _nLen_
			_cEntry_ = _aRaw_[_i_]
			_nEq_ = StzFindFirst("=", _cEntry_)
			if _nEq_ > 0
				_aResult_ + [ StzLeft(_cEntry_, _nEq_ - 1),
					      StzMidToEnd(_cEntry_, _nEq_ + 1) ]
			else
				_aResult_ + [ _cEntry_, "" ]
			ok
		next
		return _aResult_

		def All()
			return This.Variables()

	# Just the variable NAMES.
	def VariableNames()
		_aPairs_ = This.Variables()
		_aNames_ = []
		_nLen_ = len(_aPairs_)
		for _i_ = 1 to _nLen_
			_aNames_ + _aPairs_[_i_][1]
		next
		return _aNames_

		def Names()
			return This.VariableNames()

	def NumberOfVariables()
		return len(StzEngineSystemEnvList())

		def CountVariables()
			return This.NumberOfVariables()

	  #------------------------#
	 #  VARIABLES (effectful) #
	#------------------------#

	# EFFECTFUL. Sets a variable for THIS process and every child spawned
	# afterwards. Returns TRUE on success. The value is visible to a
	# subsequent Var() -- get and set share the OS-authoritative store.
	def SetVar(pcName, pcValue)
		if NOT (isString(pcName) and isString(pcValue))
			StzRaise("Incorrect param type! pcName and pcValue must be strings.")
		ok
		return StzEngineSystemEnvSet(pcName, pcValue) = 1

		def Assign(pcName, pcValue)
			return This.SetVar(pcName, pcValue)

		def SetVarQ(pcName, pcValue)
			This.SetVar(pcName, pcValue)
			return This

	# EFFECTFUL. Removes a variable.
	def UnsetVar(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok
		return StzEngineSystemEnvUnset(pcName) = 1

		def Unset(pcName)
			return This.UnsetVar(pcName)

		def RemoveVar(pcName)
			return This.UnsetVar(pcName)

	  #-------------------------#
	 #  WORKING DIRECTORY      #
	#-------------------------#

	# The REAL process working directory (not a virtual cursor). Sensing.
	def WorkingDirectory()
		return StzEngineSystemCwdGet()

		def Cwd()
			return This.WorkingDirectory()

		def CurrentDirectory()
			return This.WorkingDirectory()

	# EFFECTFUL. Changes the real process working directory. Returns TRUE on
	# success (FALSE if the path does not exist or is not a directory).
	def ChangeDirectory(pcPath)
		if NOT isString(pcPath)
			StzRaise("Incorrect param type! pcPath must be a string.")
		ok
		return StzEngineSystemCwdSet(pcPath) = 1

		def ChangeWorkingDirectory(pcPath)
			return This.ChangeDirectory(pcPath)

		def Cd(pcPath)
			return This.ChangeDirectory(pcPath)

		def ChangeDirectoryQ(pcPath)
			This.ChangeDirectory(pcPath)
			return This

	  #-------------------------#
	 #  HOST / USER IDENTITY   #
	#-------------------------#

	def HostName()
		return StzEngineSystemHostname()

		def ComputerName()
			return This.HostName()

		def MachineName()
			return This.HostName()

	def UserName()
		return StzEngineSystemUsername()

		def LoginName()
			return This.UserName()

	  #-------------------------#
	 #  MACHINE                #
	#-------------------------#

	def CpuCount()
		return StzEngineSystemCpuCount()

		def NumberOfCPUs()
			return This.CpuCount()

		def ProcessorCount()
			return This.CpuCount()
