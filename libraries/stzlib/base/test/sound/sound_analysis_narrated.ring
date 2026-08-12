# ANALYSIS, AND THE GRAPHICS CONVERGENCE -- SN5 of SOFTANZA_SOUND_PLAN.md.
#
# Spectrum, spectrogram, onsets, tempo, loudness -- and the first time this
# plane hands its output to another plane to draw.
#
# WHY THE ANALYSIS RETURNS DATA AND NOT A PICTURE, restated because it is the
# whole reason this file can exist: "the 1 kHz sine is in the 1 kHz bin" is a
# claim about numbers, and a guard can check it. "The spectrogram looks right"
# is a claim about nothing. So every analysis returns a GRID, and drawing is a
# separate step through stzCanvas.
#
# THE SWEEP IS THE CENTREPIECE. A tone that slides from 200 Hz to 4 kHz must
# produce a spectrogram whose peak bin climbs, row after row, from start to
# end. That is a picture you can SEE is right (a diagonal line) and a property
# a guard can PROVE is right (monotonically increasing), which is a rare and
# useful combination.
#
# Nothing here needs audio hardware. The SVG tier needs no device at all.

load "../../stzBase.ring"

nPass = 0
nFail = 0

cTmp = currentdir() + "/temp"
if NOT direxists(cTmp)
	system("mkdir " + '"' + cTmp + '"')
ok

pr()
decimals(4)

? "== analysis: spectrum, spectrogram, onsets, tempo, loudness =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: a spectrum puts a tone where the tone is --"

oT = MakeTone(1000, 1.0, 0.5)
Chk("the dominant frequency is 1 kHz", fabs(oT.DominantFrequency() - 1000) < 15)

oSpec = oT.ToSpectrum()
Chk("ToSpectrum returned a grid", isObject(oSpec))
Chk("of one row", oSpec.Rows() = 1)
Chk("with 2049 bins for a 4096-point window", oSpec.Columns() = 2049)
Chk("and it knows its bin width", fabs(oSpec.HertzPerColumn() - 48000/4096) < 0.001)
? "   peak at " + oSpec.PeakFrequencyOfRow(1) + " Hz, bin width " + oSpec.HertzPerColumn() + " Hz"
Chk("the peak is within one bin of 1 kHz",
    fabs(oSpec.PeakFrequencyOfRow(1) - 1000) < oSpec.HertzPerColumn() * 1.5)

# the negative sibling: a bin far away is essentially empty, so the peak means
# something rather than the whole spectrum being large
nFar = oSpec.At(1, oSpec.PeakColumnOfRow(1) + 300)
Chk("a distant bin is essentially empty", nFar < oSpec.Max() * 0.01)
oSpec.Release()
oT.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: THE SWEEP -- a picture you can see AND prove --"
? "   A tone sliding 200 Hz -> 4 kHz must make the peak bin climb, row after"
? "   row. Drawn, it is a diagonal; measured, it is monotonic."

oSw = MakeSweep(200, 4000, 2.0)
oSg = oSw.ToSpectrogram()
Chk("the spectrogram came back", isObject(oSg))
? "   " + oSg.Rows() + " windows x " + oSg.Columns() + " bins, " +
  oSg.SecondsPerRow() + " s per row"
Chk("it has many rows", oSg.Rows() > 50)
Chk("and knows what a row means in time", oSg.SecondsPerRow() > 0)

nRows = oSg.Rows()
nRises = 0
nFalls = 0
nPrev = oSg.PeakFrequencyOfRow(3)
for r = 4 to nRows - 3
	nHz = oSg.PeakFrequencyOfRow(r)
	if nHz > nPrev
		nRises++
	but nHz < nPrev
		nFalls++
	ok
	nPrev = nHz
next
? "   peak frequency rose " + nRises + " times, fell " + nFalls + " times"
Chk("the peak climbs far more often than it falls", nRises > nFalls * 10)
Chk("it starts low", oSg.PeakFrequencyOfRow(4) < 600)
Chk("and ends high", oSg.PeakFrequencyOfRow(nRows - 4) > 3000)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE GRAPHICS CONVERGENCE -- the sound plane hands numbers to"
? "   the graphics plane, and neither knows the other's internals --"

nT0 = clock()
oCanvas = oSg.ToCanvas(600, 220)
cSvg = oCanvas.ToSVG()
nMs = (clock() - nT0) / clockspersecond() * 1000
? "   drew it through stzCanvas in " + nMs + " ms, " + len(cSvg) + " bytes of SVG"
Chk("ToCanvas produced a canvas", isObject(oCanvas))
Chk("the SVG is real", len(cSvg) > 2000)
Chk("and it is SVG", substr(cSvg, "<svg") > 0)
Chk("with rectangles in it -- one per cell, because stzCanvas has no image",
    substr(cSvg, "<rect") > 0)

cSvgPath = cTmp + "/sweep_spectrogram.svg"
oSg.ToSVGFile(cSvgPath, 600, 220)
Chk("and it writes to a file with NO audio device and NO gpu", fexists(cSvgPath))

# the negative sibling: silence must NOT draw the same picture as a sweep
oQuiet = StzSoundOfSilenceQ(2.0, 1, 48000)
oQg = oQuiet.ToSpectrogram()
cQuietSvg = oQg.ToCanvas(600, 220).ToSVG()
? "   silence draws " + len(cQuietSvg) + " bytes; the sweep drew " + len(cSvg)
Chk("silence draws a much emptier picture", len(cQuietSvg) < len(cSvg) / 2)
oQg.Release()
oQuiet.Release()
oSg.Release()
oSw.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: onsets find the notes, and the tempo follows --"

oClicks = MakeClicks(4, 0.5)          # a click every half second = 120 BPM
oOn = oClicks.ToOnsets()
Chk("ToOnsets returned a grid", isObject(oOn))
? "   found " + oOn.Columns() + " onsets at: " + This_TimesText(oOn)
Chk("about four of them", oOn.Columns() >= 3 and oOn.Columns() <= 6)

nBpm = oClicks.Tempo()
? "   tempo: " + nBpm + " BPM   (want 120)"
Chk("the tempo is 120 BPM", fabs(nBpm - 120) < 12)
oOn.Release()

# the negative sibling: a steady tone has no onsets to find, and the tempo
# says so rather than inventing a number
oSteady = MakeTone(440, 2.0, 0.5)
nNoBpm = oSteady.Tempo()
? "   a steady tone reports tempo: " + nNoBpm
Chk("a sound with no events reports -1, not a confident number", nNoBpm = -1)
oSteady.Release()
oClicks.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: loudness is a STANDARD, so it can be checked by arithmetic --"

oQ1 = MakeTone(1000, 1.0, 0.1)
oQ2 = MakeTone(1000, 1.0, 0.2)
nL1 = oQ1.Loudness()
nL2 = oQ2.Loudness()
? "   0.1 amplitude: " + nL1 + " LUFS      0.2 amplitude: " + nL2 + " LUFS"
Chk("both measured", nL1 > -1000 and nL2 > -1000)
# doubling the amplitude is +6.02 dB, and LUFS is a dB scale
Chk("doubling the amplitude is +6.02 LU", fabs((nL2 - nL1) - 6.02) < 0.15)
Chk("and louder really is a bigger number", nL2 > nL1)

# the face resamples for the standard rather than returning a plausible lie
oOdd = MakeTone(1000, 1.0, 0.1)
oOdd.ResampleTo(44100)
nLodd = oOdd.Loudness()
? "   the same tone at 44.1 kHz: " + nLodd + " LUFS (the face resampled a copy)"
Chk("a non-48k sound still measures", nLodd > -1000)
Chk("and agrees with the 48k answer", fabs(nLodd - nL1) < 0.5)
Chk("while the sound itself was NOT changed by measuring it", oOdd.SampleRate() = 44100)
oOdd.Release()
oQ1.Release()
oQ2.Release()

# silence has no loudness, and says so
oSil = StzSoundOfSilenceQ(2.0, 1, 48000)
Chk("silence reports -1000, not 0 dB", oSil.Loudness() = -1000)
oSil.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: a grid is a handle, and a freed one is STALE --"

oG2 = MakeTone(500, 0.3, 0.4)
oS2 = oG2.ToSpectrum()
nGid = oS2.GridId()
Chk("the grid has rows", oS2.Rows() > 0)
oS2.Release()
Chk("after release it is empty", oS2.IsEmpty())
Chk("and the raw id reads -1, not 0", StzEngineSoundGridRows(nGid) = -1)
oG2.Release()

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

func MakeTone nHz, nSecs, nAmp
	_o_ = StzSoundOfSilenceQ(nSecs, 1, 48000)
	_n_ = _o_.Frames()
	for _i_ = 1 to _n_
		_t_ = (_i_ - 1) / 48000
		_o_.SetSampleAt(_i_, 1, nAmp * sin(2 * 3.14159265358979 * nHz * _t_))
	next
	return _o_

# A tone whose pitch slides from nFrom to nTo. The phase must be the INTEGRAL
# of frequency, not frequency times time -- the naive version sweeps at twice
# the rate you asked for and ends in the wrong place.
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

func MakeClicks nCount, nGap
	_o_ = StzSoundOfSilenceQ(nCount * nGap + 0.3, 1, 48000)
	for _k_ = 0 to nCount - 1
		_at_ = floor(_k_ * nGap * 48000) + 1
		for _i_ = 0 to 1999
			_env_ = 1 - _i_ / 2000
			_t_ = _i_ / 48000
			_o_.SetSampleAt(_at_ + _i_, 1, 0.9 * _env_ * sin(2 * 3.14159265358979 * 1200 * _t_))
		next
	next
	return _o_

func This_TimesText oGrid
	_c_ = ""
	_n_ = oGrid.Columns()
	for _i_ = 1 to _n_
		_c_ += "" + oGrid.At(1, _i_) + "s "
	next
	return _c_
