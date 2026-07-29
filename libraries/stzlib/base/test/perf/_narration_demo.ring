load "../../stzBase.ring"

? "== block 1 =="
w = StzStopwatchXT("import-orders")
_s_ = ""
for i = 1 to 200000
	_s_ += "x"
next
? w.ElapsedMs()

? "== block 2 =="
w.Lap("parsed")
_s_ = ""
for i = 1 to 100000
	_s_ += "x"
next
w.Lap("validated")
w.Pause()
StzEngineTimeSleepMs(100)
w.Resume()
_s_ = ""
for i = 1 to 100000
	_s_ += "x"
next
w.Stop()
? w.ElapsedMs()

? "== block 3 =="
w.Show()

? "== block 4 =="
aRec = w.Record()
? aRec[:name]
? aRec[:durationMs]
? aRec[:running]

? "== block 5 =="
? w.ToOtelJson()

? "== block 6 =="
? w.TraceParent()
w2 = StzStopwatchXT("notify-customer")
w2.JoinTrace(w.TraceParent())
w2.Stop()
? w2.TraceId() = w.TraceId()

? "== block 7 =="
? StzEngineWatchTimestampMs()
