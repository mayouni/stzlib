load "../../stzBase.ring"
load "../_narrated.ring"

# Engine-side time primitives -- correctness + monotonicity + the
# claim that the same clock is exposed in milliseconds and nanos.

Scenario("Engine clock advances monotonically")
    Given("two consecutive monotonic reads with a 5ms sleep between")
    n1 = StzEngineTimeNowMs()
    StzEngineTimeSleepMs(5)
    n2 = StzEngineTimeNowMs()
    Then("the second read is strictly greater", n2 > n1, TRUE)
    Then("the gap is at least 4 ms (allowing scheduler slack)",
        n2 - n1 >= 4, TRUE)
    Then("the gap is at most 200 ms (sanity)",
        n2 - n1 <= 200, TRUE)
EndScenario()

Scenario("Wall clock is a plausible post-2020 epoch ms")
    nWall = StzEngineTimeWallMs()
    Then("wall ms > 2020-01-01 epoch", nWall > 1577836800000, TRUE)
    Then("wall ms < 2100-01-01 epoch", nWall < 4102444800000, TRUE)
EndScenario()

Scenario("ms and us readings agree (rounded)")
    Given("monotonic reads in ms and us at the same instant")
    nMs = StzEngineTimeNowMs()
    nUs = StzEngineTimeNowUs()
    # us is 1000x more granular; |ms - us/1000| should be tiny.
    nDriftMs = floor(nUs / 1000) - nMs
    if nDriftMs < 0 nDriftMs = -nDriftMs ok
    Then("drift is at most 5 ms", nDriftMs <= 5, TRUE)
EndScenario()

Summary()
