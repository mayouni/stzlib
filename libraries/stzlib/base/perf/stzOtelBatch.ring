/*
	stzOtelBatch -- the OTLP span batch (perf P7).

	P0 taught one stopwatch to export as ONE OpenTelemetry span; a
	real trace is many spans shipped together. The batch collects
	spans and renders the full OTLP `resourceSpans` envelope -- the
	exact JSON an OTLP/HTTP collector ingests at /v1/traces -- with
	the service identity stated once at the top, the way the
	monitor's OtelJson() already does for metrics:

		oB = StzOtelBatch("restolean")
		oB.AddSpan(w1)            # a stzStopwatch (stopped or running)
		oB.AddSpan(w2)
		oB.AddSpanJson(cJson)     # or a pre-rendered span fragment
		? oB.ToJson()             # {"resourceSpans":[ ... ]}

	Spans that JoinTrace()d one another arrive sharing a traceId, so
	a collector reassembles the tree. The batch holds rendered JSON
	fragments (strings -- copies are harmless); Clear() empties it
	for the next shipment.
*/

func StzOtelBatch(pcServiceName)
	return new stzOtelBatch(pcServiceName)

class stzOtelBatch from stzObject

	@cService = ""
	@aSpans = []		# rendered span JSON fragments

	def init(pcServiceName)
		@cService = "" + pcServiceName

	def ServiceName()
		return @cService

	def AddSpan(poStopwatch)
		@aSpans + poStopwatch.ToOtelJson()
		return This

	def AddSpanJson(pcSpanJson)
		@aSpans + ("" + pcSpanJson)
		return This

	def SpanCount()
		return ring_len(@aSpans)

	def Clear()
		@aSpans = []
		return This

	# The OTLP resourceSpans envelope, every collected span inside.
	def ToJson()
		_cSpans_ = ""
		_nLen_ = ring_len(@aSpans)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cSpans_ += ","
			ok
			_cSpans_ += @aSpans[_i_]
		next
		_cJ_ = '{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"'
		_cJ_ += @cService
		_cJ_ += '"}}]},"scopeSpans":[{"scope":{"name":"softanza.perf"},"spans":['
		_cJ_ += _cSpans_
		_cJ_ += ']}]}]}'
		return _cJ_
