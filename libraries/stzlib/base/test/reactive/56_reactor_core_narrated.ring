load "../../stzBase.ring"
load "../_narrated.ring"

# Tier 2 slice 1: reactor core (libuv loop on a worker thread).
#
# Ring submits async work and drains results through the same
# submit/poll handle idiom as the thread pool -- the libuv loop runs on
# its own thread and Ring never sees a callback. This suite drives a
# timer op end-to-end across that thread boundary. Deterministic, no
# network.

Scenario("Submit a timer and await it across the loop thread")
    Given("a reactor (loop running on its own thread)")
    r = StzEngineReactorCreate()
    When("submitting a 30ms timer")
    nId = StzEngineReactorSubmitTimer(r, 30)
    Then("a job id was returned", nId > 0, TRUE)
    Then("awaiting it returns 0 (the timer fired)",
        StzEngineReactorAwait(r, nId, 2000), 0)
    Then("polling the drained id reports -2 (not found)",
        StzEngineReactorPoll(r, nId), -2)
    StzEngineReactorDestroy(r)
EndScenario()

Scenario("Poll reports running, then done")
    Given("a reactor and a 200ms timer")
    r = StzEngineReactorCreate()
    nId = StzEngineReactorSubmitTimer(r, 200)
    When("polling immediately")
    Then("status is -1 (still running)", StzEngineReactorPoll(r, nId), -1)
    When("waiting past the delay (350ms)")
    StzEngineTimeSleepMs(350)
    Then("status is now 0 (done)", StzEngineReactorPoll(r, nId), 0)
    StzEngineReactorDestroy(r)
EndScenario()

Scenario("An unknown job id is reported as not found")
    Given("a fresh reactor")
    r = StzEngineReactorCreate()
    Then("polling an unknown id returns -2",
        StzEngineReactorPoll(r, 99999), -2)
    StzEngineReactorDestroy(r)
EndScenario()

Summary()
