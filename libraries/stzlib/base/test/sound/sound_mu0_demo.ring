# MU0 -- THE FOUR MEASUREMENTS, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu0_narrated.ring      # first: it writes the three WAVs
#     ring sound_mu0_demo.ring
#
# The guard proved four numbers. Two of the four spikes have a half that no
# number can settle, and CENTRAL-PERCEPTGATE-01 says that half is not
# optional -- it is simply yours:
#
#   spike 2   does 9.5 ms of trigger lateness READ AS SWING?
#   spike 3   does a thirty-line pluck SOUND LIKE A STRING?
#
# The other two are played so a person has heard what the numbers describe:
#
#   spike 1   a 440 -> 880 Hz ramp with a click and without one
#   spike 4   D, then D a quarter tone sharp -- is the difference a pitch or a
#             wobble to your ear?
#
# ONE BUFFER PER SPIKE, ONE DEVICE EACH, console driven by the transport's
# clock -- VC4's arrangement, arrived at after the author's ears found three
# defects in a row in the arrangement before it.

load "../../stzBase.ring"

pr()
decimals(2)

? "=================================================================="
? " MU0 -- four measurements, out loud"
? "=================================================================="
? ""

if NOT (StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1)
	? "No output device. The three WAVs the guard wrote are in this folder;"
	? "play them in any player: mu0_grid_quantised.wav, mu0_pluck.wav,"
	? "mu0_quartertone.wav."
	bye
ok

nRate = 48000

# ---------------------------------------------------------------------------
? "-- 1 -- a frequency ramp, with a click and without --"
? ""
? "   440 Hz for a second, then 880 Hz. First the change is a JUMP -- the"
? "   guard measured its kink at 4.4x the tone's own curvature. Then the same"
? "   change on a 10 ms ramp, which the guard could not tell from no change."
? "   Listen for the tick at the first change and its absence at the second."
? ""

oJump = RenderSweep(0)
oRamp = RenderSweep(10)
oOne = StzSoundOfSilenceQ(5.0, 1, nRate)
Blit(oOne, oJump, 0)
Blit(oOne, oRamp, floor(2.5 * nRate))
Hear(oOne, [ [ 0.0, "jump: 440 -> 880 with no ramp" ],
             [ 2.5, "ramp: the same change over 10 ms" ] ])
oJump.Release()  oRamp.Release()  oOne.Release()
sleep(0.8)

# ---------------------------------------------------------------------------
? ""
? "-- 2 -- the trigger grid: as the render places it, then sample-exact --"
? ""
? "   Twenty notes at 120 BPM. The first version is the guard's own render:"
? "   every note lands at the block edge after its beat -- mean 4.8 ms late,"
? "   worst 9.5 ms. The second version places every note on the sample."
? "   THE QUESTION IS YOURS: does the first one swing, drag, or sound the"
? "   same? The answer decides whether MU2 builds sub-block triggers."
? ""

oQ = StzSoundFromFileQ("mu0_grid_quantised.wav")
oX = RenderExactGrid(20, 120)
Hear(oQ, [ [ 0.0, "as the render places it (block-quantised)" ] ])
sleep(0.6)
Hear(oX, [ [ 0.0, "sample-exact" ] ])
oQ.Release()  oX.Release()
sleep(0.8)

# ---------------------------------------------------------------------------
? ""
? "-- 3 -- a thirty-line pluck --"
? ""
? "   Karplus-Strong, 1983: a delay line the length of one period, filled"
? "   with noise, averaged with its neighbour on every pass. Four notes, then"
? "   the same four with a longer ring. The guard measured that it decays"
? "   like a string; whether it SOUNDS like one is the verdict only you can"
? "   give, and the plan records your answer by name."
? ""

aNotes = [ 220, 293.66, 329.63, 440 ]
oPh = StzSoundOfSilenceQ(8.0, 1, nRate)
nAt = 0
for nHz in aNotes
	Blit(oPh, PluckOf(nHz, 0.9, 0.996), nAt)
	nAt += floor(0.5 * nRate)
next
nAt = floor(3.2 * nRate)
for nHz in aNotes
	Blit(oPh, PluckOf(nHz, 1.6, 0.999), nAt)
	nAt += floor(0.5 * nRate)
next
oPh.SaveAs("mu0_pluck_phrase.wav")
Hear(oPh, [ [ 0.0, "A3 D4 E4 A4, decay 0.996 -- a guitar's ring" ],
            [ 3.2, "the same, decay 0.999 -- a harp's" ] ])
oPh.Release()
sleep(0.8)

# ---------------------------------------------------------------------------
? ""
? "-- 4 -- a quarter tone --"
? ""
? "   D4, then D4 one step of 24-TET higher. The guard measured the step at"
? "   49.997 cents. Then, for the ear's reference, D4 and the SEMITONE above"
? "   it, 100 cents. A quarter tone is what Rast and Dhil are made of."
? ""

oQt = StzSoundFromFileQ("mu0_quartertone.wav")
Hear(oQt, [ [ 0.0, "D4" ], [ 2.25, "D4 + 50 cents" ] ])
sleep(0.5)
oSemi = StzSoundOfSilenceQ(4.5, 1, nRate)
Blit(oSemi, RenderTone(293.66, 2.0), 0)
Blit(oSemi, RenderTone(311.13, 2.0), floor(2.25 * nRate))
Hear(oSemi, [ [ 0.0, "D4 again" ], [ 2.25, "D4 + 100 cents, a semitone" ] ])
oQt.Release()  oSemi.Release()

? ""
? "=================================================================="
? " Two numbers were the guard's. Two verdicts are yours: does 9.5 ms"
? " swing, and is the pluck a string. The STATUS section records both,"
? " or records that you have not said."
? "=================================================================="

# ---- helpers --------------------------------------------------------------

func RenderSweep nRampMs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, 440, 0.4)
	_g_.NameIt(:osc)
	_g_.AddGainOn(:osc, 1.0)
	_g_.NameIt(:bus)
	_g_.SetOutputTo(:bus)
	_g_.Prepare()
	_a_ = _g_.ToSound(1.0)
	StzEngineSoundGraphSetFrequency(_g_.GraphId(), _g_.NodeNamed(:osc), 880, nRampMs)
	_b_ = _g_.ToSound(1.0)
	_out_ = StzSoundOfSilenceQ(2.0, 1, nRate)
	Blit(_out_, _a_, 0)
	Blit(_out_, _b_, _a_.Frames())
	_a_.Release()  _b_.Release()  _g_.Release()
	return _out_

func RenderTone nHz, nSecs
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, nHz, 0.4)
	_g_.NameIt(:t)
	_g_.SetOutputTo(:t)
	_g_.Prepare()
	_s_ = _g_.ToSound(nSecs)
	_g_.Release()
	return _s_

func PluckOf nHz, nSecs, nDecay
	return StzSoundFromBufferQ(StzEngineSoundPluckOf(nHz, nRate, nSecs, nDecay))

# the same envelope note as the guard's, placed on the SAMPLE
func RenderExactGrid nBeats, nBpm
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, nRate)
	_g_.AddOscillator(:Sine, 1000, 0.5)
	_g_.NameIt(:tone)
	_g_.AddEnvelopeOn(:tone, 0.001, 0.04, 0.0, 0.02, 0.05)
	_g_.NameIt(:env)
	_g_.SetOutputTo(:env)
	_g_.Prepare()
	_spend_ = _g_.ToSound(0.5)
	_spend_.Release()
	StzEngineSoundGraphTriggerNode(_g_.GraphId(), _g_.NodeNamed(:env))
	_note_ = _g_.ToSound(0.1)
	_g_.Release()
	_beat_ = floor(60 / nBpm * nRate)
	_out_ = StzSoundOfSilenceQ((nBeats * _beat_ + nRate) / nRate, 1, nRate)
	for _i_ = 0 to nBeats - 1
		Blit(_out_, _note_, nRate + _i_ * _beat_)
	next
	_note_.Release()
	return _out_

func Hear poSound, paCues
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, poSound.SampleRate())
	_g_.AddSound(poSound)
	_t_ = new stzSoundTransport(_g_)
	_t_.PlayFor(poSound.Duration() + 0.2)
	_n_ = 1
	while NOT _t_.IsStopped()
		_t_.Tick()
		if _n_ <= len(paCues) and _t_.PositionInSeconds() >= paCues[_n_][1] - 0.05
			? "   [" + paCues[_n_][1] + "s]  " + paCues[_n_][2]
			_n_++
		ok
		sleep(0.02)
	end
	_t_.Release()
	_g_.Release()

func Blit poDest, poSrc, nAt
	_max_ = poDest.Frames()
	for _i_ = 1 to poSrc.Frames()
		_d_ = nAt + _i_
		if _d_ > _max_  exit ok
		poDest.SetSampleAt(_d_, 1, poSrc.SampleAt(_i_, 1))
	next
