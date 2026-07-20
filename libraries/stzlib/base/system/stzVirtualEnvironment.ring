#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V0.9) - STZVIRTUALENVIRONMENT         #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Phase 3, the PROCESS/ENVIRONMENT            #
#                  specialization of the Virtual System twin.  #
#                  Rehearse environment-variable changes, a    #
#                  working-directory change, and a sequence    #
#                  of process spawns; read the plan ("this     #
#                  will set PATH, change dir, spawn 2          #
#                  children"); commit atomically. Especially   #
#                  valuable because process/env effects are    #
#                  otherwise invisible until they happen.      #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Same rehearse -> plan -> commit shape as the file twin (Phase 2), reusing the
# generic stzVirtualSystem core unchanged. The state is an in-memory environment
# (vars + cwd + a queue of pending spawns); the bridge is the ONLY thing that
# touches the real environment/process, delegating to the effectful verbs of
# stzEnvironment (SetVar/UnsetVar/ChangeDirectory) and the global SpawnProcess().
# The twin holds no reference to reality: no var is set, no dir changed, no child
# spawned until plan.Execute().

  #=============#
 #  FUNCTIONS  #
#=============#

func StzVirtualEnvironmentQ()
	return new stzVirtualEnvironment()

func NewVirtualEnvironment()
	return new stzVirtualEnvironment()

	func VirtualEnvironment()
		return new stzVirtualEnvironment()


  #=======================#
 #  STZENVIRONMENTSTATE  #
#=======================#
#
# The virtual state: environment variables (each [ name, value, origin ]), the
# working directory, and a queue of pending spawn commands.

class stzEnvironmentState from stzObject

	@aVars = []
	@cCwd = ""
	@cCwdOrigin = ""
	@aSpawns = []

	def init()

	def _IndexOf(pcName)
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			if @aVars[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def HasVar(pcName)
		return This._IndexOf(pcName) > 0

	def VarValue(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			return @aVars[_i_][2]
		ok
		return ""

	def OriginOfVar(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			return @aVars[_i_][3]
		ok
		return ""

	def PutVar(pcName, pcValue, pcOrigin)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			@aVars[_i_][2] = pcValue
		else
			@aVars + [ "" + pcName, "" + pcValue, "" + pcOrigin ]
		ok

	def RemoveVar(pcName)
		_aNew_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			if @aVars[_i_][1] != pcName
				_aNew_ + @aVars[_i_]
			ok
		next
		@aVars = _aNew_

	def Cwd()
		return @cCwd

	def CwdOrigin()
		return @cCwdOrigin

	def SetCwd(pcPath, pcOrigin)
		@cCwd = "" + pcPath
		@cCwdOrigin = "" + pcOrigin

	def PendingSpawns()
		return @aSpawns

	def AddSpawn(pcCommand)
		@aSpawns + ("" + pcCommand)

	def Vars()
		return @aVars

	def VarNames()
		_a_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			_a_ + @aVars[_i_][1]
		next
		return _a_

	def NumberOfVars()
		return len(@aVars)

	def NumberOfPendingSpawns()
		return len(@aSpawns)

	# The domain hook the generic twin calls to rehearse an operation.
	def Apply(oOp)
		_t_ = oOp.Type()
		if _t_ = "set_var"
			This.PutVar(oOp.Param("name"), oOp.Param("value"), "virtual")
		but _t_ = "unset_var"
			This.RemoveVar(oOp.Param("name"))
		but _t_ = "change_dir"
			This.SetCwd(oOp.Param("path"), "virtual")
		but _t_ = "spawn_process"
			This.AddSpawn(oOp.Param("command"))
		ok

	def VarsCopy()
		_a_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			_a_ + [ @aVars[_i_][1], @aVars[_i_][2], @aVars[_i_][3] ]
		next
		return _a_

	def SpawnsCopy()
		_a_ = []
		_n_ = len(@aSpawns)
		for _i_ = 1 to _n_
			_a_ + @aSpawns[_i_]
		next
		return _a_

	def SetVars(paVars)
		@aVars = paVars

	def SetSpawns(paSpawns)
		@aSpawns = paSpawns

	def SetCwdRaw(pcCwd, pcOrigin)
		@cCwd = pcCwd
		@cCwdOrigin = pcOrigin

	def Clone()
		_o_ = new stzEnvironmentState()
		_o_.SetVars(This.VarsCopy())
		_o_.SetSpawns(This.SpawnsCopy())
		_o_.SetCwdRaw(@cCwd, @cCwdOrigin)
		return _o_

	def Show()
		? "Environment state: " + len(@aVars) + " vars, cwd=[" + @cCwd + "], " +
		  len(@aSpawns) + " pending spawn(s)"


  #========================#
 #  STZENVIRONMENTBRIDGE  #
#========================#
#
# iRealityBridge for the process/environment domain. THE ONLY class here that
# touches the real environment or starts a real process. Every method delegates
# to stzEnvironment's effectful verbs or the global SpawnProcess().

class stzEnvironmentBridge from stzObject

	@oEnv = NULL

	def init()
		@oEnv = new stzEnvironment()

	  #-- read reality (sensing) -----------------------------

	def RealVar(pcName)
		return @oEnv.Var(pcName)

	def RealHasVar(pcName)
		return @oEnv.Has(pcName)

	def RealCwd()
		return @oEnv.Cwd()

	# Mirror the live environment (all vars + cwd) into a fresh state.
	def CurrentRealityState()
		_o_ = new stzEnvironmentState()
		_aVars_ = @oEnv.Variables()
		_n_ = len(_aVars_)
		for _i_ = 1 to _n_
			_o_.PutVar(_aVars_[_i_][1], _aVars_[_i_][2], "mirrored")
		next
		_o_.SetCwd(@oEnv.Cwd(), "mirrored")
		return _o_

	def Constraints()
		return [ [ "cwd", @oEnv.Cwd() ] ]

	def Capabilities()
		return [ "set_var", "unset_var", "change_dir", "spawn_process" ]

	  #-- change reality (the ONE door) ----------------------

	def ExecuteOperation(oOp)
		_t_ = oOp.Type()
		if _t_ = "set_var"
			return @oEnv.SetVar(oOp.Param("name"), oOp.Param("value"))
		but _t_ = "unset_var"
			return @oEnv.UnsetVar(oOp.Param("name"))
		but _t_ = "change_dir"
			return @oEnv.ChangeDirectory(oOp.Param("path"))
		but _t_ = "spawn_process"
			_oChild_ = SpawnProcess(oOp.Param("command"))
			_cDrain_ = _oChild_.ReadOutputAll()
			_oChild_.Wait()
			_oChild_.Close()
			return TRUE
		ok
		return FALSE

	def VerifyOutcome(oOp)
		_t_ = oOp.Type()
		if _t_ = "set_var"
			return @oEnv.Var(oOp.Param("name")) = oOp.Param("value")
		but _t_ = "unset_var"
			return NOT @oEnv.Has(oOp.Param("name"))
		ok
		return TRUE


  #========================#
 #  STZVIRTUALENVIRONMENT #
#========================#
#
# The process/environment twin. Inherits the generic rehearse/plan/commit core
# from stzVirtualSystem and adds the intent-named rehearsal verbs (which read
# identically to the real stzEnvironment/stzProcess verbs, but only RECORD).

class stzVirtualEnvironment from stzVirtualSystem

	def init()
		@oState = new stzEnvironmentState()
		@oBaseState = @oState.Clone()
		@aHistory = []
		@aSnapshots = []
		@oBridge = new stzEnvironmentBridge()
		@cActor = "human"

	  #-- rehearsal verbs (record; touch NOTHING real) -------

	def SetVar(pcName, pcValue)
		This.ExecuteOperation(new stzVirtualOperation("set_var",
			[ [ "name", "" + pcName ], [ "value", "" + pcValue ] ]))
		return This

	def UnsetVar(pcName)
		This.ExecuteOperation(new stzVirtualOperation("unset_var",
			[ [ "name", "" + pcName ] ]))
		return This

	def ChangeDirectory(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("change_dir",
			[ [ "path", "" + pcPath ] ]))
		return This

		def Cd(pcPath)
			return This.ChangeDirectory(pcPath)

	def Spawn(pcCommand)
		This.ExecuteOperation(new stzVirtualOperation("spawn_process",
			[ [ "command", "" + pcCommand ] ]))
		return This

	  #-- read reality INTO the twin -------------------------

	def MirrorReality()
		@oState = @oBridge.CurrentRealityState()
		@oBaseState = @oState.Clone()
		return This

	  #-- free inspection (reads the TWIN, not the real env) -

	def Var(pcName)
		return @oState.VarValue(pcName)

	def HasVar(pcName)
		return @oState.HasVar(pcName)

	def OriginOfVar(pcName)
		return @oState.OriginOfVar(pcName)

	def Cwd()
		return @oState.Cwd()

	def PendingSpawns()
		return @oState.PendingSpawns()

	def NumberOfPendingSpawns()
		return @oState.NumberOfPendingSpawns()

	def Vars()
		return @oState.Vars()

	def NumberOfVars()
		return @oState.NumberOfVars()

	def Show()
		@oState.Show()
