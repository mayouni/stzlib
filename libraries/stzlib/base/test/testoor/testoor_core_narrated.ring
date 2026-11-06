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
# P3.3 adds the ROUTE JOIN and the GRAPH STORE (stzRoute.ring, stzImpact.ring; engine/src/testoor_routes.zig and
# testoor_graph.zig): the route map's Json() and Prose() and impact's reach and selection are walked on the
# reference and then on the core and must be the same bytes; and the cases only the core can judge, protocol 2's
# nodes, its incomplete-graph run and its impact records (golden/protocol2/), are sent through the Ring seam.
#
# A machine without the core library (Ring 1.27 with no engine build) runs the first section
# only and says, by name, what it did not run.

? "TESTOOR P3.1 + P3.2 + P3.3 -- the core beside the reference"
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

#============================================================================
Scenario("P3.3 -- the route join: the core and the reference write the same report")
	nCoSec = clock()
	Given("two plans (an item met twice) and tours whose routes include one no plan owns")
	oCoMap = StzRouteMapQ()
	oCoMap.AddPlan("plan.md", "### ZA1 -- first" + char(10) + "CLOSED: shipped." + char(10) +
	                          "### ZA2 -- second" + char(10) + "CLOSED: shipped." + char(10) +
	                          "### ZA3 -- third" + char(10) + "OPEN: not yet." + char(10))
	oCoMap.AddPlan("other.md", "### ZA3 -- third again" + char(10) + "OPEN: later." + char(10))
	oCoMap.AddTour([ :file = "t/a.ring", :routes = [ [ :item = "ZA1", :stop = "first", :line = 3 ] ] ])
	oCoMap.AddTour([ :file = "t/b.ring", :routes = [ [ :item = "QQ9", :stop = "", :line = 7 ] ] ])
	Then("three routes are owned, one walked, one walk names a route no plan owns",
	     "" + oCoMap.OwnedCount() + "/" + oCoMap.WalkedCount() + "/" + len(oCoMap.UnknownWalks()), "3/1/1")
	TestoorCore("ring")
	cCoRouteJsonRef = oCoMap.Json()
	cCoRouteProseRef = oCoMap.Prose()
	TestoorCore("engine")
	Then("the core answers the report (a library built before the call existed would fall back, silently)", oCoMap._CoreRoutes("json") != "", TRUE)
	Then("its JSON is the reference's bytes", oCoMap.Json(), cCoRouteJsonRef)
	Then("its prose is the reference's bytes", oCoMap.Prose(), cCoRouteProseRef)
	Then("and the report counts, never sums", StzFindFirst('"owned":3,"walked":1,"unwalked":[{"route":"ZA2"', cCoRouteJsonRef) > 0, TRUE)
	Given("a map with no plan and no tour")
	oCoEmpty = StzRouteMapQ()
	TestoorCore("ring")
	cCoEmptyRef = oCoEmpty.Json() + char(10) + oCoEmpty.Prose()
	TestoorCore("engine")
	Then("the empty report is the same bytes too", oCoEmpty.Json() + char(10) + oCoEmpty.Prose(), cCoEmptyRef)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("P3.3 -- impact: the core and the reference reach the same names and select the same tours")
	nCoSec = clock()
	cCoPlant = currentdir() + "/_planted_core"
	_CoPlantImpact(cCoPlant)
	Given("a planted subject (stzInvoice calls stzTax calls stzNet), seven tours, and a subject that dispatches by a built name")
	TestoorCore("ring")
	cCoImRef = _CoImpactTranscript(cCoPlant)
	TestoorCore("engine")
	cCoImEng = _CoImpactTranscript(cCoPlant)
	aCoFace = _ImpactFace(cCoPlant + "/lib/_subject.ring", "Vat")
	Then("the core is the one answering", len(_ImpactCore(aCoFace, [ cCoPlant + "/lib/t2_vat.ring" ])) > 0, TRUE)
	Then("the two transcripts are the same bytes: names in order, tours selected and skipped, completeness", cCoImEng, cCoImRef)
	Then("a change to Label re-walks one tour of seven", StzFindFirst("Label|names=label|sel=t6_label|skip=6|complete=1", cCoImRef) > 0, TRUE)
	Then("a change to Vat reaches Gross, which calls it, and the dynamic subject selects every tour",
	     StzFindFirst("Vat|names=vat,gross|sel=t2_vat,t3_gross|", cCoImRef) > 0 and StzFindFirst("dyn:Gross|names=gross|sel=d1_gross,d2_vat,d3_unrelated|skip=0|complete=0", cCoImRef) > 0, TRUE)
	_CoUnplantImpact(cCoPlant)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("P3.3 -- protocol 2 through the Ring seam: node evidence in a verdict, the incomplete-graph run, the impact record")
	nCoSec = clock()
	cCoP2 = cCoRoot + "/protocol2"
	Given("golden cases 15 and 16 sent to the core as the face would send them: the record, the output, the meta, the graph, the names")
	cCoT15 = _CoVerdictP2(cCoP2 + "/judge/15_nodes_named_observed")
	cCoT16 = _CoVerdictP2(cCoP2 + "/judge/16_node_line_count")
	Then("case 15: a node reached three times, one named and never reached, one reached with a count",
	     cCoT15, _CoChop(TestoorGoldenRead(cCoP2 + "/judge/15_nodes_named_observed/expected.json")))
	Then("case 16: counts add, and a malformed count is ignored", cCoT16, _CoChop(TestoorGoldenRead(cCoP2 + "/judge/16_node_line_count/expected.json")))
	Given("the run L6: those two tours against a graph that is not complete")
	cCoRunReq = '{"run":' + TestoorGoldenRead(cCoP2 + "/logbook/L6_graph_incomplete/run.json") + ',"tours":[' + cCoT15 + "," + cCoT16 + "]}"
	Then("its JSON carries protocol 2 and the three figures", StzEngineTestoorRunJson(cCoRunReq),
	     _CoChop(TestoorGoldenRead(cCoP2 + "/logbook/L6_graph_incomplete/expected.json")))
	Then("its prose says the graph is incomplete", StzEngineTestoorRunProse(cCoRunReq),
	     _CoChop(TestoorGoldenRead(cCoP2 + "/logbook/L6_graph_incomplete/expected.txt")))
	Then("and the run still exits 0: an incomplete graph is reported, not failed", StzEngineTestoorRunExit(cCoRunReq), 0)
	Given("the three impact records")
	acCoImp = _GoldenCases(cCoP2 + "/impact")
	nCoImpBad = 0
	for nCo = 1 to len(acCoImp)
		if StzEngineTestoorImpact(TestoorGoldenRead(cCoP2 + "/impact/" + acCoImp[nCo] + "/request.json")) !=
		   _CoChop(TestoorGoldenRead(cCoP2 + "/impact/" + acCoImp[nCo] + "/expected.json"))
			nCoImpBad++
			? "        DIFFERS: " + acCoImp[nCo]
		ok
	next
	Then("complete, open and two changed nodes: the core writes each record", nCoImpBad, 0)
	Then("there are three", len(acCoImp), 3)
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The evidence floor through the Ring seam: a gate's floor met, and a gate's floor refused")
	nCoSec = clock()
	Given("golden case 17 (four kept claims, two routes walked) under the floors of L7 and L8")
	cCoT17 = _CoChop(TestoorGoldenRead(cCoP2 + "/judge/17_routes_and_claims/expected.json"))
	acCoFloor = [ "L7_floor_met", "L8_floor_refused" ]
	for nCo = 1 to len(acCoFloor)
		cCoFloorReq = '{"run":' + TestoorGoldenRead(cCoP2 + "/logbook/" + acCoFloor[nCo] + "/run.json") + ',"tours":[' + cCoT17 + "]}"
		Then(acCoFloor[nCo] + ": the JSON carries the evidence record", StzEngineTestoorRunJson(cCoFloorReq),
		     _CoChop(TestoorGoldenRead(cCoP2 + "/logbook/" + acCoFloor[nCo] + "/expected.json")))
		Then(acCoFloor[nCo] + ": the prose says met or NOT MET", StzEngineTestoorRunProse(cCoFloorReq),
		     _CoChop(TestoorGoldenRead(cCoP2 + "/logbook/" + acCoFloor[nCo] + "/expected.txt")))
		Then(acCoFloor[nCo] + ": the exit code a gate reads", "" + StzEngineTestoorRunExit(cCoFloorReq),
		     _CoChop(TestoorGoldenRead(cCoP2 + "/logbook/" + acCoFloor[nCo] + "/expected.exit")))
	next
EndScenario()
? "        [section took " + ((clock() - nCoSec) / clockspersecond()) + "s]"

ok

? ""
? "[P3.1 + P3.2 + P3.3 + the floor took " + ((clock() - nCoStart) / clockspersecond()) + "s]"
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

#============================================================================
# P3.3 HELPERS: routes, impact and protocol 2 through the Ring seam

# a text without its last line feed: what a golden file holds beyond the JSON it names
func _CoChop(pcText)
	_c_ = "" + pcText
	if len(_c_) > 0 and right(_c_, 1) = char(10)
		return left(_c_, len(_c_) - 1)
	ok
	return _c_

# the file name of a path, without its folder and its .ring
func _CoStem(pcPath)
	_c_ = "" + pcPath
	_n_ = len(_c_)
	_nAt_ = 0
	for _i_ = 1 to _n_
		if _c_[_i_] = "/" or _c_[_i_] = "\"  _nAt_ = _i_  ok
	next
	_c_ = right(_c_, _n_ - _nAt_)
	if len(_c_) > 5 and right(_c_, 5) = ".ring"  _c_ = left(_c_, len(_c_) - 5)  ok
	return _c_

# names.txt (one name a line) as the JSON array the core reads
func _CoNamesJson(pcText)
	_acL_ = str2list("" + pcText)
	_c_ = "["
	_bFirst_ = 1
	_n_ = len(_acL_)
	for _i_ = 1 to _n_
		if len(_acL_[_i_]) = 0  loop  ok
		if NOT _bFirst_  _c_ += ","  ok
		_bFirst_ = 0
		_c_ += _TourJsonStr(_acL_[_i_])
	next
	return _c_ + "]"

# a golden file a case may not have: its text, or ""
func _CoReadOpt(pcPath)
	if fexists(pcPath)  return TestoorGoldenRead(pcPath)  ok
	return ""

# a protocol-2 judge case, sent to the core the way a face would send it
func _CoVerdictP2(pcDir)
	_cReq_ = '{"record":' + TestoorGoldenRead(pcDir + "/record.json") + ',"output":' + _TourJsonStr(TestoorGoldenRead(pcDir + "/output.txt")) +
	         ',"meta":' + TestoorGoldenRead(pcDir + "/meta.json") + ',"graph":' + TestoorGoldenRead(pcDir + "/graph.json") +
	         ',"names":' + _CoNamesJson(_CoReadOpt(pcDir + "/names.txt")) + "}"
	return StzEngineTestoorVerdict(_cReq_)

# the impact guard's planted subject, and tours that only NAME it (they are never run here)
func _CoPlantImpact(pcRoot)
	_CoUnplantImpact(pcRoot)
	StzMakeDir(pcRoot)
	StzMakeDir(pcRoot + "/lib")
	StzMakeDir(pcRoot + "/dyn")
	_t_ = char(9)
	_n_ = char(10)
	write(pcRoot + "/lib/_subject.ring",
		"class stzNet" + _n_ +
		_t_ + "def init()" + _n_ + _t_ + _t_ + "return" + _n_ +
		_t_ + "def Of(n)" + _n_ + _t_ + _t_ + "return n" + _n_ +
		_t_ + "def Round2(n)" + _n_ + _t_ + _t_ + "return n" + _n_ +
		"class stzTax" + _n_ +
		_t_ + '@oNet = ""' + _n_ +
		_t_ + "def init()" + _n_ + _t_ + _t_ + "@oNet = new stzNet()" + _n_ +
		_t_ + "def Vat(n)" + _n_ + _t_ + _t_ + "return @oNet.Of(n) * 2 / 10" + _n_ +
		_t_ + "def Duty(n)" + _n_ + _t_ + _t_ + "return @oNet.Round2(n) / 100" + _n_ +
		"class stzInvoice" + _n_ +
		_t_ + '@oTax = ""' + _n_ +
		_t_ + "def init()" + _n_ + _t_ + _t_ + "@oTax = new stzTax()" + _n_ +
		_t_ + "def Gross(n)" + _n_ + _t_ + _t_ + "return n + @oTax.Vat(n)" + _n_ +
		_t_ + "def Landed(n)" + _n_ + _t_ + _t_ + "return n + @oTax.Duty(n)" + _n_ +
		_t_ + "def Label()" + _n_ + _t_ + _t_ + "return 7" + _n_)
	write(pcRoot + "/lib/t1_net.ring", "o = new stzNet()" + _n_ + "? o.Of(5)" + _n_)
	write(pcRoot + "/lib/t2_vat.ring", "o = new stzTax()" + _n_ + "? o.Vat(100)" + _n_)
	write(pcRoot + "/lib/t3_gross.ring", "o = new stzInvoice()" + _n_ + "? o.Gross(100)" + _n_)
	write(pcRoot + "/lib/t4_duty.ring", "o = new stzTax()" + _n_ + "? o.Duty(1000)" + _n_)
	write(pcRoot + "/lib/t5_landed.ring", "o = new stzInvoice()" + _n_ + "? o.Landed(1000)" + _n_)
	write(pcRoot + "/lib/t6_label.ring", "o = new stzInvoice()" + _n_ + "? o.Label()" + _n_)
	write(pcRoot + "/lib/t7_unrelated.ring", '? "names nothing of the subject"' + _n_)
	write(pcRoot + "/dyn/_subject.ring",
		"func VatOf(n)" + _n_ + _t_ + "return n * 2 / 10" + _n_ +
		"class stzInvoice" + _n_ +
		_t_ + "def init()" + _n_ + _t_ + _t_ + "return" + _n_ +
		_t_ + "def Gross(n)" + _n_ +
		_t_ + _t_ + "eval('$nRes = VatOf(' + n + ')')" + _n_ +
		_t_ + _t_ + "return n + $nRes" + _n_)
	write(pcRoot + "/dyn/d1_gross.ring", "o = new stzInvoice()" + _n_ + "? o.Gross(100)" + _n_)
	write(pcRoot + "/dyn/d2_vat.ring", "? VatOf(100)" + _n_)
	write(pcRoot + "/dyn/d3_unrelated.ring", '? "names nothing"' + _n_)

func _CoUnplantImpact(pcRoot)
	if fexists(pcRoot + "/lib/_subject.ring")
		StzDirDeleteAll(pcRoot)
	ok

# the reach and the selection of a set of changes, as text: ONE script on whichever implementation is chosen
func _CoImpactTranscript(pcRoot)
	_acLib_ = [ pcRoot + "/lib/t1_net.ring", pcRoot + "/lib/t2_vat.ring", pcRoot + "/lib/t3_gross.ring", pcRoot + "/lib/t4_duty.ring",
	            pcRoot + "/lib/t5_landed.ring", pcRoot + "/lib/t6_label.ring", pcRoot + "/lib/t7_unrelated.ring" ]
	_acMeth_ = [ "Of", "Vat", "Gross", "Landed", "Label", "Round2", "stzTax.init", "init" ]
	_c_ = ""
	_nM_ = len(_acMeth_)
	for _i_ = 1 to _nM_
		_c_ += _CoImpactLine("", pcRoot + "/lib/_subject.ring", _acMeth_[_i_], _acLib_)
	next
	_acDyn_ = [ pcRoot + "/dyn/d1_gross.ring", pcRoot + "/dyn/d2_vat.ring", pcRoot + "/dyn/d3_unrelated.ring" ]
	_c_ += _CoImpactLine("dyn:", pcRoot + "/dyn/_subject.ring", "Gross", _acDyn_)
	return _c_

func _CoImpactLine(pcTag, pcSubject, pcMethod, pacTours)
	_aR_ = StzImpactedTours(pcSubject, pcMethod, pacTours)
	_cNames_ = ""
	_n_ = len(_aR_[:names])
	for _i_ = 1 to _n_
		if _i_ > 1  _cNames_ += ","  ok
		_cNames_ += _aR_[:names][_i_]
	next
	_cSel_ = ""
	_n_ = len(_aR_[:selected])
	for _i_ = 1 to _n_
		if _i_ > 1  _cSel_ += ","  ok
		_cSel_ += _CoStem(_aR_[:selected][_i_])
	next
	return pcTag + pcMethod + "|names=" + _cNames_ + "|sel=" + _cSel_ + "|skip=" + len(_aR_[:skipped]) + "|complete=" + _aR_[:complete] + char(10)
