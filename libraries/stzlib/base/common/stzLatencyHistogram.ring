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

# Tallies latency samples in an engine histogram and reads percentiles from it, such as the median and the 99th.
#
# Record samples in milliseconds, then ask for P50, P95, P99 or any Percentile. The histogram is
# bucketed: a percentile is answered as the upper bound of the bucket it falls in, so it is an
# approximation and never an interpolated value. Count and Sum are exact.
#
#   receiver   o1 = new stzLatencyHistogram() o1.Record(10) o1.Record(20) o1.Record(30)
#              o1.Record(40) o1.Record(200)
#   example    ? o1.Count()
#              #--> 5
#              ? o1.Sum()
#              #--> 300
#              ? o1.P99()
#              #--> 200
#   see        stzRateLimiter, stzEngineTimeline
class stzLatencyHistogram from stzObject

	pHandle = ""
	bReady  = 0
	bAdopted = 0	# handle owned elsewhere (a perf family child)

	# Creates the engine histogram that will tally latency samples, in milliseconds.
	#
	#   returns    nothing; the object is built
	#   see        Record, Destroy
	def init()
		This._Ensure()

	# Lazy handle creation -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring); guarded by a plain boolean.
	def _Ensure()
		if bReady = 0
			pHandle = StzEngineHistogramCreate()
			bReady = 1
		ok

	# Returns the engine handle of the histogram, to share it with another object through AdoptHandle.
	#
	#   returns    a pointer
	#   see        AdoptHandle
	def Handle()
		This._Ensure()
		return pHandle

	# Makes this object read and write an engine histogram owned elsewhere, and frees the one it created itself.
	#
	#   pEngineHandle   the handle of an engine histogram, such as the one Handle returns
	#   returns         nothing
	#   note            checked with two objects: a sample recorded on the owner showed in the
	#                   adopter's Count
	#   warning         the adopted histogram is shared: after adoption the two objects count the
	#                   same samples, and Destroy on the adopter does not free it
	#   see             Handle, Destroy
	#@ aka  Adopt an engine histogram OWNED ELSEWHERE (a perf metric family's child): frees any self-created handle; Destroy() will not free an adopted one -- the owner does.
	def AdoptHandle(pEngineHandle)
		if bReady and NOT bAdopted
			StzEngineHistogramDestroy(pHandle)
		ok
		pHandle = pEngineHandle
		bReady = 1
		bAdopted = 1
		return This

	# Tallies one latency sample, in milliseconds.
	#
	#   nMs        the latency to tally, in milliseconds
	#   returns    the histogram itself, so calls chain
	#   warning    a negative number or a text raises no error and is not checked here
	#   see        Count, Percentile
	#@ aka  Tally one latency sample, in milliseconds.
	def Record(nMs)
		This._Ensure()
		StzEngineHistogramRecord(pHandle, nMs)
		return This

	# Returns the upper bound of the bucket in which a percentile of the samples falls, so the answer is approximate.
	#
	#   nP         the percentile to read, from 0 to 100
	#   returns    a number
	#   note       0 when no sample has been recorded
	#   warning    the answer is a bucket bound, not a recorded sample: the median of 1 to 100 reads
	#              50 and the 95th percentile reads 100
	#   see        P50, P95, P99
	#@ aka  Upper bound (ms) of the bucket holding percentile nP (0..100).
	def Percentile(nP)
		This._Ensure()
		return StzEngineHistogramPercentile(pHandle, nP)

	# Returns the median latency, as the upper bound of its bucket.
	#
	#   returns    a number
	#   see        Percentile, P95
	def P50()
		return This.Percentile(50)

	# Returns the latency under which 95 percent of the samples fall, as the upper bound of its bucket.
	#
	#   returns    a number
	#   see        Percentile, P99
	def P95()
		return This.Percentile(95)

	# Returns the latency under which 99 percent of the samples fall, as the upper bound of its bucket.
	#
	#   returns    a number
	#   see        Percentile, P95
	def P99()
		return This.Percentile(99)

	# Returns how many samples were recorded.
	#
	#   returns    a number
	#   see        Sum, Reset
	def Count()
		This._Ensure()
		return StzEngineHistogramCount(pHandle)

	# Returns the total of all recorded samples, in milliseconds.
	#
	#   returns    a number
	#   see        Count
	#@ aka  Exact running sum of every recorded value (the buckets quantize, the sum does not) -- lifetime mean = Sum()/Count().
	def Sum()
		This._Ensure()
		return StzEngineHistogramSum(pHandle)

	# Forgets every sample and keeps the histogram usable.
	#
	#   returns    the histogram itself, so calls chain
	#   see        Count, Destroy
	def Reset()
		This._Ensure()
		StzEngineHistogramReset(pHandle)
		return This

	# Frees the engine histogram, unless it was adopted from another owner, and marks the object unusable.
	#
	#   returns    the histogram itself, so calls chain
	#   warning    a later call builds a fresh, empty histogram
	#   see        AdoptHandle
	def Destroy()
		if bReady = 1
			if NOT bAdopted
				StzEngineHistogramDestroy(pHandle)
			ok
			pHandle = ""
			bReady = 0
			bAdopted = 0
		ok
		return This
