/*
	stzSla -- expectations declared where the design lives (perf P4).

	An SLA is not a dashboard threshold added after the incident; it
	is part of the DESIGN, stated in the operational vocabulary
	(U/R/X/D) next to the code it judges, and checked by the same CI
	gate as every other rule in the library:

		oSla = new stzSla("restolean-api")
		oSla.Expect(:ResponseTimeP95).Under(200)      # ms
		oSla.Expect(:Availability).AtLeast(99.9)      # percent
		oSla.Expect(:CpuUtilization).Under(0.75)
		oSla.Expect(:MemoryGrowthPerHour).Under(10 * 1024 * 1024)

		aFindings = oSla.CheckAgainst(oMon)   # judge the MEASURED numbers

	Verdicts are findings in THE UNIFIED SHAPE the graph-rules plan
	settled -- [ :rule, :subject, :where, :severity, :message ] with
	:subject = "perf" -- so a perf budget joins stzRuleReport (the ONE
	CI gate over code / agents / security / workflow / orgcharts) with
	a plain Ingest(), and a p95 regression fails the build exactly the
	way a security violation does.

	Well-known subjects (resolved against the P3 instruments):
	  :ResponseTimeP50/:P95/:P99  window-exact percentiles of http.request.ms
	  :ResponseTimeMean           exact lifetime mean of http.request.ms
	  :Throughput                 measured rate of http.requests (X, req/s)
	  :ErrorRate                  http.errors / http.requests * 100
	  :Availability               100 - ErrorRate
	  :CpuUtilization             window mean of process.cpu.utilization (U)
	  :MemoryRss                  current process.memory.rss (bytes)
	  :MemoryGrowthPerHour        rss slope * 3600000 (bytes/hour -- the leak bound)
	  :SystemMemoryFree           current system.memory.free (bytes)

	Your own metrics join with the aspect named in the verb:
	  ExpectP95("shop.checkout.ms").Under(50)
	  ExpectMean("shop.checkout.ms").Under(20)
	  ExpectValue("queue.depth").AtMost(100)
	  ExpectRate("shop.orders").AtLeast(1)
	  ExpectStable("queue.depth")        # outlier judgment: |z| <= 3

	Closers: Under(n)/AtMost(n) pass when actual <= n; AtLeast(n)/
	Over(n) pass when actual >= n; AsWarning() softens the LAST closed
	expectation to advisory (warnings do not fail the gate -- the same
	convention as every rule set).

	Honesty: an expectation over a metric the monitor does not carry is
	an ERROR finding ("not measured"), never a silent pass -- an SLA
	that cannot see is broken, not satisfied.
*/

func StzSla(pcName)
	return new stzSla(pcName)

class stzSla from stzObject

	@cName = ""
	@aExpectations = []	# [ cRule, cKind, cMetric, cOp, nBound, cSeverity ]
	@bPending = 0
	@cPendKind = ""
	@cPendMetric = ""
	@cPendLabel = ""
	@aVerdicts = []		# last check: [ :rule, :ok, :actual, :bound, :message ]
	@nBreaches = 0

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	# -- Declaring ------------------------------------------------

	def Expect(pcSubject)
		This._MustNotBePending("Expect")
		_cS_ = StzLower(ring_trim("" + pcSubject))
		_aKnown_ = [ "responsetimep50", "responsetimep95", "responsetimep99",
			"responsetimemean", "throughput", "errorrate", "availability",
			"cpuutilization", "memoryrss", "memorygrowthperhour",
			"systemmemoryfree" ]
		if ring_find(_aKnown_, _cS_) = 0
			stzraise("stzSla: unknown subject ':" + _cS_ + "'. Known subjects: " +
				"ResponseTimeP50/P95/P99, ResponseTimeMean, Throughput, ErrorRate, " +
				"Availability, CpuUtilization, MemoryRss, MemoryGrowthPerHour, " +
				"SystemMemoryFree -- or name your own metric via ExpectP95/" +
				"ExpectMean/ExpectValue/ExpectRate/ExpectStable.")
		ok
		@bPending = 1
		@cPendKind = _cS_
		@cPendMetric = ""
		@cPendLabel = This._LabelOf(_cS_)
		return This

	def ExpectP95(pcMetric)
		return This._OpenCustom("p95", pcMetric)

	def ExpectMean(pcMetric)
		return This._OpenCustom("mean", pcMetric)

	def ExpectValue(pcMetric)
		return This._OpenCustom("value", pcMetric)

	def ExpectRate(pcMetric)
		return This._OpenCustom("rate", pcMetric)

	# Stability closes ITSELF: the judgment is "the newest sample is
	# no outlier against its own window" (|z| <= 3), so there is no
	# numeric bound to state.
	def ExpectStable(pcMetric)
		This._MustNotBePending("ExpectStable")
		_cM_ = "" + pcMetric
		@aExpectations + [ "stable-" + _cM_, "stable", _cM_, "stable", 3, "error" ]
		return This

	def Under(pnBound)
		return This._Close("under", pnBound)

		def AtMost(pnBound)
			return This._Close("under", pnBound)

	def AtLeast(pnBound)
		return This._Close("atleast", pnBound)

		def Over(pnBound)
			return This._Close("atleast", pnBound)

	# Soften the LAST closed expectation: it advises, it does not fail
	# the gate (stzRuleReport.IsSound ignores warnings by convention).
	def AsWarning()
		_n_ = ring_len(@aExpectations)
		if _n_ = 0
			stzraise("stzSla.AsWarning: no expectation closed yet.")
		ok
		@aExpectations[_n_][6] = "warning"
		return This

	def NumberOfExpectations()
		return ring_len(@aExpectations)

	# -- Judging --------------------------------------------------

	# Judge every expectation against the monitor's MEASURED numbers.
	# Returns the breaches as findings in the unified rule shape
	# ([ :rule, :subject, :where, :severity, :message ], subject
	# "perf") -- hand them to stzRuleReport.Ingest(). Full verdicts
	# (passes included, with actuals) stay readable via Verdicts().
	def CheckAgainst(poMonitor)
		@aVerdicts = []
		@nBreaches = 0
		_aFindings_ = []
		_nLen_ = ring_len(@aExpectations)
		for _i_ = 1 to _nLen_
			_aE_ = @aExpectations[_i_]
			_aR_ = This._Resolve(poMonitor, _aE_[2], _aE_[3])
			if NOT _aR_[1]
				# not measured: an ERROR, never a silent pass
				_cMsg_ = _aE_[1] + ": NOT MEASURED -- " + _aR_[3]
				@aVerdicts + [ :rule = _aE_[1], :ok = 0, :actual = 0,
					:bound = _aE_[5], :message = _cMsg_ ]
				_aFindings_ + [ :rule = _aE_[1], :subject = "perf",
					:where = @cName + "/" + This._WhereOf(_aE_),
					:severity = "error", :message = _cMsg_ ]
				@nBreaches++
				loop
			ok
			_nActual_ = _aR_[2]
			_bOk_ = This._Judge(_aE_[4], _nActual_, _aE_[5], _aR_)
			_cMsg_ = This._VerdictMessage(_aE_, _nActual_, _bOk_, _aR_)
			@aVerdicts + [ :rule = _aE_[1], :ok = _bOk_, :actual = _nActual_,
				:bound = _aE_[5], :message = _cMsg_ ]
			if NOT _bOk_
				_aFindings_ + [ :rule = _aE_[1], :subject = "perf",
					:where = @cName + "/" + This._WhereOf(_aE_),
					:severity = _aE_[6], :message = _cMsg_ ]
				@nBreaches++
			ok
		next
		return _aFindings_

	# The breaches of the LAST check, unified shape (re-derivable
	# without re-measuring).
	def Findings()
		_aOut_ = []
		_nLen_ = ring_len(@aVerdicts)
		for _i_ = 1 to _nLen_
			if NOT @aVerdicts[_i_][:ok]
				_cRule_ = @aVerdicts[_i_][:rule]
				_aE_ = This._ExpectationOf(_cRule_)
				_aOut_ + [ :rule = _cRule_, :subject = "perf",
					:where = @cName + "/" + This._WhereOf(_aE_),
					:severity = _aE_[6], :message = @aVerdicts[_i_][:message] ]
			ok
		next
		return _aOut_

	def Verdicts()
		return @aVerdicts

	def Passed()
		return @nBreaches = 0

	def BreachCount()
		return @nBreaches

	def Explain()
		_aLines_ = []
		_cV_ = "MET"
		if @nBreaches > 0
			_cV_ = "BREACHED (" + @nBreaches + ")"
		ok
		_aLines_ + ("SLA " + @cName + " -- " + ring_len(@aExpectations) +
			" expectation(s), last check: " + _cV_ + ".")
		_nLen_ = ring_len(@aVerdicts)
		for _i_ = 1 to _nLen_
			_cMark_ = "[MET] "
			if NOT @aVerdicts[_i_][:ok]
				_cMark_ = "[BREACH] "
			ok
			_aLines_ + ("  " + _cMark_ + @aVerdicts[_i_][:message])
		next
		return _aLines_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# -- Internals ------------------------------------------------

	def _MustNotBePending(pcVerb)
		if @bPending
			stzraise("stzSla." + pcVerb + ": the expectation on '" + @cPendLabel +
				"' is still open -- close it with Under()/AtMost()/AtLeast()/Over() first.")
		ok

	def _OpenCustom(pcAspect, pcMetric)
		This._MustNotBePending("Expect" + StzUpper(StzLeft(pcAspect,1)) + StzMidToEnd(pcAspect,2))
		@bPending = 1
		@cPendKind = pcAspect
		@cPendMetric = "" + pcMetric
		@cPendLabel = pcAspect + " of " + pcMetric
		return This

	def _Close(pcOp, pnBound)
		if NOT @bPending
			stzraise("stzSla: no open expectation to close -- say Expect(...) first.")
		ok
		_cRule_ = ""
		if @cPendMetric = ""
			_cRule_ = This._LabelOf(@cPendKind) + "-" + pcOp + "-" + pnBound
		else
			_cRule_ = @cPendKind + "-" + @cPendMetric + "-" + pcOp + "-" + pnBound
		ok
		@aExpectations + [ _cRule_, @cPendKind, @cPendMetric, pcOp, pnBound, "error" ]
		@bPending = 0
		@cPendKind = ""
		@cPendMetric = ""
		@cPendLabel = ""
		return This

	def _LabelOf(pcKind)
		if pcKind = "responsetimep50"      return "response-time-p50"
		but pcKind = "responsetimep95"     return "response-time-p95"
		but pcKind = "responsetimep99"     return "response-time-p99"
		but pcKind = "responsetimemean"    return "response-time-mean"
		but pcKind = "throughput"          return "throughput"
		but pcKind = "errorrate"           return "error-rate"
		but pcKind = "availability"        return "availability"
		but pcKind = "cpuutilization"      return "cpu-utilization"
		but pcKind = "memoryrss"           return "memory-rss"
		but pcKind = "memorygrowthperhour" return "memory-growth-per-hour"
		but pcKind = "systemmemoryfree"    return "system-memory-free"
		ok
		return pcKind

	def _WhereOf(paExp)
		if paExp[3] != ""
			return paExp[3]
		ok
		return This._MetricOfKind(paExp[2])

	def _MetricOfKind(pcKind)
		if pcKind = "throughput" or pcKind = "errorrate" or pcKind = "availability"
			return "http.requests"
		but pcKind = "cpuutilization"
			return "process.cpu.utilization"
		but pcKind = "memoryrss" or pcKind = "memorygrowthperhour"
			return "process.memory.rss"
		but pcKind = "systemmemoryfree"
			return "system.memory.free"
		ok
		return "http.request.ms"

	# Resolve one expectation's ACTUAL from the monitor.
	# Returns [ bMeasured, nActual, cWhyNot, nZ ] (nZ only for stable).
	def _Resolve(poMon, pcKind, pcMetric)
		if pcKind = "responsetimep50"
			return This._TimerPct(poMon, 50)
		but pcKind = "responsetimep95"
			return This._TimerPct(poMon, 95)
		but pcKind = "responsetimep99"
			return This._TimerPct(poMon, 99)
		but pcKind = "responsetimemean"
			if NOT poMon.HasMetric("http.request.ms")
				return [ 0, 0, "no http.request.ms -- is the server Observe()d?", 0 ]
			ok
			return [ 1, poMon.MetricQ("http.request.ms").MeanMs(), "", 0 ]
		but pcKind = "throughput"
			if NOT poMon.HasMetric("http.requests")
				return [ 0, 0, "no http.requests -- is the server Observe()d?", 0 ]
			ok
			return [ 1, poMon.MetricQ("http.requests").RatePerSecond(), "", 0 ]
		but pcKind = "errorrate"
			return This._ErrorRate(poMon)
		but pcKind = "availability"
			_aR_ = This._ErrorRate(poMon)
			if NOT _aR_[1]
				return _aR_
			ok
			return [ 1, 100 - _aR_[2], "", 0 ]
		but pcKind = "cpuutilization"
			if NOT poMon.HasMetric("process.cpu.utilization")
				return [ 0, 0, "no process.cpu.utilization -- WatchCpu() the monitor", 0 ]
			ok
			return [ 1, poMon.MetricQ("process.cpu.utilization").Mean(), "", 0 ]
		but pcKind = "memoryrss"
			if NOT poMon.HasMetric("process.memory.rss")
				return [ 0, 0, "no process.memory.rss -- WatchMemory() the monitor", 0 ]
			ok
			return [ 1, poMon.MetricQ("process.memory.rss").Value(), "", 0 ]
		but pcKind = "memorygrowthperhour"
			if NOT poMon.HasMetric("process.memory.rss")
				return [ 0, 0, "no process.memory.rss -- WatchMemory() the monitor", 0 ]
			ok
			return [ 1, poMon.MetricQ("process.memory.rss").SlopePerMs() * 3600000, "", 0 ]
		but pcKind = "systemmemoryfree"
			if NOT poMon.HasMetric("system.memory.free")
				return [ 0, 0, "no system.memory.free -- WatchSystemMemory() the monitor", 0 ]
			ok
			return [ 1, poMon.MetricQ("system.memory.free").Value(), "", 0 ]
		but pcKind = "stable"
			return This._Stability(poMon, pcMetric)
		ok
		# custom aspects over a named metric
		if NOT poMon.HasMetric(pcMetric)
			return [ 0, 0, "no metric '" + pcMetric + "' on this monitor", 0 ]
		ok
		if pcKind = "p95"
			return [ 1, poMon.MetricQ(pcMetric).Percentile(95), "", 0 ]
		but pcKind = "mean"
			return [ 1, poMon.MetricQ(pcMetric).Mean(), "", 0 ]
		but pcKind = "rate"
			return [ 1, poMon.MetricQ(pcMetric).RatePerSecond(), "", 0 ]
		ok
		return [ 1, poMon.MetricQ(pcMetric).Value(), "", 0 ]

	def _TimerPct(poMon, pnP)
		if NOT poMon.HasMetric("http.request.ms")
			return [ 0, 0, "no http.request.ms -- is the server Observe()d?", 0 ]
		ok
		return [ 1, poMon.MetricQ("http.request.ms").ExactPercentile(pnP), "", 0 ]

	def _ErrorRate(poMon)
		if NOT poMon.HasMetric("http.requests") or NOT poMon.HasMetric("http.errors")
			return [ 0, 0, "no http.requests/http.errors -- is the server Observe()d?", 0 ]
		ok
		_nReq_ = poMon.MetricQ("http.requests").Value()
		if _nReq_ = 0
			return [ 1, 0, "", 0 ]
		ok
		return [ 1, poMon.MetricQ("http.errors").Value() / _nReq_ * 100, "", 0 ]

	# The stability judgment: the NEWEST sample against the window
	# that came BEFORE it (leave-one-out). Including the newest in
	# its own baseline caps z below ~3 on small windows -- at n=10
	# the maximum possible z is exactly 3.0, so an included-sample
	# test could never fire. Against the prior window, z is unbounded
	# and means what it says. A flat baseline (std 0) is stable only
	# if the newest sample matches it. Judgment-time math over a
	# small window -- not a hot path.
	def _Stability(poMon, pcMetric)
		if NOT poMon.HasMetric(pcMetric)
			return [ 0, 0, "no metric '" + pcMetric + "' on this monitor", 0 ]
		ok
		_oS_ = poMon.MetricQ(pcMetric).SeriesQ()
		_aV_ = _oS_.Values()
		_nN_ = ring_len(_aV_)
		if _nN_ < 8
			# too little history to call anything an outlier -- pass, and say so
			return [ 1, 0, "window of " + _nN_ + " (< 8): stability not judgeable yet", 0 ]
		ok
		_nLast_ = _aV_[_nN_]
		_nBase_ = _nN_ - 1
		_nMean_ = 0
		for _i_ = 1 to _nBase_
			_nMean_ += _aV_[_i_]
		next
		_nMean_ = _nMean_ / _nBase_
		_nVar_ = 0
		for _i_ = 1 to _nBase_
			_nVar_ += (_aV_[_i_] - _nMean_) * (_aV_[_i_] - _nMean_)
		next
		_nStd_ = sqrt(_nVar_ / _nBase_)
		if _nStd_ = 0
			if _nLast_ = _nMean_
				return [ 1, 0, "", 0 ]
			ok
			# a jump off a perfectly flat line is infinitely surprising
			return [ 1, 999, "", 999 ]
		ok
		_nZ_ = (_nLast_ - _nMean_) / _nStd_
		if _nZ_ < 0
			_nZ_ = -_nZ_
		ok
		return [ 1, _nZ_, "", _nZ_ ]

	def _Judge(pcOp, pnActual, pnBound, paR)
		if pcOp = "under"
			return pnActual <= pnBound
		but pcOp = "atleast"
			return pnActual >= pnBound
		but pcOp = "stable"
			return pnActual <= pnBound   # actual = |z|, bound = 3
		ok
		return 0

	def _VerdictMessage(paExp, pnActual, pbOk, paR)
		_cOpWord_ = "<="
		if paExp[4] = "atleast"
			_cOpWord_ = ">="
		ok
		if paExp[4] = "stable"
			if ring_len(paR) >= 3 and paR[3] != ""
				return paExp[1] + ": " + paR[3]
			ok
			return paExp[1] + ": newest sample z = " + pnActual + " (|z| " + _cOpWord_ + " 3)"
		ok
		return paExp[1] + ": measured " + pnActual + " (must be " + _cOpWord_ + " " + paExp[5] + ")"

	def _ExpectationOf(pcRule)
		_nLen_ = ring_len(@aExpectations)
		for _i_ = 1 to _nLen_
			if @aExpectations[_i_][1] = pcRule
				return @aExpectations[_i_]
			ok
		next
		return [ pcRule, "", "", "", 0, "error" ]
