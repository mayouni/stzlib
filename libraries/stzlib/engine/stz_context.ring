# Softanza Engine -- Context Scopes
#
# Loads stz_context.dll for context scopes.
#
# Function prefix: StzEngineContext*

if isWindows()
    $cStzContextLib = $cEngineDir + "/zig-out/bin/stz_context.dll"
but isLinux()
    $cStzContextLib = $cEngineDir + "/zig-out/lib/libstz_context.so"
but isMacOS()
    $cStzContextLib = $cEngineDir + "/zig-out/lib/libstz_context.dylib"
ok
if fexists($cStzContextLib)
    $pStzContextHandle = LoadLib($cStzContextLib)
else
    ? "WARNING: stz_context not found at: " + $cStzContextLib
    $pStzContextHandle = NULL
ok
