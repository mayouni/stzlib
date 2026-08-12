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
	@oSeries = ""
	@oHist = ""		# timers only
	@aLabelPairs = []	# [ [name, value], ... ] when this metric is a
				# family CHILD (perf P8); [] on flat metrics

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
		if @oSeries = ""
			@oSeries = new stzPerfSeries(@nWindow)
		ok
		if @cKind = "timer" and @oHist = ""
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

	def LabelPairs()
		return @aLabelPairs

	# Family-child construction path (perf P8, internal): a child is
	# built PAREN-LESS (no init, so no engine stores are created only
	# to be replaced), named via _InitChild, then bound to the
	# family's engine-owned stores. Children are reconstructed per
	# face on cache miss -- this path must not churn engine handles.
	def _InitChild(pcName, pcKind)
		@cName = "" + pcName
		@cKind = StzLower("" + pcKind)
		return This

	def _BindAdopted(pSeriesHandle, pHistHandle, paLabelPairs)
		if @oSeries != ""
			@oSeries.Destroy()
		ok
		@oSeries = new stzPerfSeries
		@oSeries.AdoptHandle(pSeriesHandle)
		if @cKind = "timer"
			if @oHist != ""
				@oHist.Destroy()
			ok
			@oHist = new stzLatencyHistogram
			@oHist.AdoptHandle(pHistHandle)
		ok
		@aLabelPairs = paLabelPairs
		return This

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
		but @cKind = "gauge"
			_cOut_ += ("# TYPE " + _cN_ + " gauge" + Char(10))
		else
			_cOut_ += ("# TYPE " + _cN_ + " summary" + Char(10))
		ok
		_cOut_ += This._PromSampleLines()
		return _cOut_

	# The sample lines alone (no TYPE header) -- a family renders ONE
	# header then every child's samples through this. Label pairs (on
	# children) render inside the braces; on a timer they merge with
	# the quantile label, Prometheus-style.
	def _PromSampleLines()
		This._Ensure()
		_cN_ = This.PromName()
		_cOut_ = ""
		if @cKind = "counter"
			_cOut_ += (_cN_ + "_total" + This._PromLabels("") + " " + This.Value() + Char(10))
		but @cKind = "gauge"
			_cOut_ += (_cN_ + This._PromLabels("") + " " + This.Value() + Char(10))
		else
			_cOut_ += (_cN_ + This._PromLabels('quantile="0.5"') + " " + This.P50() + Char(10))
			_cOut_ += (_cN_ + This._PromLabels('quantile="0.95"') + " " + This.P95() + Char(10))
			_cOut_ += (_cN_ + This._PromLabels('quantile="0.99"') + " " + This.P99() + Char(10))
			_cOut_ += (_cN_ + "_sum" + This._PromLabels("") + " " + This.SumMs() + Char(10))
			_cOut_ += (_cN_ + "_count" + This._PromLabels("") + " " + This.Count() + Char(10))
		ok
		return _cOut_

	# Render the label block: pairs + an optional extra label (the
	# quantile), escaped per the exposition format. "" when nothing.
	def _PromLabels(pcExtra)
		_nLen_ = ring_len(@aLabelPairs)
		if _nLen_ = 0 and pcExtra = ""
			return ""
		ok
		_cB_ = "{"
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cB_ += ","
			ok
			_cB_ += (@aLabelPairs[_i_][1] + '="' + This._PromEscape(@aLabelPairs[_i_][2]) + '"')
		next
		if pcExtra != ""
			if _nLen_ > 0
				_cB_ += ","
			ok
			_cB_ += pcExtra
		ok
		_cB_ += "}"
		return _cB_

	def _PromEscape(pcVal)
		_cV_ = "" + pcVal
		_cV_ = StzReplace(_cV_, "\", "\\")
		_cV_ = StzReplace(_cV_, '"', '\"')
		return _cV_

	def _PromSuffix()
		if @cKind = "counter"
			return "_total"
		ok
		return ""

	# -- Interop: one OTLP metric fragment ------------------------

	def OtelMetricJson()
		This._Ensure()
		_cJ_ = '{"name":"' + @cName + '"'
		if @cHelp != ""
			_cJ_ += (',"description":"' + @cHelp + '"')
		ok
		_cJ_ += This._OtelBodyJson("[" + This._OtelDataPointJson() + "]")
		return _cJ_

	# The kind wrapper around a dataPoints array (family reuse: one
	# metric object, many children's data points).
	def _OtelBodyJson(pcDataPointsArray)
		if @cKind = "counter"
			return ',"sum":{"dataPoints":' + pcDataPointsArray + ',"aggregationTemporality":2,"isMonotonic":true}}'
		but @cKind = "gauge"
			return ',"gauge":{"dataPoints":' + pcDataPointsArray + '}}'
		ok
		return ',"summary":{"dataPoints":' + pcDataPointsArray + '}}'

	# One data point for THIS metric's current state, with its label
	# pairs as OTel attributes (empty on flat metrics).
	def _OtelDataPointJson()
		This._Ensure()
		_cT_ = '"' + ("" + StzEngineTimeWallMs()) + '000000"'
		_cA_ = This._OtelAttrs()
		if @cKind = "counter" or @cKind = "gauge"
			return '{' + _cA_ + '"asDouble":' + This.Value() + ',"timeUnixNano":' + _cT_ + '}'
		ok
		_cP_ = '{' + _cA_ + '"count":' + This.Count()
		_cP_ += (',"sum":' + This.SumMs())
		_cP_ += ',"quantileValues":[{"quantile":0.5,"value":'
		_cP_ += ("" + This.P50())
		_cP_ += ('},{"quantile":0.95,"value":' + This.P95())
		_cP_ += ('},{"quantile":0.99,"value":' + This.P99())
		_cP_ += ('}],"timeUnixNano":' + _cT_ + '}')
		return _cP_

	def _OtelAttrs()
		_nLen_ = ring_len(@aLabelPairs)
		if _nLen_ = 0
			return ""
		ok
		_cA_ = '"attributes":['
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cA_ += ","
			ok
			_cA_ += ('{"key":"' + @aLabelPairs[_i_][1] + '","value":{"stringValue":"' + This._JsonStrM(@aLabelPairs[_i_][2]) + '"}}')
		next
		_cA_ += "],"
		return _cA_

	def _JsonStrM(pcStr)
		_cS_ = "" + pcStr
		_cS_ = StzReplace(_cS_, "\", "\\")
		_cS_ = StzReplace(_cS_, '"', '\"')
		return _cS_

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
		if @oSeries != ""
			@oSeries.Destroy()
			@oSeries = ""
		ok
		if @oHist != ""
			@oHist.Destroy()
			@oHist = ""
		ok
		return This
