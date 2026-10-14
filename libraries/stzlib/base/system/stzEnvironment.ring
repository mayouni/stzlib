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

# Reads and changes the environment of the running process: variables, working folder, host name, user name and CPU count.
#
# It holds no state; every call goes to the operating system through the engine. SetVar and UnsetVar
# change the environment of this process only and of the processes it starts, never the machine's
# saved settings. ChangeDirectory moves the whole process, and Ring's load resolves relative paths
# against the working folder. A variable set to an empty text counts as not set for HasVar.
# Variables can contain secrets, so print names, not values.
#
#   receiver   o1 = new stzEnvironment()
#   example    ? o1.HasVar("STZ_DOC_INVENTED")
#              #--> 0
#              ? o1.SetVar("STZ_DOC_INVENTED", "hello")
#              #--> 1
#              ? o1.Var("STZ_DOC_INVENTED")
#              #--> hello
#              ? o1.UnsetVar("STZ_DOC_INVENTED")
#              #--> 1
#              ? o1.HasVar("STZ_DOC_INVENTED")
#              #--> 0
#              ? o1.CpuCount() > 0
#              #--> 1
#   see        stzProcess, stzCurrentSystem
class stzEnvironment from stzObject

	# Opens a view on the environment of the running process: its variables, working folder, host name, user and CPU count.
	#
	#   returns    nothing; the object is built
	#   warning    the object holds no state, so every method reads the process itself
	#   see        Var, WorkingDirectory
	def init()
		# Stateless: every method reads or writes the live OS environment
		# through the engine. There is nothing to hold.

	  #-----------------------#
	 #  VARIABLES (sensing)  #
	#-----------------------#

	# Returns the value of an environment variable; an empty text when it is not set.
	#
	#   pcName     the variable's name
	#   returns    a text
	#   warning    a name that is not a text raises an error; on Windows the name is matched without
	#              regard to case
	#   see        HasVar, SetVar
	#@ aka  The value of an environment variable, or "" if it is not set.
	def Var(pcName)
		if NOT isString(pcName)
			StzRaise("Incorrect param type! pcName must be a string.")
		ok
		return StzEngineSystemEnvGet(pcName)

		def GetVar(pcName)
			return This.Var(pcName)

		def ValueOf(pcName)
			return This.Var(pcName)

	# TRUE if the variable is set to a non-empty value.
	#
	#   pcName     the variable's name
	#   returns    TRUE or FALSE
	#   warning    a variable set to an empty text counts as not set
	#   see        Var, SetVar
	#@ aka  TRUE if the variable is set (even to an empty string is reported as unset by the OS get, which returns "" for both -- so Has means "get returns a non-empty value").
	def HasVar(pcName)
		return StzEngineSystemEnvGet(pcName) != ""

		def Has(pcName)
			return This.HasVar(pcName)

	# Returns all the variables of the process as a list of [ name, value ] pairs.
	#
	#   returns    a list of pairs
	#   warning    the values can hold secrets: do not print the whole list
	#   see        VariableNames, NumberOfVariables
	#@ aka  The whole environment as a list of [ name, value ] pairs.
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

	# Returns just the names of all the variables of the process.
	#
	#   returns    a list of texts
	#   see        Variables, NumberOfVariables
	#@ aka  Just the variable NAMES.
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

	# Returns how many variables the process has.
	#
	#   returns    a number
	#   see        Variables
	def NumberOfVariables()
		return len(StzEngineSystemEnvList())

		def CountVariables()
			return This.NumberOfVariables()

	  #------------------------#
	 #  VARIABLES (effectful) #
	#------------------------#

	# Sets a variable for this process and the processes it starts; the change ends with the process.
	#
	#   pcName     the variable's name
	#   pcValue    its new value
	#   returns    TRUE if set
	#   warning    both must be texts, else an error is raised; the real environment of the machine
	#              is not changed
	#   see        UnsetVar, Var
	#@ aka  EFFECTFUL. Sets a variable for THIS process and every child spawned afterwards. Returns TRUE on success. The value is visible to a subsequent Var() -- get and set share the OS-authoritative store.
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

	# Removes a variable from this process; one that was never set also answers TRUE.
	#
	#   pcName     the variable's name
	#   returns    TRUE
	#   warning    a name that is not a text raises an error
	#   see        SetVar, HasVar
	#@ aka  EFFECTFUL. Removes a variable.
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

	# Returns the folder the process is working in.
	#
	#   returns    a text
	#   warning    relative paths, and files written without a path, land here
	#   see        ChangeDirectory
	#@ aka  The REAL process working directory (not a virtual cursor). Sensing.
	def WorkingDirectory()
		return StzEngineSystemCwdGet()

		def Cwd()
			return This.WorkingDirectory()

		def CurrentDirectory()
			return This.WorkingDirectory()

	# Moves the process to another folder.
	#
	#   pcPath     the folder to move to
	#   returns    TRUE if it moved, FALSE if the folder does not exist
	#   warning    a failed move leaves the folder as it was; the move affects the whole process,
	#              including how load resolves relative paths
	#   see        WorkingDirectory
	#@ aka  EFFECTFUL. Changes the real process working directory. Returns TRUE on success (FALSE if the path does not exist or is not a directory).
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

	# Returns the name of the machine.
	#
	#   returns    a text
	#   see        UserName
	def HostName()
		return StzEngineSystemHostname()

		def ComputerName()
			return This.HostName()

		def MachineName()
			return This.HostName()

	# Returns the name of the user running the process.
	#
	#   returns    a text
	#   see        HostName
	def UserName()
		return StzEngineSystemUsername()

		def LoginName()
			return This.UserName()

	  #-------------------------#
	 #  MACHINE                #
	#-------------------------#

	# Returns how many logical processors the machine has.
	#
	#   returns    a number
	#   see        HostName
	def CpuCount()
		return StzEngineSystemCpuCount()

		def NumberOfCPUs()
			return This.CpuCount()

		def ProcessorCount()
			return This.CpuCount()
