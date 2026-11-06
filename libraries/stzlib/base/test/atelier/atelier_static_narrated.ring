load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"
load "../../../atelier/atelierEdition.ring"

# THE ATELIER, A3 -- reach. The static edition is built from a pinned commit's own
# data by one command, refuses to mix commits, carries no Ring column and no machine
# path, and a citation `<commit>:<id>` resolves to its check or is refused.
#
# Run from this folder, on rnxc:
#     rnxc atelier_static_narrated.ring
# The builder and the resolver are Ring++ (atelier/atelierEdition.ring, the command line
# atelier/edition.ring), ported from Python on 2026-11-06: the guard calls them in-process,
# and starts the command line twice for its exit codes (each child compiles edition.ring
# once, about 25 s cold). Planted data is written under _planted_static/ (ignored by git).

? "ATELIER A3 -- the static edition and the citation"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = _AtelierNormalize(cAtHere + "/../../../atelier")
cAtPlant = cAtHere + "/_planted_static"

_AtPlant(cAtPlant, cAtAtelier)
cSrc = cAtPlant + "/src"

#============================================================================
Scenario("One command builds the edition from one commit's data")
	Given("a planted folder: the page, the dictionary, two checks, their recording and a sweep, all at abc123def")
	aB = AtelierBuildChecks(cAtPlant + "/out1", cSrc, 0, cAtAtelier)
	When("the builder runs")
	if NOT aB[:ok]  ? "    " + _AtJoin(aB[:why])  ok
	Then("it succeeds", aB[:ok], 1)
	Then("it names the edition by its commit", aB[:commit], "abc123def")
	cEd = cAtPlant + "/out1/abc123def"
	Then("the checks page is there", fexists(cEd + "/index.html"), TRUE)
	Then("the coverage page", fexists(cEd + "/coverage.html"), TRUE)
	Then("the single-check page", fexists(cEd + "/check.html"), TRUE)
	Then("the data it reads", fexists(cEd + "/data/checks.json") and fexists(cEd + "/data/results.json") and fexists(cEd + "/data/tours.json") and fexists(cEd + "/data/i18n.json"), TRUE)
	Then("an edition.json says what judged it", StzFindFirst('"commit": "abc123def"', read(cEd + "/edition.json")) > 0, TRUE)
	Then("the editions list names it", StzFindFirst("abc123def", read(cAtPlant + "/out1/editions.json")) > 0, TRUE)
	cIdx = read(cEd + "/index.html")
	Then("the page knows it is an edition", StzFindFirst('const EDITION = {"commit": "abc123def"', cIdx) > 0, TRUE)
	Then("and no longer carries the live marker", StzFindFirst("const EDITION = null;", cIdx) = 0, TRUE)
EndScenario()

Scenario("No Ring column rides into an edition")
	Given("the planted source holds a verdicts.json, Ring's answers")
	Then("the source has one", fexists(cSrc + "/verdicts.json"), TRUE)
	Then("the edition carries none", fexists(cAtPlant + "/out1/abc123def/data/verdicts.json") or fexists(cAtPlant + "/out1/abc123def/verdicts.json"), FALSE)
	Then("the edition says so", StzFindFirst('"ring_column": false', read(cAtPlant + "/out1/abc123def/edition.json")) > 0, TRUE)
	Then("and the page it carries never asks for verdicts", StzFindFirst("verdicts: null", read(cAtPlant + "/out1/abc123def/index.html")) > 0, TRUE)
EndScenario()

Scenario("No machine path goes out: a recording made without the scrub is mended and counted")
	Given("the planted recording holds a failure that quotes a path of the machine that took it")
	cRes = read(cAtPlant + "/out1/abc123def/data/results.json")
	Then("the path is gone from the edition's data", StzFindFirst("someone", cRes) = 0, TRUE)
	Then("a name stands in its place", StzFindFirst("<path>", cRes) > 0, TRUE)
	Then("and the data is still JSON, the failure's two lines kept", StzJsonToList(cRes)[:said][1][2], "FAIL" + char(10) + "3" + char(10) + "2 at <path>")
	Then("the maintainer was told", StzFindFirst("machine path(s) replaced", _AtJoin(aB[:notes])) > 0, TRUE)
EndScenario()

Scenario("The three files must name one commit, else the build is refused")
	Given("a sweep taken at another commit than the recording")
	_AtWrite(cSrc + "/tours.json", _AtTours("zzz999aaa on main"))
	aM = AtelierBuildChecks(cAtPlant + "/out2", cSrc, 0, cAtAtelier)
	Then("it is refused, as a mix", "" + aM[:ok] + "/" + aM[:mixed], "0/1")
	Then("it says which file to take again", StzFindFirst("the sweep (tours.json) was taken at zzz999aaa", _AtJoin(aM[:why])) > 0, TRUE)
	Then("and nothing was written", fexists(cAtPlant + "/out2/abc123def/index.html"), FALSE)
	aA = AtelierBuildChecks(cAtPlant + "/out3", cSrc, 1, cAtAtelier)
	Then("allowing the mix builds it anyway", aA[:ok], 1)
	Then("and the edition says it is mixed", StzFindFirst('"mixed": true', read(cAtPlant + "/out3/abc123def/edition.json")) > 0, TRUE)
	_AtWrite(cSrc + "/tours.json", _AtTours("abc123def on main"))
	Given("a recording and checks that name different ids")
	_AtWrite(cSrc + "/results.json", StzReplace(_AtResults(), "#22222222", "#33333333"))
	aI = AtelierBuildChecks(cAtPlant + "/out4", cSrc, 0, cAtAtelier)
	Then("that is refused too", aI[:ok], 0)
	Then("naming the ids", StzFindFirst("do not name the same ids", _AtJoin(aI[:why])) > 0, TRUE)
	_AtWrite(cSrc + "/results.json", _AtResults())
EndScenario()

Scenario("The committed data names a commit that this history has")
	Given("the Atelier's own checks, recording and sweep, built as they stand")
	aH = AtelierBuildChecks(cAtPlant + "/out5", "", 0, cAtAtelier)
	if NOT aH[:ok]  ? "    the builder said: " + _AtJoin(aH[:why])  ok
	Then("the real data builds: one commit, in this history", aH[:ok], 1)
	Then("the edition is named by that commit", fexists(cAtPlant + "/out5/" + aH[:commit] + "/index.html"), TRUE)
EndScenario()

Scenario("The output may not be placed inside the library, where an install would copy it")
	aN = AtelierBuildChecks(cAtAtelier + "/_x", "", 0, cAtAtelier)
	Then("refused", aN[:ok], 0)
	Then("saying why", StzFindFirst("inside the Atelier folder", _AtJoin(aN[:why])) > 0, TRUE)
	Then("and nothing was written there", StzEngineDirExists(cAtAtelier + "/_x"), 0)
	aD = AtelierBuildChecks("", "", 0, cAtAtelier)
	Then("no out folder, no default", aD[:ok], 0)
EndScenario()

Scenario("A citation resolves to its check, or is refused with the reason")
	Given("the planted data at abc123def")
	aC = AtelierCiteCheck("abc123def:planted/00_p_narrated#22222222", cSrc)
	Then("it resolves", aC[:ok], 1)
	cJ = AtelierCiteCheckRender(aC[:record], "json")
	Then("to the check's description", StzFindFirst('"description": "two is three"', cJ) > 0, TRUE)
	Then("and its recorded state", StzFindFirst('"state": "fail"', cJ) > 0, TRUE)
	Then("with what was said when it failed", StzFindFirst('"said": "FAIL', cJ) > 0, TRUE)
	Then("and what judged it", StzFindFirst('"library": "abc123def on main"', cJ) > 0, TRUE)
	cMd = AtelierCiteCheckRender(AtelierCiteCheck("abc123def:planted/00_p_narrated#11111111", cSrc)[:record], "markdown")
	Then("markdown names the state and the citation", StzFindFirst("Recorded state: **pass**", cMd) > 0 and StzFindFirst("Citation: `abc123def:planted/00_p_narrated#11111111`", cMd) > 0, TRUE)
	aW = AtelierCiteCheck("fffffff00:planted/00_p_narrated#11111111", cSrc)
	Then("another commit is refused", aW[:ok], 0)
	Then("saying where the data was recorded", StzFindFirst("recorded at abc123def", aW[:why]) > 0, TRUE)
	Then("an absent id is refused", AtelierCiteCheck("abc123def:planted/nonesuch#00000000", cSrc)[:ok], 0)
	Then("a text that is not a citation is refused", AtelierCiteCheck("no-colon-here", cSrc)[:ok], 0)
EndScenario()

Scenario("The command line says the same, with an exit code a script can read")
	# the tool loads the library relative to where it stands, so the child starts in the Atelier's folder
	_AtWrite(cSrc + "/tours.json", _AtTours("zzz999aaa on main"))
	aX = _AtRun([ AtelierRnxc(), "edition.ring", "build-checks", "--from", cSrc, "--out", cAtPlant + "/out6" ], cAtAtelier)
	_AtWrite(cSrc + "/tours.json", _AtTours("abc123def on main"))
	if aX[1] != 2  ? "    the child said: " + left(aX[2], 600)  ok
	Then("a mixed build exits 2", aX[1], 2)
	Then("naming the file to take again", StzFindFirst("REFUSED, the three files do not describe one commit", aX[2]) > 0 and StzFindFirst("the sweep (tours.json)", aX[2]) > 0, TRUE)
	aY = _AtRun([ AtelierRnxc(), "edition.ring", "cite", "abc123def:planted/00_p_narrated#22222222", "--data", cSrc, "--format", "markdown" ], cAtAtelier)
	if aY[1] != 0  ? "    the child said: " + left(aY[2], 600)  ok
	Then("a check's citation resolves, exit 0", aY[1], 0)
	Then("and prints the record it names", StzFindFirst("Recorded state: **fail**", aY[2]) > 0 and StzFindFirst("Citation: `abc123def:planted/00_p_narrated#22222222`", aY[2]) > 0, TRUE)
EndScenario()

Scenario("The public tree carries no machine path")
	Given("every data file, source and document of the Atelier")
	acFiles = [ "checks.json", "results.json", "tours.json", "verdicts.json", "i18n.json", "EMBED.md", "SOFTANZA_ATELIER_PLAN.md",
	            "atelier.ring", "atelierClient.ring", "atelierEdition.ring", "edition.ring", "tours.ring", "record.ring", "atelier.html",
	            "harvest.py", "verdicts.py" ]
	cBad = ""
	for i = 1 to len(acFiles)
		if AtelierHasDrivePath(read(cAtAtelier + "/" + acFiles[i]))  cBad += acFiles[i] + " "  ok
	next
	if cBad != ""  ? "    carrying a drive path: " + cBad  ok
	Then("no file of the Atelier holds a drive path", cBad, "")
EndScenario()

StzDirDeleteAll(cAtPlant)
Summary()
shutdown($_zst_fail)

func _AtJoin(pacWhy)
	_c_ = ""
	for _i_ = 1 to len(pacWhy)
		_c_ += pacWhy[_i_] + " | "
	next
	return _c_

# a program by argv in a folder: [ exit code, stdout and stderr together ]
func _AtRun(pacArgv, pcDir)
	_oP_ = new stzProcess()
	_oP_.SpawnIn(pcDir, pacArgv)
	_cOut_ = _oP_.ReadOutputAll()
	# the timed wait leaves the pipes open, so stderr can still be read after the exit
	# (the plain Wait() closes them: a refusal's words went missing)
	_nX_ = _oP_.WaitFor(180000)
	_cErr_ = _oP_.ReadErrorAll()
	_oP_.Close()
	return [ _nX_, _cOut_ + char(10) + _cErr_ ]

func _AtWrite(pcFile, pcText)
	write(pcFile, pcText)

func _AtResults()
	_nl_ = char(10)
	_bs_ = char(92)
	# "FAIL", a newline, "3", a newline, "2 at " and a Windows path -- as JSON writes them
	_cSaid_ = "FAIL" + _bs_ + "n3" + _bs_ + "n2 at D:" + _bs_ + _bs_ + "Users" + _bs_ + _bs_ + "someone" + _bs_ + _bs_ + "x.ring"
	return '{"taken": "2026-01-01 00:00", "library": "abc123def on main", "rnxc": "ringpp x", "engine": "an engine", "checks_from": "abc123def", "checks": 2,' + _nl_ +
	       '"pass": 1, "fail": 1, "err": 0, "median_ms": 1, "total_ms": 2,' + _nl_ +
	       '"states": {"planted/00_p_narrated#11111111": "pass", "planted/00_p_narrated#22222222": "fail"},' + _nl_ +
	       '"said": {"planted/00_p_narrated#22222222": "' + _cSaid_ + '"}}' + _nl_

func _AtTours(pcLibrary)
	_nl_ = char(10)
	return '{"taken": "2026-01-01 00:00", "library": "' + pcLibrary + '", "rnxc": "ringpp x", "engine": "an engine", "tests_from": "' + pcLibrary + '",' + _nl_ +
	       '"totals": {"files": 1, "finished": 1, "broke": 0, "not_started": 0, "hung": 0, "unreadable": 0, "kept_code": 0, "claims": 2, "judged": 2, "kept": 1, "diverged": 1, "unreached": 0, "unjudged": 0, "unperceived": 0, "extra": 0, "ms": 5},' + _nl_ +
	       '"domains": {"planted": {"files": 1, "finished": 1, "broke": 0, "not_started": 0, "hung": 0, "unreadable": 0, "kept_code": 0, "claims": 2, "judged": 2, "kept": 1, "diverged": 1, "unreached": 0, "unjudged": 0, "unperceived": 0, "extra": 0, "ms": 5}},' + _nl_ +
	       '"files": []}' + _nl_

# the planted source: the real page and dictionary, and the smallest data that is consistent
func _AtPlant(pcRoot, pcAtelier)
	if fexists(pcRoot + "/src/checks.json")
		StzDirDeleteAll(pcRoot)
	ok
	StzDirCreatePath(pcRoot + "/src")
	write(pcRoot + "/src/atelier.html", read(pcAtelier + "/atelier.html"))
	write(pcRoot + "/src/i18n.json", read(pcAtelier + "/i18n.json"))
	_nl_ = char(10)
	_c1_ = _AtCheck("11111111", "1", "5", "one is one", "1, 1")
	_c2_ = _AtCheck("22222222", "2", "6", "two is three", "2, 3")
	write(pcRoot + "/src/checks.json", '{"source": "base/test", "commit": "abc123def", "taken": "2026-01-01 00:00", "files": 1, "thens": 2, "checks": [' + _nl_ + _c1_ + "," + _nl_ + _c2_ + _nl_ + "]}" + _nl_)
	write(pcRoot + "/src/results.json", _AtResults())
	write(pcRoot + "/src/tours.json", _AtTours("abc123def on main"))
	write(pcRoot + "/src/verdicts.json", '{"meta": {}, "verdicts": {}}' + _nl_)

func _AtCheck(pcId, pcN, pcLine, pcDesc, pcArgs)
	# a JSON string cannot hold a raw newline or tab: write the two-character escapes
	_bs_ = char(92)
	_cCode_ = "func Run cInput" + _bs_ + "n" + _bs_ + "treturn AtelierThen(" + pcArgs + ")" + _bs_ + "n"
	return '{"id": "planted/00_p_narrated#' + pcId + '", "n": ' + pcN + ', "domain": "planted", "file": "planted/00_p_narrated.ring", "line": ' + pcLine + ', "scenario": "a scenario", "desc": "' + pcDesc + '", "code": "' + _cCode_ + '"}'
