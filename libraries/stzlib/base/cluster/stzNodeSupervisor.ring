# base/cluster/stzNodeSupervisor.ring
# -----------------------------------------------------------------------------
# DISTRIBUTION D3 -- stzNodeSupervisor: failure handled by DECLARATION,
# not by defensive code at every call site.
#
# Grown from the house supervision family (stzClusterSupervisor healed
# HTTP workers by health probes; this one supervises NODE processes on
# the STZM plane) and it keeps the same house contracts rather than
# minting new ones: Name_() + Cycle(), so it is hostable on any
# stzAgentHost; policy is DECLARED up front; every action it takes is
# recorded and countable.
#
#   oSup = new stzNodeSupervisor()
#   oSup.Child("indexer", "my_indexer.ring", 45810)
#   oSup.Child("search",  "my_search.ring",  45811)
#   oSup.Strategy(:OneForOne)          # or :AllForOne
#   oSup.RestartBudget(3, 10000)       # max 3 restarts per 10 s window
#   oSup.Heartbeat(500, 3)             # ping every 500 ms, 3 misses = dead
#   oSup.Monitor("indexer", "watcher") # death notices go to a node
#   oSup.StartAll()
#   while ... oSup.Cycle() ... end     # or host it on an stzAgentHost
#
# Semantics (the plan's, verbatim):
# - death = OS process exit (JobState) OR heartbeat tolerance exceeded
#   (a WEDGED node -- alive but unresponsive -- is dead too; it gets
#   SpawnKilled before its restart, so the port frees up)
# - :OneForOne restarts the dead child; :AllForOne restarts every child
# - every restart is COUNTED, per child and in a sliding window
# - beyond the budget the supervisor ESCALATES: it stops restarting,
#   reports (Escalated()/EscalationReason()), and leaves the child down.
#   It never loops.
# - monitors: on any death, each subscribed node is Sent
#   [ "node.down", cChildName, nRestartsSoFar ] through the plane
#
# BOUNDED CHILDREN (OSBOUNDARY rung B3, base/security/SOFTANZA_OS_BOUNDARY_STUDY.md):
#   oSup.ChildGrant("shop", [ :profile = "stz.node.shop", :reads = [...],
#       :writes = [...], :memoryMB = 256, :cache = "...", :output = "..." ])
# runs that child inside an OS boundary (an AppContainer and a job object,
# StzEngineBoundary*) instead of as a plain process. Death is the end of the
# boundary's run; KillChild and StopAll end the whole job. Each run leaves a
# run record (RunsOf): exit code, the job's messages, the limits it met, peak
# memory, wall time; a run that met a limit is also written to the security
# ledger as node.limit. A bounded child is never sent a heartbeat: loopback is
# closed to a container, so it talks to its supervisor through files.
# -----------------------------------------------------------------------------

func StzNodeSupervisorQ()
	return new stzNodeSupervisor()

# Supervises node processes by declaration: it restarts the dead under a strategy and a budget, and escalates instead of looping.
#
# Declare children with Child, then the Strategy (:OneForOne or :AllForOne), the RestartBudget and
# optionally a Heartbeat and Monitor subscriptions. A death is a process exit or, with heartbeats
# on, a silent node. Each restart is counted per child and in a sliding window; beyond the budget
# the supervisor stops, reports through Escalated and EscalationReason, and leaves the child down.
# It keeps the house contract Name_() and Cycle(), so it can be hosted on an agent host. StartAll
# spawns real processes; the documentation run declared children and called the read methods only.
#
#   receiver   o1 = new stzNodeSupervisor() o1.Child("indexer", "my_indexer.ring", 45810)
#              o1.Strategy(:AllForOne) o1.RestartBudget(2, 5000)
#   example    ? o1.Escalated()
#              #--> 0
#              ? o1.RestartsOf("indexer")
#              #--> 0
#              ? o1.RestartsOf("nobody")
#              #--> -1
#              o1.Destroy()
#   see        stzNode, stzNodeApp, stzClusterSupervisor
class stzNodeSupervisor from stzObject

	@tName = "node-supervisor"
	@oSpawner = ""
	@cRingExe = "ring"
	@cStrategy = :OneForOne
	@nBudgetMax = 3
	@nBudgetWindowMs = 10000
	@nHbIntervalMs = 0     # 0 = heartbeats off
	@nHbTolerance = 3
	@bEscalated = 0
	@cEscalationReason = ""
	# child specs: parallel lists
	@aChildNames = []
	@aChildScripts = []
	@aChildPorts = []
	@aChildHosts = []
	@aChildJobs = []       # current spawn job id (0 = not running)
	@aChildRestarts = []   # restarts counted, per child
	@aChildMisses = []     # consecutive heartbeat misses
	@aRestartTimes = []    # window: monotonic ms of every restart
	@aMonitors = []        # [ cChildName, cSubscriberAddr ]
	@aChildGrants = []     # "" for a plain child, or the grant of a bounded one (B3)
	@aChildBounds = []     # the boundary id of a bounded child's current run (0 = none)
	@aChildRuns = []       # the run records of a bounded child, newest last
	@nLastHbMs = 0
	@oDoorGov = ""        # the governance that judges a bounded child's door calls (stzBrokerDoor); "" refuses them all

	# Creates a supervisor of node processes, one-for-one, with 3 restarts per 10 seconds and no heartbeat; starts nothing.
	#
	#   returns    nothing; the object is built
	#   see        Child, StartAll
	def init()
		@oSpawner = new stzReactor()
		@cRingExe = This._RingExecutable()

	# Returns the supervisor's name, 'node-supervisor' unless SetName changed it.
	#
	#   returns    a text
	#   see        SetName, Cycle
	def Name_()
		return @tName

	# Sets the name by which an agent host knows the supervisor.
	#
	#   pcName     the new name, as text
	#   returns    the supervisor itself, so calls chain
	#   see        Name_
	def SetName(pcName)
		@tName = "" + pcName
		return This

	# Declares a node process to supervise: its name, the Ring script that runs it and the port it listens on.
	#
	#   pcName     the node's name, stored in lower case
	#   pcScript   the path of the Ring script the process runs
	#   pnPort     the port passed to the script as its last argument
	#   returns    the supervisor itself, so calls chain
	#   warning    nothing is spawned until StartAll; the host defaults to 127.0.0.1
	#   see        StartAll, SetChildHost
	#@ aka  -- declaration --------------------------------------------------------
	def Child(pcName, pcScript, pnPort)
		@aChildNames + StzLower("" + pcName)
		@aChildScripts + ("" + pcScript)
		@aChildPorts + (0 + pnPort)
		@aChildHosts + "127.0.0.1"
		@aChildJobs + 0
		@aChildRestarts + 0
		@aChildMisses + 0
		@aChildGrants + ""
		@aChildBounds + 0
		@aChildRuns + []
		return This

	# Runs a declared child inside an OS boundary described by a grant, instead of as a plain process.
	#
	#   pcName     the child's name, matched without regard to case
	#   paGrant    a list of pairs: :profile (the AppContainer, 1 to 64 letters, digits, '.', '-', '_'),
	#              :reads and :writes (lists of paths), :network (1 for the internetClient capability),
	#              :children (how many processes it may start), :memoryMB (256 by default),
	#              :processorSeconds, :output (its stdout and stderr file), :cache (its HARO_CACHE),
	#              :interpreter (the haro.exe it runs on; the supervisor's own by default)
	#              :capabilities (a list of capability names its token carries: the shared trees, rung B4)
	#              :env (a list of variable names: when given, the node's environment is SystemRoot,
	#              TEMP, TMP, LOCALAPPDATA, STZ_ENGINE_DIR, HARO_CACHE and these, and nothing else -- threat model R20; without it
	#              the node inherits the supervisor's whole environment)
	#              :broker (a list of credential-broker grant names) and :brokerFolder (a folder among its
	#              :writes): the node asks for a call there and the supervisor's broker makes it, the value
	#              attached outside the node; every call is judged by BrokerGovernance (stzBrokerDoor.haro)
	#   returns    the supervisor itself, so calls chain
	#   warning    the grant must name the interpreter's folder and the script's folder among its reads;
	#              a bounded child is never sent a heartbeat (loopback is closed to a container)
	#   see        RunsOf, StzBoundaryInstall
	def ChildGrant(pcName, paGrant)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ > 0
			@aChildGrants[_i_] = paGrant
		ok
		return This

	# Returns the run records of a bounded child, newest last: each is a list of pairs
	# :pid, :exit, :messages, :limits, :peakMB, :wallMs, :error.
	#
	#   pcName     the child's name, matched without regard to case
	#   returns    a list; empty for a plain child or an unknown name
	#   note       Windows' peak counts a commit it refused, so a record's :peakMB can pass the ceiling;
	#              :limits, read from the job's messages, is what says a limit was met
	#   see        ChildGrant
	def RunsOf(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ = 0
			return []
		ok
		return @aChildRuns[_i_]

	# Sets the host on which a child's name resolves on the node plane, so a deployment can move it.
	#
	#   pcName     the child's name, matched without regard to case
	#   pcHost     the host or interface address
	#   returns    the supervisor itself, so calls chain
	#   warning    an unknown child name changes nothing
	#   see        Child
	#@ aka  Where the child's name resolves on the plane (deployment moves it).
	def SetChildHost(pcName, pcHost)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ > 0
			@aChildHosts[_i_] = StzLower("" + pcHost)
		ok
		return This

	# Kills the operating-system process of a child, for deployment or chaos tests; the next Cycle sees the death and handles it.
	#
	#   pcName     the child's name, matched without regard to case
	#   returns    the supervisor itself, so calls chain
	#   note       run only while no child was started, where it does nothing
	#   warning    does nothing for a child that is not running
	#   see        Cycle, StartAll
	#@ aka  Kill a child's OS process (deployment/testing); the death is then observed and handled by the next Cycle() like any other death.
	def KillChild(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ > 0 and @aChildJobs[_i_] != 0
			This._KillJob(_i_)
		ok
		return This

	# Chooses what happens when a child dies: :OneForOne restarts that child, :AllForOne restarts every child.
	#
	#   pcStrategy   :OneForOne or :AllForOne
	#   returns      the supervisor itself, so calls chain
	#   warning      any other value selects :OneForOne
	#   see          RestartBudget, Cycle
	def Strategy(pcStrategy)
		if pcStrategy = :AllForOne
			@cStrategy = :AllForOne
		else
			@cStrategy = :OneForOne
		ok
		return This

	# Sets how many restarts are allowed within a sliding time window before the supervisor escalates.
	#
	#   nMax        the restarts allowed in the window, 3 by default
	#   nWindowMs   the window length in milliseconds, 10000 by default
	#   returns     the supervisor itself, so calls chain
	#   warning     under :AllForOne one death counts as one restart per child
	#   see         Escalated, Strategy
	# Sets the governance that judges every call a bounded child asks through its door (:broker in its
	# grant): the actor is the child's name, the act "broker:<grant>". Without one the door refuses every call.
	def BrokerGovernance(oGov)
		@oDoorGov = oGov
		return This

	def RestartBudget(nMax, nWindowMs)
		@nBudgetMax = 0 + nMax
		@nBudgetWindowMs = 0 + nWindowMs
		return This

	# Turns on heartbeats: the supervisor pings each running child and treats one that stays silent as dead.
	#
	#   nIntervalMs   the time between pings in milliseconds, 0 for none
	#   nTolerance    how many consecutive misses make a child dead, 3 by default
	#   returns       the supervisor itself, so calls chain
	#   warning       a silent child is killed before it is restarted, so that its port frees
	#   see           Cycle
	def Heartbeat(nIntervalMs, nTolerance)
		@nHbIntervalMs = 0 + nIntervalMs
		@nHbTolerance = 0 + nTolerance
		return This

	# Subscribes a node to the death of a child: on each death it is sent [ node.down, child, restarts so far ].
	#
	#   pcChildName        the child to watch, matched without regard to case
	#   pcSubscriberAddr   the node address that receives the notice
	#   returns            the supervisor itself, so calls chain
	#   warning            the notice is sent over the node plane
	#   see                Cycle
	def Monitor(pcChildName, pcSubscriberAddr)
		@aMonitors + [ StzLower("" + pcChildName), "" + pcSubscriberAddr ]
		return This

	# TRUE if the restart budget was exceeded and the supervisor stopped restarting.
	#
	#   returns    1 or 0
	#   warning    after escalating, Cycle does nothing and the dead child stays down
	#   see        EscalationReason, RestartBudget
	#@ aka  -- observability ------------------------------------------------------
	def Escalated()
		return @bEscalated

	# Returns the text that says which child exceeded which budget; empty before any escalation.
	#
	#   returns    a text
	#   see        Escalated
	def EscalationReason()
		return @cEscalationReason

	# Returns how many times a child was restarted; -1 for an unknown name.
	#
	#   pcName     the child's name, matched without regard to case
	#   returns    a number
	#   see        TotalRestarts
	def RestartsOf(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ = 0
			return -1
		ok
		return @aChildRestarts[_i_]

	# Returns the restarts of all children added together.
	#
	#   returns    a number
	#   see        RestartsOf
	def TotalRestarts()
		nSum = 0
		nLen = ring_len(@aChildRestarts)
		for i = 1 to nLen
			nSum += @aChildRestarts[i]
		next
		return nSum

	# Returns the spawn job number of a child's current process, 0 when it is not running or unknown.
	#
	#   pcName     the child's name, matched without regard to case
	#   returns    a number
	#   see        StartAll
	def JobOf(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ = 0
			return 0
		ok
		return @aChildJobs[_i_]

	# Spawns the process of every declared child and registers each name on the node plane.
	#
	#   returns    the supervisor itself, so calls chain
	#   note       not run: it starts child processes
	#   warning    spawns operating-system processes and registers them on the node plane
	#   see        Cycle, StopAll
	#@ aka  -- lifecycle ----------------------------------------------------------
	def StartAll()
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			This._SpawnChild(i)
		next
		return This

	# Runs one supervision tick: finds dead children, notifies monitors, and restarts them under the strategy and the budget.
	#
	#   returns    the supervisor itself, so calls chain
	#   note       run only while no child was started, where it does nothing
	#   warning    it never waits and never loops: past the budget it escalates and stops restarting
	#   see        StartAll, Escalated
	#@ aka  One supervision tick: detect deaths (process exit; missed heartbeats), apply the declared strategy under the budget, notify monitors. Pure policy over observations -- no waiting inside.
	def Cycle()
		if @bEscalated
			return This
		ok
		This._ServeDoors()
		aDead = []
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			if @aChildJobs[i] != 0 and This._HasExited(i)
				aDead + i
			ok
		next
		if @nHbIntervalMs > 0
			nNow = StzEngineWatchTimestampMs()
			if nNow - @nLastHbMs >= @nHbIntervalMs
				@nLastHbMs = nNow
				for i = 1 to nLen
					if @aChildJobs[i] = 0
						loop
					ok
					if NOT isString(@aChildGrants[i])
						loop
					ok
					if StzFindFirst(i, aDead) > 0
						loop
					ok
					StzNodePlane().Ask(@aChildNames[i], [ "ping", 0 ], 250)
					if StzNodePlane().LastStatus() = :Ok
						@aChildMisses[i] = 0
					else
						@aChildMisses[i]++
						if @aChildMisses[i] >= @nHbTolerance
							# a WEDGED node is dead: kill the process so
							# the port frees before the restart
							This._KillJob(i)
							aDead + i
						ok
					ok
				next
			ok
		ok
		nDead = ring_len(aDead)
		for d = 1 to nDead
			This._HandleDeath(aDead[d])
			if @bEscalated
				exit
			ok
		next
		return This

	# Kills every running child process and forgets their jobs.
	#
	#   returns    the supervisor itself, so calls chain
	#   note       run only while no child was started, where it does nothing
	#   warning    kills processes
	#   see        StartAll, Destroy
	#@ aka  Stop supervising and stop every child (kill; the guard of last resort -- normal shutdown goes through stz.stop messages).
	def StopAll()
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			if @aChildJobs[i] != 0
				This._KillJob(i)
				This._DrainJob(i)
				@aChildJobs[i] = 0
			ok
		next
		return This

	# Stops every child and destroys the supervisor's reactor.
	#
	#   returns    nothing
	#   warning    the supervisor cannot be used afterwards
	#   see        StopAll
	def Destroy()
		This.StopAll()
		@oSpawner.Destroy()

	#-- internals ----------------------------------------------------------

	def _ChildIndex(pcName)
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			if @aChildNames[i] = pcName
				return i
			ok
		next
		return 0

	def _SpawnChild(i)
		@aChildMisses[i] = 0
		if NOT isString(@aChildGrants[i])
			This._StartBounded(i)
		else
			@aChildJobs[i] = @oSpawner.SubmitSpawn([ @cRingExe,
				@aChildScripts[i], "" + @aChildPorts[i] ])
		ok
		NodeRegister(@aChildNames[i], @aChildHosts[i], @aChildPorts[i])

	# A bounded child: one boundary per run. Its job slot holds -1 while the run is
	# the supervisor's, so every "is it running" test above reads it unchanged.
	def _StartBounded(i)
		_g_ = @aChildGrants[i]
		@aChildJobs[i] = -1
		@aChildBounds[i] = 0
		_nB_ = StzEngineBoundaryNew(This._GrantText(_g_, :profile, ""))
		if _nB_ = 0
			This._KeepRun(i, [ :pid = 0, :exit = -1, :messages = "", :limits = [], :peakMB = 0,
				:wallMs = 0, :error = StzEngineBoundaryError(0) ])
			return
		ok
		_aR_ = This._GrantList(_g_, :reads)
		_nR_ = len(_aR_)
		for _r_ = 1 to _nR_
			StzEngineBoundaryRead(_nB_, _aR_[_r_])
		next
		_aW_ = This._GrantList(_g_, :writes)
		_nW_ = len(_aW_)
		for _w_ = 1 to _nW_
			StzEngineBoundaryWrite(_nB_, _aW_[_w_])
		next
		_aC_ = This._GrantList(_g_, :capabilities)
		_nC_ = len(_aC_)
		for _c_ = 1 to _nC_
			StzEngineBoundaryCapability(_nB_, _aC_[_c_])
		next
		if This._GrantHas(_g_, :env)
			StzEngineBoundaryEnvKeep(_nB_, "STZ_ENGINE_DIR")
			StzEngineBoundaryEnvKeep(_nB_, "HARO_CACHE")
			_aE_ = This._GrantList(_g_, :env)
			_nE_ = len(_aE_)
			for _e_ = 1 to _nE_
				StzEngineBoundaryEnvKeep(_nB_, "" + _aE_[_e_])
			next
		ok
		StzEngineBoundaryNetwork(_nB_, This._GrantNumber(_g_, :network, 0))
		StzEngineBoundaryChildren(_nB_, This._GrantNumber(_g_, :children, 0))
		StzEngineBoundaryMemory(_nB_, This._GrantNumber(_g_, :memoryMB, 256))
		StzEngineBoundaryProcessor(_nB_, This._GrantNumber(_g_, :processorSeconds, 0))
		_cOut_ = This._GrantText(_g_, :output, "")
		StzEngineBoundaryOutput(_nB_, _cOut_, _cOut_)
		_cExe_ = This._GrantText(_g_, :interpreter, @cRingExe)
		_cCmd_ = char(34) + _cExe_ + char(34) + " " + char(34) + @aChildScripts[i] + char(34) + " " + string(@aChildPorts[i])
		_cCache_ = This._GrantText(_g_, :cache, "")
		_cOldCache_ = SysGet("HARO_CACHE")
		if _cCache_ != ""
			SysSet("HARO_CACHE", _cCache_)
		ok
		_nPid_ = StzEngineBoundaryStart(_nB_, _cCmd_)
		if _cCache_ != ""
			SysSet("HARO_CACHE", _cOldCache_)
		ok
		if _nPid_ = 0
			This._KeepRun(i, [ :pid = 0, :exit = -1, :messages = "", :limits = [], :peakMB = 0,
				:wallMs = 0, :error = StzEngineBoundaryError(_nB_) ])
			StzEngineBoundaryFree(_nB_)
			return
		ok
		@aChildBounds[i] = _nB_

	def _HasExited(i)
		if NOT isString(@aChildGrants[i])
			if @aChildBounds[i] = 0
				return 1
			ok
			return StzEngineBoundaryWait(@aChildBounds[i], 0) = 1
		ok
		# JobState: -1 still running, 0 result ready (= process exited),
		# -2 unknown (already drained -- treat as exited)
		nState = @oSpawner.JobState(@aChildJobs[i])
		return nState = 0 or nState = -2

	def _KillJob(i)
		if NOT isString(@aChildGrants[i])
			if @aChildBounds[i] != 0
				StzEngineBoundaryEnd(@aChildBounds[i])
			ok
			return
		ok
		@oSpawner.KillSpawn(@aChildJobs[i], 9)

	# The end of a bounded run: its record, and a node.limit event for each limit it met.
	def _EndBounded(i)
		_nB_ = @aChildBounds[i]
		if _nB_ = 0
			return
		ok
		StzEngineBoundaryWait(_nB_, 5000)
		_cMsgs_ = StzEngineBoundaryMessages(_nB_)
		_aLim_ = []
		_aNames_ = [ "JOB_MEMORY_LIMIT", "END_OF_JOB_TIME", "ACTIVE_PROCESS_LIMIT" ]
		for _k_ = 1 to 3
			if len(StzFindCS(_aNames_[_k_], _cMsgs_, 1)) > 0
				_aLim_ + _aNames_[_k_]
				StzNoteRefusalFrom("node.limit", @tName, @aChildNames[i],
					_aNames_[_k_] + " (exit " + string(StzEngineBoundaryExitCode(_nB_)) + ")",
					This._GrantText(@aChildGrants[i], :profile, ""))
			ok
		next
		This._KeepRun(i, [ :pid = StzEngineBoundaryPid(_nB_), :exit = StzEngineBoundaryExitCode(_nB_),
			:messages = _cMsgs_, :limits = _aLim_, :peakMB = StzEngineBoundaryPeakMb(_nB_),
			:wallMs = StzEngineBoundaryWallMs(_nB_), :error = "" ])
		StzEngineBoundaryFree(_nB_)
		@aChildBounds[i] = 0

	# keeps the last 20 run records of a child
	def _KeepRun(i, paRun)
		@aChildRuns[i] + paRun
		if len(@aChildRuns[i]) > 20
			del(@aChildRuns[i], 1)
		ok

	# a grant's keys are read without regard to case: a key written in Haro keeps its capitals
	def _GrantText(paGrant, pcKey, pcDefault)
		_n_ = len(paGrant)
		for _k_ = 1 to _n_
			if StzLower("" + paGrant[_k_][1]) = StzLower("" + pcKey)
				return "" + paGrant[_k_][2]
			ok
		next
		return pcDefault

	def _GrantNumber(paGrant, pcKey, pnDefault)
		_n_ = len(paGrant)
		for _k_ = 1 to _n_
			if StzLower("" + paGrant[_k_][1]) = StzLower("" + pcKey)
				return 0 + paGrant[_k_][2]
			ok
		next
		return pnDefault

	# Answers each bounded child's door, if its grant has one (stzBrokerDoor.haro).
	def _ServeDoors()
		_n_ = len(@aChildNames)
		for _i_ = 1 to _n_
			if isString(@aChildGrants[_i_])
				loop
			ok
			if This._GrantHas(@aChildGrants[_i_], :brokerFolder) = 0
				loop
			ok
			StzBrokerDoorServe(This._GrantText(@aChildGrants[_i_], :brokerFolder, ""), @aChildNames[_i_],
				This._GrantList(@aChildGrants[_i_], :broker), @oDoorGov)
		next

	def _GrantHas(paGrant, pcKey)
		_n_ = len(paGrant)
		for _k_ = 1 to _n_
			if StzLower("" + paGrant[_k_][1]) = StzLower("" + pcKey)
				return 1
			ok
		next
		return 0

	def _GrantList(paGrant, pcKey)
		_n_ = len(paGrant)
		for _k_ = 1 to _n_
			if StzLower("" + paGrant[_k_][1]) = StzLower("" + pcKey)
				return paGrant[_k_][2]
			ok
		next
		return []

	# A death: notify monitors, then apply the strategy under the budget.
	def _HandleDeath(i)
		cChild = @aChildNames[i]
		This._DrainJob(i)
		nSubs = ring_len(@aMonitors)
		for m = 1 to nSubs
			if @aMonitors[m][1] = cChild
				StzNodePlane().Send(@aMonitors[m][2],
					[ "node.down", cChild, @aChildRestarts[i] ])
			ok
		next
		# the budget gate: restarts inside the sliding window
		nNow = StzEngineWatchTimestampMs()
		aKeep = []
		nLen = ring_len(@aRestartTimes)
		for t = 1 to nLen
			if nNow - @aRestartTimes[t] <= @nBudgetWindowMs
				aKeep + @aRestartTimes[t]
			ok
		next
		@aRestartTimes = aKeep
		nNeed = 1
		if @cStrategy = :AllForOne
			nNeed = ring_len(@aChildNames)
		ok
		if ring_len(@aRestartTimes) + nNeed > @nBudgetMax
			@bEscalated = 1
			@cEscalationReason = "restart budget exceeded (" + @nBudgetMax +
				" per " + @nBudgetWindowMs + " ms) on child '" + cChild + "'"
			@aChildJobs[i] = 0
			return
		ok
		if @cStrategy = :AllForOne
			nAll = ring_len(@aChildNames)
			for c = 1 to nAll
				if c != i and @aChildJobs[c] != 0
					This._KillJob(c)
					This._DrainJob(c)
				ok
				This._Restart(c)
			next
		else
			This._Restart(i)
		ok

	def _Restart(i)
		@aChildRestarts[i]++
		@aRestartTimes + StzEngineWatchTimestampMs()
		This._SpawnChild(i)

	# Drain the finished spawn job so the reactor can reap it.
	def _DrainJob(i)
		if NOT isString(@aChildGrants[i])
			This._EndBounded(i)
			@aChildJobs[i] = 0
			return
		ok
		if @aChildJobs[i] != 0
			@oSpawner.AwaitSpawn(@aChildJobs[i], 100)
			@aChildJobs[i] = 0
		ok

	def _RingExecutable()
		return StzInterpreterPath()
