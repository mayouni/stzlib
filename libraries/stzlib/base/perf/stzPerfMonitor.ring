/*
	stzPerfMonitor -- the sampler (perf P2).

	P1 gave the engine senses (RSS, peak, system memory, CPU time);
	the monitor is what WATCHES them: declare what to watch and a
	cadence, and every due tick samples the senses into engine-resident
	gauges -- bounded memory forever, O(1) per sample, cheap enough to
	never turn off (the only monitoring that helps with problems you
	cannot reproduce is the monitoring that was already on).

		oMon = new stzPerfMonitor("restolean")
		oMon.WatchMemory().WatchCpu().Every(1000)
		oMon.Sample()                    # one sample, now (pull)
		? oMon.MetricQ("process.memory.rss").Value()

	Three ways to run it, same object:
	  1. PULL   -- call Sample() yourself whenever you like.
	  2. TICK   -- call Tick() from any loop you already run; it
	               samples only when the Every() cadence is due.
	  3. HOSTED -- the monitor IS an agent in the house sense: it has
	               Name_() and Cycle(), so any stzAgentHost supervises
	               it (oHost.Supervise(oMon, 1000)) -- including the
	               host inside a running stzAppServer. A server that
	               hosts agents samples its own health for free.

	The monitor also registers YOUR metrics (NewCounter/NewGauge/
	NewTimer) so one object can answer for the whole process --
	legibly (Explain/Show) and in the industry's formats:
	Prometheus() = the /metrics exposition text; OtelJson() = one
	OTLP resourceMetrics envelope batching every metric.

	Ring copy honesty: metric state is engine-side (see stzMetric),
	so the copies Ring makes when metrics enter and leave the
	registry all read and write the same truth. The monitor's OWN
	small state (cadence bookkeeping, CPU baseline) is Ring-side --
	whichever face runs the sampling loop keeps the baseline, and
	every face reads the same sampled data.

	Engine handles must be freed: Destroy() when done.
*/

func StzPerfMonitor(pcName)
	return new stzPerfMonitor(pcName)

# Samples the process senses into gauges on a cadence, holds your own counters, gauges and timers, and renders them for Prometheus or OpenTelemetry.
#
# Declare what to watch (WatchMemory, WatchCpu, WatchSystemMemory), then sample in one of three
# ways: call Sample yourself, call Tick from any loop (it samples only when the Every interval has
# passed), or host the monitor on an agent host through Name_ and Cycle. Register your own metrics
# with NewCounter, NewGauge and NewTimer and read any metric back with MetricQ. Prometheus and
# OtelJson render all of them, Explain and Show describe them in text, and EnableTracing keeps the
# last request traces. The numbers are engine-side, so copies of the monitor agree; call Destroy
# when done. Live values change on every run: test them as ranges and signs, never as exact numbers.
#
#   receiver   o1 = new stzPerfMonitor("shop")
#   example    o1.WatchMemory().WatchCpu().Every(250)
#              ? o1.Sample()
#              #--> 2
#              ? o1.Sample()
#              #--> 3
#              ? o1.MetricQ("process.memory.rss").Value() > 0
#              #--> 1
#              o1.NewCounter("orders").Increment()
#              ? o1.MetricQ("orders").Value()
#              #--> 1
#              ? @@( o1.Metrics()[4] )
#              #--> [ "orders", "counter" ]
#              ? o1.SampleCount()
#              #--> 2
#              ? o1.EveryMs()
#              #--> 250
#              o1.Destroy()
#   see        stzMetric, StzPerfMonitor, stzLog
class stzPerfMonitor from stzObject

	@cName = "perf-monitor"
	@aMetrics = []		# rows: [ name, oMetric ] -- write through the index
	@nEveryMs = 1000
	@nNextDueMs = 0
	@nSamples = 0
	@bWatchMemory = 0
	@bWatchCpu = 0
	@bWatchSystem = 0
	@nLastCpuNs = 0
	@nLastUpNs = 0
	@nSelfNs = 0		# monotonic ns spent inside Sample() (perf P6:
				# a monitor that cannot state its own cost is
				# not industry-strength)
	pTraceRing = ""	# engine trace ring (perf P7) -- request traces
	bTracing = 0	# shared by every Ring copy of this monitor

	# Builds a monitor with the given name, watching nothing yet, sampling every 1000 ms and with tracing off.
	#
	#   pcName     the monitor's name, which becomes the service name in the OpenTelemetry output
	#   returns    nothing; the object is built
	#   see        WatchMemory, Every, Sample
	def init(pcName)
		if isString(pcName) and pcName != ""
			@cName = pcName
		ok

	# Returns the monitor's name.
	#
	#   returns    a text, such as shop
	#   see        Name_
	def Name()
		return @cName

	# Returns the monitor's name under the spelling the agent-host contract expects.
	#
	#   returns    a text, such as shop
	#   see        Name, Cycle
	#@ aka  The agent-host contract spells it Name_().
	def Name_()
		return @cName

	# Declares that every sample reads the process memory, and registers the gauges process.memory.rss and process.memory.peak.
	#
	#   returns    the monitor itself, so calls chain
	#   note       calling it twice registers nothing more
	#   see        WatchCpu, WatchSystemMemory, Sample
	#@ aka  -- Declaring what to watch ----------------------------------
	def WatchMemory()
		if NOT @bWatchMemory
			@bWatchMemory = 1
			This._Register(StzMetric("process.memory.rss", :Gauge).SetHelp("Resident set size in bytes"))
			This._Register(StzMetric("process.memory.peak", :Gauge).SetHelp("Peak working set in bytes"))
		ok
		return This

	# Declares that every sample reads the CPU use of the process, and registers the gauge process.cpu.utilization.
	#
	#   returns    the monitor itself, so calls chain
	#   note       the first sample only sets the baseline, so the gauge is written from the second
	#              sample on
	#   see        WatchMemory, Sample
	def WatchCpu()
		if NOT @bWatchCpu
			@bWatchCpu = 1
			This._Register(StzMetric("process.cpu.utilization", :Gauge).SetHelp("Fraction of machine CPU this process used over the last sampling interval"))
		ok
		return This

	# Declares that every sample reads the free physical memory of the machine, and registers the gauge system.memory.free.
	#
	#   returns    the monitor itself, so calls chain
	#   see        WatchMemory, Sample
	def WatchSystemMemory()
		if NOT @bWatchSystem
			@bWatchSystem = 1
			This._Register(StzMetric("system.memory.free", :Gauge).SetHelp("Available physical memory in bytes"))
		ok
		return This

	# Sets the interval, in milliseconds, that Tick and RunFor wait between two samples.
	#
	#   pnMs       the interval in milliseconds, 1 or more
	#   returns    the monitor itself, so calls chain
	#   warning    a value below 1 or one that is not a number is ignored and the old interval stays
	#   see        EveryMs, Tick, RunFor
	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	# Returns the sampling interval in milliseconds.
	#
	#   returns    a number; 1000 on a new monitor
	#   see        Every
	def EveryMs()
		return @nEveryMs

	# Starts keeping the last requests' traces in an engine ring, and does nothing if tracing is already on.
	#
	#   pnCapacity   how many traces the ring keeps
	#   returns      the monitor itself, so calls chain
	#   note         turn it on before handing the monitor to a server, which stores a copy at that
	#                moment
	#   see          RecordTrace, RecentTraces, IsTracing
	#@ aka  -- Request tracing (perf P7) --------------------------------
	def EnableTracing(pnCapacity)
		if pTraceRing = ""
			_nCap_ = 128
			if isNumber(pnCapacity) and pnCapacity >= 1
				_nCap_ = pnCapacity
			ok
			pTraceRing = StzEnginePerfTraceCreate(_nCap_)
			bTracing = 1
		ok
		return This

	# TRUE if tracing was turned on and not yet destroyed.
	#
	#   returns    1 or 0
	#   see        EnableTracing, Destroy
	def IsTracing()
		return bTracing

	# Adds one request trace to the ring, stamped with the wall clock; ignored when tracing is off.
	#
	#   pcTraceId   the identifier of the trace
	#   pcPath      the request path
	#   pnStatus    the response status such as 200
	#   pnDurMs     how long the request took in milliseconds
	#   returns     the monitor itself, so calls chain
	#   see         RecentTraces, TraceCount, EnableTracing
	def RecordTrace(pcTraceId, pcPath, pnStatus, pnDurMs)
		if NOT bTracing
			return This
		ok
		StzEnginePerfTraceRecord(pTraceRing, "" + pcTraceId, "" + pcPath,
			pnStatus, pnDurMs, StzEngineTimeWallMs())
		return This

	# Returns how many traces were recorded since tracing started, or 0 when tracing is off.
	#
	#   returns    a number
	#   note       it counts every trace ever recorded, so it can exceed the ring's capacity;
	#              RecentTraces returns at most the capacity
	#   see        RecordTrace, RecentTraces
	def TraceCount()
		if NOT bTracing
			return 0
		ok
		return StzEnginePerfTraceCount(pTraceRing)

	# Returns the newest traces, oldest of them first, up to the number asked for.
	#
	#   pnHowMany   how many of the newest traces to return
	#   returns     a list of hash-lists with traceId, path, status, durMs and wallMs; [ ] when
	#               tracing is off
	#   see         RecordTrace, TraceCount
	#@ aka  The last pnHowMany traces, oldest first: [ [ :traceId, :path, :status, :durMs, :wallMs ], ... ]
	def RecentTraces(pnHowMany)
		_aOut_ = []
		if NOT bTracing
			return _aOut_
		ok
		_nSize_ = StzEnginePerfTraceSize(pTraceRing)
		_nFrom_ = _nSize_ - pnHowMany + 1
		if _nFrom_ < 1
			_nFrom_ = 1
		ok
		for _i_ = _nFrom_ to _nSize_
			_aOut_ + [
				:traceId = StzEnginePerfTraceIdAt(pTraceRing, _i_),
				:path = StzEnginePerfTracePathAt(pTraceRing, _i_),
				:status = StzEnginePerfTraceStatusAt(pTraceRing, _i_),
				:durMs = StzEnginePerfTraceDurAt(pTraceRing, _i_),
				:wallMs = StzEnginePerfTraceWallAt(pTraceRing, _i_)
			]
		next
		return _aOut_

	# Registers a counter of your own and returns it, ready to count up.
	#
	#   pcName     the metric's name, unique in this monitor
	#   returns    the metric object, a counter
	#   warning    raises an error when a metric of that name is already registered
	#   see        NewGauge, NewTimer, MetricQ
	#@ aka  -- Your own metrics -----------------------------------------
	def NewCounter(pcName)
		return This._Register(StzMetric(pcName, :Counter))

	# Registers a gauge of your own and returns it, ready to hold a value that goes up and down.
	#
	#   pcName     the metric's name, unique in this monitor
	#   returns    the metric object, a gauge
	#   warning    raises an error when a metric of that name is already registered
	#   see        NewCounter, NewTimer
	def NewGauge(pcName)
		return This._Register(StzMetric(pcName, :Gauge))

	# Registers a timer of your own and returns it, ready to record durations in milliseconds.
	#
	#   pcName     the metric's name, unique in this monitor
	#   returns    the metric object, a timer
	#   warning    raises an error when a metric of that name is already registered
	#   see        NewCounter, NewGauge
	def NewTimer(pcName)
		return This._Register(StzMetric(pcName, :Timer))

	# The labeled forms (perf P8): a FAMILY -- one name, declared label
	# names, one child per label-value combination. Registered in the
	# same registry; MetricQ(name) returns the family, Child([...])
	# picks the child. Cardinality bounded (default 64; use
	# StzMetricFamilyXT + _Register for other bounds).
	def NewCounterXT(pcName, paLabelNames)
		return This._Register(StzMetricFamily(pcName, :Counter, paLabelNames))

	def NewGaugeXT(pcName, paLabelNames)
		return This._Register(StzMetricFamily(pcName, :Gauge, paLabelNames))

	def NewTimerXT(pcName, paLabelNames)
		return This._Register(StzMetricFamily(pcName, :Timer, paLabelNames))

	def _Register(poMetric)
		if This._IndexOf(poMetric.Name()) > 0
			stzraise("stzPerfMonitor '" + @cName + "': a metric named '" + poMetric.Name() + "' is already registered.")
		ok
		@aMetrics + [ poMetric.Name(), poMetric ]
		return @aMetrics[ring_len(@aMetrics)][2]

	def _IndexOf(pcName)
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			if @aMetrics[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	# TRUE if a metric of this name is registered, among the watched ones or your own.
	#
	#   pcName     the metric's name
	#   returns    1 or 0
	#   see        MetricQ, Metrics
	def HasMetric(pcName)
		return This._IndexOf(pcName) > 0

	# Returns the registered metric of this name, a chainable object that shares its numbers with the registry.
	#
	#   pcName     the metric's name
	#   returns    the metric object
	#   warning    raises an error naming the metric when none is registered
	#   see        HasMetric, NewCounter
	#@ aka  The metric as a chainable object. It is a Ring COPY whose state is the SAME engine series/histogram -- record through it, read through the monitor, the numbers agree.
	def MetricQ(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzPerfMonitor '" + @cName + "': no metric named '" + pcName + "'.")
		ok
		return @aMetrics[_n_][2]

	# Returns the registry as data, one pair of name and kind for each metric, in registration order.
	#
	#   returns    a list of pairs such as [ "queue", "gauge" ]
	#   see        NumberOfMetrics, MetricQ
	#@ aka  The registry as data: [ [name, kind], ... ].
	def Metrics()
		_aRes_ = []
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			_aRes_ + [ @aMetrics[_i_][1], @aMetrics[_i_][2].Kind() ]
		next
		return _aRes_

	# Returns how many metrics are registered.
	#
	#   returns    a number
	#   see        Metrics
	def NumberOfMetrics()
		return ring_len(@aMetrics)

	# Reads every declared sense now, whether due or not, and writes the gauges.
	#
	#   returns    the number of gauge writes made, a number; 0 when nothing is watched
	#   note       the first sample with the CPU watched writes one gauge fewer, as it only sets the
	#              baseline
	#   see        Tick, SampleCount, SelfCost
	#@ aka  -- Sampling -------------------------------------------------
	def Sample()
		_nSelfT0_ = StzEngineWatchTimestampNs()
		_nWrites_ = 0
		if @bWatchMemory
			_n_ = This._IndexOf("process.memory.rss")
			@aMetrics[_n_][2].Set(StzEnginePerfMemRss())
			_n_ = This._IndexOf("process.memory.peak")
			@aMetrics[_n_][2].Set(StzEnginePerfMemPeak())
			_nWrites_ += 2
		ok
		if @bWatchCpu
			_nCpu_ = StzEnginePerfCpuNs()
			_nUp_ = StzEngineProcessUptimeNs()
			if @nLastUpNs > 0 and _nUp_ > @nLastUpNs
				_nU_ = (_nCpu_ - @nLastCpuNs) / ((_nUp_ - @nLastUpNs) * StzEngineSystemCpuCount())
				if _nU_ < 0
					_nU_ = 0
				ok
				if _nU_ > 1
					_nU_ = 1
				ok
				_n_ = This._IndexOf("process.cpu.utilization")
				@aMetrics[_n_][2].Set(_nU_)
				_nWrites_++
			ok
			# The baseline moves every sample; the FIRST sample only
			# anchors it (no interval to speak about yet -- honest).
			@nLastCpuNs = _nCpu_
			@nLastUpNs = _nUp_
		ok
		if @bWatchSystem
			_n_ = This._IndexOf("system.memory.free")
			@aMetrics[_n_][2].Set(StzEnginePerfSysMemFree())
			_nWrites_++
		ok
		@nSamples++
		@nSelfNs += (StzEngineWatchTimestampNs() - _nSelfT0_)
		return _nWrites_

	# Returns how many samples have been taken.
	#
	#   returns    a number
	#   see        Sample, Tick
	def SampleCount()
		return @nSamples

	# Returns what the sampling itself has cost, measured on the monotonic clock.
	#
	#   returns    a hash-list with samples, totalMs and perSampleMs
	#   note       totalMs and perSampleMs vary from run to run, so test them as ranges
	#   see        Sample
	#@ aka  What observation itself costs -- measured with the same clock it provides (the profiler profiles the profiler). Wall ms on the monotonic clock: sampling is straight-line sense-reading, so wall is the honest price (and Windows quantizes CPU too coarsely for per-sample readings anyway). Returns [ :samples, :totalMs, :perSampleMs ].
	def SelfCost()
		_nT_ = @nSelfNs / 1000000
		_nPer_ = 0
		if @nSamples > 0
			_nPer_ = _nT_ / @nSamples
		ok
		return [ :samples = @nSamples, :totalMs = _nT_, :perSampleMs = _nPer_ ]

	# Takes a sample only when the interval has passed since the last one, so any loop can call it freely.
	#
	#   returns    1 if it sampled, 0 if not yet due; the first call always samples
	#   see        Every, Sample, Cycle
	#@ aka  Cadence-gated: samples only when Every() has elapsed on the monotonic clock. Call from any loop; returns 1 if it sampled.
	def Tick()
		_nNow_ = StzEngineWatchTimestampMs()
		if _nNow_ < @nNextDueMs
			return 0
		ok
		@nNextDueMs = _nNow_ + @nEveryMs
		This.Sample()
		return 1

	# The agent-host contract: one perceive-decide-act cycle. The
	# monitor's whole act is sampling; hosting it on any stzAgentHost
	# (a server's included) makes monitoring continuous.
	def Cycle()
		return This.Tick()

	# Keeps ticking for the given time, sleeping between samples, and blocks until it ends.
	#
	#   pnMs       how long to run, in milliseconds
	#   returns    the monitor itself, so calls chain
	#   warning    meant for scripts and guards; a server should host the monitor instead
	#   see        Tick, Every
	#@ aka  Standalone continuous mode: drive the cadence for nMs (blocking; for scripts and guards -- servers should host, not block).
	def RunFor(pnMs)
		_nDeadline_ = StzEngineWatchTimestampMs() + pnMs
		while StzEngineWatchTimestampMs() < _nDeadline_
			This.Tick()
			_nWait_ = @nNextDueMs - StzEngineWatchTimestampMs()
			if _nWait_ > 50
				_nWait_ = 50
			ok
			if _nWait_ >= 1
				StzEngineTimeSleepMs(_nWait_)
			ok
		end
		return This

	# Renders every metric in the Prometheus text format served at /metrics.
	#
	#   returns    a text of HELP and TYPE lines followed by the values; empty text with no metric
	#   note       a labeled family with no child yet prints one line with the label value _overflow
	#   see        OtelJson, Metrics
	#@ aka  -- Interop: the industry formats ----------------------------
	def Prometheus()
		_cOut_ = ""
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			_cOut_ += @aMetrics[_i_][2].PromText()
		next
		return _cOut_

	# Renders every metric as one OpenTelemetry metrics envelope in JSON.
	#
	#   returns    a text holding the JSON, with the monitor's name as service name
	#   see        Prometheus
	#@ aka  One OTLP resourceMetrics envelope batching every metric.
	def OtelJson()
		_cMs_ = ""
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cMs_ += ","
			ok
			_cMs_ += @aMetrics[_i_][2].OtelMetricJson()
		next
		_cJ_ = '{"resourceMetrics":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"'
		_cJ_ += @cName
		_cJ_ += '"}}]},"scopeMetrics":[{"scope":{"name":"softanza.perf"},"metrics":['
		_cJ_ += _cMs_
		_cJ_ += ']}]}]}'
		return _cJ_

	# Describes the monitor and each metric in plain lines of text.
	#
	#   returns    a list of text, the first line giving the metric count, interval and sample count
	#   see        Show
	#@ aka  -- Legibility -----------------------------------------------
	def Explain()
		_aLines_ = []
		_aLines_ + ("Monitor " + @cName + " -- " + ring_len(@aMetrics) + " metric(s), sampling every " + @nEveryMs + " ms, " + @nSamples + " sample(s) taken.")
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			_aSub_ = @aMetrics[_i_][2].Explain()
			_nSub_ = ring_len(_aSub_)
			for _j_ = 1 to _nSub_
				_aLines_ + ("  " + _aSub_[_j_])
			next
		next
		return _aLines_

	# Prints the lines of the explanation on the console.
	#
	#   returns    nothing
	#   see        Explain
	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# Frees the engine handles of every metric and of the trace ring, and empties the registry.
	#
	#   returns    the monitor itself, so calls chain
	#   note       call it when done, as engine handles are not freed by Ring
	#   see        EnableTracing
	def Destroy()
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			@aMetrics[_i_][2].Destroy()
		next
		@aMetrics = []
		if bTracing
			StzEnginePerfTraceDestroy(pTraceRing)
			pTraceRing = ""
			bTracing = 0
		ok
		return This
