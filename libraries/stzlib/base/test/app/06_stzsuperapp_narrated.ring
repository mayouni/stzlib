load "../../stzBase.ring"
load "../_narrated.ring"

# R7 finish -- stzSuperApp: a living CONSTELLATION of worlds (5.10).
# A governed graph whose nodes are stzApps (recursively, other
# constellations too), sharing a Commons (world zero), bound by
# norm-gated bonds under ambient governance, with hot-swappable worlds.
# It lifts stzPlatform's registry/bond/norm floor into a construct that
# holds REAL world objects. Fully offline (in-memory sqlite commons).

# two worlds: a restaurant and its produce supplier
$oResto = StzAppQ("resto")
$oResto.AddThingQ(:dish) { Has([ :name, :price ]) }

$oSupplier = StzAppQ("supplier")
$oSupplier.AddThingQ(:crate) { Has([ :produce, :qty ]) }

$oCon = new stzSuperApp("acme-group")

Scenario("worlds are registered as nodes of the constellation")
	When("both worlds join the constellation")
	$oCon.AddWorld("resto", $oResto)
	$oCon.AddWorld("supplier", $oSupplier)
	Then("it holds two worlds", $oCon.NumberOfWorlds(), 2)
	Then("resto is a live world object",
		isObject($oCon.WorldQ("resto")), TRUE)
	Then("and it is the real resto (its dish survived)",
		$oCon.WorldQ("resto").Name(), "resto")
	Then("both are active", $oCon.IsActive("resto") and $oCon.IsActive("supplier"), TRUE)
	Then("the constellation graph has both nodes",
		$oCon.GraphQ().NodesCount(), 2)
EndScenario()

Scenario("the shared Commons is world zero")
	Given("an in-memory database backing the Commons")
	$oDb = new stzDatabase(":memory:")
	$oCon.OpenCommonsOn($oDb)
	When("an identity registers and stores a shared preference")
	Then("registration succeeds", $oCon.RegisterIdentity("owner", "s3cret"), TRUE)
	$oCon.StorePut("currency", "EUR")
	Then("a session opens for the right secret",
		len($oCon.OpenSession("owner", "s3cret")) > 0, TRUE)
	Then("the shared store round-trips", $oCon.StoreGet("currency"), "EUR")
EndScenario()

Scenario("cross-world calls are norm-gated")
	Given("a bond + governance for resto ordering from supplier")
	$oCon.Bond("resto", "supplier", "order-produce")

	When("the action lacks governance declarations")
	Then("the call is refused (undeclared risk never proceeds)",
		$oCon.CallAcross("resto", "supplier", "order-produce"), FALSE)

	When("the constellation governs the action (through its own gov)")
	$oCon.GovDeclareRisk("order-produce", 2)
	$oCon.GovGrant("resto", "order-produce")
	$oCon.GovSetAuthority("resto", :Delegated)
	Then("the bonded, governed call proceeds",
		$oCon.CallAcross("resto", "supplier", "order-produce"), TRUE)

	When("an unbonded action is attempted")
	Then("it is refused", $oCon.CallAcross("resto", "supplier", "raid-kitchen"), FALSE)
	Then("the bond is named as the reason", StzFindFirst("no bond", $oCon.Why()) > 0, TRUE)
EndScenario()

Scenario("a retired world breaks its bonds")
	Given("the previously-allowed order path")
	When("the supplier world is retired")
	$oCon.Retire("supplier")
	Then("the call is now refused", $oCon.CallAcross("resto", "supplier", "order-produce"), FALSE)
	Then("because the target is inactive", StzFindFirst("not active", $oCon.Why()) > 0, TRUE)
	When("the supplier is revived")
	$oCon.Revive("supplier")
	Then("the call proceeds again", $oCon.CallAcross("resto", "supplier", "order-produce"), TRUE)
EndScenario()

Scenario("a world is hot-swapped, keeping its node and bonds")
	Given("a new supplier implementation")
	oNewSupplier = StzAppQ("supplier-v2")
	oNewSupplier.AddThingQ(:pallet) { Has([ :sku ]) }
	When("the live supplier is swapped")
	$oCon.Swap("supplier", oNewSupplier)
	Then("still one supplier node (count unchanged)", $oCon.NumberOfWorlds(), 2)
	Then("the node now serves the new world",
		$oCon.WorldQ("supplier").Name(), "supplier-v2")
	Then("the bond survived the swap: the order still clears",
		$oCon.CallAcross("resto", "supplier", "order-produce"), TRUE)
EndScenario()

Scenario("constellations nest recursively (graph-of-graphs)")
	Given("a parent constellation holding acme-group as a node")
	oParent = new stzSuperApp("holding")
	oParent.AddConstellation("acme", $oCon)
	Then("the parent holds one world", oParent.NumberOfWorlds(), 1)
	Then("its kind is a nested constellation", oParent.KindOf("acme"), "super")
	Then("and it IS the acme constellation (two worlds inside)",
		oParent.WorldQ("acme").NumberOfWorlds(), 2)
	$oDb.Close()
EndScenario()

Summary()
