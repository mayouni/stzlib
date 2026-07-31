# Log-trace correlation -- perf system P9 (SOFTANZA_PERF_SYSTEM.md).
#
# The TRACE SCOPE: one engine-global slot holds the active traceparent;
# the observed server opens it around every request, and every stzLog
# record written inside a scope -- any log, any object, any face --
# stamps the trace id automatically. OfTrace() queries by it; the OTLP
# logs envelope ships it in the logRecord's first-class traceId field.
# The 3 a.m. circle completes: alert -> black-box trip trace-ids ->
# THE LOG LINES of those requests.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show; no cAll-like keyword names.

load "../../stzBase.ring"

nPass = 0
nFail = 0

$CRLF = char(13) + char(10)
$oReqLog = new stzLog("api")

pr()

? "-- Scene 1: the scope opens, joins, and closes --"
chk("no scope: current id is empty", StzCurrentTraceId() = "" and NOT StzInTraceScope())
cTP = StzOpenTraceScope("")
chk("a fresh scope minted a 32-hex trace id", len(StzCurrentTraceId()) = 32)
chk("the traceparent in effect is the one returned", StzCurrentTraceParent() = cTP)
StzCloseTraceScope()
cParent = StzEngineTraceNew()
StzOpenTraceScope(cParent)
chk("opening with an existing parent JOINS its trace", StzCurrentTraceId() = StzEngineTraceId(cParent))
StzCloseTraceScope()
chk("closed: current id is empty again", NOT StzInTraceScope())

? ""
? "-- Scene 2: logs stamp inside a scope, stay clean outside --"
oLog = new stzLog("shop")
cTP = StzOpenTraceScope("")
cIdA = StzCurrentTraceId()
oLog.Info("charging the card")
oLog.Record(:warn, "retrying gateway", [ [ :gateway, "stripe" ] ])
StzCloseTraceScope()
oLog.Info("anonymous housekeeping")
aE = oLog.Entries()
chk("scoped lines carry traceId", len(oLog.OfTrace(cIdA)) = 2)
chk("...alongside their own fields", len(oLog.Where("gateway", "stripe")) = 1)
chk("the unscoped line carries NO traceId", len(aE[3][:fields]) = 0)

? ""
? "-- Scene 3: OfTrace() separates interleaved requests --"
cTP = StzOpenTraceScope("")
cIdB = StzCurrentTraceId()
oLog.Info("second request begins")
StzCloseTraceScope()
chk("trace A still answers only its own lines", len(oLog.OfTrace(cIdA)) = 2)
chk("trace B answers only its own", len(oLog.OfTrace(cIdB)) = 1)

? ""
? "-- Scene 4: spans JOIN the scope -- logs and spans, one trace --"
cTP = StzOpenTraceScope("")
w = StzStopwatchXT("charge-card")
w.JoinTrace(StzCurrentTraceParent())
w.Stop()
oLog.Info("card charged")
chk("the stopwatch's span shares the scope's trace id", w.TraceId() = StzCurrentTraceId())
chk("...and the log line does too", len(oLog.OfTrace(w.TraceId())) = 1)
StzCloseTraceScope()

? ""
? "-- Scene 5: the observed server correlates handler logs, per request --"
oMon = StzPerfMonitor("shop")
oMon.EnableTracing(64)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/order", func oReq, oResp {
	$oReqLog.Info("taking the order")
	$oReqLog.Info("order placed")
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
chk("each request's log lines carry ITS ring trace id (2 apiece)",
	len($oReqLog.OfTrace(aT[1][:traceId])) = 2 and len($oReqLog.OfTrace(aT[2][:traceId])) = 2)
chk("the two requests' lines are distinct traces", aT[1][:traceId] != aT[2][:traceId])
chk("the scope CLOSED with the request bracket", NOT StzInTraceScope())

? ""
? "-- Scene 6: the 3 a.m. circle -- alert -> trip ids -> THE LOG LINES --"
gL = oMon.NewGauge("queue.depth")
gL.Set(10)
oSla = StzSla("shop-sla")
oSla.ExpectValue("queue.depth").AtMost(100)
oSent = StzPerfSentinel(oSla, oMon)
oSent.SetChannels("p9.breach", "p9.clear")
gL.Set(900)
oSent.Check()
aBox = oSent.LastBlackBox()
cTripId = aBox[:traces][1][:traceId]
aLines = $oReqLog.OfTrace(cTripId)
? "  trip " + cTripId + " -> " + len(aLines) + " log line(s): '" + aLines[1][:message] + "'"
chk("the black box's trip id fetches that request's log lines", len(aLines) = 2)
chk("...and they are the handler's own words", aLines[2][:message] = "order placed")
oMon.Destroy()

? ""
? "-- Scene 7: the OTLP logs envelope -- the OTel triad completes --"
cOtel = oLog.OtelJson()
chk("resourceLogs envelope", StzFindFirst('"resourceLogs"', cOtel) > 0)
chk("service identity from the log's category", StzFindFirst('"stringValue":"shop"', cOtel) > 0)
chk("severity text + standard number", StzFindFirst('"severityText":"WARN","severityNumber":13', cOtel) > 0)
chk("the body carries the message", StzFindFirst('"body":{"stringValue":"charging the card"}', cOtel) > 0)
chk("traceId PROMOTED to the logRecord's first-class field", StzFindFirst('"traceId":"' + cIdA + '"', cOtel) > 0)
chk("fields ride as attributes (traceId excluded from them)", StzFindFirst('{"key":"gateway","value":{"stringValue":"stripe"}}', cOtel) > 0)
chk("the unscoped record has no traceId at all", len(StzFind('"traceId"', cOtel)) = 4)

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
