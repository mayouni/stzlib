load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveSystem -- THE TIMER SURFACE: RunAfter, RunEvery, their XT forms
# and their aliases.
#
# Three defects, each of a kind this module has taught to look for:
#
#   SetTimeoutXT      had NO BODY. It was declared and the next line was the
#                     next method, so every call scheduled nothing and answered
#                     nothing -- while SetTimeout, one screen down, delegates
#                     correctly.
#
#   an unknown unit   became MILLISECONDS in silence. Both XT forms carried
#                     their own copy of the same switch and both ended at `ok`
#                     with no else, so RunAfterXT(5, :hours) asked for five
#                     milliseconds: wrong by a factor of 3,600,000.
#
#   StopTimer         could not stop a repeating timer. RunEvery answered the
#                     timer OBJECT, and AddTimer stores a COPY, so Stop() set a
#                     flag on the caller's copy while the manager went on firing
#                     the one it holds.

pr()

Scenario("The XT alias schedules something")

	Given("a reactive system")
	oRs = new stzReactiveSystem()
	Then("it starts with no timers", NTimers(oRs), 0)

	When("a timeout is set through the XT alias")
	cId = oRs.SetTimeoutXT(50, "milliseconds", func { })

	# Both halves matter. It answered nothing AND scheduled nothing, so either
	# check alone could be satisfied by half a fix.
	Then("it answers a timer id", cId != "", TRUE)
	Then("...and a timer is actually registered", NTimers(oRs), 1)

	# THE NEGATIVE SIBLING: the id has to name THAT timer, not merely be
	# non-empty -- stopping by it must work.
	oRs.StopTimer(cId)
	Then("the id it answered can stop it", NTimers(oRs), 0)
EndScenario()

Scenario("A unit the clock cannot read is refused, not silently the smallest one")

	Given("a reactive system asked to wait five hours")
	oRs2 = new stzReactiveSystem()
	oRs2.RunAfterXT(5, "hours", func { })

	Then("five hours is five hours", FirstInterval(oRs2), 5 * HOUR)

	Given("the units that were already understood")
	Then("seconds scale up", IntervalFor("seconds", 5), 5 * SECOND)
	Then("minutes too", IntervalFor("minutes", 5), 5 * MINUTE)
	Then("milliseconds pass through", IntervalFor("milliseconds", 5), 5)
	Then("...and so does a missing unit", IntervalFor(NULL, 5), 5)

	# The refusal. Scheduling five milliseconds for "five fortnights" is worse
	# than scheduling nothing, because nothing is visible and five milliseconds
	# looks like it worked.
	Given("a unit nobody can convert")
	oRs3 = new stzReactiveSystem()
	uAns = oRs3.RunAfterXT(5, "fortnights", func { })

	Then("it is refused", uAns, "")
	Then("...and nothing was scheduled", NTimers(oRs3), 0)
	Then("...and the repeating form refuses the same way", oRs3.RunEveryXT(5, "fortnights", func { }), "")

	# ...as does a delay that is not a number, or is negative.
	Then("a non-numeric delay is refused", oRs3.RunAfterXT("soon", "seconds", func { }), "")
	Then("a negative delay is refused", oRs3.RunAfterXT(-5, "seconds", func { }), "")
	Then("and still nothing was scheduled", NTimers(oRs3), 0)
EndScenario()

Scenario("A repeating timer can be stopped")

	# This is the one that mattered. RunEvery handed back the timer OBJECT, and
	# AddTimer stores a COPY -- so Stop() on what you were given set a flag on
	# something the manager had never heard of, and the real timer kept firing.
	# Removing it from the manager BY ID is what actually stops a timer.

	Given("a repeating timer")
	oRs4 = new stzReactiveSystem()
	nTicks = 0
	uHandle = oRs4.RunEvery(5, func { nTicks++ })

	Then("it is registered", NTimers(oRs4), 1)

	When("it is stopped")
	oRs4.StopTimer(uHandle)

	Then("the manager no longer holds it", NTimers(oRs4), 0)

	# The mechanism, not the bookkeeping: with it gone the loop goes idle and
	# returns, and the callback never ran. If the timer were still live this
	# loop would never come back at all.
	When("the loop is given a chance to fire it")
	oRs4.@timerManager.SetPatience(2)
	oRs4.@timerManager.SetCheckFrequency(5)
	oRs4.@timerManager.RunLoop(NULL)

	Then("it never fired", nTicks, 0)

	# ...AND THE OTHER BRANCH. StopTimer still accepts an OBJECT, and that is
	# the branch the copy bug lived in. RunEvery no longer hands one out, so it
	# has to be reached deliberately -- the manager's own registered timer is a
	# copy, which is exactly the shape a caller used to be given.
	Given("a repeating timer, stopped by handing StopTimer the object")
	oRs7 = new stzReactiveSystem()
	oRs7.RunEvery(5, func { })
	Then("it is registered", NTimers(oRs7), 1)

	oCopy = oRs7.@timerManager.@timers[1]
	oRs7.StopTimer(oCopy)
	Then("passing the object removes it too", NTimers(oRs7), 0)
EndScenario()

Scenario("Both timer setters answer the same kind of thing")

	# RunAfter answered an id and RunEvery an object. The demos in this repo
	# already assumed otherwise -- they name the result `intervalId` and
	# `cIntervalID` -- and an object that cannot stop its own timer is not a
	# handle, it is a copy.

	Given("one of each")
	oRs5 = new stzReactiveSystem()
	uAfter = oRs5.RunAfter(1000, func { })
	uEvery = oRs5.RunEvery(1000, func { })

	Then("RunAfter answers a string id", isString(uAfter), TRUE)
	Then("...and RunEvery does too", isString(uEvery), TRUE)
	Then("the two ids differ", uAfter != uEvery, TRUE)
	Then("...and both timers are registered", NTimers(oRs5), 2)

	When("both are stopped by the ids they gave")
	oRs5.StopTimer(uAfter)
	oRs5.StopTimer(uEvery)
	Then("both are gone", NTimers(oRs5), 0)

	# THE NEGATIVE SIBLING: stopping must remove ONE timer, not clear the table.
	Given("two timers again, with only one stopped")
	oRs6 = new stzReactiveSystem()
	uKeep = oRs6.RunAfter(1000, func { })
	uDrop = oRs6.RunEvery(1000, func { })
	oRs6.StopTimer(uDrop)
	Then("the other one survives", NTimers(oRs6), 1)
EndScenario()

Scenario("A callback can stop timers while the loop is running them")

	# This only became reachable once StopTimer really removed a timer. Before,
	# the object branch set a flag and the list never shrank, so RunLoop's habit
	# of collecting removal INDICES during a pass was harmless.
	#
	# CheckAndTick RUNS the callback. A callback that stops timers shortens the
	# list one line after the bound was checked, so an index collected before the
	# tick names a different timer, or none. The loop raised R2 "Array Access
	# (Index out of range)" the moment a demo did the ordinary thing and
	# cancelled its timers from inside a one-shot -- which is exactly the shape
	# below, and exactly what two shipped demos do.
	#
	# Completed one-shots are gathered by ID now, which survives any shuffling
	# the callbacks did.
	#
	# The system is created straight INTO the global. Assigning an existing one
	# to a global copies it, and a callback holding a copy stops nothing -- the
	# first draft of this scenario hung forever for precisely that reason.

	Given("two repeating timers and a one-shot that cancels everything")
	$gRs8 = new stzReactiveSystem()
	$gRs8.@timerManager.SetPatience(2)
	$gRs8.@timerManager.SetCheckFrequency(5)
	$gCancelled = 0

	$gStopId1 = $gRs8.RunEvery(5, func { })
	$gStopId2 = $gRs8.RunEvery(5, func { })
	$gRs8.RunAfter(10, :CancelBoth)

	Then("all three are registered", NTimers($gRs8), 3)

	When("the loop runs them")
	bRaised = TRUE
	try
		$gRs8.@timerManager.RunLoop(NULL)
		bRaised = FALSE
	catch
		bRaised = TRUE
	done

	Then("the loop does not raise", bRaised, FALSE)
	Then("...the cancelling callback did run", $gCancelled > 0, TRUE)
	Then("...and no timer is left behind", NTimers($gRs8), 0)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

func NTimers(poRs)
	return len(poRs.@timerManager.@timers)

func FirstInterval(poRs)
	return poRs.@timerManager.@timers[1].@interval

# The interval a unit produces, read straight off the scheduled timer.
func IntervalFor(pcUnit, pnValue)
	_o_ = new stzReactiveSystem()
	_o_.RunAfterXT(pnValue, pcUnit, func { })
	if len(_o_.@timerManager.@timers) = 0
		return -1
	ok
	return _o_.@timerManager.@timers[1].@interval

# Cancels the repeating timers from inside a one-shot's tick -- the ordinary
# thing two shipped demos do, and what used to break the loop. StopAllTimers
# closes the door behind it so the scene cannot outlive its point.
func CancelBoth()
	$gCancelled++
	$gRs8.StopTimer($gStopId1)
	$gRs8.StopTimer($gStopId2)
	$gRs8.StopAllTimers()

