load "../../stzBase.ring"
load "../_narrated.ring"

# R8 RATE LIMITING -- admission control at the front door (resilience rung
# #3). Where load-isolation caps a facet's CONCURRENCY and backpressure caps
# the QUEUE behind a busy worker, rate limiting caps the request RATE over
# TIME per key -- a flooding client is shed with a 429 BEFORE it reaches (or
# exhausts) the fleet. Token bucket (engine stz_resilience.dll): a bucket of
# `burst` tokens refilling at `rate`/sec absorbs short bursts, caps the
# sustained rate. Units are deterministic; the LIVE scenario spawns a worker.

# =====================================================================
#  UNIT: the token-bucket limiter (deterministic where no time elapses)
# =====================================================================

Scenario("an unconfigured key is unlimited")
	Given("a fresh limiter")
	$oRL = new stzRateLimiter("front")
	Then("a key with no SetLimit always admits", $oRL.Allow("ghost"), TRUE)
	Then("its available tokens read as -1 (unlimited)", $oRL.Available("ghost"), -1)
	Then("it has no limit configured", $oRL.HasLimit("ghost"), FALSE)
EndScenario()

Scenario("a bucket admits up to its burst, then sheds")
	Given("a key limited to 1/s with a burst of 5")
	oL = new stzRateLimiter("b")
	oL.SetLimit("nlp", 1, 5)
	When("8 requests arrive back-to-back (no time to refill)")
	nA = 0  nR = 0
	for i = 1 to 8
		if oL.Allow("nlp")  nA++ else nR++ ok
	next
	Then("exactly the burst (5) were admitted", nA, 5)
	Then("the overflow (3) was shed", nR, 3)
	Then("the allowed count is tracked", oL.AllowedCount("nlp"), 5)
	Then("the rejected count is tracked", oL.RejectedCount("nlp"), 3)
	Then("the bucket is essentially empty (< 1 token)", oL.Available("nlp") < 1, TRUE)
	oL.Destroy()
EndScenario()

Scenario("the bucket refills over time")
	Given("a key limited to 100/s, burst 5, fully drained")
	oF = new stzRateLimiter("r")
	oF.SetLimit("nlp", 100, 5)
	for i = 1 to 5  oF.Allow("nlp")  next
	Then("immediately, the next request is shed", oF.Allow("nlp"), FALSE)
	When("~120ms passes (100/s => ~12 tokens, capped at the burst)")
	oT = new stzReactor()
	nJ = oT.SubmitTimer(120)
	oT.AwaitTimer(nJ, 500)
	Then("the bucket has refilled (tokens available again)", oF.Available("nlp") >= 1, TRUE)
	Then("and admits once more", oF.Allow("nlp"), TRUE)
	oT.Destroy()
	oF.Destroy()
EndScenario()

Scenario("keys are independent -- one flooded key never starves another")
	Given("nlp limited to burst 2, math limited to burst 2")
	oI = new stzRateLimiter("i")
	oI.SetLimit("nlp", 1, 2)
	oI.SetLimit("math", 1, 2)
	When("nlp is flooded with 5 requests")
	for i = 1 to 5  oI.Allow("nlp")  next
	Then("nlp is now shedding", oI.Allow("nlp"), FALSE)
	Then("but math is untouched -- still admits its full burst",
		oI.Allow("math") and oI.Allow("math"), TRUE)
	Then("math sheds only after ITS own burst", oI.Allow("math"), FALSE)
	oI.Destroy()
EndScenario()

Scenario("re-configuring a key replaces its bucket cleanly")
	Given("a key limited then re-limited wider")
	oC2 = new stzRateLimiter("c")
	oC2.SetLimit("nlp", 1, 1)
	oC2.Allow("nlp")
	Then("the tight bucket sheds", oC2.Allow("nlp"), FALSE)
	When("the key is re-limited to a burst of 4")
	oC2.SetLimit("nlp", 1, 4)
	Then("the fresh bucket admits its new burst", oC2.Allow("nlp"), TRUE)
	Then("only one key exists (replaced, not duplicated)", len(oC2.Keys()), 1)
	oC2.Destroy()
EndScenario()

# =====================================================================
#  WIRING: the cluster sheds over-limit requests at the front door
# =====================================================================

Scenario("Route sheds over-limit requests with a distinct -429, before any worker")
	Given("a cluster: graph rate-limited (burst 3), nlp unlimited, neither started")
	$oCl = new stzAppCluster()
	$oCl.WithFacet(:graph, 1).WithFacet(:nlp, 1)
	$oCl.WithRateLimit(:graph, 1, 3)
	When("6 graph requests are routed")
	nLimited = 0  nNoWorker = 0
	for i = 1 to 6
		$oCl.Route("graph", "/work")
		if $oCl.RouteLastStatus() = -429  nLimited++  ok
		if $oCl.RouteLastStatus() = -1    nNoWorker++ ok
	next
	Then("the burst (3) passed the limiter (then declined -1: no worker)", nNoWorker, 3)
	Then("the overflow (3) was rate-limited (-429), not -1", nLimited, 3)
	Then("the cluster counts the rate-limited sheds", $oCl.RateLimitedCount("graph"), 3)
	Then("the Why names the rate limit", StzFindFirst($oCl.Why(), "rate limited") = 1, TRUE)

	When("the unlimited nlp facet is flooded")
	nBad = 0
	for i = 1 to 20
		$oCl.Route("nlp", "/work")
		if $oCl.RouteLastStatus() = -429  nBad++  ok
	next
	Then("nlp is NEVER rate-limited (no limit configured)", nBad, 0)
EndScenario()

Scenario("rate-limited requests are observable (traced, no latency sample)")
	Given("a rate-limited-then-flooded facet")
	$oCl2 = new stzAppCluster()
	$oCl2.WithFacet(:math, 1).WithRateLimit(:math, 1, 2)
	When("5 requests are routed")
	for i = 1 to 5  $oCl2.Route("math", "/x")  next
	Then("all 5 are traced (2 no-worker + 3 limited)", $oCl2.TelemetryQ().NumberOfTraces(), 5)
	Then("none added a latency sample (all 0-attempt)", $oCl2.TelemetryQ().LatencyCount("math"), 0)
	Then("the last shed carries the -429 status", $oCl2.RecentTraces(1)[1][4], -429)
EndScenario()

# =====================================================================
#  LIVE: a real worker, protected by a rate limit, recovers on refill
# =====================================================================

Scenario("LIVE: a rate limit protects a real worker and recovers on refill")
	Given("one real nlp worker limited to 1/s, burst 3")
	$nBase = 44000 + (StzEngineTimeNowMs() % 900)
	$oLive = new stzAppCluster()
	$oLive.WithNLP(1).WithWorkerTTL(15000).WithBasePort($nBase)
	$oLive.WithRateLimit(:nlp, 1, 3)
	$oLive.Start()
	nReady = $oLive.WaitReady(25000)
	Then("the worker is ready", nReady, 1)

	When("6 requests arrive in a burst")
	nOK = 0  nLimited = 0
	for i = 1 to 6
		cR = $oLive.Route("nlp", "/work?q=ping")
		if $oLive.RouteLastStatus() = 200    nOK++      ok
		if $oLive.RouteLastStatus() = -429   nLimited++ ok
	next
	Then("only the burst (3) reached the worker and were served", nOK, 3)
	Then("the rest (3) were shed at the front door", nLimited, 3)
	Then("the worker never saw the shed load (latency samples = served)",
		$oLive.TelemetryQ().LatencyCount("nlp"), 3)

	When("~1.2s passes and one more request arrives")
	nJ = $oLive.ReactorQ().SubmitTimer(1200)
	$oLive.ReactorQ().AwaitTimer(nJ, 2000)
	$oLive.Route("nlp", "/work?q=again")
	Then("the refilled bucket admits it and the worker serves it",
		$oLive.RouteLastStatus(), 200)

	$oLive.Stop()
EndScenario()

Summary()
