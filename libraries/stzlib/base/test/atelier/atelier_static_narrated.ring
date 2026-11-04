load "../../stzBase.ring"
load "../_narrated.ring"

# THE ATELIER, A3 -- reach. The static edition is built from a pinned commit's own
# data by one command, refuses to mix commits, carries no Ring column and no machine
# path, and a citation `<commit>:<id>` resolves to its check or is refused.
#
# Run from this folder, on rnxc:
#     rnxc atelier_static_narrated.ring
# A few seconds. The builder and the resolver are python (maintainer tools, like the
# harvester): the whole guard is SKIPPED by name when python is not on the path.
# Planted data is written under _planted_static/ (ignored by git).

? "ATELIER A3 -- the static edition and the citation"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtPlant = cAtHere + "/_planted_static"
cPy = _AtPython()

if cPy = ""
	? "    SKIPPED by name: python is not on the path, and the builder and the resolver are python"
	Summary()
	shutdown($_zst_fail)
ok

_AtPlant(cAtPlant, cAtAtelier)
cSrc = cAtPlant + "/src"

#============================================================================
Scenario("One command builds the edition from one commit's data")
	Given("a planted folder: the page, the dictionary, two checks, their recording and a sweep, all at abc123def")
	aB = _AtRun([ cPy, "build_static.py", "--from", cSrc, "--out", cAtPlant + "/out1" ], cAtAtelier)
	When("build_static.py runs")
	Then("it succeeds", aB[1], 0)
	Then("it names the edition by its commit", StzFindFirst("edition abc123def", aB[2]) > 0, TRUE)
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
	Then("the maintainer was told", StzFindFirst("machine path(s) replaced", aB[2]) > 0, TRUE)
EndScenario()

Scenario("The three files must name one commit, else the build is refused")
	Given("a sweep taken at another commit than the recording")
	_AtWrite(cSrc + "/tours.json", _AtTours("zzz999aaa on main"))
	aM = _AtRun([ cPy, "build_static.py", "--from", cSrc, "--out", cAtPlant + "/out2" ], cAtAtelier)
	Then("it is refused, exit 2", aM[1], 2)
	Then("it says which file to take again", StzFindFirst("the sweep (tours.json) was taken at zzz999aaa", aM[2]) > 0, TRUE)
	Then("and nothing was written", fexists(cAtPlant + "/out2/abc123def/index.html"), FALSE)
	aA = _AtRun([ cPy, "build_static.py", "--from", cSrc, "--out", cAtPlant + "/out3", "--allow-mixed" ], cAtAtelier)
	Then("--allow-mixed builds it anyway", aA[1], 0)
	Then("and the edition says it is mixed", StzFindFirst('"mixed": true', read(cAtPlant + "/out3/abc123def/edition.json")) > 0, TRUE)
	_AtWrite(cSrc + "/tours.json", _AtTours("abc123def on main"))
	Given("a recording and checks that name different ids")
	_AtWrite(cSrc + "/results.json", substr(_AtResults(), "#22222222", "#33333333"))
	aI = _AtRun([ cPy, "build_static.py", "--from", cSrc, "--out", cAtPlant + "/out4" ], cAtAtelier)
	Then("that is refused too", aI[1], 2)
	Then("naming the ids", StzFindFirst("do not name the same ids", aI[2]) > 0, TRUE)
	_AtWrite(cSrc + "/results.json", _AtResults())
EndScenario()

Scenario("The output may not be placed inside the library, where an install would copy it")
	aN = _AtRun([ cPy, "build_static.py", "--out", cAtAtelier + "/_x" ], cAtAtelier)
	Then("refused", aN[1] != 0, TRUE)
	Then("saying why", StzFindFirst("inside the Atelier folder", aN[2]) > 0, TRUE)
	Then("and nothing was written there", fexists(cAtAtelier + "/_x"), FALSE)
	aD = _AtRun([ cPy, "build_static.py" ], cAtAtelier)
	Then("no --out, no default", aD[1] != 0, TRUE)
EndScenario()

Scenario("A citation resolves to its check, or is refused with the reason")
	Given("the planted data at abc123def")
	aC = _AtRun([ cPy, "cite.py", "abc123def:planted/00_p_narrated#22222222", "--data", cSrc ], cAtAtelier)
	Then("it resolves", aC[1], 0)
	Then("to the check's description", StzFindFirst('"description": "two is three"', aC[2]) > 0, TRUE)
	Then("and its recorded state", StzFindFirst('"state": "fail"', aC[2]) > 0, TRUE)
	Then("with what was said when it failed", StzFindFirst('"said": "FAIL', aC[2]) > 0, TRUE)
	Then("and what judged it", StzFindFirst('"library": "abc123def on main"', aC[2]) > 0, TRUE)
	aMd = _AtRun([ cPy, "cite.py", "abc123def:planted/00_p_narrated#11111111", "--data", cSrc, "--format", "markdown" ], cAtAtelier)
	Then("markdown names the state and the citation", StzFindFirst("Recorded state: **pass**", aMd[2]) > 0 and StzFindFirst("Citation: `abc123def:planted/00_p_narrated#11111111`", aMd[2]) > 0, TRUE)
	aW = _AtRun([ cPy, "cite.py", "fffffff00:planted/00_p_narrated#11111111", "--data", cSrc ], cAtAtelier)
	Then("another commit is refused, exit 2", aW[1], 2)
	Then("saying where the data was recorded", StzFindFirst("recorded at abc123def", aW[2]) > 0, TRUE)
	aX = _AtRun([ cPy, "cite.py", "abc123def:planted/nonesuch#00000000", "--data", cSrc ], cAtAtelier)
	Then("an absent id is refused, exit 2", aX[1], 2)
	aY = _AtRun([ cPy, "cite.py", "no-colon-here", "--data", cSrc ], cAtAtelier)
	Then("a text that is not a citation is refused", aY[1], 2)
EndScenario()

Scenario("The public tree carries no machine path")
	Given("every data file, source and document of the Atelier")
	acFiles = [ "checks.json", "results.json", "tours.json", "verdicts.json", "i18n.json", "EMBED.md", "SOFTANZA_ATELIER_PLAN.md",
	            "atelier.ring", "atelierClient.ring", "tours.ring", "record.ring", "atelier.html", "build_static.py", "cite.py", "harvest.py", "verdicts.py" ]
	cCode = "import re,sys,os" + char(10) +
	        "rx=re.compile(r'(?<![A-Za-z0-9])[A-Za-z]:[\\/]')" + char(10) +
	        "bad=[]" + char(10) +
	        "for f in sys.argv[1:]:" + char(10) +
	        char(9) + "t=open(f,encoding='utf-8',errors='replace').read()" + char(10) +
	        char(9) + "if rx.search(t): bad.append(os.path.basename(f))" + char(10) +
	        "print(','.join(bad))" + char(10) +
	        "sys.exit(1 if bad else 0)" + char(10)
	acArgv = [ cPy, "-c", cCode ]
	for i = 1 to len(acFiles)
		acArgv + (cAtAtelier + "/" + acFiles[i])
	next
	aP = _AtRun(acArgv, cAtAtelier)
	if aP[1] != 0  ? "    carrying a drive path: " + trim(aP[2])  ok
	Then("no file of the Atelier holds a drive path", aP[1], 0)
EndScenario()

Summary()
shutdown($_zst_fail)

# python, when it is on the path
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

# a program by argv in a folder: [ exit code, stdout and stderr together ]
func _AtRun(pacArgv, pcDir)
	_oP_ = new stzProcess()
	_oP_.SpawnIn(pcDir, pacArgv)
	_cOut_ = _oP_.ReadOutputAll()
	# the timed wait leaves the pipes open, so stderr can still be read after the exit
	# (the plain Wait() closes them: a refusal's words went missing)
	_nX_ = _oP_.WaitFor(60000)
	_cErr_ = _oP_.ReadErrorAll()
	_oP_.Close()
	return [ _nX_, _cOut_ + char(10) + _cErr_ ]

func _AtWrite(pcFile, pcText)
	write(pcFile, pcText)

func _AtResults()
	_nl_ = char(10)
	_bs_ = char(92)
	# "FAIL", a newline, "3", a newline, "2 at D:\Users\someone\x.ring" -- as JSON writes them
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
	if fexists(pcRoot + "/src")
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
