/*
	stzMetric -- one named stream of measurements (perf P2).

	Three kinds, declared at birth, each answering the questions its
	kind makes meaningful:

	  :Counter -- a monotonic count of events (requests served, rows
	              written). Increment()/IncrementBy(n); Value();
	              RatePerSecond() -- the throughput X of the U/R/X/D
	              vocabulary, read from the counter's own timeline.

	  :Gauge   -- a sampled level (memory, queue depth, temperature).
	              Set(v)/Record(v); Value(); Mean/Min/Max;
	              SlopePerMs() -- the trend/leak detector;
	              Percentile(p) exact over the retained window.

	  :Timer   -- durations (ms). Record(nMs) or RecordWatch(oStopwatch);
	              P50/P95/P99 streaming (bucketed histogram, O(1) for
	              unbounded streams) AND ExactPercentile(p) over the
	              recent window; Count(); SumMs(); MeanMs() exact.

	THE DESIGN RULE THAT MAKES IT SOFTANZA-PROOF: all mutable state
	lives in the ENGINE (a stzPerfSeries ring + for timers a latency
	histogram). Ring copies objects on assignment -- a Ring-side
	total would silently fork in the copy. Here a copied metric is a
	second face on the SAME engine truth: record through either,
	read through either, the numbers agree.

		m = StzMetric("app.requests", :Counter)
		m.Increment()
		? m.Value()

	Interop (industry formats, design doc section 12):
	  PromText()  -- Prometheus exposition lines (# HELP/# TYPE + samples;
	                 counters gain the _total suffix, timers export as a
	                 summary with quantiles + _sum + _count)
	  OtelMetricJson() -- one OTLP metric fragment (gauge / monotonic
	                 sum / summary); stzPerfMonitor batches fragments
	                 into the resourceMetrics envelope.

	Engine handles must be freed: Destroy() when done.
*/

func StzMetric(pcName, pcKind)
	return new stzMetric(pcName, pcKind)

class stzMetric from stzObject

	@cName = ""
	@cKind = ""		# :counter / :gauge / :timer (folded lowercase)
	@cHelp = ""
	@nWindow = 1024
	@oSeries = NULL
	@oHist = NULL		# timers only

	def init(pcName, pcKind)
		if isString(pcName)
			@cName = pcName
		ok
		_cK_ = StzLower("" + pcKind)
		if _cK_ != "counter" and _cK_ != "gauge" and _cK_ != "timer"
			stzraise("stzMetric: kind must be :Counter, :Gauge or :Timer (got '" + _cK_ + "').")
		ok
		@cKind = _cK_
		This._Ensure()

	# EAGER handle materialization -- the rule the copy-proof design
	# stands on. Ring copies objects on assignment; an engine handle
	# created LAZILY (after the copy) is created per-face, silently
	# forking the metric. Created HERE (before any copy can happen),
	# the one handle rides into every copy and all faces share one
	# truth. stzLatencyHistogram is lazy by design (paren-less-new
	# robustness), so Handle() forces its engine handle NOW.
	def _Ensure()
		if @oSeries = NULL
			@oSeries = new stzPerfSeries(@nWindow)
		ok
		if @cKind = "timer" and @oHist = NULL
			@oHist = new stzLatencyHistogram()
			@oHist.Handle()
		ok

	def _MustBe(pcKind, pcVerb)
		if @cKind != pcKind
			stzraise("stzMetric '" + @cName + "': " + pcVerb + "() belongs to the :" + pcKind + " kind, and this metric is a :" + @cKind + ".")
		ok

	def Name()
		return @cName

	def Kind()
		return @cKind

	def IsCounter()
		return @cKind = "counter"

	def IsGauge()
		return @cKind = "gauge"

	def IsTimer()
		return @cKind = "timer"

	def SetHelp(pcText)
		@cHelp = "" + pcText
		return This

	def Help()
		return @cHelp

	# -- Counter face ---------------------------------------------

	# The cumulative total lives IN the series (last value); each
	# increment appends total+n stamped with the monotonic clock --
	# so the counter carries its own timeline, and rate falls out.
	def Increment()
		return This.IncrementBy(1)

	def IncrementBy(n)
		This._MustBe("counter", "IncrementBy")
		This._Ensure()
		@oSeries.Record(@oSeries.Last() + n)
		return This

	# Events per second over the retained window: the slope of the
	# cumulative count is the rate (per ms of the monotonic clock;
	# *1000 = per second). This is X, measured -- not configured.
	def RatePerSecond()
		This._MustBe("counter", "RatePerSecond")
		This._Ensure()
		return @oSeries.SlopePerMs() * 1000

	# -- Gauge face -----------------------------------------------

	def Set(nValue)
		This._MustBe("gauge", "Set")
		This._Ensure()
		@oSeries.Record(nValue)
		return This

		def RecordGauge(nValue)
			return This.Set(nValue)

	def SlopePerMs()
		This._MustBe("gauge", "SlopePerMs")
		This._Ensure()
		return @oSeries.SlopePerMs()

	def Mean()
		This._Ensure()
		if @cKind = "counter"
			stzraise("stzMetric '" + @cName + "': Mean() of a cumulative counter is not meaningful -- ask RatePerSecond().")
		ok
		return @oSeries.Mean()

	def Min()
		This._Ensure()
		return @oSeries.Min()

	def Max()
		This._Ensure()
		return @oSeries.Max()

	# -- Timer face -----------------------------------------------

	def Record(nMs)
		if @cKind = "gauge"
			return This.Set(nMs)
		ok
		This._MustBe("timer", "Record")
		This._Ensure()
		@oHist.Record(nMs)
		@oSeries.Record(nMs)
		return This

	# Feed a stopped (or running) stopwatch's reading straight in.
	def RecordWatch(poStopwatch)
		return This.Record(poStopwatch.ElapsedMs())

	# Streaming percentiles: bucket UPPER BOUNDS from the O(1)
	# histogram -- right for unbounded streams, quantized answers.
	def P50()
		This._MustBe("timer", "P50")
		This._Ensure()
		return @oHist.P50()

	def P95()
		This._MustBe("timer", "P95")
		This._Ensure()
		return @oHist.P95()

	def P99()
		This._MustBe("timer", "P99")
		This._Ensure()
		return @oHist.P99()

	# Exact percentile over the RECENT window (the series retains the
	# last @nWindow samples; sort-exact, unlike the buckets).
	def ExactPercentile(nP)
		This._MustBe("timer", "ExactPercentile")
		This._Ensure()
		return @oSeries.Percentile(nP)

	def SumMs()
		This._MustBe("timer", "SumMs")
		This._Ensure()
		return @oHist.Sum()

	# Lifetime mean -- exact (engine keeps the true sum; the buckets
	# quantize, the sum does not).
	def MeanMs()
		This._MustBe("timer", "MeanMs")
		This._Ensure()
		_nC_ = @oHist.Count()
		if _nC_ = 0
			return 0
		ok
		return @oHist.Sum() / _nC_

	# -- Reading (all kinds) --------------------------------------

	# The metric's current answer: counter total / gauge level /
	# timer's last duration.
	def Value()
		This._Ensure()
		return @oSeries.Last()

		def Last()
			return This.Value()

	# Samples ever recorded on this metric.
	def Count()
		This._Ensure()
		if @cKind = "timer"
			return @oHist.Count()
		ok
		return @oSeries.Count()

	def SeriesQ()
		This._Ensure()
		return @oSeries

	def Percentile(nP)
		This._Ensure()
		if @cKind = "timer"
			return This.ExactPercentile(nP)
		ok
		return @oSeries.Percentile(nP)

	# -- Interop: Prometheus exposition ---------------------------

	# The metric name in Prometheus vocabulary: dots and dashes fold
	# to underscores ("app.requests" -> "app_requests").
	def PromName()
		_cN_ = StzReplace(@cName, ".", "_")
		_cN_ = StzReplace(_cN_, "-", "_")
		return _cN_

	def PromText()
		This._Ensure()
		_cN_ = This.PromName()
		_cOut_ = ""
		if @cHelp != ""
			_cOut_ += ("# HELP " + _cN_ + This._PromSuffix() + " " + @cHelp + Char(10))
		ok
		if @cKind = "counter"
			_cOut_ += ("# TYPE " + _cN_ + "_total counter" + Char(10))
			_cOut_ += (_cN_ + "_total " + This.Value() + Char(10))
		but @cKind = "gauge"
			_cOut_ += ("# TYPE " + _cN_ + " gauge" + Char(10))
			_cOut_ += (_cN_ + " " + This.Value() + Char(10))
		else
			_cOut_ += ("# TYPE " + _cN_ + " summary" + Char(10))
			_cOut_ += (_cN_ + '{quantile="0.5"} ' + This.P50() + Char(10))
			_cOut_ += (_cN_ + '{quantile="0.95"} ' + This.P95() + Char(10))
			_cOut_ += (_cN_ + '{quantile="0.99"} ' + This.P99() + Char(10))
			_cOut_ += (_cN_ + "_sum " + This.SumMs() + Char(10))
			_cOut_ += (_cN_ + "_count " + This.Count() + Char(10))
		ok
		return _cOut_

	def _PromSuffix()
		if @cKind = "counter"
			return "_total"
		ok
		return ""

	# -- Interop: one OTLP metric fragment ------------------------

	def OtelMetricJson()
		This._Ensure()
		_cT_ = '"' + ("" + StzEngineTimeWallMs()) + '000000"'
		_cJ_ = '{"name":"' + @cName + '"'
		if @cHelp != ""
			_cJ_ += (',"description":"' + @cHelp + '"')
		ok
		if @cKind = "counter"
			_cJ_ += ',"sum":{"dataPoints":[{"asDouble":'
			_cJ_ += ("" + This.Value())
			_cJ_ += (',"timeUnixNano":' + _cT_ + '}],"aggregationTemporality":2,"isMonotonic":true}}')
		but @cKind = "gauge"
			_cJ_ += ',"gauge":{"dataPoints":[{"asDouble":'
			_cJ_ += ("" + This.Value())
			_cJ_ += (',"timeUnixNano":' + _cT_ + '}]}}')
		else
			_cJ_ += ',"summary":{"dataPoints":[{"count":'
			_cJ_ += ("" + This.Count())
			_cJ_ += (',"sum":' + This.SumMs())
			_cJ_ += ',"quantileValues":[{"quantile":0.5,"value":'
			_cJ_ += ("" + This.P50())
			_cJ_ += ('},{"quantile":0.95,"value":' + This.P95())
			_cJ_ += ('},{"quantile":0.99,"value":' + This.P99())
			_cJ_ += ('}],"timeUnixNano":' + _cT_ + '}]}}')
		ok
		return _cJ_

	# -- Legibility -----------------------------------------------

	def Explain()
		This._Ensure()
		_aLines_ = []
		_aLines_ + ("Metric " + @cName + " (:" + @cKind + ").")
		if @cKind = "counter"
			_aLines_ + ("  total: " + This.Value() + " ; rate: " + This.RatePerSecond() + "/s")
		but @cKind = "gauge"
			_aLines_ + ("  now: " + This.Value() + " ; mean: " + This.Mean() + " ; min..max: " + This.Min() + ".." + This.Max())
			_aLines_ + ("  trend: " + This.SlopePerMs() + " per ms")
		else
			_aLines_ + ("  count: " + This.Count() + " ; mean: " + This.MeanMs() + " ms (exact)")
			_aLines_ + ("  p50/p95/p99: " + This.P50() + " / " + This.P95() + " / " + This.P99() + " ms (bucket bounds)")
		ok
		return _aLines_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	def Destroy()
		if @oSeries != NULL
			@oSeries.Destroy()
			@oSeries = NULL
		ok
		if @oHist != NULL
			@oHist.Destroy()
			@oHist = NULL
		ok
		return This
