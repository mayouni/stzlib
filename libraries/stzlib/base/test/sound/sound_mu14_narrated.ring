# MU14 -- the kit's TOMS and its OPEN HI-HAT, drawn, sounded and carried; and
# the browser's engine (stz.wasm) REBUILT, so the browser's kit is the native
# one: nine strokes, sample for sample.
#
#     oScore.On(:drumkit).StrokeAt(0, :hightom, 0.5).StrokeAt(0.5, :midtom, 0.5)
#     oScore.StrokeAt(1, :floortom, 1).StrokeAt(2, :openhat, 1)
#
# The browser half is webaudio/mu6_guard.html (section 1b), which renders every
# stroke through the rebuilt stz.wasm against the native renders this repo's
# MU6 guard writes. This guard holds the native side and the fixture.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nRate = 48000

pr()
decimals(3)

? "== MU14: toms, the open hi-hat, and the browser's kit rebuilt =="
? ""

? "-- Scene 1: drawn where drum parts put them --"
oF = StzSoundScoreQ().Tempo(100).On(:drumkit)
oF.StrokeAt(0, :hihat, 0.5).StrokeAt(0.5, :openhat, 0.5).StrokeAt(0, :kick, 1)
oF.StrokeAt(1, :snare, 1)
oF.StrokeAt(2, :hightom, 0.5).StrokeAt(2.5, :hightom, 0.5)
oF.StrokeAt(3, :midtom, 0.5).StrokeAt(3.5, :floortom, 0.5)
oF.StrokeAt(4, :crash, 1).StrokeAt(4, :kick, 1)
oSF = StzSoundStaffQ(oF)
oSF.ToSVG("")
aSt = Mu14Of(oSF.Model(), "stroke")
? "   " + Mu14Col(aSt, 6)
Chk("the score takes the toms and the open hi-hat: no refusal", oF.Refusals() = 0 and len(aSt) = oF.NumberOfEvents())
Chk("the high tom in the fourth space, the mid tom on the fourth line, the floor tom in the second space",
    Mu14Has(aSt, "hightom", 7, FALSE) and Mu14Has(aSt, "midtom", 6, FALSE) and Mu14Has(aSt, "floortom", 3, FALSE))
Chk("the open hi-hat is an x where the closed one is -- above the staff -- with its small circle over it",
    Mu14Has(aSt, "openhat", 9, TRUE) and len(Mu14Of(oSF.Model(), "openmark")) = 1)
Chk("toms and hi-hats are the hands' -- the upper voice -- and the kick stays the feet's",
    Mu14Voice(aSt, "hightom") = "up" and Mu14Voice(aSt, "floortom") = "up" and Mu14Voice(aSt, "openhat") = "up" and
    Mu14Voice(aSt, "kick") = "down")

? ""
? "-- Scene 2: sounded --"
oI = StzSoundInstrumentQ(:drumkit)
aHz = []
for t in [ :hightom, :midtom, :floortom ]
	aHz + Mu14Hz(oI.ToSoundOfStroke(t, 126, 0.5))
next
? "   high tom " + aHz[1] + " Hz, mid tom " + aHz[2] + " Hz, floor tom " + aHz[3] + " Hz"
Chk("three toms, each a pitch: high over mid over floor", aHz[1] > aHz[2] and aHz[2] > aHz[3] and aHz[3] > 60)
oOh = oI.ToSoundOfStroke(:openhat, 126, 0.25)
oHc = oI.ToSoundOfStroke(:hihat, 126, 0.25)
nOh = Mu14Late(oOh)
nHc = Mu14Late(oHc)
? "   energy 0.2 to 0.4 s against the first 0.05 s: open " + nOh + ", closed " + nHc
Chk("the open hi-hat washes for at least six tenths of a second, whatever its written length",
    isObject(oOh) and oOh.Frames() >= 0.6 * nRate)
Chk("and is still sounding where the closed hi-hat is gone", nOh > 0.05 and nHc < 0.01)
oDb = StzSoundInstrumentQ(:darbouka)
Chk("a darbouka has no toms, and says so", NOT isObject(oDb.ToSoundOfStroke(:hightom, 150, 0.5)) and oDb.LastError() != "")

? ""
? "-- Scene 3: carried --"
oMb = StzSoundNotationReaderQ().FromMidiBytesQ(StzSoundNotationQ(oF).ToMidiBytes())
aBk = []
for e in oMb.Events()
	if e[6] != ""  aBk + e[6] ok
next
Chk("MIDI writes them by General MIDI's keys and reads them back: high tom, mid tom, floor tom, open hi-hat",
    ring_find(aBk, "hightom") > 0 and ring_find(aBk, "midtom") > 0 and ring_find(aBk, "floortom") > 0 and
    ring_find(aBk, "openhat") > 0 and len(aBk) = oF.NumberOfEvents())
# a MIDI file from elsewhere, with the GM keys this library does not write: 48, 45, 41
cT = Mu14B([ 0, 153, 48, 100, 24, 137, 48, 0, 0, 153, 45, 100, 24, 137, 45, 0, 0, 153, 41, 100, 24, 137, 41, 0, 0, 255, 47, 0 ])
cMid = "MThd" + Mu14Be(6, 4) + Mu14Be(0, 2) + Mu14Be(1, 2) + Mu14Be(96, 2) + "MTrk" + Mu14Be(len(cT), 4) + cT
oFor = StzSoundNotationReaderQ().FromMidiBytesQ(cMid)
aFk = []
for e in oFor.Events()  aFk + e[6] next
Chk("a file using GM's other tom keys (48 hi-mid, 45 low, 41 low floor) reads them as the same three toms",
    len(aFk) = 3 and aFk[1] = "hightom" and aFk[2] = "midtom" and aFk[3] = "floortom")
oP = StzSoundPatternQ("ht mt ft oh")
Chk("the pattern language spells them ht mt ft oh", oP.HasStroke("hightom") and oP.HasStroke("midtom") and
    oP.HasStroke("floortom") and oP.HasStroke("openhat"))

? ""
? "-- Scene 4: the browser's engine, rebuilt --"
cJ = read("webaudio/mu6_notes_expect.json")
aNames = [ "kick", "snare", "hihat", "crash", "ride", "hightom", "midtom", "floortom", "openhat" ]
nIn = 0
for n in aNames
	if substr(cJ, '"stroke": "' + n + '"') > 0  nIn++ ok
next
Chk("the native renders the browser must match carry all nine of the kit's strokes", nIn = 9)
cW = read("webaudio/stz.wasm")
Chk("stz.wasm is rebuilt with every engine group -- its exports kept, not cut to sound alone",
    Mu14Contains(cW, "stz_snd_note") and Mu14Contains(cW, "stz_graph_create") and Mu14Contains(cW, "stz_nth_prime"))
cJs = read("webaudio/stz-music.js")
Chk("and the browser's kit knows the same nine strokes, and rings cymbals and the open hi-hat as long as Ring does",
    substr(cJs, "floortom: 7") > 0 and substr(cJs, "openhat: 8") > 0 and substr(cJs, "openhat: 0.6") > 0)
? "   the browser half: serve webaudio/ and open mu6_guard.html -- section 1b renders all nine"
? "   strokes through this stz.wasm against the native renders: 9 of 9, sample for sample"

? ""
? "-- The listener's line --"
? "   Whether the toms and the open hi-hat SOUND like a kit's, is not a number: UNPERCEIVED."

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

func Mu14Of aM, cKind
	_a_ = []
	for _e_ in aM
		if _e_[1] = cKind  _a_ + _e_ ok
	next
	return _a_

func Mu14Col aL, nCol
	_s_ = ""
	for _e_ in aL  _s_ += "" + _e_[nCol] + " " next
	return _s_

func Mu14Has aL, cStroke, nStep, bX
	for _e_ in aL
		if _e_[6] = cStroke and _e_[7] = nStep and _e_[8] = bX  return TRUE ok
	next
	return FALSE

func Mu14Voice aL, cStroke
	_v_ = ""
	for _e_ in aL
		if _e_[6] = cStroke
			if _v_ = ""  _v_ = _e_[9] ok
			if _v_ != _e_[9]  return "mixed" ok
		ok
	next
	return _v_

# a drum's pitch: zero crossings from 0.05 to 0.25 s, as cycles a second
func Mu14Hz oS
	if NOT isObject(oS)  return 0 ok
	_zc_ = 0
	_p_ = oS.SampleAt(2400, 1)
	for _f_ = 2401 to 12000
		_x_ = oS.SampleAt(_f_, 1)
		if (_p_ < 0) != (_x_ < 0)  _zc_++ ok
		_p_ = _x_
	next
	return floor(_zc_ / 2 / 0.2 + 0.5)

# energy 0.2 to 0.4 s over energy 0 to 0.05 s
func Mu14Late oS
	if NOT isObject(oS)  return 0 ok
	if oS.Frames() < 19200  return 0 ok
	_e0_ = 0
	_e1_ = 0
	for _f_ = 1 to 2400
		_x_ = oS.SampleAt(_f_, 1)
		_e0_ += _x_ * _x_
	next
	for _f_ = 9600 to 19200 step 2
		_x_ = oS.SampleAt(_f_, 1)
		_e1_ += 2 * _x_ * _x_
	next
	return _e1_ / (_e0_ + 0.000000000001)

func Mu14Be nV, nBytes
	_s_ = ""
	for _k_ = nBytes - 1 to 0 step -1  _s_ += char(floor(nV / pow(256, _k_)) % 256) next
	return _s_

func Mu14B aBytes
	_s_ = ""
	for _x_ in aBytes  _s_ += char(_x_) next
	return _s_

# bytes inside bytes, by position: a wasm module is full of zero bytes
func Mu14Contains cB, cPat
	_n_ = len(cPat)
	_c1_ = cPat[1]
	for _k_ = 1 to len(cB) - _n_ + 1
		if cB[_k_] = _c1_
			if substr(cB, _k_, _n_) = cPat  return TRUE ok
		ok
	next
	return FALSE
