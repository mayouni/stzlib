load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, A1 -- coverage: a whole narrated file runs as ONE admission on
# the resident Atelier, judged by testoor's judge; the five stop states stay
# apart; and the court is testoor's own runner (a child rnxc per tour) walked
# on the same files: where the two disagree, the disagreement is named.
#
# Run from this folder, on rnxc:
#     rnxc atelier_tours_narrated.ring
# Warm, about 3 minutes: the guard's own start, the child Atelier's compile of
# the library (44 to 110 s measured 2026-11-03), the planted tours, and the
# court on four real files (a child rnxc each, under 2 s warm). After a
# library change every child pays its tour's compile first (35 to 123 s a
# tour), which is testoor's tax and not this guard's to hide.

? "ATELIER A1 -- whole files as tours"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
cAtTests = cAtHere + "/.."
nAtPort = 8661
cAtSettings = cAtHere + "/_planted_settings_tours.ring"
cAtPlant = cAtHere + "/_planted_tours"
_AtPlant(cAtPlant)

#============================================================================
Scenario("The source the Atelier admits: library loads dropped, a shutdown made harmless")
	Given("a planted file loading the library and the narrated helper, ending with shutdown(9)")
	aS = AtelierTourSource(cAtPlant + "/01_three_states.ring")
	When("transformed")
	Then("its folder is the planted folder", right(aS[:folder], 14), "_planted_tours")
	Then("the library load is a comment now", StzFindFirst("# load " + '"../../stzBase.ring"', aS[:source]) > 0, TRUE)
	Then("the narrated helper's load too", StzFindFirst("# load " + '"../_narrated.ring"', aS[:source]) > 0, TRUE)
	Then("no live load is left", StzFindFirst(char(10) + "load ", aS[:source]) = 0, TRUE)
	Then("shutdown(9) became AtelierShutdown(9)", StzFindFirst("AtelierShutdown(9)", aS[:source]) > 0, TRUE)
	Then("the Then lines are untouched", StzFindFirst('Then("two is three", 2, 3)', aS[:source]) > 0, TRUE)
EndScenario()

Scenario("An Atelier boots for the tours")
	oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
	aAtState = AtelierWaitReady(nAtPort, 180000, oAt)
	if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	? "    judged by: the library " + aAtState[:library][:commit] + "; rnxc " + aAtState[:rnxc][:build] + "; the engine: " + aAtState[:engine]
EndScenario()

Scenario("Kept, diverged and unreached in one tour that breaks part-way")
	Given("the planted file: a kept claim, a diverged one, a runtime error, a claim after it")
	aR = AtelierRunTour(nAtPort, cAtPlant + "/01_three_states.ring", 60)
	aRun = aR[:run]
	When("admitted whole, judged by testoor's judge")
	Then("the tour broke", aRun[:end], "broke")
	Then("the error is named", StzFindFirst("nosuchfunctionhere", lower(aR[:why])) > 0, TRUE)
	Then("the tour's state is diverged (worst of its claims)", aRun[:state], "diverged")
	Then("two stops", len(aRun[:stops]), 2)
	Then("stop 1, claim 1 kept", aRun[:stops][1][:claims][1][:state], "kept")
	Then("stop 1, claim 2 diverged", aRun[:stops][1][:claims][2][:state], "diverged")
	Then("stop 2's claim, after the error, is unreached", aRun[:stops][2][:claims][1][:state], "unreached")
	aC = AtelierClaimCounts(aRun)
	Then("counts: 3 claims, 1 kept, 1 diverged, 1 unreached", "" + aC[:claims] + "/" + aC[:kept] + "/" + aC[:diverged] + "/" + aC[:unreached], "3/1/1/1")
	Then("the code was released", aR[:release], "released")
	Then("the Atelier still answers", AtelierState(nAtPort)[:library][:state], "admitted")
EndScenario()

Scenario("A claim in a branch not taken is unjudged; a tour that finishes with pf() is finished-timed")
	Given("the planted file: one kept claim, one claim behind if 1 = 2, then pf()")
	aR = AtelierRunTour(nAtPort, cAtPlant + "/02_unjudged.ring", 60)
	aRun = aR[:run]
	if aRun[:end] != "finished-timed"  ? "    the Atelier said: " + aR[:why]  ok
	Then("the tour finished, timed", aRun[:end], "finished-timed")
	Then("the first claim is kept", aRun[:stops][1][:claims][1][:state], "kept")
	Then("the second is unjudged, never a failure", aRun[:stops][1][:claims][2][:state], "unjudged")
	# testoor's rule: a stop is as bad as its worst claim, and unjudged sits
	# between kept and unreached -- reported, never a failure
	Then("the tour's state is unjudged, which the runner reports and does not fail", aRun[:state], "unjudged")
	Then("nothing diverged", aRun[:diverged], 0)
EndScenario()

Scenario("A file that does not scan never starts; its claims are unreached")
	Given("the planted file with an unclosed literal")
	aR = AtelierRunTour(nAtPort, cAtPlant + "/03_unclosed.ring", 60)
	Then("not started", aR[:run][:end], "not-started")
	Then("the refusal is named", StzFindFirst("not admitted", aR[:why]) > 0, TRUE)
	Then("its claim is unreached", aR[:run][:stops][1][:claims][1][:state], "unreached")
	Then("nothing was released, nothing kept", aR[:release], "nothing to release")
	Then("the Atelier still answers", AtelierState(nAtPort)[:library][:state], "admitted")
EndScenario()

Scenario("A tour's own shutdown does not end the Atelier")
	Given("the first planted file again, which ends with shutdown(9) after its error")
	aR = AtelierRunTour(nAtPort, cAtPlant + "/04_shutdown.ring", 60)
	Then("the tour finished", aR[:run][:end], "finished")
	Then("its claim before the shutdown is kept", aR[:run][:stops][1][:claims][1][:state], "kept")
	Then("the ask was recorded", StzFindFirst("shutdown 9 asked", _AtJoin(aR[:output])) > 0, TRUE)
	Then("and the Atelier still answers", AtelierState(nAtPort)[:library][:state], "admitted")
EndScenario()

#============================================================================
Scenario("The court: testoor's runner and the Atelier agree on four real files")
	Given("four narrated files of the corpus, walked by a child rnxc each, and admitted whole")
	# four files that end, print little and leave the program as they found it
	# (a hostile-globals tour would clobber the resident program's constants for
	# every tour after it: the sweep restores them, the court keeps clear of it)
	acFiles = [ "adverb/00_adverb_narrated.ring", "uuid/00_uuid_narrated.ring",
	            "common/slice_primitives_narrated.ring", "string/00_string_narrated.ring" ]
	nAgree = 0
	nDis = 0
	cDis = ""
	for i = 1 to len(acFiles)
		cPath = cAtTests + "/" + acFiles[i]
		if NOT fexists(cPath)
			? "    not here: " + acFiles[i]
			loop
		ok
		# the child's first walk after a library change pays the tour's compile
		# (measured 2026-11-03: 35 to 123 s, then under 2 s): the deadline allows it
		nT1 = clock()
		oT = TravellerQ().Silent().Timeout(300000).Walk(cPath)
		aChild = oT.Records()[1][:run]
		nChildS = (clock() - nT1) / clockspersecond()
		nT1 = clock()
		aHere = AtelierRunTour(nAtPort, cPath, 300)[:run]
		nHereS = (clock() - nT1) / clockspersecond()
		aD = AtelierDisagreements(aChild, aHere)
		aC = AtelierClaimCounts(aHere)
		? "    " + acFiles[i] + ": child " + aChild[:state] + " (" + aChild[:kept] + " kept, " + aChild[:diverged] + " diverged, " + _AtelierNum(nChildS) + " s), Atelier " + aHere[:state] + " (" + aC[:kept] + " kept, " + aC[:diverged] + " diverged, " + _AtelierNum(nHereS) + " s); " + len(aD) + " disagreement(s)"
		for k = 1 to len(aD)
			? "      " + aD[k][:where] + ": child " + aD[k][:a] + ", Atelier " + aD[k][:b]
		next
		if len(aD) = 0
			nAgree++
		else
			nDis++
		ok
	next
	When("their claim states are compared one by one")
	Then("four files were judged twice", nAgree + nDis, 4)
	Then("the two courts agree on every one", nDis, 0)
EndScenario()

Scenario("tours.json, the last sweep, adds up")
	Given("tours.json beside the Atelier")
	aT = StzJsonToList(read(cAtAtelier + "/tours.json"))
	nFiles = 0  nClaims = 0  nJudged = 0
	for i = 1 to len(aT[:domains])
		nFiles += aT[:domains][i][2][:files]
		nClaims += aT[:domains][i][2][:claims]
		nJudged += aT[:domains][i][2][:judged]
	next
	? "    " + aT[:totals][:files] + " tours, " + aT[:totals][:claims] + " Then lines read, " + aT[:totals][:judged] + " judged (" + aT[:totals][:kept] + " kept, " + aT[:totals][:diverged] + " diverged), " + aT[:totals][:unreached] + " unreached, " + aT[:totals][:unjudged] + " unjudged; judged by the library " + aT[:library]
	Then("the domains sum to the totals: files", nFiles, aT[:totals][:files])
	Then("the domains sum to the totals: Then lines", nClaims, aT[:totals][:claims])
	Then("the domains sum to the totals: judged", nJudged, aT[:totals][:judged])
	Then("judged is kept plus diverged", aT[:totals][:judged], aT[:totals][:kept] + aT[:totals][:diverged])
	Then("every Then line read has one state", aT[:totals][:claims], aT[:totals][:kept] + aT[:totals][:diverged] + aT[:totals][:unreached] + aT[:totals][:unjudged] + aT[:totals][:unperceived])
	Then("the files list is the totals' files", len(aT[:files]), aT[:totals][:files])
	Then("what judged them is named", aT[:library] != "" and aT[:rnxc] != "" and aT[:engine] != "", TRUE)
EndScenario()

Scenario("The Atelier stops when asked")
	bStopped = AtelierStop(nAtPort)
	nExit = oAt.WaitFor(10000)
	Then("it answered", bStopped, TRUE)
	Then("and the child ended", nExit != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

# the planted tours, written fresh each run (the folder is ignored by git)
func _AtPlant(cRoot)
	_nl_ = char(10)
	_t_ = char(9)
	StzDirCreate(cRoot)
	write(cRoot + "/01_three_states.ring",
		'load "../../stzBase.ring"' + _nl_ + 'load "../_narrated.ring"' + _nl_ + _nl_ +
		'Scenario("the first stop")' + _nl_ +
		_t_ + 'Then("one is one", 1, 1)' + _nl_ +
		_t_ + 'Then("two is three", 2, 3)' + _nl_ +
		_t_ + 'x = NoSuchFunctionHere(1)' + _nl_ +
		'Scenario("the second stop")' + _nl_ +
		_t_ + 'Then("never reached", 1, 1)' + _nl_ +
		'Summary()' + _nl_ + 'shutdown(9)' + _nl_)
	write(cRoot + "/02_unjudged.ring",
		'load "../../stzBase.ring"' + _nl_ + 'load "../_narrated.ring"' + _nl_ + _nl_ +
		'Scenario("one stop")' + _nl_ +
		_t_ + 'Then("one is one", 1, 1)' + _nl_ +
		_t_ + 'if 1 = 2' + _nl_ +
		_t_ + _t_ + 'Then("never run", 1, 1)' + _nl_ +
		_t_ + 'ok' + _nl_ +
		'pf()' + _nl_)
	write(cRoot + "/03_unclosed.ring",
		'load "../../stzBase.ring"' + _nl_ + 'load "../_narrated.ring"' + _nl_ + _nl_ +
		'Scenario("never")' + _nl_ +
		_t_ + 'Then("never", 1, 1)' + _nl_ +
		'? "an unclosed literal' + _nl_)
	write(cRoot + "/04_shutdown.ring",
		'load "../../stzBase.ring"' + _nl_ + 'load "../_narrated.ring"' + _nl_ + _nl_ +
		'Scenario("one stop")' + _nl_ +
		_t_ + 'Then("one is one", 1, 1)' + _nl_ +
		'shutdown(9)' + _nl_ +
		_t_ + 'Then("after the shutdown", 1, 1)' + _nl_)

# the child's printed lines ([ text, seconds ] each) as one text
func _AtJoin(paLines)
	_c_ = ""
	_n_ = len(paLines)
	for _k_ = 1 to _n_
		_c_ += paLines[_k_][1] + char(10)
	next
	return _c_
