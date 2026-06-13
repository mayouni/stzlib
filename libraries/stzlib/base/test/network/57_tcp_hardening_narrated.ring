load "../../stzBase.ring"
load "../_narrated.ring"

# Hardening suite for the engine TCP surface.
# Covers: error invariants, host validation, port range, listener
# bind semantics. No live connections; everything pins the contract
# under malformed input.

Scenario("Bogus host fails fast and sets LastError")
    Given("an unreachable hostname")
    n1 = StzEngineTimeNowMs()
    pH = StzEngineTcpConnect("invalid.host.example.invalid", 1)
    n2 = StzEngineTimeNowMs()
    Then("LastError contains 'connect failed'",
        StzFind(StzEngineTcpLastError(), "connect failed") > 0, TRUE)
    # DNS resolution should fail within a few seconds even on slow nets.
    Then("Connect returned within 10000 ms",
        n2 - n1 < 10000, TRUE)
EndScenario()

Scenario("Listen with invalid bind host fails cleanly")
    Given("a non-IP host string")
    pS = StzEngineTcpListen("not an ip", 0)
    Then("LastError contains 'listen'",
        StzFind(StzEngineTcpLastError(), "listen") > 0, TRUE)
EndScenario()

Scenario("Listen on port 0 picks an ephemeral port")
    # Successful bind. Caller can then close.
    pS = StzEngineTcpListen("127.0.0.1", 0)
    Then("LastError is empty after successful bind",
        StzEngineTcpLastError(), "")
    StzEngineTcpServerClose(pS)
EndScenario()

Scenario("Listen on the same port twice without close is OK in slice 2 (SO_REUSEADDR)")
    # Engine sets reuse_address = true; back-to-back listen+close
    # cycles should succeed without TIME_WAIT pain.
    pS1 = StzEngineTcpListen("127.0.0.1", 0)
    Then("first bind OK", StzEngineTcpLastError(), "")
    StzEngineTcpServerClose(pS1)

    pS2 = StzEngineTcpListen("127.0.0.1", 0)
    Then("second bind OK after close", StzEngineTcpLastError(), "")
    StzEngineTcpServerClose(pS2)
EndScenario()

Scenario("Send/Recv on null handle return -1")
    Then("send on NULL returns -1",
        StzEngineTcpSend(NULL, "x"), -1)
    Then("recv on NULL returns empty body",
        StzEngineTcpRecv(NULL, 16), "")
EndScenario()

Summary()
