load "../../stzBase.ring"
load "../_narrated.ring"

# M-DEP3 slice 1: engine HTTP client smoke (libcurl-free).
#
# Network IO is intentionally NOT exercised here -- live tests run
# outside CI per the L99 / Windows test-loop guardrail. This suite
# pins the API surface and the malformed-URL error path.

Scenario("StzEngineHttpGet exists and is callable")
    Given("the global engine HTTP function")
    Then("StzEngineHttpGet is a defined function",
        isString(@@(:StzEngineHttpGet)), TRUE)
    Then("StzEngineHttpGetStatus is defined",
        isString(@@(:StzEngineHttpGetStatus)), TRUE)
    Then("StzEngineHttpPost is defined",
        isString(@@(:StzEngineHttpPost)), TRUE)
    Then("StzEngineHttpLastError is defined",
        isString(@@(:StzEngineHttpLastError)), TRUE)
EndScenario()

Scenario("GET against an invalid URL surfaces an error")
    Given("a malformed URL")
    cBody = StzEngineHttpGet("not a url")
    Then("the body is empty",        cBody, "")
    Then("LastError reports the failure",
        StzFindFirst(StzEngineHttpLastError(), "GET failed") > 0, TRUE)
EndScenario()

Scenario("GET status against an invalid URL is -1")
    Given("a malformed URL")
    Then("status is -1 (transport error)",
        StzEngineHttpGetStatus("not a url"), -1)
EndScenario()

Summary()
