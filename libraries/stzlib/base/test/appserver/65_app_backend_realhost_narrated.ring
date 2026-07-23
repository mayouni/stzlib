load "../../stzBase.ring"
load "../_narrated.ring"

# stzAppBackend ON A REAL HOST -- off the loopback, authenticated (2026-07-23).
#
# 63_app_backend_remote proved the backend can live in ANOTHER PROCESS, but
# every byte still crossed 127.0.0.1. A backend on a real host differs in two
# ways that matter, and only one of them is about addresses:
#
# 1. THE BIND. Start() hardcoded 127.0.0.1, so no other machine could reach a
#    Softanza backend at all. StartOn(host, port) binds a chosen interface --
#    0.0.0.0 for every one of them, or a single NIC.
#
# 2. THE TRUST. On the loopback the callers are this machine. On a real
#    interface they are whoever can route to the port, and the MBaaS floor
#    would take a POST from any of them. So leaving the loopback REQUIRES a
#    signing key, enforced at bind time rather than found later in an audit --
#    expression is free, admission is governed, applied at the transport edge.
#
# WHAT THIS GUARD REALLY EXERCISES: it binds 0.0.0.0 in a spawned OS process and
# talks to it over this machine's own ROUTABLE address (10.x/192.168.x), not
# 127.0.0.1 -- a genuine trip through the network stack that any other host on
# that network could make. What it CANNOT do is prove a second physical machine;
# that step is one reachable ssh account away and is rehearsed, not run.

$cLanIp = StzLanIpv4()

oT = new stzAppTopology("resto")
oT.AddDataset("menu", [ [ "Couscous", "semolina", 12 ] ])
oT.SetDatasetColumns("menu", [ "name", "descr", "price" ])
oT.AddDataset("orders", [])
oT.SetDatasetColumns("orders", [ "dish", "qty" ])
oT.SetPartRole(:admin, "dashboard", "orders")

Scenario("a backend refuses to leave the loopback unauthenticated")
	Given("a backend with no signing key")
	oBad = new stzAppBackend("bad", oT)
	When("it is asked to bind every interface")
	bRaised = FALSE
	try
		oBad.StartOn("0.0.0.0", 0)
	catch
		bRaised = TRUE
	done
	Then("the bind is REFUSED, not quietly exposed", bRaised, TRUE)
	Then("...and it is still not running", oBad.IsLive(), FALSE)

	When("the same backend spawns a host on a real interface")
	bRaised2 = FALSE
	try
		oBad.SpawnRemoteOn("0.0.0.0", 8431, 5000)
	catch
		bRaised2 = TRUE
	done
	Then("that is refused too -- the rule is on the bind, not the API",
	     bRaised2, TRUE)

	When("the loopback is asked for instead")
	oLoop = new stzAppBackend("loop", oT)
	oLoop.Start(0)
	Then("an unauthenticated LOOPBACK bind is still fine", oLoop.IsLive(), TRUE)
	Then("...and it reports its interface", oLoop.BindHost(), "127.0.0.1")
	oLoop.Stop()
EndScenario()

Scenario("a host bound to EVERY interface, reached at a routable address")
	Given("a signed backend spawned as its own process on 0.0.0.0")
	oHost = new stzAppBackend("resto", oT)
	oHost.SetSigningKey("edge", "s3cr3t-shared")
	oHost.SpawnRemoteOn("0.0.0.0", 8433, 30000)
	Then("it bound every interface", oHost.BindHost(), "0.0.0.0")

	When("the PARTS connect over this machine's routable LAN address")
	oParts = new stzAppBackend("resto", oT)
	oParts.SetSigningKey("edge", "s3cr3t-shared")
	oParts.ConnectTo($cLanIp, 8433)
	Then("the endpoint is NOT the loopback",
	     StzFindFirst("127.0.0.1", oParts.Endpoint()) = 0, TRUE)
	Then("the far process answers over the network", oParts.WaitReady(25000), TRUE)
	Then("...and a health probe confirms it", oParts.IsReachable(5000), TRUE)

	When("a part writes across that network")
	Then("the write is accepted",
	     oParts.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 3 ] ]), TRUE)
	Then("...another part sees it", oParts.RowCount(:admin, "orders"), 1)
	Then("...and the engine-computed total crossed the wire: 12x3",
	     oParts.Dashboard(:admin)[2], 36)
EndScenario()

Scenario("the same host refuses an unsigned caller")
	Given("a client with no key, pointed at the very same backend")
	oNoKey = new stzAppBackend("resto", oT)
	oNoKey.ConnectTo($cLanIp, 8433)
	When("it tries to read")
	aRows = oNoKey.Rows(:admin, "orders")
	Then("it gets nothing", len(aRows), 0)
	Then("...because the far side answered 401", oNoKey.LastStatus(), 401)
	When("it tries to WRITE")
	Then("the write fails too",
	     oNoKey.Create(:phone, "orders", [ [ "dish", "Tajine" ], [ "qty", 9 ] ]), FALSE)
	Then("...and nothing was written", oParts.RowCount(:admin, "orders"), 1)
	oNoKey.Stop()
EndScenario()

Scenario("a WRONG key is refused as firmly as no key")
	oWrong = new stzAppBackend("resto", oT)
	oWrong.SetSigningKey("edge", "not-the-secret")
	oWrong.ConnectTo($cLanIp, 8433)
	Then("a forged signature is refused", len(oWrong.Rows(:admin, "orders")), 0)
	Then("...with 401", oWrong.LastStatus(), 401)
	Then("...and the state is untouched", oParts.RowCount(:admin, "orders"), 1)
	oWrong.Stop()
	oParts.Stop()
	oHost.Stop()
EndScenario()

Scenario("signing itself: freshness and replay, at the transport edge")
	Given("a signer holding the shared secret")
	oSig = new stzRequestSigner("probe")
	oSig.AddKey("edge", "s3cr3t-shared")
	aEnv = oSig.Sign("edge", "GET", "/api/orders", "", 1000000, "nonce-1")
	Then("a fresh signature verifies",
	     oSig.Verify("edge", "GET", "/api/orders", "", 1000000, "nonce-1", aEnv[:sig], 30000, 1000000), TRUE)
	Then("REPLAYING the same nonce is refused",
	     oSig.Verify("edge", "GET", "/api/orders", "", 1000000, "nonce-1", aEnv[:sig], 30000, 1000000), FALSE)
	Then("...and it says why", StzFindFirst("replay", oSig.Why()) > 0, TRUE)
	Then("a stale timestamp is refused",
	     oSig.Verify("edge", "GET", "/api/orders", "", 1000000, "nonce-2", aEnv[:sig], 30000, 9000000), FALSE)
	Then("a TAMPERED path is refused",
	     oSig.Verify("edge", "GET", "/api/menu", "", 1000000, "nonce-3", aEnv[:sig], 30000, 1000000), FALSE)
EndScenario()

Scenario("launching on a GENUINELY remote machine -- rehearsed, not run")
	Given("a signed backend and an ssh target")
	oRem = new stzAppBackend("resto", oT)
	oRem.SetSigningKey("edge", "s3cr3t-shared")
	aCmds = oRem.RemoteLaunchCommands("ops@10.0.0.7", "/srv/resto", 8080, 600000)
	Then("it rehearses four steps", len(aCmds), 4)
	Then("...it makes the remote directory", StzFindFirst("mkdir", aCmds[1]) > 0, TRUE)
	Then("...ships the model", StzFindFirst("scp", aCmds[2]) > 0, TRUE)
	Then("...ships the generated host script", StzFindFirst("host.ring", aCmds[3]) > 0, TRUE)
	Then("...and launches it bound to every interface",
	     StzFindFirst("0.0.0.0", aCmds[4]) > 0, TRUE)
	Then("the SECRET never appears in any command",
	     StzFindFirst("s3cr3t-shared", aCmds[1] + aCmds[2] + aCmds[3] + aCmds[4]) = 0, TRUE)
	Then("...only the NAME of the env var that carries it",
	     StzFindFirst("STZ_BACKEND_SECRET", aCmds[4]) > 0, TRUE)

	When("a launch is rehearsed without a key")
	oNo = new stzAppBackend("nokey", oT)
	bR = FALSE
	try
		oNo.RemoteLaunchCommands("ops@10.0.0.7", "/srv/x", 8080, 1000)
	catch
		bR = TRUE
	done
	Then("it is refused -- another machine is off the loopback by definition", bR, TRUE)

	cNar = LinesToText(oRem.ExplainRemoteLaunch("ops@10.0.0.7", "/srv/resto", 8080, 600000))
	Then("the explanation is honest that nothing has run",
	     StzFindFirst("nothing has run yet", cNar) > 0, TRUE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code) ---------------------------------

func LinesToText aLines
	cT = ""
	nCount = len(aLines)
	for i = 1 to nCount
		cT += aLines[i] + nl
	next
	return cT
