load "../../stzBase.ring"

$CRLF = char(13) + char(10)
nMB = 1024 * 1024

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oMon.WatchCpu().WatchMemory().Every(20)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/order", func oReq, oResp {
	_s_ = ""
	for _k_ = 1 to 40000
		_s_ += "x"
	next
	oResp.Json([ "status", "placed" ])
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
oP = StzPerfProfile(oMon)
for i = 1 to 40
	cReq = "GET /order HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oP.Show()
oSrv.Stop()

? "== block 2 =="
? "D    = " + oP.ServiceDemandMs() + " CPU-ms per request"
? "Xmax = " + oP.MaxThroughput() + " req/s"
? "N    = " + oP.LittleN()
aUC = oP.UtilizationCheck()
? aUC[:message]

? "== block 3 =="
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
aB = oPW.Bottleneck()
? "kind = :" + aB[:kind] + " -- " + aB[:cpuMsPerRequest] + " ms computed, " + aB[:waitMsPerRequest] + " ms waited"

? "== block 4 =="
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)
	oMon.Sample()
next
oPL = StzPerfProfile(oMon)
? "trend  = " + oPL.MemoryTrendPerHour()/nMB + " MB/hour"
nRss = oMon.MetricQ("process.memory.rss").Value()
? "at this trend, +500MB in " + (oPL.HoursToMemoryCeiling(nRss + 500*nMB) * 3600) + " seconds"
aKeep = []
