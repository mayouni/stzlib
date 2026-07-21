# stz.wasm -- the web EDGE, built by the engine's build.zig `wasm` target.
#
# "Compile the ENGINE, not the interpreter": the browser gets Softanza's
# DIFFERENTIAL value (numeric solving, number theory, aggregation) as a real
# ~12 KB wasm module -- the SAME Zig logic (numtheory.zig / solver.zig) that
# backs the native DLLs, re-exported for wasm32. NOT a Ring VM, NOT Unicode
# (JS is industrial-strength there); only the engine's edge.
#
# This guard checks the WIRING + the BUILD (Ring cannot execute wasm). The real
# COMPUTE is proven in-browser (wasm_proof.html): 8/8 checks pass --
#   gcd(48,36)=12 . is_prime(97)=1 . solve_linear(2x-8=0)=4 .
#   quad_root1(x^2-5x+6)=3 . mean([10,20,30,40])=25 (via the alloc/marshal ABI).
#
# Ring traps avoided: read the TEXT sources (.zig / build.zig) for the ABI, not
# the binary .wasm (engine str boundary validates utf-8; NUL bytes vanish).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cEng = $cEngineDir
? "engine dir: " + cEng

? ""
? "-- Scene 1: the wasm ENTRY exports the curated differential ABI --"
cEntry = cEng + "/src/stz_wasm_entry.zig"
chk("src/stz_wasm_entry.zig exists", StzEngineFileExists(cEntry) = 1)
cSrc = read(cEntry)
chk("...exports the marshalling ABI (stz_alloc / stz_free / stz_reset)",
	StzFindFirst("stz_alloc", cSrc) > 0 and StzFindFirst("stz_reset", cSrc) > 0)
chk("...exports number theory (stz_gcd / stz_is_prime / stz_nth_prime)",
	StzFindFirst("stz_gcd", cSrc) > 0 and StzFindFirst("stz_is_prime", cSrc) > 0)
chk("...exports the solver (stz_solve_linear / stz_quad_root1)",
	StzFindFirst("stz_solve_linear", cSrc) > 0 and StzFindFirst("stz_quad_root1", cSrc) > 0)
chk("...exports aggregation over a marshalled array (stz_mean / stz_sum)",
	StzFindFirst("stz_mean", cSrc) > 0 and StzFindFirst("stz_sum", cSrc) > 0)
chk("...it re-exports the REAL engine logic (imports numtheory.zig / solver.zig)",
	StzFindFirst("numtheory.zig", cSrc) > 0 and StzFindFirst("solver.zig", cSrc) > 0)

? ""
? "-- Scene 2: build.zig has the `wasm` target (freestanding, JS owns memory) --"
cBuild = read(cEng + "/build.zig")
chk("build.zig declares a `wasm` step", StzFindFirst("b.step(", cBuild) > 0 and StzFindFirst("wasm", cBuild) > 0)
chk("...targets wasm32 freestanding", StzFindFirst("wasm32", cBuild) > 0 and StzFindFirst("freestanding", cBuild) > 0)
chk("...imports the memory (JS owns the linear memory)", StzFindFirst("import_memory", cBuild) > 0)

? ""
? "-- Scene 3: the target BUILDS the edge artifact (zig build wasm) --"
? "(compiling stz.wasm -- a few seconds)"
cWasm = StzBuildEngineWasm()
chk("StzBuildEngineWasm() produced an artifact", cWasm != "")
chk("...at the engine's install path", cWasm = StzEngineWasmPath())
chk("...and stz.wasm exists on disk", StzEngineFileExists(StzEngineWasmPath()) = 1)
nFull = StzEngineFileSize(StzEngineWasmPath())

? ""
? "-- Scene 4: emit ONLY the plan's per-part engine subset --"
aSolver = StzWasmGroupsFor([ :constraintsolver ])
chk("ConstraintSolver -> the solver group", len(aSolver) = 1 and aSolver[1] = "solver")
aPivot = StzWasmGroupsFor([ :pivottable ])
chk("PivotTable -> the aggregation group", len(aPivot) = 1 and aPivot[1] = "aggregation")
chk("a part using both -> both groups, deduped", len(StzWasmGroupsFor([ :pivottable, :constraintsolver, :pivottable ])) = 2)
chk("capabilities with no wasm logic ship nothing", len(StzWasmGroupsFor([ :collection, :unicode, :neural ])) = 0)

oB = new stzBuilderBrain("sub")
oB.WithSuperApp(:phone, :Android)
oB.NeedsIn(:phone, [ :Unicode, :PivotTable, :ConstraintSolver, :Neural ])
oPl = oB.Plan()
aG = StzWasmGroupsFor(oPl.EngineCapsFor(:phone))
chk("the PLAN drives it: phone subset = solver + aggregation (NOT numtheory)",
	len(aG) = 2 and StzFindFirst("solver", aG) > 0 and StzFindFirst("aggregation", aG) > 0 and StzFindFirst("numtheory", aG) = 0)

? "(compiling a solver-only subset -- a few seconds)"
cTmp = WorkingDirectory() + "/_wasmsub_tmp"
StzEngineDirCreatePath(cTmp)
cSub = StzBuildEngineWasmSubset([ "solver" ], cTmp + "/s.wasm")
chk("a solver-only subset builds", cSub != "" and StzEngineFileExists(cSub) = 1)
nSub = StzEngineFileSize(cSub)
chk("...and is SMALLER than the full edge (" + nSub + " < " + nFull + " bytes)", nSub > 0 and nSub < nFull)
StzEngineDirDelete(cTmp)

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
