load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 2: HTTP connection pool.
#
# The custom HTTP/1.1 client (engine/src/httpcore.zig) now hands its
# sockets to a connection pool (engine/src/http_pool.zig) keyed by
# (scheme, host, port). A second request to the same host reuses the
# warm socket instead of paying the TCP + TLS handshake again.
#
# These scenarios make real requests to example.com and so run OUTSIDE
# CI (network required), like the existing 52/55 suites. The pool is
# process-wide; because each `ring` invocation is a fresh process the
# counters start at zero and the reuse assertions are deterministic in
# this single-threaded test.

oHttp = new stzHttpClient()

Scenario("PoolStats exposes the four pool counters")
    Given("a fresh client and one GET to a host")
    oHttp.Get_("http://example.com/")
    When("reading PoolStats")
    aStats = oHttp.PoolStats()
    Then("opens is >= 1 after the first open", aStats[:opens] >= 1, TRUE)
    # libcurl manages its connection cache internally and does not expose
    # per-state idle/active counts, so those read 0 (opens/reuses are the
    # meaningful counters -- see the reuse scenario below).
    Then("idle is reported as 0 (libcurl-managed cache)", aStats[:idle], 0)
    Then("active is 0 once the request has completed", aStats[:active], 0)
EndScenario()

Scenario("A second request to the same host reuses the connection")
    Given("the opens + reuses counters before a same-host GET")
    aBefore = oHttp.PoolStats()
    nReusesBefore = aBefore[:reuses]
    nOpensBefore  = aBefore[:opens]
    When("issuing another GET to the same host")
    oHttp.Get_("http://example.com/")
    aAfter = oHttp.PoolStats()
    Then("reuses incremented by exactly 1", aAfter[:reuses], nReusesBefore + 1)
    Then("opens did NOT increase (no new socket)", aAfter[:opens], nOpensBefore)
EndScenario()

Scenario("HTTPS uses a distinct pool key and opens its own socket")
    Given("the opens count before an https GET to the same host name")
    aBefore = oHttp.PoolStats()
    nOpensBefore = aBefore[:opens]
    When("issuing an https GET")
    oHttp.Get_("https://example.com/")
    aAfter = oHttp.PoolStats()
    Then("opens increased (https is a separate scheme/port key)",
        aAfter[:opens] > nOpensBefore, TRUE)
EndScenario()

Summary()
