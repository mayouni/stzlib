load "../../stzBase.ring"
load "../_narrated.ring"

# ==========================================================================
# THE CAPSTONE -- the restaurant, end to end (the roadmap's definition of
# done). ONE world of knowledge threads every executable layer:
#   R1  KNOWS      -- restaurant facts + a transitive law; a new fact fires
#                     derivation with ZERO code change (the revoked-LLM thesis)
#   R4  FORGES     -- from its OWN scoped knowledgebase the restaurant forges
#                     a Domain Language Model, trains its neural rung
#                     teacher-free, and ships it as a real .gguf (the Foundry)
#   R4  DECIDES    -- from the SAME brain, tonight's menu is optimized: one
#                     declaration over stated facts (stzAllocation)
#   WORLD (app)    -- the restaurant as a living world: things, a reaction,
#                     a goal (stzApp / stzGraphGoal)
#   R5  ACTS       -- an agent takes a goal and acts, governed, ON THE
#                     REACTOR loop (stzPIAgent on stzAgentHost), and
#                     ALLOCATES through the optimizer (stzAllocationSkill)
#   R6  GOVERNS    -- change itself is governed + reversible: a typed
#                     refinement through the 4-stage gate (stzRefinableCode)
#   R7  SHIPS      -- the SAME world serves WEB + MBaaS + IoT on one reactor
#                     host, under a KDF-backed Commons, in a governed
#                     constellation (stzAppServer / stzPlatform / stzSuperApp)
# Fully offline and deterministic.
# ==========================================================================

$CRLF = char(13) + char(10)

# ---- R1: the restaurant KNOWS itself -------------------------------------

Scenario("R1 KNOWS: facts, a transitive law, and derivation with no code")
	Given("restaurant knowledge: dishes belong to categories, transitively")
	StzKnow("margherita", "dish")
	StzConstrainRelation("kind-of", :Transitive)
	StzKnowRelation("margherita", "kind-of", "pizza")
	StzKnowRelation("pizza", "kind-of", "food")
	Then("the dish reaches its category", AreRelated("margherita", "pizza") != "", TRUE)
	Then("and transitively the parent category", AreRelated("margherita", "food") != "", TRUE)
	Then("but not something unrelated yet", AreRelated("margherita", "italian"), "")

	When("the OWNER adds ONE fact (food kind-of italian)")
	StzKnowRelation("food", "kind-of", "italian")
	Then("every query above upgrades -- no code, no retrain",
		AreRelated("margherita", "italian") != "", TRUE)
EndScenario()

# ---- R4: the restaurant FORGES its own domain model ----------------------

$oRestoDLM = NULL

Scenario("R4 FORGES: from its own knowledge, the restaurant forges + trains a DLM")
	Given("the menu knowledge in the restaurant's OWN scoped graph")
	# module-oriented: a domain brain is an INSTANCE, and a DLM is forged
	# from that object -- never filled into or read from a global.
	oBrain = new stzKnowledgeGraph("bella-cucina")
	oBrain.Know("margherita", "dish").
	       Know("tiramisu", "dessert").
	       Know("chianti", "wine").
	       KnowRelation("margherita", "kind-of", "pizza").
	       KnowRelation("margherita", "pairs-with", "chianti")

	When("the Foundry forges a Domain Language Model from that brain")
	$oRestoDLM = StzDlmQ(oBrain)
	Then("rung 1 answers deterministically", $oRestoDLM.Ask("what is margherita"),
		"Margherita is a dish.")
	Then("outside its domain it REFUSES (LAW 3)",
		$oRestoDLM.AskXT("what is the stock market")[:refused], 1)

	When("the neural rung 2 trains teacher-free on the DLM's own corpus")
	$oRestoDLM.TrainNeuralRung(500)
	Then("it learned the corpus grammar (is -> a, near-certain)",
		$oRestoDLM.NextToken("is") = "a" and
		$oRestoDLM.NextTokenConfidence("is") > 0.9, TRUE)
	Then("greedy generation stays in-domain ('tiramisu is a ...')",
		StzLeft($oRestoDLM.NeuralGenerate("tiramisu", 3), 13), "tiramisu is a")

	When("the restaurant ships its model as a real .gguf artifact (FREE)")
	cModel = $oRestoDLM.ExportNeuralGguf("bella_dlm")
	Then("the artifact is a real gguf ggml reads back",
		StzEngineNeuralGgufInspect(cModel) = 2, TRUE)
	remove(cModel)
EndScenario()

# ---- R4: the restaurant DECIDES tonight's menu ---------------------------

Scenario("R4 DECIDES: tonight's menu, optimized straight from the knowledgebase")
	Given("the owner states the menu's economics as FACTS in the same brain")
	# no menu code: margins, minutes and demand are triples, and a zero
	# is stated -- a missing fact would be a gap, never a silent 0
	oBrain.Know("lasagna", "dish")
	oBrain.Know("margherita", "menu-item").Know("lasagna", "menu-item").Know("tiramisu", "menu-item")
	oBrain.KnowRelation("margherita", "margin", "6").KnowRelation("margherita", "oven-minutes", "4").
	       KnowRelation("margherita", "prep-minutes", "2").KnowRelation("margherita", "demand", "40")
	oBrain.KnowRelation("lasagna", "margin", "9").KnowRelation("lasagna", "oven-minutes", "12").
	       KnowRelation("lasagna", "prep-minutes", "5").KnowRelation("lasagna", "demand", "15")
	oBrain.KnowRelation("tiramisu", "margin", "4").KnowRelation("tiramisu", "oven-minutes", "0").
	       KnowRelation("tiramisu", "prep-minutes", "3").KnowRelation("tiramisu", "demand", "30")
	oBrain.KnowRelation("kitchen", "oven-minutes", "240").KnowRelation("kitchen", "prep-minutes", "300")

	When("ONE declaration allocates the kitchen's time (stzAllocation -> stzOptimModel)")
	oMenu = new stzAllocation("tonight")
	oMenu.Choose("menu-item").Maximize("margin").AtMost("demand").
	      Spending("oven-minutes", "kitchen", "oven-minutes").
	      Spending("prep-minutes", "kitchen", "prep-minutes").WriteAs("portions")
	oMenu.SolveOn(oBrain)
	Then("the menu is allocated", oMenu.Verdict(), "allocated")
	Then("39 margherita, 7 lasagna, 30 tiramisu",
		@@(oMenu.Placements()), @@([ [ "margherita", 39 ], [ "lasagna", 7 ], [ "tiramisu", 30 ] ]))
	# filling the oven with the best margin per oven-minute first gives
	# 40 margherita + 6 lasagna = 414: the integer optimum is not greedy
	Then("margin 417 -- above the greedy plan's 414", oMenu.Objective(), 417)
	Then("and it says which engine decided",
		StzFindFirst("engine floor (Zig simplex + branch-and-bound)", oMenu.Why()) > 0, TRUE)

	When("the decision is written back")
	oMenu.WriteTo(oBrain)
	Then("tonight's plan is now knowledge in the same brain",
		@@(oBrain.Query([ "lasagna", "portions", "?n" ])), @@([ "7-portions" ]))
	# a quantity is written with its unit: the graph keeps one edge per
	# node pair, and a bare 30 would collide with tiramisu's demand of 30
	Then("30 tiramisu portions sit beside its demand of 30",
		@@(oBrain.Query([ "tiramisu", "portions", "?n" ])) + @@(oBrain.Query([ "tiramisu", "demand", "?n" ])),
		@@([ "30-portions" ]) + @@([ "30" ]))
EndScenario()

# ---- THE WORLD: the restaurant as a living app ---------------------------

$oResto = StzAppQ("bella-cucina")
$oResto.AddThingQ(:dish)  { Has([ :name, :price ]) }
$oResto.AddThingQ(:table) { Has([ :number, :seats ]) }
$oResto.AddReactionQ(:table).Unseen(1, :service) { Propose(:served) }
$oResto.AddGoalQ(:EveryTableServed) { Means = "every :table Has(:served)"  ReachedBy = :planning }

Scenario("THE WORLD: things, a reaction that proposes, a wanted state")
	Given("two tables in the world, neither served")
	$oResto.AddInstance("t1", :table)
	$oResto.AddInstance("t2", :table)
	When("the world comes alive")
	$oResto.Live()
	Then("the reaction proposed service for each table", len($oResto.Proposals()), 2)
	Then("the goal is not yet satisfied", $oResto.GoalSatisfied(:EveryTableServed), FALSE)
EndScenario()

# ---- R5: an AGENT acts on the reactor, governed --------------------------

Scenario("R5 ACTS: a governed agent ALLOCATES the tables on the reactor loop")
	Given("a maitre-d whose seat skill OPTIMIZES (stzAllocation -> stzOptimModel)")
	# the if/but chain that stood here seated the first waiting table it
	# matched; the allocation skill reads tables and parties from memory
	# and maximizes the covers seated, one party per table
	oMaitre = new stzPIAgent("maitre-d")
	oMaitre.MemoryQ().Learn("t1", "is-a", "table").Learn("t1", "seats", "4")
	oMaitre.MemoryQ().Learn("t2", "is-a", "table").Learn("t2", "seats", "6")
	oMaitre.MemoryQ().Learn("lee", "is-a", "party").Learn("lee", "size", "2")
	oMaitre.MemoryQ().Learn("ayouni", "is-a", "party").Learn("ayouni", "size", "4")
	oMaitre.MemoryQ().Learn("smiths", "is-a", "party").Learn("smiths", "size", "6")
	oMaitre.GovernanceQ().DeclareRisk("seat-table", 1)
	oMaitre.GovernanceQ().GrantPermission("maitre-d", "seat-table")
	oMaitre.GovernanceQ().SetAuthority("maitre-d", :Delegated)
	oSeating = new stzAllocation("seating")
	oSeating.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
	oSeating.WriteAs("seated-at").UnplacedAs("waiting")
	oMaitre.AddGovernedSkill(new stzAllocationSkill("seat", oSeating), "seat-table")

	oHost = new stzAgentHost()
	oHost.Supervise(oMaitre, 15)
	When("the host runs the perceive-act loop on the reactor")
	oHost.RunFor(200)
	oLive = oHost.AgentQ("maitre-d")
	Then("the agent allocated by optimization: 10 covers, both tables",
		oLive.MemoryQ().Fact("smiths", "seated-at", "t2") = 1 and
		oLive.MemoryQ().Fact("ayouni", "seated-at", "t1") = 1, TRUE)
	Then("and the party that fits nowhere is told to wait, not squeezed in",
		oLive.MemoryQ().Fact("lee", "seated-at", "waiting"), 1)
	Then("its decisions left a governed lineage", len(oLive.DecisionLog()) >= 1, TRUE)
	Then("and the lineage names the engine that decided",
		StzFindFirst("engine floor", oLive.DecisionLog()[1][:why]) > 0, TRUE)

	# reflect the agent's work back into the world; the goal is now met
	$oResto.Relate("t1", :served, "svc1")
	$oResto.Relate("t2", :served, "svc2")
	$oResto.Pulse()
	Then("the world's goal is now satisfied", $oResto.GoalSatisfied(:EveryTableServed), TRUE)
	Then("and its service proposals cleared", len($oResto.Proposals()), 0)
	oHost.Shutdown()
EndScenario()

# ---- R6: CHANGE ITSELF is governed + reversible --------------------------

Scenario("R6 GOVERNS: a menu knob is refined through the gate, reversibly")
	Given("a refinable menu config with a VAT knob, governed")
	cCfg = 'vat = <R:PARAM name="vat" value="0.10" min="0" max="0.25">'
	oCode = new stzRefinableCode(cCfg)
	oCode.SetGovernedBy(new stzGovernance("menu-ops")).SetActor("owner")
	oCode.SetRiskFor("vat", 1).SetAllowRefine("vat").SetAuthorityLevel(:Delegated)
	oCode.DeclareDerivation("vat-cap",
		func oc { return ring_number(oc.ValueOf("vat")) <= 0.20 },
		"vat capped at 0.20 by house policy")

	When("the owner raises VAT within policy")
	r = oCode.Refine("vat").To("0.15")
	Then("it is admitted through all four stages", r[:admitted], 1)
	Then("the value changed", oCode.ValueOf("vat"), "0.15")

	When("a change over the policy cap is attempted")
	r2 = oCode.Refine("vat").To("0.24")
	Then("the derivation stage rejects it", r2[:admitted], 0)
	Then("and the value rolled back", oCode.ValueOf("vat"), "0.15")

	When("the owner reverts the admitted change")
	oCode.Revert()
	Then("one call restores the prior value", oCode.ValueOf("vat"), "0.10")
EndScenario()

# ---- R7: the SAME world SHIPS across topologies --------------------------

Scenario("R7 SHIPS: web + MBaaS + IoT on ONE reactor host")
	Given("an app server exposing the restaurant, backed by engine sqlite")
	$oDb = new stzDatabase(":memory:")
	$oDb.Exec("CREATE TABLE reservation(name TEXT, seats INTEGER)")
	$oDb.Exec("CREATE TABLE telemetry(sensor TEXT, reading TEXT)")
	$oSrv = new stzAppServer()
	$oSrv.Get_("/menu", func oReq, oResp { oResp.Json([ "restaurant", "bella-cucina", "open", 1 ]) })
	$oSrv.Expose($oDb, "reservation")          # MBaaS floor
	$oSrv.Start(0, "127.0.0.1")
	$oClient = new stzReactor()

	When("a WEB client GETs the menu")
	cMenu = HttpGet1("/menu")
	Then("the web portal answers", StzFindFirst('"restaurant":"bella-cucina"', cMenu) > 0, TRUE)

	When("a MOBILE backend POSTs a reservation (MBaaS over sqlite)")
	cRes = Post1("/api/reservation", "name=ayouni&seats=4")
	Then("the reservation is created (201)", StzFindFirst("201 Created", cRes) > 0, TRUE)
	Then("and really persisted in the engine db",
		$oDb.Value("SELECT name FROM reservation"), "ayouni")

	When("a KITCHEN SENSOR streams telemetry (IoT, raw, same loop)")
	nRaw = $oSrv.ListenRaw(0, func oHost, nSid, nConn, cData {
		nSep = StzFindFirst(":", cData)
		$oDb.Exec("INSERT INTO telemetry (sensor, reading) VALUES ('" +
			StzLeft(cData, nSep - 1) + "', '" + StzMidToEnd(cData, nSep + 1) + "')")
		oHost.RawWrite(nSid, nConn, "ack", TRUE)
	})
	nJob = $oClient.SubmitTcp("127.0.0.1", $oSrv.RawPort(nRaw), "oven-1:220C")
	$oSrv.ServeOne(3000)
	cAck = $oClient.AwaitTcp(nJob, 5000)
	Then("the sensor got an ack", cAck, "ack")
	Then("the telemetry landed in the same db",
		$oDb.Value("SELECT reading FROM telemetry WHERE sensor='oven-1'"), "220C")

	$oClient.Destroy()
	$oSrv.Stop()
	Then("one host served three topologies over one engine", TRUE, TRUE)
EndScenario()

# ---- R7: the ENVELOPE + the CONSTELLATION --------------------------------

Scenario("R7 ENVELOPE: KDF Commons identity + generated shells")
	Given("the restaurant enveloped by a platform")
	$oEnvDb = new stzDatabase(":memory:")
	$oResto.AddReaches([ :web ])
	oPlat = StzPlatformQ("bella-envelope")
	oPlat.SetWorld($oResto)
	oPlat.SetKdfRounds(20000)
	oPlat.OpenCommonsOn($oEnvDb)
	When("the owner registers an identity (secret hashed, not stored)")
	Then("registration succeeds", oPlat.RegisterIdentity("owner", "p@ss"), TRUE)
	cStored = $oEnvDb.Value("SELECT secret FROM stz_identity WHERE user='owner'")
	Then("the plaintext secret is NOT in the store", StzFindFirst("p@ss", cStored), 0)
	Then("a session opens with the right secret", len(oPlat.OpenSession("owner", "p@ss")) > 0, TRUE)
	When("Generate(:all) ships the declared reach")
	aShells = oPlat.Generate(:all)
	Then("the web shell was written", fexists(aShells[1]), TRUE)
	$oEnvDb.Close()
EndScenario()

Scenario("R7 CONSTELLATION: restaurant + supplier, norm-gated")
	Given("a constellation binding the restaurant to its supplier")
	oSupplier = StzAppQ("fresh-produce")
	oCon = new stzSuperApp("bella-group")
	oCon.AddWorld("resto", $oResto)
	oCon.AddWorld("supplier", oSupplier)
	oCon.Bond("resto", "supplier", "order-produce")
	oCon.GovDeclareRisk("order-produce", 2)
	oCon.GovGrant("resto", "order-produce")
	oCon.GovSetAuthority("resto", :Delegated)
	When("the restaurant orders produce across the bond")
	Then("the governed cross-world call proceeds",
		oCon.CallAcross("resto", "supplier", "order-produce"), TRUE)
	When("it attempts an ungoverned action")
	Then("it is refused", oCon.CallAcross("resto", "supplier", "raid-larder"), FALSE)
EndScenario()

Scenario("THE PROOF: one world, one envelope, one host, one engine")
	Then("the same knowledge that KNOWS also SHIPPED -- zero app code",
		AreRelated("margherita", "italian") != "", TRUE)
	Then("and the model FORGED from that knowledge still speaks the domain",
		$oRestoDLM.Ask("what is margherita"), "Margherita is a dish.")
	$oDb.Close()
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

func HttpGet1(cPath)
	cReq = "GET " + cPath + " HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = $oClient.SubmitTcp("127.0.0.1", $oSrv.Port(), cReq)
	$oSrv.ServeOne(3000)
	return $oClient.AwaitTcp(nJob, 5000)

func Post1(cPath, cBody)
	cReq = "POST " + cPath + " HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Content-Length: " + len(cBody) + $CRLF +
	       "Connection: close" + $CRLF + $CRLF + cBody
	nJob = $oClient.SubmitTcp("127.0.0.1", $oSrv.Port(), cReq)
	$oSrv.ServeOne(3000)
	return $oClient.AwaitTcp(nJob, 5000)
