# MU8 -- notation read back. MU7 wrote a score as ABC, MusicXML and a MIDI
# file, and read none of them. Here MIDI and ABC come back into the SAME
# stzSoundScore every transform reads:
#
#     MIDI file --FromMidiFileQ--> score      ABC text --FromAbcQ--> score
#
# Each reader is held to three things, in this order:
#   1. its OWN writer's files come back as the score that wrote them;
#   2. a file this guard ASSEMBLED BY HAND from the format's own rules -- not
#      by the writer -- is read as those rules say (a reader that only agrees
#      with its own writer can share its writer's mistakes);
#   3. whatever a score cannot hold is COUNTED in Losses(), and a file it cannot
#      read honestly is REFUSED with a reason.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== MU8: MIDI and ABC read back into one stzSoundScore =="
? ""

? "-- Scene 1: MIDI -- this library's own files come back --"
oU = StzSoundUniverseQ(:maqam).NoCycle(4)
oRast = oU.SonifyQ([ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ])
oRd = StzSoundNotationReaderQ()
oBack = oRd.FromMidiBytesQ(StzSoundNotationQ(oRast).ToMidiBytes())
aCmp = Mu8Compare(oRast, oBack)
? "   Rast, ten notes: worst onset " + aCmp[2] + " beats, worst pitch " + aCmp[3] + " cents, worst velocity " + aCmp[4]
Chk("every note comes back, at the score's tempo (" + oBack.TempoInBpm() + " BPM)",
    aCmp[1] and oBack.TempoInBpm() = oRast.TempoInBpm())
Chk("each on its tick, and each pitch within 0.1 cent -- the half-flat third a bend, read as the bend says",
    aCmp[2] <= 1 / 480 and aCmp[3] < 0.1)
Chk("the velocity within one MIDI step (1/127)", aCmp[4] <= 1 / 127)
Chk("and the instrument is the OUD, though General MIDI files it under 24, the guitar's program",
    aCmp[5] and oBack.Events()[1][4] = "oud")

# the mixed score: an oud on a channel a guitar used, a chord, a glide, strokes
oMx = StzSoundScoreQ().Tempo(100)
oMx.On(:guitar)
for k = 0 to 14  oMx.NoteAt(k, 196 * pow(2, k / 12), 1) next
oMx.On(:oud).SetVelocity(0.3)
oMx.NoteAt(15, "D4", 1).NoteAt(16, "E4-50", 1).NoteAt(17, "F4", 1)
oMx.On(:harp).SetVelocity(0.9)
oMx.NoteAt(18, "C4", 1).NoteAt(18, "E4", 1).NoteAt(18, "G4", 1)
oMx.On(:kalangu).GlideAt(19, 220, 165, 1)
oMx.On(:darbouka).StrokeAt(20, :dum, 0.5).StrokeAt(20.5, :tak, 0.5)
oMx.On(:drumkit).StrokeAt(21, :hihat, 0.25)
cMx = StzSoundNotationQ(oMx).ToMidiBytes()
oMxB = oRd.FromMidiBytesQ(cMx)
aCmp = Mu8Compare(oMx, oMxB)
? "   a mixed score, " + oMx.NumberOfEvents() + " events: worst onset " + aCmp[2] + ", worst pitch " + aCmp[3] +
  " cents, instruments all equal: " + aCmp[5] + ", strokes all equal: " + aCmp[6]
Chk("fifteen guitar notes, then an oud on a channel a guitar used -- both GM 24 -- and each comes back itself",
    aCmp[1] and aCmp[5])
Chk("a chord comes back as three notes on one onset, a quarter-flat E within 0.1 cent",
    aCmp[2] <= 1 / 480 and aCmp[3] < 0.1)
nGl = 0
for e in oMxB.Events()
	if e[4] = "kalangu" and len(e) >= 7
		if e[7] > 0  nGl = fabs(Mu8Cents(e[7], 165)) ok
	ok
next
? "   the kalangu's glide ends " + nGl + " cents from 165 Hz"
Chk("a glide comes back a glide, ending within 0.1 cent of where it was written to end", nGl > 0 and nGl < 0.1)
Chk("strokes come back as strokes on their drums: dum, tak on the darbouka, the hihat on the kit", aCmp[6])
# THE WRITER WAS WRONG THREE WAYS, and each was found only by reading back:
#  - it changed PROGRAM only when the program changed, so an oud after a
#    guitar on one channel left no trace -> it now names the instrument;
#  - a glide's last bend sat ON the note-off tick, which sorts before it, so
#    the arrival belonged to no note -> the last bend is a tick inside;
#  - "hat" (the score's alias) was written as key 39, a hand clap.
oHat = StzSoundScoreQ().On(:drumkit).StrokeAt(0, :hat, 1)
Chk("the score's 'hat' is written as General MIDI's closed hihat (42), not a hand clap (39)",
    Mu8Contains(StzSoundNotationQ(oHat).ToMidiBytes(), char(153) + char(42)))

oSl = StzSoundUniverseQ(:gamelan).NoCycle(4).SonifyQ([ 1, 2, 3, 4, 5 ])
StzSoundNotationQ(oSl).ToMidiFile("mu8_slendro.mid")
oSlB = StzSoundScoreFromMidiQ("mu8_slendro.mid")
aCmp = Mu8Compare(oSl, oSlB)
Chk("slendro, which no Western notation can write, comes back from a MIDI FILE within " + aCmp[3] + " cents",
    aCmp[1] and aCmp[3] < 0.1)

? ""
? "-- Scene 2: MIDI -- a file assembled BY HAND, byte by byte, from the standard --"
cF = Mu8ForeignMidi()
? "   " + len(cF) + " bytes: format 0, 96 ticks a beat, running status, a note-on at velocity 0 as"
? "   its note-off, a system-exclusive reset, bends at the default range and at an RPN-set 12,"
? "   a snare, a triangle, a tempo change, and a note never released"
oF = oRd.FromMidiBytesQ(cF)
aF = oF.Events()
for e in aF  ? "     beat " + e[1] + ", " + e[2] + " beats, " + e[3] + " Hz, " + e[4] + " " + e[6] next
Chk("five events: the triangle is dropped, everything else is read", len(aF) = 5)
Chk("C4 for one beat at 120 BPM, its note-off a RUNNING-STATUS note-on at velocity 0, on the flute (program 73)",
    oF.TempoInBpm() = 120 and aF[1][1] = 0 and aF[1][2] = 1 and fabs(Mu8Cents(aF[1][3], 261.6256)) < 0.01 and
    aF[1][4] = "flute")
Chk("D4 bent by 2048 at the DEFAULT range of 2 semitones: a quarter tone up, 302.27 Hz",
    fabs(Mu8Cents(aF[2][3], 440 * pow(2, (62.5 - 69) / 12))) < 0.01 and aF[2][1] = 1 and aF[2][2] = 0.5)
Chk("C4 bent by 4096 after RPN 0 sets the range to 12: six semitones up, F#4",
    fabs(Mu8Cents(aF[3][3], 440 * pow(2, (66 - 69) / 12))) < 0.01 and aF[3][1] = 1.5 and aF[3][2] = 1)
Chk("key 38 on channel 10 is a snare stroke on the kit", aF[4][6] = "snare" and aF[4][4] = "drumkit" and
    aF[4][1] = 2.5 and aF[4][2] = 0.5)
Chk("an A4 never released ends where the file ends (beat 4.25), on the piano (no program given)",
    fabs(aF[5][3] - 440) < 0.01 and aF[5][1] = 3.25 and aF[5][2] = 1 and aF[5][4] = "piano")
aL = oRd.Losses()
? "   losses:"
for c in aL  ? "     - " + c next
Chk("and every drop is COUNTED: the sysex, the triangle, the tempo change (120 kept), the unreleased note",
    Mu8Has(aL, "system-exclusive") and Mu8Has(aL, "drum key 81") and Mu8Has(aL, "keeps the first (120") and
    Mu8Has(aL, "never released") and len(aL) = 4)

? ""
? "-- Scene 3: ABC -- this library's own tunes come back --"
oA = oRd.FromAbcQ(StzSoundNotationQ(oRast).ToABC("Rast"))
aCmp = Mu8Compare(oRast, oA)
? "   Rast from ABC: worst onset " + aCmp[2] + " beats, worst pitch " + aCmp[3] + " cents"
Chk("every note, every length, and the tempo", aCmp[1] and aCmp[2] = 0 and oA.TempoInBpm() = 96)
Chk("and every pitch EXACT -- Rast's half-flat third is ABC 2.1's _/E, a quarter tone, read as one",
    aCmp[3] < 0.001 and aCmp[5])
oT = StzSoundScoreQ().Tempo(90)
oT.On(:oud).NoteAt(0, "C4", 1).NoteAt(2, "D4", 10).NoteAt(12, "E4-50", 0.5)
oT.On(:flute).NoteAt(0, "G4", 2).NoteAt(0, "B4", 2).NoteAt(0, "D5", 2).NoteAt(4, "A4", 1.5)
cT = StzSoundNotationQ(oT).ToABC("two voices")
? "   two voices, as the writer wrote them:"
for c in Mu8Lines(cT)  ? "     " + c next
oTB = oRd.FromAbcQ(cT)
aCmp = Mu8Compare(oT, oTB)
Chk("two voices, each on its instrument; a note ten beats long, written as three tied pieces over two barlines, " +
    "comes back ONE note", aCmp[1] and aCmp[2] = 0 and aCmp[3] < 0.001 and aCmp[5])

? ""
? "-- Scene 4: ABC -- tunes written for this guard, read by the standard's rules --"
cT1 = "X:1" + nl + "T:Guard tune one" + nl + "M:6/8" + nl + "L:1/8" + nl + "Q:3/8=100" + nl + "K:D" + nl +
      "|: dfa agf | e2c B2A |1 d3 D3 :|2 d3- d2 z |]" + nl
? "   |: dfa agf | e2c B2A |1 d3 D3 :|2 d3- d2 z |]     (6/8, K:D, Q:3/8=100)"
o1 = oRd.FromAbcQ(cT1)
a1 = o1.Events()
aWant = [ [0,0.5,74], [0.5,0.5,78], [1,0.5,81], [1.5,0.5,81], [2,0.5,79], [2.5,0.5,78], [3,1,76], [4,0.5,73], [4.5,1,71],
          [5.5,0.5,69], [6,1.5,74], [7.5,1.5,62],
          [9,0.5,74], [9.5,0.5,78], [10,0.5,81], [10.5,0.5,81], [11,0.5,79], [11.5,0.5,78], [12,1,76], [13,0.5,73],
          [13.5,1,71], [14.5,0.5,69], [15,2.5,74] ]
Chk("23 notes: the repeat PLAYED -- the first ending once, the second once", len(a1) = 23)
Chk("K:D sharpens every f and c (F#5, C#5), and a 6/8 bar is three quarter-note beats", Mu8Want(a1, aWant))
Chk("Q:3/8=100 is 150 quarter notes a minute", o1.TempoInBpm() = 150)
Chk("and 'd3- d2' is one note of two and a half beats", a1[23][2] = 2.5)

cT2 = "X:2" + nl + "T:Guard tune two" + nl + "M:4/4" + nl + "L:1/8" + nl + "Q:1/4=120" + nl + "K:G" + nl +
      "V:1 name=" + char(34) + "flute" + char(34) + nl + "V:2 name=" + char(34) + "Cello" + char(34) + nl +
      "[V:1] " + char(34) + "G" + char(34) + "!p! ^c c =c c (3def g>a | b<c' [GBd]2 {g}e2 _/B B,, | Z | ~c'2 z6 |]" + nl +
      "w: la la" + nl +
      "[V:2] G,8 | x8 | z4 C,4- | C,8 |]" + nl
? "   [V:1] " + char(34) + "G" + char(34) + "!p! ^c c =c c (3def g>a | b<c' [GBd]2 {g}e2 _/B B,, | Z | ~c'2 z6 |]"
? "   [V:2] G,8 | x8 | z4 C,4- | C,8 |]                              (4/4, K:G)"
o2 = oRd.FromAbcQ(cT2)
a2 = o2.Events()
aV1 = []
aV2 = []
for e in a2
	if e[4] = "flute"  aV1 + e else aV2 + e ok
next
aWant1 = [ [0,0.5,73], [0.5,0.5,73], [1,0.5,72], [1.5,0.5,72], [2,1/3,74], [7/3,1/3,76], [8/3,1/3,78], [3,0.75,79], [3.75,0.25,81],
           [4,0.25,83], [4.25,0.75,84], [5,1,67], [5,1,71], [5,1,74], [6,1,76], [7,0.5,70.5], [7.5,0.5,47], [12,1,84] ]
Chk("an accidental holds to the barline, for its octave only: ^c c =c c is C#5 C#5 C5 C5, and c' is C6", Mu8Want(aV1, aWant1))
Chk("(3def is a triplet of thirds of a beat, and K:G sharpens its f", fabs(aV1[6][1] - 7/3) < 0.000000001 and aV1[7][3] > 369)
Chk("g>a and b<c' share their beats unevenly: 3/4 + 1/4, then 1/4 + 3/4", aV1[8][2] = 0.75 and aV1[11][2] = 0.75)
Chk("_/B is a quarter tone under B4 -- and it does NOT touch B,, two octaves down", Mu8Cents(aV1[16][3], 493.8833) < -49.99 and
    fabs(Mu8Cents(aV1[17][3], 123.4708)) < 0.01)
Chk("Z rests a whole bar: c' lands on beat 12", aV1[18][1] = 12)
Chk("voice 2 is its own time: G3 at 0, and C3 tied across the barline, 10 to 16", len(aV2) = 2 and aV2[1][1] = 0 and
    aV2[1][2] = 4 and aV2[2][1] = 10 and aV2[2][2] = 6)
aL = oRd.Losses()
? "   losses:"
for c in aL  ? "     - " + c next
Chk("what a score cannot hold is COUNTED: the chord symbol, the decorations, the grace note, the lyrics, and a 'Cello'" +
    " that names no instrument here (read on the piano)",
    Mu8Has(aL, "chord symbols") and Mu8Has(aL, "decorations") and Mu8Has(aL, "grace notes") and Mu8Has(aL, "lyrics") and
    Mu8Has(aL, "'Cello'") and len(aL) = 5 and aV2[1][4] = "piano")

aKeys = [ [ "Bb", [0,0,-1,0,0,0,-1] ], [ "F#m", [1,0,0,1,1,0,0] ], [ "Ddor", [0,0,0,0,0,0,0] ], [ "A min", [0,0,0,0,0,0,0] ],
          [ "Bbmix", [0,0,-1,0,0,-1,-1] ], [ "D exp ^f", [0,0,0,1,0,0,0] ], [ "G ^c", [1,0,0,1,0,0,0] ],
          [ "C#", [1,1,1,1,1,1,1] ], [ "none", [0,0,0,0,0,0,0] ] ]
bKeys = TRUE
cBad = ""
for k in aKeys
	oK1 = oRd.FromAbcQ("X:1" + nl + "L:1/4" + nl + "K:" + k[1] + nl + "CDEFGAB|" + nl)
	aE1 = oK1.Events()
	aNat = [ 60, 62, 64, 65, 67, 69, 71 ]
	for j = 1 to 7
		if fabs(Mu8Midi(aE1[j][3]) - aNat[j] - k[2][j]) > 0.001
			bKeys = FALSE
			cBad = k[1]
		ok
	next
next
Chk("nine key signatures -- majors, a minor, three modes, 'exp' and added accidentals -- give the standard's notes " + cBad, bKeys)
oBar = oRd.FromAbcQ("X:1" + nl + "L:1/4" + nl + "K:C" + nl + "^C C | C _B | B|" + nl)
Chk("and the barline ENDS an accidental: ^C C | C is C#4 C#4 C4, and _B | B is Bb4 B4",
    Mu8Names(oBar) = "C#4 C#4 C4 A#4 B4")
oR1 = oRd.FromAbcQ("X:1" + nl + "L:1/4" + nl + "K:C" + nl + "|: A B :: c d :| e |]" + nl)
oR2 = oRd.FromAbcQ("X:1" + nl + "L:1/4" + nl + "K:C" + nl + "|: A [1 B :| [2 c |]" + nl)
Chk("'::' ends one repeat and begins the next (A B A B c d c d e), and [1 [2 are endings (A B A c)",
    Mu8Names(oR1) = "A4 B4 A4 B4 C5 D5 C5 D5 E5" and Mu8Names(oR2) = "A4 B4 A4 C5")

? ""
? "-- Scene 5: the readers COMPOSE with the writers --"
oS1 = oRd.FromAbcQ(cT)
oS2 = oRd.FromMidiBytesQ(StzSoundNotationQ(oS1).ToMidiBytes())
cT2b = StzSoundNotationQ(oS2).ToABC("two voices")
Chk("ABC -> score -> MIDI -> score -> ABC gives back the SAME TEXT, character for character", cT2b = cT)
# MIDI stores a tempo as microseconds a beat: 90 BPM is 666667, which reads
# 89.99995. The reader rounds to a thousandth; the first cut did not, and the
# ABC writer's floor() then printed Q:1/4=89
Chk("and 90 BPM comes back from MIDI as 90, not the 89.99995 its microseconds spell (" + oS2.TempoInBpm() + ")",
    oS2.TempoInBpm() = 90)
cFa = StzSoundNotationQ(oF).ToABC("by hand")
Chk("and the hand-made MIDI file becomes ABC: its quarter-tone D written ^/D, ABC 2.1's own mark",
    substr(cFa, "^/D") > 0)

? ""
? "-- Scene 6: what is REFUSED, and why --"
Chk("a file that is not MIDI: " + Mu8Refused(oRd.FromMidiBytesQ("RIFF....WAVEfmt "), oRd),
    substr(oRd.LastError(), "MThd") > 0)
Chk("format 2 (independent sequences, not one piece): " + Mu8Refused(oRd.FromMidiBytesQ(Mu8Header(2, 1, 96)), oRd),
    substr(oRd.LastError(), "format 2") > 0)
Chk("SMPTE time, not beats: " + Mu8Refused(oRd.FromMidiBytesQ(Mu8Header(0, 1, 57896)), oRd),
    substr(oRd.LastError(), "SMPTE") > 0)
Chk("a track cut inside a message: " + Mu8Refused(oRd.FromMidiBytesQ(Mu8Header(0, 1, 96) + "MTrk" + Mu8Be(3, 4) +
    char(0) + char(144) + char(60)), oRd), substr(oRd.LastError(), "ends inside") > 0)
Chk("an ABC tune with no K: line: " + Mu8Refused(oRd.FromAbcQ("X:1" + nl + "T:no key" + nl + "CDE|" + nl), oRd),
    substr(oRd.LastError(), "K:") > 0)
Chk("an empty text: " + Mu8Refused(oRd.FromAbcQ(""), oRd), substr(oRd.LastError(), "empty") > 0)

? ""
? "-- What the readers do NOT do --"
? "   MusicXML is not read (it was not asked for). MIDI: one tempo per score, no pedal, no"
? "   controllers beyond the bend's range; a moving bend is a glide, so vibrato is flattened."
? "   ABC: no ornaments, dynamics, lyrics, grace notes or chord symbols (each COUNTED when"
? "   met); no nested repeats and no P: parts order; one tune per text."

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

func Mu8Cents nA, nB
	if nA <= 0 or nB <= 0  return 9999 ok
	return 1200 * log(nA / nB) / log(2)

func Mu8Midi nHz
	return 69 + 12 * log(nHz / 440) / log(2)

# the events, in one order whatever order they were added in
func Mu8Sorted oS
	_a_ = []
	for _e_ in oS.Events()
		_k_ = floor(_e_[1] * 480 + 0.5) * 100000 + floor(_e_[3] * 10 + 0.5)
		if _e_[6] != ""  _k_ += ring_find([ "dum", "tak", "ka", "kick", "snare", "hihat" ], _e_[6]) ok
		_a_ + [ _k_, _e_ ]
	next
	_a_ = sort(_a_, 1)
	_r_ = []
	for _x_ in _a_  _r_ + _x_[2] next
	return _r_

# [ same count, worst onset/length (beats), worst pitch (cents), worst velocity,
#   instruments equal, strokes equal ]
func Mu8Compare oA, oB
	if NOT isObject(oB)  return [ FALSE, 99, 99, 99, FALSE, FALSE ] ok
	_a_ = Mu8Sorted(oA)
	_b_ = Mu8Sorted(oB)
	if len(_a_) != len(_b_)  return [ FALSE, 99, 99, 99, FALSE, FALSE ] ok
	_wt_ = 0  _wp_ = 0  _wv_ = 0  _bi_ = TRUE  _bs_ = TRUE
	for _k_ = 1 to len(_a_)
		_x_ = _a_[_k_]
		_y_ = _b_[_k_]
		_d_ = fabs(_x_[1] - _y_[1])
		if fabs(_x_[2] - _y_[2]) > _d_  _d_ = fabs(_x_[2] - _y_[2]) ok
		if _d_ > _wt_  _wt_ = _d_ ok
		if _x_[3] > 0
			_c_ = fabs(Mu8Cents(_x_[3], _y_[3]))
			if _c_ > _wp_  _wp_ = _c_ ok
		ok
		if fabs(_x_[5] - _y_[5]) > _wv_  _wv_ = fabs(_x_[5] - _y_[5]) ok
		_ia_ = _x_[4]
		if _ia_ = ""  _ia_ = "piano" ok
		if _ia_ != _y_[4]  _bi_ = FALSE ok
		_sa_ = _x_[6]
		if _sa_ = "hat"  _sa_ = "hihat" ok
		if _sa_ != _y_[6]  _bs_ = FALSE ok
	next
	return [ TRUE, _wt_, _wp_, _wv_, _bi_, _bs_ ]

# events against [ beat, beats, midi ] rows, in order
func Mu8Want aE, aW
	if len(aE) != len(aW)  return FALSE ok
	for _k_ = 1 to len(aW)
		if fabs(aE[_k_][1] - aW[_k_][1]) > 0.000000001  return FALSE ok
		if fabs(aE[_k_][2] - aW[_k_][2]) > 0.000000001  return FALSE ok
		if fabs(Mu8Midi(aE[_k_][3]) - aW[_k_][3]) > 0.0001  return FALSE ok
	next
	return TRUE

func Mu8Names oS
	_aN_ = [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]
	_s_ = ""
	for _e_ in oS.Events()
		_m_ = floor(Mu8Midi(_e_[3]) + 0.5)
		if _s_ != ""  _s_ += " " ok
		_s_ += _aN_[(_m_ % 12) + 1] + (floor(_m_ / 12) - 1)
	next
	return _s_

func Mu8Has aL, cPart
	for _c_ in aL
		if substr(_c_, cPart) > 0  return TRUE ok
	next
	return FALSE

# bytes inside bytes -- by position and length, because a MIDI file is full of
# zero bytes and a search that stops at the first one would find nothing
func Mu8Contains cB, cPat
	_n_ = len(cPat)
	for _k_ = 1 to len(cB) - _n_ + 1
		if substr(cB, _k_, _n_) = cPat  return TRUE ok
	next
	return FALSE

func Mu8Refused oX, oRdr
	if isObject(oX)  return "NOT refused" ok
	return "refused -- " + oRdr.LastError()

func Mu8Lines cT
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

# ---- a MIDI file BY HAND: the bytes the standard prescribes, not the writer's

func Mu8Be nV, nBytes
	_s_ = ""
	for _k_ = nBytes - 1 to 0 step -1  _s_ += char(floor(nV / pow(256, _k_)) % 256) next
	return _s_

func Mu8B aBytes
	_s_ = ""
	for _x_ in aBytes  _s_ += char(_x_) next
	return _s_

func Mu8Header nFormat, nTracks, nDivision
	return "MThd" + Mu8Be(6, 4) + Mu8Be(nFormat, 2) + Mu8Be(nTracks, 2) + Mu8Be(nDivision, 2)

func Mu8ForeignMidi
	_t_ = Mu8B([ 0, 255, 81, 3, 7, 161, 32 ])                  # tempo 500000 us: 120 BPM
	_t_ += Mu8B([ 0, 240, 5, 126, 127, 9, 1, 247 ])            # sysex: GM system on
	_t_ += Mu8B([ 0, 192, 73 ])                                # ch 1: program 73, a flute
	_t_ += Mu8B([ 0, 144, 60, 100 ])                           # C4 on
	_t_ += Mu8B([ 96, 60, 0 ])                                 # RUNNING STATUS: C4 at velocity 0 = off
	_t_ += Mu8B([ 0, 224, 0, 80 ])                             # bend 80*128 = 10240: +2048, at range 2
	_t_ += Mu8B([ 0, 144, 62, 80 ])                            # D4 on -> a quarter tone up
	_t_ += Mu8B([ 48, 128, 62, 64 ])                           # D4 off
	_t_ += Mu8B([ 0, 177, 101, 0 ])                            # ch 2: RPN 0 selected ...
	_t_ += Mu8B([ 0, 100, 0 ])                                 # ... (running status)
	_t_ += Mu8B([ 0, 6, 12 ])                                  # data entry: 12 semitones
	_t_ += Mu8B([ 0, 225, 0, 96 ])                             # bend 96*128 = 12288: +4096 = +6 semitones
	_t_ += Mu8B([ 0, 145, 60, 100 ])                           # C4 on ch 2 -> F#4
	_t_ += Mu8B([ 96, 129, 60, 0 ])                            # off
	_t_ += Mu8B([ 0, 153, 38, 112 ])                           # ch 10, key 38: a snare
	_t_ += Mu8B([ 48, 137, 38, 0 ])
	_t_ += Mu8B([ 0, 153, 81, 96 ])                            # key 81: a triangle, no stroke here
	_t_ += Mu8B([ 24, 137, 81, 0 ])
	_t_ += Mu8B([ 0, 255, 81, 3, 15, 66, 64 ])                 # tempo 1000000 us: 60 BPM, mid-piece
	_t_ += Mu8B([ 0, 146, 69, 64 ])                            # A4 on ch 3 -- never released
	_t_ += Mu8B([ 96, 255, 47, 0 ])                            # end of track
	return Mu8Header(0, 1, 96) + "MTrk" + Mu8Be(len(_t_), 4) + _t_
