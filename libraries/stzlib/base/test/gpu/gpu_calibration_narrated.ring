# Calibration -- the G5 half that makes thresholds MEASURED, not seeded
# (SOFTANZA_GPU_PLAN.md: "the threshold is MEASURED... nobody guesses
# where the GPU starts winning").
#
# stzGpu.Calibrate() walks a ladder of corpus sizes through the REAL G3
# seam, both routes (forced-CPU, forced-GPU), warm-min per rung (G0's
# clock inversion: sustained numbers flatter the GPU), stores the first
# rung the GPU wins with a 30% margin, and PERSISTS it -- the faces
# auto-load the file in later sessions, so the seed constant is only
# ever a first-run fallback.
#
# Scenes: a missing file loads to nothing (no crash, no phantom value);
# a measured pass produces a report + a stored threshold + both files;
# ShouldDispatch flips ACROSS the stored line (mechanism); a scrambled
# store is restored from disk (the round-trip is real).

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(3)

? "-- Scene 0: a clean slate (calibration files deleted) --"
if fexists(StzGpuCalibFileDefault())
    remove(StzGpuCalibFileDefault())
ok
StzGpuLoadCalibrationDefault()
chk("loading a MISSING default file stores nothing", StzEngineGpuCalibGet("pairdist") = 0)

oG = new stzGpu
if NOT oG.IsAvailable()
    ? "  NO GPU ON THIS MACHINE -- calibration needs a device; the missing-file scene is the CI coverage"
else
    ? "  device: " + oG.DeviceName()
    if fexists(StzGpuCalibFileForAdapter())
        remove(StzGpuCalibFileForAdapter())
    ok

    ? ""
    ? "-- Scene 1: a measured pass on a reduced ladder --"
    aRes = oG.CalibrateWith([1000, 2000, 4000])
    nThresh = aRes[1]
    aReport = aRes[2]
    chk("three rungs measured", len(aReport) = 3)
    ? "  problem-size    cpu ms      gpu ms"
    for i = 1 to len(aReport)
        ? "  " + aReport[i][1] + "    " + aReport[i][2] + "    " + aReport[i][3]
    next
    ? "  stored crossover: " + nThresh
    bLadder = FALSE
    for i = 1 to len(aReport)
        if nThresh = aReport[i][1]
            bLadder = TRUE
        ok
    next
    chk("the threshold is a LADDER value (or the CPU-only sentinel)",
        bLadder or nThresh = 999999999999)
    chk("the store carries it", StzEngineGpuCalibGet("pairdist") = nThresh)
    chk("the default file was written", fexists(StzGpuCalibFileDefault()))
    chk("the per-adapter file was written", fexists(StzGpuCalibFileForAdapter()))

    ? ""
    ? "-- Scene 2: ShouldDispatch flips ACROSS the measured line --"
    if nThresh < 999999999999
        chk("below the line: CPU", StzEngineGpuShouldDispatch("pairdist", nThresh - 1) = 0)
        chk("at the line: GPU", StzEngineGpuShouldDispatch("pairdist", nThresh) = 1)
    else
        chk("the GPU never won this ladder; everything routes CPU",
            StzEngineGpuShouldDispatch("pairdist", 100000000) = 0)
        chk("(sentinel keeps even huge problems on CPU)",
            StzEngineGpuShouldDispatch("pairdist", 999999999998) = 0)
    ok

    ? ""
    ? "-- Scene 3: the round-trip is real --"
    StzEngineGpuCalibSet("pairdist", 777)
    chk("store scrambled", StzEngineGpuCalibGet("pairdist") = 777)
    _StzGpuCalibLoadFile(StzGpuCalibFileDefault())
    chk("the persisted measurement restored the store",
        StzEngineGpuCalibGet("pairdist") = nThresh)
    StzEngineGpuShutdown()
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
