/*
	Softanza latency histogram -- gap-analysis Tier 1 item 6.

	Wraps the engine histogram (engine/src/histogram.zig,
	stz_histogram.dll): log-scale buckets for request / job latency, with
	O(1) memory and record cost. Percentile queries return the upper
	bound (ms) of the bucket the percentile falls in.

		_oH_ = new stzLatencyHistogram
		_oH_.Record(12.5)        # ms
		_oH_.Record(48)
		? _oH_.P50()             # median bucket upper bound
		? _oH_.P99()
		? _oH_.Count()
		_oH_.Reset()
		_oH_.Destroy()
*/

func StzLatencyHistogram()
	return new stzLatencyHistogram

class stzLatencyHistogram from stzObject

	pHandle = NULL
	_bReady_  = FALSE

	def init()
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring); guarded by a plain boolean.
	def _Ensure()
		if _bReady_ = FALSE
			pHandle = StzEngineHistogramCreate()
			_bReady_ = TRUE
		ok

	def Handle()
		This._Ensure()
		return pHandle

	# Tally one latency sample, in milliseconds.
	def Record(nMs)
		This._Ensure()
		StzEngineHistogramRecord(pHandle, nMs)
		return This

	# Upper bound (ms) of the bucket holding percentile nP (0..100).
	def Percentile(nP)
		This._Ensure()
		return StzEngineHistogramPercentile(pHandle, nP)

	def P50()
		return This.Percentile(50)

	def P95()
		return This.Percentile(95)

	def P99()
		return This.Percentile(99)

	def Count()
		This._Ensure()
		return StzEngineHistogramCount(pHandle)

	def Reset()
		This._Ensure()
		StzEngineHistogramReset(pHandle)
		return This

	def Destroy()
		if _bReady_ = TRUE
			StzEngineHistogramDestroy(pHandle)
			pHandle = NULL
			_bReady_ = FALSE
		ok
		return This
