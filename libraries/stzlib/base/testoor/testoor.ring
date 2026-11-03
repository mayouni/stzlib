# Testoor -- the runner at the shell. ONE process per batch, many tours.
#
# Run it FROM THIS FOLDER (Ring resolves `load` against the current directory):
#
#   rnxc testoor.ring --topic uuid                 one topic under ../test
#   rnxc testoor.ring --topic uuid --json          the logbook as JSON, for a pipe
#   rnxc testoor.ring --file ../test/uuid/00_uuid_narrated.ring
#   rnxc testoor.ring --all                        every topic (hours; the gate)
#   rnxc testoor.ring --impacted-by SUBJECT.ring#Method --topic T [--run] [--json]
#                                                  GRAPH-FIRST SELECTION: the tours of T that name anything a change to
#                                                  Method reaches (the closure of its callers in the subject's code
#                                                  graph); with --run, walk only those. A subject the graph cannot see
#                                                  all of (eval, call by a name built at run time) selects every tour.
#   rnxc testoor.ring --topic T --subject PATH     hand every tour PATH as --testoor-subject (a refined copy of the program)
#   rnxc testoor.ring --topic uuid --seed 42       walk every tour with seed 42 (a tour saying Seed(:run) adopts it);
#                                                  a failing tour prints its seed, and the same seed walks the same path
#   rnxc testoor.ring --topic uuid --repeat 2      walk each tour twice with ONE seed; verdicts that differ are FLAKY, exit 1
#   rnxc testoor.ring --routes PLAN.md --topic graphics [--class FILE.ring] [--json]
#                                                  ROUTE COVERAGE, read and not run: the plan's items
#                                                  against the tours' discharges()/Route(); with --class,
#                                                  the class's public methods no tour names. Exit 0, or 1
#                                                  when a closed route has no tour or a tour names an unknown
#                                                  one, or 2 when refused.
#   rnxc testoor.ring --topic uuid --root D:\elsewhere\test --timeout 60000 --by "the author"
#
# rnxc is Ring++'s compiler and VM (Ring is retired, RING-RETIRED-01). Each
# tour runs as a child rnxc: the one RNXC names, else the one running this
# runner, else `rnxc` on the path (TestoorProgram() in stzTraveller.ring).
# Measured 2026-11-03: a child rnxc on a tour loading stzBase starts in
# 0.44 to 0.60 s with its compiled image cached, against 4 to 5 s on Ring.
#
# Exit code (the runner's, never Ring's): 0 every stop kept or unperceived;
# 1 a stop diverged or a tour did not start, broke or hung; 2 the runner
# refused (no such root or topic, no scope given). Full law and the five
# stop states: stzTraveller.ring. The stz desk's `stz guard` calls this as
# its child.

load "../stzBase.ring"

cTrRoot = currentdir() + "/../test"
cTrTopic = ""
cTrFile = ""
bTrAll = 0
bTrJson = 0
nTrTimeout = 120000
cTrBy = "shell"
bTrUsage = 0
cTrImpact = ""
cTrSubject = ""
bTrRun = 0
nTrSeed = -1
nTrRepeat = 1
cTrPlan = ""
cTrClass = ""

nTrArgs = len(sysargv)
nTrI = 3
while nTrI <= nTrArgs
	cTrA = sysargv[nTrI]
	if cTrA = "--topic" and nTrI < nTrArgs
		cTrTopic = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--root" and nTrI < nTrArgs
		cTrRoot = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--file" and nTrI < nTrArgs
		cTrFile = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--timeout" and nTrI < nTrArgs
		nTrTimeout = 0 + sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--by" and nTrI < nTrArgs
		cTrBy = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--routes" and nTrI < nTrArgs
		cTrPlan = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--class" and nTrI < nTrArgs
		cTrClass = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--seed" and nTrI < nTrArgs
		nTrSeed = 0 + sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--repeat" and nTrI < nTrArgs
		nTrRepeat = 0 + sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--impacted-by" and nTrI < nTrArgs
		cTrImpact = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--subject" and nTrI < nTrArgs
		cTrSubject = sysargv[nTrI + 1]
		nTrI++
	but cTrA = "--run"
		bTrRun = 1
	but cTrA = "--all"
		bTrAll = 1
	but cTrA = "--json"
		bTrJson = 1
	else
		bTrUsage = 1
	ok
	nTrI++
end

# ROUTE COVERAGE: read, not run. Owned and walked are two counts and there is
# no percentage (ruling 8).
if cTrPlan != ""
	cTrDir = cTrRoot
	if cTrTopic != ""  cTrDir = cTrRoot + "/" + cTrTopic  ok
	cTrWhy = ""
	if cTrTopic = "" and NOT bTrAll  cTrWhy = "no scope: give --topic NAME or --all with --routes"  ok
	if cTrWhy = "" and NOT fexists(cTrPlan)  cTrWhy = "no such plan: " + cTrPlan  ok
	if cTrWhy = ""
		try
			aTrProbe = dir(cTrDir)
		catch
			cTrWhy = "no such topic under " + cTrRoot + ": " + cTrTopic
		done
	ok
	if cTrWhy != ""
		if bTrJson
			? '{"testoor":"logbook","kind":"routes","refusal":' + _TourJsonStr(cTrWhy) + ',"exit":2}'
		else
			? "REFUSED: " + cTrWhy
			? "exit 2"
		ok
		shutdown(2)
	ok
	oTrMap = StzRouteMapQ().AddPlanFile(cTrPlan).AddToursUnder(cTrDir)
	if cTrClass != ""
		oTrMap.MapMethods(cTrClass, _TrFilesOf(cTrDir))
	ok
	if bTrJson
		? oTrMap.Json()
	else
		? oTrMap.Prose()
	ok
	shutdown(oTrMap.NeedsAttention())
ok

oTr = TravellerQ().By(cTrBy).Timeout(nTrTimeout)
if nTrSeed >= 0  oTr.Seed(nTrSeed)  ok
oTr.Repeat(nTrRepeat)
if bTrJson  oTr.Silent()  ok
if cTrSubject != ""  oTr.Subject(cTrSubject)  ok

# IMPACT: which tours a change reaches, from the subject's code graph
if cTrImpact != ""
	nTrHash = 0
	for nTrK = len(cTrImpact) to 1 step -1
		if cTrImpact[nTrK] = "#"  nTrHash = nTrK  exit  ok
	next
	cTrWhy = ""
	if nTrHash < 2 or nTrHash = len(cTrImpact)  cTrWhy = "give --impacted-by SUBJECT.ring#Method"  ok
	if cTrWhy = "" and cTrTopic = "" and NOT bTrAll  cTrWhy = "no scope: give --topic NAME or --all with --impacted-by"  ok
	if cTrWhy = "" and NOT fexists(substr(cTrImpact, 1, nTrHash - 1))  cTrWhy = "no such subject file: " + substr(cTrImpact, 1, nTrHash - 1)  ok
	if cTrWhy != ""
		if bTrJson
			? '{"testoor":"logbook","kind":"impact","refusal":' + _TourJsonStr(cTrWhy) + ',"exit":2}'
		else
			? "REFUSED: " + cTrWhy
			? "exit 2"
		ok
		shutdown(2)
	ok
	cTrImpDir = cTrRoot
	if cTrTopic != ""  cTrImpDir = cTrRoot + "/" + cTrTopic  ok
	cTrImpMethod = substr(cTrImpact, nTrHash + 1, len(cTrImpact) - nTrHash)
	aTrImp = StzImpactedTours(substr(cTrImpact, 1, nTrHash - 1), cTrImpMethod, _TrFilesOf(cTrImpDir))
	if bTrRun
		nTrSel = len(aTrImp[:selected])
		for nTrK = 1 to nTrSel
			oTr.Walk(aTrImp[:selected][nTrK])
		next
		if bTrJson
			? oTr.Json()
		else
			? StzImpactProse(aTrImp, cTrImpMethod)
			? oTr.Summary()
		ok
		shutdown(oTr.ExitCode())
	ok
	if bTrJson
		? StzImpactJson(aTrImp, cTrImpMethod)
	else
		? StzImpactProse(aTrImp, cTrImpMethod)
	ok
	shutdown(0)
ok

if bTrUsage or (cTrTopic = "" and cTrFile = "" and NOT bTrAll)
	# a refusal, in the logbook's own words, and exit 2
	if bTrJson
		? '{"testoor":"logbook","kind":"run","refusal":"no scope: give --topic NAME, --file PATH or --all","exit":2,"owned":0,"run":0,"tours":[]}'
	else
		? "REFUSED: no scope. Give --topic NAME, --file PATH or --all (see the header of testoor.ring)."
		? "exit 2"
	ok
	shutdown(2)
ok

if cTrFile != ""
	oTr.Walk(cTrFile)
but bTrAll
	oTr.WalkTopic(cTrRoot, "")
else
	oTr.WalkTopic(cTrRoot, cTrTopic)
ok

if bTrJson
	? oTr.Json()
else
	? ""
	? oTr.Summary()
ok
shutdown(oTr.ExitCode())

func _TrFilesOf(cDir)
	aTwo = _TourFilesUnder(cDir, "")
	return aTwo[1]
