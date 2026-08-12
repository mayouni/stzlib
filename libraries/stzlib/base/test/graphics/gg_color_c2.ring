load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	C2 -- ROLE STEPS: a step that says WHAT FOR, not how light

	SOFTANZA_COLOR_SYSTEM.md, phase C2, kill criterion written first:

	    "if the six steps cannot be told apart in a rendered picture, they
	     are ceremony; keep the solid and the pair only."

	So this file has to answer a question that can come back NO, and the
	answer has to be measured in the picture rather than in the numbers
	that produced it.

	    :Danger.Surface   a tinted container background
	    :Danger.Border    a border that reads against Surface
	    :Danger.Solid     the filled control
	    :Danger.Text      text on the app background
	    :OnDanger         what can be READ on the solid

	Run:  ring gg_color_c2.ring
---------------------------------------------------------------------------*/

decimals(3)
nOk = 0  nBad = 0
aRoles = [ :Primary, :Success, :Warning, :Danger, :Info ]
aSteps = StzRoleStepNames()

? "=============================================================="
? " C2 -- role steps"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. The four steps, per role ------------------------------"
#---------------------------------------------------------------------------

? "   role       surface   border    solid     text      on"
? "   --------   -------   -------   -------   -------   -----"
for cR in aRoles
	cRow = "   " + PadR("" + cR, 9) + " "
	for cS in aSteps
		cRow += PadR(StzResolveColor("" + cR + "." + cS), 10)
	next
	? cRow + StzResolveColor("On" + cR)
next

#---------------------------------------------------------------------------
? ""
? "-- 2. THE KILL CRITERION: told apart in the PICTURE ---------"
#
# Not "the hex strings differ" -- two hexes one unit apart differ and are
# the same colour to a reader. Each step is RENDERED and the pixels
# compared, so the question is answered by the picture.
#---------------------------------------------------------------------------

if NOT StzGraphicsDevice()
	? "   (no device -- the kill criterion is a pixel property; SKIPPED,"
	? "    which means C2 is UNJUDGED on this machine, not passed)"
else
	SW = 150  SH = 90
	nWorst = 999
	cWorstPair = ""
	for cR in aRoles
		oC = new stzCanvas(len(aSteps) * SW, SH)
		k = 0
		for cS in aSteps
			oC.Flush()
			oC.FillQ("" + cR + "." + cS).AddRect(k * SW, 0, SW, SH)
			k++
		next
		cPx = oC.ToPixels()
		# every PAIR of steps, compared at the centre of its swatch
		for i = 1 to len(aSteps)
			for j = i + 1 to len(aSteps)
				nD = _PixDiff(cPx, len(aSteps) * SW,
					(i - 1) * SW + SW / 2, SH / 2,
					(j - 1) * SW + SW / 2, SH / 2)
				if nD < nWorst
					nWorst = nD
					cWorstPair = "" + cR + " " + aSteps[i] + "/" + aSteps[j]
				ok
			next
		next
	next
	? "   closest pair of rendered steps : " + nWorst + " (sum |rgb|)"
	? "   the closest was " + cWorstPair
	? ""
	? "   A pair under ~30 would be two names for one colour."
	chk("every pair of steps is visibly different", nWorst > 30)
ok

#---------------------------------------------------------------------------
? ""
? "-- 3. The steps are ORDERED, and the order is the point -----"
#
# surface lightest, then border, then solid, then text. If the order broke
# a caller could not reason about which step sits on which.
#---------------------------------------------------------------------------

nBadOrder = 0
for cR in aRoles
	aL = []
	for cS in aSteps
		aL + _L("" + cR + "." + cS)
	next
	for i = 1 to len(aL) - 1
		if aL[i] <= aL[i + 1]  loop  ok
	next
	cRow = "   " + PadR("" + cR, 9)
	bOk = TRUE
	for i = 1 to len(aL) - 1
		if aL[i] <= aL[i + 1]  bOk = FALSE  ok
		cRow += " " + aL[i]
	next
	cRow += " " + aL[len(aL)]
	if NOT bOk  nBadOrder++  ok
	? cRow + "   " + iif(bOk, "ordered", "OUT OF ORDER")
next
chkeq("every role's steps run light to dark", nBadOrder, 0)

#---------------------------------------------------------------------------
? ""
? "-- 4. .Solid NORMALISES the weight across roles -------------"
#
# This is the quiet win and it is worth stating, because it is also a
# small DEPARTURE: :Danger.Solid is not byte-identical to :Danger. It is
# :Danger re-lit to the common solid lightness -- so :Danger.Solid and
# :Success.Solid carry the SAME visual weight, which raw #FF0000 and
# #008000 emphatically do not.
#---------------------------------------------------------------------------

? "   raw name        L        .Solid          L"
nMinS = 9  nMaxS = 0
nMinR = 9  nMaxR = 0
for cR in aRoles
	nRaw = _L("" + cR)
	nSol = _L("" + cR + ".Solid")
	if nRaw < nMinR  nMinR = nRaw  ok
	if nRaw > nMaxR  nMaxR = nRaw  ok
	if nSol < nMinS  nMinS = nSol  ok
	if nSol > nMaxS  nMaxS = nSol  ok
	? "   " + PadR("" + cR, 10) + PadR("" + nRaw, 9) +
	  PadR(StzResolveColor("" + cR + ".Solid"), 16) + nSol
next
? ""
? "   raw names span   L " + nMinR + " .. " + nMaxR + "   (spread " + (nMaxR - nMinR) + ")"
? "   .Solid steps span L " + nMinS + " .. " + nMaxS + "   (spread " + (nMaxS - nMinS) + ")"
chk("the raw names are NOT of equal weight", (nMaxR - nMinR) > 0.15)
chk("...and .Solid makes them so", (nMaxS - nMinS) < 0.02)

#---------------------------------------------------------------------------
? ""
? "-- 5. The PAIR: :OnX must be legible on X ------------------"
#---------------------------------------------------------------------------

nBadPair = 0
for cR in aRoles
	cOn = StzResolveColor("On" + cR)
	cSolid = StzResolveColor("" + cR + ".Solid")
	nD = fabs(StzColorLuminance(cOn) - StzColorLuminance(cSolid))
	? "   " + PadR("" + cR, 9) + " solid " + PadR(cSolid, 9) +
	  " on " + PadR(cOn, 9) + " luminance gap " + floor(nD)
	if nD < 90  nBadPair++  ok
next
chkeq("every pair clears a luminance gap of 90", nBadPair, 0)

# the negative sibling: the pair must not be constant
chk("the pair is not always the same colour",
    StzResolveColor("OnWarning") != StzResolveColor("OnPrimary"))

#---------------------------------------------------------------------------
? ""
? "-- 6. Every face takes them; refusals still refuse ----------"
#---------------------------------------------------------------------------

chk("the canvas takes a role step", StzColorToNumber("Danger.Surface") != 0)
chk("...and the pair", StzColorToNumber("OnDanger") != 0)
chkeq("an unknown STEP is refused", StzTryResolveColor("danger.sparkle"), "")
chkeq("an unknown BASE is refused", StzTryResolveColor("sparkle.surface"), "")
# 'orange' begins with the letters of the pair prefix and must survive
chk("a name that merely STARTS with 'on' is not eaten",
    StzTryResolveColor("orange") = "#FFA500")

#---------------------------------------------------------------------------
? ""
? "-- 7. See it -------------------------------------------------"
#---------------------------------------------------------------------------

if StzGraphicsDevice()
	oFont = NULL
	if fexists("C:/Windows/Fonts/segoeui.ttf")
		oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
	ok
	CW = 210  CH = 128
	oS = new stzCanvas(len(aRoles) * CW, CH + 46)
	oS.SetBackground(:White)
	k = 0
	for cR in aRoles
		x = k * CW + 12
		# surface panel, border, solid chip, text -- each step doing its job
		oS.Flush()
		oS.FillQ("" + cR + ".Surface").StrokeQ("" + cR + ".Border", 2).
			AddRoundRect(x, 22, CW - 24, CH, 10)
		oS.Flush()
		oS.FillQ("" + cR + ".Solid").AddRoundRect(x + 16, CH - 34, CW - 56, 34, 8)
		if isObject(oFont)
			oS.Flush()
			oS.AddTextQ("" + cR, x + 16, 56).SetFontQ(oFont, 17).
				Color("" + cR + ".Text")
			nTw = oFont.WidthOf("action", 14)
			oS.Flush()
			oS.AddTextQ("action", x + 16 + (CW - 56 - nTw) / 2, CH - 12).
				SetFontQ(oFont, 14).Color("On" + cR)
		ok
		k++
	next
	oS.ToPNG("c2_role_steps.png")
	write("c2_role_steps.svg", oS.ToSVG())
	? "   wrote c2_role_steps.png"
	? "   each card: Surface panel, Border outline, Text heading,"
	? "   Solid chip labelled in On<Role>."
ok

? ""
? "=============================================================="
? " VERDICT : " + iif(nBad = 0, "C2 PASSES -- the steps earn their names",
                     "C2 FAILS -- keep the solid and the pair only")
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

# Oklab lightness of any colour expression, through the engine.
func _L cExpr
	_a_ = StzHexToRGB(StzResolveColor(cExpr))
	return StzEngineColorLightness(_a_[1] * 65536 + _a_[2] * 256 + _a_[3])

func _PixDiff cPx, nW, nX1, nY1, nX2, nY2
	_a_ = (floor(nY1) * nW + floor(nX1)) * 4 + 1
	_b_ = (floor(nY2) * nW + floor(nX2)) * 4 + 1
	if _a_ + 2 > len(cPx) or _b_ + 2 > len(cPx)  return 0  ok
	return fabs(ascii(substr(cPx, _a_, 1)) - ascii(substr(cPx, _b_, 1))) +
	       fabs(ascii(substr(cPx, _a_ + 1, 1)) - ascii(substr(cPx, _b_ + 1, 1))) +
	       fabs(ascii(substr(cPx, _a_ + 2, 1)) - ascii(substr(cPx, _b_ + 2, 1)))
