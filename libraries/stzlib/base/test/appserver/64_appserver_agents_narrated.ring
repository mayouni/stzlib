load "../../stzBase.ring"
load "../_narrated.ring"

# stzAppServer HOSTS AGENTS -- the R5 deferred slice, landed (2026-07-23).
#
# stzAppServer's own header has carried this promise since R7: "AGENTS: the
# same event loop is the R5 perceive-decide-act spine; agent hosting lands with
# the reactor-runtime slice, NOT stubbed here." stzAgentHost was built for it --
# its SetReactor() is documented as "share another host's loop (e.g. an
# stzAppServer's)". What was missing was the server side: nothing attached a
# host, and RunFor() only ever drained HTTP, so a hosted agent would never tick.
#
# Two things land here:
#
# 1. INTERLEAVING. With agents hosted the serve slice is BOUNDED: ServeOne()
#    would otherwise park on the socket for the whole remaining time whenever
#    no request arrives, and the agents -- on that same loop -- would starve.
#    Serve a slice, tick what is due, repeat. One loop, both duties.
#
# 2. AN OBSERVABILITY SURFACE, deliberately READ-ONLY. Pausing and retiring an
#    agent are EFFECTS, and the library's rule is that expression is free but
#    admission is governed. An unauthenticated socket carries no actor, so it
#    may not commit. Control stays in-process, where the R4b decommission
#    contract gates it.

$CRLF = char(13) + char(10)

oSrv = new stzAppServer()
oCli = new stzReactor()

Scenario("the agent host IS the same host")
	Given("a running server")
	oSrv.Start(0, "127.0.0.1")
	Then("it hosts no agents yet", oSrv.IsHostingAgents(), FALSE)
	# supervising before hosting is a mistake worth naming, not a silent no-op
	bRaised = FALSE
	try
		oSrv.SuperviseAgent(BuildKitchenBot(), 20)
	catch
		bRaised = TRUE
	done
	Then("supervising before HostAgents() is refused", bRaised, TRUE)

	When("HostAgents() attaches a host onto the server's own loop")
	oSrv.HostAgents()
	Then("the server is hosting", oSrv.IsHostingAgents(), TRUE)
	Then("...with no agents yet", oSrv.NumberOfAgents(), 0)
EndScenario()

Scenario("requests and perceive-decide-act interleave on ONE loop")
	Given("a governed kitchen-bot ticking every 20ms, and an ordinary route")
	oSrv.SuperviseAgent(BuildKitchenBot(), 20)
	oSrv.Get_("/greet", func oReq, oResp { oResp.Text("hello") })
	Then("the agent is supervised", oSrv.NumberOfAgents(), 1)
	Then("...and nameable", oSrv.AgentNames()[1], "kitchen-bot")
	Then("it has not ticked before the loop runs", oSrv.AgentTicks("kitchen-bot"), 0)

	When("the server runs for 300ms with no traffic at all")
	oSrv.RunFor(300)
	Then("the agent TICKED anyway -- an idle socket no longer starves it",
	     oSrv.AgentTicks("kitchen-bot") > 1, TRUE)
	Then("...and every tick is traced", len(oSrv.AgentTrace()) > 1, TRUE)
	nAfterIdle = oSrv.AgentTicks("kitchen-bot")

	When("a real HTTP request is served while the agents are live")
	cBody = Roundtrip(oCli, oSrv, "GET /greet HTTP/1.1")
	Then("the ordinary route still answers", StzFindFirst("hello", cBody) > 0, TRUE)
	Then("...and hosting did not break the 200", StzFindFirst("200 OK", cBody) > 0, TRUE)

	When("the loop runs again")
	oSrv.RunFor(200)
	Then("the agent kept ticking across the request",
	     oSrv.AgentTicks("kitchen-bot") > nAfterIdle, TRUE)
EndScenario()

Scenario("the agent surface reports the LIVE host over HTTP")
	cBody = Roundtrip(oCli, oSrv, "GET /agents HTTP/1.1")
	Then("GET /agents lists the hosted agent", StzFindFirst('"name":"kitchen-bot"', cBody) > 0, TRUE)
	Then("...as active and not retired",
	     StzFindFirst('"active":1', cBody) > 0 and StzFindFirst('"retired":0', cBody) > 0, TRUE)
	# the tick count in the response is the one the loop is actually advancing
	Then("...carrying the live tick count",
	     StzFindFirst('"ticks":' + oSrv.AgentTicks("kitchen-bot"), cBody) > 0, TRUE)

	cBody = Roundtrip(oCli, oSrv, "GET /agents/kitchen-bot HTTP/1.1")
	Then("GET /agents/<name> answers for one agent", StzFindFirst('"agent":', cBody) > 0, TRUE)

	cBody = Roundtrip(oCli, oSrv, "GET /agents/trace HTTP/1.1")
	Then("GET /agents/trace exposes the perceive-act trace",
	     StzFindFirst('"trace":', cBody) > 0 and StzFindFirst('"why":"tick', cBody) > 0, TRUE)

	cBody = Roundtrip(oCli, oSrv, "GET /agents/no-such-bot HTTP/1.1")
	Then("an unknown agent is a clean 404", StzFindFirst("404", cBody) > 0, TRUE)
EndScenario()

Scenario("the surface is READ-ONLY -- an unauthenticated socket may not commit")
	When("something POSTs to the agent surface")
	cBody = Roundtrip(oCli, oSrv, "POST /agents/kitchen-bot HTTP/1.1")
	Then("it is refused with 405", StzFindFirst("405", cBody) > 0, TRUE)
	Then("...and says why: control is in-process and governed",
	     StzFindFirst("read-only", cBody) > 0, TRUE)
	# This is the doctrine, not an omission: expression is free, admission is
	# governed. A socket carries no actor, so it cannot pause or retire an
	# agent. In-process control is exercised below, where governance applies.
EndScenario()

Scenario("EVENT-DRIVEN agents on the server's loop")
	Given("an order-bot supervised on the 'orders' channel, not a timer")
	oBus = new stzEventBus()
	oBus.ClearAll()
	oSrv.SuperviseAgentOnEvent(BuildOrderBot(), "orders")
	Then("it has not ticked with no events", oSrv.AgentTicks("order-bot"), 0)

	When("three orders are emitted and the SERVER runs")
	oBus.Emit("orders", "burger")
	oBus.Emit("orders", "fries")
	oBus.Emit("orders", "shake")
	oSrv.RunFor(150)
	Then("the agent reacted once per EVENT, driven by the serve loop",
	     oSrv.AgentTicks("order-bot"), 3)
	Then("...and the timer-driven bot is unaffected on the same loop",
	     oSrv.AgentIsActive("kitchen-bot"), TRUE)
EndScenario()

Scenario("in-process control: pause, resume")
	oSrv.PauseAgent("order-bot")
	Then("a paused agent is inactive", oSrv.AgentIsActive("order-bot"), FALSE)
	When("more events arrive while it is paused")
	oBus.Emit("orders", "salad")
	oSrv.RunFor(120)
	Then("it did not react", oSrv.AgentTicks("order-bot"), 3)
	When("it is resumed")
	oSrv.ResumeAgent("order-bot")
	oSrv.RunFor(120)
	Then("it catches up on what it missed", oSrv.AgentTicks("order-bot"), 4)
EndScenario()

Scenario("retirement is EARNED, even on a hosted agent (R4b)")
	Given("a decommission obligation declared for the order-bot")
	oSrv.DeclareAgentDecommission("order-bot", [ "handover-log" ])
	When("retirement is attempted with the obligation outstanding")
	Then("it is REFUSED", oSrv.RetireAgent("order-bot"), FALSE)
	Then("...with a reason", len(oSrv.AgentWhy()) > 0, TRUE)
	Then("...and it keeps running", oSrv.AgentIsRetired("order-bot"), FALSE)

	When("the obligation is fulfilled")
	oSrv.FulfillAgentObligation("order-bot", "handover-log")
	Then("retirement is granted", oSrv.RetireAgent("order-bot"), TRUE)
	Then("...and it is retired", oSrv.AgentIsRetired("order-bot"), TRUE)

	nBefore = oSrv.AgentTicks("order-bot")
	oBus.Emit("orders", "soda")
	oSrv.RunFor(120)
	Then("a retired agent stops ticking permanently",
	     oSrv.AgentTicks("order-bot"), nBefore)
	Then("...while the kitchen-bot carries on", oSrv.AgentIsActive("kitchen-bot"), TRUE)
EndScenario()

Scenario("teardown")
	oCli.Destroy()
	oSrv.Stop()
	Then("the server stopped with agents attached", oSrv.IsRunning(), FALSE)
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()


# -- helpers (after ALL top-level code; Ring hoists func defs) -----------

func Roundtrip oClient, oServer, cLine
	cReq = cLine + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oServer.Port(), cReq)
	oServer.ServeOne(3000)
	return oClient.AwaitTcp(nJob, 5000)

func BuildKitchenBot()
	oAg = new stzPIAgent("kitchen-bot")
	oAg.MemoryQ().Learn("stock", "level", "low")
	oAg.GovernanceQ().DeclareRisk("order-stock", 2)
	oAg.GovernanceQ().GrantPermission("kitchen-bot", "order-stock")
	oAg.GovernanceQ().SetAuthority("kitchen-bot", :Delegated)
	oSk = new stzAgentSkill("restock")
	oSk.SetWhen(func oMem { return oMem.Fact("stock", "level", "low") })
	oSk.SetDoes(func oMem {
		oMem.Forget("stock", "level", "low")
		oMem.Learn("stock", "level", "ordered")
		return 1
	})
	oSk.SetVerifiedBy(func oMem { return oMem.Fact("stock", "level", "ordered") })
	oAg.AddGovernedSkill(oSk, "order-stock")
	return oAg

func BuildOrderBot()
	oAg = new stzPIAgent("order-bot")
	oAg.GovernanceQ().DeclareRisk("log-order", 1)
	oAg.GovernanceQ().GrantPermission("order-bot", "log-order")
	oAg.GovernanceQ().SetAuthority("order-bot", :Delegated)
	oSk = new stzAgentSkill("log-order")
	oSk.SetWhen(func oMem { return TRUE })
	oSk.SetDoes(func oMem {
		oB = new stzEventBus()
		oMem.Learn("order", "last", oB.LastEvent("orders"))
		return 1
	})
	oSk.SetVerifiedBy(func oMem { return TRUE })
	oAg.AddGovernedSkill(oSk, "log-order")
	return oAg
