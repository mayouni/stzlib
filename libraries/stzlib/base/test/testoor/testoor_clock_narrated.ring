load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR TR4 -- THE CLOCK THAT RUNS BACKWARDS, AND THE WEATHER. A failing
# tour prints its seed, and the same seed walks the same path. The clock is
# the tour's to move; the weather is declared, never ambient; a tour that
# says different things under one seed is FLAKY, and flaky is a latency defect.
#
# WHAT IS PLANTED. Tours in _planted_clock/ (git ignores it; removed at the
# end). The seed tour is VM-independent on purpose: it fails exactly when its
# draw equals the draw seed 42 produces, so it fails at 42 and passes at 43
# whichever VM walks it (Ring's and Ring++'s generators differ). The flaky
# tour reads and writes a marker file: its first walk fails and its second
# passes, which is what an ambient fact looks like from outside.
#
# WHAT IS REAL. The weather on the distribution plane is the platform's own:
# a real stzNodeSupervisor, a real worker (test/cluster/_d3_worker.ring, used
# read-only), the supervisor's own KillChild, and its own restart counted.
# No mock stands in for it (ruling 13).
#
# Every positive has its sibling: seed 42 fails and 43 passes; a stable tour
# walked twice is NOT flaky; a stepped clock refuses a tick it was not
# given; an unknown weather is refused; weather fires once.

? "TESTOOR TR4 -- the clock and the weather"
nTcStart = clock()
cTcHere = currentdir()
cTcPlant = cTcHere + "/_planted_clock"
_TcPlantAll(cTcPlant)

#============================================================================
Scenario("The stepped clock moves only when the tour moves it, and replays identically")
	nTcSec = clock()
	Given("a stepped clock starting at 1000 ms, 250 ms a tick")
	TestoorReset()
	ClockTo(:stepped, [ 1000, 250 ])
	aRunA = [ ClockNow() ]
	ClockTick()
	aRunA + ClockNow()
	ClockAdvance(750)
	aRunA + ClockNow()
	ClockTick()
	aRunA + ClockNow()
	Then("it starts where it was told", aRunA[1], 1000)
	Then("a tick adds its step", aRunA[2], 1250)
	Then("ClockAdvance adds what it is given", aRunA[3], 2000)
	Then("and a tick after that adds the step again", aRunA[4], 2250)
	Then("two ticks have passed", ClockTicks(), 2)
	Then("the clock did not move by itself while the tour did other things",
		ClockNow() = aRunA[4], TRUE)
	Given("the same tour walked again from a reset")
	TestoorReset()
	ClockTo(:stepped, [ 1000, 250 ])
	aRunB = [ ClockNow() ]
	ClockTick()
	aRunB + ClockNow()
	ClockAdvance(750)
	aRunB + ClockNow()
	ClockTick()
	aRunB + ClockNow()
	Then("it reads the same four times", _TcJoin(aRunB), _TcJoin(aRunA))
	Given("a clock that is not stepped")
	TestoorReset()
	bRefused = 0
	try
		ClockTick()
	catch
		bRefused = 1
	done
	Then("a tick on it is refused: the tour is not driving the time", bRefused, 1)
	Given("the wall clock frozen, then thawed")
	ClockTo(:frozen, "2025-09-27 14:30:25")
	Then("the library's clock reads the frozen instant", StzFindFirst("27/09/2025 14:30:25", "" + StzNow()) > 0, TRUE)
	ClockTo(:live, "")
	Then("and reads today again once thawed", StzFindFirst("27/09/2025 14:30:25", "" + StzNow()) = 0, TRUE)
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nTcSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A seed replays the same draws; weather is declared and falls due once")
	nTcSec = clock()
	Given("seed 42 drawn twice and seed 43 once")
	TestoorReset()
	Seed(42)
	aD42a = [ random(1000), random(1000), random(1000) ]
	Seed(42)
	aD42b = [ random(1000), random(1000), random(1000) ]
	Seed(43)
	aD43 = [ random(1000), random(1000), random(1000) ]
	Then("the same seed draws the same numbers", _TcJoin(aD42b), _TcJoin(aD42a))
	Then("another seed draws other numbers", _TcJoin(aD43) != _TcJoin(aD42a), TRUE)
	Given("a child_killed weather without a tick, declared under seed 42 twice")
	TestoorReset()
	Seed(42)
	nT1 = Weather(:child_killed, [ "w1" ])
	TestoorReset()
	Seed(42)
	nT2 = Weather(:child_killed, [ "w1" ])
	Then("the seeded generator picks the same tick", nT1, nT2)
	Then("one of the first six", nT1 >= 1 and nT1 <= 6, TRUE)
	Given("weather declared for tick 3 on a stepped clock")
	TestoorReset()
	ClockTo(:stepped, [ 0, 100 ])
	Weather(:child_killed, [ "w1", 3 ])
	Then("it is planned, not yet fallen due", len(WeatherPlan()), 1)
	Then("and declared by name", WeatherDeclared()[1], "child_killed")
	aT1 = ClockTick()
	aT2 = ClockTick()
	Then("nothing falls due at ticks 1 and 2", len(aT1) + len(aT2), 0)
	aT3 = ClockTick()
	Then("it falls due at tick 3", len(aT3), 1)
	Then("named, with its spec", aT3[1][1] + "/" + aT3[1][2][1], "child_killed/w1")
	aT4 = ClockTick()
	Then("and only once", len(aT4), 0)
	Then("nothing is left planned", len(WeatherPlan()), 0)
	Given("a weather nobody has heard of")
	bUnknown = 0
	try
		Weather(:locusts, [ 1 ])
	catch
		bUnknown = 1
	done
	Then("it is refused: weather is declared from a known list", bUnknown, 1)
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nTcSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A tour seeded to fail at 42 fails identically twice, and passes at 43")
	nTcSec = clock()
	Given("a planted tour that fails exactly when its draw equals seed 42's draw")
	oA = TravellerQ().Silent().Timeout(60000).Seed(42).Walk(cTcPlant + "/seeded_fail.ring")
	oB = TravellerQ().Silent().Timeout(60000).Seed(42).Walk(cTcPlant + "/seeded_fail.ring")
	aA = oA.Records()[1]
	aB = oB.Records()[1]
	Then("the first walk fails", aA[:run][:state], "diverged")
	Then("the second walk fails", aB[:run][:state], "diverged")
	Then("identically: the same signature", _TravSignature(aA), _TravSignature(aB))
	Then("the same draw was printed both times", _TcDrawOf(aA), _TcDrawOf(aB))
	Then("and a draw WAS printed", _TcDrawOf(aA) != "", TRUE)
	Then("the record carries the seed", aA[:run][:seed], 42)
	Then("the failing tour's prose prints its seed", StzFindFirst("seed 42", _TravRunProse(aA)) > 0, TRUE)
	Then("and so does the JSON", StzFindFirst('"seed":42', oA.Json()) > 0, TRUE)
	Then("the tour itself printed the seed it adopted", _TcHasLine(aA, "[testoor seed 42]"), TRUE)
	Then("the runner exits 1", oA.ExitCode(), 1)
	Given("the same tour walked with seed 43")
	oC = TravellerQ().Silent().Timeout(60000).Seed(43).Walk(cTcPlant + "/seeded_fail.ring")
	aC = oC.Records()[1]
	Then("its one printed claim is kept", aC[:run][:kept], 1)
	Then("nothing diverged: the claim in the branch not taken is unjudged, not a failure", "" + aC[:run][:diverged] + "/" + aC[:run][:unjudged], "0/1")
	Then("with another draw", _TcDrawOf(aC) != _TcDrawOf(aA), TRUE)
	Then("the runner exits 0", oC.ExitCode(), 0)
	Then("a kept tour does not shout its seed", StzFindFirst("seed 43", _TravRunProse(aC)), 0)
	Given("a tour that names its own seed under a runner that offers another")
	oD = TravellerQ().Silent().Timeout(60000).Seed(42).Walk(cTcPlant + "/own_seed.ring")
	Then("the seed the tour named is the one recorded", oD.Records()[1][:run][:seed], 7)
	Given("a runner that was given no seed")
	oE = TravellerQ().Silent().Timeout(60000).Walk(cTcPlant + "/stable.ring")
	Then("chose one and REPORTED it, so the run can be walked again", oE.SeedUsed() >= 1, TRUE)
	Then("in the JSON", StzFindFirst('"seed":' + oE.SeedUsed(), oE.Json()) > 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTcSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Undeclared weather is reported flaky; a stable tour is not; declared weather is named")
	nTcSec = clock()
	_TcClearMarkers(cTcPlant)
	Given("a tour whose verdict depends on a file it leaves behind, walked twice with one seed")
	oF = TravellerQ().Silent().Timeout(60000).Seed(5).Repeat(2).Walk(cTcPlant + "/flaky_undeclared.ring")
	aF = oF.Records()[1]
	Then("it is FLAKY", aF[:flaky], 1)
	Then("the court says so, as an error", len(oF.Findings()), 1)
	Then("under the rule tour_is_flaky", "" + oF.Findings()[1][:rule], "tour_is_flaky")
	Then("severity error", "" + oF.Findings()[1][:severity], "error")
	Then("naming undeclared weather", StzFindFirst("undeclared weather", oF.Findings()[1][:message]) > 0, TRUE)
	Then("and the walk that differed", StzFindFirst("both with seed 5", aF[:flaky_why]) > 0, TRUE)
	Then("the runner exits 1", oF.ExitCode(), 1)
	Then("the prose says FLAKY and the seed", StzFindFirst("FLAKY", _TravRunProse(aF)) > 0 and StzFindFirst("seed 5", _TravRunProse(aF)) > 0, TRUE)
	_TcClearMarkers(cTcPlant)
	Given("the same tour walked ONCE")
	oG = TravellerQ().Silent().Timeout(60000).Seed(5).Walk(cTcPlant + "/flaky_undeclared.ring")
	Then("one walk cannot see flakiness: it is merely diverged", oG.Records()[1][:flaky] = 0 and oG.Records()[1][:run][:state] = "diverged", TRUE)
	_TcClearMarkers(cTcPlant)
	Given("a stable tour walked twice")
	oH = TravellerQ().Silent().Timeout(60000).Seed(5).Repeat(2).Walk(cTcPlant + "/stable.ring")
	Then("it is not flaky", oH.Records()[1][:flaky], 0)
	Then("and the court is silent", len(oH.Findings()), 0)
	Then("and the runner exits 0", oH.ExitCode(), 0)
	Given("a tour that DECLARED its weather and is still flaky")
	oJ = TravellerQ().Silent().Timeout(60000).Seed(5).Repeat(2).Walk(cTcPlant + "/flaky_declared.ring")
	aJ = oJ.Records()[1]
	Then("it is flaky", aJ[:flaky], 1)
	Then("the weather it declared is in the logbook", len(aJ[:weather]) >= 1, TRUE)
	Then("by name", StzFindFirst("skew", aJ[:weather][1]) > 0, TRUE)
	Then("and the court says the declared weather did not pin it", StzFindFirst("declared weather did not pin it", oJ.Findings()[1][:message]) > 0, TRUE)
	_TcClearMarkers(cTcPlant)
EndScenario()
? "        [section took " + ((clock() - nTcSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The weather on the distribution plane: a supervised child dies at the declared tick, and the supervisor restarts it")
	nTcSec = clock()
	Given("a real stzNodeSupervisor with one real worker, OneForOne")
	nPort = 46500 + (StzEngineTimeNowMs() % 200)
	oSup = new stzNodeSupervisor()
	oSup.Child("w1", "../cluster/_d3_worker.ring", nPort)
	oSup.Strategy(:OneForOne)
	oSup.RestartBudget(5, 30000)
	oSup.StartAll()
	Then("the worker answers after boot", _TcAwaitPong("w1", 40000), TRUE)
	TestoorReset()
	ClockTo(:stepped, [ 0, 100 ])
	Seed(42)
	nPlanned = Weather(:child_killed, [ "w1", 2 ])
	Then("the weather is declared for tick 2", nPlanned, 2)
	Then("no restart has happened yet", oSup.RestartsOf("w1"), 0)
	When("the tour takes tick 1")
	aF1 = ClockTick()
	Then("nothing falls due", len(aF1), 0)
	Then("the worker still answers", _TcPong("w1"), TRUE)
	When("the tour takes tick 2")
	aF2 = ClockTick()
	Then("the weather falls due", len(aF2), 1)
	nKilled = WeatherKill(oSup, aF2)
	Then("and the platform's own KillChild killed one child", nKilled, 1)
	Given("the supervisor's own cycles, driven until it has restarted the child")
	bRestarted = _TcDriveUntil(oSup, "w1", 1, 30000)
	Then("the restart happened", bRestarted, TRUE)
	Then("and was COUNTED, exactly once", oSup.RestartsOf("w1"), 1)
	Then("the restarted worker answers again", _TcAwaitPong("w1", 40000), TRUE)
	oSup.StopAll()
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nTcSec) / clockspersecond()) + "s]"

_TcUnplantAll(cTcPlant)
? ""
? "[TR4 took " + ((clock() - nTcStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _TcPlantAll(cRoot)
	_TcUnplantAll(cRoot)
	StzMakeDir(cRoot)
	_nl_ = char(10)
	write(cRoot + "/seeded_fail.ring",
		'load "../../../stzBase.ring"' + _nl_ +
		"Seed(:run)" + _nl_ +
		"nDraw = random(1000)" + _nl_ +
		"SeedRandom(42)" + _nl_ +
		"nRef = random(1000)" + _nl_ +
		'? "draw " + nDraw' + _nl_ +
		"if nDraw = nRef" + _nl_ +
		'	? "  [FAIL] the draw hit the value seed 42 produces"' + _nl_ +
		"else" + _nl_ +
		'	? "  [OK] the draw avoided the value seed 42 produces"' + _nl_ +
		"ok" + _nl_)
	write(cRoot + "/own_seed.ring",
		'load "../../../stzBase.ring"' + _nl_ +
		"Seed(7)" + _nl_ +
		'? "  [OK] seeded by the tour itself"' + _nl_)
	write(cRoot + "/stable.ring", '? "  [OK] the same every time"' + _nl_)
	write(cRoot + "/flaky_undeclared.ring",
		'cM = "flaky_marker_undeclared.txt"' + _nl_ +
		"if fexists(cM)" + _nl_ +
		'	? "  [OK] second time lucky"' + _nl_ +
		"else" + _nl_ +
		'	write(cM, "1")' + _nl_ +
		'	? "  [FAIL] first time unlucky"' + _nl_ +
		"ok" + _nl_)
	write(cRoot + "/flaky_declared.ring",
		'load "../../../stzBase.ring"' + _nl_ +
		"Seed(:run)" + _nl_ +
		"ClockTo(:stepped, [ 0, 100 ])" + _nl_ +
		"Weather(:skew, [ 500 ])" + _nl_ +
		'cM = "flaky_marker_declared.txt"' + _nl_ +
		"if fexists(cM)" + _nl_ +
		'	? "  [OK] second time lucky"' + _nl_ +
		"else" + _nl_ +
		'	write(cM, "1")' + _nl_ +
		'	? "  [FAIL] first time unlucky"' + _nl_ +
		"ok" + _nl_)

func _TcClearMarkers(cRoot)
	for cF in [ "/flaky_marker_undeclared.txt", "/flaky_marker_declared.txt" ]
		if fexists(cRoot + cF)  remove(cRoot + cF)  ok
	next

func _TcUnplantAll(cRoot)
	if fexists(cRoot + "/stable.ring")
		StzDirDeleteAll(cRoot)
	ok

func _TcJoin(aList)
	c = ""
	n = len(aList)
	for i = 1 to n
		c += "" + aList[i] + ","
	next
	return c

# the "draw N" line a planted tour printed, or ""
func _TcDrawOf(aRec)
	nL = len(aRec[:output])
	for i = 1 to nL
		if left(trim(aRec[:output][i][1]), 5) = "draw "  return trim(aRec[:output][i][1])  ok
	next
	return ""

func _TcHasLine(aRec, cLine)
	nL = len(aRec[:output])
	for i = 1 to nL
		if trim(aRec[:output][i][1]) = cLine  return TRUE  ok
	next
	return FALSE

func _TcPong(cChild)
	vR = Ask(cChild, [ "ping", 1 ], 1500)
	return NodeAskStatus() = :Ok

func _TcAwaitPong(cChild, nMaxMs)
	nT0 = StzEngineWatchTimestampMs()
	while StzEngineWatchTimestampMs() - nT0 < nMaxMs
		if _TcPong(cChild)  return TRUE  ok
		nW = clock()
		while (clock() - nW) / clockspersecond() < 0.3  end
	end
	return FALSE

func _TcDriveUntil(oSup, cChild, nRestarts, nMaxMs)
	nT0 = StzEngineWatchTimestampMs()
	while StzEngineWatchTimestampMs() - nT0 < nMaxMs
		oSup.Cycle()
		if oSup.RestartsOf(cChild) >= nRestarts  return TRUE  ok
		nW = clock()
		while (clock() - nW) / clockspersecond() < 0.1  end
	end
	return FALSE
