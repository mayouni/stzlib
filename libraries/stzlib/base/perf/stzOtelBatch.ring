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

# Collects spans and writes them as the OpenTelemetry resourceSpans envelope that an OTLP collector takes at its traces endpoint.
#
# One stopwatch exports as one OTLP span; a real trace is many spans shipped together. The batch
# holds rendered JSON fragments, so copies of it are harmless, and writes the service identity once
# at the top, the way the performance monitor does for metrics. Spans that joined one another arrive
# sharing a traceId, so a collector reassembles the tree. Clear empties the batch for the next
# shipment. A service name that holds a double quote or a backslash is written unescaped today.
#
#   receiver   o1 = StzOtelBatch("restolean") o2 = new stzStopwatch("checkout") o2.Start() o2.Stop()
#              o1.AddSpan(o2) o1.AddSpanJson('{"name":"manual","kind":1}')
#   example    ? o1.ServiceName()
#              #--> restolean
#              ? o1.SpanCount()
#              #--> 2
#              ? left(o1.ToJson(), 17)
#              #--> {"resourceSpans":
#              ? right(o1.ToJson(), 15)
#              #--> "kind":1}]}]}]}
#              o1.Clear()
#              ? o1.SpanCount()
#              #--> 0
#   see        stzStopwatch, stzPerfMonitor, stzMetricFamily
class stzOtelBatch from stzObject

	@cService = ""
	@aSpans = []		# rendered span JSON fragments

	# Builds an empty span batch for a service name.
	#
	#   pcServiceName   the service name written once at the top of the envelope, as service.name
	#   returns         nothing; the object is built
	#   note            StzOtelBatch builds the same object
	#   warning         a name holding a double quote or a backslash is written into the JSON as it
	#                   is and makes ToJson invalid JSON, though span names are escaped
	#   see             AddSpan, ToJson
	def init(pcServiceName)
		@cService = "" + pcServiceName

	# Returns the service name the batch was built with.
	#
	#   returns    the name as text
	#   see        init, ToJson
	def ServiceName()
		return @cService

	# Renders a stopwatch as one OTLP span and adds it to the batch.
	#
	#   poStopwatch   a stzStopwatch, stopped or running
	#   returns       the batch itself, so calls chain
	#   note          the span is rendered when added, so later changes to the stopwatch do not
	#                 reach the batch; stopwatches that joined a trace share its traceId, so a
	#                 collector rebuilds the tree
	#   see           AddSpanJson, SpanCount
	def AddSpan(poStopwatch)
		@aSpans + poStopwatch.ToOtelJson()
		return This

	# Adds a span that is already rendered as a JSON object.
	#
	#   pcSpanJson   the JSON text of one span
	#   returns      the batch itself, so calls chain
	#   note         the text is placed in the envelope as given and is not checked
	#   see          AddSpan, ToJson
	def AddSpanJson(pcSpanJson)
		@aSpans + ("" + pcSpanJson)
		return This

	# Returns how many spans the batch holds.
	#
	#   returns    a number
	#   see        AddSpan, Clear
	def SpanCount()
		return ring_len(@aSpans)

	# Empties the batch for the next shipment.
	#
	#   returns    the batch itself, so calls chain
	#   note       the service name is kept
	#   see        SpanCount, ToJson
	def Clear()
		@aSpans = []
		return This

	# Returns the OTLP resourceSpans envelope with every collected span inside, ready for an OTLP collector's traces endpoint.
	#
	#   returns    a JSON text: the service identity once at the top, the scope softanza.perf, then
	#              the spans
	#   note       an empty batch gives the envelope with an empty list of spans; the spans keep the
	#              order they were added in
	#   see        AddSpan, Clear
	#@ aka  The OTLP resourceSpans envelope, every collected span inside.
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
