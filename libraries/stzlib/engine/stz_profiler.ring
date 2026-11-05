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

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("profiler")
    $pStzProfilerHandle = NULL
but fexists($cStzProfilerLib)
    $pStzProfilerHandle = LoadLib($cStzProfilerLib)
else
    ? "WARNING: stz_profiler not found at: " + $cStzProfilerLib
    $pStzProfilerHandle = NULL
ok
