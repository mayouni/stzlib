load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 3: DNS cache with TTL.
#
# The engine caches host resolutions (engine/src/dns.zig) so repeat
# connects to the same host skip the resolver syscall. These scenarios
# exercise the Ring-facing diagnostics (StzEngineDnsResolve / Stats /
# CacheClear). The core cache/expiry/negative behaviour is covered by
# the Zig unit tests in dns.zig. Network required; runs OUTSIDE CI.
#
# Note: the DNS cache used by the HTTP hot path lives in stz_http.dll;
# these diagnostics read that same cache.

Scenario("A cold resolve increments the resolve counter")
    Given("a cleared DNS cache")
    StzEngineDnsCacheClear()
    nResolvesBefore = DnsStat("resolves")
    When("resolving a host for the first time")
    cAddr = StzEngineDnsResolve("example.com", 80)
    Then("an address string came back (non-empty)", len(cAddr) > 0, TRUE)
    Then("resolves incremented by 1",
        DnsStat("resolves"), nResolvesBefore + 1)
EndScenario()

Scenario("A warm resolve is a cache hit, not a re-resolve")
    Given("the host just resolved (now cached)")
    nResolvesBefore = DnsStat("resolves")
    nHitsBefore = DnsStat("hits")
    When("resolving the same host again")
    StzEngineDnsResolve("example.com", 80)
    Then("resolves did NOT increase (served from cache)",
        DnsStat("resolves"), nResolvesBefore)
    Then("hits incremented by 1",
        DnsStat("hits"), nHitsBefore + 1)
EndScenario()

Summary()

func DnsStat(cKey)
    # Parse "resolves=N\thits=N" -> the integer for cKey.
    cRaw = StzEngineDnsStats()
    aParts = @split(cRaw, char(9))
    nP = len(aParts)
    for i = 1 to nP
        cKV = aParts[i]
        nEq = StzFindFirst("=", cKV)
        if nEq < 1 loop ok
        if StzLeft(cKV, nEq - 1) = cKey
            return 0 + StzMidToEnd(cKV, nEq + 1)
        ok
    next
    return -1
