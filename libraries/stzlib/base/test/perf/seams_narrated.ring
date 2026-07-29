# The seams -- perf system P3 (SOFTANZA_PERF_SYSTEM.md).
#
# The instruments (P2) attach to the places requests actually flow:
# stzAppServer brackets every request (R into a timer, X into a
# counter, 5xx into an errors counter), serves /metrics in Prometheus
# exposition and a widened /health; stzAppBackend's traffic ledger
# gains the crossing's COST; stzComputePipeline's trace gains per-stage
# durations; stzSuperApp.CallAcross and stzComputeFederation.
# FederatedCall time every crossing, refusals included.
#
# Requests are REAL: a second stzReactor plays the HTTP client
# (SubmitTcp -> ServeOne -> AwaitTcp), one process holding both ends.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nMB = 1024 * 1024
$CRLF = char(13) + char(10)

pr()

? "-- Scene 1: an OBSERVED server measures every request --"
oMon = StzPerfMonitor("shop-live")
oMon.WatchMemory().Every(100)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
chk("Observe() registered the three request instruments",
	oMon.HasMetric("http.request.ms") and oMon.HasMetric("http.requests") and oMon.HasMetric("http.errors"))
chk("the server says it is observed", oSrv.IsObserved())

oSrv.Get_("/greet", func oReq, oResp { oResp.Text("hello " + oReq.Query("name")) })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()

for i = 1 to 6
	cReq = "GET /greet?name=softanza HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
next
chk("six real requests served (the last replied 200)", StzFindFirst("200 OK", cBody) > 0)
chk("the timer measured all six", oMon.MetricQ("http.request.ms").Count() = 6)
nR = oMon.MetricQ("http.request.ms").Value()
? "  last request R = " + nR + " ms"
chk("response time R is a positive number of ms", nR > 0)
chk("the requests counter counted six", oMon.MetricQ("http.requests").Value() = 6)
nX = oMon.MetricQ("http.requests").RatePerSecond()
? "  measured throughput X = " + nX + " req/s"
chk("throughput X is measured and positive", nX > 0)
chk("no errors yet", oMon.MetricQ("http.errors").Value() = 0)

? ""
? "-- Scene 2: /health widened with the senses and the measured numbers --"
cReq = "GET /health HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cHealth = oClient.AwaitTcp(nJob, 5000)
chk("health answers 200", StzFindFirst("200 OK", cHealth) > 0)
chk("health carries rss_bytes (the P1 sense)", StzFindFirst('"rss_bytes":', cHealth) > 0)
chk("health carries cpu_ms", StzFindFirst('"cpu_ms":', cHealth) > 0)
chk("an observed server adds its measured p95", StzFindFirst('"p95_ms":', cHealth) > 0)
chk("...and its measured rate", StzFindFirst('"rate_per_s":', cHealth) > 0)

? ""
? "-- Scene 3: GET /metrics speaks Prometheus natively --"
cReq = "GET /metrics HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cMet = oClient.AwaitTcp(nJob, 5000)
chk("metrics answers 200", StzFindFirst("200 OK", cMet) > 0)
chk("request timer exported as a summary", StzFindFirst("# TYPE http_request_ms summary", cMet) > 0)
chk("requests counter exported with _total", StzFindFirst("http_requests_total", cMet) > 0)
chk("the watched rss gauge is in the same exposition", StzFindFirst("process_memory_rss", cMet) > 0)

? ""
? "-- Scene 4: a handler that raises becomes a counted 500 --"
oSrv.Get_("/boom", func oReq, oResp { stzraise("deliberate failure") })
cReq = "GET /boom HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cBoom = oClient.AwaitTcp(nJob, 5000)
chk("the client saw the 500", StzFindFirst("500 Internal Server Error", cBoom) > 0)
chk("the errors counter counted it", oMon.MetricQ("http.errors").Value() = 1)
chk("...and the request was still timed", oMon.MetricQ("http.request.ms").Count() >= 9)
oSrv.Stop()

? ""
? "-- Scene 5: an UNOBSERVED server is unchanged (zero-cost when off) --"
oSrv2 = new stzAppServer()
oSrv2.Get_("/plain", func oReq, oResp { oResp.Text("ok") })
oSrv2.Start(0, "127.0.0.1")
cReq = "GET /metrics HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv2.Port(), cReq)
oSrv2.ServeOne(3000)
cNo = oClient.AwaitTcp(nJob, 5000)
chk("no monitor -> /metrics is an honest 404", StzFindFirst("404 Not Found", cNo) > 0)
cReq = "GET /health HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv2.Port(), cReq)
oSrv2.ServeOne(3000)
cH2 = oClient.AwaitTcp(nJob, 5000)
chk("unobserved /health still carries the senses", StzFindFirst('"rss_bytes":', cH2) > 0)
chk("...but no p95 (nothing measures requests)", StzFindFirst('"p95_ms":', cH2) = 0)
oSrv2.Stop()

? ""
? "-- Scene 6: the backend's ledger now carries the crossing's COST --"
oT = new stzAppTopology("restolean")
oT.AddDatasetQ("orders", [ [ "Tajine", 1 ] ])
oT.SetDatasetColumnsQ("orders", [ "dish", "qty" ])
oT.SetPartRoleQ(:phone, "menu", "orders")
oT.SetPartRoleQ(:admin, "dashboard", "orders")
oB = new stzAppBackend("restolean", oT)
oB.Start(0)
oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
oB.Rows(:admin, "orders")
aTr = oB.Traffic()
? "  last crossing: " + aTr[len(aTr)][2] + " " + aTr[len(aTr)][3] + " -> " + aTr[len(aTr)][4] + " in " + aTr[len(aTr)][5] + " ms"
chk("traffic rows carry five columns now", len(aTr[1]) = 5)
chk("the crossing cost is a positive ms number", aTr[len(aTr)][5] > 0)
chk("LastMs() reads the same cost", oB.LastMs() = aTr[len(aTr)][5])
chk("MeanCrossingMs() averages the ledger", oB.MeanCrossingMs() > 0)

? ""
? "-- Scene 7: a governance refusal costs an honest ZERO --"
oB.SetActor(GuardianActor("watcher"))
bRaised = FALSE
try
	oB.Create(:phone, "orders", [ [ "dish", "Brik" ], [ "qty", 1 ] ])
catch
	bRaised = TRUE
done
aTr = oB.Traffic()
chk("the non-effectful actor was refused (raise)", bRaised)
chk("the refusal is ledgered with status 403", aTr[len(aTr)][4] = 403)
chk("...and cost 0 ms -- it never crossed", aTr[len(aTr)][5] = 0)
oB.Stop()

? ""
? "-- Scene 8: pipeline stages carry their durations --"
oPipe = new stzComputePipeline("doc-intake")
oPipe.Stage(:vision, "ocr", func x { return StzReplace(x, "scan:", "") })
oPipe.Stage(:nlp, "entities", func x {
	_s_ = ""
	for _k_ = 1 to 120000
		_s_ += "x"
	next
	return x + " [entities]"
})
oPipe.Stage(:search, "index", func x { return x + " [indexed]" })
cOut = oPipe.Run("scan:acme invoice")
chk("the pipeline still runs", cOut = "acme invoice [entities] [indexed]")
aTrace = oPipe.Trace()
chk("trace rows carry four columns now", len(aTrace[1]) = 4)
aDur = oPipe.StageDurations()
? "  stage costs: " + aDur[1][1] + "=" + aDur[1][2] + "ms, " + aDur[2][1] + "=" + aDur[2][2] + "ms, " + aDur[3][1] + "=" + aDur[3][2] + "ms"
chk("the busy stage is the visible bottleneck", aDur[2][2] > aDur[1][2] and aDur[2][2] > aDur[3][2])
chk("TotalMs() sums the stages", fabs(oPipe.TotalMs() - (aDur[1][2] + aDur[2][2] + aDur[3][2])) < 0.001)

? ""
? "-- Scene 8b: the round trip is FAST (the timer-resolution fix holds) --"
# Windows sleeps at the default timer resolution round up to ~15.6ms,
# which once made an in-process round trip cost ~22ms of wall for
# ~1.5ms of CPU (the await paths' 1-2ms poll-sleeps stalled). The
# reactor now requests 1ms resolution at creation (reactor.zig,
# timeBeginPeriod) and a trip runs ~5ms. Generous threshold by design:
# well above the measured ~5, well below the pathological ~22.
oSrvF = new stzAppServer()
oSrvF.Get_("/ping", func oReq, oResp { oResp.Text("pong") })
oSrvF.Start(0, "127.0.0.1")
cReqF = "GET /ping HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrvF.Port(), cReqF)
oSrvF.ServeOne(3000)
oClient.AwaitTcp(nJob, 5000)          # warm-up trip
nW0 = StzEngineWatchTimestampMs()
for i = 1 to 10
	nJob = oClient.SubmitTcp("127.0.0.1", oSrvF.Port(), cReqF)
	oSrvF.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
nPerTrip = (StzEngineWatchTimestampMs() - nW0) / 10
? "  mean round trip = " + nPerTrip + " ms"
chk("a warm in-process round trip stays under 15ms wall", nPerTrip < 15)
oSrvF.Stop()

? ""
? "-- Scene 9: cross-world crossings are timed, refusals included --"
oSuper = new stzSuperApp("hq")
bOut = oSuper.CallAcross("nowhere", "elsewhere", "ping")
chk("the crossing was refused (no such worlds)", bOut = FALSE)
chk("...but LEDGERED with its cost", oSuper.CrossingCount() = 1)
aX = oSuper.Crossings()
chk("the row carries [from,to,action,allowed,ms]", len(aX[1]) = 5 and aX[1][4] = FALSE)
chk("LastCallMs() answers (>= 0)", oSuper.LastCallMs() >= 0)

oFed = new stzComputeFederation("fed")
cR = oFed.FederatedCall("caller", "nlp", "/work", "")
chk("federation refused (no host offers nlp)", cR = "" and oFed.CallLastStatus() = -1)
chk("...and the refusal was timed", oFed.LastCallMs() >= 0)

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
