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

if fexists($cStzTraceCtxLib)
    $pStzTraceCtxHandle = LoadLib($cStzTraceCtxLib)
else
    ? "WARNING: stz_tracectx not found at: " + $cStzTraceCtxLib
    $pStzTraceCtxHandle = NULL
ok
