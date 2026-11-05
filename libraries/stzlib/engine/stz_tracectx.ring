# Softanza Engine -- W3C Trace Context (traceparent).
#
# Loads stz_tracectx.dll. Generate / derive / validate distributed-trace
# headers for cross-service + agentic request correlation. Pure, no deps.
#
# Function prefix: StzEngineTrace*
#   StzEngineTraceNew()            -> fresh sampled traceparent
#   StzEngineTraceChild(cParent)   -> child header (same trace, new span)
#   StzEngineTraceIsValid(cParent) -> 1 / 0
#   StzEngineTraceId(cParent)      -> 32-hex trace-id
#   StzEngineTraceSpanId(cParent)  -> 16-hex span-id
#   StzEngineTraceSampled(cParent) -> 1 / 0

if isWindows()
    $cStzTraceCtxLib = $cEngineDir + "/zig-out/bin/stz_tracectx.dll"
but isLinux()
    $cStzTraceCtxLib = $cEngineDir + "/zig-out/lib/libstz_tracectx.so"
but isMacOS()
    $cStzTraceCtxLib = $cEngineDir + "/zig-out/lib/libstz_tracectx.dylib"
ok

# the domain door (SOFTANZA_ONE_HOUR.md W7b): skipped when a manifest leaves it out or DENIED names it
if NOT StzDomainWanted("tracectx")
    $pStzTraceCtxHandle = NULL
but fexists($cStzTraceCtxLib)
    $pStzTraceCtxHandle = LoadLib($cStzTraceCtxLib)
else
    ? "WARNING: stz_tracectx not found at: " + $cStzTraceCtxLib
    $pStzTraceCtxHandle = NULL
ok
