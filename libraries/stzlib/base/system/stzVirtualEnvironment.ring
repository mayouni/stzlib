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


  #=======================#
 #  STZENVIRONMENTSTATE  #
#=======================#
#
# The virtual state: environment variables (each [ name, value, origin ]), the
# working directory, and a queue of pending spawn commands.

# Holds an in-memory environment: variables with their origin, a working directory, and a queue of commands waiting to run.
#
# It is the state the environment twin changes. Each variable is a [ name, value, origin ] row, the
# origin being mirrored for a value read from reality and virtual for one born in the twin, which is
# what a diff against reality needs. Apply is the hook the generic twin calls to rehearse an
# operation, and Clone gives the independent copy a snapshot or a rebuild starts from. Names are
# matched with case. Nothing here touches the real environment.
#
#   receiver   o1 = new stzEnvironmentState()
#   example    o1.PutVar("MODE", "dev", "virtual")
#              o1.SetCwd("/srv/app", "virtual")
#              o1.AddSpawn("make test")
#              ? o1.VarValue("MODE")
#              #--> dev
#              ? o1.Cwd()
#              #--> /srv/app
#              ? o1.NumberOfPendingSpawns()
#              #--> 1
#   see        stzVirtualEnvironment, stzEnvironmentBridge, stzFileTree
class stzEnvironmentState from stzObject

	@aVars = []
	@cCwd = ""
	@cCwdOrigin = ""
	@aSpawns = []

	# Builds an empty environment state: no variables, no working directory and no pending spawns.
	#
	#   returns    nothing; the state is built
	#   see        Clone, stzVirtualEnvironment
	def init()

	def _IndexOf(pcName)
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			if @aVars[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	# TRUE if a variable of that exact name is in the state.
	#
	#   pcName     the variable name, matched with case
	#   returns    TRUE or FALSE
	#   see        VarValue, PutVar
	def HasVar(pcName)
		return This._IndexOf(pcName) > 0

	# Returns the value of a variable.
	#
	#   pcName     the variable name, matched with case
	#   returns    a text; an empty text when the variable is absent
	#   see        HasVar, OriginOfVar
	def VarValue(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			return @aVars[_i_][2]
		ok
		return ""

	# Returns where a variable came from.
	#
	#   pcName     the variable name, matched with case
	#   returns    mirrored for one read from reality, virtual for one born in the twin; an empty
	#              text when absent
	#   see        VarValue, PutVar
	def OriginOfVar(pcName)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			return @aVars[_i_][3]
		ok
		return ""

	# Sets a variable, adding it or replacing its value.
	#
	#   pcName     the variable name
	#   pcValue    the value, as text
	#   pcOrigin   mirrored or virtual, kept only when the variable is new
	#   returns    nothing
	#   warning    an existing variable keeps the origin it first had, so a mirrored one stays
	#              mirrored after its value changes
	#   see        VarValue, RemoveVar
	def PutVar(pcName, pcValue, pcOrigin)
		_i_ = This._IndexOf(pcName)
		if _i_ > 0
			@aVars[_i_][2] = pcValue
		else
			@aVars + [ "" + pcName, "" + pcValue, "" + pcOrigin ]
		ok

	# Removes a variable; an absent name changes nothing.
	#
	#   pcName     the variable name, matched with case
	#   returns    nothing
	#   see        PutVar, HasVar
	def RemoveVar(pcName)
		_aNew_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			if @aVars[_i_][1] != pcName
				_aNew_ + @aVars[_i_]
			ok
		next
		@aVars = _aNew_

	# Returns the working directory of the state.
	#
	#   returns    a text; empty until one is set
	#   see        SetCwd, CwdOrigin
	def Cwd()
		return @cCwd

	# Returns where the working directory came from.
	#
	#   returns    mirrored or virtual; an empty text until one is set
	#   see        Cwd, SetCwd
	def CwdOrigin()
		return @cCwdOrigin

	# Sets the working directory and where it came from.
	#
	#   pcPath     the directory, as text
	#   pcOrigin   mirrored or virtual
	#   returns    nothing
	#   see        Cwd, CwdOrigin
	def SetCwd(pcPath, pcOrigin)
		@cCwd = "" + pcPath
		@cCwdOrigin = "" + pcOrigin

	# Returns the commands waiting to be run, in order.
	#
	#   returns    a list of text
	#   see        AddSpawn, NumberOfPendingSpawns
	def PendingSpawns()
		return @aSpawns

	# Queues a command for a later run; nothing is run here.
	#
	#   pcCommand   the command line, as text
	#   returns     nothing
	#   see         PendingSpawns
	def AddSpawn(pcCommand)
		@aSpawns + ("" + pcCommand)

	# Returns every variable with its origin.
	#
	#   returns    a list of [ name, value, origin ] rows, in the order added
	#   see        VarNames, VarsCopy
	def Vars()
		return @aVars

	# Returns the names of the variables, in the order added.
	#
	#   returns    a list of text
	#   see        Vars, NumberOfVars
	def VarNames()
		_a_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			_a_ + @aVars[_i_][1]
		next
		return _a_

	# Returns how many variables the state holds.
	#
	#   returns    a number
	#   see        VarNames
	def NumberOfVars()
		return len(@aVars)

	# Returns how many commands are queued.
	#
	#   returns    a number
	#   see        PendingSpawns
	def NumberOfPendingSpawns()
		return len(@aSpawns)

	# Applies one operation to the state: set or unset a variable, change the directory, or queue a spawn; other types change nothing.
	#
	#   oOp        the stzVirtualOperation to apply
	#   returns    nothing
	#   note       this is the hook the generic twin calls when it rehearses
	#   see        stzVirtualEnvironment, Clone
	#@ aka  The domain hook the generic twin calls to rehearse an operation.
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

	# Returns a copy of the variable rows, so a clone does not share them.
	#
	#   returns    a list of [ name, value, origin ] rows
	#   see        Clone, SetVars
	def VarsCopy()
		_a_ = []
		_n_ = len(@aVars)
		for _i_ = 1 to _n_
			_a_ + [ @aVars[_i_][1], @aVars[_i_][2], @aVars[_i_][3] ]
		next
		return _a_

	# Returns a copy of the queued commands.
	#
	#   returns    a list of text
	#   see        Clone, SetSpawns
	def SpawnsCopy()
		_a_ = []
		_n_ = len(@aSpawns)
		for _i_ = 1 to _n_
			_a_ + @aSpawns[_i_]
		next
		return _a_

	# Replaces all the variable rows at once.
	#
	#   paVars     a list of [ name, value, origin ] rows
	#   returns    nothing
	#   see        VarsCopy, Clone
	def SetVars(paVars)
		@aVars = paVars

	# Replaces all the queued commands at once.
	#
	#   paSpawns   a list of command lines
	#   returns    nothing
	#   see        SpawnsCopy, Clone
	def SetSpawns(paSpawns)
		@aSpawns = paSpawns

	# Sets the working directory and its origin without any judgement, as Clone needs.
	#
	#   pcCwd      the directory
	#   pcOrigin   mirrored or virtual
	#   returns    nothing
	#   see        SetCwd, Clone
	def SetCwdRaw(pcCwd, pcOrigin)
		@cCwd = pcCwd
		@cCwdOrigin = pcOrigin

	# Returns an independent copy of the state, which a snapshot or a rebuild starts from.
	#
	#   returns    a new stzEnvironmentState
	#   see        VarsCopy, SetVars
	def Clone()
		_o_ = new stzEnvironmentState()
		_o_.SetVars(This.VarsCopy())
		_o_.SetSpawns(This.SpawnsCopy())
		_o_.SetCwdRaw(@cCwd, @cCwdOrigin)
		return _o_

	# Prints one summary line: the number of variables, the directory and the queued commands.
	#
	#   returns    nothing; it prints
	#   see        Vars, Cwd
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

# Is the one door from the environment twin to the live process: it reads variables and directory, and commits operations.
#
# The reads (RealVar, RealHasVar, RealCwd, CurrentRealityState) are free. ExecuteOperation is the
# only call that changes reality: it sets or removes a real variable, changes the real directory, or
# starts a real command and waits for it. Reach it only through a plan, after the narration and the
# risks have been read. VerifyOutcome checks afterwards that a variable is as asked.
#
#   receiver   o1 = new stzEnvironmentBridge()
#   example    ? o1.RealHasVar("STZ_DOC_INVENTED_VAR")
#              #--> 0
#              ? @@( o1.Capabilities() )
#              #--> [ "set_var", "unset_var", "change_dir", "spawn_process" ]
#   see        stzVirtualEnvironment, stzEnvironmentState, stzUpdatePlan
class stzEnvironmentBridge from stzObject

	@oEnv = ""

	# Builds the bridge to the live process environment, the only door by which this twin family reaches reality.
	#
	#   returns    nothing; the bridge is built
	#   see        ExecuteOperation, stzVirtualEnvironment
	def init()
		@oEnv = new stzEnvironment()

	# Returns the value of a variable of the live environment.
	#
	#   pcName     the variable name
	#   returns    a text; an empty text when the variable is not set
	#   note       it reads the live environment and changes nothing
	#   see        RealHasVar, CurrentRealityState
	#@ aka  -- read reality (sensing) -----------------------------
	def RealVar(pcName)
		return @oEnv.Var(pcName)

	# TRUE if the live environment has that variable.
	#
	#   pcName     the variable name
	#   returns    TRUE or FALSE
	#   see        RealVar
	def RealHasVar(pcName)
		return @oEnv.Has(pcName)

	# Returns the working directory of the running process.
	#
	#   returns    a text
	#   see        CurrentRealityState, Constraints
	def RealCwd()
		return @oEnv.Cwd()

	# Returns a new state holding the live variables and directory, each marked as mirrored.
	#
	#   returns    a stzEnvironmentState
	#   note       the live environment can hold secrets: show counts and names, never values
	#   see        stzVirtualEnvironment, RealVar
	#@ aka  Mirror the live environment (all vars + cwd) into a fresh state.
	def CurrentRealityState()
		_o_ = new stzEnvironmentState()
		_aVars_ = @oEnv.Variables()
		_n_ = len(_aVars_)
		for _i_ = 1 to _n_
			_o_.PutVar(_aVars_[_i_][1], _aVars_[_i_][2], "mirrored")
		next
		_o_.SetCwd(@oEnv.Cwd(), "mirrored")
		return _o_

	# Returns the facts that bound what the bridge acts on, which is the working directory.
	#
	#   returns    a list [ [ cwd, directory ] ]
	#   see        Capabilities, RealCwd
	def Constraints()
		return [ [ "cwd", @oEnv.Cwd() ] ]

	# Returns the operation types the bridge can commit.
	#
	#   returns    a list of text: set_var, unset_var, change_dir, spawn_process
	#   see        ExecuteOperation, Constraints
	def Capabilities()
		return [ "set_var", "unset_var", "change_dir", "spawn_process" ]

	# Commits one operation to the live process: sets or removes a variable, changes the directory, or starts a command and waits for it.
	#
	#   oOp        the stzVirtualOperation to commit
	#   returns    the result of the real call for a variable or a directory change, 1 once a
	#              spawned command has finished, 0 for another type
	#   note       a spawned command has its output read and discarded
	#   warning    not run: it changes the real environment and starts real processes, so reach it
	#              only through a plan that was narrated and reviewed
	#   see        VerifyOutcome, stzUpdatePlan
	#@ aka  -- change reality (the ONE door) ----------------------
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
			return 1
		ok
		return 0

	# Checks after a commit that reality holds what the operation asked for.
	#
	#   oOp        the stzVirtualOperation that was committed
	#   returns    TRUE or FALSE; checked for a variable being set or removed, and always TRUE for
	#              the other types
	#   see        ExecuteOperation, RealVar
	def VerifyOutcome(oOp)
		_t_ = oOp.Type()
		if _t_ = "set_var"
			return @oEnv.Var(oOp.Param("name")) = oOp.Param("value")
		but _t_ = "unset_var"
			return NOT @oEnv.Has(oOp.Param("name"))
		ok
		return 1


  #========================#
 #  STZVIRTUALENVIRONMENT #
#========================#
#
# The process/environment twin. Inherits the generic rehearse/plan/commit core
# from stzVirtualSystem and adds the intent-named rehearsal verbs (which read
# identically to the real stzEnvironment/stzProcess verbs, but only RECORD).

# Rehearses changes to variables, the working directory and processes in memory, without touching the real environment.
#
# The environment twin of stzVirtualSystem. SetVar, UnsetVar, ChangeDirectory and Spawn read like
# the real verbs but only record an operation in the twin; Var, HasVar, Cwd and the other readers
# answer from the twin, not from the process. MirrorReality fills the twin from the live environment
# first when a rehearsal should start from what is really there. A rehearsal becomes a narrated,
# reviewable plan with GenerateUpdatePlan, and only executing that plan reaches reality.
#
#   receiver   o1 = new stzVirtualEnvironment()
#   example    o1.SetVar("MODE", "dev")
#              o1.ChangeDirectory("/srv/app")
#              o1.Spawn("make test")
#              ? o1.Var("MODE")
#              #--> dev
#              ? o1.Cwd()
#              #--> /srv/app
#              ? @@( o1.PendingSpawns() )
#              #--> [ "make test" ]
#   see        stzVirtualSystem, stzEnvironmentState, stzEnvironmentBridge, stzVirtualFileSystem,
#              StzVirtualEnvironmentQ
class stzVirtualEnvironment from stzVirtualSystem

	# Builds an environment twin with an empty state, a bridge to the live environment and no history.
	#
	#   returns    nothing; the twin is built
	#   see        MirrorReality, stzVirtualSystem
	def init()
		@oState = new stzEnvironmentState()
		@oBaseState = @oState.Clone()
		@aHistory = []
		@aSnapshots = []
		@oBridge = new stzEnvironmentBridge()
		@cActor = "human"

	# Rehearses setting a variable; the real environment is not touched.
	#
	#   pcName     the variable name
	#   pcValue    the value, as text
	#   returns    the twin itself, so calls chain
	#   note       a variable mirrored from reality keeps its mirrored origin after its value is set
	#   see        UnsetVar, Var
	#@ aka  -- rehearsal verbs (record; touch NOTHING real) -------
	def SetVar(pcName, pcValue)
		This.ExecuteOperation(new stzVirtualOperation("set_var",
			[ [ "name", "" + pcName ], [ "value", "" + pcValue ] ]))
		return This

	# Rehearses removing a variable; the real environment is not touched.
	#
	#   pcName     the variable name
	#   returns    the twin itself, so calls chain
	#   note       an absent name is recorded as an operation and changes nothing in the state
	#   see        SetVar, HasVar
	def UnsetVar(pcName)
		This.ExecuteOperation(new stzVirtualOperation("unset_var",
			[ [ "name", "" + pcName ] ]))
		return This

	# Rehearses changing the working directory; no real directory is entered.
	#
	#   pcPath     the directory to move to, as text
	#   returns    the twin itself, so calls chain
	#   see        Cwd, Spawn
	def ChangeDirectory(pcPath)
		This.ExecuteOperation(new stzVirtualOperation("change_dir",
			[ [ "path", "" + pcPath ] ]))
		return This

		def Cd(pcPath)
			return This.ChangeDirectory(pcPath)

	# Rehearses starting a process by queueing its command; nothing is run.
	#
	#   pcCommand   the command line, as text
	#   returns     the twin itself, so calls chain
	#   note        the command only runs if a plan holding it is executed through the real bridge
	#   see         PendingSpawns, GenerateUpdatePlan
	def Spawn(pcCommand)
		This.ExecuteOperation(new stzVirtualOperation("spawn_process",
			[ [ "command", "" + pcCommand ] ]))
		return This

	# Replaces the twin state with a copy of the live environment: its variables and its working directory.
	#
	#   returns    the twin itself, so calls chain
	#   note       it reads the real environment, which can hold secrets, so show counts and names,
	#              never values
	#   see        Var, Cwd
	#@ aka  -- read reality INTO the twin -------------------------
	def MirrorReality()
		@oState = @oBridge.CurrentRealityState()
		@oBaseState = @oState.Clone()
		return This

	# Returns the value of a variable in the twin.
	#
	#   pcName     the variable name, matched with case
	#   returns    a text; an empty text when the twin has no such variable
	#   see        HasVar, SetVar
	#@ aka  -- free inspection (reads the TWIN, not the real env) -
	def Var(pcName)
		return @oState.VarValue(pcName)

	# TRUE if the twin holds a variable of that exact name.
	#
	#   pcName     the variable name, matched with case
	#   returns    TRUE or FALSE
	#   see        Var, OriginOfVar
	def HasVar(pcName)
		return @oState.HasVar(pcName)

	# Returns where a variable of the twin came from.
	#
	#   pcName     the variable name, matched with case
	#   returns    mirrored for one read from reality, virtual for one set in the twin; an empty
	#              text when absent
	#   see        Var, MirrorReality
	def OriginOfVar(pcName)
		return @oState.OriginOfVar(pcName)

	# Returns the working directory of the twin.
	#
	#   returns    a text; empty until mirrored or changed
	#   see        ChangeDirectory, MirrorReality
	def Cwd()
		return @oState.Cwd()

	# Returns the commands queued by Spawn, in order.
	#
	#   returns    a list of text
	#   see        Spawn, NumberOfPendingSpawns
	def PendingSpawns()
		return @oState.PendingSpawns()

	# Returns how many commands are queued.
	#
	#   returns    a number
	#   see        PendingSpawns
	def NumberOfPendingSpawns()
		return @oState.NumberOfPendingSpawns()

	# Returns every variable of the twin with its origin.
	#
	#   returns    a list of [ name, value, origin ] rows
	#   see        NumberOfVars, Var
	def Vars()
		return @oState.Vars()

	# Returns how many variables the twin holds.
	#
	#   returns    a number
	#   see        Vars
	def NumberOfVars()
		return @oState.NumberOfVars()

	# Prints one summary line of the twin state: variables, directory and queued commands.
	#
	#   returns    nothing; it prints
	#   see        Vars, Cwd
	def Show()
		@oState.Show()
