load "../../stzBase.ring"

$CRLF = char(13) + char(10)

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oMon.EnableTracing(64)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/order", func oReq, oResp { oResp.Text("placed") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 3
	cReq = "GET /order HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cResp = oClient.AwaitTcp(nJob, 5000)
next
aLines = StzSplit(cResp, $CRLF)
for i = 1 to len(aLines)
	if StzFindFirst("traceparent", aLines[i]) = 1
		? aLines[i]
	ok
next
aT = oMon.RecentTraces(3)
for i = 1 to len(aT)
	? aT[i][:traceId] + "  " + aT[i][:path] + "  " + aT[i][:status] + "  " + aT[i][:durMs] + " ms"
next

? "== block 2 =="
cCallerTP = StzEngineTraceNew()
? "caller sends : " + cCallerTP
cReq = "GET /order HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "traceparent: " + cCallerTP + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cResp = oClient.AwaitTcp(nJob, 5000)
aLines = StzSplit(cResp, $CRLF)
for i = 1 to len(aLines)
	if StzFindFirst("traceparent", aLines[i]) = 1
		? "server echoes: " + StzMidToEnd(aLines[i], 14)
	ok
next
oSrv.Stop()

? "== block 3 =="
gL = oMon.NewGauge("queue.depth")
gL.Set(10)
oSla = StzSla("restolean-sla")
oSla.ExpectValue("queue.depth").AtMost(100)
oSent = StzPerfSentinel(oSla, oMon)
gL.Set(900)
oSent.Check()
aBox = oSent.LastBlackBox()
? "breach: " + aBox[:rule]
? "the trips nearest the breach:"
for i = 1 to len(aBox[:traces])
	? "  " + aBox[:traces][i][:traceId] + "  " + aBox[:traces][i][:path] + " -> " + aBox[:traces][i][:status]
next
oMon.Destroy()

? "== block 4 =="
w1 = StzStopwatchXT("import-orders")
w1.Stop()
w2 = StzStopwatchXT("notify-customer")
w2.JoinTrace(w1.TraceParent())
w2.Stop()
oB = StzOtelBatch("restolean")
oB.AddSpan(w1).AddSpan(w2)
? left(oB.ToJson(), 200) + "..."
? "spans: " + oB.SpanCount() + " ; shared traceId appears " + len(StzFind(w1.TraceId(), oB.ToJson())) + "x"
