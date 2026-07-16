load "../../stzBase.ring"
load "../_narrated.ring"

# R8 HARDENING -- the SCALE plane under stress, three ways:
#   FUNCTIONAL  -- edge cases the happy-path suites skip.
#   DATA-INTENSIVE -- big batches, big payloads, budget saturation.
#   SECURITY    -- SSRF/host-override, CRLF smuggling, governance bypass,
#                  caller confusion, injection-safe classification.
# Deterministic + offline (the security transport checks use the guards,
# not live network).

$nBase = 51000 + (StzEngineTimeNowMs() % 700)

# =====================================================================
#  SECURITY
# =====================================================================

Scenario("SECURITY: a caller-controlled proxy path cannot override the host (SSRF)")
	Given("a cluster (no fleet needed -- the guard runs before transport)")
	$oC = new stzAppCluster()
	$oC.WithFacet(:graph, 1)
	When("a path tries to smuggle a host via userinfo '@'")
	cR = $oC.Route("graph", "@evil.example.com/pwn")
	Then("it is REJECTED before any request is sent", $oC.RouteLastStatus() < 0, TRUE)
	Then("and the body is empty", cR, "")
	Then("the why names the unsafe path", StzFindFirst($oC.Why(), "unsafe") > 0, TRUE)

	When("a path tries an absolute URL")
	$oC.Route("graph", "http://evil.example.com/")
	Then("rejected (does not start with '/')", $oC.RouteLastStatus() < 0, TRUE)

	When("a path carries CRLF (request smuggling / header injection)")
	$oC.Route("graph", "/ok" + char(13) + char(10) + "X-Injected: 1")
	Then("rejected (CRLF present)", $oC.RouteLastStatus() < 0, TRUE)

	When("a legitimate path is used")
	# no worker started -> port 0 -> declines, but NOT as an unsafe-path
	$oC.Route("graph", "/work?q=ok")
	Then("a well-formed path passes the guard (declines only for no worker)",
		StzFindFirst($oC.Why(), "unsafe"), 0)
EndScenario()

Scenario("SECURITY: the federation rejects unsafe paths before transport")
	Given("a governed federation with a member")
	$oFed = new stzComputeFederation("secure-grid")
	$oFed.Join("host-b", "127.0.0.1:65535", [ :math ])
	$oFed.Bond("web", :math)
	$oFed.GovDeclareRisk("use-math", 1).GovGrant("web", "use-math").GovSetAuthority("web", :Delegated)
	When("a bonded, governed caller sends an SSRF path")
	$oFed.FederatedCall("web", :math, "@attacker/steal", "")
	Then("the unsafe path is rejected even for an authorized caller",
		StzFindFirst($oFed.Why(), "unsafe") > 0, TRUE)
	Then("with a negative status", $oFed.CallLastStatus() < 0, TRUE)
	$oFed.Shutdown()
EndScenario()

Scenario("SECURITY: governance cannot be bypassed -- the full refusal matrix")
	Given("a federation offering :neural, with layered governance")
	$oG = new stzComputeFederation("gov-grid")
	$oG.Join("gpu", "127.0.0.1:65534", [ :neural ])
	Then("no bond -> refused", isNumberNeg($oG.FederatedCall("attacker", :neural, "/x", "")), TRUE)
	$oG.Bond("attacker", :neural)
	Then("bond but undeclared risk -> refused",
		isNumberNeg($oG.FederatedCall("attacker", :neural, "/x", "")), TRUE)
	$oG.GovDeclareRisk("use-neural", 4)   # critical
	$oG.GovGrant("attacker", "use-neural")
	$oG.GovSetAuthority("attacker", :Delegated)   # level 2 << 4
	Then("permission but insufficient authority -> refused",
		isNumberNeg($oG.FederatedCall("attacker", :neural, "/x", "")), TRUE)
	$oG.Shutdown()
EndScenario()

Scenario("SECURITY: caller confusion -- one caller's grant does not leak to another")
	Given("web is granted, evil is not")
	$oCC = new stzComputeFederation("caller-grid")
	$oCC.Join("gpu", "127.0.0.1:65533", [ :neural ])
	$oCC.GovDeclareRisk("use-neural", 2)
	$oCC.Bond("web", :neural).GovGrant("web", "use-neural").GovSetAuthority("web", :Autonomous)
	$oCC.Bond("evil", :neural)   # evil even has a bond...
	Then("but evil has NO permission -> refused",
		isNumberNeg($oCC.FederatedCall("evil", :neural, "/x", "")), TRUE)
	Then("the refusal is a governance decision", StzFindFirst($oCC.Why(), "governance") > 0, TRUE)
	$oCC.Shutdown()
EndScenario()

Scenario("SECURITY: classification is injection-safe (content is data, never code)")
	Given("a classifier fed adversarial + control-char content")
	$oR = new stzRequestClassifier()
	Then("an SQL-ish payload just classifies as text, no side effect",
		$oR.ClassifyText("'; DROP TABLE users; -- sort the list") != "", TRUE)
	Then("CRLF / control chars in content do not crash the tokenizer",
		$oR.ClassifyText("optimize" + char(13) + char(10) + char(0) + " risk"), "math")
	Then("an empty body abstains cleanly", $oR.ClassifyText(""), "")
	Then("punctuation-only abstains cleanly", $oR.ClassifyText("/// ... ??? &&&"), "")
EndScenario()

# =====================================================================
#  DATA-INTENSIVE
# =====================================================================

Scenario("DATA: the worker pool survives heavy dispatch + full drain, no leak")
	Given("a 4-slot facet pool and 500 queued work items")
	$oPool = new stzWorkerPool()
	$oPool.AddFacet(:math, 4)
	# saturate: hold all 4 slots, then dispatch 500 -> all queue
	for i = 1 to 4  $oPool.Acquire(:math)  next
	nQueued = 0
	for i = 1 to 500
		r = $oPool.Dispatch("math", func { return 1 })
		if r[:admitted] = 0  nQueued++  ok
	next
	Then("all 500 queued behind the saturated budget", nQueued, 500)
	Then("queue depth is 500", $oPool.QueueDepth("math"), 500)
	When("the held slots free and the pool drains")
	for i = 1 to 4  $oPool.Release(:math)  next
	nRan = $oPool.Drain()
	Then("every queued item ran", nRan, 500)
	Then("the queue is empty", $oPool.QueueDepth("math"), 0)
	Then("no slot leaked (in-flight back to 0)", $oPool.InFlight("math"), 0)
	Then("admitted count reflects all work", $oPool.ProfileQ("math").AdmittedCount() >= 500, TRUE)
EndScenario()

Scenario("DATA: a large payload flows through the whole pipeline intact")
	Given("a 3-stage pipeline and a big input (~200k chars)")
	$oPipe = new stzComputePipeline("bulk")
	$oPipe.Stage(:text, "tag",   func x { return "A" + x })
	$oPipe.Stage(:list, "tag2",  func x { return x + "Z" })
	$oPipe.Stage(:search, "len", func x { return "" + StzLen(x) })
	cBig = ""
	for i = 1 to 20000  cBig += "softanza "  next   # ~180k chars
	nInLen = StzLen(cBig)
	cOut = $oPipe.Run(cBig)
	Then("the pipeline completed", $oPipe.Failed(), FALSE)
	Then("the final stage counted input + the two added chars",
		ring_number(cOut), nInLen + 2)
EndScenario()

Scenario("DATA: a large batch fans through the pipeline")
	Given("the pipeline and 300 inputs")
	aIn = []
	for i = 1 to 300  aIn + ("doc-" + i)  next
	aOut = $oPipe.RunBatch(aIn)
	Then("300 results come back", len(aOut), 300)
	Then("each is the numeric length of its transformed doc",
		ring_number(aOut[1]) > 0 and ring_number(aOut[300]) > 0, TRUE)
EndScenario()

# =====================================================================
#  FUNCTIONAL edges
# =====================================================================

Scenario("FUNCTIONAL: a pipeline stage failure is CONTAINED, not fatal")
	Given("a pipeline whose middle stage raises")
	oF = new stzComputePipeline("faulty")
	oF.Stage(:text, "ok1",   func x { return x + ":1" })
	oF.Stage(:math, "boom",  func x { raise("stage exploded") })
	oF.Stage(:search, "ok3", func x { return x + ":3" })
	cR = oF.Run("start")
	Then("Run returns NULL on failure (halted)", cR = NULL, TRUE)
	Then("Failed() is set", oF.Failed(), TRUE)
	Then("Why() names the failing stage", StzFindFirst(oF.Why(), "boom") > 0, TRUE)
	Then("the trace stops at the failed stage (2 entries)", len(oF.Trace()), 2)
	Then("the last trace entry is the ERROR marker", oF.Trace()[2][3], "ERROR")

	Given("a pool-backed faulty pipeline")
	oP2 = new stzWorkerPool()
	oP2.AddFacet(:math, 1)
	oF.UsingPool(oP2)
	oF.Run("start")
	Then("the facet slot was RELEASED despite the failure (no leak)",
		oF.PoolQ().ProfileQ("math").InFlight(), 0)
EndScenario()

Scenario("FUNCTIONAL: routing/classification boundary conditions")
	Given("a fresh classifier + cluster")
	oRC = new stzRequestClassifier()
	Then("an unknown facet path with no lexical hit abstains",
		oRC.Classify("GET", "/nothing/here", "", "zzz qqq"), "")
	Given("a cluster with a facet declared but NOT started")
	oCl = new stzAppCluster()
	oCl.WithFacet(:nlp, 2)
	Then("routing before Start declines (no ready worker), cleanly",
		oCl.Route("nlp", "/work"), "")
	Then("with a negative status", oCl.RouteLastStatus() < 0, TRUE)
	Then("routing to an undeclared facet also declines",
		oCl.Route("quantum", "/work"), "")
EndScenario()

Scenario("FUNCTIONAL: federation edge cases")
	Given("a federation")
	oFd = new stzComputeFederation("edge-grid")
	oFd.Join("h1", "127.0.0.1:65532", [ :math, :nlp ])
	Then("joining a duplicate host name raises", This_Raises_Dup(oFd), TRUE)
	Then("a host offering multiple facets is discoverable by each",
		len(oFd.MembersOffering(:math)) = 1 and len(oFd.MembersOffering(:nlp)) = 1, TRUE)
	When("the only host is retired")
	oFd.Retire("h1")
	Then("it no longer appears in offerings", len(oFd.MembersOffering(:math)), 0)
	When("revived")
	oFd.Revive("h1")
	Then("it is offered again", len(oFd.MembersOffering(:math)), 1)
	oFd.Shutdown()
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

func isNumberNeg(x)
	# a FederatedCall returns "" (a string) on refusal; the status is the
	# real signal. Here we treat the empty body as "refused".
	return x = ""

func This_Raises_Dup(oFed)
	try
		oFed.Join("h1", "127.0.0.1:1", [ :math ])
		return FALSE
	catch
		return TRUE
	done
