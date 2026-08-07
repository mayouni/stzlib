load "../../stzBase.ring"
load "../_narrated.ring"

# Reactive primitives -- sync data-layer harness (no event-loop, no libuv,
# per Windows test-loop guardrail). Covers construction, configuration,
# mutation, and the no-side-effect chaining API only. Async behaviour is
# left to integration tests run outside CI.

Scenario("stzTimerManager carries default frequency and patience")
    Given("a fresh timer manager")
    oTm = new stzTimerManager()
    Then("checkFrequency defaults to DEFAULT_TIMER_CHECK",
        oTm.@checkFrequency, DEFAULT_TIMER_CHECK)
    Then("emptyLoopPatience defaults to DEFAULT_PATIENCE",
        oTm.@emptyLoopPatience, DEFAULT_PATIENCE)
    Then("timers list starts empty",       len(oTm.@timers), 0)
    Then("isRunning starts false",         oTm.@isRunning,   FALSE)
EndScenario()

Scenario("Setters mutate the corresponding fields")
    Given("a manager with default settings")
    oTm = new stzTimerManager()
    When("SetCheckFrequency is called")
    oTm.SetCheckFrequency(50)
    Then("checkFrequency updates",         oTm.@checkFrequency, 50)
    When("SetPatience is called")
    oTm.SetPatience(200)
    Then("emptyLoopPatience updates",      oTm.@emptyLoopPatience, 200)
EndScenario()

Scenario("...and the fields make the loop behave differently")

    # The scenario above checks that the assignment happened. That is worth
    # having and is not enough: it would pass just as well for a field nothing
    # reads. These two drive an idle RunLoop and MEASURE it.
    #
    # Monotonic clock, and the bands come from measurement rather than from the
    # comment: 20 idle iterations took ~145ms at 5ms and ~1117ms at 50ms (~7.7x),
    # and patience 30 outlasted patience 0 by ~30x. Asserting 3x leaves room for
    # a loaded machine while still failing outright if the knob does nothing.

    Given("an idle loop run at two different check frequencies")
    nFast = IdleMs(5, 20)
    nSlow = IdleMs(50, 20)
    Then("a slower check really does wait longer", nSlow > nFast * 3, TRUE)

    Given("an idle loop run at two different patience levels")
    nImpatient = IdleMs(10, 0)
    nPatient   = IdleMs(10, 30)
    Then("more patience really does keep it alive longer", nPatient > nImpatient * 3, TRUE)
EndScenario()

Scenario("A wait the loop cannot perform is refused")

    # Zero was the dangerous value. _WaitTick does
    # sleep(@checkFrequency / MS_PER_SECOND), so a frequency of 0 is no wait at
    # all: 200 idle iterations ran in 2ms instead of ~2000, a loop spinning flat
    # out on the knob whose whole job is to make it wait.
    #
    # A non-number was the confusing one -- it survived the setter and raised
    # R41 "Invalid numeric string" deep inside RunLoop, nowhere near the call
    # that caused it.

    Given("a manager on its default check frequency")
    oV = new stzTimerManager()
    nWas = oV.@checkFrequency

    When("it is asked to wait for zero")
    oV.SetCheckFrequency(0)
    Then("the refusal keeps the working value", oV.@checkFrequency, nWas)

    When("it is asked to wait for a negative time")
    oV.SetCheckFrequency(-25)
    Then("the refusal keeps the working value", oV.@checkFrequency, nWas)

    When("it is handed something that is not a number")
    oV.SetCheckFrequency("soon")
    Then("the refusal keeps the working value", oV.@checkFrequency, nWas)

    # ...and the loop that used to spin now still waits, which is the point of
    # refusing rather than merely disliking.
    Then("an idle loop still takes real time", IdleMs(0, 20) > 20, TRUE)

    # THE NEGATIVE SIBLING: refusing must not mean refusing everything.
    When("it is given a workable frequency")
    oV.SetCheckFrequency(25)
    Then("it takes it", oV.@checkFrequency, 25)

    # Patience is a COUNT, not a duration, and zero is its documented default --
    # so the two setters must NOT validate alike.
    Given("a manager asked for zero patience")
    oP = new stzTimerManager()
    oP.SetPatience(5)
    oP.SetPatience(0)
    Then("zero patience is legal", oP.@emptyLoopPatience, 0)
    When("it is asked for negative patience")
    oP.SetPatience(-5)
    Then("that is refused", oP.@emptyLoopPatience, 0)
EndScenario()

Scenario("The setters chain, like every other setter in the module")

    # They used to return whatever the last expression evaluated to -- a STRING,
    # as it happens -- so they could not be strung together the way
    # SetAutoConclude and its neighbours can.

    Given("a manager configured in one chain")
    oCh = new stzTimerManager()
    oCh.SetCheckFrequency(30).SetPatience(7)

    Then("the chain reached the first setter", oCh.@checkFrequency, 30)
    Then("...and the second", oCh.@emptyLoopPatience, 7)
    oOne = new stzTimerManager()
    Then("a setter answers with the object", isObject(oOne.SetPatience(1)), TRUE)

    # SetReactor chains too. NULL is its documented no-reactor-use-the-poller
    # value, so passing it must stay legal.
    oRct = new stzTimerManager()   # not oR: Ring folds that name onto the or operator
    Then("SetReactor(NULL) is still allowed and chains", isObject(oRct.SetReactor(NULL)), TRUE)
EndScenario()

Scenario("AddTimer / RemoveTimer mutate the timers list in place")
    Given("a manager with no timers and two fully-Init'd timer stubs")
    oTm = new stzTimerManager()
    oT1 = new stzReactiveTimer("t1", 100, NULL, NULL, FALSE)
    oT2 = new stzReactiveTimer("t2", 100, NULL, NULL, FALSE)
    When("both timers are added")
    oTm.AddTimer(oT1)
    oTm.AddTimer(oT2)
    Then("count = 2",                       len(oTm.@timers), 2)
    Then("first stored id is t1",           oTm.@timers[1].@timerId, "t1")
    When("t1 is removed by id")
    oTm.RemoveTimer("t1")
    Then("count = 1",                       len(oTm.@timers), 1)
    Then("the remaining timer is t2",       oTm.@timers[1].@timerId, "t2")
EndScenario()

Scenario("stzReactiveTimer.Init honors oneTime=TRUE")
    Given("a one-shot timer with oneTime=TRUE")
    oTone = new stzReactiveTimer("once", 100, NULL, NULL, TRUE)
    Then("isOneTime is TRUE",     oTone.@isOneTime, TRUE)
    Then("interval persists",     oTone.@interval,  100)
    Then("timerId persists",      oTone.@timerId,   "once")
EndScenario()

Scenario("stzReactiveTimer.Init honors oneTime=FALSE")
    Given("a repeating timer with oneTime=FALSE")
    oTrep = new stzReactiveTimer("rep", 250, NULL, NULL, FALSE)
    Then("isOneTime is FALSE",    oTrep.@isOneTime, FALSE)
    Then("interval persists",     oTrep.@interval,  250)
EndScenario()

Scenario("stzReactiveTimer.Init defaults oneTime=NULL to FALSE")
    Given("a timer with oneTime=NULL")
    oTnul = new stzReactiveTimer("default", 100, NULL, NULL, NULL)
    Then("isOneTime defaults to FALSE", oTnul.@isOneTime, FALSE)
EndScenario()

Scenario("stzReactiveTask stores Then_ and Catch_ callbacks")
    Given("a fresh task constructed with id/func/engine/errorMode")
    oTask = new stzReactiveTask("t1", NULL, NULL, NULL)
    Then("onComplete starts NULL", oTask.@onComplete, NULL)
    Then("onError starts NULL",    oTask.@onError,    NULL)
    When("Then_ and Catch_ are wired with named callbacks")
    oTask.Then_(:onDone)
    oTask.Catch_(:errored)
    Then("onComplete reflects the assignment", oTask.@onComplete, :onDone)
    Then("onError reflects the assignment",    oTask.@onError,    :errored)
EndScenario()

Scenario("stzReactiveTask DELIVERS -- storing a callback is not calling it")

	# The scenario above asserts that Then_ and Catch_ STORE what they are given,
	# and it passed for as long as the class has existed. It could not fail:
	# storage is not delivery, and neither callback had ever been invoked.
	#
	# Ring calls a function held in a variable only through `call`, and both
	# callback invocations in Execute() were missing it.
	#
	# What that produced is not the obvious failure. A Ring lambda IS a string --
	# `func { }` evaluates to "_ring_anonymous_func_NNN" -- so the body ran fine
	# and the task reached TASK_COMPLETED. It then raised R3 handing the result
	# to Then_(). The catch turned that into TASK_ERROR and printed the fixed
	# sentence "Task execution failed". A task that had SUCCEEDED reported
	# failure, discarded its answer, and said nothing about why.
	#
	# Everything below asserts the MECHANISM: what arrived, and where from.

	Given("a task whose body returns 42")
	gDelivered = "(never)"
	oRs = new stzReactiveSystem()
	oOk = new stzReactiveTask("ok", func { return 42 }, oRs, ERROR_CALLBACK)
	oOk.Then_(func r { gDelivered = "" + r })
	oOk.Execute()

	Then("the body actually ran", oOk.Result(), 42)
	Then("...the completion handler was CALLED, not merely stored", gDelivered, "42")
	Then("...and the task says so", oOk.Succeeded(), TRUE)
	Then("...without inventing a failure", oOk.HasFailed(), FALSE)

	# THE NEGATIVE SIBLING for the error channel: a task that worked must carry
	# no error at all, or Error() could be answering from some fixed default and
	# the failure assertions below would prove nothing.
	Then("a task that worked reports no error", oOk.Error(), "")

	Given("a task whose body divides by zero")
	gReason = "(never)"
	oBad = new stzReactiveTask("bad", func { return 1/0 }, oRs, ERROR_CALLBACK)
	oBad.Catch_(func msg { gReason = "" + msg })
	oBad.Execute()

	Then("the error handler was CALLED", gReason != "(never)", TRUE)

	# THE REAL REASON, not a fixed sentence. Every failure there is -- a bad
	# type, a missing file, this division -- used to arrive as the same seven
	# words, which is how a class whose every path was broken still read as one
	# that was merely failing.
	Then("...and carries Ring's actual reason", StzFindFirst("divide by zero", gReason) > 0, TRUE)
	Then("...not the generic sentence", StzFindFirst("Task execution failed", gReason), 0)
	Then("the reason survives on the object", StzFindFirst("divide by zero", oBad.Error()) > 0, TRUE)
	Then("...and the task admits failing", oBad.HasFailed(), TRUE)

	Given("the mode set to callback but no handler ever registered")

	# This combination used to fall off the end of the if-chain and vanish: the
	# status said error, and there was no accessor to ask why. The last arm is
	# now written as "not the mode that wants silence", so an unforeseen mode
	# lands on REPORT rather than on swallow.
	oOrphan = new stzReactiveTask("orphan", func { return 1/0 }, oRs, ERROR_CALLBACK)
	oOrphan.Execute()
	Then("the reason is kept", StzFindFirst("divide by zero", oOrphan.Error()) > 0, TRUE)

	# ...and RECORDING IS NOT REPORTING. The assertion above passes whichever arm
	# runs, because the message is stored before the chain -- deleting the
	# fallback entirely left it green. This is the one that covers the arm.
	Then("...and it actually reached someone", oOrphan.WasReported(), TRUE)

	Given("the mode set to ignore")

	# ...and the one mode that IS allowed to stay quiet still records, so silence
	# by request never costs the reason.
	oQuiet = new stzReactiveTask("quiet", func { return 1/0 }, oRs, ERROR_IGNORE)
	oQuiet.Execute()
	Then("ignore keeps the reason on the object", StzFindFirst("divide by zero", oQuiet.Error()) > 0, TRUE)
	Then("...and still marks the task failed", oQuiet.HasFailed(), TRUE)

	# THE NEGATIVE SIBLING for WasReported: the one mode that asked for silence
	# must be the only one that gets it, or the assertion above would hold for a
	# flag that is simply always TRUE.
	Then("...but reports to nobody, as asked", oQuiet.WasReported(), FALSE)
EndScenario()

Scenario("A subclass must fill what the inherited accessor reads")

	# Adding Status()/Result()/Error() to stzReactiveTask gave them to both its
	# subclasses for free -- and both override Execute(), so neither filled them.
	# An inherited accessor that answers "" for a task that failed, or "pending"
	# for one that finished, is worse than no accessor: it does not merely fail
	# to help, it states the opposite of what happened.

	Given("stzFunctionTask, which computes and cannot fail on its own")
	oRs2 = new stzReactiveSystem()
	oFn = new stzFunctionTask("fn", func x { return x * 2 }, [ 21 ], oRs2)
	oFn.Execute()

	# This class wrote _status_ to a LOCAL, which vanished when Execute()
	# returned -- the exact defect its HTTP sibling had fixed in July and this
	# one had not. Every inherited accessor answered as though it never ran.
	Then("the status is on the task, not in a local", oFn.Status(), TASK_COMPLETED)
	Then("...the result too", oFn.Result(), 42)
	Then("...and it says it succeeded", oFn.Succeeded(), TRUE)
	Then("a task that worked carries no error", oFn.Error(), "")

	Given("the same class given work that raises")
	oFnBad = new stzFunctionTask("fnbad", func x { return x / 0 }, [ 1 ], oRs2)
	oFnBad.Execute()

	# ...and the reason is kept whether or not a Catch_ was ever registered. It
	# used to be read only INSIDE the "is a handler set" branch, so a task with
	# no handler kept nothing -- and there was no accessor to have asked with.
	Then("a failure is recorded with no handler registered", oFnBad.HasFailed(), TRUE)
	Then("...carrying Ring's real reason", StzFindFirst("divide by zero", oFnBad.Error()) > 0, TRUE)

	Given("stzHttpTask, driven down its error path without touching the network")

	# An unrecognised method falls to the switch's `other` arm, which yields no
	# response and goes straight to the error branch -- no download(), so this is
	# deterministic and offline.
	oHt = new stzHttpTask("ht", "http://nowhere.invalid", "BOGUS_METHOD", NULL, oRs2)
	oHt.Execute()

	Then("the HTTP subclass reports failing", oHt.HasFailed(), TRUE)
	Then("...and fills the error its parent's accessor reads", oHt.Error() != "", TRUE)

	# THE NEGATIVE SIBLING: the accessor must not simply answer non-empty for
	# everything, or the assertion above would hold for a task that was fine.
	oHtFresh = new stzHttpTask("ht2", "http://nowhere.invalid", HTTP_GET, NULL, oRs2)
	Then("an unrun task reports no error", oHtFresh.Error(), "")
	Then("...and is still pending", oHtFresh.Status(), TASK_PENDING)
EndScenario()

Summary()

#-- helpers --------------------------------------------------------------------

# Wall time of an idle RunLoop at a given check frequency and patience.
# Monotonic clock: StzEngineTimeNow* is epoch WALL time and unfit for durations.
func IdleMs(pnFreq, pnPatience)
	_o_ = new stzTimerManager()
	_o_.SetCheckFrequency(pnFreq)
	_o_.SetPatience(pnPatience)
	_n0_ = StzEngineWatchTimestampNs()
	_o_.RunLoop(NULL)
	return (StzEngineWatchTimestampNs() - _n0_) / 1000000

