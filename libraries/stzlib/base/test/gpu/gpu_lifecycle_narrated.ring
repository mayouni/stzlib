# The GPU lifecycle layer -- G1 of the GPU plane (SOFTANZA_GPU_PLAN.md).
#
# G0 measured where the GPU pays (resident-chain compute-dense ops) and
# where it never will (standalone elementwise, anything under the dispatch
# floor). G1 is the machinery those numbers demand: stz_gpu.dll with
# generation-keyed buffer handles, a WGSL compile-cache, a BOUNDED VRAM
# cache with FIFO eviction, TDR-safe tiling, a calibration store, and
# fallback that is COUNTED, never silent.
#
# This guard asserts the MECHANISMS, each with its negative sibling:
#   - fallback counts before Init, and does NOT count after (both sides)
#   - the compile-cache compiles once and hits thereafter (1 compile + hits,
#     not "it returned an id twice")
#   - tiling splits into EXACTLY ceil(wx/limit) submits AND the tile-offset
#     arithmetic still lands every element (result stays exact)
#   - eviction fires under a small budget (victim goes STALE, accounting
#     shrinks) and does NOT fire under a large one
#   - create/free churn returns the live count and VRAM accounting to
#     baseline (Ring has no destructors; the explicit path must be exact)
#   - calibration answers BOTH sides of the threshold, and answers CPU
#     whenever the device is gone
#
# CI note: this guard is written to pass WITHOUT a GPU -- every device
# scene gates on IsAvailable(); the fallback scenes ARE the CI coverage.
#
# Deliberately STANDALONE (loads the engine bridge directly, not
# stzBase.ring): the lifecycle layer has no dependency on the library
# faces, so its guard shouldn't inherit their load-time failures -- a
# broken unrelated face must not mask a GPU regression, and CI can run
# this on a machine with nothing but Ring + the engine DLLs.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no keyword-bearing names.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

# counter indices (documented in engine/stz_gpu.ring)
C_DISP  = 0
C_DMS   = 1
C_BYTES = 2
C_FALL  = 3
C_COMP  = 4
C_HITS  = 5
C_SUB   = 6
C_EVICT = 7
C_LIVE  = 8
C_ERR   = 9

# status codes
S_OK = 0
S_FALLBACK = 1
S_STALE = 2
S_BADARG = 3



? "-- Scene 1: before Init, the layer answers the fallback way, and COUNTS it --"
StzEngineGpuCountersReset()
chk("not available before Init", StzEngineGpuIsAvailable() = 0)
nB = StzEngineGpuBufferNew(1024)
chk("buffer creation refuses (id 0)", nB = 0)
chk("dispatch refuses with FALLBACK", StzEngineGpuDispatch(1, [1], 1, 1) = S_FALLBACK)
nFallsBefore = StzEngineGpuCounter(C_FALL)
chk("every refusal was counted (>= 2)", nFallsBefore >= 2)
StzEngineGpuCalibSet("saxpy", 100)
chk("ShouldDispatch answers CPU while the device is absent, even calibrated",
    StzEngineGpuShouldDispatch("saxpy", 1000000) = 0)

? ""
? "-- Scene 2: Init against the vendored runtime --"
nInit = StzEngineGpuInit($cStzGpuRuntime)
? "  Init(" + $cStzGpuRuntime + ") = " + nInit
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- device scenes skipped, fallback scenes above ARE the coverage"
else
    ? "  adapters visible: " + StzEngineGpuAdapterCount()
    ? "  selected: [" + StzEngineGpuSelectedAdapter() + "] " +
        StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
    chk("at least one adapter enumerated", StzEngineGpuAdapterCount() >= 1)
    chk("a device was selected", StzEngineGpuSelectedAdapter() >= 0)

    StzEngineGpuCountersReset()

    ? ""
    ? "-- Scene 3: the compile-cache compiles ONCE per kernel text --"
    cSaxpy = "struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }" + char(10) +
        "@group(0) @binding(0) var<uniform> tile : StzTile;" + char(10) +
        "@group(0) @binding(1) var<storage, read> x : array<f32>;" + char(10) +
        "@group(0) @binding(2) var<storage, read_write> y : array<f32>;" + char(10) +
        "@compute @workgroup_size(64)" + char(10) +
        "fn main(@builtin(global_invocation_id) gid : vec3<u32>) {" + char(10) +
        "  let i = gid.x + tile.xoff * 64u;" + char(10) +
        "  if (i < arrayLength(&y)) { y[i] = 2.5 * x[i] + y[i]; }" + char(10) +
        "}"
    nK1 = StzEngineGpuKernelCompile(cSaxpy)
    chk("kernel compiles (id > 0)", nK1 > 0)
    chk("one real compile", StzEngineGpuCounter(C_COMP) = 1)
    chk("no cache hit yet", StzEngineGpuCounter(C_HITS) = 0)
    nK2 = StzEngineGpuKernelCompile(cSaxpy)
    chk("identical text returns the SAME kernel id", nK2 = nK1)
    chk("still one real compile", StzEngineGpuCounter(C_COMP) = 1)
    chk("the second ask was a cache HIT", StzEngineGpuCounter(C_HITS) = 1)
    # different TEXT, same semantics: a trailing comment changes the cache
    # key -- the cache is keyed by text, and this asserts exactly that
    cDouble = cSaxpy + char(10) + "// variant"
    nK3 = StzEngineGpuKernelCompile(cDouble)
    chk("different text is a NEW kernel (negative sibling)", nK3 > 0 and nK3 != nK1)
    chk("and a second real compile", StzEngineGpuCounter(C_COMP) = 2)

    nErrsBefore = StzEngineGpuCounter(C_ERR)
    nBadK = StzEngineGpuKernelCompile("this is not wgsl at all")
    chk("malformed WGSL refuses (id 0)", nBadK = 0)
    chk("and the device error was captured + counted", StzEngineGpuCounter(C_ERR) > nErrsBefore)

    ? ""
    ? "-- Scene 4: end-to-end saxpy through the lifecycle (exact values) --"
    nN = 1024
    aX = []
    aY = []
    for i = 1 to nN
        aX + ((i-1) * 0.5)
        aY + ((i-1) * 0.25)
    next
    nBufX = StzEngineGpuBufferNew(nN * 4)
    nBufY = StzEngineGpuBufferNew(nN * 4)
    chk("two device buffers created", nBufX > 0 and nBufY > 0)
    chk("upload x is OK", StzEngineGpuBufferUploadList(nBufX, aX) = S_OK)
    chk("upload y is OK", StzEngineGpuBufferUploadList(nBufY, aY) = S_OK)
    chk("dispatch is OK (16 workgroups of 64)", StzEngineGpuDispatch(nK1, [nBufX, nBufY], 16, 1) = S_OK)
    chk("sync is OK", StzEngineGpuSync() = S_OK)
    aOut = StzEngineGpuBufferDownloadList(nBufY, nN)
    chk("downloaded the full vector", len(aOut) = nN)
    # y = 2.5*(0.5k) + 0.25k = 1.5k -- every term exact in f32, so EQUALITY
    bExact = TRUE
    for i = 1 to nN
        if aOut[i] != 1.5 * (i-1)
            bExact = FALSE
            exit
        ok
    next
    chk("every element exact: y[k] = 1.5k (f32-exact by construction)", bExact)
    chk("transfer bytes counted the two uploads + one download",
        StzEngineGpuCounter(C_BYTES) = 3 * nN * 4)
    chk("dispatch count is 1", StzEngineGpuCounter(C_DISP) = 1)
    chk("dispatch wall time advanced", StzEngineGpuCounter(C_DMS) > 0)
    chk("NO fallback was counted on the happy path (negative sibling)",
        StzEngineGpuCounter(C_FALL) = 0)

    ? ""
    ? "-- Scene 5: TDR tiling splits submits, and the offset math stays exact --"
    # refresh y, then dispatch the same 16 workgroups with tile limit 4:
    # EXACTLY ceil(16/4) = 4 submits, and the result must still be exact,
    # which proves each tile saw its own xoff (the mechanism, not the vibe).
    chk("re-upload y", StzEngineGpuBufferUploadList(nBufY, aY) = S_OK)
    StzEngineGpuSetTileLimit(4)
    nSubsBefore = StzEngineGpuCounter(C_SUB)
    chk("tiled dispatch is OK", StzEngineGpuDispatch(nK1, [nBufX, nBufY], 16, 1) = S_OK)
    chk("sync after tiles", StzEngineGpuSync() = S_OK)
    nTileSubs = StzEngineGpuCounter(C_SUB) - nSubsBefore
    ? "  submits for wx=16 at tile limit 4: " + nTileSubs
    chk("EXACTLY 4 submits (16 workgroups / 4 per tile)", nTileSubs = 4)
    aOut2 = StzEngineGpuBufferDownloadList(nBufY, nN)
    bExact2 = TRUE
    for i = 1 to nN
        if aOut2[i] != 1.5 * (i-1)
            bExact2 = FALSE
            exit
        ok
    next
    chk("tiled result identical -- every tile landed at its offset", bExact2)
    StzEngineGpuSetTileLimit(32768)
    nSubsBefore = StzEngineGpuCounter(C_SUB)
    chk("re-upload y again", StzEngineGpuBufferUploadList(nBufY, aY) = S_OK)
    chk("untiled dispatch OK", StzEngineGpuDispatch(nK1, [nBufX, nBufY], 16, 1) = S_OK)
    chk("sync", StzEngineGpuSync() = S_OK)
    chk("ONE submit under the big limit (negative sibling)",
        StzEngineGpuCounter(C_SUB) - nSubsBefore = 1)

    ? ""
    ? "-- Scene 6: the VRAM bound evicts FIFO, and eviction is visible --"
    # scene 4's buffers are freed FIRST: they are the oldest live entries,
    # and FIFO would (correctly) evict THEM before A -- the scene needs a
    # clean cache to name its victim.
    StzEngineGpuBufferFree(nBufX)
    StzEngineGpuBufferFree(nBufY)
    chk("cache empty before the pressure scene", StzEngineGpuVramInUse() = 0)
    StzEngineGpuSetVramBudget(1000000)
    nBufA = StzEngineGpuBufferNew(400000)
    nBufB = StzEngineGpuBufferNew(400000)
    chk("A and B fit the budget", nBufA > 0 and nBufB > 0)
    chk("no eviction yet", StzEngineGpuCounter(C_EVICT) = 0)
    nBufC = StzEngineGpuBufferNew(400000)
    chk("C was created", nBufC > 0)
    chk("ONE eviction paid for it", StzEngineGpuCounter(C_EVICT) = 1)
    chk("the OLDEST (A) is the victim -- its id is now STALE",
        StzEngineGpuBufferUploadList(nBufA, [1, 2, 3]) = S_STALE)
    chk("B survived (FIFO, not random)", StzEngineGpuBufferSize(nBufB) = 400000)
    chk("C is live", StzEngineGpuBufferSize(nBufC) = 400000)
    chk("accounting shows exactly B + C", StzEngineGpuVramInUse() = 800000)
    StzEngineGpuSetVramBudget(1000000000)
    nEvBefore = StzEngineGpuCounter(C_EVICT)
    nBufD = StzEngineGpuBufferNew(400000)
    chk("under a big budget the same ask evicts NOTHING (negative sibling)",
        nBufD > 0 and StzEngineGpuCounter(C_EVICT) = nEvBefore)
    StzEngineGpuBufferFree(nBufB)
    StzEngineGpuBufferFree(nBufC)
    StzEngineGpuBufferFree(nBufD)

    ? ""
    ? "-- Scene 7: create/free churn balances to zero --"
    nLive0 = StzEngineGpuCounter(C_LIVE)
    nUse0 = StzEngineGpuVramInUse()
    nStale = 0
    for i = 1 to 200
        _nId_ = StzEngineGpuBufferNew(4096)
        StzEngineGpuBufferFree(_nId_)
        if StzEngineGpuBufferUploadList(_nId_, [1]) = S_STALE
            nStale++
        ok
    next
    chk("200 create/free cycles leave live count unmoved", StzEngineGpuCounter(C_LIVE) = nLive0)
    chk("and VRAM accounting unmoved", StzEngineGpuVramInUse() = nUse0)
    chk("every freed id went STALE -- generations, not luck (200/200)", nStale = 200)
    chk("still no fallback counted (negative sibling)", StzEngineGpuCounter(C_FALL) = 0)

    ? ""
    ? "-- Scene 8: calibration gates BOTH sides of the crossover --"
    StzEngineGpuCalibSet("matmul", 128)
    chk("stored threshold reads back", StzEngineGpuCalibGet("matmul") = 128)
    chk("below the line: CPU", StzEngineGpuShouldDispatch("matmul", 64) = 0)
    chk("AT the line: GPU", StzEngineGpuShouldDispatch("matmul", 128) = 1)
    chk("above the line: GPU", StzEngineGpuShouldDispatch("matmul", 4096) = 1)
    chk("an op with NO calibration answers CPU", StzEngineGpuShouldDispatch("mystery", 4096) = 0)

    ? ""
    ? "-- Scene 9: shutdown is honest, and Init comes back --"
    StzEngineGpuShutdown()
    chk("not available after shutdown", StzEngineGpuIsAvailable() = 0)
    chk("calibrated op routes CPU once the device is gone",
        StzEngineGpuShouldDispatch("matmul", 4096) = 0)
    nFall0 = StzEngineGpuCounter(C_FALL)
    chk("post-shutdown buffer ask refuses", StzEngineGpuBufferNew(1024) = 0)
    chk("and was counted", StzEngineGpuCounter(C_FALL) = nFall0 + 1)
    chk("re-Init restores the device", StzEngineGpuInit($cStzGpuRuntime) = 1)
    chk("available again", StzEngineGpuIsAvailable() = 1)
    StzEngineGpuShutdown()
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="



func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
