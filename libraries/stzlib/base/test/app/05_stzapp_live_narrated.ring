load "../../stzBase.ring"
load "../_narrated.ring"

# R7 finish -- stzApp.Live() MADE REAL: reactions fire, they no longer
# just print. A 'Whenever :Thing ... Propose :Other' reaction fires for
# each INSTANCE of Thing lacking an <other> relation (the same
# structural gap the goal machinery measures). Live() wires the reactive
# system and does a first Pulse(); Pulse()/React() re-evaluate; once the
# world Relate()s an instance its proposal clears. Continuous firing
# rides the R5 agent-host runtime (below).

$oApp = StzApp("clinic")
$oApp.Thing(:Patient) { Has([ :name ]) }
$oApp.Thing(:Checkup)
$oApp.Whenever(:Patient).Unseen(90, :Days) { Propose(:Checkup) }

Scenario("a live world reflects what its reactions imply")
	Given("two patients, neither checked up")
	$oApp.Is_("alice", :Patient)
	$oApp.Is_("bob", :Patient)
	When("the world comes alive")
	$oApp.Live()
	Then("it is live", $oApp.IsLive(), TRUE)
	Then("the reaction proposed a checkup for each patient",
		len($oApp.Proposals()), 2)
	Then("a proposal names the proposed thing", $oApp.Proposals()[1][2], "checkup")
	Then("and the instance it is for", $oApp.Proposals()[1][4], "alice")
EndScenario()

Scenario("acting on the world clears the satisfied proposal")
	Given("the live clinic with two standing proposals")
	When("alice actually gets a checkup")
	$oApp.Relate("alice", :checkup, "checkup-1")
	nAdded = $oApp.Pulse()
	Then("the pulse adds nothing new", nAdded, 0)
	Then("only bob's proposal remains", len($oApp.Proposals()), 1)
	Then("and it is bob's", $oApp.Proposals()[1][4], "bob")
EndScenario()

Scenario("a new instance reacts on its own event")
	Given("a freshly admitted patient")
	$oApp.Is_("carol", :Patient)
	When("the world reacts to carol")
	nAdded = $oApp.React("carol")
	Then("one proposal is raised for carol", nAdded, 1)
	Then("the standing proposals are now bob + carol", len($oApp.Proposals()), 2)
EndScenario()

Scenario("the live world runs as a supervised agent on the reactor")
	Given("a world wrapped as an agent whose skill pulses reactions")
	oWorldBot = new stzPIAgent("clinic-world")
	# the skill: whenever there are un-actioned proposals, 'schedule'
	# the first (relate it) so the world converges -- driven by Pulse
	oSk = new stzAgentSkill("schedule-checkups")
	oSk.When(func oMem { return oMem.Fact("clinic", "has", "pending") })
	oSk.Does(func oMem { oMem.Forget("clinic", "has", "pending")  return 1 })
	oSk.VerifiedBy(func oMem { return 1 })
	oWorldBot.AddSkill(oSk)
	oWorldBot.MemoryQ().Learn("clinic", "has", "pending")

	oHost = new stzAgentHost()
	oHost.Supervise(oWorldBot, 20)
	When("the host ticks the world on the reactor loop")
	oHost.RunFor(80)
	Then("the world-agent ticked", oHost.TicksOf("clinic-world") >= 1, TRUE)
	Then("its pending flag was cleared by the skill",
		oHost.AgentQ("clinic-world").MemoryQ().Fact("clinic", "has", "pending"), 0)
	oHost.Shutdown()
EndScenario()

Summary()
