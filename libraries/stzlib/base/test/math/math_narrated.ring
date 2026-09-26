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
chk("a figure kind this plane lacks is refused with the kinds", _MgRefusesKind(:Surface, "not a figure kind"))
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
