# GK1 -- the SHAPE-KEYED calibration store (SOFTANZA_GPU_PLAN.md, GK1).
#
# The flat store held ONE number per op (dispatch pairdist from n*d >= T).
# GK1's probe measured, on 2026-09-09, that T on disk routed half the
# (dimension x corpus) grid to a GPU that lost by 2-10x, and that on the
# Intel iGPU the crossover moves 4x with the dimension. So the store gains
# a shape: (op, n-class, d-class) -> the measured cpu/gpu ratio, classes
# being powers-of-two ceilings; the gate applies ONE margin; an unmeasured
# class falls back to the flat line; and the authority order G5 wrote --
# explicit > persisted > seed -- is carried to shapes with a flag.
#
# What this suite asserts, mechanism first, each with its negative sibling:
#   - classes bucket as powers of two (16000 and 16384 share one, 16385 does not)
#   - the ROUTE: a measured class decides by its ratio against the margin;
#     a ratio under the margin stays CPU; an unmeasured class falls back to
#     the flat line; an EXPLICIT flat line outranks a FILLED class (a guard
#     forcing a route keeps working after a file has loaded)
#   - the SEAM consults the shape: a losing class keeps a corpus on the CPU
#     even where the flat line would dispatch it, and a winning class sends
#     a corpus the flat line would keep -- witnessed by the dispatch counter
#   - persistence ROUND-TRIPS shapes AND the ladder: written, scrambled,
#     restored from disk; the file holds a trace row per measured cell
#   - CalibrateShapedWith on a small grid stores a class per cell, sets the
#     flat line to the most conservative crossover (or beyond the ladder),
#     and CHECKS ITSELF at two shapes the grid never held
#
# The device scenes need a GPU; the store and classing scenes are CI's.

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_DISP = 0

pr()

decimals(3)

? "-- Scene 1: shape classes are powers-of-two ceilings --"
chk("1000 and 1024 share class 10", StzEngineGpuShapeClass(1000) = 10 and StzEngineGpuShapeClass(1024) = 10)
chk("1025 is class 11 (the negative sibling)", StzEngineGpuShapeClass(1025) = 11)
chk("16000 and 16384 share class 14; 16385 does not",
	StzEngineGpuShapeClass(16000) = 14 and StzEngineGpuShapeClass(16385) = 15)
chk("dimension 16 is class 4, 1 is class 0", StzEngineGpuShapeClass(16) = 4 and StzEngineGpuShapeClass(1) = 0)

? ""
? "-- Scene 2: the route, device-free --"
# a private op name so nothing persisted interferes
cOp = "gk1_route_test"
chk("no calibration at all: CPU", StzEngineGpuCalibRouteShaped(cOp, 4000, 256) = 0)
StzEngineGpuCalibFill(cOp, 100000)
chk("a flat line filled from 'disk': n*d = 1,024,000 dispatches", StzEngineGpuCalibRouteShaped(cOp, 4000, 256) = 1)
chk("...and n*d = 1,600 does not", StzEngineGpuCalibRouteShaped(cOp, 100, 16) = 0)
StzEngineGpuCalibFillShaped(cOp, 4000, 256, 0.6)
chk("a measured class that LOSES overrides the flat line for its class", StzEngineGpuCalibRouteShaped(cOp, 3000, 200) = 0)
chk("...and only its class: (4000, 1024) still follows the flat line", StzEngineGpuCalibRouteShaped(cOp, 4000, 1024) = 1)
StzEngineGpuCalibSetShaped(cOp, 1000, 16, 1.1)
chk("a class the GPU wins by 1.1x is UNDER the 1.3 margin: CPU", StzEngineGpuCalibRouteShaped(cOp, 1000, 16) = 0)
StzEngineGpuCalibSetShaped(cOp, 1000, 16, 2.0)
chk("...at 2.0x it dispatches, though n*d = 16,000 is far below the flat line", StzEngineGpuCalibRouteShaped(cOp, 1000, 16) = 1)
StzEngineGpuCalibSet(cOp, 1)
chk("an EXPLICIT flat line outranks the FILLED losing class (a guard forcing a route)", StzEngineGpuCalibRouteShaped(cOp, 4000, 256) = 1)
StzEngineGpuCalibSetShaped(cOp, 4000, 256, 0.6)
chk("...but not an explicit shaped one: both in-process, the specific wins", StzEngineGpuCalibRouteShaped(cOp, 4000, 256) = 0)
StzEngineGpuCalibSetShaped(cOp, 4000, 256, 0)
chk("setting a class to 0 clears it: back to the flat line", StzEngineGpuCalibRouteShaped(cOp, 4000, 256) = 1)
StzEngineGpuCalibFill(cOp, 999999)
chk("a fill never overrides a set value", StzEngineGpuCalibGet(cOp) = 1)

oG = new stzGpu
if NOT oG.IsAvailable()
	? ""
	? "  NO GPU ON THIS MACHINE -- the seam, round-trip and grid scenes need a device; scenes 1-2 are the CI coverage"
else
	? ""
	? "  device: " + oG.DeviceName()
	? ""
	? "-- Scene 3: the SEAM consults the shape --"
	# a small corpus: 200 x 16 = 3,200 elements, class (8, 4)
	aVecs = []
	for i = 0 to 199
		aRow = []
		for j = 0 to 15
			aRow + ((i * 7 + j * 13) % 32)
		next
		aVecs + aRow
	next
	aQry = []
	for j = 0 to 15
		aQry + ((j * 3 + 11) % 32)
	next
	# the flat line says GPU for everything...
	StzEngineGpuCalibSet("pairdist", 1)
	# ...but the class of this corpus was measured to LOSE
	StzEngineGpuCalibSetShaped("pairdist", 200, 16, 0.5)
	StzEngineGpuCountersReset()
	oIdx = new stzVectorIndex(aVecs)
	aRes = oIdx.SearchExact(aQry, 3)
	chk("a losing class keeps the corpus on the CPU: NO dispatch, though the flat line would send it",
		len(aRes) = 3 and StzEngineGpuCounter(C_DISP) = 0)
	# the negative sibling: the class WINS, the flat line says CPU
	StzEngineGpuCalibSet("pairdist", 999999999999)
	StzEngineGpuCalibSetShaped("pairdist", 200, 16, 3.0)
	StzEngineGpuCountersReset()
	oIdx2 = new stzVectorIndex(aVecs)
	aRes2 = oIdx2.SearchExact(aQry, 3)
	chk("a winning class sends the corpus to the GPU: the dispatch counter MOVED, though the flat line would keep it",
		len(aRes2) = 3 and StzEngineGpuCounter(C_DISP) > 0)
	chk("both routes name the same neighbours", aRes[1][1] = aRes2[1][1] and aRes[2][1] = aRes2[2][1])
	StzEngineGpuCalibSetShaped("pairdist", 200, 16, 0)   # clear the class

	? ""
	? "-- Scene 3b: Wake() does the work it claims --"
	# the mechanism, not the vibe: Wake copies until a copy runs at full
	# speed, then settles and STOPS -- so a device that is already awake
	# is recognised within its settle count, whatever the cap
	nT0 = StzEngineWatchTimestampNs()
	nCopies = oG.Wake(400)
	nWakeMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  Wake(400): " + nCopies + " copies of 16 MB in " + nWakeMs + " ms"
	chk("Wake dispatched copies", nCopies > 0)
	chk("...and stopped within its cap", nWakeMs < 450)
	nT0 = StzEngineWatchTimestampNs()
	nAgain = oG.Wake(400)
	nAgainMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
	? "  Wake(400) again, device awake: " + nAgain + " copies in " + nAgainMs + " ms"
	chk("an AWAKE device is recognised: the second burst stops at the settle count (<= 25 copies)", nAgain > 0 and nAgain <= 25)
	chk("...in a few ms, not the cap (the cap is a cap)", nAgainMs < 100)

	? ""
	? "-- Scene 4: persistence round-trips shapes AND the ladder --"
	# this guard writes the calibration files to prove the round trip, but
	# a four-cell grid is NOT this machine's calibration: the real files
	# are kept and put back at the end
	cBakA = ""
	cBakD = ""
	if fexists(StzGpuCalibFileForAdapter())
		cBakA = read(StzGpuCalibFileForAdapter())
		remove(StzGpuCalibFileForAdapter())
	ok
	if fexists(StzGpuCalibFileDefault())
		cBakD = read(StzGpuCalibFileDefault())
	ok
	StzEngineGpuCalibSet("pairdist", 4096000)
	StzGpuCalibSetShaped("pairdist", 4000, 256, 2.519)
	StzGpuCalibAddLadderRow("pairdist", 4000, 256, 2.306, 3.576)
	StzGpuSaveCalibration(["pairdist"])
	cFile = read(StzGpuCalibFileForAdapter())
	chk("the file holds the flat line", StzFindFirst("pairdist" + char(9) + "4096000", cFile) > 0)
	chk("...a shape row for the measured class", StzFindFirst("shape" + char(9) + "pairdist" + char(9) + "4000" + char(9) + "256", cFile) > 0)
	chk("...and the LADDER row that produced it (the trace, not just the number)",
		StzFindFirst("ladder" + char(9) + "pairdist" + char(9) + "4000" + char(9) + "256" + char(9), cFile) > 0)
	# scramble, then restore from disk (the raw loader is the round-trip's own tool)
	StzEngineGpuCalibSetShaped("pairdist", 4000, 256, 0.1)
	StzEngineGpuCalibSet("pairdist", 7)
	_StzGpuCalibLoadFile(StzGpuCalibFileForAdapter())
	chk("the flat line is restored from disk", StzEngineGpuCalibGet("pairdist") = 4096000)
	chk("the shaped ratio is restored from disk (2.519)", fabs(StzEngineGpuCalibGetShaped("pairdist", 4000, 256) - 2.519) < 0.0005)
	aLad = StzGpuCalibrationLadder()
	chk("the ladder reads back", len(aLad) >= 1 and aLad[len(aLad)][2] = 4000 and aLad[len(aLad)][3] = 256)

	? ""
	? "-- Scene 5: CalibrateShapedWith on a small grid, and it checks itself --"
	aRep = oG.CalibrateShapedWith([16, 256], [1000, 4000])
	? "  adapter: " + aRep[:adapter]
	nCells = len(aRep[:cells])
	for i = 1 to nCells
		c = aRep[:cells][i]
		? "    d " + c[1] + "  n " + c[2] + "  cpu " + c[3] + " ms  gpu " + c[4] + " ms  ratio " + c[5]
	next
	? "  flat line stored: " + aRep[:flat] + "  (" + aRep[:flatwhy] + ")"
	aCtl = aRep[:control]
	? "  control (first cell re-measured last): cpu " + aCtl[3] + " -> " + aCtl[5] + " ms (x" + aCtl[7] + ")   gpu " + aCtl[4] + " -> " + aCtl[6] + " ms (x" + aCtl[8] + ")"
	chk("four cells measured", nCells = 4)
	chk("the CONTROL ran: the first cell was measured again at the end (8 fields)", len(aCtl) = 8 and aCtl[5] > 0 and aCtl[6] > 0)
	if aRep[:confounded]
		? "  THE CONTROL MOVED: this grid is CONFOUNDED and was NOT persisted (a wrong number on disk routes every later process wrong)"
		chk("a confounded grid says so, and stores no flat line", aRep[:flatwhy] = "confounded" and aRep[:flat] = 0)
		chk("...and its classes were withdrawn from the store", StzEngineGpuCalibGetShaped("pairdist", 1000, 16) = 0)
		chk("...and it ran no hidden check (nothing to check against)", len(aRep[:hidden]) = 0)
	else
		chk("every cell stored its class (ratio readable from the engine)",
			StzEngineGpuCalibGetShaped("pairdist", 1000, 16) > 0 and StzEngineGpuCalibGetShaped("pairdist", 4000, 256) > 0)
		chk("the flat line is either a measured crossover or beyond the ladder (never the old seed)",
			aRep[:flat] > 0 and aRep[:flat] != 256000 and (aRep[:flatwhy] = "crossover" or aRep[:flatwhy] = "beyond-ladder"))
		if aRep[:flatwhy] = "beyond-ladder"
			chk("beyond the ladder means past the largest n*d measured (1,024,000)", aRep[:flat] = 1024001)
		else
			chk("a crossover is one of the grid's n*d values", aRep[:flat] = 16000 or aRep[:flat] = 64000 or aRep[:flat] = 256000 or aRep[:flat] = 1024000)
		ok
		nHid = len(aRep[:hidden])
		for i = 1 to nHid
			h = aRep[:hidden][i]
			? "    hidden d " + h[1] + "  n " + h[2] + "  cpu " + h[3] + " ms  gpu " + h[4] + " ms  ratio " + h[8] + "  predicted " + h[5] + "  measured " + h[6] + "  agree " + h[7] + "  decisive " + h[9]
		next
		chk("TWO hidden shapes were checked (one in a measured class, one in an unmeasured one)", nHid = 2)
		chk("...and both were actually measured (both routes ran)", aRep[:hidden][1][3] > 0 and aRep[:hidden][1][4] > 0 and aRep[:hidden][2][3] > 0)
		# a hidden shape counts against the store only when its measurement is
		# DECISIVE (ratio outside the margin band); a marginal shape agrees or
		# disagrees by noise, and a guard that fails by noise teaches nothing
		chk("the in-class hidden shape agrees with its class's verdict (or is marginal)", aRep[:hidden][1][7] or NOT aRep[:hidden][1][9])
		chk("the off-class hidden shape agrees with the flat fallback (or is marginal)", aRep[:hidden][2][7] or NOT aRep[:hidden][2][9])
		chk("the ladder now holds every cell AND the hidden checks", len(StzGpuCalibrationLadder()) >= 6)
		cFile2 = read(StzGpuCalibFileForAdapter())
		chk("the file was rewritten with the grid's shapes", StzFindFirst("shape" + char(9) + "pairdist" + char(9) + "1000" + char(9) + "16", cFile2) > 0)
	ok
	# put the machine's real calibration back
	if cBakA != ""
		write(StzGpuCalibFileForAdapter(), cBakA)
	else
		if fexists(StzGpuCalibFileForAdapter())
			remove(StzGpuCalibFileForAdapter())
		ok
	ok
	if cBakD != ""
		write(StzGpuCalibFileDefault(), cBakD)
	ok
	chk("the machine's calibration files are back as they were", read(StzGpuCalibFileDefault()) = cBakD)
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

func fabs n
	if n < 0 return -n ok
	return n
