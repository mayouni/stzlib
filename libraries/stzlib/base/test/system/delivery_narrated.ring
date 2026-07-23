# stzDelivery + the placement/scope plan REHEARSAL -- the reasoning behind
# stzBuilder. Before a byte is built, the delivery planner decides, per capability
# and per target, the delivery vector -- and says WHY. The load-bearing idea is the
# DIFFERENTIAL test: the edge ships only what is critical AND (Softanza-unique OR
# weak on the target). So a browser/phone uses its OWN industrial Unicode, and the
# on-device engine (stz.wasm on the web, FIRMWARE on an MCU) carries only Softanza's
# differential compute -- no blind whole-engine dump. Scope-Oriented Programming,
# 3rd instance: the target-platform is the invisible frame.
#
# Capabilities use the Softanza named style (:PivotTable, :ConstraintSolver, ...).
# Ring traps avoided: no oR/nL/For locals; main before the first func; membership
# via StzFindFirst (not a hand-rolled utility).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = WorkingDirectory() + "/_build_scratch"

? "-- Scene 1: the DIFFERENTIAL test -- the edge uses the target where it is strong --"
oBrain = new stzDelivery("app")
oBrain.AddSuperApp(:phone, :Android)
oBrain.NeedsIn(:phone, [ :Unicode, :DateTime, :Json, :PivotTable, :ConstraintSolver, :Collection, :Neural, :Regex, :BigNumber ])
oPlan = oBrain.Plan()
chk("Unicode on the phone -> target-native (JS is industrial-strength)", oPlan.VectorFor(:phone, :Unicode) = "native")
chk("...DateTime too -> target-native", oPlan.VectorFor(:phone, :DateTime) = "native")

? ""
? "-- Scene 2: Softanza-differential compute -> the on-device engine (stz.wasm) --"
chk("PivotTable -> engine (JS weak, Softanza excels)", oPlan.VectorFor(:phone, :PivotTable) = "engine")
chk("ConstraintSolver -> engine (Softanza-unique, JS absent)", oPlan.VectorFor(:phone, :ConstraintSolver) = "engine")

? ""
? "-- Scene 3: ergonomics -> a target-language construct; the heavy -> the backend --"
chk("Collection -> construct (best in the target language: stz.js)", oPlan.VectorFor(:phone, :Collection) = "construct")
chk("Regex -> construct, NOT wasm (JS RegExp is strong; ship Softanza's regex API as stz.js over it, never PCRE2 to the browser)", oPlan.VectorFor(:phone, :Regex) = "construct")
chk("...so Regex is NOT in the on-device engine subset (the target does the matching)", StzFindFirst("regex", oPlan.EngineCapsFor(:phone)) = 0)
chk("BigNumber -> native, NOT wasm (JS BigInt is a strong native bignum; Softanza has NO arbitrary-precision engine to ship -- like Regex, it defers)", oPlan.VectorFor(:phone, :BigNumber) = "native")
chk("...so BigNumber is NOT in the on-device engine subset either", StzFindFirst("bignumber", oPlan.EngineCapsFor(:phone)) = 0)
chk("Neural -> server (too heavy for the edge)", oPlan.VectorFor(:phone, :Neural) = "server")

? ""
? "-- Scene 4: the SCOPE -- the on-device engine carries ONLY the differential subset --"
eng = oPlan.EngineCapsFor(:phone)
chk("the engine subset is scoped (far fewer than the 9 needs)", len(eng) < 9)
chk("...it carries the differential compute", StzFindFirst("pivottable", eng) > 0 and StzFindFirst("constraintsolver", eng) > 0)
chk("...it does NOT carry unicode (the target does that)", StzFindFirst("unicode", eng) = 0)
chk("...its footprint is small (KB, not the whole engine)", oPlan.EngineKbFor(:phone) < 100)

? ""
? "-- Scene 5: a SERVER part hosts the full native engine -- no edge scoping --"
oBrain.AddBackend(:api, :LinuxServer)
oBrain.NeedsIn(:api, [ :Unicode, :PivotTable, :Neural ])
oP2 = oBrain.Plan()
chk("on the server, PivotTable runs in the native engine", oP2.VectorFor(:api, :PivotTable) = "engine")
chk("...even Neural runs server-side natively (not offloaded further)", oP2.VectorFor(:api, :Neural) = "engine")
chk("...Unicode on the server also uses the engine (Softanza runs natively there)", oP2.VectorFor(:api, :Unicode) = "engine")

? ""
? "-- Scene 6: one offline mobile app is a WHOLE solution (the small end) --"
oOne = new stzDelivery("notes")
oOne.AddApp(:notes, :Android)
oOne.NeedsIn(:notes, [ :Unicode, :Pattern, :Collection ])
oP3 = oOne.Plan()
chk("a single offline app is a valid solution", oP3.NumberOfParts() = 1)
chk("...Unicode still native, Pattern still on-device engine", oP3.VectorFor(:notes, :Unicode) = "native" and oP3.VectorFor(:notes, :Pattern) = "engine")

? ""
? "-- Scene 7: the FIRMWARE case -- the design is inclusive, not web-tied --"
oFw = new stzDelivery("greenhouse")
oFw.AddFirmware(:node, :ESP32)
oFw.NeedsIn(:node, [ :GPIO, :Pattern, :BigNumber, :Neural, :Json ])
oP4 = oFw.Plan()
chk("GPIO on the MCU -> engine (lowered into firmware)", oP4.VectorFor(:node, :GPIO) = "engine")
chk("...Pattern too -> engine (firmware; MCU has no such native support)", oP4.VectorFor(:node, :Pattern) = "engine")
chk("...Neural -> server (too heavy even for an MCU)", oP4.VectorFor(:node, :Neural) = "server")
chk("...Json FOLDS into firmware on the MCU (no JS construct layer; native JSON weak)", oP4.VectorFor(:node, :Json) = "engine")
chk("...whereas the same Json on a browser -> target (inclusive: same cap, different target)", oPlan.VectorFor(:phone, :Json) = "native")
cFw = linesToText(oP4.Explain())
chk("the plan names the on-device artifact FIRMWARE for the MCU (not stz.wasm)", StzFindFirst("[firmware]", cFw) > 0 and StzFindFirst("firmware carries", cFw) > 0)
chk("...and does NOT call it stz.wasm on the MCU", StzFindFirst("stz.wasm", cFw) = 0)

? ""
? "-- Scene 8: infer a part's needs from its source (the lexical starting point) --"
StzEngineDirCreatePath(cDir)
write(cDir + "/app.ring", "o1 = new stzTable(aData)" + nl + "o1.Pivot(:Region, :Sales)" + nl + "oS = new stzSolver()" + nl + "oS.Solve()" + nl + "oB.ReadPin(4)" + nl)
oInf = new stzDelivery("inf")
oInf.AddApp(:a, :Browser)
oInf.InferNeedsIn(:a, cDir + "/app.ring")
aParts = oInf.Parts()
aCaps = aParts[1][4]
chk("inference picked PivotTable from .Pivot", StzFindFirst("pivottable", aCaps) > 0)
chk("...ConstraintSolver from .Solve", StzFindFirst("constraintsolver", aCaps) > 0)
chk("...GPIO from .ReadPin", StzFindFirst("gpio", aCaps) > 0)
StzDirDeleteAll(cDir)

? ""
? "-- Scene 9: the plan is a legible rehearsal, not a black box --"
cNar = linesToText(oPlan.Explain())
chk("the plan explains itself", StzFindFirst("placement & scope plan", cNar) > 0)
chk("...it is honest that nothing is built yet", StzFindFirst("nothing built yet", cNar) > 0)
chk("...it frames Build()/Deploy() as the commit", StzFindFirst("Build()", cNar) > 0 and StzFindFirst("Deploy()", cNar) > 0)
chk("...every capability shows a reason (WHY it landed there)", StzFindFirst("use its own", cNar) > 0)
chk("...and it says 'target', never the confusing 'platform'", StzFindFirst("[target]", cNar) > 0 and StzFindFirst("[platform]", cNar) = 0)

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

# Explain() now returns a list of lines -- join for substring checks.
# (nCount, not nL: 'nL' would alias Ring's case-insensitive builtin 'nl'.)
func linesToText aLines
	cT = ""
	nCount = len(aLines)
	for i = 1 to nCount
		cT += aLines[i] + nl
	next
	return cT
