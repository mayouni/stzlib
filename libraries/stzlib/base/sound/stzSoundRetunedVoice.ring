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

# Holds a spoken syllable on a note: the speech voice's own timbre with its pitch replaced by the engine's period-synchronous retuner.
#
# SAPI says the syllable slowly into memory and the engine's PSOLA lays its glottal periods back at
# the note's period, so the timbre is the speech voice's and the pitch is the engine's, held. Large
# shifts from the voice's own pitch, about 166 hertz for Zira, sound processed. Syllable holds one
# syllable, LineQ lays syllables on notes a beat each, and Sing does the same at 90 beats a minute
# when StzSoundSingingVerdict records the retuned voice as SINGING, which it does, ruled by the
# Principal on 2026-09-27. Everything is rendered to memory and checked by frame count, sample rate
# and peak; no audio device is opened. This run was not heard by a person (UNPERCEIVED).
#
#   receiver   o1 = StzSoundRetunedVoiceQ() oS = o1.Syllable("la", "A3", 1.2)
#   example    ? o1.IsUsable()
#              #--> 1
#              ? oS.SampleRate()
#              #--> 48000
#              ? oS.Frames() > 57600 and oS.Frames() < 66000
#              #--> 1
#              ? oS.Peak() > 0.1 and oS.Peak() <= 1
#              #--> 1
#              ? o1.Marks() > 50
#              #--> 1
#              oL = o1.LineQ("la la la", "c4 e4 g4", 90)
#              ? oL.Frames()
#              #--> 124800
#              oBad = o1.Syllable("la", "Zzz9", 1)
#              ? o1.LastError()
#              #--> a pitch is a note name (A3, C#4) or Hz
#   see        stzSoundFormantVoice, stzVoice, stzSoundScore
class stzSoundRetunedVoice

	@oV = NULL
	@nRate = 48000
	@nVibrato = 20
	@cLastError = ""
	@nRefusals = 0
	@nFromHz = 0            # the last syllable's own pitch, as spoken
	@nMarks = 0             # how many glottal periods the retune found

	# Builds a retuned voice over the machine's speech voices, taking the last one installed.
	#
	#   returns    nothing; the object is built, and not usable when the machine has no speech voice
	#   note       StzSoundRetunedVoiceQ builds the same object; with no voice it counts a refusal
	#              and LastError says no SAPI voice
	#   see        IsUsable, Spoken
	def init()
		@oV = StzVoiceQ()
		if NOT @oV.IsUsable() or @oV.VoiceCount() = 0
			This._Refuse("no SAPI voice: " + @oV.LastError())
			return
		ok
		@oV.UseVoice(@oV.VoiceCount())

	# TRUE if a speech voice is available to retune.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        VoiceName, init
	def IsUsable()
		return isObject(@oV) and @oV.IsUsable() and @oV.VoiceCount() > 0

	# Returns the name of the speech voice in use.
	#
	#   returns    the name as text, such as Microsoft Zira Desktop - English (United States); an
	#              empty text when the voice is not usable
	#   see        IsUsable
	def VoiceName()
		if NOT This.IsUsable()  return "" ok
		return @oV.CurrentVoiceName()

	# Sets the depth of the vibrato laid on a held syllable.
	#
	#   pnCents    the depth in cents, from 0 to 100
	#   returns    the voice itself, so calls chain
	#   note       the default is 20 cents
	#   warning    a value outside 0 to 100 or not a number is refused: it counts a refusal, sets
	#              LastError to SetVibrato: 0 to 100 cents, and the old depth stays
	#   see        Syllable, LineQ
	def SetVibrato(pnCents)
		if NOT isNumber(pnCents) or pnCents < 0 or pnCents > 100
			This._Refuse("SetVibrato: 0 to 100 cents")
			return This
		ok
		@nVibrato = pnCents
		return This

	# Returns the pitch the last syllable had as the speech voice spoke it.
	#
	#   returns    a number in hertz; 0 before any syllable
	#   note       for the syllable la of the voice here it was 187.11, so a note far from it is a
	#              large shift and sounds processed
	#   see        Marks, Syllable
	def FromHz()
		return @nFromHz

	# Returns how many glottal periods the last retune found in the spoken syllable.
	#
	#   returns    a number; 0 before any syllable
	#   note       139 for the syllable la of the voice here
	#   see        FromHz, Syllable
	def Marks()
		return @nMarks

	# Returns a syllable as the speech voice says it, slowly and mono, before any retuning.
	#
	#   pcSyllable   the text to speak
	#   returns      a stzSound at the voice's own rate, 22050 hertz here, mono; an empty text when
	#                the voice is not usable or refused
	#   note         the sound is rendered to memory; the syllable la gave 75398 frames and a peak
	#                of 0.77; release it with Release when done
	#   see          Syllable
	#@ aka  The syllable as SAPI says it, slowly -- the raw material, unretuned.
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

	# Holds a spoken syllable on a note: the voice's own timbre with the pitch laid down by the engine's period-synchronous retuner.
	#
	#   pcSyllable   the text to speak
	#   pNote        a note name such as A3 or C#4, or a frequency in hertz
	#   pnSeconds    how long to hold it, in seconds
	#   returns      a mono stzSound at 48000 hertz; an empty text when the pitch is bad or the
	#                voice failed, with the reason in LastError
	#   note         the sound runs about 0.05 s longer than asked: 1.2 s gave 60001 frames and 1.0
	#                s gave 50401; the peak was 0.56; the vibrato is the one set by SetVibrato
	#   warning      a pitch that is neither a note name nor a number, such as Zzz9, gives an empty
	#                text and the error a pitch is a note name (A3, C#4) or Hz
	#   see          Spoken, LineQ, FromHz
	#@ aka  The syllable held on a note (a name or Hz) for `pnSeconds`, at 48 kHz.
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

	# Sings syllables on notes, one beat each, laid end to end into one sound.
	#
	#   pcSyllables   the syllables, separated by spaces
	#   pcNotes       the notes, separated by spaces, one for each syllable
	#   pnBpm         the tempo in beats a minute
	#   returns       a mono stzSound at 48000 hertz as long as the notes plus 0.6 s; an empty text
	#                 when the counts differ or a syllable failed
	#   note          each syllable is held for 95 percent of a beat; three syllables at 90 beats a
	#                 minute gave 124800 frames, which is 2.6 seconds
	#   warning       a different number of syllables and notes gives an empty text and the error
	#                 LineQ: as many syllables as notes
	#   see           Syllable, Sing
	#@ aka  Syllables on notes, a beat each, laid end to end.
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

	# Sings lyrics on notes through LineQ at 90 beats a minute, if the voice has been ruled to sing.
	#
	#   pcLyrics   the syllables, separated by spaces
	#   pcNotes    the notes, separated by spaces
	#   returns    the same sound as LineQ; an empty text when the ruling is not SINGING
	#   note       the tempo is fixed at 90; the formant voice, by contrast, is still recorded as
	#              UNPERCEIVED
	#   warning    the class header still says Sing is refused until the author rules, which is out
	#              of date: StzSoundSingingVerdict records the retuned voice as SINGING, ruled by
	#              the Principal on 2026-09-27, and Sing returned a sound
	#   see        LineQ, StzSoundSingingVerdict
	#@ aka  SINGING -- gated by the retuned voice's own verdict.
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

	# Returns the reason of the last refusal.
	#
	#   returns    the reason as text; an empty text when the last call went well
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls were refused.
	#
	#   returns    a number
	#   note       it counts a bad pitch, a count mismatch, a bad vibrato and a missing voice
	#   see        LastError
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
