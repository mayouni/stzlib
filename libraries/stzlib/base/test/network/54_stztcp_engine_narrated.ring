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
        StzFind(oC.LastError(), "connect failed") > 0, TRUE)
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
        StzFind(oS.LastError(), "listen") > 0, TRUE)
EndScenario()

Scenario("Accept on a non-listening server returns NULL")
    Given("a fresh server")
    oS2 = new stzTcpServer
    Then("AcceptOne returns NULL", oS2.AcceptOne(), NULL)
    Then("LastError = Not listening", oS2.LastError(), "Not listening")
EndScenario()

Summary()
