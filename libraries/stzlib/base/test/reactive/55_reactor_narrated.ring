load "../../stzBase.ring"
load "../_narrated.ring"

# Tier 2 foundation: libuv-backed reactor.
#
# The engine vendors libuv (engine/vendor/libuv) as C source -- the
# industry-standard cross-platform event loop (epoll/kqueue/IOCP). This
# suite proves the vendor + build + link + run path end-to-end through
# the Ring FFI surface. The full async reactor surface is built on this
# in later slices.

Scenario("libuv is linked and reports its version")
    Given("the stz_reactor engine module is loaded")
    cVer = StzEngineReactorVersion()
    Then("a non-empty version string is returned", len(cVer) > 0, TRUE)
    Then("it looks like a 1.x libuv version", StzFindFirst(cVer, "1.") > 0, TRUE)
EndScenario()

Scenario("the libuv event loop actually runs")
    Given("a self-test that arms a one-shot timer on a real loop")
    When("the loop is run to completion")
    nFired = StzEngineReactorSelfTest()
    Then("exactly one timer callback fired (loop ran)", nFired, 1)
EndScenario()

Summary()
