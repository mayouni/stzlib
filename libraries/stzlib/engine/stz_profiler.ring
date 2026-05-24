# Softanza Engine -- Profiler (Named Timers)
#
# Loads stz_profiler.dll for function-level timing and call counting.
#
# Function prefix: StzEngineProfiler*

if isWindows()
    $cStzProfilerLib = $cEngineDir + "/zig-out/bin/stz_profiler.dll"
but isLinux()
    $cStzProfilerLib = $cEngineDir + "/zig-out/lib/libstz_profiler.so"
but isMacOS()
    $cStzProfilerLib = $cEngineDir + "/zig-out/lib/libstz_profiler.dylib"
ok

if fexists($cStzProfilerLib)
    $pStzProfilerHandle = LoadLib($cStzProfilerLib)
else
    ? "WARNING: stz_profiler not found at: " + $cStzProfilerLib
    $pStzProfilerHandle = NULL
ok
