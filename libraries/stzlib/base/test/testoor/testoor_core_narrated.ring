load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P3.1 -- THE ZIG CORE BESIDE THE RING REFERENCE, in one process.
#
# The judge is written in Zig (engine/src/testoor_*.zig, the stz_testoor library) and the Ring
# files in base/testoor are its reference. engine's own test (`zig build test-testoor`) holds
# the core to the golden logbooks with no Ring involved; THIS guard holds the two together
# through the seam Testoor actually uses: TestoorVerdict, asked of one and then of the other,
# must write the same bytes for every golden tour, for a live-shaped tour the goldens do not
# contain, and the run-level calls the Ring runner would make must give the committed logbooks.
#
# It also pins the one place the core and the reference are SUPPOSED to differ: a tour that
# prints a seed or a plan that is not a number makes the reference raise (R41, measured on Ring
# 1.27 and on Ring++) and the core ignore the line and judge the rest.
#
# P3.2 adds the WORLD of a tour -- its seed, its stepped clock, its weather (stzClock.ring, owned by
# engine/src/testoor_clock.zig): one script of calls is walked on the reference and then on the core and
# the two transcripts must be the same bytes; and the three differences the core is ALLOWED are each
# pinned: a weather's tick is picked from the SEED (portable) and not from Ring's rand(), the stepped
# clock and the weather want numbers, and a runner seed that is not a number is no seed.
#
# A machine without the core library (Ring 1.27 with no engine build) runs the first section
# only and says, by name, what it did not run.

? "TESTOOR P3.1 + P3.2 -- the core beside the reference"
nCoStart = clock()
cCoRoot = currentdir() + "/../../testoor/golden"
bCoLoaded = $bStzTestoorCore

#============================================================================
Scenario("The judge is chosen, and a machine without the core falls back to the reference")
	nCoSec = clock()
	Given("TestoorCore(ring)")
	Then("the Ring reference judges", TestoorCore("ring"), "ring")
	When("TestoorCore(auto) is asked")
	cCoWant = "ring"
	if bCoLoaded and sysget("TESTOOR_CORE") != "ring"  cCoWant = "engine"  ok
	Then("the core judges exactly when its library is loaded", TestoorCore("auto"), cCoWant)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

if NOT bCoLoaded
	? ""
	? "SKIPPED by name, because stz_testoor is not loaded on this virtual machine:"
	? "  every core-versus-reference section (golden tours, run-level calls, live-shaped tour, bad requests, deviations, the world of a tour)"
else

#============================================================================
Scenario("Every golden tour: the core and the reference write the same bytes")
	nCoSec = clock()
	acCoCases = _GoldenCases(cCoRoot + "/judge")
	Given("the " + len(acCoCases) + " committed tours, judged once by each")
	nCoDiff = 0
	for nCo = 1 to len(acCoCases)
		TestoorCore("ring")
		aCoRef = TestoorGoldenVerdict(cCoRoot + "/judge/" + acCoCases[nCo])
		cCoRef = _TravRunJson(aCoRef) + char(10) + _TravRunProse(aCoRef)
		TestoorCore("engine")
		aCoEng = TestoorGoldenVerdict(cCoRoot + "/judge/" + acCoCases[nCo])
		cCoEng = _TravRunJson(aCoEng) + char(10) + _TravRunProse(aCoEng)
		if cCoRef != cCoEng
			nCoDiff++
			? "        DIFFERS: " + acCoCases[nCo]
		ok
	next
	Then("there are at least fourteen", len(acCoCases) >= 14, TRUE)
	Then("and not one differs, in JSON or in prose", nCoDiff, 0)
	Then("the engine library is the one answering: an empty run request comes back as a logbook", left(StzEngineTestoorRunJson('{"run":{},"tours":[]}'), 19), '{"testoor":"logbook')
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The run-level calls give the committed logbooks")
	nCoSec = clock()
	acCoRuns = _GoldenCases(cCoRoot + "/logbook")
	Given("the " + len(acCoRuns) + " committed runs, their tours written by the reference")
	TestoorCore("ring")
	nCoBad = 0
	for nCo = 1 to len(acCoRuns)
		cCoReq = _CoRunRequest(cCoRoot + "/logbook/" + acCoRuns[nCo], cCoRoot + "/judge")
		cCoDir = cCoRoot + "/logbook/" + acCoRuns[nCo]
		cWantJson = TestoorGoldenRead(cCoDir + "/expected.json")
		cWantTxt = TestoorGoldenRead(cCoDir + "/expected.txt")
		cWantExit = TestoorGoldenRead(cCoDir + "/expected.exit")
		if StzEngineTestoorRunJson(cCoReq) + char(10) != cWantJson
			nCoBad++
			? "        DIFFERS: " + acCoRuns[nCo] + " json"
		ok
		if StzEngineTestoorRunProse(cCoReq) + char(10) != cWantTxt
			nCoBad++
			? "        DIFFERS: " + acCoRuns[nCo] + " prose"
		ok
		if "" + StzEngineTestoorRunExit(cCoReq) + char(10) != cWantExit
			nCoBad++
			? "        DIFFERS: " + acCoRuns[nCo] + " exit"
		ok
	next
	Then("the core writes every committed logbook, its prose and its exit code", nCoBad, 0)
	When("the whole golden set is regenerated with the core judging")
	TestoorCore("engine")
	acCoDiff = TestoorGoldenDiff(cCoRoot)
	for nCo = 1 to len(acCoDiff)
		? "        DIFFERS: " + acCoDiff[nCo]
	next
	Then("not one expected file differs: the Ring runner on the core reproduces the goldens", len(acCoDiff), 0)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A live-shaped tour the goldens do not hold: a raw control byte, a carriage return inside a line")
	nCoSec = clock()
	Given("a tour that printed an escape sequence and a progress line")
	aCoLive = _CoLiveRecord()
	aCoLines = [ [ "Live", 0.25 ], [ "  [OK] plain", 0.5 ],
	             [ "  [OK] colour " + char(27) + "[0m done", 0.75 ],
	             [ "progress 50%" + char(13) + "progress 100%", 1 ], [ "  [FAIL] last", 1.25 ] ]
	aCoFace = [ :name = "ring", :ext = "", :reader = "", :program = "", :launch = [], :ignore = "eval ",
	            :endings = [ [ "STOPPED!", "finished-timed" ] ] ]
	When("the reference judges it")
	aCoR = _TestoorVerdictRing(aCoLive, aCoLines, "", 0, 0, aCoFace, 1500, 7)
	cCoR = _TravRunJson(aCoR)
	When("the core judges the same request")
	cCoReq = '{"record":' + _CoreRecordJson(aCoLive) + ',"output":' + _CoreLinesJson(aCoLines) +
	         ',"meta":' + _CoreMetaJson("", 0, 0, aCoFace, 1500, 7) + "}"
	cCoE = StzEngineTestoorVerdict(cCoReq)
	Then("the two JSON documents are the same bytes, raw control byte and all", cCoE, cCoR)
	Then("and the wrapper stays whole: it falls back to the reference for what the library's JSON reader refuses",
	     _TravRunJson(TestoorVerdict(aCoLive, aCoLines, "", 0, 0, aCoFace, 1500, 7)), cCoR)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A request the core cannot read raises a Ring error and breaks nothing")
	nCoSec = clock()
	nCoRaised = 0
	try
		StzEngineTestoorVerdict("this is not json")
	catch
		nCoRaised = 1
	done
	Then("a request that is not JSON raises", nCoRaised, 1)
	nCoRaised = 0
	try
		StzEngineTestoorVerdict('{"record":{}}')
	catch
		nCoRaised = 1
	done
	Then("a request missing a field raises", nCoRaised, 1)
	nCoRaised = 0
	try
		StzEngineTestoorRunExit('{"tours":[]}')
	catch
		nCoRaised = 1
	done
	Then("a run request with no run settings raises", nCoRaised, 1)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The one deviation: a seed or a plan that is not a number")
	nCoSec = clock()
	Given("a self-describing tour that prints a stop, a claim kept, then a seed and a plan that are words")
	aCoP = [ :file = "tour.py", :readable = 1, :why = "", :dialect = "protocol", :helpers = [], :lines = 0,
	         :ending = "plain", :asserts = 0, :promises = 0, :markers = 0, :stops = [], :routes = [] ]
	aCoPL = [ [ "[testoor stop First]", 0.25 ], [ "[testoor ok it holds]", 0.5 ],
	          [ "[testoor seed abc]", 0.75 ], [ "[testoor plan many]", 1 ] ]
	aCoPF = [ :name = "python", :ext = "", :reader = "", :program = "", :launch = [], :ignore = "", :endings = [] ]
	nCoRaised = 0
	try
		_TestoorVerdictRing(aCoP, aCoPL, "", 0, 0, aCoPF, 1000, 9)
	catch
		nCoRaised = 1
	done
	Then("the reference raises on it (R41, Invalid numeric string)", nCoRaised, 1)
	aCoCore = _CoreVerdict(aCoP, aCoPL, "", 0, 0, aCoPF, 1000, 9)
	Then("the core answers a record", isList(aCoCore), TRUE)
	Then("ignores both lines and judges the rest: one claim kept", aCoCore[:run][:kept], 1)
	Then("keeps the runner's seed, since the tour's was not a number", aCoCore[:run][:seed], 9)
	Then("and is finished", aCoCore[:run][:end], "finished")
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("P3.2 -- the world of a tour: the core and the reference answer the same script the same way")
	nCoSec = clock()
	Given("one script of clock, seed and weather calls, walked on the reference and then on the core")
	TestoorCore("ring")
	cCoWorldRef = _CoWorldScript()
	Then("with the reference the world is held in Ring", _TestoorWorldIsEngine(), FALSE)
	TestoorCore("engine")
	Then("with the core the world is held in the engine: the library answers the world call", _TestoorWorldIsEngine(), TRUE)
	cCoWorldEng = _CoWorldScript()
	Then("the two transcripts are the same bytes", cCoWorldEng, cCoWorldRef)
	Then("and say what the script did: refusals, the stepped times, the weather fired once, the plan that is left",
	     cCoWorldEng,
	     "mode=live|tick-live=1|advance-live=1|skew-live=1|unknown-weather=1|unknown-mode=1|seed=42|clock=stepped|0=1000|1=1250|2=2000|3=2250|ticks=2|" +
	     "w1=5|w2=3|skew=0|now=2750|declared=child_killed,child_killed,skew|plan=child_killed/5,child_killed/3,skew/0|" +
	     "t3=child_killed/w2|t4=-|t5=child_killed/w1|plan-after=skew/0|now-after=3500|" +
	     "restart=stepped|declared-after-restart=skew|ticks-after-restart=0|now-after-restart=0|frozen=frozen|live=live|reset-declared=|")
	Given("TestoorDrawSeed and a runner's seed text, on each")
	TestoorCore("ring")
	nCoDrawRef = TestoorDrawSeed()
	TestoorCore("engine")
	nCoDrawEng = TestoorDrawSeed()
	Then("the reference draws a seed from 1 to 90000", nCoDrawRef >= 1 and nCoDrawRef <= 90000, TRUE)
	Then("so does the core", nCoDrawEng >= 1 and nCoDrawEng <= 90000, TRUE)
	Then("the runner's seed text 42 is adopted", 0 + StzEngineTestoorWorld("seedrun", "42", 5, 0), 42)
	Then("and a seed of 0 is a seed", 0 + StzEngineTestoorWorld("seedrun", "0", 5, 0), 0)
	TestoorReset()
	When("choosing who runs the world is done with weather declared")
	TestoorCore("engine")
	ClockTo(:stepped, [ 0, 100 ])
	Weather(:child_killed, [ "w1", 3 ])
	Then("the world holds it", len(WeatherDeclared()), 1)
	TestoorCore("ring")
	Then("choosing again forgets it, so nothing is left behind in the other place", len(WeatherDeclared()), 0)
	TestoorCore("engine")
	Then("and the other place has none either", len(WeatherDeclared()), 0)
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("P3.2 -- the differences the world is allowed, each one pinned")
	nCoSec = clock()
	Given("a weather with no tick, declared under seeds 42, 43 and 7")
	TestoorCore("engine")
	Then("the core picks 2, 5 and 3 -- the same on every machine, and pinned in the Zig tests too",
	     "" + _CoPick(42) + "," + _CoPick(43) + "," + _CoPick(7), "2,5,3")
	Then("the same seed picks the same tick twice", _CoPick(42), _CoPick(42))
	TestoorCore("ring")
	nCoPickRef = _CoPick(42)
	Then("the reference picks one of the first six too, from Ring's own generator, which differs by machine",
	     nCoPickRef >= 1 and nCoPickRef <= 6, TRUE)
	Then("and the same seed picks it twice on this machine", _CoPick(42), nCoPickRef)
	Given("a tour that draws between seeding and declaring")
	TestoorCore("engine")
	TestoorReset()
	Seed(42)
	nCoNoise = random(1000) + random(1000)
	nCoPicked = Weather(:child_killed, [ "w" ])
	Then("the core's pick is not moved by the tour's other draws: still 2", nCoPicked, 2)
	Given("a stepped clock started with a number held as text, and a tick the same way")
	TestoorCore("ring")
	Then("the reference took the text and stored it", _CoRefuses("start"), 0)
	Then("and a tick given as text", _CoRefuses("tick"), 0)
	TestoorCore("engine")
	Then("the core wants numbers, and refuses a start given as text", _CoRefuses("start"), 1)
	Then("and a tick given as text", _CoRefuses("tick"), 1)
	Given("a runner that passed a seed that is not a number")
	Then("the core takes it for no seed and draws one: 1 + 123456 mod 90000", 0 + StzEngineTestoorWorld("seedrun", "abc", 123456.7, 0), 33457)
	Then("and so does a negative one", 0 + StzEngineTestoorWorld("seedrun", "-3", 123456.7, 0), 33457)
	TestoorReset()
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

ok

? ""
? "[P3.1 + P3.2 took " + ((clock() - nCoStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

# the run request the engine reads, built from a committed run.json and the reference's tours
func _CoRunRequest(pcDir, pcJudgeRoot)
	_aJ_ = StzJsonToList(TestoorGoldenRead(pcDir + "/run.json"))
	_cRoot_ = _aJ_[:root]
	_cRef_ = ""
	if _aJ_[:refuse_root] != ""
		_cRoot_ = _aJ_[:refuse_root]
		_cRef_ = "no such root: " + _aJ_[:refuse_root]
	ok
	_c_ = '{"run":{"by":' + _TourJsonStr(_aJ_[:by]) + ',"root":' + _TourJsonStr(_cRoot_) + ',"topic":' + _TourJsonStr(_aJ_[:topic]) +
	      ',"subject":' + _TourJsonStr(_aJ_[:subject]) + ',"refusal":' + _TourJsonStr(_cRef_) + ',"seed":' + _aJ_[:seed] +
	      ',"repeat":' + _aJ_[:repeat] + ',"timeout_ms":' + _aJ_[:timeout_ms] + ',"skipped":['
	if _cRef_ = ""
		for _i_ = 1 to len(_aJ_[:skipped])
			if _i_ > 1  _c_ += ","  ok
			_c_ += _TourJsonStr(_aJ_[:skipped][_i_])
		next
	ok
	_c_ += '],"topics_skipped":['
	if _cRef_ = ""
		for _i_ = 1 to len(_aJ_[:topics_skipped])
			if _i_ > 1  _c_ += ","  ok
			_c_ += _TourJsonStr(_aJ_[:topics_skipped][_i_])
		next
	ok
	_c_ += ']},"tours":['
	if _cRef_ = ""
		_nC_ = len(_aJ_[:cases])
		for _i_ = 1 to _nC_
			if _i_ > 1  _c_ += ","  ok
			_aRec_ = TestoorGoldenVerdict(pcJudgeRoot + "/" + _aJ_[:cases][_i_])
			for _k_ = 1 to len(_aJ_[:flaky])
				if _aJ_[:flaky][_k_] = _aJ_[:cases][_i_]  _aRec_[:flaky] = 1  ok
			next
			_c_ += _TravRunJson(_aRec_)
		next
	ok
	return _c_ + "]}"

# a tour record as a reader would have made it: one stop, two claims
func _CoLiveRecord()
	return [ :file = "live.ring", :readable = 1, :why = "", :dialect = "chk", :helpers = [], :lines = 20,
	         :ending = "plain", :asserts = 3, :promises = 0, :markers = 0,
	         :stops = [ [ :title = "Live", :line = 1, :claims = [
	                      [ :line = 2, :kind = "sees", :claim = "plain", :want = "" ],
	                      [ :line = 3, :kind = "sees", :claim = "colour " + char(27) + "[0m done", :want = "" ],
	                      [ :line = 4, :kind = "sees", :claim = "last", :want = "" ] ] ] ],
	         :routes = [] ]

#============================================================================
# P3.2 HELPERS: the world of a tour, walked the same way on whichever implementation TestoorCore() chose

func _CoJoin(paList)
	_c_ = ""
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += "" + paList[_i_]
	next
	return _c_

func _CoPlanText(paPlan)
	_c_ = ""
	_n_ = len(paPlan)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += paPlan[_i_][1] + "/" + paPlan[_i_][2]
	next
	return _c_

# the weather that fell due at a tick, by name and by what its spec named; "-" for none
func _CoFiredText(paFired)
	if len(paFired) = 0  return "-"  ok
	_c_ = ""
	_n_ = len(paFired)
	for _i_ = 1 to _n_
		if _i_ > 1  _c_ += ","  ok
		_c_ += paFired[_i_][1] + "/" + paFired[_i_][2][1]
	next
	return _c_

# did the call raise? 1 or 0
func _CoRaised(pcWhat)
	_b_ = 0
	try
		if pcWhat = "tick"
			ClockTick()
		but pcWhat = "advance"
			ClockAdvance(5)
		but pcWhat = "skew"
			Weather(:skew, [ 5 ])
		but pcWhat = "unknown-weather"
			Weather(:locusts, [ 1 ])
		but pcWhat = "unknown-mode"
			ClockTo(:sideways, "")
		ok
	catch
		_b_ = 1
	done
	return _b_

# a start or a tick given as text: refused (1) or taken (0)
func _CoRefuses(pcWhich)
	TestoorReset()
	_b_ = 0
	try
		if pcWhich = "start"
			ClockTo(:stepped, [ "1000", 250 ])
		else
			ClockTo(:stepped, [ 0, 100 ])
			Weather(:child_killed, [ "w", "3" ])
		ok
	catch
		_b_ = 1
	done
	TestoorReset()
	return _b_

# the tick a weather with none gets under a seed
func _CoPick(pnSeed)
	TestoorReset()
	Seed(pnSeed)
	_n_ = Weather(:child_killed, [ "w" ])
	TestoorReset()
	return _n_

# ONE script on whichever implementation is chosen: what it returned, as text. It leaves out what
# differs on purpose (the pick of a tick; the seed a hand-run draws from the clock).
func _CoWorldScript()
	TestoorReset()
	_c_ = "mode=" + ClockMode() + "|"
	_c_ += "tick-live=" + _CoRaised("tick") + "|"
	_c_ += "advance-live=" + _CoRaised("advance") + "|"
	_c_ += "skew-live=" + _CoRaised("skew") + "|"
	_c_ += "unknown-weather=" + _CoRaised("unknown-weather") + "|"
	_c_ += "unknown-mode=" + _CoRaised("unknown-mode") + "|"
	_c_ += "seed=" + Seed(42) + "|"
	_c_ += "clock=" + ClockTo(:stepped, [ 1000, 250 ]) + "|"
	_c_ += "0=" + ClockNow() + "|"
	ClockTick()
	_c_ += "1=" + ClockNow() + "|"
	ClockAdvance(750)
	_c_ += "2=" + ClockNow() + "|"
	ClockTick()
	_c_ += "3=" + ClockNow() + "|"
	_c_ += "ticks=" + ClockTicks() + "|"
	_c_ += "w1=" + Weather(:child_killed, [ "w1", 5 ]) + "|"
	_c_ += "w2=" + Weather(:child_killed, [ "w2", 3 ]) + "|"
	_c_ += "skew=" + Weather(:skew, [ 500 ]) + "|"
	_c_ += "now=" + ClockNow() + "|"
	_c_ += "declared=" + _CoJoin(WeatherDeclared()) + "|"
	_c_ += "plan=" + _CoPlanText(WeatherPlan()) + "|"
	_c_ += "t3=" + _CoFiredText(ClockTick()) + "|"
	_c_ += "t4=" + _CoFiredText(ClockTick()) + "|"
	_c_ += "t5=" + _CoFiredText(ClockTick()) + "|"
	_c_ += "plan-after=" + _CoPlanText(WeatherPlan()) + "|"
	_c_ += "now-after=" + ClockNow() + "|"
	_c_ += "restart=" + ClockTo(:stepped, [ 0, 10 ]) + "|"
	_c_ += "declared-after-restart=" + _CoJoin(WeatherDeclared()) + "|"
	_c_ += "ticks-after-restart=" + ClockTicks() + "|"
	_c_ += "now-after-restart=" + ClockNow() + "|"
	_c_ += "frozen=" + ClockTo(:frozen, "2025-09-27 14:30:25") + "|"
	_c_ += "live=" + ClockTo(:live, "") + "|"
	TestoorReset()
	_c_ += "reset-declared=" + _CoJoin(WeatherDeclared()) + "|"
	return _c_
