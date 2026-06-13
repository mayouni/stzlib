load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 4: context-style cancellation tokens.
#
# A stzCancelToken wraps an engine CancelToken (engine/src/cancel.zig,
# shipped in stz_pool.dll). A pool job submitted via
# StzEnginePoolSubmitWithCancel carries the token; the worker checks it
# before running the job and surfaces a cancellation status
# (StzEnginePoolLastStatus() = -5) instead of executing.
#
# A single blocking fetch has exactly one safe checkpoint -- before it
# starts -- so these scenarios cancel BEFORE the worker dequeues the job,
# which is deterministic. True mid-I/O preemption needs the future
# cooperative scheduler (Tier 2), not in scope here.

Scenario("A fresh token is not cancelled")
    Given("a new cancellation token")
    oTok = new stzCancelToken
    Then("IsCancelled is FALSE", oTok.IsCancelled(), FALSE)
    oTok.Destroy()
EndScenario()

Scenario("Signalling a token flips it to cancelled")
    Given("a new cancellation token")
    oTok = new stzCancelToken
    When("the token is signalled")
    oTok.Cancel()
    Then("IsCancelled is TRUE", oTok.IsCancelled(), TRUE)
    oTok.Destroy()
EndScenario()

Scenario("A job carrying an already-cancelled token is skipped")
    Given("a pool, a token signalled before submission")
    p = StzEnginePoolCreate(1)
    oTok = new stzCancelToken
    oTok.Cancel()
    When("submitting a job that carries the cancelled token")
    nId = StzEnginePoolSubmitWithCancel(p, 0, "http://example.com/", oTok.Handle())
    Then("submission id > 0", nId > 0, TRUE)
    When("polling for the result with a generous deadline")
    StzEnginePoolPollWithDeadline(p, nId, 3000)
    Then("LastStatus is -5 (cancelled, job never ran)",
        StzEnginePoolLastStatus(), -5)
    oTok.Destroy()
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("A live (uncancelled) token does not disturb normal execution")
    Given("a pool and a token that is never signalled")
    p = StzEnginePoolCreate(1)
    oTok = new stzCancelToken
    When("submitting a bogus-URL job with the live token")
    nId = StzEnginePoolSubmitWithCancel(p, 0, "not a url", oTok.Handle())
    StzEnginePoolPollWithDeadline(p, nId, 5000)
    Then("LastStatus is -1 (job ran, transport error -- not cancelled)",
        StzEnginePoolLastStatus(), -1)
    oTok.Destroy()
    StzEnginePoolDestroy(p)
EndScenario()

Summary()
