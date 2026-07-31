/*
	The trace scope -- log-trace correlation (perf P9).

	One process-global slot holds the ACTIVE W3C traceparent. Open a
	scope and everything that logs inside it -- any stzLog, in any
	object, on any Ring face -- stamps its records with the trace id
	automatically; close it and logging is anonymous again. The
	observed server opens a scope around every request, so a
	handler's log lines correlate with the request's trace for free:

		StzOpenTraceScope("")            # "" -> a fresh trace
		oLog.Info("charging the card")   # carries traceId=...
		StzCloseTraceScope()

	Inside a scope, a downstream call propagates the SAME trace by
	sending StzCurrentTraceParent() as its traceparent header; the
	whole story -- request span, downstream spans, log lines --
	reassembles under one trace id in any backend.

	Engine-global by design (perf.zig trace scope): a Ring-side
	"current trace" would be per-face state, and the handler's log
	would never see the server's scope.
*/

# Open a trace scope. Pass an existing traceparent to JOIN that trace
# (a request's incoming header, a parent stopwatch's TraceParent());
# pass "" for a fresh one. Returns the traceparent now in effect.
func StzOpenTraceScope(pcTraceParent)
	_cTP_ = "" + pcTraceParent
	if _cTP_ = "" or StzEngineTraceIsValid(_cTP_) != 1
		_cTP_ = StzEngineTraceNew()
	ok
	StzEnginePerfTraceScopeSet(_cTP_)
	return _cTP_

func StzCloseTraceScope()
	StzEnginePerfTraceScopeClear()

# The active traceparent ("" when no scope) -- send it downstream.
func StzCurrentTraceParent()
	return StzEnginePerfTraceScopeGet()

# The active 32-hex trace id ("" when no scope) -- what logs stamp.
func StzCurrentTraceId()
	_cTP_ = StzEnginePerfTraceScopeGet()
	if _cTP_ = ""
		return ""
	ok
	return StzEngineTraceId(_cTP_)

func StzInTraceScope()
	return StzEnginePerfTraceScopeGet() != ""
