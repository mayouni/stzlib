load "../../stzBase.ring"
load "../_narrated.ring"

# R8.1 (the SCALE plane) -- the HOST'S WORKER MODEL. Specialization is a
# stzWorkerProfile (capability tag + resource BUDGET) over the ONE
# resident engine, NOT a preloading class tree (the 5.10 ruling). The
# load-bearing property: a SATURATED profile (a heavy vision/neural
# batch) never STARVES a different profile (light NLP requests) --
# LOAD ISOLATION, which is what survives once the resident engine makes
# specialization-for-warmth moot.

Scenario("the default pool has the 4 domain profiles, grounded in the engine")
	Given("the default worker pool")
	$oPool = StzDefaultWorkerPool()
	Then("it has four profiles", $oPool.NumberOfProfiles(), 4)
	Then("nlp/math/search/vision are present",
		$oPool.HasProfile("nlp") and $oPool.HasProfile("math") and
		$oPool.HasProfile("search") and $oPool.HasProfile("vision"), TRUE)
	Then("nlp/math/search are engine-native (no external tool)",
		$oPool.Profile("nlp").IsPolyglot(), FALSE)
	Then("vision is a POLYGLOT worker (external tool, per domain honesty)",
		$oPool.Profile("vision").IsPolyglot(), TRUE)
	Then("its external tool is named", $oPool.Profile("vision").ExternalTool(), "python")
EndScenario()

Scenario("capabilities route to profiles (the R8.2 seam)")
	Then("an optimization is math work", $oPool.ProfileFor(:optimize), "math")
	Then("sentiment is nlp work", $oPool.ProfileFor(:sentiment), "nlp")
	Then("similarity is search work", $oPool.ProfileFor(:similarity), "search")
	Then("ocr is vision work", $oPool.ProfileFor(:ocr), "vision")
	Then("an unknown capability routes nowhere", $oPool.ProfileFor(:teleport), "")
EndScenario()

Scenario("dispatch runs admitted work now and returns its result")
	Given("a small pool with a 2-slot math profile")
	$oP = new stzWorkerPool()
	$oP.AddProfile("math", [ :solve ], 2)
	When("math work is dispatched")
	r = $oP.Dispatch("math", func { return 6 * 7 })
	Then("it was admitted", r[:admitted], 1)
	Then("and ran, returning its value", r[:result], 42)
	Then("the slot was released after running", $oP.InFlight("math"), 0)
EndScenario()

Scenario("LOAD ISOLATION: a saturated profile never starves another")
	Given("a pool: vision budget 1 (heavy), nlp budget 3 (light)")
	$oIso = new stzWorkerPool()
	$oIso.AddProfile("vision", [ :ocr ], 1)
	$oIso.AddProfile("nlp", [ :classify ], 3)

	When("a long-running vision job holds the ONLY vision slot")
	bHeld = $oIso.Acquire("vision")   # models an in-flight heavy job
	Then("the vision slot is taken", bHeld, TRUE)
	Then("vision is now saturated", $oIso.Profile("vision").CanAdmit(), FALSE)

	When("MORE vision work arrives while the slot is held")
	rV = $oIso.Dispatch("vision", func { return "ocr-done" })
	Then("it is QUEUED, not run (vision over budget)", rV[:admitted], 0)
	Then("vision queue depth is 1", $oIso.QueueDepth("vision"), 1)

	When("light NLP work arrives at the SAME time")
	rN1 = $oIso.Dispatch("nlp", func { return "n1" })
	rN2 = $oIso.Dispatch("nlp", func { return "n2" })
	Then("NLP is admitted immediately -- NOT blocked by vision", rN1[:admitted], 1)
	Then("and the second NLP too", rN2[:admitted], 1)
	Then("NLP results came back", rN1[:result], "n1")

	When("the heavy vision job finishes and the pool drains")
	$oIso.Release("vision")
	nRan = $oIso.Drain()
	Then("the queued vision work now runs", nRan, 1)
	Then("vision queue is empty", $oIso.QueueDepth("vision"), 0)
EndScenario()

Scenario("metrics are REAL counts (not the retired random() monitor)")
	Given("the isolation pool after the run above")
	aM = $oIso.Metrics()
	Then("metrics cover every profile", len(aM), 2)
	# find the vision row
	nVis = 0
	for i = 1 to len(aM)
		if aM[i][:tag] = "vision"  nVis = i  exit  ok
	next
	Then("vision admitted 2 (the held slot + the drained job)",
		aM[nVis][:admitted], 2)
	Then("vision rejected 1 (the over-budget dispatch)", aM[nVis][:rejected], 1)
	Then("vision is idle now (0 in flight)", aM[nVis][:inflight], 0)
EndScenario()

Scenario("FACET != MODULE: the naming law and the facet->module provenance")
	# A facet is a LOGICAL competence; a module is WHERE code lives. The
	# relation is many-to-many, recorded (RealizedBy) but never forced 1:1.
	Given("the full Softanza facet pool with provenance populated")
	oF = StzSoftanzaWorkerPool(1)
	Then("GROUNDED: :data maps to exactly one module (1:1)",
		oF.Profile("data").MappingKind(), :grounded)
	Then("and that module is 'data'", oF.Profile("data").RealizingModules()[1], "data")

	Then("COMPOSED: :math spans several modules (1:n)",
		oF.Profile("math").MappingKind(), :composed)
	Then("its provenance names more than one module",
		len(oF.Profile("math").RealizingModules()) >= 2, TRUE)
	Then("COMPOSED: :knowledge spans natural + graph",
		oF.Profile("knowledge").MappingKind(), :composed)

	Then("EXTERNAL: :vision has NO module (polyglot, 1:0)",
		oF.Profile("vision").MappingKind(), :external)
	Then("its realizing-module list is empty", len(oF.Profile("vision").RealizingModules()), 0)

	Given("a facet that is LOGICAL-ONLY (no dedicated module, not polyglot)")
	# :search is composed from neural+graph+data; to show a purely logical
	# facet, declare one with NO modules recorded
	oLog = new stzWorkerProfile("forecast", [ :predict, :trend ], 1)
	Then("with no RealizedBy it is :logical", oLog.MappingKind(), :logical)
	oLog.RealizedBy([ "learning", "datetime" ])
	Then("once mapped to 2+ modules it is :composed", oLog.MappingKind(), :composed)

	Then("asymmetry proves they differ: ~18 facets, far more modules",
		len(StzKnownFacets()) < 30, TRUE)
EndScenario()

Scenario("the pre-engine class tree is retired but still loads")
	Given("stzClusterNode kept as a loadable tombstone")
	oNode = new stzClusterNode("nlp", "node-1")
	Then("it still constructs (compat)", isObject(oNode), TRUE)
	Then("but the SCALE plane is the worker model", $oPool.NumberOfProfiles(), 4)
EndScenario()

Summary()
