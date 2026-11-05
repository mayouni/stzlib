load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, A0 -- the move at parity. The guard boots an Atelier on the library
# this checkout holds, runs every check of checks.json over HTTP, and FAILS when a
# check's verdict moved against results.json, the last recording (record.ring).
# Before that it makes each protection fail on planted data: a moved state is
# named, an id that appeared or vanished is named, a folder without the library
# does not boot and says so.
#
# Run from this folder, on rnxc (the Atelier needs its resident VM):
#     rnxc atelier_narrated.ring
# RNXC names the rnxc to boot the child with when it is not the one running this.
# About 80 s: the guard's own library load, the child's compile of the library in
# the background (20 to 40 s), and 1,100 checks at 2 to 4 ms each over HTTP.
#
# What judged the checks is printed, never assumed: the library commit, the rnxc
# build and the engine, from the child's own /atelier/state.

? "ATELIER A0 -- the move at parity"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8660
cAtSettings = cAtHere + "/_planted_settings.ring"

#============================================================================
Scenario("Two recordings compared: a moved verdict is named, and only it")
	Given("a recording of four checks, and a live run where one moved")
	aWas = [ [ "1", "pass" ], [ "2", "fail" ], [ "3", "err" ], [ "4", "pass" ] ]
	aNow = [ [ "1", "pass" ], [ "2", "pass" ], [ "3", "err" ], [ "4", "pass" ] ]
	When("the two are compared")
	aMoved = AtelierMoved(aWas, aNow)
	Then("one move is named", len(aMoved), 1)
	Then("it is check 2", aMoved[1][:id], "2")
	Then("that was failing", aMoved[1][:was], "fail")
	Then("and now passes", aMoved[1][:now], "pass")
	Then("the same recording twice moves nothing", len(AtelierMoved(aWas, aWas)), 0)
EndScenario()

Scenario("An id that appeared or vanished is a move too")
	Given("a recording of three checks and a run of three, two in common")
	aWas = [ [ "1", "pass" ], [ "2", "pass" ], [ "3", "pass" ] ]
	aNow = [ [ "1", "pass" ], [ "2", "pass" ], [ "9", "pass" ] ]
	When("compared")
	aMoved = AtelierMoved(aWas, aNow)
	Then("two moves are named", len(aMoved), 2)
	Then("check 3 is gone", aMoved[1][:id] + ":" + aMoved[1][:was] + ">" + aMoved[1][:now], "3:pass>")
	Then("check 9 is new", aMoved[2][:id] + ":" + aMoved[2][:was] + ">" + aMoved[2][:now], "9:>pass")
EndScenario()

Scenario("A results file round-trips through JSON")
	Given("a state and a run of two checks")
	aState = [ :library = [ :commit = "abc123 on main" ], :rnxc = [ :build = "ringpp x" ], :engine = "the package's" ]
	aRun = [ :states = [ [ "1", "pass" ], [ "2", "fail" ] ], :pass = 1, :fail = 1, :err = 0, :median_ms = 2.345, :total_ms = 4.7 ]
	When("written as results.json's text and read back")
	cJ = AtelierResultsJson(aState, aRun, "abc123", 2)
	aBack = StzJsonToList(cJ)
	Then("the library is named", aBack[:library], "abc123 on main")
	Then("the engine is named", aBack[:engine], "the package's")
	Then("the counts survive", "" + aBack[:pass] + "/" + aBack[:fail] + "/" + aBack[:err], "1/1/0")
	Then("the states survive", AtelierStatesOf(aBack)[2][2], "fail")
	Then("and compare equal to the run's", len(AtelierMoved(aRun[:states], AtelierStatesOf(aBack))), 0)
EndScenario()

Scenario("A folder without the library does not boot, and says so")
	Given("the guard's own folder, which holds no stzLib.ring")
	oNo = AtelierBoot(cAtAtelier, nAtPort, cAtHere, cAtSettings)
	When("asked to be ready")
	aS = AtelierWaitReady(nAtPort, 20000, oNo)
	Then("there is no library state", aS[:library][:state], "")
	Then("the reason is the child's own line", StzFindFirst("no stzLib.ring", aS[:library][:why]) > 0, TRUE)
	if oNo.IsRunning()  oNo.Kill()  ok
EndScenario()

#============================================================================
Scenario("An Atelier boots on the library this checkout holds")
	Given("the Atelier's folder, three levels up from here")
	nAtT0 = clock()
	oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
	When("the library is admitted in the background")
	aAtState = AtelierWaitReady(nAtPort, 180000, oAt)
	if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	Then("it took seconds, not minutes", aAtState[:library][:seconds] > 0 and aAtState[:library][:seconds] < 180, TRUE)
	Then("the library's commit is named", aAtState[:library][:commit] != "" and aAtState[:library][:commit] != "unknown", TRUE)
	Then("the rnxc build is named", aAtState[:rnxc][:build] != "" and aAtState[:rnxc][:build] != "unknown", TRUE)
	Then("the engine is named", StzFindFirst("none found", aAtState[:engine]) = 0, TRUE)
	? "    judged by: the library " + aAtState[:library][:commit] + ", admitted in " + aAtState[:library][:seconds] + " s"
	? "               rnxc " + aAtState[:rnxc][:build]
	? "               the engine: " + aAtState[:engine]
EndScenario()

Scenario("A check passes, fails or errors as the page decides it")
	Given("three planted checks")
	cPass = "func Run cInput" + char(10) + char(9) + 'return AtelierThen(Q("abc").Uppercased(), "ABC")' + char(10)
	cFail = "func Run cInput" + char(10) + char(9) + 'return AtelierThen(Q("abc").Uppercased(), "ABX")' + char(10)
	cErr = "func Run cInput" + char(10) + char(9) + 'return AtelierThen(NoSuchFunctionInTheAtelier(1), 1)' + char(10)
	When("each is admitted, called and released")
	aP = AtelierRunCheck(nAtPort, cPass)
	aF = AtelierRunCheck(nAtPort, cFail)
	aE = AtelierRunCheck(nAtPort, cErr)
	Then("the first passes", aP[:kind], "pass")
	Then("and says PASS", aP[:text], "PASS")
	Then("the second fails", aF[:kind], "fail")
	Then("showing what was expected and what came, as @@ shows them", aF[:text], "FAIL" + char(10) + '"ABX"' + char(10) + '"ABC"')
	Then("the third errors", aE[:kind], "err")
	Then("with a 500", aE[:status], 500)
	Then("naming the missing function", StzFindFirst("nosuchfunctionintheatelier", lower(aE[:text])) > 0, TRUE)
EndScenario()

Scenario("The program after a request is the program before it")
	Given("the number of functions in the program")
	nBefore = AtelierState(nAtPort)[:functions]
	When("a playground body with its own helper runs")
	cPlay = "func Run cInput" + char(10) + char(9) + "return AtelierShow(AtelierBody())" + char(10) + char(10) + "func AtelierBody" + char(10) + 'return [ Q("abc").Uppercased(), 3 ]' + char(10)
	aR = AtelierRunCheck(nAtPort, cPlay)
	Then("the answer is shown as Softanza shows a list", aR[:text], '[ "ABC", 3 ]')
	Then("and the program holds the same functions as before", AtelierState(nAtPort)[:functions], nBefore)
EndScenario()

#============================================================================
Scenario("Every check runs over HTTP, and no verdict moved against the last recording")
	Given("checks.json and results.json, the last recording")
	aChecks = StzJsonToList(read(cAtAtelier + "/checks.json"))
	aResults = StzJsonToList(read(cAtAtelier + "/results.json"))
	aBaseline = AtelierStatesOf(aResults)
	? "    " + len(aChecks[:checks]) + " checks harvested from " + aChecks[:source] + " at " + aChecks[:commit]
	? "    the recording: " + aResults[:pass] + " pass, " + aResults[:fail] + " fail, " + aResults[:err] + " error, judged by the library " + aResults[:library] + ", rnxc " + aResults[:rnxc] + ", the engine " + aResults[:engine]
	When("every check runs")
	aRun = AtelierRunChecks(nAtPort, aChecks[:checks], 0)
	? "    this run:      " + aRun[:pass] + " pass, " + aRun[:fail] + " fail, " + aRun[:err] + " error; a check " + _AtelierNum(aRun[:median_ms]) + " ms median, " + _AtelierNum(aRun[:total_ms] / 1000) + " s in all"
	aMoved = AtelierMoved(aBaseline, aRun[:states])
	if len(aMoved) > 0
		? "    MOVED since the recording (id: was > now):"
		for i = 1 to len(aMoved)
			? "      " + aMoved[i][:id] + ": " + aMoved[i][:was] + " > " + aMoved[i][:now]
			# what the check said now: a moved id without its words cost a rerun to read
			# (B3, 2026-11-06: one check erred once in two runs, and nothing said why)
			for k = 1 to len(aRun[:said])
				if aRun[:said][k][1] = aMoved[i][:id]
					? "        it said: " + left(substr(substr(aRun[:said][k][2], char(13), ""), char(10), " | "), 300)
				ok
			next
		next
	ok
	Then("every check was run", len(aRun[:states]), len(aChecks[:checks]))
	Then("the recording covers the same checks", len(aBaseline), len(aChecks[:checks]))
	Then("no verdict moved", len(aMoved), 0)
	Then("the counts are the recording's", "" + aRun[:pass] + "/" + aRun[:fail] + "/" + aRun[:err], "" + aResults[:pass] + "/" + aResults[:fail] + "/" + aResults[:err])
	Then("a check takes milliseconds", aRun[:median_ms] < 50, TRUE)
EndScenario()

Scenario("The Atelier stops when asked")
	Given("the running Atelier")
	When("POST /atelier/stop")
	bStopped = AtelierStop(nAtPort)
	nExit = oAt.WaitFor(10000)
	Then("it answered", bStopped, TRUE)
	Then("and the child ended", nExit != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
? "guard wall time: " + ((clock() - nAtT0) / clockspersecond()) + " s from the first boot"
shutdown($_zst_fail)
