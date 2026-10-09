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

# The steps THIS channel has, and they are NOT colour's -- see SS4. Both faces
# spell a step the same way, value.step, but a SURFACE is not a thing sound has
# and an ALERT is not a thing colour has. Sharing the lists would force one
# medium to carry the other's ideas, which is the opposite of what a semantic
# layer is for. The VALUE is shared; the step is the medium's own.
func StzEarconSteps()
	return [ "cue", "alert", "ambient" ]

# Turns a meaning (danger, warning, info, success, muted) into a short sound and decides when it may play, so a screen state is corroborated by ear.
#
# An author names a meaning and gets a motif: ToSoundOf returns it as data, with no audio device,
# and the audibility and priority questions are answered by pure functions (WouldFireAt, IsAudible,
# PriorityOf). Muted renders as silence. Start opens a sound pool and Fire plays a cue through the
# device, dropping it when the same value repeats inside the refractory period or a louder alert is
# still sounding; Say queues a cue and a spoken phrase, which are only heard through TickSpeech or
# SpeakQueueToEnd. A sound is not the acknowledgement: it arrives about 419 ms after Fire, against
# the 100 ms the screen has, so it must repeat what another channel already shows. Every example of
# this reference rendered to buffers; none played through a device, and what a person hears of the
# motifs has not been recorded here.
#
#   receiver   o1 = new stzEarcons()
#   example    ? o1.IsSilentValue(:Muted)
#              #--> 1
#              ? o1.PriorityOf(:Danger)
#              #--> 4
#              ? o1.ToStepOf("Danger.Alert")
#              #--> alert
#              ? o1.WouldFireAt(:Danger, 10)
#              #--> 1
#   see        StzEarconsQ, StzSemanticValues, stzVoicePool, stzVoice
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

	# ── SS3: DUCKING ───────────────────────────────────────────────────────
	#
	# §S.3 decided the priority contract and deliberately did NOT build this:
	# attenuating a lower-priority voice needs a per-bus gain node, and adding
	# a node was on the far side of that session's boundary.
	#
	# DUCK OR DROP, and the plane already does one of them. A cue displaced by
	# something louder in meaning is DROPPED, because a cue arriving after its
	# event lies about when it happened. Ducking is the other half: a cue that
	# is ALREADY SOUNDING cannot be un-sounded, so it is turned DOWN while the
	# alert speaks over it.
	#
	# -12 dB is the default, and it is a number rather than a taste: it is deep
	# enough that the ducked cue stops competing for attention and shallow
	# enough that it is still audibly present, so a listener can tell "quieter"
	# from "gone". A duck to silence would be indistinguishable from a drop,
	# and then there would be no reason to have built this.
	@nDuckDb = -12
	@nDuckRampMs = 10     # SN3's measured ramp; see the kill criterion
	@bDuckOn = TRUE
	@nDucksApplied = 0

	# Builds the vocabulary of four motifs for danger, warning, info and success, with muted left silent; no device is opened.
	#
	#   returns    nothing; the object is built
	#   note       the motifs are rendered by the engine at 48000 Hz into ordinary sample buffers
	#   see        ToSoundOf, Start
	def init()
		This._BuildMotifs()
		_aV1_ = StzSemanticValues()
		_nV1_ = len(_aV1_)
		for _iV1_ = 1 to _nV1_
			_v_ = _aV1_[_iV1_]
			@aLastFiredAt + [ _v_, -999 ]
			@aDrops + [ _v_, 0 ]
		next

	# Returns the motif that a meaning sounds like, as a sound buffer that needs no audio device.
	#
	#   pMeaning   a semantic value (danger, warning, info, success, muted) as a name or a text,
	#              optionally followed by .cue or .alert
	#   returns    a stzSound; an empty text for muted and for a meaning that is refused, with
	#              LastError telling which half was wrong
	#   note       the danger motif lasts 0.18 seconds at 48000 Hz
	#   see        ToSoundOfSaying, IsSilentValue, LastError
	#@ aka  -- what a meaning sounds like (no device needed) -----------------------
	def ToSoundOf(pMeaning)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			# say WHY, or a caller holding an empty result has to guess
			# between "no such value" and "no such step"
			@cLastError = _p_[3]
			return ""
		ok
		if _p_[1] = "muted"  return "" ok
		for _i_ = 1 to len(@aMotifs)
			if @aMotifs[_i_][1] = _p_[1]  return @aMotifs[_i_][2] ok
		next
		return ""

	# TRUE if the meaning is muted, the one value whose rendering is silence.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    TRUE or FALSE; FALSE for an unknown meaning
	#   see        ToSoundOf, IsAudible
	#@ aka  Muted is the one value whose rendering is nothing. Asking is legitimate.
	def IsSilentValue(pMeaning)
		return This._Parse(pMeaning)[1] = "muted"

	# Returns the step a meaning asks for, cue when none is written.
	#
	#   pMeaning   a semantic value, optionally followed by a dot and a step
	#   returns    a text, cue or alert or ambient; an empty text when the meaning is refused
	#   see        PriorityOf, RequiredMarginOf
	def ToStepOf(pMeaning)
		return This._Parse(pMeaning)[2]

	# Returns how severe a meaning is, from 4 for danger down to 1 for success.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    a number: danger 4, warning 3, info 2, success 1, and 0 for muted or an unknown
	#              meaning
	#   see        WouldFireAt, DuckUnder
	def PriorityOf(pMeaning)
		switch This._Parse(pMeaning)[1]
		on "danger"    return 4
		on "warning"   return 3
		on "info"      return 2
		on "success"   return 1
		off
		return 0

	# Declares the loudness of the room in dB against which audibility is judged; it is never measured.
	#
	#   pnDb       the declared ambient level in dB, -40 being a quiet office
	#   returns    the earcons object itself, so calls chain
	#   note       a louder floor lowers every margin and can turn IsAudible to FALSE
	#   see        DeclaredFloor, AudibilityMarginOf
	#@ aka  -- THE AUDIBILITY FLOOR ------------------------------------------------
	def SetAmbientFloor(pnDb)
		@nFloorDb = pnDb
		return This

	# Returns the ambient level in dB that margins are measured against.
	#
	#   returns    a number, -40 until SetAmbientFloor changes it
	#   see        SetAmbientFloor
	def DeclaredFloor()
		return @nFloorDb

	# Returns the name of the loudness measure that the audibility margin uses.
	#
	#   returns    a text naming a K-weighted level over the sound's own length, which the text says
	#              is not an integrated LUFS figure
	#   see        LevelOf, AudibilityMarginOf
	#@ aka  WHAT THE MARGIN IS MEASURED WITH, said out loud every time it is asked.
	def MarginMetric()
		_s_ = This.ToSoundOf(:Danger)
		if isObject(_s_)  return _s_.LoudnessMetric() ok
		return "K-weighted level over the sound's support"

	# Returns the K-weighted level of a meaning's motif over its own length, in dB.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    a number; -1000 for muted and for a refused meaning
	#   note       the danger motif measured -13.13 and the success motif -14.31
	#   see        AudibilityMarginOf, MarginMetric
	def LevelOf(pMeaning)
		_s_ = This.ToSoundOf(pMeaning)
		if NOT isObject(_s_)  return -1000 ok
		return _s_.LoudnessOfSupport()

	# Returns how many dB a meaning's motif lies above the declared ambient floor.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    a number; -1000 when the meaning has no sound
	#   note       the danger margin was 26.87 over the default floor of -40
	#   see        LevelOf, RequiredMarginOf, IsAudible
	def AudibilityMarginOf(pMeaning)
		_l_ = This.LevelOf(pMeaning)
		if _l_ <= -999  return -1000 ok
		return _l_ - @nFloorDb

	# Returns the headroom over the floor that a meaning must have: 10 for a cue and 20 for an alert.
	#
	#   pMeaning   a semantic value, optionally followed by .alert
	#   returns    a number, 10 or 20
	#   see        AudibilityMarginOf, IsAudible
	#@ aka  The gate. A cue needs 10 LU of headroom over the room; an alert needs 20.
	def RequiredMarginOf(pMeaning)
		if This._Parse(pMeaning)[2] = "alert"  return 20 ok
		return 10

	# TRUE if the meaning's motif clears the required margin over the declared floor; muted counts as audible.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    TRUE or FALSE; FALSE for an unknown meaning
	#   note       muted answers TRUE because silence is lawful
	#   see        AudibilityMarginOf, RequiredMarginOf, SetAmbientFloor
	def IsAudible(pMeaning)
		if This.IsSilentValue(pMeaning)  return TRUE ok    # silence is lawful
		return This.AudibilityMarginOf(pMeaning) >= This.RequiredMarginOf(pMeaning)

	# TRUE if the playing rules let the meaning sound at the given time, and records the reason.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   pnNow      the time in seconds on the player's clock
	#   returns    TRUE or FALSE; LastReason says why, ok when TRUE
	#   note       it refuses ambient steps, muted, the same value twice inside the refractory
	#              period, and a quieter meaning while an alert is still sounding
	#   see        RecordFireAt, LastReason, Fire
	#@ aka  -- THE PRIORITY CONTRACT -----------------------------------------------
	def WouldFireAt(pMeaning, pnNow)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@cLastReason = _p_[3]
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

	# Records that a meaning sounded at a time, so later decisions see the refractory period and any alert in force.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   pnNow      the time in seconds when it sounded
	#   returns    the earcons object itself, so calls chain
	#   note       an alert holds the floor for three times its motif length, and nothing happens
	#              for a refused meaning
	#   see        WouldFireAt, CountDropAt
	#@ aka  The state advance, separated from the decision so both the real path and a device-less guard drive the same code.
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

	# Adds one to the count of dropped cues for a meaning.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    the earcons object itself, so calls chain
	#   note       Fire calls it for you when WouldFireAt says no
	#   see        DropsOf, WouldFireAt
	def CountDropAt(pMeaning)
		_v_ = This._Parse(pMeaning)[1]
		for _i_ = 1 to len(@aDrops)
			if @aDrops[_i_][1] = _v_  @aDrops[_i_][2]++ ok
		next
		return This

	# Returns how many cues of that meaning were dropped.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    a number, 0 for an unknown meaning
	#   see        CountDropAt
	def DropsOf(pMeaning)
		_v_ = This._Parse(pMeaning)[1]
		for _i_ = 1 to len(@aDrops)
			if @aDrops[_i_][1] = _v_  return @aDrops[_i_][2] ok
		next
		return 0

	# Returns why the last decision about a cue or a phrase went the way it did.
	#
	#   returns    a text such as ok, muted renders as silence, or a refractory message; empty
	#              before any decision
	#   see        WouldFireAt, Say
	def LastReason()
		return @cLastReason

	# Sets the period in seconds inside which a repeat of the same value counts as one event; it starts at 0.15.
	#
	#   pnSeconds   the refractory period in seconds
	#   returns     the earcons object itself, so calls chain
	#   see         WouldFireAt
	def SetRefractory(pnSeconds)
		@nRefractory = pnSeconds
		return This

	# Opens the sound pool so cues can be heard, and does nothing when it is already open.
	#
	#   returns    the earcons object itself, so check IsStarted afterwards
	#   note       when the device cannot open, LastError says why and IsStarted stays FALSE
	#   warning    it opens the audio device and plays through it, which no run of this reference
	#              did
	#   see        Fire, Stop, IsStarted
	#@ aka  -- hearing it ----------------------------------------------------------
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

	# Plays the cue for a meaning if the rules allow it, ducks the quieter voices, and counts a drop otherwise.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    the earcons object itself, so calls chain
	#   note       before Start it plays nothing, sets LastError to Fire: call Start() first and
	#              counts a refusal
	#   warning    it sounds through the audio device and was not run started
	#   see        WouldFireAt, Start, DuckUnder
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
		# SS3: whatever is quieter in meaning gets out of the way. This happens
		# AFTER the fire, so the alert's own bus is never the one turned down.
		This.DuckUnder(pMeaning)
		This.RecordFireAt(pMeaning, _now_)
		return This

	def FireQ(pMeaning)
		This.Fire(pMeaning)
		return This

	# Sets how many dB quieter a lower-priority cue becomes while a higher one sounds; it starts at -12.
	#
	#   pnDb       the attenuation in dB, which must be negative
	#   returns    the earcons object itself, so calls chain
	#   warning    a positive value is refused: the depth is unchanged, LastError says to give a
	#              negative value, and a refusal is counted
	#   see        DuckDepthDb, SetDucking
	#@ aka  -- SS3: ducking --------------------------------------------------------
	def SetDuckDepth(pnDb)
		if pnDb > 0
			@nRefusals++
			@cLastError = "SetDuckDepth: a duck is an attenuation -- give a " +
			              "NEGATIVE dB value"
			return This
		ok
		@nDuckDb = pnDb
		return This

	# Returns by how many dB a voice is turned down when a louder cue ducks it.
	#
	#   returns    a number, -12 until SetDuckDepth changes it
	#   see        SetDuckDepth
	def DuckDepthDb()
		return @nDuckDb

	# Sets the time in milliseconds over which a duck or an unduck moves, so that it cannot click; it starts at 10.
	#
	#   pnMs       the ramp length in milliseconds, a negative value being taken as 0
	#   returns    the earcons object itself, so calls chain
	#   see        DuckRampMs, Unduck
	def SetDuckRampMs(pnMs)
		if pnMs < 0  pnMs = 0 ok
		@nDuckRampMs = pnMs
		return This

	# Returns the length of the duck ramp in milliseconds.
	#
	#   returns    a number, 10 until SetDuckRampMs changes it
	#   see        SetDuckRampMs
	def DuckRampMs()
		return @nDuckRampMs

	# Switches ducking on or off; it is on by default.
	#
	#   pbOn       TRUE to duck quieter voices when a louder cue fires, FALSE to leave them alone
	#   returns    the earcons object itself, so calls chain
	#   see        IsDucking, DuckUnder
	def SetDucking(pbOn)
		@bDuckOn = pbOn
		return This

	# TRUE if quieter voices are turned down when a louder cue fires.
	#
	#   returns    TRUE or FALSE
	#   see        SetDucking
	def IsDucking()
		return @bDuckOn

	# Returns how many times a duck was applied, so that a sudden quiet has a number behind it.
	#
	#   returns    a number
	#   see        DuckUnder, GainOf
	#@ aka  COUNTED, like everything else this plane does behind a listener's back. "Why did that get quiet" must have an answer that is a number.
	def DucksApplied()
		return @nDucksApplied

	# Returns the gain that the player now applies to a meaning's voice.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   returns    a number, 1 at unity and lower while ducked; -1 before Start or for a refused
	#              meaning
	#   note       only the not-started answer was run, since reading a live gain needs the open
	#              pool
	#   see        DuckUnder, Unduck
	#@ aka  The gain the RENDER is applying to a value's bus right now. During a ramp this is somewhere between the old value and the target, which is what lets a guard prove the ramp MOVES rather than jumps.
	def GainOf(pMeaning)
		if NOT @bStarted  return -1 ok
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""  return -1 ok
		return @oPool.VoiceGain(_p_[1])

	# Turns down every voice that is quieter in meaning than the given one, on the duck ramp.
	#
	#   pMeaning   the semantic value that is sounding, optionally with a step
	#   returns    the earcons object itself, so calls chain
	#   note       it changes nothing before Start or while ducking is off, and only that no-op was
	#              run because ducking needs the open pool
	#   see        Unduck, SetDuckDepth, GainOf
	#@ aka  Duck every value QUIETER IN MEANING than this one, and leave the rest alone. Ramped, so it cannot click.
	def DuckUnder(pMeaning)
		if NOT @bStarted or NOT @bDuckOn  return This ok
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""  return This ok
		_pri_ = This.PriorityOf(pMeaning)
		_g_ = pow(10, @nDuckDb / 20)
		_any_ = FALSE
		_aV2_ = StzSemanticValues()
		_nV2_ = len(_aV2_)
		for _iV2_ = 1 to _nV2_
			_v_ = _aV2_[_iV2_]
			if _v_ = "muted"  loop ok
			if This.PriorityOf(_v_) < _pri_
				@oPool.SetVoiceGain(_v_, _g_, @nDuckRampMs)
				_any_ = TRUE
			ok
		next
		if _any_  @nDucksApplied++ ok
		return This

	# Brings every voice back to unity gain on the duck ramp.
	#
	#   returns    the earcons object itself, so calls chain
	#   note       it changes nothing before Start, and only that no-op was run
	#   see        DuckUnder
	#@ aka  Everything back to unity, on the same ramp. Restoring with a JUMP would click exactly as ducking with one would.
	def Unduck()
		if NOT @bStarted  return This ok
		_aV3_ = StzSemanticValues()
		_nV3_ = len(_aV3_)
		for _iV3_ = 1 to _nV3_
			_v_ = _aV3_[_iV3_]
			if _v_ = "muted"  loop ok
			@oPool.SetVoiceGain(_v_, 1.0, @nDuckRampMs)
		next
		return This

	# Chooses the language in which phrases are spoken, and refuses a language the machine has no voice for.
	#
	#   pcTag      the language tag such as en-US or fr-FR
	#   returns    TRUE if the language was accepted, FALSE if it was refused with LastError naming
	#              the languages the machine has
	#   note       it never falls back to another language
	#   see        VoiceLanguage, CanSpeak, Say
	#@ aka  -- VC4: SAY -- the earcon, then the phrase that says WHICH -------------
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

	# Returns the language phrases are spoken in.
	#
	#   returns    a text, empty until a language has been accepted
	#   see        SetVoiceLanguage
	#@ aka  Which language it is actually speaking -- empty until one is set and ACCEPTED, so a caller can tell "not asked yet" from "asked and refused".
	def VoiceLanguage()
		return @cVoiceLang

	# TRUE if this machine has a usable speech voice.
	#
	#   returns    TRUE or FALSE
	#   note       the first call loads the voice engine, which is created only on first use
	#   see        SetVoiceLanguage, ToSoundOfSaying
	def CanSpeak()
		This._EnsureVoice()
		return isObject(@oVoice) and @oVoice.IsUsable()

	# Returns one buffer holding the meaning's cue, a short gap, then the spoken phrase, with no audio device needed.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   pcPhrase   the text to speak
	#   returns    a stzSound; the plain cue when no voice is usable or the phrase is empty, and an
	#              empty text when both are silent or the meaning is refused
	#   note       the buffer takes the phrase's sample rate (22050 Hz on the run) and ends in 0.2
	#              seconds of silence so the last syllable is not cut
	#   see        Say, ToSoundOf, SpeechGapSeconds
	#@ aka  THE COMPOSITE, as DATA: earcon, a gap, then the phrase, in ONE buffer.
	def ToSoundOfSaying(pMeaning, pcPhrase)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@nRefusals++
			@cLastError = _p_[3]
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
		# A TAIL OF SILENCE, and it is not padding for its own sake. Stopping
		# closes the device, and the device is closed the moment the last
		# frame is READ rather than heard -- so a composite that ends on its
		# final syllable loses the end of that syllable. 200 ms of rendered
		# silence costs 4 KB and means the sentence finishes before anything
		# is torn down.
		_total_ = _earSecs_ + @nGapSeconds + _say_.Duration()
		_out_ = StzSoundOfSilenceQ(_total_ + 0.20, 1, _rate_)

		_at_ = 0
		if isObject(_ear_)
			This._Blit(_out_, _ear_, 0)
			_at_ = floor((_earSecs_ + @nGapSeconds) * _rate_)
		ok
		This._Blit(_out_, _say_, _at_)
		return _out_

	# Queues a cue and its phrase, higher priority first, and cancels a quieter phrase that is being spoken.
	#
	#   pMeaning   a semantic value, optionally with a step
	#   pcPhrase   the text to say
	#   returns    the earcons object itself, so calls chain
	#   note       muted queues nothing and gives the reason in LastReason, and a refused meaning is
	#              counted as a refusal; nothing is heard until TickSpeech or SpeakQueueToEnd
	#   warning    the queue holds four by default and a fifth is dropped and counted in SpeechDrops
	#   see        TickSpeech, SpeakQueueToEnd, SetSpeechQueueMax
	#@ aka  Say it: the earcon, then the phrase. Queued, not played immediately -- call TickSpeech() (or SpeakQueueToEnd()) to advance.
	def Say(pMeaning, pcPhrase)
		_p_ = This._Parse(pMeaning)
		if _p_[1] = ""
			@nRefusals++
			@cLastError = _p_[3]
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

	# Advances the speech queue by one step: reaps a finished phrase, or starts the next one.
	#
	#   returns    the earcons object itself, so calls chain
	#   note       with an empty queue it does nothing, and that was the only case run
	#   warning    it starts a transport on the audio device when a phrase is queued, which no run
	#              of this reference did
	#   see        Say, SpeakQueueToEnd, IsSpeaking
	#@ aka  One step. Starts the next phrase when nothing is speaking, and reaps the transport when it ends. Cheap; call it as often as you like.
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

	# Speaks everything queued as one buffer through one device and returns when it has finished.
	#
	#   returns    the earcons object itself, so calls chain
	#   note       with an empty queue it returns at once, and that was the only case run
	#   warning    it occupies the thread and plays through the audio device, which no run of this
	#              reference did
	#   see        Say, TickSpeech
	#@ aka  Drive the queue to the end. Occupies the thread, which is honest for a script; a program with a UI ticks instead.
	def SpeakQueueToEnd()
		# 1. Let whatever a previous TickSpeech already started finish, and do
		#    NOT start anything new here -- that is step 2's job.
		_guard_ = 0
		while isObject(@oSpeaking) and _guard_ < 4000
			@oSpeaking.Tick()
			if @oSpeaking.IsStopped()
				@oSpeaking.Release()
				@oSpeaking = NULL
				@nSpeakingPriority = 0
			else
				sleep(0.02)
			ok
			_guard_++
		end
		if len(@aQueue) = 0  return This ok

		# 2. Synthesise everything still queued BEFORE opening anything. The
		#    phrases are spoken in queue order, which priority already fixed.
		_snds_ = []
		for _i_ = 1 to len(@aQueue)
			_s_ = This.ToSoundOfSaying(@aQueue[_i_][1], @aQueue[_i_][2])
			if isObject(_s_)  _snds_ + _s_ ok
		next
		@aQueue = []
		if len(_snds_) = 0  return This ok

		# 3. Lay them end to end with the same gap that separates a cue from
		#    its phrase, so a run of announcements is paced like one.
		_rate_ = _snds_[1].SampleRate()
		_total_ = 0
		_at_ = []
		for _i_ = 1 to len(_snds_)
			_at_ + _total_
			_total_ += _snds_[_i_].Duration()
			if _i_ < len(_snds_)  _total_ += @nGapSeconds * 2 ok
		next
		_out_ = StzSoundOfSilenceQ(_total_ + 0.10, 1, _rate_)
		for _i_ = 1 to len(_snds_)
			This._Blit(_out_, _snds_[_i_], floor(_at_[_i_] * _rate_))
		next

		# 4. ONE transport, for all of it.
		_g_ = new stzSoundGraph()
		_g_.Reshape(1, _rate_)
		_g_.AddSound(_out_)
		_t_ = new stzSoundTransport(_g_)
		_t_.PlayFor(_out_.Duration())
		_guard_ = 0
		while NOT _t_.IsStopped() and _guard_ < 20000
			_t_.Tick()
			sleep(0.02)
			_guard_++
		end
		_t_.Release()
		@nSpeechSpoken += len(_snds_)
		return This

	# TRUE if a phrase is being spoken now.
	#
	#   returns    TRUE or FALSE
	#   see        TickSpeech, SpeechQueueDepth
	def IsSpeaking()
		return isObject(@oSpeaking)

	# Returns how many phrases wait in the speech queue.
	#
	#   returns    a number
	#   see        Say, SetSpeechQueueMax
	def SpeechQueueDepth()
		return len(@aQueue)

	# Returns how many phrases were dropped because the queue was full or a louder one cancelled them.
	#
	#   returns    a number
	#   see        Say, SpeechSpoken
	def SpeechDrops()
		return @nSpeechDrops

	# Returns how many phrases were spoken.
	#
	#   returns    a number
	#   see        SpeechDrops, TickSpeech
	def SpeechSpoken()
		return @nSpeechSpoken

	# Returns the silence in seconds between a cue and its phrase, and between queued announcements.
	#
	#   returns    a number, 0.12
	#   see        ToSoundOfSaying
	#@ aka  The silence between a cue and its phrase, and between two announcements when a queue drains as one. Exposed because a guard has to be able to account for it rather than assume it.
	def SpeechGapSeconds()
		return @nGapSeconds

	# Sets how many phrases the speech queue holds before it drops more.
	#
	#   pn         the queue capacity, a value below 1 being ignored
	#   returns    the earcons object itself, so calls chain
	#   note       the capacity starts at 4
	#   see        SpeechQueueDepth, SpeechDrops
	def SetSpeechQueueMax(pn)
		if pn >= 1  @nQueueMax = pn ok
		return This

	# Returns the milliseconds between firing a cue and hearing it on this pipeline, a stated figure and not a measurement.
	#
	#   returns    a number, 419: 329 for the ring plus 90 for the device
	#   note       the answer is a constant in the code, whether or not the player is started
	#   see        CanAcknowledgeWithin
	#@ aka  What a caller must not assume. Ring occupancy plus the measured device and OS floor -- see plan S.5 for where each number comes from.
	def TriggerToEarMs()
		_ring_ = 329
		if @bStarted  _ring_ = @oPool.Transport().PositionInSeconds() * 0 + 329 ok
		return _ring_ + 90

	# TRUE if a sound can arrive within the given time, which on this pipeline it cannot do inside 100 ms.
	#
	#   pnMs       the deadline in milliseconds
	#   returns    TRUE or FALSE
	#   note       100 gave FALSE and 500 gave TRUE
	#   see        TriggerToEarMs
	#@ aka  Rule 18 allows 100 ms. This answers whether a sound can be the acknowledgement, and on this pipeline the answer is no.
	def CanAcknowledgeWithin(pnMs)
		return This.TriggerToEarMs() <= pnMs

	# Stops the sound pool if it is open and marks the object as not started.
	#
	#   returns    the earcons object itself, so calls chain
	#   note       before Start it only clears the flag
	#   see        Start, Release, IsStarted
	def Stop()
		if isObject(@oPool)  @oPool.Stop() ok
		@bStarted = FALSE
		return This

	# Stops playing and frees the pool and the motif buffers it holds.
	#
	#   returns    nothing; it returns an empty text
	#   note       call it once, when you are done with the object
	#   see        Stop
	def Release()
		This.Stop()
		if isObject(@oPool)  @oPool.Release() ok
		for _i_ = 1 to len(@aMotifs)
			if isObject(@aMotifs[_i_][2])  @aMotifs[_i_][2].Release() ok
		next

	# TRUE if the sound pool is open.
	#
	#   returns    TRUE or FALSE
	#   see        Start, Stop
	def IsStarted()
		return @bStarted

	# Returns the reason of the last refusal or failure.
	#
	#   returns    a text, empty when there was none
	#   note       ToSoundOf also sets it when a meaning is refused
	#   see        Refusals, LastReason
	def LastError()
		return @cLastError

	# Returns how many calls were refused, for example Fire before Start or a positive duck depth.
	#
	#   returns    a number
	#   see        LastError
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
	# Returns [ value, step, reason ]. An empty value means refused, and the
	# THIRD element says which of the two halves was wrong -- a caller that
	# reports "no semantic value named 'danger.surface'" is telling a lie
	# about a value that exists perfectly well.
	#
	# AN UNKNOWN STEP IS REFUSED, and it did not used to be. It was silently
	# rewritten to "cue", which SS4 caught by asking the two channels the same
	# question: the colour face REFUSES `danger.alert`, and this one accepted
	# `danger.surface` and quietly made it a cue. Two faces sharing a
	# vocabulary must fail the same way, or the vocabulary is only shared when
	# nothing goes wrong.
	#
	# And the downgrade was not harmless. `.alert` is the step that PRE-EMPTS
	# and holds a bus; a typo in it -- `Danger.Alrt` -- became an ordinary cue
	# with no alert behaviour and no message. That is the plane's own law
	# broken: a setting that silently does nothing is worse than one that says
	# no.
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
		_aK4_ = StzSemanticValues()
		_nK4_ = len(_aK4_)
		for _iK4_ = 1 to _nK4_
			_k_ = _aK4_[_iK4_]
			if _k_ = _v_  _ok_ = TRUE ok
		next
		if NOT _ok_
			return [ "", "", "no semantic value named '" + pMeaning + "'" ]
		ok
		_sok_ = FALSE
		_aK5_ = StzEarconSteps()
		_nK5_ = len(_aK5_)
		for _iK5_ = 1 to _nK5_
			_k_ = _aK5_[_iK5_]
			if _k_ = _s_  _sok_ = TRUE ok
		next
		if NOT _sok_
			return [ "", "", "'" + _v_ + "' is a semantic value but '" + _s_ +
			         "' is not one of this channel's steps (" +
			         This._Joined(StzEarconSteps()) + ") -- colour's steps are " +
			         "its own, and neither channel borrows the other's" ]
		ok
		return [ _v_, _s_, "" ]

	def _Joined(paList)
		_s_ = ""
		for _i_ = 1 to len(paList)
			if _i_ > 1  _s_ += ", " ok
			_s_ += "" + paList[_i_]
		next
		return _s_

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
	# THE VOCABULARY IS NOT BUILT HERE ANY MORE, and that is SS5.
	#
	# These four motifs were written in Ring, where the native tier could reach
	# them and the browser could not. Porting them to JavaScript would have
	# created a SECOND author of what :Danger sounds like -- and two authors of
	# a vocabulary drift, silently, because nobody renders the same meaning on
	# two tiers and compares.
	#
	# They now live in `sounddsp.zig`, the seam compiled into BOTH stz_sound.dll
	# and stz.wasm, so there is exactly one. This face asks for them; so does
	# the browser; and a guard renders the same value through both and compares.
	#
	# The numbers did not change when they moved. sound_semantics_narrated and
	# sound_ss1_narrated assert the vocabulary's shape, and they were run before
	# and after to prove the move was a MOVE and not a redesign.
	def _BuildMotifs()
		_aV6_ = StzSemanticValues()
		_nV6_ = len(_aV6_)
		for _iV6_ = 1 to _nV6_
			_v_ = _aV6_[_iV6_]
			_b_ = StzEngineSoundEarconOf(This._EarconIndexOf(_v_), @nRate)
			if _b_ = 0
				@aMotifs + [ _v_, NULL ]      # muted: silence IS the rendering
			else
				@aMotifs + [ _v_, StzSoundFromBufferQ(_b_) ]
			ok
		next

	# The engine's order, and it is StzSemanticValues()' order. Kept as an
	# explicit lookup rather than a position, so reordering one list cannot
	# silently remap every meaning to the wrong sound.
	def _EarconIndexOf(pcValue)
		switch lower("" + pcValue)
		on "danger"    return 0
		on "warning"   return 1
		on "info"      return 2
		on "success"   return 3
		on "muted"     return 4
		off
		return 4

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
