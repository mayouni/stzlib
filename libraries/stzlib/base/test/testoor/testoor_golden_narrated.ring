load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P2b -- THE GOLDEN LOGBOOKS. The Zig core is built against the files in
# base/testoor/golden/, so this guard does two things and keeps them apart.
#
#   1. The REFERENCE reproduces every committed expected file byte for byte from the
#      committed inputs. That keeps the goldens true: if the Ring judge changes, this
#      fails until a human has read the diff and re-blessed the files.
#
#   2. The goldens say what each case was MEANT to show. A golden produced only by
#      the code it tests proves nothing, so the table below was written from the
#      design of each case, before the oracle was run, and the verdicts are checked
#      against it independently of the committed bytes.
#
# And the checker is shown not to be a rubber stamp: a tampered expected file, a
# missing one, and an input changed without re-blessing are each caught.
#
# Everything here is pure: no process is started and no clock is read.

? "TESTOOR P2b -- golden logbooks"
nGdStart = clock()
cGdHere = currentdir()
cGdRoot = cGdHere + "/../../testoor/golden"

# case, state, ending, kept, diverged, unreached, unjudged
aGdIntent = [
	[ "01_kept_timed",           "kept",      "finished-timed", 3, 0, 0, 0 ],
	[ "02_diverged",             "diverged",  "finished-timed", 2, 1, 0, 0 ],
	[ "03_unjudged_branch",      "unjudged",  "finished",       1, 0, 0, 1 ],
	[ "04_not_started",          "unreached", "not-started",    0, 0, 2, 0 ],
	[ "05_broke_midway",         "unreached", "broke",          1, 0, 2, 0 ],
	[ "06_hung",                 "unreached", "hung",           1, 0, 1, 0 ],
	[ "07_promise_spellings",    "kept",      "finished-timed", 8, 0, 0, 0 ],
	[ "08_promise_lie_and_prose", "diverged", "finished",       1, 2, 0, 1 ],
	[ "09_error_promise",        "kept",      "finished",       2, 0, 0, 0 ],
	[ "10_multiline_block",      "diverged",  "finished",       2, 1, 0, 0 ],
	[ "11_picture",              "diverged",  "finished",       0, 1, 0, 2 ],
	[ "12_protocol_python",      "diverged",  "finished-timed", 2, 1, 0, 2 ],
	[ "13_unreadable",           "kept",      "unreadable",     0, 0, 0, 0 ],
	[ "14_exact_case",           "diverged",  "finished",       2, 1, 0, 0 ]
]

#============================================================================
Scenario("The reference reproduces every committed expected file, byte for byte")
	nGdSec = clock()
	Given("the committed inputs of 14 tours and 5 runs")
	aGdAll = TestoorGoldenAll(cGdRoot)
	Then("they produce 43 expected files", len(aGdAll), 43)
	acGdBad = TestoorGoldenDiff(cGdRoot)
	for nGd = 1 to len(acGdBad)
		? "        DIFFERS: " + acGdBad[nGd]
	next
	Then("and not one differs from what is committed", len(acGdBad), 0)
	aGdAgain = TestoorGoldenAll(cGdRoot)
	Then("a second regeneration is identical to the first: the reference is deterministic", _GdJoin(aGdAgain), _GdJoin(aGdAll))
	nGdValid = 0
	for nGd = 1 to len(aGdAll)
		if right(aGdAll[nGd][1], 13) = "expected.json" and StzJsonIsValid(aGdAll[nGd][2])  nGdValid++  ok
	next
	Then("every expected.json is valid JSON", nGdValid, 19)
EndScenario()
? "        [section took " + ((clock() - nGdSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Each case shows what it was designed to show")
	nGdSec = clock()
	for nGd = 1 to len(aGdIntent)
		aRow = aGdIntent[nGd]
		aRec = TestoorGoldenVerdict(cGdRoot + "/judge/" + aRow[1])
		cGdTag = aRow[1] + ": "
		if aRow[3] = "unreadable"
			Then(cGdTag + "it is unreadable", aRec[:run][:end], "unreadable")
			loop
		ok
		Then(cGdTag + "the tour is " + aRow[2], aRec[:run][:state], aRow[2])
		Then(cGdTag + "it ended " + aRow[3], aRec[:run][:end], aRow[3])
		Then(cGdTag + "claims kept/diverged/unreached/unjudged",
			"" + aRec[:run][:kept] + "/" + aRec[:run][:diverged] + "/" + aRec[:run][:unreached] + "/" + aRec[:run][:unjudged],
			"" + aRow[4] + "/" + aRow[5] + "/" + aRow[6] + "/" + aRow[7])
	next
	aGdP = TestoorGoldenVerdict(cGdRoot + "/judge/12_protocol_python")
	Then("the self-describing tour's own seed won over the runner's", aGdP[:run][:seed], 7)
	Then("it declared one weather", len(aGdP[:weather]), 1)
	Then("named with its tick", aGdP[:weather][1], "child_killed@3")
	Then("it walked two routes", len(aGdP[:routes]), 2)
	Then("the first before any stop", aGdP[:routes][1][:item] + "|" + aGdP[:routes][1][:stop], "ZA1|")
	Then("the second inside the second stop", aGdP[:routes][2][:item] + "|" + aGdP[:routes][2][:stop], "ZA2|second place")
	Then("the claims it announced and never made are named", aGdP[:run][:stops][2][:claims][2][:claim], "(planned claim 4)")
	aGdU = TestoorGoldenVerdict(cGdRoot + "/judge/02_diverged")
	Then("non-ASCII text survives the whole path", aGdU[:run][:stops][1][:claims][2][:claim], "b is é à 日本")
	aGdK = TestoorGoldenVerdict(cGdRoot + "/judge/01_kept_timed")
	Then("a kept tour carries the runner's seed, not a tour's", aGdK[:run][:seed], 5)
	Then("the first stop took what the arrival times say: opened at 0.5 s, the next at 2 s", aGdK[:run][:stops][1][:wall_ms], 1500)
EndScenario()
? "        [section took " + ((clock() - nGdSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The five runs, and the exit code the runner gives each")
	nGdSec = clock()
	aL1 = TestoorGoldenLogbook(cGdRoot + "/logbook/L1_all_kept", cGdRoot + "/judge")
	aL2 = TestoorGoldenLogbook(cGdRoot + "/logbook/L2_mixed", cGdRoot + "/judge")
	aL3 = TestoorGoldenLogbook(cGdRoot + "/logbook/L3_trouble", cGdRoot + "/judge")
	aL4 = TestoorGoldenLogbook(cGdRoot + "/logbook/L4_flaky", cGdRoot + "/judge")
	aL5 = TestoorGoldenLogbook(cGdRoot + "/logbook/L5_refused", cGdRoot + "/judge")
	Then("a run of kept, unjudged and promised-raise tours exits 0", aL1[3], 0)
	Then("owning three and running three", StzFindFirst('"owned":3,"run":3', aL1[1]) > 0, TRUE)
	Then("a run with a diverged tour exits 1", aL2[3], 1)
	Then("and names what it skipped", StzFindFirst('"skipped":["_helper.ring"]', aL2[1]) > 0, TRUE)
	Then("and the topics it did not walk", StzFindFirst('"topics_skipped":["alpha","beta"]', aL2[1]) > 0, TRUE)
	Then("a run of tours that did not start, broke, hung or could not be read exits 1", aL3[3], 1)
	Then("owning four but running three: owned and run are two figures", StzFindFirst('"owned":4,"run":3', aL3[1]) > 0, TRUE)
	Then("a kept tour found flaky still exits 1", aL4[3], 1)
	Then("and says so", StzFindFirst('"flaky":1', aL4[1]) > 0, TRUE)
	Then("a run refused at its root exits 2", aL5[3], 2)
	Then("owning nothing", StzFindFirst('"owned":0,"run":0', aL5[1]) > 0, TRUE)
	Then("and saying why", StzFindFirst('"refusal":"no such root: no/such/root"', aL5[1]) > 0, TRUE)
	Then("the committed exit codes agree", TestoorGoldenRead(cGdRoot + "/logbook/L3_trouble/expected.exit"), "1" + char(10))
EndScenario()
? "        [section took " + ((clock() - nGdSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The goldens carry every key the protocol publishes")
	nGdSec = clock()
	aGdKeys = TestoorLogbookKeys()
	nGdMissing = 0
	for nGd = 1 to len(aGdAll)
		cGdPath = aGdAll[nGd][1]
		if right(cGdPath, 13) != "expected.json"  loop  ok
		if left(cGdPath, 5) = "judge"
			acGdNeed = aGdKeys[:tour]
		else
			acGdNeed = aGdKeys[:run]
		ok
		for nGdK = 1 to len(acGdNeed)
			if StzFindFirst('"' + acGdNeed[nGdK] + '":', aGdAll[nGd][2]) = 0
				nGdMissing++
				? "        " + cGdPath + " lacks " + acGdNeed[nGdK]
			ok
		next
	next
	Then("no expected.json lacks a key of its level", nGdMissing, 0)
EndScenario()
? "        [section took " + ((clock() - nGdSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The checker is not a rubber stamp: a tampered file, a missing file and a changed input are each caught")
	nGdSec = clock()
	cGdTmp = _GdTempDir() + "/stz_testoor_golden_copy"
	_GdCopyTree(cGdRoot, cGdTmp)
	TestoorGoldenUpdate(cGdTmp)
	Then("a faithful copy is clean", len(TestoorGoldenDiff(cGdTmp)), 0)
	write(cGdTmp + "/judge/01_kept_timed/expected.txt", "KEPT but not the way the reference says" + char(10))
	acGdD1 = TestoorGoldenDiff(cGdTmp)
	Then("a tampered expected file is reported", len(acGdD1), 1)
	Then("by name", acGdD1[1], "judge/01_kept_timed/expected.txt")
	TestoorGoldenUpdate(cGdTmp)
	remove(cGdTmp + "/logbook/L1_all_kept/expected.exit")
	acGdD2 = TestoorGoldenDiff(cGdTmp)
	Then("a missing expected file is reported as missing", acGdD2[1], "logbook/L1_all_kept/expected.exit (missing)")
	TestoorGoldenUpdate(cGdTmp)
	cGdOut = TestoorGoldenRead(cGdTmp + "/judge/02_diverged/output.txt")
	write(cGdTmp + "/judge/02_diverged/output.txt", substr(cGdOut, "[FAIL]", "[PASS]"))
	acGdD3 = TestoorGoldenDiff(cGdTmp)
	Then("an input changed without re-blessing is caught: the verdict no longer matches its file", len(acGdD3) >= 1, TRUE)
	Then("in the case it belongs to", _GdAnyStarts(acGdD3, "judge/02_diverged/"), TRUE)
	Then("and in the run that contains the case", _GdAnyStarts(acGdD3, "logbook/L2_mixed/"), TRUE)
	StzDirDeleteAll(cGdTmp)
EndScenario()
? "        [section took " + ((clock() - nGdSec) / clockspersecond()) + "s]"

? ""
? "[P2b took " + ((clock() - nGdStart) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _GdJoin(aPairs)
	c = ""
	n = len(aPairs)
	for i = 1 to n
		c += aPairs[i][1] + "=" + aPairs[i][2] + char(1)
	next
	return c

func _GdAnyStarts(acPaths, cPrefix)
	n = len(acPaths)
	for i = 1 to n
		if left(acPaths[i], len(cPrefix)) = cPrefix  return TRUE  ok
	next
	return FALSE

func _GdTempDir()
	cT = sysget("TEMP")
	if cT = "" or cT = NULL  cT = sysget("TMPDIR")  ok
	if cT = "" or cT = NULL  cT = "/tmp"  ok
	return substr(cT, "\", "/")

# the inputs of every case, copied: record.json, meta.json, output.txt, run.json
func _GdCopyTree(cSrc, cDst)
	if fexists(cDst + "/judge")  StzDirDeleteAll(cDst)  ok
	StzMakeDir(cDst)
	StzMakeDir(cDst + "/judge")
	StzMakeDir(cDst + "/logbook")
	acJ = _GoldenCases(cSrc + "/judge")
	for i = 1 to len(acJ)
		StzMakeDir(cDst + "/judge/" + acJ[i])
		for cF in [ "record.json", "meta.json", "output.txt" ]
			write(cDst + "/judge/" + acJ[i] + "/" + cF, read(cSrc + "/judge/" + acJ[i] + "/" + cF))
		next
	next
	acL = _GoldenCases(cSrc + "/logbook")
	for i = 1 to len(acL)
		StzMakeDir(cDst + "/logbook/" + acL[i])
		write(cDst + "/logbook/" + acL[i] + "/run.json", read(cSrc + "/logbook/" + acL[i] + "/run.json"))
	next
