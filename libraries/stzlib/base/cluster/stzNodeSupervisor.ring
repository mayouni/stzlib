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

	def init()
		@oSpawner = new stzReactor()
		@cRingExe = This._RingExecutable()

	def Name_()
		return @cName

	def SetName(pcName)
		@cName = "" + pcName
		return This

	#-- declaration --------------------------------------------------------

	def Child(pcName, pcScript, pnPort)
		@aChildNames + StzLower("" + pcName)
		@aChildScripts + ("" + pcScript)
		@aChildPorts + (0 + pnPort)
		@aChildHosts + "127.0.0.1"
		@aChildJobs + 0
		@aChildRestarts + 0
		@aChildMisses + 0
		return This

	# Where the child's name resolves on the plane (deployment moves it).
	def SetChildHost(pcName, pcHost)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ > 0
			@aChildHosts[_i_] = StzLower("" + pcHost)
		ok
		return This

	# Kill a child's OS process (deployment/testing); the death is then
	# observed and handled by the next Cycle() like any other death.
	def KillChild(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ > 0 and @aChildJobs[_i_] != 0
			@oSpawner.KillSpawn(@aChildJobs[_i_], 9)
		ok
		return This

	def Strategy(pcStrategy)
		if pcStrategy = :AllForOne
			@cStrategy = :AllForOne
		else
			@cStrategy = :OneForOne
		ok
		return This

	def RestartBudget(nMax, nWindowMs)
		@nBudgetMax = 0 + nMax
		@nBudgetWindowMs = 0 + nWindowMs
		return This

	def Heartbeat(nIntervalMs, nTolerance)
		@nHbIntervalMs = 0 + nIntervalMs
		@nHbTolerance = 0 + nTolerance
		return This

	def Monitor(pcChildName, pcSubscriberAddr)
		@aMonitors + [ StzLower("" + pcChildName), "" + pcSubscriberAddr ]
		return This

	#-- observability ------------------------------------------------------

	def Escalated()
		return @bEscalated

	def EscalationReason()
		return @cEscalationReason

	def RestartsOf(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ = 0
			return -1
		ok
		return @aChildRestarts[_i_]

	def TotalRestarts()
		nSum = 0
		nLen = ring_len(@aChildRestarts)
		for i = 1 to nLen
			nSum += @aChildRestarts[i]
		next
		return nSum

	def JobOf(pcName)
		_i_ = This._ChildIndex(StzLower("" + pcName))
		if _i_ = 0
			return 0
		ok
		return @aChildJobs[_i_]

	#-- lifecycle ----------------------------------------------------------

	# Spawn every declared child and register each name on the plane.
	def StartAll()
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			This._SpawnChild(i)
		next
		return This

	# One supervision tick: detect deaths (process exit; missed
	# heartbeats), apply the declared strategy under the budget, notify
	# monitors. Pure policy over observations -- no waiting inside.
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

	# Stop supervising and stop every child (kill; the guard of last
	# resort -- normal shutdown goes through stz.stop messages).
	def StopAll()
		nLen = ring_len(@aChildNames)
		for i = 1 to nLen
			if @aChildJobs[i] != 0
				@oSpawner.KillSpawn(@aChildJobs[i], 9)
				@aChildJobs[i] = 0
			ok
		next
		return This

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
