# Softanza Engine -- Execution Model (State Machine)
#
# Loads stz_execmodel.dll for state machine + event dispatch.
#
# Function prefix: StzEngineExec*

if isWindows()
    $cStzExecmodelLib = $cEngineDir + "/zig-out/bin/stz_execmodel.dll"
but isLinux()
    $cStzExecmodelLib = $cEngineDir + "/zig-out/lib/libstz_execmodel.so"
but isMacOS()
    $cStzExecmodelLib = $cEngineDir + "/zig-out/lib/libstz_execmodel.dylib"
ok

if fexists($cStzExecmodelLib)
    $pStzExecmodelHandle = LoadLib($cStzExecmodelLib)
else
    ? "WARNING: stz_execmodel not found at: " + $cStzExecmodelLib
    $pStzExecmodelHandle = NULL
ok
