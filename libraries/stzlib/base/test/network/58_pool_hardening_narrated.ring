load "../../stzBase.ring"
load "../_narrated.ring"

# Thread pool hardening -- consistency, isolation, scale.
# The pool is the SCALABLE primitive: a fixed number of OS threads
# handle an arbitrary backlog of submitted jobs. Direct-spawn loses
# this property at ~thousands of concurrent jobs.

Scenario("Pool create + destroy with default size")
    Given("a pool with 4 workers")
    p = StzEnginePoolCreate(4)
    Then("LastError empty after create", StzEnginePoolLastError(), "")
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Submit unique ids monotonically")
    p = StzEnginePoolCreate(2)
    # Submit a bunch of bogus HTTP GETs (job kind 0). Each should
    # get a strictly-increasing id.
    id1 = StzEnginePoolSubmit(p, 0, "bad1")
    id2 = StzEnginePoolSubmit(p, 0, "bad2")
    id3 = StzEnginePoolSubmit(p, 0, "bad3")
    Then("id1 > 0",            id1 > 0, TRUE)
    Then("id2 > id1",          id2 > id1, TRUE)
    Then("id3 > id2",          id3 > id2, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Poll an unknown id returns -2")
    p = StzEnginePoolCreate(1)
    cBody = StzEnginePoolPoll(p, 99999)
    Then("Status = -2 (not found)",
        StzEnginePoolLastStatus(), -2)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Workload of 50 bogus jobs completes under bounded wall time")
    Given("a pool of 4 workers and 50 submitted bogus HTTP GETs")
    p = StzEnginePoolCreate(4)
    aIds = []
    for _i_ = 1 to 50
        aIds + StzEnginePoolSubmit(p, 0, "bad" + _i_)
    next
    Then("50 ids issued", len(aIds), 50)

    When("polling until all 50 are drained")
    n1 = StzEngineTimeNowMs()
    nDone = 0
    while nDone < 50
        for _i_ = 1 to 50
            if aIds[_i_] != 0
                cBody = StzEnginePoolPoll(p, aIds[_i_])
                if StzEnginePoolLastStatus() != -1
                    aIds[_i_] = 0
                    nDone++
                ok
            ok
        next
        StzEngineTimeSleepMs(5)
    end
    n2 = StzEngineTimeNowMs()

    Then("all 50 jobs drained", nDone, 50)
    # With only 4 workers and 50 bogus URLs (URL parse failures are
    # ~microseconds), wall-clock should be well under 10s.
    Then("wall-clock < 10s", n2 - n1 < 10000, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Summary()
