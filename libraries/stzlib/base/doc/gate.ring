load "../stzBase.ring"

# The doc gate over the whole library (DOCREFORM step 5; meta/stzDocGate.ring).
#
#   cd libraries/stzlib/base/doc
#   ring gate.ring              judge: prints the findings, then OK or FAILED (a Ring script cannot set an exit
#                               code: the CI step reads the last line, FAILED when there is a doc-floor ERROR)
#   ring gate.ring --update     shrink the baseline: drop the roots that now pass (never adds a key)
#   ring gate.ring --seed       (re)write the baseline from every failing root -- the first time only
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

if cMode = "seed"
	aR = StzDocGateBaselineUpdate(cBase, cFile, 1)
	? "baseline seeded: " + aR[:written] + " failing roots"
	bye
ok
if cMode = "update"
	aR = StzDocGateBaselineUpdate(cBase, cFile, 0)
	? "baseline: " + aR[:removed] + " roots dropped, " + aR[:kept] + " kept"
	bye
ok

aF = StzDocGateFindings(cBase, cFile)
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
