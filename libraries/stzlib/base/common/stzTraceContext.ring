/*
	Softanza trace context -- gap-analysis Tier 2 (observability).

	W3C Trace Context (`traceparent`) for correlating a request as it
	hops across services / agentic steps. Backed by engine/src/tracectx.zig
	(stz_tracectx.dll). Pure value type -- no I/O.

		_oT_ = new stzTraceContext              # fresh sampled context
		? _oT_.TraceParent()                    # the header value
		? _oT_.TraceId()                        # 32-hex trace id

		# propagate to a downstream call (new span, same trace)
		_oChild_ = StzTraceContextFrom(cIncomingHeader)
		_cHeader_ = _oChild_.ChildHeader()

	stzHttpClient.SetTraceParent(_cHeader_) injects it as a request header.
*/

func StzTraceContext()
	return new stzTraceContext()

# Build a context object from an incoming traceparent header.
func StzTraceContextFrom(_cHeader_)
	_oT_ = new stzTraceContext()
	_oT_.SetHeader(_cHeader_)
	return _oT_

class stzTraceContext from stzObject

	_cTP_ = ""

	def init()
		_cTP_ = StzEngineTraceNew()

	# Adopt an incoming header instead of a freshly generated one.
	def SetHeader(_cHeader_)
		_cTP_ = _cHeader_
		return This

	def TraceParent()
		return _cTP_

	def IsValid()
		return StzEngineTraceIsValid(_cTP_) = 1

	def TraceId()
		return StzEngineTraceId(_cTP_)

	def SpanId()
		return StzEngineTraceSpanId(_cTP_)

	def IsSampled()
		return StzEngineTraceSampled(_cTP_) = 1

	# A child header for an outbound call: same trace-id, new span-id.
	def ChildHeader()
		return StzEngineTraceChild(_cTP_)
