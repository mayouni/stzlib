load "../../stzBase.ring"
load "../_narrated.ring"

# R5 (reactor-runtime slice) -- stzAgentHost: the PI-agent perceive-act
# loop becomes a SUPERVISED, CANCELLABLE, TRACED, DECOMMISSIONABLE job
# ON THE REACTOR. The loop the R7 delivery plane runs is the same loop
# the agents run on -- "the agent host IS the same host" (5.10). R4b's
# DecommissionContract is enforced: retirement is EARNED.
#
# Offline + deterministic: the host's inter-tick wait is a real libuv
# timer on the engine loop thread; no network needed.

# NOTE: helper funcs live at the END of this file -- top-level
# executable code (the scenarios) must come BEFORE the first func, or
# Ring absorbs it all into that function's body (the file goes silent).

$oHost = new stzAgentHost()

Scenario("an agent is supervised as a job on the reactor loop")
	Given("a governed kitchen bot handed to the host")
	$oHost.Supervise(BuildKitchenBot(), 20)
	Then("the host supervises one agent", $oHost.NumberOfAgents(), 1)
	Then("it is active", $oHost.IsActive("kitchen-bot"), TRUE)
	Then("it has not ticked yet", $oHost.TicksOf("kitchen-bot"), 0)
	Then("the host owns a real reactor", isObject($oHost.ReactorQ()), TRUE)
EndScenario()

Scenario("RunFor drives perceive-decide-act on the libuv loop")
	Given("the supervised bot with low stock")
	When("the host runs the loop for 120ms")
	$oHost.RunFor(120)
	Then("the bot ticked at least once", $oHost.TicksOf("kitchen-bot") >= 1, TRUE)
	oLive = $oHost.AgentQ("kitchen-bot")
	Then("the governed skill fired: stock is now ordered",
		oLive.MemoryQ().Fact("stock", "level", "ordered"), 1)
	Then("and low stock was cleared",
		oLive.MemoryQ().Fact("stock", "level", "low"), 0)
	Then("the decision left a governed lineage",
		len(oLive.DecisionLog()) >= 1, TRUE)
EndScenario()

Scenario("every tick is traced")
	Given("the host trace after the run")
	aTr = $oHost.Trace()
	Then("the trace has entries", len(aTr) >= 1, TRUE)
	Then("each entry names the agent", aTr[1][2], "kitchen-bot")
EndScenario()

Scenario("a governance refusal stops the act, not the tick")
	Given("a bot whose authority does NOT cover the action's risk tier")
	oWeak = new stzPIAgent("weak-bot")
	oWeak.MemoryQ().Learn("stock", "level", "low")
	oWeak.GovernanceQ().DeclareRisk("order-stock", 4)          # critical
	oWeak.GovernanceQ().GrantPermission("weak-bot", "order-stock")
	oWeak.GovernanceQ().SetAuthority("weak-bot", :Delegated)   # level 2
	oSk = new stzAgentSkill("restock")
	oSk.SetWhen(func oMem { return oMem.Fact("stock", "level", "low") })
	oSk.SetDoes(func oMem { oMem.Learn("stock", "level", "ordered")  return 1 })
	oSk.SetVerifiedBy(func oMem { return oMem.Fact("stock", "level", "ordered") })
	oWeak.AddGovernedSkill(oSk, "order-stock")
	$oHost.Supervise(oWeak, 20)
	When("the host runs the loop")
	$oHost.RunFor(80)
	oLive = $oHost.AgentQ("weak-bot")
	Then("the bot ticked", $oHost.TicksOf("weak-bot") >= 1, TRUE)
	Then("but the risk-4 act was REFUSED (stock still low)",
		oLive.MemoryQ().Fact("stock", "level", "low"), 1)
	Then("the refusal is in the decision log",
		len(oLive.DecisionLog()) >= 1, TRUE)
EndScenario()

Scenario("an agent is cancellable (reversible pause)")
	Given("the kitchen bot, now at fixpoint")
	nBefore = $oHost.TicksOf("kitchen-bot")
	When("it is cancelled and the loop runs")
	$oHost.Cancel("kitchen-bot")
	Then("it is no longer active", $oHost.IsActive("kitchen-bot"), FALSE)
	$oHost.RunFor(60)
	Then("a cancelled agent does not tick", $oHost.TicksOf("kitchen-bot"), nBefore)
	When("it is resumed")
	$oHost.Resume("kitchen-bot")
	Then("it is active again", $oHost.IsActive("kitchen-bot"), TRUE)
EndScenario()

Scenario("retirement is EARNED -- the R4b decommission gate")
	Given("a decommission contract declared THROUGH the host")
	$oHost.DeclareDecommission("kitchen-bot", [ "handover-notes", "final-report" ])

	When("retirement is attempted with obligations pending")
	Then("it is REFUSED", $oHost.Retire("kitchen-bot"), FALSE)
	Then("the bot keeps running (still supervised, active)",
		$oHost.IsActive("kitchen-bot"), TRUE)
	Then("the why names pending obligations",
		StzFindFirst($oHost.Why(), "pending") > 0, TRUE)

	When("only one obligation is fulfilled")
	$oHost.FulfillObligation("kitchen-bot", "handover-notes")
	Then("retirement is STILL refused", $oHost.Retire("kitchen-bot"), FALSE)

	When("the last obligation is fulfilled")
	$oHost.FulfillObligation("kitchen-bot", "final-report")
	Then("retirement is now GRANTED", $oHost.Retire("kitchen-bot"), TRUE)
	Then("the bot is retired", $oHost.IsRetired("kitchen-bot"), TRUE)
	When("the loop runs after retirement")
	nAfter = $oHost.TicksOf("kitchen-bot")
	$oHost.RunFor(60)
	Then("a retired agent never ticks again", $oHost.TicksOf("kitchen-bot"), nAfter)
EndScenario()

Scenario("EVENT-DRIVEN supervision -- the perceive-act loop IS an event loop")
	Given("a governed order-bot supervised on the 'orders' event channel")
	$oBus = new stzEventBus()
	$oBus.ClearAll()
	$oHost.SuperviseOnEvent(BuildOrderBot(), "orders")
	Then("it is supervised on that channel", $oHost.ChannelOf("order-bot"), "orders")
	Then("with no events yet, it has not ticked", $oHost.TicksOf("order-bot"), 0)

	When("three orders are EMITTED on the bus and the host runs")
	$oBus.Emit("orders", "burger")
	$oBus.Emit("orders", "fries")
	$oBus.Emit("orders", "shake")
	$oHost.RunFor(80)
	Then("the agent reacted ONCE PER EVENT (not on a timer)",
		$oHost.TicksOf("order-bot"), 3)
	oLive = $oHost.AgentQ("order-bot")
	Then("it PERCEIVED the latest event off the bus",
		oLive.MemoryQ().Fact("order", "last", "shake"), 1)

	When("two more orders arrive")
	$oBus.Emit("orders", "salad")
	$oBus.Emit("orders", "soda")
	$oHost.RunFor(80)
	Then("the agent caught up -- 5 reactions total", $oHost.TicksOf("order-bot"), 5)

	When("an UNsubscribed channel gets traffic")
	$oBus.Emit("kitchen-noise", "clatter")
	$oHost.RunFor(60)
	Then("the order-bot ignores events on other channels (still 5)",
		$oHost.TicksOf("order-bot"), 5)

	When("the bus is queried directly (the un-orphaned engine event bus)")
	Then("it reports the events emitted on the channel", $oBus.EventCount("orders"), 5)
	Then("and the last payload", $oBus.LastEvent("orders"), "soda")
EndScenario()

Scenario("teardown releases the owned reactor")
	Given("the host after all runs")
	$oHost.Shutdown()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

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
	# event-driven: fire every cycle (one cycle == one delivered event); the
	# act PERCEIVES the latest event off the engine bus and records it.
	oSk.SetWhen(func oMem { return TRUE })
	oSk.SetDoes(func oMem {
		oB = new stzEventBus()
		cLast = oB.LastEvent("orders")
		oMem.Learn("order", "last", cLast)
		return 1
	})
	oSk.SetVerifiedBy(func oMem { return TRUE })
	oAg.AddGovernedSkill(oSk, "log-order")
	return oAg
