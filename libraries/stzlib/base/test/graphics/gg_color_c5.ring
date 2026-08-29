load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	C5 -- A THEME IS DATA, AND DATA CAN LEAVE RING

	SOFTANZA_COLOR_SYSTEM.md, phase C5, kill criterion written first:

	    "if a round trip does not reproduce the same rendered colours, the
	     export is decorative."

	So the centre of this file is not "the CSS parses". It is: take a theme
	out to CSS, read it BACK, paint with what came back, and compare the
	PIXELS against the same paint applied from the live theme. A file that
	merely parses proves nothing.

	Run:  ring gg_color_c5.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " C5 -- theme export"
? "=============================================================="

oT = new stzTheme(:pro)

#---------------------------------------------------------------------------
? ""
? "-- 1. What goes out is more than the six role names ---------"
#
# A web face paints with --stz-danger-surface and --stz-on-danger as much
# as with --stz-danger. Exporting only the roles would leave the far side
# needing a resolver, a ramp and a contrast metric -- which is the whole
# thing this export exists to avoid.
#---------------------------------------------------------------------------

aTok = oT.Tokens()
? "   theme '" + oT.Name() + "' exports " + len(aTok) + " tokens"
chk("more tokens than roles", len(aTok) > len(oT.Roles()))

_aC60_ = [ "danger", "danger-surface", "danger-border", "danger-solid",
           "danger-text", "on-danger", "background" ]
_nC60_ = len(_aC60_)
for _iC60_ = 1 to _nC60_
	c = _aC60_[_iC60_]
	cV = StzThemeTokenOf(aTok, c)
	? "     " + PadR(c, 16) + " " + cV
	chk("  " + c + " is exported", cV != "")
next

# EVERY token must be a resolved hex. An expression like "blue+" leaving
# in a CSS file is a colour no browser can render.
nNotHex = 0
_aA61_ = aTok
_nA61_ = len(_aA61_)
for _iA61_ = 1 to _nA61_
	a = _aA61_[_iA61_]
	if left(a[2], 1) != "#" or len(a[2]) != 7  nNotHex++  ok
next
chkeq("every token is a resolved #rrggbb", nNotHex, 0)

# background has no steps -- it is a surface, not something that carries
# text, and four unusable tokens would be four things to explain
chkeq("background exports no step tokens",
      StzThemeTokenOf(aTok, "background-solid"), "")

#---------------------------------------------------------------------------
? ""
? "-- 2. Three formats, ONE token list -------------------------"
#
# CSS, JSON and Ring all read Tokens(), so they cannot disagree about which
# tokens exist. Checked, because "they share a function" is a claim about
# the source and this is a claim about the output.
#---------------------------------------------------------------------------

cCss = oT.ToCSS()
cJson = oT.ToJSON()
cRing = oT.ToRing()
? "   CSS  " + len(cCss) + " chars   JSON " + len(cJson) +
  "   Ring " + len(cRing)

nMissing = 0
_aA62_ = aTok
_nA62_ = len(_aA62_)
for _iA62_ = 1 to _nA62_
	a = _aA62_[_iA62_]
	if StzFindFirst(a[2], cCss) = 0   nMissing++  ok
	if StzFindFirst(a[2], cJson) = 0  nMissing++  ok
	if StzFindFirst(a[2], cRing) = 0  nMissing++  ok
next
chkeq("every token's value appears in all three formats", nMissing, 0)
chk("the CSS uses the declared prefix",
    StzFindFirst(StzThemeCssPrefix() + "danger", cCss) > 0)
chk("the JSON names its theme", StzFindFirst('"theme": "pro"', cJson) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. THE KILL CRITERION: the round trip in PIXELS ----------"
#
# Out to CSS, back from CSS, painted -- against the same paint from the
# live theme. Compared as RENDERED BYTES, because that is the only
# comparison a caller cares about.
#---------------------------------------------------------------------------

aBack = StzThemeFromCSS(cCss)
? "   parsed back : " + len(aBack) + " tokens (exported " + len(aTok) + ")"
chkeq("the round trip loses no token", len(aBack), len(aTok))

if NOT StzGraphicsDevice()
	? "   (no device -- the kill criterion is a PIXEL property, so C5 is"
	? "    UNJUDGED on this machine rather than passed)"
else
	# a small chart-like painting, done twice: once from the live theme,
	# once from nothing but the parsed file
	aPaint = [ "background", "primary-solid", "success-solid",
	           "warning-solid", "danger-solid", "info-solid",
	           "neutral-border", "danger-surface", "on-danger" ]

	oLive = _Paint(aTok, aPaint)
	oFile = _Paint(aBack, aPaint)
	cA = oLive.ToPixels()
	cB = oFile.ToPixels()

	nDiff = 0
	nL = min([ len(cA), len(cB) ])
	for i = 1 to nL step 37
		if substr(cA, i, 1) != substr(cB, i, 1)  nDiff++  ok
	next
	? "   sampled " + floor(nL / 37) + " bytes of both renders"
	? "   bytes differing : " + nDiff
	chkeq("the exported theme renders IDENTICALLY", nDiff, 0)

	# THE NEGATIVE SIBLING. Byte-equality is also what two renders of the
	# SAME thing give, so prove the comparison can see a difference: nudge
	# one token and the same check must fail.
	aBent = []
	_aA63_ = aBack
	_nA63_ = len(_aA63_)
	for _iA63_ = 1 to _nA63_
		a = _aA63_[_iA63_]
		if a[1] = "danger-solid"
			aBent + [ a[1], "#00FF00" ]
		else
			aBent + [ a[1], a[2] ]
		ok
	next
	cC = _Paint(aBent, aPaint).ToPixels()
	nDiff2 = 0
	for i = 1 to nL step 37
		if substr(cA, i, 1) != substr(cC, i, 1)  nDiff2++  ok
	next
	? "   with ONE token bent, differing : " + nDiff2
	chk("the comparison DISCRIMINATES", nDiff2 > 20)
ok

#---------------------------------------------------------------------------
? ""
? "-- 4. Every shipped theme exports, and stays legible --------"
#
# C3 gated the themes as they live in Ring. The export is what a web face
# will actually paint with, so the gate has to hold on the FAR side too --
# otherwise C3 guarantees a property of a file nobody uses.
#---------------------------------------------------------------------------

nBadPair = 0
? "   theme      tokens   worst on/solid contrast"
_aCT64_ = StzColorThemes()
_nCT64_ = len(_aCT64_)
for _iCT64_ = 1 to _nCT64_
	cT = _aCT64_[_iCT64_]
	if StzThemeColor(cT, :primary) = ""  loop  ok
	oX = new stzTheme(cT)
	aX = oX.Tokens()
	nWorst = 99
	_aCR65_ = [ "primary", "success", "warning", "danger", "info" ]
	_nCR65_ = len(_aCR65_)
	for _iCR65_ = 1 to _nCR65_
		cR = _aCR65_[_iCR65_]
		cOn = StzThemeTokenOf(aX, "on-" + cR)
		cSol = StzThemeTokenOf(aX, cR + "-solid")
		if cOn = "" or cSol = ""  loop  ok
		nW = StzContrastOf(cOn, cSol)
		if nW < nWorst  nWorst = nW  ok
	next
	? "   " + PadR(cT, 10) + " " + PadR("" + len(aX), 8) + nWorst + ":1"
	if nWorst < StzContrastMinimumBodyText()  nBadPair++  ok
next
chkeq("every exported theme's pairs clear the C3 minimum", nBadPair, 0)

#---------------------------------------------------------------------------
? ""
? "-- 5. Refusals ----------------------------------------------"
#---------------------------------------------------------------------------

chk("an unknown theme is REFUSED, not silently substituted", Raises('
	o = new stzTheme(:sparkle)
'))
chk("an empty name is refused", Raises('
	o = new stzTheme("")
'))
try
	oE = new stzTheme(:sparkle)
catch
	cMsg = cCatchError
done
? "   " + cMsg
chk("...and the message lists the themes", StzFindFirst("vibrant", cMsg) > 0)

#---------------------------------------------------------------------------
? ""
? "-- 6. The files -----------------------------------------------"
#---------------------------------------------------------------------------

write("theme_pro.css", cCss)
write("theme_pro.json", cJson)
write("theme_pro.ring", cRing)
? "   wrote theme_pro.css / .json / .ring"
? ""
? StzSubStr(cCss, 1, 210) + "..."

? ""
? "=============================================================="
? " VERDICT : " + iif(nBad = 0, "C5 PASSES -- the export is not decorative",
                     "C5 FAILS -- see above")
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

# Paint a small composition using ONLY the token list handed in -- so the
# live theme and the parsed file go through identical drawing code and any
# difference can only be the colours.
func _Paint aTokens, aWhich
	_o_ = new stzCanvas(360, 200)
	_o_.SetBackground(StzThemeTokenOf(aTokens, "background"))
	_k_ = 0
	_aC66_ = aWhich
	_nC66_ = len(_aC66_)
	for _iC66_ = 1 to _nC66_
		_c_ = _aC66_[_iC66_]
		if _c_ = "background"  loop  ok
		_v_ = StzThemeTokenOf(aTokens, _c_)
		if _v_ = ""  loop  ok
		_o_.Flush()
		_o_.FillQ(_v_).AddRoundRect(20 + (_k_ % 4) * 82,
			20 + floor(_k_ / 4) * 62, 70, 50, 8)
		_k_++
	next
	_o_.Flush()
	return _o_
