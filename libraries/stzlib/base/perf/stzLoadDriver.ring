/*
	stzLoadDriver -- the driven-load harness (perf P11).

	The R-vs-X KNEE -- response time exploding as throughput nears
	its ceiling -- is queueing's signature, and queueing needs
	CONCURRENT ARRIVALS. A serial in-process harness can never show
	it (P7 ruled exactly that). This driver produces the real thing
	with real PROCESSES: it spawns a target stzAppServer as one
	child, N driver clients as more children (each firing its
	requests independently -- 1 concurrent arrivals at the
	listener), and reads client-observed response times back through
	their stdout:

		oL = new stzLoadDriver()
		oL.SetBusyMs(3).SetRequestsPerDriver(30)
		oL.SpawnTarget(0)                 # its own server child
		aRow = oL.DriveWith(1)            #--> [ :drivers, :x, :rMeanMs, :rP95Ms, ... ]
		aCurve = oL.Curve([ 1, 6 ])       # the R-vs-X rows
		oL.Show()                         # the knee, narrated
		oL.Destroy()                      # kills the target child

	This is a CLOSED-LOOP load model (each driver fires its next
	request when the previous answers): with a single-threaded
	server and service demand D, textbook operational analysis says
	X saturates near 1/D while R grows roughly with the number of
	waiting drivers -- and that is precisely what the harness
	measures, from the OUTSIDE, wait time included (the server-side
	bracket cannot see the accept-queue wait; the client can).

	Percentiles are exact: every driver prints every duration; the
	parent folds them into an engine series and sorts.

	Mechanics reuse the fleet's recipes: generated scripts with the
	absolute stzBase path (launch-cwd-proof), ring exe discovered
	from sysargv, /health readiness probe, TTL self-termination so
	an orphaned target cannot outlive its usefulness.
*/

func StzLoadDriver()
	return new stzLoadDriver()

class stzLoadDriver from stzObject

	@oReactor = ""
	@cRingExe = "ring"
	@cBaseRing = ""
	@cTargetScript = ""
	@cDriverScript = ""
	@nTargetJob = 0
	@cHost = "127.0.0.1"
	@nPort = 0
	@cPath = "/work"
	@nBusyMs = 3		# the target handler's CPU-bound cost per request
	@nPerDriver = 30	# requests each driver fires (sequentially)
	@nTtlMs = 120000	# target self-terminates regardless
	@aCurve = []
	bSpawnedTarget = 0

	def init()
		@oReactor = new stzReactor()
		@cRingExe = This._RingExecutable()
		@cBaseRing = This._DeriveStzBasePath()

	# -- configuration --------------------------------------------

	def SetBusyMs(pnMs)
		if isNumber(pnMs) and pnMs >= 0
			@nBusyMs = pnMs
		ok
		return This

	def SetRequestsPerDriver(pnM)
		if isNumber(pnM) and pnM >= 1
			@nPerDriver = pnM
		ok
		return This

	def SetPath(pcPath)
		@cPath = "" + pcPath
		return This

	def SetTtlMs(pnMs)
		if isNumber(pnMs) and pnMs >= 1000
			@nTtlMs = pnMs
		ok
		return This

	# -- the target -----------------------------------------------

	# Drive an ALREADY-RUNNING server (any host:port) instead of
	# spawning one -- the driver fleet works the same.
	def AimAt(pcHost, pnPort)
		@cHost = "" + pcHost
		@nPort = pnPort
		bSpawnedTarget = 0
		return This

	# Spawn the harness's own target child: a stzAppServer whose
	# /work handler burns @nBusyMs of CPU per request (the service
	# demand D under study). pnPort 0 picks one from the wall clock.
	# Returns TRUE when the child answers its readiness probe.
	def SpawnTarget(pnPort)
		if pnPort = 0
			pnPort = 37000 + (StzEngineTimeWallMs() % 900)
		ok
		@nPort = pnPort
		@cHost = "127.0.0.1"
		This._GenerateTargetScript()
		@nTargetJob = @oReactor.SubmitSpawn([
			@cRingExe, @cTargetScript, "" + @nPort, "" + @nBusyMs, "" + @nTtlMs ])
		bSpawnedTarget = 1
		return This.WaitReady(15000)

	def Port()
		return @nPort

	# Probe GET /health until it answers 200 (the child needs a
	# moment to load stzBase and bind).
	def WaitReady(pnTimeoutMs)
		_nDeadline_ = StzEngineTimeNowMs() + pnTimeoutMs
		_cCRLF_ = char(13) + char(10)
		_cReq_ = "GET /health HTTP/1.1" + _cCRLF_ + "Host: local" + _cCRLF_ + "Connection: close" + _cCRLF_ + _cCRLF_
		while StzEngineTimeNowMs() < _nDeadline_
			_nJob_ = @oReactor.SubmitTcp(@cHost, @nPort, _cReq_)
			_cResp_ = @oReactor.AwaitTcp(_nJob_, 1500)
			if StzFindFirst("200 OK", _cResp_) > 0
				return 1
			ok
			StzEngineTimeSleepMs(100)
		end
		return 0

	# -- driving --------------------------------------------------

	# One load level: pnDrivers concurrent driver PROCESSES, each
	# firing @nPerDriver sequential requests and printing every
	# client-observed duration. Returns the level's row:
	# [ :drivers, :requests, :x, :rMeanMs, :rP50Ms, :rP95Ms, :wallMs ]
	def DriveWith(pnDrivers)
		if @nPort = 0
			stzraise("stzLoadDriver: no target -- SpawnTarget() or AimAt() first.")
		ok
		This._GenerateDriverScript()
		_aJobs_ = []
		_nT0_ = StzEngineWatchTimestampMs()
		for _i_ = 1 to pnDrivers
			_aJobs_ + @oReactor.SubmitSpawn([
				@cRingExe, @cDriverScript, @cHost, "" + @nPort, @cPath, "" + @nPerDriver ])
		next
		_oSer_ = new stzPerfSeries(pnDrivers * @nPerDriver + 8)
		_nGot_ = 0
		for _i_ = 1 to pnDrivers
			_cOut_ = @oReactor.AwaitSpawn(_aJobs_[_i_], 60000)
			_nGot_ += This._FoldDurations(_cOut_, _oSer_)
		next
		_nWallMs_ = StzEngineWatchTimestampMs() - _nT0_
		_nX_ = 0
		if _nWallMs_ > 0
			_nX_ = _nGot_ / (_nWallMs_ / 1000)
		ok
		_aRow_ = [
			:drivers = pnDrivers,
			:requests = _nGot_,
			:x = _nX_,
			:rMeanMs = _oSer_.Mean(),
			:rP50Ms = _oSer_.Percentile(50),
			:rP95Ms = _oSer_.Percentile(95),
			:wallMs = _nWallMs_
		]
		_oSer_.Destroy()
		@aCurve + _aRow_
		return _aRow_

	# The R-vs-X curve: one row per concurrency level.
	def Curve(paLevels)
		@aCurve = []
		_nLen_ = ring_len(paLevels)
		for _i_ = 1 to _nLen_
			This.DriveWith(paLevels[_i_])
		next
		return @aCurve

	def CurveRows()
		return @aCurve

	# -- reading the knee -----------------------------------------

	def Explain()
		_aL_ = []
		_nN_ = ring_len(@aCurve)
		_aL_ + ("Driven load -- target " + @cHost + ":" + @nPort + ", D ~" +
			@nBusyMs + "ms CPU/request, " + _nN_ + " level(s).")
		for _i_ = 1 to _nN_
			_r_ = @aCurve[_i_]
			_cLine_ = "  " + _r_[:drivers] + " driver(s): X = "
			_cLine_ += ("" + _r_[:x] + " req/s, R mean " + _r_[:rMeanMs])
			_cLine_ += (" ms, p95 " + _r_[:rP95Ms] + " ms")
			_aL_ + _cLine_
		next
		if _nN_ >= 2
			_rLo_ = @aCurve[1]
			_rHi_ = @aCurve[_nN_]
			_nRGrow_ = 0
			if _rLo_[:rMeanMs] > 0
				_nRGrow_ = _rHi_[:rMeanMs] / _rLo_[:rMeanMs]
			ok
			_cK_ = "The knee, in one sentence: "
			_cK_ += ("" + _rHi_[:drivers] + "x the drivers bought ")
			_cK_ += ("" + This._Round1(_rHi_[:x] / _rLo_[:x]) + "x the throughput at ")
			_cK_ += ("" + This._Round1(_nRGrow_) + "x the response time -- ")
			_cK_ += "past saturation, added load buys only waiting."
			_aL_ + _cK_
		ok
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	def Destroy()
		if bSpawnedTarget and @nTargetJob > 0
			@oReactor.KillSpawnHard(@nTargetJob)
			@nTargetJob = 0
			bSpawnedTarget = 0
		ok
		return This

	# -- internals ------------------------------------------------

	def _RingExecutable()
		_a_ = sysargv
		_n_ = ring_len(_a_)
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
			if $cEngineDir[_i_] = "/"
				_nSlash_ = _i_
			ok
		next
		_cRoot_ = StzLeft($cEngineDir, _nSlash_ - 1)
		return _cRoot_ + "/base/stzBase.ring"

	# The target child: /health + a /work handler burning nBusyMs of
	# CPU on the monotonic clock (real service demand, not a sleep --
	# a sleeping handler would not saturate anything).
	def _GenerateTargetScript()
		@cTargetScript = $cEngineDir + "/../base/perf/.stzloadtarget_gen.ring"
		_cNL_ = char(10)
		_cW_ = 'load "' + @cBaseRing + '"' + _cNL_
		_cW_ += '_a_ = sysargv' + _cNL_
		_cW_ += '_n_ = len(_a_)' + _cNL_
		_cW_ += '_nTtl_ = number(_a_[_n_])' + _cNL_
		_cW_ += '$nBusy = number(_a_[_n_-1])' + _cNL_
		_cW_ += '_nPort_ = number(_a_[_n_-2])' + _cNL_
		_cW_ += '_oS_ = new stzAppServer()' + _cNL_
		_cW_ += '_oS_.Get_("/health", func oReq, oResp { oResp.Text("ok") })' + _cNL_
		_cW_ += '_oS_.Get_("/work", func oReq, oResp {' + _cNL_
		_cW_ += '    _s_ = ""' + _cNL_
		_cW_ += '    _t0_ = StzEngineWatchTimestampMs()' + _cNL_
		_cW_ += '    while StzEngineWatchTimestampMs() - _t0_ < $nBusy' + _cNL_
		_cW_ += '        _s_ += "x"' + _cNL_
		_cW_ += '    end' + _cNL_
		_cW_ += '    oResp.Text("done") })' + _cNL_
		_cW_ += '_oS_.Start(_nPort_, "127.0.0.1")' + _cNL_
		_cW_ += '_oS_.RunFor(_nTtl_)' + _cNL_
		_cW_ += '_oS_.Stop()' + _cNL_
		write(@cTargetScript, _cW_)

	# The driver child: M sequential requests, each timed on the
	# monotonic clock ARRIVAL-TO-ANSWER (connect + queue wait +
	# service), all durations printed for exact parent-side stats.
	def _GenerateDriverScript()
		@cDriverScript = $cEngineDir + "/../base/perf/.stzloaddriver_gen.ring"
		_cNL_ = char(10)
		_cW_ = 'load "' + @cBaseRing + '"' + _cNL_
		_cW_ += '_a_ = sysargv' + _cNL_
		_cW_ += '_n_ = len(_a_)' + _cNL_
		_cW_ += '_nM_ = number(_a_[_n_])' + _cNL_
		_cW_ += '_cPath_ = _a_[_n_-1]' + _cNL_
		_cW_ += '_nPort_ = number(_a_[_n_-2])' + _cNL_
		_cW_ += '_cHost_ = _a_[_n_-3]' + _cNL_
		_cW_ += '_oC_ = new stzReactor()' + _cNL_
		_cW_ += '_cCRLF_ = char(13) + char(10)' + _cNL_
		_cW_ += '_cReq_ = "GET " + _cPath_ + " HTTP/1.1" + _cCRLF_ + "Host: local" + _cCRLF_ + "Connection: close" + _cCRLF_ + _cCRLF_' + _cNL_
		_cW_ += '_cOut_ = "DUR:"' + _cNL_
		_cW_ += 'for _i_ = 1 to _nM_' + _cNL_
		_cW_ += '    _t0_ = StzEngineWatchTimestampNs()' + _cNL_
		_cW_ += '    _nJ_ = _oC_.SubmitTcp(_cHost_, _nPort_, _cReq_)' + _cNL_
		_cW_ += '    _oC_.AwaitTcp(_nJ_, 30000)' + _cNL_
		_cW_ += '    _cOut_ += " " + ((StzEngineWatchTimestampNs() - _t0_) / 1000000)' + _cNL_
		_cW_ += 'next' + _cNL_
		_cW_ += '? _cOut_' + _cNL_
		write(@cDriverScript, _cW_)

	# Parse a driver's "DUR: d1 d2 ..." stdout into the series.
	def _FoldDurations(pcOut, poSeries)
		_nAt_ = StzFindFirst("DUR:", pcOut)
		if _nAt_ = 0
			return 0
		ok
		_cRest_ = StzMidToEnd(pcOut, _nAt_ + 4)
		_aParts_ = StzSplit(ring_trim(_cRest_), " ")
		_nGot_ = 0
		_nLen_ = ring_len(_aParts_)
		for _i_ = 1 to _nLen_
			_cP_ = ring_trim(_aParts_[_i_])
			if _cP_ != "" and isdigit(StzLeft(_cP_, 1))
				poSeries.Record(number(_cP_))
				_nGot_++
			ok
		next
		return _nGot_

	def _Round1(pnV)
		return floor(pnV * 10 + 0.5) / 10
