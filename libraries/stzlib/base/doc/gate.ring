load "../stzBase.ring"

# The doc gate over the whole library (DOCREFORM step 5; meta/stzDocGate.ring).
#
#   cd libraries/stzlib/base/doc
#   ring gate.ring              judge: prints the findings, then OK or FAILED (a Ring script cannot set an exit
#                               code: the CI step reads the last line, FAILED when there is a doc-floor ERROR)
#   ring gate.ring --update     shrink the baselines: drop the roots that now pass and the dead forwards now fixed (never adds a key)
#   ring gate.ring --seed       (re)write the baselines from every failing root and every dead forward -- the first time only
#
# Two baselines: doc_baseline.txt (roots without a passing block) and deadforward_baseline.txt (public names that
# forward to a method no class of their chain defines). A NEW dead forward is an ERROR; a pvt name shown as public and a
# typo-shaped word are warnings. --seed and --update also write findings.json, every finding of the extractor, sorted.
#
# One export of the library: about a minute, one process. Run it once before a commit that adds or
# renames methods, never after every edit.

aArgs = sysargv
cMode = "judge"
if len(aArgs) >= 3
	if aArgs[3] = "--update" cMode = "update" ok
	if aArgs[3] = "--seed" cMode = "seed" ok
ok
cBase = ".."
cFile = "doc_baseline.txt"

cFwd = "deadforward_baseline.txt"
if cMode = "seed"
	aR = StzDocGateBaselineUpdate(cBase, cFile, 1)
	? "baseline seeded: " + aR[:written] + " failing roots"
	aX = StzDocFindings(cBase)
	aR = StzDocGateForwardBaselineWrite(aX, cFwd, 1)
	? "forward baseline seeded: " + aR[:written] + " dead forwards"
	? "findings.json: " + StzDocFindingsWriteJson(aX, "findings.json") + " findings"
	bye
ok
if cMode = "update"
	aR = StzDocGateBaselineUpdate(cBase, cFile, 0)
	? "baseline: " + aR[:removed] + " roots dropped, " + aR[:kept] + " kept"
	aX = StzDocFindings(cBase)
	aR = StzDocGateForwardBaselineWrite(aX, cFwd, 0)
	? "forward baseline: " + aR[:removed] + " dead forwards dropped, " + aR[:kept] + " kept"
	? "findings.json: " + StzDocFindingsWriteJson(aX, "findings.json") + " findings"
	bye
ok

aF = StzDocGateFindings(cBase, cFile)
aX = StzDocFindings(cBase)
aG = StzDocGateForwardJudge(aX, StzDocGateBaseline(cFwd))
nG = len(aG)
for i = 1 to nG
	aF + aG[i]
next
nErr = 0
nWarn = 0
nStale = 0
for i = 1 to len(aF)
	if aF[i][:severity] = :error
		nErr++
		? "ERROR   " + aF[i][:rule] + "  " + aF[i][:where] + "  " + aF[i][:message]
	but aF[i][:rule] = "doc-baseline-stale"
		nStale++
	else
		nWarn++
		? "warning " + aF[i][:rule] + "  " + aF[i][:where] + "  " + aF[i][:message]
	ok
next
? "doc gate: " + nErr + " errors, " + nWarn + " warnings, " + nStale + " baseline roots now pass (run --update)"
if nErr > 0
	? "FAILED"
	bye
ok
? "OK"
