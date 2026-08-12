load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	C1 -- IS THE OKLCH RAMP ACTUALLY A RAMP?

	SOFTANZA_COLOR_SYSTEM.md, phase C1, kill criterion written before the
	code existed:

	    "if an OKLCH ramp is not monotonic and even across all base hues
	     when measured the same way as the table in section 1, the space is
	     not buying what it claims and the shade algebra stays sRGB."

	The table it refers to, measured on the SHIPPED sRGB algebra:

	    blue    --=227  -=173  base=29  +=91  ++=11   steps 54,144,-63,79
	    yellow  --=251  -=244  base=225 +=45  ++=10   steps  6, 18,180,34

	A ramp whose middle is darker than both its neighbours, and whose steps
	differ by thirty times. This file asks whether the replacement is
	better BY THE SAME MEASUREMENT -- and it is allowed to answer no.

	Run:  ring gg_color_c1.ring
---------------------------------------------------------------------------*/

decimals(3)
nOk = 0  nBad = 0

? "=============================================================="
? " C1 -- the OKLCH ramp against its kill criterion"
? "=============================================================="

# five rungs, evenly spaced in PERCEPTUAL lightness
aL = [ 0.92, 0.78, 0.62, 0.46, 0.30 ]
aBases = [ "blue", "green", "yellow", "red", "purple", "cyan", "gold" ]

#---------------------------------------------------------------------------
? ""
? "-- 1. Monotonic? (the sRGB ramp was not) --------------------"
#---------------------------------------------------------------------------

? "   base      L at each rung                        monotonic"
? "   -------   -----------------------------------   ---------"

nNonMono = 0
for cB in aBases
	nSeed = _Hex24(StzResolveColor(cB))
	cRow = "   " + PadR(cB, 9) + " "
	aGot = []
	for x in aL
		nRamp = StzEngineColorRampStep(nSeed, x)
		nGot = StzEngineColorLightness(nRamp)
		aGot + nGot
		cRow += PadR("" + nGot, 7)
	next
	bMono = TRUE
	for i = 1 to len(aGot) - 1
		if aGot[i] <= aGot[i + 1]  bMono = FALSE  ok
	next
	if NOT bMono  nNonMono++  ok
	? cRow + "  " + iif(bMono, "yes", "NO")
next
chkeq("every ramp decreases at every step", nNonMono, 0)

#---------------------------------------------------------------------------
? ""
? "-- 2. Even? (the sRGB steps ranged 6 to 180) ----------------"
#
# The requested rungs are 0.14 apart in L. What comes back should be too --
# and the SPREAD between the largest and smallest step is the number the
# old ramp failed by thirty times over.
#---------------------------------------------------------------------------

nWorstSpread = 0
cWorst = ""
for cB in aBases
	nSeed = _Hex24(StzResolveColor(cB))
	aGot = []
	for x in aL
		aGot + StzEngineColorLightness(StzEngineColorRampStep(nSeed, x))
	next
	nMin = 99  nMax = 0
	for i = 1 to len(aGot) - 1
		nStep = aGot[i] - aGot[i + 1]
		if nStep < nMin  nMin = nStep  ok
		if nStep > nMax  nMax = nStep  ok
	next
	nSpread = nMax / max([ nMin, 0.0001 ])
	if nSpread > nWorstSpread
		nWorstSpread = nSpread
		cWorst = cB
	ok
	? "   " + PadR(cB, 9) + " steps " + PadR("" + nMin, 7) + " .. " +
	  PadR("" + nMax, 7) + "   ratio " + nSpread
next
? ""
? "   worst spread : " + nWorstSpread + "x  (" + cWorst + ")"
? "   the sRGB algebra's worst was 180/6 = 30x"
chk("no ramp's steps differ by more than 1.5x", nWorstSpread < 1.5)

#---------------------------------------------------------------------------
? ""
? "-- 3. Across HUES, the same rung reads the same weight ------"
#
# The property sRGB cannot give: a yellow and a blue asked for the same
# lightness must COME BACK at the same lightness. In BT.709 terms a
# saturated yellow is 225 and a saturated blue is 29 -- the same word
# meaning two completely different brightnesses.
#---------------------------------------------------------------------------

for x in [ 0.92, 0.62, 0.30 ]
	nMin = 99  nMax = 0
	for cB in aBases
		nGot = StzEngineColorLightness(
			StzEngineColorRampStep(_Hex24(StzResolveColor(cB)), x))
		if nGot < nMin  nMin = nGot  ok
		if nGot > nMax  nMax = nGot  ok
	next
	? "   rung " + x + " : L ranges " + nMin + " .. " + nMax +
	  "   spread " + (nMax - nMin)
	chk("  at rung " + x + " every hue lands within 0.02 L", (nMax - nMin) < 0.02)
next

#---------------------------------------------------------------------------
? ""
? "-- 4. The hue SURVIVES (green must stay green) --------------"
#
# Clipping RGB channels to fit the gamut shifts the hue -- which is how
# 'green+' became olive. The clamp reduces CHROMA instead, so a rung is a
# lighter green rather than a different colour.
#
# MEASURED IN OKLCH, NOT HSL, and that correction matters more than the
# result. The first version of this scene compared HSL hues and reported
# four drifting rungs, all of them blue. HSL hue is the wrong instrument
# for a ramp built in OKLCH: it disagrees with perception at high chroma,
# and it is meaningless as chroma tends to zero -- a near-grey has no hue
# to preserve, so asking about one manufactures a failure.
#
# The honest move was to fix the INSTRUMENT rather than raise the
# threshold until the check passed.
#---------------------------------------------------------------------------

nDrift = 0
cWorstHue = ""
nWorstD = 0
for cB in aBases
	nSeed = _Hex24(StzResolveColor(cB))
	nH0 = StzEngineColorHue(nSeed)
	for x in aL
		nV = StzEngineColorRampStep(nSeed, x)
		# no chroma, no hue: below this there is nothing to preserve
		if StzEngineColorChroma(nV) < 0.02  loop  ok
		nD = fabs(StzEngineColorHue(nV) - nH0)
		if nD > 180  nD = 360 - nD  ok
		if nD > nWorstD
			nWorstD = nD
			cWorstHue = cB + " at rung " + x
		ok
		if nD > 2  nDrift++  ok
	next
next
? "   worst hue drift : " + nWorstD + " degrees  (" + cWorstHue + ")"
chkeq("no rung with real chroma drifts more than 2 degrees", nDrift, 0)

#---------------------------------------------------------------------------
? ""
? "-- 5. SEE IT: the two ramps side by side --------------------"
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- numbers above needed none)"
else
	SW = 116  SH = 54
	oC = new stzCanvas(5 * SW + 190, len(aBases) * 2 * SH + 60)
	oC.SetBackground(:White)
	oFont = NULL
	if fexists("C:/Windows/Fonts/segoeui.ttf")
		oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
	ok

	r = 0
	for cB in aBases
		# the sRGB algebra, as shipped
		c = 0
		for cS in [ "--", "-", "", "+", "++" ]
			oC.Flush()
			oC.FillQ(cB + cS).AddRect(180 + c * SW, 30 + r * SH, SW - 6, SH - 8)
			c++
		next
		if isObject(oFont)
			oC.Flush()
			oC.AddTextQ(cB + "  sRGB", 16, 30 + r * SH + SH / 2).
				SetFontQ(oFont, 13).Color(:Black)
		ok
		r++

		# the OKLCH ramp
		c = 0
		for x in aL
			nHx = StzEngineColorRampStep(_Hex24(StzResolveColor(cB)), x)
			oC.Flush()
			oC.FillQ(_ToHex(nHx)).AddRect(180 + c * SW, 30 + r * SH, SW - 6, SH - 8)
			c++
		next
		if isObject(oFont)
			oC.Flush()
			oC.AddTextQ(cB + "  OKLCH", 16, 30 + r * SH + SH / 2).
				SetFontQ(oFont, 13).Color(:Black)
		ok
		r++
	next
	oC.ToPNG("c1_ramp_compare.png")
	write("c1_ramp_compare.svg", oC.ToSVG())
	? "   wrote c1_ramp_compare.png   (each base: sRGB row, then OKLCH row)"
ok

? ""
? "=============================================================="
? " VERDICT : " + iif(nBad = 0, "C1 PASSES its kill criterion", "C1 FAILS -- keep sRGB")
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

# "#RRGGBB" -> 0xRRGGBB, the 24-bit form the engine takes (no alpha).
func _Hex24 cHex
	_a_ = StzHexToRGB(cHex)
	return _a_[1] * 65536 + _a_[2] * 256 + _a_[3]

func _ToHex nV
	_r_ = floor(nV / 65536)
	_g_ = floor((nV - _r_ * 65536) / 256)
	_b_ = nV - _r_ * 65536 - _g_ * 256
	return StzRGBToHex(_r_, _g_, _b_)

# Hue in degrees, from the engine's own round trip -- computed here only
# because the bridge exposes lightness, not hue.
func _Hue nV
	_r_ = floor(nV / 65536)
	_g_ = floor((nV - _r_ * 65536) / 256)
	_b_ = nV - _r_ * 65536 - _g_ * 256
	_mx_ = max([ _r_, _g_, _b_ ])
	_mn_ = min([ _r_, _g_, _b_ ])
	_d_ = _mx_ - _mn_
	if _d_ = 0  return 0  ok
	if _mx_ = _r_
		_h_ = 60 * (((_g_ - _b_) / _d_) % 6)
	but _mx_ = _g_
		_h_ = 60 * ((_b_ - _r_) / _d_ + 2)
	else
		_h_ = 60 * ((_r_ - _g_) / _d_ + 4)
	ok
	if _h_ < 0  _h_ += 360  ok
	return _h_
