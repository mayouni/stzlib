load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE MATERIAL LANGUAGE GETS TEXTURES

	Until now a material could compute a surface but not READ one. Two
	additions:

	    texture NAME              a picture the material reads
	    sample(NAME, @uv)         the one verb a texture answers

	The author never names a SAMPLER, because a sampler is not a surface
	property -- the transpiler emits the pair and the draw path binds the
	pair, at group(0) 3+2k / 4+2k in declaration order.

	WHY THAT ORDER IS WRITTEN DOWN ON BOTH SIDES. A bind-group mismatch does
	not report where it is made. It reports at wgpuQueueSubmit as a Rust
	PANIC -- non-unwinding, so no try/catch, no message naming the material.
	The previous slice cost exactly that: a colour DECLARED but never read
	got stripped from the layout while the draw still bound it. So the same
	keep-alive is applied to textures HERE, before it could bite, and scene 4
	is the assertion that it works.

	Run:  ring gg5_texture.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " TEXTURES IN THE MATERIAL LANGUAGE"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. What the author writes, and what it becomes ------------"
#
# Transpiling needs no device, so this scene runs everywhere.
#---------------------------------------------------------------------------

cBody = '{ let t = sample(skin, @uv);' +
        '  @out = t * tint * (@lambert * 0.8 + 0.2) }'

? "   color tint"
? "   texture skin"
? "   {"
? "     let t = sample(skin, @uv)"
? "     @out = t * tint * (@lambert * 0.8 + 0.2)"
? "   }"

oM = new stzMaterialMaker()
oM.TakesColor(:tint)
oM.TakesTexture(:skin)
oM.ForEachFragment(cBody)
cW = oM.ToWGSL()

? ""
? "   became:"
for cNeed in [ "var t_skin : texture_2d<f32>", "var sm_skin : sampler",
               "textureSample(t_skin, sm_skin" ]
	nAt = StzFindFirst(cNeed, cW)
	? "     " + cNeed + "   " + iif(nAt > 0, "[emitted]", "[MISSING]")
	chk("emitted: " + cNeed, nAt > 0)
next

chk("the texture sits at binding 3", StzFindFirst("@binding(3) var t_skin", cW) > 0)
chk("its sampler at binding 4", StzFindFirst("@binding(4) var sm_skin", cW) > 0)
chk("the buffers keep bindings 0..2",
    StzFindFirst("@binding(0) var<storage, read> frame", cW) > 0 and
    StzFindFirst("@binding(2) var<storage, read> m", cW) > 0)

# two textures take the NEXT pair, not the same one
oM2 = new stzMaterialMaker()
oM2.TakesTexture(:albedo)
oM2.TakesTexture(:mask)
oM2.ForEachFragment('{ let a = sample(albedo, @uv);' +
                    '  let k = sample(mask, @uv);' +
                    '  @out = a * k.r }')
cW2 = oM2.ToWGSL()
chk("a second texture takes bindings 5 and 6",
    StzFindFirst("@binding(5) var t_mask", cW2) > 0 and
    StzFindFirst("@binding(6) var sm_mask", cW2) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. The refusals, which are where a language is real -------"
#---------------------------------------------------------------------------

chk("sampling a texture nobody declared is refused", Raises('
	o = new stzMaterialMaker()
	o.ForEachFragment("{ @out = sample(ghost, @uv) }")
	o.ToWGSL()
'))
chk("a texture used as a VALUE is refused (and says how to read it)", Raises('
	o = new stzMaterialMaker()
	o.TakesTexture(:skin)
	o.ForEachFragment("{ @out = skin }")
	o.ToWGSL()
'))
chk("sample without a coordinate is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesTexture(:skin)
	o.ForEachFragment("{ @out = sample(skin) }")
	o.ToWGSL()
'))
chk("sample with no parenthesis is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesTexture(:skin)
	o.ForEachFragment("{ @out = sample skin }")
	o.ToWGSL()
'))
chk("a texture name colliding with a colour is refused", Raises('
	o = new stzMaterialMaker()
	o.TakesColor(:skin)
	o.TakesTexture(:skin)
	o.ForEachFragment("{ @out = sample(skin, @uv) }")
	o.ToWGSL()
'))

# the message must NAME the offender -- a refusal that says "error" costs
# more than no refusal, because the author looks in the wrong place
try
	o = new stzMaterialMaker()
	o.TakesTexture(:skin)
	o.ForEachFragment("{ @out = skin }")
	o.ToWGSL()
catch
	cMsg = cCatchError
done
? "   the value-misuse message : " + cMsg
chk("...and it names the texture and the fix",
    StzFindFirst("skin", cMsg) > 0 and StzFindFirst("sample(", cMsg) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. It DRAWS the image, not just a shader that compiles ----"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- everything above needed none)"
else
	# A 2x2 texture with four UNMISTAKABLE colours. Small on purpose: with
	# NEAREST sampling every rendered pixel must be one of exactly these
	# four, which turns "did the texture arrive" into an exact question
	# instead of a resemblance.
	cTex = char(230) + char(40)  + char(40)  + char(255) +   # red
	       char(40)  + char(220) + char(60)  + char(255) +   # green
	       char(50)  + char(90)  + char(240) + char(255) +   # blue
	       char(240) + char(220) + char(60)  + char(255)     # yellow

	hTex = StzEngineGpuTextureNew(2, 2, 1)          # 1 = sampled NEAREST
	chk("the texture was created", hTex > 0)
	chkeq("and accepted its pixels", StzEngineGpuTextureWrite(hTex, cTex), 0)

	oMesh = new stzMesh([ :Sphere, 1.3, 64, 40 ])

	oSc = new stzScene(420, 420)
	oSc.SetBackgroundQ("#05070D").SetCamera(0, 1.4, 3.9, 0, 0, 0)
	oSc.SetLight(-0.4, -0.75, -0.45, "#FFFFFF", "#3A3A3A")
	oSc.AddMesh(oMesh, 0, 0, 0)
	oSc.SetMaterial(oM, [ :tint = "#FFFFFF", :skin = hTex ])
	chkeq("the scene knows it holds ONE texture", oSc.MaterialTextureCount(), 1)
	oSc.ToPNG("gg5_texture_a.png")
	cA = oSc.ToPixels()

	# The four texture colours must be FINDABLE in the render. Lighting
	# scales them, so the test is on the DOMINANT CHANNEL -- a red texel
	# still renders red-dominant at any brightness, and a material that
	# ignored the texture would be tint-white everywhere and have no
	# dominant channel at all.
	nRed = 0  nGreen = 0  nBlue = 0  nGrey = 0
	nPixLen = len(cA)
	for i = 1 to nPixLen - 4 step 4
		r = ascii(substr(cA, i, 1))
		g = ascii(substr(cA, i + 1, 1))
		b = ascii(substr(cA, i + 2, 1))
		if r + g + b < 60  loop  ok           # background
		if r > g + 25 and r > b + 25       nRed++
		but g > r + 25 and g > b + 25      nGreen++
		but b > r + 25 and b > g + 25      nBlue++
		but max([r, g, b]) - min([r, g, b]) < 20  nGrey++
		ok
	next
	? "   FRONT view:  red " + nRed + "   green " + nGreen + "   blue " +
	  nBlue + "   grey " + nGrey
	chk("the texture's RED reached the surface", nRed > 200)
	chk("its BLUE did too", nBlue > 200)
	chk("and the ball is NOT flat white (the tint-only picture)", nGrey < nRed)

	# GREEN is not in the front view, and that is CORRECT, not a bug: a
	# sphere's u runs once around it, so a 2x2 texture puts red/blue on one
	# side and green/yellow on the other. Asserting all four from one camera
	# would be asserting that a ball is transparent.
	#
	# So look from the OTHER side. This is a stronger claim than "four
	# colours appeared somewhere": it says the texture WRAPS the surface,
	# each texel where the UVs put it.
	oSc.SetCamera(0, 1.4, -3.9, 0, 0, 0)
	oSc.ToPNG("gg5_texture_back.png")
	cBack = oSc.ToPixels()
	nRedB = 0  nGreenB = 0
	for i = 1 to nPixLen - 4 step 4
		r = ascii(substr(cBack, i, 1))
		g = ascii(substr(cBack, i + 1, 1))
		b = ascii(substr(cBack, i + 2, 1))
		if r + g + b < 60  loop  ok
		if g > r + 25 and g > b + 25  nGreenB++  ok
		if r > g + 25 and r > b + 25  nRedB++  ok
	next
	? "   BACK view:   red " + nRedB + "   green " + nGreenB
	chk("GREEN is on the far side, where the UVs put it", nGreenB > 200)
	chk("...and green was NOT visible from the front", nGreen < 100)
	chk("the two views disagree, which is what WRAPPING means",
	    nGreenB > nGreen * 10)
	oSc.SetCamera(0, 1.4, 3.9, 0, 0, 0)

	#-----------------------------------------------------------------------
	? ""
	? "-- 4. A DECLARED-but-UNREAD texture must not kill the run ----"
	#
	# The failure this slice was written to avoid. naga strips a binding
	# nothing reads; the draw still binds it; wgpu panics at submit and the
	# process dies with no catchable error. If the keep-alive were missing,
	# this scene would not FAIL -- the run would END here.
	#-----------------------------------------------------------------------

	oDead = new stzMaterialMaker()
	oDead.TakesColor(:tint)
	oDead.TakesTexture(:never)
	oDead.ForEachFragment('{ @out = tint * @lambert }')

	oSc2 = new stzScene(220, 220)
	oSc2.SetBackgroundQ("#05070D").SetCamera(0, 1.4, 3.9, 0, 0, 0)
	oSc2.SetLight(-0.4, -0.75, -0.45, "#FFFFFF", "#3A3A3A")
	oSc2.AddMesh(oMesh, 0, 0, 0)
	oSc2.SetMaterial(oDead, [ :tint = "#40C0FF", :never = hTex ])
	cD = oSc2.ToPixels()
	? "   the run reached this line, which is the whole assertion"
	chk("a declared-but-unread texture renders instead of panicking",
	    len(cD) = 220 * 220 * 4)

	#-----------------------------------------------------------------------
	? ""
	? "-- 5. Swapping the IMAGE needs no new shader -----------------"
	#
	# A texture is a handle, not a value. Rebinding must change the picture
	# WITHOUT recompiling -- otherwise it is a constant with extra steps.
	#-----------------------------------------------------------------------

	cTex2 = char(20)  + char(20)  + char(20)  + char(255) +
	        char(250) + char(250) + char(250) + char(255) +
	        char(250) + char(250) + char(250) + char(255) +
	        char(20)  + char(20)  + char(20)  + char(255)
	hTex2 = StzEngineGpuTextureNew(2, 2, 1)
	StzEngineGpuTextureWrite(hTex2, cTex2)

	oSc.SetMaterial(oM, [ :tint = "#FFFFFF", :skin = hTex2 ])
	oSc.ToPNG("gg5_texture_b.png")
	cB = oSc.ToPixels()

	nDiff = 0
	for i = 1 to nPixLen step 331
		if substr(cA, i, 1) != substr(cB, i, 1)  nDiff++  ok
	next
	? "   sampled " + floor(nPixLen / 331) + " bytes, differing : " + nDiff
	chk("a different image gives a different picture", nDiff > 100)

	# and the NEW picture is greyscale, which the old one was not
	nGrey2 = 0
	for i = 1 to nPixLen - 4 step 4
		r = ascii(substr(cB, i, 1))
		g = ascii(substr(cB, i + 1, 1))
		b = ascii(substr(cB, i + 2, 1))
		if r + g + b < 60  loop  ok
		if max([r, g, b]) - min([r, g, b]) < 20  nGrey2++  ok
	next
	? "   grey samples: colour texture " + nGrey + " -> grey texture " + nGrey2
	chk("the greyscale image renders greyscale", nGrey2 > nGrey * 3)

	#-----------------------------------------------------------------------
	? ""
	? "-- 6. A dead handle is refused where it can be NAMED ---------"
	#-----------------------------------------------------------------------

	StzEngineGpuTextureFree(hTex2)
	chk("binding a freed texture RAISES here, not at submit", Raises('
		oSc.SetMaterial(oM, [ :tint = "#FFFFFF", :skin = ' + hTex2 + ' ])
	'))
	chk("a declared texture with no image RAISES", Raises('
		oSc.SetMaterial(oM, [ :tint = "#FFFFFF" ])
	'))

	#-----------------------------------------------------------------------
	? ""
	? "-- 7. A 2D CANVAS becomes a 3D SURFACE -----------------------"
	#
	# The point of textures being ordinary handles: the 2D plane already
	# produces RGBA pixels, so it can feed the 3D plane with nothing in
	# between. No file, no encode, no new API -- a canvas IS a picture.
	#-----------------------------------------------------------------------

	TW = 512  TH = 256
	oCv = new stzCanvas(TW, TH)
	oCv.SetBackgroundQ("#101A2E")
	for k = 0 to 15
		oCv.AddRectQ(k * 32, 0, 32, TH).FillQ(StzColorFromHSL(k * 22, 70, 55))
	next
	for k = 0 to 7
		oCv.AddCircleQ(32 + k * 64, 128, 22).FillQ("#0B1020")
		oCv.AddCircleQ(64 + k * 64, 64, 12).FillQ("#FFFFFF")
		oCv.AddCircleQ(64 + k * 64, 192, 12).FillQ("#FFFFFF")
	next
	cCanvasPx = oCv.ToPixels()
	? "   canvas rendered : " + len(cCanvasPx) + " bytes (" + TW + "x" + TH + ")"
	chkeq("the canvas gave exactly a texture's worth of pixels",
	      len(cCanvasPx), TW * TH * 4)

	hCanvasTex = StzEngineGpuTextureNew(TW, TH, 2)      # 2 = sampled LINEAR
	chkeq("the canvas uploads as a texture",
	      StzEngineGpuTextureWrite(hCanvasTex, cCanvasPx), 0)

	oShow = new stzMaterialMaker()
	oShow.TakesTexture(:art)
	oShow.TakesColor(:shade)
	oShow.TakesScalar(:amb)
	oShow.ForEachFragment('{ let c = sample(art, @uv);' +
	                      '  let l = @lambert * (1.0 - amb) + amb;' +
	                      '  @out = mix(shade, c, l) }')

	oBall = new stzScene(640, 640)
	oBall.SetBackgroundQ("#060911").SetCamera(0, 1.1, 3.6, 0, 0, 0)
	oBall.SetLight(-0.5, -0.7, -0.35, "#FFF4E0", "#20263A")
	oBall.AddMesh(new stzMesh([ :Sphere, 1.35, 96, 64 ]), 0, 0, 0)
	oBall.SetMaterial(oShow, [ :art = hCanvasTex, :shade = "#070B16",
	                           :amb = 0.25 ])
	oBall.ToPNG("gg5_texture_canvas.png")
	? "   wrote gg5_texture_canvas.png"

	# it must show the CANVAS's colours, not the material's shade colour
	cBall = oBall.ToPixels()
	aHues = []
	nB = len(cBall)
	for i = 1 to nB - 4 step 401
		r = ascii(substr(cBall, i, 1))
		g = ascii(substr(cBall, i + 1, 1))
		b = ascii(substr(cBall, i + 2, 1))
		if r + g + b < 90  loop  ok
		if max([r, g, b]) - min([r, g, b]) < 30  loop  ok   # not colourful
		nH = floor(r / 32) * 64 + floor(g / 32) * 8 + floor(b / 32)
		if NOT StzFind(nH, aHues)  aHues + nH  ok
	next
	? "   distinct saturated colours on the ball : " + len(aHues)
	chk("the canvas's 16 hues wrapped onto the sphere", len(aHues) > 10)
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

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

func Raises cCode
	try
		eval(cCode)
	catch
		return TRUE
	done
	return FALSE
