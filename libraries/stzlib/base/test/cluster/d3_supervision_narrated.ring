# DISTRIBUTION D3 -- supervision: declared restart strategies, a counted
# budget that ESCALATES instead of looping, monitors, and heartbeat
# liveness that catches the failure mode process-exit cannot: the WEDGED
# node (alive, unresponsive).
#
# Everything here is proven against REAL child processes killed for
# real, and restarts are proven by STATE, not by counters alone:
# :OneForOne leaves the sibling's accumulated state intact; :AllForOne
# wipes it (a fresh process has no memory). The plan's D3 scene --
# "kill a child mid-conversation" -- is the first scenario: the
# in-flight Ask fails plainly (at-most-once, no ghost reply), and the
# supervisor restarts the child within the declared window.

load "../../stzBase.ring"
load "../_narrated.ring"

$oPause = new stzReactor()
$oSpawner = new stzReactor()

nBase = 46100 + (StzEngineTimeNowMs() % 200)
$nPortW1 = nBase
$nPortW2 = nBase + 1
$nPortWatch = nBase + 2
$nPortW3 = nBase + 3
$nPortW4 = nBase + 4
$nPortW5 = nBase + 5
$nPortW6 = nBase + 6

# the watcher is a PLAIN node (not supervised): it subscribes to deaths
cExe = D3RingExe()
nJobWatch = $oSpawner.SubmitSpawn([ cExe, "_d3_worker.ring", "" + $nPortWatch ])
NodeRegister("watcher", "127.0.0.1", $nPortWatch)

Scenario(":OneForOne -- a killed child restarts; its sibling is untouched")
	Given("a supervisor with two children, OneForOne, budget 5 per 30 s")
	oSup = new stzNodeSupervisor()
	oSup.Child("w1", "_d3_worker.ring", $nPortW1)
	oSup.Child("w2", "_d3_worker.ring", $nPortW2)
	oSup.Strategy(:OneForOne)
	oSup.RestartBudget(5, 30000)
	oSup.Monitor("w1", "watcher")
	oSup.StartAll()
	Then("both children answer after boot",
		D3AwaitBoot("w1", 15000) and D3AwaitBoot("w2", 15000), TRUE)
	Given("state accumulated in the SIBLING (seq 1 into w2)")
	Send("w2", [ "seq", 1 ])
	When("w1 is killed MID-CONVERSATION (boom, then an immediate Ask)")
	Send("w1", [ "boom" ])
	vR = Ask("w1", [ "ping", 1 ], 1500)
	Then("the in-flight Ask fails plainly -- no ghost reply",
		NodeAskStatus() != :Ok, TRUE)
	When("the supervisor runs its cycles")
	nT0 = StzEngineWatchTimestampMs()
	bRestarted = D3DriveUntil(oSup, "w1", 1, 20000)
	Then("the restart happened and was COUNTED (exactly 1)",
		oSup.RestartsOf("w1"), 1)
	Then("the restarted child answers again",
		D3AwaitBoot("w1", 15000), TRUE)
	nT1 = StzEngineWatchTimestampMs()
	? "  [measure] death -> answering again in " + (nT1 - nT0) + " ms"
	Then("within the declared 20 s window", nT1 - nT0 < 20000, TRUE)
	Then("the sibling was NOT restarted", oSup.RestartsOf("w2"), 0)
	vSeq = Ask("w2", [ "drain" ], 3000)
	Then("the sibling KEPT its state (OneForOne left it alone)",
		D3PackEq(vSeq, [ 1 ]), TRUE)
	When("the watcher is asked what it observed")
	vDowns = Ask("watcher", [ "downs" ], 3000)
	Then("exactly one death notice arrived for w1",
		D3PackEq(vDowns, [ [ "w1", 0 ] ]), TRUE)
	oSup.Destroy()
EndScenario()

Scenario(":AllForOne -- one death restarts EVERY child (state proves it)")
	Given("a supervisor with two children, AllForOne")
	oSup = new stzNodeSupervisor()
	oSup.Child("w3", "_d3_worker.ring", $nPortW3)
	oSup.Child("w4", "_d3_worker.ring", $nPortW4)
	oSup.Strategy(:AllForOne)
	oSup.RestartBudget(5, 30000)
	oSup.StartAll()
	Then("both children answer after boot",
		D3AwaitBoot("w3", 15000) and D3AwaitBoot("w4", 15000), TRUE)
	Given("state accumulated in the sibling (seq 9 into w4)")
	Send("w4", [ "seq", 9 ])
	vSeq = Ask("w4", [ "drain" ], 3000)
	Then("the sibling really held it", D3PackEq(vSeq, [ 9 ]), TRUE)
	When("w3 is killed and the supervisor runs its cycles")
	Send("w3", [ "boom" ])
	D3DriveUntil(oSup, "w3", 1, 20000)
	Then("w3's restart was counted", oSup.RestartsOf("w3"), 1)
	Then("w4 was restarted TOO", oSup.RestartsOf("w4"), 1)
	Then("both answer again",
		D3AwaitBoot("w3", 15000) and D3AwaitBoot("w4", 15000), TRUE)
	vSeq = Ask("w4", [ "drain" ], 3000)
	Then("the sibling's state is GONE -- a fresh process has no memory",
		D3PackEq(vSeq, []), TRUE)
	oSup.Destroy()
EndScenario()

Scenario("beyond the budget the supervisor ESCALATES -- it never loops")
	Given("one child under a budget of 2 restarts per 30 s")
	oSup = new stzNodeSupervisor()
	oSup.Child("w5", "_d3_worker.ring", $nPortW5)
	oSup.Strategy(:OneForOne)
	oSup.RestartBudget(2, 30000)
	oSup.StartAll()
	Then("the child answers after boot", D3AwaitBoot("w5", 15000), TRUE)
	When("it is killed three times in a row")
	Send("w5", [ "boom" ])
	D3DriveUntil(oSup, "w5", 1, 20000)
	D3AwaitBoot("w5", 15000)
	Send("w5", [ "boom" ])
	D3DriveUntil(oSup, "w5", 2, 20000)
	D3AwaitBoot("w5", 15000)
	Send("w5", [ "boom" ])
	D3DriveEscalation(oSup, 20000)
	Then("the supervisor ESCALATED", oSup.Escalated(), TRUE)
	Then("only the budgeted 2 restarts ever happened", oSup.RestartsOf("w5"), 2)
	Then("the reason names the child",
		StzFindFirst("w5", oSup.EscalationReason()) > 0, TRUE)
	When("more cycles run after escalation")
	oSup.Cycle()
	oSup.Cycle()
	Then("nothing restarts -- it reported and stopped", oSup.RestartsOf("w5"), 2)
	Ask("w5", [ "ping", 1 ], 1500)
	Then("the child stays down, observably", NodeAskStatus() != :Ok, TRUE)
	oSup.Destroy()
EndScenario()

Scenario("heartbeats catch the WEDGED node that process-exit cannot")
	Given("one child with heartbeat every 300 ms, tolerance 2")
	oSup = new stzNodeSupervisor()
	oSup.Child("w6", "_d3_worker.ring", $nPortW6)
	oSup.Strategy(:OneForOne)
	oSup.RestartBudget(3, 30000)
	oSup.Heartbeat(300, 2)
	oSup.StartAll()
	Then("the child answers after boot", D3AwaitBoot("w6", 15000), TRUE)
	When("the child WEDGES (alive, unresponsive -- no exit to detect)")
	Send("w6", [ "wedge" ])
	nT0 = StzEngineWatchTimestampMs()
	D3DriveUntil(oSup, "w6", 1, 25000)
	Then("the heartbeat verdict killed and restarted it (counted)",
		oSup.RestartsOf("w6"), 1)
	Then("the restarted child answers again", D3AwaitBoot("w6", 15000), TRUE)
	nT1 = StzEngineWatchTimestampMs()
	? "  [measure] wedge -> answering again in " + (nT1 - nT0) + " ms"
	oSup.Destroy()
EndScenario()

Scenario("teardown")
	Given("the watcher node")
	Send("watcher", [ "stz.stop" ])
	cW = $oSpawner.AwaitSpawn(nJobWatch, 8000)
	Then("the watcher stopped cleanly",
		StzFindFirst("d3-worker: done", cW) > 0, TRUE)
	StzNodePlane().Destroy()
	$oSpawner.Destroy()
	$oPause.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- helpers ---------------------------------------------------------

func D3RingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

func D3AwaitBoot(cAddr, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		Ask(cAddr, [ "ping", 0 ], 1000)
		if NodeAskStatus() = :Ok
			return TRUE
		ok
	end
	return FALSE

# Drive supervision cycles until a child's restart count reaches nWant.
func D3DriveUntil(oSup, cChild, nWant, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		oSup.Cycle()
		if oSup.RestartsOf(cChild) >= nWant
			return TRUE
		ok
		_nT_ = $oPause.SubmitTimer(100)
		$oPause.AwaitTimer(_nT_, 500)
	end
	return FALSE

func D3DriveEscalation(oSup, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		oSup.Cycle()
		if oSup.Escalated()
			return TRUE
		ok
		_nT_ = $oPause.SubmitTimer(100)
		$oPause.AwaitTimer(_nT_, 500)
	end
	return FALSE

func D3PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)
