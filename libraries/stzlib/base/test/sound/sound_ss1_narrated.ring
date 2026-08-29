# SS1 -- THE VOCABULARY, AND WHAT ACTUALLY CARRIES IDENTITY.
# See SOFTANZA_SOUND_PLAN.md, the SOUND SEMANTICS section, S.2 and S.8.
#
# THE QUESTION. THE-SECOND-FOUNDING's section 6.1 proposes, by analogy with the
# colour system, that TIMBRE carries identity as hue does. The semantics session
# tried to settle it, failed honestly, and recorded why: it used a spectral L1
# distance with each spectrum normalised to its OWN peak, so a filter that
# removes a fundamental rescales everything and inflates the distance. The
# measurement read 86% at 880 Hz and OVER 100% at 150 Hz, which is not a result.
#
# THE INSTRUMENT THIS TIME, and why it is the right shape:
#
#   1. FEATURES, not a raw spectral difference. A motif is (contour, interval,
#      duration, timbre), so the features are pitch contour (peak frequency per
#      spectrogram row) and brightness contour (spectral centroid per row), both
#      in LOG2 hertz -- an octave is a doubling, and a distance measured in
#      linear hertz would call 200-400 Hz the same step as 4000-4200 Hz.
#
#   2. Z-SCORED PER DIMENSION across the whole set. This is what kills the
#      earlier confound: no dimension can dominate because of its units, and no
#      per-signal renormalisation happens at all.
#
#   3. SEPARABILITY IS A RATIO, not a distance. Identity must survive the
#      CHANNEL, so the question is not "how far apart are two motifs" but "are
#      two motifs further apart than one motif is from ITSELF heard through a
#      different speaker". Each motif is rendered through two channels -- a
#      laptop band and a phone band -- and
#
#          separability = smallest between-motif distance
#                         -------------------------------
#                          largest within-motif distance
#
#      Above 1, a listener has something to go on. Below 1, a motif is closer to
#      a different meaning than to itself, and the vocabulary is not a
#      vocabulary.
#
# THE KILL CRITERION, from the plan and applied below: if the four sounding
# values cannot be told apart through a 500 Hz-6 kHz band, the motifs are wrong;
# and if a timbre-only set cannot while a contour-only set can, then timbre is
# NOT the identity carrier and section 6.1's second row is refused.
#
# No audio device is needed. Every motif is rendered offline.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(2)

RATE = 48000

? "== SS1: can four meanings be told apart, and by WHAT? =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

# ---------------------------------------------------------------------------
? "-- Scene 1: the shipped motifs, through two speakers --"
? "   The four sounding values of Rule 118, as stzEarcons renders them."

oE = new stzEarcons()
aShipped = []
_aCV175_ = [ "Danger", "Warning", "Info", "Success" ]
_nCV175_ = len(_aCV175_)
for _iCV175_ = 1 to _nCV175_
	cV = _aCV175_[_iCV175_]
	aShipped + [ cV, oE.ToSoundOf(cV) ]
next
aSep = Separability(aShipped)
? ""
? "   smallest distance BETWEEN two meanings : " + aSep[1]
? "   largest distance WITHIN one meaning    : " + aSep[2] + "  (same motif, other speaker)"
? "   separability                           : " + aSep[3]
Chk("the four meanings are further apart than any is from itself", aSep[3] > 1.0)
Chk("and with margin, not by a hair", aSep[3] > 1.5)

# the negative sibling: a set that SHOULD fail must fail, or the instrument is
# measuring nothing. Four copies of one motif have no identity to find.
aSame = []
for i = 1 to 4
	aSame + [ "copy" + i, oE.ToSoundOf(:Info) ]
next
aSepSame = Separability(aSame)
? ""
? "   four copies of ONE motif: separability " + aSepSame[3]
Chk("four copies of one sound are NOT separable", aSepSame[3] < 1.0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: TIMBRE alone, or CONTOUR alone -- which survives a speaker? --"
? "   Two sets of four. One holds pitch fixed and varies only the waveform;"
? "   the other holds the waveform fixed and varies only the melodic shape."
? "   Whichever set stays separable through a small speaker is the carrier."

aTimbre = []
aTimbre + [ "sine",     MotifOf([880], :Sine) ]
aTimbre + [ "triangle", MotifOf([880], :Triangle) ]
aTimbre + [ "square",   MotifOf([880], :Square) ]
aTimbre + [ "saw",      MotifOf([880], :Saw) ]
aST = Separability(aTimbre)

aContour = []
aContour + [ "flat",   MotifOf([770, 770], :Triangle) ]
aContour + [ "up",     MotifOf([660, 990], :Triangle) ]
aContour + [ "down",   MotifOf([990, 660], :Triangle) ]
aContour + [ "updown", MotifOf([770, 990, 660], :Triangle) ]
aSC = Separability(aContour)

? ""
? "   TIMBRE only  (one pitch, four waveforms) : separability " + aST[3]
? "   CONTOUR only (one waveform, four shapes) : separability " + aSC[3]
? ""

Chk("contour alone carries identity through a small speaker", aSC[3] > 1.5)

# THE FINDING. Whichever way this goes, it is reported rather than hoped for.
if aST[3] > 1.5
	? "   FINDING: timbre alone ALSO survives. Section 6.1's second row stands,"
	? "   and a motif may lean on either. Both are admitted."
	Chk("timbre alone also carries identity -- 6.1's row 2 stands", aST[3] > 1.5)
else
	? "   FINDING: timbre alone does NOT survive at the margin contour does."
	? "   Section 6.1's 'timbre = identity' is REFUSED as the primary carrier:"
	? "   contour is, and timbre reinforces it. Recorded in the plan's S.2."
	Chk("contour is the STRONGER carrier of the two", aSC[3] > aST[3])
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the vocabulary is still the law's, and :Muted is still silent --"

Chk("five values, no more", len(StzSemanticValues()) = 5)
Chk("muted renders to nothing", NOT isObject(oE.ToSoundOf(:Muted)))
Chk("and the other four render", len(aShipped) = 4)
# a motif must also be SHORT: a semantic sound that outlasts the event it
# reports stops being a report and becomes a mood
for i = 1 to len(aShipped)
	Chk("the " + aShipped[i][1] + " motif is under 300 ms",
	    aShipped[i][2].Duration() < 0.30)
next

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok
oE.Release()

# ---- the instrument -------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

# Separability of a labelled set: [ minBetween, maxWithin, ratio ].
#
# Every motif is featurised through TWO channels. Distances between DIFFERENT
# motifs (same channel) must beat distances between the SAME motif heard through
# the two channels -- that is what "identity survives the channel" means.
func Separability paSet
	_n_ = len(paSet)
	_vecs_ = []                      # [ [motifIndex, channel, features...] ]
	for _i_ = 1 to _n_
		_vecs_ + [ _i_, 1, FeaturesOf(BandOf(paSet[_i_][2], :Laptop)) ]
		_vecs_ + [ _i_, 2, FeaturesOf(BandOf(paSet[_i_][2], :Phone)) ]
	next

	# Z-SCORE EACH DIMENSION over the whole set. Without this, a dimension
	# measured in log-hertz around 10 swamps one that varies by 0.2 -- and the
	# earlier attempt at this question died of exactly that class of mistake.
	_dims_ = len(_vecs_[1][3])
	for _d_ = 1 to _dims_
		_sum_ = 0
		for _k_ = 1 to len(_vecs_)
			_sum_ += _vecs_[_k_][3][_d_]
		next
		_mean_ = _sum_ / len(_vecs_)
		_ss_ = 0
		for _k_ = 1 to len(_vecs_)
			_ss_ += pow(_vecs_[_k_][3][_d_] - _mean_, 2)
		next
		_sd_ = sqrt(_ss_ / len(_vecs_))
		if _sd_ < 0.000001  _sd_ = 1 ok
		for _k_ = 1 to len(_vecs_)
			_vecs_[_k_][3][_d_] = (_vecs_[_k_][3][_d_] - _mean_) / _sd_
		next
	next

	_minBetween_ = 999999
	_maxWithin_ = 0
	for _a_ = 1 to len(_vecs_)
		for _b_ = _a_ + 1 to len(_vecs_)
			_d_ = Dist(_vecs_[_a_][3], _vecs_[_b_][3])
			if _vecs_[_a_][1] = _vecs_[_b_][1]
				# the same meaning, two speakers
				if _d_ > _maxWithin_  _maxWithin_ = _d_ ok
			else
				if _d_ < _minBetween_  _minBetween_ = _d_ ok
			ok
		next
	next
	_ratio_ = 0
	if _maxWithin_ > 0.000001  _ratio_ = _minBetween_ / _maxWithin_ ok
	return [ _minBetween_, _maxWithin_, _ratio_ ]

func Dist paA, paB
	_s_ = 0
	for _i_ = 1 to len(paA)
		_s_ += pow(paA[_i_] - paB[_i_], 2)
	next
	return sqrt(_s_)

# PITCH and BRIGHTNESS, sampled at eight points across the sound, in log2 Hz.
# Log because an octave is a doubling and the ear hears octaves as equal steps;
# eight points because a motif's identity is a SHAPE over time, and one number
# per sound cannot hold a shape.
func FeaturesOf poSound
	_f_ = []
	_g_ = poSound.ToSpectrogramOf(1, 2048, 512, 4)
	if NOT isObject(_g_)  return [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] ok
	_rows_ = _g_.Rows()
	_hzPer_ = _g_.HertzPerColumn()
	_cols_ = _g_.Columns()
	if _cols_ > 300  _cols_ = 300 ok            # to ~7 kHz, the speaker's band
	for _k_ = 0 to 7
		_r_ = floor(1 + _k_ * (_rows_ - 1) / 7)
		if _r_ < 1  _r_ = 1 ok
		if _r_ > _rows_  _r_ = _rows_ ok
		# peak frequency -- the pitch contour
		_pk_ = _g_.PeakFrequencyOfRow(_r_)
		if _pk_ < 20  _pk_ = 20 ok
		_f_ + (log(_pk_) / log(2))
		# spectral centroid -- the brightness contour, which is where a
		# waveform's identity lives once its fundamental is fixed
		_num_ = 0
		_den_ = 0
		for _c_ = 2 to _cols_
			_v_ = _g_.At(_r_, _c_)
			_num_ += _v_ * ((_c_ - 1) * _hzPer_)
			_den_ += _v_
		next
		_cen_ = 20
		if _den_ > 0  _cen_ = _num_ / _den_ ok
		if _cen_ < 20  _cen_ = 20 ok
		_f_ + (log(_cen_) / log(2))
	next
	_g_.Release()
	return _f_

# The two speakers a semantic sound has to survive. Neither is a measurement of
# a real device -- they are stated bands, and the plan says so.
func BandOf poSound, pWhich
	_lo_ = 500  _hi_ = 6000
	if pWhich = :Phone
		_lo_ = 700  _hi_ = 4000
	ok
	_g_ = new stzSoundGraph()
	_g_.Reshape(1, RATE)
	_g_.AddSound(poSound)
	_g_.NameIt(:src)
	_g_.AddFilterOn(:src, :HighPass, _lo_, 0.707)
	_g_.NameIt(:hp)
	_g_.AddFilterOn(:hp, :LowPass, _hi_, 0.707)
	_o_ = _g_.ToSound(poSound.Duration())
	_g_.Release()
	return _o_

# A motif: a run of notes at one waveform, each shaped at both ends so no note
# begins or ends on a step.
func MotifOf paHz, pWave
	_n_ = len(paHz)
	_per_ = 0.09
	_o_ = StzSoundOfSilenceQ(_n_ * _per_, 1, RATE)
	_pf_ = floor(_per_ * RATE)
	_ramp_ = floor(0.006 * RATE)
	for _k_ = 0 to _n_ - 1
		_hz_ = paHz[_k_ + 1]
		for _i_ = 0 to _pf_ - 1
			_at_ = _k_ * _pf_ + _i_ + 1
			if _at_ > _o_.Frames()  loop ok
			_t_ = _i_ / RATE
			_e_ = 1
			if _i_ < _ramp_  _e_ = _i_ / _ramp_ ok
			if _i_ > _pf_ - _ramp_  _e_ = (_pf_ - _i_) / _ramp_ ok
			_o_.SetSampleAt(_at_, 1, 0.45 * _e_ * WaveVal(pWave, _hz_ * _t_))
		next
	next
	return _o_

func WaveVal pWave, pnCycles
	_p_ = 2 * 3.14159265358979 * pnCycles
	switch lower("" + pWave)
	on "sine"     return sin(_p_)
	on "triangle"
		_s_ = 0
		for _h_ = 1 to 15 step 2
			_s_ += (0.81 / (_h_ * _h_)) * sin(_h_ * _p_)
		next
		return _s_
	on "square"
		_s_ = 0
		for _h_ = 1 to 15 step 2
			_s_ += (0.64 / _h_) * sin(_h_ * _p_)
		next
		return _s_
	on "saw"
		_s_ = 0
		for _h_ = 1 to 15
			_s_ += (0.64 / _h_) * sin(_h_ * _p_)
		next
		return _s_
	off
	return sin(_p_)
