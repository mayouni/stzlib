# MU7 -- the convergence. The plan's four transforms on ONE stzSoundScore:
#
#     data  --RENDER-->   score   (SonifyQ: a series becomes a melody in a universe)
#     score --SYNTHESISE--> sound  (ToSound: the instruments of MU1)
#     sound --RECOGNISE--> score   (the transcriber: onsets + pitch, confidence per note)
#     score --ANALYSE-->   data    (range, density, contour, which declared mode fits)
#     score --NOTATE-->    ABC, MusicXML, a MIDI file
#
# and Niger's row: TEXT --> DRUM (tone-marked Hausa becomes a kalangu contour).
#
# Kill criterion (plan section 6): "the four transforms compose on one
# stzScore with no adapter, or the missing step is named as VC6 named its."

load "../../stzBase.ring"

nPass = 0
nFail = 0
nRate = 48000

pr()
decimals(3)

? "== MU7: data -> score -> sound -> score -> data, and notation, on one object =="
? ""

? "-- Scene 1: RENDER -- a series becomes a melody in a declared universe --"
aSeries = [ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ]
oU = StzSoundUniverseQ(:maqam).NoCycle(4)
oS = oU.SonifyQ(aSeries)
? "   the series " + JoinL(aSeries) + "-> Rast degrees " + JoinL(oU.SonifiedDegrees()) +
  "(top allowed: " + oU.SonifiedTop() + ", the oud's range)"
Chk("the lowest value is degree 1, the highest the top the instrument allows, and the rest in proportion",
    JoinL(oU.SonifiedDegrees()) = JoinL(aSeries) and oU.SonifiedTop() = 11)
Chk("one note per value, on the score every transform shares", oS.NumberOfEvents() = 10 and
    classname(oS) = "stzsoundscore")
oW = StzSoundUniverseQ(:western).NoCycle(4).On(:oud)
oSW = oW.SonifyQ(aSeries)
Chk("the same series in the West keeps its contour and changes its intervals: 400 against Rast's 350",
    oSW.Contour() = oS.Contour() and fabs(Cents(oSW.PitchedEvents()[2][3], oSW.PitchedEvents()[1][3]) - 400) < 0.01 and
    fabs(Cents(oS.PitchedEvents()[2][3], oS.PitchedEvents()[1][3]) - 350) < 0.01)
oBad = StzSoundUniverseQ(:maqam)
oBad.SonifyQ([ 5, 5, 5 ])
Chk("a series that does not move is refused, not played as one repeated note",
    substr(oBad.LastError(), "does not move") > 0)

? ""
? "-- Scene 2: SYNTHESISE, then RECOGNISE -- the sound becomes a score again --"
oSnd = oS.ToSound()
oTr = StzSoundTranscriberQ().SetInstrument(oU.Melody())
oBack = oTr.TranscribeQ(oSnd, oS.TempoInBpm())
aA = oS.PitchedEvents()
aB = oBack.PitchedEvents()
? "   " + len(aA) + " notes rendered, " + len(aB) + " transcribed, " + len(oTr.Unpitched()) + " onsets without a pitch"
nWorstMs = 0
nWorstC = 0
nLowConf = 1
for k = 1 to len(aA)
	if k > len(aB)  exit ok
	nMs = fabs(aB[k][1] - aA[k][1]) * 60 / oS.TempoInBpm() * 1000
	nC = fabs(Cents(aB[k][3], aA[k][3]))
	if nMs > nWorstMs  nWorstMs = nMs ok
	if nC > nWorstC  nWorstC = nC ok
	if oTr.Confidences()[k] < nLowConf  nLowConf = oTr.Confidences()[k] ok
next
? "   worst onset " + nWorstMs + " ms, worst pitch " + nWorstC + " cents, lowest confidence " + nLowConf
Chk("every note comes back: the same count", len(aB) = len(aA))
Chk("each onset within 1 ms of where the score put it", nWorstMs < 1)
Chk("each pitch within 2 cents -- the half-flat third included", nWorstC < 2)
Chk("and each carries a confidence (the pitch reader's clarity), all above 0.9", nLowConf > 0.9)
# THE FIRST TRANSCRIBER FAILED HERE, THREE WAYS, and each changed it:
#  - SN5's spectral-flux onsets missed notes and ran up to a window (43 ms)
#    early, so pitches were read inside the previous note -> onsets now come
#    from the first difference's energy, refined to the sample;
#  - a plucked note still rings when the next begins, and the two together are
#    periodic at their COMMON period (C4 under G4: 130.8 Hz) -> each reading
#    and its multiples are scored by which gained energy at the onset;
#  - a level threshold placed notes 6 ms early over a ringing tail -> the
#    refinement reads the attack's edge, not its level.
oNoise = new stzSound("")
oNoise.MakeSilence(1, 1, nRate)
for f = 1 to 48000 step 1  oNoise.SetSampleAt(f, 1, (random(2000) - 1000) / 4000) next
oTrN = StzSoundTranscriberQ()
oBackN = oTrN.TranscribeQ(oNoise, 120)
Chk("noise is not music: no pitched note is transcribed from it", len(oBackN.PitchedEvents()) = 0)

? ""
? "-- Scene 3: ANALYSE -- the transcribed score becomes data --"
aBest = oBack.BestModes(4)
for m in aBest
	? "   " + Pad(m[1] + "/" + m[2], 26) + " tonic " + floor(m[3] * 100) / 100 + " Hz, " +
	  floor(m[4] * 100) / 100 + " cents off on average"
next
Chk("the contour survives the round trip: " + oBack.Contour(), oBack.Contour() = oS.Contour())
Chk("the best-fitting declared modes are Rast and Dhil, TIED -- the same seven numbers on paper (MU4)",
    ((aBest[1][2] = "rast" and aBest[2][2] = "dhil") or (aBest[1][2] = "dhil" and aBest[2][2] = "rast")) and
    fabs(aBest[1][4] - aBest[2][4]) < 0.001 and aBest[1][4] < 2)
nWest = 999
for m in oBack.BestModes(40)
	if m[1] = "western" and m[4] < nWest  nWest = m[4] ok
next
? "   the nearest Western mode is " + floor(nWest * 100) / 100 + " cents off on average"
Chk("and the West is far behind: the half-flat third and seventh do not fit a twelve-tone mode", nWest > 10)
Chk("range and density are numbers a caller can use: " + floor(oBack.RangeInCents()) + " cents, " +
    oBack.Density() + " notes a beat", oBack.RangeInCents() > 1000 and oBack.Density() > 0.9)

? ""
? "-- Scene 4: NOTATE -- ABC, MusicXML, and a MIDI file read back --"
oN = StzSoundNotationQ(oBack)
cAbc = oN.ToABC("Rast, sonified and transcribed")
? "   ABC:"
for cL in Mu7Lines(cAbc)  ? "     " + cL next
Chk("ABC writes Rast's half-flat third in ABC 2.1's own quarter-tone mark: _/E",
    substr(cAbc, "_/E") > 0)
cXml = oN.ToMusicXML("Rast, sonified and transcribed")
aXmlCheck = Mu7XmlBalanced(cXml)
? "   MusicXML: " + len(cXml) + " characters, " + aXmlCheck[2] + " elements, well-formed: " + aXmlCheck[1]
Chk("MusicXML is well-formed (every element closed, one root) and carries the quarter tone as <alter>-0.5</alter>",
    aXmlCheck[1] and substr(cXml, "<alter>-0.5</alter>") > 0)
nBytes = oN.ToMidiFile("mu7_rast.mid")
aMidi = Mu7ReadMidi("mu7_rast.mid")
? "   MIDI: " + nBytes + " bytes; read back by a reader written apart from the writer: " +
  len(aMidi[2]) + " notes at " + aMidi[1] + " BPM"
nWorstMidi = 0
for k = 1 to len(aMidi[2])
	if k > len(aB)  exit ok
	nC = fabs(Cents(aMidi[2][k][2], aB[k][3]))
	if nC > nWorstMidi  nWorstMidi = nC ok
next
Chk("the MIDI file holds every note, at the score's tempo",
    len(aMidi[2]) = len(aB) and fabs(aMidi[1] - oBack.TempoInBpm()) < 0.01)
Chk("and every pitch, key + bend, within 1 cent -- quarter tones and all (worst " + nWorstMidi + ")",
    nWorstMidi < 1)
? "   what the formats could not carry: " + len(oN.Losses()) + " kinds"
for cLs in oN.Losses()  ? "     - " + cLs next

oSl = StzSoundUniverseQ(:gamelan).NoCycle(4).SonifyQ([ 1, 2, 3, 4, 5 ])
oNs = StzSoundNotationQ(oSl)
oNs.ToMusicXML("slendro")
aSlLoss = oNs.Losses()          # Losses() are the LAST export's -- read them before the next one
bSlLoss = FALSE
for cLs in aSlLoss
	if substr(cLs, "nearest quarter tone") > 0  bSlLoss = TRUE ok
next
oNs.ToMidiFile("mu7_slendro.mid")
aMs = Mu7ReadMidi("mu7_slendro.mid")
aSlP = oSl.PitchedEvents()
nWs = 0
for k = 1 to len(aMs[2])
	nC = fabs(Cents(aMs[2][k][2], aSlP[k][3]))
	if nC > nWs  nWs = nC ok
next
? "   slendro (231, 474, 717, 955 cents): MusicXML reports '" + aSlLoss[1] + "'; MIDI keeps it within " + nWs + " cents"
Chk("a pitch no Western format can write is COUNTED as lost in notation, and KEPT by MIDI's bends",
    bSlLoss and len(aMs[2]) = len(aSlP) and nWs < 1)

? ""
? "-- Scene 5: THE KILL CRITERION -- one object, no adapter --"
? "   data -> SonifyQ -> stzSoundScore -> ToSound -> stzSound -> TranscribeQ ->"
? "   stzSoundScore -> BestModes / Contour / ToABC / ToMusicXML / ToMidiFile."
? "   Every arrow above took the object the last one returned, unchanged."
Chk("the four transforms compose on one stzSoundScore: every step above ran on what the last returned",
    classname(oS) = "stzsoundscore" and classname(oBack) = "stzsoundscore" and len(aB) = len(aA) and
    nBytes > 0 and aXmlCheck[1])
? "   THE MISSING STEPS, named as VC6 named its:"
? "     1. sound -> score cannot say WHICH drum stroke a hit was: an unpitched onset is kept"
? "        (Unpitched) with its time, not guessed into a dum or a tak;"
? "     2. the transcriber is MONOPHONIC: it hears one new note at a time, and a chord"
? "        comes back as its loudest new pitch;"
? "     3. ABC and MusicXML cannot carry slendro or a just-intoned Yaman: such pitches"
? "        are written at the nearest quarter tone and COUNTED (Losses) -- MIDI carries them."

? ""
? "-- Scene 6: TEXT -> DRUM -- Niger's row --"
oNg = StzSoundUniverseQ(:niger)
cHausa = "sànnu dà zuwàa"
aSy = oNg.ToneSyllables(cHausa)
cRead = ""
for y in aSy  cRead += y[1] + ":" + y[2] + y[3] + " " next
? "   " + char(34) + cHausa + char(34) + " (Newman's marks: none = High, grave = Low) -> " + cRead
cContour = ""
for y in aSy  cContour += y[2] next
cDeclared = ""
oNg.SentenceQ("sannu da zuwa")
for n in oNg.PlayedNotes()  cDeclared += n[3] next
Chk("the tone-marked text is read as the declared sentence's contour: " + cContour + " = " + cDeclared,
    cContour = cDeclared and cContour = "LHLHL")
Chk("and 'waa', a long vowel, is heavy: two units", aSy[5][3] = 2)
oDrum = oNg.DrumTonesQ(cHausa).ToSound().ToMonoQ()
nHi = StzEngineSoundMeasurePitch(oDrum.BufferId(), floor(0.5 * 60 / 84 * nRate) + 1201, 220, 1)
nLo = StzEngineSoundMeasurePitch(oDrum.BufferId(), floor(1.0 * 60 / 84 * nRate) + 1201, 165, 1)
? "   drummed: 'nu' " + nHi + " Hz, 'da' " + nLo + " Hz"
Chk("the kalangu speaks the contour -- 'nu' high, 'da' low, each within 1%",
    fabs(nHi - 220) / 220 < 0.01 and fabs(nLo - 165) / 165 < 0.01)
aF = oNg.ToneSyllables("sâ")
Chk("a circumflex is a FALLING tone, which the drum glides", len(aF) = 1 and aF[1][2] = "F")
Chk("everyday Hausa, which marks no tones, is REFUSED -- read as all-High it would lie",
    len(oNg.ToneSyllables("sannu da zuwa")) = 0 and substr(oNg.LastError(), "no tone marks") > 0)
oSay = oNg.SayOnDrum(cHausa)
? "   SayOnDrum: " + oNg.LastError()
Chk("and SayOnDrum -- the verb the plan names -- REFUSES until a Hausa speaker has heard it",
    isNull(oSay) and substr(oNg.LastError(), "UNPERCEIVED") > 0)

? ""
? "-- The listener's line --"
? "   Two things here are not numbers. Is a sonified series MUSIC to a listener"
? "   from its universe -- or a meter in costume? And does the drum SAY 'sannu"
? "   da zuwa' to a Hausa speaker? Both read UNPERCEIVED; the second one gates"
? "   SayOnDrum by the plan's own words."

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

func JoinL aL
	_s_ = ""
	for _x_ in aL  _s_ += "" + _x_ + " " next
	return _s_

func Pad cS, nW
	_s_ = "" + cS
	while len(_s_) < nW  _s_ += " " end
	return _s_

func Mu7Lines cT
	_a_ = []
	_w_ = ""
	for _k_ = 1 to len(cT)
		if cT[_k_] = nl
			if _w_ != ""  _a_ + _w_ ok
			_w_ = ""
		but cT[_k_] != char(13)
			_w_ += cT[_k_]
		ok
	next
	if _w_ != ""  _a_ + _w_ ok
	return _a_

# Well-formed? Every tag opened is closed in order, one root; [ ok, elements ]
func Mu7XmlBalanced cX
	_aSt_ = []
	_nEl_ = 0
	_nRoots_ = 0
	_k_ = 1
	_n_ = len(cX)
	while _k_ <= _n_
		if cX[_k_] != "<"
			_k_++
			loop
		ok
		_e_ = _k_
		while _e_ <= _n_ and cX[_e_] != ">"  _e_++ end
		_tag_ = substr(cX, _k_ + 1, _e_ - _k_ - 1)
		_k_ = _e_ + 1
		if len(_tag_) = 0  loop ok
		if _tag_[1] = "?"  loop ok
		_bClose_ = (_tag_[1] = "/")
		_bSelf_ = (_tag_[len(_tag_)] = "/")
		_name_ = ""
		_s0_ = 1
		if _bClose_  _s0_ = 2 ok
		for _j_ = _s0_ to len(_tag_)
			if _tag_[_j_] = " " or _tag_[_j_] = "/"  exit ok
			_name_ += _tag_[_j_]
		next
		if _bClose_
			if len(_aSt_) = 0  return [ FALSE, _nEl_ ] ok
			if _aSt_[len(_aSt_)] != _name_  return [ FALSE, _nEl_ ] ok
			del(_aSt_, len(_aSt_))
		else
			_nEl_++
			if len(_aSt_) = 0  _nRoots_++ ok
			if NOT _bSelf_  _aSt_ + _name_ ok
		ok
	end
	return [ len(_aSt_) = 0 and _nRoots_ = 1, _nEl_ ]

# A Standard MIDI File, read back -- written apart from the writer, and
# handling running status, which the writer never uses. [ bpm, [ [tick, hz] ] ]
func Mu7ReadMidi cPath
	_b_ = read(cPath)
	_bpm_ = 120
	_aNotes_ = []
	_pos_ = 15
	_nTr_ = Mu7Be(_b_, 11, 2)
	for _t_ = 1 to _nTr_
		_len_ = Mu7Be(_b_, _pos_ + 4, 4)
		_p_ = _pos_ + 8
		_end_ = _p_ + _len_
		_tick_ = 0
		_st_ = 0
		_aBend_ = list(16)
		for _c_ = 1 to 16  _aBend_[_c_] = 8192 next
		while _p_ < _end_
			_d_ = 0
			while TRUE
				_x_ = ascii(_b_[_p_])
				_p_++
				_d_ = _d_ * 128 + (_x_ % 128)
				if _x_ < 128  exit ok
			end
			_tick_ += _d_
			_x_ = ascii(_b_[_p_])
			if _x_ >= 128
				_st_ = _x_
				_p_++
			ok
			if _st_ = 255
				_ty_ = ascii(_b_[_p_])
				_ml_ = ascii(_b_[_p_ + 1])
				if _ty_ = 81  _bpm_ = 60000000 / Mu7Be(_b_, _p_ + 2, 3) ok
				_p_ += 2 + _ml_
				loop
			ok
			_hi_ = floor(_st_ / 16)
			_ch_ = _st_ % 16
			if _hi_ = 12 or _hi_ = 13
				_p_ += 1
				loop
			ok
			_a1_ = ascii(_b_[_p_])
			_a2_ = ascii(_b_[_p_ + 1])
			_p_ += 2
			if _hi_ = 14  _aBend_[_ch_ + 1] = _a1_ + 128 * _a2_ ok
			if _hi_ = 9 and _a2_ > 0 and _ch_ != 9
				_semis_ = (_aBend_[_ch_ + 1] - 8192) / 8192 * 12
				_aNotes_ + [ _tick_, 440 * pow(2, (_a1_ + _semis_ - 69) / 12) ]
			ok
		end
		_pos_ = _end_
	next
	return [ _bpm_, _aNotes_ ]

func Mu7Be cB, nAt, nN
	_v_ = 0
	for _k_ = 0 to nN - 1  _v_ = _v_ * 256 + ascii(cB[nAt + _k_]) next
	return _v_
