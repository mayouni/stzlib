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
#   oSup.Policy(:nlp, 1, 4).Policy(:graph, 1, 3).WithWaterMarks(0.25, 0.75)
#   oSup.ReportLoad(:nlp, 0.9)      # the app's observed demand (0..1)
#   oSup.Supervise()                # heal + scale to policy
#   oHost.Supervise(oSup, 200)      # ...or run it as a supervised job (R5)
# -----------------------------------------------------------------------------

func StzClusterSupervisor(poCluster)
	return new stzClusterSupervisor(poCluster)

class stzClusterSupervisor from stzObject

	@cName = "cluster-supervisor"
	@oCluster = NULL
	@aPolicy = []          # [ [ tag, min, max ], ... ]
	@aLoad = []            # [ [ tag, ratio(0..1) ], ... ]  observed demand
	@nLow = 0.25
	@nHigh = 0.75
	@aLastActions = []     # actions taken on the last Supervise()

	def init(poCluster)
		@oCluster = poCluster

	def Name_()
		return @cName

	def SetName(pcName)
		@cName = "" + pcName
		return This

	def ClusterQ()
		return @oCluster

	#-- policy -------------------------------------------------------------

	# Bound a profile's fleet size: never below nMin, never above nMax.
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

	def WithWaterMarks(nLow, nHigh)
		@nLow = nLow
		@nHigh = nHigh
		return This

	# The app's observed demand for a profile (0..1: e.g. latency/SLA or
	# in-flight/capacity). This is the honest load signal -- the app
	# measures it; the supervisor enforces the policy.
	def ReportLoad(pcTag, nRatio)
		_c_ = StzLower("" + pcTag)
		_i_ = This._LoadIndex(_c_)
		if _i_ > 0
			@aLoad[_i_][2] = nRatio
		else
			@aLoad + [ _c_, nRatio ]
		ok
		return This

	def LoadOf(pcTag)
		_i_ = This._LoadIndex(StzLower("" + pcTag))
		if _i_ = 0  return 0  ok
		return @aLoad[_i_][2]

	#-- the decision (PURE policy) -----------------------------------------

	# Given the current fleet metrics + reported load, return the actions
	# to take: [ [ :restart, tag ], [ :scaleup, tag ], [ :scaledown, tag ] ].
	# Dead-worker restart takes precedence; then load-driven scaling within
	# the [min, max] bounds. No side effects -- Supervise() applies these.
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

	#-- applying the decision to the live cluster --------------------------

	# One supervision pass: refresh health, decide, apply. Returns the
	# actions taken.
	def Supervise()
		@oCluster.HealthCheck()
		_aM_ = @oCluster.FleetMetrics()
		_aActions_ = This.Decide(_aM_)
		This._Apply(_aActions_)
		@aLastActions = _aActions_
		return _aActions_

	def _Apply(aActions)
		_bRestarted_ = FALSE
		_n_ = len(aActions)
		for _i_ = 1 to _n_
			_cKind_ = aActions[_i_][1]
			_cTag_ = aActions[_i_][2]
			if _cKind_ = :restart
				if NOT _bRestarted_
					@oCluster.RestartDead()   # heals ALL dead in one pass
					_bRestarted_ = TRUE
				ok
			but _cKind_ = :scaleup
				@oCluster.ScaleUp(_cTag_)
			but _cKind_ = :scaledown
				@oCluster.ScaleDown(_cTag_)
			ok
		next

	def LastActions()
		return @aLastActions

	#-- R5 composition: a supervised job on stzAgentHost -------------------
	# stzAgentHost ticks Cycle() on any supervised object. So the cluster
	# supervisor runs on the SAME reactor loop the fleet runs on. Returns
	# the number of actions taken this tick (0 -> quiescent).
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
