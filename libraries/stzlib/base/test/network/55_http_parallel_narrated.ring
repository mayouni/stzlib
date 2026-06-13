load "../../stzBase.ring"
load "../_narrated.ring"

# M-DEP4 follow-on: parallel HTTP GET via std.Thread per URL.
# Pins the API surface + the all-fail path (every URL bogus).

Scenario("StzEngineHttpParallelGet exists and is callable")
    Then("StzEngineHttpParallelGet is defined",
        isString(@@(:StzEngineHttpParallelGet)), TRUE)
EndScenario()

Scenario("Parallel GET against all-bogus URLs returns one record per URL")
    Given("three bogus URLs joined by newline")
    cBlob = "not a url" + char(10) + "also bad" + char(10) + "still bad"
    cJoined = StzEngineHttpParallelGet(cBlob)
    Then("output is non-empty", len(cJoined) > 0, TRUE)
    # Each record ends with the RECORD_SEPARATOR (0x1E).
    aRecs = @split(cJoined, char(30))
    # Empty trailing element after the final separator is filtered.
    nFilled = 0
    nLr = len(aRecs)
    for _i_ = 1 to nLr
        if aRecs[_i_] != "" nFilled++ ok
    next
    Then("three records produced", nFilled, 3)
    Then("each record begins with '-1:' (transport error)",
        StzLeft(aRecs[1], 3), "-1:")
EndScenario()

Scenario("stzHttpClient.GetMany wraps the engine call")
    Given("a client and a list of bogus URLs")
    oC = new stzHttpClient()
    aR = oC.GetMany([ "bad1", "bad2", "bad3" ])
    Then("three responses returned",     len(aR), 3)
    Then("each response is a list",      isList(aR[1]), TRUE)
    Then("status code = -1 (transport)", aR[1][:code], -1)
EndScenario()

Summary()
