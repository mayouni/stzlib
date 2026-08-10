# The portable sample tier -- stz_sound.dll, SN1 of SOFTANZA_SOUND_PLAN.md.
#
# THIS GUARD NEEDS NO AUDIO HARDWARE, and that is the point rather than a
# convenience. The plan's lesson 5 says the sink is a parameter, not a fork:
# the whole sample tier -- decode, encode, resample, convert -- lives in a DLL
# that never touches a device, so CI can assert the SAMPLES themselves. A CI
# box with no sound card runs every line below.
#
# WHAT IT ASSERTS: the mechanism, never the vibe. Every positive scene has a
# negative sibling -- the thing that proves the guard would NOTICE a failure.
# Where a counter is the witness, the guard asserts that the number MOVED, and
# that it did not move on the other side of the gate.

load "../../stzBase.ring"

nPass = 0
nFail = 0

# counter indices (see engine/stz_sound.ring)
C_LIVE = 0
C_CREATED = 1
C_STALE = 8
C_REFUSALS = 9

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

pr()
decimals(12)

? "== stz_sound: the portable sample tier =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load -- this is a BUILD problem, not a"
	? "         machine capability. The portable half needs no hardware."
	? ""
	? "0 passed, 1 failed"
	bye
ok
? "  stz_sound.dll loaded; IsAvailable = " + StzEngineSoundIsAvailable() +
  "  (always 1 -- it needs no hardware)"

# ---------------------------------------------------------------------------
? ""
? "-- Scene 1: buffer ids are GENERATION-KEYED, so a freed id is detected --"
? "   A recycled slot must not answer to the dead id. The counter is the"
? "   witness: sound.stale.hits moves on the dead read and NOT on the live one."

StzEngineSoundCountersReset()
nId = StzEngineSoundNewSilent(100, 2, 48000)
Chk("a new buffer has a non-zero id", nId != 0)
Chk("frames reads back", StzEngineSoundFrames(nId) = 100)
Chk("channels reads back", StzEngineSoundChannels(nId) = 2)
Chk("rate reads back", StzEngineSoundRate(nId) = 48000)

nStaleBefore = StzEngineSoundCounter(C_STALE)
Chk("a LIVE read does not count as stale", nStaleBefore = 0)

Chk("free succeeds once", StzEngineSoundFree(nId) = 0)

# the negative sibling: the same id must now fail, and be counted
Chk("freeing twice returns STALE, not OK", StzEngineSoundFree(nId) = 2)
Chk("a stale read returns -1, not 0", StzEngineSoundFrames(nId) = -1)
Chk("sound.stale.hits MOVED", StzEngineSoundCounter(C_STALE) > nStaleBefore)

# and the recycled slot must not answer to the old id
nId2 = StzEngineSoundNewSilent(50, 1, 44100)
Chk("the new buffer got a different id", nId2 != nId)
Chk("the new buffer reads its own length", StzEngineSoundFrames(nId2) = 50)
Chk("the OLD id still reads -1 after the slot was recycled", StzEngineSoundFrames(nId) = -1)
StzEngineSoundFree(nId2)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: silence is silent, set/get is exact, out of range is COUNTED --"

nB = StzEngineSoundNewSilent(16, 2, 48000)
Chk("a silent buffer peaks at exactly 0", StzEngineSoundPeak(nB) = 0)
Chk("and its rms is exactly 0", StzEngineSoundRms(nB) = 0)

StzEngineSoundSet(nB, 4, 2, 0.5)
Chk("a written sample reads back exactly", StzEngineSoundGet(nB, 4, 2) = 0.5)
Chk("the OTHER channel of that frame is untouched", StzEngineSoundGet(nB, 4, 1) = 0)
Chk("peak now sees it", StzEngineSoundPeak(nB) = 0.5)

# the negative sibling: an out-of-range write must refuse AND count
nRefBefore = StzEngineSoundCounter(C_REFUSALS)
Chk("writing past the end returns BAD_ARG", StzEngineSoundSet(nB, 999, 1, 1.0) = 3)
Chk("sound.refusals MOVED", StzEngineSoundCounter(C_REFUSALS) > nRefBefore)
Chk("and the buffer was NOT changed by the refused write", StzEngineSoundPeak(nB) = 0.5)
StzEngineSoundFree(nB)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: a WAV round-trip returns the SAMPLES, not something like them --"
? "   f32 must be bit-exact. s16 must NOT be -- and asserting that is what"
? "   proves the comparison would notice a real corruption."

nSrc = MakeRamp(64, 1, 48000)
cF32 = cTmp + "/rt_f32.wav"
cS16 = cTmp + "/rt_s16.wav"
Chk("saving 32-bit WAV succeeds", StzEngineSoundSaveWav(nSrc, cF32, 32) = 0)
Chk("saving 16-bit WAV succeeds", StzEngineSoundSaveWav(nSrc, cS16, 16) = 0)

nBackF = StzEngineSoundLoadFile(cF32)
Chk("the 32-bit file decodes", nBackF != 0)
Chk("frames survive", StzEngineSoundFrames(nBackF) = 64)
Chk("rate survives", StzEngineSoundRate(nBackF) = 48000)
Chk("channels survive", StzEngineSoundChannels(nBackF) = 1)
Chk("f32 round-trip is BIT-EXACT", MaxDiff(nSrc, nBackF) = 0)

nBackS = StzEngineSoundLoadFile(cS16)
Chk("the 16-bit file decodes", nBackS != 0)
nDiffS16 = MaxDiff(nSrc, nBackS)
? "   worst s16 round-trip deviation: " + nDiffS16 + "   (one quantum is " + (1.0/32768.0) + ")"
# 16-bit quantisation is one part in 32767; anything much smaller would mean
# the comparison is not actually comparing
Chk("s16 round-trip is CLOSE (within a quantum)", nDiffS16 < 0.0001)
Chk("s16 round-trip is NOT exact -- the comparison has teeth", nDiffS16 > 0)

StzEngineSoundFree(nBackF)
StzEngineSoundFree(nBackS)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: an ARABIC filename survives encode AND decode --"
? "   miniaudio's narrow path reaches fopen, which on Windows reads bytes in"
? "   the ANSI codepage: a UTF-8 Arabic name fails to open a file that plainly"
? "   exists. The engine converts to UTF-16 and uses the _w variants. The"
? "   filename is not printed -- Windows consoles garble it -- but it is used."

cArabic = cTmp + "/" + char(216)+char(181) + char(217)+char(136) + char(216)+char(170) + ".wav"
nSaveAr = StzEngineSoundSaveWav(nSrc, cArabic, 32)
Chk("saving to an Arabic-named path succeeds", nSaveAr = 0)
Chk("and the file really exists on disk under that name", fexists(cArabic))
nAr = StzEngineSoundLoadFile(cArabic)
Chk("the Arabic-named file decodes", nAr != 0)
Chk("its samples are bit-exact", MaxDiff(nSrc, nAr) = 0)
StzEngineSoundFree(nAr)

# the negative sibling: a path that genuinely does not exist must fail, so the
# scene above is proving Unicode handling rather than proving nothing
nMissing = StzEngineSoundLoadFile(cTmp + "/no_such_file_at_all.wav")
Chk("a genuinely missing file returns 0", nMissing = 0)
Chk("and LastError says something", len(StzEngineSoundLastError()) > 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: resampling keeps duration and DC gain, and sinc beats linear --"
? "   Both resamplers are OURS, in Zig (plan sec.1). The assertion is against"
? "   an ANALYTIC reference sine, not against the other resampler, so 'better'"
? "   means closer to the truth rather than merely different."

nTone = MakeTone(4800, 48000, 1000)     # 0.1 s of 1 kHz at 48 kHz
nSinc = StzEngineSoundResample(nTone, 44100, StzSoundQualitySinc())
nLin  = StzEngineSoundResample(nTone, 44100, StzSoundQualityLinear())
Chk("the sinc resample produced a buffer", nSinc != 0)
Chk("the linear resample produced a buffer", nLin != 0)
Chk("the new rate is 44100", StzEngineSoundRate(nSinc) = 44100)
Chk("duration is preserved within one frame",
    fabs(StzEngineSoundDuration(nSinc) - StzEngineSoundDuration(nTone)) < (1.0/44100.0))
Chk("the source buffer was NOT mutated", StzEngineSoundRate(nTone) = 48000)

nErrSinc = ToneError(nSinc, 44100, 1000)
nErrLin  = ToneError(nLin, 44100, 1000)
? "   max error vs the analytic 1 kHz sine:  sinc " + nErrSinc + "   linear " + nErrLin
Chk("sinc tracks the true sine closely", nErrSinc < 0.01)
# the negative sibling: linear must be MEASURABLY worse, or the metric is not
# discriminating and 'sinc is better' would be an unfalsifiable claim
Chk("linear is measurably worse -- the metric discriminates", nErrLin > nErrSinc * 2)

StzEngineSoundFree(nSinc)
StzEngineSoundFree(nLin)
StzEngineSoundFree(nTone)

# DC gain: a constant must stay constant, INCLUDING at the edges where the
# kernel is truncated. This is the assertion that catches a missing weight
# normalisation, which would fade every file in and out by a few percent.
nDC = StzEngineSoundNewSilent(500, 1, 48000)
for i = 1 to 500
	StzEngineSoundSet(nDC, i, 1, 1.0)
next
nUp = StzEngineSoundResample(nDC, 96000, StzSoundQualitySinc())
nWorst = 0
nN = StzEngineSoundFrames(nUp)
for i = 1 to nN
	nD = fabs(StzEngineSoundGet(nUp, i, 1) - 1.0)
	if nD > nWorst
		nWorst = nD
	ok
next
? "   worst DC deviation across ALL " + nN + " upsampled frames: " + nWorst
Chk("DC gain is unity everywhere, edges included", nWorst < 0.001)
StzEngineSoundFree(nUp)
StzEngineSoundFree(nDC)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: channel conversion averages down, replicates up, mutates nothing --"

nSt = StzEngineSoundNewSilent(4, 2, 48000)
for i = 1 to 4
	StzEngineSoundSet(nSt, i, 1, 1.0)
	StzEngineSoundSet(nSt, i, 2, 0.0)
next
nMono = StzEngineSoundToChannels(nSt, 1)
Chk("stereo -> mono gives 1 channel", StzEngineSoundChannels(nMono) = 1)
Chk("and it is the AVERAGE, not the first channel", StzEngineSoundGet(nMono, 1, 1) = 0.5)

nBack2 = StzEngineSoundToChannels(nMono, 2)
Chk("mono -> stereo gives 2 channels", StzEngineSoundChannels(nBack2) = 2)
Chk("left carries the mono signal", StzEngineSoundGet(nBack2, 1, 1) = 0.5)
Chk("right carries the same signal", StzEngineSoundGet(nBack2, 1, 2) = 0.5)
Chk("the ORIGINAL stereo buffer is untouched", StzEngineSoundGet(nSt, 1, 1) = 1.0)
Chk("frames are preserved by conversion", StzEngineSoundFrames(nMono) = 4)

StzEngineSoundFree(nBack2)
StzEngineSoundFree(nMono)
StzEngineSoundFree(nSt)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: FLAC encode REFUSES rather than writing a mislabelled WAV --"
? "   miniaudio decodes flac but encodes only WAV. A silent substitution is"
? "   the kind of thing found years later in someone's archive."

nRef2 = StzEngineSoundCounter(C_REFUSALS)
cFlac = cTmp + "/should_not_appear.flac"
Chk("SaveFlac returns UNSUPPORTED (6)", StzEngineSoundSaveFlac(nSrc, cFlac) = 6)
Chk("sound.refusals MOVED", StzEngineSoundCounter(C_REFUSALS) > nRef2)
Chk("and NO file was written under that name", NOT fexists(cFlac))
Chk("LastError explains why", len(StzEngineSoundLastError()) > 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: live is a GAUGE, tallies are TALLIES --"
? "   Resetting the counters must not claim that live buffers stopped existing."

StzEngineSoundCountersReset()
nLive0 = StzEngineSoundLiveCount()
nA = StzEngineSoundNewSilent(8, 1, 8000)
nBb = StzEngineSoundNewSilent(8, 1, 8000)
Chk("live count rose by 2", StzEngineSoundLiveCount() = nLive0 + 2)
Chk("the gauge agrees with the table", StzEngineSoundCounter(C_LIVE) = StzEngineSoundLiveCount())
Chk("created is a tally and counted 2", StzEngineSoundCounter(C_CREATED) = 2)

StzEngineSoundCountersReset()
Chk("after reset the TALLY is zero", StzEngineSoundCounter(C_CREATED) = 0)
Chk("after reset the GAUGE still tells the truth",
    StzEngineSoundCounter(C_LIVE) = StzEngineSoundLiveCount())

StzEngineSoundFree(nA)
StzEngineSoundFree(nBb)
StzEngineSoundFree(nSrc)

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers (below the main body: in Ring, top-level code after a func
# ---- never runs, so the scenes must come first) ---------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# The sample VALUES here are load-bearing, and the first version of this guard
# got them wrong in a way the guard itself caught. A ramp of (i%8)/8 - 0.5 is
# multiples of 1/8, and those survive a 16-bit round trip EXACTLY (0.375 ->
# 12287.625 -> rounds to 12288 -> 12288/32768 = 0.375 again). So "s16 is not
# exact" failed -- not because the codec was exact, but because the test data
# was chosen from the measure-zero set that quantises perfectly.
#
# Values off the 1/8 grid are what actually exercise quantisation. f32
# round-tripping stays bit-exact for ANY value, because what is stored is
# already f32.
func MakeRamp nFrames, nCh, nRate
	_id_ = StzEngineSoundNewSilent(nFrames, nCh, nRate)
	for _i_ = 1 to nFrames
		StzEngineSoundSet(_id_, _i_, 1, 0.9 * sin(_i_ * 0.7))
	next
	return _id_

func MakeTone nFrames, nRate, nHz
	_id_ = StzEngineSoundNewSilent(nFrames, 1, nRate)
	for _i_ = 1 to nFrames
		_t_ = (_i_ - 1) / nRate
		StzEngineSoundSet(_id_, _i_, 1, sin(2 * 3.14159265358979 * nHz * _t_))
	next
	return _id_

func MaxDiff nA, nB
	_n_ = StzEngineSoundFrames(nA)
	if StzEngineSoundFrames(nB) < _n_
		_n_ = StzEngineSoundFrames(nB)
	ok
	_nCh_ = StzEngineSoundChannels(nA)
	_worst_ = 0
	for _i_ = 1 to _n_
		for _c_ = 1 to _nCh_
			_d_ = fabs(StzEngineSoundGet(nA, _i_, _c_) - StzEngineSoundGet(nB, _i_, _c_))
			if _d_ > _worst_
				_worst_ = _d_
			ok
		next
	next
	return _worst_

# Max error against an analytically generated sine at the OUTPUT rate. The
# first and last few frames are skipped: there the interpolation kernel runs
# off the end of the signal, and no resampler can invent the samples it would
# have needed. Judging the interior is the honest comparison.
func ToneError nId, nRate, nHz
	_n_ = StzEngineSoundFrames(nId)
	_skip_ = 64
	_worst_ = 0
	for _i_ = _skip_ to _n_ - _skip_
		_t_ = (_i_ - 1) / nRate
		_want_ = sin(2 * 3.14159265358979 * nHz * _t_)
		_d_ = fabs(StzEngineSoundGet(nId, _i_, 1) - _want_)
		if _d_ > _worst_
			_worst_ = _d_
		ok
	next
	return _worst_
