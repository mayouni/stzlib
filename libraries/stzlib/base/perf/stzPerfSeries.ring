/*
	stzPerfSeries -- the engine-resident metric series (perf P1).

	A bounded (time, value) ring buffer that LIVES IN THE ENGINE
	(engine/src/perf.zig, stz_perf.dll): recording is O(1), memory is
	fixed at creation, and the handle survives Ring's copy-on-assign
	-- so a monitor left running for a month costs the same memory as
	one left running for an hour, and no sweep of samples ever crosses
	the bridge (analysis questions cross; answers come back as one
	number each).

	This is the storage stratum of the performance system
	(SOFTANZA_PERF_SYSTEM.md section 6): P2's stzMetric builds its
	counter/gauge/timer faces on it.

		s = StzPerfSeries(1024)          # capacity, samples
		s.Record(nRssBytes)              # stamped with the monotonic clock
		s.RecordAt(nMyClockMs, nValue)   # or bring your own clock
		? s.Last()
		? s.Mean()
		? s.Percentile(95)               # exact, over the retained window
		? s.SlopePerMs()                 # the leak/trend detector
		s.Destroy()                      # engine handle -- free it

	Honesty notes: past capacity the OLDEST samples are overwritten
	(Count() = ever recorded, Size() = retained); statistics answer
	over the RETAINED window only; Percentile() is exact (copy+sort
	engine-side), unlike the bucketed stzLatencyHistogram -- pick the
	histogram for unbounded streams, the series for windowed gauges.
*/

func StzPerfSeries(pnCapacity)
	return new stzPerfSeries(pnCapacity)

class stzPerfSeries from stzObject

	pHandle = ""
	bReady = 0
	bAdopted = 0	# handle owned elsewhere (a family child)
	@nCapacity = 0

	def init(pnCapacity)
		if isNumber(pnCapacity) and pnCapacity >= 1
			@nCapacity = pnCapacity
		else
			@nCapacity = 1024
		ok
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran
	# (paren-less `new` skips init in Ring).
	def _Ensure()
		if bReady = 0
			if @nCapacity < 1
				@nCapacity = 1024
			ok
			pHandle = StzEnginePerfSeriesCreate(@nCapacity)
			bReady = 1
		ok

	def Handle()
		This._Ensure()
		return pHandle

	# Adopt an engine series OWNED ELSEWHERE (a metric family's child,
	# perf P8): frees any self-created handle, then reads/writes the
	# adopted one. Destroy() will NOT free an adopted handle -- the
	# owner (the family) frees it.
	def AdoptHandle(pEngineHandle)
		if bReady and NOT bAdopted
			StzEnginePerfSeriesDestroy(pHandle)
		ok
		pHandle = pEngineHandle
		bReady = 1
		bAdopted = 1
		return This

	def Capacity()
		This._Ensure()
		return @nCapacity

	# Record a value stamped with the engine's MONOTONIC watch clock
	# (ms since module load) -- the right default for rate/slope math.
	def Record(nValue)
		This._Ensure()
		StzEnginePerfSeriesRecord(pHandle, StzEngineWatchTimestampMs(), nValue)
		return This

	# Record against a caller-supplied clock (ms). The scope is named
	# at the call site: you brought the clock, you own its semantics.
	def RecordAt(nTimeMs, nValue)
		This._Ensure()
		StzEnginePerfSeriesRecord(pHandle, nTimeMs, nValue)
		return This

	# Samples ever recorded (keeps counting past capacity).
	def Count()
		This._Ensure()
		return StzEnginePerfSeriesCount(pHandle)

	# Samples retained in the window (never exceeds Capacity()).
	def Size()
		This._Ensure()
		return StzEnginePerfSeriesSize(pHandle)

	def Last()
		This._Ensure()
		return StzEnginePerfSeriesLast(pHandle)

	def Min()
		This._Ensure()
		return StzEnginePerfSeriesMin(pHandle)

	def Max()
		This._Ensure()
		return StzEnginePerfSeriesMax(pHandle)

	def Mean()
		This._Ensure()
		return StzEnginePerfSeriesMean(pHandle)

	# Least-squares slope of value over time, per ms of the series'
	# clock: ~0 = stable, positive = growing (the leak detector).
	def SlopePerMs()
		This._Ensure()
		return StzEnginePerfSeriesSlopePerMs(pHandle)

	# Exact nearest-rank percentile over the retained window.
	def Percentile(nP)
		This._Ensure()
		return StzEnginePerfSeriesPercentile(pHandle, nP)

	def P50()
		return This.Percentile(50)

	def P95()
		return This.Percentile(95)

	def P99()
		return This.Percentile(99)

	# 1-based, oldest first, over the retained window.
	def TimeAt(n)
		This._Ensure()
		return StzEnginePerfSeriesTimeAt(pHandle, n)

	def ValueAt(n)
		This._Ensure()
		return StzEnginePerfSeriesValueAt(pHandle, n)

	# The retained window as Ring lists (crosses the bridge per item --
	# for display and small windows, not hot paths).
	def Values()
		This._Ensure()
		_aRes_ = []
		_nLen_ = This.Size()
		for _i_ = 1 to _nLen_
			_aRes_ + StzEnginePerfSeriesValueAt(pHandle, _i_)
		next
		return _aRes_

	def Times()
		This._Ensure()
		_aRes_ = []
		_nLen_ = This.Size()
		for _i_ = 1 to _nLen_
			_aRes_ + StzEnginePerfSeriesTimeAt(pHandle, _i_)
		next
		return _aRes_

	def Reset()
		This._Ensure()
		StzEnginePerfSeriesReset(pHandle)
		return This

	def Destroy()
		if bReady = 1
			if NOT bAdopted
				StzEnginePerfSeriesDestroy(pHandle)
			ok
			pHandle = ""
			bReady = 0
			bAdopted = 0
		ok
		return This
