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
#
# ---- GR1 render lifecycle (SOFTANZA_GRAPHICS_PLAN.md) ----------------
#
# Counter indices added by GR1:
#   10 render-pipeline compiles   11 render-pipeline cache hits
#   12 draw calls                 13 live textures/targets
#
# Textures and offscreen targets join the SAME discipline: gen-keyed ids
# (their own namespace, like kernels vs buffers), the same VRAM budget,
# FIFO eviction ACROSS buffers and textures, counted fallback. RGBA8 only.
#   StzEngineGpuTextureNew(w, h, kind) -> id (0 = refusal)
#       kind: 0 = render TARGET, 1 = sampled NEAREST, 2 = sampled LINEAR
#   StzEngineGpuTextureFree(id) / TextureWidth(id) / TextureHeight(id)
#   StzEngineGpuTextureWrite(id, cRgbaBytes)   -- sampled kinds; len = w*h*4
#
# Render pipelines compile WGSL with entry points `vmain` + `fmain`,
# cached by (text, vertex format, blend) -- 1 compile + N hits, counted.
#   StzEngineGpuRenderPipeline(cWgsl, cFmt, bBlend) -> id (0 = refusal)
#       cFmt: comma-separated float32 component counts per attribute in
#       location order -- "2,4" = vec2 pos @location(0) + vec4 color
#       @location(1). bBlend: 0 opaque, 1 standard alpha.
#       A TEXTURED pipeline declares @group(0) @binding(0)
#       texture_2d<f32> + @binding(1) sampler and its draws pass a
#       sampled-texture id; an untextured one passes 0.
#
# The pass: Begin opens ONE encoder on a TARGET, draws encode into it,
# End submits ONCE (asynchronous, like Dispatch; a read or Sync
# completes). Vertex/index data lives in ORDINARY lifecycle buffers
# (BufferNew/UploadList) -- any buffer can feed a draw, and a compute
# kernel can write vertices a render pass consumes (the GR0 witness).
#   StzEngineGpuBufferUploadListU32(id, aNumbers)  -- index data (u32 LE)
#   StzEngineGpuRenderBegin(hTarget, r, g, b, a)   -- clear color 0..1
#   StzEngineGpuRenderDraw(hPipe, hVbuf, nFirst, nVerts, hTexOr0)
#   StzEngineGpuRenderDrawIndexed(hPipe, hVbuf, hIbuf, nIndices, hTexOr0)
#   StzEngineGpuRenderEnd() / StzEngineGpuRenderActive()
#   StzEngineGpuTargetRead(hTarget) -> tight RGBA8 bytes ("" = refusal;
#       the 256-byte row padding is handled and stripped engine-side)
#
# Codecs (CPU-side, work without a device):
#   StzEngineGpuPngEncode(w, h, cRgbaBytes, nLevel) -> PNG bytes
#       nLevel 1..9; anything else takes the measured default z1
#       (GR0: z1 = same pixels at half the cost of z6; z6 = archival)
#   StzEngineGpuImageDecode(cBytes) -> [w, h, cRgbaBytes] or []
#       (stb_image: PNG/JPG/BMP/GIF/TGA/PSD, always RGBA8 out)
#   StzEngineGpuImageGrid(cTiles, nTileW, nTileH, nCount, nCols, nGutter,
#       nBgR, nBgG, nBgB) -> [w, h, cRgbaBytes] or []
#       Equal-sized RGBA tiles, CONCATENATED, laid out as a contact sheet.
#       A short tile buffer refuses rather than tearing. Engine-side because
#       nine 420x420 tiles is 6.3 MB of blit.
#
# ---- GR2 text pipeline (CPU-side: fonts and layout need NO device) ---
#
# THE pipeline: SheenBidi reorders (UAX#9 visual runs), HarfBuzz shapes
# (joining, mandatory ligatures, GSUB/GPOS -- codepoints in, GLYPH IDS
# out), stb_truetype rasters BY GLYPH ID. One engine entry serves every
# renderer, so GPU and SVG output cannot disagree about where letters
# sit. Per-codepoint Arabic is WRONG, not degraded -- never bypass this.
#
#   StzEngineGpuFontLoad(cFontBytes) -> id (0 = refusal; TTF/OTF memory)
#   StzEngineGpuFontFree(id) / StzEngineGpuFontGlyphCount(id)
#   StzEngineGpuTextLayout(hFont, cUtf8, nSizePx)
#       -> [nWidthPx, nRunCount, [ [gid, x, y, byteCluster], ... ]]
#       or [] on refusal. Glyphs in VISUAL left-to-right order; first
#       paragraph only (single-line contract); baseline y=0, y positive
#       up (HarfBuzz convention); 1/64 px precision.
#   StzEngineGpuGlyphBitmap(hFont, nGlyphId, nSizePx)
#       -> [w, h, xoff, yoff, cGrayBytes] ([0,0,0,0,""] = ink-free glyph,
#       a valid answer). Same em->px scale contract as TextLayout.
#
# ---- GR2b display list: ONE model, TWO renderers ---------------------
#
# A scene is a painter-ordered list of shapes and text in PIXEL space
# (y DOWN, like SVG and like a screen). From that ONE list:
#   ToSvg  -> vector text. No device. The CI-safe floor, always works.
#   ToPng  -> tessellate, draw in ONE pass through the GR1 surface, read
#             back, encode. "" when there is no device -- and the refusal
#             is COUNTED (gpu.fallback.count), so a face can drop to the
#             SVG tier knowing why.
# Neither backend owns the geometry -- the display list does -- so they
# cannot disagree about WHERE anything sits. Text goes through the GR2a
# pipeline on BOTH sides: Arabic is correct on both or broken on both.
#
# Colors are PACKED 0xRRGGBBAA numbers (exact in Ring's f64). Point
# lists are FLAT: [x0,y0, x1,y1, ...].
#
#   StzEngineGpuSceneNew(w, h) -> id (0 = refusal) / SceneFree(id)
#   StzEngineGpuSceneClear(id, nRGBA)
#   StzEngineGpuSceneRect(id, x, y, w, h, nRGBA)
#   StzEngineGpuSceneRectGradient(id, x, y, w, h, nRGBA0, nRGBA1, bVertical)
#   StzEngineGpuSceneCircle(id, cx, cy, r, nRGBA)
#   StzEngineGpuSceneLine(id, x1, y1, x2, y2, nWidth, nRGBA)
#   StzEngineGpuScenePolyline(id, aFlatPts, nWidth, nRGBA)
#   StzEngineGpuScenePolygon(id, aFlatPts, nRGBA)   -- simple polygons
#   StzEngineGpuSceneText(id, hFont, cUtf8, x, y, nSizePx, nRGBA)
#       (x,y) is the BASELINE origin, as the text pipeline reports it
#   StzEngineGpuSceneToSvg(id) -> SVG text
#   StzEngineGpuSceneToPng(id, nLevel) -> PNG bytes
#   StzEngineGpuSceneToPixels(id) -> raw RGBA8 of the GPU tier
#   StzEngineGpuSceneCommandCount(id)
#   StzEngineGpuSceneStats(id)
#       -> [commands, shapeVerts, textVerts, drawSegments, builds]
#       `builds` is the RETAINED-BUFFER witness: it increments only when
#       the display list actually changed (a still redraws for free; a
#       future frame loop must not re-upload static geometry 60x/s).
#   StzEngineGpuCircleSegments(nRadius) -> the tessellation count chosen
#       BY THE ERROR BOUND: chord sagitta <= 0.15 px at any radius. SVG
#       emits a true <circle>, so this bound IS the honest parity band
#       between the two backends for curves.
#   StzEngineGpuAtlasStats() -> [w, h, entries, uploads]
#   StzEngineGpuAtlasReset()
#       The atlas is a TEXTURE atlas, not a font atlas -- glyphs are its
#       first tenant; sprites are the same shape.
#
# ---- GR3: meshes and the 3D scene ------------------------------------
#
# Meshes are CPU-side, gen-keyed, and describe themselves. The vertex
# format is DERIVED from the mesh's attribute list ("3,3,2" = position,
# normal, uv), so extending a mesh extends its pipeline -- adding skin
# weights later is a new attribute, NOT a change to the render contract.
# Winding is CCW for front faces (back-face culling is on for 3D).
#   StzEngineGpuMeshCube(nSize) / MeshSphere(nR, nSegs, nRings)
#   StzEngineGpuMeshPlane(nSize) / MeshFree(id)
#   StzEngineGpuMeshFromObj(cObjText) -- v/vt/vn/f, faces fanned,
#       vertices deduped by their (v,vt,vn) TRIPLE (two faces sharing a
#       position but not a normal are two vertices -- merging them is how
#       a hard edge goes soft); negative indices resolve; a file with no
#       normals gets generated ones rather than black geometry
#   StzEngineGpuMeshCustom(aComps, aVerts, aIndices) -- any layout
#   StzEngineGpuMeshStats(id)
#       -> [vertices, indices, attributes, strideFloats, cFormat]
#
# A 3D scene is a camera, a directional light and INSTANCES. An
# instance's TRANSFORM lives apart from its mesh and material: moving
# one re-uploads matrices and never touches geometry, which is what lets
# a simulation drive a scene without knowing what rendering is.
# All instances of one mesh draw in a SINGLE instanced call.
#   StzEngineGpuScene3dNew(w, h) / Scene3dFree(id)
#   StzEngineGpuScene3dClear(id, nRGBA)
#   StzEngineGpuScene3dCamera(id, ex,ey,ez, tx,ty,tz, nFovDeg, nNear, nFar)
#   StzEngineGpuScene3dLight(id, dx,dy,dz, nRGB, nAmbientRGB)
#   StzEngineGpuScene3dAdd(id, hMesh, px,py,pz, ax,ay,az, nAngleDeg,
#                          sx,sy,sz, nRGBA) -> instance index (0 = refusal)
#   StzEngineGpuScene3dSetTransform(id, nIndex, px,py,pz, ax,ay,az,
#                                   nAngleDeg, sx,sy,sz)
#   StzEngineGpuScene3dSetColor(id, nIndex, nRGBA)
#   StzEngineGpuScene3dStats(id)
#       -> [instances, meshesResident, drawCalls, geometryUploads,
#           transformUploads]
#       geometryUploads vs transformUploads is the separation witness.
#   StzEngineGpuScene3dToPixels(id) / Scene3dToPng(id, nLevel)
#
# Scope, per the plan: NO shadows, NO PBR, NO skeletal animation --
# each is a later, workload-justified increment.
#
# Depth buffers join the texture table as kind 3 (TEX_DEPTH,
# Depth32Float): never sampled, never read back; they exist so the GPU
# can decide what is in front.
#
# ---- GR5: presentation (a picture WATCHED, not saved) ----------------
#
# Every tier above ends in a READBACK: render offscreen, drag the pixels
# home, encode. That is right for a file and wrong for a window, where the
# readback is the most expensive thing in the frame. Here the swapchain's
# own texture is ADOPTED into the texture table as an ordinary render
# TARGET -- so the pass machine, the 2D scene and the 3D scene all draw to
# a window through the code that already existed, and the picture never
# crosses the bus. Measured: 120 frames of a 700x420 scene moved 6,696
# bytes total (all of it the first frame's vertices) against 141,120,000
# bytes for the same frames through ToPng.
#
# The window itself lives in stz_window.dll (see engine/stz_window.ring) --
# GLFW cannot cross-compile, and linking it here would have cost the GPU
# plane its portability. Only the native HANDLE crosses, which is an OS
# handle, not a gen-keyed engine handle.
#
#   StzEngineGpuSurfaceNew(nHandle, nDisplay, w, h) -> id (0 = refusal)
#       nHandle: HWND / X11 Window / NSWindow, from StzEngineWindowNativeHandle
#       nDisplay: X11 Display*; 0 elsewhere
#   StzEngineGpuSurfaceFree(id)
#   StzEngineGpuSurfaceResize(id, w, h)      -- idempotent; reconfigures
#   StzEngineGpuSurfaceSetPresentMode(id, n) -- 0 fifo (vsync), 1 immediate,
#       2 mailbox. An unsupported mode is REFUSED rather than silently
#       downgraded: a caller turning vsync off to MEASURE frame cost must
#       be told when it did not get what it asked for.
#   StzEngineGpuSurfaceAcquire(id) -> a TARGET id for this frame (0 =
#       refusal, which a frame loop treats as "skip this frame", not as an
#       error -- a minimised window and a display change both look like it)
#   StzEngineGpuSurfacePresent(id)
#       PRESENT THEN RELEASE, in that order. Dropping the frame reference
#       before presenting leaves the swapchain unable to retire the image,
#       and it answers Timeout from the third frame on -- forever.
#   StzEngineGpuSurfaceFormatName(id) -> "rgba8" | "bgra8" | ...
#   StzEngineGpuSurfaceStat(id, n)
#       0 w  1 h  2 framesPresented  3 reconfigures  4 frameHeld
#       5 presentMode  6 lastAcquireStatus
#
#   StzEngineGpuSceneDrawToTarget(hScene, hTarget, nFmt, w, h)
#   StzEngineGpuScene3dDrawToTarget(hScene, hTarget, nFmt, w, h)
#       Draw into a target somebody else owns. nFmt: 0 rgba8, 1 bgra8 --
#       the render-pipeline cache is keyed by target format, because a
#       pipeline compiled for the wrong one is a validation error rather
#       than a wrong colour.
#   StzEngineGpuSceneReset(hScene)
#       Empty the display list, keep the background and the buffers. What
#       an ANIMATED scene calls each frame; without it a frame loop appends
#       shapes forever -- a defect a one-shot renderer cannot expose,
#       because it only ever draws frame 1.
#
# SceneStats gained a sixth field, `vertexUploads`. `builds` counts
# TESSELLATIONS; a still scene that tessellates once could still re-upload
# its whole vertex set every frame, and did, until the window found it.

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
