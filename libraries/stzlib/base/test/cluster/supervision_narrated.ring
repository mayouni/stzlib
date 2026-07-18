load "../../stzBase.ring"
load "../_narrated.ring"

# R8.4 (the SCALE plane) -- FACET BREADTH + cluster SUPERVISION.
#
# TWO points. FIRST: NLP and Math are NOT the only facets of Softanza --
# the SCALE plane specializes workers along the FULL Softanza breadth
# (text/list/table/graph/knowledge/learning/neural/datetime/reactive/
# agentic/refine/code/data/search/...), every one engine-native except
# vision (the sole polyglot facet). SECOND: the fleet is supervised on
# REAL metrics (health / dead / draining per profile), not the old
# random() monitor: self-heal dead workers, elastic scale to a policy,
# graceful drain -- and the supervisor is itself a SUPERVISED JOB on
# stzAgentHost (R5), managing the cluster on the same reactor loop.

# clock-derived base port so back-to-back runs don't collide (workers
# linger until TTL)
$nBase = 48000 + (StzEngineTimeNowMs() % 800)

Scenario("BREADTH: specialization spans the full facet catalog")
	Given("a fresh facet catalog (the deployment's competence registry)")
	oCat = new stzFacetCatalog()
	Then("it is far broader than the doc's four", oCat.NumberOf() >= 15, TRUE)
	Then("graph is a known facet", oCat.Has(:graph), TRUE)
	Then("knowledge is a known facet", oCat.Has(:knowledge), TRUE)
	Then("neural is a known facet", oCat.Has(:neural), TRUE)
	Then("table/list/datetime/reactive/agentic all present",
		oCat.Has(:table) and oCat.Has(:list) and oCat.Has(:datetime) and
		oCat.Has(:reactive) and oCat.Has(:agentic), TRUE)
	Then("every facet is engine-native EXCEPT vision (polyglot)",
		oCat.IsPolyglot(:graph) = FALSE and oCat.IsPolyglot(:neural) = FALSE and
		oCat.IsPolyglot(:vision) = TRUE, TRUE)

	Given("a cluster specialized along NON-doc facets")
	oC = new stzAppCluster()
	oC.WithFacet(:graph, 2).WithFacet(:knowledge, 1).WithFacet(:neural, 1)
	Then("four workers across three facets", oC.FleetSize(), 4)
	Then("the pool serves :prove (a knowledge capability)",
		oC.PoolQ().ProfileFor(:prove), "knowledge")
	Then("and :embed (a neural capability)", oC.PoolQ().ProfileFor(:embed), "neural")
EndScenario()

Scenario("a pool can seed one profile per catalog facet")
	oFull = new stzWorkerPool()
	oFull.SeedAllFacets(2)
	Then("one profile per facet", oFull.NumberOfProfiles(), oFull.CatalogQ().NumberOf())
	Then("vision is polyglot in it", oFull.ProfileQ("vision").IsPolyglot(), TRUE)
	Then("graph is not", oFull.ProfileQ("graph").IsPolyglot(), FALSE)
EndScenario()

Scenario("AUTOSCALE POLICY (pure): decisions from real metrics")
	Given("a supervisor with a graph policy [min 1, max 3], water 0.25/0.75")
	oC2 = new stzAppCluster()
	oC2.WithFacet(:graph, 2)
	$oSup = new stzClusterSupervisor(oC2)
	$oSup.Policy(:graph, 1, 3).SetWaterMarks(0.25, 0.75)

	When("load is HIGH and below max")
	$oSup.ReportLoad(:graph, 0.9)
	aUp = $oSup.Decide([ [ :tag = "graph", :ready = 2, :dead = 0 ] ])
	Then("it decides to SCALE UP", This_Has(aUp, :scaleup, "graph"), TRUE)

	When("load is LOW and above min")
	$oSup.ReportLoad(:graph, 0.1)
	aDn = $oSup.Decide([ [ :tag = "graph", :ready = 2, :dead = 0 ] ])
	Then("it decides to SCALE DOWN", This_Has(aDn, :scaledown, "graph"), TRUE)

	When("already at min under low load")
	aMin = $oSup.Decide([ [ :tag = "graph", :ready = 1, :dead = 0 ] ])
	Then("it does NOT scale below min", This_Has(aMin, :scaledown, "graph"), FALSE)

	When("a worker is dead")
	aDead = $oSup.Decide([ [ :tag = "graph", :ready = 1, :dead = 1 ] ])
	Then("it decides to RESTART", This_Has(aDead, :restart, "graph"), TRUE)
EndScenario()

Scenario("REAL health: a live fleet reports healthy; supervision heals via spawn")
	# NOTE: the DECISION to restart a dead worker is proven by the pure
	# Decide(:restart) test above; the restart MECHANISM (RestartDead) is
	# the SAME real spawn path as ScaleUp, proven in the elastic-scale
	# scenario below. Here we prove the live-health read is real.
	Given("a knowledge worker cluster")
	$oHeal = new stzAppCluster()
	$oHeal.WithFacet(:knowledge, 1).SetWorkerTTL(15000).SetBasePort($nBase)
	$oHeal.Start()
	Then("it comes up ready", $oHeal.WaitReady(20000), 1)
	When("we health-check the live fleet")
	nReady = $oHeal.HealthCheck()
	Then("HealthCheck reports the worker ready (real /health probe)", nReady, 1)
	Then("and no dead workers", $oHeal.DeadCount(), 0)
	When("the supervisor runs against a healthy cluster")
	oSupH = new stzClusterSupervisor($oHeal)
	oSupH.Policy(:knowledge, 1, 2).ReportLoad(:knowledge, 0.5)
	aAct = oSupH.Supervise()
	Then("it takes no action on a healthy, mid-load cluster", len(aAct), 0)
	$oHeal.Stop()
EndScenario()

Scenario("REAL elastic scale + graceful drain")
	Given("a graph cluster with 1 worker")
	$oEl = new stzAppCluster()
	$oEl.WithFacet(:graph, 1).SetWorkerTTL(15000).SetBasePort($nBase + 40)
	$oEl.Start()
	$oEl.WaitReady(20000)
	Then("one graph worker ready", $oEl.WorkersOf("graph"), 1)

	When("the supervisor scales UP under high load")
	$oEl.ScaleUp("graph")
	nR = $oEl.WaitReady(20000)
	Then("now two graph workers", $oEl.WorkersOf("graph"), 2)
	Then("both are ready", nR, 2)

	When("load drops and one worker is drained")
	nPort = $oEl.ScaleDown("graph")
	Then("a worker was drained (returns its port)", nPort > 0, TRUE)
	aM = $oEl.FleetMetrics()
	Then("metrics show one draining", This_MetricField(aM, "graph", :draining), 1)
	Then("routing still works (skips the draining worker)",
		StzFindFirst("graph:done", $oEl.Route("graph", "/work?q=x")) > 0, TRUE)
	$oEl.Stop()
EndScenario()

Scenario("R5 COMPOSITION: the supervisor runs as a supervised reactor job")
	Given("a graph cluster and a supervisor with a satisfied policy")
	$oJob = new stzAppCluster()
	$oJob.WithFacet(:graph, 1).SetWorkerTTL(15000).SetBasePort($nBase + 80)
	$oJob.Start()
	$oJob.WaitReady(20000)
	oSupJ = new stzClusterSupervisor($oJob)
	oSupJ.SetName("graph-supervisor").Policy(:graph, 1, 2)
	oSupJ.ReportLoad(:graph, 0.5)        # mid-band: no scale action

	When("stzAgentHost supervises it and ticks it on the reactor")
	oHost = new stzAgentHost()
	oHost.Supervise(oSupJ, 60)
	oHost.RunFor(220)
	Then("the supervisor ticked as a job", oHost.TicksOf("graph-supervisor") >= 1, TRUE)
	oHost.Shutdown()
	$oJob.Stop()
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

func This_Has(aActions, cKind, cTag)
	for i = 1 to len(aActions)
		if aActions[i][1] = cKind and aActions[i][2] = cTag
			return TRUE
		ok
	next
	return FALSE

func This_MetricField(aMetrics, cTag, cField)
	for i = 1 to len(aMetrics)
		if aMetrics[i][:tag] = cTag
			return aMetrics[i][cField]
		ok
	next
	return -1
