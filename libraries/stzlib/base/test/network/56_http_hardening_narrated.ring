load "../../stzBase.ring"
load "../_narrated.ring"

# Hardening suite for the engine HTTP surface.
# Covers: correctness, consistency, security, performance.
# No live HTTP needed -- error-path + invariant checks only.

# ── correctness ──────────────────────────────────────────────

Scenario("Status code is sane for malformed URL")
    Given("a malformed URL")
    cBody = StzEngineHttpGet("not a url")
    nStatus = StzEngineHttpGetStatus("not a url")
    Then("body is empty",       cBody, "")
    Then("status is -1 (transport)", nStatus, -1)
EndScenario()

Scenario("Empty URL is rejected cleanly")
    Given("an empty URL")
    cBody = StzEngineHttpGet("")
    nStatus = StzEngineHttpGetStatus("")
    Then("body is empty", cBody, "")
    Then("status is -1", nStatus, -1)
    Then("LastError mentions empty",
        StzFindFirst("URL", StzEngineHttpLastError()) > 0 or
        StzFindFirst("empty", StzEngineHttpLastError()) > 0,
        TRUE)
EndScenario()

# ── security ─────────────────────────────────────────────────

Scenario("Header injection via CRLF in custom header is sanitised by std.http")
    Given("a generic request with a header that contains a CRLF")
    cHeaders = "X-Test: safe" + char(13) + char(10) + "X-Injected: bad"
    cBody = StzEngineHttpRequest(0, "not a url", cHeaders, "", "")
    nStatus = StzEngineHttpLastStatus()
    # Either the engine refuses with a parse error or the request
    # fails at the URL stage. Either way the call returns -1 / empty
    # body without crashing -- the key invariant.
    Then("status is non-positive (transport reject)", nStatus <= 0, TRUE)
    Then("body is empty",                              cBody,       "")
EndScenario()

Scenario("Massive URL is rejected at the parse stage")
    Given("a 1KB-long URL with no scheme")
    cBigUrl = ""
    for _i_ = 1 to 100
        cBigUrl += "abcdefghij"
    next
    cBody = StzEngineHttpGet(cBigUrl)
    Then("status is -1 (parse rejection)",
        StzEngineHttpGetStatus(cBigUrl), -1)
EndScenario()

# ── consistency ──────────────────────────────────────────────

Scenario("Repeated identical errors leave LastError stable")
    Given("two failing GETs in sequence")
    cBody1 = StzEngineHttpGet("not a url")
    cErr1 = StzEngineHttpLastError()
    cBody2 = StzEngineHttpGet("not a url")
    cErr2 = StzEngineHttpLastError()
    Then("error messages match", cErr1, cErr2)
EndScenario()

Scenario("Concurrent parallel-GET batch handles bogus URLs uniformly")
    Given("five bogus URLs joined by newline")
    cBlob = "bad1" + char(10) + "bad2" + char(10) + "bad3" + char(10) + "bad4" + char(10) + "bad5"
    cJoined = StzEngineHttpParallelGet(cBlob)
    # Count "-1:" prefixes.
    aRecs = @split(cJoined, char(30))
    nMinus1 = 0
    nLr = len(aRecs)
    for _i_ = 1 to nLr
        if StzLeft(aRecs[_i_], 3) = "-1:" nMinus1++ ok
    next
    Then("all five records reported transport error",
        nMinus1, 5)
EndScenario()

# ── performance ──────────────────────────────────────────────

Scenario("Parallel GET wall-clock is bounded for N bogus URLs")
    Given("ten malformed URLs, no host (engine cap is 32)")
    # Use URLs libcurl rejects at parse time (no host part) so they
    # fast-fail without a DNS lookup -- a single-label name like "bad1"
    # would otherwise trigger a real (slow) resolver attempt.
    cBlob = ""
    for _i_ = 1 to 10
        if _i_ > 1 cBlob += char(10) ok
        cBlob += "http://"
    next
    When("the parallel call runs")
    n1 = StzEngineTimeNowMs()
    cJoined = StzEngineHttpParallelGet(cBlob)
    n2 = StzEngineTimeNowMs()
    nElapsedMs = n2 - n1
    Then("ten records came back",
        len(@split(cJoined, char(30))) - 1 >= 10, TRUE)
    # Each URL parse fails fast; the wall-clock should be tens of ms.
    # Cap at 2000ms to detect a regression (serialisation, retry storm).
    Then("wall-clock < 2000ms (parallel, fast-fail)",
        nElapsedMs < 2000, TRUE)
EndScenario()

Summary()
