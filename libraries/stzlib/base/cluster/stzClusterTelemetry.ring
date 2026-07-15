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

func StzClusterTelemetry(pcName)
	return new stzClusterTelemetry(pcName)

class stzClusterTelemetry from stzObject

	@cName = ""
	@aHist = []          # [ [ facetTag, stzLatencyHistogram ], ... ] (engine-backed)
	@aTraces = []        # bounded ring: [ id, facet, endpoint, status, durMs, attempts ]
	@nMaxTraces = 512    # keep the most recent N request records
	@nSeq = 0            # monotonic trace counter
	@cBase = ""          # clock-derived prefix -> ids unique across instances

	def init(pcName)
		@cName = "" + pcName
		@aHist = []
		@aTraces = []
		@cBase = "" + StzEngineTimeNowMs()

	def Name_()
		return @cName

	#-- trace ids ----------------------------------------------------------

	# A fresh, monotonic, URL-safe id: "t-<clockbase>-<seq>". Unique within
	# this recorder; the clock base keeps two recorders from colliding.
	def NewTraceId()
		@nSeq++
		return "t-" + @cBase + "-" + @nSeq

	#-- recording ----------------------------------------------------------

	# Record one COMPLETED request: its trace id, the facet, the endpoint
	# that served it (or "none"), the final HTTP status, the end-to-end
	# latency in ms, and how many workers were attempted (>1 = failover).
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

	#-- latency percentiles (per facet) ------------------------------------

	# Upper-bound (ms) of the bucket holding percentile nP for a facet's
	# request latency. 0 when the facet has no samples yet.
	def LatencyPercentile(pcFacet, nP)
		_i_ = This._HistIndex(StzLower("" + pcFacet))
		if _i_ = 0  return 0  ok
		return @aHist[_i_][2].Percentile(nP)

	def LatencyP50(pcFacet)
		return This.LatencyPercentile(pcFacet, 50)
	def LatencyP90(pcFacet)
		return This.LatencyPercentile(pcFacet, 90)
	def LatencyP95(pcFacet)
		return This.LatencyPercentile(pcFacet, 95)
	def LatencyP99(pcFacet)
		return This.LatencyPercentile(pcFacet, 99)

	def LatencyCount(pcFacet)
		_i_ = This._HistIndex(StzLower("" + pcFacet))
		if _i_ = 0  return 0  ok
		return @aHist[_i_][2].Count()

	# A one-shot snapshot the health console reads.
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

	# The facets that have received at least one sample.
	def Facets()
		_a_ = []
		_n_ = len(@aHist)
		for _i_ = 1 to _n_
			_a_ + @aHist[_i_][1]
		next
		return _a_

	#-- trace lookups ------------------------------------------------------

	def NumberOfTraces()
		return len(@aTraces)

	# The last n request records (most recent last), as
	# [ id, facet, endpoint, status, durMs, attempts ] rows.
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

	def LastTrace()
		if len(@aTraces) = 0  return []  ok
		return @aTraces[len(@aTraces)]

	# The record for a given trace id (the most recent if reused), or [].
	def TraceById(pcId)
		_c_ = "" + pcId
		_n_ = len(@aTraces)
		for _i_ = _n_ to 1 step -1
			if @aTraces[_i_][1] = _c_  return @aTraces[_i_]  ok
		next
		return []

	# The trace ids whose request failed OVER (attempts > 1) -- the visible
	# footprint of the circuit breaker / retry path.
	def FailoverTraces()
		_a_ = []
		_n_ = len(@aTraces)
		for _i_ = 1 to _n_
			if @aTraces[_i_][6] > 1  _a_ + @aTraces[_i_]  ok
		next
		return _a_

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

	#-- teardown (engine histograms hold native handles) -------------------

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
