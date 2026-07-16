load "../../stzBase.ring"
load "../_narrated.ring"

# R8.5 (the SCALE plane) -- COMPUTATIONAL PIPELINES. A complex workflow
# becomes a chain of FACET stages: the doc's document pipeline
#   VISION (ocr) -> NLP (entities) -> KNOWLEDGE (compliance) -> SEARCH
# is DECLARED, and Run() threads an input through every stage in order
# (each stage's output feeds the next). With a worker pool attached,
# each stage is admitted into ITS facet's budget (R8.1 load isolation,
# per stage). Validated against a deployment's catalog (R8.2 competences).
# Deterministic + offline.

$oPipe = new stzComputePipeline("doc-intake")
$oPipe.Stage(:vision, "ocr",     func x { return StzReplace(x, "scan:", "") })
$oPipe.Stage(:nlp, "entities",   func x { return x + " [entities]" })
$oPipe.Stage(:knowledge, "comply", func x { return x + " [compliant]" })
$oPipe.Stage(:search, "index",   func x { return x + " [indexed]" })

Scenario("a workflow is a DECLARED chain of facet stages")
	Then("it has four stages", $oPipe.NumberOfStages(), 4)
	Then("the facet sequence is the routing contract",
		$oPipe.Facets()[1] = "vision" and $oPipe.Facets()[2] = "nlp" and
		$oPipe.Facets()[3] = "knowledge" and $oPipe.Facets()[4] = "search", TRUE)
	Then("it narrates the pipeline",
		$oPipe.Narrate(), "pipeline doc-intake: vision -> nlp -> knowledge -> search")
EndScenario()

Scenario("Run threads an input through every stage in order")
	Given("a scanned document")
	cOut = $oPipe.Run("scan:acme invoice")
	Then("vision stripped the scan prefix, then each stage appended",
		cOut, "acme invoice [entities] [compliant] [indexed]")
	Then("the trace records every stage", len($oPipe.Trace()), 4)
	Then("the first trace stage is the vision OCR",
		$oPipe.Trace()[1][1] = "vision" and $oPipe.Trace()[1][2] = "ocr", TRUE)
	Then("the last stage output IS the final output",
		$oPipe.Trace()[4][3], $oPipe.LastOutput())
EndScenario()

Scenario("each stage is admitted into ITS facet's budget (load isolation)")
	Given("a worker pool covering the pipeline's facets")
	oPool = new stzWorkerPool()
	oPool.AddFacetQ(:vision, 1).AddFacetQ(:nlp, 2).AddFacetQ(:knowledge, 1).AddFacet(:search, 1)
	$oPipe.SetPool(oPool)
	When("two documents run through the pipeline")
	$oPipe.Run("scan:doc-one")
	$oPipe.Run("scan:doc-two")
	Then("each facet was admitted once per run (read via the pipeline's pool)",
		$oPipe.PoolQ().ProfileQ("nlp").AdmittedCount(), 2)
	Then("vision too", $oPipe.PoolQ().ProfileQ("vision").AdmittedCount(), 2)
	Then("and every slot was released (no leak)",
		$oPipe.PoolQ().ProfileQ("nlp").InFlight(), 0)
EndScenario()

Scenario("RunBatch fans many inputs through the whole pipeline")
	aOut = $oPipe.RunBatch([ "scan:a", "scan:b", "scan:c" ])
	Then("three results come back", len(aOut), 3)
	Then("each went through the full chain",
		StzFindFirst(aOut[1], "a [entities] [compliant] [indexed]") = 1, TRUE)
	Then("and the third too",
		StzFindFirst(aOut[3], "c [entities] [compliant] [indexed]") = 1, TRUE)
EndScenario()

Scenario("a pipeline is VALIDATED against a deployment's catalog")
	Given("a catalog that does NOT offer the knowledge facet")
	oCat = new stzFacetCatalog()
	oCat.Drop(:knowledge)
	aUnknown = $oPipe.ValidateAgainst(oCat)
	Then("validation flags the missing facet", len(aUnknown), 1)
	Then("naming it", aUnknown[1], "knowledge")

	Given("the full catalog")
	oFull = new stzFacetCatalog()
	Then("the pipeline validates clean (all facets offered)",
		len($oPipe.ValidateAgainst(oFull)), 0)
EndScenario()

Scenario("a pipeline can specialize along NON-doc facets (breadth)")
	Given("a data-science pipeline: table -> learning -> search")
	oDS = new stzComputePipeline("ds")
	oDS.Stage(:table, "load",    func x { return x + " |cleaned" })
	oDS.Stage(:learning, "train", func x { return x + " |model" })
	oDS.Stage(:search, "publish", func x { return x + " |indexed" })
	Then("its facets are table/learning/search (not the doc's four)",
		oDS.Facets()[1] = "table" and oDS.Facets()[2] = "learning", TRUE)
	Then("it runs end to end", oDS.Run("dataset"), "dataset |cleaned |model |indexed")
EndScenario()

Summary()
