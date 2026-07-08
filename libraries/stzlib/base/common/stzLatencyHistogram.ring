/*
	Softanza latency histogram -- gap-analysis Tier 1 item 6.

	Wraps the engine histogram (engine/src/histogram.zig,
	stz_histogram.dll): log-scale buckets for request / job latency, with
	O(1) memory and record cost. Percentile queries return the upper
	bound (ms) of the bucket the percentile falls in.

		oH = new stzLatencyHistogram
		oH.Record(12.5)        # ms
		oH.Record(48)
		? oH.P50()             # median bucket upper bound
		? oH.P99()
		? oH.Count()
		oH.Reset()
		oH.Destroy()
*/

func StzLatencyHistogram()
	return new stzLatencyHistogram

class stzLatencyHistogram from stzObject

	pHandle = NULL
	bReady  = FALSE

	def init()
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring); guarded by a plain boolean.
	def _Ensure()
		if bReady = FALSE
			pHandle = StzEngineHistogramCreate()
			bReady = TRUE
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
		if bReady = TRUE
			StzEngineHistogramDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
		ok
		return This
