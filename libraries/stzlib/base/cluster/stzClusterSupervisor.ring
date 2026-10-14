# base/cluster/stzClusterSupervisor.ring
# -----------------------------------------------------------------------------
# R8.4 (the SCALE plane) -- stzClusterSupervisor: HEALTH + ELASTIC SCALE
# on REAL metrics. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.)
#
# The 2024 doc's cluster monitor busy-looped on random() metrics. The
# supervisor reads REAL cluster state (ready / dead / draining per
# profile, from live /health probes) and a demand signal the app
# reports (observed load vs SLA), then DECIDES per profile: restart dead
# workers (self-healing), scale UP when load is high and below max,
# scale DOWN (graceful drain) when load is low and above min. Decide()
# is a PURE policy (testable without processes); Supervise() applies it
# to a live stzAppCluster (R8.3).
#
# THE R5 COMPOSITION: the supervisor exposes Name_() + Cycle(), so it is
# itself a SUPERVISED JOB on stzAgentHost (R5) -- the cluster is managed
# by a supervisor that is itself a supervised reactor job, ticking on
# the same loop the fleet runs on. It works across ANY Softanza facet
# (text/list/graph/knowledge/neural/...), not just nlp/math.
#
#   oSup = new stzClusterSupervisor(oCluster)
#   oSup.Policy(:nlp, 1, 4).Policy(:graph, 1, 3).SetWaterMarks(0.25, 0.75)
#   oSup.ReportLoad(:nlp, 0.9)      # the app's observed demand (0..1)
#   oSup.Supervise()                # heal + scale to policy
#   oHost.Supervise(oSup, 200)      # ...or run it as a supervised job (R5)
# -----------------------------------------------------------------------------

func StzClusterSupervisorQ(poCluster)
	return new stzClusterSupervisor(poCluster)

# Keeps a cluster of worker processes healthy and sized to its load: restarts dead workers, scales up under high load, drains under low.
#
# Set a Policy (a minimum and a maximum per tag), the water marks, and report the demand with
# ReportLoad or FeedLoadFrom. Decide is a pure function from fleet metrics to a list of actions and
# touches nothing; Supervise applies those actions to the live cluster and Cycle is Supervise as a
# tickable job for an agent host. Dead workers are restarted before any scaling; scaling stops at
# the policy bounds. Only Decide is safe to call on its own; Supervise and Cycle start and stop
# processes.
#
#   receiver   o1 = new stzClusterSupervisor("") o1.Policy("nlp", 1, 4) o1.SetWaterMarks(0.25, 0.75)
#              o1.ReportLoad("nlp", 0.9)
#   example    ? @@( o1.Decide([ [ :tag = "nlp", :ready = 2, :dead = 1 ] ]) )
#              #--> [ [ "restart", "nlp" ], [ "scaleup", "nlp" ] ]
#              ? o1.LoadOf("nlp")
#              #--> 0.90
#   see        stzClusterTelemetry, stzNodeSupervisor, stzAppCluster
class stzClusterSupervisor from stzObject

	@cName = "cluster-supervisor"
	@oCluster = ""
	@aPolicy = []          # [ [ tag, min, max ], ... ]
	@aLoad = []            # [ [ tag, ratio(0..1) ], ... ]  observed demand
	@nLow = 0.25
	@nHigh = 0.75
	@aLastActions = []     # actions taken on the last Supervise()

	# Builds a supervisor for a cluster of worker processes; it reads the cluster's health and scales it, and does nothing until it is asked.
	#
	#   poCluster   the cluster to supervise, an object with HealthCheck, FleetMetrics, RestartDead,
	#               ScaleUp and ScaleDown, such as a stzAppCluster
	#   returns     nothing; the object is built
	#   see         Policy, Supervise
	def init(poCluster)
		@oCluster = poCluster

	# Returns the supervisor's name, 'cluster-supervisor' unless SetName changed it.
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

	# Returns the cluster the supervisor was given.
	#
	#   returns    the cluster object
	#   see        init
	def ClusterQ()
		return @oCluster

	# Sets how many workers a tag may have, at least nMin and at most nMax; the tag is matched without regard to case.
	#
	#   pcTag      the facet or profile tag the policy covers
	#   nMin       the fewest workers to keep, raised to 1 if smaller
	#   nMax       the most workers to start, raised to nMin if smaller
	#   returns    the supervisor itself, so calls chain
	#   warning    a second call for the same tag replaces the bounds
	#   see        Decide, SetWaterMarks
	#@ aka  -- policy -------------------------------------------------------------
	def Policy(pcTag, nMin, nMax)
		if nMin < 1  nMin = 1  ok
		if nMax < nMin  nMax = nMin  ok
		_c_ = StzLower("" + pcTag)
		_i_ = This._PolicyIndex(_c_)
		if _i_ > 0
			@aPolicy[_i_][2] = nMin
			@aPolicy[_i_][3] = nMax
		else
			@aPolicy + [ _c_, nMin, nMax ]
		ok
		return This

	# Sets the two load ratios that trigger scaling: below nLow the supervisor scales down, above nHigh it scales up.
	#
	#   nLow       the low-water load ratio, 0.25 by default
	#   nHigh      the high-water load ratio, 0.75 by default
	#   returns    the supervisor itself, so calls chain
	#   warning    one pair of marks serves every tag
	#   see        Decide, ReportLoad
	def SetWaterMarks(nLow, nHigh)
		@nLow = nLow
		@nHigh = nHigh
		return This

	# Records the demand observed for a tag, as a ratio from 0 to 1, replacing the earlier figure.
	#
	#   pcTag      the facet or profile tag, matched without regard to case
	#   nRatio     the observed load from 0 to 1
	#   returns    the supervisor itself, so calls chain
	#   see        LoadOf, FeedLoadFrom, Decide
	#@ aka  The app's observed demand for a profile (0..1: e.g. latency/SLA or in-flight/capacity). This is the honest load signal -- the app measures it; the supervisor enforces the policy.
	def ReportLoad(pcTag, nRatio)
		_c_ = StzLower("" + pcTag)
		_i_ = This._LoadIndex(_c_)
		if _i_ > 0
			@aLoad[_i_][2] = nRatio
		else
			@aLoad + [ _c_, nRatio ]
		ok
		return This

	# Returns the last load ratio reported for a tag; 0 when none was reported.
	#
	#   pcTag      the tag to look up, matched without regard to case
	#   returns    a number
	#   see        ReportLoad
	def LoadOf(pcTag)
		_i_ = This._LoadIndex(StzLower("" + pcTag))
		if _i_ = 0  return 0  ok
		return @aLoad[_i_][2]

	# Reads the load ratio from a performance profile and reports it for a tag, so the signal is measured and not typed in.
	#
	#   pcTag       the tag the load belongs to
	#   poProfile   an object that answers LoadRatio(), such as a stzPerfProfile
	#   returns     the supervisor itself, so calls chain
	#   see         ReportLoad, LoadOf
	#@ aka  The perf-P6 closing of the loop: the load signal MEASURED instead of hand-fed. A stzPerfProfile's LoadRatio() is X/Xmax -- how close the observed workload is to its CPU ceiling -- read from the same engine instruments everything else trusts. Call it before each Supervise()/Cycle() pass (or from the same host tick).
	def FeedLoadFrom(pcTag, poProfile)
		return This.ReportLoad(pcTag, poProfile.LoadRatio())

	# Returns the actions the policy calls for given the fleet metrics, without touching the cluster.
	#
	#   aMetrics   the fleet metrics, a list of hashlists such as [ :tag = 'nlp', :ready = 2, :dead
	#              = 1 ]
	#   returns    a list of [ kind, tag ] pairs, kind being :restart, :scaleup or :scaledown
	#   note       read from the code and run with invented metrics; no cluster was involved
	#   warning    a tag with a policy but no entry in the metrics is skipped; a dead worker gives a
	#              restart first, then the load decides; a tag at its bound gives no scaling
	#   see        Supervise, Policy
	#@ aka  -- the decision (PURE policy) -----------------------------------------
	def Decide(aMetrics)
		_aActions_ = []
		_nP_ = len(@aPolicy)
		for _p_ = 1 to _nP_
			_cTag_ = @aPolicy[_p_][1]
			_nMin_ = @aPolicy[_p_][2]
			_nMax_ = @aPolicy[_p_][3]
			_aM_ = This._MetricFor(aMetrics, _cTag_)
			if len(_aM_) = 0  loop  ok
			_nReady_ = _aM_[:ready]
			_nDead_ = _aM_[:dead]
			_nLoad_ = This.LoadOf(_cTag_)

			if _nDead_ > 0
				_aActions_ + [ :restart, _cTag_ ]
			ok
			if _nLoad_ > @nHigh and _nReady_ < _nMax_
				_aActions_ + [ :scaleup, _cTag_ ]
			but _nLoad_ < @nLow and _nReady_ > _nMin_
				_aActions_ + [ :scaledown, _cTag_ ]
			ok
		next
		return _aActions_

	# Runs one pass: checks the cluster's health, reads its metrics, decides, and applies the actions to the cluster.
	#
	#   returns    the list of actions taken, as Decide returns it
	#   note       one restart call heals every dead worker, however many restart actions there are
	#   warning    it calls HealthCheck, RestartDead, ScaleUp and ScaleDown on the cluster, so it
	#              changes a live fleet; it was run here only against an invented stand-in object,
	#              never a real cluster
	#   see        Decide, Cycle, LastActions
	#@ aka  -- applying the decision to the live cluster --------------------------
	def Supervise()
		@oCluster.HealthCheck()
		_aM_ = @oCluster.FleetMetrics()
		_aActions_ = This.Decide(_aM_)
		This._Apply(_aActions_)
		@aLastActions = _aActions_
		return _aActions_

	def _Apply(aActions)
		_bRestarted_ = 0
		_n_ = len(aActions)
		for _i_ = 1 to _n_
			_cKind_ = aActions[_i_][1]
			_cTag_ = aActions[_i_][2]
			if _cKind_ = :restart
				if NOT _bRestarted_
					@oCluster.RestartDead()   # heals ALL dead in one pass
					_bRestarted_ = 1
				ok
			but _cKind_ = :scaleup
				@oCluster.ScaleUp(_cTag_)
			but _cKind_ = :scaledown
				@oCluster.ScaleDown(_cTag_)
			ok
		next

	# Returns the actions taken by the last Supervise pass; empty before the first.
	#
	#   returns    a list of [ kind, tag ] pairs
	#   see        Supervise
	def LastActions()
		return @aLastActions

	# Runs one Supervise pass and returns how many actions it took, so an agent host can tick the supervisor as a job.
	#
	#   returns    a number; 0 when the fleet was quiescent
	#   note       run here only against an invented stand-in object
	#   warning    same warning as Supervise: it acts on the cluster it was given
	#   see        Supervise, Name_
	#@ aka  -- R5 composition: a supervised job on stzAgentHost ------------------- stzAgentHost ticks Cycle() on any supervised object. So the cluster supervisor runs on the SAME reactor loop the fleet runs on. Returns the number of actions taken this tick (0 -> quiescent).
	def Cycle()
		return len(This.Supervise())

	#-- internals ----------------------------------------------------------

	def _PolicyIndex(pcTag)
		_n_ = len(@aPolicy)
		for _i_ = 1 to _n_
			if @aPolicy[_i_][1] = pcTag  return _i_  ok
		next
		return 0

	def _LoadIndex(pcTag)
		_n_ = len(@aLoad)
		for _i_ = 1 to _n_
			if @aLoad[_i_][1] = pcTag  return _i_  ok
		next
		return 0

	def _MetricFor(aMetrics, pcTag)
		_n_ = len(aMetrics)
		for _i_ = 1 to _n_
			if aMetrics[_i_][:tag] = pcTag  return aMetrics[_i_]  ok
		next
		return []
