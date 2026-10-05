#---------------------------------------------------------------------------#
#  STZSOUNDTRANSCRIBER -- a sound becomes a score (MU7, RECOGNISE)           #
#---------------------------------------------------------------------------#
#
#     oT = StzSoundTranscriberQ()
#     oS = oT.TranscribeQ(oSound, 96)       # a stzSoundScore, at 96 BPM
#     ? oT.Confidences()                    # how sure, per note (0..1)
#     ? oT.Unpitched()                      # onsets that had no pitch
#
# THE PLAN'S MU7 ROW "Sound -> score (pitch + onsets -> stzScore, confidence
# per note, exactly as VC3 carries confidence)". Onsets are found in the
# sample domain -- a jump in 5 ms energy -- and refined to the sample (not
# SN5's spectral flux: see _Onsets for why). Pitch is read at each onset, past its attack, by the seam's UNGUIDED
# reader (detectPitch: McLeod over 50-2000 Hz, no guess) -- and its clarity is
# the note's confidence. What comes back is an ordinary stzSoundScore: the
# same object the other three transforms make and read, with no adapter.
#
# WHAT IT CANNOT RECOVER, named: WHICH stroke a drum hit was. An onset with no
# pitch is kept (Unpitched) with its time, and not guessed into a dum or a tak.
# Nor does it separate two notes sounding at once: it is monophonic.

func StzSoundTranscriberQ()
	return new stzSoundTranscriber()

class stzSoundTranscriber

	@nRate = 48000
	@aConf = []             # clarity per note, in the score's order
	@aUnpitched = []        # [ seconds, clarity ] -- onsets with no pitch
	@nMinClarity = 0.6
	@cInstrument = "piano"
	@cLastError = ""

	# present on purpose: "new X()" WITH parentheses calls init, and fails
	# when there is none ("Calling Function without definition: init")
	def init()

	def SetInstrument(pcName)
		@cInstrument = lower("" + pcName)
		return This

	def SetMinClarity(pn)
		@nMinClarity = pn
		return This

	def Confidences()
		return @aConf

	def Unpitched()
		return @aUnpitched

	def LastError()
		return @cLastError

	def TranscribeQ(poSound, pnBpm)
		_oS_ = StzSoundScoreQ().Tempo(pnBpm)
		_oS_.On(@cInstrument)
		@aConf = []
		@aUnpitched = []
		if NOT isObject(poSound) or poSound.Frames() = 0
			@cLastError = "TranscribeQ: nothing to transcribe"
			return _oS_
		ok
		# a MONO copy, made by the engine -- never ToMono on the caller's sound
		_id_ = StzEngineSoundToChannels(poSound.BufferId(), 1)
		if _id_ = 0
			@cLastError = StzEngineSoundLastError()
			return _oS_
		ok
		_m_ = StzSoundFromBufferQ(_id_)
		@nRate = _m_.SampleRate()
		_nF_ = _m_.Frames()
		# NOT SN5's onsets, and the first cut used them: spectral flux over a
		# 2048-frame window with a 512 hop MISSED the first note, skipped others,
		# and put the rest up to a window (43 ms) EARLY -- so each pitch was read
		# inside the previous note, and the transcription came back wrong in
		# pitch as well as time. MU0 found the same thing about the same
		# detector: its resolution is the size of the error being measured.
		_aOn_ = This._Onsets(_m_)
		_spb_ = 60 / pnBpm
		for _i_ = 1 to len(_aOn_)
			_s_ = _aOn_[_i_]
			_e_ = _nF_
			if _i_ < len(_aOn_)  _e_ = _aOn_[_i_ + 1] ok
			_at_ = _s_ + floor(0.04 * @nRate)            # past the attack
			_win_ = 2048
			if _at_ + _win_ + 1000 > _e_  _win_ = 1024 ok
			_hz_ = StzEngineSoundPitchOf(_id_, _at_ + 1, _win_, 50, 2000)
			_cl_ = StzEngineSoundPitchClarity()
			if _hz_ > 0 and _s_ > 1200
				_hz_ = This._WhichIsNew(_m_, _s_, _hz_)
			ok
			_beat_ = (_s_ / @nRate) / _spb_
			if _hz_ > 0 and _cl_ >= @nMinClarity
				_len_ = ((_e_ - _s_) / @nRate) / _spb_
				_oS_.NoteAt(_beat_, _hz_, _len_)
				@aConf + _cl_
			else
				@aUnpitched + [ _s_ / @nRate, _cl_ ]
			ok
		next
		_m_.Release()
		return _oS_

	# WHICH PART IS NEW. A plucked note still rings when the next begins, and
	# two notes together are periodic at their COMMON period: C4 under G4
	# repeats at 130.8 Hz, and the first transcription read G4 as C3 -- right
	# about the mixture, wrong about the note. The new note is the energy that
	# GREW at the onset. So the reading and its multiples (up to 2 kHz) are
	# scored by how much their first four harmonics gained, the 1024 frames
	# after the attack against the 1024 before the onset, and the best wins.
	def _WhichIsNew(poM, pnOn, pnHz)
		_aB_ = This._Window(poM, pnOn - 1024 - 64, 1024)
		_aA_ = This._Window(poM, pnOn + floor(0.02 * @nRate), 1024)
		_best_ = pnHz
		_bestS_ = -1
		for _k_ = 1 to 6
			_c_ = pnHz * _k_
			if _c_ > 2000  exit ok
			_sc_ = 0
			for _hh_ = 1 to 4
				_f_ = _c_ * _hh_
				if _f_ > @nRate / 2  exit ok
				_sc_ += This._Mag(_aA_, _f_) - This._Mag(_aB_, _f_)
			next
			if _sc_ > _bestS_
				_bestS_ = _sc_
				_best_ = _c_
			ok
		next
		return _best_

	def _Window(poM, pnFrom, pnN)
		_a_ = list(pnN)
		for _i_ = 1 to pnN
			_f_ = pnFrom + _i_
			if _f_ >= 1 and _f_ <= poM.Frames()
				_a_[_i_] = poM.SampleAt(_f_, 1)
			else
				_a_[_i_] = 0
			ok
		next
		return _a_

	# |DFT| of a Hann-windowed block at one frequency
	def _Mag(paX, pnHz)
		_n_ = len(paX)
		_w_ = 2 * 3.14159265358979 * pnHz / @nRate
		_re_ = 0
		_im_ = 0
		for _i_ = 1 to _n_
			_hn_ = 0.5 - 0.5 * cos(2 * 3.14159265358979 * (_i_ - 1) / (_n_ - 1))
			_re_ += paX[_i_] * _hn_ * cos(_w_ * _i_)
			_im_ += paX[_i_] * _hn_ * sin(_w_ * _i_)
		next
		return sqrt(_re_ * _re_ + _im_ * _im_)

	# Onsets in the sample domain: the energy of the FIRST DIFFERENCE in 5 ms
	# hops -- an attack's noise and edges, which a ringing note's tail barely
	# has -- and an onset where a hop is more than four times the mean of the
	# four before it and above a floor (a thousandth of the loudest), at least
	# 50 ms after the last; then refined to the sample. Frames, 0-based. (The
	# plain energy of a first cut missed notes that began while the last one
	# still rang loud.)
	def _Onsets(poM)
		_n_ = poM.Frames()
		_h_ = floor(0.005 * @nRate)
		_aE_ = []
		_top_ = 0
		_f_ = 1
		_pv_ = 0
		while _f_ + _h_ - 1 <= _n_
			_acc_ = 0
			for _k_ = _f_ to _f_ + _h_ - 1
				_v_ = poM.SampleAt(_k_, 1)
				_acc_ += (_v_ - _pv_) * (_v_ - _pv_)
				_pv_ = _v_
			next
			_aE_ + _acc_
			if _acc_ > _top_  _top_ = _acc_ ok
			_f_ += _h_
		end
		_aOut_ = []
		_last_ = -999999
		for _i_ = 1 to len(_aE_)
			_prev_ = 0
			_cnt_ = 0
			for _j_ = _i_ - 4 to _i_ - 1
				if _j_ >= 1
					_prev_ += _aE_[_j_]
					_cnt_++
				ok
			next
			if _cnt_ > 0  _prev_ = _prev_ / _cnt_ ok
			_fr_ = (_i_ - 1) * _h_
			if _aE_[_i_] > 4 * _prev_ and _aE_[_i_] > _top_ / 1000 and _fr_ - _last_ > 0.05 * @nRate
				_on_ = This._Refine(poM, _fr_ + 1)
				_aOut_ + _on_
				_last_ = _on_
			ok
		next
		return _aOut_

	# the onset to the sample: within the hop that rose, the first frame whose
	# CHANGE (first difference) passes a third of the largest change in the
	# next 10 ms. By level, as the first cut did, a note beginning over a
	# ringing tail was placed up to 6 ms early -- the tail already passed the
	# threshold; an attack's edge is what the tail does not have.
	def _Refine(poM, pnF)
		_from_ = pnF - floor(0.005 * @nRate)
		if _from_ < 2  _from_ = 2 ok
		_to_ = pnF + floor(0.01 * @nRate)
		if _to_ > poM.Frames()  _to_ = poM.Frames() ok
		_pk_ = 0
		for _f_ = _from_ to _to_
			_d_ = fabs(poM.SampleAt(_f_, 1) - poM.SampleAt(_f_ - 1, 1))
			if _d_ > _pk_  _pk_ = _d_ ok
		next
		for _f_ = _from_ to _to_
			if fabs(poM.SampleAt(_f_, 1) - poM.SampleAt(_f_ - 1, 1)) > _pk_ / 3  return _f_ - 1 ok
		next
		return pnF
