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
        oTm.checkFrequency, DEFAULT_TIMER_CHECK)
    Then("emptyLoopPatience defaults to DEFAULT_PATIENCE",
        oTm.emptyLoopPatience, DEFAULT_PATIENCE)
    Then("timers list starts empty",       len(oTm.timers), 0)
    Then("isRunning starts false",         oTm.isRunning,   FALSE)
EndScenario()

Scenario("Setters mutate the corresponding fields")
    Given("a manager with default settings")
    oTm = new stzTimerManager()
    When("SetCheckFrequency is called")
    oTm.SetCheckFrequency(50)
    Then("checkFrequency updates",         oTm.checkFrequency, 50)
    When("SetPatience is called")
    oTm.SetPatience(200)
    Then("emptyLoopPatience updates",      oTm.emptyLoopPatience, 200)
EndScenario()

Scenario("AddTimer / RemoveTimer mutate the timers list in place")
    Given("a manager with no timers and two fully-Init'd timer stubs")
    oTm = new stzTimerManager()
    oT1 = new stzReactiveTimer("t1", 100, NULL, NULL, FALSE)
    oT2 = new stzReactiveTimer("t2", 100, NULL, NULL, FALSE)
    When("both timers are added")
    oTm.AddTimer(oT1)
    oTm.AddTimer(oT2)
    Then("count = 2",                       len(oTm.timers), 2)
    Then("first stored id is t1",           oTm.timers[1].timerId, "t1")
    When("t1 is removed by id")
    oTm.RemoveTimer("t1")
    Then("count = 1",                       len(oTm.timers), 1)
    Then("the remaining timer is t2",       oTm.timers[1].timerId, "t2")
EndScenario()

Scenario("stzReactiveTimer.Init honors oneTime=TRUE")
    Given("a one-shot timer with oneTime=TRUE")
    oTone = new stzReactiveTimer("once", 100, NULL, NULL, TRUE)
    Then("isOneTime is TRUE",     oTone.isOneTime, TRUE)
    Then("interval persists",     oTone.interval,  100)
    Then("timerId persists",      oTone.timerId,   "once")
EndScenario()

Scenario("stzReactiveTimer.Init honors oneTime=FALSE")
    Given("a repeating timer with oneTime=FALSE")
    oTrep = new stzReactiveTimer("rep", 250, NULL, NULL, FALSE)
    Then("isOneTime is FALSE",    oTrep.isOneTime, FALSE)
    Then("interval persists",     oTrep.interval,  250)
EndScenario()

Scenario("stzReactiveTimer.Init defaults oneTime=NULL to FALSE")
    Given("a timer with oneTime=NULL")
    oTnul = new stzReactiveTimer("default", 100, NULL, NULL, NULL)
    Then("isOneTime defaults to FALSE", oTnul.isOneTime, FALSE)
EndScenario()

Scenario("stzReactiveTask stores Then_ and Catch_ callbacks")
    Given("a fresh task constructed with id/func/engine/errorMode")
    oTask = new stzReactiveTask("t1", NULL, NULL, NULL)
    Then("onComplete starts NULL", oTask.onComplete, NULL)
    Then("onError starts NULL",    oTask.onError,    NULL)
    When("Then_ and Catch_ are wired with named callbacks")
    oTask.Then_(:onDone)
    oTask.Catch_(:errored)
    Then("onComplete reflects the assignment", oTask.onComplete, :onDone)
    Then("onError reflects the assignment",    oTask.onError,    :errored)
EndScenario()

Summary()
