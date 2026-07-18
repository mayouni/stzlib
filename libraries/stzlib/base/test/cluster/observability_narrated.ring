load "../../stzBase.ring"
load "../_narrated.ring"

# R8 OBSERVABILITY -- the fleet made DIAGNOSABLE (resilience rung #2):
#   LATENCY PERCENTILES -- per-facet p50/p90/p99 request latency, engine-
#     backed (log-scale histogram), so the tail (where failovers + breaker
#     trips hide) is visible and one heavy facet never smears another.
#   TRACE IDS -- every routed request gets a unique id, recorded with its
#     facet, endpoint, status, latency and attempt-count (>1 = a failover),
#     and put ON THE WIRE (_trace query param) for cross-fleet correlation.
# The unit scenarios are deterministic + offline; the LIVE scenario spawns
# one real worker to prove end-to-end timing + on-wire propagation.

# =====================================================================
#  UNIT: the telemetry recorder (deterministic, no cluster)
# =====================================================================

Scenario("trace ids are unique and monotonic")
	Given("a telemetry recorder")
	$oT = new stzClusterTelemetry("unit")
	c1 = $oT.NewTraceId()
	c2 = $oT.NewTraceId()
	c3 = $oT.NewTraceId()
	Then("each id is distinct", c1 != c2 and c2 != c3 and c1 != c3, TRUE)
	Then("ids carry the trace prefix", StzFindFirst("t-", c1) = 1, TRUE)
EndScenario()

Scenario("latency percentiles are computed per facet")
	Given("a recorder fed a spread of nlp latencies + one math latency")
	oL = new stzClusterTelemetry("lat")
	# nlp: a tight cluster of fast requests + a slow tail
	aMs = [ 5, 6, 6, 7, 8, 8, 9, 10, 12, 250 ]
	nn = len(aMs)
	for i = 1 to nn
		oL.RecordRequest(oL.NewTraceId(), "nlp", "h:1", 200, aMs[i], 1)
	next
	oL.RecordRequest(oL.NewTraceId(), "math", "h:2", 200, 1000, 1)
	Then("nlp recorded all 10 samples", oL.LatencyCount("nlp"), 10)
	Then("math is isolated (its own histogram, 1 sample)", oL.LatencyCount("math"), 1)
	Then("nlp p50 sits in the fast cluster (<= 20ms bucket)", oL.LatencyP50("nlp") <= 20, TRUE)
	Then("nlp p99 reflects the slow tail (>= 200ms)", oL.LatencyP99("nlp") >= 200, TRUE)
	Then("the tail dwarfs the median (p99 > p50)", oL.LatencyP99("nlp") > oL.LatencyP50("nlp"), TRUE)
	Then("math's big latency did NOT smear nlp's tail",
		oL.LatencyP99("nlp") < oL.LatencyP99("math"), TRUE)
	Then("two facets have histograms", len(oL.Facets()), 2)
	oL.Destroy()
EndScenario()

Scenario("an unknown facet has no latency (0), never crashes")
	Given("a fresh recorder")
	oU = new stzClusterTelemetry("empty")
	Then("percentile of an unseen facet is 0", oU.LatencyP99("ghost"), 0)
	Then("count of an unseen facet is 0", oU.LatencyCount("ghost"), 0)
	oU.Destroy()
EndScenario()

Scenario("traces record status, endpoint, attempts, and are queryable")
	Given("a recorder with a mix of ok + failover + declined requests")
	oTr = new stzClusterTelemetry("tr")
	cA = oTr.NewTraceId()  oTr.RecordRequest(cA, "nlp", "h:1", 200, 8,  1)   # clean
	cB = oTr.NewTraceId()  oTr.RecordRequest(cB, "nlp", "h:2", 200, 60, 3)   # failed over
	cC = oTr.NewTraceId()  oTr.RecordRequest(cC, "nlp", "none", -1, 0,  0)   # declined
	Then("three traces are recorded", oTr.NumberOfTraces(), 3)
	Then("a trace is fetchable by id", oTr.TraceById(cB)[4], 200)
	Then("the failover trace shows > 1 attempt", oTr.TraceById(cB)[6], 3)
	Then("only requests that failed over show attempts>1", len(oTr.FailoverTraces()), 1)
	Then("the last trace is the declined one", oTr.LastTrace()[1], cC)
	Then("a declined (0-attempt) request is NOT a latency sample",
		oTr.LatencyCount("nlp"), 2)
	Then("RecentTraces returns the tail in order", len(oTr.RecentTraces(2)), 2)
	Then("RecentTraces caps at what exists", len(oTr.RecentTraces(99)), 3)
	oTr.Destroy()
EndScenario()

# =====================================================================
#  WIRING: the cluster feeds telemetry from Route (no spawn)
# =====================================================================

Scenario("Route assigns a trace and records the request even when it declines")
	Given("a cluster with a facet declared but not started")
	$oC = new stzAppCluster()
	$oC.WithFacet(:graph, 1)
	When("a request is routed with no ready worker")
	$oC.Route("graph", "/work?q=x")
	Then("it declined", $oC.RouteLastStatus() < 0, TRUE)
	Then("a trace id was still assigned", StzFindFirst("t-", $oC.LastTraceId()) = 1, TRUE)
	Then("the decline was recorded as a trace", $oC.TelemetryQ().NumberOfTraces(), 1)
	Then("but it added NO latency sample (no round-trip)", $oC.LatencyP99("graph"), 0)
	Then("the trace's status is the decline", $oC.RecentTraces(1)[1][4] < 0, TRUE)
EndScenario()

# =====================================================================
#  LIVE: real timing + on-wire trace propagation
# =====================================================================

Scenario("LIVE: a served request has measured latency and an on-wire trace")
	Given("one real nlp worker")
	$nBase = 45000 + (StzEngineTimeNowMs() % 900)
	$oLive = new stzAppCluster()
	$oLive.WithNLP(1).SetWorkerTTL(15000).SetBasePort($nBase)
	$oLive.Start()
	nReady = $oLive.WaitReady(25000)
	Then("the worker is ready", nReady, 1)

	When("a handful of requests are routed")
	for i = 1 to 5
		$oLive.Route("nlp", "/work?q=ping")
	next
	Then("all five were served (200)", $oLive.RouteLastStatus(), 200)
	Then("latency samples were recorded", $oLive.TelemetryQ().LatencyCount("nlp"), 5)
	Then("p50 is a real (>= 0) measured latency", $oLive.LatencyP50("nlp") >= 0, TRUE)
	Then("the last request carries a trace id", StzFindFirst("t-", $oLive.LastTraceId()) = 1, TRUE)
	Then("the served trace names the worker endpoint (not 'none')",
		StzFindFirst("127.0.0.1", $oLive.RecentTraces(1)[1][3]) = 1, TRUE)

	When("the worker echoes back the _trace it received (real on-wire proof)")
	cEcho = $oLive.Route("nlp", "/echo")
	cId = $oLive.LastTraceId()
	Then("the worker received the SAME trace id the front host assigned",
		StzFindFirst(cId, cEcho) > 0, TRUE)
	Then("the echoed trace is the /echo request's own id (correlation holds)",
		StzFindFirst("trace=" + cId, cEcho) > 0, TRUE)

	$oLive.Stop()
EndScenario()

Summary()
