# Judgment -- perf system P4 (SOFTANZA_PERF_SYSTEM.md).
#
# stzSla: expectations declared fluently in the U/R/X/D vocabulary,
# judged against MEASURED numbers, verdicts emitted as findings in the
# unified rule shape (subject "perf") so a perf budget fails CI through
# stzRuleReport -- the ONE gate -- exactly like a security violation.
# stzPerfSentinel: edge-triggered alerts on transitions (a breach fires
# once, not four hundred times), event-bus fanout, agent-host contract.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

nMB = 1024 * 1024
$CRLF = char(13) + char(10)
nBreachSeen = 0
nClearSeen = 0

pr()

? "-- Scene 1: expectations declare fluently, and the grammar protects itself --"
oSla = StzSla("restolean-api")
oSla.Expect(:ResponseTimeP95).Under(200)
oSla.Expect(:Availability).AtLeast(99.9)
oSla.Expect(:Throughput).AtLeast(0.1)
chk("three expectations declared", oSla.NumberOfExpectations() = 3)

bRaised = FALSE
try
	oSla.Expect(:ErrorRate)
	oSla.Expect(:CpuUtilization)
catch
	bRaised = TRUE
done
chk("an OPEN expectation refuses a second Expect()", bRaised)
oSla2 = StzSla("x")
bRaised = FALSE
try
	oSla2.Under(5)
catch
	bRaised = TRUE
done
chk("a closer with nothing open refuses", bRaised)
bRaised = FALSE
try
	oSla2.Expect(:SomethingImaginary)
catch
	bRaised = TRUE
done
chk("an unknown subject refuses with the catalog", bRaised)

? ""
? "-- Scene 2: a healthy observed server MEETS its SLA --"
oMon = StzPerfMonitor("api-mon")
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/menu", func oReq, oResp { oResp.Text("couscous") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 8
	cReq = "GET /menu HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oSlaOk = StzSla("restolean-api")
oSlaOk.Expect(:ResponseTimeP95).Under(500)
oSlaOk.Expect(:Availability).AtLeast(99.9)
oSlaOk.Expect(:ErrorRate).AtMost(0)
aF = oSlaOk.CheckAgainst(oMon)
chk("the healthy system produced ZERO findings", len(aF) = 0)
chk("Passed() says met", oSlaOk.Passed())
chk("verdicts carry the ACTUALS (3 rows)", len(oSlaOk.Verdicts()) = 3)
? "  " + oSlaOk.Verdicts()[1][:message]

? ""
? "-- Scene 3: a breach becomes a finding in the UNIFIED rule shape --"
oSlaTight = StzSla("impossible")
oSlaTight.Expect(:ResponseTimeP95).Under(0.000001)
aF = oSlaTight.CheckAgainst(oMon)
chk("one breach found", len(aF) = 1)
chk("finding carries :rule", StzFindFirst("response-time-p95-under-", aF[1][:rule]) = 1)
chk("finding subject is 'perf'", aF[1][:subject] = "perf")
chk("finding :where names sla/metric", StzFindFirst("impossible/http.request.ms", aF[1][:where]) > 0)
chk("finding severity is error", aF[1][:severity] = "error")
chk("finding message carries the measured actual", StzFindFirst("measured", aF[1][:message]) > 0)

? ""
? "-- Scene 4: the perf budget joins THE one CI gate --"
oRep = new stzRuleReport("ci")
oRep.Ingest(aF)
chk("the report is UNSOUND -- the build fails on a p95 regression", NOT oRep.IsSound())
chk("the perf subject is visible in the gate", len(oRep.FindingsOfSubject("perf")) = 1)
chk("it is an error-severity finding", len(oRep.Errors()) = 1)

? ""
? "-- Scene 5: AsWarning() advises without failing the gate --"
oSlaWarn = StzSla("advisory")
oSlaWarn.Expect(:ResponseTimeP95).Under(0.000001).AsWarning()
aFW = oSlaWarn.CheckAgainst(oMon)
chk("the warning breach still reports", len(aFW) = 1 and aFW[1][:severity] = "warning")
oRep2 = new stzRuleReport("ci2")
oRep2.Ingest(aFW)
chk("...but the gate stays SOUND (warnings advise)", oRep2.IsSound())

? ""
? "-- Scene 6: an SLA that cannot SEE is broken, not satisfied --"
oBlind = StzPerfMonitor("blind")
oSlaBlind = StzSla("blind-check")
oSlaBlind.Expect(:ResponseTimeP95).Under(200)
aFB = oSlaBlind.CheckAgainst(oBlind)
chk("the unmeasured expectation is an ERROR finding", len(aFB) = 1 and aFB[1][:severity] = "error")
chk("...that says NOT MEASURED, never a silent pass", StzFindFirst("NOT MEASURED", aFB[1][:message]) > 0)

? ""
? "-- Scene 7: a real 500 moves ErrorRate and Availability --"
oSrv.Get_("/boom", func oReq, oResp { stzraise("deliberate failure") })
cReq = "GET /boom HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
oClient.AwaitTcp(nJob, 5000)
oSlaAvail = StzSla("availability-check")
oSlaAvail.Expect(:Availability).AtLeast(99.9)
oSlaAvail.Expect(:ErrorRate).AtMost(5)
aFA = oSlaAvail.CheckAgainst(oMon)
? "  " + oSlaAvail.Verdicts()[1][:message]
chk("1 error in 9 requests breaches 99.9% availability", len(aFA) = 2)
chk("availability verdict names the shortfall", StzFindFirst("availability", aFA[1][:rule]) > 0)
oSrv.Stop()

? ""
? "-- Scene 8: your own metrics judged -- value bound and STABILITY --"
oMon2 = StzPerfMonitor("shop")
gQ = oMon2.NewGauge("queue.depth")
gQ.Set(10)
gQ.Set(10.2)
gQ.Set(9.8)
gQ.Set(10.1)
gQ.Set(9.9)
gQ.Set(10)
gQ.Set(10.05)
gQ.Set(9.95)
gQ.Set(10)
oSlaQ = StzSla("shop-sla")
oSlaQ.ExpectValue("queue.depth").AtMost(100)
oSlaQ.ExpectStable("queue.depth")
aFQ = oSlaQ.CheckAgainst(oMon2)
chk("a steady queue passes both (value + stability)", len(aFQ) = 0)

gQ.Set(500)
aFQ = oSlaQ.CheckAgainst(oMon2)
? "  after the spike: " + oSlaQ.Verdicts()[2][:message]
chk("the spike breaches BOTH: over the bound and an outlier", len(aFQ) = 2)
chk("the stability rule names the metric", StzFindFirst("stable-queue.depth", aFQ[2][:rule]) > 0)

? ""
? "-- Scene 9: the slow-leak budget -- growth per hour, judged --"
oMon3 = StzPerfMonitor("leaky")
oMon3.WatchMemory()
aKeep = []
for i = 1 to 8
	aKeep + copy("y", 4 * nMB)
	oMon3.Sample()
next
oSlaLeak = StzSla("leak-check")
oSlaLeak.Expect(:MemoryGrowthPerHour).Under(1)
aFL = oSlaLeak.CheckAgainst(oMon3)
? "  " + oSlaLeak.Verdicts()[1][:message]
chk("the watched leak breaches a 1-byte/hour budget", len(aFL) = 1)
aKeep = []

? ""
? "-- Scene 10: the sentinel alerts on TRANSITIONS, not repetitions --"
oMon4 = StzPerfMonitor("sentinel-mon")
gS = oMon4.NewGauge("load.level")
gS.Set(10)
oSlaS = StzSla("sentinel-sla")
oSlaS.ExpectValue("load.level").AtMost(100)
oSent = StzPerfSentinel(oSlaS, oMon4)
oSent.SetChannels("guard.breach", "guard.clear")
oSent.OnBreach(func aFinding { nBreachSeen++ })
oSent.OnClear(func cRule { nClearSeen++ })
oBus = new stzEventBus()

chk("healthy: a check fires nothing", oSent.Check() = 0 and NOT oSent.IsBreached())
gS.Set(900)
chk("the breach fires ONCE on appearance", oSent.Check() = 1)
chk("the callback saw it", nBreachSeen = 1)
chk("one active breach", len(oSent.ActiveBreaches()) = 1)
chk("...fanned out on the event bus", oBus.EventCount("guard.breach") = 1)
chk("STILL breached: no re-fire (flap suppression)", oSent.Check() = 0)
chk("callback count unchanged", nBreachSeen = 1)
gS.Set(50)
oSent.Check()
chk("recovery fired the clear callback once", nClearSeen = 1)
chk("...and the clear channel", oBus.EventCount("guard.clear") = 1)
chk("no active breaches after recovery", NOT oSent.IsBreached())
gS.Set(900)
chk("a NEW breach after recovery re-fires", oSent.Check() = 1 and nBreachSeen = 2)
chk("the alert log kept the story (breach, clear, breach)", len(oSent.AlertLog()) = 3)
chk("the last alert is the re-breach", oSent.LastAlert()[2] = "breach")

? ""
? "-- Scene 11: the sentinel wears the agent-host contract --"
chk("Name_() answers", oSent.Name_() = "perf-sentinel")
oSent.Every(60)
nC1 = oSent.Cycle()
nC2 = oSent.Cycle()
chk("Cycle() is cadence-gated like the monitor", isNumber(nC1) and nC2 = 0)

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
