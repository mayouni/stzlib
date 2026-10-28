# GC0 -- the foundry's matrix product on the same shapes gc0_cublas.py times.
#
# For each shape the foundry runs every real variant (tile16, tile8, reg2,
# reg4) under the checker -- a visible and a hidden shape against the generic
# kernel, warm, best of the repetitions, on the GPU clock where the adapter
# has timestamps -- and prints each variant's time and GFLOP/s, and the best.
# A variant the checker refuses prints as refused and never counts.
#
# Run with Ring++, from this folder: rnxc gc0_ours.ring
# Optional: an output file for the table, as the first line of gc0_ours.out.txt.

load "../../../stzBase.ring"

decimals(4)
aShapes = [ [ 130, 384, 384 ], [ 130, 384, 1536 ], [ 130, 1536, 384 ],
	[ 256, 256, 256 ], [ 512, 512, 512 ], [ 1024, 1024, 1024 ], [ 2048, 2048, 2048 ], [ 4096, 4096, 4096 ] ]
aNames = [ "tile16", "tile8", "reg2", "reg4" ]
oG = new stzGpu
if NOT oG.IsAvailable()
	? "no device"
	shutdown(1)
ok
? "adapter: " + oG.DeviceName()
cOut = ""
nS = len(aShapes)
for q = 1 to nS
	m = aShapes[q][1]
	k = aShapes[q][2]
	n = aShapes[q][3]
	nSt = StzEngineGpuFoundryMatmul(m, k, n, 7, 0)
	if nSt != 0
		? "" + m + " x " + k + " x " + n + ": the foundry refused to run (" + nSt + ")"
		loop
	ok
	nFlops = 2 * m * k * n
	nClocks = StzEngineGpuFoundryResult(5)
	nBest = StzEngineGpuFoundryResult(1)
	cBest = "tile16"
	cLine = "" + m + " x " + k + " x " + n + "  clocks " + nClocks + "  tile16 " + StzEngineGpuFoundryResult(1) + " ms"
	for v = 1 to 3
		nBase = 10 + v * 5
		nV = StzEngineGpuFoundryResult(nBase)
		if nV = 1
			nMs = StzEngineGpuFoundryResult(nBase + 1)
			if nClocks < 2
				nMs = StzEngineGpuFoundryResult(nBase + 2)
			ok
			cLine += "  " + aNames[v + 1] + " " + nMs + " ms (wall " + StzEngineGpuFoundryResult(nBase + 2) + ")"
			if nMs > 0 and nMs < nBest
				nBest = nMs
				cBest = aNames[v + 1]
			ok
		but nV = 0
			cLine += "  " + aNames[v + 1] + " refused"
		else
			cLine += "  " + aNames[v + 1] + " not eligible"
		ok
	next
	cLine += "  || best " + cBest + " " + nBest + " ms, " + (nFlops / nBest / 1000000) + " GFLOP/s"
	? cLine
	cOut += "" + m + " " + k + " " + n + " " + cBest + " " + nBest + char(10)
next
write("gc0_ours.out.txt", cOut)
