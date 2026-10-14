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

# Keeps the latest samples of a metric in a fixed-size window held by the engine, and answers statistics over it.
#
# Recording is constant-time and the memory is fixed at creation: a series left running for a month
# costs what one left for an hour does. Past its capacity the oldest samples are overwritten, so
# Count says how many were ever recorded and Size how many are kept; every statistic answers over
# the kept window only. Percentile is exact (nearest rank), unlike the bucketed latency histogram:
# choose the histogram for an unbounded stream and the series for a windowed gauge. SlopePerMs is
# the leak detector. Call Destroy when done, because the samples live in the engine.
#
#   receiver   o1 = new stzPerfSeries(4)
#   example    for i = 1 to 6 o1.RecordAt(i * 1000, i * 10) next
#              ? o1.Size()
#              #--> 4
#              ? o1.Count()
#              #--> 6
#              ? @@( o1.Values() )
#              #--> [ 30, 40, 50, 60 ]
#              ? o1.Percentile(50)
#              #--> 40
#              ? o1.SlopePerMs()
#              #--> 0.01
#   see        StzPerfSeries, stzPerfProfile, stzStopwatch
class stzPerfSeries from stzObject

	pHandle = ""
	bReady = 0
	bAdopted = 0	# handle owned elsewhere (a family child)
	@nCapacity = 0

	# Builds a series that keeps the latest samples of a metric in a fixed-size window held by the engine.
	#
	#   pnCapacity   how many samples the window retains
	#   returns      nothing; the object is built
	#   see          StzPerfSeries, Capacity
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

	# Returns the engine pointer that holds the samples, to share the series with other engine calls.
	#
	#   returns    a pointer
	#   see        AdoptHandle, Destroy
	def Handle()
		This._Ensure()
		return pHandle

	# Makes the series read and write a window owned elsewhere, freeing the one it made for itself.
	#
	#   pEngineHandle   the engine pointer of the series to adopt, for example the Handle of another
	#                   series
	#   returns         the series itself, so calls chain
	#   note            Destroy on the adopter leaves the owner's samples untouched
	#   warning         an adopted window is never freed by this object: freeing it stays with its
	#                   owner
	#   see             Handle, Destroy
	#@ aka  Adopt an engine series OWNED ELSEWHERE (a metric family's child, perf P8): frees any self-created handle, then reads/writes the adopted one. Destroy() will NOT free an adopted handle -- the owner (the family) frees it.
	def AdoptHandle(pEngineHandle)
		if bReady and NOT bAdopted
			StzEnginePerfSeriesDestroy(pHandle)
		ok
		pHandle = pEngineHandle
		bReady = 1
		bAdopted = 1
		return This

	# Returns how many samples the window can hold at most.
	#
	#   returns    a number
	#   see        Size, Count
	def Capacity()
		This._Ensure()
		return @nCapacity

	# Adds a value to the window, stamped with the engine's monotonic clock in milliseconds.
	#
	#   nValue     the number to record
	#   returns    the series itself, so calls chain
	#   see        RecordAt, Last
	#@ aka  Record a value stamped with the engine's MONOTONIC watch clock (ms since module load) -- the right default for rate/slope math.
	def Record(nValue)
		This._Ensure()
		StzEnginePerfSeriesRecord(pHandle, StzEngineWatchTimestampMs(), nValue)
		return This

	# Adds a value to the window against a time you supply, in milliseconds of your own clock.
	#
	#   nTimeMs    the time of the sample, in the unit of the clock you chose
	#   nValue     the number to record
	#   returns    the series itself, so calls chain
	#   see        Record, TimeAt
	#@ aka  Record against a caller-supplied clock (ms). The scope is named at the call site: you brought the clock, you own its semantics.
	def RecordAt(nTimeMs, nValue)
		This._Ensure()
		StzEnginePerfSeriesRecord(pHandle, nTimeMs, nValue)
		return This

	# Returns how many samples were ever recorded, including those the window has already overwritten.
	#
	#   returns    a number
	#   see        Size, Capacity
	#@ aka  Samples ever recorded (keeps counting past capacity).
	def Count()
		This._Ensure()
		return StzEnginePerfSeriesCount(pHandle)

	# Returns how many samples the window holds now, never more than its capacity.
	#
	#   returns    a number
	#   see        Count, Capacity
	#@ aka  Samples retained in the window (never exceeds Capacity()).
	def Size()
		This._Ensure()
		return StzEnginePerfSeriesSize(pHandle)

	# Returns the most recent value recorded.
	#
	#   returns    a number; 0 for an empty series
	#   see        Min, Max, ValueAt
	def Last()
		This._Ensure()
		return StzEnginePerfSeriesLast(pHandle)

	# Returns the smallest value in the window.
	#
	#   returns    a number; 0 for an empty series
	#   see        Max, Mean
	def Min()
		This._Ensure()
		return StzEnginePerfSeriesMin(pHandle)

	# Returns the largest value in the window.
	#
	#   returns    a number; 0 for an empty series
	#   see        Min, Mean
	def Max()
		This._Ensure()
		return StzEnginePerfSeriesMax(pHandle)

	# Returns the average of the values in the window.
	#
	#   returns    a number; 0 for an empty series
	#   see        Min, Max, Percentile
	def Mean()
		This._Ensure()
		return StzEnginePerfSeriesMean(pHandle)

	# Returns the least-squares slope of the values over time, per millisecond: near 0 is stable, positive is growing.
	#
	#   returns    a number; 0 for an empty series
	#   note       with a clock in milliseconds, a rise of 10 over 2000 ms is 0.005; use it to spot
	#              a leak
	#   see        Mean, Record
	#@ aka  Least-squares slope of value over time, per ms of the series' clock: ~0 = stable, positive = growing (the leak detector).
	def SlopePerMs()
		This._Ensure()
		return StzEnginePerfSeriesSlopePerMs(pHandle)

	# Returns the value at a rank, as the exact nearest-rank percentile over the window.
	#
	#   nP         the percentage from 0 to 100, such as 95
	#   returns    a number; 0 for an empty series
	#   note       0 gives the smallest value and 100 the largest
	#   see        P50, P95, P99
	#@ aka  Exact nearest-rank percentile over the retained window.
	def Percentile(nP)
		This._Ensure()
		return StzEnginePerfSeriesPercentile(pHandle, nP)

	# Returns the median value of the window.
	#
	#   returns    a number; 0 for an empty series
	#   see        Percentile, Mean
	def P50()
		return This.Percentile(50)

	# Returns the value under which 95 percent of the window lies.
	#
	#   returns    a number; 0 for an empty series
	#   see        Percentile, P99
	def P95()
		return This.Percentile(95)

	# Returns the value under which 99 percent of the window lies.
	#
	#   returns    a number; 0 for an empty series
	#   see        Percentile, P95
	def P99()
		return This.Percentile(99)

	# Returns the time of the nth sample in the window, oldest first.
	#
	#   n          the position in the window, from 1 for the oldest sample
	#   returns    a number; -1 when n is 0 or beyond the window
	#   see        ValueAt, Times
	#@ aka  1-based, oldest first, over the retained window.
	def TimeAt(n)
		This._Ensure()
		return StzEnginePerfSeriesTimeAt(pHandle, n)

	# Returns the value of the nth sample in the window, oldest first.
	#
	#   n          the position in the window, from 1 for the oldest sample
	#   returns    a number; -1 when n is 0 or beyond the window
	#   note       -1 is also a legal sample value: check Size before reading
	#   see        TimeAt, Values
	def ValueAt(n)
		This._Ensure()
		return StzEnginePerfSeriesValueAt(pHandle, n)

	# Returns the whole window as a list of numbers, oldest first.
	#
	#   returns    a list of numbers; empty for an empty series
	#   note       it crosses the engine bridge once per sample, so keep it for display and small
	#              windows
	#   see        Times, ValueAt
	#@ aka  The retained window as Ring lists (crosses the bridge per item -- for display and small windows, not hot paths).
	def Values()
		This._Ensure()
		_aRes_ = []
		_nLen_ = This.Size()
		for _i_ = 1 to _nLen_
			_aRes_ + StzEnginePerfSeriesValueAt(pHandle, _i_)
		next
		return _aRes_

	# Returns the times of the whole window as a list of numbers, oldest first.
	#
	#   returns    a list of numbers; empty for an empty series
	#   see        Values, TimeAt
	def Times()
		This._Ensure()
		_aRes_ = []
		_nLen_ = This.Size()
		for _i_ = 1 to _nLen_
			_aRes_ + StzEnginePerfSeriesTimeAt(pHandle, _i_)
		next
		return _aRes_

	# Empties the window and the count and keeps the capacity.
	#
	#   returns    the series itself, so calls chain
	#   see        Destroy, Size
	def Reset()
		This._Ensure()
		StzEnginePerfSeriesReset(pHandle)
		return This

	# Frees the engine memory of the series; any later call builds a fresh, empty window.
	#
	#   returns    the series itself, so calls chain
	#   see        Reset, AdoptHandle
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
