# The first-error slot -- the CAUSE of a refused kernel, not its symptom
# (SOFTANZA_GPU_PLAN.md: named by GS6b, which lost three rebuilds to it).
#
# A shader that fails validation raises two errors in a row: the parser's
# ("name `target` is a reserved keyword", with the line) and then the
# pipeline's ("ShaderModule with 'stz_kernel' label is invalid"). One slot
# kept the second and hid the first. gpu.zig now keeps the FIRST error since
# the last clear beside the last, a kernel compile clears both before it
# starts, and the face's refusal names the cause.
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - a kernel with a reserved word is refused; FirstError names the WORD and
#     its LINE; LastError is the pipeline's symptom; they differ
#   - the same kernel with the word renamed compiles, and both slots are
#     EMPTY afterwards (a compile clears them -- a stale cause never survives
#     a good compile)
#   - ClearErrors() empties both by hand
#   - the face reads the same slots, and its compile refusal names the cause
#   - the stats DLL's device has its OWN slots (its own gpu.zig): a k-means
#     run leaves them empty, and they are not stz_gpu.dll's

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- the slots exist but no driver will ever write them here"
	chk("both slots are empty strings without a device", StzEngineGpuFirstError() = "" and StzEngineGpuLastError() = "")
else
	cBad = '
		struct P { n : u32, target : f32 }
		@group(0) @binding(0) var<uniform> p : P;
		@group(0) @binding(1) var<storage, read_write> a : array<f32>;
		@compute @workgroup_size(64)
		fn main(@builtin(global_invocation_id) id : vec3<u32>) {
			if (id.x < p.n) { a[id.x] = a[id.x] * p.target; }
		}
	'
	cGood = StzReplace(cBad, "target", "tgt")

	? "-- Scene 1: a reserved word refuses the kernel, and the FIRST slot names it --"
	nK = StzEngineGpuKernelCompile(cBad)
	cFirst = StzEngineGpuFirstError()
	cLast = StzEngineGpuLastError()
	? "  compile answered " + nK
	? "  first: " + StzReplace(StzReplace(cFirst, char(10), " | "), char(13), "")
	? "  last:  " + StzReplace(StzReplace(cLast, char(10), " | "), char(13), "")
	chk("the kernel is refused (handle 0)", nK = 0)
	chk("FirstError names the reserved word", has(cFirst, "target") and has(cFirst, "reserved"))
	chk("...and the line it stands on (wgsl:2)", has(cFirst, "wgsl:2"))
	chk("LastError is the pipeline's symptom ('is invalid'), not the cause", has(cLast, "invalid") and NOT has(cLast, "reserved"))
	chk("the two slots differ (one slot could not hold both)", cFirst != cLast)

	? ""
	? "-- Scene 2: the same kernel with the word renamed compiles, and both slots are empty after --"
	nG = StzEngineGpuKernelCompile(cGood)
	chk("the renamed kernel compiles (a handle)", nG > 0)
	chk("a good compile leaves BOTH slots empty (the stale cause did not survive)", StzEngineGpuFirstError() = "" and StzEngineGpuLastError() = "")

	? ""
	? "-- Scene 3: a refusal after a good compile fills the slots again; ClearErrors empties them --"
	StzEngineGpuKernelCompile(cBad)
	chk("the cause is back in the first slot", has(StzEngineGpuFirstError(), "reserved"))
	StzEngineGpuErrorClear()
	chk("ClearErrors() empties both", StzEngineGpuFirstError() = "" and StzEngineGpuLastError() = "")

	? ""
	? "-- Scene 4: the face reads the same slots --"
	StzEngineGpuKernelCompile(cBad)
	oG = new stzGpu
	chk("stzGpu.FirstError() is the cause", has(oG.FirstError(), "reserved") and has(oG.FirstError(), "target"))
	chk("stzGpu.LastError() is the symptom", has(oG.LastError(), "invalid"))
	chk("stzGpu.ClearErrors() empties both, and chains", oG.ClearErrors().FirstError() = "" and oG.LastError() = "")

	? ""
	? "-- Scene 5: the stats DLL's device has its own slots --"
	StzEngineGpuKernelCompile(cBad)
	aRows = []
	for i = 1 to 300
		aRows + [ i % 7, (i * 3) % 11, i % 5 ]
	next
	oKm = new stzKMeans(aRows)
	oKm.SetK(3)
	oKm.Run(20)
	chk("a k-means run on the stats device leaves ITS slots empty", StzEngineStatsGpuFirstError() = "" and StzEngineStatsGpuLastError() = "")
	chk("...while stz_gpu.dll's first slot still holds its own cause (two devices, two memories)", has(StzEngineGpuFirstError(), "reserved"))
	StzEngineGpuErrorClear()
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

# a plain byte search is right for the driver's ASCII text
func has cHay, cNeedle
	return substr(cHay, cNeedle) > 0
