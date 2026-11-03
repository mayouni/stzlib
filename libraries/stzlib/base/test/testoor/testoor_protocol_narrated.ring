load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR PROTOCOL -- CONFORMANCE. The core of Testoor (runner, judge, routes,
# seeds, logbook) must not know the language a tour is written in; what it
# knows is TESTOOR_PROTOCOL.md. This guard proves it the only way that counts:
# it runs tours written in PYTHON through the same runner, with a face that
# is nothing but a registered profile, and gets the same logbook.
#
#   - a kept tour, a failing tour, a tour that breaks with claims still owed,
#     one that never starts, one that ends with claims unmade, a seeded tour
#     that fails at 42 and passes at 43, a tour that names its own seed, a
#     tour that declares a route -- every one prints only protocol lines
#   - one runner walks a folder holding a Ring tour and a Python tour and
#     answers ONE logbook; a program that is not Ring (python) checks that
#     logbook against the key list the protocol publishes
#   - a language with no face is NAMED, not guessed and not run; a face that
#     has no launch is read-only; a third face registered at run time works
#
# Python is the reference second language because it is on this machine; the
# guard does not care which it is. It needs `python` on the path.
#
# WHAT THE PROTOCOL DOES NOT REACH, said plainly: a self-describing tour can
# only be judged on what it prints. A claim it never announces is not a claim
# the runner knows about; [testoor plan N] is the tour's own promise of N, and
# the runner holds it to that.

? "TESTOOR PROTOCOL -- conformance"
nTpStart = clock()
cTpHere = currentdir()
cTpPlant = cTpHere + "/_planted_protocol"
TestoorUnregisterFaces()
aTpPy = [ :name = "python", :ext = ".py", :reader = "protocol", :program = "python",
          :launch = [ "{program}", "{file}", "--testoor-seed", "{seed}" ], :ignore = "",
          :endings = [ [ "SyntaxError", "not-started" ], [ "Traceback (most recent call last)", "broke" ] ] ]
TestoorRegisterFace(aTpPy)
_TpPlantAll(cTpPlant)

#============================================================================
Scenario("A tour in another language is judged by the same runner, from the lines it prints")
	nTpSec = clock()
	Given("a Python tour that prints two stops, three kept claims and the timed ending")
	oK = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/kept.py")
	aK = oK.Records()[1]
	Then("the reader recognised a self-describing tour", aK[:dialect], "protocol")
	Then("it is kept", aK[:run][:state], "kept")
	Then("and finished, timed", aK[:run][:end], "finished-timed")
	Then("two stops were announced", len(aK[:run][:stops]), 2)
	Then("named as the tour named them", aK[:run][:stops][1][:title], "first place")
	Then("the first stop has two claims", len(aK[:run][:stops][1][:claims]), 2)
	Then("and the second claim is the text it printed", aK[:run][:stops][1][:claims][2][:claim], "two is two")
	Then("three claims kept, none diverged", "" + aK[:run][:kept] + "/" + aK[:run][:diverged], "3/0")
	Then("the runner exits 0", oK.ExitCode(), 0)
	Given("a Python tour whose second claim fails")
	oF = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/failing.py")
	aF = oF.Records()[1]
	Then("one claim is kept and one diverged", "" + aF[:run][:kept] + "/" + aF[:run][:diverged], "1/1")
	Then("the diverged claim is named", aF[:run][:stops][1][:claims][2][:claim], "the bad one")
	Then("the tour is diverged", aF[:run][:state], "diverged")
	Then("the runner exits 1", oF.ExitCode(), 1)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A tour that breaks leaves its owed claims unreached; one that never starts is not-started; one that ends early leaves them unjudged")
	nTpSec = clock()
	Given("a Python tour that announces 3 claims, keeps 1 and then divides by zero")
	oB = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/broke.py")
	aB = oB.Records()[1]
	Then("it broke, read from the face's own error text", aB[:run][:end], "broke")
	Then("one claim is kept", aB[:run][:kept], 1)
	Then("the two it owed are UNREACHED, not failed", aB[:run][:unreached], 2)
	Then("none diverged", aB[:run][:diverged], 0)
	Then("the runner exits 1: a tour that broke", oB.ExitCode(), 1)
	Given("a Python file with a syntax error")
	oN = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/nostart.py")
	Then("it did not start", oN.Records()[1][:run][:end], "not-started")
	Then("the runner exits 1", oN.ExitCode(), 1)
	Given("a Python tour that announces 3 claims, keeps 1 and ends normally")
	oU = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/planned.py")
	aU = oU.Records()[1]
	Then("it ran to its end", aU[:run][:end], "finished")
	Then("the two claims it never made are UNJUDGED", aU[:run][:unjudged], 2)
	Then("not unreached", aU[:run][:unreached], 0)
	Then("and not a failure: the runner exits 0", oU.ExitCode(), 0)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The seed crosses the language boundary: fails at 42, passes at 43, and the tour may name its own")
	nTpSec = clock()
	Given("a Python tour that fails exactly when it is handed seed 42, walked twice")
	oA = TravellerQ().Silent().Timeout(30000).Seed(42).Walk(cTpPlant + "/seeded.py")
	oB2 = TravellerQ().Silent().Timeout(30000).Seed(42).Walk(cTpPlant + "/seeded.py")
	Then("it fails", oA.Records()[1][:run][:state], "diverged")
	Then("identically the second time", _TravSignature(oB2.Records()[1]), _TravSignature(oA.Records()[1]))
	Then("the logbook carries the seed", oA.Records()[1][:run][:seed], 42)
	oC = TravellerQ().Silent().Timeout(30000).Seed(43).Walk(cTpPlant + "/seeded.py")
	Then("with seed 43 it passes", oC.Records()[1][:run][:state], "kept")
	Then("the runner exits 0", oC.ExitCode(), 0)
	Given("a Python tour that prints [testoor seed 7] under a runner offering 42")
	oD = TravellerQ().Silent().Timeout(30000).Seed(42).Walk(cTpPlant + "/own_seed.py")
	Then("the seed the tour named is the one recorded", oD.Records()[1][:run][:seed], 7)
	Given("the same tour walked twice with --repeat")
	oR2 = TravellerQ().Silent().Timeout(30000).Seed(42).Repeat(2).Walk(cTpPlant + "/seeded.py")
	Then("a tour fully determined by its seed is not flaky", oR2.Records()[1][:flaky], 0)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Routes are declared the same way in any language")
	nTpSec = clock()
	Given("a Python tour that prints [testoor route ZA1]")
	oRt = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/route.py")
	aRt = oRt.Records()[1]
	Then("the route is in the tour's record", len(aRt[:routes]), 1)
	Then("named", aRt[:routes][1][:item], "ZA1")
	Then("and at the stop it was declared in", aRt[:routes][1][:stop], "a routed place")
	oMap = StzRouteMapQ().AddPlan("plan", "### ZA1 -- first" + char(10) + "CLOSED: shipped." + char(10) +
	       "### ZA2 -- second" + char(10) + "CLOSED: shipped." + char(10)).AddTour(aRt)
	Then("the map counts it walked", oMap.WalkedCount(), 1)
	Then("and the other closed route unwalked", oMap.Unwalked()[1][1], "ZA2")
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("One runner, two languages, one logbook -- checked by a program that is not Ring")
	nTpSec = clock()
	Given("a folder holding a Ring tour and a Python tour")
	oMix = TravellerQ().Silent().Timeout(60000).Seed(5).WalkTree(cTpPlant + "/mix")
	Then("both were owned and run", "" + oMix.Owned() + "/" + oMix.Run(), "2/2")
	Then("both are kept", oMix.Counts()[:kept], 2)
	Then("the runner exits 0", oMix.ExitCode(), 0)
	cJson = oMix.Json()
	Then("the logbook is valid JSON", StzJsonIsValid(cJson), TRUE)
	write(cTpPlant + "/logbook.json", cJson)
	write(cTpPlant + "/need.json", TestoorLogbookKeysJson())
	oP = new stzProcess()
	oP.SpawnIn(cTpPlant, [ "python", "check_keys.py", "logbook.json", "need.json" ])
	cOut = trim(oP.ReadOutputAll())
	oP.Wait()
	oP.Close()
	? "        (python says: " + cOut + ")"
	Then("python finds every key the protocol publishes, at all four levels", left(cOut, 7), "KEYS OK")
	Then("in both tours", right(cOut, 1), "2")
	Given("a logbook with a key missing")
	write(cTpPlant + "/logbook_bad.json", substr(cJson, '"claims":', '"claimz":'))
	oP2 = new stzProcess()
	oP2.SpawnIn(cTpPlant, [ "python", "check_keys.py", "logbook_bad.json", "need.json" ])
	cBad = trim(oP2.ReadOutputAll())
	oP2.Wait()
	oP2.Close()
	Then("the checker is not a rubber stamp: it names what is missing", left(cBad, 7), "MISSING")
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A language with no face is named, not guessed; a read-only face is not run; a face can be registered by anyone")
	nTpSec = clock()
	Given("a file in a language nobody has given a face")
	aH = Tour(cTpPlant + "/other/x.haro")
	Then("it is readable text", aH[:readable], 1)
	Then("and its dialect is unknown", aH[:dialect], "unknown")
	Then("the record says why, naming the protocol", StzFindFirst("no face is registered", aH[:why]) > 0 and StzFindFirst("TESTOOR_PROTOCOL.md", aH[:why]) > 0, TRUE)
	Then("the folder walker does not even list it", _TpListed(cTpPlant + "/other", "x.haro"), FALSE)
	oH = TravellerQ().Silent().Timeout(30000).Walk(cTpPlant + "/other/x.haro")
	Then("walked by name, it is not run: unreadable", oH.Records()[1][:run][:end], "unreadable")
	Then("the runner exits 1", oH.ExitCode(), 1)
	Given("Zin's .zst, which has a reader and no way to launch")
	oZ = TravellerQ().Silent().Timeout(30000).Walk(cTpPlant + "/other/y.zst")
	Then("it is not run either", oZ.Records()[1][:run][:end], "unreadable")
	Then("and says it is read-only", StzFindFirst("read-only", oZ.Records()[1][:why]) > 0, TRUE)
	Given("a third face registered at run time for the extension .pyt")
	aPyt = aTpPy
	aPyt[:name] = "pyt"
	aPyt[:ext] = ".pyt"
	TestoorRegisterFace(aPyt)
	oT = TravellerQ().Silent().Timeout(30000).Seed(5).Walk(cTpPlant + "/other/third.pyt")
	Then("a tour in it is walked and kept", oT.Records()[1][:run][:state], "kept")
	Then("and the folder walker now lists it", _TpListed(cTpPlant + "/other", "third.pyt"), TRUE)
	TestoorUnregisterFaces()
	Then("unregistered, the extension is unknown again", Tour(cTpPlant + "/other/third.pyt")[:dialect], "unknown")
	Given("a Ring tour, which has a face built in")
	TestoorRegisterFace(aTpPy)
	oG = TravellerQ().Silent().Timeout(60000).Seed(5).Walk(cTpPlant + "/mix/a_ring.ring")
	Then("it is judged as it always was", oG.Records()[1][:run][:kept], 1)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

TestoorUnregisterFaces()
_TpUnplantAll(cTpPlant)
? ""
? "[PROTOCOL took " + ((clock() - nTpStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

# the six-line helper a language needs (TESTOOR_PROTOCOL.md section 3), plus a body
func _TpPy(acBody)
	c = "import sys" + char(10) +
	    'def stop(t): print("[testoor stop " + t + "]", flush=True)' + char(10) +
	    'def ok(t): print("[testoor ok " + t + "]", flush=True)' + char(10) +
	    'def fail(t): print("[testoor fail " + t + "]", flush=True)' + char(10)
	n = len(acBody)
	for i = 1 to n
		c += acBody[i] + char(10)
	next
	return c

func _TpPlantAll(cRoot)
	_TpUnplantAll(cRoot)
	StzMakeDir(cRoot)
	StzMakeDir(cRoot + "/mix")
	StzMakeDir(cRoot + "/other")
	write(cRoot + "/kept.py", _TpPy([ 'stop("first place")', 'ok("one is one")', 'ok("two is two")',
		'stop("second place")', 'ok("three is three")', 'print("[testoor end timed]")' ]))
	write(cRoot + "/failing.py", _TpPy([ 'stop("a place")', 'ok("the good one")', 'fail("the bad one")' ]))
	write(cRoot + "/broke.py", _TpPy([ 'print("[testoor plan 3]", flush=True)', 'stop("a place")',
		'ok("before the break")', 'x = 1 / 0', 'ok("never reached")' ]))
	write(cRoot + "/nostart.py", "import sys" + char(10) + "def (:" + char(10) + 'print("[testoor ok never]")' + char(10))
	write(cRoot + "/planned.py", _TpPy([ 'print("[testoor plan 3]", flush=True)', 'stop("a place")', 'ok("only one")' ]))
	write(cRoot + "/seeded.py", _TpPy([ 'seed = int(sys.argv[sys.argv.index("--testoor-seed") + 1])',
		'print("[testoor seed " + str(seed) + "]", flush=True)', 'stop("the seeded place")',
		'if seed == 42: fail("seed 42 is the unlucky one")', 'else: ok("this seed is lucky enough")' ]))
	write(cRoot + "/own_seed.py", _TpPy([ 'print("[testoor seed 7]", flush=True)', 'stop("a place")', 'ok("seeded by the tour itself")' ]))
	write(cRoot + "/route.py", _TpPy([ 'stop("a routed place")', 'print("[testoor route ZA1]", flush=True)', 'ok("walked")' ]))
	write(cRoot + "/mix/a_ring.ring", '? "  [OK] a ring claim in a mixed folder"' + char(10))
	write(cRoot + "/mix/b_py.py", _TpPy([ 'stop("a python place in a mixed folder")', 'ok("a python claim")' ]))
	write(cRoot + "/other/x.haro", "this tour is written in a language with no face" + char(10))
	write(cRoot + "/other/y.zst", "DEFINE NARRATED_TEST y AS ( )" + char(10))
	write(cRoot + "/other/third.pyt", _TpPy([ 'stop("a third-party place")', 'ok("a third-party claim")' ]))
	# the independent checker: a program that is not Ring reads the logbook
	write(cRoot + "/check_keys.py",
		"import json, sys" + char(10) +
		'd = json.load(open(sys.argv[1], encoding="utf-8"))' + char(10) +
		'need = json.load(open(sys.argv[2], encoding="utf-8"))' + char(10) +
		'bad = [k for k in need["run"] if k not in d]' + char(10) +
		'for t in d.get("tours", []):' + char(10) +
		'    bad += ["tour." + k for k in need["tour"] if k not in t]' + char(10) +
		'    for s in t.get("stops", []):' + char(10) +
		'        bad += ["stop." + k for k in need["stop"] if k not in s]' + char(10) +
		'        for c in s.get("claims", []):' + char(10) +
		'            bad += ["claim." + k for k in need["claim"] if k not in c]' + char(10) +
		'print("KEYS OK " + str(len(d["tours"])) if not bad else "MISSING " + ",".join(sorted(set(bad))))' + char(10))

# is a file of this name among the tours the folder walker lists?
func _TpListed(cDir, cName)
	aFiles = _TourFilesUnder(cDir, "")[1]
	n = len(aFiles)
	for i = 1 to n
		if right(aFiles[i], len(cName)) = cName  return TRUE  ok
	next
	return FALSE

func _TpUnplantAll(cRoot)
	if fexists(cRoot + "/kept.py")
		StzDirDeleteAll(cRoot)
	ok
