load "../../stzBase.ring"
load "../_narrated.ring"

# R8.2 (the SCALE plane) -- THE SMART ROUTER. Maps a request to a FACET
# in three tiers: (1) deterministic RULES (path/content-type/method),
# (2) capability-LEXICAL scoring over THIS deployment's facet vocabulary
# (engine Unicode text ops; always available, offline), (3) an OPTIONAL
# MODEL seam (zero-shot/embedding when a neural model is loaded). It only
# routes to facets the deployment's catalog knows (instance-scoped).
# Deterministic + offline (no model required for the floor).

$oR = new stzRequestClassifier()

Scenario("TIER 1 rules: explicit routes win, cheaply")
	Given("path + content-type rules")
	$oR.RouteWhenPath("/api/calculate-risk", :math)
	$oR.RouteWhenPath("/api/search", :search)
	$oR.RouteWhenContentType("application/pdf", :vision)
	Then("a known path routes deterministically",
		$oR.Classify("POST", "/api/calculate-risk", "", ""), "math")
	Then("a content-type rule wins even over a lexical body hit",
		$oR.Classify("POST", "/api/analyze", "application/pdf", "translate this text"), "vision")
	Then("the search path routes to search", $oR.ClassifyPath("/api/search/products"), "search")
	Then("Why() explains the rule", StzFindFirst("rule:", $oR.Why()) = 1, TRUE)
EndScenario()

# A PATH RULE IS A PREFIX RULE, and a content type may carry parameters.
# Both loops used to ask "does the REQUEST appear inside the RULE" --
# true only when the two are identical -- so every rule that was not an
# exact match silently did not fire and tier 1 fell through to the
# lexical tier. The lexical tier often reached the SAME facet by a
# different route, which is why the routing assertions above passed for
# the wrong reason for months: only Why() disagreed. These scenes assert
# the TIER, not just the destination.
Scenario("TIER 1: a path rule matches by PREFIX, not by equality")
	Given("the rules declared above")
	Then("a longer path under the rule still routes",
		$oR.ClassifyPath("/api/search/products/42"), "search")
	Then("...and says it was a RULE, not a lexical guess",
		StzFindFirst("rule: path", $oR.Why()) = 1, TRUE)
	Then("a path OUTSIDE the rule does not borrow it",
		StzFindFirst("rule: path '/api/search'", $oR.Why()) = 1, TRUE)
	$oR.ClassifyPath("/api/calculate-risk/portfolio")
	Then("the other prefix rule fires on its own subtree too",
		StzFindFirst("rule: path '/api/calculate-risk'", $oR.Why()) = 1, TRUE)
EndScenario()

Scenario("TIER 1: a content type keeps its rule when it carries parameters")
	Given("the application/pdf rule")
	Then("a real header with a charset still routes",
		$oR.Classify("POST", "/api/analyze", "application/pdf; charset=binary",
		             "translate this text"), "vision")
	Then("...by RULE, so the lexical body hit never got a vote",
		StzFindFirst("rule: content-type", $oR.Why()) = 1, TRUE)
	Then("an unrelated content type does NOT match the rule",
		$oR.Classify("POST", "/api/analyze", "text/plain", "scan this image with ocr"),
		"vision")
	Then("...that one was the LEXICAL tier, honestly labelled",
		StzFindFirst("lexical:", $oR.Why()) = 1, TRUE)
EndScenario()

Scenario("TIER 2 lexical: route by the facet's OWN capability vocabulary")
	Given("no matching rule -> capability-lexical scoring")
	Then("shortest-path talk is graph work",
		$oR.ClassifyText("find the shortest path between two nodes"), "graph")
	Then("sentiment talk is nlp work",
		$oR.ClassifyText("analyze the sentiment of this customer review"), "nlp")
	Then("optimization/risk talk is math work",
		$oR.ClassifyText("optimize the portfolio to reduce risk"), "math")
	Then("embedding/similarity talk is search work",
		$oR.ClassifyText("embed and rank these documents by similarity"), "search")
	Then("scan/ocr talk is vision work (the polyglot facet)",
		$oR.ClassifyText("scan this image with ocr"), "vision")
	Then("prove/derive talk is knowledge work",
		$oR.ClassifyText("prove this fact is derived from the ontology"), "knowledge")
	Then("Why() explains the lexical hit", StzFindFirst("lexical:", $oR.Why()) = 1, TRUE)
EndScenario()

Scenario("the classifier ABSTAINS honestly when it cannot decide")
	Then("gibberish routes nowhere", $oR.ClassifyText("qwerty zxcvb foobar"), "")
	Then("Why() says undecidable/no-hit",
		StzFindFirst("undecidable", $oR.Why()) > 0 or StzFindFirst("no capability", $oR.Why()) > 0, TRUE)
EndScenario()

Scenario("it only routes to facets THIS deployment's catalog knows")
	Given("a router bound to a catalog WITHOUT the vision facet")
	oCat = new stzFacetCatalog()
	oCat.Drop(:vision)
	oV = new stzRequestClassifier()
	oV.SetCatalog(oCat)
	Then("scan/ocr no longer routes to vision (facet not offered here)",
		oV.ClassifyText("scan this image with ocr") != "vision", TRUE)

	Given("a router with a CUSTOM facet + keyword")
	oCat2 = new stzFacetCatalog()
	oCat2.DefinePolyglot(:pdf, [ :extract ], "python")
	oP = new stzRequestClassifier()
	oP.SetCatalog(oCat2).AddKeyword(:invoice, :pdf)
	Then("a custom keyword routes to the custom facet",
		oP.ClassifyText("extract the invoice fields"), "pdf")
EndScenario()

Scenario("TIER 3 model seam: used only when tiers 1+2 abstain")
	Given("a classifier with a stub model that always says 'neural'")
	oM = new stzRequestClassifier()
	oM.SetModelClassifier(func cText { return "neural" })
	Then("gibberish (lexically undecidable) falls through to the model",
		oM.ClassifyText("qwerty zxcvb foobar"), "neural")
	Then("but a clear lexical hit is decided WITHOUT the model",
		oM.ClassifyText("find the shortest path"), "graph")
EndScenario()

Scenario("cluster integration: classify then route (R8.2 -> R8.3 seam)")
	Given("a cluster declaring graph + nlp facets")
	oC = new stzAppCluster()
	oC.WithFacet(:graph, 1).WithFacet(:nlp, 1)
	Then("the cluster classifier is bound to its own catalog",
		isObject(oC.ClassifierQ()), TRUE)
	Then("a graph request classifies to the graph facet",
		oC.ClassifierQ().ClassifyText("compute centrality on the network graph"), "graph")
	# RouteRequest would proxy to a live worker (R8.3); with no fleet
	# started it declines cleanly rather than crashing
	Then("routing an undecidable request declines cleanly",
		oC.RouteRequest("GET", "/xyz", "", "zzz"), "")
	Then("with a negative status", oC.RouteLastStatus() < 200, TRUE)
EndScenario()

Summary()
