# The honest stopwatch -- perf system P0 (SOFTANZA_PERF_SYSTEM.md).
#
# Three promises under test: elapsed readings are NUMBERS from a
# MONOTONIC engine clock (engine/src/watch.zig, Instant-based since the
# P0 fix -- it used to be wall-clock nanoTimestamp, the same epoch
# defect the process-uptime fix removed); instances are UNLIMITED and
# independent (state in the object, not the engine's 64-slot table);
# and a stopped watch exports as an OpenTelemetry span with real W3C
# trace identity (industry interop, requirement 1 of P0).
#
# Ring traps avoided: main code before the first func; no local oR / nL
# / Try / Show; helper temps underscored.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: elapsed is a NUMBER, and it advances --"
w = StzStopwatch()
_s_ = ""
for i = 1 to 100000
	_s_ += "x"
next
nMs = w.ElapsedMs()
? "  ElapsedMs() = " + nMs
chk("ElapsedMs() returns a number, not a sentence", isNumber(nMs))
chk("busy work registered elapsed time (> 0)", nMs > 0)

bMono = TRUE
nPrev = w.ElapsedNs()
for i = 1 to 50
	nNow = w.ElapsedNs()
	if nNow < nPrev
		bMono = FALSE
	ok
	nPrev = nNow
next
chk("50 successive reads never decrease (monotonic clock)", bMono)

? ""
? "-- Scene 2: the engine watch clock counts from MODULE LOAD, not the epoch --"
# The P0 engine fix: watch.zig used std.time.nanoTimestamp() (wall-clock
# UTC since 1970 -- jumps on NTP corrections). Now: a monotonic Instant
# baseline captured at DLL load. Epoch millis would be ~1.7e12; a
# since-load reading in a test run is far under an hour.
nTs = StzEngineWatchTimestampMs()
? "  StzEngineWatchTimestampMs() = " + nTs
chk("watch timestamp is small and sane (< 3600000 ms = 1h)", nTs >= 0 and nTs < 3600000)
chk("watch timestamp is NOT epoch wall-clock (~1.7e12)", nTs < 100000000000)

? ""
? "-- Scene 3: ns / us / ms / s are the same clock in different units --"
nNs = w.ElapsedNs()
nUs = w.ElapsedUs()
nMs2 = w.ElapsedMs()
nSs = w.ElapsedS()
chk("ns / 1e3 is about us (within 500 us)", fabs(nNs/1000 - nUs) < 500)
chk("ns / 1e6 is about ms (within 5 ms)", fabs(nNs/1000000 - nMs2) < 5)
chk("ms / 1e3 is about s (within 0.05 s)", fabs(nMs2/1000 - nSs) < 0.05)
chk("Elapsed() is the ms house unit", fabs(w.Elapsed() - w.ElapsedMs()) < 5)

? ""
? "-- Scene 4: Pause() excludes time, Resume() continues --"
w2 = StzStopwatchXT("paused-work")
_s_ = ""
for i = 1 to 50000
	_s_ += "x"
next
w2.Pause()
nAtPause = w2.ElapsedNs()
StzEngineTimeSleepMs(60)
nAfterSleep = w2.ElapsedNs()
? "  at pause: " + (nAtPause/1000000) + " ms ; after 60ms sleep: " + (nAfterSleep/1000000) + " ms"
chk("60 sleeping ms while paused registered NOTHING", nAfterSleep = nAtPause)
w2.Resume()
_s_ = ""
for i = 1 to 50000
	_s_ += "x"
next
chk("after Resume() the clock advances again", w2.ElapsedNs() > nAtPause)
chk("IsRunning() says running after Resume()", w2.IsRunning())

? ""
? "-- Scene 5: Stop() freezes the reading and closes the span --"
w2.Stop()
nFrozen = w2.ElapsedNs()
StzEngineTimeSleepMs(20)
chk("a stopped watch reads the same twice", w2.ElapsedNs() = nFrozen)
chk("IsRunning() says stopped", NOT w2.IsRunning())
aRec = w2.Record()
chk("Record() carries the name", aRec[:name] = "paused-work")
chk("Record() stamps the span's wall end (stopWallMs > 0)", aRec[:stopWallMs] > 0)
chk("Record() duration agrees with ElapsedMs()", fabs(aRec[:durationMs] - w2.ElapsedMs()) < 0.001)

? ""
? "-- Scene 6: laps are labeled splits, in order --"
w3 = StzStopwatchXT("laps")
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
w3.Lap("parsed")
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
w3.Lap("validated")
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
w3.Lap("written")
chk("three laps recorded", w3.NumberOfLaps() = 3)
aLaps = w3.Laps()
chk("labels preserved in order", aLaps[1][:label] = "parsed" and aLaps[2][:label] = "validated" and aLaps[3][:label] = "written")
chk("lap times never decrease", aLaps[1][:atMs] <= aLaps[2][:atMs] and aLaps[2][:atMs] <= aLaps[3][:atMs])
chk("laps carry a wall anchor for serialization", aLaps[1][:wallMs] > 1577836800000)

? ""
? "-- Scene 7: unlimited, independent instances (no 64-slot table) --"
# The engine's watch table has 64 slots; stopwatch state lives in the
# OBJECT, so 70 concurrent watches must all work and never collide.
aWs = []
for i = 1 to 70
	aWs + StzStopwatch()
next
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
bAllSane = TRUE
for i = 1 to 70
	if NOT (aWs[i].ElapsedNs() > 0)
		bAllSane = FALSE
	ok
next
chk("70 concurrent stopwatches all advance (old cap was 64)", bAllSane)

wA = StzStopwatch()
wB = StzStopwatch()
wA.Pause()
nA1 = wA.ElapsedNs()
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
chk("pausing one stopwatch does not stop another", wB.ElapsedNs() > 0 and wA.ElapsedNs() = nA1)

? ""
? "-- Scene 8: the OTel export -- industry interop --"
w4 = StzStopwatchXT("checkout")
_s_ = ""
for i = 1 to 30000
	_s_ += "x"
next
w4.Lap("validated")
w4.Stop()
aSpan = w4.ToOtelSpan()
? "  traceId = " + aSpan[:traceId]
? "  startTimeUnixNano = " + aSpan[:startTimeUnixNano]
chk("traceId is a 32-hex W3C id", len(aSpan[:traceId]) = 32)
chk("spanId is a 16-hex W3C id", len(aSpan[:spanId]) = 16)
chk("start anchor is a unix-nano STRING ending in 000000", right(aSpan[:startTimeUnixNano], 6) = "000000")
chk("...long enough to be epoch nanos (19 digits)", len(aSpan[:startTimeUnixNano]) = 19)
chk("laps became span events", ring_len(aSpan[:events]) = 1 and aSpan[:events][1][:name] = "validated")

cJson = w4.ToOtelJson()
? "  ToOtelJson() = " + left(cJson, 60) + "..."
chk("JSON names the span", StzFindFirst('"name":"checkout"', cJson) > 0)
chk("JSON carries the exact ns duration attribute", StzFindFirst('"stz.duration_ns"', cJson) > 0)
chk("JSON carries the events array", StzFindFirst('"events":[{"name":"validated"', cJson) > 0)

cTP = w4.TraceParent()
chk("TraceParent() is a W3C header (00-...)", left(cTP, 3) = "00-")

# Joining an existing trace: the exported span adopts the parent's id.
w5 = StzStopwatchXT("child-step")
w5.JoinTrace(cTP)
w5.Stop()
chk("JoinTrace() adopts the parent's traceId", w5.TraceId() = w4.TraceId())

? ""
? "-- Scene 9: Explain() tells the story in words --"
aLines = w4.Explain()
? "  " + aLines[1]
chk("Explain() returns lines", isList(aLines) and ring_len(aLines) >= 2)
chk("...naming the stopwatch", StzFindFirst("checkout", aLines[1]) > 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
