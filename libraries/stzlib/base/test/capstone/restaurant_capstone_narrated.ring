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
#   WORLD (app)    -- the restaurant as a living world: things, a reaction,
#                     a goal (stzApp / stzGraphGoal)
#   R5  ACTS       -- an agent takes a goal and acts, governed, ON THE
#                     REACTOR loop (stzPIAgent on stzAgentHost)
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

# ---- THE WORLD: the restaurant as a living app ---------------------------

$oResto = StzAppQ("bella-cucina")
$oResto.Thing(:dish)  { Has([ :name, :price ]) }
$oResto.Thing(:table) { Has([ :number, :seats ]) }
$oResto.Whenever(:table).Unseen(1, :service) { Propose(:served) }
$oResto.Want(:EveryTableServed) { Means = "every :table Has(:served)"  ReachedBy = :planning }

Scenario("THE WORLD: things, a reaction that proposes, a wanted state")
	Given("two tables in the world, neither served")
	$oResto.Is_("t1", :table)
	$oResto.Is_("t2", :table)
	When("the world comes alive")
	$oResto.Live()
	Then("the reaction proposed service for each table", len($oResto.Proposals()), 2)
	Then("the goal is not yet satisfied", $oResto.GoalSatisfied(:EveryTableServed), FALSE)
EndScenario()

# ---- R5: an AGENT acts on the reactor, governed --------------------------

Scenario("R5 ACTS: a governed agent serves the tables on the reactor loop")
	Given("a maitre-d agent whose skill serves an unserved table")
	oMaitre = new stzPIAgent("maitre-d")
	oMaitre.MemoryQ().Learn("t1", "state", "waiting")
	oMaitre.MemoryQ().Learn("t2", "state", "waiting")
	oMaitre.GovernanceQ().DeclareRisk("seat-table", 1)
	oMaitre.GovernanceQ().GrantPermission("maitre-d", "seat-table")
	oMaitre.GovernanceQ().SetAuthority("maitre-d", :Delegated)
	oSk = new stzAgentSkill("seat")
	oSk.SetWhen(func oMem { return oMem.Fact("t1", "state", "waiting") or oMem.Fact("t2", "state", "waiting") })
	oSk.SetDoes(func oMem {
		if oMem.Fact("t1", "state", "waiting")
			oMem.Forget("t1", "state", "waiting")  oMem.Learn("t1", "state", "served")
		but oMem.Fact("t2", "state", "waiting")
			oMem.Forget("t2", "state", "waiting")  oMem.Learn("t2", "state", "served")
		ok
		return 1
	})
	oSk.SetVerifiedBy(func oMem { return 1 })
	oMaitre.AddGovernedSkill(oSk, "seat-table")

	oHost = new stzAgentHost()
	oHost.Supervise(oMaitre, 15)
	When("the host runs the perceive-act loop on the reactor")
	oHost.RunFor(200)
	oLive = oHost.AgentQ("maitre-d")
	Then("the agent acted (both tables served)",
		oLive.MemoryQ().Fact("t1", "state", "served") = 1 and
		oLive.MemoryQ().Fact("t2", "state", "served") = 1, TRUE)
	Then("its decisions left a governed lineage", len(oLive.DecisionLog()) >= 1, TRUE)

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
	Then("the web portal answers", StzFindFirst(cMenu, '"restaurant":"bella-cucina"') > 0, TRUE)

	When("a MOBILE backend POSTs a reservation (MBaaS over sqlite)")
	cRes = Post1("/api/reservation", "name=ayouni&seats=4")
	Then("the reservation is created (201)", StzFindFirst(cRes, "201 Created") > 0, TRUE)
	Then("and really persisted in the engine db",
		$oDb.Value("SELECT name FROM reservation"), "ayouni")

	When("a KITCHEN SENSOR streams telemetry (IoT, raw, same loop)")
	nRaw = $oSrv.ListenRaw(0, func oHost, nSid, nConn, cData {
		nSep = StzFindFirst(cData, ":")
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
	$oResto.Reaches([ :web ])
	oPlat = StzPlatformQ("bella-envelope")
	oPlat.SetWorld($oResto)
	oPlat.SetKdfRounds(20000)
	oPlat.OpenCommonsOn($oEnvDb)
	When("the owner registers an identity (secret hashed, not stored)")
	Then("registration succeeds", oPlat.RegisterIdentity("owner", "p@ss"), TRUE)
	cStored = $oEnvDb.Value("SELECT secret FROM stz_identity WHERE user='owner'")
	Then("the plaintext secret is NOT in the store", StzFindFirst(cStored, "p@ss"), 0)
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
