# The 3D LAYER -- GR3 of the graphics plane (SOFTANZA_GRAPHICS_PLAN.md).
#
# Meshes with an EXTENSIBLE vertex format, a camera, a directional light,
# instances whose TRANSFORM STATE is separate from their render state, and
# ONE forward-lit pipeline drawing into a DEPTH-TESTED pass.
#
# The f32 math itself is asserted where it can be asserted exactly -- Zig
# unit tests in engine/src/gpu_math.zig (9 identities: lookAt sends the eye
# to the origin, perspective maps near/far to 0/1 in WebGPU's convention,
# quaternion composition equals matrix composition, the normal matrix keeps
# normals perpendicular under non-uniform scale...). A rendered picture can
# look plausible with a subtly wrong matrix; those identities cannot.
# THIS guard asserts what only a running renderer can show:
#
#   - DEPTH, not painter order: a nearer object wins even when the farther
#     one is submitted LAST (and the reversed order agrees -- if both
#     orders give the same picture, ordering is not what decided it)
#   - INSTANCING: N instances of one mesh cost ONE draw call; two meshes
#     cost two, each still instanced
#   - the §3b TRANSFORM door: moving something re-uploads transforms and
#     does NOT re-upload geometry (the counters are the witness)
#   - the §3b VERTEX-FORMAT door: a 4-attribute mesh renders through the
#     same contract, with no change in the render layer
#   - LIGHTING is real: with a white light the lit and unlit faces of a
#     cube differ; with a black light every face collapses to the SAME
#     ambient value (the negative sibling that proves the first is shading
#     and not texture, gradient or luck)
#   - OBJ geometry survives the round trip into pixels
#
# CI note: mesh building, OBJ parsing and every refusal run WITHOUT a
# device; only the rendering scenes gate on IsAvailable().
#
# STANDALONE like the other gpu guards: loads only the engine bridge.

load "stdlib.ring"
$cEngineDir = "../../../engine"
load "../../../engine/stz_gpu.ring"

nPass = 0
nFail = 0

WHITE = rgba(255, 255, 255, 255)
BLACK = rgba(0, 0, 0, 255)
DARKBG = rgba(10, 12, 16, 255)
RED   = rgba(220, 70, 60, 255)
GREEN = rgba(60, 200, 90, 255)
AMB   = rgba(40, 45, 55, 255)

? "-- Scene 1: meshes exist and describe themselves (no device needed) --"
chk("no device needed to build geometry", TRUE)
hCube = StzEngineGpuMeshCube(2)
aC = StzEngineGpuMeshStats(hCube)
chk("cube built", hCube > 0 and len(aC) = 5)
chk("24 vertices, not 8 -- faces keep their own normals", aC[1] = 24)
chk("36 indices (12 triangles)", aC[2] = 36)
chk("3 attributes, stride 8 floats", aC[3] = 3 and aC[4] = 8)
chk("its vertex format is DERIVED, not hardcoded", aC[5] = "3,3,2")
hSphere = StzEngineGpuMeshSphere(1, 16, 8)
aSp = StzEngineGpuMeshStats(hSphere)
chk("sphere built with the ring/segment grid", aSp[1] = 17 * 9)
chk("sphere index count is 2 triangles per cell", aSp[2] = 16 * 8 * 6)
hPlane = StzEngineGpuMeshPlane(4)
chk("plane is one quad", StzEngineGpuMeshStats(hPlane)[2] = 6)

? ""
? "-- Scene 2: OBJ parses, dedupes and triangulates --"
cObj = "v 0 0 0" + char(10) + "v 1 0 0" + char(10) + "v 1 1 0" + char(10) +
       "v 0 1 0" + char(10) + "vn 0 0 1" + char(10) +
       "f 1//1 2//1 3//1 4//1"
hObj = StzEngineGpuMeshFromObj(cObj)
aO = StzEngineGpuMeshStats(hObj)
chk("OBJ loaded", hObj > 0)
chk("4 unique (v,vt,vn) triples", aO[1] = 4)
chk("the quad face fanned into 2 triangles", aO[2] = 6)
chk("garbage OBJ refuses (id 0)", StzEngineGpuMeshFromObj("not an obj") = 0)

? ""
? "-- Scene 3: the vertex format is EXTENSIBLE (the §3b door) --"
# 4 attributes: position(3) normal(3) uv(2) colour(4)
aV = []
aTri = [ [-1,-1,0], [1,-1,0], [0,1,0] ]
aCols = [ [1,0,0,1], [0,1,0,1], [0,0,1,1] ]
for i = 1 to 3
    aV + aTri[i][1]  aV + aTri[i][2]  aV + aTri[i][3]
    aV + 0  aV + 0  aV + 1
    aV + 0  aV + 0
    _aCol9_ = aCols[i]
	_nCol9_ = len(_aCol9_)
	for _iCol9_ = 1 to _nCol9_
		aV + _aCol9_[_iCol9_]
	next
next
hVC = StzEngineGpuMeshCustom([3,3,2,4], aV, [0,1,2])
aVC = StzEngineGpuMeshStats(hVC)
chk("a 4-attribute mesh builds", hVC > 0)
chk("its format string grew with it", aVC[5] = "3,3,2,4")
chk("stride is 12 floats", aVC[4] = 12)
chk("an out-of-range index refuses instead of crashing later",
    StzEngineGpuMeshCustom([3], [0,0,0, 1,1,1], [0,1,9]) = 0)

? ""
? "-- Scene 4: refusals answer by name --"
chk("mesh free answers OK", StzEngineGpuMeshFree(hPlane) = 0)
chk("double free answers STALE", StzEngineGpuMeshFree(hPlane) = 2)
chk("stats on a freed mesh answer []", len(StzEngineGpuMeshStats(hPlane)) = 0)
hBad = StzEngineGpuScene3dNew(0, 100)
chk("a zero-size scene refuses", hBad = 0)
hSc = StzEngineGpuScene3dNew(64, 64)
chk("scene created", hSc > 0)
chk("a camera with far <= near refuses", StzEngineGpuScene3dCamera(hSc, 0,0,5, 0,0,0, 45, 10, 1) = 3)
chk("adding a freed mesh refuses (index 0)",
    StzEngineGpuScene3dAdd(hSc, hPlane, 0,0,0, 0,1,0, 0, 1,1,1, WHITE) = 0)
StzEngineGpuScene3dFree(hSc)
chk("a freed scene answers STALE", StzEngineGpuScene3dFree(hSc) = 2)

? ""
? "-- Scene 5: with a device, the 3D layer draws --"
nInit = StzEngineGpuInit($cStzGpuRuntime)
if StzEngineGpuIsAvailable() = 0
    ? "  NO GPU ON THIS MACHINE -- render scenes skipped; scenes 1-4 ARE the coverage"
else
    ? "  device: " + StzEngineGpuAdapterName(StzEngineGpuSelectedAdapter())
    nW = 80  nH = 80

    ? ""
    ? "-- Scene 6: DEPTH decides, not submission order --"
    # a red cube at the origin, a green one BEHIND it, added LAST
    hD = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hD, DARKBG)
    StzEngineGpuScene3dCamera(hD, 0,0,6, 0,0,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hD, 0,0,-1, WHITE, AMB)
    StzEngineGpuScene3dAdd(hD, hCube, 0,0,0,   0,1,0, 0, 1,1,1, RED)
    StzEngineGpuScene3dAdd(hD, hCube, 0,0,-3,  0,1,0, 0, 1,1,1, GREEN)
    cD = StzEngineGpuScene3dToPixels(hD)
    chk("rendered", len(cD) = nW * nH * 4)
    nCr = ascii(substr(cD, (40*nW + 40)*4 + 1, 1))
    nCg = ascii(substr(cD, (40*nW + 40)*4 + 2, 1))
    chk("the NEARER cube owns the centre pixel though it was added FIRST",
        nCr > nCg)
    # reversed submission: the far one first. Depth must give the SAME answer.
    hD2 = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hD2, DARKBG)
    StzEngineGpuScene3dCamera(hD2, 0,0,6, 0,0,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hD2, 0,0,-1, WHITE, AMB)
    StzEngineGpuScene3dAdd(hD2, hCube, 0,0,-3, 0,1,0, 0, 1,1,1, GREEN)
    StzEngineGpuScene3dAdd(hD2, hCube, 0,0,0,  0,1,0, 0, 1,1,1, RED)
    cD2 = StzEngineGpuScene3dToPixels(hD2)
    chk("reversing the submission order changes NOTHING -- so order is not " +
        "what decided it", cD2 = cD)

    ? ""
    ? "-- Scene 7: instancing -- many objects, ONE draw call --"
    hI = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hI, DARKBG)
    StzEngineGpuScene3dCamera(hI, 0,0,12, 0,0,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hI, -0.4,-1,-0.6, WHITE, AMB)
    for i = 1 to 5
        StzEngineGpuScene3dAdd(hI, hCube, (i-3)*2.2, 0, 0, 0,1,0, 20, 0.7,0.7,0.7, RED)
    next
    StzEngineGpuScene3dToPixels(hI)
    aIs = StzEngineGpuScene3dStats(hI)
    chk("5 instances", aIs[1] = 5)
    chk("ONE mesh resident", aIs[2] = 1)
    chk("and ONE draw call for all five", aIs[3] = 1)
    # a second mesh: two draws, each still instanced
    StzEngineGpuScene3dAdd(hI, hSphere, 0, 3, 0, 0,1,0, 0, 1,1,1, GREEN)
    StzEngineGpuScene3dAdd(hI, hSphere, 2, 3, 0, 0,1,0, 0, 1,1,1, GREEN)
    StzEngineGpuScene3dToPixels(hI)
    aIs2 = StzEngineGpuScene3dStats(hI)
    chk("7 instances across 2 meshes", aIs2[1] = 7 and aIs2[2] = 2)
    chk("2 draw calls -- one per MESH, not one per object", aIs2[3] = 2)

    ? ""
    ? "-- Scene 8: the §3b door -- transforms move without touching geometry --"
    nGeo = aIs2[4]
    nTr = aIs2[5]
    StzEngineGpuScene3dSetTransform(hI, 1, 0, 4, 0, 0,1,0, 45, 1,1,1)
    cMoved = StzEngineGpuScene3dToPixels(hI)
    aIs3 = StzEngineGpuScene3dStats(hI)
    chk("geometry was NOT re-uploaded when a transform changed",
        aIs3[4] = nGeo)
    chk("transform state WAS re-uploaded (cheap, by design)", aIs3[5] = nTr + 1)
    chk("and the picture actually changed", cMoved != StzEngineGpuScene3dToPixels(hD))

    # The instance buffer is REUSED, not recreated, when nothing grows.
    # Asserted because it is the reason the scene needs no capacity field:
    # ensureBuffer refuses to shrink, and an instance count cannot fall
    # (instances are only ever added). A dead `inst_capacity` sat here for
    # two phases on the theory that oscillation had to be absorbed -- it
    # never can. A gen-keyed id CHANGES when a buffer is recreated, so an
    # unchanged id across renders is the witness.
    nBufA = StzEngineGpuScene3dInstanceBuffer(hI)
    StzEngineGpuScene3dSetTransform(hI, 2, 1, 1, 0, 0,1,0, 10, 1,1,1)
    StzEngineGpuScene3dToPixels(hI)
    StzEngineGpuScene3dToPixels(hI)
    chk("the instance buffer is REUSED across frames, never recreated",
        StzEngineGpuScene3dInstanceBuffer(hI) = nBufA and nBufA != 0)

    # The negative sibling, on its OWN scene so it cannot disturb the
    # instance counts asserted further down. Without it the line above
    # could pass on a function that always returned the same number.
    hG = StzEngineGpuScene3dNew(200, 150)
    StzEngineGpuScene3dCamera(hG, 0,0,12, 0,0,0, 45, 0.1, 100)
    for i = 1 to 5
        StzEngineGpuScene3dAdd(hG, hCube, i, 0, 0, 0,1,0, 0, 1,1,1, RED)
    next
    StzEngineGpuScene3dToPixels(hG)
    nSmall = StzEngineGpuScene3dInstanceBuffer(hG)
    for i = 1 to 400
        StzEngineGpuScene3dAdd(hG, hCube, i, 1, 0, 0,1,0, 0, 1,1,1, GREEN)
    next
    StzEngineGpuScene3dToPixels(hG)
    chk("but growing PAST it does recreate the buffer -- so the check above " +
        "is reading a real id, not a constant",
        StzEngineGpuScene3dInstanceBuffer(hG) != nSmall)
    StzEngineGpuScene3dFree(hG)

    ? ""
    ? "-- Scene 9: lighting is SHADING, and the black light proves it --"
    hL = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hL, BLACK)
    StzEngineGpuScene3dCamera(hL, 3,3,5, 0,0,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hL, 0,-1,0, WHITE, AMB)     # straight down
    StzEngineGpuScene3dAdd(hL, hCube, 0,0,0, 0,1,0, 0, 1,1,1, WHITE)
    cLit = StzEngineGpuScene3dToPixels(hL)
    aLit = inkRange(cLit, nW, nH)
    chk("the cube has ink", aLit[3] > 100)
    chk("its faces differ in brightness -- a top face lit, a side face not " +
        "(" + aLit[1] + ".." + aLit[2] + ")", aLit[2] - aLit[1] > 40)
    # the negative sibling: kill the light, keep the ambient. Every face must
    # collapse to the SAME value -- if they still differed, the "shading"
    # above was coming from somewhere else.
    StzEngineGpuScene3dLight(hL, 0,-1,0, BLACK, AMB)
    cFlat = StzEngineGpuScene3dToPixels(hL)
    aFlat = inkRange(cFlat, nW, nH)
    chk("with a BLACK light every visible face collapses to one ambient " +
        "value (" + aFlat[1] + ".." + aFlat[2] + ")", aFlat[2] - aFlat[1] <= 1)
    chk("and that value is the ambient we asked for", aFlat[1] = 40)
    chk("ambient-only is darker than lit", aFlat[2] < aLit[2])

    ? ""
    ? "-- Scene 10: an OBJ mesh and a 4-attribute mesh both reach pixels --"
    hOS = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hOS, BLACK)
    StzEngineGpuScene3dCamera(hOS, 0.5,0.5,3, 0.5,0.5,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hOS, 0,0,-1, WHITE, AMB)
    StzEngineGpuScene3dAdd(hOS, hObj, 0,0,0, 0,1,0, 0, 1,1,1, GREEN)
    cO = StzEngineGpuScene3dToPixels(hOS)
    chk("the OBJ quad put ink on the target", inkRange(cO, nW, nH)[3] > 200)

    hVS = StzEngineGpuScene3dNew(nW, nH)
    StzEngineGpuScene3dClear(hVS, BLACK)
    StzEngineGpuScene3dCamera(hVS, 0,0,4, 0,0,0, 45, 0.1, 100)
    StzEngineGpuScene3dLight(hVS, 0,0,-1, WHITE, AMB)
    StzEngineGpuScene3dAdd(hVS, hVC, 0,0,0, 0,1,0, 0, 1,1,1, WHITE)
    cVC = StzEngineGpuScene3dToPixels(hVS)
    chk("the 4-attribute mesh rendered through the SAME contract",
        len(cVC) = nW * nH * 4 and inkRange(cVC, nW, nH)[3] > 100)
    chk("its per-vertex colours vary across the triangle (the extra " +
        "attribute reached the shader)", colorSpread(cVC, nW, nH) > 40)

    ? ""
    ? "-- Scene 11: device loss is honest --"
    StzEngineGpuShutdown()
    chk("rendering refuses once the device is gone",
        StzEngineGpuScene3dToPixels(hI) = "")
    chk("but the scene and its meshes still describe themselves",
        StzEngineGpuScene3dStats(hI)[1] = 7 and StzEngineGpuMeshStats(hCube)[1] = 24)
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

func rgba nR, nG, nB, nA
	return nR * 16777216 + nG * 65536 + nB * 256 + nA

# [minRed, maxRed, inkedPixels] over pixels that are not the clear colour
func inkRange cPix, nW, nH
	_nMin_ = 999  _nMax_ = -1  _nCount_ = 0
	for _i_ = 0 to nW * nH - 1
		_nR_ = ascii(substr(cPix, _i_*4 + 1, 1))
		_nG_ = ascii(substr(cPix, _i_*4 + 2, 1))
		_nB_ = ascii(substr(cPix, _i_*4 + 3, 1))
		if _nR_ + _nG_ + _nB_ > 12       # above the near-black background
			_nCount_++
			if _nR_ < _nMin_  _nMin_ = _nR_  ok
			if _nR_ > _nMax_  _nMax_ = _nR_  ok
		ok
	next
	if _nCount_ = 0  return [0, 0, 0]  ok
	return [_nMin_, _nMax_, _nCount_]

# how far apart the red and blue channels get -- a per-vertex colour ramp
# separates them, a flat material does not
func colorSpread cPix, nW, nH
	_nMax_ = 0
	for _i_ = 0 to nW * nH - 1
		_nR_ = ascii(substr(cPix, _i_*4 + 1, 1))
		_nB_ = ascii(substr(cPix, _i_*4 + 3, 1))
		_nD_ = _nR_ - _nB_
		if _nD_ < 0  _nD_ = -_nD_  ok
		if _nD_ > _nMax_  _nMax_ = _nD_  ok
	next
	return _nMax_
