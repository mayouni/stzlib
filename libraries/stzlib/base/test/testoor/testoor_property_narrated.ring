load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR V2 -- PROPERTIES. A property is ONE claim checked over many inputs drawn from a declared
# domain, in ONE walk: on Haro a walk pays the library's compile, so a property that started a child
# per input would cost minutes. The core generates the inputs from the domain and a seed, and orders
# the candidates that shrink a failure (TESTOOR_PROTOCOL_3.md section 4); TestoorProperty() only calls
# the check. A property that held raises the nodes it is about on the evidence ladder: to
# GENERALISED, or to EXHAUSTED when every value of a finite domain was tried.
#
# Every positive has its sibling: a domain tried whole and one drawn from; a property that holds and
# one that fails; a failure shrunk to the same smallest input from two seeds; a tour that holds up
# (its nodes rise) beside one that fails (its nodes stay observed).
#
# The text property that fails is chosen to show what a shrink is for: "a text's length in BYTES equals
# its length in LETTERS" is false for any text with a letter outside ASCII, and from any such text the
# shrink arrives at the shortest, simplest one -- the first non-ASCII letter of the alphabet, alone.
# That is the stzlib law "len() counts bytes, StzLen() counts letters", found by a machine.

? "TESTOOR V2 -- properties"
nPrStart = clock()
cPrHere = currentdir()
cPrPlant = cPrHere + "/_planted_property"

#============================================================================
Scenario("The core's domains, through the Ring seam: every value when there are few, else the origin and seeded draws")
	nPrSec = clock()
	Given("a dec domain of 26 values, asked for up to 100 inputs")
	aPrD = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"rate dec 0..0.25 step 0.01","seed":42,"tries":100}'))
	Then("it is tried whole: exhaustive, 26 of 26", "" + aPrD[:exhaustive] + "/" + aPrD[:of] + "/" + len(aPrD[:inputs]), "1/26/26")
	Then("a dec is exact text, never a float: the first, the eighth and the last",
	     aPrD[:inputs][1][:rate] + " " + aPrD[:inputs][8][:rate] + " " + aPrD[:inputs][26][:rate], "0.00 0.07 0.25")
	Given("an int domain of 101 values, asked for 10")
	aPrI = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"n int 0..100","seed":42,"tries":10}'))
	Then("it is drawn from: not exhaustive, of 101, ten inputs", "" + aPrI[:exhaustive] + "/" + aPrI[:of] + "/" + len(aPrI[:inputs]), "0/101/10")
	Then("the first input is the origin, the value nearest zero", aPrI[:inputs][1][:n], 0)
	nPrOut = 0
	for nPr = 1 to len(aPrI[:inputs])
		if aPrI[:inputs][nPr][:n] < 0 or aPrI[:inputs][nPr][:n] > 100  nPrOut++  ok
	next
	Then("every draw is inside the domain", nPrOut, 0)
	aPrI2 = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"n int 0..100","seed":42,"tries":10}'))
	aPrI3 = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"n int 0..100","seed":43,"tries":10}'))
	Then("the same seed draws the same inputs", _PrJoin(aPrI[:texts]) = _PrJoin(aPrI2[:texts]), TRUE)
	Then("another seed draws others", _PrJoin(aPrI[:texts]) = _PrJoin(aPrI3[:texts]), FALSE)
	Given("a text domain over every alphabet")
	aPrT = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"s text 0..12 of mixed","seed":5,"tries":20}'))
	Then("it is unbounded: no size is written", StzFindFirst('"of"', StzEngineTestoorProperty('{"op":"inputs","domain":"s text 0..12 of mixed","seed":5,"tries":2}')), 0)
	Then("and its origin is the empty text", aPrT[:inputs][1][:s], "")
	Given("a failing input, and the candidates the core offers to shrink it")
	aPrS = StzJsonToList(StzEngineTestoorProperty('{"op":"shrink","domain":"n int 0..100","input":{"n":100}}'))
	Then("an int halves its distance to zero: 0, 50, 75, 88, 94, 97, 99", _PrValues(aPrS[:candidates], :n), "0,50,75,88,94,97,99")
	aPrS2 = StzJsonToList(StzEngineTestoorProperty('{"op":"shrink","domain":"s text 0..5 of ascii","input":{"s":"ab"}}'))
	Then("a text gets shorter first, then its letters earlier: '', a, b, aa", _PrValues(aPrS2[:candidates], :s), ",a,b,aa")
	Then("a domain the core cannot read raises a Ring error and breaks nothing", _PrRaises('{"op":"inputs","domain":"n int 9..1","tries":3}'), 1)
	Then("so does an input that is not one of the domain's values", _PrRaises('{"op":"shrink","domain":"n int 0..4","input":{"n":9}}'), 1)
EndScenario()
? "        [section took " + ((clock() - nPrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("TestoorProperty in this process: held whole, failed and shrunk to the same answer from two seeds")
	nPrSec = clock()
	Given("a square is never negative, over every int from -50 to 50")
	aPrA = TestoorProperty("SQUARE-NOT-NEGATIVE", "n int -50..50", "_PrSquareNotNegative", [ :tries = 200, :seed = 5, :print = 0 ])
	Then("it held, and every value was tried: exhausted", "" + aPrA[:held] + "/" + aPrA[:exhaustive] + "/" + aPrA[:tried] + "/" + aPrA[:of], "1/1/101/101")
	Given("a square is under 50, over 0 to 100 -- false from 8 on")
	aPrB = TestoorProperty("SQUARE-UNDER-50", "n int 0..100", "_PrSquareUnder50", [ :tries = 20, :seed = 5, :print = 0 ])
	aPrB2 = TestoorProperty("SQUARE-UNDER-50", "n int 0..100", "_PrSquareUnder50", [ :tries = 20, :seed = 6, :print = 0 ])
	Then("it failed", aPrB[:held], 0)
	Then("and shrank to the smallest counterexample, 8", aPrB[:counterexample], '{"n":8}')
	Then("from another seed, to the same 8", aPrB2[:counterexample], '{"n":8}')
	Then("the shrink's path ends where the counterexample is", aPrB[:path][len(aPrB[:path])], '{"n":8}')
	Given("a text's length in bytes equals its length in letters, over texts in every alphabet")
	aPrC = TestoorProperty("BYTES-ARE-LETTERS", "s text 0..8 of mixed", "_PrBytesAreLetters", [ :tries = 200, :seed = 5, :print = 0 ])
	aPrC2 = TestoorProperty("BYTES-ARE-LETTERS", "s text 0..8 of mixed", "_PrBytesAreLetters", [ :tries = 200, :seed = 6, :print = 0 ])
	Then("it failed: len() counts bytes", aPrC[:held], 0)
	Then("and shrank to ONE letter, the first outside ASCII: U+00E0", aPrC[:counterexample], '{"s":"' + _PrUtf8(224) + '"}')
	Then("from another seed, to the same letter", aPrC2[:counterexample], aPrC[:counterexample])
	Given("the library's own law: replacing a letter by a letter keeps the length in letters, over texts in every alphabet")
	aPrD2 = TestoorProperty("REPLACE-KEEPS-LENGTH", "s text 0..12 of mixed", "_PrReplaceKeepsLength", [ :tries = 200, :seed = 5, :print = 0 ])
	Then("it held over 200 texts; the domain is unbounded, so the grade it gives is generalised, not exhausted",
	     "" + aPrD2[:held] + "/" + aPrD2[:exhaustive] + "/" + aPrD2[:tried] + "/" + aPrD2[:of], "1/0/200/")
	Given("a choice among three algorithms, where the last one fails")
	aPrE = TestoorProperty("NOT-HEAP", "algo one quick|merge|heap", "_PrNotHeap", [ :tries = 10, :print = 0 ])
	Then("all three were tried, the third failed, and nothing simpler fails", "" + aPrE[:held] + "/" + aPrE[:tried] + "/" + aPrE[:shrinks] + "/" + aPrE[:counterexample], '0/3/0/{"algo":"heap"}')
	Given("the line TestoorProperty prints, judged by the core as a child's output")
	cPrOut = "250" + char(9) + "[testoor stop squares]" + char(10) + "500" + char(9) + "[testoor node stzMath.Square 20]" + char(10) +
	         "750" + char(9) + aPrB[:line] + char(10) + "1000" + char(9) + "[testoor end timed]" + char(10)
	aPrV = StzJsonToList(StzEngineTestoorVerdict('{"record":{"file":"squares.ring","dialect":"protocol","asserts":1,"stops":[],"routes":[]},"output":' +
	        _TourJsonStr(cPrOut) + ',"meta":{"exit":0,"hung":0,"stderr":"","wall_ms":1000,"seed":5,"unreadable":0,"face":{"ignore":"","endings":[]}}}'))
	Then("the property is the stop's claim, and it diverged", aPrV[:stops][1][:claims][1][:claim] + ":" + aPrV[:stops][1][:claims][1][:state], "property SQUARE-UNDER-50:diverged")
	Then("the tour keeps the record, counterexample included", aPrV[:properties][1][:counterexample][:n], 8)
EndScenario()
? "        [section took " + ((clock() - nPrSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("Lists: stzList's own Verb/Verbed pairs checked over generated lists of numbers, texts in every alphabet, and lists of lists")
	nPrSec = clock()
	Given("a list domain through the seam: lists of up to two 0s and 1s")
	aPrL = StzJsonToList(StzEngineTestoorProperty('{"op":"inputs","domain":"xs list 0..2 of int 0..1","seed":1,"tries":10}'))
	Then("seven lists, tried whole, shortest first", "" + aPrL[:exhaustive] + "/" + aPrL[:of] + "/" + _PrJoin(aPrL[:texts]),
	     '1/7/{"xs":[]}|{"xs":[0]}|{"xs":[1]}|{"xs":[0,0]}|{"xs":[0,1]}|{"xs":[1,0]}|{"xs":[1,1]}|')
	aPrLS = StzJsonToList(StzEngineTestoorProperty('{"op":"shrink","domain":"xs list 0..5 of int 0..9","input":{"xs":[3,1]}}'))
	Then("a list shrinks shorter first, then element by element", _PrJoin(aPrLS[:texts]),
	     '{"xs":[]}|{"xs":[3]}|{"xs":[1]}|{"xs":[0,1]}|{"xs":[2,1]}|{"xs":[3,0]}|')
	Given("Reverse() and Reversed(), over lists of numbers")
	aPrR = TestoorProperty("LIST-REVERSE-PAIR", "xs list 0..12 of int -50..50", "_PrReversePair", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("Reverse() leaves the list as Reversed() returns it", aPrR[:held], 1)
	aPrR2 = TestoorProperty("LIST-REVERSE-TWICE", "ws list 0..8 of text 0..4 of mixed", "_PrReverseTwice", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("and reversing twice gives the list back, over texts in every alphabet", aPrR2[:held], 1)
	Given("Sort() and Sorted()")
	aPrS = TestoorProperty("LIST-SORT-PAIR", "xs list 0..12 of int -50..50", "_PrSortPair", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("Sort() leaves the list as Sorted() returns it", aPrS[:held], 1)
	aPrS2 = TestoorProperty("LIST-SORTED-IN-ORDER", "xs list 0..12 of int -50..50", "_PrSortedInOrder", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("Sorted() puts every number before the next, and keeps the length", aPrS2[:held], 1)
	aPrS3 = TestoorProperty("LIST-SORT-TWICE", "ws list 0..8 of text 0..4 of mixed", "_PrSortTwice", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("sorting a sorted list of texts changes nothing", aPrS3[:held], 1)
	Given("Flatten() and Flattened(), over lists of lists")
	aPrF = TestoorProperty("LIST-FLATTEN-PAIR", "ls list 0..4 of list 0..3 of int 0..9", "_PrFlattenPair", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("Flatten() leaves the list as Flattened() returns it", aPrF[:held], 1)
	aPrF2 = TestoorProperty("LIST-FLATTEN-COUNTS", "ls list 0..4 of list 0..3 of int 0..9", "_PrFlattenCounts", [ :tries = 150, :seed = 5, :print = 0 ])
	Then("Flattened() keeps every element: its length is the sum of the inner lengths", aPrF2[:held], 1)
	Given("a law that is false: a list equals itself sorted")
	aPrX = TestoorProperty("LIST-IS-SORTED", "xs list 0..8 of int 0..9", "_PrIsSorted", [ :tries = 100, :seed = 5, :print = 0 ])
	aPrX2 = TestoorProperty("LIST-IS-SORTED", "xs list 0..8 of int 0..9", "_PrIsSorted", [ :tries = 100, :seed = 6, :print = 0 ])
	Then("it fails, and shrinks to the smallest unsorted list, [1,0]", aPrX[:counterexample], '{"xs":[1,0]}')
	Then("from another seed, to the same [1,0]", aPrX2[:counterexample], '{"xs":[1,0]}')
EndScenario()
? "        [section took " + ((clock() - nPrSec) / clockspersecond()) + "s]"

#============================================================================
cPrExe = TestoorNativeExe()
if cPrExe = ""
	? ""
	? "SKIPPED by name, because the native runner is not built:"
	? "  the property tours walked as children (cd engine && zig build testoor-exe -j2)"
else
Scenario("Property tours walked as children, the ladder asked for: a tour that holds up raises its node, one that fails does not")
	nPrSec = clock()
	_PrPlant(cPrPlant)
	acPr = [ cPrPlant + "/replace_tour.ring", cPrPlant + "/bytes_tour.ring" ]
	Given("one tour whose text property holds, one whose text property fails; each loads the library")
	write(cPrPlant + "/manifest.json", TestoorManifestJson(acPr, [ :seed = 5, :timeout_ms = 180000, :ladder = TRUE ]))
	aPrN = _PrRun([ "run", cPrPlant + "/manifest.json", "--json" ])
	aPrJ = StzJsonToList(aPrN[2])
	Then("the run is protocol 3 and exits 1, for the failing tour", "" + aPrJ[:protocol] + "/" + aPrN[1], "3/1")
	Then("the first tour kept its property", aPrJ[:tours][1][:state] + ":" + aPrJ[:tours][1][:properties][1][:held], "kept:1")
	Then("the second diverged, its counterexample shrunk to one letter in the child too", aPrJ[:tours][2][:properties][1][:counterexample][:s], _PrUtf8(224))
	Then("Replace is generalised, by the property that held", aPrJ[:ladder][:nodes][1][:id] + ":" + aPrJ[:ladder][:nodes][1][:grade] + ":" +
	     aPrJ[:ladder][:nodes][1][:properties][1], "stzString.Replace:generalised:REPLACE-KEEPS-LENGTH")
	Then("Len stays observed: a tour that failed raises nothing", aPrJ[:ladder][:nodes][2][:id] + ":" + aPrJ[:ladder][:nodes][2][:grade], "stzString.Len:observed")
	Then("the ladder counts grades 3 and 4 when a run carries properties", "" + aPrJ[:ladder][:generalised] + "/" + aPrJ[:ladder][:exhausted], "1/0")
	aPrP = _PrRun([ "run", cPrPlant + "/manifest.json", "--prose" ])
	Then("the prose shows the counterexample and the seed that replays it",
	     StzFindFirst("counterexample  BYTES-ARE-LETTERS  {" + '"s":"' + _PrUtf8(224) + '"}  (seed 5,', aPrP[2]) > 0, TRUE)
	_PrUnplant(cPrPlant)
EndScenario()
? "        [section took " + ((clock() - nPrSec) / clockspersecond()) + "s]"
ok

? ""
? "[V2 took " + ((clock() - nPrStart) / clockspersecond()) + "s]"
Summary()
shutdown($_zst_fail)

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _PrSquareNotNegative(paIn)
	return paIn[:n] * paIn[:n] >= 0

func _PrSquareUnder50(paIn)
	return paIn[:n] * paIn[:n] < 50

func _PrBytesAreLetters(paIn)
	return len(paIn[:s]) = StzLen(paIn[:s])

func _PrReplaceKeepsLength(paIn)
	return StzLen(StzReplace(paIn[:s], "a", "b")) = StzLen(paIn[:s])

func _PrNotHeap(paIn)
	return paIn[:algo] != "heap"

func _PrReversePair(paIn)
	_o_ = new stzList(paIn[:xs])
	_o_.Reverse()
	return _o_.IsStrictlyEqualTo(new stzList(paIn[:xs]).Reversed())

func _PrReverseTwice(paIn)
	return new stzList(new stzList(new stzList(paIn[:ws]).Reversed()).Reversed()).IsStrictlyEqualTo(paIn[:ws])

func _PrSortPair(paIn)
	_o_ = new stzList(paIn[:xs])
	_o_.Sort()
	return _o_.IsStrictlyEqualTo(new stzList(paIn[:xs]).Sorted())

func _PrSortedInOrder(paIn)
	_a_ = new stzList(paIn[:xs]).Sorted()
	if len(_a_) != len(paIn[:xs])  return 0  ok
	for _i_ = 2 to len(_a_)
		if _a_[_i_ - 1] > _a_[_i_]  return 0  ok
	next
	return 1

func _PrSortTwice(paIn)
	_a_ = new stzList(paIn[:ws]).Sorted()
	return new stzList(new stzList(_a_).Sorted()).IsStrictlyEqualTo(_a_)

func _PrFlattenPair(paIn)
	_o_ = new stzList(paIn[:ls])
	_o_.Flatten()
	return _o_.IsStrictlyEqualTo(new stzList(paIn[:ls]).Flattened())

func _PrFlattenCounts(paIn)
	_n_ = 0
	for _i_ = 1 to len(paIn[:ls])
		_n_ += len(paIn[:ls][_i_])
	next
	return len(new stzList(paIn[:ls]).Flattened()) = _n_

func _PrIsSorted(paIn)
	return new stzList(paIn[:xs]).IsStrictlyEqualTo(new stzList(paIn[:xs]).Sorted())

func _PrJoin(pacList)
	_c_ = ""
	for _i_ = 1 to len(pacList)
		_c_ += pacList[_i_] + "|"
	next
	return _c_

# one dimension's values across a list of inputs, joined by commas
func _PrValues(paIns, pcKey)
	_c_ = ""
	for _i_ = 1 to len(paIns)
		if _i_ > 1  _c_ += ","  ok
		_c_ += "" + paIns[_i_][pcKey]
	next
	return _c_

func _PrRaises(pcReq)
	_b_ = 0
	try
		StzEngineTestoorProperty(pcReq)
	catch
		_b_ = 1
	done
	return _b_

# a code point as its UTF-8 bytes (two bytes below U+0800, which is all this guard needs)
func _PrUtf8(pnCp)
	if pnCp < 128  return char(pnCp)  ok
	return char(192 + floor(pnCp / 64)) + char(128 + (pnCp % 64))

func _PrRun(pacArgs)
	_oP_ = new stzProcess()
	_aArgv_ = [ TestoorNativeExe() ]
	for _i_ = 1 to len(pacArgs)
		_aArgv_ + pacArgs[_i_]
	next
	_oP_.SpawnIn(currentdir(), _aArgv_)
	_cOut_ = _oP_.ReadOutputAll()
	_nX_ = _oP_.Wait()
	_oP_.Close()
	return [ _nX_, _cOut_ ]

func _PrPlant(pcRoot)
	_PrUnplant(pcRoot)
	StzMakeDir(pcRoot)
	_n_ = char(10)
	write(pcRoot + "/replace_tour.ring",
		'load "../../../stzBase.ring"' + _n_ +
		'? "[testoor stop replace keeps the length of any text]"' + _n_ +
		'? "[testoor node stzString.Replace]"' + _n_ +
		'TestoorProperty("REPLACE-KEEPS-LENGTH", "s text 0..12 of mixed", "KeepsLength", [ :tries = 150, :seed = 5, :nodes = [ "stzString.Replace" ] ])' + _n_ +
		"func KeepsLength(paIn)" + _n_ +
		'	return StzLen(StzReplace(paIn[:s], "a", "b")) = StzLen(paIn[:s])' + _n_)
	write(pcRoot + "/bytes_tour.ring",
		'load "../../../stzBase.ring"' + _n_ +
		'? "[testoor stop a text has as many bytes as letters]"' + _n_ +
		'? "[testoor node stzString.Len]"' + _n_ +
		'TestoorProperty("BYTES-ARE-LETTERS", "s text 0..8 of mixed", "BytesAreLetters", [ :tries = 150, :seed = 5, :nodes = [ "stzString.Len" ] ])' + _n_ +
		"func BytesAreLetters(paIn)" + _n_ +
		"	return len(paIn[:s]) = StzLen(paIn[:s])" + _n_)

func _PrUnplant(pcRoot)
	if fexists(pcRoot + "/replace_tour.ring")
		StzDirDeleteAll(pcRoot)
	ok
