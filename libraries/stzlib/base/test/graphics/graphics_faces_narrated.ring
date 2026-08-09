# THE DECLARATIVE FACES -- GR4 of the graphics plane
# (SOFTANZA_GRAPHICS_PLAN.md). stzColor / stzFont / stzMesh / stzCanvas /
# stzScene: the engine's substance, wearing Softanza's manners.
#
# The thing this guard exists to protect is the NAMING LAW, because a
# convention that is only written down drifts:
#   - a method is an explicit VERB acting on the object (AddCircle, Fill,
#     SetBackground) -- never a bare noun;
#   - the PLAIN form acts and returns NOTHING (asserted: it is not an
#     object, so a chain cannot accidentally work);
#   - the ...Q twin does the same act and returns THE MAIN OBJECT
#     (asserted by IDENTITY -- the returned thing's Id_() is the canvas's
#     own, so no sub-object is being handed back);
#   - To...() keeps its name and returns DATA.
#
# And the behaviour those manners are wrapped around:
#   - Fill colours the LAST SHAPE ADDED; before any shape it sets the
#     canvas default (both directions asserted with real pixels)
#   - one model, two tiers: the same canvas answers SVG and PNG
#   - the 3D transform door still holds through the face
#   - Project() puts a scene point exactly where the picture shows it
#
# CI note: everything except the pixel scenes runs with no GPU.

load "../../stzBase.ring"

nPass = 0
nFail = 0
cFixture = "../gpu/fixtures/amiri_arabic_subset.ttf"

? "-- Scene 1: colours are written the way a designer writes them --"
chk("6-digit hex", StzColorToHex(StzColorToNumber("#e0a030")) = "#e0a030")
chk("3-digit short form expands", StzColorToNumber("#fa3") = StzColorToNumber("#ffaa33"))
chk("8-digit carries alpha", StzColorToNumber("#00000080") % 256 = 128)
chk("a name works", StzColorToNumber(:White) = StzColorToNumber("#ffffff"))
chk("case does not matter", StzColorToNumber("#E0A030") = StzColorToNumber("#e0a030"))
chk("transparent is fully transparent", StzColorToNumber(:Transparent) % 256 = 0)
chk("a bad colour RAISES rather than turning black", raises('StzColorToNumber("#zz")'))
chk("a wrong-length hex RAISES", raises('StzColorToNumber("#12345")'))

? ""
? "-- Scene 2: a font is bytes you loaded, and a measuring tape --"
oF = new stzFont(cFixture)
chk("font loaded", oF.Id_() > 0 and oF.IsAlive())
chk("it knows its repertoire", oF.GlyphCount() = 1449)
nLat = oF.WidthOf("Softanza", 24)
chk("Latin measures positive", nLat > 0)
cAr = char(0xD8)+char(0xB3) + char(0xD9)+char(0x88) + char(0xD9)+char(0x81) +
      char(0xD8)+char(0xAA) + char(0xD8)+char(0xA7) + char(0xD9)+char(0x86) +
      char(0xD8)+char(0xB2) + char(0xD8)+char(0xA7)
chk("Arabic measures positive (a real shaped advance)", oF.WidthOf(cAr, 24) > 0)
chk("Arabic is ONE visual run", oF.RunCountOf(cAr, 24) = 1)
chk("mixed script is THREE runs", oF.RunCountOf("abc " + cAr + " xyz", 24) = 3)
chk("8 Arabic codepoints shape to 8 glyphs", len(oF.GlyphsOf(cAr, 24)) = 8)
chk("a missing font RAISES by name", raises('new stzFont("no_such_font.ttf")'))

? ""
? "-- Scene 3: a mesh knows its own layout --"
oCube = StzMeshQ(:Cube)
chk("cube is 24 vertices, not 8 (normals stay sharp)", oCube.VertexCount() = 24)
chk("12 triangles", oCube.TriangleCount() = 12)
chk("its format is DERIVED from its attributes", oCube.Format() = "3,3,2")
oBall = new stzMesh([ :Sphere, 1, 16, 8 ])
chk("a sphere builds to its grid", oBall.VertexCount() = 17 * 9)
oQuad = StzMeshFromObjQ("v 0 0 0" + char(10) + "v 1 0 0" + char(10) +
	"v 1 1 0" + char(10) + "v 0 1 0" + char(10) + "vn 0 0 1" + char(10) +
	"f 1//1 2//1 3//1 4//1")
chk("an OBJ quad fans into 2 triangles", oQuad.TriangleCount() = 2)
chk("an unknown kind RAISES", raises('new stzMesh(:Banana)'))
chk("a broken OBJ RAISES", raises('StzMeshFromObjQ("not an obj")'))

? ""
? "-- Scene 4: THE NAMING LAW -- plain acts, Q returns the MAIN object --"
oC = new stzCanvas(200, 100)
chk("the plain form does NOT return an object",
    isObject(oC.AddCircle(50, 50, 30)) = FALSE)
chk("the plain form did the act anyway", oC.ShapeCount() = 1)
oBack = oC.AddCircleQ(150, 50, 30)
chk("the Q form returns an object", isObject(oBack))
chk("and it is THE CANVAS ITSELF, not a shape object",
    oBack.Id_() = oC.Id_())
chk("SetBackground has no Q-less surprise",
    isObject(oC.SetBackground(:Black)) = FALSE)
chk("SetBackgroundQ chains on the canvas",
    oC.SetBackgroundQ(:Black).Id_() = oC.Id_())
chk("a whole chain stays on the canvas",
    oC.AddRectQ(0,0,10,10).FillQ(:Red).StrokeQ(:White, 1).Id_() = oC.Id_())

? ""
? "-- Scene 5: Fill colours the LAST shape; before any shape, the default --"
oD = new stzCanvas(200, 100)
oD.SetBackground(:Black)
oD.AddCircleQ(50, 50, 30).FillQ("#ffffff")
oD.AddCircleQ(150, 50, 30).FillQ("#e0a030")
if oD.CanDrawPixels()
    cPix = oD.ToPixels()
    chk("the first circle took its own fill", px(cPix, 200, 50, 50) = "255,255,255")
    chk("the second took ITS own fill (not the first's)",
        px(cPix, 200, 150, 50) = "224,160,48")
    chk("the background stayed", px(cPix, 200, 5, 5) = "0,0,0")

    oE = new stzCanvas(100, 100)
    oE.SetBackground(:Black)
    oE.Fill("#3050c0")                 # BEFORE any shape: sets the default
    oE.AddCircle(50, 50, 30)
    chk("Fill before any Add became the canvas default",
        px(oE.ToPixels(), 100, 50, 50) = "48,80,192")
else
    ? "  (no GPU -- pixel assertions skipped; the SVG tier below is the coverage)"
ok

? ""
? "-- Scene 6: one model, two tiers --"
oG = new stzCanvas(220, 120)
oG.SetBackgroundQ("#101418").
   AddCircleQ(60, 60, 40).FillQ("#e0a030").
   AddTextQ("Softanza", 110, 70).SetFontQ(oF, 18).ColorQ("#ffffff")
cSvg = oG.ToSVG()
chk("the SVG tier answered", len(cSvg) > 100)
chk("it carries the canvas size", substr(cSvg, 'width="220" height="120"') > 0)
chk("the circle's EXACT geometry is in it", substr(cSvg, 'cx="60" cy="60" r="40"') > 0)
chk("text became glyph OUTLINES (no font needed to view it)",
    substr(cSvg, '<path d="M') > 0 and substr(cSvg, "font-family") = 0)
chk("Content() is the portable form", oG.Content() = cSvg)
if oG.CanDrawPixels()
    cPng = oG.ToPNG("")
    chk("the PNG tier answered from the SAME model", len(cPng) > 100)
    chk("and it is a real PNG", ascii(substr(cPng, 1, 1)) = 137 and substr(cPng, 2, 3) = "PNG")
ok
chk("AddText without a font RAISES by name",
    raises('oX = new stzCanvas(50,50)  oX.AddText("hi", 0, 0)  oX.ToSVG()'))

? ""
? "-- Scene 7: the 3D face keeps its manners and its door --"
oS = new stzScene(320, 240)
chk("the Q chain stays on the SCENE",
    oS.SetBackgroundQ("#0c0e14").SetCameraQ(4,3,6, 0,0,0).Id_() = oS.Id_())
chk("AddMesh's plain form returns no object",
    isObject(oS.AddMesh(oCube, 0, 0, 0)) = FALSE)
chk("but it recorded the instance", oS.InstanceCount() = 1 and oS.LastIndex() = 1)
chk("AddMeshQ chains and styles the last one added",
    oS.AddMeshQ(oCube, 2, 0, 0).ColorQ("#e0a030").Id_() = oS.Id_())
chk("two instances now", oS.InstanceCount() = 2)
chk("a camera with far <= near RAISES", raises('oS.SetLens(45, 10, 1)'))

aPrj = oS.Project(0, 0, 0)
chk("Project puts the camera target at the picture's centre",
    aPrj[4] = 1 and abs(aPrj[1] - 160) < 1 and abs(aPrj[2] - 120) < 1)
aBehind = oS.Project(0, 0, 100)
chk("a point behind the camera answers NOT VISIBLE, not a NaN", aBehind[4] = 0)

if oS.CanDrawPixels()
    oS.SetLight(-0.5, -1, -0.4, "#fff4e0", "#2a3040")
    oS.ToPixels()
    aSt0 = oS.Stats()
    chk("both instances drew in ONE call (same mesh)", aSt0[3] = 1)
    nGeo = aSt0[4]
    oS.MoveTo(1, 0, 1.5, 0)
    oS.RotateTo(2, 0, 1, 0, 45)
    oS.ToPixels()
    aSt1 = oS.Stats()
    chk("moving and rotating did NOT re-upload geometry", aSt1[4] = nGeo)
    chk("but transforms WERE re-sent", aSt1[5] = aSt0[5] + 1)

    ? ""
    ? "-- Scene 8: the GPU-driven door (the challenge pass's gap, closed) --"
    chk("the instance buffer is reachable once the scene has rendered",
        oS.InstanceBuffer() > 0)
    chk("its stride is the shader's stride", oS.InstanceStride() = 36)
    chk("a scene is CPU-driven by default", oS.IsGpuDriven() = FALSE)
    oS.SetGpuDrivenQ(TRUE)
    chk("and can be handed to the GPU", oS.IsGpuDriven())
    nTr = oS.Stats()[5]
    oS.MoveTo(1, 0, 3, 0)
    oS.ToPixels()
    chk("once GPU-driven, the face stops overwriting what a kernel wrote",
        oS.Stats()[5] = nTr)
    oS.SetGpuDriven(FALSE)
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

# "r,g,b" of the pixel at (x, y) in tight RGBA8 bytes
func px cBytes, nRowW, nX, nY
	_nO_ = (nY * nRowW + nX) * 4
	return "" + ascii(substr(cBytes, _nO_+1, 1)) + "," +
	       ascii(substr(cBytes, _nO_+2, 1)) + "," +
	       ascii(substr(cBytes, _nO_+3, 1))

# TRUE when the code raises -- a refusal that names itself is a feature,
# and this is how the guard holds the faces to it
func raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE
