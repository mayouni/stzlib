load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, B1 -- the process. A chain on a `?` line is unfolded step by step:
# each method runs ONCE, on what the step before it answered, held by ref() so a
# chain that changes its object changes it exactly as the line written whole does
# (plain variables would copy the object and detach the chain from it); each step's
# value and its time are kept, and the same move is offered in its other forms. A
# scene's object is captured after every complete line, changed or not.
#
# Run from this folder, on rnxc:
#     rnxc atelier_process_narrated.ring
# About a minute: the child Atelier's compile of the library, then a dozen cells.

? "ATELIER B1 -- the chain and the scene unfolded"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8665
cAtSettings = cAtHere + "/_planted_settings_process.ring"
_nl_ = char(10)

oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
aAtState = AtelierWaitReady(nAtPort, 600000, oAt)
if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok

#============================================================================
Scenario("A chain is unfolded: one step per call, each with its value and its time")
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	aC = _AtCell(nAtPort, '? Q("softanza").UppercaseQ().Spacified()   #--> S O F T A N Z A' + _nl_)
	aS = aC[:sees][1]
	Then("three steps", len(aS[:steps]), 3)
	Then("the root first", aS[:steps][1][:text], 'Q("softanza")')
	Then("then each call", aS[:steps][2][:text] + " " + aS[:steps][3][:text], ".UppercaseQ() .Spacified()")
	Then("the root's value: the object, as it stands", aS[:steps][1][:payload], '"softanza"')
	Then("after UppercaseQ: the object changed", aS[:steps][2][:payload], '"SOFTANZA"')
	Then("the last step is the line's value", aS[:steps][3][:payload], "S O F T A N Z A")
	Then("every step has a time on the monotonic clock", aS[:steps][1][:ns] > 0 and aS[:steps][2][:ns] > 0 and aS[:steps][3][:ns] > 0, TRUE)
	Then("and the promise is judged on the line's value, kept", aS[:state], "kept")
EndScenario()

Scenario("A chain that changes a named object changes it as the line written whole does")
	aC = _AtCell(nAtPort,
		'o1 = new stzList([ "tea", "rice", "tea" ])' + _nl_ +
		'? @@( o1.RemoveDuplicatesQ().AddQ("soup").Content() )   #--> [ "tea", "rice", "soup" ]' + _nl_ +
		'? @@( o1.Content() )   #--> [ "tea", "rice", "soup" ]' + _nl_)
	Then("the chain inside @@( ) is unfolded too", len(aC[:sees][1][:steps]), 4)
	Then("the root is the object before the line", aC[:sees][1][:steps][1][:payload], '[ "tea", "rice", "tea" ]')
	Then("the line's value", aC[:sees][1][:state], "kept")
	Then("and the object itself is changed afterwards: ref() kept the chain attached", aC[:sees][2][:state], "kept")
EndScenario()

Scenario("The same move in its other forms, only when it has them")
	aC = _AtCell(nAtPort, '? Q("softanza").UppercaseQ().Spacified()' + _nl_)
	aF = aC[:sees][1][:forms]
	Then("two forms", len(aF), 2)
	Then("the scene: the Q dropped inside the braces", aF[1][:code], 'Q("softanza") {' + _nl_ + "    Uppercase()" + _nl_ + "    ? Spacified()" + _nl_ + "}" + _nl_)
	Then("the classic: a name, then one line per call", aF[2][:code], "o1 = Q(" + '"softanza"' + ")" + _nl_ + "o1.Uppercase()" + _nl_ + "? o1.Spacified()" + _nl_)
	aT = _AtCell(nAtPort, '? Q("abc").Uppercased()' + _nl_)
	Then("a root and one call: two steps", len(aT[:sees][1][:steps]), 2)
	Then("and no other form", len(aT[:sees][1][:forms]), 0)
	aN = _AtCell(nAtPort, '? Q("abc").Uppercased().Size()' + _nl_)
	Then("a middle step that is not a Q method offers no form", len(aN[:sees][1][:forms]), 0)
EndScenario()

Scenario("What is not a chain is not unfolded")
	aC = _AtCell(nAtPort, '? 1 + Q("ab").NumberOfChars()   #--> 3' + _nl_)
	Then("no steps: an operator outside a call is not a chain", len(aC[:sees][1][:steps]), 0)
	Then("the line runs as written", aC[:sees][1][:state], "kept")
EndScenario()

Scenario("A chain in a loop keeps the steps of its first pass only")
	aC = _AtCell(nAtPort, 'for i = 1 to 3' + _nl_ + '    ? Q("ab").Uppercased()' + _nl_ + 'next' + _nl_)
	Then("three values", len(aC[:sees][1][:values]), 3)
	Then("two steps, not six", len(aC[:sees][1][:steps]), 2)
EndScenario()

Scenario("A scene is unfolded: the object after each line, and the lines that changed it")
	aC = _AtCell(nAtPort,
		'o1 = new stzList([ "tea", "rice", "tea", "fish" ])' + _nl_ +
		'o1 {' + _nl_ +
		'    ? @@( DuplicatesRemoved() )' + _nl_ +
		'    RemoveDuplicates()' + _nl_ +
		'    Add("soup")' + _nl_ +
		'    ? NumberOfItems()   #--> 4' + _nl_ +
		'}' + _nl_)
	aSc = aC[:scenes]
	Then("one scene", len(aSc), 1)
	Then("named after its object", aSc[1][:name], "o1")
	Then("from its opening line to its closing one", "" + aSc[1][:line] + "-" + aSc[1][:end], "2-7")
	aSt = aSc[1][:states]
	Then("the object before, then after each of the four lines", len(aSt), 5)
	Then("DuplicatesRemoved() leaves it as it was", aSt[2][:changed], 0)
	Then("RemoveDuplicates() changes it", aSt[3][:changed], 1)
	Then("to the list without its repeats", aSt[3][:payload], '[ "tea", "rice", "fish" ]')
	Then("Add() changes it again", aSt[4][:changed], 1)
	Then("NumberOfItems() only asks", aSt[5][:changed], 0)
	Then("and the scene's own promise is kept", aC[:sees][2][:state], "kept")
EndScenario()

Scenario("A statement over several lines is captured once, when it is complete")
	aC = _AtCell(nAtPort,
		'o1 = new stzList([ "a" ])' + _nl_ +
		'o1 {' + _nl_ +
		'    Add(' + _nl_ +
		'        "b"' + _nl_ +
		'    )' + _nl_ +
		'    ? NumberOfItems()' + _nl_ +
		'}' + _nl_)
	Then("the cell runs", aC[:end], "finished")
	aSt = aC[:scenes][1][:states]
	cLines = ""
	for i = 1 to len(aSt)
		cLines += "" + aSt[i][:line] + " "
	next
	Then("the states are taken after lines 2, 5 and 6, never inside the call", trim(cLines), "2 5 6")
EndScenario()

Scenario("The Atelier stops when asked")
	Then("it answered", AtelierStop(nAtPort), TRUE)
	Then("and the child ended", oAt.WaitFor(10000) != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

func _AtCell(pnPort, pcCode)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(60)
	_oH_.Post("http://127.0.0.1:" + pnPort + "/atelier/cell", pcCode)
	if _oH_.ResponseCode() != 200
		return [ :end = "http " + _oH_.ResponseCode(), :why = _oH_.ResponseBody(), :sees = [], :scenes = [] ]
	ok
	return StzJsonToList(_oH_.ResponseBody())
