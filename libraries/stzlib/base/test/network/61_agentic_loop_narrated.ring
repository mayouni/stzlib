load "../../stzBase.ring"
load "../_narrated.ring"

# Agentic-loop integration test.
# An "agent" pulls jobs off a queue, calls a downstream API with
# a rate limit + circuit breaker + retry, and reports success or
# graceful degradation. This pins the integration contract for the
# primitives shipped in M-DEP4 hardening.

Scenario("Agent retries with backoff under a token bucket and trips a breaker")
    Given("rate limiter (3/sec), circuit breaker (3 fails -> open), pool of 4")
    pRate    = StzEngineRateCreate(3, 3)
    pCircuit = StzEngineCircuitCreate(3, 200)
    pPool    = StzEnginePoolCreate(4)

    nAttempts = 0
    nSucceeded = 0
    nCircuitBlocks = 0
    nRateThrottles = 0

    nTask = 0
    while nTask < 6
        nTask++

        # Honour the circuit breaker first.
        if StzEngineCircuitCanPass(pCircuit) = 0
            nCircuitBlocks++
            loop
        ok

        # Then the rate limiter (non-blocking try).
        if StzEngineRateTryTake(pRate, 1) = 0
            nRateThrottles++
            StzEngineTimeSleepMs(50)
            nTask--   # retry the same task next iteration
            loop
        ok

        # Submit the work.
        nId = StzEnginePoolSubmit(pPool, 0, "bad-task-" + nTask)
        nAttempts++

        # Poll until done (bogus URLs fail fast).
        bDone = FALSE
        nTries = 0
        while not bDone and nTries < 100
            nTries++
            cBody = StzEnginePoolPoll(pPool, nId)
            nStatus = StzEnginePoolLastStatus()
            if nStatus != -1
                bDone = TRUE
                if nStatus > 0
                    nSucceeded++
                    StzEngineCircuitRecordSuccess(pCircuit)
                else
                    StzEngineCircuitRecordFailure(pCircuit)
                ok
            else
                StzEngineTimeSleepMs(10)
            ok
        end
    end

    Then("we attempted at least 3 tasks (until breaker opened)",
        nAttempts >= 3, TRUE)
    Then("the circuit blocked at least 1 task",
        nCircuitBlocks >= 1, TRUE)
    Then("breaker ends OPEN (3 consecutive failures)",
        StzEngineCircuitState(pCircuit), STZ_CIRCUIT_OPEN)

    StzEnginePoolDestroy(pPool)
    StzEngineCircuitDestroy(pCircuit)
    StzEngineRateDestroy(pRate)
EndScenario()

Scenario("Backoff delays grow then stay capped under retry pressure")
    Given("base 50ms, max 800ms, deterministic seed")
    a0  = StzEngineRetryDelayMs(0,  50, 800, 7)
    a1  = StzEngineRetryDelayMs(1,  50, 800, 7)
    a2  = StzEngineRetryDelayMs(2,  50, 800, 7)
    a8  = StzEngineRetryDelayMs(8,  50, 800, 7)
    a16 = StzEngineRetryDelayMs(16, 50, 800, 7)
    Then("attempt 0 <= 50ms (base window)",  a0  <= 50,  TRUE)
    Then("attempt 1 <= 100ms",               a1  <= 100, TRUE)
    Then("attempt 2 <= 200ms",               a2  <= 200, TRUE)
    Then("attempt 8 <= 800ms (cap reached)", a8  <= 800, TRUE)
    Then("attempt 16 <= 800ms (cap held)",   a16 <= 800, TRUE)
EndScenario()

Summary()
