load "../../stzBase.ring"
load "../_narrated.ring"

# stzAppBackend -- LIVE CROSS-PART STATE (2026-07-23).
#
# stzAppTopology gives each part a role over a named dataset, but those
# datasets are STATIC lists: an order "created" on the phone never reaches the
# admin, because each part reads its own frozen copy of the model. The emulator
# could only ever render a rehearsal.
#
# stzAppBackend makes the state LIVE. It materialises the model's datasets as
# real sqlite tables, serves them over a REAL running stzAppServer, and lets the
# parts read/write over REAL HTTP (SubmitTcp -> ServeOne -> AwaitTcp, one
# process holding both ends -- offline by construction). What one part writes,
# another part sees, because there is now exactly ONE copy of the state and it
# lives outside them both.
#
# The load-bearing proof is Scenario 2: the admin's dashboard total is computed
# by the engine (stzTable SumCol / MaxColumn -- its declared :PivotTable) and it
# CHANGES because the phone wrote.

  #-- the solution's model: a restaurant with a menu and an order book ------

oT = new stzAppTopology("restolean")
oT.AddDatasetQ("menu", [ [ "Couscous", "semolina + 7 vegetables", 12 ],
                         [ "Tajine",   "slow-cooked, clay pot",   15 ] ])
oT.SetDatasetColumnsQ("menu", [ "name", "descr", "price" ])
oT.AddDatasetQ("orders", [ [ "Tajine", 1 ] ])          # one order already placed
oT.SetDatasetColumnsQ("orders", [ "dish", "qty" ])
oT.SetPartRoleQ(:phone, "menu", "menu")                # the guest app
oT.SetPartRoleQ(:admin, "dashboard", "orders")         # the manager view

oB = new stzAppBackend("restolean", oT)

Scenario("the backend goes live: the model's datasets become real shared state")
	Given("a topology whose datasets are static in-memory lists")
	When("Start(0) materialises them and binds an ephemeral port")
	oB.Start(0)
	Then("the backend reports live", oB.IsLive(), TRUE)
	Then("a real port is bound", oB.Port() > 0, TRUE)
	Then("the seeded order is really in the live state", oB.RowCount(:admin, "orders"), 1)
	Then("...and the menu came across too", oB.RowCount(:phone, "menu"), 2)
EndScenario()

Scenario("THE PROOF: an order created on the phone is seen by the admin")
	Given("the admin's dashboard before anything is ordered")
	aBefore = oB.Dashboard(:admin)
	Then("the total is the one seeded Tajine (15)", aBefore[2], 15)
	Then("...and Tajine is the top dish", aBefore[3], "Tajine")

	When("the PHONE part creates an order -- a real HTTP POST to the backend")
	bOk = oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
	Then("the backend accepted it (201 Created)", bOk, TRUE)

	When("the ADMIN part reads -- a separate real HTTP GET")
	Then("the admin SEES the phone's order", oB.RowCount(:admin, "orders"), 2)

	aAfter = oB.Dashboard(:admin)
	Then("the engine-computed total CHANGED: 15 + 12x2 = 39", aAfter[2], 39)
	Then("...and the top dish flipped to Couscous (24 > 15)", aAfter[3], "Couscous")
	Then("...computed over 2 live rows, not the frozen model", len(aAfter[1]), 2)
EndScenario()

Scenario("the state left the model: the topology is untouched")
	Given("the live backend now holds two orders")
	Then("the MODEL still holds only the one it was declared with",
	     len(oT.Dataset("orders")), 1)
	Then("...so the parts are sharing LIVE state, not re-reading the model",
	     oB.RowCount(:admin, "orders"), 2)
EndScenario()

Scenario("a cross-part write is a governed crossing, like every other effect")
	Given("an LLM actor bound as the acting actor")
	oB.SetActorQ(LLMActor("planner"))
	Then("the backend is governed", oB.IsGoverned(), TRUE)

	When("the LLM READS the whole solution (sensing is free)")
	Then("it sees every order", len(oB.Rows(:admin, "orders")), 2)

	When("the LLM tries to WRITE (an effect it does not hold)")
	bRaised = FALSE
	try
		oB.Create(:phone, "orders", [ [ "dish", "Tajine" ], [ "qty", 9 ] ])
	catch
		bRaised = TRUE
	done
	Then("the crossing is REFUSED", bRaised, TRUE)
	Then("...nothing was written", oB.RowCount(:admin, "orders"), 2)
	Then("...and the refusal is audited, not silent", len(oB.RefusedCrossings()), 1)

	When("an effectful human actor acts instead")
	oB.SetActorQ(HumanActor("ops"))
	Then("the same write is admitted",
	     oB.Create(:phone, "orders", [ [ "dish", "Tajine" ], [ "qty", 1 ] ]), TRUE)
	Then("...and the state grew", oB.RowCount(:admin, "orders"), 3)
EndScenario()

Scenario("every crossing is on the record")
	Given("the traffic log the backend kept throughout")
	Then("it recorded crossings from both parts", oB.TrafficCount() > 6, TRUE)
	Then("...the phone's are attributed to the phone", len(oB.TrafficOf(:phone)) > 0, TRUE)
	Then("...and the admin's to the admin", len(oB.TrafficOf(:admin)) > 0, TRUE)
	cNar = BackendText(oB)
	Then("Explain() names the backend and its port",
	     StzFindFirst("Live backend 'restolean'", cNar) > 0, TRUE)
	Then("...and says it is governed", StzFindFirst("governed", cNar) > 0, TRUE)
EndScenario()

Scenario("a non-ASCII dish name survives the whole live path")
	Given("Softanza is unicode-first, so an Arabic dish is an ordinary value")
	When("the phone orders a dish written in Arabic")
	oB.Create(:phone, "orders", [ [ "dish", "كسكس" ], [ "qty", 1 ] ])
	aRows = oB.Rows(:admin, "orders")
	Then("it round-trips HTTP -> sqlite -> json -> the admin intact",
	     aRows[len(aRows)][1], "كسكس")
	# Regression guard: this used to come back as "كسكس" truncated to half its
	# bytes. stzAppServer._ParseFormBody sliced with StzMidToEnd, which feeds a
	# CODEPOINT index to a BYTE-addressed engine slice -- so every non-ASCII
	# form value POSTed to the MBaaS floor was silently corrupted. Both that
	# parser and the request-body split are split-based now.
EndScenario()

Scenario("teardown releases the host, the client and the database")
	oB.Stop()
	Then("the backend reports stopped", oB.IsLive(), FALSE)
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

# Explain() returns a list of lines -- join for substring checks.
# (nCount, not nL: 'nL' would alias Ring's case-insensitive builtin 'nl'.)
func BackendText oBackend
	aLines = oBackend.Explain()
	cT = ""
	nCount = len(aLines)
	for i = 1 to nCount
		cT += aLines[i] + nl
	next
	return cT
