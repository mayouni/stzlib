# Softanza Engine -- bounded thread pool with work queue.
# Replaces per-call std.Thread.spawn for scalable concurrency.
#
# StzEnginePoolCreate(nWorkers)         -> opaque pool handle
# StzEnginePoolSubmit(pool, nKind, cArg) -> job id (>0) or -1
# StzEnginePoolPoll(pool, nJobId)       -> body string (drains the job)
# StzEnginePoolLastStatus()             -> last poll result code
#                                            -1 = job still running
#                                            -2 = id not found
#                                            -3 = result body too large
#                                            >=0 = HTTP status (or job-kind status)
# StzEnginePoolDestroy(pool)
# StzEnginePoolLastError()
#
# Job kinds (currently): 0 = HTTP GET (cArg = url).

if isWindows()
    $cStzPoolLib = $cEngineDir + "/zig-out/bin/stz_pool.dll"
but isLinux()
    $cStzPoolLib = $cEngineDir + "/zig-out/lib/libstz_pool.so"
but isMacOS()
    $cStzPoolLib = $cEngineDir + "/zig-out/lib/libstz_pool.dylib"
ok

if fexists($cStzPoolLib)
    $pStzPoolHandle = LoadLib($cStzPoolLib)
else
    ? "WARNING: stz_pool not found at: " + $cStzPoolLib
    $pStzPoolHandle = NULL
ok
