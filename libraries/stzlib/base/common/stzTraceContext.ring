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

class stzTraceContext

	cTP = ""

	def init()
		cTP = StzEngineTraceNew()

	# Adopt an incoming header instead of a freshly generated one.
	def SetHeader(cHeader)
		cTP = cHeader
		return This

	def TraceParent()
		return cTP

	def IsValid()
		return StzEngineTraceIsValid(cTP) = 1

	def TraceId()
		return StzEngineTraceId(cTP)

	def SpanId()
		return StzEngineTraceSpanId(cTP)

	def IsSampled()
		return StzEngineTraceSampled(cTP) = 1

	# A child header for an outbound call: same trace-id, new span-id.
	def ChildHeader()
		return StzEngineTraceChild(cTP)
