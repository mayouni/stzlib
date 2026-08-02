load "../../stzBase.ring"
load "../_narrated.ring"

# M-DEP4 slice 2: stzTcpClient + stzTcpServer rewired to engine TCP.
# Live network IO stays out of CI per L99; this suite pins error
# paths and the construction surface.

Scenario("Engine TCP global helpers exist")
    Then("StzEngineTcpConnect defined",
        isString(@@(:StzEngineTcpConnect)),     TRUE)
    Then("StzEngineTcpSend defined",
        isString(@@(:StzEngineTcpSend)),        TRUE)
    Then("StzEngineTcpRecv defined",
        isString(@@(:StzEngineTcpRecv)),        TRUE)
    Then("StzEngineTcpClose defined",
        isString(@@(:StzEngineTcpClose)),       TRUE)
    Then("StzEngineTcpListen defined",
        isString(@@(:StzEngineTcpListen)),      TRUE)
    Then("StzEngineTcpAccept defined",
        isString(@@(:StzEngineTcpAccept)),      TRUE)
    Then("StzEngineTcpServerClose defined",
        isString(@@(:StzEngineTcpServerClose)), TRUE)
    Then("StzEngineTcpLastError defined",
        isString(@@(:StzEngineTcpLastError)),   TRUE)
EndScenario()

Scenario("Connect to a bogus host surfaces an error")
    Given("a fresh client and an unreachable host")
    oC = new stzTcpClient
    oC.Connect("invalid.host.example.invalid", 1)
    Then("IsConnected stays FALSE", oC.IsConnected(), FALSE)
    Then("LastError reports failure",
        StzFindFirst("connect failed", oC.LastError()) > 0, TRUE)
EndScenario()

Scenario("Send on a never-connected client is a no-op")
    Given("a client that was never Connect'd")
    oC2 = new stzTcpClient
    oC2.Send("hello")
    Then("LastError says Not connected", oC2.LastError(), "Not connected")
EndScenario()

Scenario("Server with an unbindable host fails to listen")
    Given("a server and an invalid bind host")
    oS = new stzTcpServer
    oS.Listen(8080, "not an ip")
    Then("IsListening stays FALSE", oS.IsListening(), FALSE)
    Then("LastError captured",
        StzFindFirst("listen", oS.LastError()) > 0, TRUE)
EndScenario()

Scenario("Accept on a non-listening server returns NULL")
    Given("a fresh server")
    oS2 = new stzTcpServer
    Then("AcceptOne returns NULL", oS2.AcceptOne(), NULL)
    Then("LastError = Not listening", oS2.LastError(), "Not listening")
EndScenario()

# THE SCENES ABOVE ONLY EVER ASK FOR A FAILURE, and every one of them
# passed for four months against an error slot that was never written
# -- because they compared against a STRING, and an unwritten slot
# answers "". Two properties they cannot see:
#   - the reason is the ENGINE's, not a generic placeholder;
#   - SUCCESS CLEARS IT, so an error is about the last call rather
#     than the last failure, however long ago.
Scenario("The error is a real reason, and success clears it")
    Given("a client pointed at a host that cannot resolve")
    oC3 = new stzTcpClient
    oC3.Connect("invalid.host.example.invalid", 1)
    Then("HasError agrees with LastError", oC3.HasError(), TRUE)
    Then("...and the reason came from the engine, not a placeholder",
        StzFindFirst("dns", StzLower(oC3.LastError())) > 0, TRUE)

    When("a server binds successfully")
    oS3 = new stzTcpServer
    oS3.Listen(0, "127.0.0.1")
    Then("it is listening", oS3.IsListening(), TRUE)
    Then("...and the error slot is CLEAR, not stale", oS3.LastError(), "")
    Then("...so HasError is FALSE", oS3.HasError(), FALSE)
    oS3.Close()
EndScenario()

# stzWebSocket writes the same inherited slot and was broken the same
# way -- 11 of the 24 damaged writes were its.
Scenario("stzWebSocket reports through the same inherited slot")
    Given("a socket that was never connected")
    oW = new stzWebSocket
    oW.Send("x")
    Then("Send says why", oW.LastError(), "Not connected")
EndScenario()

Summary()
