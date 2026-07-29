# The engine senses -- perf system P1 (SOFTANZA_PERF_SYSTEM.md).
#
# Until P1 the engine could tell time but not observe MEMORY or CPU --
# the notebook issues 2-5 (degradation, slow leaks, crash leaks, CPU
# spikes) were literally unobservable. stz_perf.dll adds: process
# RSS/peak, system memory total/free, process CPU time, and the
# engine-resident metric SERIES (bounded ring, O(1) record, exact
# windowed stats). This guard pins the senses' honesty properties:
# peak never below current, CPU advances with WORK not with sleep,
# series statistics exact on known data, oldest-overwrite ring
# semantics, and the profile's Resources() gap finally filled.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nMB = 1024 * 1024

pr()

? "-- Scene 1: the process weighs something real --"
nRss = StzEnginePerfMemRss()
nPeak = StzEnginePerfMemPeak()
? "  rss  = " + (nRss / nMB) + " MB"
? "  peak = " + (nPeak / nMB) + " MB"
chk("rss is a real weight (> 5 MB for a loaded stzlib)", nRss > 5 * nMB)
chk("peak is never below current", nPeak >= nRss)

? ""
? "-- Scene 2: the sense SEES an allocation happen --"
nBefore = StzEnginePerfMemRss()
_cBig_ = copy("x", 40 * nMB)
nAfter = StzEnginePerfMemRss()
? "  before = " + (nBefore / nMB) + " MB ; after 40MB string = " + (nAfter / nMB) + " MB"
chk("a 40MB allocation is visible in rss (grew > 10MB)", (nAfter - nBefore) > 10 * nMB)
chk("peak followed the high water", StzEnginePerfMemPeak() >= nAfter)
_cBig_ = ""

? ""
? "-- Scene 3: the machine's memory, total and free --"
nTotal = StzEnginePerfSysMemTotal()
nFree = StzEnginePerfSysMemFree()
? "  total = " + (nTotal / (1024 * nMB)) + " GB ; free = " + (nFree / (1024 * nMB)) + " GB"
chk("total physical memory > 1 GB", nTotal > 1024 * nMB)
chk("free is positive and below total", nFree > 0 and nFree < nTotal)

? ""
? "-- Scene 4: CPU time counts WORK, not waiting --"
# The honest property that makes CPU time the spike detector: a busy
# stretch advances it, a sleeping stretch does not -- while uptime
# (wall-ish monotonic) advances through both.
nCpu0 = StzEnginePerfCpuNs()
nUp0 = StzEngineProcessUptimeNs()
_s_ = ""
for i = 1 to 400000
	_s_ += "x"
next
nCpu1 = StzEnginePerfCpuNs()
chk("busy work advanced CPU time", nCpu1 > nCpu0)

nUp1 = StzEngineProcessUptimeNs()
StzEngineTimeSleepMs(200)
nCpu2 = StzEnginePerfCpuNs()
nUp2 = StzEngineProcessUptimeNs()
nCpuSleptMs = (nCpu2 - nCpu1) / 1000000
nUpSleptMs = (nUp2 - nUp1) / 1000000
? "  during a 200ms sleep: uptime advanced " + nUpSleptMs + " ms, CPU only " + nCpuSleptMs + " ms"
chk("uptime saw the 200ms sleep (>= 150ms)", nUpSleptMs >= 150)
chk("CPU time barely moved while sleeping (< 50ms)", nCpuSleptMs < 50)

nCores = StzEngineSystemCpuCount()
nUtil = (nCpu2 - nCpu0) / ((nUp2 - nUp0) * nCores)
? "  utilization over the whole window (U = dCPU / (dT * " + nCores + " cores)) = " + nUtil
chk("utilization is a sane fraction (0 < U <= 1)", nUtil > 0 and nUtil <= 1)

? ""
? "-- Scene 5: stzProcess wears the senses --"
oProc = new stzProcess()
chk("MemoryBytes() agrees with the engine (within 20MB drift)", fabs(oProc.MemoryBytes() - StzEnginePerfMemRss()) < 20 * nMB)
chk("Rss() is its alias", fabs(oProc.Rss() - oProc.MemoryBytes()) < 20 * nMB)
chk("PeakMemoryBytes() >= MemoryBytes()", oProc.PeakMemoryBytes() >= oProc.MemoryBytes())
chk("CpuTimeMs() is ns / 1e6", fabs(oProc.CpuTimeMs() - oProc.CpuTimeNs()/1000000) < 100)

? ""
? "-- Scene 6: the profile's Resources() gap is FILLED --"
# stzSystemProfile.Resources() carried a comment for months: memory is
# "a PLANNED engine add". P1 is that add. Live profiles now carry the
# facts; a DECLARED target (never observed) honestly reports 0.
oSys = CurrentSystem()
aRes = oSys.Resources()
? "  live mem_total = " + (aRes["mem_total"] / (1024 * nMB)) + " GB"
chk("live profile carries mem_total (> 1 GB)", aRes["mem_total"] > 1024 * nMB)
chk("live profile carries mem_free (> 0)", aRes["mem_free"] > 0)
chk("cpu_count and address_bits still there", aRes["cpu_count"] > 0 and aRes["address_bits"] > 0)

oTarget = DeclareSystem("some-target-box")
aTRes = oTarget.Resources()
chk("a DECLARED profile reports 0 (not observed, not invented)", aTRes["mem_total"] = 0 and aTRes["mem_free"] = 0)

? ""
? "-- Scene 7: the series -- exact stats on known data --"
s = StzPerfSeries(16)
s.RecordAt(1, 10)
s.RecordAt(2, 30)
s.RecordAt(3, 20)
chk("Count()=3, Size()=3 below capacity", s.Count() = 3 and s.Size() = 3)
chk("Last() is the newest value", s.Last() = 20)
chk("Min()/Max() exact", s.Min() = 10 and s.Max() = 30)
chk("Mean() exact", s.Mean() = 20)
chk("ValueAt is 1-based, oldest first", s.ValueAt(1) = 10 and s.ValueAt(3) = 20)
chk("TimeAt carries the caller's clock", s.TimeAt(2) = 2)
s.Destroy()

? ""
? "-- Scene 8: past capacity, the OLDEST samples give way --"
s2 = StzPerfSeries(3)
for i = 1 to 5
	s2.RecordAt(i, i * 100)
next
chk("Count() remembers all 5, Size() retains 3", s2.Count() = 5 and s2.Size() = 3)
chk("retained window is 300,400,500 oldest-first", s2.ValueAt(1) = 300 and s2.ValueAt(3) = 500)
chk("stats answer over the retained window only", s2.Min() = 300 and s2.Max() = 500)
s2.Destroy()

? ""
? "-- Scene 9: slope is the trend detector --"
s3 = StzPerfSeries(32)
for t = 0 to 10
	s3.RecordAt(t, 2*t + 5)
next
? "  slope of v = 2t+5  ->  " + s3.SlopePerMs()
chk("a perfect 2/ms growth reports slope 2", fabs(s3.SlopePerMs() - 2) < 0.000001)
s3.Destroy()

s4 = StzPerfSeries(8)
s4.RecordAt(1, 7)
s4.RecordAt(2, 7)
s4.RecordAt(3, 7)
chk("a flat series reports slope 0", fabs(s4.SlopePerMs()) < 0.000000001)
s4.Destroy()

? ""
? "-- Scene 10: percentiles are EXACT here (unlike the histogram's buckets) --"
s5 = StzPerfSeries(128)
for i = 1 to 100
	s5.RecordAt(i, i)
next
chk("P50 of 1..100 is exactly 50", s5.P50() = 50)
chk("P95 is exactly 95", s5.P95() = 95)
chk("Percentile(100) is the max", s5.Percentile(100) = 100)
s5.Destroy()

? ""
? "-- Scene 11: self-stamped Record() rides the monotonic clock --"
s6 = StzPerfSeries(8)
s6.Record(1)
s6.Record(2)
s6.Record(3)
bTimesOrdered = (s6.TimeAt(1) <= s6.TimeAt(2)) and (s6.TimeAt(2) <= s6.TimeAt(3))
chk("self-stamped times never decrease", bTimesOrdered)
chk("...and are since-load ms, not the epoch", s6.TimeAt(3) < 3600000)
s6.Destroy()

? ""
? "-- Scene 12: a leak, WATCHED: rss series while allocating --"
# The P1 pieces composed: sample the rss sense into a series while a
# 'leak' grows, and the slope turns positive -- issue 3 of the
# notebook (slow leaks), observable at last.
s7 = StzPerfSeries(64)
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)
	s7.Record(StzEnginePerfMemRss())
next
? "  rss samples (MB): first = " + (s7.ValueAt(1)/nMB) + " ... last = " + (s7.Last()/nMB)
? "  slope = " + (s7.SlopePerMs() / nMB) + " MB/ms"
chk("the growing 'leak' shows a positive slope", s7.SlopePerMs() > 0)
chk("last sample outweighs the first", s7.Last() > s7.ValueAt(1))
s7.Destroy()
aKeep = []

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
