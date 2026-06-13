# Softanza Engine -- resilience primitives for web / cloud / agentic loops.
#
# Retry (pure):
#   StzEngineRetryDelayMs(nAttempt, nBaseMs, nMaxMs, nSeed)
#     -> jittered backoff delay (use seed=0 for OS RNG)
#
# Token bucket rate limiter:
#   StzEngineRateCreate(nCapacity, nRefillPerSec)
#   StzEngineRateTryTake(pRate, nTokens)            -> 1 ok / 0 denied
#   StzEngineRateWaitFor(pRate, nTokens)            -> ms waited (blocks)
#   StzEngineRateAvailable(pRate)                   -> tokens (float)
#   StzEngineRateDestroy(pRate)
#
# Circuit breaker (3-state: closed / open / half_open):
#   StzEngineCircuitCreate(nFailureThreshold, nResetAfterMs)
#   StzEngineCircuitCanPass(pCircuit)               -> 1 pass / 0 block
#   StzEngineCircuitRecordSuccess(pCircuit)
#   StzEngineCircuitRecordFailure(pCircuit)
#   StzEngineCircuitState(pCircuit)                 -> 0=closed 1=open 2=half_open
#   StzEngineCircuitReset(pCircuit)
#   StzEngineCircuitDestroy(pCircuit)

if isWindows()
    $cStzResilienceLib = $cEngineDir + "/zig-out/bin/stz_resilience.dll"
but isLinux()
    $cStzResilienceLib = $cEngineDir + "/zig-out/lib/libstz_resilience.so"
but isMacOS()
    $cStzResilienceLib = $cEngineDir + "/zig-out/lib/libstz_resilience.dylib"
ok

if fexists($cStzResilienceLib)
    $pStzResilienceHandle = LoadLib($cStzResilienceLib)
else
    ? "WARNING: stz_resilience not found at: " + $cStzResilienceLib
    $pStzResilienceHandle = NULL
ok

# State constants (mirror engine CircuitState enum)
STZ_CIRCUIT_CLOSED    = 0
STZ_CIRCUIT_OPEN      = 1
STZ_CIRCUIT_HALF_OPEN = 2
