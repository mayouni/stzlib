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

# Measures elapsed time on the monotonic engine clock, with pause, laps, and export as an OpenTelemetry span.
#
# A stopwatch starts running when it is made. Pause leaves the paused time out, Resume carries on,
# Stop also stamps the end of the span, and Start throws everything away and begins again. Elapsed
# time is a number in the unit named by the method, taken from a clock that wall-clock changes
# cannot move. A stopped stopwatch is exportable as an OpenTelemetry span with real W3C trace and
# span ids, its laps as events, so a program can hand its timings to any OTLP backend. Assert ranges
# and signs on live readings, never exact values.
#
#   receiver   o1 = new stzStopwatch("job")
#   example    ? o1.IsRunning()
#              #--> 1
#              o1.Lap("first")
#              o1.Stop()
#              ? o1.NumberOfLaps()
#              #--> 1
#              ? o1.IsRunning()
#              #--> 0
#              ? o1.Record()[:name]
#              #--> job
#              ? o1.ElapsedNs() > 0
#              #--> 1
#   see        StzStopwatch, stzPerfProfile, stzPerfSeries
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

	# Builds a stopwatch that starts running at once, under a name that labels its span.
	#
	#   pcName     the span's name, kept as given
	#   returns    nothing; the object is built
	#   see        StzStopwatch, Name
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

	# Returns the name that labels this stopwatch's span.
	#
	#   returns    a text; empty when none was given
	#   see        SetName, Record
	def Name()
		return @cName

	# Sets the name of the span; a value that is not a text is ignored and the old name is kept.
	#
	#   pcName     the new name, as text
	#   returns    the stopwatch itself, so calls chain
	#   see        Name, init
	def SetName(pcName)
		if isString(pcName)
			@cName = pcName
		ok
		return This

	# Restarts the stopwatch from zero, with no laps and a fresh start time, and leaves it running.
	#
	#   returns    the stopwatch itself, so calls chain
	#   note       it throws away the time already counted; use Resume to carry on after a pause
	#   see        Resume, Reset, Stop
	#@ aka  -- The clock ------------------------------------------------
	def Start()
		This._Begin()
		return This

	# Stops counting without discarding what was counted, so the time spent paused is left out.
	#
	#   returns    the stopwatch itself, so calls chain; pausing twice changes nothing
	#   see        Resume, Stop, IsRunning
	def Pause()
		This._Ensure()
		if @bRunning
			@nAccumNs += (StzEngineWatchTimestampNs() - @nStartMonoNs)
			@bRunning = 0
		ok
		return This

	# Starts counting again after a pause or a stop and clears the span's end time, keeping the time already counted.
	#
	#   returns    the stopwatch itself, so calls chain
	#   see        Pause, Start, Stop
	def Resume()
		This._Ensure()
		if NOT @bRunning
			@nStartMonoNs = StzEngineWatchTimestampNs()
			@nStopWallMs = 0
			@bRunning = 1
		ok
		return This

	# Pauses the stopwatch and stamps the span's end time, so the record and the export carry a closed interval.
	#
	#   returns    the stopwatch itself, so calls chain
	#   see        Pause, Resume, Record
	#@ aka  Stop() = Pause() + stamp the span's wall end, so the record / OTel export has a closed [start, end] interval.
	def Stop()
		This.Pause()
		@nStopWallMs = StzEngineTimeWallMs()
		return This

	# Sets the elapsed time to zero, empties the laps and leaves the stopwatch paused, not running.
	#
	#   returns    the stopwatch itself, so calls chain
	#   see        Start, Pause
	def Reset()
		This._Begin()
		This.Pause()
		@nAccumNs = 0
		return This

	# TRUE if the stopwatch is counting, FALSE once it is paused, stopped or reset.
	#
	#   returns    TRUE or FALSE
	#   see        Pause, Resume
	def IsRunning()
		This._Ensure()
		return @bRunning

	# Returns the time counted so far in nanoseconds, from the monotonic engine clock.
	#
	#   returns    a number
	#   see        ElapsedUs, ElapsedMs, ElapsedS
	#@ aka  -- Elapsed: numbers, monotonic, unit in the verb ------------
	def ElapsedNs()
		This._Ensure()
		_nTotal_ = @nAccumNs
		if @bRunning
			_nTotal_ += (StzEngineWatchTimestampNs() - @nStartMonoNs)
		ok
		return _nTotal_

	# Returns the time counted so far in microseconds, as a number with a fraction.
	#
	#   returns    a number
	#   see        ElapsedNs, ElapsedMs
	def ElapsedUs()
		return This.ElapsedNs() / 1000

	# Returns the time counted so far in milliseconds, as a number with a fraction; the library's house unit.
	#
	#   returns    a number
	#   see        ElapsedNs, ElapsedS, Lap
	def ElapsedMs()
		return This.ElapsedNs() / 1000000

	# Returns the time counted so far in seconds, as a number with a fraction.
	#
	#   returns    a number
	#   see        ElapsedMs, ElapsedNs
	def ElapsedS()
		return This.ElapsedNs() / 1000000000

	# The house unit is milliseconds (see the engine time bridge).
	def Elapsed()
		return This.ElapsedMs()

	# Records a split reading with a label and the elapsed milliseconds, without stopping the watch.
	#
	#   pcLabel    the split's label
	#   returns    the stopwatch itself, so calls chain
	#   see        Laps, NumberOfLaps
	#@ aka  -- Laps -----------------------------------------------------
	def Lap(pcLabel)
		This._Ensure()
		_cLabel_ = ""
		if isString(pcLabel)
			_cLabel_ = pcLabel
		ok
		_aLap_ = [ :label = _cLabel_, :atMs = This.ElapsedMs(), :wallMs = StzEngineTimeWallMs() ]
		@aLaps + _aLap_
		return This

	# Returns the splits recorded so far, oldest first.
	#
	#   returns    a list of hashlists with the keys label, atMs and wallMs
	#   see        Lap, NumberOfLaps
	def Laps()
		This._Ensure()
		return @aLaps

	# Returns how many splits have been recorded since the last start or reset.
	#
	#   returns    a number
	#   see        Laps, Lap
	def NumberOfLaps()
		This._Ensure()
		return ring_len(@aLaps)

	# Returns the stopwatch as one hashlist, the library's own serialization of a span.
	#
	#   returns    a hashlist with the keys name, startWallMs, stopWallMs, durationMs, running and
	#              laps; stopWallMs is 0 while the span is open
	#   note       the wall times are epoch milliseconds; durationMs comes from the monotonic clock
	#   see        ToOtelSpan, Stop
	#@ aka  -- The record (Softanza-native serialization) ---------------
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

	# Returns the W3C trace context object of this span, created on first use.
	#
	#   returns    a stzTraceContext
	#   see        TraceId, SpanId, TraceParent
	#@ aka  -- W3C trace identity (engine tracectx) ---------------------
	def TraceContextQ()
		if @oTraceCtx = ""
			@oTraceCtx = new stzTraceContext()
		ok
		return @oTraceCtx

	# Returns the 32-hex-digit trace identity of the span.
	#
	#   returns    a text of 32 hexadecimal digits; empty after JoinTrace with a header that is not
	#              valid
	#   see        SpanId, TraceParent, JoinTrace
	def TraceId()
		return This.TraceContextQ().TraceId()

	# Returns the 16-hex-digit identity of this span inside its trace.
	#
	#   returns    a text of 16 hexadecimal digits; empty after JoinTrace with a header that is not
	#              valid
	#   see        TraceId, TraceParent
	def SpanId()
		return This.TraceContextQ().SpanId()

	# Returns the W3C traceparent header value to hand to a downstream call so both join one trace.
	#
	#   returns    a text such as 00-<trace id>-<span id>-01
	#   see        TraceId, JoinTrace
	#@ aka  The traceparent header value -- hand it to a downstream call (stzHttpClient.SetTraceParent) and the export joins one trace.
	def TraceParent()
		return This.TraceContextQ().TraceParent()

	# Adopts the identity carried by an incoming traceparent header, so this span joins an existing trace.
	#
	#   pcTraceParent   the traceparent header text received from the caller
	#   returns         the stopwatch itself, so calls chain
	#   note            a valid header gives its trace and span ids back unchanged
	#   warning         the header is not checked: garbage, a short header such as 00-abc-def-01 and
	#                   an empty text leave TraceId and SpanId empty, TraceParent echoes the text as
	#                   given, and the OTLP export then carries an empty traceId and spanId
	#   see             TraceParent, TraceId
	#@ aka  Adopt an incoming traceparent so this span joins an existing trace instead of opening a fresh one.
	def JoinTrace(pcTraceParent)
		@oTraceCtx = StzTraceContextFrom(pcTraceParent)
		return This

	# Returns the span in OpenTelemetry vocabulary, with its laps as events and its exact duration as an attribute.
	#
	#   returns    a hashlist with the keys name, traceId, spanId, kind, startTimeUnixNano,
	#              endTimeUnixNano, attributes and events
	#   note       the absolute times are epoch nanoseconds written as text (milliseconds followed
	#              by 000000), because a number cannot hold them; a running watch is exported with
	#              the current time as its end
	#   see        ToOtelJson, Record
	#@ aka  -- OpenTelemetry export (industry interop) ------------------
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

	# Returns the span as one OTLP-style JSON text, ready for a backend that speaks OpenTelemetry.
	#
	#   returns    a text holding one JSON object
	#   see        ToOtelSpan, TraceParent
	#@ aka  One OTLP-style span as a JSON string.
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

	# Returns a short narration of the stopwatch: its name, state, elapsed milliseconds and one line per lap.
	#
	#   returns    a list of text lines
	#   see        Show, Record
	#@ aka  -- Legibility ----------------------------------------------
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

	# Prints the narration of the stopwatch, one line per row.
	#
	#   returns    nothing; it prints
	#   see        Explain
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
