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

# Holds one named series of measurements, a counter, a gauge or a timer, and answers the questions that its kind allows.
#
# The kind is fixed at birth. A counter counts events (Increment, IncrementBy, Value,
# RatePerSecond); a gauge holds a sampled level (Set, Mean, Min, Max, SlopePerMs); a timer records
# durations in milliseconds (Record, RecordWatch, then P50, P95 and P99 from a bucketed histogram,
# ExactPercentile over the recent samples, and an exact SumMs and MeanMs). A call that belongs to
# another kind raises an error that names the right kind. The samples are kept in the engine, so a
# copy of a metric is a second face on the same samples: recording through either is read through
# both. PromText and OtelMetricJson render the metric in the Prometheus and OpenTelemetry formats.
# Free a metric with Destroy when done. Readings that depend on the clock, such as RatePerSecond and
# SlopePerMs, should be tested with ranges and signs, not exact values.
#
#   receiver   o1 = StzMetric("db.query", :Timer)
#   example    o1.Record(5).Record(15).Record(25)
#              ? o1.Count()
#              #--> 3
#              ? o1.SumMs()
#              #--> 45
#              ? o1.MeanMs()
#              #--> 15
#              ? o1.ExactPercentile(50)
#              #--> 15
#              ? o1.P50()
#              #--> 20
#              o2 = StzMetric("app.requests", :Counter)
#              o2.Increment().IncrementBy(4)
#              ? o2.Value()
#              #--> 5
#              ? o2.RatePerSecond() >= 0
#              #--> 1
#   see        StzPerfMonitor, stzStopwatch, stzPerfSeries
class stzMetric from stzObject

	@cName = ""
	@cKind = ""		# :counter / :gauge / :timer (folded lowercase)
	@cHelp = ""
	@nWindow = 1024
	@oSeries = ""
	@oHist = ""		# timers only
	@aLabelPairs = []	# [ [name, value], ... ] when this metric is a
	# Builds a named metric of one kind, :Counter, :Gauge or :Timer, whose samples live in the engine; any other kind raises an error.
	#
	#   pcName     the metric's name, such as app.requests
	#   pcKind     the kind: :Counter, :Gauge or :Timer, matched without regard to case
	#   returns    nothing; the object is built
	#   note       StzMetric(name, kind) is the usual way to build one; a copy of a metric shares
	#              the same samples
	#   warning    a kind that is not one of the three raises stzMetric: kind must be :Counter,
	#              :Gauge or :Timer
	#   see        Name, Kind, Destroy
	#@ aka  family CHILD (perf P8); [] on flat metrics
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

	# Returns the metric's name as given.
	#
	#   returns    a text
	#   see        Kind, PromName
	def Name()
		return @cName

	# Returns the metric's kind, in lower case.
	#
	#   returns    the text counter, gauge or timer
	#   see        IsCounter, IsGauge, IsTimer
	def Kind()
		return @cKind

	# TRUE if the metric counts events.
	#
	#   returns    1 or 0
	#   see        Kind, IsGauge, IsTimer
	def IsCounter()
		return @cKind = "counter"

	# TRUE if the metric holds a sampled level.
	#
	#   returns    1 or 0
	#   see        Kind, IsCounter, IsTimer
	def IsGauge()
		return @cKind = "gauge"

	# TRUE if the metric records durations.
	#
	#   returns    1 or 0
	#   see        Kind, IsCounter, IsGauge
	def IsTimer()
		return @cKind = "timer"

	# Sets the description that the Prometheus and OpenTelemetry outputs carry, and returns the metric.
	#
	#   pcText     the description, as text
	#   returns    the metric itself, so calls chain
	#   see        Help, PromText, OtelMetricJson
	def SetHelp(pcText)
		@cHelp = "" + pcText
		return This

	# Returns the description set with SetHelp.
	#
	#   returns    a text; empty until one is set
	#   see        SetHelp
	def Help()
		return @cHelp

	# Returns the label pairs of a metric that is a child of a family.
	#
	#   returns    a list of [ name, value ] pairs; an empty list for a metric made on its own
	#   see        PromText, OtelMetricJson
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

	# Adds one to a counter and returns the metric.
	#
	#   returns    the metric itself, so calls chain
	#   note       each call is one sample on the counter's timeline
	#   warning    a gauge or a timer raises an error saying the call belongs to the counter kind
	#   see        IncrementBy, Value, RatePerSecond
	#@ aka  -- Counter face ---------------------------------------------
	def Increment()
		return This.IncrementBy(1)

	# Adds a number to a counter and returns the metric.
	#
	#   n          how much to add
	#   returns    the metric itself, so calls chain
	#   warning    a gauge or a timer raises an error saying the call belongs to the counter kind
	#   see        Increment, Value
	def IncrementBy(n)
		This._MustBe("counter", "IncrementBy")
		This._Ensure()
		@oSeries.Record(@oSeries.Last() + n)
		return This

	# Returns the counter's events per second over the retained samples, read from the slope of its own timeline.
	#
	#   returns    a number, 0 or more; it depends on the clock, so test it with a range
	#   note       the rate is measured, never configured
	#   warning    a gauge or a timer raises an error saying the call belongs to the counter kind
	#   see        Increment, Value
	#@ aka  Events per second over the retained window: the slope of the cumulative count is the rate (per ms of the monotonic clock; *1000 = per second). This is X, measured -- not configured.
	def RatePerSecond()
		This._MustBe("counter", "RatePerSecond")
		This._Ensure()
		return @oSeries.SlopePerMs() * 1000

	# Records a level on a gauge and returns the metric.
	#
	#   nValue     the level to record
	#   returns    the metric itself, so calls chain
	#   note       RecordGauge is the same call
	#   warning    a counter or a timer raises an error saying the call belongs to the gauge kind
	#   see        Value, Mean, SlopePerMs
	#@ aka  -- Gauge face -----------------------------------------------
	def Set(nValue)
		This._MustBe("gauge", "Set")
		This._Ensure()
		@oSeries.Record(nValue)
		return This

		def RecordGauge(nValue)
			return This.Set(nValue)

	# Returns the trend of a gauge, in units per millisecond, over the retained samples.
	#
	#   returns    a number; positive for a rising gauge, negative for a falling one
	#   note       it depends on the clock, so test its sign, not its value
	#   warning    a counter or a timer raises an error saying the call belongs to the gauge kind
	#   see        Set, Mean
	def SlopePerMs()
		This._MustBe("gauge", "SlopePerMs")
		This._Ensure()
		return @oSeries.SlopePerMs()

	# Returns the mean of the retained samples of a gauge or a timer.
	#
	#   returns    a number
	#   note       a timer's lifetime mean is MeanMs
	#   warning    a counter raises an error and points to RatePerSecond
	#   see        MeanMs, Min, Max
	def Mean()
		This._Ensure()
		if @cKind = "counter"
			stzraise("stzMetric '" + @cName + "': Mean() of a cumulative counter is not meaningful -- ask RatePerSecond().")
		ok
		return @oSeries.Mean()

	# Returns the smallest retained sample.
	#
	#   returns    a number; 0 before any sample
	#   see        Max, Mean
	def Min()
		This._Ensure()
		return @oSeries.Min()

	# Returns the largest retained sample.
	#
	#   returns    a number; 0 before any sample
	#   see        Min, Mean
	def Max()
		This._Ensure()
		return @oSeries.Max()

	# Records a duration on a timer in milliseconds and returns the metric; on a gauge it records a level, as Set does.
	#
	#   nMs        the duration in milliseconds
	#   returns    the metric itself, so calls chain
	#   warning    a counter raises an error saying the call belongs to the timer kind
	#   see        RecordWatch, P50, SumMs, Set
	#@ aka  -- Timer face -----------------------------------------------
	def Record(nMs)
		if @cKind = "gauge"
			return This.Set(nMs)
		ok
		This._MustBe("timer", "Record")
		This._Ensure()
		@oHist.Record(nMs)
		@oSeries.Record(nMs)
		return This

	# Records the reading of a stopwatch, running or stopped, as one duration and returns the metric.
	#
	#   poStopwatch   a stzStopwatch, as StzStopwatch() builds it
	#   returns       the metric itself, so calls chain
	#   see           Record, P50
	#@ aka  Feed a stopped (or running) stopwatch's reading straight in.
	def RecordWatch(poStopwatch)
		return This.Record(poStopwatch.ElapsedMs())

	# Returns the median duration of a timer as the upper bound of its histogram bucket.
	#
	#   returns    a number in milliseconds, rounded up to a bucket bound
	#   note       with the samples 5, 15 and 25 it gave 20; ExactPercentile gives 15
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        P95, P99, ExactPercentile
	#@ aka  Streaming percentiles: bucket UPPER BOUNDS from the O(1) histogram -- right for unbounded streams, quantized answers.
	def P50()
		This._MustBe("timer", "P50")
		This._Ensure()
		return @oHist.P50()

	# Returns the 95th percentile duration of a timer as the upper bound of its histogram bucket.
	#
	#   returns    a number in milliseconds, rounded up to a bucket bound
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        P50, P99, ExactPercentile
	def P95()
		This._MustBe("timer", "P95")
		This._Ensure()
		return @oHist.P95()

	# Returns the 99th percentile duration of a timer as the upper bound of its histogram bucket.
	#
	#   returns    a number in milliseconds, rounded up to a bucket bound
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        P50, P95, ExactPercentile
	def P99()
		This._MustBe("timer", "P99")
		This._Ensure()
		return @oHist.P99()

	# Returns the percentile of the recent samples of a timer, computed by sorting them, with no bucket rounding.
	#
	#   nP         the percentile, from 0 to 100
	#   returns    a number in milliseconds
	#   note       only the last 1024 samples are kept
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        P50, Percentile
	#@ aka  Exact percentile over the RECENT window (the series retains the last @nWindow samples; sort-exact, unlike the buckets).
	def ExactPercentile(nP)
		This._MustBe("timer", "ExactPercentile")
		This._Ensure()
		return @oSeries.Percentile(nP)

	# Returns the total of all the durations recorded on a timer since it was built.
	#
	#   returns    a number in milliseconds
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        MeanMs, Count
	def SumMs()
		This._MustBe("timer", "SumMs")
		This._Ensure()
		return @oHist.Sum()

	# Returns the exact mean of all the durations recorded on a timer, and 0 before any.
	#
	#   returns    a number in milliseconds
	#   note       the sum is kept exactly; only the buckets are rounded
	#   warning    a counter or a gauge raises an error saying the call belongs to the timer kind
	#   see        SumMs, Count, Mean
	#@ aka  Lifetime mean -- exact (engine keeps the true sum; the buckets quantize, the sum does not).
	def MeanMs()
		This._MustBe("timer", "MeanMs")
		This._Ensure()
		_nC_ = @oHist.Count()
		if _nC_ = 0
			return 0
		ok
		return @oHist.Sum() / _nC_

	# Returns the metric's current reading: a counter's total, a gauge's level, or a timer's last duration.
	#
	#   returns    a number; 0 before any sample
	#   note       Last is the same call
	#   see        Count, Increment, Set
	#@ aka  -- Reading (all kinds) --------------------------------------
	def Value()
		This._Ensure()
		return @oSeries.Last()

		def Last()
			return This.Value()

	# Returns how many samples were recorded on the metric.
	#
	#   returns    a number
	#   see        Value, SumMs
	#@ aka  Samples ever recorded on this metric.
	def Count()
		This._Ensure()
		if @cKind = "timer"
			return @oHist.Count()
		ok
		return @oSeries.Count()

	# Returns the series object that holds the metric's recent samples.
	#
	#   returns    a stzPerfSeries
	#   see        Percentile, Mean
	def SeriesQ()
		This._Ensure()
		return @oSeries

	# Returns the percentile of the recent samples, whatever the kind.
	#
	#   nP         the percentile, from 0 to 100
	#   returns    a number
	#   warning    for a timer it is the same as ExactPercentile
	#   see        ExactPercentile, P50
	def Percentile(nP)
		This._Ensure()
		if @cKind = "timer"
			return This.ExactPercentile(nP)
		ok
		return @oSeries.Percentile(nP)

	# Returns the name in the Prometheus vocabulary, with dots and dashes folded to underscores.
	#
	#   returns    a text such as app_requests
	#   see        PromText, Name
	#@ aka  -- Interop: Prometheus exposition ---------------------------
	def PromName()
		_cN_ = StzReplace(@cName, ".", "_")
		_cN_ = StzReplace(_cN_, "-", "_")
		return _cN_

	# Returns the metric in the Prometheus exposition format: help line, type line and samples; a counter gets _total.
	#
	#   returns    a text of several lines
	#   note       a timer gives the quantiles 0.5, 0.95 and 0.99, then _sum and _count
	#   see        PromName, OtelMetricJson
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

	# Returns one OpenTelemetry metric as JSON text: a sum for a counter, a gauge, or a summary for a timer.
	#
	#   returns    a JSON text
	#   note       the time stamp in it is the wall clock, so compare the rest
	#   see        PromText
	#@ aka  -- Interop: one OTLP metric fragment ------------------------
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

	# Returns the metric's state as a list of plain lines: its total or level, its rate or trend, and its percentiles.
	#
	#   returns    a list of text
	#   see        Show, Value
	#@ aka  -- Legibility -----------------------------------------------
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

	# Prints the lines that Explain returns.
	#
	#   returns    nothing; it writes to the console
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Frees the engine handles of the metric and returns it; a later call builds fresh, empty ones.
	#
	#   returns    the metric itself, so calls chain
	#   note       free every metric when done, since the engine holds the samples
	#   see        init
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
