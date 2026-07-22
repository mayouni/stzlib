# stzLog -- logging the Softanza way: STRUCTURED-FIRST and QUERYABLE.
#
# A log is not a wall of text; it is a stream of timestamped, leveled, structured
# entries you write, filter by level, query by field, and render as text OR JSON.
# Logs are inspectable DATA -- "give me every error about part=api", not "grep".
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); the sink class has an empty init(); StzFindFirst not StzFind.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a log is a stream of LEVELED entries; writes chain --"
oLog = new stzLog("deploy")
oLog.Info("build started").Warn("low disk").Error("compile failed")   # chained writes
chk("three entries recorded", oLog.NumberOfEntries() = 3)
chk("...the category is the log's name", oLog.LastEntry()[:category] = "deploy")
chk("...each entry is timestamped (epoch ms)", oLog.LastEntry()[:ts] > 0)

? ""
? "-- Scene 2: a LEVEL THRESHOLD drops anything below it (default info) --"
oLog.Debug("verbose detail")                                          # below info -> dropped
chk("debug is dropped at the default 'info' threshold", oLog.NumberOfEntries() = 3)
oLog.SetLevelQ(:trace)
oLog.Debug("now visible")
chk("...lowering the threshold to trace records it", oLog.CountOfLevel(:debug) = 1)
chk("an unknown level is refused", This_UnknownLevelRaises())

? ""
? "-- Scene 3: STRUCTURED entries -- fields, queried by key/value --"
oLog2 = new stzLog("api")
oLog2.Record(:error, "compile failed", [ [ :part, "backend" ], [ :code, 2 ] ])
oLog2.Record(:error, "compile failed", [ [ :part, "firmware" ], [ :code, 7 ] ])
oLog2.Record(:info, "recovered", [ [ :part, "backend" ] ])
chk("Where(field, value) returns the structured matches", len(oLog2.Where(:part, "backend")) = 2)
chk("...only the ones with that value", len(oLog2.Where(:part, "firmware")) = 1)
chk("the entry keeps its fields", oLog2.Where(:part, "firmware")[1][:fields][2][2] = 7)

? ""
? "-- Scene 4: the log is QUERYABLE data --"
chk("entries can be counted by level", oLog2.CountOfLevel(:error) = 2 and oLog2.CountOfLevel(:info) = 1)
chk("EntriesOfLevel returns just that level", len(oLog2.EntriesOfLevel(:error)) = 2)
chk("Since(0) returns all; Since(a far-future ms) returns none", len(oLog2.Since(0)) = 3 and len(oLog2.Since(9999999999999)) = 0)

? ""
? "-- Scene 5: render as TEXT (humans) or JSON (pipelines) --"
cText = oLog2.AsText()
chk("AsText carries the level, category, message", StzFindFirst("ERROR", cText) > 0 and StzFindFirst("api: compile failed", cText) > 0)
chk("...and the structured fields", StzFindFirst("part=backend", cText) > 0)
cJson = oLog2.AsJson()
chk("AsJson is a structured array -- fields inlined as top-level keys", StzFindFirst(char(34) + "level" + char(34) + ": " + char(34) + "error", cJson) > 0)
chk("...ready to ship (the part field is a JSON key)", StzFindFirst(char(34) + "part" + char(34) + ": " + char(34) + "firmware", cJson) > 0)

? ""
? "-- Scene 6: retention CAP -- oldest entries evicted (FIFO) --"
oCap = new stzLog("ring")
oCap.SetLevelQ(:trace)
oCap.SetCapQ(2)
oCap.Info("a")
oCap.Info("b")
oCap.Info("c")
chk("a cap of 2 keeps only the last 2", oCap.NumberOfEntries() = 2)
chk("...evicting the oldest -- 'a' is gone, 'c' is newest", oCap.LastEntry()[:message] = "c" and len(oCap.Where(:none, "x")) = 0)

? ""
? "-- Scene 7: output -- render the whole log to a file (text or JSON) --"
cDir = WorkingDirectory() + "/_log_scratch"
StzEngineDirCreatePath(cDir)
oLog2.WriteToFile(cDir + "/app.log")
chk("WriteToFile persists the rendered text log", StzFindFirst("api: compile failed", read(cDir + "/app.log")) > 0)
oLog2.WriteJsonToFile(cDir + "/app.json")
chk("...WriteJsonToFile persists the structured JSON (fields as keys)", StzFindFirst(char(34) + "part" + char(34), read(cDir + "/app.json")) > 0)
StzDirDeleteAll(cDir)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func This_UnknownLevelRaises()
	bR = FALSE
	oT = new stzLog("t")
	try
		oT.SetLevelQ("shout")
	catch
		bR = TRUE
	done
	return bR
