load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, B0 -- the cell. A cell is code the reader writes, run top to bottom
# as one admission on the live program and released. Every `?` line is seen with
# its value's FACE (text, list, table, drawing, object), and every `#-->` promise
# under it judged by testoor's own matcher: kept, diverged, unreached, unjudged.
#
# Run from this folder, on rnxc:
#     rnxc atelier_cell_narrated.ring
# About a minute: the guard's own start, the child Atelier's compile of the
# library (20 s warm), then a dozen cells at a few milliseconds each.

? "ATELIER B0 -- the cell and its faces"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8664
cAtSettings = cAtHere + "/_planted_settings_cell.ring"
_nl_ = char(10)

oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
aAtState = AtelierWaitReady(nAtPort, 600000, oAt)
if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok

#============================================================================
Scenario("A cell runs, and its ? lines are seen in a scene, with their promises kept")
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	aC = _AtCell(nAtPort,
		'o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])' + _nl_ +
		'o1 {' + _nl_ +
		'    ? NumberOfDuplicates()' + _nl_ +
		'    #--> 3' + _nl_ +
		'    RemoveDuplicates()' + _nl_ +
		'    ? @@( Content() )   #--> [ "tea", "rice", "fish" ]' + _nl_ +
		'}' + _nl_)
	Then("the cell finished", aC[:end], "finished")
	Then("two lines were seen", len(aC[:sees]), 2)
	Then("the first inside the scene, at its own line", aC[:sees][1][:line], 3)
	Then("its value is what the method answered", aC[:sees][1][:values][1][:payload], "3")
	Then("its promise, on the line under it, is kept", aC[:sees][1][:state], "kept")
	Then("a trailing promise is read too, and kept", aC[:sees][2][:state], "kept")
	Then("the object was changed by the verb before it", aC[:sees][2][:values][1][:payload], '[ "tea", "rice", "fish" ]')
	Then("the counts", "" + aC[:kept] + "/" + aC[:diverged], "2/0")
	Then("in milliseconds", aC[:ms] < 1000, TRUE)
EndScenario()

Scenario("A promise that does not hold is diverged, never kept")
	aC = _AtCell(nAtPort, '? 1 + 1   #--> 3' + _nl_)
	Then("diverged", aC[:sees][1][:state], "diverged")
	Then("what came is shown", aC[:sees][1][:values][1][:payload], "2")
	Then("the counts", "" + aC[:kept] + "/" + aC[:diverged], "0/1")
EndScenario()

Scenario("Each value comes in its own face")
	aL = _AtCell(nAtPort, '? [ 1, 2, 3 ]' + _nl_ + '#--> [ 1, 2, 3 ]' + _nl_)
	Then("a list is a list", aL[:sees][1][:values][1][:kind], "list")
	Then("with its count", aL[:sees][1][:values][1][:label], "3")
	Then("and its promise, against the list printed item by item, kept", aL[:sees][1][:state], "kept")
	aT = _AtCell(nAtPort, 'o2 = new stzTable([ [ "dish", "orders" ], [ "tea", 3 ], [ "rice", 2 ] ])' + _nl_ + '? o2' + _nl_)
	Then("a stzTable is a table", aT[:sees][1][:values][1][:kind], "table")
	Then("as its ToHtml() writes it", StzFindFirst("<table", aT[:sees][1][:values][1][:payload]) > 0, TRUE)
	aS = _AtCell(nAtPort, '? new stzBarPlot([ :A = 5, :B = 8, :C = 3 ])' + _nl_)
	Then("a plot is a drawing", aS[:sees][1][:values][1][:kind], "svg")
	Then("the engine's SVG", StzFindFirst("<svg", aS[:sees][1][:values][1][:payload]) > 0, TRUE)
	Then("named by its class", aS[:sees][1][:values][1][:label], "stzbarplot")
	aO = _AtCell(nAtPort, '? new stzList([ "a", "b" ])' + _nl_)
	Then("an object with a content shows its content", aO[:sees][1][:values][1][:kind] + " " + aO[:sees][1][:values][1][:payload], 'object [ "a", "b" ]')
	aX = _AtCell(nAtPort, '? "plain words"' + _nl_)
	Then("a string is text", aX[:sees][1][:values][1][:kind], "text")
	Then("and it asserts nothing", aX[:sees][1][:state], "")
EndScenario()

Scenario("A ? in a loop is seen once per pass")
	aC = _AtCell(nAtPort, 'for i = 1 to 3' + _nl_ + '    ? i * 10' + _nl_ + 'next' + _nl_)
	Then("one line", len(aC[:sees]), 1)
	Then("three values", len(aC[:sees][1][:values]), 3)
	Then("in the order they came", aC[:sees][1][:values][3][:payload], "30")
EndScenario()

Scenario("A cell that breaks: the promise before is kept, the one after unreached")
	aC = _AtCell(nAtPort, '? 1   #--> 1' + _nl_ + 'x = NoSuchFunctionInACell(1)' + _nl_ + '? 2   #--> 2' + _nl_)
	Then("the cell broke", aC[:end], "broke")
	Then("naming the error", StzFindFirst("nosuchfunctioninacell", lower(aC[:why])) > 0, TRUE)
	Then("the line before it is kept", aC[:sees][1][:state], "kept")
	Then("the line after it is unreached, not diverged", aC[:sees][2][:state], "unreached")
	Then("the counts", "" + aC[:kept] + "/" + aC[:diverged] + "/" + aC[:unreached], "1/0/1")
EndScenario()

Scenario("A cell that does not scan never starts")
	aC = _AtCell(nAtPort, '? "an unclosed literal' + _nl_)
	Then("not started", aC[:end], "not-started")
	Then("and says why", StzFindFirst("not admitted", aC[:why]) > 0, TRUE)
EndScenario()

Scenario("The program after a cell is the program before it")
	nBefore = AtelierState(nAtPort)[:functions]
	aC = _AtCell(nAtPort, 'func CellHelperOfTheGuard' + _nl_ + '    return 42' + _nl_)
	Then("a cell may define a function", aC[:end], "finished")
	Then("and it is released with the cell", AtelierState(nAtPort)[:functions], nBefore)
	aC = _AtCell(nAtPort, '? isfunction("cellhelperoftheguard")' + _nl_ + '#--> 0' + _nl_)
	Then("the next cell does not see it", aC[:sees][1][:state], "kept")
EndScenario()

Scenario("The page serves the notebook as home, and the checks at their own address")
	oH = new stzHttpClient()
	oH.SetTimeout(10)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier")
	cHome = oH.ResponseBody()
	Then("the home carries the notebook", StzFindFirst('id="view-notebook"', cHome) > 0, TRUE)
	Then("its menu names it first", StzFindFirst('data-view="notebook"', cHome) < StzFindFirst('data-view="checks"', cHome), TRUE)
	Then("the playground is gone from the menu", StzFindFirst('data-view="playground"', cHome), 0)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier/library")
	Then("/atelier/library serves the same page", oH.ResponseBody() = cHome, TRUE)
EndScenario()

Scenario("The Atelier stops when asked")
	Then("it answered", AtelierStop(nAtPort), TRUE)
	Then("and the child ended", oAt.WaitFor(10000) != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

# one cell, as the page sends it: the answer as a list
func _AtCell(pnPort, pcCode)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(60)
	_oH_.Post("http://127.0.0.1:" + pnPort + "/atelier/cell", pcCode)
	if _oH_.ResponseCode() != 200
		return [ :end = "http " + _oH_.ResponseCode(), :why = _oH_.ResponseBody(), :sees = [], :kept = 0, :diverged = 0, :unreached = 0, :ms = 0 ]
	ok
	return StzJsonToList(_oH_.ResponseBody())
