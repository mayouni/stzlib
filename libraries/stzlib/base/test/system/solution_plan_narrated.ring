# stzSolution + the placement/scope plan REHEARSAL -- the building brain.
#
# Before a byte is built, the brain decides, per capability and per target, the
# delivery vector -- and says WHY. The load-bearing idea is the DIFFERENTIAL test:
# the edge ships only what is critical AND (Softanza-unique OR weak on the target).
# So a browser/phone uses its OWN industrial-strength Unicode, and the scoped edge
# engine carries only Softanza's differential compute -- no blind whole-engine dump.
#
# Ring traps avoided: no oR/nL/For locals; main before the first func.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = WorkingDirectory() + "/_build_scratch"

? "-- Scene 1: the DIFFERENTIAL test -- the edge uses the platform where it is strong --"
oSol = new stzSolution("app")
oSol.WithSuperApp(:phone, :Android)
oSol.NeedsIn(:phone, [ :unicode, :datetime, :json, :table_pivot, :constraint_solver, :collection_dsl, :neural, :regex ])
oPlan = oSol.Plan()
chk("unicode on the phone -> PLATFORM-native (JS is industrial-strength)", oPlan.VectorFor(:phone, :unicode) = "native")
chk("...datetime too -> platform-native", oPlan.VectorFor(:phone, :datetime) = "native")

? ""
? "-- Scene 2: Softanza-differential compute -> the scoped edge engine (stz.wasm) --"
chk("table_pivot -> stz.wasm (JS weak, Softanza excels)", oPlan.VectorFor(:phone, :table_pivot) = "engine")
chk("constraint_solver -> stz.wasm (Softanza-unique, JS absent)", oPlan.VectorFor(:phone, :constraint_solver) = "engine")
chk("regex -> stz.wasm (Softanza's scoped/PCRE2 regex beats JS)", oPlan.VectorFor(:phone, :regex) = "engine")

? ""
? "-- Scene 3: ergonomics -> stz.js; the heavy -> the backend --"
chk("collection_dsl -> stz.js (ergonomic, best in the target language)", oPlan.VectorFor(:phone, :collection_dsl) = "stzjs")
chk("neural -> server (too heavy for the edge)", oPlan.VectorFor(:phone, :neural) = "server")

? ""
? "-- Scene 4: the SCOPE -- the edge engine carries ONLY the differential subset --"
eng = oPlan.EngineCapsFor(:phone)
chk("the edge engine subset is scoped (fewer than the 8 needs)", len(eng) < 8)
chk("...it carries the differential compute", has(eng, "table_pivot") and has(eng, "constraint_solver"))
chk("...it does NOT carry unicode (the platform does that)", not has(eng, "unicode"))
chk("...its footprint is small (KB, not the whole engine)", oPlan.EngineKbFor(:phone) < 100)

? ""
? "-- Scene 5: a SERVER part hosts the full native engine -- no edge scoping --"
oSol.WithBackend(:api, :LinuxServer)
oSol.NeedsIn(:api, [ :unicode, :table_pivot, :neural ])
oP2 = oSol.Plan()
chk("on the server, table_pivot runs in the native engine", oP2.VectorFor(:api, :table_pivot) = "engine")
chk("...even neural runs server-side natively (not offloaded further)", oP2.VectorFor(:api, :neural) = "engine")
chk("...unicode on the server also uses the engine (Softanza runs natively there)", oP2.VectorFor(:api, :unicode) = "engine")

? ""
? "-- Scene 6: one offline mobile app is a WHOLE solution (the small end) --"
oOne = new stzSolution("notes")
oOne.WithApp(:notes, :Android)
oOne.NeedsIn(:notes, [ :unicode, :pattern, :collection_dsl ])
oP3 = oOne.Plan()
chk("a single offline app is a valid solution", oP3.NumberOfParts() = 1)
chk("...unicode still native, pattern still stz.wasm", oP3.VectorFor(:notes, :unicode) = "native" and oP3.VectorFor(:notes, :pattern) = "engine")

? ""
? "-- Scene 7: infer a part's needs from its source (the lexical starting point) --"
StzEngineDirCreatePath(cDir)
write(cDir + "/app.ring", "o1 = new stzTable(aData)" + nl + "o1.Pivot(:Region, :Sales)" + nl + "oS = new stzSolver()" + nl + "oS.Solve()" + nl + "? Q(cText).Uppercase()" + nl)
oInf = new stzSolution("inf")
oInf.WithApp(:a, :Browser)
oInf.InferNeedsIn(:a, cDir + "/app.ring")
aParts = oInf.Parts()
aCaps = aParts[1][4]
chk("inference picked table_pivot from .Pivot", has(aCaps, "table_pivot"))
chk("...constraint_solver from .Solve", has(aCaps, "constraint_solver"))
chk("...unicode from .Uppercase", has(aCaps, "unicode"))
StzEngineDirDelete(cDir)

? ""
? "-- Scene 8: the plan is a legible rehearsal, not a black box --"
cNar = oPlan.Narration()
chk("the plan narrates itself", StzFindFirst("placement & scope plan", cNar) > 0)
chk("...it is honest that nothing is built yet", StzFindFirst("nothing built yet", cNar) > 0)
chk("...it frames Build()/Deploy() as the commit", StzFindFirst("Build()", cNar) > 0 and StzFindFirst("Deploy()", cNar) > 0)
chk("...every capability shows a reason (WHY it landed there)", StzFindFirst("use the platform's own", cNar) > 0)

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

func has paList, pcX
	nLen = len(paList)
	for i = 1 to nLen
		if paList[i] = pcX
			return TRUE
		ok
	next
	return FALSE
