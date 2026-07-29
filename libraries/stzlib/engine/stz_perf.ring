# Softanza Engine -- Performance Senses (perf system P1)
#
# Loads stz_perf.dll: process memory (RSS/peak), system memory
# (total/available), process CPU time, and the engine-resident metric
# series (bounded (time, value) ring buffer with statistical queries).
#
# Function prefix: StzEnginePerf*

if isWindows()
    $cStzPerfLib = $cEngineDir + "/zig-out/bin/stz_perf.dll"
but isLinux()
    $cStzPerfLib = $cEngineDir + "/zig-out/lib/libstz_perf.so"
but isMacOS()
    $cStzPerfLib = $cEngineDir + "/zig-out/lib/libstz_perf.dylib"
ok

if fexists($cStzPerfLib)
    $pStzPerfHandle = LoadLib($cStzPerfLib)
else
    ? "WARNING: stz_perf not found at: " + $cStzPerfLib
    $pStzPerfHandle = NULL
ok
