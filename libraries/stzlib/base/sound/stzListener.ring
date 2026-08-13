#---------------------------------------------------------------------------#
#  STZLISTENER -- sound in, TEXT out. VC3 of SOFTANZA_VOICE_PLAN.md.         #
#  COMMANDS, NOT TRANSCRIPTION -- and that is a measured decision.           #
#---------------------------------------------------------------------------#
#
#     oL = StzListenerQ()
#     oL.Accept([ "ouvrir le fichier", "enregistrer", "annuler" ])
#     oL.HearSound(oSay)                  # or oL.HearMicrophoneFor(5)
#     ? oL.HeardText() + "  (" + oL.Confidence() + ")"
#
# ── WHY THIS ONLY DOES COMMANDS ────────────────────────────────────────────
#
# The plan set the gate before any number was taken: free dictation ships as
# transcription only if it reaches 80% exact AND 0.60 mean confidence on a
# stated phrase set. Nine phrases, spoken by this plane's OWN voice and fed
# straight back -- the cleanest audio recognition will ever get -- three rounds,
# identical every time:
#
#     free dictation   66.7% exact (6/9)   mean confidence 0.600   FAIL
#     closed grammar   100%  exact (6/6)   mean confidence 0.898   PASS
#
# So this face has no Transcribe() and never will until a better recognizer
# exists. That is the criterion applied, not a shortcut.
#
# AND WHY DICTATION FAILED IS THE USEFUL PART. Every miss was a WRITTEN FORM,
# not a mishearing: "annuler" came back "annule", "arreter" came back "arrete",
# and "soixante deux gigaoctets" came back "60 de gigaoctet". The recognizer
# heard the sounds correctly and chose a different spelling -- a verb ending, a
# numeral instead of words. A closed grammar cannot make that mistake, because
# it maps the sound to the string YOU declared; there is no spelling left to get
# wrong. One measurement, two verdicts, for that reason.
#
# ── CONFIDENCE TRAVELS WITH THE TEXT ───────────────────────────────────────
#
# Confidence() is a separate call so it cannot be skipped by accident. A
# recognised string without one is a guess wearing a fact's clothes -- and at
# 0.75 for one of the six commands even a closed grammar is not certain.
#
# ── LOCAL ONLY, AND THAT IS A PROMISE ──────────────────────────────────────
#
# The engine uses SAPI's IN-PROCESS recognizer, which runs here and reaches no
# network. The shared recognizer can be routed to Windows' online speech
# service; it is not used, and choosing it would have to be an explicit,
# disclosed act. A microphone is a consent boundary, and a microphone that
# reaches a network is a different product.
#
# ── CAPABILITY IS PER LANGUAGE **AND PER DIRECTION** ───────────────────────
#
# This machine SPEAKS en-US and fr-FR and HEARS fr-FR only. Ask
# Languages() before assuming, exactly as stzVoice makes you ask before
# speaking -- and note the two answers differ. That asymmetry is the shape of
# the problem, not a quirk of one laptop.

func StzListenerQ()
	return new stzListener()

class stzListener

	@nL = 0
	@aPhrases = []
	@cLastError = ""
	@nRefusals = 0
	# DECLARED HERE, ABOVE THE FIRST def: Ring only registers attributes
	# written before the first method. One declared among the private helpers
	# at the bottom reads as uninitialised at runtime -- a trap this plane has
	# now paid for twice, in stzEarcons and here.
	@nLastResult = 0

	def init()
		if NOT StzVoiceEngineLoaded()
			@cLastError = "stz_voice.dll is not loaded"
			return
		ok
		if StzEngineListenIsAvailable() = 0
			@cLastError = "no speech recognizer is installed on this machine"
			return
		ok
		@nL = StzEngineListenOpen()
		if @nL = 0  @cLastError = StzEngineListenLastError() ok

	def Release()
		if @nL != 0
			StzEngineListenFree(@nL)
			@nL = 0
		ok

	#-- can this machine hear at all? ---------------------------------------

	def IsUsable()
		return @nL != 0

	def LastError()
		if @cLastError != ""  return @cLastError ok
		if StzVoiceEngineLoaded()  return StzEngineListenLastError() ok
		return ""

	def Refusals()
		return @nRefusals

	#-- what it can hear, as DATA -------------------------------------------

	def RecognizerCount()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineListenInstalledCount()

	# The BCP-47 tags this machine can HEAR. Compare with stzVoice's
	# Languages(), which is what it can SPEAK -- on the machine this was built
	# on the two lists differ, and an application that assumes otherwise will
	# offer a control surface nobody can drive.
	def Languages()
		_a_ = []
		for _i_ = 1 to This.RecognizerCount()
			_t_ = StzEngineListenInstalledLanguage(_i_)
			if _t_ != "" and NOT This._Has(_a_, _t_)  _a_ + _t_ ok
		next
		return _a_

	def ToRecognizerList()
		_a_ = []
		for _i_ = 1 to This.RecognizerCount()
			_a_ + [ StzEngineListenInstalledName(_i_),
			        StzEngineListenInstalledLanguage(_i_) ]
		next
		return _a_

	def HasLanguage(pcTag)
		_want_ = lower("" + pcTag)
		for _t_ in This.Languages()
			if lower(_t_) = _want_  return TRUE ok
			if This._PrimaryOf(lower(_t_)) = This._PrimaryOf(_want_)  return TRUE ok
		next
		return FALSE

	#-- THE GRAMMAR: what it is allowed to hear -----------------------------

	# Declare every phrase this listener will accept. Anything else is a
	# no-match, which is a RESULT rather than a failure -- "somebody said
	# something that is not a command" is information a control surface needs.
	def Accept(paPhrases)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "Accept: there is no usable recognizer on this machine"
			return FALSE
		ok
		_c_ = ""
		_n_ = 0
		for _p_ in paPhrases
			_s_ = trim("" + _p_)
			if _s_ = ""  loop ok
			if _c_ != ""  _c_ += nl ok
			_c_ += _s_
			_n_++
		next
		if _n_ = 0
			@nRefusals++
			@cLastError = "Accept: no usable phrases were given"
			return FALSE
		ok
		if StzEngineListenSetPhrases(@nL, _c_) != 0
			@nRefusals++
			@cLastError = StzEngineListenLastError()
			return FALSE
		ok
		@aPhrases = paPhrases
		@cLastError = ""
		return TRUE

	def AcceptQ(paPhrases)
		This.Accept(paPhrases)
		return This

	def AcceptedPhrases()
		return @aPhrases

	def PhraseCount()
		if NOT This.IsUsable()  return 0 ok
		return StzEngineListenPhraseCount(@nL)

	#-- LISTENING -----------------------------------------------------------

	# Hear a stzSound -- which is what makes this testable with no microphone,
	# and what lets a spoken phrase from stzVoice be fed straight back.
	def HearSound(poSound)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "there is no usable recognizer"
			return FALSE
		ok
		if NOT isObject(poSound)
			@nRefusals++
			@cLastError = "HearSound needs a stzSound"
			return FALSE
		ok
		_wav_ = poSound.ToWavBytes()
		if _wav_ = ""
			@nRefusals++
			@cLastError = "could not read that sound as WAV bytes"
			return FALSE
		ok
		return This._Result(StzEngineListenToWav(@nL, _wav_))

	# Hear the MICROPHONE. This is the consent boundary of the library: it
	# opens an input device and listens. Local only -- nothing leaves this
	# machine -- but a caller should still tell the operator it is listening,
	# because an open microphone the operator cannot see is indefensible
	# (Rule 82, visible state).
	def HearMicrophoneFor(pnSeconds)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "there is no usable recognizer"
			return FALSE
		ok
		return This._Result(StzEngineListenToMicrophone(@nL, pnSeconds * 1000))

	#-- what came back ------------------------------------------------------

	def HeardText()
		if NOT This.IsUsable()  return "" ok
		return StzEngineListenLastText(@nL)

	# A SEPARATE CALL, on purpose: a recognised string without its confidence
	# is a guess wearing a fact's clothes.
	def Confidence()
		if NOT This.IsUsable()  return 0 ok
		return StzEngineListenLastConfidence(@nL)

	def HeardSomething()
		return This.HeardText() != ""

	# A no-match is a RESULT, not an error: somebody said something that was
	# not in the grammar, and a control surface needs to know that happened.
	def WasNoMatch()
		return @nLastResult = 4

	#-- counters ------------------------------------------------------------

	def Recognitions()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineListenCounter(0 + 1)

	def NoMatches()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineListenCounter(2)

	#-- private -------------------------------------------------------------

	def _Result(pnRc)
		@nLastResult = pnRc
		if pnRc = 0  return TRUE ok
		if pnRc != 4                       # 4 = NO_MATCH, which is not a refusal
			@nRefusals++
			@cLastError = StzEngineListenLastError()
		ok
		return FALSE

	def _Has(paList, pcWhat)
		for _i_ = 1 to len(paList)
			if paList[_i_] = pcWhat  return TRUE ok
		next
		return FALSE

	def _PrimaryOf(pcTag)
		_d_ = substr(pcTag, "-")
		if _d_ > 0  return left(pcTag, _d_ - 1) ok
		return pcTag
