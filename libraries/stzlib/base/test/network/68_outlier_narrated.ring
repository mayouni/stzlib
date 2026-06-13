load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 7: outlier ejection per host.
#
# The engine tracks consecutive failures per host (resilience.zig, in
# stz_http.dll alongside the connection pool). Once a host crosses the
# failure threshold it is ejected for a cooldown window, then
# auto-readmitted; a success resets the failure run. The HTTP pool's
# acquire() refuses ejected hosts. These scenarios drive the detector
# directly via StzEngineOutlier* -- no network needed.

Scenario("Ten consecutive failures eject a host")
    Given("a clean host with the default threshold of 10")
    StzEngineOutlierConfig(10, 30000)
    StzEngineOutlierReset("eject.example")
    When("recording 10 failures in a row")
    for i = 1 to 10
        StzEngineOutlierRecord("eject.example", 0, 0)
    next
    Then("the host is now ejected", StzEngineOutlierShouldEject("eject.example"), 1)
EndScenario()

Scenario("A success resets the failure count")
    Given("a host with 9 failures (one below threshold 10)")
    StzEngineOutlierConfig(10, 30000)
    StzEngineOutlierReset("reset.example")
    for i = 1 to 9
        StzEngineOutlierRecord("reset.example", 0, 0)
    next
    Then("not yet ejected", StzEngineOutlierShouldEject("reset.example"), 0)
    When("a success is recorded, then 9 more failures")
    StzEngineOutlierRecord("reset.example", 1, 0)
    for i = 1 to 9
        StzEngineOutlierRecord("reset.example", 0, 0)
    next
    Then("still not ejected -- the success reset the run",
        StzEngineOutlierShouldEject("reset.example"), 0)
EndScenario()

Scenario("A host is readmitted after the cooldown")
    Given("a low threshold (3) and a short cooldown (200ms)")
    StzEngineOutlierConfig(3, 200)
    StzEngineOutlierReset("cooldown.example")
    for i = 1 to 3
        StzEngineOutlierRecord("cooldown.example", 0, 0)
    next
    Then("the host is ejected", StzEngineOutlierShouldEject("cooldown.example"), 1)
    When("we wait past the cooldown (300ms)")
    StzEngineTimeSleepMs(300)
    Then("the host is readmitted", StzEngineOutlierShouldEject("cooldown.example"), 0)
    StzEngineOutlierConfig(10, 30000)
EndScenario()

Summary()
