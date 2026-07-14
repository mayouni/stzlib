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

func StzAppCluster()
	return new stzAppCluster()

# The ring executable that launches workers -- derived from sysargv (the
# interpreter running us), falling back to bare "ring".
func StzRingExecutable()
	_a_ = sysargv
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_c_ = StzLower("" + _a_[_i_])
		if StzFindFirst(_c_, "ring.exe") > 0 or StzRight(_c_, 5) = "/ring" or _c_ = "ring"
			return "" + _a_[_i_]
		ok
	next
	return "ring"


class stzAppCluster from stzObject

	@oPool = NULL          # stzWorkerPool -- profiles + budgets (R8.1)
	@oReactor = NULL       # spawn + curl (R7)
	@cRingExe = ""
	@cBaseRing = ""        # abs path to stzBase.ring (for the worker script)
	@cWorkerScript = ""    # generated worker entry
	@nBasePort = 47100
	@nTtlMs = 30000
	@aFleet = []           # [ [ tag, port, jobId, ready ], ... ] one per worker
	@aRR = []              # [ [ tag, cursor ], ... ] round-robin per profile
	@nLastStatus = 0
	@bStarted = FALSE

	def init()
		@oPool = new stzWorkerPool()
		@oReactor = new stzReactor()
		@cRingExe = StzRingExecutable()
		@cBaseRing = This._DeriveStzBasePath()

	#-- declaring the fleet composition ------------------------------------

	# Declare nWorkers processes of a profile (capability tag + caps).
	# One @aFleet row per worker is created NOW (port assigned at Start),
	# so FleetSize/WorkersOf are correct before and after launch.
	def WithProfile(pcTag, paCaps, nWorkers)
		if nWorkers < 1
			stzraise("A profile needs >= 1 worker.")
		ok
		_cTag_ = StzLower("" + pcTag)
		if @oPool.HasProfile(_cTag_)
			@oPool.Profile(_cTag_).SetBudget(@oPool.Profile(_cTag_).Budget() + nWorkers)
		else
			@oPool.AddProfile(_cTag_, paCaps, nWorkers)
		ok
		if This._RRIndex(_cTag_) = 0
			@aRR + [ _cTag_, 0 ]
		ok
		for _w_ = 1 to nWorkers
			@aFleet + [ _cTag_, 0, 0, FALSE ]   # [ tag, port(0), jobId(0), ready ]
		next
		return This

	# Sugar for the doc's domain profiles (grounded in engine capabilities).
	def WithNLP(n)
		return This.WithProfile("nlp", [ :sentiment, :entities, :classify, :summarize, :translate ], n)
	def WithMath(n)
		return This.WithProfile("math", [ :matrix, :optimize, :stats, :solve ], n)
	def WithSearch(n)
		return This.WithProfile("search", [ :embed, :similarity, :rank, :index ], n)
	def WithVision(n)
		This.WithProfile("vision", [ :ocr, :image ], n)
		@oPool.Profile("vision").UsesExternalTool("python")
		return This

	def WithWorkerTTL(nMs)
		@nTtlMs = nMs
		return This
	def WithBasePort(nPort)
		@nBasePort = nPort
		return This
	def WithRingExe(pcPath)
		@cRingExe = "" + pcPath
		return This

	#-- launching the fleet ------------------------------------------------

	def Start()
		if @bStarted
			stzraise("stzAppCluster already started.")
		ok
		This._GenerateWorkerScript()
		# assign a sequential port + spawn a worker process per fleet row
		_nPort_ = @nBasePort
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			@aFleet[_i_][2] = _nPort_
			@aFleet[_i_][3] = @oReactor.SubmitSpawn([
				@cRingExe, @cWorkerScript,
				"" + _nPort_, @aFleet[_i_][1], "" + @nTtlMs ])
			_nPort_++
		next
		@bStarted = TRUE
		return This

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
				if This._HealthOk(@aFleet[_i_][2])
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

	def _HealthOk(nPort)
		_nJ_ = @oReactor.SubmitHttp(0, "http://127.0.0.1:" + nPort + "/health", "")
		@oReactor.AwaitHttp(_nJ_, 2000)
		return @oReactor.HttpLastStatus() = 200

	#-- routing (the load-balanced proxy) ----------------------------------

	# Round-robin proxy to a READY worker of pcTag; returns the response
	# body. HTTP status via RouteLastStatus().
	def Route(pcTag, pcPath)
		_cTag_ = StzLower("" + pcTag)
		_nPort_ = This._NextWorkerPort(_cTag_)
		if _nPort_ = 0
			@nLastStatus = -1
			return ""
		ok
		_nJ_ = @oReactor.SubmitHttp(0, "http://127.0.0.1:" + _nPort_ + pcPath, "")
		_cBody_ = @oReactor.AwaitHttp(_nJ_, 5000)
		@nLastStatus = @oReactor.HttpLastStatus()
		return _cBody_

	def RouteLastStatus()
		return @nLastStatus

	# Round-robin the next READY worker port for a tag (0 if none ready).
	def _NextWorkerPort(pcTag)
		_aPorts_ = []
		_nF_ = len(@aFleet)
		for _i_ = 1 to _nF_
			if @aFleet[_i_][1] = pcTag and @aFleet[_i_][4]
				_aPorts_ + @aFleet[_i_][2]
			ok
		next
		if len(_aPorts_) = 0
			return 0
		ok
		# advance the profile's round-robin cursor
		_nR_ = This._RRIndex(pcTag)
		if _nR_ = 0  return _aPorts_[1]  ok
		@aRR[_nR_][2] = @aRR[_nR_][2] + 1
		if @aRR[_nR_][2] > len(_aPorts_)
			@aRR[_nR_][2] = 1
		ok
		return _aPorts_[@aRR[_nR_][2]]

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

	#-- teardown -----------------------------------------------------------
	# R8.3: workers self-terminate on their TTL. Graceful drain / kill /
	# health-restart / autoscale is R8.4 (stzAgentHost supervision).
	def Stop()
		if @oReactor != NULL
			@oReactor.Destroy()
			@oReactor = NULL
		ok
		@bStarted = FALSE
		return This

	#-- internals ----------------------------------------------------------

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
		       '_oS_.Start(_nPort_, "127.0.0.1")' + _cNL_ +
		       '_oS_.RunFor(_nTtl_)' + _cNL_
		write(@cWorkerScript, _cW_)
