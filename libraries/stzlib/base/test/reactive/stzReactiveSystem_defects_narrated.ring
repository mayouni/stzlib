load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveSystem -- the safe stop and BindObjects.
#
# Register rows (doc/DEFECTS.md, stzReactiveSystem): StopSafe and its five aliases
# (SafeStopLoop, SafeStopExecution, SafeStopLoopExecution, StopNext, StopNextLoop) and BindObjects.
#
# StopSafe scheduled a callback "Stop()" with SetTimeout. A Ring lambda is a global function: its
# bare Stop() found the profiler's global Stop, which raises the STOPPED banner, and the loop never
# ended cleanly. The request is now a flag on the live system, honoured by the loop at the end of
# the pass in which it was made. The loop is handed the system as its drain, so the flag is read on
# the live object and never on a copy.
#
# BindObjects wrapped COPIES of both objects (Ring copies an object it is handed), so the binding
# linked two throwaway wrappers. It now binds the reactive objects the caller passes, directly.
#
# EVERY loop here is bounded: the tick function stops the system at the 20th tick whatever else
# happens, so a bug cannot hang the run. "Ended early" means ended before that bound.

$nTicks = 0
$nStopAt = 0
$cStopCall = ""
$nBound = 20
$oRs = ""
$oCopy = ""
$bUseCopy = 0

Scenario("The safe stop ends the loop at the end of the pass that asked for it")
	Given("a system with one repeating timer, asking for the safe stop at tick 3")
	cErr = GRun("StopSafe", 3)
	Then("the run raised nothing (no STOPPED banner)", cErr, "")
	Then("the loop ended at the pass that asked: 3 ticks", $nTicks, 3)
	Then("...well before the bound of 20", $nTicks < $nBound, TRUE)
	Then("the system reports itself stopped", $oRs.@isRunning, ENGINE_STOPPED)
EndScenario()

Scenario("Without the safe stop the same loop keeps ticking until the bound")
	Given("the same system, asking for nothing")
	cErr = GRun("", 0)
	Then("the run raised nothing", cErr, "")
	Then("the loop ran to the bound: 20 ticks", $nTicks, 20)
	Given("the same system, asking for the plain Stop at tick 3")
	cErr = GRun("Stop", 3)
	Then("the plain Stop also ends it at 3 (the safe one is not the only exit)", $nTicks, 3)
EndScenario()

Scenario("The five other spellings do the same")
	acNames = [ "SafeStopLoop", "SafeStopExecution", "SafeStopLoopExecution", "StopNext", "StopNextLoop" ]
	nNames = len(acNames)
	for i = 1 to nNames
		cErr = GRun(acNames[i], 4)
		Then(acNames[i] + " raised nothing", cErr, "")
		Then(acNames[i] + " ended the loop at 4 ticks", $nTicks, 4)
	next
EndScenario()

Scenario("A request made while no loop runs does not carry over to the next run")
	Given("a system asked for the safe stop BEFORE Start")
	$nTicks = 0
	$nStopAt = 0
	$cStopCall = ""
	$oRs = new stzReactiveSystem()
	$oRs.StopSafe()
	$oRs.RunEvery(15, "GTick")
	cErr = ""
	try
		$oRs.Start()
	catch
		cErr = CatchError()
	done
	Then("the run raised nothing", cErr, "")
	Then("the loop ran to the bound: the old request was dropped at Start", $nTicks, 20)
EndScenario()

Scenario("A task can ask for the safe stop before the first pass")
	# A slow timer (300 ms) so that the first pass is certainly before it is due, and a bound
	# of 2 ticks so that the sibling run takes about 0.6 s.
	Given("a system with a slow repeating timer and a task that asks for the safe stop")
	$nBound = 2
	$nTicks = 0
	$nStopAt = 0
	$cStopCall = ""
	$oRs = new stzReactiveSystem()
	$oRs.RunEvery(300, "GTick")
	$oRs.CreateTask("t1", "GTaskStop")
	cErr = ""
	try
		$oRs.Start()
	catch
		cErr = CatchError()
	done
	Then("the run raised nothing", cErr, "")
	Then("the loop ended at its first pass, before the timer was due: 0 ticks", $nTicks, 0)

	Given("the same system with a task that asks for nothing")
	$nTicks = 0
	$oRs = new stzReactiveSystem()
	$oRs.RunEvery(300, "GTick")
	$oRs.CreateTask("t2", "GTaskNothing")
	cErr = ""
	try
		$oRs.Start()
	catch
		cErr = CatchError()
	done
	Then("the loop ran to its bound: 2 ticks", $nTicks, 2)
	$nBound = 20
EndScenario()

Scenario("BindObjects binds the reactive objects you pass")
	oRs2 = new stzReactiveSystem()
	oSrc = oRs2.ReactiveObject()
	oTgt = oRs2.ReactiveObject()
	oSrc.SetAttribute(:name, "Ann")
	oTgt.SetAttribute(:other, "keep")

	Given("a source holding name = Ann and a target without an alias")
	Then("the target has no alias yet", oTgt.GetAttribute(:alias), "")

	When("the two are bound, name to alias")
	nRes = oRs2.BindObjects(oSrc, :name, oTgt, :alias, "")
	Then("it answers 1", nRes, 1)
	Then("the target YOU PASSED now holds the source value", oTgt.GetAttribute(:alias), "Ann")
	Then("...an unrelated attribute of the target is untouched", oTgt.GetAttribute(:other), "keep")
	Then("...the source is unchanged", oSrc.GetAttribute(:name), "Ann")

	When("the target attribute name is left empty")
	oTgt2 = oRs2.ReactiveObject()
	nRes2 = oRs2.BindObjects(oSrc, :name, oTgt2, "", "")
	Then("the same name is used on the target", oTgt2.GetAttribute(:name), "Ann")

	When("the source changes afterwards")
	oSrc.SetAttribute(:name, "Bob")
	Then("the source holds the new value", oSrc.GetAttribute(:name), "Bob")
	Then("LIMIT: the target keeps the value of the moment of binding (BindTo keeps a copy of its target)",
		oTgt.GetAttribute(:alias), "Ann")
EndScenario()

Scenario("BindObjects refuses what it cannot bind, and says so")
	oRs3 = new stzReactiveSystem()
	oPlainA = new persbind
	oPlainB = new persbind
	oPlainA.name = "Ann"

	Given("two PLAIN objects (not reactive objects)")
	nRes = oRs3.BindObjects(oPlainA, :name, oPlainB, :name, "")
	Then("it answers 0", nRes, 0)
	Then("...and the target you passed is unchanged", oPlainB.name, "")
	Then("...as is the source", oPlainA.name, "Ann")

	Given("a reactive source and a plain target")
	oSrc = oRs3.ReactiveObject()
	oSrc.SetAttribute(:name, "Ann")
	Then("it answers 0", oRs3.BindObjects(oSrc, :name, oPlainB, :name, ""), 0)
	Then("...and the plain target is unchanged", oPlainB.name, "")

	Given("something that is not an object at all")
	Then("it answers 0", oRs3.BindObjects("text", :name, 42, :name, ""), 0)
EndScenario()

Scenario("LIMIT: a request made on a COPY of the system is not seen by the loop")
	Given("a loop whose tick asks for the safe stop on a copy taken before Start")
	$nTicks = 0
	$nStopAt = 3
	$cStopCall = "StopSafe"
	$oRs = new stzReactiveSystem()
	$oRs.RunEvery(15, "GTick")
	$oCopy = $oRs
	$bUseCopy = 1
	cErr = ""
	try
		$oRs.Start()
	catch
		cErr = CatchError()
	done
	$bUseCopy = 0
	Then("the run raised nothing", cErr, "")
	Then("the loop was not stopped by the copy: it ran to the bound, 20 ticks", $nTicks, 20)
EndScenario()

Summary()

#-- helpers --------------------------------------------------------------------

# The repeating tick: counts, asks for the call named in $cStopCall at tick $nStopAt, and stops
# the system at $nBound whatever happens so that a bug cannot hang the run.
func GTick()
	$nTicks++
	if $nTicks = $nStopAt and $cStopCall != ""
		if $bUseCopy
			eval("$oCopy." + $cStopCall + "()")
		else
			eval("$oRs." + $cStopCall + "()")
		ok
	ok
	if $nTicks >= $nBound
		$oRs.Stop()
	ok

func GTaskStop()
	$oRs.StopSafe()

func GTaskNothing()
	nX = 1

# One run: a fresh system with one 15 ms repeating timer; returns the error text ("" when none).
func GRun(cStopCall, nStopAt)
	$nTicks = 0
	$nStopAt = nStopAt
	$cStopCall = cStopCall
	$oRs = new stzReactiveSystem()
	$oRs.RunEvery(15, "GTick")
	cErr = ""
	try
		$oRs.Start()
	catch
		cErr = CatchError()
	done
	return cErr

class persbind
	name = ""
