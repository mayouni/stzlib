load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("stzReactiveTimer is polling-driven on Start (no libuv)")
    Given("a fresh one-shot timer")
    oT = new stzReactiveTimer("t1", 50, NULL, NULL, TRUE)
    bActiveBefore = oT.isActive
    nStartBefore = oT.startTime
    When("Start is called")
    oT.Start()
    bActiveAfter = oT.isActive
    bStartSet = oT.startTime > 0
    Then("isActive starts FALSE",        bActiveBefore, FALSE)
    Then("startTime is 0 before Start",  nStartBefore,  0)
    Then("isActive becomes TRUE",        bActiveAfter,  TRUE)
    Then("startTime is set",             bStartSet,     TRUE)
EndScenario()

Scenario("CheckAndTick on an inactive timer is a no-op")
    Given("a fresh timer that has never been Start'd")
    oT2 = new stzReactiveTimer("t2", 100, NULL, NULL, FALSE)
    bTick = oT2.CheckAndTick()
    Then("CheckAndTick returns false", bTick, FALSE)
EndScenario()

Scenario("Stop deactivates a running timer")
    Given("an active timer")
    oT3 = new stzReactiveTimer("t3", 100, NULL, NULL, FALSE)
    oT3.Start()
    When("Stop is called")
    oT3.Stop()
    bActive = oT3.isActive
    Then("isActive becomes FALSE", bActive, FALSE)
EndScenario()

Scenario("isOneTime parameter is honoured (regression test)")
    Given("a one-shot and a repeating timer")
    oOne = new stzReactiveTimer("once", 100, NULL, NULL, TRUE)
    oRep = new stzReactiveTimer("rep",  100, NULL, NULL, FALSE)
    Then("one-shot timer has isOneTime TRUE",  oOne.isOneTime, TRUE)
    Then("repeating timer has isOneTime FALSE", oRep.isOneTime, FALSE)
EndScenario()

Summary()
