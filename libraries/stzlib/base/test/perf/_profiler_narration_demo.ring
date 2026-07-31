load "../../stzBase.ring"

oTimerFix = new stzReactor()

? "== block 1 =="
oP = StzProfiler(64)
oP.Enter("import-orders")
_s_ = ""
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 15
	_s_ += "x"
end
oP.Enter("parse")
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 25
	_s_ += "x"
end
oP.Leave()
oP.Enter("validate")
nT0 = StzEngineWatchTimestampMs()
while StzEngineWatchTimestampMs() - nT0 < 45
	_s_ += "x"
end
oP.Leave()
oP.Leave()
oP.Show()

? "== block 2 =="
aHot = oP.HotSpots(2)
? "hottest self-time: " + aHot[1][:path] + " (" + aHot[1][:selfMs] + " ms)"
oP.Destroy()

? "== block 3 =="
oS = StzProfiler(64)
oS.StartSampling(2)
oS.Enter("serve")
for i = 1 to 3
	oS.Enter("handle")
	_s_ = ""
	nT0 = StzEngineWatchTimestampMs()
	while StzEngineWatchTimestampMs() - nT0 < 40
		_s_ += "x"
	end
	oS.Leave()
	oS.Enter("write")
	nT0 = StzEngineWatchTimestampMs()
	while StzEngineWatchTimestampMs() - nT0 < 10
		_s_ += "x"
	end
	oS.Leave()
next
oS.Leave()
oS.StopSampling()
? "folded stacks (paste into speedscope.app / flamegraph.pl):"
see oS.Folded()
oS.Destroy()

? "== block 4 =="
oC = StzProfiler(64)
nT0 = StzEngineWatchTimestampNs()
for i = 1 to 10000
	oC.Enter("cost")
	oC.Leave()
next
? "a frame pair costs " + (StzEngineWatchTimestampNs() - nT0) / 10000 / 1000 + " us"
oC.Destroy()
