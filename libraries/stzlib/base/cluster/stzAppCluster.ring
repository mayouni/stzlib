# base/cluster/stzAppCluster.ring
# -----------------------------------------------------------------------------
# R8.3 (the SCALE plane) -- stzAppCluster: THE FLEET (true horizontal
# scale). (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.)
#
# Ring's VM is single-threaded, so CPU-bound parallelism must cross
# PROCESSES. A cluster is a front host + a fleet of stzAppServer worker
# PROCESSES -- each its own Ring VM + resident engine -- launched via the
# reactor's async SPAWN (R7) and proxied via the reactor's async CURL/TCP
# (native TLS, R7). This is what delivers the "1000+ concurrent" scale
# the clustering doc promised; specialization stays a WORKER PROFILE
# (R8.1), never a subclass.
#
#   oC = new stzAppCluster()
#   oC.WithNLP(3).WithMath(2)          # spawn 3 nlp + 2 math worker procs
#   oC.Start()                          # launch the fleet on sequential ports
#   oC.WaitReady(20000)                 # each worker binds + answers /health
#   ? oC.Route("nlp", "/work?q=hello")  # round-robin proxy to an nlp worker
#   oC.Stop()
#
# Worker lifecycle: each worker is `ring stzWorkerMain <port> <profile>
# <ttl>` (the script is GENERATED with an absolute stzBase load, since
# Ring's `load` needs a compile-time literal). Workers self-terminate on
# their TTL; graceful drain / kill / health-restart / autoscale is R8.4
# (supervision), which composes stzAgentHost. Load-isolation bookkeeping
# rides stzWorkerPool (R8.1).
# -----------------------------------------------------------------------------

func StzAppClusterQ()
	return new stzAppCluster()


class stzAppCluster from stzObject

	@oPool = NULL          # stzWorkerPool -- profiles + budgets (R8.1)
	@oReactor = NULL       # spawn + curl (R7)
	@cRingExe = ""
	@cBaseRing = ""        # abs path to stzBase.ring (for the worker script)
	@cWorkerScript = ""    # generated worker entry
	@nBasePort = 47100
	@nTtlMs = 30000
	@aFleet = []           # [ [ tag, port, jobId, ready, draining ], ... ] per worker
	@aRR = []              # [ [ tag, cursor ], ... ] round-robin per profile
	@nNextPort = 0         # next free port for scale-up / restart
	@nLastStatus = 0
	@bStarted = FALSE
	@oClassifier = NULL    # R8.2 smart router (lazy, bound to the catalog)
	@cWhy = ""
	# resilience: retry-with-failover + per-worker circuit breaker
	@nMaxTries = 3         # max workers to try per Route (failover cap)
	@nBreakerThreshold = 3 # consecutive failures that OPEN a worker's circuit
	@nBreakerCooldownMs = 5000  # how long a circuit stays open before half-open
	# observability: latency percentiles + trace ids
	@oTelemetry = NULL     # stzClusterTelemetry (per-facet histograms + traces)
	@cLastTrace = ""       # the trace id of the most recent Route
		@oLimiter = NULL       # stzRateLimiter (per-facet token buckets, opt-in)
		@nKilled = 0           # lifetime forced-kill count (orphan-cleanup metric)

	def init()
		@oPool = new stzWorkerPool()
		@oReactor = new stzReactor()
		@cRingExe = This._RingExecutable()
		@cBaseRing = This._DeriveStzBasePath()
		@oTelemetry = new stzClusterTelemetry("cluster")
		@oLimiter = new stzRateLimiter("cluster")

	#-- declaring the fleet composition ------------------------------------

	# Declare nWorkers processes of a profile (capability tag + caps).
	# One @aFleet row per worker is created NOW (port assigned at Start),
	# so FleetSize/WorkersOf are correct before and after launch.
	def AddProfile(pcTag, paCaps, nWorkers)
		if nWorkers < 1
			stzraise("A profile needs >= 1 worker.")
		ok
		_cTag_ = StzLower("" + pcTag)
		if @oPool.HasProfile(_cTag_)
			@oPool.ProfileQ(_cTag_).SetBudget(@oPool.ProfileQ(_cTag_).Budget() + nWorkers)
		else
			@oPool.AddProfile(_cTag_, paCaps, nWorkers)
		ok
		if This._RRIndex(_cTag_) = 0
			@aRR + [ _cTag_, 0 ]
		ok
		for _w_ = 1 to nWorkers
			# tag,port,jobId,ready,draining,failures,circuitOpenUntilMs,host
			@aFleet + [ _cTag_, 0, 0, FALSE, FALSE, 0, 0, "127.0.0.1" ]
		next
		return

	#-- resilience config --------------------------------------------------

	# Cap the number of workers a single Route tries before giving up
	# (retry-with-failover across healthy workers of the facet).

		def AddProfileQ(pcTag, paCaps, nWorkers)
			This.AddProfile(pcTag, paCaps, nWorkers)
			return This

	def SetMaxTries(n)
		if n < 1  n = 1  ok
		@nMaxTries = n
		return This

	# Circuit breaker: after nThreshold consecutive failures a worker's
	# circuit OPENS (it is skipped for nCooldownMs, then half-open: one
	# probe re-closes on success or re-opens on failure).
	def SetCircuitBreaker(nThreshold, nCooldownMs)
		if nThreshold < 1  nThreshold = 1  ok
		@nBreakerThreshold = nThreshold
		@nBreakerCooldownMs = nCooldownMs
		return This

	# Rate limit a facet at the front door: nRatePerSec sustained with a
	# bucket of nBurst (the largest instantaneous burst absorbed). A facet
	# with no SetRateLimit is UNLIMITED. Requests over the limit are shed
	# with a -429 status before any worker is touched.
	def SetRateLimit(pcFacet, nRatePerSec, nBurst)
		@oLimiter.SetLimit(StzLower("" + pcFacet), nRatePerSec, nBurst)
		return This

	# Register a PRE-EXISTING worker (e.g. a remote/static host) into a
	# facet's pool -- it participates in routing, failover and health like
	# a spawned worker. host:port endpoint.
	def RegisterExternalWorker(pcFacet, pcHost, nPort)
		_cTag_ = StzLower("" + pcFacet)
		if This._RRIndex(_cTag_) = 0
			@aRR + [ _cTag_, 0 ]
			@oPool.AddProfile(_cTag_, [ _cTag_ ], 1)
		ok
		# ready TRUE: assumed up; HealthCheck / the circuit breaker verify
		@aFleet + [ _cTag_, nPort, 0, TRUE, FALSE, 0, 0, "" + pcHost ]
		return This

	# THE GENERAL FORM: specialize workers along ANY facet in THIS cluster's
	# catalog (not just the doc's four). Capabilities, provenance and any
	# external tool are taken from the pool's own catalog (instance-scoped,
	# customizable via CatalogQ()/DefineFacet).
	#   oC.WithFacet(:graph, 2).WithFacet(:knowledge, 2).WithFacet(:neural, 1)
	def WithFacet(pcFacet, n)
		if NOT @oPool.CatalogQ().Has(pcFacet)
			stzraise("stzAppCluster.WithFacet: '" + pcFacet + "' is not in this " +
			         "cluster's facet catalog. Define it via CatalogQ()/DefineFacet, " +
			         "or see CatalogQ().Names().")
		ok
		_cTag_ = StzLower("" + pcFacet)
		This.AddProfile(_cTag_, @oPool.CatalogQ().CapabilitiesOf(pcFacet), n)
		# call THROUGH Profile() (no local assign -> no copy; aliasing)
		@oPool.ProfileQ(_cTag_).SetRealizedBy(@oPool.CatalogQ().ModulesOf(pcFacet))
		if @oPool.CatalogQ().IsPolyglot(pcFacet)
			@oPool.ProfileQ(_cTag_).SetExternalTool(@oPool.CatalogQ().ToolOf(pcFacet))
		ok
		return This

	# The cluster's facet catalog (instance-scoped -- customize per
	# deployment: DefineFacet/DefinePolyglotFacet/Drop before WithFacet).
	def CatalogQ()
		return @oPool.CatalogQ()

	# Sugar for the doc's four (each just a WithFacet over the catalog).
	def WithNLP(n)
		return This.WithFacet(:nlp, n)
	def WithMath(n)
		return This.WithFacet(:math, n)
	def WithSearch(n)
		return This.WithFacet(:search, n)
	def WithVision(n)
		return This.WithFacet(:vision, n)

	def SetWorkerTTL(nMs)
		@nTtlMs = nMs
		return This
	def SetBasePort(nPort)
		@nBasePort = nPort
		return This
	def SetRingExe(pcPath)
		@cRingExe = "" + pcPath
		return This

	#-- launching the fleet ------------------------------------------------

	def Start()
		if @bStarted
			stzraise("stzAppCluster already started.")
		ok
		This._GenerateWorkerScript()
		# assign a sequential port + spawn a worker process per OWNED fleet
		# row. Rows with a port already set are EXTERNAL (RegisterExternalWorker
		# -- a remote/static host we do NOT spawn); leave their endpoint intact.
		_nPort_ = @nBasePort
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][2] != 0  loop  ok   # external -> not ours to spawn
			@aFleet[_i_][2] = _nPort_
			@aFleet[_i_][3] = This._SpawnWorker(@aFleet[_i_][1], _nPort_)
			_nPort_++
		next
		@nNextPort = _nPort_
		@bStarted = TRUE
		return This

	def _SpawnWorker(pcTag, nPort)
		return @oReactor.SubmitSpawn([
			@cRingExe, @cWorkerScript, "" + nPort, "" + pcTag, "" + @nTtlMs ])

	# Poll every worker's /health until it answers 200 (workers need a
	# moment to load stzBase + bind). Returns the number now ready.
	def WaitReady(nTimeoutMs)
		_nDeadline_ = StzEngineTimeNowMs() + nTimeoutMs
		while StzEngineTimeNowMs() < _nDeadline_
			_nReady_ = 0
			_nF_ = len(@aFleet)
			for _i_ = 1 to _nF_
				if @aFleet[_i_][4]
					_nReady_++
					loop
				ok
				if This._HealthOk(_i_)
					@aFleet[_i_][4] = TRUE
					_nReady_++
				ok
			next
			if _nReady_ = len(@aFleet)
				return _nReady_
			ok
			_nT_ = @oReactor.SubmitTimer(200)
			@oReactor.AwaitTimer(_nT_, 500)
		end
		return This.ReadyCount()

	def _HealthOk(nIdx)
		_nJ_ = @oReactor.SubmitHttp(0, "http://" + This._EndpointOf(nIdx) + "/health", "")
		@oReactor.AwaitHttp(_nJ_, 2000)
		# HttpLastStatus is a GLOBAL updated only when a job DRAINS; on an
		# await TIMEOUT it stays stale (a prior 200). A drained job is reaped
		# -> JobState = -2 confirms THIS request actually completed.
		if @oReactor.JobState(_nJ_) != -2  return FALSE  ok
		return @oReactor.HttpLastStatus() = 200

	def _EndpointOf(nIdx)
		return @aFleet[nIdx][8] + ":" + @aFleet[nIdx][2]

	#-- routing: RETRY-WITH-FAILOVER + per-worker CIRCUIT BREAKER -----------

	# Proxy to a healthy worker of pcTag. On a failed attempt (transport
	# error or non-2xx), FAIL OVER to the next healthy worker, up to
	# SetMaxTries. A worker that fails SetCircuitBreaker consecutive times
	# has its circuit OPENED (skipped for the cooldown, then half-open). A
	# success resets/closes its circuit. Path is SSRF/CRLF-validated first.
	def Route(pcTag, pcPath)
		if NOT This._SafePath(pcPath)
			@cWhy = "unsafe proxy path rejected (must start with '/', no CRLF): " + pcPath
			@nLastStatus = -1
			return ""
		ok
		_cTag_ = StzLower("" + pcTag)
		# one TRACE id per request, shared across every failover attempt, and
		# put ON THE WIRE (a _trace query param) so a worker sees the same id.
		_cTrace_ = @oTelemetry.NewTraceId()
		@cLastTrace = _cTrace_
		_cSep_ = "?"
		if StzFindFirst("?", pcPath) > 0  _cSep_ = "&"  ok
		_cTracedPath_ = pcPath + _cSep_ + "_trace=" + _cTrace_
		_nReqStart_ = StzEngineTimeNowMs()   # end-to-end latency clock
		# RATE LIMIT (admission control at the front door): if this facet has
		# a configured limit and its token bucket is empty, SHED the request
		# with a 429 BEFORE touching a worker -- a flooding client never
		# reaches (or exhausts) the fleet. Still traced (0 attempts, so no
		# latency sample), with a distinct -429 status callers can branch on.
		if NOT @oLimiter.Allow(_cTag_)
			@cWhy = "rate limited: facet '" + _cTag_ + "' exceeded " +
				@oLimiter.RateOf(_cTag_) + "/s (burst " + @oLimiter.BurstOf(_cTag_) + ")"
			@nLastStatus = -429
			@oTelemetry.RecordRequest(_cTrace_, _cTag_, "ratelimited", -429,
				StzEngineTimeNowMs() - _nReqStart_, 0)
			return ""
		ok
		_aIdx_ = This._RoutableIndices(_cTag_)
		if len(_aIdx_) = 0
			@cWhy = "no routable worker for facet '" + _cTag_ + "' (none ready, or all circuits open)"
			@nLastStatus = -1
			@oTelemetry.RecordRequest(_cTrace_, _cTag_, "none", -1,
				StzEngineTimeNowMs() - _nReqStart_, 0)
			return ""
		ok
		_nTries_ = @nMaxTries
		if _nTries_ > len(_aIdx_)  _nTries_ = len(_aIdx_)  ok
		_nLastStatus_ = -1
		for _t_ = 1 to _nTries_
			_nIdx_ = _aIdx_[_t_]
			_nJ_ = @oReactor.SubmitHttp(0, "http://" + This._EndpointOf(_nIdx_) + _cTracedPath_, "")
			_cBody_ = @oReactor.AwaitHttp(_nJ_, 5000)
			# HttpLastStatus is a GLOBAL, refreshed only when a job DRAINS. On
			# an await TIMEOUT (a hung/black-holed worker) it keeps a PRIOR
			# call's status -- so a healthy 200 would be misread onto a dead
			# worker. A drained job is reaped -> JobState = -2 proves THIS
			# attempt actually completed; only then is the status trustworthy.
			_bDrained_ = (@oReactor.JobState(_nJ_) = -2)
			_nStatus_ = -1
			if _bDrained_  _nStatus_ = @oReactor.HttpLastStatus()  ok
			_nLastStatus_ = _nStatus_
			if _bDrained_ and _nStatus_ >= 200 and _nStatus_ < 400
				This._RecordSuccess(_nIdx_)
				@nLastStatus = _nStatus_
				@cWhy = "ok via " + This._EndpointOf(_nIdx_) + " (attempt " + _t_ + ")"
				# record the END-TO-END request span (attempts = _t_; >1 = failover)
				@oTelemetry.RecordRequest(_cTrace_, _cTag_, This._EndpointOf(_nIdx_),
					_nStatus_, StzEngineTimeNowMs() - _nReqStart_, _t_)
				return _cBody_
			ok
			This._RecordFailure(_nIdx_)   # count + maybe open the circuit
		next
		@nLastStatus = _nLastStatus_
		@cWhy = "all " + _nTries_ + " worker(s) failed for facet '" + _cTag_ + "'"
		@oTelemetry.RecordRequest(_cTrace_, _cTag_, "none", _nLastStatus_,
			StzEngineTimeNowMs() - _nReqStart_, _nTries_)
		return ""

	def RouteLastStatus()
		return @nLastStatus

	def Why()
		return @cWhy

	#-- observability (latency percentiles + trace ids) --------------------

	def TelemetryQ()
		return @oTelemetry

	# The trace id assigned to the most recent Route (correlates the front
	# host's record with the worker's _trace on the wire).
	def LastTraceId()
		return @cLastTrace

	# Tail-aware latency for a facet (ms; the engine histogram bucket bound).
	def LatencyP50(pcFacet)
		return @oTelemetry.LatencyP50(pcFacet)
	def LatencyP90(pcFacet)
		return @oTelemetry.LatencyP90(pcFacet)
	def LatencyP99(pcFacet)
		return @oTelemetry.LatencyP99(pcFacet)
	def LatencyStats(pcFacet)
		return @oTelemetry.LatencyStats(pcFacet)

	# The last n request records: [ id, facet, endpoint, status, durMs, attempts ].
	def RecentTraces(n)
		return @oTelemetry.RecentTraces(n)

	#-- rate limiting (front-door admission) -------------------------------

	def LimiterQ()
		return @oLimiter

	# How many requests this facet has shed for exceeding its rate limit.
	def RateLimitedCount(pcFacet)
		return @oLimiter.RejectedCount(pcFacet)

	# Tokens left in a facet's bucket (-1 = unlimited / no limit configured).
	def TokensAvailable(pcFacet)
		return @oLimiter.Available(pcFacet)

	# A proxy path is safe only if it starts with "/" (so "@host" / a bare
	# host can never land in the URL AUTHORITY -> no SSRF host-override)
	# and carries no CR/LF (no request smuggling / header injection).
	def _SafePath(pcPath)
		_c_ = "" + pcPath
		if _c_ = "" or StzLeft(_c_, 1) != "/"
			return FALSE
		ok
		if StzFindFirst(char(13), _c_) > 0 or StzFindFirst(char(10), _c_) > 0
			return FALSE
		ok
		return TRUE

	# The fleet INDICES of workers routable for pcTag -- READY, NOT
	# draining, and circuit-CLOSED (open circuits past their cooldown are
	# half-open = eligible again) -- ordered starting from the profile's
	# round-robin cursor so load spreads AND failover hits a different
	# worker. Empty when nothing is routable.
	def _RoutableIndices(pcTag)
		_nNow_ = StzEngineTimeNowMs()
		_aAll_ = []
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][1] = pcTag and @aFleet[_i_][4] and NOT @aFleet[_i_][5]
				if @aFleet[_i_][7] = 0 or _nNow_ >= @aFleet[_i_][7]   # circuit closed / half-open
					_aAll_ + _i_
				ok
			ok
		next
		if len(_aAll_) = 0  return []  ok
		# rotate the list to start at the RR cursor, then advance it
		_nR_ = This._RRIndex(pcTag)
		if _nR_ = 0  return _aAll_  ok
		@aRR[_nR_][2] = @aRR[_nR_][2] + 1
		if @aRR[_nR_][2] > len(_aAll_)  @aRR[_nR_][2] = 1  ok
		_nStart_ = @aRR[_nR_][2]
		_aOrd_ = []
		for _k_ = 0 to len(_aAll_) - 1
			_j_ = _nStart_ + _k_
			if _j_ > len(_aAll_)  _j_ -= len(_aAll_)  ok
			_aOrd_ + _aAll_[_j_]
		next
		return _aOrd_

	# A successful call CLOSES the worker's circuit (resets failures).
	def _RecordSuccess(nIdx)
		@aFleet[nIdx][6] = 0
		@aFleet[nIdx][7] = 0
		return This

	# A failed call increments the worker's consecutive-failure count; at
	# the threshold its circuit OPENS for the cooldown window.
	def _RecordFailure(nIdx)
		@aFleet[nIdx][6] = @aFleet[nIdx][6] + 1
		if @aFleet[nIdx][6] >= @nBreakerThreshold
			@aFleet[nIdx][7] = StzEngineTimeNowMs() + @nBreakerCooldownMs
		ok
		return This

	def CircuitOpenCount()
		_nNow_ = StzEngineTimeNowMs()
		_n_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][7] != 0 and _nNow_ < @aFleet[_i_][7]  _n_++  ok
		next
		return _n_

	def _RRIndex(pcTag)
		_n_ = len(@aRR)
		for _i_ = 1 to _n_
			if @aRR[_i_][1] = pcTag  return _i_  ok
		next
		return 0

	#-- introspection ------------------------------------------------------

	def FleetSize()
		return len(@aFleet)

	def ReadyCount()
		_n_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][4]  _n_++  ok
		next
		return _n_

	def WorkersOf(pcTag)
		_c_ = StzLower("" + pcTag)
		_n_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][1] = _c_  _n_++  ok
		next
		return _n_

	def Ports()
		_a_ = []
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			_a_ + @aFleet[_i_][2]
		next
		return _a_

	def PoolQ()
		return @oPool

	def ReactorQ()
		return @oReactor

	#-- R8.2 smart routing (classify -> route) -----------------------------

	# A request classifier bound to THIS cluster's facet catalog (created
	# lazily, after facets are declared).
	def ClassifierQ()
		if @oClassifier = NULL
			@oClassifier = new stzRequestClassifier()
			@oClassifier.SetCatalog(@oPool.CatalogQ())
		ok
		return @oClassifier

	# Classify a request to a facet (R8.2), then proxy it to a worker of
	# that facet (R8.3). Returns the response body; "" (with negative
	# RouteLastStatus) when the request is undecidable or has no worker.
	def RouteRequest(pcMethod, pcPath, pcContentType, pcBody)
		_cFacet_ = This.ClassifierQ().Classify(pcMethod, pcPath, pcContentType, pcBody)
		if _cFacet_ = ""
			@nLastStatus = -1
			return ""
		ok
		return This.Route(_cFacet_, pcPath)

	#-- R8.4 health + elastic scale (the supervision surface) --------------

	# Re-probe every worker's /health and refresh its ready flag. A worker
	# that stops answering (crashed, exited its TTL) flips to NOT ready.
	# Returns the number ready now.
	def HealthCheck()
		_nReady_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][2] = 0  loop  ok   # never launched
			_bOk_ = This._HealthOk(_i_)
			@aFleet[_i_][4] = _bOk_
			if _bOk_  _nReady_++  ok
		next
		return _nReady_

	# Workers that were launched but are not answering (crashed / expired).
	def DeadCount()
		_n_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][2] != 0 and NOT @aFleet[_i_][4] and NOT @aFleet[_i_][5]
				_n_++
			ok
		next
		return _n_

	# Add ONE worker of a profile (elastic scale-up). Spawns a new process
	# on a fresh port; call WaitReady()/HealthCheck() to see it come up.
	# Returns the new port.
	def ScaleUp(pcTag)
		_cTag_ = StzLower("" + pcTag)
		if This._RRIndex(_cTag_) = 0
			stzraise("stzAppCluster.ScaleUp: unknown profile '" + _cTag_ + "'.")
		ok
		_nPort_ = @nNextPort
		@nNextPort++
		_nJob_ = This._SpawnWorker(_cTag_, _nPort_)
		@aFleet + [ _cTag_, _nPort_, _nJob_, FALSE, FALSE, 0, 0, "127.0.0.1" ]
		@oPool.ProfileQ(_cTag_).SetBudget(@oPool.ProfileQ(_cTag_).Budget() + 1)
		return _nPort_

	# GRACEFUL drain-down: mark one ready worker of a profile DRAINING --
	# routing stops immediately (it finishes in-flight work), and the
	# process self-exits on its TTL. Returns the drained port, or 0 if
	# there is nothing to drain. (Forced kill of a hung worker is a small
	# future engine add; drain is the graceful path.)
	def ScaleDown(pcTag)
		_cTag_ = StzLower("" + pcTag)
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][1] = _cTag_ and @aFleet[_i_][4] and NOT @aFleet[_i_][5]
				@aFleet[_i_][5] = TRUE   # draining -> no new routes
				if @oPool.ProfileQ(_cTag_).Budget() > 1
					@oPool.ProfileQ(_cTag_).SetBudget(@oPool.ProfileQ(_cTag_).Budget() - 1)
				ok
				return @aFleet[_i_][2]
			ok
		next
		return 0

	# Respawn every dead worker in place (health-driven self-healing).
	# Returns the number restarted.
	def RestartDead()
		_nRestarted_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][2] != 0 and NOT @aFleet[_i_][4] and NOT @aFleet[_i_][5]
				# FORCE-KILL the old process first: a worker can read "dead"
				# (not answering /health) while its process is HUNG, not gone.
				# Respawning without killing it would ORPHAN the hung process;
				# a genuinely-exited one returns -3 (harmless, not counted).
				if @aFleet[_i_][3] != 0
					if @oReactor.KillSpawnHard(@aFleet[_i_][3]) = 0  @nKilled++  ok
				ok
				# fresh port avoids a dead worker's lingering socket
				_nPort_ = @nNextPort
				@nNextPort++
				@aFleet[_i_][2] = _nPort_
				@aFleet[_i_][3] = This._SpawnWorker(@aFleet[_i_][1], _nPort_)
				@aFleet[_i_][6] = 0   # a restarted worker starts with a
				@aFleet[_i_][7] = 0   # clean circuit (no stale failures)
				_nRestarted_++
			ok
		next
		return _nRestarted_

	#-- forced kill + orphan cleanup (the forceful sibling of drain) --------

	# Force-kill EVERY spawned worker of a facet (SIGKILL). The forceful
	# counterpart to ScaleDown's graceful drain: use it on a WEDGED worker
	# that neither answers health nor self-exits on its TTL. Marks each not
	# ready and returns how many were actually killed. External workers
	# (RegisterExternalWorker, jobId 0) are NOT ours to kill and are skipped.
	def ForceKill(pcTag)
		_cTag_ = StzLower("" + pcTag)
		_n_ = 0
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][1] = _cTag_ and @aFleet[_i_][3] != 0
				if This._KillWorker(_i_)  _n_++  ok
			ok
		next
		return _n_

	# Total workers force-killed over the cluster's life (a hung-worker /
	# orphan-cleanup signal for the health console).
	def KilledCount()
		return @nKilled

	def _KillWorker(nIdx)
		if @aFleet[nIdx][3] = 0  return FALSE  ok   # external / not spawned
		_rc_ = @oReactor.KillSpawnHard(@aFleet[nIdx][3])
		@aFleet[nIdx][4] = FALSE                     # no longer ready
		if _rc_ = 0
			@nKilled++
			return TRUE
		ok
		return FALSE                                 # -3 already exited, etc.

	# A per-profile metrics snapshot the supervisor reads (REAL counts).
	def FleetMetrics()
		_a_ = []
		_aTags_ = @oPool.Tags()
		_nT_ = len(_aTags_)
		for _t_ = 1 to _nT_
			_cTag_ = _aTags_[_t_]
			_nReady_ = 0  _nDrain_ = 0  _nDead_ = 0  _nTotal_ = 0
			_nF_ = len(@aFleet)
			for _i_ = 1 to _nF_
				if @aFleet[_i_][1] = _cTag_
					_nTotal_++
					if @aFleet[_i_][5]
						_nDrain_++
					but @aFleet[_i_][4]
						_nReady_++
					but @aFleet[_i_][2] != 0
						_nDead_++
					ok
				ok
			next
			_a_ + [ :tag = _cTag_, :total = _nTotal_, :ready = _nReady_,
			        :draining = _nDrain_, :dead = _nDead_ ]
		next
		return _a_

	#-- teardown -----------------------------------------------------------
	# R8.3: workers self-terminate on their TTL. Graceful drain / kill /
	# health-restart / autoscale is R8.4 (stzAgentHost supervision).
	def Stop()
		if @oReactor != NULL
			# ORPHAN CLEANUP: force-kill every worker PROCESS we spawned so
			# NONE outlive the cluster. TTL self-exit is the graceful path;
			# this is the guarantee (a hung worker would otherwise linger as
			# an orphan). External (jobId 0) workers are not ours -- skipped.
			_nF_ = len(@aFleet)
			for _i_ = 1 to _nF_
				if @aFleet[_i_][3] != 0
					if @oReactor.KillSpawnHard(@aFleet[_i_][3]) = 0  @nKilled++  ok
				ok
			next
			@oReactor.Destroy()
			@oReactor = NULL
		ok
		if @oTelemetry != NULL
			@oTelemetry.Destroy()   # free the engine histogram handles
		ok
		if @oLimiter != NULL
			@oLimiter.Destroy()     # free the engine token-bucket handles
		ok
		@bStarted = FALSE
		return This

	#-- internals ----------------------------------------------------------

	# The ring interpreter that launches workers -- derived from sysargv
	# (the interpreter running us), falling back to bare "ring".
	def _RingExecutable()
		_a_ = sysargv
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_c_ = StzLower("" + _a_[_i_])
			if StzFindFirst("ring.exe", _c_) > 0 or StzRight(_c_, 5) = "/ring" or _c_ = "ring"
				return "" + _a_[_i_]
			ok
		next
		return "ring"

	def _DeriveStzBasePath()
		_nSlash_ = 0
		_nL_ = len($cEngineDir)
		for _i_ = 1 to _nL_
			if $cEngineDir[_i_] = "/"  _nSlash_ = _i_  ok
		next
		_cRoot_ = StzLeft($cEngineDir, _nSlash_ - 1)      # .../stzlib
		return _cRoot_ + "/base/stzBase.ring"

	# The worker entry: a standalone stzAppServer tagged with its profile,
	# serving /health + /work, self-terminating on its TTL. Generated
	# (not shipped as a fixed file) so the absolute stzBase load is a
	# compile-time literal regardless of the launch cwd.
	def _GenerateWorkerScript()
		@cWorkerScript = $cEngineDir + "/../base/cluster/.stzworker_gen.ring"
		_cNL_ = char(10)
		_cW_ = 'load "' + @cBaseRing + '"' + _cNL_ +
		       '_a_ = sysargv' + _cNL_ +
		       '_n_ = len(_a_)' + _cNL_ +
		       '_nTtl_ = number(_a_[_n_])' + _cNL_ +
		       '_cProfile_ = _a_[_n_-1]' + _cNL_ +
		       '_nPort_ = number(_a_[_n_-2])' + _cNL_ +
		       '_oS_ = new stzAppServer()' + _cNL_ +
		       '_oS_.Get_("/health", func oReq, oResp { oResp.Text("ok:" + _cProfile_) })' + _cNL_ +
		       '_oS_.Get_("/work", func oReq, oResp {' + _cNL_ +
		       '    oResp.Text(_cProfile_ + ":done:" + oReq.Query("q")) })' + _cNL_ +
		       '_oS_.Get_("/info", func oReq, oResp {' + _cNL_ +
		       '    oResp.Json([ "profile", _cProfile_, "port", _nPort_, "pid", 0 ]) })' + _cNL_ +
		       '_oS_.Get_("/echo", func oReq, oResp {' + _cNL_ +
		       '    oResp.Text("trace=" + oReq.Query("_trace")) })' + _cNL_ +
		       '_oS_.Start(_nPort_, "127.0.0.1")' + _cNL_ +
		       '_oS_.RunFor(_nTtl_)' + _cNL_ +
		       '_oS_.Stop()' + _cNL_     # join the reactor loop thread on exit
		write(@cWorkerScript, _cW_)
