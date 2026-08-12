load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	C4 -- SHADING IN LINEAR SPACE

	SOFTANZA_COLOR_SYSTEM.md, phase C4:

	    "Kill: none. This is a correctness fix; if measurement shows the two
	     paths already agree, the phase is closed as unnecessary and that is
	     recorded."

	They did not agree. The measurement, before any code was written:

	    a material saying `@out = tint * k`, tint #808080, k 0.5
	        rendered                   64
	        correct in linear light    92

	Multiplying an sRGB-ENCODED value by 0.5 does not halve the light, it
	halves the ENCODING -- so every shadow in every material was far too
	dark and every mid-tone muddy. The classic gamma bug, and it had been
	shipping.

	Run:  ring gg_color_c4.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " C4 -- shading in linear space"
? "=============================================================="

if NOT StzGraphicsDevice()
	? ""
	? "   (no device -- C4 is entirely a rendered property, so this is"
	? "    UNJUDGED on this machine rather than passed)"
	? ""
	return
ok

#---------------------------------------------------------------------------
? ""
? "-- 1. The measurement that opened the phase -----------------"
#
# One multiply, no geometry subtlety, so the answer is arithmetic and the
# two candidate answers are far apart -- 64 against 92 is not a rounding
# question.
#---------------------------------------------------------------------------

oHalf = new stzMaterialMaker()
oHalf.TakesColor(:tint)
oHalf.TakesScalar(:k)
oHalf.ForEachFragment("{ @out = tint * k }")

nGot = _Centre(oHalf, [ :tint = "#808080", :k = 0.5 ])
nWrong = 64
nRight = floor(_ToSrgb(_ToLinear(128 / 255) * 0.5) * 255)

? "   tint #808080 halved"
? "     rendered                  : " + nGot
? "     sRGB arithmetic (wrong)   : " + nWrong
? "     linear light (correct)    : " + nRight
chk("the shading is done in LINEAR light", fabs(nGot - nRight) <= 2)
chk("...and is NOT the sRGB answer", fabs(nGot - nWrong) > 10)

# the same at a second factor, so one lucky value cannot carry it
nGot2 = _Centre(oHalf, [ :tint = "#C08040", :k = 0.25 ])
nRight2 = floor(_ToSrgb(_ToLinear(192 / 255) * 0.25) * 255)
? "   #C08040 quartered          : " + nGot2 + "   correct " + nRight2
chk("a second factor agrees too", fabs(nGot2 - nRight2) <= 2)

#---------------------------------------------------------------------------
? ""
? "-- 2. The transfer must ROUND-TRIP exactly ------------------"
#
# The risk a linear pipeline introduces: every flat colour now goes
# sRGB -> linear -> sRGB. If that loses a bit, EVERY material shifts and
# the fix costs more than the bug. A material returning its colour
# untouched is the exact test.
#---------------------------------------------------------------------------

oFlat = new stzMaterialMaker()
oFlat.TakesColor(:tint)
oFlat.ForEachFragment("{ @out = tint }")

nDrift = 0
for c in [ "#808080", "#E0A030", "#1B3A5C", "#FFFFFF", "#010101", "#7F00FF" ]
	aW = StzHexToRGB(c)
	aG = _CentreRGB(oFlat, [ :tint = c ])
	nD = fabs(aG[1] - aW[1]) + fabs(aG[2] - aW[2]) + fabs(aG[3] - aW[3])
	? "   " + c + " -> " + aG[1] + "," + aG[2] + "," + aG[3] + "   drift " + nD
	if nD > 2  nDrift++  ok
next
chkeq("every flat colour survives the round trip", nDrift, 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. The BACKGROUND path is literal, and stays so ----------"
#
# A clear colour has no arithmetic applied, so it must arrive exactly as
# written. If the fix had linearised it too, every background in the
# library would have shifted -- which is how a correctness fix becomes a
# regression.
#---------------------------------------------------------------------------

nBadBg = 0
for c in [ "#808080", "#1B3A5C", "#E0A030" ]
	oB = new stzScene(80, 80)
	oB.SetBackgroundQ(c).SetCamera(0, 0, 3, 0, 0, 0)
	oB.AddMesh(new stzMesh([ :Sphere, 0.15, 8, 6 ]), 0, 0, 0)
	cPx = oB.ToPixels()
	i = (6 * 80 + 6) * 4 + 1
	aW = StzHexToRGB(c)
	nD = fabs(ascii(substr(cPx, i, 1)) - aW[1]) +
	     fabs(ascii(substr(cPx, i + 1, 1)) - aW[2]) +
	     fabs(ascii(substr(cPx, i + 2, 1)) - aW[3])
	? "   background " + c + " arrives with drift " + nD
	if nD > 2  nBadBg++  ok
next
chkeq("backgrounds are still literal", nBadBg, 0)

#---------------------------------------------------------------------------
? ""
? "-- 4. What it looks like: shadows stop crushing -------------"
#
# The visible consequence. A lambert-shaded sphere in sRGB arithmetic
# collapses its dark half toward black; in linear light the falloff is
# gradual. Counted as DISTINCT levels down the terminator -- a crushed
# gradient has fewer.
#---------------------------------------------------------------------------

oLit = new stzMaterialMaker()
oLit.TakesColor(:tint)
oLit.ForEachFragment("{ @out = tint * @lambert }")

oS = new stzScene(300, 300)
oS.SetBackgroundQ("#000000").SetCamera(0, 1.2, 3.6, 0, 0, 0)
oS.SetLight(-0.45, -0.75, -0.4, "#FFFFFF", "#000000")
oS.AddMesh(new stzMesh([ :Sphere, 1.4, 64, 48 ]), 0, 0, 0)
oS.SetMaterial(oLit, [ :tint = "#C08040" ])
oS.ToPNG("c4_linear_shading.png")

cPx = oS.ToPixels()
aSeen = []
for y = 40 to 260
	i = (y * 300 + 150) * 4 + 1
	v = ascii(substr(cPx, i, 1))
	if v > 2 and NOT StzFind(v, aSeen)  aSeen + v  ok
next
? "   distinct levels down the terminator : " + len(aSeen)
chk("the falloff is a gradient, not a cliff", len(aSeen) > 40)
? "   wrote c4_linear_shading.png"

? ""
? "=============================================================="
? " VERDICT : " + iif(nBad = 0,
	"C4 PASSES -- shading is linear, and nothing else moved",
	"C4 FAILS -- see above")
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

# The sRGB transfer pair, in Ring, so the expected value is computed here
# rather than copied from the shader it is checking.
func _ToLinear v
	if v <= 0.04045  return v / 12.92  ok
	return pow((v + 0.055) / 1.055, 2.4)

func _ToSrgb v
	if v <= 0.0031308  return v * 12.92  ok
	return 1.055 * pow(v, 1 / 2.4) - 0.055

func _CentreRGB oMat, aBind
	_o_ = new stzScene(80, 80)
	_o_.SetBackgroundQ("#000000").SetCamera(0, 0, 3, 0, 0, 0)
	_o_.AddMesh(new stzMesh([ :Sphere, 1.5, 24, 18 ]), 0, 0, 0)
	_o_.SetMaterial(oMat, aBind)
	_c_ = _o_.ToPixels()
	_i_ = (40 * 80 + 40) * 4 + 1
	return [ ascii(substr(_c_, _i_, 1)),
	         ascii(substr(_c_, _i_ + 1, 1)),
	         ascii(substr(_c_, _i_ + 2, 1)) ]

func _Centre oMat, aBind
	return _CentreRGB(oMat, aBind)[1]
