# Softanza Engine -- latency histogram (p50 / p95 / p99).
#
# Loads stz_histogram.dll. Log-scale bucketed histogram for request /
# job latency; gap-analysis Tier 1 item 6.
#
# Function prefix: StzEngineHistogram*
#   StzEngineHistogramCreate()              -> opaque handle
#   StzEngineHistogramRecord(h, nMs)        -> tally one sample
#   StzEngineHistogramPercentile(h, nP)     -> ms upper bound for pctile
#   StzEngineHistogramCount(h)              -> total samples
#   StzEngineHistogramReset(h)
#   StzEngineHistogramDestroy(h)

if isWindows()
    $cStzHistogramLib = $cEngineDir + "/zig-out/bin/stz_histogram.dll"
but isLinux()
    $cStzHistogramLib = $cEngineDir + "/zig-out/lib/libstz_histogram.so"
but isMacOS()
    $cStzHistogramLib = $cEngineDir + "/zig-out/lib/libstz_histogram.dylib"
ok

if fexists($cStzHistogramLib)
    $pStzHistogramHandle = LoadLib($cStzHistogramLib)
else
    ? "WARNING: stz_histogram not found at: " + $cStzHistogramLib
    $pStzHistogramHandle = NULL
ok
