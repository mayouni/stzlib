/*
	Softanza trace context -- gap-analysis Tier 2 (observability).

	W3C Trace Context (`traceparent`) for correlating a request as it
	hops across services / agentic steps. Backed by engine/src/tracectx.zig
	(stz_tracectx.dll). Pure value type -- no I/O.

		oT = new stzTraceContext              # fresh sampled context
		? oT.TraceParent()                    # the header value
		? oT.TraceId()                        # 32-hex trace id

		# propagate to a downstream call (new span, same trace)
		oChild = StzTraceContextFrom(cIncomingHeader)
		cHeader = oChild.ChildHeader()

	stzHttpClient.SetTraceParent(cHeader) injects it as a request header.
*/

func StzTraceContext()
	return new stzTraceContext()

# Build a context object from an incoming traceparent header.
func StzTraceContextFrom(cHeader)
	oT = new stzTraceContext()
	oT.SetHeader(cHeader)
	return oT

# Carries a W3C traceparent so one request can be followed as it hops across services and agent steps.
#
# A new object holds a fresh sampled context. SetHeader loads the header of an incoming request, and
# ChildHeader builds the header to propagate to a downstream call: same trace id, new span id. It is
# a pure value type with no I/O; the engine does the parsing and the random ids. A header that is
# not well-formed makes IsValid answer FALSE rather than raise.
#
#   receiver   o1 = new stzTraceContext()
#              o1.SetHeader("00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
#   example    ? o1.TraceId()
#              #--> 0af7651916cd43dd8448eb211c80319c
#              ? o1.SpanId()
#              #--> b7ad6b7169203331
#              ? o1.IsSampled()
#              #--> 1
#              ? left(o1.ChildHeader(), 36)
#              #--> 00-0af7651916cd43dd8448eb211c80319c-
#   see        stzLatencyHistogram, stzEngineTimeline
class stzTraceContext from stzObject

	cTP = ""

	# Creates a fresh, sampled W3C trace context with a random trace id and span id.
	#
	#   returns    nothing; the object is built
	#   see        TraceParent, SetHeader
	def init()
		cTP = StzEngineTraceNew()

	# Replaces the context with one read from an incoming traceparent header.
	#
	#   cHeader    the traceparent header, such as
	#              '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01'
	#   returns    the context itself, so calls chain
	#   warning    a header that is not well-formed is stored as given: IsValid then answers FALSE
	#              and the ids and the child header are empty
	#   see        IsValid, TraceId
	#@ aka  Adopt an incoming header instead of a freshly generated one.
	def SetHeader(cHeader)
		cTP = cHeader
		return This

	# Returns the traceparent header the context holds, ready to send on a request.
	#
	#   returns    a text
	#   see        SetHeader, ChildHeader
	def TraceParent()
		return cTP

	# TRUE if the held header is a well-formed traceparent.
	#
	#   returns    TRUE or FALSE
	#   see        SetHeader
	def IsValid()
		return StzEngineTraceIsValid(cTP) = 1

	# Returns the 32-character hexadecimal trace id, shared by every hop of one request.
	#
	#   returns    a text; empty when the header is invalid
	#   see        SpanId, ChildHeader
	def TraceId()
		return StzEngineTraceId(cTP)

	# Returns the 16-character hexadecimal span id of this hop.
	#
	#   returns    a text; empty when the header is invalid
	#   see        TraceId, ChildHeader
	def SpanId()
		return StzEngineTraceSpanId(cTP)

	# TRUE if the sampled flag of the header is set, which asks every service to record the trace.
	#
	#   returns    TRUE or FALSE
	#   warning    an invalid header answers FALSE
	#   see        TraceParent
	def IsSampled()
		return StzEngineTraceSampled(cTP) = 1

	# Returns a traceparent for a downstream call: the same trace id and sampled flag, with a new random span id.
	#
	#   returns    a text; empty when the header is invalid
	#   warning    every call returns a different span id
	#   see        TraceId, SpanId
	#@ aka  A child header for an outbound call: same trace-id, new span-id.
	def ChildHeader()
		return StzEngineTraceChild(cTP)
