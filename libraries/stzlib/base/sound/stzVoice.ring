#---------------------------------------------------------------------------#
#  STZVOICE -- text in, a SOUND out. VC2 of SOFTANZA_VOICE_PLAN.md.          #
#---------------------------------------------------------------------------#
#
#     oV = StzVoiceQ()
#     oSay = oV.ToSoundOf("The disk is nearly full")   # -> a stzSound
#     oV.Say("The disk is nearly full")                # or just say it
#
#     oV.UseLanguage("fr-FR")                          # refused if absent
#     oV.Languages()                                   # what this machine has
#
# THE PRIMARY VERB IS ToSoundOf, AND Say IS THE CONVENIENCE. That ordering is
# the architecture rather than a preference: a voice renders to a BUFFER, and a
# buffer is a stzSound, so every verb this plane owns already applies to speech
# -- filter it, echo it, mix it under an earcon, measure its loudness, draw its
# spectrogram, play it through SN6's transport. `To...` returns DATA, per the
# house law, and that is exactly what makes the rest possible.
#
#     oSay = oV.ToSoundOf("sixty two gigabytes remain")
#     oSay.ResampleTo(48000)
#     ? oSay.LoudnessOfSupport()                    # SS2's instrument
#     oG.AddSound(oSay)                             # a source like any other
#
# NO NEW SINK, NO NEW CLOCK, NO NEW RING. Speaking plays through the sound
# plane's existing device path, because a voice is a sound.
#
# ── CAPABILITY IS PER LANGUAGE, AND IT IS ASKABLE BEFORE IT IS USED ────────
#
# The machine this was built on has voices for en-US and fr-FR, a recognizer for
# fr-FR ONLY, and OCR for ar-SA and fr-FR. Three capabilities, three different
# language sets. So `UseLanguage` REFUSES a language it does not have and counts
# the refusal -- it never falls back. Speaking French to an operator who asked
# for English is worse than saying nothing, and a face that substitutes silently
# will make an application lie to somebody.
#
# ── THE LATENCY, SAID HERE RATHER THAN IN A FOOTNOTE ───────────────────────
#
# VC2's kill criterion asked whether a warmed voice can start a short phrase
# inside the plane's own output latency. Measured, and the answer is not the
# interesting part:
#
#     synthesising "disk full"        ~3 ms   (warm)
#     the plane's output latency    ~419 ms   native Windows shared-mode WASAPI
#                                     ~10 ms   in a browser (SN6)
#
# **Synthesis is under one percent of the delay.** So speech is not slow because
# it is computed; it is late because the audio path is long, and that was true
# before a voice existed. The consequence is the one the sound plan's S.5
# already reached: THE SOUND IS NOT THE ACKNOWLEDGEMENT. The screen acknowledges
# inside Rule 18's hundred milliseconds; the earcon corroborates; the phrase
# explains. A caller who needs speech to feel immediate should be on the web
# tier, where the same declaration costs ten milliseconds instead of four
# hundred.
#
# WARM UP OUT OF BAND. VC0 measured a cold synthesis at 4.3x a warm one, the
# same trap SN0 found in ma_device_start. `WarmUp()` pays that cost when the
# program starts rather than in the middle of the first sentence.

func StzVoiceQ()
	return new stzVoice()

# A voice for one language, if the machine has it. Returns the object either
# way -- ask IsUsable() rather than testing for NULL.
func StzVoiceForQ(pcLanguageTag)
	_o_ = new stzVoice()
	_o_.UseLanguage(pcLanguageTag)
	return _o_

# Turns text into a sound buffer with the machine's speech engine, one language at a time, refusing rather than substituting.
#
# The primary verb is ToSoundOf: a voice renders to a buffer, and a buffer is a stzSound, so every
# verb of the sound plane then applies to speech. The sound carries the engine's own sample rate
# (22050 Hz here, not 48000), which is stored in a saved file too. UseLanguage tries an exact tag
# and then the same language with another region, and otherwise refuses and says which languages the
# machine has. Synthesis is under 1 percent of the output latency, so speech is late because the
# audio path is long, not because it is computed. Say and ToTransportOf open an audio device and
# were not run in this reference. The speech has not been heard by a person (UNPERCEIVED): it is
# checked by frame count, rate, duration and peak level.
#
#   receiver   o1 = StzVoiceQ()
#   example    ? o1.IsUsable()
#              #--> 1
#              ? o1.UseLanguage("de-DE")
#              #--> 0
#              ? o1.UseLanguage("en-US")
#              #--> 1
#              ? o1.ToSoundOf("The disk is nearly full").SampleRate()
#              #--> 22050
#   see        stzListener, stzSound, stzSoundTransport
class stzVoice

	@nV = 0
	@cLastError = ""
	@nRefusals = 0
	@bWarm = FALSE
	@nCurrent = 0            # 1-based index of the selected voice, 0 = platform default

	# Opens the machine's speech engine for a voice that renders text to sound buffers.
	#
	#   returns    nothing; the object is built
	#   note       no audio device is opened
	#   warning    a machine with no speech engine is a supported configuration: the object is then
	#              not usable and LastError says why
	#   see        StzVoiceQ, IsUsable
	def init()
		if NOT StzVoiceEngineLoaded()
			@cLastError = "stz_voice.dll is not loaded"
			return
		ok
		if StzEngineVoiceIsAvailable() = 0
			@cLastError = StzEngineVoiceLastError()
			return
		ok
		@nV = StzEngineVoiceOpen()
		if @nV = 0
			@cLastError = StzEngineVoiceLastError()
		ok

	# Frees the speech engine handle held by the voice.
	#
	#   returns    nothing
	#   warning    afterwards the voice is not usable and every render is refused
	#   see        IsUsable
	def Release()
		if @nV != 0
			StzEngineVoiceFree(@nV)
			@nV = 0
		ok

	# TRUE if the machine has a speech engine and the voice opened it.
	#
	#   returns    TRUE or FALSE
	#   warning    ask this first
	#   see        init, LastError
	#@ aka  -- can this machine speak at all? --------------------------------------
	def IsUsable()
		return @nV != 0

	# Returns the reason the last call failed, or the engine's last voice error when none was recorded here.
	#
	#   returns    a text
	#   warning    a render that succeeds does not clear it, so a stale message can outlive the
	#              failure that made it
	#   see        Refusals
	def LastError()
		if @cLastError != ""  return @cLastError ok
		if StzVoiceEngineLoaded()  return StzEngineVoiceLastError() ok
		return ""

	# Returns how many calls the voice refused.
	#
	#   returns    a number
	#   see        LastError
	def Refusals()
		return @nRefusals

	# Returns how many voices are installed on the machine.
	#
	#   returns    a number; 0 when the speech tier is missing
	#   see        VoiceNames, Languages
	#@ aka  -- what it can do, as DATA ---------------------------------------------
	def VoiceCount()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceInstalledCount()

	# Returns the names of the installed voices, in the order UseVoice counts them.
	#
	#   returns    a list of text
	#   see        VoiceCount, ToVoiceList
	def VoiceNames()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_a_ + StzEngineVoiceInstalledName(_i_)
		next
		return _a_

	# Returns the language tags the machine can speak, without repeats.
	#
	#   returns    a list of text such as en-US and fr-FR
	#   warning    this is what the machine can speak, which is not what it can hear
	#   see        HasLanguage, UseLanguage
	#@ aka  The BCP-47 tags this machine can SPEAK. Not what it can hear -- that is stzListener's question and on this machine the answer differs.
	def Languages()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_t_ = StzEngineVoiceInstalledLanguage(_i_)
			if _t_ != "" and NOT This._Has(_a_, _t_)
				_a_ + _t_
			ok
		next
		return _a_

	# Returns every installed voice with its language.
	#
	#   returns    a list of [ name, language tag ] rows
	#   see        VoiceNames, Languages
	#@ aka  The whole capability matrix for this direction: [ [name, tag], ... ]
	def ToVoiceList()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_a_ + [ StzEngineVoiceInstalledName(_i_),
			        StzEngineVoiceInstalledLanguage(_i_) ]
		next
		return _a_

	# TRUE if some installed voice speaks the language, an exact tag first and then the language alone.
	#
	#   pcTag      a language tag such as en-US, or a bare language such as fr
	#   returns    TRUE or FALSE
	#   warning    the bare language fr matches fr-FR
	#   see        UseLanguage, Languages
	def HasLanguage(pcTag)
		return This._FindLanguage(pcTag) > 0

	# Returns the name of the voice chosen with UseLanguage or UseVoice.
	#
	#   returns    a text; an empty text while the platform default is in use
	#   see        CurrentLanguage, UseVoice
	def CurrentVoiceName()
		if @nCurrent = 0  return "" ok
		return StzEngineVoiceInstalledName(@nCurrent)

	# Returns the language tag of the voice chosen with UseLanguage or UseVoice.
	#
	#   returns    a text; an empty text while the platform default is in use
	#   see        CurrentVoiceName
	def CurrentLanguage()
		if @nCurrent = 0  return "" ok
		return StzEngineVoiceInstalledLanguage(@nCurrent)

	# Chooses a voice that speaks a language, and refuses rather than substituting another language.
	#
	#   pcTag      a language tag such as en-US, or a bare language such as fr
	#   returns    TRUE if a voice was chosen; FALSE with LastError naming the languages the machine
	#              has
	#   note       with no usable voice it is refused as well
	#   warning    an exact tag is tried first, then the same language with another region; a
	#              different language is a counted refusal
	#   see        UseVoice, HasLanguage
	#@ aka  -- choosing ------------------------------------------------------------
	def UseLanguage(pcTag)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "UseLanguage: there is no usable voice on this machine"
			return FALSE
		ok
		_i_ = This._FindLanguage(pcTag)
		if _i_ = 0
			@nRefusals++
			@cLastError = "no voice speaks '" + pcTag + "' -- this machine has: " +
				This._Join(This.Languages())
			return FALSE
		ok
		return This.UseVoice(_i_)

	def UseLanguageQ(pcTag)
		This.UseLanguage(pcTag)
		return This

	# Chooses an installed voice by its position.
	#
	#   pnIndex    the voice's position in VoiceNames, counted from 1
	#   returns    TRUE if the voice was chosen; FALSE with LastError set when there is no such
	#              voice
	#   note       the error text for a bad position counts from 0, one less than the number given
	#   warning    choosing a voice makes the voice cold again, so WarmUp pays its start-up cost
	#   see        UseLanguage, VoiceNames
	def UseVoice(pnIndex)
		if NOT This.IsUsable()  return FALSE ok
		if StzEngineVoiceSelectVoice(@nV, pnIndex) != 0
			@nRefusals++
			@cLastError = StzEngineVoiceLastError()
			return FALSE
		ok
		@nCurrent = pnIndex
		@bWarm = FALSE          # a different voice has its own start-up cost
		@cLastError = ""
		return TRUE

	def UseVoiceQ(pnIndex)
		This.UseVoice(pnIndex)
		return This

	# Sets the speaking rate of later renders.
	#
	#   pnRate     the rate from -10 for slowest to 10 for fastest, 0 being normal
	#   returns    the voice itself, so calls chain
	#   note       measured: a rate of 5 shortened a 2.52 s phrase to 1.47 s
	#   warning    the engine clamps values outside the range; with no usable voice the call does
	#              nothing
	#   see        SetVolume
	#@ aka  -- prosody -------------------------------------------------------------
	def SetRate(pnRate)
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSetRate(@nV, pnRate)
		return This

	# Sets the speaking volume of later renders.
	#
	#   pnVolume   the volume from 0 to 100
	#   returns    the voice itself, so calls chain
	#   note       measured: a volume of 30 lowered the peak of a phrase from 0.49 to 0.07
	#   warning    the engine clamps values outside the range; with no usable voice the call does
	#              nothing
	#   see        SetRate
	def SetVolume(pnVolume)
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSetVolume(@nV, pnVolume)
		return This

	# Pays the start-up cost of the voice now by synthesising and discarding one syllable.
	#
	#   returns    the voice itself, so calls chain
	#   note       no audio device is opened
	#   warning    a cold synthesis costs about 4.3 times a warm one
	#   see        IsWarm, ToSoundOf
	#@ aka  -- WARMING UP ----------------------------------------------------------
	def WarmUp()
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSpeak(@nV, "a")
		@bWarm = TRUE
		return This

	# TRUE if the voice has rendered something since it was opened or since its voice was changed.
	#
	#   returns    TRUE or FALSE
	#   see        WarmUp
	def IsWarm()
		return @bWarm

	# Renders text to a sound in memory with the current voice, playing nothing.
	#
	#   pcText     the text to speak
	#   returns    a stzSound mono at the speech engine's rate, 22050 Hz on this machine; an empty
	#              text with LastError set on refusal
	#   note       the sound has not been heard by a person; the empty text is not refused and gives
	#              a sound
	#   warning    no audio device is opened; the rate is carried in the sound and in a saved file,
	#              and is not 48000, so resample before measuring loudness
	#   see        ToSoundOfSsml, SampleRate
	#@ aka  -- THE PRIMARY VERB: text in, DATA out ---------------------------------
	def ToSoundOf(pcText)
		return This._Render(pcText, FALSE)

	# Renders SSML markup to a sound in memory, after the engine has checked that the markup is well formed.
	#
	#   pcSsml     the SSML document, such as a speak element holding text and prosody elements
	#   returns    a stzSound as ToSoundOf gives; an empty text with LastError set on refusal
	#   note       no audio device is opened
	#   warning    markup with an unclosed tag is refused by the engine, since the platform would
	#              discard it silently and speak the words
	#   see        ToSoundOf
	#@ aka  The same, with SSML prosody. The engine validates the markup, because the platform does not: handed an unclosed tag SAPI silently discards it and speaks the words, so a typo means the prosody never happens and nobody is told.
	def ToSoundOfSsml(pcSsml)
		return This._Render(pcSsml, TRUE)

	# Speaks the text on the audio device and waits until it has ended.
	#
	#   pcText     the text to speak
	#   returns    the voice itself
	#   note       for a script that has nothing else to do
	#   warning    not run in this reference: it opens an audio device through the sound; a refused
	#              render makes it do nothing
	#   see        ToSoundOf, ToTransportOf
	#@ aka  -- the convenience -----------------------------------------------------
	def Say(pcText)
		_s_ = This.ToSoundOf(pcText)
		if NOT isObject(_s_)  return This ok
		_s_.Play()
		return This

	def SayQ(pcText)
		This.Say(pcText)
		return This

	# Speaks the text on the audio device without waiting and returns the transport that is playing it.
	#
	#   pcText     the text to speak
	#   returns    a stzSoundTransport already started; an empty text when the render is refused
	#   note       the transport stops by itself after the phrase's length, which Tick must see
	#   warning    not run in this reference: it opens an audio device through a transport
	#   see        Say, ToSoundOf
	#@ aka  Say it WITHOUT waiting, through SN6's transport -- so a program with a UI or a game loop keeps running while it speaks. The transport comes back started; ask it for the position, pause it, or stop it early.
	def ToTransportOf(pcText)
		_s_ = This.ToSoundOf(pcText)
		if NOT isObject(_s_)  return "" ok
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, _s_.SampleRate())
		_g_.AddSound(_s_)
		_t_ = new stzSoundTransport(_g_)
		_t_.PlayFor(_s_.Duration())
		return _t_

	# Returns the sample rate of the sounds the speech engine produces, in hertz.
	#
	#   returns    a number, 22050 on this machine; 0 without the speech tier
	#   warning    not 48000, so loudness measures need a resample first
	#   see        Channels, ToSoundOf
	#@ aka  -- what a caller must not assume --------------------------------------
	def SampleRate()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceSampleRate()

	# Returns the number of channels of the sounds the speech engine produces.
	#
	#   returns    a number, 1 on this machine; 0 without the speech tier
	#   see        SampleRate
	def Channels()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceChannelCount()

	# Answers whether computing the speech is what makes it late, which it is not.
	#
	#   returns    FALSE always
	#   warning    synthesis is under 1 percent of the output latency; the audio path is long
	#   see        WarmUp
	#@ aka  Synthesis is under one percent of the plane's output latency, so speech is not slow because it is computed -- it is late because the audio path is long. See the header, and the sound plan's S.5.
	def SynthesisIsTheBottleneck()
		return FALSE

	#-- private -------------------------------------------------------------

	def _Render(pcText, pbSsml)
		if NOT This.IsUsable()
			@nRefusals++
			@cLastError = "there is no usable voice on this machine"
			return ""
		ok
		_n_ = 0
		if pbSsml
			_n_ = StzEngineVoiceSpeakSsml(@nV, pcText)
		else
			_n_ = StzEngineVoiceSpeak(@nV, pcText)
		ok
		if _n_ = 0
			@nRefusals++
			@cLastError = StzEngineVoiceLastError()
			return ""
		ok
		@bWarm = TRUE
		# BYTES cross the DLL boundary, never a handle: the buffer table lives
		# in stz_sound.dll and a handle from one DLL means nothing in another.
		# A Ring string is length-delimited and byte-safe, so it is the carrier.
		_buf_ = StzEngineSoundLoadMemory(StzEngineVoiceLastBytes(@nV))
		if _buf_ = 0
			@nRefusals++
			@cLastError = "the sound tier could not decode the voice's bytes: " +
				StzEngineSoundLastError()
			return ""
		ok
		return StzSoundFromBufferQ(_buf_)

	# exact tag, then language-only within the SAME language
	def _FindLanguage(pcTag)
		_want_ = lower("" + pcTag)
		for _i_ = 1 to This.VoiceCount()
			if lower(StzEngineVoiceInstalledLanguage(_i_)) = _want_  return _i_ ok
		next
		# "fr" matching "fr-FR" is a widening inside one language, which is not
		# the substitution this face refuses
		for _i_ = 1 to This.VoiceCount()
			_have_ = lower(StzEngineVoiceInstalledLanguage(_i_))
			if _have_ != "" and This._PrimaryOf(_have_) = This._PrimaryOf(_want_)
				return _i_
			ok
		next
		return 0

	def _PrimaryOf(pcTag)
		_d_ = substr(pcTag, "-")
		if _d_ > 0  return left(pcTag, _d_ - 1) ok
		return pcTag

	def _Has(paList, pcWhat)
		for _i_ = 1 to len(paList)
			if paList[_i_] = pcWhat  return TRUE ok
		next
		return FALSE

	def _Join(paList)
		_c_ = ""
		for _i_ = 1 to len(paList)
			if _c_ != ""  _c_ += ", " ok
			_c_ += paList[_i_]
		next
		if _c_ = ""  return "(none)" ok
		return _c_
