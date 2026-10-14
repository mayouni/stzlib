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

# Recognises a sound against a closed list of accepted phrases, with a confidence, using the local speech recognizer.
#
# It does commands, not dictation, on purpose: free dictation measured 66.7 percent exact against
# 100 percent for a closed grammar, and every miss was a written form rather than a mishearing. A
# phrase outside the list is a no-match, which is a result and not an error. The text and its
# Confidence are separate calls so the confidence cannot be skipped. The recognizer runs in the
# process and reaches no network. Capability is per language and per direction: this machine hears
# only fr-FR. HearMicrophoneFor opens an input device, the library's consent boundary, and was not
# run in this reference. The examples feed the machine's own French voice to it; no person has been
# heard (UNPERCEIVED).
#
#   receiver   o1 = StzListenerQ()
#   example    ? o1.Accept([ "ouvrir le fichier", "enregistrer", "annuler" ])
#              #--> 1
#              ? o1.PhraseCount()
#              #--> 3
#              ? o1.HearSound(StzVoiceForQ("fr-FR").ToSoundOf("ouvrir le fichier"))
#              #--> 1
#              ? o1.HeardText()
#              #--> ouvrir le fichier
#   see        stzVoice, stzSound, stzSemanticResolver
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
	@aMeanings = []      # [ lower(phrase), meaning ] -- VC6, see AcceptMeanings

	# Opens the machine's local speech recognizer for a listener that hears only a closed list of phrases.
	#
	#   returns    nothing; the object is built
	#   note       no microphone is opened here
	#   warning    a machine with no recognizer leaves the object unusable and LastError says why;
	#              the recognizer runs in the process and reaches no network
	#   see        StzListenerQ, IsUsable
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

	# Frees the recognizer handle held by the listener.
	#
	#   returns    nothing
	#   warning    afterwards the listener is not usable and every call is refused
	#   see        IsUsable
	def Release()
		if @nL != 0
			StzEngineListenFree(@nL)
			@nL = 0
		ok

	# TRUE if the machine has a recognizer and the listener opened it.
	#
	#   returns    TRUE or FALSE
	#   see        init, LastError
	#@ aka  -- can this machine hear at all? ---------------------------------------
	def IsUsable()
		return @nL != 0

	# Returns the reason the last call failed, or the engine's last recognizer error when none was recorded here.
	#
	#   returns    a text
	#   warning    a successful call does not clear it, apart from Accept, which does
	#   see        Refusals
	def LastError()
		if @cLastError != ""  return @cLastError ok
		if StzVoiceEngineLoaded()  return StzEngineListenLastError() ok
		return ""

	# Returns how many calls the listener refused.
	#
	#   returns    a number, a no-match not being counted
	#   see        LastError, NoMatches
	def Refusals()
		return @nRefusals

	# Returns how many speech recognizers are installed.
	#
	#   returns    a number; 0 when the speech tier is missing
	#   see        Languages, ToRecognizerList
	#@ aka  -- what it can hear, as DATA -------------------------------------------
	def RecognizerCount()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineListenInstalledCount()

	# Returns the language tags the machine can hear, without repeats.
	#
	#   returns    a list of text; fr-FR alone on this machine, which speaks en-US and fr-FR
	#   warning    hearing and speaking differ, so ask stzVoice for what can be spoken
	#   see        HasLanguage, ToRecognizerList
	#@ aka  The BCP-47 tags this machine can HEAR. Compare with stzVoice's Languages(), which is what it can SPEAK -- on the machine this was built on the two lists differ, and an application that assumes otherwise will offer a control surface nobody can drive.
	def Languages()
		_a_ = []
		for _i_ = 1 to This.RecognizerCount()
			_t_ = StzEngineListenInstalledLanguage(_i_)
			if _t_ != "" and NOT This._Has(_a_, _t_)  _a_ + _t_ ok
		next
		return _a_

	# Returns every installed recognizer with its language.
	#
	#   returns    a list of [ name, language tag ] rows
	#   see        Languages, RecognizerCount
	def ToRecognizerList()
		_a_ = []
		for _i_ = 1 to This.RecognizerCount()
			_a_ + [ StzEngineListenInstalledName(_i_),
			        StzEngineListenInstalledLanguage(_i_) ]
		next
		return _a_

	# TRUE if some recognizer hears the language, an exact tag or the same language with another region.
	#
	#   pcTag      a language tag such as fr-FR, or a bare language such as fr
	#   returns    TRUE or FALSE
	#   warning    the bare language fr matches fr-FR
	#   see        Languages
	def HasLanguage(pcTag)
		_want_ = lower("" + pcTag)
		_aT7_ = This.Languages()
		_nT7_ = len(_aT7_)
		for _iT7_ = 1 to _nT7_
			_t_ = _aT7_[_iT7_]
			if lower(_t_) = _want_  return TRUE ok
			if This._PrimaryOf(lower(_t_)) = This._PrimaryOf(_want_)  return TRUE ok
		next
		return FALSE

	# Declares the closed list of phrases the listener may hear; anything else will be a no-match.
	#
	#   paPhrases   the list of phrases that count as commands
	#   returns     TRUE if the grammar was set; FALSE with LastError set
	#   note        there is no free dictation by design: the measured free dictation reached 66.7
	#               percent exact against 100 percent for a closed list
	#   warning     blank phrases are skipped; an empty list, or a listener that is not usable, is
	#               refused and counted
	#   see         AcceptMeanings, HearSound
	#@ aka  -- THE GRAMMAR: what it is allowed to hear -----------------------------
	def Accept(paPhrases)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "Accept: there is no usable recognizer on this machine"
			return FALSE
		ok
		_c_ = ""
		_n_ = 0
		_aP8_ = paPhrases
		_nP8_ = len(_aP8_)
		for _iP8_ = 1 to _nP8_
			_p_ = _aP8_[_iP8_]
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

	# Returns the phrases last accepted, as they were given.
	#
	#   returns    a list of text; [ ] before Accept
	#   see        Accept, PhraseCount
	def AcceptedPhrases()
		return @aPhrases

	# Declares the phrases and the meaning each one carries in a single call.
	#
	#   paPairs    a list of [ phrase, meaning ] rows, each meaning one of danger, warning, info,
	#              success or muted
	#   returns    TRUE if the grammar was set; FALSE with LastError set
	#   note       the author declares each meaning; nothing is inferred from the words
	#   warning    an empty list, a row that is not a pair or a sixth meaning is refused at once,
	#              with LastError set and the refusal counted
	#   see        MeaningHeard, Accept
	#@ aka  -- VC6: the step that closes the loop -----------------------------------
	def AcceptMeanings(paPairs)
		if NOT isList(paPairs) or len(paPairs) = 0
			@nRefusals++
			@cLastError = "AcceptMeanings: give [ [phrase, meaning], ... ]"
			return FALSE
		ok
		_ph_ = []
		_mp_ = []
		for _i_ = 1 to len(paPairs)
			_row_ = paPairs[_i_]
			if NOT isList(_row_) or len(_row_) < 2
				@nRefusals++
				@cLastError = "AcceptMeanings: row " + _i_ + " is not [phrase, meaning]"
				return FALSE
			ok
			_p_ = trim("" + _row_[1])
			_m_ = lower(trim("" + _row_[2]))
			if _p_ = ""  loop ok
			# REFUSE AN UNKNOWN MEANING HERE, not when it is spoken. Rule 118
			# legislates five values; a grammar that maps a phrase to a sixth
			# would fail silently at the far end of the loop, where the cause
			# is hardest to see.
			if ring_find(StzSemanticValues(), _m_) = 0
				@nRefusals++
				@cLastError = "AcceptMeanings: '" + _row_[2] + "' is not one of the " +
				              "five semantic values: " + This._Joined(StzSemanticValues())
				return FALSE
			ok
			_ph_ + _p_
			_mp_ + [ lower(_p_), _m_ ]
		next
		if NOT This.Accept(_ph_)  return FALSE ok
		@aMeanings = _mp_
		return TRUE

	def AcceptMeaningsQ(paPairs)
		This.AcceptMeanings(paPairs)
		return This

	# Returns the meaning declared for the phrase just heard.
	#
	#   returns    a text such as success or danger; an empty text for a no-match, which is a result
	#              and not an error
	#   warning    the phrase is matched without regard to case
	#   see        AcceptMeanings, HeardText
	#@ aka  The meaning of what was just heard, or "" -- and "" is a RESULT, not a failure. A no-match means somebody said something that is not a command, which is information a control surface needs; the dangerous alternative is a confident wrong meaning.
	def MeaningHeard()
		_t_ = lower(trim(This.HeardText()))
		if _t_ = ""  return "" ok
		for _i_ = 1 to len(@aMeanings)
			if @aMeanings[_i_][1] = _t_  return @aMeanings[_i_][2] ok
		next
		return ""

	# Returns the phrase and meaning pairs last declared.
	#
	#   returns    a list of [ phrase in lower case, meaning in lower case ] rows; [ ] before
	#              AcceptMeanings
	#   see        AcceptMeanings
	def AcceptedMeanings()
		return @aMeanings

	def _Joined(paList)
		_s_ = ""
		for _i_ = 1 to len(paList)
			if _i_ > 1  _s_ += ", " ok
			_s_ += "" + paList[_i_]
		next
		return _s_

	# Returns how many phrases the grammar holds.
	#
	#   returns    a number; 0 before Accept or when the listener is not usable
	#   see        Accept, AcceptedPhrases
	def PhraseCount()
		if NOT This.IsUsable()  return 0 ok
		return StzEngineListenPhraseCount(@nL)

	# Recognises a sound against the accepted phrases, which needs no microphone.
	#
	#   poSound    the stzSound to listen to, such as one made by stzVoice
	#   returns    TRUE if a phrase was recognised; FALSE for a no-match or a refusal
	#   note       the recognizer ran on a phrase spoken by the machine's own voice, not on a person
	#   warning    a non-sound, an unusable listener and a sound with no WAV bytes are refused and
	#              counted; a no-match is not
	#   see        HeardText, HearMicrophoneFor
	#@ aka  -- LISTENING -----------------------------------------------------------
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

	# Opens the microphone for a number of seconds and recognises what is said against the accepted phrases.
	#
	#   pnSeconds   how long to listen, in seconds
	#   returns     TRUE if a phrase was recognised; FALSE for a no-match or a refusal
	#   note        the operator should be told that the microphone is open; nothing leaves the
	#               machine
	#   warning     not run in this reference: it opens an input device, which is this library's
	#               consent boundary
	#   see         HearSound, Confidence
	#@ aka  Hear the MICROPHONE. This is the consent boundary of the library: it opens an input device and listens. Local only -- nothing leaves this machine -- but a caller should still tell the operator it is listening, because an open microphone the operator cannot see is indefensible (Rule 82, visible state).
	def HearMicrophoneFor(pnSeconds)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "there is no usable recognizer"
			return FALSE
		ok
		return This._Result(StzEngineListenToMicrophone(@nL, pnSeconds * 1000))

	# Returns the text of the last recognised phrase.
	#
	#   returns    a text; an empty text for a no-match and for a listener that is not usable
	#   warning    it is one of the accepted phrases, as declared
	#   see        Confidence, HeardSomething
	#@ aka  -- what came back ------------------------------------------------------
	def HeardText()
		if NOT This.IsUsable()  return "" ok
		return StzEngineListenLastText(@nL)

	# Returns how sure the recognizer was of the last phrase, from 0 to 1.
	#
	#   returns    a number; 0 for a no-match
	#   warning    always read it with the text, since a phrase without its confidence is a guess
	#              dressed as a fact
	#   see        HeardText
	#@ aka  A SEPARATE CALL, on purpose: a recognised string without its confidence is a guess wearing a fact's clothes.
	def Confidence()
		if NOT This.IsUsable()  return 0 ok
		return StzEngineListenLastConfidence(@nL)

	# TRUE if the last hearing recognised a phrase.
	#
	#   returns    TRUE or FALSE
	#   see        HeardText, WasNoMatch
	def HeardSomething()
		return This.HeardText() != ""

	# TRUE if the last hearing found nothing in the grammar, which is a result and not an error.
	#
	#   returns    TRUE or FALSE; FALSE before any hearing
	#   see        HeardSomething, NoMatches
	#@ aka  A no-match is a RESULT, not an error: somebody said something that was not in the grammar, and a control surface needs to know that happened.
	def WasNoMatch()
		return @nLastResult = 4

	# Returns how many phrases the engine has recognised since it was loaded.
	#
	#   returns    a number
	#   warning    it is an engine-wide counter, shared by every listener of the process
	#   see        NoMatches
	#@ aka  -- counters ------------------------------------------------------------
	def Recognitions()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineListenCounter(0 + 1)

	# Returns how many hearings found nothing in the grammar since the engine was loaded.
	#
	#   returns    a number
	#   warning    it is an engine-wide counter, shared by every listener of the process
	#   see        Recognitions, WasNoMatch
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
