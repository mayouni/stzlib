# stzBuilderBrain + the placement/scope plan REHEARSAL -- the reasoning behind
# stzBuilder. Before a byte is built, the brain decides, per capability and per
# target, the delivery vector -- and says WHY. The load-bearing idea is the
# DIFFERENTIAL test: the edge ships only what is critical AND (Softanza-unique OR
# weak on the target). So a browser/phone uses its OWN industrial Unicode, and the
# on-device engine (stz.wasm on the web, FIRMWARE on an MCU) carries only Softanza's
# differential compute -- no blind whole-engine dump. Scope-Oriented Programming,
# 3rd instance: the target platform is the invisible frame.
#
# Ring traps avoided: no oR/nL/For locals; main before the first func; membership
# via StzFindFirst (not a hand-rolled utility).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = WorkingDirectory() + "/_build_scratch"

? "-- Scene 1: the DIFFERENTIAL test -- the edge uses the platform where it is strong --"
oBrain = new stzBuilderBrain("app")
oBrain.WithSuperApp(:phone, :Android)
oBrain.NeedsIn(:phone, [ :unicode, :datetime, :json, :table_pivot, :constraint_solver, :collection_dsl, :neural, :regex ])
oPlan = oBrain.Plan()
chk("unicode on the phone -> PLATFORM-native (JS is industrial-strength)", oPlan.VectorFor(:phone, :unicode) = "native")
chk("...datetime too -> platform-native", oPlan.VectorFor(:phone, :datetime) = "native")

? ""
? "-- Scene 2: Softanza-differential compute -> the on-device engine (stz.wasm) --"
chk("table_pivot -> engine (JS weak, Softanza excels)", oPlan.VectorFor(:phone, :table_pivot) = "engine")
chk("constraint_solver -> engine (Softanza-unique, JS absent)", oPlan.VectorFor(:phone, :constraint_solver) = "engine")
chk("regex -> engine (Softanza's scoped/PCRE2 regex beats JS)", oPlan.VectorFor(:phone, :regex) = "engine")

? ""
? "-- Scene 3: ergonomics -> a target-language construct; the heavy -> the backend --"
chk("collection_dsl -> construct (best in the target language: stz.js)", oPlan.VectorFor(:phone, :collection_dsl) = "construct")
chk("neural -> server (too heavy for the edge)", oPlan.VectorFor(:phone, :neural) = "server")

? ""
? "-- Scene 4: the SCOPE -- the on-device engine carries ONLY the differential subset --"
eng = oPlan.EngineCapsFor(:phone)
chk("the engine subset is scoped (fewer than the 8 needs)", len(eng) < 8)
chk("...it carries the differential compute", StzFindFirst("table_pivot", eng) > 0 and StzFindFirst("constraint_solver", eng) > 0)
chk("...it does NOT carry unicode (the platform does that)", StzFindFirst("unicode", eng) = 0)
chk("...its footprint is small (KB, not the whole engine)", oPlan.EngineKbFor(:phone) < 100)

? ""
? "-- Scene 5: a SERVER part hosts the full native engine -- no edge scoping --"
oBrain.WithBackend(:api, :LinuxServer)
oBrain.NeedsIn(:api, [ :unicode, :table_pivot, :neural ])
oP2 = oBrain.Plan()
chk("on the server, table_pivot runs in the native engine", oP2.VectorFor(:api, :table_pivot) = "engine")
chk("...even neural runs server-side natively (not offloaded further)", oP2.VectorFor(:api, :neural) = "engine")
chk("...unicode on the server also uses the engine (Softanza runs natively there)", oP2.VectorFor(:api, :unicode) = "engine")

? ""
? "-- Scene 6: one offline mobile app is a WHOLE solution (the small end) --"
oOne = new stzBuilderBrain("notes")
oOne.WithApp(:notes, :Android)
oOne.NeedsIn(:notes, [ :unicode, :pattern, :collection_dsl ])
oP3 = oOne.Plan()
chk("a single offline app is a valid solution", oP3.NumberOfParts() = 1)
chk("...unicode still native, pattern still on-device engine", oP3.VectorFor(:notes, :unicode) = "native" and oP3.VectorFor(:notes, :pattern) = "engine")

? ""
? "-- Scene 7: the FIRMWARE case -- the design is inclusive, not web-tied --"
oFw = new stzBuilderBrain("greenhouse")
oFw.WithFirmware(:node, :ESP32)
oFw.NeedsIn(:node, [ :gpio, :pattern, :exact_numerics, :neural, :json ])
oP4 = oFw.Plan()
chk("gpio on the MCU -> engine (lowered into firmware)", oP4.VectorFor(:node, :gpio) = "engine")
chk("...pattern too -> engine (firmware; MCU has no such native support)", oP4.VectorFor(:node, :pattern) = "engine")
chk("...neural -> server (too heavy even for an MCU)", oP4.VectorFor(:node, :neural) = "server")
chk("...json FOLDS into firmware on the MCU (no JS construct layer there; native JSON weak)", oP4.VectorFor(:node, :json) = "engine")
chk("...whereas the same json on a browser -> platform (inclusive: same cap, different target)", oPlan.VectorFor(:phone, :json) = "native")
cFw = oP4.Narration()
chk("the plan names the on-device artifact FIRMWARE for the MCU (not stz.wasm)", StzFindFirst("[firmware]", cFw) > 0 and StzFindFirst("firmware carries", cFw) > 0)
chk("...and does NOT call it stz.wasm on the MCU", StzFindFirst("stz.wasm", cFw) = 0)

? ""
? "-- Scene 8: infer a part's needs from its source (the lexical starting point) --"
StzEngineDirCreatePath(cDir)
write(cDir + "/app.ring", "o1 = new stzTable(aData)" + nl + "o1.Pivot(:Region, :Sales)" + nl + "oS = new stzSolver()" + nl + "oS.Solve()" + nl + "oB.ReadPin(4)" + nl)
oInf = new stzBuilderBrain("inf")
oInf.WithApp(:a, :Browser)
oInf.InferNeedsIn(:a, cDir + "/app.ring")
aParts = oInf.Parts()
aCaps = aParts[1][4]
chk("inference picked table_pivot from .Pivot", StzFindFirst("table_pivot", aCaps) > 0)
chk("...constraint_solver from .Solve", StzFindFirst("constraint_solver", aCaps) > 0)
chk("...gpio from .ReadPin", StzFindFirst("gpio", aCaps) > 0)
StzEngineDirDelete(cDir)

? ""
? "-- Scene 9: the plan is a legible rehearsal, not a black box --"
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
