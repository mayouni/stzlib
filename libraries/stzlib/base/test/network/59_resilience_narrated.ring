load "../../stzBase.ring"
load "../_narrated.ring"

# Resilience primitives -- retry / rate / circuit.
# Critical for web/cloud + agentic-loop workloads where transient
# failures, rate limits, and downstream outages are the norm.

# ── retry / backoff ─────────────────────────────────────────

Scenario("retry_delay_ms is bounded by max and grows with attempt")
    Given("deterministic seed for reproducibility")
    nSeed = 42
    a0 = StzEngineRetryDelayMs(0, 100, 5000, nSeed)
    a3 = StzEngineRetryDelayMs(3, 100, 5000, nSeed)
    Then("attempt 0 delay <= 100 ms (base window)",
        a0 <= 100, TRUE)
    Then("attempt 3 delay <= 800 ms (2^3 * 100)",
        a3 <= 800, TRUE)
    Then("attempt 50 delay <= max (5000)",
        StzEngineRetryDelayMs(50, 100, 5000, nSeed) <= 5000, TRUE)
EndScenario()

Scenario("retry_delay_ms returns 0 when base is 0")
    Then("zero base => zero delay",
        StzEngineRetryDelayMs(5, 0, 1000, 1), 0)
EndScenario()

# ── token bucket rate limiter ───────────────────────────────

Scenario("Rate limiter: capacity controls burst")
    Given("a bucket of capacity 3, refilling at 1 token/sec")
    pR = StzEngineRateCreate(3, 1)
    Then("first take succeeds",        StzEngineRateTryTake(pR, 1), 1)
    Then("second take succeeds",       StzEngineRateTryTake(pR, 1), 1)
    Then("third take succeeds",        StzEngineRateTryTake(pR, 1), 1)
    Then("fourth take is denied",      StzEngineRateTryTake(pR, 1), 0)
    StzEngineRateDestroy(pR)
EndScenario()

Scenario("Rate limiter: refills over time")
    Given("a bucket of capacity 2 refilling at 1000 tokens/sec")
    pR = StzEngineRateCreate(2, 1000)
    StzEngineRateTryTake(pR, 2)
    Then("bucket is empty (0 available)",
        StzEngineRateAvailable(pR) < 0.1, TRUE)
    When("we sleep 50ms")
    StzEngineTimeSleepMs(50)
    Then("refill brought tokens > 1.0",
        StzEngineRateAvailable(pR) > 1.0, TRUE)
    StzEngineRateDestroy(pR)
EndScenario()

# ── circuit breaker ─────────────────────────────────────────

Scenario("Circuit: opens after threshold failures")
    Given("a breaker that trips on 3 failures")
    pC = StzEngineCircuitCreate(3, 100)
    Then("starts CLOSED",          StzEngineCircuitState(pC), STZ_CIRCUIT_CLOSED)
    Then("can_pass = 1 (CLOSED)",  StzEngineCircuitCanPass(pC), 1)
    StzEngineCircuitRecordFailure(pC)
    StzEngineCircuitRecordFailure(pC)
    Then("still CLOSED after 2",   StzEngineCircuitState(pC), STZ_CIRCUIT_CLOSED)
    StzEngineCircuitRecordFailure(pC)
    Then("OPEN after 3rd",         StzEngineCircuitState(pC), STZ_CIRCUIT_OPEN)
    Then("can_pass = 0 (OPEN)",    StzEngineCircuitCanPass(pC), 0)
    StzEngineCircuitDestroy(pC)
EndScenario()

Scenario("Circuit: half-open after reset window, closes on success")
    Given("an open circuit and a reset window of 100ms")
    pC = StzEngineCircuitCreate(2, 100)
    StzEngineCircuitRecordFailure(pC)
    StzEngineCircuitRecordFailure(pC)
    Then("OPEN",                   StzEngineCircuitState(pC), STZ_CIRCUIT_OPEN)
    When("we wait past the reset window")
    StzEngineTimeSleepMs(150)
    StzEngineCircuitCanPass(pC)        # advances to HALF_OPEN
    Then("now HALF_OPEN",          StzEngineCircuitState(pC), STZ_CIRCUIT_HALF_OPEN)
    StzEngineCircuitRecordSuccess(pC)
    Then("CLOSED after success",   StzEngineCircuitState(pC), STZ_CIRCUIT_CLOSED)
    StzEngineCircuitDestroy(pC)
EndScenario()

Scenario("Circuit: half-open trips back open on failure")
    Given("an open circuit reset window 50ms")
    pC = StzEngineCircuitCreate(2, 50)
    StzEngineCircuitRecordFailure(pC)
    StzEngineCircuitRecordFailure(pC)
    StzEngineTimeSleepMs(75)
    StzEngineCircuitCanPass(pC)   # -> HALF_OPEN
    StzEngineCircuitRecordFailure(pC)
    Then("back to OPEN",           StzEngineCircuitState(pC), STZ_CIRCUIT_OPEN)
    StzEngineCircuitDestroy(pC)
EndScenario()

Summary()
