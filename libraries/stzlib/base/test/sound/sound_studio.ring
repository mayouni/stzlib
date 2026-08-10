# THE SOUND STUDIO -- an INTERACTIVE listening bench for the sound plane.
#
# This is NOT a guard. It is the thing you run when you want to HEAR what the
# guards assert. Every scene the test files measure numerically, this file
# plays out loud, one at a time, so "triangle" and "saw" stop being words.
#
# Run it:
#     cd libraries/stzlib/base/test/sound
#     ring sound_studio.ring              -- the menu
#     ring sound_studio.ring compose      -- go straight to the piece
#     ring sound_studio.ring save         -- render the piece to a WAV and exit
#
# It needs a working audio device for everything except `save`.

load "../../stzBase.ring"

RATE = 48000
cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

# note names, so the composition below reads like music instead of arithmetic
A2 = 110.00   E3 = 164.81   F3 = 174.61   G3 = 196.00   A3 = 220.00
B3 = 246.94   C4 = 261.63   D4 = 293.66   E4 = 329.63   F4 = 349.23
G4 = 392.00   A4 = 440.00   B4 = 493.88   C5 = 523.25   D5 = 587.33
E5 = 659.25   A5 = 880.00
C3 = 130.81   F2 = 87.31    G2 = 98.00

? ""
? "  ======================================================="
? "   THE SOFTANZA SOUND STUDIO -- press a key, hear a thing"
? "  ======================================================="

if NOT StzSoundEngineLoaded()
	? "  stz_sound.dll did not load. Build the engine first:"
	? "      cd libraries/stzlib/engine && zig build"
	bye
ok

bHaveDevice = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
if bHaveDevice
	? "   device: " + StzEngineAudioDevName(0, StzEngineAudioDevDefaultIndex(0))
	? "   backend: " + StzEngineAudioDevBackendName()
else
	? "   NO AUDIO DEVICE -- only 'save' will work here."
ok

cArg = ""
if len(sysargv) >= 3
	cArg = lower(sysargv[3])
ok

if cArg = "compose"
	PlayComposition()
	bye
but cArg = "save"
	SaveComposition()
	bye
ok

# ---------------------------------------------------------------- the menu

bRunning = TRUE
while bRunning
	? ""
	? "  --- THE FOUR WAVES (same pitch, same loudness, different colour) ---"
	? "   1  sine       -- pure, hollow, a tuning fork"
	? "   2  triangle   -- soft and flute-like, a sine with a little edge"
	? "   3  square     -- hollow and reedy, like a clarinet"
	? "   4  saw        -- bright and buzzy, the richest of the four"
	? ""
	? "  --- WHAT THE PARTS DO ---"
	? "   5  filter     -- the SAME saw, closing down from bright to dark"
	? "   6  envelope   -- the same note as a PLUCK, then as a PAD"
	? "   7  delay      -- one note, then the same note with an echo"
	? "   8  pan        -- a tone walking from your left ear to your right"
	? "   9  chord      -- one note, then three together (A minor)"
	? "   0  bell       -- envelope + echo, the two combined"
	? ""
	? "  --- THE PIECE ---"
	? "   c  compose    -- 20 seconds of actual music, built from the above"
	? "   s  save       -- render the piece to a .wav file"
	? "   q  quit"
	? ""
	give cKey
	cKey = lower(trim(cKey))

	switch cKey
	on "1"  Say("SINE at 440 Hz -- pure. One frequency and nothing else.")
	        PlayWave(StzSoundWaveSine(), A4, 2)
	on "2"  Say("TRIANGLE -- soft, a little reedy. Odd harmonics, dropping away fast.")
	        PlayWave(StzSoundWaveTriangle(), A4, 2)
	on "3"  Say("SQUARE -- hollow and woody. Odd harmonics, dropping away slowly.")
	        PlayWave(StzSoundWaveSquare(), A4, 2)
	on "4"  Say("SAW -- bright and buzzy. EVERY harmonic is present.")
	        PlayWave(StzSoundWaveSaw(), A4, 2)
	on "5"  DemoFilter()
	on "6"  DemoEnvelope()
	on "7"  DemoDelay()
	on "8"  DemoPan()
	on "9"  DemoChord()
	on "0"  DemoBell()
	on "c"  PlayComposition()
	on "s"  SaveComposition()
	on "q"  bRunning = FALSE
	other   ? "   ...not a key on this instrument."
	off
end

? ""
? "  Goodbye."

# =========================================================================
# helpers (Ring runs top-level code only BEFORE the first func, so the menu
# above must come first and everything it calls must live down here)
# =========================================================================

func Say cText
	? ""
	? "   >> " + cText

# Build a graph, play it through the speakers for nSeconds, then tear it all
# down. This is the whole SN3 path -- producer thread, ring buffer, device
# callback -- wrapped in one convenience for listening.
func PlayGraph nG, nSeconds
	if NOT bHaveDevice
		? "   (no device -- nothing to play)"
		StzEngineSoundGraphFree(nG)
		return
	ok
	_s_ = StzEngineSoundStreamStart(nG, 16384)
	if _s_ = 0
		? "   could not start the stream: " + StzEngineSoundGraphLastError()
		StzEngineSoundGraphFree(nG)
		return
	ok
	sleep(0.15)                      # let the producer get ahead of the device
	_d_ = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(_s_), 256)
	if _d_ = 0
		? "   could not open the device: " + StzEngineAudioDevLastError()
		StzEngineSoundStreamStop(_s_)
		StzEngineSoundGraphFree(_s_)
		return
	ok
	StzEngineAudioDevPlaybackStart(_d_)
	sleep(nSeconds)
	StzEngineAudioDevPlaybackStop(_d_)
	_u_ = StzEngineSoundStreamUnderruns(_s_)
	StzEngineAudioDevPlaybackClose(_d_)    # consumer first, ALWAYS
	StzEngineSoundStreamStop(_s_)          # then the producer frees the ring
	StzEngineSoundGraphFree(nG)
	if _u_ > 0
		? "   (" + _u_ + " frames underran)"
	ok

func PlayWave nWave, nHz, nSeconds
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o_ = StzEngineSoundGraphAddOsc(_g_, nWave, nHz, 0.35)
	_p_ = StzEngineSoundGraphAddPan(_g_, _o_, 0.5)
	StzEngineSoundGraphSetOutput(_g_, _p_)
	StzEngineSoundGraphPrepare(_g_)
	PlayGraph(_g_, nSeconds)

func DemoFilter
	Say("The SAME saw wave three times, with the filter closing down.")
	? "      bright (12000 Hz) ... then 1200 ... then 400. Same note, less light."
	_a_ = [12000, 1200, 400]
	for _i_ = 1 to 3
		? "      cutoff " + _a_[_i_] + " Hz"
		_g_ = StzEngineSoundGraphNew(2, RATE, 512)
		_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveSaw(), A3, 0.35)
		_f_ = StzEngineSoundGraphAddFilter(_g_, _o_, StzSoundFilterLowPass(), _a_[_i_], 0.9)
		_p_ = StzEngineSoundGraphAddPan(_g_, _f_, 0.5)
		StzEngineSoundGraphSetOutput(_g_, _p_)
		StzEngineSoundGraphPrepare(_g_)
		PlayGraph(_g_, 1.6)
	next

func DemoEnvelope
	Say("The same note twice. First a PLUCK, then a PAD.")
	? "      A pluck is a fast attack and a fast decay -- a harp."
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveTriangle(), A4, 0.6)
	_e_ = StzEngineSoundGraphAddEnvelope(_g_, _o_, 0.002, 0.35, 0.0, 0.1, 0.35)
	_p_ = StzEngineSoundGraphAddPan(_g_, _e_, 0.5)
	StzEngineSoundGraphSetOutput(_g_, _p_)
	StzEngineSoundGraphPrepare(_g_)
	PlayGraph(_g_, 2)

	? "      A pad is a slow attack and a long release -- strings swelling."
	_g2_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o2_ = StzEngineSoundGraphAddOsc(_g2_, StzSoundWaveTriangle(), A4, 0.6)
	_e2_ = StzEngineSoundGraphAddEnvelope(_g2_, _o2_, 0.8, 0.3, 0.7, 1.0, 1.6)
	_p2_ = StzEngineSoundGraphAddPan(_g2_, _e2_, 0.5)
	StzEngineSoundGraphSetOutput(_g2_, _p2_)
	StzEngineSoundGraphPrepare(_g2_)
	PlayGraph(_g2_, 3.5)

func DemoDelay
	Say("One plucked note DRY, then the same note with an echo behind it.")
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveTriangle(), C5, 0.6)
	_e_ = StzEngineSoundGraphAddEnvelope(_g_, _o_, 0.002, 0.25, 0.0, 0.05, 0.25)
	_p_ = StzEngineSoundGraphAddPan(_g_, _e_, 0.5)
	StzEngineSoundGraphSetOutput(_g_, _p_)
	StzEngineSoundGraphPrepare(_g_)
	PlayGraph(_g_, 1.5)

	? "      ...and now with a 300 ms echo, feeding back on itself."
	_g2_ = StzEngineSoundGraphNew(2, RATE, 512)
	_o2_ = StzEngineSoundGraphAddOsc(_g2_, StzSoundWaveTriangle(), C5, 0.6)
	_e2_ = StzEngineSoundGraphAddEnvelope(_g2_, _o2_, 0.002, 0.25, 0.0, 0.05, 0.25)
	_d2_ = StzEngineSoundGraphAddDelay(_g2_, _e2_, 0.30, 0.55, 0.45)
	_p2_ = StzEngineSoundGraphAddPan(_g2_, _d2_, 0.5)
	StzEngineSoundGraphSetOutput(_g2_, _p2_)
	StzEngineSoundGraphPrepare(_g2_)
	PlayGraph(_g2_, 4)

func DemoPan
	Say("A tone walking across in front of you: LEFT, centre, RIGHT.")
	_a_ = [0.0, 0.5, 1.0]
	_c_ = ["hard LEFT", "CENTRE", "hard RIGHT"]
	for _i_ = 1 to 3
		? "      " + _c_[_i_]
		_g_ = StzEngineSoundGraphNew(2, RATE, 512)
		_o_ = StzEngineSoundGraphAddOsc(_g_, StzSoundWaveTriangle(), E4, 0.4)
		_p_ = StzEngineSoundGraphAddPan(_g_, _o_, _a_[_i_])
		StzEngineSoundGraphSetOutput(_g_, _p_)
		StzEngineSoundGraphPrepare(_g_)
		PlayGraph(_g_, 1.2)
	next

func DemoChord
	Say("One note alone, then the same note inside an A minor chord.")
	PlayWave(StzSoundWaveTriangle(), A3, 1.5)
	? "      ...now with C and E added. Same root, whole different feeling."
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	_v_ = []
	_v_ + AddVoice(_g_, StzSoundWaveTriangle(), A3, 0.22, 0, 2.2, 0.15, 0.3, 0.7, 0.6, 0.3)
	_v_ + AddVoice(_g_, StzSoundWaveTriangle(), C4, 0.22, 0, 2.2, 0.15, 0.3, 0.7, 0.6, 0.5)
	_v_ + AddVoice(_g_, StzSoundWaveTriangle(), E4, 0.22, 0, 2.2, 0.15, 0.3, 0.7, 0.6, 0.7)
	_m_ = MixOf(_g_, _v_)
	StzEngineSoundGraphSetOutput(_g_, _m_)
	StzEngineSoundGraphPrepare(_g_)
	PlayGraph(_g_, 3.5)

func DemoBell
	Say("A bell: a fast attack, a long decay, and an echo in a big room.")
	_g_ = StzEngineSoundGraphNew(2, RATE, 512)
	# a bell is a fundamental plus a bright partial that dies away sooner
	_v_ = []
	_v_ + AddVoice(_g_, StzSoundWaveSine(), A5, 0.30, 0, 1.6, 0.001, 1.4, 0.0, 0.4, 0.45)
	_v_ + AddVoice(_g_, StzSoundWaveSine(), A5 * 2.76, 0.10, 0, 0.5, 0.001, 0.45, 0.0, 0.2, 0.55)
	_m_ = MixOf(_g_, _v_)
	_d_ = StzEngineSoundGraphAddDelay(_g_, _m_, 0.38, 0.5, 0.4)
	StzEngineSoundGraphSetOutput(_g_, _d_)
	StzEngineSoundGraphPrepare(_g_)
	PlayGraph(_g_, 5)

# ONE VOICE = oscillator -> envelope (starting at nStart) -> pan.
# With a start time, a "voice" IS a note, and a list of voices is a score.
#
# It returns the voice rather than joining a mix, and that is not a style
# choice: a mix may only take inputs that ALREADY EXIST, because creation
# order is what guarantees the graph is acyclic. Build the voices, THEN the
# mix. (The first version of this file created the mixes first, every MixAdd
# was refused with BAD_ARG, nobody checked the return, and the piece rendered
# 21.7 seconds of perfect silence.)
func AddVoice nG, nWave, nHz, nAmp, nStart, nGate, nA, nD, nSus, nR, nPan
	_o_ = StzEngineSoundGraphAddOsc(nG, nWave, nHz, nAmp)
	_e_ = StzEngineSoundGraphAddEnvelopeAt(nG, _o_, nA, nD, nSus, nR, nGate, nStart)
	return StzEngineSoundGraphAddPan(nG, _e_, nPan)

# Collect a list of voices into a fresh mix, and REFUSE TO BE SILENT about a
# rejected input -- the failure mode this whole file exists to make audible.
func MixOf nG, aVoices
	_m_ = StzEngineSoundGraphAddMix(nG)
	for _v_ in aVoices
		if StzEngineSoundGraphMixAdd(nG, _m_, _v_) != 0
			? "   !! a voice was REFUSED by the mix: " + StzEngineSoundGraphLastError()
		ok
	next
	return _m_

# =========================================================================
# THE COMPOSITION -- "Ostinato in A minor"
#
# 100 BPM, 4/4, eight bars, about twenty seconds. Four layers, each built
# from nothing but the nodes the guards test:
#
#   PAD    slow triangle chords, panned wide, one per bar
#   BASS   a filtered saw on the root, two hits a bar, dead centre
#   ARP    a fast triangle arpeggio through the chord, drifting L to R
#   BELL   a sine melody with a long decay, through a big echo
#
# The chords are Am - F - C - G, twice. It is the most ordinary progression
# in Western music, which is the point: if the engine is honest, ordinary
# music comes out sounding ordinary rather than wrong.
# =========================================================================

func BuildComposition
	_bpm_ = 100
	_beat_ = 60.0 / _bpm_          # 0.6 s
	_bar_ = _beat_ * 4             # 2.4 s

	# Am, F, C, G -- root, third, fifth, and the bass note an octave down
	_chords_ = [
		[ A3, C4, E4, A2 ],
		[ F3, A3, C4, F2 ],
		[ C4, E4, G4, C3 ],
		[ G3, B3, D4, G2 ]
	]
	# the melody, one note per bar over the last four bars
	_tune_ = [ E5, C5, D5, B4, C5, A4, B4, A4 ]

	_g_ = StzEngineSoundGraphNew(2, RATE, 512)

	# VOICES FIRST, MIXES AFTER. A mix may only take inputs that already
	# exist -- that rule is what makes a cycle impossible to express -- so the
	# score is collected into lists here and mixed down below.
	_vPad_ = []
	_vBass_ = []
	_vArp1_ = []
	_vArp2_ = []
	_vBell_ = []

	for _bar_i_ = 0 to 7
		_ch_ = _chords_[(_bar_i_ % 4) + 1]
		_t0_ = _bar_i_ * _bar_
		_swell_ = 0.55
		if _bar_i_ >= 4
			_swell_ = 0.75            # the second half opens up
		ok

		# -- PAD: three notes, wide, slow in and slow out
		_vPad_ + AddVoice(_g_, StzSoundWaveTriangle(), _ch_[1], 0.13 * _swell_, _t0_, _bar_ * 0.9, 0.35, 0.4, 0.75, 0.7, 0.18)
		_vPad_ + AddVoice(_g_, StzSoundWaveTriangle(), _ch_[2], 0.11 * _swell_, _t0_, _bar_ * 0.9, 0.40, 0.4, 0.75, 0.7, 0.50)
		_vPad_ + AddVoice(_g_, StzSoundWaveTriangle(), _ch_[3], 0.11 * _swell_, _t0_, _bar_ * 0.9, 0.45, 0.4, 0.75, 0.7, 0.82)

		# -- BASS: beats 1 and 3, centred, short and round
		for _hit_ = 0 to 1
			_vBass_ + AddBass(_g_, _ch_[4], _t0_ + _hit_ * _beat_ * 2, _beat_ * 0.9)
		next

		# -- ARP: four eighth-notes climbing the chord, drifting across
		for _n_ = 0 to 3
			_hz_ = _ch_[(_n_ % 3) + 1]
			if _n_ = 3
				_hz_ = _hz_ * 2        # the fourth note jumps an octave
			ok
			_when_ = _t0_ + _n_ * _beat_
			_pan_ = 0.25 + (_n_ / 3.0) * 0.5
			_vv_ = AddVoice(_g_, StzSoundWaveTriangle(), _hz_, 0.16, _when_, 0.18, 0.004, 0.22, 0.0, 0.08, _pan_)
			# two arp mixes, because ONE mix takes at most 32 inputs and eight
			# bars of four notes is exactly 32 -- no room for a mistake
			if _bar_i_ < 4
				_vArp1_ + _vv_
			else
				_vArp2_ + _vv_
			ok
		next

		# -- BELL: the tune, second half only, one note per bar
		if _bar_i_ >= 4
			_vBell_ + AddVoice(_g_, StzSoundWaveSine(), _tune_[_bar_i_ + 1], 0.26, _t0_ + _beat_, _bar_ * 0.5, 0.006, 1.1, 0.0, 0.5, 0.45)
		ok
	next

	# ---- now the mixes, every one of them AFTER its inputs
	_mPad_ = MixOf(_g_, _vPad_)
	_mBass_ = MixOf(_g_, _vBass_)
	_mBell_ = MixOf(_g_, _vBell_)

	# -- the bell goes through a big echo in time with the music
	_bellEcho_ = StzEngineSoundGraphAddDelay(_g_, _mBell_, _beat_ * 0.75, 0.42, 0.42)

	# -- the arp gets a shorter, tighter echo
	_arpSum_ = MixOf(_g_, _vArp1_)
	_arpSum2_ = MixOf(_g_, _vArp2_)
	_arpBoth_ = MixOf(_g_, [ _arpSum_, _arpSum2_ ])
	_arpEcho_ = StzEngineSoundGraphAddDelay(_g_, _arpBoth_, _beat_ * 0.5, 0.30, 0.28)

	# -- everything together, then a gentle lowpass so nothing is harsh
	_master_ = MixOf(_g_, [ _mPad_, _mBass_, _arpEcho_, _bellEcho_ ])

	_warm_ = StzEngineSoundGraphAddFilter(_g_, _master_, StzSoundFilterLowPass(), 7000, 0.7)
	_out_ = StzEngineSoundGraphAddGain(_g_, _warm_, 1.9)   # brings the peak to ~0.75
	StzEngineSoundGraphSetOutput(_g_, _out_)
	return [ _g_, _out_, _bar_ * 8 + 2.5 ]

func AddBass nG, nHz, nStart, nGate
	_o_ = StzEngineSoundGraphAddOsc(nG, StzSoundWaveSaw(), nHz, 0.34)
	_f_ = StzEngineSoundGraphAddFilter(nG, _o_, StzSoundFilterLowPass(), 420, 1.1)
	_e_ = StzEngineSoundGraphAddEnvelopeAt(nG, _f_, 0.008, 0.22, 0.35, 0.25, nGate, nStart)
	return StzEngineSoundGraphAddPan(nG, _e_, 0.5)

func PlayComposition
	? ""
	? "   >> OSTINATO IN A MINOR -- 100 BPM, eight bars, four layers."
	? "      pad . bass . arpeggio . a bell melody in the second half"
	_r_ = BuildComposition()
	_g_ = _r_[1]
	_gain_ = _r_[2]
	_len_ = _r_[3]
	? "      " + StzEngineSoundGraphNodeCount(_g_) + " nodes; " + _len_ + " seconds"
	if StzEngineSoundGraphPrepare(_g_) != 0
		? "      prepare failed: " + StzEngineSoundGraphLastError()
		return
	ok
	if NOT bHaveDevice
		? "      (no device -- use 's' to save it to a file instead)"
		StzEngineSoundGraphFree(_g_)
		return
	ok

	# fade in from silence, so the first chord arrives rather than lands
	StzEngineSoundGraphSetGain(_g_, _gain_, 0.0, 0)
	_s_ = StzEngineSoundStreamStart(_g_, 32768)
	sleep(0.2)
	_d_ = StzEngineAudioDevPlaybackOpen(StzEngineSoundStreamRingPtr(_s_), 256)
	if _d_ = 0
		? "      device would not open: " + StzEngineAudioDevLastError()
		StzEngineSoundStreamStop(_s_)
		StzEngineSoundGraphFree(_g_)
		return
	ok
	StzEngineAudioDevPlaybackStart(_d_)
	StzEngineSoundGraphSetGain(_g_, _gain_, 1.9, 1200)     # 1.2 s fade in
	sleep(_len_ - 2.0)
	StzEngineSoundGraphSetGain(_g_, _gain_, 0.0, 1800)     # and out
	sleep(2.0)
	StzEngineAudioDevPlaybackStop(_d_)
	? "      played " + StzEngineAudioDevPlaybackFramesOut(_d_) + " frames, " +
	  "worst callback " + StzEngineAudioDevPlaybackWorstUs(_d_) + " us, " +
	  StzEngineSoundStreamUnderruns(_s_) + " underruns"
	StzEngineAudioDevPlaybackClose(_d_)
	StzEngineSoundStreamStop(_s_)
	StzEngineSoundGraphFree(_g_)

func SaveComposition
	? ""
	? "   >> rendering the piece to a file (no device needed for this)..."
	_r_ = BuildComposition()
	_g_ = _r_[1]
	_len_ = _r_[3]
	if StzEngineSoundGraphPrepare(_g_) != 0
		? "      prepare failed: " + StzEngineSoundGraphLastError()
		return
	ok
	_path_ = cTmp + "/ostinato_in_am.wav"
	_frames_ = floor(_len_ * RATE)
	_t0_ = clock()
	if StzEngineSoundGraphToFile(_g_, _frames_, _path_, 16) = 0
		_secs_ = (clock() - _t0_) / clockspersecond()
		? "      wrote " + _path_
		? "      " + _len_ + " s of audio rendered in " + _secs_ + " s"
	else
		? "      could not write it: " + StzEngineSoundLastError()
	ok
	StzEngineSoundGraphFree(_g_)
