# Softanza Engine -- GPU Plane Lifecycle (G1, SOFTANZA_GPU_PLAN.md)
#
# Loads stz_gpu.dll: device/buffer/kernel handles, WGSL compile-cache,
# bounded VRAM cache, TDR-safe tiling, calibration store, instruments.
#
# The wgpu runtime (wgpu_native.dll) is NOT a load-time dependency: it is
# resolved when StzEngineGpuInit(cPath) is called. On machines without a
# GPU (or without the runtime) every GPU function answers the fallback
# way and gpu.fallback.count increments -- nothing crashes.
#
# Function prefix: StzEngineGpu*
#
# Status codes (returned by buffer/dispatch/sync functions):
#   0 = OK   1 = FALLBACK (no device)   2 = STALE (buffer evicted/freed)
#   3 = BAD_ARG   4 = TOO_LARGE   5 = GPU_ERROR
#
# Counter indices for StzEngineGpuCounter(n):
#   0 dispatch count    1 dispatch ms (total)   2 transfer bytes
#   3 fallback count    4 kernel compiles       5 compile-cache hits
#   6 queue submits     7 evictions             8 live buffers
#   9 device errors
#
# The G2 op library (all ops take BUFFER IDS -- upload once, chain,
# read back once; every op is submit-only except the reductions):
#   StzEngineGpuOpMatmul(hA, hB, hC, m, k, n)        C = A*B, row-major f32
#   StzEngineGpuOpPairDist(hA, hB, hD, m, n, d)      squared L2, rows x rows
#   StzEngineGpuOpAxpby(alpha, hA, beta, hB, hOut, n)
#   StzEngineGpuOpMul(hA, hB, hOut, n)               Hadamard
#   StzEngineGpuOpScaleInPlace(hV, alpha, n)
#   StzEngineGpuOpSoftmax(hIn, hOut, n)              max-shifted, 3 passes
#   StzEngineGpuOpSum(hA, n)  -> [status, value]     f64 fold of partials
#   StzEngineGpuOpDot(hA, hB, n) -> [status, value]
# OUT buffers must be distinct from inputs (WebGPU aliasing validation).
#
# Kernel binding contract (every kernel compiled through this layer):
#   @group(0) @binding(0)  var<uniform> tile : StzTile   -- layer-owned
#       struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }
#       xoff = this tile's x-offset IN WORKGROUPS (TDR tiling); a kernel
#       computes its element index as gid.x + tile.xoff * WORKGROUP_X.
#   @group(0) @binding(1..) = the dispatch call's buffers, in list order.

if isWindows()
    $cStzGpuLib = $cEngineDir + "/zig-out/bin/stz_gpu.dll"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/bin/wgpu_native.dll"
but isLinux()
    $cStzGpuLib = $cEngineDir + "/zig-out/lib/libstz_gpu.so"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/lib/libwgpu_native.so"
but isMacOS()
    $cStzGpuLib = $cEngineDir + "/zig-out/lib/libstz_gpu.dylib"
    $cStzGpuRuntime = $cEngineDir + "/zig-out/lib/libwgpu_native.dylib"
ok

if fexists($cStzGpuLib)
    $pStzGpuHandle = LoadLib($cStzGpuLib)
else
    ? "WARNING: stz_gpu not found at: " + $cStzGpuLib
    $pStzGpuHandle = NULL
ok

# ---- calibration persistence (G5) ------------------------------------
#
# Measured crossovers survive the process in small text files under the
# engine's data/ dir: gpu_calib_default.txt (the last calibrated machine,
# loadable BEFORE any device exists -- cheap prechecks read it) and
# gpu_calib_<adapter>.txt (per-adapter truth, loaded after Init). Format:
# one "op<TAB>threshold" per line. Faces call the two Load functions at
# their natural moments; both are idempotent.

$bStzGpuCalibDefaultLoaded_ = FALSE
$bStzGpuCalibAdapterLoaded_ = FALSE

func StzGpuCalibFileDefault()
	return $cEngineDir + "/data/gpu_calib_default.txt"

func StzGpuCalibFileForAdapter()
	if StzEngineGpuIsAvailable() = 0
		return ""
	ok
	_cName_ = StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
	_cSafe_ = ""
	_nL_ = len(_cName_)
	for _i_ = 1 to _nL_
		_c_ = substr(_cName_, _i_, 1)
		if isalnum(_c_)
			_cSafe_ += _c_
		else
			_cSafe_ += "_"
		ok
	next
	return $cEngineDir + "/data/gpu_calib_" + _cSafe_ + ".txt"

# loadable WITHOUT a device -- the pre-Init precheck's file.
# FILL-ONLY: a persisted value never overrides one set in THIS process
# (an explicit CalibSet -- a guard's, a tuner's -- outranks the disk).
func StzGpuLoadCalibrationDefault()
	if $bStzGpuCalibDefaultLoaded_
		return
	ok
	$bStzGpuCalibDefaultLoaded_ = TRUE
	_StzGpuCalibFillFromFile(StzGpuCalibFileDefault())

# per-adapter truth; call after a successful Init (idempotent, FILL-ONLY)
func StzGpuLoadCalibrationForAdapter()
	if $bStzGpuCalibAdapterLoaded_
		return
	ok
	_cCalF_ = StzGpuCalibFileForAdapter()
	if _cCalF_ = ""
		return
	ok
	$bStzGpuCalibAdapterLoaded_ = TRUE
	_StzGpuCalibFillFromFile(_cCalF_)

# fill-only: set an op's threshold from the file ONLY where none is set yet
func _StzGpuCalibFillFromFile pcPath
	if NOT fexists(pcPath)
		return
	ok
	_aLines_ = str2list(read(pcPath))
	_nL_ = len(_aLines_)
	for _i_ = 1 to _nL_
		_aParts_ = split(_aLines_[_i_], char(9))
		if len(_aParts_) = 2
			if StzEngineGpuCalibGet(_aParts_[1]) = 0
				StzEngineGpuCalibSet(_aParts_[1], 0 + _aParts_[2])
			ok
		ok
	next

# raw overwrite (the calibration round-trip's own tool; faces use the
# fill-only loaders above)
func _StzGpuCalibLoadFile pcPath
	if NOT fexists(pcPath)
		return
	ok
	_aLines_ = str2list(read(pcPath))
	_nL_ = len(_aLines_)
	for _i_ = 1 to _nL_
		_aParts_ = split(_aLines_[_i_], char(9))
		if len(_aParts_) = 2
			StzEngineGpuCalibSet(_aParts_[1], 0 + _aParts_[2])
		ok
	next

# persist the given ops' current thresholds (default + per-adapter files)
func StzGpuSaveCalibration paOps
	_cOut_ = ""
	_nL_ = len(paOps)
	for _i_ = 1 to _nL_
		_nT_ = StzEngineGpuCalibGet(paOps[_i_])
		if _nT_ > 0
			_cOut_ += paOps[_i_] + char(9) + _nT_ + char(10)
		ok
	next
	if _cOut_ = ""
		return FALSE
	ok
	write(StzGpuCalibFileDefault(), _cOut_)
	_cCalF_ = StzGpuCalibFileForAdapter()
	if _cCalF_ != ""
		write(_cCalF_, _cOut_)
	ok
	return TRUE
