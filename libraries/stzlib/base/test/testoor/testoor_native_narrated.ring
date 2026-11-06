load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P3.5 -- THE NATIVE RUNNER. The walk loop, the judge and the logbook now run in a program
# with no Ring virtual machine in it (engine/src/testoor_main.zig, `testoor run MANIFEST`), so that a
# command line that is not Ring -- the stz CLI -- can call Testoor's runner as a child and read its
# logbook and its exit code. This guard holds that program to the Ring runner: THE SAME TOURS, WALKED
# BY EACH, MUST READ THE SAME. State, ending, exit code, seed, every stop and every claim; only the
# milliseconds differ, because two walks never take the same time.
#
# The Ring face still READS the tours (reading a source file into a tour record is the face's work);
# TestoorManifestJson hands the native runner what it read, the argv and the ending rules, and the
# native runner walks, judges and logs.
#
# Every positive has its sibling: a tour that fails reads diverged on both; one that breaks midway
# reads broke; one that hangs is killed at the deadline on both AND the native runner itself returns
# promptly (a grandchild once kept it alive for 29 s); a flaky tour is found flaky by each; a manifest
# that cannot be read is refused with exit 2, not walked.
#
# The native runner is built with `cd engine && zig build testoor-exe -j2` and found through the
# TESTOOR_EXE variable or engine/zig-out/bin/testoor.exe beside the library. When it is not there this
# guard says so by name and runs nothing: a gate owned and not run.

? "TESTOOR P3.5 -- the native runner"
nNvStart = clock()
cNvExe = TestoorNativeExe()
cNvHere = currentdir()
cNvPlant = cNvHere + "/_planted_native"

if cNvExe = ""
	? ""
	? "SKIPPED by name, because the native runner is not built:"
	? "  every section (the parity of the Ring runner and the native one, flakiness, the deadline, a self-describing tour, a refusal)"
	? "  build it with: cd engine && zig build testoor-exe -j2, then set TESTOOR_EXE to zig-out/bin/testoor.exe"
else

_NvPlantAll(cNvPlant)
acNvFiles = [ cNvPlant + "/kept.ring", cNvPlant + "/fails.ring", cNvPlant + "/broke.ring", cNvPlant + "/hang.ring", cNvPlant + "/selfdesc.ring" ]

#============================================================================
Scenario("The native runner answers, and refuses what it cannot read")
	nNvSec = clock()
	aV = _NvRun([ "version" ])
	Then("it says what it is", StzFindFirst("testoor 3.5", aV[2]) > 0, TRUE)
	aMissing = _NvRun([ "run", cNvPlant + "/no_such_manifest.json", "--json" ])
	Then("a manifest that is not there is refused: exit 2", aMissing[1], 2)
	Then("with a logbook that says why", StzFindFirst('"refusal":"cannot read the manifest', aMissing[2]) > 0, TRUE)
	write(cNvPlant + "/not_json.json", "this is not json")
	aBad = _NvRun([ "run", cNvPlant + "/not_json.json", "--json" ])
	Then("a manifest that is not JSON is refused too", aBad[1], 2)
	aNoArgs = _NvRun([ "run" ])
	Then("and a command with no manifest is a usage error: exit 2", aNoArgs[1], 2)
EndScenario()
? "        [section took " + ((clock() - nNvSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Five tours, walked by the Ring runner and by the native one, read the same")
	nNvSec = clock()
	Given("a tour that holds, one that fails, one that breaks midway, one that hangs, and one that describes itself")
	oRing = TravellerQ().Silent().Timeout(3000).Seed(5)
	for i = 1 to len(acNvFiles)
		oRing.Walk(acNvFiles[i])
	next
	cRingJson = oRing.Json()
	nRingExit = oRing.ExitCode()
	cManifest = TestoorManifestJson(acNvFiles, [ :by = "native", :seed = 5, :repeat = 1, :timeout_ms = 3000 ])
	write(cNvPlant + "/manifest.json", cManifest)
	aNative = _NvRun([ "run", cNvPlant + "/manifest.json", "--json" ])
	Then("the native runner gave a logbook", left(aNative[2], 19), '{"testoor":"logbook')
	aR = StzJsonToList(cRingJson)
	aN = StzJsonToList(aNative[2])
	Then("both walked five tours", "" + aR[:owned] + "/" + aR[:run] + " " + aN[:owned] + "/" + aN[:run], "5/5 5/5")
	Then("the run's exit code is the same: the runner's, not a tour's", aNative[1], nRingExit)
	Then("and it is 1: one tour failed, one broke, one hung", nRingExit, 1)
	Then("the run reads the same: seed, claims, how the tours ended", _NvRunCanon(aN), _NvRunCanon(aR))
	nBad = 0
	for i = 1 to 5
		cR = _NvTourCanon(aR[:tours][i])
		cN = _NvTourCanon(aN[:tours][i])
		if cR != cN
			nBad++
			? "        DIFFERS: " + acNvFiles[i]
			? "          ring   " + cR
			? "          native " + cN
		ok
	next
	Then("every tour reads the same: state, ending, exit, seed, stops and claims", nBad, 0)
	Then("the one that holds is kept", aN[:tours][1][:state], "kept")
	Then("the one that fails is diverged", aN[:tours][2][:state], "diverged")
	Then("the one that breaks ended broke", aN[:tours][3][:end], "broke")
	Then("the one that hangs ended hung, killed at the deadline", aN[:tours][4][:end], "hung")
	Then("and the self-describing one, with no record in the manifest, is kept", aN[:tours][5][:state] + "/" + aN[:tours][5][:dialect], "kept/protocol")
EndScenario()
? "        [section took " + ((clock() - nNvSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A flaky tour is found flaky by both, and a stable one is not")
	nNvSec = clock()
	acFlaky = [ cNvPlant + "/flaky.ring", cNvPlant + "/kept.ring" ]
	_NvClearMarker(cNvPlant)
	oRingF = TravellerQ().Silent().Timeout(6000).Seed(5).Repeat(2)
	oRingF.Walk(acFlaky[1])
	oRingF.Walk(acFlaky[2])
	aRF = StzJsonToList(oRingF.Json())
	_NvClearMarker(cNvPlant)
	write(cNvPlant + "/manifest_flaky.json", TestoorManifestJson(acFlaky, [ :seed = 5, :repeat = 2, :timeout_ms = 6000 ]))
	aNF = StzJsonToList(_NvRun([ "run", cNvPlant + "/manifest_flaky.json", "--json" ])[2])
	_NvClearMarker(cNvPlant)
	Then("the Ring runner finds the first tour flaky and not the second", "" + aRF[:tours][1][:flaky] + "/" + aRF[:tours][2][:flaky], "1/0")
	Then("so does the native runner", "" + aNF[:tours][1][:flaky] + "/" + aNF[:tours][2][:flaky], "1/0")
	Then("a flaky tour makes the run exit 1 in both", "" + aRF[:exit] + "/" + aNF[:exit], "1/1")
EndScenario()
? "        [section took " + ((clock() - nNvSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The deadline holds: a hung tour is killed, and the native runner itself returns promptly")
	nNvSec = clock()
	write(cNvPlant + "/manifest_hang.json", TestoorManifestJson([ cNvPlant + "/hang.ring" ], [ :seed = 5, :timeout_ms = 2500 ]))
	nT0 = clock()
	aH = _NvRun([ "run", cNvPlant + "/manifest_hang.json", "--json" ])
	nWholeS = (clock() - nT0) / clockspersecond()
	aHJ = StzJsonToList(aH[2])
	? "        the whole native process took " + nWholeS + " s for a 2.5 s deadline"
	Then("the tour ended hung", aHJ[:tours][1][:end], "hung")
	Then("the runner exits 1", aH[1], 1)
	Then("the kill reads as the Ring runner's: exit -3", aHJ[:tours][1][:exit], -3)
	Then("and the process returned within seconds of the deadline, not when the child would have", nWholeS < 9, TRUE)
EndScenario()
? "        [section took " + ((clock() - nNvSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A gate's floor of evidence: a run whose every tour holds still exits 1 when the walk is too thin")
	nNvSec = clock()
	acThin = [ cNvPlant + "/kept.ring" ]
	Given("one tour that holds, with two kept claims and no route walked")
	cFloorA = '{"posture":"human","tier":"normal","floor":{"min_kept":2}}'
	cFloorB = '{"posture":"llm","tier":"critical","floor":{"min_kept":3}}'
	cFloorC = '{"posture":"llm","tier":"critical","floor":{"min_kept":1,"min_routes":1}}'
	write(cNvPlant + "/manifest_a.json", TestoorManifestJson(acThin, [ :seed = 5, :timeout_ms = 6000, :evidence_json = cFloorA ]))
	write(cNvPlant + "/manifest_b.json", TestoorManifestJson(acThin, [ :seed = 5, :timeout_ms = 6000, :evidence_json = cFloorB ]))
	write(cNvPlant + "/manifest_c.json", TestoorManifestJson(acThin, [ :seed = 5, :timeout_ms = 6000, :evidence_json = cFloorC ]))
	aFA = _NvRun([ "run", cNvPlant + "/manifest_a.json", "--json" ])
	aFB = _NvRun([ "run", cNvPlant + "/manifest_b.json", "--json" ])
	aFC = _NvRun([ "run", cNvPlant + "/manifest_c.json", "--json" ])
	aJA = StzJsonToList(aFA[2])
	aJB = StzJsonToList(aFB[2])
	aJC = StzJsonToList(aFC[2])
	Then("a floor of two kept claims is met: the gate accepts, exit 0", "" + aFA[1] + "/" + aJA[:evidence][:met], "0/1")
	Then("a floor of three is not, though the tour is kept: the gate refuses, exit 1", "" + aFB[1] + "/" + aJB[:evidence][:met], "1/0")
	Then("and the record says why", aJB[:evidence][:why], "kept 2 is below the floor's min_kept 3")
	Then("a floor that asks for a route nobody walked is not met either", "" + aFC[1] + "/" + aJC[:evidence][:met], "1/0")
	Then("naming the routes", aJC[:evidence][:why], "routes walked 0 is below the floor's min_routes 1")
	Then("the tour itself is kept in every one of them: the floor is the gate's verdict, not the tour's", aJB[:tours][1][:state], "kept")
	Then("a run with no floor carries no evidence record and no protocol key", StzFindFirst('"evidence":{', aNative[2]) + StzFindFirst('"protocol":2', aNative[2]), 0)
EndScenario()
? "        [section took " + ((clock() - nNvSec) / clockspersecond()) + "s]"

_NvUnplantAll(cNvPlant)

ok

? ""
? "[P3.5 took " + ((clock() - nNvStart) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

# run the native runner with these arguments: [ exit code, what it printed ]
func _NvRun(pacArgs)
	_oP_ = new stzProcess()
	_aArgv_ = [ TestoorNativeExe() ]
	_n_ = len(pacArgs)
	for _i_ = 1 to _n_
		_aArgv_ + pacArgs[_i_]
	next
	_oP_.SpawnIn(currentdir(), _aArgv_)
	_cOut_ = _oP_.ReadOutputAll()
	_nX_ = _oP_.Wait()
	_oP_.Close()
	return [ _nX_, _cOut_ ]

# one tour, as text, without the milliseconds two walks never share
func _NvTourCanon(paT)
	_c_ = paT[:file] + "|" + paT[:dialect] + "|" + paT[:state] + "|" + paT[:end] + "|exit " + paT[:exit] + "|seed " + paT[:seed] +
	      "|flaky " + paT[:flaky] + "|" + paT[:kept] + "/" + paT[:diverged] + "/" + paT[:unreached] + "/" + paT[:unjudged]
	_nS_ = len(paT[:stops])
	for _s_ = 1 to _nS_
		_c_ += "|[" + paT[:stops][_s_][:title] + ":" + paT[:stops][_s_][:line] + ":" + paT[:stops][_s_][:state]
		_nC_ = len(paT[:stops][_s_][:claims])
		for _k_ = 1 to _nC_
			_c_ += "{" + paT[:stops][_s_][:claims][_k_][:claim] + ":" + paT[:stops][_s_][:claims][_k_][:state] + "}"
		next
		_c_ += "]"
	next
	return _c_

# the run, as text, without its times
func _NvRunCanon(paR)
	return "exit " + paR[:exit] + "|owned " + paR[:owned] + "|run " + paR[:run] + "|seed " + paR[:seed] + "|repeat " + paR[:repeat] + "|flaky " + paR[:flaky] +
	       "|claims " + paR[:claims][:kept] + "/" + paR[:claims][:diverged] + "/" + paR[:claims][:unreached] + "/" + paR[:claims][:unjudged] +
	       "|ends " + paR[:tours_by_end][:finished] + "/" + paR[:tours_by_end]["finished-timed"] + "/" + paR[:tours_by_end]["not-started"] + "/" +
	       paR[:tours_by_end][:broke] + "/" + paR[:tours_by_end][:hung] + "/" + paR[:tours_by_end][:unreadable]

func _NvClearMarker(pcRoot)
	if fexists(pcRoot + "/nv_flaky_marker.txt")  remove(pcRoot + "/nv_flaky_marker.txt")  ok

func _NvPlantAll(pcRoot)
	_NvUnplantAll(pcRoot)
	StzMakeDir(pcRoot)
	_n_ = char(10)
	write(pcRoot + "/kept.ring", '? "  [OK] the first thing holds"' + _n_ + '? "  [OK] the second thing holds"' + _n_)
	write(pcRoot + "/fails.ring", '? "  [OK] this one holds"' + _n_ + '? "  [FAIL] this one does not"' + _n_)
	write(pcRoot + "/broke.ring", '? "  [OK] before the break"' + _n_ + 'x = 0 + "abc"' + _n_ + '? "  [OK] never printed"' + _n_)
	write(pcRoot + "/hang.ring", '? "  [OK] alive"' + _n_ + "while 1" + _n_ + "end" + _n_)
	write(pcRoot + "/selfdesc.ring", '? "[testoor stop it says what it is]"' + _n_ + '? "[testoor ok it said so]"' + _n_)
	write(pcRoot + "/flaky.ring",
		'cM = "nv_flaky_marker.txt"' + _n_ +
		"if fexists(cM)" + _n_ +
		'	? "  [OK] second time lucky"' + _n_ +
		"else" + _n_ +
		'	write(cM, "1")' + _n_ +
		'	? "  [FAIL] first time unlucky"' + _n_ +
		"ok" + _n_)

func _NvUnplantAll(pcRoot)
	if fexists(pcRoot + "/kept.ring")
		StzDirDeleteAll(pcRoot)
	ok
