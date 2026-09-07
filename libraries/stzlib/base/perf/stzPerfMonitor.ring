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

	def init(pcName)
		if isString(pcName) and pcName != ""
			@cName = pcName
		ok

	def Name()
		return @cName

	# The agent-host contract spells it Name_().
	def Name_()
		return @cName

	# -- Declaring what to watch ----------------------------------

	def WatchMemory()
		if NOT @bWatchMemory
			@bWatchMemory = 1
			This._Register(StzMetric("process.memory.rss", :Gauge).SetHelp("Resident set size in bytes"))
			This._Register(StzMetric("process.memory.peak", :Gauge).SetHelp("Peak working set in bytes"))
		ok
		return This

	def WatchCpu()
		if NOT @bWatchCpu
			@bWatchCpu = 1
			This._Register(StzMetric("process.cpu.utilization", :Gauge).SetHelp("Fraction of machine CPU this process used over the last sampling interval"))
		ok
		return This

	def WatchSystemMemory()
		if NOT @bWatchSystem
			@bWatchSystem = 1
			This._Register(StzMetric("system.memory.free", :Gauge).SetHelp("Available physical memory in bytes"))
		ok
		return This

	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	def EveryMs()
		return @nEveryMs

	# -- Request tracing (perf P7) --------------------------------

	# Keep the last pnCapacity request traces [traceId, path, status,
	# durMs, wallMs] in an ENGINE ring -- one truth for every face
	# (the server's copy records, the sentinel's copy reads, alerts
	# carry the trip's trace ids). Enable BEFORE handing the monitor
	# to Observe(): the server stores a Ring copy at that moment, and
	# a copy made earlier does not know tracing was turned on later.
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

	def IsTracing()
		return bTracing

	def RecordTrace(pcTraceId, pcPath, pnStatus, pnDurMs)
		if NOT bTracing
			return This
		ok
		StzEnginePerfTraceRecord(pTraceRing, "" + pcTraceId, "" + pcPath,
			pnStatus, pnDurMs, StzEngineTimeWallMs())
		return This

	def TraceCount()
		if NOT bTracing
			return 0
		ok
		return StzEnginePerfTraceCount(pTraceRing)

	# The last pnHowMany traces, oldest first:
	# [ [ :traceId, :path, :status, :durMs, :wallMs ], ... ]
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

	# -- Your own metrics -----------------------------------------

	def NewCounter(pcName)
		return This._Register(StzMetric(pcName, :Counter))

	def NewGauge(pcName)
		return This._Register(StzMetric(pcName, :Gauge))

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

	def HasMetric(pcName)
		return This._IndexOf(pcName) > 0

	# The metric as a chainable object. It is a Ring COPY whose state
	# is the SAME engine series/histogram -- record through it, read
	# through the monitor, the numbers agree.
	def MetricQ(pcName)
		_n_ = This._IndexOf(pcName)
		if _n_ = 0
			stzraise("stzPerfMonitor '" + @cName + "': no metric named '" + pcName + "'.")
		ok
		return @aMetrics[_n_][2]

	# The registry as data: [ [name, kind], ... ].
	def Metrics()
		_aRes_ = []
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			_aRes_ + [ @aMetrics[_i_][1], @aMetrics[_i_][2].Kind() ]
		next
		return _aRes_

	def NumberOfMetrics()
		return ring_len(@aMetrics)

	# -- Sampling -------------------------------------------------

	# One sample of every watched sense, NOW (unconditional pull).
	# Returns the number of gauge writes performed. Self-priced: the
	# monotonic cost of every pass accumulates for SelfCost().
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

	def SampleCount()
		return @nSamples

	# What observation itself costs -- measured with the same clock it
	# provides (the profiler profiles the profiler). Wall ms on the
	# monotonic clock: sampling is straight-line sense-reading, so
	# wall is the honest price (and Windows quantizes CPU too coarsely
	# for per-sample readings anyway). Returns
	# [ :samples, :totalMs, :perSampleMs ].
	def SelfCost()
		_nT_ = @nSelfNs / 1000000
		_nPer_ = 0
		if @nSamples > 0
			_nPer_ = _nT_ / @nSamples
		ok
		return [ :samples = @nSamples, :totalMs = _nT_, :perSampleMs = _nPer_ ]

	# Cadence-gated: samples only when Every() has elapsed on the
	# monotonic clock. Call from any loop; returns 1 if it sampled.
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

	# Standalone continuous mode: drive the cadence for nMs (blocking;
	# for scripts and guards -- servers should host, not block).
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

	# -- Interop: the industry formats ----------------------------

	# The Prometheus /metrics exposition text, every metric.
	def Prometheus()
		_cOut_ = ""
		_nLen_ = ring_len(@aMetrics)
		for _i_ = 1 to _nLen_
			_cOut_ += @aMetrics[_i_][2].PromText()
		next
		return _cOut_

	# One OTLP resourceMetrics envelope batching every metric.
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

	# -- Legibility -----------------------------------------------

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

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

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
