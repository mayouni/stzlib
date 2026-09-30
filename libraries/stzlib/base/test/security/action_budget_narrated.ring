load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-ACTION-BUDGET-01 -- threat-model risk R7 (OWASP ASI08, cascading
# failures): a runaway agent is contained, not merely slowed.
#
# One agent acting in a loop floods everything downstream of it. The host
# now keeps, per agent, a budget of ACTIONS (skill firings) in a window:
# SetActionBudget(name, maxActs, windowMs). An agent that exceeds it is
# QUARANTINED -- it stays stopped until an effectful actor releases it, and
# the reason says how far over it went. Both schedulers account, and so does
# an event-driven agent catching up on a burst of events.

$oHuman = HumanActor("oncall")

Scenario("a runaway on the timer is quarantined at its budget")
	oHost = new stzAgentHost()
	oHost.Supervise(new actingAgent("runaway"), 1)
	oHost.Supervise(new actingAgent("neighbour"), 1)
	oHost.SetActionBudget("runaway", 5, 60000)
	Pump(oHost, 20)
	Then("the runaway is quarantined", oHost.IsQuarantined("runaway"), 1)
	Then("...after exactly one act over its budget", oHost.TicksOf("runaway"), 6)
	Then("the reason says how far over it went",
		StzFindFirst("exceeded its action budget: 6 acts", oHost.QuarantineOf("runaway")[:reason]) > 0, 1)
	Then("the neighbour, with no budget, keeps running", oHost.TicksOf("neighbour") > 6, 1)
EndScenario()

Scenario("an agent within its budget is never stopped (negative sibling)")
	oHost = new stzAgentHost()
	oHost.Supervise(new actingAgent("steady"), 1)
	oHost.SetActionBudget("steady", 1000, 60000)
	Pump(oHost, 20)
	Then("not quarantined", oHost.IsQuarantined("steady"), 0)
	Then("its acts are counted", oHost.ActionBudgetOf("steady")[:acts] > 0, 1)
EndScenario()

Scenario("a released agent starts a fresh window")
	oHost = new stzAgentHost()
	oHost.Supervise(new actingAgent("runaway"), 1)
	oHost.SetActionBudget("runaway", 3, 60000)
	Pump(oHost, 10)
	Then("quarantined", oHost.IsQuarantined("runaway"), 1)
	oHost.Release("runaway", $oHuman)
	Then("released", oHost.IsQuarantined("runaway"), 0)
	Then("with a fresh count", oHost.ActionBudgetOf("runaway")[:acts], 0)
	Pump(oHost, 2)
	Then("its next acts do not re-trip it at once", oHost.IsQuarantined("runaway"), 0)
EndScenario()

Scenario("the engine loop accounts too")
	StzResetEngineAgentLoop()
	oHost = new stzAgentHost()
	oHost.UseEngineLoop()
	# the engine loop schedules only an agent whose reach is stated (Law 18)
	oHost.Declare("runaway", "acts on every tick -- the shape of a runaway", "reversible")
	oHost.Supervise(new actingAgent("runaway"), 1)
	oHost.SetActionBudget("runaway", 5, 60000)
	Pump(oHost, 20)
	Then("the engine-scheduled runaway is quarantined", oHost.IsQuarantined("runaway"), 1)
	Then("...at the same point", oHost.TicksOf("runaway"), 6)
	StzResetEngineAgentLoop()
EndScenario()

Scenario("an event-driven runaway stops in the middle of a burst")
	oBus = new stzEventBus()
	oHost = new stzAgentHost()
	oHost.SuperviseOnEvent(new actingAgent("listener"), "flood")
	oHost.SetActionBudget("listener", 5, 60000)
	for i = 1 to 20  oBus.Emit("flood", "e" + i)  next
	oHost.TickDue()
	Then("quarantined during the catch-up", oHost.IsQuarantined("listener"), 1)
	Then("...after 6 of the 20 events, not all 20", oHost.TicksOf("listener"), 6)
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

func Pump oHost, nPasses
	for i = 1 to nPasses
		StzEngineTimeSleepMs(3)
		oHost.TickDue()
	next

# an agent that fires one skill on every cycle -- the runaway's shape
class actingAgent from stzObject
	@cName = ""
	def init(pcName)
		@cName = "" + pcName
	def Name_()
		return @cName
	def Cycle()
		return 1
