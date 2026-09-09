# GS4 LADDER PROBE -- the measurement behind the semantic index's seam
# (SOFTANZA_GPU_PLAN.md, GS4). Runs stzGpu.CalibrateKnnResident(): both
# routes through the REAL stzSemanticIndex on synthetic unit vectors (no
# model needed), search-by-vector so the query embedding is excluded,
# warm-min of 5, the device woken before every GPU timing, the first rung
# re-measured last as the control; the shaped classes and the flat line
# are PERSISTED unless the control moved.
#
# Measured 2026-09-09, RTX 3050 laptop, 384 dims, device awake:
#   n  1,000  CPU 0.124 ms  GPU 0.320 ms  0.39x
#   n  4,000  CPU 0.677 ms  GPU 0.692 ms  0.98x
#   n 16,000  CPU 3.128 ms  GPU 2.210 ms  1.42x   <- the one class that wins
#   n 32,000  CPU 6.303 ms  GPU 5.883 ms  1.07x   (under the 1.3 margin)
# The window is ONE class wide on this card, and the reason is measured:
# the pairdist kernel is a 16x16 tile written for m x n, and a single
# query (m = 1) uses 1 of its 16 rows -- GK2's first variant target.

load "../../stzBase.ring"

pr()

decimals(3)

oG = new stzGpu
if NOT oG.IsAvailable()
	? "  NO GPU -- nothing to ladder"
else
	? "  device: " + oG.DeviceName()
	aRep = oG.CalibrateKnnResident()
	nCells = len(aRep[:cells])
	for i = 1 to nCells
		c = aRep[:cells][i]
		? "  n " + c[2] + " x " + c[1] + "  (n*d " + (c[1] * c[2]) + ")   CPU top-k " + c[3] + " ms   GPU seam " + c[4] + " ms   cpu/gpu " + c[5]
	next
	? "  flat line: " + aRep[:flat] + "  (" + aRep[:flatwhy] + ")   confounded " + aRep[:confounded]
	aC = aRep[:control]
	if len(aC) = 8
		? "  control: cpu x" + aC[7] + "  gpu x" + aC[8]
	ok
ok

pf()
