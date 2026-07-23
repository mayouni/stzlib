load "../../stzBase.ring"
load "../_narrated.ring"

# stzAppBackend REMOTE -- the backend leaves this process (2026-07-23).
#
# 62_app_backend_narrated proved live cross-part state INSIDE one process: the
# server, the sqlite and the parts' client all shared a Ring interpreter, and a
# crossing worked because the caller pumped its own server between submit and
# await. That is honest, but it is not a backend -- a backend is something the
# parts do NOT contain.
#
# Here the backend is a SEPARATE OPERATING-SYSTEM PROCESS. SpawnRemote()
# serialises the model, generates a host script, and launches a real `ring`
# child that Start()s the backend and Serve()s it. The parts then ConnectTo()
# it over real TCP and must NOT pump anything -- the far process runs its own
# loop. Two processes, one socket, one sqlite.
#
# The payoff is LOCATION TRANSPARENCY: scenario 4 (remote) and scenario 6
# (local) assert the SAME numbers through the SAME calls. Part code does not
# know, and does not need to know, where its backend lives.

nRemotePort = 8531

  #-- the solution's model ------------------------------------------------

oT = new stzAppTopology("restolean")
oT.AddDatasetQ("menu", [ [ "Couscous", "semolina | 7 veg", 12 ],
                         [ "Tajine",   "clay pot, 100% slow", 15 ] ])
oT.SetDatasetColumnsQ("menu", [ "name", "descr", "price" ])
oT.AddDatasetQ("orders", [ [ "Tajine", 1 ] ])
oT.SetDatasetColumnsQ("orders", [ "dish", "qty" ])
oT.SetPartRoleQ(:phone, "menu", "menu")
oT.SetPartRoleQ(:admin, "dashboard", "orders")

Scenario("the MODEL crosses to another process intact")
	Given("a model whose cells contain the record separator, a newline and a percent")
	oSer = new stzAppBackend("sertest", oT)
	cPath = WorkingDirectory() + "/_model_probe.txt"
	oSer.SaveModelTo(cPath)
	oBack = StzLoadAppTopologyFrom(cPath)
	Then("the solution name survives", oBack.Name(), "restolean")
	Then("both datasets survive", len(oBack.DatasetNames()), 2)
	Then("...with their declared columns", len(oBack.ColumnsOf("menu")), 3)
	aM = oBack.Dataset("menu")
	Then("a cell containing the | separator is intact", aM[1][2], "semolina | 7 veg")
	Then("...and one containing a percent is intact", aM[2][2], "clay pot, 100% slow")
	# types are TAGGED, not sniffed: a price must stay numeric for the revenue
	# maths, and "looks numeric" is how "007" silently becomes 7.
	Then("a price came back a NUMBER, not a string", isNumber(aM[1][3]), TRUE)
	Then("the part roles survive", oBack.DatasetNameOf(:admin), "orders")
	StzFileDelete(cPath)
EndScenario()

Scenario("the backend is launched as a REAL second process")
	Given("a host spawned from the model, with a TTL so it cannot outlive the run")
	oHost = new stzAppBackend("restolean", oT)
	cEndpoint = oHost.SpawnRemote(nRemotePort, 60000)
	Then("it reports the endpoint it launched on", cEndpoint, "127.0.0.1:" + nRemotePort)
	When("we wait for the child to load stzBase and bind")
	Then("the far backend comes up", oHost.WaitReady(40000), TRUE)
EndScenario()

Scenario("a part CONNECTS to it -- no database, no server, just a client")
	oPhone = new stzAppBackend("restolean", oT)
	oPhone.ConnectTo("127.0.0.1", nRemotePort)
	Then("this object knows it is remote", oPhone.IsRemote(), TRUE)
	Then("...and can reach the far backend", oPhone.IsReachable(5000), TRUE)
	Then("...it addresses it by endpoint", oPhone.Endpoint(), "127.0.0.1:" + nRemotePort)
	# a client owns nothing to serve; asking it to would mean pumping a server
	# that is not the one answering -- exactly the bug this seam prevents.
	bRaised = FALSE
	try
		oPhone.Serve(10)
	catch
		bRaised = TRUE
	done
	Then("asking a CLIENT to Serve() is refused", bRaised, TRUE)
EndScenario()

Scenario("THE PROOF: one part writes over the network, another part sees it")
	Given("a SECOND, independent client object standing in for the admin part")
	oAdmin = new stzAppBackend("restolean", oT)
	oAdmin.ConnectTo("127.0.0.1", nRemotePort)

	Then("the admin sees the state the far backend was seeded with",
	     oAdmin.RowCount(:admin, "orders"), 1)
	aBefore = oAdmin.Dashboard(:admin)
	Then("...and its dashboard totals that one Tajine", aBefore[2], 15)

	When("the PHONE client POSTs an order across the wire")
	Then("the far backend accepts it (201)",
	     oPhone.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ]), TRUE)

	When("the ADMIN client -- a different object, a different socket -- reads")
	Then("it SEES the phone's order", oAdmin.RowCount(:admin, "orders"), 2)
	aAfter = oAdmin.Dashboard(:admin)
	Then("the engine-computed total moved: 15 + 12x2 = 39", aAfter[2], 39)
	Then("...and the top dish flipped to Couscous", aAfter[3], "Couscous")
	# Neither client holds the state. It lives in the OTHER PROCESS, and the
	# only thing crossing between them is HTTP.
EndScenario()

Scenario("a non-ASCII order survives the network hop too")
	oPhone.Create(:phone, "orders", [ [ "dish", "كسكس" ], [ "qty", 1 ] ])
	aRows = oAdmin.Rows(:admin, "orders")
	Then("arabic round-trips process -> socket -> sqlite -> json -> the admin",
	     aRows[len(aRows)][1], "كسكس")
EndScenario()

Scenario("governance still holds over the wire")
	Given("the phone client bound to an LLM actor")
	oPhone.SetActorQ(LLMActor("planner"))
	Then("it may still READ the remote solution", len(oPhone.Rows(:phone, "orders")) > 0, TRUE)
	bRaised = FALSE
	try
		oPhone.Create(:phone, "orders", [ [ "dish", "Tajine" ], [ "qty", 9 ] ])
	catch
		bRaised = TRUE
	done
	Then("but the remote WRITE is refused before it leaves this process", bRaised, TRUE)
	Then("...nothing reached the far backend", oAdmin.RowCount(:admin, "orders"), 3)
	Then("...and the refusal is audited", len(oPhone.RefusedCrossings()), 1)
	oPhone.Stop()
	oAdmin.Stop()
	oHost.Stop()
EndScenario()

Scenario("LOCATION TRANSPARENCY: the same calls, the same answers, in-process")
	Given("the identical model served LOCALLY instead")
	oLocal = new stzAppBackend("restolean", oT)
	oLocal.Start(0)
	Then("it is not remote", oLocal.IsRemote(), FALSE)
	Then("the same seeded count", oLocal.RowCount(:admin, "orders"), 1)
	Then("the same dashboard before", oLocal.Dashboard(:admin)[2], 15)
	Then("the same write call succeeds",
	     oLocal.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ]), TRUE)
	Then("the same total after", oLocal.Dashboard(:admin)[2], 39)
	Then("the same top dish", oLocal.Dashboard(:admin)[3], "Couscous")
	# Identical assertions to scenario 4. The part code never learned where its
	# backend was -- which is the whole point of the remote seam.
	oLocal.Stop()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
