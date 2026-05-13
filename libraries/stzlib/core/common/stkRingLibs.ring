
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  LOADING NECESSARY RING LIBS (INCLUDING EXTENSIONS)  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

load "stdlibcore.ring"

# Engine-first loading: if $STZ_USE_ENGINE is set and the Engine
# DLL exists, load the Engine FFI bridge instead of Qt.
# Otherwise fall back to Qt as before.

if isGlobal(:$STZ_USE_ENGINE) and $STZ_USE_ENGINE = TRUE
    # Try to load the Engine
    $cEnginePath = exefolder() + "/../libraries/stzlib/engine"
    if isWindows()
        $cEngineDLL = $cEnginePath + "/zig-out/bin/softanza_engine.dll"
    but isLinux()
        $cEngineDLL = $cEnginePath + "/zig-out/lib/libsoftanza_engine.so"
    but isMacOS()
        $cEngineDLL = $cEnginePath + "/zig-out/lib/libsoftanza_engine.dylib"
    ok

    if fexists($cEngineDLL)
        $pEngineHandle = LoadLib($cEngineDLL)
        $STZ_ENGINE_LOADED = TRUE
    else
        $STZ_ENGINE_LOADED = FALSE
        load "qtcore.ring"
    ok
else
    $STZ_ENGINE_LOADED = FALSE
    load "qtcore.ring"
ok

# load "sqlitelib.ring"
# load "Internetlib.ring"
# load "fastpro.ring"
# load "tracelib.ring"
