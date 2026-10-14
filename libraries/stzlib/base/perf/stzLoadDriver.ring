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

# Drives real concurrent load at a server with separate processes and measures the response time clients see, to show the knee of the curve.
#
# The knee, response time exploding as throughput nears its ceiling, is the signature of queueing,
# and queueing needs concurrent arrivals that a serial in-process harness can never produce. The
# driver spawns a target stzAppServer as a child, or aims at a server already running, then runs a
# number of driver processes at once, each firing its requests one after another and printing every
# duration it observed, wait in the accept queue included. It is a closed-loop model: a driver fires
# its next request when the previous answers. DriveWith gives one level, Curve several, Explain
# narrates the knee. Spawning processes was not run for this reference; the settings, AimAt,
# WaitReady against a closed port and Explain were.
#
#   receiver   o1 = new stzLoadDriver() o1.SetBusyMs(5) o1.SetRequestsPerDriver(10)
#              o1.AimAt("127.0.0.1", 1)
#   example    ? o1.Port()
#              #--> 1
#              ? @@( o1.CurveRows() )
#              #--> [ ]
#              ? o1.WaitReady(200)
#              #--> 0
#              ? o1.Explain()[1]
#              #--> Driven load -- target 127.0.0.1:1, D ~5ms CPU/request, 0 level(s).
#              ? o1.Destroy().Port()
#              #--> 1
#   see        stzReactor, stzAppServer, stzPerfSeries, stzSla
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

	# Builds a load driver with a reactor, the Ring executable found from the command line and the path of stzBase, and default settings.
	#
	#   returns    nothing; the object is built and no process is started
	#   note       the defaults are a target cost of 3 ms per request, 30 requests per driver, the
	#              path /work and a 120000 ms lifetime for the target; StzLoadDriver builds the same
	#              object
	#   see        SpawnTarget, AimAt, DriveWith
	def init()
		@oReactor = new stzReactor()
		@cRingExe = This._RingExecutable()
		@cBaseRing = This._DeriveStzBasePath()

	# Sets how many milliseconds of CPU the spawned target burns for each request, the service demand under study.
	#
	#   pnMs       the cost in milliseconds, 0 or more
	#   returns    the driver itself, so calls chain
	#   note       it takes effect when SpawnTarget starts the target
	#   see        SetRequestsPerDriver, SpawnTarget
	#@ aka  -- configuration --------------------------------------------
	def SetBusyMs(pnMs)
		if isNumber(pnMs) and pnMs >= 0
			@nBusyMs = pnMs
		ok
		return This

	# Sets how many requests each driver process fires one after another.
	#
	#   pnM        the number of requests, 1 or more
	#   returns    the driver itself, so calls chain
	#   see        SetBusyMs, DriveWith
	def SetRequestsPerDriver(pnM)
		if isNumber(pnM) and pnM >= 1
			@nPerDriver = pnM
		ok
		return This

	# Sets the path the drivers request.
	#
	#   pcPath     the path, such as /work
	#   returns    the driver itself, so calls chain
	#   note       the target the driver spawns serves /work and /health
	#   see        AimAt, DriveWith
	def SetPath(pcPath)
		@cPath = "" + pcPath
		return This

	# Sets how long the spawned target lives before it ends itself, so an orphan cannot outlive its use.
	#
	#   pnMs       the lifetime in milliseconds, 1000 or more
	#   returns    the driver itself, so calls chain
	#   see        SpawnTarget, Destroy
	def SetTtlMs(pnMs)
		if isNumber(pnMs) and pnMs >= 1000
			@nTtlMs = pnMs
		ok
		return This

	# Points the drivers at a server that is already running, instead of spawning one.
	#
	#   pcHost     the host name or address
	#   pnPort     the port
	#   returns    the driver itself, so calls chain
	#   note       after it Destroy has no process to kill
	#   see        SpawnTarget, DriveWith
	#@ aka  -- the target -----------------------------------------------
	def AimAt(pcHost, pnPort)
		@cHost = "" + pcHost
		@nPort = pnPort
		bSpawnedTarget = 0
		return This

	# Starts a child Ring process running a small stzAppServer whose /work handler burns CPU, and waits until it answers /health.
	#
	#   pnPort     the port to listen on, or 0 to pick one from the wall clock between 37000 and
	#              37899
	#   returns    TRUE when the child answered its readiness probe within 15 seconds, FALSE
	#              otherwise
	#   note       the target ends itself after the lifetime set by SetTtlMs
	#   warning    not run: it starts a child process, listens on a local port and writes a
	#              generated script to base/perf/.stzloadtarget_gen.ring
	#   see        WaitReady, Destroy
	#@ aka  Spawn the harness's own target child: a stzAppServer whose /work handler burns @nBusyMs of CPU per request (the service demand D under study). pnPort 0 picks one from the wall clock. Returns TRUE when the child answers its readiness probe.
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

	# Returns the port of the target.
	#
	#   returns    a number; 0 before SpawnTarget or AimAt
	#   see        AimAt, SpawnTarget
	def Port()
		return @nPort

	# Asks the target's /health until it answers 200, for up to a given time.
	#
	#   pnTimeoutMs   how long to keep asking, in milliseconds
	#   returns       TRUE as 1 when it answered in time, FALSE as 0 otherwise
	#   note          aimed at a local port where nothing listens it answered 0 after the timeout,
	#                 here 300 ms; the child needs a moment to load stzBase and bind, hence the
	#                 retries
	#   see           SpawnTarget, AimAt
	#@ aka  Probe GET /health until it answers 200 (the child needs a moment to load stzBase and bind).
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

	# Fires one load level, a number of driver processes at once, and measures the response time each client sees.
	#
	#   pnDrivers   how many driver processes to run at the same time
	#   returns     a hash list with the keys drivers, requests, x, rmeanms, rp50ms, rp95ms and
	#               wallms: the throughput in requests per second and the response times in
	#               milliseconds
	#   note        closed loop: each driver fires its next request when the previous answers, and
	#               the wait for the accept queue is counted, which a server-side timer cannot see;
	#               the row is also appended to CurveRows
	#   warning     a call with no target raises error stzLoadDriver: no target -- SpawnTarget() or
	#               AimAt() first; the real run was not run: it spawns one Ring process for each
	#               driver and writes a generated script to base/perf/.stzloaddriver_gen.ring
	#   see         Curve, AimAt
	#@ aka  -- driving --------------------------------------------------
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

	# Runs several load levels in turn and returns the response-time against throughput rows.
	#
	#   paLevels   the numbers of drivers to try, such as [ 1, 6 ]
	#   returns    a list of the rows DriveWith gives, one for each level
	#   note       the values are live measurements, so a guard should assert ranges and signs and
	#              not exact values
	#   warning    not run: each level spawns driver processes; it clears the rows kept so far
	#              before it starts
	#   see        DriveWith, CurveRows
	#@ aka  The R-vs-X curve: one row per concurrency level.
	def Curve(paLevels)
		@aCurve = []
		_nLen_ = ring_len(paLevels)
		for _i_ = 1 to _nLen_
			This.DriveWith(paLevels[_i_])
		next
		return @aCurve

	# Returns the rows gathered so far by DriveWith and Curve.
	#
	#   returns    a list of hash lists; [ ] before any level was driven
	#   see        Curve, Explain
	def CurveRows()
		return @aCurve

	# Returns the curve as lines of text: a header, one line per level, and a closing sentence about the knee when there are two levels or more.
	#
	#   returns    a list of text lines
	#   note       with no level driven it is the header alone; for levels of 1 and 6 drivers
	#              reading 100 and 160 requests per second and 10 and 37 ms it says 6x the drivers
	#              bought 1.6x the throughput at 3.7x the response time, checked by hand
	#   see        Show, CurveRows
	#@ aka  -- reading the knee -----------------------------------------
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

	# Prints the narrated curve to the console, one line per line.
	#
	#   returns    nothing
	#   note       it prints with the ? statement
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Kills the target child that SpawnTarget started.
	#
	#   returns    the driver itself, so calls chain
	#   note       it does nothing for a target the driver did not spawn, such as one given to AimAt
	#   see        SpawnTarget, AimAt
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
