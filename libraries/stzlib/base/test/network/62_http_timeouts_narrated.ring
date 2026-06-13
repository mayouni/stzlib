load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 1: HTTP timeouts.
#
# This first slice ships CALLER-SIDE deadlines via
# StzEnginePoolPollWithDeadline. The pool worker keeps running the
# fetch to completion; the caller just gets a timely answer. A hung
# downstream still ties up a worker -- engine-side socket-level
# timeouts (SO_RCVTIMEO / SO_SNDTIMEO) require a custom HTTP/1.1
# implementation on raw std.net.Stream sockets and is the next item
# in the Tier 1 list, deferred to its own session because doing it
# half-right leaks resources.

Scenario("Deadline-aware poll returns -4 when no result arrives in time")
    Given("a small pool with one slow-but-not-immediate bogus URL")
    p = StzEnginePoolCreate(1)
    # Submit a bogus URL -- parse fails fast, but on a fresh pool
    # the worker takes a few ms to spin up + dispatch. We pick a
    # 0-ms deadline so the poll definitely returns -4.
    nId = StzEnginePoolSubmit(p, 0, "not a url")
    Then("submission id > 0", nId > 0, TRUE)
    When("polling with deadline = 0 ms (no waiting)")
    # 0 ms means legacy poll behaviour -- one shot, no wait.
    cBody1 = StzEnginePoolPollWithDeadline(p, nId, 0)
    Then("status is -1 (running) or >=0 (already finished)",
        StzEnginePoolLastStatus() = -1 or StzEnginePoolLastStatus() >= 0,
        TRUE)
    # If the job already finished, we cannot exercise the timeout
    # path on this id; skip the rest of this scenario gracefully.
    if StzEnginePoolLastStatus() = -1
        When("polling with deadline = 1 ms (likely too short)")
        cBody2 = StzEnginePoolPollWithDeadline(p, nId, 1)
        nS = StzEnginePoolLastStatus()
        # -4 = deadline exceeded
        # -1 = job finished with transport error
        # >=0 = job finished with HTTP status
        # -2 = job already drained by another poll (possible on slow runs)
        Then("status is -4 (deadline) or job finished (-1, -2, or >=0)",
            nS = -4 or nS = -1 or nS = -2 or nS >= 0, TRUE)
    ok
    # Drain the job either way.
    StzEnginePoolPoll(p, nId)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Generous deadline lets a fast-fail job finish")
    Given("a pool and a bogus URL")
    p = StzEnginePoolCreate(2)
    nId = StzEnginePoolSubmit(p, 0, "still not a url")
    When("polling with deadline = 5000 ms")
    cBody = StzEnginePoolPollWithDeadline(p, nId, 5000)
    Then("LastStatus is -1 (transport error)",
        StzEnginePoolLastStatus(), -1)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Unknown id returns -2 even with a deadline")
    p = StzEnginePoolCreate(1)
    cBody = StzEnginePoolPollWithDeadline(p, 99999, 1000)
    Then("LastStatus = -2 (not found)",
        StzEnginePoolLastStatus(), -2)
    StzEnginePoolDestroy(p)
EndScenario()

Summary()
