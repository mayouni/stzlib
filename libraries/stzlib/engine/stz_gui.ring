# Softanza Engine -- Layout and Markup (G1, base/gui/SOFTANZA_GUI_PLAN.md)
#
# Loads stz_gui.dll: RmlUi, laying out a document and handing back the
# TRIANGLES it wants drawn. It paints nothing.
#
# WHY THIS IS A SEPARATE DLL, and not part of stz_gpu -- measured in G0,
# not assumed (see engine/vendor/rmlui/VERSION.txt):
#
#     RmlUi needs C++ EXCEPTIONS  (its in-tree itlib/flat_map throws)
#     RmlUi needs C++ RTTI        (Traits.h calls typeid(T).name())
#
# stz_gpu.dll compiles HarfBuzz with -fno-exceptions -fno-rtti and is
# guarded for cross-compilation. Linking RmlUi into it would impose both
# on the whole GPU plane for the sake of a widget layer. This is the
# stz_window.dll precedent exactly: a dependency whose build requirements
# differ does not get to impose them on its neighbours.
#
# WHAT COMES BACK IS A DISPLAY LIST, not pixels. RmlUi's render interface
# is eight pure virtuals that emit vertices and indices; this DLL records
# them into one flat buffer and answers with it. The graphics plane draws
# it through stzCanvas.AddMesh -- so the GUI rides the SAME display list
# the whole house already uses, and the GPU and SVG tiers cannot disagree
# about where a panel sits.
#
# Function prefix: StzEngineGui*
#
# Status codes: 0 = OK   2 = STALE   3 = BAD_ARG   4 = NOT FOUND
#
#   StzEngineGuiIsAvailable()            -- 1 when RmlUi initialised
#   StzEngineGuiInit() / StzEngineGuiShutdown()
#   StzEngineGuiLastError()              -- the last warning RmlUi logged,
#       so a refusal answers by NAME and not with a number
#   StzEngineGuiContextNew(w, h) -> id (0 = refusal)
#   StzEngineGuiContextFree(id) / ContextResize(id, w, h)
#   StzEngineGuiLoadRml(id, cRml)        -- a document from MEMORY. There
#       is no load-from-path on purpose: RML is EMITTED, never authored
#       (§4 of the plan), so a path would invite the thing the doctrine
#       forbids.
#   StzEngineGuiUpdate(id)               -- lay out (cheap when nothing
#       changed: G0 measured a still frame at 1/362 of a dirty one)
#   StzEngineGuiRender(id)               -- fill the recorder
#   StzEngineGuiVerts()                  -- flat x,y,r,g,b,a per vertex,
#       pixel space, channels 0..255 -- exactly stzCanvas.AddMesh's shape
#   StzEngineGuiIndices()                -- flat 0-based triangle indices
#   StzEngineGuiCounters() -> [ draws, droppedTexturedDraws,
#       ignoredScissors, widthCalls, generateCalls, keyboardActivations ]
#       The record's own account of what it drew AND what it could not.
#       In G1 the font engine is a stub that makes no textures, so a
#       nonzero dropped count means something arrived this phase cannot
#       draw -- which is exactly what G2 turns on.
#   StzEngineGuiElementBox(id, cElemId) -> [x, y, w, h] or []
#   StzEngineGuiSetTime(nSeconds)        -- RmlUi's clock, driven by the
#       caller so a test frame is deterministic
#
# TWO SEAM DETAILS, both paid for in G1 rather than assumed:
#   - RmlUi's vertex colour is PREMULTIPLIED alpha; the scene blends with
#     STRAIGHT alpha. The recorder divides it back out. Without that,
#     translucent surfaces render too dark and opaque ones look fine --
#     the worst way for a bug like this to present.
#   - RenderGeometry carries a per-draw TRANSLATION, baked into the
#     positions here, because the display list downstream has no per-draw
#     transform and should not grow one for this.

if isWindows()
    $cStzGuiLib = $cEngineDir + "/zig-out/bin/stz_gui.dll"
but isLinux()
    $cStzGuiLib = $cEngineDir + "/zig-out/lib/libstz_gui.so"
but isMacOS()
    $cStzGuiLib = $cEngineDir + "/zig-out/lib/libstz_gui.dylib"
ok

# Loaded ONLY if present. Its absence is not an error: a machine without
# it keeps every other graphics path, exactly as the window tier does.
$pStzGuiHandle = NULL
if fexists($cStzGuiLib)
    $pStzGuiHandle = LoadLib($cStzGuiLib)
ok

func StzGuiEngineLoaded()
	return $pStzGuiHandle != NULL
