load "../../stzBase.ring"
load "../_narrated.ring"

# R7 -- stzPlatform: THE OPERATIONAL ENVELOPE (5.10).
#
# stzApp models the world; stzPlatform is everything AROUND it that
# makes it operable: GENERATION (declared Reach -> real per-platform
# shells), the CAPABILITY SEAM (device capabilities gated by the R4b
# governance lattice), the COMMONS runtime (identity/sessions/
# messaging/stores over engine sqlite), the NETWORKED BODY (the world
# served multi-user through the R7 reactor host), and the REGISTRY
# with norm-ENFORCED cross-world calls.
#
# Fully offline: the reactor's async tcp client plays the network peer.

$CRLF = char(13) + char(10)

# -- the world under envelope: a small restaurant ---------------------
$oApp = StzApp("resto")
$oApp.Thing(:dish) { Has([ :name, :price ]) }
$oApp.Thing(:table) { Has([ :number, :seats ]) }
$oApp.Screen(:menu)
$oApp.Reaches([ :web, :desktop ])

$oPlat = StzPlatform("resto-envelope")
$oPlat.ForWorld($oApp)

Scenario("GENERATION: declared Reach becomes real per-platform shells")
	Given("a world reaching :web and :desktop, enveloped by a platform")
	When("Generate(:all) runs")
	aShells = $oPlat.Generate(:all)
	Then("one shell per declared reach was written", len(aShells), 2)
	Then("the web shell exists on disk", fexists(aShells[1]), TRUE)
	cWeb = read(aShells[1])
	Then("it embeds the world's name", StzFindFirst(cWeb, "resto") > 0, TRUE)
	Then("and its declared screen", StzFindFirst(cWeb, "menu") > 0, TRUE)
	cDesk = read(aShells[2])
	Then("the desktop shell is a Ring launcher over the one engine",
		StzFindFirst(cDesk, "stzlib.ring") > 0, TRUE)

	When("a world WITHOUT any Reach asks for generation")
	oBare = StzApp("bare")
	oPlat2 = StzPlatform("bare-envelope")
	oPlat2.ForWorld(oBare)
	bRaised = FALSE
	try
		oPlat2.Generate(:all)
	catch
		bRaised = TRUE
	done
	Then("the platform refuses instead of stubbing (LAW 3)", bRaised, TRUE)
EndScenario()

Scenario("CAPABILITY SEAM: capabilities are governed by construction")
	Given("a sealed governance regime for the resto world")
	oGov = new stzGovernance("resto-regime")
	oGov.GrantPermission("resto", "use-camera")     # CAN
	oGov.GrantPermission("resto", "use-payments")   # CAN, but...
	oGov.SetAuthority("resto", :Delegated)          # SHOULD level 2
	$oPlat.GovernedBy(oGov)

	When("the world admits :camera for a declared purpose")
	$oPlat.Admits(:camera).With([ :scan_dish_photo ])
	Then("camera (risk 2) is granted to a delegated world", $oPlat.Granted(:camera), TRUE)

	When("the world admits :payments (risk tier 4)")
	$oPlat.Admits(:payments).With([ :charge_guests ])
	Then("payments is refused despite permission", $oPlat.Granted(:payments), FALSE)
	Then("the refusal narrates the SHOULD gap",
		StzFindFirst($oPlat.Why(), "risk tier 4") > 0, TRUE)

	When("a capability that was never admitted is asked for")
	Then("it is refused outright", $oPlat.Granted(:location), FALSE)
	Then("with an honest why", StzFindFirst($oPlat.Why(), "never requested") > 0, TRUE)
EndScenario()

Scenario("COMMONS: identity, sessions, messaging and stores over sqlite")
	Given("an in-memory engine database wired as the Commons")
	$oDb = new stzDatabase(":memory:")
	$oPlat.CommonsOn($oDb)

	When("two identities register")
	Then("mansour registers", $oPlat.RegisterIdentity("mansour", "s3cret"), TRUE)
	Then("teejan registers", $oPlat.RegisterIdentity("teejan", "pass99"), TRUE)
	Then("a duplicate registration is refused", $oPlat.RegisterIdentity("mansour", "x"), FALSE)

	When("mansour opens a session")
	cToken = $oPlat.OpenSession("mansour", "s3cret")
	Then("a token is issued", len(cToken) > 0, TRUE)
	Then("the token resolves back to the identity", $oPlat.SessionUser(cToken), "mansour")
	Then("a wrong secret gets no session", $oPlat.OpenSession("teejan", "wrong"), "")

	When("mansour messages teejan and a preference is stored")
	$oPlat.PostMessage("mansour", "teejan", "table 4 is ready")
	aInbox = $oPlat.Inbox("teejan")
	Then("the message is in teejan's inbox", len(aInbox), 1)
	Then("with its body", aInbox[1][2], "table 4 is ready")
	$oPlat.StorePut("theme", "dark")
	Then("the store round-trips", $oPlat.StoreGet("theme"), "dark")
EndScenario()

Scenario("NETWORKED BODY: the world served through the reactor host")
	Given("the platform serving the resto world on an ephemeral port")
	$oPlat.ServeBody(0)
	nPort = $oPlat.HostQ().Port()
	Then("the host is live on a real port", nPort > 0, TRUE)

	When("a client asks GET /world")
	oPeer = new stzReactor()
	cReq = "GET /world HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oPeer.SubmitTcp("127.0.0.1", nPort, cReq)
	$oPlat.ServeOne(3000)
	cBody = oPeer.AwaitTcp(nJob, 5000)
	Then("the world names itself", StzFindFirst(cBody, '"world":"resto"') > 0, TRUE)
	Then("and lists its things", StzFindFirst(cBody, '"dish"') > 0, TRUE)

	When("a client asks GET /thing?name=dish")
	cReq = "GET /thing?name=dish HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oPeer.SubmitTcp("127.0.0.1", nPort, cReq)
	$oPlat.ServeOne(3000)
	cBody = oPeer.AwaitTcp(nJob, 5000)
	Then("the thing answers with its fields", StzFindFirst(cBody, '"price"') > 0, TRUE)

	oPeer.Destroy()
	$oPlat.StopServing()
	Then("serving stops cleanly", TRUE, TRUE)
EndScenario()

Scenario("REGISTRY + ENFORCEMENT: cross-world calls are norm-gated")
	Given("two worlds pushed into the registry, bonded for one action")
	$oPlat.PushWorld("resto", "1.0")
	$oPlat.PushWorld("supplier", "2.1")
	$oPlat.Bond("resto", "supplier", "order-produce")

	When("the bonded action lacks governance declarations")
	Then("the call is refused (undeclared risk never proceeds)",
		$oPlat.CallAcross("resto", "supplier", "order-produce"), FALSE)

	When("the regime declares the action and grants resto the right")
	oGov2 = new stzGovernance("constellation-regime")
	oGov2.DeclareRisk("order-produce", 2)
	oGov2.GrantPermission("resto", "order-produce")
	oGov2.SetAuthority("resto", :Delegated)
	$oPlat.GovernedBy(oGov2)
	Then("the bonded, governed call proceeds",
		$oPlat.CallAcross("resto", "supplier", "order-produce"), TRUE)

	When("an unbonded action is attempted")
	Then("it is refused", $oPlat.CallAcross("resto", "supplier", "raid-kitchen"), FALSE)
	Then("with the bond named as the reason", StzFindFirst($oPlat.Why(), "no bond") > 0, TRUE)

	When("the supplier world is retired")
	$oPlat.RetireWorld("supplier")
	Then("the previously allowed call is now refused",
		$oPlat.CallAcross("resto", "supplier", "order-produce"), FALSE)
	Then("because the target is inactive",
		StzFindFirst($oPlat.Why(), "not active") > 0, TRUE)
	$oDb.Close()
EndScenario()

Summary()
