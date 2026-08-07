load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveObject -- WHAT THE CLASS DOES WITH AN ERROR IT CATCHES.
#
# Five try/catch blocks here used to drop the error entirely. Three were a bare
# comment; two were an `if` whose whole body was a comment:
#
#     catch
#         # Handle watcher error based on error handling mode
#         if DEFAULT_ERROR_HANDLING = ERROR_LOG
#             # Log the error
#         ok
#     done
#
# The cost is written into the file's own history. A note above StreamAttribute
# records a watcher bug that "arity-crashed on every trigger and the error was
# swallowed by TriggerAttributeWatchers' try/catch". The swallow that hid it was
# still there -- and it was hiding another one, which the first run of the new
# recorder named in a single line.

pr()

Scenario("The swallow was hiding a live bug in the class it belonged to")

	# ComputeAttribute called AddAttribute() on every recompute. Adding an
	# attribute that already exists is R54, so from the SECOND computation on it
	# raised -- and the catch ate it. Everything after that line stopped running,
	# invisibly:
	#
	#   - the plain field kept the value from the first computation, forever
	#   - TriggerAttributeWatchers sits BELOW it, so a watcher on a computed
	#     attribute never fired even once
	#
	# The storage path runs BEFORE the raise, which is exactly why nobody
	# noticed: GetAttribute() answered correctly the whole time.

	Given("a computed attribute with a watcher on it")
	oRs = new stzReactiveSystem()
	oC = oRs.ReactivateObject(new persr)
	oC.SetAttribute(:name, "Ali")
	nFires = 0
	oC.Computed(:greeting, func obj { return "Hi " + obj.GetAttribute(:name) }, [ :name ])
	oC.Watch(:greeting, func(oSelf, attr, oldv, newv) { nFires++ })

	When("the dependency changes, forcing a SECOND computation")
	oC.SetAttribute(:name, "Mona")

	# This one always passed -- storage is written before the line that raised.
	Then("the computed value is right", oC.GetAttribute(:greeting), "Hi Mona")

	# These two are what the swallow was hiding.
	Then("...the watcher on it actually fires", nFires, 1)
	Then("...and the plain field is current, not frozen at the first compute", oC.greeting, "Hi Mona")

	# THE NEGATIVE SIBLING: recomputing must not itself become an error, or the
	# assertions above could hold while the class quietly logged R54 forever.
	Then("and nothing was caught along the way", oC.HasErrors(), FALSE)
EndScenario()

Scenario("A caught error is recorded, named, and reachable")

	Given("a watcher that raises")
	oRs2 = new stzReactiveSystem()
	oW = oRs2.ReactivateObject(new persr)
	aSeen = []
	oW.OnError(func(cWhere, cMsg) { aSeen + [ cWhere, cMsg ] })
	oW.Watch(:name, func(oSelf, attr, oldv, newv) { return 1/0 })

	When("the attribute it watches changes")
	oW.SetAttribute(:name, "Zed")

	Then("the failure is recorded", oW.HasErrors(), TRUE)
	Then("...naming WHICH watcher", oW.LastErrorWhere(), "Watcher:name")
	Then("...with Ring's real reason", StzFindFirst("divide by zero", oW.LastError()) > 0, TRUE)

	# The set itself must still complete -- a watcher is an observer, and one
	# that throws should not undo the change it was watching.
	Then("the attribute still took the value", oW.GetAttribute(:name), "Zed")

	# The handler seam: given one, the class reports through it and prints
	# nothing. (Ring's + appends the pair as a single item, so one call is one
	# entry carrying both halves.)
	Then("a registered handler was called once", len(aSeen), 1)
	Then("...and told where", aSeen[1][1], "Watcher:name")
	Then("...and why", StzFindFirst("divide by zero", aSeen[1][2]) > 0, TRUE)

	# THE NEGATIVE SIBLING, and the one that makes the rest mean something: a
	# watcher that works must leave NO error behind, or HasErrors() could simply
	# be answering TRUE for every set that ever happened.
	Given("a watcher that does not raise")
	oOk = oRs2.ReactivateObject(new persr)
	oOk.OnError(func(cWhere, cMsg) { })
	oOk.Watch(:name, func(oSelf, attr, oldv, newv) { })
	oOk.SetAttribute(:name, "fine")
	Then("nothing is recorded", oOk.HasErrors(), FALSE)
	Then("...and there is no last error to read", oOk.LastError(), "")
	Then("...nor a place it came from", oOk.LastErrorWhere(), "")
EndScenario()

Scenario("A batch that fails half-way says so -- and keeps what it did")

	# It never used to say anything at all.
	#
	# BATCH IS NOT ATOMIC. SetAttribute writes the value immediately and queues
	# only the reactive NOTIFICATION, so a batch that raises halfway leaves the
	# changes it managed to make in storage. That was true before this pass and
	# is still true: undoing them is not something the catch can do, and
	# discarding the queued notifications instead would leave the data changed
	# with every watcher and binding unaware -- worse than either.
	#
	# What changed is that the failure is no longer silent. These assertions pin
	# the CURRENT contract, partial commit included, so that making Batch truly
	# all-or-nothing later has to be a deliberate act that updates this guard.

	Given("an object holding a known value")
	oRs3 = new stzReactiveSystem()
	oB = oRs3.ReactivateObject(new persr)
	oB.OnError(func(cWhere, cMsg) { })
	oB.SetAttribute(:name, "before")

	When("a batch changes it and then raises")
	oB.Batch(func {
		oB.SetAttribute(:name, "after")
		x = 1/0
		oB.SetAttribute(:age, 99)
	})

	Then("the failure is recorded", oB.LastErrorWhere(), "Batch")
	Then("...with the real reason", StzFindFirst("divide by zero", oB.LastError()) > 0, TRUE)

	# The documented limitation, asserted rather than assumed:
	Then("the change made before the raise is kept (batch is NOT atomic)", oB.GetAttribute(:name), "after")
	Then("...while the one after it never ran", oB.GetAttribute(:age), 0)

	# THE NEGATIVE SIBLING: a batch that SUCCEEDS must still commit, or "does not
	# commit on failure" would be indistinguishable from "never commits".
	Given("a batch that completes")
	oB2 = oRs3.ReactivateObject(new persr)
	oB2.SetAttribute(:name, "before")
	oB2.Batch(func {
		oB2.SetAttribute(:name, "after")
		oB2.SetAttribute(:age, 42)
	})
	Then("its changes are applied", oB2.GetAttribute(:name), "after")
	Then("...all of them", oB2.GetAttribute(:age), 42)
	Then("...and nothing is recorded", oB2.HasErrors(), FALSE)
EndScenario()

Scenario("The record is bounded, and says how much it dropped")

	# A watcher that raises on every set could grow this without limit. It is
	# capped -- and a cap that reported only its own length would under-count
	# exactly when a caller most needs the number.

	Given("a watcher that raises, driven past the cap of 50")
	oRs4 = new stzReactiveSystem()
	oM = oRs4.ReactivateObject(new persr)
	oM.OnError(func(cWhere, cMsg) { })
	oM.Watch(:name, func(oSelf, attr, oldv, newv) { return 1/0 })
	for i = 1 to 60
		oM.SetAttribute(:name, "v" + i)
	next

	Then("the kept record stops at the cap", len(oM.Errors()), 50)
	Then("...but the count is the TRUE total", oM.ErrorCount(), 60)
	Then("...and it says how many it let go", oM.ErrorsDropped(), 10)

	# THE FIRST failure is the one worth reading, so the cap keeps the earliest
	# and drops the newest rather than the other way round.
	Then("the first one kept is the first that happened", StzFindFirst("divide by zero", oM.Errors()[1][2]) > 0, TRUE)

	When("the record is cleared")
	oM.ClearErrors()
	Then("everything resets, the counter included", oM.ErrorCount(), 0)
	Then("...and the dropped tally with it", oM.ErrorsDropped(), 0)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

class persr
	name = ""
	age = 0
	greeting = ""
