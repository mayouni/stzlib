load "../../stzBase.ring"
load "../_narrated.ring"

# stzEventBus -- THE OO SURFACE OVER THE ENGINE EVENT BUS, and the one thing it
# could not tell you.
#
# The bus itself is in good order: declare, subscribe, emit, count, destroy all
# do what they say. What it lacked was a way to answer "is this the same channel
# I was watching?", and that gap had a live consumer.
#
# EventCount restarts at zero when a channel is remade -- DestroyChannel does it,
# and ClearAll, offered for test isolation, does it PROCESS-WIDE. stzAgentHost
# ticks an event-supervised agent once per new event by comparing the live count
# against a remembered one, so after a reset the remembered number was the bigger
# of the two and the agent went deaf. Measured before the fix: three events after
# a reset produced ONE tick instead of three.
#
# Watching for the count to DROP does not fix it. By the time anyone polls, the
# fresh channel may already have climbed past the remembered value and the dip is
# never seen -- which is exactly what the first attempt did, and it still lost
# two events. The engine now stamps every channel with a GENERATION that is
# unique for the life of the process and survives ClearAll, so the comparison is
# exact rather than a race.

pr()

Scenario("The bus does what its surface says")

	Given("a clean bus")
	oBus = new stzEventBus()
	oBus.ClearAll()
	Then("nothing is declared", oBus.NumberOfChannels(), 0)
	Then("...and an undeclared channel is not there", oBus.HasChannel("orders"), FALSE)

	When("a channel is declared")
	oBus.Channel("orders")
	Then("it exists", oBus.HasChannel("orders"), TRUE)
	Then("...and is counted", oBus.NumberOfChannels(), 1)
	Then("declaring is chainable", isObject(oBus.Channel("orders")), TRUE)
	Then("...and idempotent", oBus.NumberOfChannels(), 1)

	When("someone subscribes and an event is emitted")
	nSub = oBus.Subscribe("orders")
	Then("a subscriber id comes back", nSub > 0, TRUE)
	Then("...and is counted", oBus.SubscriberCount("orders"), 1)
	Then("the emit reports who it reached", oBus.Emit("orders", "burger"), 1)
	Then("...the channel counts it", oBus.EventCount("orders"), 1)
	Then("...and remembers the payload", oBus.LastEvent("orders"), "burger")

	When("the subscriber leaves")
	oBus.Unsubscribe(nSub)
	Then("the count drops", oBus.SubscriberCount("orders"), 0)
	Then("...and an emit now reaches nobody", oBus.Emit("orders", "fries"), 0)
	Then("...though the channel still counts it", oBus.EventCount("orders"), 2)

	# THE NEGATIVE SIBLINGS: refusals must be reported, not crashed on.
	Then("unsubscribing a stranger is refused", oBus.Unsubscribe(99999) < 0, TRUE)
	Then("emitting to an empty name is refused", oBus.Emit("", "x") < 0, TRUE)
	Then("...and no channel was made for it", oBus.NumberOfChannels(), 1)

	When("the channel is destroyed")
	oBus.DestroyChannel("orders")
	Then("it is gone", oBus.HasChannel("orders"), FALSE)
	Then("...and uncounted", oBus.NumberOfChannels(), 0)
EndScenario()

Scenario("Channels are separate, and the bus is one bus for the whole process")

	Given("two channels on one handle")
	oB = new stzEventBus()
	oB.ClearAll()
	oB.Emit("a", "apple")
	oB.Emit("b", "banana")

	Then("emitting declares the channel, as documented", oB.HasChannel("a"), TRUE)
	Then("each keeps its own payload", oB.LastEvent("a"), "apple")
	Then("...separately", oB.LastEvent("b"), "banana")
	Then("...and its own count", oB.EventCount("a"), 1)

	# The header promises this, and an agent host in the same process depends
	# on it, so it is asserted rather than assumed.
	Given("a SECOND handle on the same process bus")
	oB2 = new stzEventBus()
	Then("it sees the same channels", oB2.NumberOfChannels(), 2)
	Then("...and the same last event", oB2.LastEvent("a"), "apple")

	When("the second handle emits")
	oB2.Emit("a", "from-elsewhere")
	Then("the first handle sees it", oB.LastEvent("a"), "from-elsewhere")
	Then("...and the count is shared", oB.EventCount("a"), 2)
EndScenario()

Scenario("A generation says WHICH channel, not just whether one exists")

	Given("a fresh channel")
	oG = new stzEventBus()
	oG.ClearAll()
	oG.Channel("orders")
	nGen1 = oG.ChannelGeneration("orders")
	Then("it has a generation", nGen1 > 0, TRUE)
	Then("asking again gives the same one", oG.ChannelGeneration("orders"), nGen1)

	# Emitting must not change it -- it identifies the channel, not its traffic.
	oG.Emit("orders", "x")
	Then("emitting does not change it", oG.ChannelGeneration("orders"), nGen1)

	When("the channel is destroyed and remade under the same name")
	oG.DestroyChannel("orders")
	oG.Channel("orders")
	nGen2 = oG.ChannelGeneration("orders")

	Then("the name is back", oG.HasChannel("orders"), TRUE)
	Then("...its count restarted", oG.EventCount("orders"), 0)
	Then("...but it is a DIFFERENT channel", nGen2 != nGen1, TRUE)

	# ...and the point of it: the number never repeats, so a remade channel can
	# never be mistaken for the one it replaced -- not even after ClearAll,
	# which resets everything else.
	When("everything is cleared and the name is used again")
	oG.ClearAll()
	oG.Channel("orders")
	nGen3 = oG.ChannelGeneration("orders")
	Then("the generation moved on again", nGen3 != nGen2, TRUE)
	Then("...and never went backwards", nGen3 > nGen2, TRUE)

	# THE NEGATIVE SIBLING: a name nobody declared has no generation to give.
	Then("an unknown channel has none", oG.ChannelGeneration("no-such-thing") < 0, TRUE)
EndScenario()

Scenario("An event-supervised agent does not go deaf when its channel is remade")

	# This is what the generation was for. The host ticks once per new event by
	# comparing the live count against a remembered one; a reset made the
	# remembered number the bigger of the two, so the catch-up loop never ran.

	Given("an agent supervised on a channel, fed two events")
	$gBus = new stzEventBus()
	$gBus.ClearAll()
	$gHost = new stzAgentHost()
	$gHost.SuperviseOnEvent(BuildProbeBot(), "orders")

	$gBus.Emit("orders", "one")
	$gBus.Emit("orders", "two")
	$gHost.TickDue()
	Then("it ticked once per event", $gHost.TicksOf("probe-bot"), 2)

	When("the channel is cleared and three more events arrive")
	$gBus.ClearAll()
	$gBus.Emit("orders", "three")
	$gBus.Emit("orders", "four")
	$gBus.Emit("orders", "five")
	$gHost.TickDue()

	# Before the fix this answered 3: the remembered count was 2, the fresh
	# channel was at 3, and only the difference got through -- two events lost
	# in silence. With a higher prior count the agent would have stopped
	# ticking altogether.
	Then("every event still reaches the agent", $gHost.TicksOf("probe-bot"), 5)

	# THE NEGATIVE SIBLING: re-baselining must not replay history. A fresh
	# supervision starts from the channel's CURRENT count, so events that
	# happened before it began are not delivered.
	Given("an agent that starts watching a channel with a past")
	$gHost.Supervise(BuildLateBot(), 100000)   # timer-supervised, never due
	$gBus.Emit("orders", "six")
	$gHost2 = new stzAgentHost()
	$gHost2.SuperviseOnEvent(BuildLateBot(), "orders")
	$gHost2.TickDue()
	Then("the past is not replayed", $gHost2.TicksOf("late-bot"), 0)

	When("something new happens")
	$gBus.Emit("orders", "seven")
	$gHost2.TickDue()
	Then("...only that is delivered", $gHost2.TicksOf("late-bot"), 1)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

func BuildProbeBot()
	return new stzPIAgent("probe-bot")

func BuildLateBot()
	return new stzPIAgent("late-bot")
