# base/cluster/stzClusterTelemetry.ring
# -----------------------------------------------------------------------------
# R8.1 RESILIENCE (observability rung) -- stzClusterTelemetry: the fleet's
# OBSERVABILITY surface. (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 7.1.)
#
# Once workers can fail and fail over, you must be able to SEE it. Two
# industry-standard signals:
#
#   LATENCY PERCENTILES -- per facet, the p50/p90/p95/p99 request latency.
#     The tail (p99) is where circuit-breaker trips and failovers surface as
#     slow requests, invisible to an average. Backed by the engine's O(1)
#     log-scale histogram (stzLatencyHistogram / stz_histogram.dll), one per
#     facet -- so a heavy vision facet's tail never smears a light nlp one.
#
#   TRACE IDS -- every routed request gets a unique id, recorded with its
#     facet, the endpoint that served it, final status, total latency and
#     the number of attempts (>1 = a failover happened). The id is also put
#     ON THE WIRE (a _trace query param) so a worker sees the same id the
#     front host recorded -- request correlation across the fleet.
#
#   oT = new stzClusterTelemetry("acme")
#   cId = oT.NewTraceId()
#   oT.RecordRequest(cId, "nlp", "127.0.0.1:47001", 200, 12, 1)
#   ? oT.LatencyP99("nlp")     # tail latency bucket (ms) for the nlp facet
#   ? oT.RecentTraces(5)       # the last five request records
#
# It is a plain recorder (no reactor, no governance) -- the cluster owns one
# and feeds it from Route; pipelines/federation can feed the same shape.
# -----------------------------------------------------------------------------

func StzClusterTelemetryQ(pcName)
	return new stzClusterTelemetry(pcName)

# Records the requests a cluster routes: a bounded list of traces, and a latency histogram per facet for p50 to p99.
#
# Each routed request gets a trace id from NewTraceId and is recorded with RecordRequest: facet,
# endpoint, status, duration and attempts (more than one means a failover happened). Percentiles
# come from the engine histogram, one per facet, so a heavy facet's tail does not smear a light one;
# they are bucket bounds, not exact values. The recorder keeps the latest 512 traces. It is a plain
# recorder: no reactor, no process.
#
#   receiver   o1 = new stzClusterTelemetry("front") o1.RecordRequest("r1", "nlp",
#              "127.0.0.1:47001", 200, 12, 1) o1.RecordRequest("r2", "nlp", "127.0.0.1:47002", 200,
#              40, 2)
#   example    ? o1.LatencyCount("nlp")
#              #--> 2
#              ? o1.LatencyP99("nlp")
#              #--> 50
#              ? @@( o1.LastTrace() )
#              #--> [ "r2", "nlp", "127.0.0.1:47002", 200, 40, 2 ]
#              ? len(o1.FailoverTraces())
#              #--> 1
#   see        stzLatencyHistogram, stzClusterSupervisor, stzTraceContext
class stzClusterTelemetry from stzObject

	@cName = ""
	@aHist = []          # [ [ facetTag, stzLatencyHistogram ], ... ] (engine-backed)
	@aTraces = []        # bounded ring: [ id, facet, endpoint, status, durMs, attempts ]
	@nMaxTraces = 512    # keep the most recent N request records
	@nSeq = 0            # monotonic trace counter
	@cBase = ""          # clock-derived prefix -> ids unique across instances

	# Creates an empty recorder of request traces and per-facet latency histograms for a cluster, under a name.
	#
	#   pcName     the recorder's name, shown in Narrate
	#   returns    nothing; the object is built
	#   see        RecordRequest, NewTraceId
	def init(pcName)
		@cName = "" + pcName
		@aHist = []
		@aTraces = []
		@cBase = "" + StzEngineTimeNowMs()

	# Returns the recorder's name.
	#
	#   returns    a text
	#   see        init
	def Name_()
		return @cName

	# Returns a fresh trace id of the form t-<start time in ms>-<sequence number>, unique within this recorder.
	#
	#   returns    a text
	#   warning    the part after t- starts from the wall clock when the recorder is created, so the
	#              full id differs between runs
	#   see        RecordRequest, TraceById
	#@ aka  -- trace ids ----------------------------------------------------------
	def NewTraceId()
		@nSeq++
		return "t-" + @cBase + "-" + @nSeq

	# Records one routed request as a trace and, if it was attempted at least once, adds its duration to the histogram of its facet.
	#
	#   pcId         the trace id of the request
	#   pcFacet      the facet that served it, matched without regard to case
	#   pcEndpoint   the endpoint that answered
	#   pnStatus     the final status
	#   pnDurMs      the total duration in milliseconds
	#   pnAttempts   how many endpoints were tried, more than 1 meaning a failover
	#   returns      nothing
	#   warning      a request with 0 attempts is kept as a trace but adds nothing to the latency
	#                histogram; only the latest 512 traces are kept, older ones are dropped
	#   see          RecentTraces, FailoverTraces
	#@ aka  -- recording ----------------------------------------------------------
	def RecordRequest(pcId, pcFacet, pcEndpoint, pnStatus, pnDurMs, pnAttempts)
		_cTag_ = StzLower("" + pcFacet)
		# feed the LATENCY histogram only for requests that made a real
		# round-trip (attempts > 0). An instant "no routable worker" reject
		# is 0ms with no network -- counting it would deflate the tail and
		# make a facet look faster than it is. It is still recorded as a
		# trace (a decline is a signal), just not a latency sample.
		if pnAttempts > 0
			This._HistFor(_cTag_).Record(pnDurMs)
		ok
		@aTraces + [ "" + pcId, _cTag_, "" + pcEndpoint, pnStatus, pnDurMs, pnAttempts ]
		if len(@aTraces) > @nMaxTraces
			del(@aTraces, 1)         # evict the oldest (bounded ring)
		ok
		return This

	# Returns the latency, in milliseconds, under which a percentile of a facet's requests fall, as the upper bound of a histogram bucket.
	#
	#   pcFacet    the facet, matched without regard to case
	#   nP         the percentile, from 0 to 100
	#   returns    a number; 0 for a facet never recorded
	#   warning    approximate: two requests of 12 and 40 ms read p50 as 20 and p99 as 50
	#   see        LatencyP99, LatencyStats
	#@ aka  -- latency percentiles (per facet) ------------------------------------
	def LatencyPercentile(pcFacet, nP)
		_i_ = This._HistIndex(StzLower("" + pcFacet))
		if _i_ = 0  return 0  ok
		return @aHist[_i_][2].Percentile(nP)

	# Returns the median latency of a facet, in milliseconds, as a bucket bound.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a number
	#   see        LatencyPercentile, LatencyP99
	def LatencyP50(pcFacet)
		return This.LatencyPercentile(pcFacet, 50)
	# Returns the latency under which 90 percent of a facet's requests fall, as a bucket bound.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a number
	#   see        LatencyPercentile, LatencyP99
	def LatencyP90(pcFacet)
		return This.LatencyPercentile(pcFacet, 90)
	# Returns the latency under which 95 percent of a facet's requests fall, as a bucket bound.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a number
	#   see        LatencyPercentile, LatencyP99
	def LatencyP95(pcFacet)
		return This.LatencyPercentile(pcFacet, 95)
	# Returns the tail latency of a facet, the one under which 99 percent of its requests fall, as a bucket bound.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a number
	#   see        LatencyPercentile, LatencyP50
	def LatencyP99(pcFacet)
		return This.LatencyPercentile(pcFacet, 99)

	# Returns how many requests were added to a facet's histogram; 0 for a facet never recorded.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a number
	#   see        LatencyStats
	def LatencyCount(pcFacet)
		_i_ = This._HistIndex(StzLower("" + pcFacet))
		if _i_ = 0  return 0  ok
		return @aHist[_i_][2].Count()

	# Returns a facet's figures in one hashlist: facet, count, p50, p90, p95 and p99.
	#
	#   pcFacet    the facet, matched without regard to case
	#   returns    a hashlist
	#   warning    a facet never recorded gives the same keys with 0 in every figure
	#   see        LatencyPercentile, LatencyCount
	#@ aka  A one-shot snapshot the health console reads.
	def LatencyStats(pcFacet)
		_cT_ = StzLower("" + pcFacet)
		return [
			:facet = _cT_,
			:count = This.LatencyCount(_cT_),
			:p50 = This.LatencyPercentile(_cT_, 50),
			:p90 = This.LatencyPercentile(_cT_, 90),
			:p95 = This.LatencyPercentile(_cT_, 95),
			:p99 = This.LatencyPercentile(_cT_, 99)
		]

	# Returns the facets that have a histogram, lower-cased, in the order they first appeared.
	#
	#   returns    a list of texts
	#   see        LatencyStats
	#@ aka  The facets that have received at least one sample.
	def Facets()
		_a_ = []
		_n_ = len(@aHist)
		for _i_ = 1 to _n_
			_a_ + @aHist[_i_][1]
		next
		return _a_

	# Returns how many traces are held, at most 512.
	#
	#   returns    a number
	#   see        RecentTraces
	#@ aka  -- trace lookups ------------------------------------------------------
	def NumberOfTraces()
		return len(@aTraces)

	# Returns the n latest traces, oldest first; each is [ id, facet, endpoint, status, duration, attempts ].
	#
	#   n          how many traces to return
	#   returns    a list of lists; empty when n is below 1 or nothing was recorded
	#   see        LastTrace, TraceById
	#@ aka  The last n request records (most recent last), as [ id, facet, endpoint, status, durMs, attempts ] rows.
	def RecentTraces(n)
		_nAll_ = len(@aTraces)
		if n < 1 or _nAll_ = 0  return []  ok
		_nFrom_ = _nAll_ - n + 1
		if _nFrom_ < 1  _nFrom_ = 1  ok
		_a_ = []
		for _i_ = _nFrom_ to _nAll_
			_a_ + @aTraces[_i_]
		next
		return _a_

	# Returns the most recent trace as [ id, facet, endpoint, status, duration, attempts ]; empty when there is none.
	#
	#   returns    a list
	#   see        RecentTraces
	def LastTrace()
		if len(@aTraces) = 0  return []  ok
		return @aTraces[len(@aTraces)]

	# Returns the latest trace recorded under an id, or an empty list when none matches.
	#
	#   pcId       the trace id to look for
	#   returns    a list
	#   see        NewTraceId, RecentTraces
	#@ aka  The record for a given trace id (the most recent if reused), or [].
	def TraceById(pcId)
		_c_ = "" + pcId
		_n_ = len(@aTraces)
		for _i_ = _n_ to 1 step -1
			if @aTraces[_i_][1] = _c_  return @aTraces[_i_]  ok
		next
		return []

	# Returns the traces of the requests that needed more than one attempt, oldest first.
	#
	#   returns    a list of lists
	#   see        RecordRequest
	#@ aka  The trace ids whose request failed OVER (attempts > 1) -- the visible footprint of the circuit breaker / retry path.
	def FailoverTraces()
		_a_ = []
		_n_ = len(@aTraces)
		for _i_ = 1 to _n_
			if @aTraces[_i_][6] > 1  _a_ + @aTraces[_i_]  ok
		next
		return _a_

	# Returns a short text that gives the trace count and, per facet, the p50, p99 and count.
	#
	#   returns    a text
	#   see        LatencyStats
	def Narrate()
		_cR_ = "telemetry " + @cName + ": " + len(@aTraces) + " trace(s), " +
			len(@aHist) + " facet histogram(s)"
		_n_ = len(@aHist)
		for _i_ = 1 to _n_
			_cT_ = @aHist[_i_][1]
			_cR_ += char(10) + "  " + _cT_ + " p50=" + This.LatencyPercentile(_cT_, 50) +
				"ms p99=" + This.LatencyPercentile(_cT_, 99) + "ms n=" +
				This.LatencyCount(_cT_)
		next
		return _cR_

	# Frees the engine histograms and forgets the facets; the traces stay.
	#
	#   returns    the recorder itself, so calls chain
	#   warning    NumberOfTraces and RecentTraces still answer after it
	#   see        init
	#@ aka  -- teardown (engine histograms hold native handles) -------------------
	def Destroy()
		_n_ = len(@aHist)
		for _i_ = 1 to _n_
			@aHist[_i_][2].Destroy()
		next
		@aHist = []
		return This

	#-- internals ----------------------------------------------------------

	def _HistIndex(pcTag)
		_n_ = len(@aHist)
		for _i_ = 1 to _n_
			if @aHist[_i_][1] = pcTag  return _i_  ok
		next
		return 0

	def _HistFor(pcTag)
		_i_ = This._HistIndex(pcTag)
		if _i_ > 0  return @aHist[_i_][2]  ok
		_oH_ = new stzLatencyHistogram()
		@aHist + [ pcTag, _oH_ ]
		# call THROUGH the stored slot (Ring aliasing: the local _oH_ is a
		# copy of the handle-carrying object; the list holds the live one)
		return @aHist[len(@aHist)][2]
