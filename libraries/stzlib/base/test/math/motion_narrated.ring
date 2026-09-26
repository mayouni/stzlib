# MOTION_NARRATED -- the second gate of the mathematics plane: M2, motion.
#
# What it proves (base/math/CHARTER.md, law 5 and decision 8):
#
#   1. a parameter is a slider: it moves the computed half at once and the
#      solved half on release, and the two are told apart by mechanism
#   2. THE TWO NUMBERS: the computed half's frame cost against 16.7 ms, and
#      the solved half's settle cost against the graph plane's 100 ms drag
#      budget -- both measured here, both printed, the first asserted; the
#      second is a budget owed as a number, never claimed
#   3. a frame is the same picture offscreen as the parts the window draws:
#      the settled picture is the figure's own bytes, and a frame drawn
#      twice is the same bytes
#
# Run from this directory:  ring motion_narrated.ring

load "../../stzBase.ring"

nOk = 0
nBad = 0
nSecClock = 0
? "=============================================================="
? " MOTION GATE -- the mathematics plane, M2a: a parameter is a slider"
? "=============================================================="

#---------------------------------------------------------------------------

sec("-- 1. A PARAMETER IS A SLIDER: THE COMPUTED HALF NOW, THE SOLVED ON RELEASE")

oM = StzMathMotionQ(:Function, [ :f = "{a} * sin({b} * x)", :on = [ -6.3, 6.3 ],
                                 :mark = [ :extrema ], :maxmarks = 5, :curve = :live,
                                 :label = "y = a sin(b x)" ])
oM.Param("a", 0.5, 3, 1)
oM.Param("b", 0.5, 3, 1)
oM.Settle()
chk("the motion settles into a lawful figure", oM.Figure().IsSolved())
chkeq("the settled figure minted no curve run -- a motion draws it", oM.Figure().RunCount(), 0)
chk("its declaration resolved a and b to numbers", StzFindFirst("(1)", _FfGet(oM.Resolved(), "f", "")) > 0)
aE1 = oM.Figure().Extrema()
nTop1 = 0
for i = 1 to len(aE1)
	if aE1[i][2] > nTop1  nTop1 = aE1[i][2]  ok
next
chk("with a = 1 the highest extremum is 1", fabs(nTop1 - 1) < 0.000001)
# MOVE a: the live curve is 2 sin x at once -- checked against Ring's own sin
oM.Set("a", 2)
chk("the motion is dirty after a move", oM.IsDirty())
aS = oM.LiveSamples()
nWorst = 0
for i = 1 to len(aS)
	nD = fabs(aS[i][2] - 2 * sin(aS[i][1]))
	if nD > nWorst  nWorst = nD  ok
next
chk("the live curve is 2 sin x to 1e-12, by Ring's own sin  [worst " + nWorst + "]", nWorst < 0.000000000001)
# ...while the solved half is STALE until the release
aE2 = oM.Figure().Extrema()
nTop2 = 0
for i = 1 to len(aE2)
	if aE2[i][2] > nTop2  nTop2 = aE2[i][2]  ok
next
chk("NEGATIVE: the figure's marks still say 1 -- the solved half waits for the release", fabs(nTop2 - 1) < 0.000001)
oM.Settle()
aE3 = oM.Figure().Extrema()
nTop3 = 0
for i = 1 to len(aE3)
	if aE3[i][2] > nTop3  nTop3 = aE3[i][2]  ok
next
chk("on release the marks say 2", fabs(nTop3 - 2) < 0.000001 and NOT oM.IsDirty())
oM.Set("b", 2)
oM.Settle()
aE4 = oM.Figure().Extrema()
chk("with b = 2 there are more extrema on the range -- the family changed shape", len(aE4) > len(aE3))
chk("a value past the range is clamped", oM.Set("a", 9).Value("a") = 3)
chk("a parameter the declaration never writes is refused", _MgMotionRefuses("c"))
chk("a name that is not letters is refused", _MgMotionRefuses("a1"))
chk("NEGATIVE: the lawful parameter is accepted", NOT _MgMotionRefuses("a"))

#---------------------------------------------------------------------------

sec("-- 2. THE TWO NUMBERS: FRAME COST AGAINST 16.7 ms, SETTLE COST AGAINST 100 ms")

oM.Set("a", 1)
oM.Set("b", 1)
oM.Settle()
oOver = new stzCanvas(StzFunctionFigureWidth(), StzFunctionFigureHeight())
# sixty frames of a moving parameter, the overlay redrawn each time: the
# computed half's cost, measured inside the motion (clear, 400 samples on
# the tape, the polyline, the flush)
aC0 = oM.Counts()
nSum = 0
nMax = 0
aMs = []
for f = 1 to 60
	oM.Set("a", 0.5 + 2.5 * f / 60)
	oM.DrawLiveOn(oOver)
	nMs = oM.FrameMs()
	nSum += nMs
	aMs + nMs
	if nMs > nMax  nMax = nMs  ok
next
nMean = nSum / 60
aMs = sort(aMs)
nMedian = (aMs[30] + aMs[31]) / 2
? "        computed half: " + _FfNum(nMedian, 2) + " ms median, " + _FfNum(nMean, 2) + " ms mean, " + _FfNum(nMax, 2) + " ms worst, over 60 frames of " + oM.LiveSampleCount() + " samples (16.7 ms is one frame at 60 fps)"
# THE MEDIAN, NOT THE MEAN: this machine runs several sessions and its
# ambient load spikes single frames; a median of sixty is the frame cost,
# a mean is the frame cost plus whatever else the machine was doing
chk("the computed half fits a 60 fps frame on the median of sixty", nMedian < 16.7)
chk("and its worst frame fits two", nMax < 33.4)
# THE STRUCTURE, BY COUNT -- immune to this machine's ambient load: sixty
# frames are sixty flushes and sixty times the samples on the tape, and
# NO settle, no rebuild, no re-solve
aC1 = oM.Counts()
chkeq("sixty frames flushed the overlay sixty times", aC1[:flushes] - aC0[:flushes], 60)
chkeq("and crossed into the tape once per sample per frame", aC1[:tapecalls] - aC0[:tapecalls], 60 * oM.LiveSampleCount())
chkeq("and settled NOTHING -- the solved half never ran during the drag", aC1[:settles] - aC0[:settles], 0)
# the solved half: three settles, the mean printed against the 100 ms budget
nS = 0
for k = 1 to 3
	oM.Set("a", 1 + k * 0.4)
	oM.Settle()
	nS += oM.SettleMs()
next
nS = nS / 3
? "        solved half: " + _FfNum(nS, 1) + " ms per settle, mean of three (the graph plane's drag budget is 100 ms)"
if nS <= 100
	chk("the solved half settles within the 100 ms drag budget", TRUE)
else
	chk("the solved half settles within a second -- the 100 ms budget is OWED, not met: " + _FfNum(nS, 0) + " ms", nS < 1000)
ok
oOver.Free()

#---------------------------------------------------------------------------

sec("-- 3. A FRAME IS THE SAME PICTURE OFFSCREEN ------------------------------")

oM.Set("a", 1.5)
oM.Set("b", 1)
oM.Settle()
cA = oM.FrameSVG()
cB = oM.FrameSVG()
chk("a frame drawn twice is the same bytes  [" + len(cA) + " bytes]", cA = cB)
cFig = oM.Figure().ToSVG()
chk("and it carries the live curve over the figure's own elements: longer than the figure's SVG by the curve's points  [+" + (len(cA) - len(cFig)) + " bytes]", len(cA) > len(cFig) + 400 and StzFindFirst("<g id=", cA) > 0)
oM.Set("a", 2.5)
cC = oM.FrameSVG()
chk("NEGATIVE: a moved parameter gives different bytes", cC != cA)
oM.Set("a", 1.5)
cD = oM.FrameSVG()
chk("and moved back, the same bytes again", cD = cA)
chk("the window's availability is a fact the gate reports, never assumes: " + StzWindowAvailabilityText(), TRUE)

#---------------------------------------------------------------------------

if nSecClock > 0
	? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? " skipped: none -- every section of this gate ran"
? "=============================================================="

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

func _MgMotionRefuses cName
	_b_ = FALSE
	try
		_o_ = StzMathMotionQ(:Function, [ :f = "{a} * x", :on = [ 0, 1 ] ])
		_o_.Param(cName, 0, 1, 0.5)
	catch
		_b_ = TRUE
	done
	return _b_

func StzWindowAvailabilityText
	_b_ = FALSE
	try
		_b_ = StzWindowingAvailable()
	catch
		_b_ = FALSE
	done
	if _b_  return "a window can open on this machine"  ok
	return "no window on this machine, the offscreen path is the frame"
