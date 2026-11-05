load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, B2 -- the notebook. A notebook IS a narrated test file: running cell k
# runs cells 1 to k as one admission, top to bottom, so a name a cell makes is the one
# the cells below it read. A cell's definitions (from its first func, def or class line)
# move after every cell's statements, as Ring requires. A Then line is judged by `=`,
# as the suite judges it. Saved, the notebook is a file testoor reads and its own
# runner judges; opened back, it is the same cells.
#
# Run from this folder, on rnxc:
#     rnxc atelier_notebook_narrated.ring
# About a minute warm: the child Atelier's compile of the library, a dozen notebook
# runs, then the court: testoor's runner walks the saved file in a child rnxc of its
# own, which pays a compile of the library too when the library has just changed.

? "ATELIER B2 -- the notebook"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8666
cAtSettings = cAtHere + "/_planted_settings_notebook.ring"
# directly under base/test, so the saved file's own loads (../../stzBase.ring) resolve
cAtPlant = cAtHere + "/../_planted_notebook"
_nl_ = char(10)

oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
aAtState = AtelierWaitReady(nAtPort, 600000, oAt)
if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok

# the notebook the court judges at the end: a name made in cell 1, read in cell 2,
# a helper defined in cell 3 and called in cell 2, one claim that fails
aAtBook = [
	[ :title = "the orders", :code = 'o1 = new stzList([ "tea", "rice", "tea", "fish" ])' + _nl_ + "? o1.NumberOfItems()" + _nl_ + "#--> 4" + _nl_ ],
	[ :title = "their repeats", :code = "? @@( o1.DuplicatesRemoved() )" + _nl_ + '#--> [ "tea", "rice", "fish" ]' + _nl_ +
	                                    'Then("a helper from another cell", Twice(21), 42)' + _nl_ +
	                                    'Then("a claim that fails", 1 + 1, 3)' + _nl_ ],
	[ :title = "a helper", :code = "func Twice n" + _nl_ + char(9) + "return 2 * n" + _nl_ ]
]

#============================================================================
Scenario("A name a cell makes is the one the cells below it read")
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	aN = _AtNotebook(nAtPort, 2, aAtBook)
	Then("cells 1 and 2 ran", aN[:ran], 2)
	Then("two promises kept before cell 2 calls a helper cell 3 defines", aN[:kept], 2)
	Then("cell 1's promise kept", aN[:sees][1][:state], "kept")
	Then("cell 2 read o1, made by cell 1: kept", aN[:sees][2][:state], "kept")
	Then("the map: the second line seen is cell 2's line 1", _AtWhere(aN, aN[:sees][2][:line]), "2:1")
EndScenario()

Scenario("A cell's definitions move after every cell's statements")
	aN = _AtNotebook(nAtPort, 3, aAtBook)
	Then("all three cells ran", aN[:ran], 3)
	Then("cell 2 called Twice, which cell 3 defines: kept", aN[:sees][3][:state], "kept")
	Then("the last line of the composed file is cell 3's line 2", _AtWhere(aN, len(aN[:map])), "3:2")
	aN = _AtNotebook(nAtPort, 2, aAtBook)
	Then("running up to cell 2 leaves cell 3's definitions out: the call breaks", aN[:end], "broke")
	Then("and the missing function is named", StzFindFirst("twice", lower(aN[:why])) > 0, TRUE)
	Then("the Then line that called it was not reached", aN[:sees][3][:state], "unreached")
EndScenario()

Scenario("A Then line is judged as the suite judges it")
	aN = _AtNotebook(nAtPort, 3, aAtBook)
	aS = aN[:sees][3]
	Then("a Then line is seen as a Then", aS[:kind], "then")
	Then("named by its description", aS[:expr], "a helper from another cell")
	Then("its actual value in a face", aS[:values][1][:payload], "42")
	Then("its expected value shown", aS[:promise], "42")
	aS = aN[:sees][4]
	Then("1 + 1 = 3 diverged", aS[:state], "diverged")
	Then("what came is 2", aS[:values][1][:payload], "2")
	Then("the notebook counts: 3 kept, 1 diverged", "" + aN[:kept] + "/" + aN[:diverged], "3/1")
	aQ = _AtNotebook(nAtPort, 1, [ [ :title = "", :code = 'Then("it' + "'" + 's a string", Q("a, b").Uppercased(), "A, B")' + _nl_ ] ])
	Then("a description with a quote, an argument with a comma: kept", aQ[:sees][1][:state], "kept")
	Then("a string's expected value is shown as code", aQ[:sees][1][:promise], '"A, B"')
EndScenario()

Scenario("Nothing is kept between two runs")
	aN = _AtNotebook(nAtPort, 1, [ [ :title = "", :code = "zzqLeftBehind = 5" + _nl_ + "? zzqLeftBehind" + _nl_ ] ])
	Then("the first run made the name", aN[:sees][1][:values][1][:payload], "5")
	aN = _AtNotebook(nAtPort, 1, [ [ :title = "", :code = '? isglobal("zzqLeftBehind")' + _nl_ ] ])
	Then("the next run does not know it", aN[:sees][1][:values][1][:payload], "0")
EndScenario()

Scenario("Saved as a narrated test file, opened back as the same cells")
	aBook = aAtBook
	aBook + [ :title = 'a "quoted" title', :code = "? 2" + _nl_ + _nl_ + _nl_ + "? 3" + _nl_ ]
	cSaved = _AtPost(nAtPort, "/atelier/notebook/save", _AtCellsJson(0, aBook))
	Then("the file loads the library", StzFindFirst('load "../../stzBase.ring"', cSaved) > 0, TRUE)
	Then("and the narrated helpers", StzFindFirst('load "../_narrated.ring"', cSaved) > 0, TRUE)
	Then("each cell is a Scenario", StzFindFirst('Scenario("their repeats")', cSaved) > 0, TRUE)
	Then("a title keeps its quotes, wrapped in a mark it does not use", StzFindFirst("Scenario('a " + '"quoted"' + " title')", cSaved) > 0, TRUE)
	Then("the definitions come after Summary()", StzFindFirst("# definitions of cell 3", cSaved) > StzFindFirst("Summary()", cSaved), TRUE)
	aBack = StzJsonToList(_AtPost(nAtPort, "/atelier/notebook/open", cSaved))[:cells]
	Then("four cells came back", len(aBack), 4)
	nSame = 0
	for i = 1 to len(aBack)
		if aBack[i][:title] = aBook[i][:title] and _AtTrimNl(aBack[i][:code]) = _AtTrimNl(aBook[i][:code])  nSame++  ok
	next
	Then("each the same title and the same code, blank lines included", nSame, 4)
EndScenario()

Scenario("testoor reads the saved file, and its own runner agrees with the notebook")
	StzDirCreate(cAtPlant)
	cPath = cAtPlant + "/notebook_narrated.ring"
	write(cPath, _AtPost(nAtPort, "/atelier/notebook/save", _AtCellsJson(0, aAtBook)))
	aT = Tour(cPath)
	Then("the reader reads it as narrated", aT[:dialect], "narrated")
	Then("one stop per cell", len(aT[:stops]), 3)
	Then("the stops are the cells' titles", aT[:stops][2][:title], "their repeats")
	aN = _AtNotebook(nAtPort, 3, aAtBook)
	nT1 = clock()
	oT = TravellerQ().Silent().Timeout(300000).Walk(cPath)
	aChild = oT.Records()[1][:run]
	? "    testoor's runner, a child rnxc: " + aChild[:state] + ", " + aChild[:kept] + " kept, " + aChild[:diverged] + " diverged, " + _AtelierNum((clock() - nT1) / clockspersecond()) + " s"
	Then("the runner finished the file", aChild[:end], "finished")
	Then("it kept what the notebook kept", aChild[:kept], aN[:kept])
	Then("it diverged where the notebook diverged", aChild[:diverged], aN[:diverged])
	remove(cPath)
EndScenario()

Scenario("The Atelier stops when asked")
	Then("it answered", AtelierStop(nAtPort), TRUE)
	Then("and the child ended", oAt.WaitFor(10000) != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

func _AtCellsJson(pnRun, paCells)
	_c_ = "{"
	if pnRun > 0  _c_ += '"run":' + pnRun + ","  ok
	_c_ += '"cells":['
	for _i_ = 1 to len(paCells)
		if _i_ > 1  _c_ += ","  ok
		_c_ += '{"title":' + _AtelierJsonStr(paCells[_i_][:title]) + ',"code":' + _AtelierJsonStr(paCells[_i_][:code]) + "}"
	next
	return _c_ + "]}"

func _AtPost(pnPort, pcPath, pcBody)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(60)
	_oH_.Post("http://127.0.0.1:" + pnPort + pcPath, pcBody)
	return _oH_.ResponseBody()

func _AtNotebook(pnPort, pnRun, paCells)
	_c_ = _AtPost(pnPort, "/atelier/notebook", _AtCellsJson(pnRun, paCells))
	if left(_c_, 1) != "{"
		return [ :end = "no answer", :why = _c_, :ran = 0, :sees = [], :map = [], :kept = 0, :diverged = 0 ]
	ok
	return StzJsonToList(_c_)

# a line of the composed file, as "cell:line"
func _AtWhere(paN, pnLine)
	if pnLine < 1 or pnLine > len(paN[:map])  return "none"  ok
	return "" + paN[:map][pnLine][1] + ":" + paN[:map][pnLine][2]

func _AtTrimNl(pcText)
	_c_ = pcText
	while right(_c_, 1) = char(10)
		_c_ = left(_c_, len(_c_) - 1)
	end
	return _c_
