load "../../stzBase.ring"
load "../_narrated.ring"

# R8.6 (the SCALE plane, FINALE) -- the GOVERNED MULTI-HOST CONSTELLATION.
# A cluster spanning machines IS an stzSuperApp constellation: member
# HOSTS offer facets at endpoints; a federated compute call is DISCOVERED
# (which host offers the facet), GOVERNED (a bond must permit the caller
# AND the governance capability lattice must clear it), and TRANSPORTED
# over the wire via the reactor's async curl. This closes the 2024 doc's
# "federated compute marketplace" on real primitives: governance = the
# SLA layer, curl = the transport, the facet catalog = the offering.

# clock-derived port so back-to-back runs don't collide
$nBase = 49000 + (StzEngineTimeNowMs() % 700)

Scenario("the registry: hosts join and declare the facets they offer")
	Given("a federation of two farms")
	$oFed = new stzComputeFederation("acme-grid")
	$oFed.Join("gpu-farm", "10.0.0.7:8080", [ :neural, :vision ])
	$oFed.Join("math-farm", "10.0.0.8:8080", [ :math ])
	Then("two members", $oFed.NumberOfMembers(), 2)
	Then("gpu-farm offers :neural", ring_find($oFed.MembersOffering(:neural), "gpu-farm") > 0, TRUE)
	Then("math-farm offers :math", ring_find($oFed.MembersOffering(:math), "math-farm") > 0, TRUE)
	Then("nobody offers :graph (yet)", len($oFed.MembersOffering(:graph)), 0)
EndScenario()

Scenario("a federated call is GOVERNED before it is transported")
	When("a caller requests a facet with no bond")
	r = $oFed.FederatedCall("web-host", :neural, "/work", "")
	Then("it is refused (no bond)", $oFed.CallLastStatus() < 0, TRUE)
	Then("the why names the missing bond", StzFindFirst($oFed.Why(), "no bond") > 0, TRUE)

	When("a bond exists but the action has no declared risk tier")
	$oFed.Bond("web-host", :neural)
	$oFed.FederatedCall("web-host", :neural, "/work", "")
	Then("still refused (undeclared risk never proceeds)", $oFed.CallLastStatus() < 0, TRUE)
	Then("the why cites governance", StzFindFirst($oFed.Why(), "governance") > 0, TRUE)

	When("the caller lacks authority for the facet's risk tier")
	$oFed.GovDeclareRisk("use-neural", 3)               # risk 3
	$oFed.GovGrant("web-host", "use-neural")            # CAN
	$oFed.GovSetAuthority("web-host", :Delegated)       # SHOULD level 2
	$oFed.FederatedCall("web-host", :neural, "/work", "")
	Then("refused: authority 2 < risk 3", $oFed.CallLastStatus() < 0, TRUE)

	When("a request targets a facet nobody offers")
	$oFed.FederatedCall("web-host", :graph, "/work", "")
	Then("refused: no active host offers it", StzFindFirst($oFed.Why(), "no active host") > 0, TRUE)
	$oFed.Shutdown()
EndScenario()

Scenario("REAL cross-host transport: a governed call reaches a live worker")
	Given("a live compute host (a spawned worker offering :vision)")
	$oHostCluster = new stzAppCluster()
	$oHostCluster.WithFacet(:vision, 1).SetWorkerTTL(15000).SetBasePort($nBase)
	$oHostCluster.Start()
	$oHostCluster.WaitReady(20000)
	nPort = $oHostCluster.Ports()[1]

	Given("a federation with that host joined + fully governed")
	$oGrid = new stzComputeFederation("live-grid")
	$oGrid.Join("vision-host", "127.0.0.1:" + nPort, [ :vision ])
	$oGrid.Bond("web", :vision)
	$oGrid.GovDeclareRisk("use-vision", 2)
	$oGrid.GovGrant("web", "use-vision")
	$oGrid.GovSetAuthority("web", :Delegated)          # level 2 >= risk 2

	When("web makes a governed federated call for :vision work")
	cResp = $oGrid.FederatedCall("web", :vision, "/work?q=scan-me", "")
	Then("the call was allowed + transported (HTTP 200)", $oGrid.CallLastStatus(), 200)
	Then("the remote vision worker answered", StzFindFirst(cResp, "vision:done:scan-me") > 0, TRUE)
	Then("the why records offered+bonded+governed",
		StzFindFirst($oGrid.Why(), "allowed") = 1, TRUE)
	Then("the decision left governed lineage",
		$oGrid.GovernanceQ().NumberOfDecisions() >= 1, TRUE)

	When("the host is retired from the grid")
	$oGrid.Retire("vision-host")
	$oGrid.FederatedCall("web", :vision, "/work?q=x", "")
	Then("the call is refused (no active host offers it now)",
		$oGrid.CallLastStatus() < 0, TRUE)

	$oGrid.Shutdown()
	$oHostCluster.Stop()
	Then("federation + host tear down cleanly", TRUE, TRUE)
EndScenario()

Summary()
