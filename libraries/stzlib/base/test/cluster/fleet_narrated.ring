load "../../stzBase.ring"
load "../_narrated.ring"

# R8.3 (the SCALE plane) -- THE FLEET: true horizontal scale. Ring's VM
# is single-threaded, so CPU-bound parallelism crosses PROCESSES. A
# cluster is a front host + a fleet of stzAppServer worker PROCESSES
# (each its own Ring VM + resident engine), launched via the reactor's
# async SPAWN (R7) and proxied via the reactor's async CURL (R7).
#
# This suite launches a SMALL REAL fleet (3 processes), health-waits,
# routes work round-robin, and tears down. Workers self-terminate on
# their TTL. (Not deterministic-instant: worker startup loads stzlib,
# so allow a health-wait window.)

# derive a base port from the clock so back-to-back runs (workers linger
# until their TTL) don't collide on the same ports
$nBase = 47000 + (StzEngineTimeNowMs() % 800)
$oC = new stzAppCluster()
$oC.WithNLP(2).WithMath(1).SetWorkerTTL(15000).SetBasePort($nBase)

Scenario("the fleet is declared as worker profiles (not a class tree)")
	Then("three workers are declared", $oC.FleetSize(), 3)
	Then("two are nlp", $oC.WorkersOf("nlp"), 2)
	Then("one is math", $oC.WorkersOf("math"), 1)
	Then("the pool tracks the profiles (R8.1 bookkeeping)",
		$oC.PoolQ().HasProfile("nlp") and $oC.PoolQ().HasProfile("math"), TRUE)
EndScenario()

Scenario("Start launches real worker PROCESSES that bind and go ready")
	When("the cluster starts and we wait for readiness")
	$oC.Start()
	nReady = $oC.WaitReady(25000)
	Then("all three worker processes became ready", nReady, 3)
	Then("each got its own port", len($oC.Ports()), 3)
EndScenario()

Scenario("requests are proxied to workers over real HTTP")
	When("nlp work is routed")
	cR = $oC.Route("nlp", "/work?q=hello")
	Then("a worker answered (HTTP 200)", $oC.RouteLastStatus(), 200)
	Then("the response came from an nlp worker", StzFindFirst(cR, "nlp:done:hello") > 0, TRUE)

	When("math work is routed")
	cM = $oC.Route("math", "/work?q=42")
	Then("a math worker answered", $oC.RouteLastStatus(), 200)
	Then("with the math tag", StzFindFirst(cM, "math:done:42") > 0, TRUE)
EndScenario()

Scenario("load is round-robined across a profile's workers")
	Given("two nlp workers and the /info route (reports the port)")
	# collect the ports that answer across several routes; with 2 workers
	# round-robin, we should see BOTH ports over 4 requests
	aSeen = []
	for i = 1 to 4
		cInfo = $oC.Route("nlp", "/info")
		# extract the "port":N value
		nP = StzFindFirst(cInfo, '"port":')
		if nP > 0
			cTail = StzMidToEnd(cInfo, nP + 7)
			nEnd = StzFindFirst(cTail, "}")
			cPort = StzLeft(cTail, nEnd - 1)
			if ring_find(aSeen, cPort) = 0
				aSeen + cPort
			ok
		ok
	next
	Then("both nlp workers received traffic (round-robin)", len(aSeen) >= 2, TRUE)
EndScenario()

Scenario("routing to an unknown profile fails cleanly")
	cX = $oC.Route("quantum", "/work")
	Then("no worker -> negative status, empty body", $oC.RouteLastStatus() < 200, TRUE)
	Then("body is empty", cX, "")
EndScenario()

Scenario("teardown stops the front host (workers self-exit on TTL)")
	$oC.Stop()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
