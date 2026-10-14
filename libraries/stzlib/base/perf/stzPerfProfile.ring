/*
	stzPerfProfile -- the analyst (perf P5).

	The instruments measure; the profile UNDERSTANDS. It reads a
	monitor's engine-backed numbers and answers the questions of
	operational analysis -- the U/R/X/D vocabulary the whole system
	is built on:

	  U  Utilization    fraction of the machine's CPU this process
	                     used over the interval
	  R  Response time  the request timer's mean and percentiles
	  X  Throughput     requests completed per second, measured
	  D  Service demand THE diagnostic number: CPU-ms each request
	                     actually consumed (D = deltaCPU / deltaReq)

	and the laws that bind them:

	  Utilization law  U = X * D / cores. Computed from one set of
	     anchors this is an algebraic identity -- so the profile's
	     UtilizationCheck() compares its anchor-computed U against
	     the monitor's independently SAMPLED utilization gauge: two
	     measurements, one truth, and a disagreement means the
	     MEASUREMENT is broken, not the machine.
	  Little's law     N = X * R: the average number of requests in
	     flight implied by throughput and response time.
	     LittleCheckAgainst(nMeasured) compares it with a concurrency
	     you measured elsewhere (a worker pool's InFlight()).

	  Bottleneck()     splits each request's R into CPU-ms computed
	     (D) and ms waited (R - D): a slow app is either COMPUTING
	     or WAITING, and the split names which -- the first question
	     of every performance investigation, answered with a number.
	  MaxThroughput()  cores * 1000 / D -- where this machine
	     saturates if CPU is the constraint; Headroom() = 1 - X/Xmax.

	The profile is INTERVAL-based: it anchors (CPU time, request
	count, monotonic clock) at birth, and every answer covers the
	stretch since; Mark() re-anchors to start a fresh interval.
	R percentiles answer over the timer's retained window and U
	sampling over the gauge's -- Explain() states its windows.

		oP = StzPerfProfile(oMon)     # anchors here
		# ... serve load ...
		? oP.ServiceDemandMs()        # CPU-ms per request
		? oP.Bottleneck()             # :Cpu or :Waiting, with the split
		? oP.Explain()                # the narrated analysis

	Snapshot()/Curve() record (X, R) points across load levels you
	drive -- the R-vs-X curve that shows where response time turns.

	Ring-state honesty: the anchors live Ring-side -- one face drives
	Mark()/Snapshot(); the metrics it reads are engine-shared.

	Windows quantization caveat: GetProcessTimes accounts CPU in
	15.625ms quanta, so CpuMsUsed()/D over a SHORT interval with few
	requests is quantized (a reading of 15.63ms may represent
	anything under one quantum). Profile over intervals long enough
	to span many quanta -- dozens of requests, hundreds of ms -- and
	the averages are honest. (Discovered attributing a "7ms/request"
	figure that was one quantum + a cold start; the steady-state
	truth was under 1.6ms.)
*/

func StzPerfProfile(poMonitor)
	return new stzPerfProfile(poMonitor)

# Turns a monitor's measured numbers into operational analysis: throughput, utilization, service demand and response time over an interval.
#
# The instruments measure and the profile understands. It speaks the vocabulary of operational
# analysis: U utilization, R response time, X throughput and D, the CPU milliseconds each request
# consumed. It applies the laws that bind them (the utilization law and Little's law, each checked
# against a second, independent measurement), splits a request's time into computing and waiting,
# and forecasts memory growth. A profile is interval-based: it anchors at birth and every answer
# covers the time since; Mark starts a fresh interval. Assert ranges and signs on live readings,
# never exact values, and profile over many requests, because Windows accounts CPU in 15.625 ms
# ticks.
#
#   receiver   o1 = new stzPerfProfile(StzPerfMonitor("api"))
#   example    ? o1.Requests()
#              #--> 0
#              ? o1.ServiceDemandMs()
#              #--> 0
#              ? o1.Bottleneck()[:kind]
#              #--> cpu
#              ? o1.UtilizationCheck()[:sampled]
#              #--> -1
#              ? o1.HoursToMemoryCeiling(1000)
#              #--> -1
#   see        StzPerfProfile, stzPerfSeries, stzStopwatch
class stzPerfProfile from stzObject

	@oMon = ""
	@nAnchorCpuNs = 0
	@nAnchorReq = 0
	@nAnchorMs = 0
	@nAnchorRSum = 0
	@nAnchorRCount = 0
	@bHasRequests = 0
	@bHasTimer = 0
	@aSnapshots = []	# [ [ atMs, X, U, D, Rp95 ], ... ] (newest 128)

	# Builds a profile of a performance monitor and anchors it there, so every answer covers the time since.
	#
	#   poMonitor   the stzPerfMonitor whose request timer and CPU numbers are analysed
	#   returns     nothing; the object is built
	#   see         StzPerfProfile, Mark
	def init(poMonitor)
		@oMon = poMonitor
		This.Mark()

	# Moves the anchor to now, so the next answers cover a fresh interval and forget the earlier one.
	#
	#   returns    the profile itself, so calls chain
	#   see        IntervalMs, Snapshot
	#@ aka  Re-anchor: the next answers cover a fresh interval from NOW. The timer's exact lifetime sum/count are anchored too, so the interval's mean R and the interval's D describe THE SAME requests -- mixing a lifetime R with an interval D would make the computing/waiting split compare different populations.
	def Mark()
		@nAnchorCpuNs = StzEnginePerfCpuNs()
		@nAnchorMs = StzEngineWatchTimestampMs()
		@bHasRequests = @oMon.HasMetric("http.requests")
		@nAnchorReq = 0
		if @bHasRequests
			@nAnchorReq = @oMon.MetricQ("http.requests").Value()
		ok
		@bHasTimer = @oMon.HasMetric("http.request.ms")
		@nAnchorRSum = 0
		@nAnchorRCount = 0
		if @bHasTimer
			@nAnchorRSum = @oMon.MetricQ("http.request.ms").SumMs()
			@nAnchorRCount = @oMon.MetricQ("http.request.ms").Count()
		ok
		return This

	# Returns the monitor this profile reads.
	#
	#   returns    the stzPerfMonitor given at birth
	#   see        init
	def MonitorQ()
		return @oMon

	# Returns how many milliseconds have passed since the anchor, on the monotonic clock.
	#
	#   returns    a number
	#   see        Mark, Throughput
	#@ aka  -- The interval facts ---------------------------------------
	def IntervalMs()
		return StzEngineWatchTimestampMs() - @nAnchorMs

	# Returns how many requests the monitor counted since the anchor.
	#
	#   returns    a number; 0 when the monitor has no http.requests counter
	#   see        Throughput, ServiceDemandMs
	#@ aka  Requests completed since the anchor.
	def Requests()
		if NOT @bHasRequests
			return 0
		ok
		return @oMon.MetricQ("http.requests").Value() - @nAnchorReq

	# Returns X, the requests completed per second over the interval.
	#
	#   returns    a number; 0 when no time has passed
	#   see        Requests, MaxThroughput, LittleN
	#@ aka  X -- requests per second over the interval.
	def Throughput()
		_nMs_ = This.IntervalMs()
		if _nMs_ <= 0
			return 0
		ok
		return This.Requests() / _nMs_ * 1000

	# Returns the CPU time the whole process consumed since the anchor, in milliseconds, all threads together.
	#
	#   returns    a number
	#   note       Windows counts CPU in 15.625 ms ticks, so a short interval reads 0 or one tick:
	#              average over many ticks
	#   see        Utilization, ServiceDemandMs
	#@ aka  CPU actually consumed over the interval, in ms (all threads).
	def CpuMsUsed()
		return (StzEnginePerfCpuNs() - @nAnchorCpuNs) / 1000000

	# Returns U, the fraction of the whole machine's CPU this process used over the interval.
	#
	#   returns    a number from 0 to 1; 0 when no time has passed
	#   see        CpuMsUsed, UtilizationCheck
	#@ aka  U -- the fraction of the MACHINE this process used.
	def Utilization()
		_nMs_ = This.IntervalMs()
		if _nMs_ <= 0
			return 0
		ok
		return This.CpuMsUsed() / (_nMs_ * StzEngineSystemCpuCount())

	# Returns D, the CPU milliseconds each request consumed, the profile's most diagnostic number.
	#
	#   returns    a number; 0 when no request completed
	#   note       D counts the whole process, so a quiet interval with few requests is quantized by
	#              the CPU tick
	#   see        Requests, MaxThroughput, Bottleneck
	#@ aka  D -- the diagnostic number: CPU-ms each request consumed. 0 when no requests crossed the interval (nothing to attribute).
	def ServiceDemandMs()
		_nReq_ = This.Requests()
		if _nReq_ = 0
			return 0
		ok
		return This.CpuMsUsed() / _nReq_

	# Returns the requests per second at which this machine saturates if the CPU is the constraint.
	#
	#   returns    a number; 0 when D is 0
	#   see        ServiceDemandMs, Headroom, LoadRatio
	#@ aka  Where this machine saturates IF CPU is the constraint (req/s).
	def MaxThroughput()
		_nD_ = This.ServiceDemandMs()
		if _nD_ <= 0
			return 0
		ok
		return StzEngineSystemCpuCount() * 1000 / _nD_

	# Returns how close the workload is to its CPU ceiling, throughput over maximum throughput, capped at 1.
	#
	#   returns    a number from 0 to 1; 0 when nothing is measurable yet
	#   see        MaxThroughput, Headroom
	#@ aka  The demand signal for elastic scaling (perf P6): how close this workload is to its CPU ceiling, X/Xmax in 0..1. This is what stzClusterSupervisor.ReportLoad() always wanted -- MEASURED, not hand-fed: FeedLoadFrom(tag, oProfile) closes the loop. 0 when nothing is measurable yet (no requests / no demand). (Named LoadRatio: `load` is a Ring keyword.)
	def LoadRatio()
		_nMax_ = This.MaxThroughput()
		if _nMax_ <= 0
			return 0
		ok
		_nL_ = This.Throughput() / _nMax_
		if _nL_ > 1
			_nL_ = 1
		ok
		return _nL_

	# Returns how much of the CPU ceiling remains, 1 minus throughput over maximum throughput.
	#
	#   returns    a number from 0 to 1; 0 when nothing is measurable yet
	#   see        LoadRatio, MaxThroughput
	#@ aka  1 - X/Xmax: how much of the CPU ceiling remains (0..1).
	def Headroom()
		_nMax_ = This.MaxThroughput()
		if _nMax_ <= 0
			return 0
		ok
		_nH_ = 1 - This.Throughput() / _nMax_
		if _nH_ < 0
			_nH_ = 0
		ok
		return _nH_

	# Compares the utilization computed from the anchors with the monitor's independently sampled CPU gauge.
	#
	#   returns    a hashlist with the keys computed, sampled, consistent and message; sampled is -1
	#              and consistent 0 when the monitor does not watch the CPU
	#   note       the two agree when within a factor of 3; a disagreement means the measurement is
	#              broken, not the machine
	#   see        Utilization, LittleCheckAgainst
	#@ aka  -- The self-checks ------------------------------------------
	def UtilizationCheck()
		_nC_ = This.Utilization()
		_nS_ = -1
		if @oMon.HasMetric("process.cpu.utilization")
			if @oMon.MetricQ("process.cpu.utilization").Count() > 0
				_nS_ = @oMon.MetricQ("process.cpu.utilization").Mean()
			ok
		ok
		if _nS_ < 0
			return [ :computed = _nC_, :sampled = -1, :consistent = 0,
				:message = "no sampled utilization to check against (WatchCpu + sampling needed)" ]
		ok
		_bOk_ = This._SameScale(_nC_, _nS_)
		_cV_ = "the two measurements agree -- the measurement is sound"
		if NOT _bOk_
			_cV_ = "computed and sampled utilization DISAGREE -- distrust the measurement"
		ok
		return [ :computed = _nC_, :sampled = _nS_, :consistent = _bOk_,
			:message = "U computed from anchors = " + _nC_ + ", U sampled by the monitor = " + _nS_ + ": " + _cV_ ]

	# Returns N, the average requests in flight that Little's law implies from throughput and mean response time.
	#
	#   returns    a number
	#   see        LittleCheckAgainst, Throughput, ResponseTimeMeanMs
	#@ aka  N -- the average requests in flight IMPLIED by Little's law (X * mean R). What you should see if you counted concurrency.
	def LittleN()
		return This.Throughput() * This.ResponseTimeMeanMs() / 1000

	# Compares the implied requests in flight with a concurrency you measured elsewhere, for example a worker pool's.
	#
	#   pnMeasured   the concurrency you counted, as a number
	#   returns      a hashlist with the keys implied, measured, consistent and message
	#   note         consistent means within a factor of 3, with both sides floored at 0.05 so tiny
	#                numbers agree
	#   see          LittleN, UtilizationCheck
	#@ aka  Compare the implied N with a concurrency you MEASURED elsewhere (e.g. a worker pool's InFlight()). Same-scale consistency: within a factor of 3 (floored at 0.05 -- tiny numbers agree).
	def LittleCheckAgainst(pnMeasured)
		_nImp_ = This.LittleN()
		_bOk_ = This._SameScale(_nImp_, pnMeasured)
		_cV_ = "consistent -- the measurement holds together"
		if NOT _bOk_
			_cV_ = "INCONSISTENT -- something is measuring wrong"
		ok
		return [ :implied = _nImp_, :measured = pnMeasured, :consistent = _bOk_,
			:message = "Little's law implies N = X*R = " + _nImp_ + " in flight; you measured " + pnMeasured + ": " + _cV_ ]

	# Returns R, the mean response time in milliseconds of the requests completed since the anchor.
	#
	#   returns    a number; 0 when none completed or the monitor has no http.request.ms timer
	#   see        ResponseTimeP95, WaitMsPerRequest
	#@ aka  -- R, and the computing/waiting split -----------------------
	def ResponseTimeMeanMs()
		if NOT @bHasTimer
			return 0
		ok
		_nC_ = @oMon.MetricQ("http.request.ms").Count() - @nAnchorRCount
		if _nC_ = 0
			return 0
		ok
		return (@oMon.MetricQ("http.request.ms").SumMs() - @nAnchorRSum) / _nC_

	# Returns the median response time in milliseconds, over the timer's retained window.
	#
	#   returns    a number; 0 when the monitor has no http.request.ms timer
	#   note       a window percentile, not an interval one: it can include requests from before the
	#              anchor
	#   see        ResponseTimeMeanMs, ResponseTimeP95
	def ResponseTimeP50()
		return This._Pct(50)

	# Returns the response time in milliseconds under which 95 percent of requests fall, over the timer's window.
	#
	#   returns    a number; 0 when the monitor has no http.request.ms timer
	#   see        ResponseTimeP50, ResponseTimeP99
	def ResponseTimeP95()
		return This._Pct(95)

	# Returns the response time in milliseconds under which 99 percent of requests fall, over the timer's window.
	#
	#   returns    a number; 0 when the monitor has no http.request.ms timer
	#   see        ResponseTimeP95, ResponseTimeP50
	def ResponseTimeP99()
		return This._Pct(99)

	# Returns the part of each request's mean response time that was not computation: waiting on IO, locks or queues.
	#
	#   returns    a number of milliseconds, never below 0
	#   see        Bottleneck, ResponseTimeMeanMs, ServiceDemandMs
	#@ aka  Of each request's R, the part that was NOT computation: waiting on IO, locks, sleeps, the queue. R - D, floored at 0.
	def WaitMsPerRequest()
		_nW_ = This.ResponseTimeMeanMs() - This.ServiceDemandMs()
		if _nW_ < 0
			_nW_ = 0
		ok
		return _nW_

	# Answers whether the app is busy or blocked, by splitting each request's time into CPU computed and time waited.
	#
	#   returns    a hashlist with the keys kind (cpu or waiting, whichever share is larger),
	#              cpuMsPerRequest, waitMsPerRequest and maxThroughput
	#   note       with no requests it answers cpu and zeros
	#   see        WaitMsPerRequest, ServiceDemandMs
	#@ aka  The first question of every investigation -- busy or blocked? -- answered with the split: a request's time goes to CPU (D) or to waiting (R - D); the larger share names the constraint.
	def Bottleneck()
		_nD_ = This.ServiceDemandMs()
		_nW_ = This.WaitMsPerRequest()
		_cKind_ = "cpu"
		if _nW_ > _nD_
			_cKind_ = "waiting"
		ok
		return [ :kind = _cKind_, :cpuMsPerRequest = _nD_,
			:waitMsPerRequest = _nW_, :maxThroughput = This.MaxThroughput() ]

	# Returns the bytes per hour by which the monitor's resident memory gauge is trending, positive when growing.
	#
	#   returns    a number; 0 when the monitor does not watch memory
	#   see        HoursToMemoryCeiling, Explain
	#@ aka  -- Memory: trend and forecast -------------------------------
	def MemoryTrendPerHour()
		if NOT @oMon.HasMetric("process.memory.rss")
			return 0
		ok
		return @oMon.MetricQ("process.memory.rss").SeriesQ().SlopePerMs() * 3600000

	# Returns the hours until resident memory reaches a ceiling at the current trend.
	#
	#   pnCeilingBytes   the memory ceiling, in bytes
	#   returns          a number of hours; 0 when memory is already at or past the ceiling, -1 when
	#                    it is not growing or is not watched
	#   see              MemoryTrendPerHour
	#@ aka  At the current trend, hours until rss reaches pnCeilingBytes. 0 = already at/past the ceiling; -1 = not growing (never, at this trend).
	def HoursToMemoryCeiling(pnCeilingBytes)
		if NOT @oMon.HasMetric("process.memory.rss")
			return -1
		ok
		_nNow_ = @oMon.MetricQ("process.memory.rss").Value()
		if _nNow_ >= pnCeilingBytes
			return 0
		ok
		_nPerHour_ = This.MemoryTrendPerHour()
		if _nPerHour_ <= 0
			return -1
		ok
		return (pnCeilingBytes - _nNow_) / _nPerHour_

	# Records one point of the response-time-versus-throughput curve for the current interval and returns it.
	#
	#   returns    a list [ atMs, X, U, D, Rp95 ]
	#   note       only the newest 128 points are kept
	#   see        Curve, Mark
	#@ aka  -- The R-vs-X curve -----------------------------------------
	def Snapshot()
		_aRow_ = [ StzEngineWatchTimestampMs(), This.Throughput(),
			This.Utilization(), This.ServiceDemandMs(), This.ResponseTimeP95() ]
		@aSnapshots + _aRow_
		if ring_len(@aSnapshots) > 128
			del(@aSnapshots, 1)
		ok
		return _aRow_

	# Returns the points recorded by Snapshot, in recording order.
	#
	#   returns    a list of [ atMs, X, U, D, Rp95 ] rows
	#   see        Snapshot
	#@ aka  [ [ atMs, X, U, D, Rp95 ], ... ] in recording order.
	def Curve()
		return @aSnapshots

	# Returns a narration of the interval in lines: work done, CPU, service demand, response time, Little's law and the constraint.
	#
	#   returns    a list of text lines
	#   note       a monitor with no request instruments gets only the CPU line
	#   see        Show, Bottleneck
	#@ aka  -- The narrated analysis ------------------------------------
	def Explain()
		_aL_ = []
		_nCores_ = StzEngineSystemCpuCount()
		_nMs_ = This.IntervalMs()
		_aL_ + ("Profile of monitor '" + @oMon.Name() + "' over the last " + (_nMs_/1000) + " s (" + _nCores_ + " cores).")
		if NOT @bHasRequests
			_aL_ + ("No request instruments on this monitor -- Observe() a server with it and the analysis widens to R, X, D and the laws.")
			_aL_ + ("CPU: " + This.CpuMsUsed() + " ms consumed: U = " + This.Utilization() + ".")
			This._ExplainMemory(_aL_)
			return _aL_
		ok
		_nReq_ = This.Requests()
		if _nReq_ = 0
			_aL_ + ("No requests completed in this interval -- nothing to attribute. CPU used: " + This.CpuMsUsed() + " ms (U = " + This.Utilization() + ").")
			This._ExplainMemory(_aL_)
			return _aL_
		ok
		_nX_ = This.Throughput()
		_nU_ = This.Utilization()
		_nD_ = This.ServiceDemandMs()
		_aL_ + ("Work: " + _nReq_ + " request(s) completed: X = " + _nX_ + " req/s.")
		_aL_ + ("CPU: " + This.CpuMsUsed() + " ms consumed: U = " + _nU_ + " of the machine.")
		_aL_ + ("Each request therefore demanded D = " + _nD_ + " ms of CPU -- the service demand, the most diagnostic number here.")
		if _nD_ > 0
			_aL_ + ("At that demand this machine saturates near Xmax = " + _nCores_ + " x 1000/D = " + This.MaxThroughput() + " req/s -- headroom " + (This.Headroom()*100) + "%.")
		ok
		_nR_ = This.ResponseTimeMeanMs()
		_aL_ + ("Response time R: mean " + _nR_ + " ms; p50/p95/p99 = " + This.ResponseTimeP50() + " / " + This.ResponseTimeP95() + " / " + This.ResponseTimeP99() + " ms (timer window).")
		_aL_ + ("Little's law: N = X*R = " + This.LittleN() + " request(s) in flight on average.")
		_aB_ = This.Bottleneck()
		if _aB_[:kind] = "cpu"
			if _nD_ > _nR_ and _nR_ > 0
				# D counts the whole PROCESS's CPU; when it exceeds each
				# request's wall time, threads (or co-resident work in
				# this process) computed alongside the requests.
				_aL_ + ("The process computed " + _nD_ + " CPU-ms per request -- MORE than each request's " + _nR_ + " ms of wall time: concurrent threads or co-resident work computed alongside (D is per-PROCESS). Either way the constraint is CPU -- faster code or more cores move this app.")
			else
				_aL_ + ("Of each request's " + _nR_ + " ms, " + _aB_[:cpuMsPerRequest] + " ms COMPUTED and " + _aB_[:waitMsPerRequest] + " ms waited: the constraint is CPU -- faster code or more cores move this app.")
			ok
		else
			_aL_ + ("Of each request's " + _nR_ + " ms, only " + _aB_[:cpuMsPerRequest] + " ms COMPUTED; " + _aB_[:waitMsPerRequest] + " ms WAITED -- the app is blocked, not busy: look at IO, locks and queues, not the CPU.")
		ok
		This._ExplainMemory(_aL_)
		return _aL_

	# Prints the narration of the interval, one line per row.
	#
	#   returns    nothing; it prints
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# -- Internals ------------------------------------------------

	def _Pct(pnP)
		if NOT @oMon.HasMetric("http.request.ms")
			return 0
		ok
		return @oMon.MetricQ("http.request.ms").ExactPercentile(pnP)

	def _ExplainMemory(paLines)
		if NOT @oMon.HasMetric("process.memory.rss")
			return
		ok
		if @oMon.MetricQ("process.memory.rss").Count() < 2
			return
		ok
		_nPerHour_ = This.MemoryTrendPerHour()
		_nMB_ = _nPerHour_ / (1024*1024)
		if _nPerHour_ <= 0
			paLines + ("Memory: rss stable or shrinking (" + _nMB_ + " MB/hour).")
		else
			paLines + ("Memory: rss trending +" + _nMB_ + " MB/hour -- watched growth; set a :MemoryGrowthPerHour budget (P4) to be paged before it matters.")
		ok

	# Same-scale consistency: within a factor of 3, values floored at
	# 0.05 so near-zero pairs agree instead of dividing by nothing.
	def _SameScale(pnA, pnB)
		_nA_ = pnA
		_nB_ = pnB
		if _nA_ < 0.05
			_nA_ = 0.05
		ok
		if _nB_ < 0.05
			_nB_ = 0.05
		ok
		_nHi_ = _nA_
		_nLo_ = _nB_
		if _nB_ > _nA_
			_nHi_ = _nB_
			_nLo_ = _nA_
		ok
		return _nHi_ / _nLo_ <= 3
