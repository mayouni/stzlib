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

	@cName = "node-supervisor"
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
	@nLastHbMs = 0

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
		return @cName

	# Sets the name by which an agent host knows the supervisor.
	#
	#   pcName     the new name, as text
	#   returns    the supervisor itself, so calls chain
	#   see        Name_
	def SetName(pcName)
		@cName = "" + pcName
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
		return This

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
			@oSpawner.KillSpawn(@aChildJobs[_i_], 9)
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
							@oSpawner.KillSpawn(@aChildJobs[i], 9)
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
				@oSpawner.KillSpawn(@aChildJobs[i], 9)
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
		@aChildJobs[i] = @oSpawner.SubmitSpawn([ @cRingExe,
			@aChildScripts[i], "" + @aChildPorts[i] ])
		@aChildMisses[i] = 0
		NodeRegister(@aChildNames[i], @aChildHosts[i], @aChildPorts[i])

	def _HasExited(i)
		# JobState: -1 still running, 0 result ready (= process exited),
		# -2 unknown (already drained -- treat as exited)
		nState = @oSpawner.JobState(@aChildJobs[i])
		return nState = 0 or nState = -2

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
					@oSpawner.KillSpawn(@aChildJobs[c], 9)
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
		if @aChildJobs[i] != 0
			@oSpawner.AwaitSpawn(@aChildJobs[i], 100)
			@aChildJobs[i] = 0
		ok

	def _RingExecutable()
		_aA_ = sysargv
		_nLen_ = ring_len(_aA_)
		for _i_ = 1 to _nLen_
			_c_ = StzLower("" + _aA_[_i_])
			if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
				return "" + _aA_[_i_]
			ok
		next
		return "ring"
