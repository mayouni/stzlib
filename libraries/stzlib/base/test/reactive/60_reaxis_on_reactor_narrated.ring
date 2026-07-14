load "../../stzBase.ring"
load "../_narrated.ring"

# F5 -- REAXIS RUNS ON REACTOR (the reactive-coherence structural task).
#
# The declarative surface's runtime now rides the vendored-libuv
# reactor: the timer manager's inter-tick waits are REAL libuv timers
# awaited on the engine loop thread, reactive HTTP submits async TCP
# jobs and dispatches callbacks from the same RunLoop, and
# stzReactiveObject COMPOSES the engine (the F3 inheritance untangle).
# The pure-Ring sleep-poller remains only as the documented no-DLL
# fallback (LAW 2).
#
# The HTTP scenario is the delivery-plane convergence in one process:
# an stzAppServer (R7 host) is PUMPED BY A REAXIS TIMER while the
# reactive HTTP client talks to it -- server, client, timers and
# callbacks all interleaved on one Ring thread over one engine.

$oRs = new stzReactive()

Scenario("the reactive system reports its reactor backing")
	Given("a fresh reactive system with stz_reactor.dll present")
	Then("ReactorQ() exposes the backing reactor", isObject($oRs.ReactorQ()), TRUE)
	Then("LibuvLoop() is a real loop handle again", $oRs.LibuvLoop() != NULL, TRUE)
EndScenario()

Scenario("RunAfter fires once, on time, on the reactor runtime")
	Given("a 60ms one-shot timer")
	$nFired = 0
	$nT0 = StzEngineTimeNowMs()
	$nTFire = 0
	$oRs.RunAfter(60, func {
		$nFired++
		$nTFire = StzEngineTimeNowMs()
	})
	When("the loop runs to completion")
	$oRs.RunLoop()
	Then("the callback fired exactly once", $nFired, 1)
	Then("and not before its delay", ($nTFire - $nT0) >= 55, TRUE)
EndScenario()

Scenario("RunEvery repeats and can be stopped from its own callback")
	Given("a 25ms repeating timer that stops itself after 3 ticks")
	$nTicks = 0
	$oRs2 = new stzReactive()
	$oRs2.RunEvery(25, func {
		$nTicks++
		if $nTicks >= 3
			$oRs2.StopAllTimers()
		ok
	})
	When("the loop runs")
	$oRs2.RunLoop()
	Then("the timer ticked exactly 3 times", $nTicks, 3)
	$oRs2.Stop()
EndScenario()

Scenario("reactive HTTP is genuinely non-blocking and served locally")
	Given("an R7 app server on an ephemeral port with a /ping route")
	$oSrv = new stzAppServer()
	$oSrv.Get_("/ping", func oReq, oResp { oResp.Text("pong") })
	$oSrv.Start(0, "127.0.0.1")

	Given("a reactive system whose pump timer serves the app server")
	$oRs3 = new stzReactive()
	$cGot = ""
	$bBlockedProof = TRUE

	When("HttpGet submits (no callback may run before the loop)")
	$oRs3.HttpGet("http://127.0.0.1:" + $oSrv.Port() + "/ping",
		func cBody { $cGot = cBody },
		func cErr { $cGot = "ERR:" + cErr })
	Then("the submit returned WITHOUT dispatching", $cGot, "")

	When("a Reaxis timer pumps the server while the loop drains http")
	$nPumps = 0
	$oRs3.RunEvery(10, func {
		$nPumps++
		$oSrv.ServeOne(1)
		if $cGot != "" or $nPumps > 300
			$oRs3.StopAllTimers()
		ok
	})
	$oRs3.RunLoop()
	Then("the async response arrived through the callback", $cGot, "pong")
	$oSrv.Stop()
	$oRs3.Stop()
EndScenario()

Scenario("a reactive object composes the engine (F3 untangle) and debounces")
	Given("a reactive object with a 50ms settle watcher on :query")
	$oRs4 = new stzReactive()
	$oX = $oRs4.ReactiveObject()
	$nSettled = 0
	$oX.WaitForAttributetoSettle("query", 50, func(attr, oldV, newV) {
		$nSettled++
	})
	When("the attribute changes three times in quick succession")
	$oX.SetAttribute("query", "s")
	$oX.SetAttribute("query", "so")
	$oX.SetAttribute("query", "sof")
	$oX { ProcessPendingReactions() }
	When("the loop runs the settle window out")
	$oRs4.RunLoop()
	Then("the settle callback fired exactly once", $nSettled, 1)
	$oRs4.Stop()
EndScenario()

Scenario("teardown: stopping a system releases its reactor loop")
	Given("the first system of this suite")
	$oRs.Stop()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
