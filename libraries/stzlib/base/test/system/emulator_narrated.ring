# stzEmulator -- Deploy(:Emulated), the programming-phase face of Deploy(). The
# brain's placement/scope plan is GENERATED into a web-based mission-control: a
# live solution map, one panel per part, colored by status, showing each part's
# capability placement and its fidelity, with breadcrumb navigation. Deployment is
# a high-friction moment; this makes it calm, legible, one-clear-action.
#
# This guard checks the GENERATION (files + the plan rendered faithfully into the
# HTML). The in-browser render + navigation is verified separately (Ring has no DOM).
#
# Ring traps avoided: no oR/nL/For locals; main before the first func; no inline
# new X().M().

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cDir = WorkingDirectory() + "/_build_scratch"
StzEngineDirCreatePath(cDir)

oBrain = new stzBuilderBrain("restolean")
oBrain.WithBackend(:api, :LinuxServer)
oBrain.WithSuperApp(:phone, :Android)
oBrain.WithApp(:admin, :Browser)
oBrain.WithFirmware(:node, :ESP32)
oBrain.NeedsIn(:phone, [ :Unicode, :DateTime, :PivotTable, :ConstraintSolver, :Collection, :Neural ])
oBrain.NeedsIn(:api, [ :PivotTable, :Neural ])
oBrain.NeedsIn(:admin, [ :PivotTable, :Collection ])
oBrain.NeedsIn(:node, [ :GPIO, :Pattern, :Neural ])

? "-- Scene 1: Deploy(:Emulated) generates the mission-control bundle --"
oEmu = oBrain.Deploy(:Emulated)
oEmu.OutDir(cDir + "/dist")
oEmu.Build()
chk("Deploy(:Emulated) returns a built emulator", oEmu.IsBuilt())
chk("...it emits index.html + manifest.json", StzEngineFileExists(cDir + "/dist/index.html") = 1 and StzEngineFileExists(cDir + "/dist/manifest.json") = 1)

cH = read(cDir + "/dist/index.html")

? ""
? "-- Scene 2: the MAP renders every part of the solution --"
chk("the phone part is on the map", StzFindFirst("data-part='phone'", cH) > 0)
chk("...the backend (api) part too", StzFindFirst("data-part='api'", cH) > 0)
chk("...the browser (admin) part", StzFindFirst("data-part='admin'", cH) > 0)
chk("...and the firmware (node) part", StzFindFirst("data-part='node'", cH) > 0)
chk("parts are tiered by role (Frontends / Backends / Edge devices)", StzFindFirst("Backends", cH) > 0 and StzFindFirst("Frontends", cH) > 0 and StzFindFirst("Edge devices", cH) > 0)
chk("...the grid can be filtered by role", StzFindFirst("class='filters'", cH) > 0 and StzFindFirst("data-f='front'", cH) > 0)

? ""
? "-- Scene 3: each part shows the brain's PLACEMENT, per capability --"
oPlan = oBrain.Plan()
chk("the phone's differential compute is labeled [stz.wasm]", StzFindFirst("[stz.wasm]", cH) > 0)
chk("...Unicode defers to the target [target]", StzFindFirst("[target]", cH) > 0)
chk("...Collection is a [stz.js] construct", StzFindFirst("[stz.js]", cH) > 0)
chk("...Neural is offloaded [server]", StzFindFirst("[server]", cH) > 0)
chk("...the MCU's caps lower to [firmware]", StzFindFirst("[firmware]", cH) > 0)
chk("the rendered label matches the plan (PivotTable on the phone)",
	oPlan.LabelFor(oPlan.VectorFor(:phone, :PivotTable), "mobile") = "[stz.wasm]" and StzFindFirst("[stz.wasm]", cH) > 0)

? ""
? "-- Scene 4: the FIDELITY contract is on screen -- calm, honest colour --"
chk("healthy/faithful parts read 'faithful'", StzFindFirst("faithful", cH) > 0)
chk("...the MCU flags what is only approximated", StzFindFirst("2 approximated", cH) > 0)
chk("...and names it (pump timing / sensor noise)", StzFindFirst("pump timing", cH) > 0)

? ""
? "-- Scene 5: the standard master-detail surface, calm and legible --"
chk("the parts GRID is the master list (left)", StzFindFirst("gridcol", cH) > 0)
chk("...the selected part's auxiliary detail sits beside it (right)", StzFindFirst("auxcol", cH) > 0)
chk("the deploy action is a bar at the TOP", StzFindFirst("deploybar", cH) > 0)
chk("a per-part 'Runs here' placement view", StzFindFirst("Runs here", cH) > 0)
chk("one clear next action, gated on health", StzFindFirst("Deploy to production", cH) > 0)

? ""
? "-- Scene 5b: each part opens a maximized device window, device + console --"
chk("the window is maximized to the browser", StzFindFirst("window wide", cH) > 0)
chk("...with the device on the left", StzFindFirst("dzone", cH) > 0)
chk("...browser parts get a desktop frame, not a phone", StzFindFirst("deskframe", cH) > 0)
chk("...and a live log + query console on the right", StzFindFirst("Live log", cH) > 0 and StzFindFirst("rconsole", cH) > 0)

? ""
? "-- Scene 6: the manifest declares the emulator bundle --"
cM = read(cDir + "/dist/manifest.json")
chk("the manifest is a web emulator listing its parts", StzFindFirst("emulator", cM) > 0 and StzFindFirst("phone", cM) > 0)

? ""
? "-- Scene 7: the bundle is a clean web app -- CSS / JS are separate assets --"
chk("index.html LINKS a stylesheet, not an inline <style> blob", StzFindFirst("emulator.css", cH) > 0 and StzFindFirst("<style>", cH) = 0)
chk("...and an external script, not an inline <script> blob", StzFindFirst("emulator.js", cH) > 0)
chk("emulator.css ships as its own file", StzEngineFileExists(cDir + "/dist/emulator.css") = 1)
chk("emulator.js ships as its own file", StzEngineFileExists(cDir + "/dist/emulator.js") = 1)
cCss = read(cDir + "/dist/emulator.css")
chk("...the CSS holds the real layout (gridcol + deploybar)", StzFindFirst(".gridcol", cCss) > 0 and StzFindFirst(".deploybar", cCss) > 0)
cJs = read(cDir + "/dist/emulator.js")
chk("...the JS holds the window routing (openPop + Escape close)", StzFindFirst("function openPop", cJs) > 0 and StzFindFirst("Escape", cJs) > 0)

StzEngineDirDelete(cDir)

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
