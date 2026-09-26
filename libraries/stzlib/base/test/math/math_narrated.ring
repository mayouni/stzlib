# MATH_NARRATED -- the gate of the mathematics plane (base/math/).
#
# ONE PROCESS, MANY ASSERTIONS. Iterate on the probes beside this file;
# run this once per task, before the commit, in the background. Every
# section prints its wall time as the next banner arrives, so a section
# over budget can be named. A scoped run is not offered: the gate is small
# enough to run whole, and when it is not, it will print what it skipped.
#
# What it proves, and the law each proof serves (base/math/CHARTER.md):
#
#   1. y = f(x) is DECLARED, COMPUTED, then SOLVED (law 4): the samples
#      agree with an independent computation, the zeros are the multiples
#      of pi, the extrema satisfy tan x = x, and every note is near its
#      mark by arithmetic re-derived from the solved shapes.
#   2. the parametric and polar forms compute what they declare.
#   3. a pole breaks the curve; a window bounds it; the sign change across
#      a pole is NOT a zero -- the negative sibling of section 1.
#   4. a wrong declaration is refused by name, at the line that made it.
#   5. the one gate judges a figure: six lawful pictures, zero findings;
#      the witness, exactly the three it plants.
#   6. the SVG is the same bytes: an expectation GENERATED from the bytes
#      and committed; a different declaration gives different bytes.
#   7. a figure is an entry object that answers for itself (law 1).
#
# Run from this directory:  ring math_narrated.ring

load "../../stzBase.ring"
load "math_scenes.ring"

nOk = 0
nBad = 0
nSecClock = 0
acSkipped = []
? "=============================================================="
? " MATH GATE -- the mathematics plane, M1a: the :Function figure"
? "=============================================================="

PI = 3.14159265358979

#---------------------------------------------------------------------------

sec("-- 1. y = f(x) IS DECLARED, COMPUTED, THEN SOLVED ---------------------")

oF1 = StzMathFigScene01()
oF1.Layout()
chkeq("the declaration asked for 400 samples and 400 were computed", oF1.SampleCount(), 400)
chkeq("the cardinal sine is one unbroken piece", oF1.PieceCount(), 1)
chkeq("drawn as seven runs of at most 64 controls, sharing endpoints", oF1.RunCount(), 7)
chk("and the picture is lawful", oF1.IsSolved())

# TWO READINGS OF ONE TRUTH. The samples were computed on the engine's
# tape; here every one is read back from the pixels through the window
# and compared with Ring's own sin(x)/x -- a different computation over
# the same numbers, which is what a self-check needs to mean anything.
aW = oF1.Window()
oS1 = oF1.Substance()
nX0 = oS1.DataOf("fr", "x0")  nY0 = oS1.DataOf("fr", "y0")
nX1 = oS1.DataOf("fr", "x1")  nY1 = oS1.DataOf("fr", "y1")
nWorst = 0
nSeen = 0
acRuns = oS1.ObjectsOfType("Curve")
for iR = 1 to len(acRuns)
	nN = oS1.DataOf(acRuns[iR], "n")
	for v = 1 to nN
		nPx = oS1.DataOf(acRuns[iR], "x" + v)
		nPy = oS1.DataOf(acRuns[iR], "y" + v)
		x = aW[1] + (nPx - nX0) * (aW[2] - aW[1]) / (nX1 - nX0)
		y = aW[4] - (nPy - nY0) * (aW[4] - aW[3]) / (nY1 - nY0)
		nD = fabs(y - sin(x) / x)
		if nD > nWorst  nWorst = nD  ok
		nSeen++
	next
next
chkeq("the runs carry every sample once, plus the six shared endpoints", nSeen, 406)
chk("every sample read back from the pixels is Ring's own sin(x)/x to 1e-9  [worst " + nWorst + "]",
    nWorst < 0.000000001)

# THE ZEROS ARE THE MULTIPLES OF PI -- known independently of any search
aZ = oF1.Zeros()
chkeq("six zeros were found on [-12, 12]", len(aZ), 6)
bZ = TRUE
for i = 1 to len(aZ)
	nK = floor(fabs(aZ[i][1]) / PI + 0.5)
	if fabs(fabs(aZ[i][1]) - nK * PI) > 0.00000001 or nK < 1 or nK > 3  bZ = FALSE  ok
next
chk("and every one is k * pi for k in 1..3, to 1e-8", bZ)
bZv = TRUE
for i = 1 to len(aZ)
	if fabs(aZ[i][2]) > 0.000000001  bZv = FALSE  ok
next
chk("and the value at every zero is under 1e-9", bZv)

# THE EXTREMA SATISFY tan x = x: the derivative of sin(x)/x vanishes
# exactly where x cos x = sin x, a mechanism the search never used
aE = oF1.Extrema()
chkeq("seven extrema were found -- the peak at 0 and three on each side", len(aE), 7)
bE = TRUE
for i = 1 to len(aE)
	x = aE[i][1]
	if fabs(x * cos(x) - sin(x)) > 0.000001  bE = FALSE  ok
next
chk("and every one satisfies x cos x = sin x to 1e-6", bE)
bPeak = FALSE
for i = 1 to len(aE)
	if fabs(aE[i][1]) < 0.000001 and fabs(aE[i][2] - 1) < 0.000001  bPeak = TRUE  ok
next
chk("the peak is at (0, 1)", bPeak)

# THE SOLVED HALF: every note is within its leash of its mark, and off
# both axes, by plain arithmetic over the solved shapes
oD1 = oF1.Diagram()
chkeq("nine notes were solved -- two unknowns each, an offset from their own mark", oD1.NumberOfUnknowns(), 18)
chkeq("of thirteen marks; the cap named nine and the frame says four were left", oS1.DataOf("fr", "marksleft"), 4)
bNear = TRUE  bOffAx = TRUE
aAx = oD1.ShapeOf("ax.icon")
aAy = oD1.ShapeOf("ay.icon")
aDefs = oS1.Definitions()
nNotes = 0
for i = 1 to len(aDefs)
	if aDefs[i][2] != "Note"  loop  ok
	nNotes++
	aT = oD1.ShapeOf(aDefs[i][1] + ".text")
	aM = oD1.ShapeOf(aDefs[i][3][1] + ".icon")
	nD = sqrt(pow(aT[:cx] - aM[:cx], 2) + pow(aT[:cy] - aM[:cy], 2))
	if nD > 40 + aT[:w] / 2 + 0.5  bNear = FALSE  ok
	# a text box straddling an axis line covers it
	if fabs(aT[:cy] - aAx[:y1]) < aT[:h] / 2 and aT[:cx] - aT[:w] / 2 < aAx[:x2] and aT[:cx] + aT[:w] / 2 > aAx[:x1]
		bOffAx = FALSE
	ok
	if fabs(aT[:cx] - aAy[:x1]) < aT[:w] / 2 and aT[:cy] - aT[:h] / 2 < aAy[:y1] and aT[:cy] + aT[:h] / 2 > aAy[:y2]
		bOffAx = FALSE
	ok
next
chkeq("nine notes are defined over their marks", nNotes, 9)
chk("every note stands within 40 px plus half its width of its mark", bNear)
chk("and no note's box covers either axis", bOffAx)

# THE DOCUMENT CHANNEL: the curve's runs and the marks are named elements
cSvg1 = oF1.ToSVG()
chk('the first run is <g id="c1"> to a consumer', len(StzFindCS('id="c1" class="spline', cSvg1, TRUE)) = 1)
chk("and the seventh run is there too", len(StzFindCS('id="c7" class="spline', cSvg1, TRUE)) = 1)
chk("NEGATIVE: there is no eighth run", len(StzFindCS('id="c8"', cSvg1, TRUE)) = 0)
chk("a mark is a named circle", len(StzFindCS('id="m1" class="circle', cSvg1, TRUE)) = 1)

#---------------------------------------------------------------------------

sec("-- 2. PARAMETRIC AND POLAR FORMS COMPUTE WHAT THEY DECLARE -------------")

oF3 = StzMathFigScene03()
oF3.Layout()
chk("the Lissajous figure is lawful", oF3.IsSolved())
# x = cos t, y = sin 2t satisfies y^2 = 4 x^2 (1 - x^2) -- an identity the
# builder never used, checked on every sample read back from the pixels
aW = oF3.Window()
oS3 = oF3.Substance()
nX0 = oS3.DataOf("fr", "x0")  nY0 = oS3.DataOf("fr", "y0")
nX1 = oS3.DataOf("fr", "x1")  nY1 = oS3.DataOf("fr", "y1")
nWorst = 0
acRuns = oS3.ObjectsOfType("Curve")
for iR = 1 to len(acRuns)
	nN = oS3.DataOf(acRuns[iR], "n")
	for v = 1 to nN
		x = aW[1] + (oS3.DataOf(acRuns[iR], "x" + v) - nX0) * (aW[2] - aW[1]) / (nX1 - nX0)
		y = aW[4] - (oS3.DataOf(acRuns[iR], "y" + v) - nY0) * (aW[4] - aW[3]) / (nY1 - nY0)
		nD = fabs(y * y - 4 * x * x * (1 - x * x))
		if nD > nWorst  nWorst = nD  ok
	next
next
chk("every sample satisfies y^2 = 4x^2(1 - x^2) to 1e-9  [worst " + nWorst + "]", nWorst < 0.000000001)
aM3 = oF3.Marks()
chkeq("two points were named by their parameter", len(aM3), 2)
chk("t = 0 is (1, 0)", fabs(aM3[1][2] - 1) < 0.000001 and fabs(aM3[1][3]) < 0.000001)
chk("t = pi/2 is (0, 0) to the precision of the declared 1.5708", fabs(aM3[2][2]) < 0.0001 and fabs(aM3[2][3]) < 0.0001)
chk("the window holds the whole figure with air: x in [-1.16, 1.16], y symmetric and wider than the figure",
    fabs(aW[1] + 1.16) < 0.01 and fabs(aW[2] - 1.16) < 0.01 and aW[3] < -1.05 and aW[4] > 1.05 and fabs(aW[3] + aW[4]) < 0.000001)

oF4 = StzMathFigScene04()
oF4.Layout()
chk("the rose is lawful, with nothing to solve", oF4.IsSolved() and oF4.Diagram().NumberOfUnknowns() = 0)
# r = cos 3t: every sample satisfies x^2 + y^2 = cos^2(3 atan2(y, x)),
# whichever sign r took -- the square erases the half-turn
aW = oF4.Window()
oS4 = oF4.Substance()
nX0 = oS4.DataOf("fr", "x0")  nY0 = oS4.DataOf("fr", "y0")
nX1 = oS4.DataOf("fr", "x1")  nY1 = oS4.DataOf("fr", "y1")
nWorst = 0
acRuns = oS4.ObjectsOfType("Curve")
for iR = 1 to len(acRuns)
	nN = oS4.DataOf(acRuns[iR], "n")
	for v = 1 to nN
		x = aW[1] + (oS4.DataOf(acRuns[iR], "x" + v) - nX0) * (aW[2] - aW[1]) / (nX1 - nX0)
		y = aW[4] - (oS4.DataOf(acRuns[iR], "y" + v) - nY0) * (aW[4] - aW[3]) / (nY1 - nY0)
		if x * x + y * y < 0.000000000001  loop  ok
		nD = fabs(x * x + y * y - pow(cos(3 * atan2(y, x)), 2))
		if nD > nWorst  nWorst = nD  ok
	next
next
chk("every sample of the rose satisfies r^2 = cos^2(3t) to 1e-9  [worst " + nWorst + "]", nWorst < 0.000000001)

#---------------------------------------------------------------------------

sec("-- 3. A POLE BREAKS THE CURVE; A WINDOW BOUNDS IT; A POLE IS NOT A ZERO -")

oF5 = StzMathFigScene05()
oF5.Layout()
chkeq("y = 1/x on [-2, 2] is two pieces", oF5.PieceCount(), 2)
chk("and lawful", oF5.IsSolved())
oS5 = oF5.Substance()
aW = oF5.Window()
chk("the window is the author's: y in [-6, 6]", aW[3] = -6 and aW[4] = 6)
chkeq("the figure says it was clipped to the window", oS5.DataOf("fr", "clipped"), 1)
# no run crosses the pole: every run lies wholly left or wholly right of 0
bSide = TRUE
nX0 = oS5.DataOf("fr", "x0")  nX1 = oS5.DataOf("fr", "x1")
acRuns = oS5.ObjectsOfType("Curve")
for iR = 1 to len(acRuns)
	nN = oS5.DataOf(acRuns[iR], "n")
	xa = aW[1] + (oS5.DataOf(acRuns[iR], "x1") - nX0) * (aW[2] - aW[1]) / (nX1 - nX0)
	xb = aW[1] + (oS5.DataOf(acRuns[iR], "x" + nN) - nX0) * (aW[2] - aW[1]) / (nX1 - nX0)
	if (xa < 0) != (xb < 0)  bSide = FALSE  ok
next
chk("no run of the curve crosses the pole at 0", bSide)
chkeq("NEGATIVE: the cardinal sine, which is finite everywhere, is one piece", oF1.PieceCount(), 1)

oF6 = StzMathFigScene06()
oF6.Layout()
chkeq("y = tan x on [-4.5, 4.5] is three pieces", oF6.PieceCount(), 3)
chk("and lawful", oF6.IsSolved())
aZ6 = oF6.Zeros()
chkeq("only its three TRUE zeros are marked", len(aZ6), 3)
bNoPole = TRUE
for i = 1 to len(aZ6)
	if fabs(fabs(aZ6[i][1]) - PI / 2) < 0.01  bNoPole = FALSE  ok
next
chk("NEGATIVE: the sign change across the pole at pi/2 is NOT a zero", bNoPole)
bTrue = TRUE
for i = 1 to len(aZ6)
	if fabs(sin(aZ6[i][1])) > 0.00000001  bTrue = FALSE  ok
next
chk("and each marked zero has sin x = 0 to 1e-8", bTrue)

oF2 = StzMathFigScene02()
oF2.Layout()
chk("the cubic with its tangent is lawful", oF2.IsSolved())
oS2 = oF2.Substance()
chk("the tangent's slope at 1.2 is 3x^2 - 1 = 3.32, from the tape", fabs(oS2.DataOf("tg", "slope") - 3.32) < 0.000001)
aTg = oF2.ShapeOf("tg.icon")
chk("and the tangent stays inside the frame -- it was clipped, not refused",
    aTg[:x2] <= oS2.DataOf("fr", "x1") + 0.01 and aTg[:x1] >= oS2.DataOf("fr", "x0") - 0.01)
aZ2 = oF2.Zeros()
chkeq("the cubic's three zeros are found", len(aZ2), 3)
bCubic = TRUE
for i = 1 to len(aZ2)
	x = aZ2[i][1]
	if fabs(x) > 0.00000001 and fabs(fabs(x) - 1) > 0.00000001  bCubic = FALSE  ok
next
chk("and they are -1, 0 and 1 to 1e-8", bCubic)
aE2 = oF2.Extrema()
bSq3 = TRUE
for i = 1 to len(aE2)
	if fabs(fabs(aE2[i][1]) - 1 / sqrt(3)) > 0.00000001  bSq3 = FALSE  ok
next
chk("its two extrema are at +-1/sqrt(3) to 1e-8", len(aE2) = 2 and bSq3)

#---------------------------------------------------------------------------

sec("-- 4. A WRONG DECLARATION IS REFUSED BY NAME ---------------------------")

chk("no expression is refused", _MgRefuses([ :on = [ 0, 1 ] ], "say what to draw"))
chk("a range running backwards is refused", _MgRefuses([ :f = "x", :on = [ 1, 0 ] ], "runs backwards"))
chk("too few samples are refused", _MgRefuses([ :f = "x", :on = [ 0, 1 ], :samples = 3 ], "8 to 4000"))
chk("a key the figure lacks is refused with the list", _MgRefuses([ :f = "x", :on = [ 0, 1 ], :colour = "red" ], "is not a key"))
chk("a mark that is not :zeros, :extrema or a number is refused", _MgRefuses([ :f = "x", :on = [ 0, 1 ], :mark = [ :poles ] ], "is not a mark"))
chk("a tangent off the range is refused", _MgRefuses([ :f = "x", :on = [ 0, 1 ], :tangent = 5 ], "not on the range"))
chk("a function finite nowhere on its range is refused", _MgRefuses([ :f = "sqrt(x)", :on = [ -3, -1 ] ], "finite nowhere"))
chk("an expression the tape cannot read is refused with the reason", _MgRefuses([ :f = "sin(x", :on = [ 0, 1 ] ], "Can't read"))
chk(":zeros on a polar curve is refused -- zeros belong to y = f(x)", _MgRefuses([ :r = "cos(t)", :t = [ 0, 3 ], :mark = [ :zeros ] ], "marks of y = f(x)"))
chk("a figure kind this plane lacks is refused with the kinds", _MgRefusesKind(:Histogram, "not a figure kind"))
chk("NEGATIVE: the lawful forms of all of these are accepted", NOT _MgRefuses([ :f = "sin(x)", :on = [ 0, 6 ], :samples = 64, :mark = [ :zeros, 1 ], :tangent = 1, :label = "ok" ], ""))

#---------------------------------------------------------------------------

sec("-- 5. THE ONE GATE JUDGES A FIGURE ------------------------------------")

aGp = []
aGp + [ "function/sinc", oF1.Diagram() ]
aGp + [ "function/cubic", oF2.Diagram() ]
aGp + [ "function/lissajous", oF3.Diagram() ]
aGp + [ "function/rose", oF4.Diagram() ]
aGp + [ "function/hyperbola", oF5.Diagram() ]
aGp + [ "function/tan", oF6.Diagram() ]
oGRep = StzCheckPictures(aGp)
chkeq("six lawful figures, judged by the one gate, raise no finding", oGRep.NumberOfFindings(), 0)

oW = StzMathFigWitness()
aWm = StzMathFigWitnessMarks(oW)
oWRep = StzCheckPictures([ [ "function/witness", oW.Diagram() ] ])
acRules = []
aWf = oWRep.Findings()
for i = 1 to len(aWf)
	acRules + ("" + aWf[i][:rule])
next
chk("the witness's zero between same-sign samples is found by zero_brackets_a_sign_change",
    _MgHas(acRules, "zero_brackets_a_sign_change"))
chk("its extremum with no turn is found by extremum_brackets_a_turn",
    _MgHas(acRules, "extremum_brackets_a_turn"))
chk("its note out of reach is found by note_reads_near_its_mark",
    _MgHas(acRules, "note_reads_near_its_mark"))
chk("and each finding names the mark by its place", _MgMessageHas(aWf, "x = "))
chk("NEGATIVE: the untouched marks raise nothing -- exactly one finding per rule planted",
    _MgCount(acRules, "zero_brackets_a_sign_change") = 1 and _MgCount(acRules, "extremum_brackets_a_turn") = 1 and
    _MgCount(acRules, "note_reads_near_its_mark") = 1)

#---------------------------------------------------------------------------

sec("-- 6. THE SVG IS THE SAME BYTES ----------------------------------------")

# THE EXPECTATION IS GENERATED FROM THE BYTES, NOT TYPED (the discipline
# plot.zig set for the text renderers): the first run writes it and FAILS
# by name, so a missing expectation is never a green; every later run
# compares byte for byte. A different declaration must give different
# bytes, or the comparison proves nothing.
cExpect = "expect/fig_01.svg"
if NOT fexists(cExpect)
	write(cExpect, cSvg1)
	chk("EXPECTATION GENERATED at " + cExpect + " -- commit it and run again", FALSE)
else
	cWant = read(cExpect)
	chk("the cardinal sine's SVG is byte for byte the committed expectation  [" + len(cSvg1) + " bytes]",
	    cSvg1 = cWant)
	if cSvg1 != cWant
		write("expect/fig_01.got.svg", cSvg1)
		? "        (the bytes this run produced are in expect/fig_01.got.svg)"
	ok
ok
oF1b = StzMathFigScene01()
chk("a second build of the same declaration gives the same bytes", oF1b.ToSVG() = cSvg1)
oF1c = StzMathFigureQ(:Function, [ :f = "sin(x) / x", :on = [ -12, 12 ], :mark = [ :zeros ], :label = "y = sin(x) / x" ])
chk("NEGATIVE: a different declaration gives different bytes", oF1c.ToSVG() != cSvg1)

#---------------------------------------------------------------------------

sec("-- 7. A FIGURE IS AN ENTRY OBJECT THAT ANSWERS FOR ITSELF -------------")

chkeq("it knows its kind", oF1.Kind(), "function")
chk("its Why says what was computed and what was solved",
    StzFindFirst("400 samples", oF1.Why()) > 0 and StzFindFirst("satisfied", oF1.Why()) > 0)
chk("its picture is an stzMathDiagram", StzLower(classname(oF1.Diagram())) = "stzmathdiagram")
chkeq("a datum is a fact: the frame carries 400 samples", oF1.Fact(:datum, [ "fr", "samples" ])[:value], 400)
chk("its vector rendition is SVG", oF1.Rendition()[:mime] = "image/svg+xml")
chk("its layout time is a number the caller can budget against", isNumber(oF1.LayoutMs()) and oF1.LayoutMs() > 0)
chk("the house font was found on this machine", isObject(StzMathFigureFont()))

#---------------------------------------------------------------------------

sec("-- 8. A NUMBER LINE: EVERY POINT AT ITS VALUE, EVERY JUMP ADDS UP ------")

oN8 = StzMathFigScene08()
oN8.Layout()
chk("the number line is lawful", oN8.IsSolved())
oSN = oN8.Substance()
chkeq("six points stand on it -- four declared, and the jump's two ends", oSN.DataOf("ax", "points"), 6)
# every point's dot is where the line maps its value -- re-derived from
# the axis's own ends with plain arithmetic
nA = oSN.DataOf("ax", "a")  nB = oSN.DataOf("ax", "b")
nPx0 = oSN.DataOf("ax", "px0")  nPx1 = oSN.DataOf("ax", "px1")
bAt = TRUE
acP = oSN.ObjectsOfType("Point")
for i = 1 to len(acP)
	aD = oN8.ShapeOf(acP[i] + ".icon")
	nWant = nPx0 + (oSN.DataOf(acP[i], "v") - nA) * (nPx1 - nPx0) / (nB - nA)
	if fabs(aD[:cx] - nWant) > 0.000001  bAt = FALSE  ok
next
chk("every dot stands where the line maps its value, to 1e-6", bAt)
chk("the points are numbered left to right: p1 is -2, p6 is 7.5",
    oSN.DataOf("p1", "v") = -2 and oSN.DataOf("p6", "v") = 7.5)
chk("the jump from 2 to 5 prints '+ 3'", oSN.LabelOf("j1") = "+ 3")
chk("and its landing dot is at 5", oSN.DataOf("p5", "v") = 5 or oSN.DataOf("p4", "v") = 5)
chk("a named point reads 'half = 0.5'", oSN.LabelOf("n2") = "half = 0.5")
nNotesN = 0
for i = 1 to len(oSN.Definitions())
	if oSN.Definitions()[i][2] = "Note"  nNotesN++  ok
next
chkeq("only the two points off the ticks are noted -- a point on a tick is named by the tick", nNotesN, 2)
bNearN = TRUE
aDefs = oSN.Definitions()
for i = 1 to len(aDefs)
	if aDefs[i][2] != "Note"  loop  ok
	aT = oN8.ShapeOf(aDefs[i][1] + ".text")
	aP = oN8.ShapeOf(aDefs[i][3][1] + ".icon")
	if sqrt(pow(aT[:cx] - aP[:cx], 2) + pow(aT[:cy] - aP[:cy], 2)) > StzNumberLineFigureLeash() + aT[:w] / 2 + 0.5  bNearN = FALSE  ok
next
chk("every note stands within its leash of its point, by arithmetic", bNearN)
oN9 = StzMathFigScene09()
oN9.Layout()
chk("9 - 5 is lawful", oN9.IsSolved())
chk("and its jump prints '- 5' and reads backwards", oN9.Substance().LabelOf("j1") = "- 5" and oN9.Substance().Holds("Backward", [ "j1" ]))
chkeq("with a step of 1 there are thirteen ticks on [0, 12]", oN9.Substance().DataOf("ax", "ticks"), 13)
chk("a point off the line is refused", _MgRefusesKindSpec(:NumberLine, [ :on = [ 0, 5 ], :points = [ 9 ] ], "is not on the line"))
chk("a jump to itself is refused", _MgRefusesKindSpec(:NumberLine, [ :on = [ 0, 5 ], :jumps = [ [ 2, 2 ] ] ], "to itself"))
chk("a number placed twice is refused", _MgRefusesKindSpec(:NumberLine, [ :on = [ 0, 5 ], :points = [ 2, 2 ] ], "placed twice"))
chk("NEGATIVE: the lawful forms are accepted", NOT _MgRefusesKindSpec(:NumberLine, [ :on = [ 0, 5 ], :points = [ 2, [ 4, "four" ] ], :jumps = [ [ 1, 3 ] ] ], ""))
oNW = StzMathFigNumberLineWitness()
oNWRep = StzCheckPictures([ [ "numberline/witness", oNW.Diagram() ] ])
acNr = []
aNf = oNWRep.Findings()
for i = 1 to len(aNf)  acNr + ("" + aNf[i][:rule])  next
chk("the witness's jump printing + 4 that lands 3 away is found", _MgHas(acNr, "jump_lands_where_it_says"))
chk("its point drawn past its neighbour is found", _MgHas(acNr, "points_keep_their_order"))
oN8Rep = StzCheckPictures([ [ "numberline/08", oN8.Diagram() ], [ "numberline/09", oN9.Diagram() ] ])
chkeq("NEGATIVE: the two lawful lines raise no finding", oN8Rep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

sec("-- 9. A FRACTION: THE PICTURE AGREES WITH A COUNT ----------------------")

oF10 = StzMathFigScene10()
oF10.Layout()
chk("three of four is lawful, with nothing to lay out", oF10.IsSolved() and oF10.Diagram().NumberOfUnknowns() = 0)
cSvg10 = oF10.ToSVG()
# THE CHILD'S PROOF: count the shaded parts -- they are the elements named s1_1, s1_2, s1_3
chkeq("the picture has exactly three shaded parts, counted by their ids", len(StzFindCS('id="s1_', cSvg10, TRUE)), 3)
chkeq("and one unshaded", len(StzFindCS('id="u1_', cSvg10, TRUE)), 1)
oS10 = oF10.Substance()
aW1 = oF10.ShapeOf("w1.box")
nSum = 0
acParts = oS10.ObjectsOfType("Part")
for i = 1 to len(acParts)
	aP = oF10.ShapeOf(acParts[i] + ".icon")
	nSum += aP[:w]
next
chk("the four parts add up to the bar's width, by the solved shapes", fabs(nSum - aW1[:w]) < 0.001)
chk("its name reads 3/4", oS10.LabelOf("nm1") = "3/4")

oF11 = StzMathFigScene11()
oF11.Layout()
chk("four fractions compared are lawful", oF11.IsSolved())
oS11 = oF11.Substance()
# 2/4 and 1/2 END at the same pixel -- the picture's own proof of equality
aS3 = oF11.ShapeOf("s3_2.icon")
aS4 = oF11.ShapeOf("s4_1.icon")
chk("2/4 and 1/2 end at the same pixel, to 1e-9", fabs((aS3[:cx] + aS3[:w] / 2) - (aS4[:cx] + aS4[:w] / 2)) < 0.000000001)
aS1 = oF11.ShapeOf("s1_3.icon")
chk("NEGATIVE: 3/4 ends elsewhere", fabs((aS1[:cx] + aS1[:w] / 2) - (aS4[:cx] + aS4[:w] / 2)) > 10)
chk("the verdicts are cross-multiplied: 3/4 > 2/3, 2/3 > 2/4, 2/4 = 1/2",
    oS11.LabelOf("v1") = ">" and oS11.LabelOf("v2") = ">" and oS11.LabelOf("v3") = "=")

oF12 = StzMathFigScene12()
oF12.Layout()
chk("three of eight and one of four as discs are lawful", oF12.IsSolved())
cSvg12 = oF12.ToSVG()
chkeq("the first disc has three shaded wedges", len(StzFindCS('id="s1_', cSvg12, TRUE)), 3)
chkeq("and the second one", len(StzFindCS('id="s2_', cSvg12, TRUE)), 1)
oS12 = oF12.Substance()
nTurn = 0
acParts = oS12.ObjectsOfType("Part")
for i = 1 to len(acParts)
	if oS12.DataOf(acParts[i], "whole") = 1  nTurn += oS12.DataOf(acParts[i], "angle")  ok
next
chk("the eight wedges turn exactly once round", fabs(nTurn - 2 * PI) < 0.000000001)
chk("the verdict says 3/8 > 1/4", oS12.LabelOf("v1") = ">")

chk("a denominator of zero is refused", _MgRefusesKindSpec(:Fraction, [ :of = [ 1, 0 ] ], "no parts"))
chk("an improper fraction is refused, and told why", _MgRefusesKindSpec(:Fraction, [ :of = [ 5, 4 ] ], "more than one whole"))
chk("a fraction of halves of numbers is refused", _MgRefusesKindSpec(:Fraction, [ :of = [ 1.5, 4 ] ], "whole numbers"))
chk("too many parts to count are refused", _MgRefusesKindSpec(:Fraction, [ :of = [ 1, 100 ] ], "cannot be counted"))
chk("NEGATIVE: 0/4 and 4/4 are accepted -- nothing and everything are fractions",
    NOT _MgRefusesKindSpec(:Fraction, [ :of = [ 0, 4 ] ], "") and NOT _MgRefusesKindSpec(:Fraction, [ :of = [ 4, 4 ] ], ""))
oFW = StzMathFigFractionWitness()
oFWRep = StzCheckPictures([ [ "fraction/witness", oFW.Diagram() ] ])
acFr = []
aFf = oFWRep.Findings()
for i = 1 to len(aFf)  acFr + ("" + aFf[i][:rule])  next
chk("the witness's numerator of two over three shaded parts is found", _MgHas(acFr, "shaded_is_the_numerator"))
chk("its denominator of five over four cut parts is found", _MgHas(acFr, "parts_are_the_denominator"))
oFRep = StzCheckPictures([ [ "fraction/10", oF10.Diagram() ], [ "fraction/11", oF11.Diagram() ], [ "fraction/12", oF12.Diagram() ] ])
chkeq("NEGATIVE: the three lawful fraction pictures raise no finding", oFRep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

sec("-- 10. THE ENTRY OBJECT KNOWS ITS KINDS --------------------------------")

chkeq("the kinds are function, numberline, fraction, matrix, complexplane, boxplot and surface", len(StzMathFigureKinds()), 7)
chk("a number line's Why says what it holds", StzFindFirst("6 point(s)", oN8.Why()) > 0 and StzFindFirst("1 jump(s)", oN8.Why()) > 0)
chk("a fraction's Why says what is shaded", StzFindFirst("3 of 4 shaded", oF10.Why()) > 0)
bRef = FALSE
try
	oN8.SampleCount()
catch
	bRef = TRUE
done
chk("a :Function reader on a number line is refused by name", bRef)

#---------------------------------------------------------------------------

sec("-- 11. A MATRIX: A PRODUCT IS A PICTURE OF HOW EVERY CELL IS MADE -----")

oM2 = StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ] ])
oM2.Layout()
chk("a 2 x 2 product is lawful, with nothing to lay out", oM2.IsSolved() and oM2.Diagram().NumberOfUnknowns() = 0)
oSM = oM2.Substance()
# the product typed by hand, not computed: [ 19 22 ; 43 50 ]
chk("the product's cells are 19, 22, 43, 50 -- typed here, computed there",
    oSM.DataOf("c1_1", "v") = 19 and oSM.DataOf("c1_2", "v") = 22 and oSM.DataOf("c2_1", "v") = 43 and oSM.DataOf("c2_2", "v") = 50)
chk("and every cell's text is its value", oSM.LabelOf("c2_1") = "43")
oM15 = StzMathFigScene15()
oM15.Layout()
chk("scene 30's product is lawful", oM15.IsSolved())
oS15 = oM15.Substance()
chkeq("three grids hold 12 + 12 + 9 cells", oS15.DataOf("fig", "cells"), 33)
nLit = 0
acC = oS15.ObjectsOfType("Cell")
for i = 1 to len(acC)
	if oS15.Holds("Lit", [ acC[i] ])  nLit++  ok
next
chkeq("row 2 of A, column 2 of B and their cell are lit: 4 + 4 + 1", nLit, 9)
chk("the lit cell of the product is 2*0 + 8*2 + 1*3 + 8*2 = 35", oS15.DataOf("c2_2", "v") = 35 and oS15.Holds("Lit", [ "c2_2" ]))
cSvg15 = oM15.ToSVG()
chk("a cell is a named element to a consumer", len(StzFindCS('id="c2_2" class="rect', cSvg15, TRUE)) = 1)
oM16 = StzMathFigScene16()
oM16.Layout()
oS16 = oM16.Substance()
chk("the heat form puts the least value at 0 on the ramp and the greatest at 1",
    oS16.DataOf("a1_3", "t") = 0 and oS16.DataOf("a1_1", "t") = 1 and fabs(oS16.DataOf("a1_2", "t") - 0.25) < 0.000001)
chk("a product of mismatched sizes is refused with the numbers",
    _MgRefusesKindSpec(:Matrix, [ :product = [ [ [ 1, 2, 3 ] ], [ [ 1, 2 ] ] ] ], "needs them equal"))
chk("a ragged matrix is refused", _MgRefusesKindSpec(:Matrix, [ :of = [ [ 1, 2 ], [ 3 ] ] ], "rectangular"))
chk("a cell to show that the product lacks is refused", _MgRefusesKindSpec(:Matrix, [ :product = [ [ [ 1 ] ], [ [ 2 ] ] ], :show = [ 2, 1 ] ], "no cell"))
chk("NEGATIVE: the lawful forms are accepted", NOT _MgRefusesKindSpec(:Matrix, [ :of = [ [ 1 ] ], :as = :heat ], ""))
oMW = StzMathFigMatrixWitness()
oMWRep = StzCheckPictures([ [ "matrix/witness", oMW.Diagram() ] ])
acMr = []
aMf = oMWRep.Findings()
for i = 1 to len(aMf)  acMr + ("" + aMf[i][:rule])  next
chk("the witness's cell of 999 is found by product_cell_is_the_dot_product", _MgHas(acMr, "product_cell_is_the_dot_product"))
chk("its five rows of B are found by dimensions_agree", _MgHas(acMr, "dimensions_agree"))
chk("and by grid_holds_its_cells, since B holds twelve cells and says fifteen", _MgHas(acMr, "grid_holds_its_cells"))
chkeq("NEGATIVE: exactly one cell is wrong", _MgCount(acMr, "product_cell_is_the_dot_product"), 1)
oMRep = StzCheckPictures([ [ "matrix/2x2", oM2.Diagram() ], [ "matrix/15", oM15.Diagram() ], [ "matrix/16", oM16.Diagram() ] ])
chkeq("NEGATIVE: the three lawful matrix pictures raise no finding", oMRep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

sec("-- 12. THE COMPLEX PLANE: A ROOT IS CHECKED WHERE IT IS DRAWN ----------")

oC17 = StzMathFigScene17()
oC17.Layout()
chk("the cube roots of one are lawful", oC17.IsSolved())
oS17 = oC17.Substance()
chkeq("three roots were drawn", oS17.DataOf("fr", "points"), 3)
# the roots, known independently: 1, and -1/2 +- i sqrt(3)/2
bR = TRUE
nHalf3 = sqrt(3) / 2
acP = oS17.ObjectsOfType("Point")
bOne = FALSE  bUp = FALSE  bDown = FALSE
for i = 1 to len(acP)
	re = oS17.DataOf(acP[i], "re")  im = oS17.DataOf(acP[i], "im")
	if fabs(re - 1) < 0.000000001 and fabs(im) < 0.000000001  bOne = TRUE  ok
	if fabs(re + 0.5) < 0.000000001 and fabs(im - nHalf3) < 0.000000001  bUp = TRUE  ok
	if fabs(re + 0.5) < 0.000000001 and fabs(im + nHalf3) < 0.000000001  bDown = TRUE  ok
	# and every one is on the unit circle
	if fabs(re * re + im * im - 1) > 0.000000001  bR = FALSE  ok
next
chk("they are 1 and -1/2 +- i sqrt(3)/2, to 1e-9", bOne and bUp and bDown)
chk("and every one lies on the unit circle", bR)
# THE CHECK OF THE ENGINE: Horner in Ring at each root, on the coefficients
bH = TRUE
for i = 1 to len(acP)
	if _CpHorner(oS17, oS17.DataOf(acP[i], "re"), oS17.DataOf(acP[i], "im")) > 0.000000001  bH = FALSE  ok
next
chk("z^3 - 1 is under 1e-9 in modulus at each, by Horner's rule in Ring", bH)
chk("the unit circle is drawn as a named element", len(StzFindCS('id="unit"', oC17.ToSVG(), TRUE)) = 1)
chk("the notes read as complex numbers: '-0.5 + 0.866i'", _MgLabelExists(oS17, "-0.5 + 0.866i"))
oC18 = StzMathFigScene18()
oC18.Layout()
chk("z = 3 + 2i with its conjugate is lawful", oC18.IsSolved())
oS18 = oC18.Substance()
chk("the ray reads |z| = 3.606 -- sqrt(13) to three places", oS18.LabelOf("ray") = "|z| = 3.606")
chk("the arc reads arg z = 33.7 deg", oS18.LabelOf("arc") = "arg z = 33.7 deg")
chk("the modulus datum is sqrt(13) to 1e-12", fabs(oS18.DataOf("ray", "mod") - sqrt(13)) < 0.000000000001)
chk("a degree-zero polynomial is refused", _MgRefusesKindSpec(:ComplexPlane, [ :roots = [ 5 ] ], "no root"))
chk("a leading zero is refused", _MgRefusesKindSpec(:ComplexPlane, [ :roots = [ 0, 1, 2 ] ], "leading coefficient"))
chk("a point to show that is not drawn is refused", _MgRefusesKindSpec(:ComplexPlane, [ :points = [ [ 1, 1 ] ], :show = [ 2, 2 ] ], "not one of"))
chk("NEGATIVE: the lawful forms are accepted", NOT _MgRefusesKindSpec(:ComplexPlane, [ :points = [ [ 1, 1, "w" ] ], :roots = [ 1, 0, 1 ], :unit = TRUE, :show = [ 1, 1 ] ], ""))
oCW = StzMathFigComplexWitness()
oCWRep = StzCheckPictures([ [ "complex/witness", oCW.Diagram() ] ])
acCr = []
aCf = oCWRep.Findings()
for i = 1 to len(aCf)  acCr + ("" + aCf[i][:rule])  next
chk("the moved root is found by root_is_a_root", _MgHas(acCr, "root_is_a_root"))
chk("and by conjugates_pair, twice -- it lost its mirror and its mirror lost it", _MgCount(acCr, "conjugates_pair") = 2)
chkeq("NEGATIVE: exactly one point is no root", _MgCount(acCr, "root_is_a_root"), 1)
oCRep = StzCheckPictures([ [ "complex/17", oC17.Diagram() ], [ "complex/18", oC18.Diagram() ] ])
chkeq("NEGATIVE: the two lawful planes raise no finding", oCRep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

sec("-- 13. A BOX PLOT: THE FIVE NUMBERS IT DRAWS ARE THE FIVE IT SAYS ------")

oB21 = StzMathFigScene21()
oB21.Layout()
chk("eight values with one alone are lawful", oB21.IsSolved())
oSB = oB21.Substance()
# the five numbers, by an independent reading: the engine's percentiles
# through stzDataSet directly, and the fences by hand
oDs = new stzDataSet([ 2, 4, 4, 5, 7, 9, 12, 25 ])
chk("the box's quartiles are the data set's own", oSB.DataOf("b1", "q1") = oDs.Q1() and oSB.DataOf("b1", "med") = oDs.Q2() and oSB.DataOf("b1", "q3") = oDs.Q3())
nIqr = oDs.Q3() - oDs.Q1()
chk("the upper fence is Q3 + 1.5 IQR", fabs(oSB.DataOf("b1", "fhi") - (oDs.Q3() + 1.5 * nIqr)) < 0.000000001)
chkeq("25 is the one value beyond it, drawn alone", oSB.DataOf("fr", "outliers"), 1)
chk("and the high whisker stops at the last value inside the fence", oSB.DataOf("b1", "whi") <= oSB.DataOf("b1", "fhi") and oSB.DataOf("b1", "whi") < 25)
chkeq("three numbers are written above the box", oB21.Diagram().NumberOfUnknowns(), 6)
# the drawn box is the numbers: the rect from Q1 to Q3, the median line at the median
aBox = oB21.ShapeOf("b1.icon")
aMed = oB21.ShapeOf("b1.med")
nX0 = oSB.DataOf("fr", "x0")  nX1 = oSB.DataOf("fr", "x1")
nVmin = oSB.DataOf("fr", "vmin")  nVmax = oSB.DataOf("fr", "vmax")
nQ1px = nX0 + (oDs.Q1() - nVmin) * (nX1 - nX0) / (nVmax - nVmin)
chk("the rect's left edge stands at Q1 on the axis, re-derived", fabs((aBox[:cx] - aBox[:w] / 2) - nQ1px) < 0.000001)
chk("the median line stands at the median", fabs(aMed[:x1] - (nX0 + (oDs.Q2() - nVmin) * (nX1 - nX0) / (nVmax - nVmin))) < 0.000001)
# THE TEXT RENDITION (TK3): read back, the columns are the numbers
cTxt = oB21.Text()
chk("the text rendition names the five numbers", StzFindFirst("Q1 " + _FfNum(oDs.Q1(), 4), cTxt) > 0 and StzFindFirst("med " + _FfNum(oDs.Q2(), 4), cTxt) > 0)
chk("and draws the box, the median and the outlier in characters", StzFindFirst("[", cTxt) > 0 and StzFindFirst("|", cTxt) > 0 and StzFindFirst("o", StzStringSection(cTxt, StzFindFirst("[", cTxt), len(cTxt))) > 0)
oB22 = StzMathFigScene22()
oB22.Layout()
chk("three groups on one axis are lawful", oB22.IsSolved())
chk("their names are written", oB22.Substance().LabelOf("b2") = "noon")
chk("a group of three values is refused", _MgRefusesKindSpec(:BoxPlot, [ :of = [ 1, 2, 3 ] ], "at least four"))
chk("a seventh group is refused", _MgRefusesKindSpec(:BoxPlot, [ :groups = [ [ "a", [1,2,3,4] ], [ "b", [1,2,3,4] ], [ "c", [1,2,3,4] ], [ "d", [1,2,3,4] ], [ "e", [1,2,3,4] ], [ "f", [1,2,3,4] ], [ "g", [1,2,3,4] ] ] ], "at most"))
chk("NEGATIVE: the lawful forms are accepted", NOT _MgRefusesKindSpec(:BoxPlot, [ :of = [ 5, 1, 4, 2 ], :numbers = FALSE ], ""))
oBW = StzMathFigBoxPlotWitness()
oBWRep = StzCheckPictures([ [ "boxplot/witness", oBW.Diagram() ] ])
acBr = []
aBf = oBWRep.Findings()
for i = 1 to len(aBf)  acBr + ("" + aBf[i][:rule])  next
chk("the witness's median past Q3 is found by box_keeps_its_order", _MgHas(acBr, "box_keeps_its_order"))
chk("its outlier inside the fences is found by outliers_lie_beyond_the_fences", _MgHas(acBr, "outliers_lie_beyond_the_fences"))
oBRep = StzCheckPictures([ [ "boxplot/21", oB21.Diagram() ], [ "boxplot/22", oB22.Diagram() ] ])
chkeq("NEGATIVE: the two lawful box plots raise no finding", oBRep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

sec("-- 14. A SURFACE: z = f(x, y) PROJECTED BY THE ENGINE, DRAWN AS WIRE ---")

oS23 = StzMathFigScene23()
oS23.Layout()
chk("the saddle is lawful, with nothing to lay out", oS23.IsSolved() and oS23.Diagram().NumberOfUnknowns() = 0)
oSS = oS23.Substance()
chkeq("a 20 x 20 grid is 40 lines", oSS.DataOf("fr", "lines"), 40)
# twenty samples never land on y = 0, so the top is 1 - (1/19)^2 -- the
# nearest sample to the ridge, computed here, not read there
nTop = 1 - pow(1 / 19, 2)
chk("z spans +-(1 - (1/19)^2), the ridge's nearest samples, to 1e-9", fabs(oSS.DataOf("fr", "zmin") + nTop) < 0.000000001 and fabs(oSS.DataOf("fr", "zmax") - nTop) < 0.000000001)
# the saddle's corners, known: (-1,-1) -> 0, (1,-1) -> 0, (-1, 1) -> 0, and the centre 0
chk("the centre sample is 0 -- the saddle point", fabs(oSS.DataOf("fr", "z10_10")) < 0.02)
chk("the corner (x = -1, y = 1) is 1 - 1 = 0", fabs(oSS.DataOf("fr", "z1_20")) < 0.000000001)
# the projection is the engine's: a row's points are in canvas range
aR1 = oS23.ShapeOf("r1.icon")
chkeq("a row is a spline of twenty controls", aR1[:n], 20)
bIn = TRUE
for i = 1 to len(aR1[:controls]) step 2
	if aR1[:controls][i] < 0 or aR1[:controls][i] > StzSurfaceFigureWidth() or aR1[:controls][i+1] < 0 or aR1[:controls][i+1] > StzSurfaceFigureHeight()  bIn = FALSE  ok
next
chk("and every control lands on the paper", bIn)
# the same point projected twice agrees: a row's j-th point IS the column's i-th
aC1 = oS23.ShapeOf("c1.icon")
chk("row 1's first point is column 1's first point, to 1e-9", fabs(aR1[:controls][1] - aC1[:controls][1]) < 0.000000001 and fabs(aR1[:controls][2] - aC1[:controls][2]) < 0.000000001)
chk("the lines are named elements", len(StzFindCS('id="r1" class="spline', oS23.ToSVG(), TRUE)) = 1)
oS24 = StzMathFigScene24()
oS24.Layout()
chk("a 24 x 24 ripple is lawful", oS24.IsSolved())
chk("a surface with a pole is refused with the place", _MgRefusesKindSpec(:Surface, [ :f = "1 / (x * y)", :x = [ -1, 1 ], :y = [ -1, 1 ], :samples = 9 ], "not finite"))
chk("an elevation on the plane is refused", _MgRefusesKindSpec(:Surface, [ :f = "x", :x = [ 0, 1 ], :y = [ 0, 1 ], :view = [ 0, 0 ] ], "elevation"))
chk("too many samples are refused", _MgRefusesKindSpec(:Surface, [ :f = "x", :x = [ 0, 1 ], :y = [ 0, 1 ], :samples = 100 ], "8 to 48"))
chk("NEGATIVE: the lawful form is accepted", NOT _MgRefusesKindSpec(:Surface, [ :f = "x * y", :x = [ 0, 1 ], :y = [ 0, 1 ], :samples = 8 ], ""))
oSW = StzMathFigSurfaceWitness()
oSWRep = StzCheckPictures([ [ "surface/witness", oSW.Diagram() ] ])
acSr = []
aSf = oSWRep.Findings()
for i = 1 to len(aSf)  acSr + ("" + aSf[i][:rule])  next
chk("the witness's tampered corner is found by sample_is_the_function", _MgHas(acSr, "sample_is_the_function"))
oSRep = StzCheckPictures([ [ "surface/23", oS23.Diagram() ], [ "surface/24", oS24.Diagram() ] ])
chkeq("NEGATIVE: the two lawful surfaces raise no finding", oSRep.NumberOfFindings(), 0)

#---------------------------------------------------------------------------

if nSecClock > 0
	? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
if len(acSkipped) > 0
	? " skipped: " + @@(acSkipped)
else
	? " skipped: none -- every section of this gate ran"
ok
? "=============================================================="

#---------------------------------------------------------------------------

func sec cTitle
	if nSecClock > 0
		? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
	ok
	nSecClock = clock()
	? cTitle

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

# does the declaration raise, with the words expected in the reason?
func _MgRefuses aSpec, cWords
	_b_ = FALSE
	_c_ = ""
	try
		_o_ = StzMathFigureQ(:Function, aSpec)
	catch
		_b_ = TRUE
		_c_ = cCatchError
	done
	if NOT _b_  return FALSE  ok
	if cWords = ""  return TRUE  ok
	return StzFindFirst(cWords, _c_) > 0

func _MgLabelExists oS, cLabel
	_aD_ = oS.Definitions()
	for _i_ = 1 to len(_aD_)
		if oS.LabelOf(_aD_[_i_][1]) = cLabel  return TRUE  ok
	next
	return FALSE

func _MgRefusesKindSpec cKind, aSpec, cWords
	_b_ = FALSE
	_c_ = ""
	try
		_o_ = StzMathFigureQ(cKind, aSpec)
	catch
		_b_ = TRUE
		_c_ = cCatchError
	done
	if NOT _b_  return FALSE  ok
	if cWords = ""  return TRUE  ok
	return StzFindFirst(cWords, _c_) > 0

func _MgRefusesKind cKind, cWords
	_b_ = FALSE
	_c_ = ""
	try
		_o_ = StzMathFigureQ(cKind, [ :f = "x", :on = [ 0, 1 ] ])
	catch
		_b_ = TRUE
		_c_ = cCatchError
	done
	if NOT _b_  return FALSE  ok
	return StzFindFirst(cWords, _c_) > 0

func _MgHas acList, cItem
	return _MgCount(acList, cItem) > 0

func _MgCount acList, cItem
	_n_ = 0
	for _i_ = 1 to len(acList)
		if acList[_i_] = cItem  _n_++  ok
	next
	return _n_

func _MgMessageHas aFindings, cWords
	for _i_ = 1 to len(aFindings)
		if StzFindFirst(cWords, "" + aFindings[_i_][:message]) > 0  return TRUE  ok
	next
	return FALSE
