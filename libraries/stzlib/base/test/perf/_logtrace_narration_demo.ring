load "../../stzBase.ring"

$CRLF = char(13) + char(10)
$oLog = new stzLog("restolean")

? "== block 1 =="
StzOpenTraceScope("")
$oLog.Info("charging the card")
$oLog.Record(:warn, "gateway slow, retrying", [ [ :gateway, "stripe" ] ])
StzCloseTraceScope()
$oLog.Info("nightly cleanup")
see $oLog.AsText() + nl

? "== block 2 =="
oMon = StzPerfMonitor("restolean")
oMon.EnableTracing(64)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/order", func oReq, oResp {
	$oLog.Info("taking the order")
	$oLog.Info("order placed")
	oResp.Text("placed")
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 2
	cReq = "GET /order HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oSrv.Stop()
aT = oMon.RecentTraces(2)
? "request 1 trace: " + aT[1][:traceId]
? "request 2 trace: " + aT[2][:traceId]
aL = $oLog.OfTrace(aT[2][:traceId])
? "lines of request 2 alone:"
for i = 1 to len(aL)
	? "  " + aL[i][:message]
next

? "== block 3 =="
gL = oMon.NewGauge("queue.depth")
gL.Set(900)
oSla = StzSla("restolean-sla")
oSla.ExpectValue("queue.depth").AtMost(100)
oSent = StzPerfSentinel(oSla, oMon)
oSent.Check()
cTrip = oSent.LastBlackBox()[:traces][1][:traceId]
? "breach trip " + cTrip + " -> its log lines:"
aL = $oLog.OfTrace(cTrip)
for i = 1 to len(aL)
	? "  " + aL[i][:message]
next
oMon.Destroy()

? "== block 4 =="
? left($oLog.OtelJson(), 230) + "..."
