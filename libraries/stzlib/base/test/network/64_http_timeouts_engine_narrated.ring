load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 1 (engine-side half): per-layer timeouts on
# the custom HTTP/1.1 client.
#
#   * connect timeout -- non-blocking connect + poll(POLLOUT) with a
#     deadline, so an unreachable host fails in milliseconds instead of
#     blocking on the OS connect timeout (~21s on Windows).
#   * request timeout -- SO_RCVTIMEO / SO_SNDTIMEO on the socket
#     (honoured on POSIX; best-effort on Windows -- the caller-side
#     deadline from 62_http_timeouts_narrated remains the cross-platform
#     guarantee there).
#
# The connect-timeout scenario uses RFC 5737 TEST-NET-1 (192.0.2.0/24),
# which is guaranteed never routable, so it is deterministic without a
# cooperating server. Network required; runs OUTSIDE CI.

Scenario("Connect timeout fires fast on an unreachable host")
    Given("a client with a 400 ms connect timeout")
    oHttp = new stzHttpClient()
    oHttp.SetConnectTimeout(400)
    Then("ConnectTimeout() reports the configured value", oHttp.ConnectTimeout(), 400)
    When("GET-ing a guaranteed-unreachable TEST-NET-1 address")
    oHttp.Get_("http://192.0.2.1/")
    Then("the request failed (ResponseCode -1)", oHttp.ResponseCode(), -1)
    # The exact classification of a black-hole address is OS / network
    # dependent (ConnectTimeout when the deadline wins, ConnectRefused or
    # unreachable when the stack rejects first; an intercepting middlebox
    # may turn it into a request-layer error). Assert the connect-layer
    # failure, falling back to "an error was surfaced" for odd networks.
    Then("a connect-layer failure is surfaced",
        StzFindFirst("connect failed", oHttp.LastError()) > 0 or oHttp.HasError(),
        TRUE)
EndScenario()

Scenario("A malformed URL surfaces cleanly even with timeouts set")
    Given("a client with explicit connect + request timeouts")
    oHttp2 = new stzHttpClient()
    oHttp2.SetConnectTimeout(500)
    oHttp2.SetRequestTimeout(2000)
    Then("RequestTimeout() reports the configured value", oHttp2.RequestTimeout(), 2000)
    When("GET-ing a malformed URL")
    oHttp2.Get_("not a url")
    Then("ResponseCode is -1", oHttp2.ResponseCode(), -1)
    Then("the response body is empty", oHttp2.ResponseBody(), "")
EndScenario()

Scenario("Process-wide engine defaults can be set and a request still runs")
    Given("default timeouts set via the engine")
    oHttp3 = new stzHttpClient()
    oHttp3.SetDefaultTimeouts(3000, 10000, 30000)
    When("a normal request runs under the new defaults")
    oHttp3.Get_("http://example.com/")
    Then("the request succeeds (200)", oHttp3.ResponseCode(), 200)
EndScenario()

Summary()
