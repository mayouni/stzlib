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
aRoles = [ :primary, :success, :warning, :danger, :info, :neutral ]

nFail = 0
nChecked = 0
aFailures = []
for cT in aThemes
	for cR in aRoles
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
	for a in aFailures
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
for cR in [ :Primary, :Success, :Warning, :Danger, :Info ]
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
	for cBg in [ "#FFFFFF", "#000000", "#767676" ]
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

func PadR c, n
	_s_ = "" + c
	while len(_s_) < n  _s_ += " "  end
	return _s_
