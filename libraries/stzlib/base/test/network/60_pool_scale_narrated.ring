load "../../stzBase.ring"
load "../_narrated.ring"

# Pool at agentic-loop scale -- 1000 jobs through 8 workers, plus
# backpressure semantics from a bounded queue.

Scenario("Bounded pool refuses submissions past max_queue")
    Given("a pool with 2 workers and a 4-slot queue")
    p = StzEnginePoolCreateXT(2, 4)
    # Submit 6 jobs; the engine should accept up to max_queue
    # in the queue plus however many workers can immediately pick up.
    aIds = []
    nDenied = 0
    for _i_ = 1 to 20
        nId = StzEnginePoolSubmit(p, 0, "bad" + _i_)
        if nId = -2
            nDenied++
        else
            aIds + nId
        ok
    next
    Then("some submissions were denied (backpressure)",
        nDenied > 0, TRUE)
    Then("LastError mentions backpressure",
        StzFind(StzEnginePoolLastError(), "queue full") > 0, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Pool inflight + pending counters reflect activity")
    Given("a pool with 4 workers and an unbounded queue")
    p = StzEnginePoolCreate(4)
    for _i_ = 1 to 12
        StzEnginePoolSubmit(p, 0, "bad" + _i_)
    next
    # At this instant, some are pending, some in flight, some done.
    nPending = StzEnginePoolPending(p)
    nInflight = StzEnginePoolInflight(p)
    Then("pending + inflight + done = 12 (or fewer pending if all started)",
        nPending + nInflight <= 12, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Pool drains 1000 jobs through 8 workers within bounded time")
    Given("a pool of 8 workers and 1000 bogus HTTP GETs")
    p = StzEnginePoolCreate(8)
    aIds = []
    for _i_ = 1 to 1000
        aIds + StzEnginePoolSubmit(p, 0, "bad" + _i_)
    next
    Then("1000 ids issued", len(aIds), 1000)

    When("polling until all are drained")
    n1 = StzEngineTimeNowMs()
    nDone = 0
    nIters = 0
    while nDone < 1000 and nIters < 1000
        nIters++
        for _i_ = 1 to 1000
            if aIds[_i_] != 0
                cBody = StzEnginePoolPoll(p, aIds[_i_])
                if StzEnginePoolLastStatus() != -1
                    aIds[_i_] = 0
                    nDone++
                ok
            ok
        next
        StzEngineTimeSleepMs(10)
    end
    n2 = StzEngineTimeNowMs()

    Then("all 1000 jobs drained", nDone, 1000)
    # 1000 URL parse failures through 8 workers should finish
    # comfortably in a few seconds on a slow box.
    Then("wall-clock < 30s", n2 - n1 < 30000, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Summary()
