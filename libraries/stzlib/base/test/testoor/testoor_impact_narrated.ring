load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P1a -- IMPACT RECALL. The graph-first premise, measured before any Zig
# is written: when a method changes, does the set of tours the subject's own code
# graph selects contain EVERY tour that actually fails?
#
# The experiment is exact because the subject is planted: three classes with
# known call edges (stzInvoice -> stzTax -> stzNet), seven public methods, eight
# tours that each name a different part of it. For every method a MUTANT is made
# (the first return of the method gets + 1), every tour is walked against it, and
# the tours that fail are the ground truth. The graph's selection is compared
# with that truth, tour by tour, for all seven mutants: 56 real walks.
#
#   RECALL is the safety claim and it is asserted: a tour that fails and is not
#   selected would be a verdict silently lost. PRECISION is reported, not
#   asserted: a selected tour that did not fail costs time, never a verdict.
#
# Then the blind spot, measured the same way. A subject whose method reaches
# another by a name built at run time (eval) has an edge the graph cannot see.
# The naive selection MISSES a failing tour; the graph reads such a subject as
# INCOMPLETE and selects every tour, and recall is back to 100 percent.
#
# This measures the planted subject, which proves the method and not the real
# library; the real library's recall (dynamic dispatch, inheritance, Q-chains) is
# the next measurement in SOFTANZA_TESTOOR_ROADMAP.md, P4.

? "TESTOOR P1a -- impact recall"
nImStart = clock()
cImHere = currentdir()
cImRoot = cImHere + "/_planted_impact"
_ImPlantAll(cImRoot)
cImDir = cImRoot + "/lib"
cImSubj = cImDir + "/_subject.ring"
cImOrig = read(cImSubj)
cImOrigFile = cImDir + "/_orig.ring"
write(cImOrigFile, cImOrig)
acImTours = _ImTours(cImDir)

#============================================================================
Scenario("The reach of a change is the closure of its callers in the subject's own graph")
	nImSec = clock()
	Given("a subject of three classes: stzInvoice calls stzTax calls stzNet")
	aI = StzImpactOf(cImSubj, "Of")
	Then("a change to Of reaches Vat, which calls it", _ImHas(aI[:names], "vat"), TRUE)
	Then("and Gross, which calls Vat: the closure is transitive", _ImHas(aI[:names], "gross"), TRUE)
	Then("it does not reach the other branch", _ImHas(aI[:names], "duty") or _ImHas(aI[:names], "landed"), FALSE)
	Then("nor an unrelated method", _ImHas(aI[:names], "label"), FALSE)
	Then("the graph can see every edge of this subject", aI[:complete], 1)
	aD = StzImpactOf(cImSubj, "Round2")
	Then("the other branch is reached from its own end: Duty and Landed", _ImHas(aD[:names], "duty") and _ImHas(aD[:names], "landed"), TRUE)
	Then("and not the first branch", _ImHas(aD[:names], "vat"), FALSE)
	Then("a method nobody calls reaches only itself", len(StzImpactOf(cImSubj, "Label")[:names]), 1)
	aC = StzImpactOf(cImSubj, "stzTax.init")
	Then("a changed constructor reaches whoever builds its class", _ImHas(aC[:names], "stzinvoice"), TRUE)
	Then("but not a class built the other way round", _ImHas(aC[:names], "stznet"), FALSE)
EndScenario()
? "        [section took " + ((clock() - nImSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Selection: the tours that name the reach are re-walked and the rest are skipped by name")
	nImSec = clock()
	Given("a change to Vat")
	aS = StzImpactedTours(cImSubj, "Vat", acImTours)
	Then("three tours name Vat or a caller of it", len(aS[:selected]), 3)
	Then("five are skipped", len(aS[:skipped]), 5)
	Then("the Vat tour is selected", _ImListed(aS[:selected], "t2_vat"), TRUE)
	Then("the Gross tour is selected, because Gross calls Vat", _ImListed(aS[:selected], "t3_gross"), TRUE)
	Then("the Label tour is skipped", _ImListed(aS[:skipped], "t6_label"), TRUE)
	Then("and the tour that names nothing of the subject", _ImListed(aS[:skipped], "t8_unrelated"), TRUE)
	Given("a change to Label")
	aL = StzImpactedTours(cImSubj, "Label", acImTours)
	Then("one tour of eight is re-walked", len(aL[:selected]), 1)
EndScenario()
? "        [section took " + ((clock() - nImSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("RECALL: for every mutant of the subject, every tour that fails is in the graph's selection")
	nImSec = clock()
	Given("the eight tours walked against the unchanged subject")
	acBase = _ImStates(acImTours)
	Then("all eight pass at the start: the runner exits 0 on each", _ImCount(acBase, "kept"), 8)
	acMethods = [ "Of", "Round2", "Vat", "Duty", "Gross", "Landed", "Label" ]
	nRuns = 0  nSel = 0  nFail = 0  nMissed = 0  nWasted = 0
	for nM = 1 to len(acMethods)
		cMeth = acMethods[nM]
		write(cImSubj, _ImMutate(cImOrig, cMeth))
		acNow = _ImStates(acImTours)
		aSel = StzImpactedTours(cImOrigFile, cMeth, acImTours)
		nMissedHere = 0
		nSelHere = len(aSel[:selected])
		nFailHere = 0
		for nT = 1 to len(acImTours)
			bFails = (acNow[nT] != "kept")
			bSelected = ring_find(aSel[:selected], acImTours[nT]) > 0
			if bFails  nFailHere++  ok
			if bFails and NOT bSelected  nMissedHere++  ok
			if bSelected and NOT bFails  nWasted++  ok
		next
		nRuns += len(acImTours)
		nSel += nSelHere
		nFail += nFailHere
		nMissed += nMissedHere
		? "        " + cMeth + ": " + nFailHere + " tours fail, " + nSelHere + " selected, " + nMissedHere + " missed"
		Then("mutant " + cMeth + ": at least one tour notices it", nFailHere >= 1, TRUE)
		Then("mutant " + cMeth + ": no failing tour is outside the selection", nMissedHere, 0)
	next
	write(cImSubj, cImOrig)
	? "        (" + len(acMethods) + " mutants x " + len(acImTours) + " tours = " + nRuns + " walks; the graph selected " + nSel + ", " + nFail + " failed, " + nMissed + " missed, " + nWasted + " selected without need)"
	Then("recall is total across all mutants", nMissed, 0)
	Then("and the selection is smaller than walking everything", nSel < nRuns, TRUE)
EndScenario()
? "        [section took " + ((clock() - nImSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The blind spot: a call by a name built at run time is an edge the graph cannot see, and it says so")
	nImSec = clock()
	cDynDir = cImRoot + "/dyn"
	cDynSubj = cDynDir + "/_subject.ring"
	cDynOrig = read(cDynSubj)
	acDyn = _ImTours(cDynDir)
	Given("a subject whose Gross reaches VatOf through eval, and three tours")
	Then("they all pass at the start", _ImCount(_ImStates(acDyn), "kept"), 3)
	aG = StzImpactOf(cDynSubj, "VatOf")
	Then("the graph reads the subject as incomplete", aG[:complete], 0)
	Then("and names the line", StzFindFirst("dispatches by a name built at run time", aG[:why]) > 0, TRUE)
	write(cDynSubj, _ImMutate(cDynOrig, "VatOf"))
	acNow = _ImStates(acDyn)
	write(cDynSubj, cDynOrig)
	nFailing = 0
	nNaiveMiss = 0
	nSafeMiss = 0
	aSafe = StzImpactedTours(cDynSubj, "VatOf", acDyn)
	for nT = 1 to len(acDyn)
		if acNow[nT] != "kept"
			nFailing++
			# the NAIVE selection: tours that name the reach, ignoring that the graph is incomplete
			acT = _RouteCalledNames(read(acDyn[nT]))
			bNaive = 0
			for nN = 1 to len(aG[:names])
				if _RouteIndexOf(acT, aG[:names][nN]) > 0  bNaive = 1  ok
			next
			if NOT bNaive  nNaiveMiss++  ok
			if ring_find(aSafe[:selected], acDyn[nT]) = 0  nSafeMiss++  ok
		ok
	next
	? "        (" + nFailing + " tours fail; the naive selection misses " + nNaiveMiss + "; the honest one misses " + nSafeMiss + ")"
	Then("two tours fail on the mutant", nFailing, 2)
	Then("the naive name join MISSES one of them: that is the hole", nNaiveMiss >= 1, TRUE)
	Then("the honest selection misses none", nSafeMiss, 0)
	Then("because it selected every tour", len(aSafe[:selected]), len(acDyn))
	Then("and its prose says the graph was incomplete", StzFindFirst("GRAPH INCOMPLETE", StzImpactProse(aSafe, "VatOf")) > 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nImSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("At the shell: --impacted-by lists the tours to re-walk, and --run walks only those")
	nImSec = clock()
	Given("testoor.ring asked what a change to Label reaches")
	aOut = _ImShell([ "--impacted-by", cImSubj + "#Label", "--root", cImRoot, "--topic", "lib" ])
	Then("it exits 0", aOut[1], 0)
	Then("and lists the one tour to re-walk", StzFindFirst("RE-WALK", aOut[2]) > 0 and StzFindFirst("t6_label", aOut[2]) > 0, TRUE)
	Then("exactly one, not eight", _ImOccurrences(aOut[2], "RE-WALK"), 1)
	Then("and the others are named as skipped", _ImOccurrences(aOut[2], "skipped  "), 7)
	aJ = _ImShell([ "--impacted-by", cImSubj + "#Label", "--root", cImRoot, "--topic", "lib", "--json" ])
	cJ = _ImJsonOnly(aJ[2])
	Then("--json answers valid JSON", StzJsonIsValid(cJ), TRUE)
	Then("naming the selection", StzFindFirst('"selected":["', cJ) > 0, TRUE)
	aR = _ImShell([ "--impacted-by", cImSubj + "#Label", "--root", cImRoot, "--topic", "lib", "--run" ])
	Then("--run walks the selected tour and exits 0", aR[1], 0)
	Then("owning one tour, not eight", StzFindFirst("owned 1 tours", aR[2]) > 0, TRUE)
	aBad = _ImShell([ "--impacted-by", cImSubj, "--root", cImRoot, "--topic", "lib" ])
	Then("a request without #Method is refused, exit 2", aBad[1], 2)
EndScenario()
? "        [section took " + ((clock() - nImSec) / clockspersecond()) + "s]"

write(cImSubj, cImOrig)
_ImUnplantAll(cImRoot)
? ""
? "[P1a took " + ((clock() - nImStart) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _ImHas(acNames, cName)
	return ring_find(acNames, lower(cName)) > 0

func _ImListed(acFiles, cStem)
	n = len(acFiles)
	for i = 1 to n
		if StzFindFirst(cStem, acFiles[i]) > 0  return TRUE  ok
	next
	return FALSE

func _ImCount(acList, cWhat)
	n = 0
	for i = 1 to len(acList)
		if acList[i] = cWhat  n++  ok
	next
	return n

# the tours of a folder: its .ring files, in name order; names opening with _ are not tours
func _ImTours(cDir)
	aTwo = _TourFilesUnder(cDir, "")
	return aTwo[1]

# Walk every tour once and answer the RUNNER'S verdict on each: "kept" when it
# exits 0, "fails" otherwise. The exit code is what an agent in a loop reads, and
# it is the right test for "this tour noticed the change": a planted tour prints
# either an OK or a FAIL line, so its other branch is always unjudged, which is
# not a failure and would have read as one if the state had been compared.
func _ImStates(acTours)
	_acOut_ = []
	for _i_ = 1 to len(acTours)
		_oT_ = TravellerQ().Silent().Timeout(30000).Seed(1).Walk(acTours[_i_])
		if _oT_.ExitCode() = 0
			_acOut_ + "kept"
		else
			_acOut_ + "fails"
		ok
	next
	return _acOut_

# the first return of a method gets + 1: the smallest change that is still a change
func _ImMutate(cSrc, cName)
	_aLn_ = str2list(substr(cSrc, char(13), ""))
	_n_ = len(_aLn_)
	_cA_ = "def " + lower(cName) + "("
	_cB_ = "func " + lower(cName) + "("
	_bIn_ = 0
	for _i_ = 1 to _n_
		_cT_ = lower(trim(_aLn_[_i_]))
		if NOT _bIn_
			if left(_cT_, len(_cA_)) = _cA_ or left(_cT_, len(_cB_)) = _cB_  _bIn_ = 1  ok
		else
			if left(_cT_, 7) = "return "
				_nInd_ = 0
				while _nInd_ < len(_aLn_[_i_]) and (_aLn_[_i_][_nInd_ + 1] = char(9) or _aLn_[_i_][_nInd_ + 1] = " ")  _nInd_++  end
				_cTr_ = trim(_aLn_[_i_])
				_aLn_[_i_] = left(_aLn_[_i_], _nInd_) + "return (" + substr(_cTr_, 8, len(_cTr_) - 7) + ") + 1"
				exit
			ok
		ok
	next
	_c_ = ""
	for _i_ = 1 to _n_
		_c_ += _aLn_[_i_] + char(10)
	next
	return _c_

func _ImOccurrences(cText, cSub)
	_n_ = 0
	_cRest_ = cText
	while 1
		_nP_ = substr(_cRest_, cSub)
		if _nP_ = 0  exit  ok
		_n_++
		_cRest_ = substr(_cRest_, _nP_ + len(cSub), len(_cRest_) - _nP_ - len(cSub) + 1)
	end
	return _n_

# testoor.ring as a child: [ exit code, output ]
func _ImShell(acArgs)
	oP = new stzProcess()
	acArgv = [ TestoorProgram(), "testoor.ring" ]
	for i = 1 to len(acArgs)
		acArgv + acArgs[i]
	next
	oP.SpawnIn(currentdir() + "/../../testoor", acArgv)
	cOut = oP.ReadOutputAll()
	nX = oP.Wait()
	oP.Close()
	return [ nX, cOut ]

# the engine may print warnings about DLLs this build lacks; the JSON is the line that starts with {
func _ImJsonOnly(cOut)
	ac = str2list(substr(cOut, char(13), ""))
	for i = 1 to len(ac)
		if left(trim(ac[i]), 1) = "{"  return trim(ac[i])  ok
	next
	return ""

func _ImPlantAll(cRoot)
	_ImUnplantAll(cRoot)
	StzMakeDir(cRoot)
	StzMakeDir(cRoot + "/lib")
	StzMakeDir(cRoot + "/dyn")
	_t_ = char(9)
	_n_ = char(10)
	# the planted subject: stzInvoice calls stzTax calls stzNet
	write(cRoot + "/lib/_subject.ring",
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
	_ImTour(cRoot + "/lib/t1_net.ring", "stzNet", "Of(5)", "5", "Of returns its argument")
	_ImTour(cRoot + "/lib/t2_vat.ring", "stzTax", "Vat(100)", "20", "a fifth of the net is the vat")
	_ImTour(cRoot + "/lib/t3_gross.ring", "stzInvoice", "Gross(100)", "120", "gross is net plus vat")
	_ImTour(cRoot + "/lib/t4_duty.ring", "stzTax", "Duty(1000)", "10", "a hundredth is the duty")
	_ImTour(cRoot + "/lib/t5_landed.ring", "stzInvoice", "Landed(1000)", "1010", "landed is net plus duty")
	_ImTour(cRoot + "/lib/t6_label.ring", "stzInvoice", "Label()", "7", "the label is seven")
	write(cRoot + "/lib/t7_both.ring",
		'load "_subject.ring"' + _n_ +
		"oI = new stzInvoice()" + _n_ +
		'if oI.Gross(100) = 120 ? "  [OK] gross holds" else ? "  [FAIL] gross holds" ok' + _n_ +
		'if oI.Landed(1000) = 1010 ? "  [OK] landed holds" else ? "  [FAIL] landed holds" ok' + _n_)
	write(cRoot + "/lib/t8_unrelated.ring", '? "  [OK] this tour names nothing of the subject"' + _n_)
	# the dynamic subject: Gross reaches VatOf through eval, a name the graph cannot read
	write(cRoot + "/dyn/_subject.ring",
		"func VatOf(n)" + _n_ + _t_ + "return n * 2 / 10" + _n_ +
		"class stzInvoice" + _n_ +
		_t_ + "def init()" + _n_ + _t_ + _t_ + "return" + _n_ +
		_t_ + "def Gross(n)" + _n_ +
		_t_ + _t_ + "eval('$nRes = VatOf(' + n + ')')" + _n_ +
		_t_ + _t_ + "return n + $nRes" + _n_)
	_ImTour(cRoot + "/dyn/d1_gross.ring", "stzInvoice", "Gross(100)", "120", "gross is net plus vat")
	_ImTour(cRoot + "/dyn/d2_vat.ring", "", "VatOf(100)", "20", "vat is a fifth")
	write(cRoot + "/dyn/d3_unrelated.ring", '? "  [OK] this tour names nothing"' + _n_)

# a tour that loads the subject, builds the object when there is a class, and
# prints one OK or one FAIL line: Ring does not chain a call onto new X()
func _ImTour(cPath, cClass, cCall, cExpect, cText)
	_cSetup_ = ""
	_cCall_ = cCall
	if cClass != ""
		_cSetup_ = "o = new " + cClass + "()" + char(10)
		_cCall_ = "o." + cCall
	ok
	write(cPath,
		'load "_subject.ring"' + char(10) +
		_cSetup_ +
		"if " + _cCall_ + " = " + cExpect + char(10) +
		char(9) + '? "  [OK] ' + cText + '"' + char(10) +
		"else" + char(10) +
		char(9) + '? "  [FAIL] ' + cText + '"' + char(10) +
		"ok" + char(10))

func _ImUnplantAll(cRoot)
	if fexists(cRoot + "/lib/_subject.ring")
		StzDirDeleteAll(cRoot)
	ok
