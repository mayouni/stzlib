load "../../stzBase.ring"
load "../_narrated.ring"

# HTTP test-HARDENING: the integration seam exercised against a local
# loopback server (engine/src/testserver.zig) -- DETERMINISTIC and
# OFFLINE (no public internet). This is the regression net the live
# suites (which need the web) can't be: exact status codes, header
# capture, POST echo, large bodies, the overflow path, redirect on/off,
# request-timeout firing, auth 401/200, and cookie round-trip.

nPort = StzEngineTestServerStart(0)
cBase = "http://127.0.0.1:" + nPort

Scenario("Non-2xx status codes are surfaced exactly")
    Given("a running loopback server")
    o = new stzHttpClient()
    o.Get_(cBase + "/status/404")
    Then("404 is reported", o.ResponseCode(), 404)
    o.Get_(cBase + "/status/500")
    Then("500 is reported", o.ResponseCode(), 500)
    o.Get_(cBase + "/status/204")
    Then("204 is reported", o.ResponseCode(), 204)
EndScenario()

Scenario("Response headers are captured deterministically")
    Given("an endpoint returning a known custom header")
    o2 = new stzHttpClient()
    o2.Get_(cBase + "/headers")
    Then("status is 200", o2.ResponseCode(), 200)
    Then("the custom header is present",
        StzFindFirst(lower(o2.ResponseHeaders()), "x-test-header") > 0, TRUE)
EndScenario()

Scenario("POST echoes the request body")
    Given("the /echo endpoint")
    o3 = new stzHttpClient()
    o3.Post(cBase + "/echo", "SOFTANZA-PAYLOAD")
    Then("the body is echoed back", o3.ResponseBody(), "SOFTANZA-PAYLOAD")
EndScenario()

Scenario("A large body is received intact")
    Given("a 100000-byte response")
    o4 = new stzHttpClient()
    o4.Get_(cBase + "/big/100000")
    Then("status is 200", o4.ResponseCode(), 200)
    Then("the full body arrived", len(o4.ResponseBody()), 100000)
EndScenario()

Scenario("A body past the output cap reports overflow")
    Given("a 5MB response (> the 4MB engine buffer)")
    o5 = new stzHttpClient()
    o5.Get_(cBase + "/big/5000000")
    Then("the request reports overflow (-2)", o5.ResponseCode(), -2)
EndScenario()

Scenario("Redirects are followed by default and stoppable")
    Given("a 3-hop redirect chain")
    o6 = new stzHttpClient()
    o6.Get_(cBase + "/redirect/3")
    Then("with follow on, it lands on 200", o6.ResponseCode(), 200)
    o7 = new stzHttpClient()
    o7.FollowRedirects(FALSE)
    o7.Get_(cBase + "/redirect/3")
    Then("with follow off, it returns 302", o7.ResponseCode(), 302)
EndScenario()

Scenario("A request timeout fires on a slow endpoint")
    Given("a client with a 300ms request timeout")
    o8 = new stzHttpClient()
    o8.SetRequestTimeout(300)
    When("hitting an endpoint that sleeps 1500ms")
    o8.Get_(cBase + "/slow/1500")
    Then("the request failed (timed out)", o8.ResponseCode(), -1)
EndScenario()

Scenario("Auth: 401 without credentials, 200 with")
    Given("an endpoint requiring authorization")
    o9 = new stzHttpClient()
    o9.Get_(cBase + "/auth")
    Then("unauthenticated returns 401", o9.ResponseCode(), 401)
    o10 = new stzHttpClient()
    o10.SetAuth("user", "pass")
    o10.Get_(cBase + "/auth")
    Then("authenticated returns 200", o10.ResponseCode(), 200)
EndScenario()

Scenario("Cookies round-trip via a jar file")
    Given("a client with a cookie jar")
    o11 = new stzHttpClient()
    o11.SetCookieFile("_ck_test.txt")
    o11.SetCookieJar("_ck_test.txt")
    When("a Set-Cookie response is received, then a follow-up request")
    o11.Get_(cBase + "/setcookie")
    o11.Get_(cBase + "/checkcookie")
    Then("the cookie was sent back on the second request",
        StzFindFirst(o11.ResponseBody(), "sid=abc123") > 0, TRUE)
    remove("_ck_test.txt")
EndScenario()

StzEngineTestServerStop()
Summary()
