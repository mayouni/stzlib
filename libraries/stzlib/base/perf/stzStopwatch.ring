/*
	stzStopwatch -- the honest stopwatch (perf system, P0).

	The measuring primitive of the Softanza performance system
	(doc/design/SOFTANZA_PERF_SYSTEM.md). Three promises the older
	timing surfaces did not keep:

	1. NUMBERS, not sentences. ElapsedMs() returns 12.437 -- a value
	   you can compare, add, and assert on. (stzProfilingTimer's
	   StzElapsedTime() returns the string "0.123 second(s)".)

	2. A MONOTONIC engine clock. Readings come from the engine's
	   watch module (engine/src/watch.zig), which counts on a
	   std.time.Instant baseline captured at DLL load -- nanosecond
	   precision, immune to NTP wall-clock jumps. Ring's clock() is
	   neither. The clock in use is named in the verb: ElapsedMs()
	   is monotonic; the wall anchors used for serialization say
	   Wall in their names.

	3. UNLIMITED, INDEPENDENT instances. State lives in the object
	   (two engine-clock reads bound it), not in a shared slot table
	   -- so stopwatches never collide and there is nothing to free.

	Usage:

		w = StzStopwatch("checkout")     # starts on birth
		# ... work ...
		? w.ElapsedMs()                  #--> 12.437
		w.Lap("validated")               # split without stopping
		w.Pause()                        # excluded time starts
		w.Resume()                       # ...and ends
		w.Stop()                         # freeze; stamps the span end

	Interop (industry formats): a stopped stopwatch is exportable as
	an OpenTelemetry span -- real W3C trace/span ids (engine
	tracectx), laps as span events -- so a Softanza program can hand
	its timings to any OTLP-speaking backend:

		? w.ToOtelJson()                 # one OTLP-style span, JSON
		? w.TraceParent()                # W3C header for propagation

	Absolute anchors (startTimeUnixNano/endTimeUnixNano) carry ms
	resolution (Ring numbers are f64; epoch nanos overflow 2^53); the
	exact nanosecond duration rides in the stz.duration_ns attribute.
*/

func StzStopwatch()
	return new stzStopwatch("")

# The named variant (Ring functions take a fixed arity).
func StzStopwatchXT(pcName)
	return new stzStopwatch(pcName)

class stzStopwatch from stzObject

	@cName = ""
	@bStarted = 0
	@bRunning = 0
	@nStartMonoNs = 0	# engine monotonic ns at (re)start / resume
	@nAccumNs = 0		# ns accumulated over completed run stretches
	@nStartWallMs = 0	# wall anchor of the span start (serialization)
	@nStopWallMs = 0	# wall anchor of the span end (0 = still open)
	@aLaps = []
	@oTraceCtx = ""	# W3C trace context, created on first need

	def init(pcName)
		if isString(pcName)
			@cName = pcName
		ok
		This._Begin()

	# Lazy anchor -- robust whether or not init() ran (paren-less
	# `new` skips init in Ring), same guard as stzLatencyHistogram.
	def _Ensure()
		if @bStarted = 0
			This._Begin()
		ok

	def _Begin()
		@nStartMonoNs = StzEngineWatchTimestampNs()
		@nStartWallMs = StzEngineTimeWallMs()
		@nStopWallMs = 0
		@nAccumNs = 0
		@aLaps = []
		@bRunning = 1
		@bStarted = 1

	def Name()
		return @cName

	def SetName(pcName)
		if isString(pcName)
			@cName = pcName
		ok
		return This

	# -- The clock ------------------------------------------------

	# Start() restarts from zero (fresh span, fresh laps, fresh wall
	# anchor) -- the engine watch_start semantics. To continue after
	# a Pause()/Stop() without discarding, use Resume().
	def Start()
		This._Begin()
		return This

	def Pause()
		This._Ensure()
		if @bRunning
			@nAccumNs += (StzEngineWatchTimestampNs() - @nStartMonoNs)
			@bRunning = 0
		ok
		return This

	def Resume()
		This._Ensure()
		if NOT @bRunning
			@nStartMonoNs = StzEngineWatchTimestampNs()
			@nStopWallMs = 0
			@bRunning = 1
		ok
		return This

	# Stop() = Pause() + stamp the span's wall end, so the record /
	# OTel export has a closed [start, end] interval.
	def Stop()
		This.Pause()
		@nStopWallMs = StzEngineTimeWallMs()
		return This

	def Reset()
		This._Begin()
		This.Pause()
		@nAccumNs = 0
		return This

	def IsRunning()
		This._Ensure()
		return @bRunning

	# -- Elapsed: numbers, monotonic, unit in the verb ------------

	def ElapsedNs()
		This._Ensure()
		_nTotal_ = @nAccumNs
		if @bRunning
			_nTotal_ += (StzEngineWatchTimestampNs() - @nStartMonoNs)
		ok
		return _nTotal_

	def ElapsedUs()
		return This.ElapsedNs() / 1000

	def ElapsedMs()
		return This.ElapsedNs() / 1000000

	def ElapsedS()
		return This.ElapsedNs() / 1000000000

	# The house unit is milliseconds (see the engine time bridge).
	def Elapsed()
		return This.ElapsedMs()

	# -- Laps -----------------------------------------------------

	# A split reading without stopping: label + elapsed-at-lap (ms,
	# monotonic) + a wall anchor for serialization.
	def Lap(pcLabel)
		This._Ensure()
		_cLabel_ = ""
		if isString(pcLabel)
			_cLabel_ = pcLabel
		ok
		_aLap_ = [ :label = _cLabel_, :atMs = This.ElapsedMs(), :wallMs = StzEngineTimeWallMs() ]
		@aLaps + _aLap_
		return This

	def Laps()
		This._Ensure()
		return @aLaps

	def NumberOfLaps()
		This._Ensure()
		return ring_len(@aLaps)

	# -- The record (Softanza-native serialization) ---------------

	def Record()
		This._Ensure()
		return [
			:name = @cName,
			:startWallMs = @nStartWallMs,
			:stopWallMs = @nStopWallMs,
			:durationMs = This.ElapsedMs(),
			:running = @bRunning,
			:laps = @aLaps
		]

	# -- W3C trace identity (engine tracectx) ---------------------

	def TraceContextQ()
		if @oTraceCtx = ""
			@oTraceCtx = new stzTraceContext()
		ok
		return @oTraceCtx

	def TraceId()
		return This.TraceContextQ().TraceId()

	def SpanId()
		return This.TraceContextQ().SpanId()

	# The traceparent header value -- hand it to a downstream call
	# (stzHttpClient.SetTraceParent) and the export joins one trace.
	def TraceParent()
		return This.TraceContextQ().TraceParent()

	# Adopt an incoming traceparent so this span joins an existing
	# trace instead of opening a fresh one.
	def JoinTrace(pcTraceParent)
		@oTraceCtx = StzTraceContextFrom(pcTraceParent)
		return This

	# -- OpenTelemetry export (industry interop) ------------------

	# The span as a hashlist in OTel vocabulary. Absolute anchors in
	# unix NANOS as STRINGS (integer ms + "000000" -- exact, since
	# f64 cannot hold epoch nanos); exact ns duration as an attribute.
	def ToOtelSpan()
		This._Ensure()
		_nEndWallMs_ = @nStopWallMs
		if _nEndWallMs_ = 0
			_nEndWallMs_ = StzEngineTimeWallMs()
		ok
		_aEvents_ = []
		_nLen_ = ring_len(@aLaps)
		for _i_ = 1 to _nLen_
			_aEvents_ + [
				:name = @aLaps[_i_][:label],
				:timeUnixNano = This._MsToNanoStr(@aLaps[_i_][:wallMs])
			]
		next
		return [
			:name = @cName,
			:traceId = This.TraceId(),
			:spanId = This.SpanId(),
			:kind = "SPAN_KIND_INTERNAL",
			:startTimeUnixNano = This._MsToNanoStr(@nStartWallMs),
			:endTimeUnixNano = This._MsToNanoStr(_nEndWallMs_),
			:attributes = [
				[ :key = "stz.duration_ns", :value = This.ElapsedNs() ]
			],
			:events = _aEvents_
		]

	# One OTLP-style span as a JSON string.
	def ToOtelJson()
		_aSpan_ = This.ToOtelSpan()
		_cEvents_ = ""
		_aEvs_ = _aSpan_[:events]
		_nLen_ = ring_len(_aEvs_)
		for _i_ = 1 to _nLen_
			if _i_ > 1
				_cEvents_ += ","
			ok
			_cEvents_ += '{"name":"'
			_cEvents_ += This._JsonStr(_aEvs_[_i_][:name])
			_cEvents_ += '","timeUnixNano":"'
			_cEvents_ += _aEvs_[_i_][:timeUnixNano]
			_cEvents_ += '"}'
		next
		_cJson_ = '{"name":"'
		_cJson_ += This._JsonStr(_aSpan_[:name])
		_cJson_ += '","traceId":"'
		_cJson_ += _aSpan_[:traceId]
		_cJson_ += '","spanId":"'
		_cJson_ += _aSpan_[:spanId]
		_cJson_ += '","kind":"'
		_cJson_ += _aSpan_[:kind]
		_cJson_ += '","startTimeUnixNano":"'
		_cJson_ += _aSpan_[:startTimeUnixNano]
		_cJson_ += '","endTimeUnixNano":"'
		_cJson_ += _aSpan_[:endTimeUnixNano]
		_cJson_ += '","attributes":[{"key":"stz.duration_ns","value":{"doubleValue":'
		_cJson_ += ("" + This.ElapsedNs())
		_cJson_ += '}}],"events":['
		_cJson_ += _cEvents_
		_cJson_ += ']}'
		return _cJson_

	# -- Legibility ----------------------------------------------

	def Explain()
		This._Ensure()
		_aLines_ = []
		_cState_ = "stopped"
		if @bRunning
			_cState_ = "running"
		ok
		_cN_ = @cName
		if _cN_ = ""
			_cN_ = "(unnamed)"
		ok
		_aLines_ + ("Stopwatch " + _cN_ + " -- " + _cState_ + ".")
		_aLines_ + ("Elapsed: " + This.ElapsedMs() + " ms (monotonic engine clock).")
		_nLen_ = ring_len(@aLaps)
		if _nLen_ > 0
			_aLines_ + ("Laps (" + _nLen_ + "):")
			for _i_ = 1 to _nLen_
				_cLine_ = "  " + _i_ + ". " + @aLaps[_i_][:label]
				_cLine_ += (" at " + @aLaps[_i_][:atMs] + " ms")
				_aLines_ + _cLine_
			next
		ok
		return _aLines_

	def Show()
		_aLines_ = This.Explain()
		_nLen_ = ring_len(_aLines_)
		for _i_ = 1 to _nLen_
			? _aLines_[_i_]
		next

	# -- Internals ------------------------------------------------

	# Integer epoch-ms -> epoch-ns decimal STRING ("...000000").
	# String-built because epoch nanos exceed f64 integer precision.
	def _MsToNanoStr(nMs)
		return "" + nMs + "000000"

	# Minimal JSON string escaping (backslash, quote).
	def _JsonStr(pcStr)
		_cS_ = "" + pcStr
		_cS_ = StzReplace(_cS_, '\', '\\')
		_cS_ = StzReplace(_cS_, '"', '\"')
		return _cS_
