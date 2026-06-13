load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 8: graceful pool shutdown.
#
# StzEnginePoolDrain stops the thread pool accepting new submissions,
# then waits up to a timeout for queued + in-flight jobs to finish,
# returning the residual count still outstanding at the timeout. Submit
# is refused with -4 ("pool draining") once draining.
#
# stzHttpClient.Shutdown() releases the HTTP connection pool's idle
# sockets (a separate concern from the thread pool drain).

Scenario("Drain rejects new submissions")
    Given("an idle pool")
    p = StzEnginePoolCreate(1)
    When("draining an empty pool")
    nResidual = StzEnginePoolDrain(p, 1000)
    Then("residual is 0 (nothing was in flight)", nResidual, 0)
    When("submitting after the drain")
    nId = StzEnginePoolSubmit(p, 0, "http://example.com/")
    Then("the submission is refused with -4", nId, -4)
    Then("LastError says the pool is draining",
        StzFind(StzEnginePoolLastError(), "draining") > 0, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("In-flight jobs complete within a generous drain timeout")
    Given("a pool with one fast-failing job in flight")
    p = StzEnginePoolCreate(2)
    nId = StzEnginePoolSubmit(p, 0, "not a url")
    When("draining with a 5s timeout")
    nResidual = StzEnginePoolDrain(p, 5000)
    Then("everything drained (residual 0)", nResidual, 0)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("A zero timeout returns a non-zero residual when work is queued")
    Given("one worker flooded with 8 network jobs")
    p = StzEnginePoolCreate(1)
    for i = 1 to 8
        StzEnginePoolSubmit(p, 0, "http://example.com/")
    next
    When("draining with timeout 0 (no wait)")
    nResidual = StzEnginePoolDrain(p, 0)
    Then("residual is non-zero (jobs still queued/running)",
        nResidual >= 1, TRUE)
    StzEnginePoolDestroy(p)
EndScenario()

Scenario("Client Shutdown releases pooled connections")
    Given("an HTTP client that has made one request (leaving an idle socket)")
    oC = new stzHttpClient()
    oC.Get_("http://example.com/")
    When("the client is shut down")
    nClosed = oC.Shutdown()
    Then("at least one idle connection was closed", nClosed >= 1, TRUE)
EndScenario()

Summary()
