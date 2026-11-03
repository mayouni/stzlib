# THE IMAGE FACULTIES REACH AN AGENT -- IM9a, narrated
#
# SOFTANZA_IMAGE_INTELLIGENCE.md IM9a, the wiring audit. Measured before anything was built
# (2026-11-03): in a fresh process NO image faculty was declared -- only a guard declared them -- so a
# registry call from an agent was refused with "unknown-faculty"; and once declared, an agent's ask left
# no ledger record of ITS call (the model door writes only when a model runs, and a repeated ask is
# answered from the memo), and no record said WHO asked. Built here: stzBase declares the faculties,
# an agent's cycle names itself as the caller, the registry files an agent's ask as faculty.call, and the
# model door writes the agent as the origin of its model.call.
#
#   Scene 1  every image faculty exists in a fresh process, each with a floor
#   Scene 2  the registry's choice is the implementation that answers; a person asking leaves no faculty.call
#   Scene 3  an agent asks, one ring: skill per faculty: each ask is filed, each model.call names the agent
#   Scene 4  the same ask again is answered from the memo -- and still filed, saying nothing ran
#   Scene 5  the negative siblings: a refused ask is filed; the caller is cleared when the cycle ends
#   Scene 6  what a person looks at: the ledger rows as an HTML page
#
# Runs on the CPU on purpose: it is about wiring, not speed, and it must not touch a GPU that another
# process may hold. NOT covered here (owned, not run here): :doc-vlm and :object-at run only as far as
# being declared and resolved -- image_docvlm_narrated and image_promptable_narrated run them.
# NEEDS the models in models/vision and the photographs beside the sources. THE HELPERS LIVE AFTER pf().

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$nSec = clock()
$cSrc = "D:/GitHub/_wti_models_src/"
$cPic = $cSrc + "photos/street.jpg"
$aAskList = []
$nAsk = 0
$cAgent = "image-auditor"

cOut = StzReplace(WorkingDirectory(), "\", "/") + "/_wiring-out"
if NOT StzDirExists(cOut)
	StzDirCreatePath(cOut)
ok

if NOT fexists($cPic) or NOT StzVisionModelsInstalled()
	? "NOT RUN: the photographs (" + $cPic + ") or the vision models (" + StzVisionModelsDir() + ")"
	shutdown(0)
ok

StzEngineNeuralVisionGpu(0)
StzClearParcelMemo()
aEvery = [ "image-label", "faces", "objects", "foreground", "object-at", "depth", "describe", "doc-vlm" ]
aAsked = [ "image-label", "faces", "objects", "foreground", "depth", "describe" ]

? "-- Scene 1: every image faculty exists in a fresh process --"
nE = len(aEvery)
for i = 1 to nE
	oF = StzFacultyQ(aEvery[i])
	chk(aEvery[i] + " is declared, with a floor", StzHasFaculty(aEvery[i]) = 1 and oF.HasFloor() = 1)
next
chk("no model has been run yet, so no ledger has been opened by this guard", Calls("model.call") = 0)
sec("scene 1")

? "-- Scene 2: the registry's choice is the implementation that answers --"
nB = Calls("faculty.call")
nA = len(aAsked)
nMc0 = Calls("model.call")
for i = 1 to nA
	cChosen = StzModelRegistryQ().ResolveQ(StzRequirementQ(aAsked[i])).Chosen()
	oP = StzRunFaculty(aAsked[i], $cPic, [], [], [], 0)
	aProv = oP.Provenance()
	cGot = ""
	if oP.IsRefusal() = 0
		cGot = aProv[1][:implementation]
	ok
	chk(aAsked[i] + ": answered by the registry's choice '" + cChosen + "'", oP.IsRefusal() = 0 and cGot = cChosen and cChosen != "")
next
chk("a person asking leaves no faculty.call (the models' own doors already record the runs)", Calls("faculty.call") = nB)
nMc1 = Calls("model.call")
chk("...and each run reached the door: model.call grew by at least " + nA, nMc1 - nMc0 >= nA)
aRec = Ledger("model.call")
nNoOrigin = 0
nR = len(aRec)
for i = 1 to nR
	if aRec[i][:origin] = ""
		nNoOrigin++
	ok
next
chk("...with no origin, because no agent was acting (" + nNoOrigin + " of " + nR + " records)", nNoOrigin = nR)
sec("scene 2")

? "-- Scene 3: an agent asks, one ring: skill per faculty --"
StzClearParcelMemo()
StzAllowAgentFunction("WiringAsk", "trusted")
$aAskList = aAsked
$nAsk = 0
oA = NewAgent()
nFc0 = Calls("faculty.call")
nMc0 = Calls("model.call")
for i = 1 to nA
	nOk = oA.Cycle()
	chk("cycle " + i + ": the skill ran and verified", nOk = 1)
next
chk("the agent remembers asking all " + nA, len(oA.MemoryQ().Recall("faculty", "asked")) = nA)
aFc = Ledger("faculty.call")
nFcNew = len(aFc) - nFc0
chk("each ask is filed as faculty.call: " + nFcNew + " new records", nFcNew = nA)
nByAgent = 0
nRan = 0
for i = nFc0 + 1 to len(aFc)
	if aFc[i][:actor] = $cAgent
		nByAgent++
	ok
	if Has("it ran", aFc[i][:reason])
		nRan++
	ok
next
chk("...every one under the agent's own name", nByAgent = nA)
chk("...and every one says the model ran", nRan = nA)
aMc = Ledger("model.call")
nMcNew = len(aMc) - nMc0
nOrig = 0
for i = nMc0 + 1 to len(aMc)
	if aMc[i][:origin] = "agent:" + $cAgent
		nOrig++
	ok
next
chk("the models' doors wrote " + nMcNew + " model.call records, at least one per ask", nMcNew >= nA)
chk("...every one with the agent as origin (" + nOrig + " of " + nMcNew + ")", nOrig = nMcNew)
sec("scene 3")

? "-- Scene 4: the same ask again is answered from the memo, and still filed --"
$aAskList = [ "faces", "objects" ]
$nAsk = 0
oB = NewAgent()
nFc1 = Calls("faculty.call")
nMc1 = Calls("model.call")
oB.Cycle()
oB.Cycle()
aFc = Ledger("faculty.call")
chk("two asks, two faculty.call records", len(aFc) - nFc1 = 2)
nMemo = 0
for i = nFc1 + 1 to len(aFc)
	if Has("from the memo", aFc[i][:reason])
		nMemo++
	ok
next
chk("...both say they came from the memo", nMemo = 2)
chk("...and no model ran: model.call did not grow", Calls("model.call") = nMc1)
sec("scene 4")

? "-- Scene 5: the negative siblings --"
$aAskList = [ "no-such-faculty" ]
$nAsk = 0
oC = NewAgent()
nFc2 = Calls("faculty.call")
oC.Cycle()
aFc = Ledger("faculty.call")
chk("an ask for a faculty that does not exist is filed too", len(aFc) - nFc2 = 1)
chk("...as refused", Has("refused", aFc[len(aFc)][:reason]))
chk("the caller is cleared when the cycle ends", $cStzCaller = "")
nFc3 = Calls("faculty.call")
oP = StzRunFaculty("faces", $cPic, [], [], [], 0)
chk("a person asking afterwards still leaves no faculty.call", Calls("faculty.call") = nFc3)
sec("scene 5")

? "-- Scene 6: what a person looks at --"
WritePage(cOut + "/wiring.html")
chk("the ledger page is written", fexists(cOut + "/wiring.html"))
sec("scene 6")

? ""
? "ASSERTIONS: " + ($nPass + $nFail) + " -- " + $nPass + " passed, " + $nFail + " failed"
pf()
shutdown($nFail)

# one skill, run once per cycle: asks the next faculty of $aAskList through the registry
func WiringAsk(poMemory)
	$nAsk++
	cName = $aAskList[$nAsk]
	oP = StzRunFaculty(cName, $cPic, [], [], [], 0)
	poMemory.Learn("faculty", "asked", cName)
	poMemory.Learn("faculty", "answered", "done")

func NewAgent()
	cDecl = "pia: 2" + char(10) + "name: " + $cAgent + char(10) + "kind: pi" + char(10) +
		"coverage: asks image faculties to answer one picture, through the registry" + char(10) +
		"reversibility: reversible" + char(10) + "schedule:" + char(10) + "  timer: 20" + char(10) + "skills:" + char(10) +
		"  - name: ask" + char(10) + "    when: always" + char(10) + "    does: ring:WiringAsk" + char(10) +
		"    verify: fact faculty answered done" + char(10) + "    posture: trusted" + char(10)
	oD = StzAgentDeclarationQ(cDecl)
	if oD.IsValid() = 0
		? "the declaration was refused: " + @@(oD.Findings())
		shutdown(1)
	ok
	return oD.ToAgent()

func Ledger(cKind)
	if NOT StzSecurityLedgerIsOpen()
		return []
	ok
	return StzSecurityLedgerQ().OfKind(cKind)

func Calls(cKind)
	return len(Ledger(cKind))

func chk(cWhat, bCond)
	if bCond = 1
		$nPass++
		? "  [OK] " + cWhat
	else
		$nFail++
		? "  [FAIL] " + cWhat
	ok

func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - $nSec) / clockspersecond()) + "s"
	? ""
	$nSec = clock()

func Esc(c)
	return StzReplace(StzReplace(StzReplace("" + c, "&", "&amp;"), "<", "&lt;"), ">", "&gt;")

# the faculty and model records of this run as a table: who asked, what answered, what the door wrote
func WritePage(cPath)
	c = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>" +
		"<title>Who asked the image faculties</title><style>" +
		":root{--bg:#fff;--fg:#1c1c1e;--mut:#6b6b70;--line:#d8d8dc;--card:#f6f6f8;--ag:#e8f0ff;--agb:#2f6fdd}" +
		"@media (prefers-color-scheme:dark){:root{--bg:#161618;--fg:#ececf0;--mut:#9a9aa2;--line:#3a3a40;--card:#202024;--ag:#1d2a44;--agb:#6aa0ff}}" +
		"body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.5 system-ui,Segoe UI,sans-serif}" +
		"main{max-width:1100px;margin:0 auto;padding:16px}h1{font-size:1.5rem;margin:.3em 0}" +
		"p.sub{color:var(--mut);margin:0 0 1em}table{border-collapse:collapse;width:100%;font-size:.92rem}" +
		"th,td{border-bottom:1px solid var(--line);padding:6px 8px;text-align:left;vertical-align:top}" +
		"th{color:var(--mut);font-weight:600}tr.ag td{background:var(--ag)}tr.ag td:first-child{border-left:4px solid var(--agb)}" +
		"code{font-size:.9em}.k{white-space:nowrap}</style></head><body><main>" +
		"<h1>Who asked the image faculties</h1><p class='sub'>The ledger of this run. Rows on a blue band were made while an agent was acting: " +
		"its <code>faculty.call</code> says who asked and whether anything ran; its <code>model.call</code> carries the agent as origin. " +
		"Rows with no band are a person asking, which the models' own doors record and the registry does not repeat.</p>" +
		"<table><tr><th>#</th><th>kind</th><th>actor</th><th>origin</th><th>subject</th><th>what</th></tr>"
	aAll = StzSecurityLedgerQ().All()
	aKeep = []
	n = len(aAll)
	for i = 1 to n
		if aAll[i][:kind] = "model.call" or aAll[i][:kind] = "faculty.call"
			aKeep + aAll[i]
		ok
	next
	# consecutive rows of the same kind, actor, origin and subject are one line (one image-label ask writes 42)
	nK = len(aKeep)
	nShown = 0
	i = 1
	while i <= nK
		j = i
		while j < nK and SameRow(aKeep[j + 1], aKeep[i])
			j++
		end
		nShown++
		cCls = ""
		if aKeep[i][:origin] != "" or aKeep[i][:actor] = $cAgent
			cCls = " class='ag'"
		ok
		cWhat = Esc(aKeep[i][:reason])
		if j > i
			cWhat = "<b>x " + (j - i + 1) + "</b>, the first: " + cWhat
		ok
		c += "<tr" + cCls + "><td>" + nShown + "</td><td class='k'><code>" + aKeep[i][:kind] + "</code></td><td>" +
			Esc(aKeep[i][:actor]) + "</td><td>" + Esc(aKeep[i][:origin]) + "</td><td><code>" + Esc(aKeep[i][:subject]) +
			"</code></td><td>" + cWhat + "</td></tr>"
		i = j + 1
	end
	c += "</table></main></body></html>"
	write(cPath, c)

func SameRow(aA, aB)
	return aA[:kind] = aB[:kind] and aA[:actor] = aB[:actor] and aA[:origin] = aB[:origin] and aA[:subject] = aB[:subject]

# StzFind answers a LIST of positions
func Has(cNeedle, cHay)
	return len(StzFind(cNeedle, "" + cHay)) > 0
