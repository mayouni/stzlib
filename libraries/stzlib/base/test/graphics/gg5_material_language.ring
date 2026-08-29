load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE MATERIAL LANGUAGE, DEEPENED

	The plan gates GG5 (the material NODE GRAPH) on this:

	    "if the material language has not gained multi-statement bodies and
	     texture sampling, do not start GG5 -- a node editor over a
	     one-assignment language is a toy with a GUI."

	Until now a material was exactly ONE assignment:

	    ForEachFragment('{ @out = tint * @lambert }')

	which meant every intermediate value had to be spelled out again
	wherever it was used. You could describe a surface; you could not build
	one. This adds LET BINDINGS, so a material has steps.

	Each material below prints its SOURCE, then the WGSL it became, then
	renders it -- so the language, the translation and the result are all
	visible together.

	Run:  ring gg5_material_language.ring
---------------------------------------------------------------------------*/

decimals(3)
nOk = 0  nBad = 0

? "=============================================================="
? " THE MATERIAL LANGUAGE -- multi-statement bodies"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. One assignment still works (nothing was broken) --------"
#---------------------------------------------------------------------------

oM1 = new stzMaterialMaker()
oM1.TakesColor(:tint)
oM1.ForEachFragment('{ @out = tint * @lambert }')
cW1 = oM1.ToWGSL()
? "   source : @out = tint * @lambert"
chk("the one-liner still transpiles", len(cW1) > 200)
chk("  ...and its colour reached the shader", StzFindFirst("m.c_tint", cW1) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. LET BINDINGS: a material now has STEPS -----------------"
#---------------------------------------------------------------------------

cSrc2 = '{ let lit = @lambert * 0.8 + 0.2;' +
        '  let band = fract(@position.y * rings);' +
        '  let edge = smoothstep(0.35, 0.5, band);' +
        '  @out = mix(dark, light, edge) * lit }'

oM2 = new stzMaterialMaker()
oM2.TakesColor(:dark)
oM2.TakesColor(:light)
oM2.TakesScalar(:rings)
oM2.ForEachFragment(cSrc2)
cW2 = oM2.ToWGSL()

? "   source:"
? "     let lit  = @lambert * 0.8 + 0.2"
? "     let band = fract(@position.y * rings)"
? "     let edge = smoothstep(0.35, 0.5, band)"
? "     @out     = mix(dark, light, edge) * lit"
? ""
? "   became, in the emitted fragment shader:"
nAt = StzFindFirst("let v_lit", cW2)
if nAt > 0
	? "     " + StzTrim(StzSubStr(cW2, nAt, 45))
ok
nAt = StzFindFirst("let v_band", cW2)
if nAt > 0
	? "     " + StzTrim(StzSubStr(cW2, nAt, 49))
ok
nAt = StzFindFirst("let v_edge", cW2)
if nAt > 0
	? "     " + StzTrim(StzSubStr(cW2, nAt, 53))
ok

chk("three lets became three WGSL lets",
    StzFindFirst("let v_lit", cW2) > 0 and StzFindFirst("let v_band", cW2) > 0 and
    StzFindFirst("let v_edge", cW2) > 0)
# 'v_band' appears in its OWN declaration, so finding it proves nothing. The
# property worth asserting is that a LATER statement consumes an EARLIER
# binding: smoothstep's third argument is v_band, declared one line above.
chk("a later statement REFERS to an earlier let",
    StzFindFirst("smoothstep(0.35, 0.5, v_band)", cW2) > 0)

# CAREFUL: the emitted module carries a VERTEX stage too, and it returns
# first. Comparing against the file's first 'return' compares the fragment's
# lets against the VERTEX's return and fails while the emission is perfect.
# The real property: a return exists AFTER the last let.
nLast = StzFindFirst("let v_edge", cW2)
cTail = StzSubStr(cW2, nLast, len(cW2) - nLast + 1)
chk("the lets come BEFORE the fragment's return", StzFindFirst("return", cTail) > 0)
chk("  ...and the return CONSUMES them", StzFindFirst("v_lit", cTail) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. The refusals, which are the language's real edges ------"
#---------------------------------------------------------------------------

chk("a let used BEFORE it exists is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:c)
	o.ForEachFragment("{ @out = c * later; let later = @lambert }")
	o.ToWGSL()
'))
chk("a let that shadows a declared colour is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:tint)
	o.ForEachFragment("{ let tint = @lambert; @out = tint }")
	o.ToWGSL()
'))
chk("@out anywhere but LAST is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:c)
	o.ForEachFragment("{ @out = c; let x = @lambert }")
	o.ToWGSL()
'))
chk("a body with no @out is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:c)
	o.ForEachFragment("{ let x = @lambert }")
	o.ToWGSL()
'))
chk("a statement that is neither let nor @out is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:c)
	o.ForEachFragment("{ x = 3; @out = c }")
	o.ToWGSL()
'))
chk("an unknown builtin is still refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:c)
	o.ForEachFragment("{ let a = @sparkle; @out = c * a }")
	o.ToWGSL()
'))

#---------------------------------------------------------------------------
? ""
? "-- 4. Render them, because a shader that compiles may still --"
? "      draw nothing                                          --"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- rendering skipped; everything above needed none)"
else
	oMesh = new stzMesh([ :Sphere, 1.25, 48, 32 ])

	aShows = [
		[ "flat",   "@out = tint * @lambert",
		  [ [ :tint, "#E0A030" ] ], [],
		  '{ @out = tint * @lambert }' ],

		[ "banded", "let band = fract(@position.y * rings); @out = mix(dark, light, band)",
		  [ [ :dark, "#22304F" ], [ :light, "#7FD8E8" ] ], [ [ :rings, 3.0 ] ],
		  '{ let band = fract(@position.y * rings);' +
		  '  @out = mix(dark, light, band) * (@lambert * 0.7 + 0.3) }' ],

		[ "rim",    "let rim = 1 - abs(@normal.z); let s = pow(rim, sharp); @out = mix(core, edge, s)",
		  [ [ :core, "#1B2A4A" ], [ :edge, "#FF9A3C" ] ], [ [ :sharp, 2.5 ] ],
		  '{ let rim = 1.0 - abs(@normal.z);' +
		  '  let s = pow(rim, sharp);' +
		  '  @out = mix(core * (@lambert * 0.8 + 0.2), edge, s) }' ]
	]

	_aAS27_ = aShows
	_nAS27_ = len(_aAS27_)
	for _iAS27_ = 1 to _nAS27_
		aS = _aAS27_[_iAS27_]
		oMM = new stzMaterialMaker()
		aBind = []
		_aC28_ = aS[3]
		_nC28_ = len(_aC28_)
		for _iC28_ = 1 to _nC28_
			c = _aC28_[_iC28_]
			oMM.TakesColor(c[1])
			aBind + [ c[1], c[2] ]
		next
		_aS29_ = aS[4]
		_nS29_ = len(_aS29_)
		for _iS29_ = 1 to _nS29_
			s = _aS29_[_iS29_]
			oMM.TakesScalar(s[1])
			aBind + [ s[1], s[2] ]
		next
		oMM.ForEachFragment(aS[5])

		oSc = new stzScene(420, 420)
		oSc.SetBackgroundQ("#0A0E18").SetCamera(0, 1.6, 4.2, 0, 0, 0)
		oSc.SetLight(-0.45, -0.8, -0.4, "#FFF6E4", "#1E2438")
		oSc.AddMesh(oMesh, 0, 0, 0)
		oSc.SetMaterial(oMM, aBind)
		cB = oSc.ToPNG("gg5_mat_" + aS[1] + ".png")

		# a shader that compiled but drew nothing would still write a PNG,
		# so check the pixels are not all background
		cPx = oSc.ToPixels()
		nInk = 0
		for i = 1 to len(cPx) step 613
			if ascii(substr(cPx, i, 1)) > 40  nInk++  ok
		next
		? "   " + PadR(aS[1], 7) + " " + PadR("" + len(cB) + " bytes", 12) +
		  " lit samples " + nInk
		chk("  '" + aS[1] + "' actually drew something", nInk > 20)
	next
ok

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

#---------------------------------------------------------------------------

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
