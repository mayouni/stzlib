# Softanza Engine -- State Machine
#
# Loads stz_statemachine.dll for state machine.
#
# Function prefix: StzEngineStatemachine*

if isWindows()
    $cStzStatemachineLib = $cEngineDir + "/zig-out/bin/stz_statemachine.dll"
but isLinux()
    $cStzStatemachineLib = $cEngineDir + "/zig-out/lib/libstz_statemachine.so"
but isMacOS()
    $cStzStatemachineLib = $cEngineDir + "/zig-out/lib/libstz_statemachine.dylib"
ok
# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("statemachine")
    $pStzStatemachineHandle = NULL
but fexists($cStzStatemachineLib)
    $pStzStatemachineHandle = LoadLib($cStzStatemachineLib)
else
    ? "WARNING: stz_statemachine not found at: " + $cStzStatemachineLib
    $pStzStatemachineHandle = NULL
ok
