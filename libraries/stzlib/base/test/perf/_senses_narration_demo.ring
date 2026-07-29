load "../../stzBase.ring"

nMB = 1024 * 1024

? "== block 1 =="
? "rss   : " + StzEnginePerfMemRss() / nMB + " MB"
? "peak  : " + StzEnginePerfMemPeak() / nMB + " MB"
? "total : " + StzEnginePerfSysMemTotal() / (1024*nMB) + " GB"
? "free  : " + StzEnginePerfSysMemFree() / (1024*nMB) + " GB"
? "cpu   : " + StzEnginePerfCpuNs() / 1000000 + " ms"

? "== block 2 =="
nCpu0 = StzEnginePerfCpuNs()
nUp0 = StzEngineProcessUptimeNs()
StzEngineTimeSleepMs(300)
? "slept 300ms: uptime +" + (StzEngineProcessUptimeNs()-nUp0)/1000000 + " ms, cpu +" + (StzEnginePerfCpuNs()-nCpu0)/1000000 + " ms"
nCpu0 = StzEnginePerfCpuNs()
nUp0 = StzEngineProcessUptimeNs()
_s_ = ""
for i = 1 to 400000
	_s_ += "x"
next
? "worked hard: uptime +" + (StzEngineProcessUptimeNs()-nUp0)/1000000 + " ms, cpu +" + (StzEnginePerfCpuNs()-nCpu0)/1000000 + " ms"

? "== block 3 =="
s = StzPerfSeries(64)
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)
	s.Record(StzEnginePerfMemRss())
next
? "first sample : " + s.ValueAt(1)/nMB + " MB"
? "last sample  : " + s.Last()/nMB + " MB"
? "mean         : " + s.Mean()/nMB + " MB"
? "slope        : " + s.SlopePerMs()/nMB + " MB per ms"
s.Destroy()
aKeep = []

? "== block 4 =="
aRes = CurrentSystem().Resources()
? "cpu_count    : " + aRes["cpu_count"]
? "address_bits : " + aRes["address_bits"]
? "mem_total    : " + aRes["mem_total"] / (1024*nMB) + " GB"
? "mem_free     : " + aRes["mem_free"] / (1024*nMB) + " GB"
? "declared box : mem_total = " + DeclareSystem("target-box").Resources()["mem_total"]

? "== block 5 =="
s2 = StzPerfSeries(3)
for i = 1 to 5
	s2.RecordAt(i, i * 100)
next
? "recorded 5 into capacity 3:"
? "Count() = " + s2.Count() + " ; Size() = " + s2.Size()
? "window  = " + s2.ValueAt(1) + ", " + s2.ValueAt(2) + ", " + s2.ValueAt(3)
s2.Destroy()
