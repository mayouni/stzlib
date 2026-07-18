load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 2: HTTP/2 via vendored nghttp2 (through libcurl).
#
# The HTTP client now negotiates HTTP/2 over TLS (ALPN) when the server
# supports it, falling back to HTTP/1.1 otherwise. StzEngineHttpLastVersion
# reports the negotiated version (1 = HTTP/1.x, 2 = HTTP/2, 3 = HTTP/3).
# Live requests to h2-capable hosts; runs OUTSIDE CI (network required).

Scenario("The engine reports a libcurl + nghttp2 backend")
    Given("the HTTP engine version string")
    cEng = StzEngineHttpEngineVersion()
    Then("it is libcurl", StzFindFirst("libcurl", cEng) > 0, TRUE)
    Then("HTTP/2 (nghttp2) is built in", StzFindFirst("nghttp2", cEng) > 0, TRUE)
EndScenario()

Scenario("An https request to an h2 host negotiates HTTP/2")
    Given("an HTTP client and an h2-capable host")
    o = new stzHttpClient()
    When("GET-ing https://nghttp2.org/")
    o.Get_("https://nghttp2.org/")
    Then("the request succeeded (200)", o.ResponseCode(), 200)
    Then("the negotiated version is HTTP/2",
        StzEngineHttpLastVersion(), 2)
EndScenario()

Scenario("A second h2 host also negotiates HTTP/2")
    Given("an HTTP client and Cloudflare (h2)")
    o2 = new stzHttpClient()
    o2.Get_("https://www.cloudflare.com/")
    Then("the request succeeded (200)", o2.ResponseCode(), 200)
    Then("the negotiated version is HTTP/2",
        StzEngineHttpLastVersion(), 2)
EndScenario()

Summary()
