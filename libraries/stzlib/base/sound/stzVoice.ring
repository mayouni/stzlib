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

class stzVoice

	@nV = 0
	@cLastError = ""
	@nRefusals = 0
	@bWarm = FALSE
	@nCurrent = 0            # 1-based index of the selected voice, 0 = platform default

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

	def Release()
		if @nV != 0
			StzEngineVoiceFree(@nV)
			@nV = 0
		ok

	#-- can this machine speak at all? --------------------------------------

	# ASK THIS FIRST. A machine with no speech engine is a supported
	# configuration, not a broken install, and every other path still works.
	def IsUsable()
		return @nV != 0

	def LastError()
		if @cLastError != ""  return @cLastError ok
		if StzVoiceEngineLoaded()  return StzEngineVoiceLastError() ok
		return ""

	def Refusals()
		return @nRefusals

	#-- what it can do, as DATA ---------------------------------------------

	def VoiceCount()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceInstalledCount()

	def VoiceNames()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_a_ + StzEngineVoiceInstalledName(_i_)
		next
		return _a_

	# The BCP-47 tags this machine can SPEAK. Not what it can hear -- that is
	# stzListener's question and on this machine the answer differs.
	def Languages()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_t_ = StzEngineVoiceInstalledLanguage(_i_)
			if _t_ != "" and NOT This._Has(_a_, _t_)
				_a_ + _t_
			ok
		next
		return _a_

	# The whole capability matrix for this direction: [ [name, tag], ... ]
	def ToVoiceList()
		_a_ = []
		for _i_ = 1 to This.VoiceCount()
			_a_ + [ StzEngineVoiceInstalledName(_i_),
			        StzEngineVoiceInstalledLanguage(_i_) ]
		next
		return _a_

	def HasLanguage(pcTag)
		return This._FindLanguage(pcTag) > 0

	def CurrentVoiceName()
		if @nCurrent = 0  return "" ok
		return StzEngineVoiceInstalledName(@nCurrent)

	def CurrentLanguage()
		if @nCurrent = 0  return "" ok
		return StzEngineVoiceInstalledLanguage(@nCurrent)

	#-- choosing ------------------------------------------------------------

	# REFUSES rather than substitutes. An exact tag match is tried first, then a
	# language-only match ("fr" finds "fr-FR") -- which is a WIDENING within one
	# language, not a substitution across two. Anything else is a counted
	# refusal, and the reason names what the machine actually has.
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

	#-- prosody -------------------------------------------------------------
	#
	# SAPI takes rate -10..10 and volume 0..100 and IGNORES anything else. The
	# engine clamps and reports, because a setting that silently does nothing is
	# worse than one that is visibly limited.

	def SetRate(pnRate)
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSetRate(@nV, pnRate)
		return This

	def SetVolume(pnVolume)
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSetVolume(@nV, pnVolume)
		return This

	#-- WARMING UP ----------------------------------------------------------

	# Pay the cold cost NOW, not in the middle of the first sentence. VC0
	# measured a cold synthesis at 4.3x a warm one -- the same trap SN0 found in
	# ma_device_start, where start-up took 500 ms and callbacks ran ahead of real
	# time during it. One inaudible syllable, discarded.
	def WarmUp()
		if NOT This.IsUsable()  return This ok
		StzEngineVoiceSpeak(@nV, "a")
		@bWarm = TRUE
		return This

	def IsWarm()
		return @bWarm

	#-- THE PRIMARY VERB: text in, DATA out ---------------------------------

	# A stzSound, or "" on refusal. Needs no audio device at all: the whole
	# point is that a voice becomes a buffer, and a buffer needs no speaker.
	def ToSoundOf(pcText)
		return This._Render(pcText, FALSE)

	# The same, with SSML prosody. The engine validates the markup, because the
	# platform does not: handed an unclosed tag SAPI silently discards it and
	# speaks the words, so a typo means the prosody never happens and nobody is
	# told.
	def ToSoundOfSsml(pcSsml)
		return This._Render(pcSsml, TRUE)

	#-- the convenience -----------------------------------------------------

	# Say it, and wait. The simple case in one line, for a script.
	def Say(pcText)
		_s_ = This.ToSoundOf(pcText)
		if NOT isObject(_s_)  return This ok
		_s_.Play()
		return This

	def SayQ(pcText)
		This.Say(pcText)
		return This

	# Say it WITHOUT waiting, through SN6's transport -- so a program with a UI
	# or a game loop keeps running while it speaks. The transport comes back
	# started; ask it for the position, pause it, or stop it early.
	#
	# IT STOPS BY ITSELF, and the first version did not. `Play()` means "play
	# until stopped", so a caller writing the obvious loop --
	#
	#     while oT.IsPlaying()   oT.Tick()   end
	#
	# -- never left it: the phrase ended, the transport kept rendering silence,
	# and IsPlaying stayed true forever. A spoken phrase has a KNOWN length, so
	# the transport is given it. The trap was real enough to hang this face's
	# own demo before it was found.
	def ToTransportOf(pcText)
		_s_ = This.ToSoundOf(pcText)
		if NOT isObject(_s_)  return "" ok
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, _s_.SampleRate())
		_g_.AddSound(_s_)
		_t_ = new stzSoundTransport(_g_)
		_t_.PlayFor(_s_.Duration())
		return _t_

	#-- what a caller must not assume --------------------------------------

	# The format the platform produces. NOT 48 kHz, so anything that measures
	# loudness must resample first -- BS.1770 refuses another rate rather than
	# returning a plausible number.
	def SampleRate()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceSampleRate()

	def Channels()
		if NOT StzVoiceEngineLoaded()  return 0 ok
		return StzEngineVoiceChannelCount()

	# Synthesis is under one percent of the plane's output latency, so speech is
	# not slow because it is computed -- it is late because the audio path is
	# long. See the header, and the sound plan's S.5.
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
