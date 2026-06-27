load "../../stzBase.ring"
load "../_narrated.ring"

# Tier 2 slice 2+3: async TCP on the reactor, via the stzReactor class.
#
# The reactor runs a libuv loop on its own thread; a TCP request
# (resolve -> connect -> write -> read-to-EOF) runs fully async there and
# Ring drains the response through await/poll. The TCP scenario makes a
# real request to example.com:80 and runs OUTSIDE CI (network required).

oReactor = new stzReactor()

Scenario("The reactor reports its libuv backend version")
    Given("a reactor")
    Then("Version() looks like a 1.x libuv", StzFindFirst(oReactor.Version(), "1.") > 0, TRUE)
EndScenario()

Scenario("A timer submitted through the class fires")
    Given("a 40ms timer")
    nId = oReactor.SubmitTimer(40)
    Then("a job id was returned", nId > 0, TRUE)
    Then("awaiting it returns 0 (fired)", oReactor.AwaitTimer(nId, 2000), 0)
EndScenario()

Scenario("An async TCP request returns the HTTP response")
    Given("a raw HTTP/1.0 request to example.com:80")
    cCRLF = char(13) + char(10)
    cReq = "GET / HTTP/1.0" + cCRLF
    cReq += "Host: example.com" + cCRLF
    cReq += "Connection: close" + cCRLF + cCRLF
    When("submitting it on the reactor and awaiting the body")
    cBody = oReactor.TcpRequest("example.com", 80, cReq, 15000)
    Then("the request succeeded (status 0)", oReactor.TcpLastStatus(), 0)
    Then("a non-empty body came back", len(cBody) > 0, TRUE)
    Then("the body starts with an HTTP status line",
        StzFindFirst(cBody, "HTTP/") > 0, TRUE)
EndScenario()

oReactor.Destroy()
Summary()
