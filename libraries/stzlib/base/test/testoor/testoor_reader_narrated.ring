load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR TR0 -- THE READER. Every test Softanza already has, read as a
# TOUR, and not one of them edited.
#
# WHY THIS GUARD EXISTS. The five runners this plane replaces read a test
# file five different ways, and none of them as data: _sweepall.sh greps the
# OUTPUT for "[OK]" (case-sensitive, so a file printing "[ok]" counted as
# not asserting), promises.py pairs `?` with `#-->` in Python, the CLI calls
# every pf() ending a FAIL. The reader is the one place a test file is
# understood, and this guard is where that understanding is measured:
#
#   1. one narrated tour, read, and the file byte-identical afterwards
#   2. the three Ring dialects and Zin's .zst -- planted, so the counts are
#      exact and the guard does not move when the corpus does -- and the
#      real files of each dialect, for the shape
#   3. the three states the launch prompt names: a planted lower-case [ok]
#      counts as asserting; a planted file with no claim "runs, asserts
#      nothing"; an unknown dialect is NAMED, not edited
#   4. the corpus read: every *_narrated.ring under base/test, once, one
#      line per file, JSON and prose from the same read, what was skipped
#      named. This is the heavy section and it runs ONCE per task.
#
# Planted files are written to the system temp folder and removed at the
# end -- nothing is written under base/test by a guard whose whole claim is
# that it writes nothing there.
#
# Every positive claim has its negative sibling (ruling 3): a path that is
# not there is unreadable WITH a reason; a comment that merely contains
# "#-->" is not a promise; a `?` followed by a plain comment is not a claim.

? "TESTOOR TR0 -- the reader"
nTrStart = clock()
$acTrPlanted = []
cTrTemp = _TrTempDir()

#============================================================================
Scenario("A narrated tour is read as data, and the file is not edited")
	nTrSec = clock()
	cPath = "../uuid/00_uuid_narrated.ring"
	Given("the uuid narrated suite, Given/When/Then from _narrated.ring")
	cBefore = read(cPath)
	When("Tour(path) reads it")
	aT = Tour(cPath)
	cAfter = read(cPath)
	Then("it is readable", aT[:readable], 1)
	Then("its dialect is narrated", aT[:dialect], "narrated")
	Then("it has four stops, one per Scenario()", len(aT[:stops]), 4)
	Then("it makes 17 claims, one per Then()", len(TourQ(cPath).Claims()), 17)
	Then("the first stop is titled by its Scenario()",
		aT[:stops][1][:title], "A generated UUID has the v4 format and metadata")
	Then("its first claim is the Then() text",
		aT[:stops][1][:claims][1][:claim], "it is 36 chars (8-4-4-4-12 + hyphens)")
	Then("the claim carries its line", aT[:stops][1][:claims][1][:line], 14)
	Then("it ends with Summary()", aT[:ending], "summary")
	Then("it asserts", aT[:asserts], 1)
	Then("the file is byte-identical after the read", cAfter = cBefore, TRUE)
	Then("the record's JSON is valid JSON", StzJsonIsValid(TourQ(cPath).Json()), TRUE)
	Then("the prose names the dialect and the counts",
		StzFindFirst("narrated, 4 stops, 17 claims", TourQ(cPath).Prose()) > 0, TRUE)
	# the negative sibling: a path that is not there
	aNo = Tour(cTrTemp + "/stz_testoor_does_not_exist.ring")
	Then("a missing file is unreadable", aNo[:readable], 0)
	Then("and says why", StzFindFirst("cannot read", aNo[:why]) > 0, TRUE)
	Then("an unreadable tour asserts nothing", aNo[:asserts], 0)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The three Ring dialects and Zin's .zst are faces of one grammar")
	nTrSec = clock()
	Given("a planted file of each dialect, so the counts are exact")

	cChk = _TrPlant("planted_chk.ring",
		"load " + '"' + "../../stzBase.ring" + '"' + char(10) +
		"nPass = 0  nFail = 0" + char(10) +
		'? "-- Scene 1: the first scene --"' + char(10) +
		'Chk("one is one", 1 = 1)' + char(10) +
		'Chk("two is two", 2 = 2)' + char(10) +
		'? "-- Scene 2: the second scene --"' + char(10) +
		'Chk("three is three", 3 = 3)' + char(10) +
		"pf()" + char(10) +
		"func Chk(cWhat, bCond)" + char(10) +
		char(9) + "if bCond nPass++ ? " + '"  [OK] "' + " + cWhat else nFail++ ? " + '"  [FAIL] "' + " + cWhat ok" + char(10))
	aC = Tour(cChk)
	When("the self-contained helper is read")
	Then("the dialect is chk", aC[:dialect], "chk")
	Then("one helper is found by its body", len(aC[:helpers]), 1)
	Then("under its own name, lower-cased as Ring reads names", aC[:helpers][1], "chk")
	Then("the two scene banners are two stops", len(aC[:stops]), 2)
	Then("the second stop is the second scene", aC[:stops][2][:title], "-- Scene 2: the second scene --")
	Then("three Chk() calls are three claims", len(TourQ(cChk).Claims()), 3)
	Then("the third claim sits at the second stop", len(aC[:stops][2][:claims]), 1)
	Then("it ends finished-timed, which pf() means", aC[:ending], "finished-timed")
	Then("the helper's own [OK] print is not a claim of the file",
		len(TourQ(cChk).Claims()), 3)

	cGate = _TrPlant("planted_gate.ring",
		"nOk = 0  nBad = 0" + char(10) +
		'sec("-- 1. the first section --")' + char(10) +
		'chk("a is a", 1 = 1)' + char(10) +
		'discharges("TR0")' + char(10) +
		'sec("-- 2. the second section --")' + char(10) +
		'chkeq("b is b", 2, 2)' + char(10) +
		'? "TOTAL: " + nOk + " ok"' + char(10) +
		"func sec cTitle" + char(10) + char(9) + "? cTitle" + char(10) +
		"func chk cWhat, bCond" + char(10) + char(9) + "if bCond nOk++ else nBad++ ok" + char(10) +
		"func chkeq cWhat, xGot, xWant" + char(10) + char(9) + "chk(cWhat, xGot = xWant)" + char(10) +
		"func discharges cItem" + char(10) + char(9) + "? cItem" + char(10))
	aG = Tour(cGate)
	When("the gate dialect is read")
	Then("the dialect is gate", aG[:dialect], "gate")
	Then("sec() opens a stop", len(aG[:stops]), 2)
	Then("chk() and chkeq() are claims", len(TourQ(cGate).Claims()), 2)
	Then("discharges() is a route", len(aG[:routes]), 1)
	Then("the route names the plan item", aG[:routes][1][:item], "TR0")
	Then("the route records the stop it sits in", aG[:routes][1][:stop], "-- 1. the first section --")
	Then("a printed TOTAL: is its own ending", aG[:ending], "own-total")

	cProm = _TrPlant("planted_promises.ring",
		"? 1 + 1" + char(10) + "#--> 2" + char(10) + char(10) +
		'? "a"  #--> a' + char(10) +
		"# a comment that merely mentions #--> is not a promise" + char(10) +
		"? 3" + char(10) + "# a plain comment after a ? is not a claim" + char(10))
	aP = Tour(cProm)
	When("bare promises are read")
	Then("the dialect is promises", aP[:dialect], "promises")
	Then("a next-line #--> and a trailing #--> are both claims", len(TourQ(cProm).Claims()), 2)
	Then("the first promise's expression", aP[:stops][1][:claims][1][:claim], "1 + 1")
	Then("the first promise's value", aP[:stops][1][:claims][1][:want], "2")
	Then("the trailing form keeps its value", aP[:stops][1][:claims][2][:want], "a")
	Then("the claims are of kind promise", aP[:stops][1][:claims][2][:kind], "promise")
	Then("the comment mentioning #--> is not counted", aP[:promises], 2)

	cZst = _TrPlant("planted_narrated.zst",
		"DEFINE NARRATED_TEST planted AS (" + char(10) +
		'    TITLE "Planted",' + char(10) +
		"    STEP A1 (" + char(10) +
		'        COMMAND "zin version",' + char(10) +
		'        EXPECT "zin"' + char(10) + "    )," + char(10) +
		"    STEP A2 (" + char(10) +
		'        COMMAND "zin info",' + char(10) +
		'        EXPECT_EXIT 0' + char(10) + "    )" + char(10) + ")" + char(10))
	aZ = Tour(cZst)
	When("Zin's .zst is read")
	Then("the dialect is the DEFINE kind", aZ[:dialect], "zst:NARRATED_TEST")
	Then("each STEP is a stop", len(aZ[:stops]), 2)
	Then("the stop is named by its STEP", aZ[:stops][1][:title], "STEP A1")
	Then("EXPECT and EXPECT_EXIT are claims", len(TourQ(cZst).Claims()), 2)

	Given("the real files of each dialect, for the shape")
	aR1 = Tour("../agentic/agentfile_narrated.ring")
	Then("agentfile_narrated.ring is the chk dialect", aR1[:dialect], "chk")
	Then("with scene banners as stops", len(aR1[:stops]) >= 8, TRUE)
	aR2 = Tour("../graphics/gg_adversarial.ring")
	Then("gg_adversarial.ring is the gate dialect", aR2[:dialect], "gate")
	Then("with more than a hundred sections", len(aR2[:stops]) > 100, TRUE)
	Then("and routes declared by discharges()", len(aR2[:routes]) > 0, TRUE)
	Then("the first route is GG6", aR2[:routes][1][:item], "GG6")
	aR3 = Tour("../uuid/01_basic_generation.ring")
	Then("01_basic_generation.ring is the promises dialect", aR3[:dialect], "promises")
	Then("with its promise on the line after the ?",
		aR3[:stops][1][:claims][1][:claim], "o1.Content()")
	aR4 = Tour("../world/world_contract_narrated.ring")
	Then("world_contract's Assert, which raises on failure, is a helper",
		ring_find(aR4[:helpers], "assert") > 0, TRUE)
	Then("so the file is the chk dialect, not unknown", aR4[:dialect], "chk")
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A lower-case [ok] asserts; a file with no claim runs and asserts nothing; an unknown dialect is named, not edited")
	nTrSec = clock()
	Given("a planted file printing a lower-case [ok] with no helper at all")
	cOk = _TrPlant("planted_lower_ok.ring",
		'? "  [ok]   the planted marker counts as asserting"' + char(10))
	aOk = Tour(cOk)
	Then("it asserts", aOk[:asserts], 1)
	Then("its dialect is markers", aOk[:dialect], "markers")
	Then("the marker is a claim of kind marker", aOk[:stops][1][:claims][1][:kind], "marker")
	Then("one marker was counted", aOk[:markers], 1)

	Given("a planted file that runs and asserts nothing")
	cNo = _TrPlant("planted_nothing.ring", "x = 1 + 1" + char(10) + '? "hello"' + char(10))
	aNo = Tour(cNo)
	Then("it is readable", aNo[:readable], 1)
	Then("it asserts nothing", aNo[:asserts], 0)
	Then("the prose says so, in those words",
		StzFindFirst("RUNS, ASSERTS NOTHING", TourQ(cNo).Prose()) > 0, TRUE)
	Then("the logbook lists it under asserting nothing",
		len(StzLogbookQ().Read(cNo).AssertingNothing()), 1)

	Given("a planted file in no dialect the reader knows")
	cUnk = _TrPlant("planted_unknown.ring", "this is not a test file in any dialect" + char(10) + "blah = 1" + char(10))
	cUnkBefore = read(cUnk)
	aUnk = Tour(cUnk)
	cUnkAfter = read(cUnk)
	Then("its dialect is unknown", aUnk[:dialect], "unknown")
	Then("the prose names it as unknown and not edited",
		StzFindFirst("UNKNOWN DIALECT, named, not edited", TourQ(cUnk).Prose()) > 0, TRUE)
	Then("and the file is byte-identical after the read", cUnkAfter = cUnkBefore, TRUE)
	Then("the logbook lists it under unknown", len(StzLogbookQ().Read(cUnk).Unknown()), 1)

	Given("a planted .zst of a DEFINE kind the Zst spec does not declare")
	cWz = _TrPlant("planted_weird.zst", "DEFINE WEIRD_THING nope AS ( )" + char(10))
	aWz = Tour(cWz)
	Then("it is unknown", aWz[:dialect], "unknown")
	Then("and the why names the kind", StzFindFirst("WEIRD_THING", aWz[:why]) > 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The logbook reads every narrated file under base/test, once, and reports per file")
	nTrSec = clock()
	Given("base/test, every *_narrated.ring under it, in one read")
	oL = StzLogbookQ().ReadTree("..", "_narrated.ring")
	nRead = oL.Count()
	When("each tour is reported on one line")
	for k = 1 to nRead
		? "  " + oL.ProseOf(k)
	next
	? ""
	? oL.Summary()
	nWalk = _TrCountNarrated("..")
	Then("the count equals an independent walk of the tree", nRead, nWalk)
	Then("every narrated file was readable", len(oL.Unreadable()), 0)
	aUnknown = oL.Unknown()
	nUnknown = len(aUnknown)
	for k = 1 to nUnknown
		? "  UNKNOWN: " + aUnknown[k][:file]
	next
	Then("no narrated file is of a dialect the reader cannot name", nUnknown, 0)
	aNothing = oL.AssertingNothing()
	nNothing = len(aNothing)
	for k = 1 to nNothing
		? "  ASSERTS NOTHING: " + aNothing[k][:file]
	next
	Then("the helper _narrated.ring was skipped by name, and named",
		ring_find(oL.Skipped(), "../_narrated.ring") > 0, TRUE)
	cJson = oL.Json()
	Then("the logbook's JSON is valid JSON", StzJsonIsValid(cJson), TRUE)
	Then("the JSON carries the same count as the prose",
		StzFindFirst('"read":' + nRead + ',', cJson) > 0, TRUE)
	Then("the JSON names what was skipped",
		StzFindFirst('"../_narrated.ring"', cJson) > 0, TRUE)
	Then("more claims than tours were read", oL.ClaimsCount() > nRead, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

_TrUnplant()
? ""
? "[TR0 took " + ((clock() - nTrStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# THE HELPERS LIVE AFTER THE TOP-LEVEL CODE. Ring runs a file until its
# first func; a helper defined above would end the guard silently.

func _TrTempDir()
	cT = sysget("TEMP")
	if cT = "" or cT = NULL  cT = sysget("TMPDIR")  ok
	if cT = "" or cT = NULL  cT = "/tmp"  ok
	return substr(cT, "\", "/")

func _TrPlant(cName, cText)
	cP = _TrTempDir() + "/stz_testoor_" + cName
	write(cP, cText)
	$acTrPlanted + cP
	return cP

func _TrUnplant()
	n = len($acTrPlanted)
	for i = 1 to n
		if fexists($acTrPlanted[i])  remove($acTrPlanted[i])  ok
	next

# an independent count of *_narrated.ring files, written differently from
# the logbook's own walker: recursion, not a queue; no sort; no skip list
# beyond the one convention (a name opening with "_" is not a tour)
func _TrCountNarrated(cDir)
	n = 0
	aE = dir(cDir)
	nE = len(aE)
	for i = 1 to nE
		cN = aE[i][1]
		if aE[i][2]
			if cN != "." and cN != ".." and left(cN, 1) != "_" and left(cN, 1) != "."
				n += _TrCountNarrated(cDir + "/" + cN)
			ok
		else
			if left(cN, 1) != "_" and right(lower(cN), 14) = "_narrated.ring"  n++  ok
		ok
	next
	return n
