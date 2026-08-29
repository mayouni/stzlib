load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	C3 -- CONTRAST AS A NUMBER, AND A GATE OVER THE SHIPPED THEMES

	SOFTANZA_COLOR_SYSTEM.md, phase C3, kill criterion written first:

	    "if the existing themes cannot pass a stated minimum and cannot be
	     adjusted to, the minimum is wrong or the themes are -- either way
	     that is the finding, and it gets written down rather than lowered
	     quietly."

	So this file is allowed to fail, and if it does the failure is the
	deliverable. What it must NOT do is pick a threshold that the current
	themes happen to clear.

	StzContrastingText answers WHICH of black/white to use. It cannot answer
	"is this pair legible?", so nothing could refuse an illegible
	combination. A design system that cannot FAIL an accessibility check
	does not have one.

	Run:  ring gg_color_c3.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " C3 -- contrast as a number"
? "=============================================================="

#---------------------------------------------------------------------------
? ""
? "-- 1. Both metrics against their PUBLISHED anchors -----------"
#
# A metric nobody has checked against a known value is a number, not a
# measurement. These four are the values every implementation must
# reproduce, so they are what makes the gate below worth trusting.
#---------------------------------------------------------------------------

? "   WCAG  white on black : " + StzContrastOf(:White, :Black) + "   anchor 21.00"
? "   WCAG  white on white : " + StzContrastOf(:White, :White) + "   anchor  1.00"
? "   APCA  black on white : " + StzContrastLc(:Black, :White) + "   anchor ~106"
? "   APCA  white on black : " + StzContrastLc(:White, :Black) + "   anchor ~-108"

chk("WCAG hits 21.0 exactly", fabs(StzContrastOf(:White, :Black) - 21) < 0.02)
chk("WCAG hits 1.0 for a colour against itself",
    fabs(StzContrastOf(:White, :White) - 1) < 0.01)
chk("APCA reaches its published Lc for black on white",
    fabs(StzContrastLc(:Black, :White) - 106.04) < 1)
chk("APCA carries POLARITY (the reverse pair is negative)",
    StzContrastLc(:White, :Black) < -100)

#---------------------------------------------------------------------------
? ""
? "-- 2. THE GATE: every shipped theme, every role -------------"
#
# For each theme, each role colour is checked as a FILL carrying its
# on-colour, and the theme's own text/background pair is checked too. The
# minimum is WCAG 4.5:1 for body text -- the published figure, stated
# before the results were seen.
#---------------------------------------------------------------------------

nMin = StzContrastMinimumBodyText()
? "   minimum : " + nMin + ":1  (WCAG 2 body text)"
? ""
? "   theme      role         fill      on        ratio   verdict"
? "   --------   ----------   -------   -------   -----   -------"

aThemes = [ "neutral", "light", "dark", "vibrant", "pro", "access", "print" ]
# :MUTED joins the sweep, 42 pairs -> 49. It is family one's fifth value
# and it carries text like any other fill, so it is gated like any other
# fill. Background stays out -- it is a surface and holds no text -- and
# the three grey themes stay out, as they were.
aRoles = [ :primary, :success, :warning, :danger, :info, :muted, :neutral ]

nFail = 0
nChecked = 0
aFailures = []
_aCT53_ = aThemes
_nCT53_ = len(_aCT53_)
for _iCT53_ = 1 to _nCT53_
	cT = _aCT53_[_iCT53_]
	_aCR54_ = aRoles
	_nCR54_ = len(_aCR54_)
	for _iCR54_ = 1 to _nCR54_
		cR = _aCR54_[_iCR54_]
		cFill = StzThemeColor(cT, cR)
		if cFill = ""  loop  ok
		aBest = StzBestTextOn(cFill)
		nChecked++
		cV = "ok"
		if aBest[2] < nMin
			nFail++
			cV = "FAILS"
			aFailures + [ cT, cR, StzResolveColor(cFill), aBest[2] ]
		ok
		if cV = "FAILS" or cR = :primary
			? "   " + PadR(cT, 10) + " " + PadR("" + cR, 12) +
			  PadR(StzResolveColor(cFill), 10) + PadR(aBest[1], 10) +
			  PadR("" + aBest[2], 8) + cV
		ok
	next
next

? ""
? "   checked " + nChecked + " theme/role pairs, " + nFail + " below " + nMin + ":1"

if nFail > 0
	? ""
	? "   THE FAILURES, written down rather than explained away:"
	_aA55_ = aFailures
	_nA55_ = len(_aA55_)
	for _iA55_ = 1 to _nA55_
		a = _aA55_[_iA55_]
		? "     " + PadR(a[1], 10) + PadR("" + a[2], 12) + PadR(a[3], 10) +
		  "best achievable " + a[4] + ":1"
	next
ok

chkeq("every shipped theme role can carry legible text", nFail, 0)

#---------------------------------------------------------------------------
? ""
? "-- 3. C2's role steps, gated the same way -------------------"
#
# The steps were generated, not chosen, so they are the interesting case:
# nothing guaranteed :Danger.Text is readable on a page, or that :OnDanger
# is readable on :Danger.Solid.
#---------------------------------------------------------------------------

? "   role       .Text on white   :On<Role> on .Solid"
? "   --------   --------------   -------------------"
nStepFail = 0
_aCR56_ = [ :Primary, :Success, :Warning, :Danger, :Info ]
_nCR56_ = len(_aCR56_)
for _iCR56_ = 1 to _nCR56_
	cR = _aCR56_[_iCR56_]
	nT = StzContrastOf("" + cR + ".Text", :White)
	nO = StzContrastOf("On" + cR, "" + cR + ".Solid")
	? "   " + PadR("" + cR, 10) + " " + PadR("" + nT, 16) + nO
	if nT < nMin  nStepFail++  ok
	if nO < nMin  nStepFail++  ok
next
chkeq("every generated step pair is legible", nStepFail, 0)

#---------------------------------------------------------------------------
? ""
? "-- 4. The gate can REFUSE (or it is not a gate) -------------"
#
# The negative sibling. A checker that always answered "legible" would
# pass every line above.
#---------------------------------------------------------------------------

chk("mid-grey on white is REFUSED", NOT StzIsLegible("#999999", :White))
chk("black on white passes", StzIsLegible(:Black, :White))
chk("a colour on itself is refused", NOT StzIsLegible(:Danger, :Danger))
? "   #999999 on white : " + StzContrastOf("#999999", :White) + ":1  (below " + nMin + ")"
? "   large-text minimum is lower, and named : " +
  StzContrastMinimumLargeText() + ":1"
chk("the large-text minimum is a DIFFERENT, named number",
    StzContrastMinimumLargeText() < StzContrastMinimumBodyText())

#---------------------------------------------------------------------------
? ""
? "-- 5. WCAG and APCA are not one metric twice ----------------"
#
# The first version of this scene picked four pairs by hand and ASSERTED
# that the two metrics would disagree. They agreed on all four, and the
# assertion failed -- which said nothing about the metrics and everything
# about choosing four pairs to make a point.
#
# So: SWEEP. A grid of greys against both a light and a dark ground, and
# report the rate at which the verdicts differ. A rate, unlike four
# examples, cannot be cherry-picked.
#---------------------------------------------------------------------------

nPairs = 0
nDiffer = 0
cFirst = ""
for nG = 0 to 255 step 5
	cG = StzRGBToHex(nG, nG, nG)
	_aCBg57_ = [ "#FFFFFF", "#000000", "#767676" ]
	_nCBg57_ = len(_aCBg57_)
	for _iCBg57_ = 1 to _nCBg57_
		cBg = _aCBg57_[_iCBg57_]
		nW = StzContrastOf(cG, cBg)
		nA = fabs(StzContrastLc(cG, cBg))
		nPairs++
		# WCAG 4.5 is the body-text line; Lc 60 is APCA's rough equivalent
		if (nW >= 4.5) != (nA >= 60)
			nDiffer++
			if cFirst = ""
				cFirst = cG + " on " + cBg + "  WCAG " + nW + "  Lc " + nA
			ok
		ok
	next
next

? "   swept " + nPairs + " grey/ground pairs"
? "   verdicts differ on " + nDiffer + "  (" + floor(nDiffer * 100 / nPairs) + "%)"
if cFirst != ""
	? "   first disagreement : " + cFirst
ok
chk("the two metrics reach different verdicts somewhere", nDiffer > 0)
? "   (WCAG 2 is known to be generous in the dark mid-tones; that band is"
? "    where the disagreements land, and it is why both are carried.)"

? ""
? "-- 4. :MUTED -- family one's fifth value ---------------------"
#
# Rule 118 names five values in family one and this plane shipped four.
# What it did NOT ship was not a hue: a single grey would render a WAITING
# DANGER and a WAITING SUCCESS identically, which asserts they are the
# same fact, and they are not. So muting is a TREATMENT -- hold the hue,
# keep a quarter of the chroma, travel four tenths of the way to the
# surface rung -- and the enumerated value is that treatment applied to
# the one thing carrying no status.
#
# Four claims, each of which could be false.
#---------------------------------------------------------------------------

? ""
? "   value      live      muted     hue    text"
aMuteC = [ :Danger, :Success, :Warning, :Info ]
nMuteHueDrift = 0
nMuteUnread = 0
aMuteHex = []
for i = 1 to len(aMuteC)
	cLive = StzResolveColor(aMuteC[i])
	cMute = StzMutedOf(aMuteC[i])
	aMuteHex + cMute
	nHl = StzEngineColorHue(_Rgb24C3(cLive))
	nHm = StzEngineColorHue(_Rgb24C3(cMute))
	nD = fabs(nHl - nHm)
	if nD > 180  nD = 360 - nD  ok
	if nD > 12  nMuteHueDrift++  ok
	nR = StzBestTextOn(cMute)[2]
	if nR < StzContrastMinimumBodyText()  nMuteUnread++  ok
	? "   " + PadR("" + aMuteC[i], 10) + PadR(cLive, 10) + PadR(cMute, 10) +
	  PadR("" + ceil(nD), 7) + "" + nR + ":1"
next

# 1 · A MUTED STATUS IS STILL THAT STATUS. The hue survives, so a waiting
#     danger and a waiting success stay different things.
? "   statuses whose hue drifted when muted : " + nMuteHueDrift
chkeq("muting holds the hue -- a waiting danger is still a danger",
      nMuteHueDrift, 0)

nMuteSame = 0
for i = 1 to len(aMuteHex)
	for j = i + 1 to len(aMuteHex)
		if aMuteHex[i] = aMuteHex[j]  nMuteSame++  ok
	next
next
? "   muted statuses that collapsed onto each other : " + nMuteSame
chkeq("...and no two of them become one grey", nMuteSame, 0)

# 2 · IT IS STILL A FILL. Muted is not "unstyled", it carries text.
? "   muted statuses that cannot carry text : " + nMuteUnread
chkeq("a muted fill still reads", nMuteUnread, 0)

# 3 · :MUTED IS NOT :NEUTRAL. Different families, so they must not be the
#     same colour -- and the standalone value must resolve with no theme.
cMutedStandalone = StzResolveColor(:Muted)
? "   :Muted " + cMutedStandalone + " vs :Neutral " + StzResolveColor(:Neutral)
chk("the fifth value resolves on its own, with no theme in force",
    cMutedStandalone != "" and StzTryResolveColor(:Muted) != "")
chk("...and family one's muted is not family two's neutral",
    cMutedStandalone != StzResolveColor(:Neutral))
chkeq("it is exactly the treatment applied to neutral -- ONE mechanism",
      cMutedStandalone, StzMutedOf(:Neutral))

# 4 · EVERY THEME NAMES IT, and where the theme distinguishes neutral from
#     primary at all, it distinguishes muted from neutral too. The three
#     wholly white themes are exempt by their own construction rather than
#     by a list of names: they already collapse primary onto neutral.
nThemeMissing = 0
nThemeFlat = 0
aAllThemes = StzColorThemes()
for i = 1 to len(aAllThemes)
	cT = aAllThemes[i]
	cM = StzThemeColor(cT, :muted)
	if cM = ""  nThemeMissing++  loop  ok
	cN = StzResolveColor(StzThemeColor(cT, :neutral))
	cP = StzResolveColor(StzThemeColor(cT, :primary))
	if cN = cP  loop  ok
	if StzResolveColor(cM) = cN
		nThemeFlat++
		? "   " + cT + " renders muted as its own neutral"
	ok
next
? "   themes with no muted role : " + nThemeMissing +
  " , themes where muted = neutral : " + nThemeFlat
chkeq("every shipped theme names the fifth value", nThemeMissing, 0)
chkeq("...and states it where it states a neutral at all", nThemeFlat, 0)

? ""
? "=============================================================="
? " VERDICT : " + iif(nBad = 0, "C3 PASSES -- the themes clear the stated minimum",
                     "C3 FAILS -- see the failures above; they are the finding")
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

func _Rgb24C3 cHex
	_a_ = StzHexToRGB(cHex)
	return _a_[1] * 65536 + _a_[2] * 256 + _a_[3]

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
