load "../../stzBase.ring"

$CRLF = char(13) + char(10)
nAlerts = 0

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/menu", func oReq, oResp { oResp.Text("couscous") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 12
	cReq = "GET /menu HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next

oSla = StzSla("restolean-api")
oSla.Expect(:ResponseTimeP95).Under(200)
oSla.Expect(:Availability).AtLeast(99.9)
oSla.Expect(:ErrorRate).AtMost(0)
oSla.CheckAgainst(oMon)
oSla.Show()

? "== block 2 =="
oSrv.Get_("/boom", func oReq, oResp { stzraise("deliberate failure") })
cReq = "GET /boom HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
oClient.AwaitTcp(nJob, 5000)
aF = oSla.CheckAgainst(oMon)
oSla.Show()

? "== block 3 =="
oRep = new stzRuleReport("restolean-ci")
oRep.Ingest(aF)
oRep.Report()
? "IsSound() = " + oRep.IsSound()
oSrv.Stop()

? "== block 4 =="
oMon2 = StzPerfMonitor("shop")
gQ = oMon2.NewGauge("queue.depth")
aSteady = [ 10, 10.2, 9.8, 10.1, 9.9, 10, 10.05, 9.95, 10 ]
for i = 1 to len(aSteady)
	gQ.Set(aSteady[i])
next
oSla2 = StzSla("shop-sla")
oSla2.ExpectValue("queue.depth").AtMost(100)
oSla2.ExpectStable("queue.depth")
oSent = StzPerfSentinel(oSla2, oMon2)
oSent.OnBreach(func aFinding { nAlerts++ ? "  >> ALERT: " + aFinding[:message] })
oSent.OnClear(func cRule { ? "  >> recovered: " + cRule })
? "steady:  Check() fired " + oSent.Check() + " alert(s)"
gQ.Set(500)
? "spike:   Check() fired " + oSent.Check() + " alert(s)"
? "still:   Check() fired " + oSent.Check() + " alert(s) -- suppressed"
gQ.Set(10)
oSent.Check()
oBus = new stzEventBus()
? "alert log: " + len(oSent.AlertLog()) + " entries; bus count: " + oBus.EventCount("perf.breach")
