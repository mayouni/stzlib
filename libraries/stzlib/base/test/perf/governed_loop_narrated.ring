# The governed loop -- perf system P6, the final phase
# (SOFTANZA_PERF_SYSTEM.md). Monitor -> Alert -> Analyze -> OPTIMIZE.
#
# Four closures under test: the supervisor's load signal MEASURED
# (Profile.Load() = X/Xmax -> FeedLoadFrom) instead of hand-fed; the
# monitor pricing its own observation (SelfCost); the sentinel writing
# the FLIGHT RECORDER at breach time (notebook issue 7); and
# optimization as a GOVERNED act (stzPerfPlan: an inference-only actor
# may build and explain the plan, only an effectful actor commits --
# expression is free, admission is governed; every outcome audited).
#
# The plan executes against a rehearsal DOUBLE here (any object
# answering the same effectful verbs) -- the service-virtualization
# pattern: prove the crossing without spawning a fleet.
#
# Ring traps avoided: main code before the first func; ring_len inside
# classes; helper temps underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

$CRLF = char(13) + char(10)

pr()

? "-- Scene 1: the load signal is MEASURED, not hand-fed --"
oMon = StzPerfMonitor("api")
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/work", func oReq, oResp {
	_s_ = ""
	for _k_ = 1 to 20000
		_s_ += "x"
	next
	oResp.Text("done")
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
oP = StzPerfProfile(oMon)
for i = 1 to 10
	cReq = "GET /work HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oSrv.Stop()
nLoad = oP.LoadRatio()
? "  measured load = X/Xmax = " + nLoad
chk("load is a fraction of the ceiling (0 < L < 1)", nLoad > 0 and nLoad < 1)
# LoadRatio is LIVE in both directions (the interval grows -> X decays;
# any work between reads burns CPU -> D grows), so two successive
# reads differ by large RELATIVE amounts on a short interval. The
# guard asserts the range here; the exact-transfer property is proven
# with a frozen stub in Scene 2.

? ""
? "-- Scene 2: the measured load drives the supervisor's pure policy --"
oCluster = new stzAppCluster()
oSup = new stzClusterSupervisor(oCluster)
oSup.Policy(:nlp, 1, 4).SetWaterMarks(0.25, 0.75)
# Exact-transfer property, proven with a FROZEN stub (a live profile's
# ratio moves between the feed and the read):
oSup.FeedLoadFrom(:stub, new StubProfile)
chk("FeedLoadFrom carries LoadRatio() into the supervisor EXACTLY", oSup.LoadOf(:stub) = 0.42)
# ...and the real measured profile feeds a sane, decision-driving value:
oSup.FeedLoadFrom(:nlp, oP)
nFed = oSup.LoadOf(:nlp)
chk("the real measured load landed (0 < fed < 0.25, the scaledown zone)", nFed > 0 and nFed < 0.25)
aMetrics = [ [ :tag = "nlp", :total = 3, :ready = 3, :draining = 0, :dead = 0 ] ]
aActs = oSup.Decide(aMetrics)
chk("a lightly-loaded fleet decides SCALEDOWN (measured " + nLoad + " < 0.25)", len(aActs) = 1 and aActs[1][1] = :scaledown)

oSup.ReportLoad(:nlp, 0.9)
aActs = oSup.Decide(aMetrics)
chk("heavy load decides SCALEUP (0.9 > 0.75, ready < max)", len(aActs) = 1 and aActs[1][1] = :scaleup)
aMetricsDead = [ [ :tag = "nlp", :total = 3, :ready = 2, :draining = 0, :dead = 1 ] ]
aActs = oSup.Decide(aMetricsDead)
chk("a dead worker adds RESTART, healing first", aActs[1][1] = :restart)

? ""
? "-- Scene 3: observation prices ITSELF --"
oMonSelf = StzPerfMonitor("self")
oMonSelf.WatchMemory().WatchCpu().WatchSystemMemory()
for i = 1 to 20
	oMonSelf.Sample()
next
aCost = oMonSelf.SelfCost()
? "  " + aCost[:samples] + " samples cost " + aCost[:totalMs] + " ms total, " + aCost[:perSampleMs] + " ms each"
chk("SelfCost counted every sample", aCost[:samples] = 20)
chk("a full sampling pass costs under 1 ms (generous; measured far less)", aCost[:perSampleMs] < 1)
chk("...and the cost is a real positive number", aCost[:totalMs] > 0)

? ""
? "-- Scene 4: a plan proposes freely -- the catalog is closed --"
oPlan = StzPerfPlan("relieve-nlp")
oPlan.Propose(:ScaleUp, "nlp", "measured load 0.9 > high-water 0.75")
oPlan.Propose(:RestartDead, "nlp", "1 dead worker in FleetMetrics")
chk("two actions proposed", oPlan.NumberOfActions() = 2)
bRaised = FALSE
try
	oPlan.Propose(:DeleteEverything, "nlp", "chaos")
catch
	bRaised = TRUE
done
chk("an action outside the closed catalog refuses", bRaised)

? ""
? "-- Scene 5: the LLM may PROPOSE -- it may never COMMIT --"
oLlm = LLMActor("advisor")
oHuman = HumanActor("mansour")
oFake = new FakeCluster
chk("preflight: the inference-only actor may not commit", NOT oPlan.MayCommit(oLlm))
chk("preflight: the effectful human may", oPlan.MayCommit(oHuman))
nDone = oPlan.ExecuteOn(oFake, oLlm)
chk("execution by the LLM commits NOTHING", nDone = 0)
chk("...the double was never touched", oFake.CallCount() = 0)
chk("...and every action was audited REFUSED", oPlan.RefusedCount() = 2)
aAud = oPlan.AuditTrail()
chk("the refusal explains itself", StzFindFirst("admission is governed", aAud[1][6]) > 0)

? ""
? "-- Scene 6: the effectful actor commits -- audited, in order --"
nDone = oPlan.ExecuteOn(oFake, oHuman)
chk("the human committed both actions", nDone = 2)
chk("the double received scaleup then restartdead", oFake.Calls()[1][1] = "scaleup" and oFake.Calls()[2][1] = "restartdead")
chk("committed rows joined the same audit trail", oPlan.CommittedCount() = 2)
chk("the plan knows it crossed", oPlan.WasExecuted())

oPlanHeal = StzPerfPlan("heal-twice")
oPlanHeal.Propose(:RestartDead, "nlp", "first")
oPlanHeal.Propose(:RestartDead, "math", "second")
oFake2 = new FakeCluster
oPlanHeal.ExecuteOn(oFake2, oHuman)
chk("RestartDead heals ONCE per plan (all-dead in one pass)", oFake2.CallCount() = 1)

? ""
? "-- Scene 7: the flight recorder -- written AT breach time --"
oMonFly = StzPerfMonitor("flight")
oMonFly.WatchMemory()
oMonFly.Sample()
gL = oMonFly.NewGauge("load.level")
gL.Set(10)
oSlaFly = StzSla("flight-sla")
oSlaFly.ExpectValue("load.level").AtMost(100)
oSentFly = StzPerfSentinel(oSlaFly, oMonFly)
oSentFly.SetChannels("p6.breach", "p6.clear")
oSentFly.Check()
chk("no breach, no black box", len(oSentFly.BlackBox()) = 0)
gL.Set(900)
oSentFly.Check()
aBox = oSentFly.LastBlackBox()
chk("the breach photographed the process", len(oSentFly.BlackBox()) = 1)
chk("the box names the broken rule", StzFindFirst("load.level", aBox[:rule]) > 0)
chk("the box carries the senses (rss > 0)", aBox[:rssBytes] > 0)
chk("...and the cpu odometer", aBox[:cpuMs] > 0)
bFound = FALSE
for i = 1 to len(aBox[:metrics])
	if aBox[:metrics][i][1] = "load.level" and aBox[:metrics][i][3] = 900
		bFound = TRUE
	ok
next
chk("...and every metric's value at the moment of failure", bFound)

? ""
? "-- Scene 8: the full circle -- measure, judge, propose, govern, act --"
# The breach's finding becomes a plan; the LLM hands it over; the
# human commits; the fleet double scales. Monitor -> Alert -> Analyze
# -> Optimize, end to end, governed at the one crossing that matters.
# (The SENTINEL'S copy of the SLA did the judging -- one face drives;
# so judge freshly through our own face to read the finding.)
aF = oSlaFly.CheckAgainst(oMonFly)
oPlanFix = StzPerfPlan("fix-" + aF[1][:rule])
oPlanFix.Propose(:ScaleUp, "nlp", aF[1][:message])
chk("the plan carries the finding's own rationale", StzFindFirst("measured", oPlanFix.Actions()[1][3]) > 0)
oFake3 = new FakeCluster
chk("the advisor still cannot commit it", oPlanFix.ExecuteOn(oFake3, oLlm) = 0)
chk("the human closes the loop", oPlanFix.ExecuteOn(oFake3, oHuman) = 1 and oFake3.CallCount() = 1)

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

# A frozen profile double: LoadRatio() pinned, so the exact-transfer
# property of FeedLoadFrom is assertable (a live ratio moves).
class StubProfile
	def LoadRatio()
		return 0.42

# The rehearsal double: any object answering the plan's effectful
# verbs qualifies (the service-virtualization pattern).
class FakeCluster
	aFakeCalls = []

	def ScaleUp(pcTag)
		aFakeCalls + [ "scaleup", pcTag ]

	def ScaleDown(pcTag)
		aFakeCalls + [ "scaledown", pcTag ]

	def RestartDead()
		aFakeCalls + [ "restartdead", "" ]

	def Calls()
		return aFakeCalls

	def CallCount()
		return ring_len(aFakeCalls)
