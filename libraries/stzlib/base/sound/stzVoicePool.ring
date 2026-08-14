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

class stzVoicePool

	@oGraph = NULL
	@oTransport = NULL
	@nRate = 48000
	# [ name, [slotNode,...], nNext, nFires, nSteals, nSecs, [slotFreeAt,...] ]
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

	def init(pnRate)
		@nRate = pnRate
		if @nRate <= 0  @nRate = 48000 ok
		@oGraph = new stzSoundGraph()
		@oGraph.Reshape(2, @nRate)

	#-- building it ---------------------------------------------------------

	# A voice made from an existing sound. pnSlots is how many of it may
	# sound at the same time.
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

	# A voice made from an oscillator and an envelope -- a blip, a coin, a
	# beep. pnSeconds is how long one shot lasts.
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

	# Mix everything, open the device, and start rendering silence. From here
	# the graph's shape is frozen -- the two-phase contract -- and firing is
	# the only thing left that costs anything.
	def Start()
		if @bStarted  return This ok
		if len(@aVoices) = 0
			@cLastError = "Start: the pool has no voices"
			@nRefusals++
			return This
		ok
		_all_ = []
		for _v_ = 1 to len(@aVoices)
			_s_ = @aVoices[_v_][2]
			for _k_ = 1 to len(_s_)
				_all_ + _s_[_k_]
			next
		next
		@oGraph.AddMixOf(_all_)
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

	#-- using it ------------------------------------------------------------

	# Sound this voice, now. Round-robins the slots, so the same sound can
	# overlap itself up to as many times as it has slots.
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

	def Stop()
		if isObject(@oTransport)  @oTransport.Stop() ok
		@bStarted = FALSE
		return This

	def Release()
		This.Stop()
		if isObject(@oTransport)  @oTransport.Release() ok
		if isObject(@oGraph)  @oGraph.Release() ok

	#-- what it is doing ----------------------------------------------------

	def IsStarted()
		return @bStarted

	def Transport()
		return @oTransport

	def Graph()
		return @oGraph

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	def VoiceNames()
		return @aNames

	def SlotsOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return len(@aVoices[_i_][2])

	def FiresOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return @aVoices[_i_][4]

	# How many shots landed on a slot that was still sounding. Not an error --
	# it is the pool doing its job -- but a number worth seeing before
	# deciding a voice needs more slots.
	def StealsOf(pName)
		_i_ = This._IndexOf(pName)
		if _i_ = 0  return 0 ok
		return @aVoices[_i_][5]

	def PositionInSeconds()
		if NOT isObject(@oTransport)  return 0 ok
		return @oTransport.PositionInSeconds()

	def Underruns()
		if NOT isObject(@oTransport)  return 0 ok
		return @oTransport.Underruns()

	#-- private -------------------------------------------------------------

	def _Register(pName, paSlots, pnSecs)
		_free_ = []
		for _i_ = 1 to len(paSlots)
			_free_ + 0
		next
		@aVoices + [ lower("" + pName), paSlots, 1, 0, 0, pnSecs, _free_ ]
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
