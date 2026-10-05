load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR TR2 -- PROMISES AS STOPS. The rules of base/meta/promises.py, the
# Python harness that first compared the library's 2,874 files of `#-->`
# promises with what they print, now live in the traveller (stzTraveller.ring,
# the _TravPromise* functions) and judge a promise as a claim of a stop:
# kept, diverged, unreached, unjudged. _expect.ring's pictures join the
# logbook the same way.
#
# EVERY RULE WAS LEARNED BY WATCHING THE HARNESS ACCUSE THE LIBRARY FALSELY,
# so every rule here is planted both ways: the lie it must catch and the
# truth it must not accuse.
#
#   lies/     01 a plain lie                          -> diverged
#             02 two lies in a row                    -> BOTH diverged (a divergence consumes one line)
#             03 a short lie hiding inside a later list -> diverged, the list kept
#   kept/     01 the spellings: TRUE as 1, a note in parentheses, quotes,
#                :Symbol lowercased, @@() list spacing, a bare list item by
#                item, '' for an empty line, a second # as a note -> all kept
#             02 "#--> ERROR: boom" on a line that raises  -> kept, and the tour FINISHED as promised
#             03 a label line before the real value      -> one promise, kept
#   prose/    01 "#--> "C" but should be "sm_AS""        -> prose: unjudged, never diverged, exit 0
#   nostart/  01 a syntax error (C)  02 an unclosed literal (S) -> not-started, promises unreached, 0 diverged
#   raised/   01 a promise, a division by zero, a promise -> 1 kept, 1 unreached, 0 diverged
#   picture/  01 a Shows() that prints PICTURE DOES NOT MATCH and raises -> diverged, named with its row
#             02 a Shows() that is silent                 -> kept
#   and one REAL plot example under ../plot, read and run.

? "TESTOOR TR2 -- promises as stops"
nTpStart = clock()
cTpHere = currentdir()
cTpPlant = cTpHere + "/_planted_promises"
_TpPlantAll(cTpPlant)

#============================================================================
Scenario("A planted lie is diverged; two lies in a row are both caught; a short lie cannot hide in a later line")
	nTpSec = clock()
	Given("a planted tour promising 3 for 1 + 1")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/lies/01_lie.ring")
	aR = oT.Records()[1][:run]
	Then("the promise is diverged", aR[:diverged], 1)
	Then("the claim is the expression", aR[:stops][1][:claims][1][:claim], "1 + 1")
	Then("the tour is diverged", aR[:state], "diverged")
	Then("the runner exits 1", oT.ExitCode(), 1)
	Given("two consecutive lies")
	oT2 = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/lies/02_two_lies.ring")
	Then("both are diverged, the first did not hand its line to the second",
		oT2.Records()[1][:run][:diverged], 2)
	Given("a short lie, 6 for 3, followed by a line printing [ 6, 28 ]")
	oT3 = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/lies/03_short_hidden.ring")
	aR3 = oT3.Records()[1][:run]
	Then("the short lie is diverged, not found inside the list", aR3[:stops][1][:claims][1][:state], "diverged")
	Then("the list promise after it is kept", aR3[:stops][1][:claims][2][:state], "kept")
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The spellings a promise may print as are all kept")
	nTpSec = clock()
	Given("one planted tour with eight true promises in eight spellings")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/kept/01_variants.ring")
	aR = oT.Records()[1][:run]
	aC = aR[:stops][1][:claims]
	Then("TRUE printed as 1", aC[1][:state], "kept")
	Then("FALSE (absent): the note in parentheses dropped", aC[2][:state], "kept")
	Then("a quoted promise against an unquoted print", aC[3][:state], "kept")
	Then(":Number printed bare and lowercased", aC[4][:state], "kept")
	Then("@@() spacing: [ 6, 28 ] against [6, 28]", aC[5][:state], "kept")
	Then("a bare list, one item per line, item by item", aC[6][:state], "kept")
	Then("'' for a line that prints nothing", aC[7][:state], "kept")
	Then("a second # is a note, not more value", aC[8][:state], "kept")
	Then("eight kept, none diverged", "" + aR[:kept] + "/" + aR[:diverged], "8/0")
	Then("the runner exits 0", oT.ExitCode(), 0)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("#--> ERROR: is honoured; a label line is not a promise; a prose promise is prose")
	nTpSec = clock()
	Given("a planted tour whose last line promises to raise, and does")
	oT = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/kept/02_error.ring")
	aR = oT.Records()[1][:run]
	Then("the ERROR promise is kept", aR[:stops][1][:claims][2][:state], "kept")
	Then("the promise before it is kept", aR[:stops][1][:claims][1][:state], "kept")
	Then("the tour FINISHED, as it promised, though Ring exited 1", aR[:end], "finished")
	Then("the runner exits 0", oT.ExitCode(), 0)
	Given("a trailing #--> that reads as a label, then the value on its own line")
	oL = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/kept/03_label.ring")
	aL = oL.Records()[1][:run]
	Then("one promise was read, not two", len(aL[:stops][1][:claims]), 1)
	Then("its value is the standalone line's", aL[:stops][1][:claims][1][:want], "[ 1, 2 ]")
	Then("and it is kept", aL[:stops][1][:claims][1][:state], "kept")
	Given("a promise that argues with itself")
	oP = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/prose/01_prose.ring")
	aP = oP.Records()[1][:run]
	Then("the reader calls it prose", aP[:stops][1][:claims][1][:kind], "prose")
	Then("the traveller leaves it unjudged", aP[:stops][1][:claims][1][:state], "unjudged")
	Then("nothing diverged", aP[:diverged], 0)
	Then("the runner exits 0: a note is not a broken promise", oP.ExitCode(), 0)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Did-not-compile is not diverged; a raise part-way leaves the promises below it unreached")
	nTpSec = clock()
	Given("a planted tour with a promise and a syntax error")
	oC = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/nostart/01_syntax.ring")
	aC = oC.Records()[1][:run]
	Then("the tour did not start", aC[:end], "not-started")
	Then("its promise is unreached, not diverged", "" + aC[:unreached] + "/" + aC[:diverged], "1/0")
	Given("a planted tour with an unclosed string literal (a scanner error)")
	oS = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/nostart/02_scanner.ring")
	Then("it did not start either", oS.Records()[1][:run][:end], "not-started")
	Then("both exit 1: a tour that did not start", "" + oC.ExitCode() + "/" + oS.ExitCode(), "1/1")
	Given("a planted tour: a true promise, a division by zero, a true promise")
	oRz = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/raised/01_partway.ring")
	aRr = oRz.Records()[1][:run]
	Then("the tour broke", aRr[:end], "broke")
	Then("the first promise is kept", aRr[:stops][1][:claims][1][:state], "kept")
	Then("the second is unreached, not diverged", aRr[:stops][1][:claims][2][:state], "unreached")
	Then("one finding, not two", aRr[:diverged], 0)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("A picture that does not match is diverged and names its row; a picture that matches is kept")
	nTpSec = clock()
	Given("a planted tour whose Shows() prints PICTURE DOES NOT MATCH and raises")
	oM = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/picture/01_mismatch.ring")
	aM = oM.Records()[1][:run]
	Then("the reader read a picture claim", oM.Records()[1][:stops][1][:claims][1][:kind], "picture")
	Then("the tour is diverged", aM[:state], "diverged")
	Then("the verdict names the row",
		StzFindFirst("first difference at row 2", aM[:stops][1][:claims][2][:claim]) > 0, TRUE)
	Then("the tour's ending is the assertion's own, not a break", aM[:end], "finished")
	Then("the runner exits 1", oM.ExitCode(), 1)
	Given("a planted tour whose Shows() is silent")
	oKept = TravellerQ().Silent().Timeout(10000).Walk(cTpPlant + "/picture/02_match.ring")
	aKept = oKept.Records()[1][:run]
	Then("the picture is kept", aKept[:stops][1][:claims][1][:state], "kept")
	Then("the runner exits 0", oKept.ExitCode(), 0)
	Given("one real plot example under ../plot that calls Shows()")
	cPlot = _TpFirstPictureTour(cTpHere + "/../plot")
	? "        (" + cPlot + ")"
	oPl = TravellerQ().Silent().Timeout(60000).Walk(cPlot)
	aPl = oPl.Records()[1][:run]
	? "        " + _TravRunProse(oPl.Records()[1])
	Then("it was found", cPlot != "", TRUE)
	Then("its pictures were walked", len(oPl.Records()[1][:stops][1][:claims]) > 0, TRUE)
	Then("and the run ended as finished or finished-timed",
		aPl[:end] = "finished" or aPl[:end] = "finished-timed", TRUE)
EndScenario()
? "        [section took " + ((clock() - nTpSec) / clockspersecond()) + "s]"

_TpUnplantAll(cTpPlant)
? ""
? "[TR2 took " + ((clock() - nTpStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _TpPlantAll(cRoot)
	_TpUnplantAll(cRoot)
	StzMakeDir(cRoot)
	StzMakeDir(cRoot + "/lies")
	StzMakeDir(cRoot + "/kept")
	StzMakeDir(cRoot + "/prose")
	StzMakeDir(cRoot + "/nostart")
	StzMakeDir(cRoot + "/raised")
	StzMakeDir(cRoot + "/picture")
	_nl_ = char(10)
	write(cRoot + "/lies/01_lie.ring", "? 1 + 1" + _nl_ + "#--> 3" + _nl_)
	write(cRoot + "/lies/02_two_lies.ring",
		'? "alpha"  #--> beta' + _nl_ + '? "gamma"  #--> delta' + _nl_)
	write(cRoot + "/lies/03_short_hidden.ring",
		"? 3  #--> 6" + _nl_ + '? "[ 6, 28 ]"  #--> [ 6, 28 ]' + _nl_)
	write(cRoot + "/kept/01_variants.ring",
		"? 1 = 1  #--> TRUE" + _nl_ +
		"? 1 = 2  #--> FALSE (absent)" + _nl_ +
		'? "13"  #--> "13"' + _nl_ +
		"? :Number  #--> :Number" + _nl_ +
		'? "[ 6, 28 ]"  #--> [6, 28]' + _nl_ +
		'? [ "a", "b" ]  #--> ["a", "b"]' + _nl_ +
		'? ""  #--> ' + "''" + _nl_ +
		"? 5  #--> 5  # a note after the value" + _nl_)
	write(cRoot + "/kept/02_error.ring",
		'? "before"  #--> before' + _nl_ +
		"? Boom()  #--> ERROR: boom happened" + _nl_ +
		"func Boom()" + _nl_ + char(9) + 'raise("boom happened")' + _nl_)
	write(cRoot + "/kept/03_label.ring",
		'? "[ 1, 2 ]"   #--> Leads to a normal Ring list' + _nl_ +
		"#--> [ 1, 2 ]" + _nl_)
	write(cRoot + "/prose/01_prose.ring",
		'? "C"  #--> "C" but should be "sm_AS"' + _nl_)
	write(cRoot + "/nostart/01_syntax.ring",
		"? 1  #--> 1" + _nl_ + "if 1 = 1" + _nl_ + '? "unclosed if"' + _nl_)
	write(cRoot + "/nostart/02_scanner.ring",
		"? 1  #--> 1" + _nl_ + '? "an unclosed literal' + _nl_)
	write(cRoot + "/raised/01_partway.ring",
		"? 1  #--> 1" + _nl_ + "x = 1 / 0" + _nl_ + "? 2  #--> 2" + _nl_)
	write(cRoot + "/picture/01_mismatch.ring",
		'Shows("a", "b")' + _nl_ +
		"func Shows(a, b)" + _nl_ +
		char(9) + '? ""' + _nl_ +
		char(9) + '? "PICTURE DOES NOT MATCH"' + _nl_ +
		char(9) + '? "  expected 3 rows, got 3"' + _nl_ +
		char(9) + '? "  first difference at row 2:"' + _nl_ +
		char(9) + '? "    expected |x|"' + _nl_ +
		char(9) + '? "    actual   |y|"' + _nl_ +
		char(9) + 'raise("The picture does not match what the example says it shows.")' + _nl_)
	write(cRoot + "/picture/02_match.ring",
		'Shows("a", "a")' + _nl_ +
		"func Shows(a, b)" + _nl_ + char(9) + "return 1" + _nl_)

func _TpUnplantAll(cRoot)
	if fexists(cRoot + "/lies/01_lie.ring")
		StzDirDeleteAll(cRoot)
	ok

# the first tour under a folder that the reader says carries a picture claim
func _TpFirstPictureTour(cDir)
	_aTwo_ = _TourFilesUnder(cDir, "")
	_aF_ = _aTwo_[1]
	_n_ = len(_aF_)
	for _k_ = 1 to _n_
		_aRec_ = Tour(_aF_[_k_])
		_aC_ = _TourClaimsOf(_aRec_)
		_nC_ = len(_aC_)
		for _c_ = 1 to _nC_
			if _aC_[_c_][:kind] = "picture"  return _aF_[_k_]  ok
		next
	next
	return ""
