#---------------------------------------------------------------------------#
#  STZSOUNDFORMANTVOICE -- the voice, honestly (MU5)                         #
#---------------------------------------------------------------------------#
#
#     oV = StzSoundFormantVoiceQ()
#     oV.Vowel("a", "A3", 1.5).Play()                 # one sung vowel
#     oV.VowelsQ("a e i o u", "c4 d4 e4 f4 g4", 96)   # a line of vowels
#     oV.Sing("la la la", "c4 e4 g4")                 # REFUSED -- see below
#
# THE PLAN'S MU5 IS THREE ATTEMPTS IN ORDER, EACH MEASURED:
#
#   (a) SAPI with <prosody pitch> on a syllable per note -- does it hold a pitch
#       within 20 cents? MEASURED, and NO: asked for +-6 semitones it moves
#       about +-2.5, up to 407 cents off, and within one syllable its pitch
#       wanders 286 to 575 cents -- it is INTONING SPEECH, not holding a note.
#       The numbers are in sound_mu5_narrated.ring and the MU5 STATUS.
#   (b) a formant vowel voice in the seam -- five vowels, a pitch, a breath.
#       BUILT: a Rosenberg glottal pulse through five formant resonators
#       (the Csound manual's tenor and soprano tables). Held pitch measured to
#       0.218 cents. Whether it reads as a VOICE -- as singing -- is not a
#       number: it is the author's, and UNTIL THEY SAY SO it is not singing.
#   (c) neither -> singing deferred to the neural tier, in writing.
#
# SO Sing() IS PRESENT AND GATED. It reads the verdict below -- declared data --
# and refuses while the verdict is anything but "SINGING". The plan's kill
# criterion is exactly this: "the plan does not ship a Sing() that produces
# something the author would not call singing". What this class DOES offer
# ungated is what it honestly is: vowels at pitches, named Vowel and Vowels.
#
# WHAT IT CANNOT DO: consonants. A formant voice sings vowels; "la" is sung as
# its vowel "a". Words need a consonant model or the neural tier.

# THE VERDICT -- declared data, changed by one line when the author rules.
# TWO CANDIDATES, since the author heard SAPI on 2026-09-27 and said its
# voice is "very close from real human voice": the formant voice (b), and
# SAPI's own voice retuned by PSOLA (a'). Each entry's :verdict is
# "UNPERCEIVED", "SINGING" (its Sing() then works) or "NOT SINGING".
func StzSoundSingingVerdict()
	return [
		:formant = [
			:voice = "formant (Rosenberg pulse, Csound formant tables)",
			:verdict = "UNPERCEIVED", :by = "", :date = "", :said = "" ],
		:retuned = [
			:voice = "SAPI's own voice, retuned by PSOLA onto the note",
			:verdict = "SINGING", :by = "Mansour Ayouni (the Principal)", :date = "2026-09-27",
			:said = "the retuned voice is somehow singing, open Sing()",
			:timbre = "the Principal, 2026-09-27, of SAPI's unretuned voice: 'very close from real human voice'" ],
		:sapi = "measured 2026-09-26: +-6 st asked, +-2.5 st given, up to 407 cents off, 286-575 cents of wander within a syllable -- it speaks, it cannot hold a note"
	]

func StzSoundFormantVoiceQ()
	return new stzSoundFormantVoice()

# Sings the five vowels at a pitch with a formant voice built in the engine, a glottal pulse through five resonators.
#
# The voice is a Rosenberg glottal pulse through formant resonators taken from the Csound tenor and
# soprano tables, and holds a pitch to a fraction of a cent. Vowel gives one vowel at a note,
# VowelGlide a gliding pitch, VowelsQ a line of vowels at a tempo. It sings vowels only: a consonant
# needs a model or the neural tier. Sing is present and gated by StzSoundSingingVerdict, and refuses
# while the formant voice is recorded as UNPERCEIVED. Everything is rendered to memory and checked
# by frame count, sample rate, peak and measured pitch; no audio device is opened. It has not been
# heard by a person (UNPERCEIVED), so whether it reads as a voice is not claimed.
#
#   receiver   o1 = StzSoundFormantVoiceQ() oV = o1.Vowel("a", "A3", 1.5)
#   example    ? oV.SampleRate()
#              #--> 48000
#              ? oV.Frames()
#              #--> 79200
#              ? oV.Peak() > 0.1 and oV.Peak() <= 1
#              #--> 1
#              ? abs(StzEngineSoundPitchOf(oV.BufferId(), 24001, 4096, 50, 2000) - 220) < 2
#              #--> 1
#              ? @@( o1.FormantsOf("a", 220) )
#              #--> [ 650, 1080 ]
#              oBad = o1.Vowel("y", "A3", 1)
#              ? o1.LastError()
#              #--> 'y' is not one of the five vowels a e i o u
#              oS = o1.Sing("la la", "c4 e4")
#              ? o1.Refusals()
#              #--> 2
#   see        stzSoundRetunedVoice, stzVoice, stzSoundScore
class stzSoundFormantVoice

	@nRate = 48000
	@nBreath = 0.2
	@nVibrato = 25          # +- cents; 0 holds the pitch dead still
	@nVelocity = 0.8
	@cLastError = ""
	@nRefusals = 0

	# Builds a formant voice that sings the five vowels, noting whether the sound engine is loaded.
	#
	#   returns    nothing; the object is built
	#   note       StzSoundFormantVoiceQ builds the same object; without the sound engine LastError
	#              says stz_sound.dll is not loaded
	#   see        Vowel, Sing
	def init()
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
		ok

	# Sets how much breath noise is mixed into the voice.
	#
	#   pn         the breath, from 0 for none to 1 for all
	#   returns    the voice itself, so calls chain
	#   note       the default is 0.2
	#   warning    a value outside 0 to 1 or not a number is refused: it counts a refusal, sets
	#              LastError to SetBreath: 0 to 1, and the old value stays
	#   see        SetVibrato, Vowel
	def SetBreath(pn)
		if NOT isNumber(pn) or pn < 0 or pn > 1
			This._Refuse("SetBreath: 0 to 1")
			return This
		ok
		@nBreath = pn
		return This

	# Sets the depth of the vibrato, in cents above and below the pitch.
	#
	#   pnCents    the depth in cents, from 0, which holds the pitch still, to 100
	#   returns    the voice itself, so calls chain
	#   note       the default is 25 cents
	#   warning    a value outside 0 to 100 or not a number is refused as SetBreath is, with the
	#              error SetVibrato: 0 to 100 cents
	#   see        SetBreath, Vowel
	def SetVibrato(pnCents)
		if NOT isNumber(pnCents) or pnCents < 0 or pnCents > 100
			This._Refuse("SetVibrato: 0 to 100 cents")
			return This
		ok
		@nVibrato = pnCents
		return This

	# Returns the five vowels the voice can sing.
	#
	#   returns    the list a, e, i, o, u
	#   see        FormantsOf, Vowel
	#@ aka  The five vowels, and the first two formants each sits on at a pitch -- what the guard holds the rendered spectrum against.
	def Vowels()
		return [ "a", "e", "i", "o", "u" ]

	# Returns the two lowest formants a vowel sits on at a pitch, in hertz.
	#
	#   pcVowel    one of a, e, i, o or u
	#   pnHz       the pitch in hertz
	#   returns    a list of two numbers; [ ] for a name that is not one of the five vowels
	#   note       for the vowel a at 220 hertz they are 650 and 1080, and for i 290 and 1870, from
	#              the Csound formant tables
	#   see        Vowels, Vowel
	def FormantsOf(pcVowel, pnHz)
		_i_ = This._VowelIndex(pcVowel)
		if _i_ = 0  return [] ok
		return [ StzEngineSoundVowelFormant(_i_, pnHz, 1), StzEngineSoundVowelFormant(_i_, pnHz, 2) ]

	# Renders one sung vowel at a pitch as a sound.
	#
	#   pcVowel     one of a, e, i, o or u
	#   pNote       a note name such as A3 or a frequency in hertz
	#   pnSeconds   how long to hold it, in seconds
	#   returns     a mono stzSound at 48000 hertz; an empty text when the vowel or the pitch is
	#               refused, with the reason in LastError
	#   note        the sound runs 0.15 s longer than asked, a release: 1.5 s gave 79200 frames; A3
	#               read back at 219.73 hertz by the engine's pitch reader, against 220; the peak
	#               was 0.56
	#   warning     a vowel that is not one of the five, such as y, gives an empty text and the
	#               error ... is not one of the five vowels a e i o u; a pitch that is neither a
	#               note name nor a number gives the error a pitch is a note name (A3, C#4) or Hz
	#   see         VowelGlide, FormantsOf
	#@ aka  One vowel at a pitch (a note name or Hz) for `pnSeconds`.
	def Vowel(pcVowel, pNote, pnSeconds)
		return This.VowelGlide(pcVowel, pNote, pNote, pnSeconds)

	# Renders one sung vowel whose pitch glides from one note to another.
	#
	#   pcVowel     one of a, e, i, o or u
	#   pFrom       the note or frequency it starts on
	#   pTo         the note or frequency it ends on
	#   pnSeconds   how long the glide lasts, in seconds
	#   returns     a mono stzSound at 48000 hertz; an empty text when refused, with the reason in
	#               LastError
	#   note        the pitch rises or falls through the sound: from A3 to A4 over 1 s it read about
	#               233 hertz early on and 400 hertz near the end; the tail adds 0.15 s as in Vowel
	#   warning     the same refusals as Vowel
	#   see         Vowel
	def VowelGlide(pcVowel, pFrom, pTo, pnSeconds)
		_i_ = This._VowelIndex(pcVowel)
		if _i_ = 0
			This._Refuse("'" + pcVowel + "' is not one of the five vowels a e i o u")
			return NULL
		ok
		_a_ = This._Hz(pFrom)
		_b_ = This._Hz(pTo)
		if _a_ <= 0 or _b_ <= 0
			This._Refuse("a pitch is a note name (A3, C#4) or Hz")
			return NULL
		ok
		_id_ = StzEngineSoundVowelOf(_i_, _a_, _b_, pnSeconds, @nVelocity, @nBreath, @nVibrato, @nRate)
		if _id_ = 0
			This._Refuse(StzEngineSoundLastError())
			return NULL
		ok
		@cLastError = ""
		return StzSoundFromBufferQ(_id_)

	# A line of vowels, one per note, at a tempo: "a e i o u" over
	# "c4 d4 e4 f4 g4", a beat each, laid end to end with a small overlap.
	def VowelsQ(pcVowels, pcNotes, pnBpm)
		_aV_ = This._Words(pcVowels)
		_aN_ = This._Words(pcNotes)
		if len(_aV_) = 0 or len(_aV_) != len(_aN_)
			This._Refuse("VowelsQ: as many vowels as notes")
			return NULL
		ok
		_beat_ = 60 / pnBpm
		_o_ = new stzSound("")
		_o_.MakeSilence(len(_aN_) * _beat_ + 0.5, 1, @nRate)
		for _k_ = 1 to len(_aN_)
			_n_ = This.Vowel(_aV_[_k_], _aN_[_k_], _beat_ * 0.95)
			if NOT isObject(_n_)  return NULL ok
			_o_.MixIn(_n_, (_k_ - 1) * _beat_, 1)
			_n_.Release()
		next
		return _o_

	# Sings lyrics, each syllable as its first vowel, if the voice has been ruled to sing.
	#
	#   pcLyrics   the syllables, separated by spaces
	#   pcNotes    the notes, separated by spaces
	#   returns    a sound, as VowelsQ gives, one vowel for each note at 90 beats a minute; an empty
	#              text while the ruling is not SINGING
	#   note       it sings vowels only: a consonant model does not exist, so la is sung as a; Vowel
	#              and VowelsQ are what the voice honestly does
	#   warning    refused today: StzSoundSingingVerdict records the formant voice as UNPERCEIVED,
	#              so it returns an empty text and the error Sing is not available YET: the formant
	#              voice has not been heard by the author
	#   see        Vowel, StzSoundSingingVerdict
	#@ aka  SINGING -- gated by the verdict. Refused, with the reason, until the author has heard the formant voice and called it singing.
	def Sing(pcLyrics, pcNotes)
		_aAll_ = StzSoundSingingVerdict()
		_aV_ = This._Get(_aAll_, :formant, [])
		_aV_ + [ "sapi", This._Get(_aAll_, :sapi, "") ]
		_v_ = This._Get(_aV_, :verdict, "UNPERCEIVED")
		if _v_ = "UNPERCEIVED"
			This._Refuse("Sing is not available YET: the formant voice has not been heard by the " +
			             "author (sound_mu5_demo.ring plays it). SAPI was measured and does not hold " +
			             "a pitch (" + This._Get(_aV_, :sapi, "") + "). Until the author calls the " +
			             "formant voice singing, Vowel and VowelsQ are what this voice honestly does")
			return NULL
		ok
		if _v_ != "SINGING"
			This._Refuse("Sing is deferred to the neural tier: the author heard the formant voice (" +
			             This._Get(_aV_, :by, "") + ", " + This._Get(_aV_, :date, "") + ") and said: " +
			             This._Get(_aV_, :said, "") + " -- and SAPI does not hold a pitch")
			return NULL
		ok
		# approved: each syllable is sung as its first vowel (no consonants)
		_aS_ = This._Words(pcLyrics)
		_cV_ = ""
		for _s_ in _aS_
			_x_ = This._FirstVowel(_s_)
			if _x_ = ""
				This._Refuse("Sing: '" + _s_ + "' has no vowel to sing")
				return NULL
			ok
			_cV_ += _x_ + " "
		next
		return This.VowelsQ(_cV_, pcNotes, 90)

	# Returns the reason of the last refusal.
	#
	#   returns    the reason as text; an empty text when the last call went well
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls were refused.
	#
	#   returns    a number
	#   note       it counts a bad vowel, a bad pitch, a refused Sing and a bad breath or vibrato
	#   see        LastError
	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	def _VowelIndex(pc)
		_c_ = lower(ring_trim("" + pc))
		_a_ = [ "a", "e", "i", "o", "u" ]
		for _k_ = 1 to 5
			if _a_[_k_] = _c_  return _k_ ok
		next
		return 0

	def _FirstVowel(pc)
		_c_ = lower("" + pc)
		for _k_ = 1 to len(_c_)
			if ring_find([ "a", "e", "i", "o", "u" ], _c_[_k_]) > 0  return _c_[_k_] ok
			if _c_[_k_] = "y"  return "i" ok
		next
		return ""

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
