load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, A2 -- the experience. A check's id stays stable when its file
# changes elsewhere; the page speaks two languages whole, from one dictionary
# file; the page is served at its three addresses and names what judges it.
#
# Run from this folder, on rnxc:
#     rnxc atelier_page_narrated.ring
# About 60 s: the harvester runs twice on a planted test folder (python, a
# maintainer's tool: named SKIPPED when python is not on the path), then an
# Atelier boots for the page.

? "ATELIER A2 -- ids, languages, the page"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8662
cAtSettings = cAtHere + "/_planted_settings_page.ring"
cAtPlant = cAtHere + "/_planted_page"

#============================================================================
Scenario("A check's id stays the same when its file changes elsewhere")
	Given("a planted narrated file harvested, then harvested again with a line added above its checks")
	cPy = _AtPython()
	if cPy = ""
		? "    SKIPPED by name: the harvester is a python tool and python is not on the path"
	else
		_AtPlantTests(cAtPlant, 0)
		cOut1 = _AtHarvest(cPy, cAtPlant + "/tests", cAtPlant + "/one")
		_AtPlantTests(cAtPlant, 1)
		cOut2 = _AtHarvest(cPy, cAtPlant + "/tests", cAtPlant + "/two")
		aOne = StzJsonToList(read(cAtPlant + "/one/checks.json"))
		aTwo = StzJsonToList(read(cAtPlant + "/two/checks.json"))
		When("the two harvests are compared")
		Then("both harvested the same two checks", "" + len(aOne[:checks]) + "/" + len(aTwo[:checks]), "2/2")
		Then("the first check's id did not move", aOne[:checks][1][:id], aTwo[:checks][1][:id])
		Then("the second's neither", aOne[:checks][2][:id], aTwo[:checks][2][:id])
		Then("while its line did move", aTwo[:checks][2][:line] - aOne[:checks][2][:line], 2)
		Then("an id names its file and a digest", StzFindFirst("planted/00_planted_narrated#", aOne[:checks][1][:id]) > 0, TRUE)
		Then("two checks of one file have two ids", aOne[:checks][1][:id] != aOne[:checks][2][:id], TRUE)
	ok
EndScenario()

Scenario("The checks, the results and the verdicts in the tree share the same ids")
	Given("checks.json, results.json and verdicts.json beside the Atelier")
	aC = StzJsonToList(read(cAtAtelier + "/checks.json"))
	aR = StzJsonToList(read(cAtAtelier + "/results.json"))
	aV = StzJsonToList(read(cAtAtelier + "/verdicts.json"))
	acIds = []
	for i = 1 to len(aC[:checks])
		acIds + aC[:checks][i][:id]
	next
	nR = 0
	for i = 1 to len(aR[:states])
		if find(acIds, aR[:states][i][1]) > 0  nR++  ok
	next
	nV = 0
	for i = 1 to len(aV[:verdicts])
		if find(acIds, aV[:verdicts][i][1]) > 0  nV++  ok
	next
	Then("every recorded state names a harvested check", nR, len(aC[:checks]))
	Then("every verdict too", nV, len(aC[:checks]))
	Then("an id is a file and a digest, never a rank", StzFindFirst("#", acIds[1]) > 0, TRUE)
EndScenario()

Scenario("The page speaks two languages whole, from one dictionary")
	Given("i18n.json and the page")
	aL = StzJsonToList(read(cAtAtelier + "/i18n.json"))
	cPage = read(cAtAtelier + "/atelier.html")
	acEn = []
	for i = 1 to len(aL[:en])
		acEn + aL[:en][i][1]
	next
	nMissingFr = 0
	for i = 1 to len(acEn)
		if NOT HasKey(aL[:fr], acEn[i])  nMissingFr++  ok
	next
	# every key the page asks for, as data-t="key" or t('key', is in the dictionary
	nAsked = 0  nUnknown = 0
	acAsk = StzSplit(cPage, 'data-t="')
	for i = 2 to len(acAsk)
		cKey = left(acAsk[i], StzFindFirst('"', acAsk[i]) - 1)
		nAsked++
		if find(acEn, cKey) = 0  nUnknown++  ok
	next
	# a call t('key' is the t function when the character before it is not part of
	# a longer name (get('lang', split('{' and setItem('x' are not translations)
	nPos = 1
	nLen = len(cPage)
	while nPos < nLen
		nRel = substr(substr(cPage, nPos), "t('")
		if nRel = 0  exit  ok
		nAt = nPos + nRel - 1
		nPos = nAt + 3
		cBefore = " "
		if nAt > 1  cBefore = cPage[nAt - 1]  ok
		if isalnum(cBefore) or cBefore = "." or cBefore = "_"  loop  ok
		cRest = substr(cPage, nAt + 3, 60)
		nQ = substr(cRest, "'")
		if nQ < 2  loop  ok
		cKey = left(cRest, nQ - 1)
		nAsked++
		if find(acEn, cKey) = 0 and left(cKey, 6) != "state_" and left(cKey, 4) != "end_" and left(cKey, 5) != "ring_"
			nUnknown++
			? "    unknown key asked by the page: " + cKey
		ok
	end
	Then("the English dictionary has its keys", len(acEn) > 80, TRUE)
	Then("French has every English key", nMissingFr, 0)
	? "    the page asks for " + nAsked + " keys (data-t and t() calls)"
	Then("the page asks for many keys", nAsked > 40, TRUE)
	Then("and every one it asks for exists", nUnknown, 0)
	Then("no string of the page is hard-wired past the dictionary: the menu says Checks only as a default", StzFindFirst('data-t="menu_checks"', cPage) > 0, TRUE)
EndScenario()

Scenario("The page is served at its three addresses, with its dictionary, and names what judges it")
	oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
	aS = AtelierWaitReady(nAtPort, 600000, oAt)
	Then("the library is admitted", aS[:library][:state], "admitted")
	oH = new stzHttpClient()
	oH.SetTimeout(10)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier")
	cHome = oH.ResponseBody()
	Then("/atelier answers the page", oH.ResponseCode(), 200)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier/coverage")
	Then("/atelier/coverage answers the same page", oH.ResponseBody() = cHome, TRUE)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier/playground")
	Then("/atelier/playground too", oH.ResponseBody() = cHome, TRUE)
	oH.Get_("http://127.0.0.1:" + nAtPort + "/atelier/i18n")
	Then("/atelier/i18n answers the dictionary", StzFindFirst('"fr"', oH.ResponseBody()) > 0, TRUE)
	Then("the page carries a trail from the root", StzFindFirst('aria-label="Breadcrumb"', cHome) > 0, TRUE)
	Then("a main menu of three short labels", len(StzSplit(cHome, 'data-view="')) - 1, 3)
	Then("nothing moves: every transition and animation is refused", StzFindFirst("transition:none!important;animation:none!important", cHome) > 0, TRUE)
	Then("one reading size, the site's", StzFindFirst("--read:1.3125rem", cHome) > 0, TRUE)
	Then("the state names what judges a check", aS[:library][:commit] != "" and aS[:rnxc][:build] != "", TRUE)
	AtelierStop(nAtPort)
	oAt.WaitFor(10000)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

# python, when it is on the path (a maintainer's tool; the harvester is one)
func _AtPython()
	_oP_ = new stzProcess()
	try
		_oP_.Spawn("python --version")
		_c_ = _oP_.ReadOutputAll()
		_oP_.Wait()
		_oP_.Close()
		if StzFindFirst("Python 3", _c_) > 0  return "python"  ok
	catch
	done
	return ""

# a planted test tree: planted/00_planted_narrated.ring with two checks; with
# pbShifted, two comment lines are added above the second check
func _AtPlantTests(cRoot, pbShifted)
	_nl_ = char(10)
	StzDirCreatePath(cRoot + "/tests/planted")
	_c_ = 'load "../../stzBase.ring"' + _nl_ + 'load "../_narrated.ring"' + _nl_ + _nl_ +
	      'Scenario("planted")' + _nl_ +
	      char(9) + 'Then("one is one", 1, 1)' + _nl_
	if pbShifted
		_c_ += char(9) + "# a line added above" + _nl_ + char(9) + "# and another" + _nl_
	ok
	_c_ += char(9) + 'Then("two is two", 2, 2)' + _nl_
	write(cRoot + "/tests/planted/00_planted_narrated.ring", _c_)

# the harvester on a tests folder, its output copied into pcOut/checks.json
func _AtHarvest(pcPython, pcTests, pcOut)
	StzDirCreatePath(pcOut)
	_cAtelier_ = substr(currentdir(), "\", "/") + "/../../../atelier"
	_oP_ = new stzProcess()
	_oP_.SpawnIn(_cAtelier_, [ pcPython, "harvest.py", "--tests=" + pcTests, "--out=" + pcOut + "/checks.json" ])
	_c_ = _oP_.ReadOutputAll()
	_oP_.Wait()
	_oP_.Close()
	return _c_
