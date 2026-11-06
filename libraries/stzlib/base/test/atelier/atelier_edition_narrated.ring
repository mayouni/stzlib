load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"
load "../../../atelier/atelierEdition.ring"

# THE ATELIER, B4 -- the edition of a notebook. A notebook is RECORDED by a running Atelier
# (every cell's lines, values and verdicts, with the commit, the Ring++ build and the engine
# that answered), BUILT into one static page that runs nothing and fetches nothing, and each
# of its cells is CITED as <commit>:notebook/<name>#<hash>. The builder refuses what would
# make a citation lie: a notebook changed since its recording, a commit not in this history,
# a machine path, an out folder inside the Atelier.
#
# Run from this folder, on rnxc:
#     rnxc atelier_edition_narrated.ring
# About a minute warm: the child Atelier's compile of the library, the recording, the builds,
# and one child rnxc for the command line's exit code.

? "ATELIER B4 -- the edition of a notebook"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = _AtelierNormalize(cAtHere + "/../../../atelier")
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8668
cAtSettings = cAtHere + "/_planted_settings_edition.ring"
cAtPlant = cAtHere + "/_planted_edition"
cAtOut = cAtPlant + "/out"
cAtNotebook = cAtPlant + "/an-edition.ring"
_nl_ = char(10)
StzEduRemoveTree(cAtPlant)
StzEngineDirCreatePath(cAtPlant)

oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
aAtState = AtelierWaitReady(nAtPort, 600000, oAt)
if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok
cAtCommit = StzSplit(aAtState[:library][:commit], " ")[1]

# the notebook, written by the Atelier's own saver: a name made in cell 1, a chain, a claim that
# diverges, a drawing
cAtCells = '{"cells":[' +
	'{"title":"the orders","code":' + _AtelierJsonStr('o1 = new stzList([ "tea", "rice", "tea" ])' + _nl_ + "? o1.NumberOfItems()" + _nl_ + "#--> 3" + _nl_) + '},' +
	'{"title":"a chain","code":' + _AtelierJsonStr('? Q("ab").UppercaseQ().Spacified()' + _nl_ + "#--> A B" + _nl_) + '},' +
	'{"title":"a claim that fails","code":' + _AtelierJsonStr('Then("one and one", 1 + 1, 3)' + _nl_) + '},' +
	'{"title":"a drawing","code":' + _AtelierJsonStr("? new stzBarPlot([ :Tea = 2, :Rice = 1 ])" + _nl_) + '}]}'
oH = new stzHttpClient()
oH.SetTimeout(60)
oH.Post("http://127.0.0.1:" + nAtPort + "/atelier/notebook/save", cAtCells)
write(cAtNotebook, oH.ResponseBody())

#============================================================================
Scenario("A notebook is recorded by a running Atelier, with what judged it")
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	aR = AtelierRecordNotebook(nAtPort, cAtNotebook)
	if NOT aR[:ok]  ? "    " + aR[:why]  ok
	Then("the recording is written", aR[:ok], 1)
	Then("beside the notebook, named after it", fexists(cAtPlant + "/an-edition.recording.json"), TRUE)
	aRec = StzJsonToList(read(cAtPlant + "/an-edition.recording.json"))
	Then("four cells", len(aRec[:cells]), 4)
	Then("two promises kept and one claim diverged", "" + aRec[:kept] + "/" + aRec[:diverged], "2/1")
	Then("it names the library commit that ran it", StzSplit(aRec[:library], " ")[1], cAtCommit)
	Then("and the Ring++ build and the engine", aRec[:rnxc] != "" and aRec[:engine] != "", TRUE)
	Then("a cell's id: the notebook's name and 8 hex of the sha256 of its title and code", aRec[:cells][2][:id], "notebook/an-edition#" + left(StzLower(StzEngineCryptoSha256("a chain" + _nl_ + '? Q("ab").UppercaseQ().Spacified()' + _nl_ + "#--> A B" + _nl_)), 8))
	Then("it keeps the notebook's digest", aRec[:digest], AtelierNotebookDigest(read(cAtNotebook)))
	Then("and no folder of this machine", AtelierHasDrivePath(read(cAtPlant + "/an-edition.recording.json")), 0)
EndScenario()

Scenario("The edition is one static page: the recording and the dictionary inside, nothing fetched")
	aB = AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)
	if NOT aB[:ok]  ? "    " + _AtJoin(aB[:why])  ok
	Then("it is built", aB[:ok], 1)
	cPage = _AtelierNormalize(cAtOut) + "/" + cAtCommit + "/notebook/an-edition/index.html"
	Then("at <out>/<commit>/notebook/<name>/index.html", fexists(cPage), TRUE)
	cHtml = read(cPage)
	Then("it is an edition of a notebook", StzFindFirst('const EDITION = {"kind":"notebook"', cHtml) > 0, TRUE)
	Then("the live page's empty edition is gone", StzFindFirst("const EDITION = null;", cHtml), 0)
	Then("every cell's id is on it", StzFindFirst(aRec[:cells][4][:id], cHtml) > 0, TRUE)
	Then("the dictionary rides inside: no fetch is needed", StzFindFirst('"nbed_intro"', cHtml) > 0, TRUE)
	Then("no recorded text can close the page's script", StzFindFirst("</svg>", cHtml), 0)
	Then("no folder of this machine", AtelierHasDrivePath(cHtml), 0)
	aIdx = StzJsonToList(read(_AtelierNormalize(cAtOut) + "/notebooks.json"))
	Then("notebooks.json lists the edition", aIdx[1][:page], cAtCommit + "/notebook/an-edition/index.html")
	AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)
	Then("a second build replaces its entry, never adds one", len(StzJsonToList(read(_AtelierNormalize(cAtOut) + "/notebooks.json"))), 1)
EndScenario()

Scenario("The builder refuses what would make a citation lie")
	Then("an out folder inside the Atelier", AtelierBuildNotebook(cAtNotebook, cAtAtelier + "/_editions", cAtAtelier)[:ok], 0)
	cKeep = read(cAtNotebook)
	write(cAtNotebook, cKeep + "# one more line" + _nl_)
	aB = AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)
	Then("a notebook changed since it was recorded", aB[:ok], 0)
	Then("and says so", StzFindFirst("changed since it was recorded", _AtJoin(aB[:why])) > 0, TRUE)
	write(cAtNotebook, cKeep)
	cRecFile = cAtPlant + "/an-edition.recording.json"
	cRec = read(cRecFile)
	write(cRecFile, StzReplace(cRec, '"library": "' + aRec[:library] + '"', '"library": "0123456789 on nowhere"'))
	aB = AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)
	Then("a recording naming a commit this history does not have", StzFindFirst("not in this history", _AtJoin(aB[:why])) > 0, TRUE)
	write(cRecFile, StzReplace(cRec, '"engine": ', '"engine_at": "C:/Users/someone/work", "engine": '))
	aB = AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)
	Then("a recording that names a folder of a machine", StzFindFirst("folder of a machine", _AtJoin(aB[:why])) > 0, TRUE)
	write(cRecFile, cRec)
	Then("and the notebook as recorded builds again", AtelierBuildNotebook(cAtNotebook, cAtOut, cAtAtelier)[:ok], 1)
EndScenario()

Scenario("A cell is cited as <commit>:<id>, and resolved from its recording")
	cCite = cAtCommit + ":" + aRec[:cells][2][:id]
	aC = AtelierCiteNotebook(cCite, cRecFile)
	Then("the citation resolves", aC[:ok], 1)
	Then("to the cell", aC[:record][:title], "a chain")
	Then("with the line it saw and what it recorded", aC[:record][:seen][1][:values][1], "A B")
	Then("and the verdict", aC[:record][:seen][1][:state], "kept")
	aC = AtelierCiteNotebook(cAtCommit + ":" + aRec[:cells][3][:id], cRecFile)
	Then("a cited claim that failed says so", aC[:record][:seen][1][:state], "diverged")
	Then("markdown names what judged it", StzFindFirst("Recorded by the library " + aRec[:library], AtelierCiteRender(AtelierCiteNotebook(cCite, cRecFile)[:record], "markdown")) > 0, TRUE)
	Then("another commit is refused", AtelierCiteNotebook("0123456789:" + aRec[:cells][2][:id], cRecFile)[:ok], 0)
	Then("so is an id no cell has", AtelierCiteNotebook(cAtCommit + ":notebook/an-edition#00000000", cRecFile)[:ok], 0)
EndScenario()

Scenario("The command line says the same, with an exit code a script can read")
	# the tool loads the library relative to where it stands (Ring++ resolves a load against
	# the working folder), so the child starts in the Atelier's folder: the system call's own
	# shell would end a `cd` before the command ran
	cCmd = AtelierRnxc() + " edition.ring cite 0123456789:" + aRec[:cells][2][:id] + " --data " + cRecFile
	chdir(cAtAtelier)
	aX = StzEngineSystemRunXT(cCmd)
	chdir(cAtHere)
	if 0 + aX[2] != 2  ? "    the line: " + cCmd + _nl_ + "    the child said: " + left("" + aX[1] + " | " + aX[3], 400)  ok
	Then("a refused citation exits 2", 0 + aX[2], 2)
	Then("and names why", StzFindFirst("REFUSED", "" + aX[1]) > 0, TRUE)
EndScenario()

Scenario("The Atelier stops when asked")
	Then("it answered", AtelierStop(nAtPort), TRUE)
	Then("and the child ended", oAt.WaitFor(10000) != -2, TRUE)
	remove(cAtSettings)
	StzEduRemoveTree(cAtPlant)
EndScenario()

Summary()
shutdown($_zst_fail)

func _AtJoin(pacWhy)
	_c_ = ""
	for _i_ = 1 to len(pacWhy)
		_c_ += pacWhy[_i_] + " | "
	next
	return _c_
