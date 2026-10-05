load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR TR1 -- THE RUNNER. One process per batch, many tours; the exit
# code is the runner's, never Ring's; JSON on a pipe and prose on a terminal
# from one run; wall time per stop; skipped by name; owned and run as two
# figures; pf() as a state.
#
# WHAT IS PLANTED, AND WHY PLANTED. The tours below are written into
# _planted/ beside this guard (a leading "_" is what the reader skips, and
# the folder is ignored by git), one topic folder per outcome, each tour a
# standalone Ring file that needs no library -- so a child starts in tens of
# milliseconds and the guard measures the RUNNER, not the library's load.
# Then the real uuid topic is walked once, for the shape against the corpus.
#
#   pass/    01 two scenes, three [OK]           -> kept, two stops timed
#            02 two promises, next-line and trailing -> kept
#            03 a claim then pf()'s STOPPED!     -> kept, finished-timed
#            04 a claim in a branch never taken  -> unjudged, NOT a failure
#            _skipme.ring                        -> skipped by name
#   fail/    01 a [FAIL]                         -> diverged
#            02 a promise that lies              -> diverged
#            03 a load of a file that is not there -> not-started (E9 exits 0!)
#            04 a claim, a division by zero, a claim -> broke, the second unreached
#   hang/    01 a loop that writes a heartbeat   -> hung, killed, heartbeat stops
#   nonesuch -> the runner refuses, exit 2
#
# Every exit code is read TWICE: from the traveller in this process, and
# from a CHILD `ring testoor.ring ...` through the OS -- the $? a shell sees.

? "TESTOOR TR1 -- the runner"
nTrStart = clock()
cTrHere = currentdir()
cTrPlant = cTrHere + "/_planted"
cTrTestoor = cTrHere + "/../../testoor"
_TrPlantAll(cTrPlant)

#============================================================================
Scenario("A kept tour: two stops, three claims, each stop timed")
	nTrSec = clock()
	Given("a planted tour printing two scene banners and three [OK] lines")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/pass/01_kept.ring")
	aR = oT.Records()[1][:run]
	When("the traveller walks it")
	Then("the tour is kept", aR[:state], "kept")
	Then("its child finished", aR[:end], "finished")
	Then("the child's exit was 0", aR[:exit], 0)
	Then("two stops were walked", len(aR[:stops]), 2)
	Then("the first stop is kept", aR[:stops][1][:state], "kept")
	Then("with two claims", len(aR[:stops][1][:claims]), 2)
	Then("the second stop's one claim is kept, from a lower-case [ok]",
		aR[:stops][2][:claims][1][:state], "kept")
	Then("three claims kept, none diverged", aR[:kept], 3)
	Then("none diverged", aR[:diverged], 0)
	Then("the tour has a wall time", aR[:wall_ms] > 0, TRUE)
	Then("the first stop has a wall time of its own", aR[:stops][1][:wall_ms] >= 0, TRUE)
	Then("the stop opened after the tour started", aR[:stops][1][:opened] >= 0, TRUE)
	Then("one tour owned, one run", "" + oT.Owned() + "/" + oT.Run(), "1/1")
	Then("the runner's exit code is 0", oT.ExitCode(), 0)
	Then("the seed is null until TR4", StzFindFirst('"seed":null', oT.Json()) > 0, TRUE)
	Then("the JSON is valid JSON", StzJsonIsValid(oT.Json()), TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Promises are stops: kept when the value appears, diverged when it lies")
	nTrSec = clock()
	Given("a planted tour with a next-line and a trailing promise, both true")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/pass/02_promises.ring")
	aR = oT.Records()[1][:run]
	Then("both promises are kept", aR[:kept], 2)
	Then("the tour is kept", aR[:state], "kept")
	Given("a planted tour whose promise lies")
	oF = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/fail/02_lie.ring")
	aF = oF.Records()[1][:run]
	Then("the lie is diverged", aF[:diverged], 1)
	Then("the tour is diverged", aF[:state], "diverged")
	Then("and the runner exits 1", oF.ExitCode(), 1)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("pf() is a state, never a failure; a claim in a branch not taken is unjudged, never a failure")
	nTrSec = clock()
	Given("a planted tour that keeps a claim and then ends the way pf() ends")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/pass/03_timed.ring")
	aR = oT.Records()[1][:run]
	Then("Ring exited 1 on the STOPPED! raise", aR[:exit], 1)
	Then("but the tour ended finished-timed", aR[:end], "finished-timed")
	Then("its claim is kept", aR[:kept], 1)
	Then("the tour is kept", aR[:state], "kept")
	Then("and the RUNNER exits 0", oT.ExitCode(), 0)
	Given("a planted tour with a claim inside an if that is never true")
	oU = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/pass/04_unjudged.ring")
	aU = oU.Records()[1][:run]
	Then("the printed claim is kept", aU[:kept], 1)
	Then("the silent claim is unjudged, because the tour ran to its end", aU[:unjudged], 1)
	Then("nothing is unreached", aU[:unreached], 0)
	Then("the stop is unjudged", aU[:stops][1][:state], "unjudged")
	Then("the runner exits 0: unjudged is reported, not counted against", oU.ExitCode(), 0)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A diverged claim, a tour that never starts, a tour that breaks")
	nTrSec = clock()
	Given("a planted tour printing one [OK] and one [FAIL]")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/fail/01_diverge.ring")
	aR = oT.Records()[1][:run]
	Then("one kept, one diverged", "" + aR[:kept] + "/" + aR[:diverged], "1/1")
	Then("the stop is diverged", aR[:stops][1][:state], "diverged")
	Then("the diverged claim is named", aR[:stops][1][:claims][2][:claim], "two is three")
	Then("the runner exits 1", oT.ExitCode(), 1)
	Given("a planted tour that loads a file that is not there")
	oN = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/fail/03_nostart.ring")
	aN = oN.Records()[1][:run]
	? "        (Ring's own exit on the E9 was " + aN[:exit] + " -- Ring's business, not the runner's)"
	Then("the tour did not start", aN[:end], "not-started")
	Then("its claim is unreached", aN[:unreached], 1)
	Then("the runner exits 1", oN.ExitCode(), 1)
	Given("a planted tour that keeps a claim, divides by zero, and would keep another")
	oB = TravellerQ().Silent().Timeout(10000).Walk(cTrPlant + "/fail/04_broke.ring")
	aB = oB.Records()[1][:run]
	Then("the tour broke", aB[:end], "broke")
	Then("the first claim is kept", aB[:stops][1][:claims][1][:state], "kept")
	Then("the second is unreached, not unjudged", aB[:stops][1][:claims][2][:state], "unreached")
	Then("the stop is unreached", aB[:stops][1][:state], "unreached")
	Then("the runner exits 1 -- decided here, recorded in CONCLUSIONS", oB.ExitCode(), 1)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A hung tour is killed at the deadline, reported hung, and leaves no process behind")
	nTrSec = clock()
	Given("a planted tour that loops for 30 s writing a heartbeat, and a 1.5 s deadline")
	cBeat = cTrPlant + "/hang/heartbeat.txt"
	if fexists(cBeat)  remove(cBeat)  ok
	nT0 = clock()
	oH = TravellerQ().Silent().Timeout(1500).Walk(cTrPlant + "/hang/01_hang.ring")
	nTook = (clock() - nT0) / clockspersecond()
	aH = oH.Records()[1][:run]
	Then("the tour is hung", aH[:end], "hung")
	Then("the runner came back near the deadline, not after 30 s", nTook < 6, TRUE)
	Then("its claim is unreached", aH[:unreached], 1)
	Then("the runner exits 1", oH.ExitCode(), 1)
	cBeat1 = ""
	if fexists(cBeat)  cBeat1 = read(cBeat)  ok
	nW = clock()
	while (clock() - nW) / clockspersecond() < 1.2  end
	cBeat2 = ""
	if fexists(cBeat)  cBeat2 = read(cBeat)  ok
	Then("the heartbeat was beating before the kill", len(cBeat1) > 0, TRUE)
	Then("and stopped after it: the child process is gone", cBeat2 = cBeat1, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A topic walk: owned and run as two figures, skipped by name, the other topics named, exit 0 / 1 / 2")
	nTrSec = clock()
	Given("the planted root and its pass topic")
	oP = TravellerQ().Silent().Timeout(10000).WalkTopic(cTrPlant, "pass")
	Then("four tours owned", oP.Owned(), 4)
	Then("four tours run", oP.Run(), 4)
	Then("_skipme.ring was skipped by name, and named",
		StzFindFirst("_skipme.ring", oP.Skipped()[1]) > 0, TRUE)
	Then("the topics not walked are named", len(oP.TopicsSkipped()), 2)
	Then("the pass topic exits 0", oP.ExitCode(), 0)
	Then("the JSON carries owned and run as two fields",
		StzFindFirst('"owned":4,"run":4', oP.Json()) > 0, TRUE)
	Then("the JSON is valid JSON", StzJsonIsValid(oP.Json()), TRUE)
	Given("the fail topic")
	oF = TravellerQ().Silent().Timeout(10000).WalkTopic(cTrPlant, "fail")
	Then("four owned, four run, even though two never finished", "" + oF.Owned() + "/" + oF.Run(), "4/4")
	Then("the fail topic exits 1", oF.ExitCode(), 1)
	Given("a topic that is not there")
	oRef = TravellerQ().Silent().WalkTopic(cTrPlant, "nonesuch")
	Then("the runner refuses", oRef.Refused(), TRUE)
	Then("and exits 2", oRef.ExitCode(), 2)
	Then("owning nothing", oRef.Owned(), 0)
	Then("the refusal is in the JSON", StzFindFirst('"refusal":"no such topic', oRef.Json()) > 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The exit code reaches the shell: 0, 1 and 2 read from a child ring testoor.ring")
	nTrSec = clock()
	Given("testoor.ring run as a child, from its own folder, on each planted topic")
	aPass = _TrShell(cTrTestoor, [ "--root", cTrPlant, "--topic", "pass", "--json" ])
	Then("pass: the shell sees 0", aPass[1], 0)
	Then("pass: JSON came down the pipe", StzFindFirst('"testoor":"logbook"', aPass[2]) > 0, TRUE)
	Then("pass: the JSON says exit 0", StzFindFirst('"exit":0', aPass[2]) > 0, TRUE)
	aFail = _TrShell(cTrTestoor, [ "--root", cTrPlant, "--topic", "fail", "--json" ])
	Then("fail: the shell sees 1", aFail[1], 1)
	Then("fail: the JSON says exit 1", StzFindFirst('"exit":1', aFail[2]) > 0, TRUE)
	aNone = _TrShell(cTrTestoor, [ "--root", cTrPlant, "--topic", "nonesuch" ])
	Then("nonesuch: the shell sees 2", aNone[1], 2)
	Then("nonesuch: the prose says REFUSED", StzFindFirst("REFUSED", aNone[2]) > 0, TRUE)
	aNoScope = _TrShell(cTrTestoor, [])
	Then("no scope at all: the shell sees 2", aNoScope[1], 2)
	aProse = _TrShell(cTrTestoor, [ "--root", cTrPlant, "--topic", "pass" ])
	Then("without --json the terminal gets prose, one line per tour",
		StzFindFirst("KEPT", aProse[2]) > 0 and StzFindFirst("owned 4 tours, run 4", aProse[2]) > 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The real uuid topic, walked once: the narrated tour kept, the one-off UUID promises diverged")
	nTrSec = clock()
	Given("base/test/uuid, nine tours, each loading the library in its own child")
	oU = TravellerQ().Silent().Timeout(60000).WalkTopic(cTrHere + "/..", "uuid")
	? oU.Prose()
	Then("nine owned, nine run", "" + oU.Owned() + "/" + oU.Run(), "9/9")
	aN = oU.Records()[1][:run]
	Then("00_uuid_narrated.ring is kept", aN[:state], "kept")
	Then("with four stops", len(aN[:stops]), 4)
	Then("and 17 claims kept", aN[:kept], 17)
	Then("its first stop took measurable time", aN[:stops][1][:wall_ms] >= 0, TRUE)
	Then("the pf() tours ended finished-timed", oU.Counts()[:finished_timed] >= 6, TRUE)
	Then("the recorded one-off UUIDs diverged, as the narrated file's header says they must",
		oU.Counts()[:diverged] >= 5, TRUE)
	Then("so the topic exits 1", oU.ExitCode(), 1)
	Then("the other topics were named as not walked", len(oU.TopicsSkipped()) > 100, TRUE)
EndScenario()
? "        [section took " + ((clock() - nTrSec) / clockspersecond()) + "s]"

_TrUnplantAll(cTrPlant)
? ""
? "[TR1 took " + ((clock() - nTrStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE (Ring runs a file until its first func)

func _TrPlantAll(cRoot)
	_TrUnplantAll(cRoot)
	StzMakeDir(cRoot)
	StzMakeDir(cRoot + "/pass")
	StzMakeDir(cRoot + "/fail")
	StzMakeDir(cRoot + "/hang")
	_nl_ = char(10)
	write(cRoot + "/pass/01_kept.ring",
		'? "-- Scene 1: the first stop --"' + _nl_ +
		'? "  [OK] one is one"' + _nl_ +
		'? "  [OK] two is two"' + _nl_ +
		'? "-- Scene 2: the second stop --"' + _nl_ +
		'? "  [ok] three is three"' + _nl_)
	write(cRoot + "/pass/02_promises.ring",
		"? 1 + 1" + _nl_ + "#--> 2" + _nl_ + NL +
		'? "a"  #--> a' + _nl_)
	write(cRoot + "/pass/03_timed.ring",
		'? "  [OK] a claim before the timer"' + _nl_ +
		'? "Executed in almost 0 second(s)"' + _nl_ +
		'raise("----------------" + char(10) + "    STOPPED!    ")' + _nl_)
	write(cRoot + "/pass/04_unjudged.ring",
		'? "  [OK] seen"' + _nl_ +
		"if 1 = 2" + _nl_ +
		'	? "  [OK] never printed"' + _nl_ +
		"ok" + _nl_)
	write(cRoot + "/pass/_skipme.ring", '? "  [OK] a helper, not a tour"' + _nl_)
	write(cRoot + "/fail/01_diverge.ring",
		'? "  [OK] one is one"' + _nl_ +
		'? "  [FAIL] two is three"' + _nl_)
	write(cRoot + "/fail/02_lie.ring",
		"? 1 + 1" + _nl_ + "#--> 3" + _nl_)
	write(cRoot + "/fail/03_nostart.ring",
		'load "nope_not_here.ring"' + _nl_ +
		'? "  [OK] never"' + _nl_)
	write(cRoot + "/fail/04_broke.ring",
		'? "  [OK] before the break"' + _nl_ +
		"x = 1 / 0" + _nl_ +
		'? "  [OK] after the break"' + _nl_)
	write(cRoot + "/hang/01_hang.ring",
		"n = 0" + _nl_ +
		"t0 = clock()" + _nl_ +
		"while (clock() - t0) / clockspersecond() < 30" + _nl_ +
		"	t1 = clock()" + _nl_ +
		"	while (clock() - t1) / clockspersecond() < 0.3  end" + _nl_ +
		"	n++" + _nl_ +
		'	write("heartbeat.txt", "" + n)' + _nl_ +
		"end" + _nl_ +
		'? "  [OK] never"' + _nl_)

func _TrUnplantAll(cRoot)
	if fexists(cRoot + "/pass/01_kept.ring") or fexists(cRoot + "/hang/01_hang.ring")
		StzDirDeleteAll(cRoot)
	ok

# testoor.ring as a child, from its own folder, by argv: [ exit code, output ]
# -- the exit code read here is the one the OS hands any parent, a shell
# included
func _TrShell(cTestoorDir, acArgs)
	_oP_ = new stzProcess()
	_acArgv_ = [ "ring", "testoor.ring" ]
	_n_ = len(acArgs)
	for _k_ = 1 to _n_
		_acArgv_ + acArgs[_k_]
	next
	_oP_.SpawnIn(cTestoorDir, _acArgv_)
	_cOut_ = _oP_.ReadOutputAll()
	_nX_ = _oP_.Wait()
	_oP_.Close()
	return [ _nX_, _cOut_ ]
