#---------------------------------------------------------------------------#
#  STZEARCONS -- an author writes a MEANING and gets a sound.                #
#  The semantic layer. See SOFTANZA_SOUND_PLAN.md, section SOUND SEMANTICS.  #
#---------------------------------------------------------------------------#
#
#     oEar = StzEarconsQ()
#     oEar.Start()
#     oEar.Fire(:Success)                 # one word, like oC.FillQ(:Danger)
#     oEar.Fire("Danger.Alert")           # the role step, spelled as colour spells it
#
#     oEar.ToSoundOf(:Warning)            # DATA -- needs no audio device at all
#     oEar.AudibilityMarginOf(:Danger)    # dB over the DECLARED ambient floor
#
# THE VOCABULARY IS NOT THIS PLANE'S TO CHOOSE. StzZui's constitution, Rule 118,
# legislates exactly five semantic values -- success, warning, danger, info,
# muted -- and one vocabulary across two channels is the whole argument for a
# semantic layer: declare the meaning once, and every channel renders it. A
# sixth value here would be a constitutional amendment wearing a library's
# clothes.
#
# :MUTED RENDERS AS SILENCE, and that is a rendering, not a gap. Muted means
# waiting or inactive; a sound announcing inactivity is a contradiction, and
# silence already carries it exactly. Four of the five sound. This is also why
# there is no pressure for a sixth.
#
# NOTHING HERE TOUCHES THE REAL-TIME PATH. No node type, no sink, no callback,
# no buffer, no timing. Motifs are rendered offline into ordinary sample
# buffers, and delivery is a stzVoicePool -- which is to say, verbs that
# already existed.
#
# WHAT A MOTIF IS. Contour, interval, duration, timbre. Which of those four
# actually carries identity is NOT settled -- the plan's S.2 records a
# measurement that tried and was confounded -- so the motifs below are a
# starting set with a kill criterion (SS1), not a claim.
#
# THREE LAWS THIS FACE OBEYS, and they are not colour's:
#   1. Sound reports, it never decorates. Rule 112's auditory form, and the
#      stronger one: there is no eyelid for the ear.
#   2. Silence is the default and must remain sufficient. A semantic sound is
#      always REDUNDANT with another channel, never the sole carrier of a
#      state -- the accessibility law and the practicality law in one sentence.
#   3. A sound is not persistent. Anything the operator has a right to know
#      must stay re-requestable somewhere that is not a sound.
#
# AND ONE MEASURED WARNING. On this pipeline a sound arrives roughly 419 ms
# after Fire() -- 329 ms of ring plus ~90 ms of device and OS. Rule 18 allows
# 100. TriggerToEarMs() reports it rather than letting a caller assume, and
# plan section S.5 says plainly what it means: the sound is not the
# acknowledgement. The screen is. The sound corroborates.

func StzEarconsQ()
	return new stzEarcons()

# The five, in the law's own order of severity. muted is last and silent.
func StzSemanticValues()
	return [ "danger", "warning", "info", "success", "muted" ]

class stzEarcons

	@nRate = 48000
	@aMotifs = []        # [ value, oSound or NULL for muted ]
	@oPool = NULL
	@bStarted = FALSE
	@cLastError = ""
	@cLastReason = ""
	@nRefusals = 0

	# priority, and the state the contract is decided against.
	# DECLARED HERE, ABOVE THE FIRST def: Ring only registers attributes
	# written before the first method, so an @attribute declared among the
	# private helpers at the bottom reads as uninitialised at runtime.
	@nAlertUntil = 0
	@nAlertPriority = 0
	@aLastFiredAt = []   # [ value, seconds ]
	@aDrops = []         # [ value, count ]
	@nRefractory = 0.150

	# The ambient floor is DECLARED, never silently measured. A microphone
	# could measure it and this plane ships one -- but measuring a room is a
	# privacy act needing consent, it is absent on a machine with no input, and
	# CI has neither. -40 LUFS is a quiet office, stated so a caller can
	# disagree with a number rather than with a vibe.
	@nFloorDb = -40

	# ── VC4: THE SEMANTIC BRIDGE ────────────────────────────────────────────
	#
	# A meaning already renders to a colour (the colour plane) and an earcon
	# (above). Add a PHRASE and the three channels answer three different
	# questions from one declaration:
	#
	#     the screen   acknowledges   (inside Rule 18's 100 ms)
	#     the earcon   corroborates   (fast, ~200 ms, "something happened")
	#     the phrase   explains       (slow, seconds, "WHICH thing happened")
	#
	# THE EARCON ALWAYS PRECEDES THE PHRASE. The earcon is the alerting signal
	# and it is already synthesised; the phrase is the content and it is slow.
	# Inverting them spends the only fast channel on a slow message.
	#
	# SPEECH QUEUES WHERE AN EARCON DROPS. A displaced cue is dropped, because a
	# cue arriving after its event lies about when it happened. A displaced
	# PHRASE is queued, because dropping it loses the only statement of WHAT
	# occurred while delaying it merely makes it late. The queue is BOUNDED and
	# its overflow is counted -- an unbounded queue of speech is a program that
	# talks for a minute about something that took a second.
	#
	# HIGHER PRIORITY CANCELS, IT NEVER INTERLEAVES. A danger phrase stops a
	# success phrase. Two half-sentences are worse than one sentence and a
	# counted drop, and a listener cannot un-hear the first half.
	@oVoice = NULL
	@cVoiceLang = ""
	@aQueue = []          # [ value, phrase, oSound, priority ]
	@nQueueMax = 4
	@oSpeaking = NULL     # the transport currently speaking, or NULL
	@nSpeakingPriority = 0
	@nSpeechDrops = 0
	@nSpeechSpoken = 0
	@nGapSeconds = 0.12   # between the earcon and the phrase

	def init()
		This._BuildMotifs()
		for _v_ in StzSemanticValues()
			@aLastFiredAt + [ _v_, -999 ]
			@aDrops + [ _v_, 0 ]
		next

	#-- what a meaning sounds like (no device needed) -----------------------

	# The motif as DATA. Works with no audio hardware, which is what lets a CI
	# machine assert the vocabulary.
	def ToSoundOf(pMeaning)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""  return "" ok
		if _p_[1] = "muted"  return "" ok
		for _i_ = 1 to len(@aMotifs)
			if @aMotifs[_i_][1] = _p_[1]  return @aMotifs[_i_][2] ok
		next
		return ""

	# Muted is the one value whose rendering is nothing. Asking is legitimate.
	def IsSilentValue(pMeaning)
		return This._Parse(pMeaning)[1] = "muted"

	def ToStepOf(pMeaning)
		return This._Parse(pMeaning)[2]

	def PriorityOf(pMeaning)
		switch This._Parse(pMeaning)[1]
		on "danger"    return 4
		on "warning"   return 3
		on "info"      return 2
		on "success"   return 1
		off
		return 0

	#-- THE AUDIBILITY FLOOR ------------------------------------------------
	#
	# Colour's doctrine, transposed: a sound system that cannot fail an
	# audibility check does not have one. The check is a MARGIN over the floor.

	def SetAmbientFloor(pnDb)
		@nFloorDb = pnDb
		return This

	def DeclaredFloor()
		return @nFloorDb

	# WHAT THE MARGIN IS MEASURED WITH, said out loud every time it is asked.
	#
	# SS2 CLOSED THIS. The first version had to use unweighted RMS, because
	# SN5's Loudness() integrates over 400 ms blocks behind a -70 LUFS gate and
	# an 880 Hz tone at PEAK 0.50 reports -1000 -- silence -- at every duration
	# below 400 ms. An earcon is shorter than one block, so the standard cannot
	# see it.
	#
	# The margin now uses LoudnessOfSupport: the SAME K-weighting and the same
	# -0.691 + 10log10(z) formula, over the sound's own length. It is not a
	# standard LUFS figure and the metric name says so -- but it is the ear's
	# own weighting rather than a flat average, which is the difference between
	# a gate that models hearing and one that models arithmetic.
	def MarginMetric()
		_s_ = This.ToSoundOf(:Danger)
		if isObject(_s_)  return _s_.LoudnessMetric() ok
		return "K-weighted level over the sound's support"

	def LevelOf(pMeaning)
		_s_ = This.ToSoundOf(pMeaning)
		if NOT isObject(_s_)  return -1000 ok
		return _s_.LoudnessOfSupport()

	def AudibilityMarginOf(pMeaning)
		_l_ = This.LevelOf(pMeaning)
		if _l_ <= -999  return -1000 ok
		return _l_ - @nFloorDb

	# The gate. A cue needs 10 LU of headroom over the room; an alert needs 20.
	def RequiredMarginOf(pMeaning)
		if This._Parse(pMeaning)[2] = "alert"  return 20 ok
		return 10

	def IsAudible(pMeaning)
		if This.IsSilentValue(pMeaning)  return TRUE ok    # silence is lawful
		return This.AudibilityMarginOf(pMeaning) >= This.RequiredMarginOf(pMeaning)

	#-- THE PRIORITY CONTRACT -----------------------------------------------
	#
	# :OverDanger is REFUSED as a colour-style pair, and plan S.3 argues why:
	# two sounds in one instant do not layer, they MASK, and masking is
	# frequency-selective and asymmetric -- so there is no fixed answer to
	# "what can be heard over danger". The answer is nothing. You drop, or you
	# duck. Ducking needs a per-bus gain node and is SS3, not this session.
	#
	# THE DECISION IS A PURE FUNCTION of (state, meaning, now), so a guard can
	# assert the contract on a machine with no audio device at all. Fire()
	# calls exactly this, with the transport's clock.

	def WouldFireAt(pMeaning, pnNow)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@cLastReason = "no semantic value named '" + pMeaning + "'"
			return FALSE
		ok
		# .Ambient never arrives by default. Rule 1's own lint forbids this
		# shape -- autoplay is attention taken uninvited -- so a continuous
		# bed must be asked for by something other than Fire().
		if _p_[2] = "ambient"
			@cLastReason = "ambient is opt-in and never fired"
			return FALSE
		ok
		if _p_[1] = "muted"
			@cLastReason = "muted renders as silence"
			return FALSE
		ok
		# the same state twice in a tenth of a second is one state
		if pnNow - This._LastFiredAt(_p_[1]) < @nRefractory
			@cLastReason = "refractory: the same value inside " +
				(@nRefractory * 1000) + " ms is one event"
			return FALSE
		ok
		# an alert that can be talked over is not an alert
		if pnNow < @nAlertUntil and This.PriorityOf(_p_[1]) < @nAlertPriority
			@cLastReason = "pre-empted by a louder meaning still sounding"
			return FALSE
		ok
		@cLastReason = "ok"
		return TRUE

	# The state advance, separated from the decision so both the real path and
	# a device-less guard drive the same code.
	def RecordFireAt(pMeaning, pnNow)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""  return This ok
		for _i_ = 1 to len(@aLastFiredAt)
			if @aLastFiredAt[_i_][1] = _p_[1]  @aLastFiredAt[_i_][2] = pnNow ok
		next
		if _p_[2] = "alert"
			_s_ = This.ToSoundOf(pMeaning)
			_d_ = 0.3
			if isObject(_s_)  _d_ = _s_.Duration() * 3 ok    # an alert repeats
			@nAlertUntil = pnNow + _d_
			@nAlertPriority = This.PriorityOf(_p_[1])
		ok
		return This

	def CountDropAt(pMeaning)
		_v_ = This._Parse(pMeaning)[1]
		for _i_ = 1 to len(@aDrops)
			if @aDrops[_i_][1] = _v_  @aDrops[_i_][2]++ ok
		next
		return This

	def DropsOf(pMeaning)
		_v_ = This._Parse(pMeaning)[1]
		for _i_ = 1 to len(@aDrops)
			if @aDrops[_i_][1] = _v_  return @aDrops[_i_][2] ok
		next
		return 0

	def LastReason()
		return @cLastReason

	def SetRefractory(pnSeconds)
		@nRefractory = pnSeconds
		return This

	#-- hearing it ----------------------------------------------------------

	def Start()
		if @bStarted  return This ok
		@oPool = new stzVoicePool(@nRate)
		for _i_ = 1 to len(@aMotifs)
			if isObject(@aMotifs[_i_][2])
				@oPool.AddVoice(@aMotifs[_i_][1], @aMotifs[_i_][2], 2)
			ok
		next
		@oPool.Start()
		if NOT @oPool.IsStarted()
			@cLastError = @oPool.LastError()
			return This
		ok
		@bStarted = TRUE
		@cLastError = ""
		return This

	def StartQ()
		This.Start()
		return This

	def Fire(pMeaning)
		if NOT @bStarted
			@cLastError = "Fire: call Start() first"
			@nRefusals++
			return This
		ok
		_now_ = @oPool.PositionInSeconds()
		if NOT This.WouldFireAt(pMeaning, _now_)
			This.CountDropAt(pMeaning)
			return This
		ok
		@oPool.Fire(This._Parse(pMeaning)[1])
		This.RecordFireAt(pMeaning, _now_)
		return This

	def FireQ(pMeaning)
		This.Fire(pMeaning)
		return This

	#-- VC4: SAY -- the earcon, then the phrase that says WHICH -------------

	# Which language the phrase is spoken in. REFUSED rather than substituted
	# if the machine has no voice for it -- speaking French to an operator who
	# asked for English is worse than saying nothing.
	def SetVoiceLanguage(pcTag)
		This._EnsureVoice()
		if NOT isObject(@oVoice)
			@nRefusals++
			@cLastError = "no voice on this machine to speak with"
			return FALSE
		ok
		if NOT @oVoice.UseLanguage(pcTag)
			@nRefusals++
			@cLastError = @oVoice.LastError()
			return FALSE
		ok
		@cVoiceLang = pcTag
		return TRUE

	# Which language it is actually speaking -- empty until one is set and
	# ACCEPTED, so a caller can tell "not asked yet" from "asked and refused".
	def VoiceLanguage()
		return @cVoiceLang

	def CanSpeak()
		This._EnsureVoice()
		return isObject(@oVoice) and @oVoice.IsUsable()

	# THE COMPOSITE, as DATA: earcon, a gap, then the phrase, in ONE buffer.
	#
	# One buffer rather than two players is what answers VC4's kill criterion.
	# Two independent players sharing a speaker can mask each other (the phrase
	# starting under the earcon's tail) and can clip where they overlap. Laid
	# out in one buffer they are SEQUENTIAL by construction: nothing overlaps,
	# so nothing masks, and the peak is the louder of the two rather than their
	# sum.
	#
	# Needs no audio device, which is what lets a guard measure the composition
	# on a machine that cannot play it.
	def ToSoundOfSaying(pMeaning, pcPhrase)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@nRefusals++
			@cLastError = "no semantic value named '" + pMeaning + "'"
			return ""
		ok
		This._EnsureVoice()
		_say_ = ""
		if isObject(@oVoice) and @oVoice.IsUsable() and pcPhrase != ""
			_say_ = @oVoice.ToSoundOf(pcPhrase)
		ok
		_ear_ = This.ToSoundOf(pMeaning)      # "" for :Muted -- silence is its rendering

		if NOT isObject(_ear_) and NOT isObject(_say_)  return "" ok
		if NOT isObject(_say_)  return _ear_ ok

		# the phrase's rate wins: it is the longer signal, and resampling a
		# 200 ms earcon costs less than resampling a sentence
		_rate_ = _say_.SampleRate()
		_earSecs_ = 0
		if isObject(_ear_)
			if _ear_.SampleRate() != _rate_
				_ear_ = This._Resampled(_ear_, _rate_)
			ok
			_earSecs_ = _ear_.Duration()
		ok
		_total_ = _earSecs_ + @nGapSeconds + _say_.Duration()
		_out_ = StzSoundOfSilenceQ(_total_ + 0.05, 1, _rate_)

		_at_ = 0
		if isObject(_ear_)
			This._Blit(_out_, _ear_, 0)
			_at_ = floor((_earSecs_ + @nGapSeconds) * _rate_)
		ok
		This._Blit(_out_, _say_, _at_)
		return _out_

	# Say it: the earcon, then the phrase. Queued, not played immediately --
	# call TickSpeech() (or SpeakQueueToEnd()) to advance.
	def Say(pMeaning, pcPhrase)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@nRefusals++
			@cLastError = "no semantic value named '" + pMeaning + "'"
			return This
		ok
		# :Muted has no earcon and no phrase. Silence is its rendering, and
		# that holds for speech exactly as it holds for a cue.
		if _p_[1] = "muted"
			@cLastReason = "muted renders as silence, in every channel"
			return This
		ok
		_pri_ = This.PriorityOf(pMeaning)

		# HIGHER PRIORITY CANCELS WHAT IS BEING SPOKEN, because two half
		# sentences are worse than one sentence and a counted drop -- and a
		# listener cannot un-hear the first half.
		if _pri_ > @nSpeakingPriority and isObject(@oSpeaking)
			@oSpeaking.Stop()
			@oSpeaking.Release()
			@oSpeaking = NULL
			@nSpeakingPriority = 0
			@nSpeechDrops++          # the cancelled sentence IS a drop
		ok

		if len(@aQueue) >= @nQueueMax
			# BOUNDED, and the overflow is counted. An unbounded queue of
			# speech is a program that talks for a minute about something
			# that took a second.
			@nSpeechDrops++
			@cLastReason = "the speech queue is full (" + @nQueueMax + ")"
			return This
		ok

		# INSERTED BY PRIORITY, NOT APPENDED -- and NOT clearing what is
		# already waiting. The first cut cleared every queued phrase quieter
		# than the new one, which contradicts the contract this bridge was
		# built to honour: an earcon DROPS when displaced, a phrase QUEUES,
		# because dropping a phrase loses the only statement of what happened
		# while delaying it merely makes it late. Danger jumps the queue; the
		# success behind it is still spoken afterwards.
		_ins_ = len(@aQueue) + 1
		for _i_ = 1 to len(@aQueue)
			if @aQueue[_i_][4] < _pri_
				_ins_ = _i_
				exit
			ok
		next
		_new_ = []
		for _i_ = 1 to _ins_ - 1
			_new_ + @aQueue[_i_]
		next
		_new_ + [ _p_[1], pcPhrase, "", _pri_ ]
		for _i_ = _ins_ to len(@aQueue)
			_new_ + @aQueue[_i_]
		next
		@aQueue = _new_
		return This

	def SayQ(pMeaning, pcPhrase)
		This.Say(pMeaning, pcPhrase)
		return This

	# One step. Starts the next phrase when nothing is speaking, and reaps the
	# transport when it ends. Cheap; call it as often as you like.
	def TickSpeech()
		if isObject(@oSpeaking)
			@oSpeaking.Tick()
			if @oSpeaking.IsStopped()
				@oSpeaking.Release()
				@oSpeaking = NULL
				@nSpeakingPriority = 0
			else
				return This
			ok
		ok
		if len(@aQueue) = 0  return This ok
		_head_ = @aQueue[1]
		_rest_ = []
		for _i_ = 2 to len(@aQueue)
			_rest_ + @aQueue[_i_]
		next
		@aQueue = _rest_

		_s_ = This.ToSoundOfSaying(_head_[1], _head_[2])
		if NOT isObject(_s_)  return This ok
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, _s_.SampleRate())
		_g_.AddSound(_s_)
		@oSpeaking = new stzSoundTransport(_g_)
		@oSpeaking.PlayFor(_s_.Duration())
		@nSpeakingPriority = _head_[4]
		@nSpeechSpoken++
		return This

	# Drive the queue to the end. Occupies the thread, which is honest for a
	# script; a program with a UI ticks instead.
	def SpeakQueueToEnd()
		_guard_ = 0
		while (len(@aQueue) > 0 or isObject(@oSpeaking)) and _guard_ < 4000
			This.TickSpeech()
			sleep(0.02)
			_guard_++
		end
		return This

	def IsSpeaking()
		return isObject(@oSpeaking)

	def SpeechQueueDepth()
		return len(@aQueue)

	def SpeechDrops()
		return @nSpeechDrops

	def SpeechSpoken()
		return @nSpeechSpoken

	def SetSpeechQueueMax(pn)
		if pn >= 1  @nQueueMax = pn ok
		return This

	# What a caller must not assume. Ring occupancy plus the measured device
	# and OS floor -- see plan S.5 for where each number comes from.
	def TriggerToEarMs()
		_ring_ = 329
		if @bStarted  _ring_ = @oPool.Transport().PositionInSeconds() * 0 + 329 ok
		return _ring_ + 90

	# Rule 18 allows 100 ms. This answers whether a sound can be the
	# acknowledgement, and on this pipeline the answer is no.
	def CanAcknowledgeWithin(pnMs)
		return This.TriggerToEarMs() <= pnMs

	def Stop()
		if isObject(@oPool)  @oPool.Stop() ok
		@bStarted = FALSE
		return This

	def Release()
		This.Stop()
		if isObject(@oPool)  @oPool.Release() ok
		for _i_ = 1 to len(@aMotifs)
			if isObject(@aMotifs[_i_][2])  @aMotifs[_i_][2].Release() ok
		next

	def IsStarted()
		return @bStarted

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	# The voice is created on FIRST USE, not in init(): a machine with no
	# speech engine must still get earcons, and constructing a voice that
	# cannot exist would make the whole semantic layer unusable there.
	def _EnsureVoice()
		if isObject(@oVoice)  return ok
		if NOT StzVoiceEngineLoaded()  return ok
		@oVoice = StzVoiceQ()
		if NOT @oVoice.IsUsable()
			@oVoice = NULL
			return
		ok
		@oVoice.WarmUp()      # pay the 4.3x cold cost before the first phrase

	# Copy one sound into another at a frame offset. Sequential layout is what
	# makes the composition safe: nothing overlaps, so nothing masks and
	# nothing sums into a clip.
	def _Blit(poDest, poSrc, pnAtFrame)
		_n_ = poSrc.Frames()
		_max_ = poDest.Frames()
		for _i_ = 1 to _n_
			_at_ = pnAtFrame + _i_
			if _at_ > _max_  exit ok
			poDest.SetSampleAt(_at_, 1, poSrc.SampleAt(_i_, 1))
		next

	def _Resampled(poSound, pnRate)
		_c_ = StzSoundFromBufferQ(StzEngineSoundResample(
			poSound.BufferId(), pnRate, StzSoundQualitySinc()))
		if _c_.Frames() = 0  return poSound ok
		return _c_

	# "Danger" -> ["danger", "cue"] ; "Danger.Alert" -> ["danger", "alert"]
	# The dot spelling is colour's, deliberately: :Danger.Surface reads the
	# same way and an author should not have to learn two.
	def _Parse(pMeaning)
		_c_ = lower("" + pMeaning)
		_v_ = _c_
		_s_ = "cue"
		_d_ = substr(_c_, ".")
		if _d_ > 0
			_v_ = left(_c_, _d_ - 1)
			_s_ = substr(_c_, _d_ + 1)
		ok
		_ok_ = FALSE
		for _k_ in StzSemanticValues()
			if _k_ = _v_  _ok_ = TRUE ok
		next
		if NOT _ok_  return [ "", "" ] ok
		if _s_ != "cue" and _s_ != "alert" and _s_ != "ambient"  _s_ = "cue" ok
		return [ _v_, _s_ ]

	def _LastFiredAt(pcValue)
		for _i_ = 1 to len(@aLastFiredAt)
			if @aLastFiredAt[_i_][1] = pcValue  return @aLastFiredAt[_i_][2] ok
		next
		return -999

	# THE STARTING MOTIF SET. Rising means good and falling means bad, which is
	# the one mapping that is close to universal across musical cultures; the
	# fundamentals sit at 660-990 Hz so that the harmonics that distinguish
	# them land INSIDE a small speaker's band rather than under its low
	# rolloff. Danger gets three notes and the brightest timbre because
	# salience is loudness and spectral centroid -- and it gets them in one
	# gesture, not by repeating, because a repeat costs time Rule 18 has
	# already spent.
	def _BuildMotifs()
		@aMotifs + [ "danger",  This._Motif([990, 880, 660], 0.06, :Square,   0.45) ]
		@aMotifs + [ "warning", This._Motif([990, 660],       0.09, :Triangle, 0.40) ]
		@aMotifs + [ "info",    This._Motif([770],            0.10, :Sine,     0.32) ]
		@aMotifs + [ "success", This._Motif([660, 990],       0.08, :Triangle, 0.36) ]
		@aMotifs + [ "muted",   NULL ]                 # silence IS the rendering

	# Rendered OFFLINE into an ordinary sample buffer -- no device, no callback,
	# no timing path. Each note is shaped at both ends: a step into or out of a
	# note is a click, which plate 2 of the insight gallery draws as a stripe
	# across every frequency.
	def _Motif(paHz, pnSecs, pWave, pnAmp)
		_n_ = len(paHz)
		_o_ = StzSoundOfSilenceQ(_n_ * pnSecs, 1, @nRate)
		_fr_ = _o_.Frames()
		_per_ = floor(pnSecs * @nRate)
		_ramp_ = floor(0.006 * @nRate)
		for _k_ = 0 to _n_ - 1
			_hz_ = paHz[_k_ + 1]
			for _i_ = 0 to _per_ - 1
				_at_ = _k_ * _per_ + _i_ + 1
				if _at_ > _fr_  loop ok
				_t_ = _i_ / @nRate
				_e_ = 1
				if _i_ < _ramp_  _e_ = _i_ / _ramp_ ok
				if _i_ > _per_ - _ramp_  _e_ = (_per_ - _i_) / _ramp_ ok
				_v_ = This._Wave(pWave, _hz_ * _t_)
				_o_.SetSampleAt(_at_, 1, pnAmp * _e_ * _v_)
			next
		next
		return _o_

	# Additive and band-limited by construction: harmonics only while they fit
	# under Nyquist. The engine's oscillators are band-limited too, but a motif
	# is rendered once and offline, so exactness costs nothing here.
	def _Wave(pWave, pnPhaseCycles)
		_p_ = 2 * 3.14159265358979 * pnPhaseCycles
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
		off
		return sin(_p_)
