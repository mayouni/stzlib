# The profile -- perf system P5 (SOFTANZA_PERF_SYSTEM.md).
#
# stzPerfProfile turns measured numbers into operational UNDERSTANDING:
# interval-anchored U/R/X/D (service demand = CPU-ms per request,
# measured not configured), the computing/waiting split that names the
# bottleneck, Little's-law and utilization-law consistency checks (two
# INDEPENDENT measurements agreeing = evidence the measurement is
# sound), memory trend + time-to-ceiling forecast, the R-vs-X curve,
# and the narrated Explain() that teaches the analysis on real numbers.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nMB = 1024 * 1024
$CRLF = char(13) + char(10)

pr()

? "-- Scene 1: the profile anchors, load flows, the interval answers --"
oMon = StzPerfMonitor("api")
oMon.WatchCpu().Every(20)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/work", func oReq, oResp {
	_s_ = ""
	for _k_ = 1 to 30000
		_s_ += "x"
	next
	oResp.Text("done")
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()

oP = StzPerfProfile(oMon)
for i = 1 to 15
	cReq = "GET /work HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
chk("the interval saw all 15 requests", oP.Requests() = 15)
chk("the interval has real duration", oP.IntervalMs() > 0)
nX = oP.Throughput()
? "  X = " + nX + " req/s over " + oP.IntervalMs() + " ms"
chk("X is measured and positive", nX > 0)

? ""
? "-- Scene 2: U and D -- utilization and the service demand --"
nU = oP.Utilization()
nD = oP.ServiceDemandMs()
? "  U = " + nU + " ; D = " + nD + " CPU-ms per request"
chk("U is a sane fraction (0 < U <= 1)", nU > 0 and nU <= 1)
chk("each request demanded real CPU (D > 0)", nD > 0)
chk("CpuMsUsed is positive", oP.CpuMsUsed() > 0)
nMax = oP.MaxThroughput()
? "  Xmax (if CPU-bound) = " + nMax + " req/s ; headroom = " + (oP.Headroom()*100) + "%"
chk("the CPU ceiling is computable and above current X", nMax > nX)
chk("headroom is a fraction", oP.Headroom() >= 0 and oP.Headroom() <= 1)

? ""
? "-- Scene 3: the utilization law, checked with TWO measurements --"
aUC = oP.UtilizationCheck()
? "  " + aUC[:message]
chk("the sampled gauge existed (monitor ticked while serving)", aUC[:sampled] >= 0)
chk("computed and sampled U agree (the measurement is sound)", aUC[:consistent])

oBlindMon = StzPerfMonitor("blind")
oPBlind = StzPerfProfile(oBlindMon)
aUCB = oPBlind.UtilizationCheck()
chk("without a sampled gauge the check says so, honestly", aUCB[:sampled] = -1 and NOT aUCB[:consistent])

? ""
? "-- Scene 4: Little's law -- the implied concurrency --"
nN = oP.LittleN()
? "  N = X*R = " + nN + " request(s) in flight (a serial harness must imply <= 1)"
chk("the serial loop implies N in (0, 1]", nN > 0 and nN <= 1)
aLC = oP.LittleCheckAgainst(nN * 1.5)
chk("a same-scale measured N is consistent", aLC[:consistent])
aLC2 = oP.LittleCheckAgainst(nN * 10 + 1)
chk("a wildly different N is called INCONSISTENT", NOT aLC2[:consistent])

? ""
? "-- Scene 5: the bottleneck split -- BUSY names CPU --"
aB = oP.Bottleneck()
? "  per request: " + aB[:cpuMsPerRequest] + " ms computed, " + aB[:waitMsPerRequest] + " ms waited"
chk("a compute-heavy handler is CPU-bound", aB[:kind] = "cpu")
chk("the split carries the ceiling", aB[:maxThroughput] > 0)
# capture the narration NOW, while the interval is rich (scene 9 reads it)
aLExplain = oP.Explain()
oSrv.Stop()

? ""
? "-- Scene 6: the bottleneck split -- BLOCKED names WAITING --"
# NOT via in-process HTTP: the serve/await path itself costs real CPU
# per round trip (the client and server share this process), which
# would mask the wait. The profile reads the standard instruments, so
# a batch worker that sleeps -- genuinely blocked work -- makes the
# case deterministically: D collapses toward 0, R stays ~10ms.
oMonW = StzPerfMonitor("batch")
oMonW.NewCounter("http.requests")
oMonW.NewTimer("http.request.ms")
oPW = StzPerfProfile(oMonW)
for i = 1 to 6
	w = StzStopwatch()
	StzEngineTimeSleepMs(10)
	oMonW.MetricQ("http.request.ms").RecordWatch(w)
	oMonW.MetricQ("http.requests").Increment()
next
aB2 = oPW.Bottleneck()
? "  per request: " + aB2[:cpuMsPerRequest] + " ms computed, " + aB2[:waitMsPerRequest] + " ms waited"
chk("blocked work is WAIT-bound -- blocked, not busy", aB2[:kind] = "waiting")
chk("the wait dominates the compute", aB2[:waitMsPerRequest] > aB2[:cpuMsPerRequest])
chk("interval mean R sees the ~10ms sleeps", oPW.ResponseTimeMeanMs() > 8)

? ""
? "-- Scene 7: memory trend and the time-to-ceiling forecast --"
oMonLeak = StzPerfMonitor("leaky")
oMonLeak.WatchMemory()
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)
	oMonLeak.Sample()
next
oPLeak = StzPerfProfile(oMonLeak)
nTrend = oPLeak.MemoryTrendPerHour()
? "  trend = " + (nTrend/nMB) + " MB/hour"
chk("the watched leak trends positive", nTrend > 0)
nRssNow = oMonLeak.MetricQ("process.memory.rss").Value()
nHours = oPLeak.HoursToMemoryCeiling(nRssNow + 100 * nMB)
? "  " + nHours + " hour(s) until +100MB at this trend"
chk("a finite forecast to a ceiling above us", nHours > 0)
chk("a ceiling already passed answers 0", oPLeak.HoursToMemoryCeiling(1) = 0)
aKeep = []

? ""
? "-- Scene 8: the R-vs-X curve -- snapshots across load levels --"
aRow = oP.Snapshot()
chk("a snapshot row carries [at, X, U, D, Rp95]", len(aRow) = 5)
oP.Mark()
oP.Snapshot()
chk("the curve keeps the points in order", len(oP.Curve()) = 2)

? ""
? "-- Scene 9: Explain() teaches the analysis on the real numbers --"
aL = aLExplain
cNarr = ""
for i = 1 to len(aL)
	cNarr += (aL[i] + char(10))
next
? "  (" + len(aL) + " lines)"
chk("the narration is substantial (>= 6 lines)", len(aL) >= 6)
chk("it names X", StzFindFirst("X = ", cNarr) > 0)
chk("it names U", StzFindFirst("U = ", cNarr) > 0)
chk("it teaches the service demand D", StzFindFirst("demanded D = ", cNarr) > 0)
chk("it applies Little's law", StzFindFirst("Little", cNarr) > 0)
chk("it names the constraint in words", StzFindFirst("constraint", cNarr) > 0 or StzFindFirst("blocked", cNarr) > 0)

aLB = oPBlind.Explain()
chk("a blind monitor's narration says what is missing", StzFindFirst("No request instruments", aLB[2]) > 0)

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
