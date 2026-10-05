# MU4 -- the universes. A tradition is DECLARED DATA: a tuning, movement
# rules, a cycle with accents, ornaments, instruments -- and its sources, and
# a listener's line that reads UNPERCEIVED until someone from it has heard it.
#
# Kill criterion (plan section 6): "a listener from the tradition says it is
# wrong." Recorded by name. This guard cannot run that criterion -- nothing
# here can. What it runs is everything BELOW it: that each declaration says
# what its sources say, that the render plays what the declaration says, and
# that where the sources are thin the declaration says so rather than filling
# the gap. The listener's line closes the file.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nRate = 48000

pr()
decimals(3)

? "== MU4: eight universes, declared, and the same phrase in each =="
? ""

? "-- Scene 1: eight declarations, and they are DATA --"
aU = StzSoundUniverses()
? "   " + len(aU) + ": " + Joined(aU)
Chk("the plan's eight universes are declared", len(aU) = 8)
bAll = TRUE
for u in aU
	o = StzSoundUniverseQ(u)
	# the Tunisian universe has been HEARD (2026-09-26) and its line says so;
	# every other still reads UNPERCEIVED -- a listener line may only change
	# when a person has listened
	_cWant_ = "UNPERCEIVED"
	if u = "tunisian"  _cWant_ = "HEARD" ok
	if NOT o.IsUsable() or len(o.Sources()) = 0 or ring_left(o.Listener(), len(_cWant_)) != _cWant_  bAll = FALSE ok
next
Chk("each loads and names its sources; seven read UNPERCEIVED, and Tunisia records who heard it", bAll)
? "   tunisian: " + StzSoundUniverseQ(:tunisian).Listener()
nLogic = 0
for u in aU
	cT = read("../../sound/universes/" + u + ".ring")
	for cL in Mu4Lines(cT)
		cW = lower(trim(cL))
		if StartsWithAny(cW, [ "if ", "for ", "while ", "switch ", "but ", "else" ])  nLogic++ ok
	next
next
Chk("and not one line of logic lives in a universe file: 0 if/for/while/switch/else", nLogic = 0)

? ""
? "-- Scene 2: the tunings, MEASURED on the instrument that plays them --"
? "   MU1 proved the instruments in tune to 0.417 cents. So the number that"
? "   can go wrong here is the universe's: degree -> cents -> Hz. Each interval"
? "   below is read off two rendered notes by the fine pitch instrument, and"
? "   held against the declaration."
aI = [
	[ :maqam, :rast, "3", "1", 350, "Rast's half-flat third" ],
	[ :maqam, :hijaz, "3", "2", 300, "Hijaz's augmented second" ],
	[ :tunisian, :sika, "2", "1", 150, "Tunisian Sika's three-quarter step" ],
	[ :tunisian, :sika_hijaz, "5", "4", 250, "the 'Tunisian hijaz' five-quarter step" ],
	[ :tunisian, :rasdaldhil, "4", "3", 200, "Rasd al-Dhil's e-half-flat to f-half-sharp (Snoussi)" ],
	[ :raga, :yaman, "4", "1", 590, "Yaman's tivra Ma (45/32)" ],
	[ :flamenco, :phrygian, "2", "1", 100, "the Phrygian half step" ],
	[ :niger, :zarma, "2", "1", 300, "the placeholder pentatonic's minor third" ] ]
nWorst = 0
for r in aI
	o = StzSoundUniverseQ(r[1]).Mode(r[2])
	nA = MeasureDegree(o, r[3])
	nB = MeasureDegree(o, r[4])
	nC = Cents(nA, nB)
	nErr = fabs(nC - r[5])
	if nErr > nWorst  nWorst = nErr ok
	? "   " + Pad(r[6], 52) + " declared " + PadN(r[5], 4) + "   measured " + nC
next
Chk("every interval measured within 2 cents of its declaration (worst " + nWorst + ")", nWorst < 2)

o = StzSoundUniverseQ(:gamelan)
nOct = Cents(MeasureDegreeSpectral(o, "6"), MeasureDegreeSpectral(o, "1"))
? "   slendro's octave, averaged over 30 gamelans: declared 1208, measured " + nOct
Chk("slendro's octave is STRETCHED -- 1208, not 1200 -- within 2 cents", fabs(nOct - 1208) < 2)

? ""
? "-- Scene 3: one phrase, eight universes --"
cPhrase = "1 2 3 4 5 4 3 2"
? "   the phrase: " + char(34) + cPhrase + char(34) + " -- degrees, so it means something in each"
aSeqs = []
for u in aU
	o = StzSoundUniverseQ(u)
	o.PerformQ(cPhrase, 1)
	cS = ""
	for n in o.PlayedNotes()  cS += "" + n[3] + " " next
	if cS = ""  cS = "(refused: " + o.LastError() + ")" ok
	? "   " + Pad(u + "/" + o.ModeName(), 22) + cS
	aSeqs + [ u, cS ]
next
Chk("the West African timeline REFUSES a phrase: it declares a rhythm, not a scale",
    substr(SeqOf(aSeqs, "westafrican"), "refused") > 0)
Chk("the West differs from Rast on the third: 400 against 350",
    substr(SeqOf(aSeqs, "western"), "0 200 400") = 1 and substr(SeqOf(aSeqs, "maqam"), "0 200 350") = 1)
# THE HONEST ONE. On the quarter-tone grid Snoussi's Dhil and textbook Rast are
# the same seven numbers. The sources place Dhil's difference in a third that
# MOVES (300 / 350 / 400 in one 1932 recording) and a "very high" seventh --
# neither of which a fixed list can carry. This check asserts the equality
# instead of hiding it, and the declaration carries the variants.
Chk("Dhil's declared skeleton EQUALS Rast's -- said, not hidden; its moving third is declared as a variant",
    SeqOf(aSeqs, "tunisian") = SeqOf(aSeqs, "maqam") and
    len(StzSoundUniverseQ(:tunisian).Mode(:dhil).Declaration()) > 0)
nDistinct = 0
aSeen = []
for s in aSeqs
	if ring_find(aSeen, s[2]) = 0  aSeen + s[2]  nDistinct++ ok
next
Chk("seven distinct renderings of one phrase, plus the one refusal (Dhil = Rast on paper)",
    nDistinct = 7)

? ""
? "-- Scene 4: movement, not only pitch --"
oRst = StzSoundUniverseQ(:maqam).Mode(:rast)
oRst.PerformQ("5 6 7 8 7 6 5", 1)
aN = oRst.PlayedNotes()
? "   Rast, 5 6 7 8 7 6 5: the seventh up " + aN[3][3] + ", down " + aN[5][3]
Chk("Rast ascends through the half-flat seventh (1050) and descends through the flat (1000)",
    aN[3][3] = 1050 and aN[5][3] = 1000)
oF = StzSoundUniverseQ(:flamenco)
oF.PerformQ("1 2 3 4 3 2 1", 1)
aF = oF.PlayedNotes()
Chk("the flamenco third is raised going up (400) and natural coming down (300)",
    aF[3][3] = 400 and aF[5][3] = 300)
aC1 = StzSoundUniverseQ(:raga).Check("1 2 3 4 5")
aC2 = StzSoundUniverseQ(:raga).Check("5 4 3 2 1")
? "   Yaman, 1 2 3 4 5: " + aC1[1]
Chk("Yaman's rule catches Pa taken going up, and passes the same notes going down",
    len(aC1) = 1 and len(aC2) = 0)
aC3 = StzSoundUniverseQ(:tunisian).Mode(:rasdaldhil).Check("5 4 3")
Chk("Rasd al-Dhil's declared habit catches the fourth taken going down (Ghanim, 1932)",
    len(aC3) = 1)

? ""
? "-- Scene 5: the cycles, as their sources give them --"
Chk("the 12/8 bell strikes pulses 1 3 5 6 8 10 12 -- no more, no fewer",
    Mu4Positions(:westafrican, "standard", 1, 12) = "1 3 5 6 8 10 12")
Chk("solea: twelve beats, accents on 3 6 8 10 12",
    AccentsOf(:flamenco, "solea") = "3 6 8 10 12")
# THE FIRST VERSION OF THIS CHECK FAILED, AND THE CLAIM WAS WRONG, NOT THE
# DATA. It asserted the bass absent on beats 9-12. The source's theka is
# dha dhin dhin dha | dha dhin dhin dha | dha tin tin ta | ta dhin dhin dha:
# khali's beat 9 is still dha, and the bass drops out on the tin tin ta ta
# of 10-13. The pattern followed the source; the sentence about it did not.
Chk("teental: sixteen, khali's dha on 9, and the bass absent on 10-13 (tin tin ta ta)",
    StrokesAt(:raga, "teental", 9, 9) = "dum" and StrokesAt(:raga, "teental", 10, 13) = "tak tak tak tak" and
    StrokesAt(:raga, "teental", 1, 4) = "dum dum dum dum")
Chk("lancaran: gong on 16, kenong 4 8 12 16, kempul 6 10 14, ketuk on the odd beats",
    Mu4Positions(:gamelan, "lancaran", 1, 16) = "16" and Mu4Positions(:gamelan, "lancaran", 2, 16) = "4 8 12 16" and
    Mu4Positions(:gamelan, "lancaran", 3, 16) = "6 10 14" and Mu4Positions(:gamelan, "lancaran", 4, 16) = "1 3 5 7 9 11 13 15")
Chk("tende n-emnas: strokes on eighths 1 4 5 7 8, claps on 3 and 7 (Schmidt 2018)",
    Mu4Positions(:niger, "tende", 1, 8) = "1 4 5 7 8" and Mu4Positions(:niger, "tende", 2, 8) = "3 7")
oT = StzSoundUniverseQ(:tunisian)
aMet = []
bSilent = TRUE
for c in [ "btayhi", "barwal", "draj", "khafif", "khatm" ]
	oT.Cycle(c)
	aMet + oT._Get(oT.@aCycle, :beats, 0)
next
for c in [ "draj", "khafif", "khatm" ]
	oT.Cycle(c)
	if len(oT._Get(oT.@aCycle, :layers, [ 1 ])) != 0  bSilent = FALSE ok
next
? "   the nuba's five, in order: btayhi 8, barwal 2, draj 6, khafif 6, khatm 3 (beats)"
Chk("the five iqa'at are declared in the nuba's order with the CNRS meters",
    aMet[1] = 8 and aMet[2] = 2 and aMet[3] = 6 and aMet[4] = 6 and aMet[5] = 3)
Chk("and the three whose strokes no source gave play NONE -- silent, not invented", bSilent)

? ""
? "-- Scene 6: ornaments that are heard, not only written --"
oY = StzSoundUniverseQ(:raga)
oYs = oY.PerformQ("1 2", 1)
aYn = oY.PlayedNotes()
Chk("Yaman's meend: the step up into Re is written as a slide", aYn[2][5] = "slide")
oG = StzSoundInstrumentQ(:Flute).ToSoundOfGlide(aYn[1][4], aYn[2][4], 1.2)
nEarly = StzEngineSoundMeasurePitch(oG.BufferId(), 2401, aYn[1][4], 0)
nLate = StzEngineSoundMeasurePitch(oG.BufferId(), 45601, aYn[2][4], 0)
? "   the meend on the flute: " + nEarly + " Hz near its start, " + nLate + " Hz near its end " +
  "(Sa " + aYn[1][4] + ", Re " + aYn[2][4] + ")"
Chk("and it is a GLIDE: it starts near Sa and ends near Re", nEarly < aYn[1][4] * 1.03 and
    nLate > aYn[2][4] * 0.97 and nLate > nEarly)
oP = StzSoundUniverseQ(:gamelan).Mode(:slendro_paired)
oP.NoCycle(4)                     # the pair alone: no gong, no ketuk, in the reading
oPs = oP.PerformQ("1", 1)
nBeat = Mu4BeatRate(oPs, oP.HzOf("1", FALSE))
? "   slendro_paired: two metallophones 6 Hz apart, their sum's envelope beats at " + nBeat + " Hz"
Chk("the paired detuning is HEARD as beating at 6 Hz (within 0.5)", fabs(nBeat - 6) < 0.5)

? ""
? "-- Scene 7: a sentence of a tonal language, drummed --"
oNig = StzSoundUniverseQ(:niger)
oKal = oNig.SentenceQ("sannu da zuwa")
aK = oNig.PlayedNotes()
cTones = ""
for k in aK  cTones += k[3] + " " next
? "   sannu da zuwa ('welcome'): " + trim(cTones) + "  -- Newman's tones, low-high-low-high-low"
Chk("the declared contour is L H L H L", trim(cTones) = "L H L H L")
oKals = oKal.ToSound().ToMonoQ()      # the pitch instrument reads MONO; a score renders stereo
nH = StzEngineSoundMeasurePitch(oKals.BufferId(), floor(aK[2][1] * 60 / 84 * nRate) + 1201, 220, 1)
nL = StzEngineSoundMeasurePitch(oKals.BufferId(), floor(aK[3][1] * 60 / 84 * nRate) + 1201, 165, 1)
? "   measured on the kalangu: 'nu' " + nH + " Hz, 'da' " + nL + " Hz -- a fourth, the declared choice"
Chk("the drum speaks the contour: 'nu' high, 'da' low, each within 1% of its declared pitch",
    fabs(nH - 220) / 220 < 0.01 and fabs(nL - 165) / 165 < 0.01)
Chk("and the long vowel of 'waa' lasts twice as long as the others",
    aK[5][1] - aK[4][1] = aK[2][1] - aK[1][1] and oKal.Beats() - aK[5][1] = 2 * (aK[2][1] - aK[1][1]))

? ""
? "-- Scene 8: every gamelan is tuned differently, on purpose --"
oA = StzSoundUniverseQ(:gamelan).Mode(:slendro)
oB = StzSoundUniverseQ(:gamelan).Mode(:kanyutmesem)
nDA = Cents(MeasureDegreeSpectral(oA, "5"), MeasureDegreeSpectral(oA, "1"))
nDB = Cents(MeasureDegreeSpectral(oB, "5"), MeasureDegreeSpectral(oB, "1"))
? "   degree 6 (nem) above 1: the average of 30 gamelans " + nDA + ", Kyai Kanyut Mesem " + nDB
Chk("two real gamelans, the same phrase, two answers 18 cents apart on nem (955 vs 937)",
    fabs((nDA - nDB) - 18) < 2)

? ""
? "-- Scene 9: refusals --"
Chk("an unknown universe is refused, naming the eight", NOT StzSoundUniverseQ(:mars).IsUsable() and
    substr(StzSoundUniverseQ(:mars).LastError(), "flamenco") > 0)
oQ = StzSoundUniverseQ(:maqam)
oQ.Mode(:bayati)
Chk("an undeclared mode is refused, naming the declared ones -- Bayati is not declared",
    substr(oQ.LastError(), "rast, hijaz") > 0)
oQ2 = StzSoundUniverseQ(:maqam)
oQ2.PerformQ("1 x 3", 1)
Chk("a word that is not a degree is refused", substr(oQ2.LastError(), "not a degree") > 0)

? ""
? "-- Scene 10: THE PHASE GATE, and section 4 in the universe's words --"
oM = StzMusicQ().In(:Maqam, :Hijaz, :D)
oMs = oM.PhraseToSound("1 2 3 4 5 4 3 2", 1)
Chk("StzMusicQ().In(:Maqam, :Hijaz, :D) plays a phrase, with no refusal",
    isObject(oMs) and oMs.Frames() > 0 and oM.Refusals() = 0)
oOne = StzMusicQ().ToSound("c e g c5").ToMonoQ()
nW = 0
aHz = [ 261.6256, 329.6276, 391.9954, 523.2511 ]
for k = 1 to 4
	nHz = StzEngineSoundMeasurePitch(oOne.BufferId(), (k - 1) * 24000 + 4801, aHz[k], 0)
	if fabs(Cents(nHz, aHz[k])) > nW  nW = fabs(Cents(nHz, aHz[k])) ok
next
Chk("and the first line still makes C E G C within 2 cents (worst " + nW + ")", nW < 2)

? ""
? "-- The listener's line --"
? "   Every universe above reads UNPERCEIVED. The kill criterion is a person"
? "   from each tradition saying it is wrong -- or right -- by name. Where the"
? "   sources were thin (Tunisian strokes, the Zarma scale, takamba), the"
? "   declaration says so, and that person is not a check on it: they are the"
? "   only source it has."

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

func Cents nA, nB
	if nA <= 0 or nB <= 0  return 9999 ok
	return 1200 * log(nA / nB) / log(2)

func Joined paList
	_s_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _s_ += ", " ok
		_s_ += "" + paList[_i_]
	next
	return _s_

func Pad cS, nW
	_s_ = "" + cS
	while len(_s_) < nW  _s_ += " " end
	return _s_

func PadN nV, nW
	_s_ = "" + nV
	while len(_s_) < nW  _s_ = " " + _s_ end
	return _s_

func Mu4Lines cT
	_a_ = []
	_w_ = ""
	for _k_ = 1 to len(cT)
		if cT[_k_] = nl
			_a_ + _w_
			_w_ = ""
		but cT[_k_] != char(13)
			_w_ += cT[_k_]
		ok
	next
	_a_ + _w_
	return _a_

func StartsWithAny cW, aP
	for _p_ in aP
		if ring_left(cW, len(_p_)) = _p_  return TRUE ok
	next
	return FALSE

# One degree of a mode, rendered on the mode's own instrument and read back by
# the harmonic pitch instrument from 0.25 s.
func MeasureDegree oU, cDeg
	_hz_ = oU.HzOf(cDeg, FALSE)
	_o_ = StzSoundInstrumentQ(oU.Melody()).ToSoundOf(_hz_, 1.2)
	_r_ = StzEngineSoundMeasurePitch(_o_.BufferId(), 12001, _hz_, 0)
	_o_.Release()
	return _r_

# The same, for an inharmonic bar: the spectral instrument, on its lowest mode.
func MeasureDegreeSpectral oU, cDeg
	_hz_ = oU.HzOf(cDeg, FALSE)
	_o_ = StzSoundInstrumentQ(oU.Melody()).ToSoundOf(_hz_, 1.2)
	_r_ = StzEngineSoundMeasurePitch(_o_.BufferId(), 2401, _hz_, 1)
	_o_.Release()
	return _r_

func SeqOf aS, cU
	for _s_ in aS
		if _s_[1] = cU  return _s_[2] ok
	next
	return ""

# the 1-based positions a cycle's layer strikes, of nSlots
func Mu4Positions pU, cCycle, nLayer, nSlots
	_o_ = StzSoundUniverseQ(pU)
	_o_.Cycle(cCycle)
	_L_ = _o_._Get(_o_.@aCycle, :layers, [])[nLayer]
	if len(_L_) >= 3
		_p_ = StzSoundDegreePatternQ(_L_[2])
	else
		_p_ = StzSoundPatternQ(_L_[2])
	ok
	_s_ = ""
	for _e_ in _p_.CycleEvents(0)
		if _s_ != ""  _s_ += " " ok
		_s_ += "" + (floor(_e_[1] * nSlots + 0.5) + 1)
	next
	return _s_

func AccentsOf pU, cCycle
	_o_ = StzSoundUniverseQ(pU)
	_o_.Cycle(cCycle)
	_s_ = ""
	for _a_ in _o_._Get(_o_.@aCycle, :accents, [])
		if _s_ != ""  _s_ += " " ok
		_s_ += "" + _a_
	next
	return _s_

func StrokesAt pU, cCycle, nFrom, nTo
	_o_ = StzSoundUniverseQ(pU)
	_o_.Cycle(cCycle)
	_p_ = StzSoundPatternQ(_o_._Get(_o_.@aCycle, :layers, [])[1][2])
	_B_ = _o_._Get(_o_.@aCycle, :beats, 16)
	_s_ = ""
	for _e_ in _p_.CycleEvents(0)
		_pos_ = floor(_e_[1] * _B_ + 0.5) + 1
		if _pos_ >= nFrom and _pos_ <= nTo
			if _s_ != ""  _s_ += " " ok
			_s_ += _e_[4]
		ok
	next
	return _s_

# The beat rate of two tones summed: RMS in 5 ms windows over one second of
# the performance, and the envelope's minima counted. Nothing from the
# declaration is used -- only the sound.
func Mu4BeatRate oS, nHz
	_o_ = oS.ToSound().ToMonoQ()
	_w_ = 240
	_a_ = []
	for _k_ = 0 to 199
		_acc_ = 0
		for _f_ = 1 to _w_
			_x_ = _o_.SampleAt(4801 + _k_ * _w_ + _f_, 1)
			_acc_ += _x_ * _x_
		next
		_a_ + sqrt(_acc_ / _w_)
	next
	_mins_ = 0
	for _k_ = 3 to len(_a_) - 2
		if _a_[_k_] < _a_[_k_ - 1] and _a_[_k_] <= _a_[_k_ + 1] and
		   _a_[_k_] < _a_[_k_ - 2] and _a_[_k_] <= _a_[_k_ + 2]
			_mins_++
		ok
	next
	return _mins_
