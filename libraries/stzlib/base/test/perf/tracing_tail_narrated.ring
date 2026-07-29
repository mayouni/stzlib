# The deferred tail -- perf system P7 (SOFTANZA_PERF_SYSTEM.md).
#
# Two deferred promises kept: (1) request TRACING at the seam -- every
# request on a traced+observed server gets a W3C trace identity (a
# valid incoming traceparent JOINS the caller's trace as a child; the
# response echoes the header), recorded in an ENGINE trace ring so the
# server face writes and every other face reads one truth -- and the
# sentinel's black box now carries the trace ids of the requests
# nearest the breach. (2) The OTLP span BATCH: stzOtelBatch renders
# the resourceSpans envelope a collector ingests at /v1/traces.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

$CRLF = char(13) + char(10)

pr()

? "-- Scene 1: the engine trace ring -- bounded, shared, honest --"
oMonA = StzPerfMonitor("ring-basics")
oMonA.EnableTracing(4)
chk("tracing is on", oMonA.IsTracing())
oMonA.RecordTrace("aaaa1111", "/one", 200, 1.5)
oMonA.RecordTrace("bbbb2222", "/two", 404, 2.5)
chk("two traces held", oMonA.TraceCount() = 2)
aT = oMonA.RecentTraces(10)
chk("rows carry id/path/status/durMs", aT[1][:traceId] = "aaaa1111" and aT[2][:path] = "/two" and aT[2][:status] = 404 and aT[1][:durMs] = 1.5)
chk("rows carry a wall anchor", aT[1][:wallMs] > 1577836800000)
for i = 1 to 4
	oMonA.RecordTrace("cccc" + i, "/more", 200, 1)
next
chk("past capacity the OLDEST give way (count 6, size 4)", oMonA.TraceCount() = 6 and len(oMonA.RecentTraces(99)) = 4)
chk("...and the survivors are the newest", oMonA.RecentTraces(99)[1][:traceId] = "cccc1")
oMonA.Destroy()

oMonNo = StzPerfMonitor("untraced")
chk("an untraced monitor answers honestly (no ring, no rows)", NOT oMonNo.IsTracing() and len(oMonNo.RecentTraces(5)) = 0)

? ""
? "-- Scene 2: every request on a traced server gets a trace identity --"
oMon = StzPerfMonitor("shop")
oMon.EnableTracing(64)          # BEFORE Observe: the server copies the monitor
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/greet", func oReq, oResp { oResp.Text("hello") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 3
	cReq = "GET /greet HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cResp = oClient.AwaitTcp(nJob, 5000)
next
chk("the response ECHOES a traceparent header", StzFindFirst("traceparent: 00-", cResp) > 0)
chk("the SERVER face recorded into the ring OUR face reads (engine truth)", oMon.TraceCount() = 3)
aT = oMon.RecentTraces(3)
chk("the trace knows the path", aT[1][:path] = "/greet")
chk("...the status", aT[1][:status] = 200)
chk("...and the cost", aT[1][:durMs] > 0)
chk("trace ids are 32-hex W3C ids", len(aT[1][:traceId]) = 32)
chk("each request opened its own trace", aT[1][:traceId] != aT[2][:traceId])

? ""
? "-- Scene 3: a valid incoming traceparent JOINS the caller's trace --"
cCallerTP = StzEngineTraceNew()
cCallerId = StzEngineTraceId(cCallerTP)
cReq = "GET /greet HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "traceparent: " + cCallerTP + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cResp = oClient.AwaitTcp(nJob, 5000)
chk("the response header carries the CALLER'S traceId (same trace, child span)", StzFindFirst("traceparent: 00-" + cCallerId, cResp) > 0)
aT = oMon.RecentTraces(1)
chk("the ring recorded the caller's traceId too", aT[1][:traceId] = cCallerId)
oSrv.Stop()

? ""
? "-- Scene 4: the alert carries the trips that tripped it --"
gL = oMon.NewGauge("queue.depth")
gL.Set(10)
oSla = StzSla("shop-sla")
oSla.ExpectValue("queue.depth").AtMost(100)
oSent = StzPerfSentinel(oSla, oMon)
oSent.SetChannels("p7.breach", "p7.clear")
gL.Set(900)
oSent.Check()
aBox = oSent.LastBlackBox()
chk("the black box now carries traces", len(aBox[:traces]) = 4)
chk("...with the request path", aBox[:traces][1][:path] = "/greet")
chk("...and real 32-hex ids -- the 3 a.m. answer includes WHICH requests", len(aBox[:traces][1][:traceId]) = 32)
oMon.Destroy()

? ""
? "-- Scene 5: the OTLP span batch -- many spans, one shipment --"
w1 = StzStopwatchXT("import-orders")
w1.Lap("parsed")
w1.Stop()
w2 = StzStopwatchXT("notify-customer")
w2.JoinTrace(w1.TraceParent())
w2.Stop()
oB = StzOtelBatch("restolean")
oB.AddSpan(w1).AddSpan(w2)
chk("two spans collected", oB.SpanCount() = 2)
cJson = oB.ToJson()
chk("the envelope is resourceSpans", StzFindFirst('"resourceSpans"', cJson) > 0)
chk("service identity stated once at the top", StzFindFirst('"stringValue":"restolean"', cJson) > 0)
chk("scopeSpans wraps the spans", StzFindFirst('"scopeSpans"', cJson) > 0)
chk("both spans are inside", StzFindFirst('"name":"import-orders"', cJson) > 0 and StzFindFirst('"name":"notify-customer"', cJson) > 0)
aHits = StzFind(w1.TraceId(), cJson)
chk("the JOINED spans share ONE traceId in the shipment (a collector reassembles the tree)", len(aHits) = 2)
oB.Clear()
chk("Clear() readies the next shipment", oB.SpanCount() = 0)

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
