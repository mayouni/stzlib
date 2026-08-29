load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE MATERIAL LANGUAGE -- NINE SURFACES, ONE CONTACT SHEET

	Every picture below is produced by a material the library TRANSPILED --
	no hand-written WGSL anywhere in this file. Each entry carries the source
	you would type and the shader it became, and each is RENDERED, because a
	shader that compiles can still draw nothing.

	The nine are chosen to exercise DIFFERENT parts of the language, not to
	look pretty nine times:

	    1 flat        one expression, one colour            (the floor)
	    2 latitude    fract on @position                    (a let feeding a mix)
	    3 fresnel     pow on @normal.z                       (rim light)
	    4 toon        step on @lambert                       (a hard edge)
	    5 checker     fract on BOTH @uv axes                 (two lets combining)
	    6 iridescent  @normal.x and @normal.z together       (three-way mix)
	    7 contour     smoothstep on fract                    (an anti-aliased line)
	    8 marble      sin of a sum                           (trig in a body)
	    9 terminator  smoothstep across @lambert             (a soft edge)

	The sheet itself is composed by the ENGINE (StzEngineGpuImageGrid): nine
	400x400 tiles is 5.8 MB of blit, which is not Ring's work.

	Run:  ring gg5_gallery.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0
TILE = 400

? "=============================================================="
? " THE MATERIAL LANGUAGE -- a gallery that is also a guard"
? "=============================================================="

#---------------------------------------------------------------------------
# The nine, as DATA:
#   [ name, [ colours ], [ scalars ], body, meshSpec, [ nMinLevels, nMax ] ]
#
# THE LEVEL BAND IS THE REAL ASSERTION. Counting "did it draw ink" passes for
# a material that painted the ball one flat colour. Counting DISTINCT byte
# values says whether the BODY ran: a mix or a smoothstep produces a
# continuous ramp (100+ levels), while a step produces a staircase.
#
# So 4_toon's band is DELIBERATELY the opposite of the others'. A toon
# material that came back with 180 levels did not quantize, and that is a
# failure even though the picture would look fine.
#---------------------------------------------------------------------------

aGallery = [

  [ "1_flat",
    [ [ :tint, "#E8A33D" ] ], [],
    '{ @out = tint * (@lambert * 0.85 + 0.15) }',
    [ :Sphere, 1.25, 48, 32 ], [ 60, 256 ] ],

  [ "2_latitude",
    [ [ :cold, "#16324F" ], [ :warm, "#7FD8E8" ] ], [ [ :rings, 7.0 ] ],
    '{ let band = fract(@position.y * rings);' +
    '  let lit  = @lambert * 0.75 + 0.25;' +
    '  @out = mix(cold, warm, band) * lit }',
    [ :Sphere, 1.25, 48, 32 ], [ 60, 256 ] ],

  [ "3_fresnel",
    [ [ :core, "#141C33" ], [ :edge, "#FF8A3C" ] ], [ [ :sharp, 3.0 ] ],
    '{ let facing = abs(@normal.z);' +
    '  let rim    = pow(1.0 - facing, sharp);' +
    '  @out = mix(core * (@lambert * 0.8 + 0.2), edge, rim) }',
    [ :Sphere, 1.25, 48, 32 ], [ 60, 256 ] ],

  [ "4_toon",
    [ [ :dark, "#2B1B4A" ], [ :mid, "#7A4FBF" ], [ :lit, "#F2E9FF" ] ],
    [ [ :cut1, 0.35 ], [ :cut2, 0.75 ] ],
    '{ let a = step(cut1, @lambert);' +
    '  let b = step(cut2, @lambert);' +
    '  @out = mix(mix(dark, mid, a), lit, b) }',
    [ :Sphere, 1.25, 48, 32 ], [ 4, 24 ] ],   # QUANTIZED on purpose

  [ "5_checker",
    [ [ :black, "#12161F" ], [ :white, "#E6EDF5" ] ], [ [ :n, 8.0 ] ],
    '{ let u = step(0.5, fract(@uv.x * n));' +
    '  let v = step(0.5, fract(@uv.y * n));' +
    '  let sq = abs(u - v);' +
    '  @out = mix(black, white, sq) * (@lambert * 0.7 + 0.3) }',
    [ :Sphere, 1.25, 64, 40 ], [ 60, 256 ] ],

  [ "6_iridescent",
    [ [ :a, "#FF3D7F" ], [ :b, "#3DFFC4" ], [ :c, "#3D7FFF" ] ], [],
    '{ let x = @normal.x * 0.5 + 0.5;' +
    '  let z = @normal.z * 0.5 + 0.5;' +
    '  @out = mix(mix(a, b, x), c, z) * (@lambert * 0.7 + 0.3) }',
    [ :Sphere, 1.25, 48, 32 ], [ 60, 256 ] ],

  [ "7_contour",
    [ [ :body, "#1A3A2E" ], [ :line, "#9CFF7A" ] ], [ [ :freq, 12.0 ] ],
    '{ let h = fract(@position.y * freq);' +
    '  let d = abs(h - 0.5);' +
    '  let k = 1.0 - smoothstep(0.02, 0.09, d);' +
    '  @out = mix(body * (@lambert * 0.8 + 0.2), line, k) }',
    [ :Sphere, 1.25, 64, 48 ], [ 60, 256 ] ],

  [ "8_marble",
    [ [ :vein, "#0E1524" ], [ :stone, "#D8DCE6" ] ], [ [ :scale, 4.0 ] ],
    '{ let s = sin((@position.x + @position.y) * scale);' +
    '  let t = abs(s);' +
    '  @out = mix(vein, stone, t) * (@lambert * 0.75 + 0.25) }',
    [ :Cube, 1.7 ], [ 60, 256 ] ],

  [ "9_terminator",
    [ [ :night, "#0B1026" ], [ :day, "#FFD9A0" ] ], [],
    '{ let k = smoothstep(0.35, 0.65, @lambert);' +
    '  @out = mix(night, day, k) }',
    [ :Sphere, 1.3, 64, 40 ], [ 60, 256 ] ]
]

#---------------------------------------------------------------------------
? ""
? "-- Every source TRANSPILES (this needs no device) ------------"
#
# Transpilation is CPU work. Running it before touching the GPU means a
# machine with no device still proves the language, and a failure names the
# material rather than dying inside a render.
#---------------------------------------------------------------------------

_aAM20_ = aGallery
_nAM20_ = len(_aAM20_)
for _iAM20_ = 1 to _nAM20_
	aM = _aAM20_[_iAM20_]
	oMM = new stzMaterialMaker()
	_aMc9_ = aM[2]
	_nMc9_ = len(_aMc9_)
	for _iMc9_ = 1 to _nMc9_
		oMM.TakesColor(_aMc9_[_iMc9_][1])
	next
	_aMs9_ = aM[3]
	_nMs9_ = len(_aMs9_)
	for _iMs9_ = 1 to _nMs9_
		oMM.TakesScalar(_aMs9_[_iMs9_][1])
	next
	oMM.ForEachFragment(aM[4])
	cW = oMM.ToWGSL()
	chk(PadR(aM[1], 13) + len(cW) + " chars of WGSL",
	    len(cW) > 200 and StzFindFirst("@fragment", cW) > 0)
next

#---------------------------------------------------------------------------
? ""
? "-- One of them, end to end, so the SHAPE is visible ----------"
#
# The point of a material language is that this is the whole of what an
# author writes. Everything below the line is emitted.
#---------------------------------------------------------------------------

oShow = new stzMaterialMaker()
oShow.TakesColor(:core)
oShow.TakesColor(:edge)
oShow.TakesScalar(:sharp)
oShow.ForEachFragment(aGallery[3][4])

? "   WHAT THE AUTHOR WRITES"
? "     color core     color edge     scalar sharp"
? "     {"
? "       let facing = abs(@normal.z)"
? "       let rim    = pow(1.0 - facing, sharp)"
? "       @out = mix(core * (@lambert * 0.8 + 0.2), edge, rim)"
? "     }"
? ""
? "   WHAT THE ENGINE EMITS (the fragment half)"
cWShow = oShow.ToWGSL()
nAt = StzFindFirst("@fragment", cWShow)
? StzSubStr(cWShow, nAt, len(cWShow) - nAt + 1)

#---------------------------------------------------------------------------
? ""
? "-- And every one of them DRAWS -------------------------------"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- rendering skipped; the transpiles above needed none)"
else
	cTiles = ""
	nTiles = 0
	aLevels = []

	_aAM21_ = aGallery
	_nAM21_ = len(_aAM21_)
	for _iAM21_ = 1 to _nAM21_
		aM = _aAM21_[_iAM21_]
		oMM = new stzMaterialMaker()
		aBind = []
		_aC22_ = aM[2]
		_nC22_ = len(_aC22_)
		for _iC22_ = 1 to _nC22_
			c = _aC22_[_iC22_]
			oMM.TakesColor(c[1])
			aBind + [ c[1], c[2] ]
		next
		_aS23_ = aM[3]
		_nS23_ = len(_aS23_)
		for _iS23_ = 1 to _nS23_
			s = _aS23_[_iS23_]
			oMM.TakesScalar(s[1])
			aBind + [ s[1], s[2] ]
		next
		oMM.ForEachFragment(aM[4])

		oSc = new stzScene(TILE, TILE)
		oSc.SetBackgroundQ("#080B14").SetCamera(0, 1.5, 4.0, 0, 0, 0)
		oSc.SetLight(-0.45, -0.8, -0.4, "#FFF6E4", "#181E2E")
		oSc.AddMesh(new stzMesh(aM[5]), 0, 0, 0)
		oSc.SetMaterial(oMM, aBind)
		oSc.ToPNG("gal_" + aM[1] + ".png")

		cPx = oSc.ToPixels()

		# INK, and DISTINCT ink. A material that painted the whole ball one
		# flat colour would pass an "is it lit" test while proving nothing
		# about the body -- so count how many DIFFERENT byte values the
		# surface shows. A gradient, a band, a rim: all of them are variety.
		nInk = 0  aSeen = []
		nPixLen = len(cPx)
		for i = 1 to nPixLen step 409
			v = ascii(substr(cPx, i, 1))
			if v > 40
				nInk++
				if NOT StzFind(v, aSeen)  aSeen + v  ok
			ok
		next
		nLev = len(aSeen)
		aLevels + [ aM[1], nLev ]
		? "   " + PadR(aM[1], 13) + PadR("ink " + nInk, 11) +
		  PadR("levels " + nLev, 12) +
		  "expected " + aM[6][1] + ".." + aM[6][2]
		chk("  " + aM[1] + " drew, and drew what its BODY says",
		    nInk > 150 and nLev >= aM[6][1] and nLev <= aM[6][2])

		cTiles += cPx
		nTiles++
	next

	# The bands above are numbers I chose. This one is not: whatever the
	# thresholds, the STEP material must come out flatter than every material
	# built on mix and smoothstep. If that ordering ever inverts, step stopped
	# stepping, and no per-material band would have to be re-tuned to notice.
	nToon = 0  nSmoothMin = 9999
	_aA24_ = aLevels
	_nA24_ = len(_aA24_)
	for _iA24_ = 1 to _nA24_
		a = _aA24_[_iA24_]
		if a[1] = "4_toon"
			nToon = a[2]
		else
			if a[2] < nSmoothMin  nSmoothMin = a[2]  ok
		ok
	next
	? ""
	? "   toon " + nToon + " levels vs the flattest smooth material " +
	  nSmoothMin
	chk("STEP quantizes and MIX does not -- an ordering, not a threshold",
	    nToon < nSmoothMin)

	#-----------------------------------------------------------------------
	? ""
	? "-- The contact sheet, composed by the ENGINE -----------------"
	#-----------------------------------------------------------------------

	aSheet = StzEngineGpuImageGrid(cTiles, TILE, TILE, nTiles, 3, 14,
	                              10, 13, 22)
	chk("the engine returned a sheet", len(aSheet) = 3)
	if len(aSheet) = 3
		? "   " + nTiles + " tiles of " + TILE + "x" + TILE + " -> " +
		  aSheet[1] + "x" + aSheet[2] + "  (" + len(aSheet[3]) + " bytes)"
		chkeq("width  = 3 tiles + 4 gutters", aSheet[1], 3 * TILE + 4 * 14)
		chkeq("height = 3 tiles + 4 gutters", aSheet[2], 3 * TILE + 4 * 14)

		cSheet = StzEngineGpuPngEncode(aSheet[1], aSheet[2], aSheet[3], 6)
		write("gg5_gallery.png", cSheet)
		? "   wrote gg5_gallery.png  (" + len(cSheet) + " bytes)"
		chk("the sheet is a real PNG", len(cSheet) > 20000)
	ok

	# a SHORT tile buffer must refuse, not tear
	aBad = StzEngineGpuImageGrid(cTiles, TILE, TILE, nTiles + 5, 3, 14, 0, 0, 0)
	chkeq("a short tile buffer is REFUSED, not torn", len(aBad), 0)
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

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
