# _measure_flows.ring -- measure each faculty's floor and the chosen model implementations on its golden set.
#
#     ring _measure_flows.ring <faculties|all> <models|none|all>
#
#   faculties: comma-separated (retrieve,rerank,triage_extract,brief,kind) or all
#   models:    comma-separated implementation ids (smollm2-135m,qwen3-0.6b,granite-350m,qwen25c-0.5b,qwen25c-1.5b,
#              minilm-cosine,jina-turbo), none (floors only) or all
# The floor is ALWAYS measured first: its score is the bar a model must strictly beat.
# Results are appended to results/measurements.zmdl.txt (one row per faculty/implementation/golden version) and
# printed with the seconds each took. Record the CPU's state beside the numbers: python bench/heartbeat.py.

load "../../stzBase.ring"
load "_ticket_app.ring"

cFacs = sysargv[3]
cModels = sysargv[4]
cStore = "results/measurements.zmdl.txt"
if NOT direxists("results") system("mkdir results") ok
nLoaded = StzLoadMeasurements(cStore)
StzTicketAppDeclare()

aFacs = StzFacultyNames()
if cFacs != "all" aFacs = split(cFacs, ",") ok
aModels = []
if cModels = "none" aModels = [ "__none__" ] ok
if cModels != "none" and cModels != "all" aModels = split(cModels, ",") ok

? "MEASURE faculties=" + cFacs + " models=" + cModels + "  (loaded " + nLoaded + " earlier rows)"
for i = 1 to len(aFacs)
	cF = lower(aFacs[i])
	if NOT StzHasFaculty(cF) ? "unknown faculty " + cF loop ok
	t0 = clock()
	aRows = StzRunGoldensFor(cF, aModels, [])
	nSec = (clock() - t0) / clockspersecond()
	for j = 1 to len(aRows)
		? "  " + cF + " / " + aRows[j][:impl] + "  score=" + aRows[j][:score] + "  n=" + aRows[j][:n] + "  conformance=" + aRows[j][:conformance]
	next
	? "  (" + cF + " took " + nSec + " s)"
	StzSaveMeasurements(cStore)
next
aSw = StzModelSwapCosts()
for i = 1 to len(aSw)
	? "  load-swap " + aSw[i][:needle] + ": " + aSw[i][:seconds] + " s"
next
