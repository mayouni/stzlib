load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE COLOUR DSL AS A UNIVERSAL ASSET

	stzDiagramColor.ring has carried a real little language for a long time:

	    names        24 of them, one source of truth
	    shades       blue+  blue++  gray-  gray--     (an algebra, not a list)
	    roles        :Success :Warning :Danger :Info :Primary :Neutral
	    themes       neutral light dark vibrant pro access print + 3 grays,
	                 each mapping the roles to shades
	    contrast     what text can be READ on a given fill

	Its own header carried the author's TODO: "Abstract it in a stzColor
	class -> Visual Module". Only stzDiagram could speak it. Everything else
	-- canvas, scene, plots, trees, graph canvas, materials -- was locked
	out, and worse, a SECOND colour table lived in stzColor.ring and
	DISAGREED: "blue" was #0000FF to the resolver and #466EE6 to the canvas.

	This file is the proof that there is now ONE language and ONE table, and
	that a colour expression means the same thing wherever it is written.

	Run:  ring gg_color_dsl.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " THE COLOUR DSL -- one language, every face"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. The language, and that the CANVAS speaks all of it -----"
#
# The old canvas table knew eleven names and REFUSED everything else. The
# test is not that the call survives -- it is that the canvas lands on the
# byte the resolver names.
#---------------------------------------------------------------------------

aExpr = [ "blue", "blue+", "blue++", "gray--", "gold-", "#3E6EA8",
          :Success, :Warning, :Danger, :Info, :Primary, :Neutral ]

nDisagree = 0
for x in aExpr
	cHex = StzResolveColor(x)
	nDirect = StzColorToNumber(x)
	nViaHex = StzColorToNumber(cHex)
	cMark = "ok"
	if nDirect != nViaHex
		nDisagree++
		cMark = "DIFFERS"
	ok
	? "   " + PadR("" + x, 10) + " -> " + PadR(cHex, 9) + "  " + cMark
next
chkeq("every expression means the same to the canvas as to the resolver",
      nDisagree, 0)

# THE SHADE ALGEBRA IS AN ALGEBRA. '+' must darken toward the base and '-'
# must lighten -- if all four shades resolved to the same colour the
# language would be decoration.
nBase = StzColorLuminance("blue")
nUp   = StzColorLuminance("blue++")
nDown = StzColorLuminance("blue--")
? ""
? "   luminance  blue-- " + nDown + "   blue " + nBase + "   blue++ " + nUp
chk("'--' is lighter than the base", nDown > nBase)
chk("'++' is darker than the base", nUp < nBase)
chk("...so the four shades are genuinely different colours",
    StzResolveColor("blue-") != StzResolveColor("blue+"))

#---------------------------------------------------------------------------
? ""
? "-- 2. EVERY FACE, proved in PIXELS ---------------------------"
#
# "It did not raise" is too weak: a face could swallow the expression and
# paint its default. Each face below is given a semantic role and the
# rendered pixel is compared against what the resolver says that role is.
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- this scene is a pixel property; skipped)"
else
	aWant = StzHexToRGB(StzResolveColor(:Danger))
	? "   :Danger resolves to " + StzResolveColor(:Danger) +
	  "  = rgb " + aWant[1] + "," + aWant[2] + "," + aWant[3]

	# -- the CANVAS
	oC = new stzCanvas(120, 90)
	oC.SetBackgroundQ("#FFFFFF").FillQ(:Danger).AddRect(20, 20, 80, 50)
	chk("stzCanvas paints :Danger", _PixelIs(oC.ToPixels(), 120, 60, 45, aWant))

	# -- a canvas BACKGROUND, which is a different code path
	oB = new stzCanvas(120, 90)
	oB.SetBackground(:Danger)
	chk("a canvas BACKGROUND takes it too", _PixelIs(oB.ToPixels(), 120, 60, 45, aWant))

	# -- the SCENE (3D), whose clear colour is the same choke point.
	#    It needs CONTENT: a scene with no mesh renders nothing at all and
	#    ToPixels answers 0 bytes, which would have read as "the colour did
	#    not arrive" when nothing had been asked to draw.
	oS = new stzScene(120, 90)
	oS.SetBackground(:Danger)
	oS.SetCamera(0, 0, 4, 0, 0, 0)
	oS.AddMesh(new stzMesh([ :Sphere, 0.35, 16, 12 ]), 0, 0, 0)
	cSp = oS.ToPixels()
	chk("a 3D scene renders at all", len(cSp) > 0)
	chk("stzScene's background takes the DSL", _PixelIs(cSp, 120, 6, 6, aWant))

	# -- a shade, through the node vocabulary
	aWant2 = StzHexToRGB(StzResolveColor("gold-"))
	oN = new stzCanvas(140, 100)
	oN.SetBackgroundQ("#FFFFFF")
	StzDrawNodeShapeXT(oN, :Box, 20, 20, 100, 60, "gold-", "gold-", 0)
	chk("the node vocabulary takes a SHADE expression",
	    _PixelIs(oN.ToPixels(), 140, 70, 50, aWant2))

	# -- the DIAGRAM, which is where the language started
	oD = new stzDiagram("d")
	oD.AddNodeXTT(:a, "A", [ :type = "box", :color = :Danger ])
	oD.AddNodeXTT(:b, "B", [ :type = "box", :color = "gold-" ])
	oD.AddEdge(:a, :b)
	cSvg = oD.ToSVGXT([ :Width = 400, :Height = 300 ])
	chk("a diagram still speaks it (nothing was taken away)", len(cSvg) > 500)
ok

#---------------------------------------------------------------------------
? ""
? "-- 3. CONTRAST is universal, and has ONE implementation ------"
#
# Legible text on a fill is not a diagram concern. It used to be a METHOD
# on stzDiagram, so a plot or a canvas had to instantiate a diagram to
# borrow the rule.
#---------------------------------------------------------------------------

? "   on gold   : " + StzContrastingText("gold")
? "   on blue+  : " + StzContrastingText("blue+")
? "   on gray-- : " + StzContrastingText("gray--")
chkeq("dark text on a light fill", StzContrastingText("gold"), "black")
chkeq("light text on a dark fill", StzContrastingText("blue+"), "white")
chk("StzIsDarkColor agrees with it",
    StzIsDarkColor("blue+") and NOT StzIsDarkColor("gold"))

# and stzDiagram must now DELEGATE, not carry a second copy
oDg = new stzDiagram("dg")
nSame = 0
for c in [ "gold", "blue+", "gray--", "red", "#123456", "#EEEEEE" ]
	if oDg.ContrastingTextColor(c) = StzContrastingText(c)  nSame++  ok
next
chkeq("stzDiagram's answer IS the universal answer, on all six", nSame, 6)

# THE NEGATIVE SIBLING: the rule must actually discriminate. A checker
# that always said "white" would pass every line above except this one.
chk("the rule DISCRIMINATES (it does not always answer the same)",
    StzContrastingText("#FFFFFF") != StzContrastingText("#000000"))

#---------------------------------------------------------------------------
? ""
? "-- 4. THEMES: a role, resolved through a named theme ---------"
#---------------------------------------------------------------------------

? "   roles : " + @@(StzColorRoles())
? ""
? "   theme      primary    danger     background"
? "   --------   --------   --------   ----------"
for cT in [ "neutral", "light", "dark", "pro", "access" ]
	? "   " + PadR(cT, 8) + "   " +
	  PadR(StzThemeColor(cT, :primary), 8) + "   " +
	  PadR(StzThemeColor(cT, :danger), 8) + "   " +
	  StzThemeColor(cT, :background)
next
chk("a theme role resolves to something", StzThemeColor("dark", :primary) != "")
chk("different themes give different primaries",
    StzThemeColor("dark", :primary) != StzThemeColor("light", :primary))
chkeq("an unknown role answers empty, it does not guess",
      StzThemeColor("dark", :sparkle), "")

# and a theme role is itself a DSL expression, so it flows straight into
# any face -- that composition is the whole point
chk("a theme role resolves onward to a hex",
    left(StzResolveColor(StzThemeColor("dark", :primary)), 1) = "#")

#---------------------------------------------------------------------------
? ""
? "-- 5. Refusals still name themselves -------------------------"
#---------------------------------------------------------------------------

chk("a nonsense colour is still refused", Raises('
	StzColorToNumber("sparkleplum")
'))
try
	StzColorToNumber("sparkleplum")
catch
	cMsg = cCatchError
done
? "   " + cMsg
chk("...and the message TEACHES the language",
    StzFindFirst("blue+", cMsg) > 0 and StzFindFirst("Success", cMsg) > 0)

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

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_

# Is the pixel at (x, y) the colour aRGB wants, within a tolerance that
# covers the renderer's rounding but nothing like a different colour?
func _PixelIs cPx, nW, nX, nY, aRGB
	_at_ = (nY * nW + nX) * 4 + 1
	if _at_ + 2 > len(cPx)  return FALSE  ok
	_r_ = ascii(substr(cPx, _at_, 1))
	_g_ = ascii(substr(cPx, _at_ + 1, 1))
	_b_ = ascii(substr(cPx, _at_ + 2, 1))
	_d_ = fabs(_r_ - aRGB[1]) + fabs(_g_ - aRGB[2]) + fabs(_b_ - aRGB[3])
	if _d_ > 12
		? "        got rgb " + _r_ + "," + _g_ + "," + _b_ +
		  "  wanted " + aRGB[1] + "," + aRGB[2] + "," + aRGB[3]
	ok
	return _d_ <= 12
