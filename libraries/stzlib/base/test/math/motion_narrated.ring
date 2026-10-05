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
cSkipped = "none -- every section of this gate ran"
? "=============================================================="
? " MOTION GATE -- the mathematics plane, M2: sliders and declared states"
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

sec("-- 4. DECLARED STATES: A CAPTION AND THE ACTS THAT REACH IT ---------------")

# The second subject: a solved stzMathDiagram, here Byrne's I.47 built from
# library code (StzPythagorasMotionQ), and the second kind of motion: a
# sequence of STATES, each a caption and the acts that reach it. The acts
# are the picture's own verbs -- a drag of a free vertex -- so the picture
# at every state is the solver's answer, never a drawing of one.
oFont = StzMathFigureFont()
oP = StzPythagorasMotionQ(oFont)
chkeq("Pythagoras is told in four declared states", oP.NumberOfStates(), 4)
chk("before any Apply the motion stands as declared: " + oP.Why(), oP.Applied() = 0)
chk("the opening state has no act: it is the picture as built", len(oP.ActsOf(1)) = 0)
chk("the second state drags A by (+60, -30): an act is a verb and its numbers  [" + @@(oP.ActsOf(2)) + "]",
	len(oP.ActsOf(2)) = 1 and oP.ActsOf(2)[1][1] = "dragby" and oP.ActsOf(2)[1][3] = 60 and oP.ActsOf(2)[1][4] = -30)
chk("the first state binds five facts, each written as a hole in its caption", len(oP.FactsOf(1)) = 5)
nX1 = oP.Picture().ValueOf("A.icon.cx")
nY1 = oP.Picture().ValueOf("A.icon.cy")
oP.Apply(2)
nX2 = oP.Picture().ValueOf("A.icon.cx")
nY2 = oP.Picture().ValueOf("A.icon.cy")
chk("Apply(2) moves A by exactly (+60, -30) from where it stood  [" + _FfNum(nX1, 2) + "," + _FfNum(nY1, 2) + " -> " + _FfNum(nX2, 2) + "," + _FfNum(nY2, 2) + "]",
	fabs(nX2 - nX1 - 60) < 0.000001 and fabs(nY2 - nY1 + 30) < 0.000001)
chk("and the motion says so: " + oP.Why(), oP.Applied() = 2)
chk("the drag is a warm re-solve under the graph plane's 100 ms budget  [" + _FfNum(oP.ApplyMs(), 1) + " ms]", oP.ApplyMs() < 100)

# EVERY CLAIM CARRIES ITS CHECK (law 3): the equality is never asserted in
# the picture -- every square is an expression over the three points -- so
# the gate reads a^2 + b^2 - c^2 back out of the solved coordinates, in
# every state, and holds it to zero. The angle at A is read the same way.
oP2 = StzPythagorasMotionQ(oFont)
nWorstGap = 0
nWorstAng = 0
for i = 1 to 4
	oP2.Apply(i)
	nGap = fabs(oP2.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:value])
	nAng = fabs(oP2.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:value] - 90)
	if nGap > nWorstGap  nWorstGap = nGap  ok
	if nAng > nWorstAng  nWorstAng = nAng  ok
next
chk("in every state a^2 + b^2 - c^2 reads ZERO from the coordinates, never from an assertion  [worst " + _FfNum(nWorstGap, 4) + " px^2 over 4 states]", nWorstGap < 0.5)
chk("and the angle at A stays a right angle through every drag  [worst off by " + _FfNum(nWorstAng, 4) + " degrees]", nWorstAng < 0.01)
oNeg = StzMathMotionOverQ(StzMathNotRightAtA(oFont))
oNeg.State("the same expression, another triangle {gap}", [ [ :DragBy, "A.icon", 60, -30 ] ])
oNeg.Apply(1)
nNeg = fabs(oNeg.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:value])
chk("NEGATIVE: a triangle whose right angle is not at A gives the same expression far from zero -- the zero above is measured, not an identity  [" + _FfNum(nNeg, 0) + " px^2]", nNeg > 1000)

chk("a state refuses a verb that is not an act: " + _MgStateRefuses(1), StzFindFirst("not an act", _MgStateRefuses(1)) > 0)
chk("a motion over a picture refuses Set -- it has no parameter: " + _MgStateRefuses(2), StzFindFirst("has none", _MgStateRefuses(2)) > 0)
chk("a motion over a figure refuses DragTo -- its states Set parameters: " + _MgStateRefuses(3), StzFindFirst("Set parameters", _MgStateRefuses(3)) > 0)
chk("a fact whose hole the caption never writes is refused -- a fact is bound to be shown: " + _MgStateRefuses(4), StzFindFirst("never writes", _MgStateRefuses(4)) > 0)
chk("Apply(0) is refused by count: " + _MgStateRefuses(5), StzFindFirst("not declared", _MgStateRefuses(5)) > 0)
chk("a drag of a derived shape is refused -- only a free centre moves: " + _MgStateRefuses(6), StzFindFirst("no free centre", _MgStateRefuses(6)) > 0)

#---------------------------------------------------------------------------

sec("-- 5. THE EXPORT IS THE PICTURE: FRAMES, FACTS, NARRATION, PROVED BY BYTES")

# ExportTo drives an stzStoryboard with the SAME acts: every state a frame
# written as a PNG in the folio, every fact bound and computed on that frame,
# the narration beside them. Then the guard the charter owes: the bytes of
# every exported frame are the bytes of the picture walked BY HAND through
# the same acts on a second build -- the storyboard is not a film.
oM = StzPythagorasMotionQ(oFont)
cExportRefusal = ""
try
	nT0 = StzEngineWatchTimestampMs()
	oS = oM.ExportTo("folio", "pythagoras")
	nExportMs = StzEngineWatchTimestampMs() - nT0
catch
	cExportRefusal = cCatchError
done
if cExportRefusal != ""
	chk("no graphics device: ExportTo refuses BY NAME and points at the offscreen path: " + cExportRefusal, StzFindFirst("no graphics device", cExportRefusal) > 0)
	cSkipped = "the byte guard of section 5 and the sine export of section 6 (no graphics device)"
else
	chkeq("four frames in folio/  [" + _FfNum(nExportMs, 0) + " ms for four solves, four PNGs and four judgements]", oS.NumberOfFrames(), 4)
	chk("the storyboard judges itself clean: every hole filled from its fact, no finding in any frame", oS.IsClean())
	bNoHole = TRUE
	for i = 1 to 4
		if StzFindFirst("{", oS.Caption(i)) > 0  bNoHole = FALSE  ok
	next
	chk("every caption shows its numbers and keeps no hole  [frame 2: " + oS.Caption(2) + "]", bNoHole)
	aH = oS.HolesOf(1)
	nSum = 0  nC2 = 0
	for k = 1 to len(aH)
		if aH[k][1] = "sum"  nSum = aH[k][2][:value]  ok
		if aH[k][1] = "c2"   nC2 = aH[k][2][:value]  ok
	next
	chk("frame 1's caption shows the sum of the two squares equal to the third, and both are facts read from that frame  [" + _FfNum(nSum, 2) + " = " + _FfNum(nC2, 2) + "]", nSum > 1000 and fabs(nSum - nC2) < 0.5)
	cNarr = read("folio/pythagoras.narration")
	chk("the narration is written beside the frames, names the story and every frame as a cell  [" + len(cNarr) + " bytes]",
		StzFindFirst("DEFINE NARRATION pythagoras", cNarr) > 0 and StzFindFirst("picture_4", cNarr) > 0 and StzFindFirst("gap_4", cNarr) > 0)
	chk("the export leaves the motion where it found it: the storyboard worked on its own copy", oM.Applied() = 0 and fabs(oM.Picture().ValueOf("A.icon.cx") - nX1) < 0.000001)

	# THE FRAME-REALITY GUARD: a second build, walked by hand through the
	# declared acts with the diagram's own DragTo, drawn with the diagram's
	# own ToPNG -- and its bytes are the folio's bytes, state by state.
	oH = StzPythagorasPictureQ(oFont)
	aLive = []
	aLive + oH.ToPNG("folio/_hand_1.png")
	for i = 2 to 4
		aA = oM.ActsOf(i)
		for k = 1 to len(aA)
			if aA[k][1] = "dragby"
				oH.DragTo(aA[k][2], oH.ValueOf(aA[k][2] + ".cx") + aA[k][3], oH.ValueOf(aA[k][2] + ".cy") + aA[k][4])
			ok
		next
		aLive + oH.ToPNG("folio/_hand_" + i + ".png")
	next
	nSame = 0
	nBytes = 0
	for i = 1 to 4
		cE = read("folio/" + oS.FileOf(i))
		nBytes += len(cE)
		if aLive[i] = cE  nSame++  ok
		remove("folio/_hand_" + i + ".png")
	next
	chkeq("EVERY exported frame is byte-for-byte the picture walked by hand  [" + nBytes + " bytes over 4 frames]", nSame, 4)
	bDiffer = TRUE
	for i = 2 to 4
		if aLive[i] = aLive[i-1]  bDiffer = FALSE  ok
	next
	chk("NEGATIVE: consecutive frames are different bytes -- the equality above is not vacuous", bDiffer)
	nSame = 0
	for i = 1 to 4
		oM.Apply(i)
		if oM.Picture().ToPNG("folio/_apply.png") = read("folio/" + oS.FileOf(i))  nSame++  ok
	next
	remove("folio/_apply.png")
	chkeq("and what PlayStates would show -- the motion's own Apply -- is the exported frame", nSame, 4)
ok

#---------------------------------------------------------------------------

sec("-- 6. THE SINE FAMILY AS STATES: A PARAMETER PER FRAME -------------------")

# a :Function motion's states Set its parameters; each state settles and the
# settled figure is the frame. The fact bound is the extremum nearest the
# origin, found by the engine's own search, and the gate holds its height
# to the parameter the state set.
oF = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3, :label = "y = a sin x" ])
oF.Param("a", 1, 3, 1)
for k = 1 to 3
	oF.State("With a = " + k + " the extremum nearest the origin sits at y = {top}.", [ [ :Set, "a", k ] ])
	oF.StateFact("top", :datum, [ "m1", "y" ])
next
chkeq("three states, each setting a", oF.NumberOfStates(), 3)
if cExportRefusal = ""
	nT0 = StzEngineWatchTimestampMs()
	oS2 = oF.ExportTo("folio", "sine")
	nSineMs = StzEngineWatchTimestampMs() - nT0
	chkeq("three frames in folio/  [" + _FfNum(nSineMs, 0) + " ms: three settles of the figure]", oS2.NumberOfFrames(), 3)
	chk("the storyboard is clean", oS2.IsClean())
	nOff = 0
	for k = 1 to 3
		aH = oS2.HolesOf(k)
		nTop = aH[1][2][:value]
		if fabs(fabs(nTop) - k) > 0.000001  nOff++  ok
	next
	chkeq("the extremum's height IS the parameter in every frame: the engine's search checked against the number the state set", nOff, 0)
	chk("the parameters are put back after the export  [a = " + oF.Value("a") + ", moved since it settled: " + oF.IsDirty() + "]", oF.Value("a") = 1 and oF.IsDirty())
	oF2 = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3, :label = "y = a sin x" ])
	oF2.Param("a", 1, 3, 1)
	nSame = 0
	for k = 1 to 3
		oF2.Set("a", k)
		oF2.Settle()
		if oF2.Figure().Diagram().ToPNG("folio/_sine.png") = read("folio/" + oS2.FileOf(k))  nSame++  ok
	next
	remove("folio/_sine.png")
	chkeq("every exported frame is the figure settled by hand at that parameter, byte for byte", nSame, 3)
ok
cLiveRefusal = ""
try
	oL = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :curve = :live ])
	oL.Param("a", 1, 3, 1)
	oL.State("x", [ [ :Set, "a", 2 ] ])
	oL.ExportTo("folio", "live")
catch
	cLiveRefusal = cCatchError
done
chk("a motion drawing its curve live refuses to export -- a frame is the settled picture: " + cLiveRefusal, StzFindFirst("settled picture", cLiveRefusal) > 0)

#---------------------------------------------------------------------------

if nSecClock > 0
	? "        [section took " + ((clock() - nSecClock) / clockspersecond()) + "s]"
ok
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? " skipped: " + cSkipped
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

# the six refusals of a declared state, by number
func _MgStateRefuses n
	_c_ = ""
	try
		_o_ = StzPythagorasMotionQ(StzMathFigureFont())
		if n = 1  _o_.State("x", [ [ :Fly, "A.icon", 1, 2 ] ])
		but n = 2  _o_.State("x", [ [ :Set, "a", 1 ] ])
		but n = 3
			_o2_ = StzMathMotionQ(:Function, [ :f = "{a} * x", :on = [ 0, 1 ] ])
			_o2_.Param("a", 0, 1, 0.5)
			_o2_.State("x", [ [ :DragTo, "A.icon", 1, 2 ] ])
		but n = 4  _o_.State("no hole here", [])  _o_.StateFact("gap", :expr, [ "1" ])
		but n = 5  _o_.State("x", [])  _o_.Apply(0)
		but n = 6  _o_.State("x", [ [ :DragBy, "ABC.sqbc", 1, 2 ] ])
		ok
	catch
		_c_ = cCatchError
	done
	_n_ = StzFindFirst("stzMathMotion", _c_)
	if _n_ > 0  _c_ = right(_c_, len(_c_) - _n_ + 1)  ok
	return ring_trim(_c_)

# the NEGATIVE's substance: the same three points and triangle, the right
# angle declared at B -- so the expression written for A is not zero
func StzMathNotRightAtA poFont
	_oS_ = new stzMathSubstance(StzGeometryDomain())
	_oS_.DeclareAll("Point", [ "A", "B", "C" ])
	_oS_.Define("ABC", "Triangle", [ "A", "B", "C" ])
	_oS_.Define("CBA", "InteriorAngle", [ "C", "B", "A" ])
	_oS_.Assert("Right", [ "CBA" ])
	_oS_.AutoLabelAll()
	_oS_.Label("ABC", "")
	_oS_.Label("CBA", "")
	_o_ = new stzMathDiagram(StzGeometryDomain(), _oS_, StzByrneStyle())
	_o_.SetFont(poFont, 24)
	_o_.SetVariation("byrne")
	_o_.Layout()
	return _o_
