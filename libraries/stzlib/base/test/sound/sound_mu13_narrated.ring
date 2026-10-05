# MU13 -- TIME SIGNATURE CHANGES inside a piece, and the kit's CYMBALS.
#
#     StzSoundStaffQ(oScore).MeterChangeAt(8, 3, 4)       # 3/4 from beat 8
#     oScore.On(:drumkit).StrokeAt(0, :crash, 1).StrokeAt(0, :ride, 0.5)
#
# The cymbals are not only drawn: the score accepts them, the kit's synthesis
# rings them as metal (soundinstr.zig, the crash long, the ride with a bell),
# MIDI writes and reads them by General MIDI's keys, the pattern language
# spells them cr and rd. Held, as before, through the MODEL the page is drawn
# from and through the sound itself.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nRate = 48000

pr()
decimals(3)

? "== MU13: metre changes, and the kit's cymbals =="
? ""

? "-- Scene 1: the time signature changes at a barline --"
oT = StzSoundScoreQ().On(:flute)
for k = 0 to 7  oT.NoteAt(k, "C5", 1) next
for k = 0 to 5  oT.NoteAt(8 + k, "D5", 1) next
for k = 0 to 11  oT.NoteAt(14 + k * 0.5, "E5", 0.5) next
oW = StzSoundStaffQ(oT).SetWidth(1800).MeterChangeAt(8, 3, 4).MeterChangeAt(14, 6, 8)
oW.ToSVG("")
aM = oW.Model()
? "   " + Mu13Meters(oW.Meters()) + "-- " + oW.Bars() + " bars on " + oW.Systems() + " system"
Chk("4/4 for two bars, 3/4 for two, 6/8 for two: each bar the length its metre says", Mu13Meters(oW.Meters()) = "1:4/4 3:3/4 5:6/8 " and
    oW.Bars() = 6)
aMt = Mu13Of(aM, "meter")
Chk("the new signatures are drawn where they begin, inside the system", Mu13Col(Mu13Only(aMt, 7, "change"), 4) = "3 5 " and
    oW.Systems() = 1)
aBm = Mu13Of(aM, "beam")
Chk("in 6/8 the eighths are beamed in THREES, by the dotted quarter -- four groups in two bars",
    len(aBm) = 4 and Mu13Col(aBm, 5) = "3 3 3 3 ")
oX = StzSoundScoreQ().On(:flute).NoteAt(6, "G4", 4)
oSX = StzSoundStaffQ(oX).MeterChangeAt(8, 3, 4)
oSX.ToSVG("")
aHX = Mu13Of(oSX.Model(), "head")
Chk("a note across a barline into a shorter bar is split by the bars' OWN lengths: a half tied to a half",
    len(aHX) = 2 and aHX[1][10] = 8 and aHX[2][10] = 8 and len(Mu13Of(oSX.Model(), "tie")) = 1)
oY = StzSoundScoreQ().On(:flute).NoteAt(0, "A4", 4).NoteAt(4, "B4", 3)
oSY = StzSoundStaffQ(oY).MeterChangeAt(4, 3, 4)
oSY.ToSVG("")
Chk("and three beats fill a 3/4 bar as ONE dotted half, with no tie", Mu13Col(Mu13Of(oSY.Model(), "head"), 10) = "16 12 " and
    len(Mu13Of(oSY.Model(), "tie")) = 0)
# where only the SHORT bar's length can decide: a half note begun on the third
# beat of a 3/4 bar has one beat of room -- a quarter, tied over its barline
oZ = StzSoundScoreQ().On(:flute).NoteAt(0, "A4", 4).NoteAt(4, "B4", 2).NoteAt(6, "C5", 2).NoteAt(8, "D5", 2)
oSZ = StzSoundStaffQ(oZ).MeterChangeAt(4, 3, 4)
oSZ.ToSVG("")
Chk("a half note begun on beat 3 of a 3/4 bar is a quarter there, tied to a quarter over the barline",
    Mu13Col(Mu13Of(oSZ.Model(), "head"), 10) = "16 8 4 4 8 " and len(Mu13Of(oSZ.Model(), "tie")) = 1)
oOff = StzSoundStaffQ(oT).MeterChangeAt(9, 3, 4)
oOff.ToSVG("")
Chk("a change asked for inside a bar is written at the next barline, and counted",
    Mu13Meters(oOff.Meters()) = "1:4/4 4:3/4 " and Mu13Has(oOff.Losses(), "next barline"))
oBad = StzSoundStaffQ(oT).MeterChangeAt(8, 5, 3)
Chk("and a metre that is not one is refused", substr(oBad.LastError(), "unit of 2, 4, 8 or 16") > 0)
oKM = StzSoundStaffQ(oT).MeterChangeAt(8, 3, 4).KeyChangeAt(8, "D")
oKM.ToSVG("")
Chk("a key and a metre may change at the same barline: both are drawn there",
    Mu13Has(Mu13ColList(Mu13Of(oKM.Model(), "keysig"), 8), 3) and Mu13Has(Mu13ColList(Mu13Of(oKM.Model(), "meter"), 4), 3))

? ""
? "-- Scene 2: at the head of a system, and the courtesy signature before it --"
oN2 = StzSoundStaffQ(oT).SetWidth(420).MeterChangeAt(8, 3, 4).MeterChangeAt(14, 6, 8)
oN2.ToSVG("")
aMn = Mu13Of(oN2.Model(), "meter")
? "   a narrow page: " + oN2.Systems() + " systems; signatures " + Mu13Col(aMn, 7)
Chk("a system that begins with a change carries the new signature in its head",
    Mu13Has(Mu13ColList(Mu13Only(aMn, 7, "head"), 4), 3) and Mu13Has(Mu13ColList(Mu13Only(aMn, 7, "head"), 4), 5))
Chk("and the system before it ends with a COURTESY signature", Mu13Col(Mu13Only(aMn, 7, "courtesy"), 4) = "3 5 ")

? ""
? "-- Scene 3: the cymbals, drawn --"
oKit2 = StzSoundScoreQ().Tempo(100).On(:drumkit)
oKit2.StrokeAt(0, :crash, 1).StrokeAt(0, :kick, 1)
for b = 0 to 3
	oKit2.StrokeAt(b, :ride, 0.5).StrokeAt(b + 0.5, :ride, 0.5)
	if b % 2 = 1  oKit2.StrokeAt(b, :snare, 1) ok
next
oSK = StzSoundStaffQ(oKit2)
oSK.ToSVG("")
aSt = Mu13Of(oSK.Model(), "stroke")
? "   strokes: " + Mu13Col(aSt, 6)
Chk("the score takes the cymbals: no refusal", oKit2.Refusals() = 0 and Mu13Count(aSt, 6, "ride") = 8 and Mu13Count(aSt, 6, "crash") = 1)
Chk("the ride is an x on the top line, the crash an x above the staff -- on a ledger line of its own",
    Mu13HasStroke(aSt, "ride", 8, TRUE) and Mu13HasStroke(aSt, "crash", 10, TRUE) and len(Mu13Of(oSK.Model(), "ledger")) = 1)
Chk("and both are the hands' -- the upper voice, stems up", Mu13Voices(aSt, "ride") = "up" and Mu13Voices(aSt, "crash") = "up")

? ""
? "-- Scene 4: the cymbals, SOUNDED, and carried --"
oI = StzSoundInstrumentQ(:drumkit)
oCr = oI.ToSoundOfStroke(:crash, 126, 0.5)
oHh = oI.ToSoundOfStroke(:hihat, 126, 0.5)
oRd = oI.ToSoundOfStroke(:ride, 126, 0.5)
nCr = Mu13Late(oCr)
nHh = Mu13Late(oHh)
nRd = Mu13Late(oRd)
? "   energy after 0.6 s, against the first 0.1 s: crash " + nCr + ", ride " + nRd + ", hihat " + nHh
Chk("a crash written half a beat long still RINGS -- its sound lasts at least two seconds, as cymbals do",
    isObject(oCr) and oCr.Frames() >= 2 * nRate)
Chk("and is still sounding after 0.6 s, when the hihat has long gone", nCr > 0.05 and nHh < 0.001 and nRd > nHh * 10)
oDb = StzSoundInstrumentQ(:darbouka)
oNo = oDb.ToSoundOfStroke(:crash, 150, 1)
Chk("a darbouka has no cymbal, and says so: " + oDb.LastError(), NOT isObject(oNo) and oDb.LastError() != "")
oMb = StzSoundNotationReaderQ().FromMidiBytesQ(StzSoundNotationQ(oKit2).ToMidiBytes())
aBk = []
for e in oMb.Events()
	if e[6] != ""  aBk + e[6] ok
next
Chk("MIDI carries them by General MIDI's keys (crash 49, ride 51), and reads them back", ring_find(aBk, "crash") > 0 and
    ring_find(aBk, "ride") > 0 and len(aBk) = oKit2.NumberOfEvents())
oP = StzSoundPatternQ("cr rd rd rd")
Chk("the pattern language spells them cr and rd", oP.HasStroke("crash") and oP.HasStroke("ride"))

? ""
? "-- The listener's line --"
? "   Whether the crash and ride SOUND like cymbals, and the changing metres"
? "   read as an engraver writes them, is not a number: UNPERCEIVED."

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

func Mu13Of aM, cKind
	_a_ = []
	for _e_ in aM
		if _e_[1] = cKind  _a_ + _e_ ok
	next
	return _a_

func Mu13Only aL, nCol, cVal
	_a_ = []
	for _e_ in aL
		if _e_[nCol] = cVal  _a_ + _e_ ok
	next
	return _a_

func Mu13Col aL, nCol
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_[nCol] + " " next
	return _s_

func Mu13ColList aL, nCol
	_a_ = []
	for _e_ in aL  _a_ + _e_[nCol] next
	return _a_

func Mu13Count aL, nCol, cVal
	_n_ = 0
	for _e_ in aL
		if _e_[nCol] = cVal  _n_++ ok
	next
	return _n_

func Mu13Has aL, xVal
	for _x_ in aL
		if isString(_x_) and isString(xVal)
			if substr(_x_, xVal) > 0  return TRUE ok
		but _x_ = xVal
			return TRUE
		ok
	next
	return FALSE

func Mu13Meters aM
	_s_ = ""
	for _m_ in aM  _s_ += "" + _m_[1] + ":" + _m_[2] + "/" + _m_[3] + " " next
	return _s_

func Mu13HasStroke aL, cStroke, nStep, bX
	for _e_ in aL
		if _e_[6] = cStroke and _e_[7] = nStep and _e_[8] = bX  return TRUE ok
	next
	return FALSE

# the one voice a stroke is drawn in, or "mixed"
func Mu13Voices aL, cStroke
	_v_ = ""
	for _e_ in aL
		if _e_[6] = cStroke
			if _v_ = ""  _v_ = _e_[9] ok
			if _v_ != _e_[9]  return "mixed" ok
		ok
	next
	return _v_

# energy 0.6 to 1.0 s over energy 0 to 0.1 s, of a mono or stereo sound
func Mu13Late oS
	if NOT isObject(oS)  return 0 ok
	_n_ = oS.Frames()
	if _n_ < 48000  return 0 ok
	_e0_ = 0
	_e1_ = 0
	for _f_ = 1 to 4800
		_x_ = oS.SampleAt(_f_, 1)
		_e0_ += _x_ * _x_
	next
	for _f_ = 28800 to 48000 step 4
		_x_ = oS.SampleAt(_f_, 1)
		_e1_ += 4 * _x_ * _x_
	next
	return _e1_ / (_e0_ + 0.000000000001)
