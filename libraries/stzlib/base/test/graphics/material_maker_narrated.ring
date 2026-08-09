# MATERIALS -- GR4b of the graphics plane (SOFTANZA_GRAPHICS_PLAN.md).
#
# stzMaterialMaker is the stzKernelMaker of pixels: describe how a surface
# should look, and the ENGINE generates and validates the shader. Same
# LITERAL-body discipline as the compute maker, aimed at a fragment.
#
# What this guard protects:
#   - AUTHORING NEEDS NO DEVICE. A material is text until someone renders
#     it, so it can be written and inspected on a GPU-less machine.
#   - the transpile is documented BY ITS OUTPUT (ToWGSL returns the shader
#     verbatim), and what it emits is a COMPLETE shader on the render
#     layer's 3D contract -- a pipeline you can run, not a fragment
#     nobody can bind.
#   - every refusal NAMES its offender (the W lessons).
#   - declared values reach the shader in the layout its struct expects,
#     and a MISSING binding raises by name rather than shading with black.
#   - with a device: a material actually changes the picture, and clearing
#     it restores the built-in shading.

load "../../stzBase.ring"

nPass = 0
nFail = 0

? "-- Scene 1: a material is TEXT, and needs no GPU to write --"
oM = new stzMaterialMaker
oM.TakesColor(:base)
oM.TakesScalar(:glow)
oM.ForEachFragment('{ @out = base * (0.25 + 0.75 * @lambert) * (1.0 + glow * @normal.y) }')
chk("the declarations are readable back", len(oM.ColorNames()) = 1 and len(oM.ScalarNames()) = 1)
cSpec = oM.Spec()
chk("the spec collapses to engine lines",
    substr(cSpec, "color base") > 0 and substr(cSpec, "scalar glow") > 0)
cW = oM.ToWGSL()
chk("a shader came back", len(cW) > 400)
chk("the transpile is documented BY ITS OUTPUT -- the body is visible",
    substr(cW, "m.c_base") > 0 and substr(cW, "m.s_glow") > 0)
chk("builtins became real fragment values",
    substr(cW, "f_lambert") > 0 and substr(cW, "f_normal.y") > 0)
chk("it is a COMPLETE shader, not a loose fragment",
    substr(cW, "@vertex") > 0 and substr(cW, "@fragment") > 0)
chk("and it binds the render layer's 3D contract",
    substr(cW, "@binding(0) var<storage, read> frame") > 0 and
    substr(cW, "@binding(1) var<storage, read> instances") > 0 and
    substr(cW, "@binding(2) var<storage, read> m") > 0)
chk("ToWGSL is cached -- the same text twice", oM.ToWGSL() = cW)

? ""
? "-- Scene 2: the fragment builtins are the point --"
for cB in [ "normal", "position", "uv", "lambert", "color" ]
    oB = new stzMaterialMaker
    oB.TakesColor(:c)
    oB.ForEachFragment("{ @out = c * (0.5 + 0.5 * @" + cB + ".x) }")
    if cB = "lambert"
        oB.ForEachFragment("{ @out = c * @lambert }")
    ok
    chk("@" + cB + " is a builtin the material can read", len(oB.ToWGSL()) > 400)
next

? ""
? "-- Scene 3: every refusal names its offender --"
chk("an unknown @builtin refuses", raises('_Mat("{ @out = c * @gloss }").ToWGSL()'))
chk("an undeclared name refuses", raises('_Mat("{ @out = missing * 2.0 }").ToWGSL()'))
chk("assigning something other than @out refuses",
    raises('_Mat("{ @c = c }").ToWGSL()'))
chk("reading @out refuses", raises('_Mat("{ @out = @out }").ToWGSL()'))
chk("a foreign character refuses", raises('_Mat("{ @out = c $ 2.0 }").ToWGSL()'))
chk("a bad swizzle refuses", raises('_Mat("{ @out = c * @normal.q }").ToWGSL()'))
chk("an uncalled function refuses", raises('_Mat("{ @out = c * sqrt }").ToWGSL()'))
chk("no body at all refuses", raises('StzMaterialMakerQ().TakesColor(:c)  StzMaterialMakerQ().ToWGSL()'))
chk("a whitelisted function that IS called is fine",
    len(_Mat("{ @out = c * sqrt(@lambert) }").ToWGSL()) > 400)

? ""
? "-- Scene 4: declared values reach the shader's struct --"
aP = oM.ParamsFrom([ :base = "#e0a030", :glow = 0.6 ])
chk("a colour flattens to FOUR numbers, then the scalar", len(aP) = 5)
chk("and they are the colour, normalised",
    fabs(aP[1] - 224/255.0) < 0.001 and fabs(aP[2] - 160/255.0) < 0.001 and
    fabs(aP[3] - 48/255.0) < 0.001 and aP[4] = 1)
chk("the scalar rides last", aP[5] = 0.6)
chk("a MISSING colour raises by name, never shades black",
    raises('oM.ParamsFrom([ :glow = 0.6 ])'))
chk("a missing scalar raises by name too",
    raises('oM.ParamsFrom([ :base = "#ffffff" ])'))

? ""
? "-- Scene 5: with a device, a material changes the picture --"
if StzEngineGpuIsAvailable() = 0 and NOT StzGraphicsDevice()
    ? "  NO GPU -- authoring scenes above ARE the coverage"
else
    oCube = StzMeshQ(:Cube)
    oS = new stzScene(240, 180)
    oS.SetBackgroundQ("#0b0d13").SetCameraQ(3.5, 2.6, 4.2, 0, 0, 0).
       SetLightQ(-0.5, -1, -0.4, "#fff2dc", "#2b3244")
    oS.AddMeshQ(oCube, 0, 0, 0).ColorQ("#8090b0")
    chk("a fresh scene has no material", oS.HasMaterial() = FALSE)
    cPlain = oS.ToPixels()
    chk("it renders with the built-in shading", len(cPlain) = 240*180*4)

    oS.SetMaterial(oM, [ :base = "#e0a030", :glow = 0.6 ])
    chk("the scene now carries a material", oS.HasMaterial())
    cMat = oS.ToPixels()
    chk("and the picture CHANGED", cMat != cPlain)
    chk("the material's own colour is what shows (gold, not the instance's blue)",
        _IsGoldish(cMat, 240, 180))

    oS.ClearMaterial()
    chk("clearing it restores the built-in shading", oS.HasMaterial() = FALSE)
    chk("and the picture comes back", oS.ToPixels() = cPlain)

    chk("SetMaterial with a non-material RAISES", raises('oS.SetMaterial(oCube, [])'))
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

func raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

# a one-colour material carrying the given body -- the refusal scenes read
# better when the only thing varying is the body itself
func _Mat cBody
	_o_ = new stzMaterialMaker
	_o_.TakesColor(:c)
	_o_.ForEachFragment(cBody)
	return _o_

# is there a pixel where red clearly leads blue? the material paints gold
# over an instance whose own colour is blue-grey, so this separates them
func _IsGoldish cPix, nW, nH
	for _i_ = 0 to nW * nH - 1
		_nR_ = ascii(substr(cPix, _i_*4 + 1, 1))
		_nB_ = ascii(substr(cPix, _i_*4 + 3, 1))
		if _nR_ > 90 and _nR_ - _nB_ > 40
			return TRUE
		ok
	next
	return FALSE
