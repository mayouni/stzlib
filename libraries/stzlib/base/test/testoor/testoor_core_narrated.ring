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
# A machine without the core library (Ring 1.27 with no engine build) runs the first section
# only and says, by name, what it did not run.

? "TESTOOR P3.1 -- the core beside the reference"
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
	? "  every core-versus-reference section (golden tours, run-level calls, live-shaped tour, bad requests, deviations)"
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

ok

? ""
? "[P3.1 took " + ((clock() - nCoStart) / clockspersecond()) + "s]"
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
