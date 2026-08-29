# The RENDER lifecycle layer -- GR1 of the graphics plane
# (SOFTANZA_GRAPHICS_PLAN.md; rides the G1 lifecycle of the GPU plane).
#
# GR0 proved the vendored render surface needs no lifecycle surgery and
# measured where the budget goes (the PNG encoder, not the pass). GR1 is
# that proof as product: textures/targets in the SAME gen-keyed + VRAM
# discipline, a render-pipeline cache (1 compile + N hits, counted), a
# one-submit pass machine, de-padded readback, and the PNG/image codecs.
#
# This guard asserts the MECHANISMS, each with its negative sibling:
#   - the codecs work WITHOUT a device (encode->decode round-trip is a
#     cross-check of two independent implementations: our zlib chunks
#     out, stb_image's inflate+parser back in)
#   - fallback counts before Init and does NOT count after
#   - texture churn returns live count and VRAM accounting to baseline;
#     freed ids answer STALE by name
#   - the pipeline cache compiles ONCE per (text,fmt,blend); malformed
#     WGSL refuses AND counts a device error
#   - drawn pixels are EXACT (flat colors chosen to round-trip unorm8)
#   - readback de-pads correctly at a width whose row is NOT 256-aligned
#   - a 15-rect batch is BYTE-IDENTICAL to a Ring-computed reference
#     (the GR0 parity claim, now guarded through the product layer)
#   - a COMPUTE kernel writes the vertex buffer a RENDER pass consumes
#     (the composition witness through stz_gpu.dll, not the spike)
#   - eviction under a small budget crosses KINDS (oldest buffer evicted
#     to fit a texture), counted; big budget ⇒ zero evictions
#   - shutdown mid-pass is clean; re-Init restores service
#
# CI note: passes WITHOUT a GPU -- device scenes gate on IsAvailable();
# the fallback + codec scenes ARE the CI coverage.
#
# STANDALONE like gpu_lifecycle_narrated: loads only the engine bridge.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

# counter indices (documented in engine/stz_gpu.ring)
C_BYTES = 2
C_FALL  = 3
C_SUB   = 6
C_EVICT = 7
C_LIVE  = 8
C_ERR   = 9
C_RPC   = 10
C_RPH   = 11
C_DRAW  = 12
C_TLIVE = 13

# status codes
S_OK = 0
S_FALLBACK = 1
S_STALE = 2
S_BADARG = 3

# texture kinds
K_TARGET = 0
K_NEAREST = 1
K_LINEAR = 2

# WGSL: flat/interpolated color pipeline (vmain/fmain, pos2+col4)
cWgslColor = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) col: vec4<f32> }' + char(10) +
    '@vertex' + char(10) +
    'fn vmain(@location(0) pos: vec2<f32>, @location(1) col: vec4<f32>) -> VSOut {' + char(10) +
    '  var o: VSOut;' + char(10) +
    '  o.pos = vec4<f32>(pos, 0.0, 1.0);' + char(10) +
    '  o.col = col;' + char(10) +
    '  return o;' + char(10) +
    '}' + char(10) +
    '@fragment' + char(10) +
    'fn fmain(in: VSOut) -> @location(0) vec4<f32> { return in.col; }'

# WGSL: textured pipeline (pos2+uv2, group0 = texture+sampler)
cWgslTex = 'struct VSOut { @builtin(position) pos: vec4<f32>, @location(0) uv: vec2<f32> }' + char(10) +
    '@vertex' + char(10) +
    'fn vmain(@location(0) pos: vec2<f32>, @location(1) uv: vec2<f32>) -> VSOut {' + char(10) +
    '  var o: VSOut;' + char(10) +
    '  o.pos = vec4<f32>(pos, 0.0, 1.0);' + char(10) +
    '  o.uv = uv;' + char(10) +
    '  return o;' + char(10) +
    '}' + char(10) +
    '@group(0) @binding(0) var tex: texture_2d<f32>;' + char(10) +
    '@group(0) @binding(1) var smp: sampler;' + char(10) +
    '@fragment' + char(10) +
    'fn fmain(in: VSOut) -> @location(0) vec4<f32> { return textureSample(tex, smp, in.uv); }'

? "-- Scene 1: the codecs live CPU-side -- no device, real bytes --"
StzEngineGpuCountersReset()
# a 3x2 image with exact byte values, encoded then decoded back
cSrc = ""
for _i_ = 0 to 23
    cSrc += char((_i_ * 37) % 251)
next
cPng = StzEngineGpuPngEncode(3, 2, cSrc, 1)
chk("PNG bytes came back", len(cPng) > 8)
chk("PNG signature is real", ascii(substr(cPng, 1, 1)) = 137 and substr(cPng, 2, 3) = "PNG")
aImg = StzEngineGpuImageDecode(cPng)
chk("decode returns [w, h, bytes]", len(aImg) = 3)
if len(aImg) = 3
    chk("width survives the round-trip", aImg[1] = 3)
    chk("height survives the round-trip", aImg[2] = 2)
    chk("pixels are BYTE-IDENTICAL through encode->decode", aImg[3] = cSrc)
ok
chk("z6 also answers (opt-in knob), same pixels",
    StzEngineGpuImageDecode(StzEngineGpuPngEncode(3, 2, cSrc, 6))[3] = cSrc)

? ""
? "-- Scene 2: before Init, render asks refuse and are COUNTED --"
chk("not available before Init", StzEngineGpuIsAvailable() = 0)
nF0 = StzEngineGpuCounter(C_FALL)
chk("texture creation refuses (id 0)", StzEngineGpuTextureNew(64, 64, K_TARGET) = 0)
chk("RenderBegin refuses with FALLBACK", StzEngineGpuRenderBegin(1, 0, 0, 0, 1) = S_FALLBACK)
chk("pipeline compile refuses (id 0)", StzEngineGpuRenderPipeline(cWgslColor, "2,4", 0) = 0)
chk("every refusal was counted", StzEngineGpuCounter(C_FALL) >= nF0 + 3)

? ""
? "-- Scene 3: Init against the vendored runtime --"
nInit = StzEngineGpuInit($cStzGpuRuntime)
? "  Init(" + $cStzGpuRuntime + ") = " + nInit
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- device scenes skipped, scenes 1-2 ARE the coverage"
else
    StzEngineGpuCountersReset()

    ? ""
    ? "-- Scene 4: texture churn is exact, staleness answers by name --"
    nLive0 = StzEngineGpuCounter(C_TLIVE)
    nVram0 = StzEngineGpuVramInUse()
    aTex = []
    for _i_ = 1 to 20
        aTex + StzEngineGpuTextureNew(32, 32, K_TARGET)
    next
    chk("20 targets live", StzEngineGpuCounter(C_TLIVE) = nLive0 + 20)
    chk("VRAM accounts 20*32*32*4", StzEngineGpuVramInUse() = nVram0 + 20*32*32*4)
    chk("width reads back", StzEngineGpuTextureWidth(aTex[1]) = 32)
    for _i_ = 1 to 20
        StzEngineGpuTextureFree(aTex[_i_])
    next
    chk("live count returns to baseline", StzEngineGpuCounter(C_TLIVE) = nLive0)
    chk("VRAM accounting returns to baseline", StzEngineGpuVramInUse() = nVram0)
    chk("freed id answers STALE on free", StzEngineGpuTextureFree(aTex[1]) = S_STALE)
    chk("freed id answers -1 on width", StzEngineGpuTextureWidth(aTex[1]) = -1)

    ? ""
    ? "-- Scene 5: the render-pipeline cache compiles ONCE per key --"
    nP1 = StzEngineGpuRenderPipeline(cWgslColor, "2,4", 0)
    chk("color pipeline compiled (id > 0)", nP1 > 0)
    nP2 = StzEngineGpuRenderPipeline(cWgslColor, "2,4", 0)
    chk("same key returns the SAME id", nP2 = nP1)
    chk("exactly 1 real compile", StzEngineGpuCounter(C_RPC) = 1)
    chk("and 1 cache hit", StzEngineGpuCounter(C_RPH) = 1)
    nErr0 = StzEngineGpuCounter(C_ERR)
    chk("malformed WGSL refuses (id 0)", StzEngineGpuRenderPipeline("@fragment fn broken(", "2,4", 0) = 0)
    chk("and the device error was counted", StzEngineGpuCounter(C_ERR) > nErr0)
    chk("malformed FORMAT refuses (id 0)", StzEngineGpuRenderPipeline(cWgslColor, "9,x", 0) = 0)

    ? ""
    ? "-- Scene 6: a flat triangle lands EXACT pixels on a target --"
    nW = 64  nH = 48
    hT = StzEngineGpuTextureNew(nW, nH, K_TARGET)
    chk("target created", hT > 0)
    # flat color (240,200,40) -- k/255 values round-trip unorm8 exactly
    aV = []
    aV + [-0.8, -0.8]  aV + [240/255.0, 200/255.0, 40/255.0, 1]
    aV + [ 0.0,  0.9]  aV + [240/255.0, 200/255.0, 40/255.0, 1]
    aV + [ 0.8, -0.8]  aV + [240/255.0, 200/255.0, 40/255.0, 1]
    aFlat = []
    _aRow2_ = aV
    _nRow2_ = len(_aRow2_)
    for _iRow2_ = 1 to _nRow2_
    	_row_ = _aRow2_[_iRow2_]
        _aV3_ = _row_
        _nV3_ = len(_aV3_)
        for _iV3_ = 1 to _nV3_
        	_v_ = _aV3_[_iV3_]
            aFlat + _v_
        next
    next
    hV = StzEngineGpuBufferNew(len(aFlat) * 4)
    chk("vertex buffer created", hV > 0)
    chk("vertex upload OK", StzEngineGpuBufferUploadList(hV, aFlat) = S_OK)
    nDraw0 = StzEngineGpuCounter(C_DRAW)
    nSub0 = StzEngineGpuCounter(C_SUB)
    chk("Begin opens the pass", StzEngineGpuRenderBegin(hT, 16/255.0, 20/255.0, 24/255.0, 1) = S_OK)
    chk("pass reports active", StzEngineGpuRenderActive() = 1)
    chk("draw encodes", StzEngineGpuRenderDraw(nP1, hV, 0, 3, 0) = S_OK)
    chk("End submits", StzEngineGpuRenderEnd() = S_OK)
    chk("pass no longer active", StzEngineGpuRenderActive() = 0)
    chk("ONE submit for the whole pass", StzEngineGpuCounter(C_SUB) = nSub0 + 1)
    chk("draw was counted", StzEngineGpuCounter(C_DRAW) = nDraw0 + 1)
    cFrame = StzEngineGpuTargetRead(hT)
    chk("readback returns w*h*4 bytes", len(cFrame) = nW * nH * 4)
    chk("corner pixel = clear color EXACT", pxeq(cFrame, nW, 2, 2, 16, 20, 24))
    chk("triangle center = flat color EXACT", pxeq(cFrame, nW, nW/2, nH/2, 240, 200, 40))

    ? ""
    ? "-- Scene 7: PNG round-trip on REAL rendered pixels --"
    cP = StzEngineGpuPngEncode(nW, nH, cFrame, 1)
    aBack = StzEngineGpuImageDecode(cP)
    chk("decode gives the frame back byte-identical", len(aBack) = 3 and aBack[3] = cFrame)

    ? ""
    ? "-- Scene 8: textured quad samples EXACT texels (nearest) --"
    # 2x2 checker: (200,60,60) and (240,240,240)
    hCk = StzEngineGpuTextureNew(2, 2, K_NEAREST)
    cCk = char(200)+char(60)+char(60)+char(255) + char(240)+char(240)+char(240)+char(255) +
          char(240)+char(240)+char(240)+char(255) + char(200)+char(60)+char(60)+char(255)
    chk("checker upload OK", StzEngineGpuTextureWrite(hCk, cCk) = S_OK)
    chk("upload to a TARGET refuses BAD_ARG", StzEngineGpuTextureWrite(hT, cCk) = S_BADARG)
    nPT = StzEngineGpuRenderPipeline(cWgslTex, "2,2", 0)
    chk("textured pipeline compiled", nPT > 0)
    # full-screen quad, uv 0..1 (v: 0 at top of target)
    aQ = []
    aQ + [-1.0, -1.0]  aQ + [0.0, 1.0]
    aQ + [ 1.0, -1.0]  aQ + [1.0, 1.0]
    aQ + [ 1.0,  1.0]  aQ + [1.0, 0.0]
    aQ + [-1.0, -1.0]  aQ + [0.0, 1.0]
    aQ + [ 1.0,  1.0]  aQ + [1.0, 0.0]
    aQ + [-1.0,  1.0]  aQ + [0.0, 0.0]
    aQF = []
    _aRow4_ = aQ
    _nRow4_ = len(_aRow4_)
    for _iRow4_ = 1 to _nRow4_
    	_row_ = _aRow4_[_iRow4_]
        _aV5_ = _row_
        _nV5_ = len(_aV5_)
        for _iV5_ = 1 to _nV5_
        	_v_ = _aV5_[_iV5_]
            aQF + _v_
        next
    next
    hVQ = StzEngineGpuBufferNew(len(aQF) * 4)
    StzEngineGpuBufferUploadList(hVQ, aQF)
    StzEngineGpuRenderBegin(hT, 0, 0, 0, 1)
    chk("textured draw encodes", StzEngineGpuRenderDraw(nPT, hVQ, 0, 6, hCk) = S_OK)
    StzEngineGpuRenderEnd()
    cTex = StzEngineGpuTargetRead(hT)
    # quadrant centers: TL texel (0,0)=A, TR=(1,0)=B, BL=(0,1)=B, BR=(1,1)=A
    chk("top-left quadrant = checker A", pxeq(cTex, nW, nW/4, nH/4, 200, 60, 60))
    chk("top-right quadrant = checker B", pxeq(cTex, nW, 3*nW/4, nH/4, 240, 240, 240))
    chk("bottom-left quadrant = checker B", pxeq(cTex, nW, nW/4, 3*nH/4, 240, 240, 240))
    chk("bottom-right quadrant = checker A", pxeq(cTex, nW, 3*nW/4, 3*nH/4, 200, 60, 60))

    ? ""
    ? "-- Scene 9: indexed draw reaches the same pixels --"
    # same full-screen quad as 4 unique verts + 6 u32 indices
    aQI = []
    aQI + [-1.0, -1.0]  aQI + [0.0, 1.0]
    aQI + [ 1.0, -1.0]  aQI + [1.0, 1.0]
    aQI + [ 1.0,  1.0]  aQI + [1.0, 0.0]
    aQI + [-1.0,  1.0]  aQI + [0.0, 0.0]
    aQIF = []
    _aRow6_ = aQI
    _nRow6_ = len(_aRow6_)
    for _iRow6_ = 1 to _nRow6_
    	_row_ = _aRow6_[_iRow6_]
        _aV7_ = _row_
        _nV7_ = len(_aV7_)
        for _iV7_ = 1 to _nV7_
        	_v_ = _aV7_[_iV7_]
            aQIF + _v_
        next
    next
    hVI = StzEngineGpuBufferNew(len(aQIF) * 4)
    StzEngineGpuBufferUploadList(hVI, aQIF)
    hIdx = StzEngineGpuBufferNew(6 * 4)
    chk("index upload OK", StzEngineGpuBufferUploadListU32(hIdx, [0, 1, 2, 0, 2, 3]) = S_OK)
    StzEngineGpuRenderBegin(hT, 0, 0, 0, 1)
    chk("indexed draw encodes", StzEngineGpuRenderDrawIndexed(nPT, hVI, hIdx, 6, hCk) = S_OK)
    StzEngineGpuRenderEnd()
    cIdxFrame = StzEngineGpuTargetRead(hT)
    chk("indexed result matches the non-indexed frame byte-for-byte", cIdxFrame = cTex)

    ? ""
    ? "-- Scene 10: readback de-pads at a NON-256-aligned width --"
    # 63*4 = 252 bytes/row: the padded staging row is 256 -- a de-pad bug
    # would shear every row after the first
    hT63 = StzEngineGpuTextureNew(63, 5, K_TARGET)
    StzEngineGpuRenderBegin(hT63, 90/255.0, 140/255.0, 210/255.0, 1)
    StzEngineGpuRenderEnd()
    c63 = StzEngineGpuTargetRead(hT63)
    chk("tight length 63*5*4", len(c63) = 63*5*4)
    bRows = TRUE
    for _y_ = 0 to 4
        if NOT (pxeq(c63, 63, 0, _y_, 90, 140, 210) and pxeq(c63, 63, 62, _y_, 90, 140, 210))
            bRows = FALSE
        ok
    next
    chk("first AND last pixel of EVERY row carry the clear color", bRows)
    StzEngineGpuTextureFree(hT63)

    ? ""
    ? "-- Scene 11: 15-rect batch is BYTE-IDENTICAL to the Ring-computed reference --"
    nBW = 40  nBH = 30
    hTB = StzEngineGpuTextureNew(nBW, nBH, K_TARGET)
    # palette (exact u8 triples), rect = [x, y, w, h, palette index]
    aPal = [ [220,60,60], [60,180,90], [70,110,230], [235,200,60] ]
    aRects = [ [2,2,10,8,1], [8,5,12,10,2], [15,1,9,20,3], [0,20,18,8,4], [25,3,12,12,1],
               [30,15,9,9,2], [5,12,20,6,3], [22,22,14,7,4], [1,8,6,15,2], [33,0,7,26,1],
               [12,18,10,10,4], [18,9,8,8,1], [27,20,11,8,3], [3,25,30,4,2], [20,14,15,5,1] ]
    # GPU: 6 verts per rect, integer pixel corners -> NDC, painter order
    aBV = []
    _aR8_ = aRects
    _nR8_ = len(_aR8_)
    for _iR8_ = 1 to _nR8_
    	_r_ = _aR8_[_iR8_]
        _x0_ = _r_[1] / nBW * 2 - 1
        _x1_ = (_r_[1] + _r_[3]) / nBW * 2 - 1
        _y0_ = 1 - _r_[2] / nBH * 2
        _y1_ = 1 - (_r_[2] + _r_[4]) / nBH * 2
        _aC_ = aPal[_r_[5]]
        _aP_ = [ [_x0_,_y0_], [_x1_,_y0_], [_x1_,_y1_], [_x0_,_y0_], [_x1_,_y1_], [_x0_,_y1_] ]
        _aP9_ = _aP_
        _nP9_ = len(_aP9_)
        for _iP9_ = 1 to _nP9_
        	_p_ = _aP9_[_iP9_]
            aBV + _p_[1]  aBV + _p_[2]
            aBV + (_aC_[1]/255.0)  aBV + (_aC_[2]/255.0)  aBV + (_aC_[3]/255.0)  aBV + 1
        next
    next
    hVB = StzEngineGpuBufferNew(len(aBV) * 4)
    StzEngineGpuBufferUploadList(hVB, aBV)
    StzEngineGpuRenderBegin(hTB, 16/255.0, 20/255.0, 24/255.0, 1)
    StzEngineGpuRenderDraw(nP1, hVB, 0, len(aRects) * 6, 0)
    StzEngineGpuRenderEnd()
    cBatch = StzEngineGpuTargetRead(hTB)
    # Ring reference: same painter order, per-pixel palette index
    aRef = list(nBW * nBH)
    for _i_ = 1 to nBW * nBH
        aRef[_i_] = 0
    next
    _aR10_ = aRects
    _nR10_ = len(_aR10_)
    for _iR10_ = 1 to _nR10_
    	_r_ = _aR10_[_iR10_]
        for _dy_ = 0 to _r_[4] - 1
            _nRow_ = (_r_[2] + _dy_) * nBW
            for _dx_ = 0 to _r_[3] - 1
                aRef[_nRow_ + _r_[1] + _dx_ + 1] = _r_[5]
            next
        next
    next
    nMismatch = 0
    for _i_ = 0 to nBW * nBH - 1
        _nIdx_ = aRef[_i_ + 1]
        if _nIdx_ = 0
            _aC_ = [16, 20, 24]
        else
            _aC_ = aPal[_nIdx_]
        ok
        _nOff_ = _i_ * 4
        if ascii(substr(cBatch, _nOff_+1, 1)) != _aC_[1] or
           ascii(substr(cBatch, _nOff_+2, 1)) != _aC_[2] or
           ascii(substr(cBatch, _nOff_+3, 1)) != _aC_[3]
            nMismatch++
        ok
    next
    chk("0 mismatching pixels of " + (nBW * nBH), nMismatch = 0)
    StzEngineGpuTextureFree(hTB)

    ? ""
    ? "-- Scene 12: a COMPUTE kernel writes the verts a RENDER pass draws --"
    # the GR0 composition witness, through the product layer: one buffer,
    # Storage in the compute pass, Vertex in the render pass
    # NOTE: the kernel must READ the tile uniform, not merely declare it --
    # layout:"auto" drops unread bindings and the layer's bind group would
    # be invalid (the neural-backbone lesson, resurfacing on cue)
    cWgslGen = 'struct StzTile { xoff : u32, p0 : u32, p1 : u32, p2 : u32 }' + char(10) +
        '@group(0) @binding(0) var<uniform> tile : StzTile;' + char(10) +
        '@group(0) @binding(1) var<storage, read_write> v : array<f32>;' + char(10) +
        '@compute @workgroup_size(1)' + char(10) +
        'fn main() {' + char(10) +
        '  if (tile.xoff != 0u) { return; }' + char(10) +
        '  let r = 80.0/255.0; let g = 220.0/255.0; let b = 160.0/255.0;' + char(10) +
        '  v[0] = -0.9; v[1] = -0.9; v[2] = r; v[3] = g; v[4] = b; v[5] = 1.0;' + char(10) +
        '  v[6] =  0.0; v[7] =  0.9; v[8] = r; v[9] = g; v[10] = b; v[11] = 1.0;' + char(10) +
        '  v[12] = 0.9; v[13] = -0.9; v[14] = r; v[15] = g; v[16] = b; v[17] = 1.0;' + char(10) +
        '}'
    nKGen = StzEngineGpuKernelCompile(cWgslGen)
    chk("generator kernel compiled", nKGen > 0)
    hVC = StzEngineGpuBufferNew(18 * 4)
    chk("compute dispatch over the vertex buffer", StzEngineGpuDispatch(nKGen, [hVC], 1, 1) = S_OK)
    StzEngineGpuRenderBegin(hT, 0, 0, 0, 1)
    chk("render consumes the compute-written buffer", StzEngineGpuRenderDraw(nP1, hVC, 0, 3, 0) = S_OK)
    StzEngineGpuRenderEnd()
    cComp = StzEngineGpuTargetRead(hT)
    chk("compute-authored triangle landed EXACT", pxeq(cComp, nW, nW/2, nH/2, 80, 220, 160))

    ? ""
    ? "-- Scene 13: refusals answer by NAME --"
    chk("draw outside a pass: BAD_ARG", StzEngineGpuRenderDraw(nP1, hV, 0, 3, 0) = S_BADARG)
    chk("Begin on a SAMPLED texture: BAD_ARG", StzEngineGpuRenderBegin(hCk, 0, 0, 0, 1) = S_BADARG)
    hDead = StzEngineGpuBufferNew(72)
    StzEngineGpuBufferFree(hDead)
    StzEngineGpuRenderBegin(hT, 0, 0, 0, 1)
    chk("draw with a FREED vertex buffer: STALE", StzEngineGpuRenderDraw(nP1, hDead, 0, 3, 0) = S_STALE)
    chk("second Begin while a pass is open: BAD_ARG", StzEngineGpuRenderBegin(hT, 0, 0, 0, 1) = S_BADARG)
    chk("readback mid-pass: BAD_ARG", StzEngineGpuTargetRead(hT) = "")
    StzEngineGpuRenderEnd()

    ? ""
    ? "-- Scene 14: eviction crosses KINDS under a small budget --"
    nBudget0 = StzEngineGpuVramBudget()
    # drain to a clean slate for exact accounting
    StzEngineGpuTextureFree(hT)
    StzEngineGpuTextureFree(hCk)
    StzEngineGpuBufferFree(hV)
    StzEngineGpuBufferFree(hVQ)
    StzEngineGpuBufferFree(hVI)
    StzEngineGpuBufferFree(hIdx)
    StzEngineGpuBufferFree(hVB)
    StzEngineGpuBufferFree(hVC)
    nEv0 = StzEngineGpuCounter(C_EVICT)
    StzEngineGpuSetVramBudget(StzEngineGpuVramInUse() + 100000)
    hOldBuf = StzEngineGpuBufferNew(40000)      # oldest resident
    hTx1 = StzEngineGpuTextureNew(100, 100, K_TARGET)   # 40000 bytes
    chk("two residents fit without eviction", StzEngineGpuCounter(C_EVICT) = nEv0)
    hTx2 = StzEngineGpuTextureNew(100, 100, K_TARGET)   # forces one out
    chk("third resident evicted the OLDEST (counted)", StzEngineGpuCounter(C_EVICT) = nEv0 + 1)
    chk("and the victim was the BUFFER, now STALE", StzEngineGpuBufferSize(hOldBuf) = -1)
    chk("the newer texture survived", StzEngineGpuTextureWidth(hTx1) = 100)
    StzEngineGpuSetVramBudget(1073741824)
    nEv1 = StzEngineGpuCounter(C_EVICT)
    hTx3 = StzEngineGpuTextureNew(100, 100, K_TARGET)
    chk("negative sibling: big budget ⇒ zero evictions", StzEngineGpuCounter(C_EVICT) = nEv1)
    StzEngineGpuTextureFree(hTx1)
    StzEngineGpuTextureFree(hTx2)
    StzEngineGpuTextureFree(hTx3)
    StzEngineGpuSetVramBudget(nBudget0)

    ? ""
    ? "-- Scene 15: shutdown mid-pass is clean, re-Init restores service --"
    hTS = StzEngineGpuTextureNew(16, 16, K_TARGET)
    StzEngineGpuRenderBegin(hTS, 0, 0, 0, 1)
    StzEngineGpuShutdown()
    chk("not available after shutdown", StzEngineGpuIsAvailable() = 0)
    chk("the open pass was aborted", StzEngineGpuRenderActive() = 0)
    nF1 = StzEngineGpuCounter(C_FALL)
    chk("post-shutdown texture ask refuses", StzEngineGpuTextureNew(16, 16, K_TARGET) = 0)
    chk("and was counted", StzEngineGpuCounter(C_FALL) = nF1 + 1)
    chk("re-Init restores the device", StzEngineGpuInit($cStzGpuRuntime) = 1)
    hTR = StzEngineGpuTextureNew(8, 8, K_TARGET)
    chk("render service is back (target creates)", hTR > 0)
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

# pixel (x,y) 0-based in tight RGBA8 bytes equals (r,g,b) exactly
func pxeq cBytes, nRowW, nX, nY, nR, nG, nB
	_nOff_ = (floor(nY) * nRowW + floor(nX)) * 4
	return ascii(substr(cBytes, _nOff_+1, 1)) = nR and
	       ascii(substr(cBytes, _nOff_+2, 1)) = nG and
	       ascii(substr(cBytes, _nOff_+3, 1)) = nB
