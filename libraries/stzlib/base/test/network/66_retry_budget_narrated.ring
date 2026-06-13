load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 5: retry budget.
#
# stzRetryBudget wraps the engine token-bucket rate limiter
# (stz_resilience.dll) with a budget-shaped API: N retries that refill
# over a W-second window. It caps retries across a workload so transient
# failures cannot escalate into a retry storm. No network needed -- this
# exercises the budget/refill arithmetic directly.

Scenario("A fresh budget allows the first N retries")
    Given("a budget of 3 retries over a 1s window")
    oB = new stzRetryBudget(3, 1)
    Then("RefillPerSecond is 3 (3 / 1s)", oB.RefillPerSecond(), 3)
    Then("first retry granted",  oB.Allow(), TRUE)
    Then("second retry granted", oB.Allow(), TRUE)
    Then("third retry granted",  oB.Allow(), TRUE)
    When("the budget is spent")
    Then("the fourth retry is refused", oB.Allow(), FALSE)
    oB.Destroy()
EndScenario()

Scenario("The budget refills over the window")
    Given("a budget of 2 retries over a 1s window, fully spent")
    oB2 = new stzRetryBudget(2, 1)
    oB2.Allow()
    oB2.Allow()
    Then("the budget is empty (next retry refused)", oB2.Allow(), FALSE)
    When("we wait 800ms (refill 2/sec => ~1.6 tokens)")
    StzEngineTimeSleepMs(800)
    Then("a retry is granted again after refill", oB2.Allow(), TRUE)
    oB2.Destroy()
EndScenario()

Scenario("A small budget over a long window still grants at least one")
    Given("a budget of 1 retry over a 10s window")
    oB3 = new stzRetryBudget(1, 10)
    Then("refill floors to a minimum of 1", oB3.RefillPerSecond(), 1)
    Then("the single retry is granted", oB3.Allow(), TRUE)
    Then("the next retry is refused",    oB3.Allow(), FALSE)
    oB3.Destroy()
EndScenario()

Summary()
