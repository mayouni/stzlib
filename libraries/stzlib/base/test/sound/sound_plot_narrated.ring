# THE PLOT FACE -- guards for stzSoundPlot, the thing that turns an analysis
# grid into a picture a person can read.
#
# EVERY GUARD HERE IS A BUG THAT HAPPENED. The gallery was drawn, looked at,
# and found wrong five times over; each fault is now a narrated assertion, so
# the next person to touch the drawing code finds out before the picture does.
#
#   1  AddPolyline takes a FLAT point list. Handed pairs it drew nothing at
#      all, silently -- two whole plates came out as empty axes.
#   2  Each series was normalised to ITS OWN peak, which puts every curve at
#      0 dB and destroys the comparison the chart exists to make.
#   3  The footer ran off the right edge, losing the end of the sentence that
#      explained the picture.
#   4  SetFont before AddText restyles the PREVIOUS shape, so the title came
#      out smaller than its own subtitle.
#   5  A -70 dB floor lights up every pixel of a sound with a broadband floor,
#      hiding the structure inside a wash.
#
# THE GUARDS MEASURE GEOMETRY, NOT MARKUP. stzCanvas renders text as glyph
# OUTLINES -- there is no <text> element and no font-size attribute in the
# output, and no way to read a sentence back out of it. So a claim about a
# label's size becomes a claim about how tall its glyphs are, which is the
# thing that was actually wrong anyway.
#
# No audio device is needed: SVG is drawn on the CPU, which is what lets a
# machine with no sound card still check that the drawing is right.

load "../../stzBase.ring"

nPass = 0
nFail = 0

# the series hues, as stzCanvas writes them into SVG
C_S1 = "rgb(57,135,229)"        # #3987e5, series 1
C_S2 = "rgb(217,89,38)"         # #d95926, series 2
C_MARK = "rgb(227,73,72)"       # #e34948, the marker red

pr()
decimals(4)

? "== the plot face: an analysis grid, drawn =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: a spectrum becomes a POLYLINE, and a FLAT point list is why --"

oT1 = MakeTone(220, 0.4, 0.5)
oT2 = MakeTone(880, 0.4, 0.1)          # two octaves up, a fifth the size
oS1 = oT1.ToSpectrumOf(1, 1000, 8192)
oS2 = oT2.ToSpectrumOf(1, 1000, 8192)

oP = new stzSoundPlot(700, 300)
oP.SetTitle("two tones", "one loud, one quiet")
oP.DrawSpectra([ ["loud", oS1], ["quiet", oS2] ], 100, 8000)
cSvg = oP.ToSVG()
? "   " + len(cSvg) + " bytes of SVG"
Chk("the plate drew something", len(cSvg) > 2000)
Chk("and it is SVG", substr(cSvg, "<svg") > 0)

# THE BUG: AddPolyline wants x, y, x, y -- a flat list. Given a list of PAIRS
# it accepted the call, drew nothing, and reported no error. The plate came
# out as bare axes, and the failure was silent, which is the worst kind.
# Gridlines are polylines too, so the guard asks for the SERIES colour.
aL1 = PointsOfStroke(cSvg, C_S1)
aL2 = PointsOfStroke(cSvg, C_S2)
? "   series 1 drew " + len(aL1) + " line(s), series 2 drew " + len(aL2)
Chk("the loud series drew a line in its own colour", len(aL1) = 1)
Chk("and so did the quiet one", len(aL2) = 1)

nPts1 = len(split(aL1[1], " "))
? "   the first line has " + nPts1 + " points"
Chk("a line, not a stub -- hundreds of points across the axis", nPts1 > 200)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: ONE reference for every series --"
? "   A quiet series must LOOK quiet. Normalising each curve to its own peak"
? "   puts them both at the top and draws the opposite of the truth."

nGapDb = 20 * log10(oS1.Max() / oS2.Max())
? "   the two peaks are " + nGapDb + " dB apart in the data"
Chk("the loud one really is louder in the data", nGapDb > 10)

# The drawn evidence. SVG counts y DOWNWARD, so the smaller y is the higher ink.
nTopLoud = MinYOf(aL1[1])
nTopQuiet = MinYOf(aL2[1])
? "   highest ink: loud at y=" + nTopLoud + ", quiet at y=" + nTopQuiet
Chk("the quiet series is drawn LOWER on the plate", nTopQuiet > nTopLoud + 10)

# and the gap on the plate matches the gap in the data, because the axis is
# 72 dB tall over the plot's height -- a scale, not a decoration
nPlotH = 300 - 74 - 62
nDrawnGapDb = (nTopQuiet - nTopLoud) * 72 / nPlotH
? "   which reads as " + nDrawnGapDb + " dB on the axis (data says " + nGapDb + ")"
Chk("the drawn gap IS the measured gap", fabs(nDrawnGapDb - nGapDb) < 3)

oS1.Release()
oS2.Release()
oT1.Release()
oT2.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the note WRAPS instead of running off the edge --"

cLong = "This is a deliberately long explanatory note, of the length a real " +
        "one reaches when it has to say what the picture means rather than " +
        "merely name it, and it must not vanish off the right hand edge."
oW = new stzSoundPlot(700, 300)
oW.SetNote(cLong)
aLines = oW.ToNoteLines()
? "   " + len(cLong) + " characters became " + len(aLines) + " lines"
Chk("a long note becomes more than one line", len(aLines) > 1)

nWidest = 0
for i = 1 to len(aLines)
	if len(aLines[i]) > nWidest  nWidest = len(aLines[i]) ok
next
? "   the widest line is " + nWidest + " characters"
Chk("and no line is wider than the plate", nWidest <= 113)
Chk("the words all survived the wrapping", JoinWords(aLines) = cLong)

# the negative sibling: a short note is left alone rather than cut up
oN = new stzSoundPlot(700, 300)
oN.SetNote("Short.")
Chk("a short note stays one line", len(oN.ToNoteLines()) = 1)

# and a wider plate fits more on a line, because the wrap MEASURES
oWidePlate = new stzSoundPlot(1400, 300)
oWidePlate.SetNote(cLong)
? "   the same note on a 1400 px plate: " + len(oWidePlate.ToNoteLines()) + " line(s)"
Chk("a wider plate needs fewer lines", len(oWidePlate.ToNoteLines()) < len(aLines))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: the title is bigger than its subtitle, and SetFont is why --"
? "   stzCanvas's SetFont behaves exactly like Fill: with a shape PENDING it"
? "   restyles that shape; with none pending it sets the canvas default. So"
? "   a run of labels that styles BEFORE adding is off by one -- every call"
? "   resizes the label before it, and the plate's title came out smaller"
? "   than its own subtitle."
? ""
? "   ONE TEXT RUN IS ONE PATH in the output, so a label's height is the"
? "   vertical span of its path -- which is the thing that was wrong."

oFont = FindAFont()
if NOT isObject(oFont)
	? "   [skipped] no system font found to measure with"
else
	nBig = GlyphHeight(oFont, 28)
	nSmall = GlyphHeight(oFont, 11)
	? "   'Hxy' added then styled at 28 px is " + nBig + " px tall; at 11 px, " + nSmall
	Chk("asking for a bigger font gets a bigger glyph", nBig > nSmall * 2)

	# THE BUG ITSELF. On an EMPTY canvas the wrong order looks harmless: with
	# nothing pending, SetFont just sets the default and the next AddText
	# picks it up. It only bites in a RUN of labels -- which is what a chart
	# is -- where each SetFont lands on the label before it.
	nHarmless = GlyphHeightWrongOrderAlone(oFont, 28)
	? "   on an empty canvas the wrong order still gives " + nHarmless + " px"
	Chk("which is why the bug survived a casual look",
	    fabs(nHarmless - nBig) < 2)

	aRun = GlyphHeightsWrongOrderRun(oFont, 28, 11)
	? "   but in a RUN, asking for 28 then 11 draws " + aRun[1] + " px then " + aRun[2]
	Chk("the first label does NOT get the size it asked for", aRun[1] < nBig / 2)
	Chk("and the second wears the first one's size", aRun[2] > aRun[1])

	# the plate does it the right way round, and the proof is on the plate
	oTP = new stzSoundPlot(700, 300)
	oTP.SetTitle("H", "H")
	oTP.DrawSpectra([], 100, 8000)
	cTP = oTP.ToSVG()
	nTitleH = PathYExtent(NextNPaths(cTP, 0, 1))
	nSubH = PathYExtent(NextNPaths(cTP, 1, 1))
	? "   on a real plate: the title's H is " + nTitleH + " px, the subtitle's " + nSubH
	Chk("so the plate adds first and styles second", nTitleH > nSubH)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the dynamic range decides how much of the floor gets ink --"

oSw = MakeSweep(200, 4000, 1.0)
oSg = oSw.ToSpectrogram()

oWideDb = new stzSoundPlot(600, 260)
oWideDb.SetDynamicRange(70)
oWideDb.DrawSpectrogram(oSg, 12000)
nWideCells = CountOf(oWideDb.ToSVG(), "<rect")

oTight = new stzSoundPlot(600, 260)
oTight.SetDynamicRange(30)
oTight.DrawSpectrogram(oSg, 12000)
nTightCells = CountOf(oTight.ToSVG(), "<rect")

? "   -70 dB draws " + nWideCells + " cells, -30 dB draws " + nTightCells
Chk("a tighter range draws strictly fewer cells", nTightCells < nWideCells)
Chk("but it does not draw NOTHING -- the signal survives", nTightCells > 20)

# the negative sibling: a range of zero or less is refused, not obeyed
oZero = new stzSoundPlot(600, 260)
oZero.SetDynamicRange(0)
oZero.DrawSpectrogram(oSg, 12000)
Chk("a range of 0 is ignored, and the default still draws",
    CountOf(oZero.ToSVG(), "<rect") > 20)

oSg.Release()
oSw.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: a marker outside the axis is not drawn off the plate --"

oM = new stzSoundPlot(600, 260)
oM.DrawSpectra([], 100, 8000)
nBefore = len(PointsOfStroke(oM.ToSVG(), C_MARK))
oM.MarkFrequencyAt(50000, 100, 8000, "past the axis")
nAfterOut = len(PointsOfStroke(oM.ToSVG(), C_MARK))
? "   markers before: " + nBefore + ", after one out of range: " + nAfterOut
Chk("a marker outside the range draws nothing at all", nAfterOut = nBefore)

oM.MarkFrequencyAt(1000, 100, 8000, "1 kHz")
Chk("and one inside it does draw",
    len(PointsOfStroke(oM.ToSVG(), C_MARK)) = nBefore + 1)

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func CountOf pcHay, pcNeedle
	_n_ = 0
	_p_ = substr(pcHay, pcNeedle)
	while _p_ > 0
		_n_++
		pcHay = substr(pcHay, _p_ + len(pcNeedle))
		_p_ = substr(pcHay, pcNeedle)
	end
	return _n_

# Every element drawn in a given stroke colour, as its points attribute. This
# is how a guard picks one SERIES out of a plate that is mostly gridlines.
func PointsOfStroke pcSvg, pcRgb
	_a_ = []
	_s_ = pcSvg
	_p_ = substr(_s_, "<polyline")
	while _p_ > 0
		_s_ = substr(_s_, _p_ + 9)
		_e_ = substr(_s_, ">")
		if _e_ = 0  exit ok
		_el_ = left(_s_, _e_)
		if substr(_el_, 'stroke="' + pcRgb + '"') > 0
			_a_ + AttrOf(_el_, "points")
		ok
		_p_ = substr(_s_, "<polyline")
	end
	return _a_

func AttrOf pcElem, pcName
	_p_ = substr(pcElem, pcName + '="')
	if _p_ = 0  return "" ok
	_t_ = substr(pcElem, _p_ + len(pcName) + 2)
	_e_ = substr(_t_, '"')
	if _e_ = 0  return "" ok
	return left(_t_, _e_ - 1)

# The smallest y in a "x,y x,y ..." list -- the HIGHEST ink, because SVG
# counts y downward from the top of the plate.
func MinYOf pcPoints
	_min_ = 999999
	_a_ = split(pcPoints, " ")
	for _i_ = 1 to len(_a_)
		_xy_ = split(_a_[_i_], ",")
		if len(_xy_) < 2  loop ok
		_y_ = number(_xy_[2])
		if _y_ < _min_  _min_ = _y_ ok
	next
	return _min_

func JoinWords paLines
	_c_ = ""
	for _i_ = 1 to len(paLines)
		if _c_ != ""  _c_ += " " ok
		_c_ += paLines[_i_]
	next
	return _c_

func FindAFont
	_aP160_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf",
	             "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf" ]
	_nP160_ = len(_aP160_)
	for _iP160_ = 1 to _nP160_
		_p_ = _aP160_[_iP160_]
		if fexists(_p_)
			return new stzFont(_p_)
		ok
	next
	return NULL

# How tall the glyphs come out when the text is ADDED first and STYLED after.
func GlyphHeight poFont, pnSize
	_c_ = new stzCanvas(300, 120)
	_c_.SetBackground("#000000")
	_c_.AddText("Hxy", 20, 80)
	_c_.SetFont(poFont, pnSize)
	_c_.Fill("#ffffff")
	return PathYExtent(_c_.ToSVG())

# The wrong order on an EMPTY canvas, where it happens to work: nothing is
# pending, so SetFont sets the default and the next AddText inherits it.
func GlyphHeightWrongOrderAlone poFont, pnSize
	_c_ = new stzCanvas(300, 120)
	_c_.SetBackground("#000000")
	_c_.SetFont(poFont, pnSize)
	_c_.AddText("Hxy", 20, 80)
	_c_.Fill("#ffffff")
	return PathYExtent(_c_.ToSVG())

# The wrong order in a RUN of labels, where it does not: the second SetFont
# lands on the FIRST label, and every size is off by one.
func GlyphHeightsWrongOrderRun poFont, pnFirst, pnSecond
	_c_ = new stzCanvas(300, 200)
	_c_.SetBackground("#000000")
	_c_.SetFont(poFont, pnFirst)
	_c_.AddText("Hxy", 20, 60)
	_c_.Fill("#ffffff")
	_c_.SetFont(poFont, pnSecond)
	_c_.AddText("Hxy", 20, 150)
	_c_.Fill("#ffffff")
	_svg_ = _c_.ToSVG()
	return [ PathYExtent(NextNPaths(_svg_, 0, 1)),
	         PathYExtent(NextNPaths(_svg_, 1, 1)) ]

# The vertical span of every glyph outline in a fragment. Path commands here
# all take coordinate PAIRS, so every second number is a y.
func PathYExtent pcSvg
	_lo_ = 999999
	_hi_ = -999999
	_s_ = pcSvg
	_p_ = substr(_s_, '<path d="')
	while _p_ > 0
		_s_ = substr(_s_, _p_ + 9)
		_e_ = substr(_s_, '"')
		if _e_ = 0  exit ok
		_d_ = left(_s_, _e_ - 1)
		_aCh161_ = [ "M", "L", "Q", "C", "Z", "H", "V", "," ]
		_nCh161_ = len(_aCh161_)
		for _iCh161_ = 1 to _nCh161_
			_ch_ = _aCh161_[_iCh161_]
			_d_ = substr(_d_, _ch_, " ")
		next
		_nums_ = split(_d_, " ")
		_k_ = 0
		for _i_ = 1 to len(_nums_)
			if trim(_nums_[_i_]) = ""  loop ok
			_k_++
			if _k_ % 2 = 0
				_v_ = number(_nums_[_i_])
				if _v_ < _lo_  _lo_ = _v_ ok
				if _v_ > _hi_  _hi_ = _v_ ok
			ok
		next
		_p_ = substr(_s_, '<path d="')
	end
	if _hi_ < _lo_  return 0 ok
	return _hi_ - _lo_

# A slice of the picture's glyph outlines, in the order they were drawn --
# the title's are first, the subtitle's next.
func NextNPaths pcSvg, pnSkip, pnN
	_out_ = ""
	_s_ = pcSvg
	_i_ = 0
	_p_ = substr(_s_, '<path d="')
	while _p_ > 0 and _i_ < pnSkip + pnN
		_s_ = substr(_s_, _p_)
		_e_ = substr(_s_, ">")
		if _e_ = 0  exit ok
		_i_++
		if _i_ > pnSkip
			_out_ += left(_s_, _e_)
		ok
		_s_ = substr(_s_, _e_ + 1)
		_p_ = substr(_s_, '<path d="')
	end
	return _out_

func MakeTone nHz, nSecs, nAmp
	_o_ = StzSoundOfSilenceQ(nSecs, 1, 48000)
	_n_ = _o_.Frames()
	for _i_ = 1 to _n_
		_t_ = (_i_ - 1) / 48000
		_o_.SetSampleAt(_i_, 1, nAmp * sin(2 * 3.14159265358979 * nHz * _t_))
	next
	return _o_

func MakeSweep nFrom, nTo, nSecs
	_o_ = StzSoundOfSilenceQ(nSecs, 1, 48000)
	_n_ = _o_.Frames()
	_ph_ = 0
	for _i_ = 1 to _n_
		_u_ = (_i_ - 1) / _n_
		_hz_ = nFrom + (nTo - nFrom) * _u_
		_ph_ += 2 * 3.14159265358979 * _hz_ / 48000
		_o_.SetSampleAt(_i_, 1, 0.7 * sin(_ph_))
	next
	return _o_
