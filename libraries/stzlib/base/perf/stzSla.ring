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

# Holds the expectations a service must meet, stated in operational terms, and judges them against measured numbers.
#
# An SLA is part of the design and not a dashboard threshold added after an incident. Expect names a
# well-known subject, response time percentiles, throughput, error rate, availability, CPU, memory,
# and a closer, Under, AtMost, AtLeast or Over, gives the bound; ExpectP95, ExpectMean, ExpectValue,
# ExpectRate and ExpectStable do the same for a metric of your own. CheckAgainst judges them against
# a stzPerfMonitor and returns the breaches as findings in the unified shape, subject perf, ready
# for stzRuleReport. An expectation over a metric the monitor does not carry is an error finding,
# never a silent pass. AsWarning softens the last expectation to advice. Judged values that depend
# on the clock, rates and CPU, should be asserted by range.
#
#   receiver   oMon = StzPerfMonitor("api") oT = oMon.NewTimer("http.request.ms") oT.Record(20)
#              oT.Record(40) oT.Record(60) oT.Record(80) oT.Record(400) oReq =
#              oMon.NewCounter("http.requests") oReq.IncrementBy(200) oErr =
#              oMon.NewCounter("http.errors") oErr.IncrementBy(1) oDepth =
#              oMon.NewGauge("queue.depth") oDepth.Set(120) o1 = StzSla("restolean-api")
#              o1.Expect(:ResponseTimeP95).Under(200) o1.Expect(:ResponseTimeP50).AtMost(100)
#              o1.Expect(:Availability).AtLeast(99.9) o1.ExpectValue("queue.depth").AtMost(100)
#   example    ? o1.NumberOfExpectations()
#              #--> 4
#              aF = o1.CheckAgainst(oMon)
#              ? len(aF)
#              #--> 3
#              ? aF[1][:rule]
#              #--> response-time-p95-under-200
#              ? aF[1][:message]
#              #--> response-time-p95-under-200: measured 400 (must be <= 200)
#              ? o1.Verdicts()[2][:ok]
#              #--> 1
#              ? o1.Passed()
#              #--> 0
#              ? o1.BreachCount()
#              #--> 3
#   see        stzPerfMonitor, stzPerfSentinel, stzRuleReport
class stzSla from stzObject

	@cName = ""
	@aExpectations = []	# [ cRule, cKind, cMetric, cOp, nBound, cSeverity ]
	@bPending = 0
	@cPendKind = ""
	@cPendMetric = ""
	@cPendLabel = ""
	@aVerdicts = []		# last check: [ :rule, :ok, :actual, :bound, :message ]
	@nBreaches = 0

	# Builds an empty service-level agreement under a name, to which expectations are added.
	#
	#   pcName     the name of the SLA, written into every finding
	#   returns    nothing; the object is built
	#   note       StzSla builds the same object
	#   see        Expect, CheckAgainst
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the SLA was built with.
	#
	#   returns    the name as text
	#   see        Explain
	def Name()
		return @cName

	# Opens an expectation on one of the well-known measured subjects, to be closed with a bound.
	#
	#   pcSubject   ResponseTimeP50, ResponseTimeP95, ResponseTimeP99, ResponseTimeMean, Throughput,
	#               ErrorRate, Availability, CpuUtilization, MemoryRss, MemoryGrowthPerHour or
	#               SystemMemoryFree, in any letter case
	#   returns     the SLA itself, so the closer can follow
	#   note        the subjects are resolved against the monitor's metrics, such as http.request.ms
	#               for the response times and process.cpu.utilization for the CPU
	#   warning     a subject that is not in the list, such as Happiness, raises error stzSla:
	#               unknown subject ... with the list; opening a second expectation before closing
	#               the first raises error stzSla.Expect: the expectation on ... is still open --
	#               close it with Under()/AtMost()/AtLeast()/Over() first
	#   see         Under, AtLeast, ExpectP95
	#@ aka  -- Declaring ------------------------------------------------
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

	# Opens an expectation on the 95th percentile of a metric of your own, to be closed with a bound.
	#
	#   pcMetric   the name of a metric on the monitor, such as shop.checkout.ms
	#   returns    the SLA itself, so the closer can follow
	#   note       a metric the monitor does not carry gives an error finding saying NOT MEASURED,
	#              never a silent pass
	#   warning    an expectation still open raises error ... is still open
	#   see        ExpectMean, Under
	def ExpectP95(pcMetric)
		return This._OpenCustom("p95", pcMetric)

	# Opens an expectation on the mean of a metric of your own, to be closed with a bound.
	#
	#   pcMetric   the name of a metric on the monitor
	#   returns    the SLA itself, so the closer can follow
	#   note       an unmeasured metric is an error finding
	#   warning    an expectation still open raises error ... is still open
	#   see        ExpectP95, Under
	def ExpectMean(pcMetric)
		return This._OpenCustom("mean", pcMetric)

	# Opens an expectation on the current value of a metric of your own, to be closed with a bound.
	#
	#   pcMetric   the name of a counter or gauge on the monitor, such as queue.depth
	#   returns    the SLA itself, so the closer can follow
	#   note       an unmeasured metric is an error finding
	#   warning    an expectation still open raises error ... is still open
	#   see        ExpectRate, Under
	def ExpectValue(pcMetric)
		return This._OpenCustom("value", pcMetric)

	# Opens an expectation on the measured rate per second of a metric of your own, to be closed with a bound.
	#
	#   pcMetric   the name of a counter on the monitor, such as shop.orders
	#   returns    the SLA itself, so the closer can follow
	#   note       a rate is live: judge it by range, never by an exact number
	#   warning    an expectation still open raises error ... is still open
	#   see        ExpectValue, AtLeast
	def ExpectRate(pcMetric)
		return This._OpenCustom("rate", pcMetric)

	# Declares that a metric must have no outlier: its newest sample must lie within 3 standard deviations of the window before it.
	#
	#   pcMetric   the name of a metric on the monitor
	#   returns    the SLA itself; it closes itself and takes no bound
	#   note       with fewer than 8 samples it passes and says stability is not judgeable yet; a
	#              jump off a perfectly flat window is judged infinitely surprising; the rule is
	#              named stable- followed by the metric
	#   warning    an expectation still open raises error ... is still open
	#   see        ExpectValue, CheckAgainst
	#@ aka  Stability closes ITSELF: the judgment is "the newest sample is no outlier against its own window" (|z| <= 3), so there is no numeric bound to state.
	def ExpectStable(pcMetric)
		This._MustNotBePending("ExpectStable")
		_cM_ = "" + pcMetric
		@aExpectations + [ "stable-" + _cM_, "stable", _cM_, "stable", 3, "error" ]
		return This

	# Closes the open expectation: it passes when the measured value is at most the bound.
	#
	#   pnBound    the largest value that passes, in the unit of the subject: milliseconds for
	#              response times, a fraction for CPU, bytes for memory
	#   returns    the SLA itself, so calls chain
	#   note       the rule is named from the subject, the closer and the bound, such as response-
	#              time-p95-under-200; AtMost is the same call
	#   warning    closing when nothing is open raises error stzSla: no open expectation to close --
	#              say Expect(...) first
	#   see        AtMost, AtLeast, AsWarning
	def Under(pnBound)
		return This._Close("under", pnBound)

		# Closes the open expectation: it passes when the measured value is at most the bound.
		#
		#   pnBound    the largest value that passes
		#   returns    the SLA itself, so calls chain
		#   note       the same call as Under
		#   warning    closing when nothing is open raises error stzSla: no open expectation to
		#              close
		#   see        Under, AtLeast
		def AtMost(pnBound)
			return This._Close("under", pnBound)

	# Closes the open expectation: it passes when the measured value is at least the bound.
	#
	#   pnBound    the smallest value that passes, such as 99.9 for an availability in percent
	#   returns    the SLA itself, so calls chain
	#   note       the rule name carries atleast; Over is the same call
	#   warning    closing when nothing is open raises error stzSla: no open expectation to close
	#   see        Over, Under, AsWarning
	def AtLeast(pnBound)
		return This._Close("atleast", pnBound)

		# Closes the open expectation: it passes when the measured value is at least the bound.
		#
		#   pnBound    the smallest value that passes
		#   returns    the SLA itself, so calls chain
		#   note       the same call as AtLeast, so the bound itself passes
		#   warning    closing when nothing is open raises error stzSla: no open expectation to
		#              close
		#   see        AtLeast, Under
		def Over(pnBound)
			return This._Close("atleast", pnBound)

	# Softens the last closed expectation to an advisory one, which does not fail the gate.
	#
	#   returns    the SLA itself, so calls chain
	#   note       its findings carry the severity warning, which stzRuleReport.IsSound ignores;
	#              Passed and BreachCount still count them
	#   warning    calling it before any expectation is closed raises error stzSla.AsWarning: no
	#              expectation closed yet
	#   see        Under, CheckAgainst
	#@ aka  Soften the LAST closed expectation: it advises, it does not fail the gate (stzRuleReport.IsSound ignores warnings by convention).
	def AsWarning()
		_n_ = ring_len(@aExpectations)
		if _n_ = 0
			stzraise("stzSla.AsWarning: no expectation closed yet.")
		ok
		@aExpectations[_n_][6] = "warning"
		return This

	# Returns how many expectations have been closed.
	#
	#   returns    a number; an expectation still open is not counted
	#   see        Expect, CheckAgainst
	def NumberOfExpectations()
		return ring_len(@aExpectations)

	# Judges every expectation against the monitor's measured numbers and returns the breaches.
	#
	#   poMonitor   the stzPerfMonitor whose metrics are read
	#   returns     a list of findings in the unified shape, each a hash list with rule, subject
	#               perf, where, severity and message; [ ] when everything is met
	#   note        the finding is ready for stzRuleReport.Ingest; where reads the SLA name, a
	#               slash, and the metric; a call replaces the verdicts of the call before
	#   warning     an expectation over a metric the monitor does not carry is an error finding
	#               whose message says NOT MEASURED and what to watch, never a pass
	#   see         Verdicts, Findings, Explain
	#@ aka  -- Judging --------------------------------------------------
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

	# Returns the breaches of the last check again, in the unified shape, without measuring anything.
	#
	#   returns    a list of findings; [ ] before any check or when all were met
	#   see        CheckAgainst, Verdicts
	#@ aka  The breaches of the LAST check, unified shape (re-derivable without re-measuring).
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

	# Returns the verdict of every expectation from the last check, the passes too.
	#
	#   returns    a list of hash lists with the keys rule, ok, actual, bound and message
	#   note       an unmeasured expectation has ok 0 and actual 0
	#   see        Findings, Passed
	def Verdicts()
		return @aVerdicts

	# TRUE if the last check found no breach, of any severity.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 1 before any check
	#   note       an advisory breach makes it 0 though the gate stays sound: with only a warning it
	#              answered 0 while stzRuleReport.IsSound answered 1
	#   see        BreachCount, Findings
	def Passed()
		return @nBreaches = 0

	# Returns how many expectations breached in the last check.
	#
	#   returns    a number, the advisory ones and the not-measured ones included
	#   see        Passed, Findings
	def BreachCount()
		return @nBreaches

	# Returns the last check as lines of text: a verdict line, then each expectation marked MET or BREACH with its message.
	#
	#   returns    a list of text lines
	#   note       the first line gives the number of expectations and MET or BREACHED with the
	#              count
	#   see        Show, Verdicts
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

	# Prints the explanation to the console, one line per line.
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
