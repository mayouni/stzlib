load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	STZCANVAS WEARING SEMANTIC COLOURS

	Every colour in this file is written as MEANING, never as a hex value:

	    :Success  :Warning  :Danger  :Info  :Primary  :Neutral
	    blue+  blue++  gray-  gray--            the shade algebra
	    StzThemeColor(:pro, :primary)           a role, through a theme
	    StzContrastingText(fill)                text that can be READ

	There is not a single "#rrggbb" in the drawing code below. The point is
	that an author says what a thing MEANS and the picture follows -- and
	that switching the theme restyles the whole composition without touching
	a shape.

	Run:  ring gg_color_showcase.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0
FONT = "C:/Windows/Fonts/segoeui.ttf"

? "=============================================================="
? " STZCANVAS WEARING SEMANTIC COLOURS"
? "=============================================================="

oFont = NULL
if fexists(FONT)  oFont = new stzFont(FONT)  ok
chk("a font is available", isObject(oFont))

if NOT StzGraphicsDevice()
	? "   (no device -- the SVG tier still works; PNGs skipped)"
ok

#---------------------------------------------------------------------------
? ""
? "-- 1. The roles, each labelled in text it can carry ----------"
#
# The label colour is not chosen by hand. StzContrastingText reads the
# fill and answers what can be read on it -- so :Warning (yellow) takes
# black and :Primary (blue) takes white, without the author deciding.
#---------------------------------------------------------------------------

aRoles = StzSemanticColors()
CW = 190  CH = 96
oSw = new stzCanvas(len(aRoles) * CW, CH + 40)
oSw.SetBackground(:White)

k = 0
_aCRole70_ = aRoles
_nCRole70_ = len(_aCRole70_)
for _iCRole70_ = 1 to _nCRole70_
	cRole = _aCRole70_[_iCRole70_]
	x = k * CW + 14
	oSw.Flush()
	oSw.FillQ(cRole).StrokeQ(:Neutral, 1).
		AddRoundRect(x, 20, CW - 28, CH - 20, 10)
	if isObject(oFont)
		cTxt = "" + cRole
		nTw = oFont.WidthOf(cTxt, 15)
		oSw.Flush()
		oSw.AddTextQ(cTxt, x + (CW - 28 - nTw) / 2, 20 + (CH - 20) / 2 + 5).
			SetFontQ(oFont, 15).Color(StzContrastingText(cRole))
	ok
	k++
next
write("showcase_roles.svg", oSw.ToSVG())
if StzGraphicsDevice()  oSw.ToPNG("showcase_roles.png")  ok
? "   wrote showcase_roles.png   (" + len(aRoles) + " roles, auto-contrast labels)"

_aCRole71_ = aRoles
_nCRole71_ = len(_aCRole71_)
for _iCRole71_ = 1 to _nCRole71_
	cRole = _aCRole71_[_iCRole71_]
	? "     " + PadR("" + cRole, 11) + " -> " + PadR(StzResolveColor(cRole), 9) +
	  "  label " + StzContrastingText(cRole)
next
chk("the label colour is not constant across the roles",
    StzContrastingText(:Warning) != StzContrastingText(:Primary))

#---------------------------------------------------------------------------
? ""
? "-- 2. The shade ALGEBRA, as a ramp ---------------------------"
#
# Five steps of one word. Nothing here is a colour value -- '--' through
# '++' is arithmetic on a name.
#---------------------------------------------------------------------------

aBases = [ "blue", "green", "red", "gold", "purple", "cyan" ]
aSteps = [ "--", "-", "", "+", "++" ]
SW = 118  SH = 62
oRamp = new stzCanvas(len(aSteps) * SW + 120, len(aBases) * SH + 30)
oRamp.SetBackground(:White)

r = 0
_aCB72_ = aBases
_nCB72_ = len(_aCB72_)
for _iCB72_ = 1 to _nCB72_
	cB = _aCB72_[_iCB72_]
	if isObject(oFont)
		oRamp.Flush()
		oRamp.AddTextQ(cB, 14, r * SH + 30 + SH / 2 - 6).
			SetFontQ(oFont, 14).Color(:Black)
	ok
	c = 0
	_aCS73_ = aSteps
	_nCS73_ = len(_aCS73_)
	for _iCS73_ = 1 to _nCS73_
		cS = _aCS73_[_iCS73_]
		cExpr = cB + cS
		oRamp.Flush()
		oRamp.FillQ(cExpr).StrokeQ("gray-", 1).
			AddRect(110 + c * SW, r * SH + 22, SW - 8, SH - 12)
		if isObject(oFont)
			nTw = oFont.WidthOf(cExpr, 13)
			oRamp.Flush()
			oRamp.AddTextQ(cExpr, 110 + c * SW + (SW - 8 - nTw) / 2,
				r * SH + 22 + (SH - 12) / 2 + 4).
				SetFontQ(oFont, 13).Color(StzContrastingText(cExpr))
		ok
		c++
	next
	r++
next
write("showcase_shades.svg", oRamp.ToSVG())
if StzGraphicsDevice()  oRamp.ToPNG("showcase_shades.png")  ok
? "   wrote showcase_shades.png   (" + len(aBases) + " bases x " +
  len(aSteps) + " steps)"

nLight = StzColorLuminance("green--")
nDark  = StzColorLuminance("green++")
? "   green-- luminance " + nLight + "   green++ " + nDark
chk("the ramp really is a ramp", nLight > nDark)

#---------------------------------------------------------------------------
? ""
? "-- 3. ONE panel, FIVE themes, no shape touched ---------------"
#
# The same drawing code runs five times. Only the THEME NAME changes, and
# every fill, stroke and label follows -- because each is a ROLE looked up
# in the theme rather than a colour written down.
#---------------------------------------------------------------------------

aThemes = [ "neutral", "light", "dark", "pro", "access" ]
PW = 340  PH = 210
oAll = new stzCanvas(PW * len(aThemes), PH)
oAll.SetBackground(:White)

t = 0
_aCTheme74_ = aThemes
_nCTheme74_ = len(_aCTheme74_)
for _iCTheme74_ = 1 to _nCTheme74_
	cTheme = _aCTheme74_[_iCTheme74_]
	_Panel(oAll, t * PW, 0, PW, PH, cTheme, oFont)
	t++
next
write("showcase_themes.svg", oAll.ToSVG())
if StzGraphicsDevice()  oAll.ToPNG("showcase_themes.png")  ok
? "   wrote showcase_themes.png   (" + len(aThemes) + " themes, identical code)"

_aCT75_ = aThemes
_nCT75_ = len(_aCT75_)
for _iCT75_ = 1 to _nCT75_
	cT = _aCT75_[_iCT75_]
	? "     " + PadR(cT, 9) + " primary " + PadR(StzThemeColor(cT, :primary), 8) +
	  "  background " + StzThemeColor(cT, :background)
next
chk("the themes really differ",
    StzResolveColor(StzThemeColor("dark", :background)) !=
    StzResolveColor(StzThemeColor("light", :background)))

# AND THE PROOF IT IS NOT DECORATION: the panel drawn under 'dark' must
# actually be dark where the panel under 'light' is light. Same pixel, two
# themes, opposite answers.
if StzGraphicsDevice()
	cPx = oAll.ToPixels()
	# SAMPLE WHERE ONLY THE BACKGROUND IS. The first version read y=150,
	# which is the NEUTRAL bar -- and neutral is gray+ under 'light' and
	# gray- under 'dark', so the answer came back exactly inverted and
	# looked like the themes were wrong. They were not; the probe was
	# pointing at a different thing in each panel.
	nLightPx = _Lum(cPx, PW * len(aThemes), 1 * PW + PW - 30, 20)
	nDarkPx  = _Lum(cPx, PW * len(aThemes), 2 * PW + PW - 30, 20)
	? "   background luminance  light panel " + nLightPx +
	  "   dark panel " + nDarkPx
	chk("the dark theme really renders darker than the light one",
	    nDarkPx < nLightPx)
ok

#---------------------------------------------------------------------------
? ""
? "-- 4. A status board written entirely in MEANING -------------"
#---------------------------------------------------------------------------

aRows = [
	[ "Payments API",   :Success, "operational" ],
	[ "Batch settle",   :Warning, "degraded"    ],
	[ "Card gateway",   :Danger,  "down"        ],
	[ "Reporting",      :Info,    "maintenance" ],
	[ "Archive",        :Neutral, "idle"        ]
]

BW = 620  BH = 72
oBoard = new stzCanvas(BW, len(aRows) * BH + 70)
oBoard.SetBackground("gray--")
if isObject(oFont)
	oBoard.Flush()
	oBoard.AddTextQ("Service status", 28, 44).SetFontQ(oFont, 22).Color(:Black)
ok

r = 0
_aA76_ = aRows
_nA76_ = len(_aA76_)
for _iA76_ = 1 to _nA76_
	a = _aA76_[_iA76_]
	y = 66 + r * BH
	oBoard.Flush()
	oBoard.FillQ(:White).StrokeQ("gray-", 1).AddRoundRect(24, y, BW - 48, BH - 14, 8)
	oBoard.Flush()
	oBoard.FillQ(a[2]).AddRoundRect(24, y, 8, BH - 14, 4)
	oBoard.Flush()
	oBoard.FillQ(a[2]).AddRoundRect(BW - 190, y + 14, 140, BH - 42, 12)
	if isObject(oFont)
		oBoard.Flush()
		oBoard.AddTextQ(a[1], 56, y + BH / 2).SetFontQ(oFont, 16).Color(:Black)
		nTw = oFont.WidthOf(a[3], 14)
		oBoard.Flush()
		oBoard.AddTextQ(a[3], BW - 190 + (140 - nTw) / 2, y + BH / 2 + 1).
			SetFontQ(oFont, 14).Color(StzContrastingText(a[2]))
	ok
	r++
next
write("showcase_board.svg", oBoard.ToSVG())
if StzGraphicsDevice()  oBoard.ToPNG("showcase_board.png")  ok
? "   wrote showcase_board.png"
? ""
? "   Not one hex value appears in the drawing code above."

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

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_

# One panel, drawn from ROLES. Nothing below names a colour: every fill is
# a role looked up in the theme it was handed.
func _Panel oC, nX, nY, nW, nH, cTheme, oFont
	_bg_   = StzThemeColor(cTheme, :background)
	_prim_ = StzThemeColor(cTheme, :primary)
	_ok_   = StzThemeColor(cTheme, :success)
	_warn_ = StzThemeColor(cTheme, :warning)
	_bad_  = StzThemeColor(cTheme, :danger)
	_neut_ = StzThemeColor(cTheme, :neutral)

	oC.Flush()
	oC.FillQ(_bg_).StrokeQ(_neut_, 1).AddRect(nX + 6, nY + 6, nW - 12, nH - 12)

	if isObject(oFont)
		oC.Flush()
		oC.AddTextQ(cTheme, nX + 22, nY + 34).SetFontQ(oFont, 17).
			Color(StzContrastingText(_bg_))
	ok

	oC.Flush()
	oC.FillQ(_prim_).AddRoundRect(nX + 22, nY + 48, nW - 44, 40, 8)
	if isObject(oFont)
		oC.Flush()
		oC.AddTextQ("primary", nX + 36, nY + 73).SetFontQ(oFont, 14).
			Color(StzContrastingText(_prim_))
	ok

	_k_ = 0
	_aC77_ = [ _ok_, _warn_, _bad_ ]
	_nC77_ = len(_aC77_)
	for _iC77_ = 1 to _nC77_
		_c_ = _aC77_[_iC77_]
		oC.Flush()
		oC.FillQ(_c_).AddRoundRect(nX + 22 + _k_ * ((nW - 44) / 3),
			nY + 100, (nW - 44) / 3 - 10, 36, 8)
		_k_++
	next

	oC.Flush()
	oC.FillQ(_neut_).AddRoundRect(nX + 22, nY + 148, nW - 44, 22, 6)

# Mean luminance of one pixel, for asserting a theme actually landed.
func _Lum cPx, nW, nX, nY
	_at_ = (nY * nW + nX) * 4 + 1
	if _at_ + 2 > len(cPx)  return -1  ok
	return 0.299 * ascii(substr(cPx, _at_, 1)) +
	       0.587 * ascii(substr(cPx, _at_ + 1, 1)) +
	       0.114 * ascii(substr(cPx, _at_ + 2, 1))
