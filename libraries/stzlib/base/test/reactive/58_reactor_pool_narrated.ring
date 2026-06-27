load "../../stzBase.ring"
load "../_narrated.ring"

# Tier 2: multi-loop reactor pool (horizontal scale).
#
# N libuv loops on N threads; a batch of async TCP requests is
# round-robined across them and runs concurrently. The fetch scenario
# hits example.com:80 a few times in parallel and runs OUTSIDE CI
# (network required).

cCRLF = char(13) + char(10)
cReq = "GET / HTTP/1.0" + cCRLF
cReq += "Host: example.com" + cCRLF
cReq += "Connection: close" + cCRLF + cCRLF

Scenario("A pool reports its loop count")
    Given("a pool of 3 loops")
    oPool = new stzReactorPool(3)
    Then("Count() is 3", oPool.Count(), 3)
    oPool.Destroy()
EndScenario()

Scenario("A batch of async requests runs across the loops")
    Given("a pool of 2 loops and 4 requests")
    oPool2 = new stzReactorPool(2)
    aReqs = [
        [ "example.com", 80, cReq ],
        [ "example.com", 80, cReq ],
        [ "example.com", 80, cReq ],
        [ "example.com", 80, cReq ]
    ]
    When("fetching them all in parallel")
    aBodies = oPool2.FetchAll(aReqs, 20000)
    Then("we got 4 responses back", len(aBodies), 4)
    Then("the first response is an HTTP reply",
        StzFindFirst(aBodies[1], "HTTP/") > 0, TRUE)
    Then("the last response is an HTTP reply",
        StzFindFirst(aBodies[4], "HTTP/") > 0, TRUE)
    oPool2.Destroy()
EndScenario()

Summary()
