# MU1 -- TWENTY INSTRUMENTS, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu1_demo.ring
#
# The guard proved every instrument is in tune, and that the engines are
# physically distinct. It cannot prove the oud sounds like an oud. That is the
# one verdict MU1 needs from a person, instrument by instrument -- and MU1's kill
# criterion says what happens on a "no": the instrument ships under its honest
# name (:Oud becomes :DarkPluck), a fallback written into the engine BEFORE
# anyone listened.
#
# Every phrase is written to its own WAV beside this file (mu1_NN_name.wav), and
# then the whole tour plays as ONE buffer on ONE device, the console driven by
# the transport's clock -- the arrangement the author's ears settled in VC4.

load "../../stzBase.ring"

pr()
decimals(1)
nRate = 48000

? "=================================================================="
? " MU1 -- twenty instruments, then Tunisia, then Niger"
? "=================================================================="
? ""

aTour = []    # [ name, what to listen for, stzSound ]

# ---- the general twelve ----------------------------------------------------

Mu1Add(:Piano, "a hammer and a ringing string -- a piano, or only a hammered string?", [
	[ 0.00, "C4", 0.9 ], [ 0.35, "E4", 0.9 ], [ 0.70, "G4", 0.9 ], [ 1.05, "C5", 1.2 ],
	[ 1.90, "C4", 1.2 ], [ 1.90, "E4", 1.2 ], [ 1.90, "G4", 1.2 ] ], 0.35)

Mu1Add(:Guitar, "two strummed chords, E then A", [
	[ 0.00, "E2", 1.5 ], [ 0.03, "B2", 1.5 ], [ 0.06, "E3", 1.5 ], [ 0.09, "G#3", 1.5 ],
	[ 0.12, "B3", 1.5 ], [ 0.15, "E4", 1.5 ],
	[ 1.80, "A2", 1.5 ], [ 1.83, "E3", 1.5 ], [ 1.86, "A3", 1.5 ], [ 1.89, "C#4", 1.5 ],
	[ 1.92, "E4", 1.5 ] ], 0.25)

Mu1Add(:Harp, "a glissando up two octaves", Mu1Run([ "C4", "D4", "E4", "F4", "G4", "A4",
	"B4", "C5", "D5", "E5", "F5", "G5" ], 0.09, 1.4), 0.3)

Mu1Add(:Bell, "three strikes, and the long ring after each", [
	[ 0.0, "C5", 0.4 ], [ 1.0, "G4", 0.4 ], [ 2.0, "E5", 0.4 ] ], 0.5)

Mu1Add(:EPiano, "a major-seventh chord, then three notes", [
	[ 0.00, "C4", 1.2 ], [ 0.00, "E4", 1.2 ], [ 0.00, "G4", 1.2 ], [ 0.00, "B4", 1.2 ],
	[ 1.40, "E5", 0.3 ], [ 1.75, "D5", 0.3 ], [ 2.10, "C5", 0.6 ] ], 0.3)

Mu1Add(:Brass, "a fanfare", [
	[ 0.0, "G3", 0.25 ], [ 0.3, "C4", 0.25 ], [ 0.6, "E4", 0.25 ], [ 0.9, "G4", 1.0 ] ], 0.8)

Mu1Add(:Flute, "breath, and a small vibrato", Mu1Run([ "D5", "E5", "F#5", "A5", "B5",
	"A5", "F#5" ], 0.32, 0.34), 0.8)

Mu1Add(:Oud, "a Hijaz line -- an oud, or only a dark pluck?", Mu1Run([ "D4", "Eb4", "F#4",
	"G4", "A4", "G4", "F#4", "Eb4", "D4" ], 0.28, 0.5), 0.8)

Mu1Add(:Koto, "a pentatonic line, bright and struck", Mu1Run([ "D4", "E4", "F4", "A4",
	"Bb4", "A4", "F4", "E4", "D4" ], 0.3, 0.8), 0.8)

Mu1Add(:Kora, "an ostinato that rings over itself", Mu1Run([ "F3", "A3", "C4", "F4",
	"A4", "C4", "A3", "C4", "F3", "A3", "C4", "F4", "A4", "C4", "A3", "C4" ], 0.2, 0.6), 0.5)

Mu1Add(:Metallophone, "struck bars, not strings", Mu1Run([ "C5", "D5", "E5", "G5",
	"A5", "G5", "E5", "D5" ], 0.35, 0.3), 0.6)

aKit = []
nE8 = 60 / 110 / 2
for b = 0 to 1
	for e = 0 to 7
		t = (b * 8 + e) * nE8
		aKit + [ t, :stroke, :hihat, 200, 0.1 ]
		if e = 0 or e = 4 or e = 5  aKit + [ t, :stroke, :kick, 55, 0.4 ] ok
		if e = 2 or e = 6  aKit + [ t, :stroke, :snare, 190, 0.25 ] ok
	next
next
Mu1Add(:DrumKit, "two bars of a rock beat", aKit, 0.5)

# ---- Tunisia ---------------------------------------------------------------

Mu1Add(:Mezwed, "two chanters, BEATING -- and E is a quarter tone flat", Mu1Run([ "D4",
	"E4-50", "F4", "G4", "A4", "G4", "F4", "E4-50", "D4" ], 0.3, 0.33), 0.8)

Mu1Add(:Zokra, "a double reed, loud and bright -- the cone's even harmonics", Mu1Run([ "G4",
	"A4", "Bb4", "C5", "D5", "C5", "Bb4", "A4", "G4" ], 0.25, 0.27), 0.8)

Mu1Add(:Darbouka, "maqsum: dum at the centre, tak at the rim, ka the weaker rim",
	Mu1Maqsum(0, 2, 150), 0.8)

aBd = []
for b = 0 to 1
	aBd + [ b * 1.2 + 0.0, :stroke, :dum, 110, 0.6 ]
	aBd + [ b * 1.2 + 0.4, :stroke, :tak, 110, 0.4 ]
	aBd + [ b * 1.2 + 0.8, :stroke, :dum, 110, 0.4 ]
next
Mu1Add(:Bendir, "listen UNDER the stroke: the snares buzz", aBd, 0.8)

# ---- Niger -----------------------------------------------------------------

Mu1Add(:Kakaki, "a two-metre trumpet: few notes, long and low", [
	[ 0.0, 110, 1.1 ], [ 1.3, 146.83, 0.6 ], [ 2.1, 110, 1.2 ] ], 0.8)

Mu1Add(:Sarewa, "a Fulani flute -- the breath is part of the note", Mu1Run([ "A4", "C5",
	"D5", "E5", "G5", "E5", "D5", "C5", "A4" ], 0.3, 0.34), 0.8)

Mu1Add(:Imzad, "one string, bowed -- and it SLIDES", [
	[ 0.0, "E4", 0.8 ], [ 0.9, :glide, "E4", "G4", 0.45 ], [ 1.45, "A4", 0.6 ],
	[ 2.15, :glide, "A4", "E4", 0.7 ] ], 0.8)

Mu1Add(:Kalangu, "a drum squeezed so its pitch follows speech", [
	[ 0.00, :glide, 150, 220, 0.35 ], [ 0.40, :glide, 220, 150, 0.35 ],
	[ 0.85, 170, 0.3 ], [ 1.25, :glide, 150, 205, 0.45 ], [ 1.80, :stroke, :tak, 160, 0.2 ],
	[ 2.05, :glide, 205, 140, 0.5 ] ], 0.8)

# ---- the two ensembles -----------------------------------------------------

oTun = StzSoundOfSilenceQ(6.2, 1, nRate)
oTun.MixIn(Mu1Phrase(:Darbouka, Mu1Maqsum(0, 4, 150), 0.6), 0, 1)
oTun.MixIn(Mu1Phrase(:Mezwed, Mu1Run([ "D4", "E4-50", "F4", "G4", "A4", "Bb4", "A4", "G4",
	"F4", "E4-50", "D4", "E4-50", "F4", "E4-50", "D4" ], 0.3, 0.32), 0.6), 0.6, 1)
aTour + [ "Tunisia", "darbouka maqsum under the mezwed's line", oTun ]

oNig = StzSoundOfSilenceQ(6.0, 1, nRate)
oNig.MixIn(Mu1Phrase(:Kalangu, [ [ 0.0, :glide, 150, 210, 0.35 ], [ 0.45, :glide, 210, 150, 0.35 ],
	[ 1.0, :glide, 160, 200, 0.4 ], [ 1.6, :stroke, :tak, 160, 0.2 ], [ 1.9, :glide, 200, 140, 0.5 ],
	[ 2.6, :glide, 150, 210, 0.35 ], [ 3.1, :glide, 210, 150, 0.35 ], [ 3.7, 170, 0.3 ] ], 0.6), 0, 1)
oNig.MixIn(Mu1Phrase(:Imzad, [ [ 0.0, "E4", 1.2 ], [ 1.3, :glide, "E4", "G4", 0.5 ],
	[ 1.9, "A4", 0.9 ], [ 2.9, :glide, "A4", "E4", 0.9 ] ], 0.45), 0.3, 1)
oNig.MixIn(Mu1Phrase(:Sarewa, Mu1Run([ "A4", "C5", "D5", "E5", "D5", "C5", "A4" ], 0.4, 0.45), 0.4), 2.2, 1)
aTour + [ "Niger", "the kalangu talking, the imzad sliding, the sarewa breathing", oNig ]

# ---- write every phrase, then play the tour --------------------------------

? "writing each phrase to its own WAV:"
for i = 1 to len(aTour)
	cN = "" + i
	if len(cN) < 2  cN = "0" + cN ok
	cFile = "mu1_" + cN + "_" + lower(aTour[i][1]) + ".wav"
	aTour[i][3].SaveAs(cFile)
	? "   " + cFile + "   " + aTour[i][3].Duration() + " s"
next
? ""

nGap = 0.9
nTot = 0.5
aAt = []
for i = 1 to len(aTour)
	aAt + nTot
	nTot += aTour[i][3].Duration() + nGap
next
oAll = StzSoundOfSilenceQ(nTot, 1, nRate)
for i = 1 to len(aTour)
	oAll.MixIn(aTour[i][3], aAt[i], 1)
next
oAll.SaveAs("mu1_00_tour.wav")
? "the whole tour: mu1_00_tour.wav, " + oAll.Duration() + " s, peak " + oAll.Peak()
? ""

if NOT (StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1)
	? "No output device -- the WAVs are written; play them in any player."
	bye
ok

? "=== NOW LISTEN ==="
? "   for each: does it sound like its name? A 'no' is a real answer, and"
? "   the instrument then ships under the honest name shown."
? ""
oG = new stzSoundGraph()
oG.Reshape(1, nRate)
oG.AddSound(oAll)
oT = new stzSoundTransport(oG)
oT.PlayFor(oAll.Duration())
n = 1
while NOT oT.IsStopped()
	oT.Tick()
	if n <= len(aTour) and oT.PositionInSeconds() >= aAt[n] - 0.05
		cHon = ""
		if n <= 20  cHon = "   (honest name: " + StzInstrumentQ(aTour[n][1]).HonestName() + ")" ok
		? "   " + Mu1Pad(lower(aTour[n][1]), 13) + aTour[n][2] + cHon
		n++
	ok
	sleep(0.02)
end
? ""
? "   underruns: " + oT.Underruns()
oT.Release()

? ""
? "=================================================================="
? " Twenty instruments, two ensembles. The verdict the plan needs is one"
? " word per instrument: its name, or its honest name."
? "=================================================================="

# ---- helpers (Mu1-prefixed, so they cannot collide with the library) -------

# Render a phrase and add it to the tour.
func Mu1Add pName, cListen, aEvents, nGain
	aTour + [ "" + pName, cListen, Mu1Phrase(pName, aEvents, nGain) ]

# One instrument, a list of events, into one buffer.
#   [ t, "C4", dur ]                    a note by name
#   [ t, 146.83, dur ]                  a note by Hz
#   [ t, :glide, from, to, dur ]        a pitch that moves (names or Hz)
#   [ t, :stroke, :tak, hz, dur ]       where a drum is struck
func Mu1Phrase pName, aEvents, nGain
	_oI_ = StzInstrumentQ(pName)
	_end_ = 0
	for _e_ in aEvents
		_d_ = _e_[len(_e_)]
		if _e_[1] + _d_ > _end_  _end_ = _e_[1] + _d_ ok
	next
	_tail_ = 1.0
	if lower("" + pName) = "bell"  _tail_ = 2.6 ok
	if lower("" + pName) = "metallophone"  _tail_ = 1.6 ok
	_out_ = StzSoundOfSilenceQ(_end_ + _tail_, 1, nRate)
	for _e_ in aEvents
		_s_ = ""
		if isString(_e_[2]) and lower(_e_[2]) = "glide"
			_s_ = _oI_.ToSoundOfGlide(Mu1Hz(_e_[3]), Mu1Hz(_e_[4]), _e_[5])
		but isString(_e_[2]) and lower(_e_[2]) = "stroke"
			_s_ = _oI_.ToSoundOfStroke(_e_[3], _e_[4], _e_[5])
		else
			_s_ = _oI_.ToSoundOf(Mu1Hz(_e_[2]), _e_[3])
		ok
		if isObject(_s_)
			_out_.MixIn(_s_, _e_[1], nGain)
			_s_.Release()
		else
			? "   (" + pName + ": " + _oI_.LastError() + ")"
		ok
	next
	return _out_

func Mu1Hz pV
	if isNumber(pV)  return pV ok
	return StzNoteToHz(pV)

# Notes in a row, evenly spaced.
func Mu1Run aNotes, nStep, nDur
	_a_ = []
	for _i_ = 1 to len(aNotes)
		_a_ + [ (_i_ - 1) * nStep, aNotes[_i_], nDur ]
	next
	return _a_

# Maqsum, the commonest rhythm of the Arab world and of Tunisia's popular
# repertoire: dum tak . tak dum . tak . -- in eighths, with ka between.
func Mu1Maqsum nFrom, nBars, nHz
	_a_ = []
	_e_ = 0.15
	for _b_ = 0 to nBars - 1
		_t0_ = nFrom + _b_ * 8 * _e_
		_a_ + [ _t0_ + 0 * _e_, :stroke, :dum, nHz, 0.4 ]
		_a_ + [ _t0_ + 1 * _e_, :stroke, :tak, nHz, 0.2 ]
		_a_ + [ _t0_ + 2 * _e_, :stroke, :ka,  nHz, 0.15 ]
		_a_ + [ _t0_ + 3 * _e_, :stroke, :tak, nHz, 0.2 ]
		_a_ + [ _t0_ + 4 * _e_, :stroke, :dum, nHz, 0.4 ]
		_a_ + [ _t0_ + 5 * _e_, :stroke, :ka,  nHz, 0.15 ]
		_a_ + [ _t0_ + 6 * _e_, :stroke, :tak, nHz, 0.2 ]
		_a_ + [ _t0_ + 7 * _e_, :stroke, :ka,  nHz, 0.15 ]
	next
	return _a_

func Mu1Pad cS, nW
	_s_ = "" + cS
	while len(_s_) < nW  _s_ += " " end
	return _s_
