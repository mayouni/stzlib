#---------------------------------------------------------------------------#
#  STZVOICEPOOL -- fire a sound NOW, again, and again, without building      #
#  anything. The game plane's door, opened.                                  #
#---------------------------------------------------------------------------#
#
#     oPool = StzVoicePoolOfQ(48000)
#     oPool.AddVoice(:blip, oBlipSound, 4)      # 4 can overlap
#     oPool.AddToneVoice(:coin, :Square, 880, 0.05, 3)
#     oPool.Start()
#
#     oPool.Fire(:blip)                          # returns AT ONCE
#     oPool.Fire(:coin)
#
# WHY A POOL AND NOT "PLAY THIS SOUND". A game fires the same footstep thirty
# times a minute and two of them overlap. Building a graph per shot means
# allocating, preparing and opening a device inside the frame that has to draw
# -- which is the one place in the program that must not allocate. So the
# whole pool is built ONCE, prepared ONCE, and mixed into ONE stream; firing a
# voice is an atomic flag, and the render picks it up at the next block.
#
# SLOTS ARE THE POLICY. A voice with four slots can sound four times at once;
# the fifth fire steals the oldest, which is what every game audio engine does
# and is better than the alternatives (dropping the sound, or growing without
# bound). Stolen shots are COUNTED, so "why did that footstep vanish" has an
# answer.
#
# ONE CLOCK. The pool runs on a stzSoundTransport, so its position is the same
# device clock the rest of the plane reads -- a pool and a music bed and a
# graphics frame counter can all be told the same time.
#
# WHAT IT IS NOT. There is no pitch-per-shot, no per-shot volume, no 3D
# panning. Those need per-node parameters the engine does not have yet, and a
# face that pretends otherwise would be a face that lies. AddVoice builds the
# voice's sound once; Fire plays THAT.

func StzVoicePoolOfQ(pnRate)
	return new stzVoicePool(pnRate)

# Fires a sound now, again and again, without building anything: the pool is built once and mixed into one stream.
#
# A game fires the same footstep thirty times a minute and two overlap, and building a graph per
# shot would allocate inside the frame that has to draw. The pool is built once, prepared once and
# mixed into one stream, and firing a voice is an atomic flag the render picks up at its next block.
# Slots are the policy: a voice of four slots sounds four times at once and the fifth fire steals
# the oldest, counted and not hidden. Each voice has its own gain bus so one can be ducked with a
# ramp, never a jump. The pool runs on a stzSoundTransport, so its position is the plane's one
# device clock. There is no pitch or volume per shot and no panning. Start opens a sound card: for
# this reference it was never run, the example builds the pool and reads what needs no device, and
# nothing was heard (UNPERCEIVED).
#
#   receiver   o1 = StzVoicePoolOfQ(48000) oBlip = StzSoundScoreQ().Note(880, 0.2).ToSound()
#              o1.AddVoice(:blip, oBlip, 4) o1.AddToneVoice(:coin, :Square, 880, 0.05, 3)
#   example    ? @@( o1.VoiceNames() )
#              #--> [ "blip", "coin" ]
#              ? o1.SlotsOf(:blip)
#              #--> 4
#              ? o1.SlotsOf(:coin)
#              #--> 3
#              ? o1.IsStarted()
#              #--> 0
#              ? o1.FiresOf(:blip)
#              #--> 0
#              o1.Fire(:blip)
#              ? o1.LastError()
#              #--> Fire: call Start() first
#              ? o1.Refusals()
#              #--> 1
#              ? o1.VoiceGain(:blip)
#              #--> -1
#   see        stzSoundTransport, stzSoundGraph, stzSoundLive, stzSoundScheduler
class stzVoicePool

	@oGraph = NULL
	@oTransport = NULL
	@nRate = 48000
	# [ name, [slotNode,...], nNext, nFires, nSteals, nSecs, [slotFreeAt,...],
	#   nBusGain ]
	#
	# nBusGain is SS3. Every voice gets its OWN gain node between its slots and
	# the master mix, so one voice can be attenuated without touching another.
	# Without it there is one mix and nothing to turn down: ducking would have
	# to be done by re-rendering, which is exactly the sort of work the audio
	# thread must never do.
	#
	# slotFreeAt is WHEN each slot's last shot runs out, on the transport's
	# clock. Without it a "steal" can only be guessed at from the fire count,
	# and the guess is wrong: eight shots through three slots reads as five
	# steals even when every shot had finished long before its slot came round
	# again. That was the first version, and the number it printed was fiction.
	@aVoices = []
	@aNames = []
	@bStarted = FALSE
	@cLastError = ""
	@nRefusals = 0

	# Builds an empty voice pool and its audio graph, stereo at a sample rate, without opening a device.
	#
	#   pnRate     the sample rate in hertz
	#   returns    nothing; the object is built
	#   note       StzVoicePoolOfQ builds the same object; nothing is audible until Start
	#   see        AddVoice, Start
	def init(pnRate)
		@nRate = pnRate
		if @nRate <= 0  @nRate = 48000 ok
		@oGraph = new stzSoundGraph()
		@oGraph.Reshape(2, @nRate)

	# Adds a voice made from an existing sound, with a number of slots so it can overlap itself.
	#
	#   pName      the voice name, matched in lower case
	#   poSound    the stzSound to fire
	#   pnSlots    how many shots may sound at once, 1 or more
	#   returns    nothing; the voice is added. AddVoiceQ returns the pool for chaining
	#   note       a slot count below 1 gives 1; the sound is built into the graph once and Fire
	#              plays that one sound: there is no pitch or volume for each shot and no panning
	#   warning    adding to a pool that is already started counts a refusal and sets LastError to
	#              AddVoice: the pool is already started -- build it first
	#   see        AddToneVoice, Fire
	#@ aka  -- building it ---------------------------------------------------------
	def AddVoice(pName, poSound, pnSlots)
		if @bStarted
			@cLastError = "AddVoice: the pool is already started -- build it first"
			@nRefusals++
			return
		ok
		_slots_ = []
		_n_ = pnSlots
		if _n_ < 1  _n_ = 1 ok
		for _i_ = 1 to _n_
			@oGraph.AddSound(poSound)
			_src_ = @oGraph.OutputNode()
			# a gain of 0 would be silent forever; the slot is silent because
			# its source has run out, not because it is turned down
			_slots_ + _src_
		next
		_secs_ = 1.0
		if isObject(poSound)  _secs_ = poSound.Duration() ok
		This._Register(pName, _slots_, _secs_)

	def AddVoiceQ(pName, poSound, pnSlots)
		This.AddVoice(pName, poSound, pnSlots)
		return This

	# Adds a voice made from an oscillator and a short envelope, such as a blip or a coin.
	#
	#   pName       the voice name, matched in lower case
	#   pWave       the waveform, such as :Square or :Sine
	#   pnHz        the pitch in hertz
	#   pnSeconds   how long one shot lasts
	#   pnSlots     how many shots may sound at once, 1 or more
	#   returns     nothing; the voice is added. AddToneVoiceQ returns the pool for chaining
	#   note        a slot count below 1 gives 1; each slot has its own oscillator and an envelope
	#               with a 4 ms attack
	#   warning     adding to a started pool counts a refusal as AddVoice does
	#   see         AddVoice, Fire
	#@ aka  A voice made from an oscillator and an envelope -- a blip, a coin, a beep. pnSeconds is how long one shot lasts.
	def AddToneVoice(pName, pWave, pnHz, pnSeconds, pnSlots)
		if @bStarted
			@cLastError = "AddToneVoice: the pool is already started"
			@nRefusals++
			return
		ok
		_slots_ = []
		_n_ = pnSlots
		if _n_ < 1  _n_ = 1 ok
		for _i_ = 1 to _n_
			@oGraph.AddOscillator(pWave, pnHz, 0.5)
			_osc_ = @oGraph.OutputNode()
			@oGraph.AddEnvelopeOn(_osc_, 0.004, pnSeconds * 0.9, 0.0,
			                      pnSeconds * 0.1, pnSeconds)
			_slots_ + @oGraph.OutputNode()
		next
		This._Register(pName, _slots_, pnSeconds)

	def AddToneVoiceQ(pName, pWave, pnHz, pnSeconds, pnSlots)
		This.AddToneVoice(pName, pWave, pnHz, pnSeconds, pnSlots)
		return This

	# Mixes every voice through its own gain bus, opens the device and starts the render, silent until a voice is fired.
	#
	#   returns    the pool itself, so calls chain
	#   note       from here the graph shape is frozen; every voice starts spent, rendered past its
	#              longest shot and discarded, so the pool makes no noise when it opens; StartQ is
	#              the same call
	#   warning    not run: it opens a sound card; with no voice it counts a refusal and sets
	#              LastError to Start: the pool has no voices, which was run, and a pool that cannot
	#              start is left not started with the device error in LastError
	#   see        Fire, Stop, IsStarted
	#@ aka  Mix everything, open the device, and start rendering silence. From here the graph's shape is frozen -- the two-phase contract -- and firing is the only thing left that costs anything.
	def Start()
		if @bStarted  return This ok
		if len(@aVoices) = 0
			@cLastError = "Start: the pool has no voices"
			@nRefusals++
			return This
		ok
		# SS3: ONE BUS PER VOICE. Each voice's slots are mixed together, that
		# mix passes through a gain node that belongs to the voice alone, and
		# the master mix takes the GAINS rather than the slots. The extra node
		# per voice is what makes ducking a value written to an atomic instead
		# of a re-render.
		_buses_ = []
		for _v_ = 1 to len(@aVoices)
			_s_ = @aVoices[_v_][2]
			@oGraph.AddMixOf(_s_)
			@oGraph.AddGainOn(@oGraph.OutputNode(), 1.0)
			_g_ = @oGraph.OutputNode()
			@aVoices[_v_][8] = _g_
			_buses_ + _g_
		next
		@oGraph.AddMixOf(_buses_)
		@oTransport = new stzSoundTransport(@oGraph)

		# EVERY VOICE STARTS SPENT. Without this the pool makes a noise the
		# moment it opens -- every envelope begins at the top of its attack,
		# so a pool of twelve slots fires all twelve at once on Start(). The
		# first version did exactly that.
		This._SilenceAll()

		@oTransport.Play()
		if NOT @oTransport.IsPlaying()
			@cLastError = @oTransport.LastError()
			return This
		ok
		@bStarted = TRUE
		@cLastError = ""
		return This

	def StartQ()
		This.Start()
		return This

	# Sounds a voice now, returning at once; the render picks the shot up at its next block.
	#
	#   pName      the voice name
	#   returns    the pool itself, so calls chain; FireQ is the same call
	#   note       slots are taken in turn, so a voice with four slots can sound four times at once
	#              and the fifth shot steals the oldest; a steal is counted from the clock only when
	#              the slot had not finished, so a shot that lands on a spent slot is not a steal
	#   warning    an unknown name counts a refusal and sets LastError to no voice is named ...; a
	#              pool not started counts a refusal and sets LastError to Fire: call Start() first,
	#              both run; the started path was not run: it posts a trigger to the render thread
	#   see        Start, StealsOf, FiresOf
	#@ aka  -- using it ------------------------------------------------------------
	def Fire(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0
			@cLastError = "no voice is named '" + pName + "'"
			@nRefusals++
			return This
		ok
		if NOT @bStarted
			@cLastError = "Fire: call Start() first"
			@nRefusals++
			return This
		ok
		_v_ = @aVoices[_i_]
		_slots_ = _v_[2]
		_next_ = _v_[3]
		_now_ = @oTransport.PositionInSeconds()

		# A STEAL is a shot landing on a slot that had not finished -- read
		# from the clock, not inferred from the count.
		if _now_ < _v_[7][_next_]
			@aVoices[_i_][5] = _v_[5] + 1
		ok

		StzEngineSoundGraphTriggerNode(@oGraph.GraphId(), _slots_[_next_])
		@aVoices[_i_][4] = _v_[4] + 1
		@aVoices[_i_][7][_next_] = _now_ + _v_[6]
		@aVoices[_i_][3] = (_next_ % len(_slots_)) + 1
		return This

	def FireQ(pName)
		This.Fire(pName)
		return This

	# Ramps the gain of one voice bus, so one voice can be turned down without touching another.
	#
	#   pName      the voice name
	#   pnGain     the gain to reach, 1 for unchanged
	#   pnRampMs   the length of the ramp in milliseconds
	#   returns    the pool itself, so calls chain; SetVoiceGainQ is the same call
	#   note       the gain is ramped and never assigned, because a step is a click; the write is
	#              one atomic store the render reads each block, so nothing is allocated; the ramp
	#              after Start was not run
	#   warning    an unknown name, or a call before Start, counts a refusal and sets LastError to
	#              no voice is named ... or SetVoiceGain: the bus does not exist until Start(), both
	#              run
	#   see        VoiceGain, Fire
	#@ aka  -- SS3: DUCKING -------------------------------------------------------
	def SetVoiceGain(pName, pnGain, pnRampMs)
		_i_ = This._IndexOf(pName)
		if _i_ = 0
			@cLastError = "no voice is named '" + pName + "'"
			@nRefusals++
			return This
		ok
		if NOT @bStarted
			@cLastError = "SetVoiceGain: the bus does not exist until Start()"
			@nRefusals++
			return This
		ok
		_n_ = @aVoices[_i_][8]
		if _n_ = 0
			@cLastError = "SetVoiceGain: '" + pName + "' has no bus"
			@nRefusals++
			return This
		ok
		StzEngineSoundGraphSetGain(@oGraph.GraphId(), _n_, pnGain, pnRampMs)
		return This

	def SetVoiceGainQ(pName, pnGain, pnRampMs)
		This.SetVoiceGain(pName, pnGain, pnRampMs)
		return This

	# Returns the gain the render is applying to a voice right now.
	#
	#   pName      the voice name
	#   returns    a number, between the old and the new value during a ramp; -1 for an unknown
	#              voice or before Start
	#   note       -1 before Start was run; read afresh from the engine, not remembered, so a guard
	#              can see a ramp both move and arrive
	#   see        SetVoiceGain, BusNodeOf
	#@ aka  The gain the RENDER is applying right now, which during a ramp is somewhere between the old value and the target. Read rather than remembered, so a guard can prove the ramp both MOVES and ARRIVES.
	def VoiceGain(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return -1 ok
		if @aVoices[_i_][8] = 0  return -1 ok
		return StzEngineSoundGraphCurrentGain(@oGraph.GraphId(), @aVoices[_i_][8])

	# Returns the graph node of a voice's gain bus.
	#
	#   pName      the voice name
	#   returns    the node number; 0 for an unknown voice or before Start
	#   note       the bus exists only after Start
	#   see        VoiceGain, Graph
	def BusNodeOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return @aVoices[_i_][8]

	# Stops the transport and marks the pool as not started.
	#
	#   returns    the pool itself, so calls chain
	#   warning    not run with a started pool: it stops the sound card; before Start it only clears
	#              the flag
	#   see        Start, Release
	def Stop()
		if isObject(@oTransport)  @oTransport.Stop() ok
		@bStarted = FALSE
		return This

	# Stops the pool and frees the transport and the graph.
	#
	#   returns    nothing
	#   note       before Start it frees the graph only; run that way, it did nothing visible
	#   see        Stop
	def Release()
		This.Stop()
		if isObject(@oTransport)  @oTransport.Release() ok
		if isObject(@oGraph)  @oGraph.Release() ok

	# TRUE if the pool has been started.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Start, Stop
	#@ aka  -- what it is doing ----------------------------------------------------
	def IsStarted()
		return @bStarted

	# Returns the stzSoundTransport that plays the pool, the one device clock of the plane.
	#
	#   returns    the transport; an empty text before Start
	#   note       before Start it was an empty text
	#   see        PositionInSeconds, Underruns
	def Transport()
		return @oTransport

	# Returns the audio graph the voices are built into.
	#
	#   returns    a stzSoundGraph
	#   note       the voices' slot nodes are private to the pool
	#   see        Transport, AddVoice
	def Graph()
		return @oGraph

	# Returns the reason of the last refusal.
	#
	#   returns    the reason as text; an empty text when nothing was refused
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls were refused.
	#
	#   returns    a number
	#   note       it counts an add after Start, a start with no voice, a fire of an unknown voice
	#              or before Start, and a gain of an unknown voice or before Start
	#   see        LastError
	def Refusals()
		return @nRefusals

	# Returns the names of the voices in the order they were added.
	#
	#   returns    a list of text; [ ] for an empty pool
	#   see        SlotsOf, AddVoice
	def VoiceNames()
		return @aNames

	# Returns how many slots a voice has.
	#
	#   pName      the voice name, matched in lower case
	#   returns    a number; 0 for an unknown voice
	#   note       an added voice with 0 slots has 1
	#   see        VoiceNames, FiresOf
	def SlotsOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return len(@aVoices[_i_][2])

	# Returns how many times a voice was fired.
	#
	#   pName      the voice name
	#   returns    a number; 0 for an unknown voice or a voice never fired
	#   see        StealsOf, Fire
	def FiresOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return @aVoices[_i_][4]

	# Returns how many shots landed on a slot that was still sounding.
	#
	#   pName      the voice name
	#   returns    a number; 0 for an unknown voice
	#   note       not an error, it is the pool doing its job: a number to read before deciding a
	#              voice needs more slots
	#   see        FiresOf, SlotsOf
	#@ aka  How many shots landed on a slot that was still sounding. Not an error -- it is the pool doing its job -- but a number worth seeing before deciding a voice needs more slots.
	def StealsOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return @aVoices[_i_][5]

	# Returns the time on the transport's clock.
	#
	#   returns    a number of seconds; 0 before Start
	#   note       the same clock the rest of the plane reads
	#   warning    not run after Start: it reads the device clock
	#   see        Transport, Underruns
	def PositionInSeconds()
		if NOT isObject(@oTransport)  return 0 ok
		return @oTransport.PositionInSeconds()

	# Returns how many blocks the device wanted and the render did not have.
	#
	#   returns    a number; 0 before Start
	#   note       the counter tells delivery, not whether anything sounded right, which only a
	#              person can say
	#   warning    not run after Start: it reads the device
	#   see        PositionInSeconds, Transport
	def Underruns()
		if NOT isObject(@oTransport)  return 0 ok
		return @oTransport.Underruns()

	#-- private -------------------------------------------------------------

	def _Register(pName, paSlots, pnSecs)
		_free_ = []
		for _i_ = 1 to len(paSlots)
			_free_ + 0
		next
		@aVoices + [ lower("" + pName), paSlots, 1, 0, 0, pnSecs, _free_, 0 ]
		@aNames + ("" + pName)

	def _IndexOf(pName)
		_c_ = lower("" + pName)
		for _i_ = 1 to len(@aVoices)
			if @aVoices[_i_][1] = _c_  return _i_ ok
		next
		return 0

	# Render past every envelope so each slot is finished before the device
	# ever hears it. Cheaper and more honest than a gain of zero: the slot is
	# quiet because its shot is OVER, which is the state Fire() restarts from.
	# EVERY VOICE STARTS SPENT, and "spent" means EVERY voice, not most.
	#
	# A sound voice has no envelope to turn down -- it is silent because its
	# source has RUN OUT. So silencing means rendering the graph forward far
	# enough that the longest source has reached its end, and throwing the
	# result away.
	#
	# This rendered a fixed THREE SECONDS, which is fine for the blips a game
	# pool is made of and wrong for anything longer. A five-second spoken
	# announcement was left two seconds from its end, so the device opened
	# straight into the TAIL of the sentence -- you heard its last few words,
	# and then heard the whole sentence again when it was fired. Reported by
	# ear; no counter can see it, because playing a voice nobody triggered is
	# not a dropped frame.
	#
	# The pool already records every voice's duration, so the distance is
	# known rather than assumed. The margin covers the block boundary.
	def _SilenceAll()
		if NOT @oGraph.Prepare()  return ok
		_secs_ = 0.5
		for _i_ = 1 to len(@aVoices)
			if @aVoices[_i_][6] > _secs_  _secs_ = @aVoices[_i_][6] ok
		next
		_b_ = StzEngineSoundGraphToBuffer(@oGraph.GraphId(),
		                                  floor((_secs_ + 0.25) * @nRate))
		if _b_ != 0
			StzEngineSoundFree(_b_)
		ok
