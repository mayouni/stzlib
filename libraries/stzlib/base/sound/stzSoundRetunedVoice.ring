#---------------------------------------------------------------------------#
#  STZSOUNDRETUNEDVOICE -- a human-sounding voice, held on the note (MU5 a') #
#---------------------------------------------------------------------------#
#
#     oR = StzSoundRetunedVoiceQ()                 # BEFORE any audio device
#     oR.Syllable("la", "A3", 1.2).Play()          # SAPI says it; PSOLA holds it
#     oR.LineQ("la la la la", "c4 e4 g4 c5", 90)
#     oR.Sing("la la la", "c4 e4 g4")              # REFUSED until the author rules
#
# WHY THIS EXISTS. MU5's (a) asked SAPI to sing through <prosody pitch> and it
# could not: it moves a third of the way asked, and slides 300-500 cents within
# a syllable. The author then HEARD it and said its voice is "very close from
# real human voice" -- and the rejection had been of its pitch control, not its
# voice. So (a') keeps the voice and takes the pitch: SAPI speaks the syllable,
# slowly, and the engine's PSOLA (soundinstr.zig, `retune`) lays its glottal
# periods back down at the note's period. The timbre is SAPI's; the pitch is
# the engine's, held.
#
# THE ORDER NO LONGER MATTERS. Until 2026-09-30, probing the audio device
# first initialised COM in a mode the voice then refused (0x80010106), and
# SAPI reported no voices (STZLIB-VOICE-COMODE-01). The engine now accepts COM
# in either mode; sound_voicecom_narrated.ring does the old forbidden order.
#
# WHAT IT CANNOT DO WELL, and the guard measures it rather than hides it: a note
# far from SAPI's own pitch (about 166 Hz for Zira) is a large shift, and large
# shifts sound processed. The words are SAPI's: consonants included, which the
# formant voice cannot do.

func StzSoundRetunedVoiceQ()
	return new stzSoundRetunedVoice()

class stzSoundRetunedVoice

	@oV = NULL
	@nRate = 48000
	@nVibrato = 20
	@cLastError = ""
	@nRefusals = 0
	@nFromHz = 0            # the last syllable's own pitch, as spoken
	@nMarks = 0             # how many glottal periods the retune found

	def init()
		@oV = StzVoiceQ()
		if NOT @oV.IsUsable() or @oV.VoiceCount() = 0
			This._Refuse("no SAPI voice: " + @oV.LastError())
			return
		ok
		@oV.UseVoice(@oV.VoiceCount())

	def IsUsable()
		return isObject(@oV) and @oV.IsUsable() and @oV.VoiceCount() > 0

	def VoiceName()
		if NOT This.IsUsable()  return "" ok
		return @oV.CurrentVoiceName()

	def SetVibrato(pnCents)
		if NOT isNumber(pnCents) or pnCents < 0 or pnCents > 100
			This._Refuse("SetVibrato: 0 to 100 cents")
			return This
		ok
		@nVibrato = pnCents
		return This

	def FromHz()
		return @nFromHz

	def Marks()
		return @nMarks

	# The syllable as SAPI says it, slowly -- the raw material, unretuned.
	def Spoken(pcSyllable)
		if NOT This.IsUsable()  return NULL ok
		_q_ = char(34)
		_o_ = @oV.ToSoundOfSsml("<speak version=" + _q_ + "1.0" + _q_ + " xmlns=" + _q_ +
		      "http://www.w3.org/2001/10/synthesis" + _q_ + " xml:lang=" + _q_ + "en-US" + _q_ +
		      "><prosody rate=" + _q_ + "x-slow" + _q_ + ">" + pcSyllable + "</prosody></speak>")
		if NOT isObject(_o_)
			This._Refuse(@oV.LastError())
			return NULL
		ok
		# IN PLACE, THEN RETURN THE OBJECT. The first cut ended with
		# "return _o_.ToMonoQ()" -- the Q form returns This of a LOCAL object,
		# and Ring died on it with no message at all (exit 1, nothing printed).
		_o_.ToMono()
		return _o_

	# The syllable held on a note (a name or Hz) for `pnSeconds`, at 48 kHz.
	def Syllable(pcSyllable, pNote, pnSeconds)
		_hz_ = This._Hz(pNote)
		if _hz_ <= 0
			This._Refuse("a pitch is a note name (A3, C#4) or Hz")
			return NULL
		ok
		_sp_ = This.Spoken(pcSyllable)
		if NOT isObject(_sp_)  return NULL ok
		_id_ = StzEngineSoundRetune(_sp_.BufferId(), _hz_, pnSeconds, @nVibrato)
		_sp_.Release()
		if _id_ = 0
			This._Refuse(StzEngineSoundLastError())
			return NULL
		ok
		@nFromHz = StzEngineSoundRetuneFromHz()
		@nMarks = StzEngineSoundRetuneMarks()
		_o_ = StzSoundFromBufferQ(_id_)
		# in place, and NOT "_r_ = _o_.ResampleToQ(...); _o_.Release()": the Q
		# form returns the same object, so that release would free the very
		# buffer _r_ held
		_o_.ResampleTo(@nRate)
		@cLastError = ""
		return _o_

	# Syllables on notes, a beat each, laid end to end.
	def LineQ(pcSyllables, pcNotes, pnBpm)
		_aS_ = This._Words(pcSyllables)
		_aN_ = This._Words(pcNotes)
		if len(_aS_) = 0 or len(_aS_) != len(_aN_)
			This._Refuse("LineQ: as many syllables as notes")
			return NULL
		ok
		_beat_ = 60 / pnBpm
		_o_ = new stzSound("")
		_o_.MakeSilence(len(_aN_) * _beat_ + 0.6, 1, @nRate)
		for _k_ = 1 to len(_aN_)
			_n_ = This.Syllable(_aS_[_k_], _aN_[_k_], _beat_ * 0.95)
			if NOT isObject(_n_)  return NULL ok
			_o_.MixIn(_n_, (_k_ - 1) * _beat_, 1)
			_n_.Release()
		next
		return _o_

	# SINGING -- gated by the retuned voice's own verdict.
	def Sing(pcLyrics, pcNotes)
		_aAll_ = StzSoundSingingVerdict()
		_aV_ = This._Get(_aAll_, :retuned, [])
		_v_ = This._Get(_aV_, :verdict, "UNPERCEIVED")
		if _v_ = "UNPERCEIVED"
			This._Refuse("Sing is not available YET: the retuned voice has not been heard by the " +
			             "author (sound_mu5_demo.ring plays it). Syllable and LineQ are what it does " +
			             "until the author calls it singing")
			return NULL
		ok
		if _v_ != "SINGING"
			This._Refuse("Sing (retuned voice) is closed: " + This._Get(_aV_, :by, "") + " said: " +
			             This._Get(_aV_, :said, ""))
			return NULL
		ok
		return This.LineQ(pcLyrics, pcNotes, 90)

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	def _Hz(p)
		if isNumber(p)  return p ok
		_c_ = "" + p
		if len(_c_) >= 2
			_c_ = upper(_c_[1]) + substr(_c_, 2, len(_c_) - 1)
		ok
		return StzNoteToHz(_c_)

	def _Words(pcText)
		_a_ = []
		_w_ = ""
		for _k_ = 1 to len(pcText)
			_ch_ = pcText[_k_]
			if _ch_ = " " or _ch_ = char(9)
				if _w_ != ""  _a_ + _w_  _w_ = "" ok
			else
				_w_ += _ch_
			ok
		next
		if _w_ != ""  _a_ + _w_ ok
		return _a_

	def _Get(paL, pcKey, pDefault)
		for _p_ in paL
			if isList(_p_) and len(_p_) = 2 and lower("" + _p_[1]) = lower(pcKey)  return _p_[2] ok
		next
		return pDefault

	def _Refuse(pcWhy)
		@nRefusals++
		@cLastError = pcWhy
