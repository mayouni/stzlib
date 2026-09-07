#---------------------------------------------------------------------------#
#  STZSOUNDTRANSPORT -- play, pause, resume, stop. And a CLOCK the rest of   #
#  the library can read.                                                     #
#---------------------------------------------------------------------------#
#
#     oT = StzSoundTransportOfQ(oGraph)
#     oT.Play()                       # returns AT ONCE -- nothing blocks
#     while oT.IsPlaying()
#         oT.Tick()                   # or let the reactive plane call it
#         ? oT.PositionInSeconds()
#     end
#
#     oT.PlayForQ(5).DriveWith(oRx)   # the reactive loop ticks it instead
#
# WHY THIS IS NOT stzSoundGraph.PlayFor(). PlayFor sleeps for the length of
# the sound, which means nothing else in the program happens while it plays --
# no UI, no game loop, no reading the position, no stopping early. That is
# fine for a demo and useless for anything that has to keep running. The
# transport owns the same three engine handles and never sleeps.
#
# THREE THINGS THIS PHASE IS ABOUT (SN6, the convergence dividend):
#
# 1. THE STATE MACHINE IS NOT DECORATION. "Resume something that was never
#    paused" is refused by stzStateMachine, not by an if-ladder that drifts
#    away from the comment above it. The legal moves are DECLARED once, as
#    five transitions, and the refusals are counted.
#
# 2. THE CLOCK IS THE DEVICE'S, NOT THE WALL'S. Position comes from the frames
#    the device has actually CONSUMED, so it cannot drift away from what you
#    are hearing. A wall clock started at Play() drifts the moment the machine
#    is busy, and drifts in the direction that looks fine in a demo and wrong
#    in a recording. This is the shared clock the game plane will read.
#
# 3. PAUSE IS A RAMP, NOT A SWITCH. Cutting the device dead is the click SN3
#    measured at 480 times the size of a ramped one, and plate 2 of the sound
#    gallery draws it as a stripe across every frequency. So pause fades the
#    master gain over 10 ms first, and resume fades it back.
#
# WHAT IT DOES NOT DO. There is no seek: the engine can rewind a graph to the
# top but cannot start it from the middle, and a Seek() that silently meant
# "back to zero" would be a lie. Recorded, not hidden.

func StzSoundTransportOfQ(poGraph)
	return new stzSoundTransport(poGraph)

class stzSoundTransport

	@oGraph = NULL
	@oFsm = NULL
	@nStream = 0
	@nDevice = 0
	@nMaster = 0            # the gain node a pause fades
	@nRate = 48000
	@nStopAtFrame = 0       # 0 = play until stopped
	@nBaseFrames = 0        # frames consumed before the current stream started
	@nLastFrames = 0
	@cLastError = ""
	@nRefusals = 0
	@nFadeMs = 10

	# what to call, and when
	@fOnStarted = NULL
	@fOnFinished = NULL
	@fOnTick = NULL

	def init(poGraph)
		if NOT isObject(poGraph)
			@cLastError = "a transport needs a stzSoundGraph"
			return
		ok
		@oGraph = poGraph
		@nRate = poGraph.SampleRate()

		# the master gain goes in BEFORE prepare, because the graph's shape is
		# frozen the moment it is prepared -- the two-phase contract
		@nMaster = poGraph.AddMasterGain()

		@oFsm = new stzStateMachine("transport" + poGraph.GraphId())
		@oFsm.AddStates([ :stopped, :playing, :paused ])
		# the ONLY legal moves. Everything else is a counted refusal.
		@oFsm.AddTransitions([
			[ :stopped, :play,   :playing ],
			[ :playing, :pause,  :paused  ],
			[ :paused,  :resume, :playing ],
			[ :playing, :stop,   :stopped ],
			[ :paused,  :stop,   :stopped ] ])
		@oFsm.SetState(:stopped)

	#-- what it is doing ----------------------------------------------------

	def State()
		if NOT isObject(@oFsm)  return "stopped" ok
		return @oFsm.CurrentState()

	def IsPlaying()
		return This.State() = "playing"

	def IsPaused()
		return This.State() = "paused"

	def IsStopped()
		return This.State() = "stopped"

	def LastError()
		return @cLastError

	# How many moves the state machine refused. A transport that is being
	# driven wrongly says so in a number rather than misbehaving quietly.
	def Refusals()
		return @nRefusals

	#-- THE CLOCK -----------------------------------------------------------
	#
	# Frames the DEVICE has consumed, not frames the graph has produced: the
	# producer runs ahead by a ring's worth, so asking it would report a
	# position up to a third of a second in the future. What the listener has
	# heard is what the device has taken.

	def PositionInFrames()
		if @nStream = 0  return @nBaseFrames ok
		return @nBaseFrames + StzEngineSoundStreamFramesRead(@nStream)

	def PositionInSeconds()
		return This.PositionInFrames() / @nRate

	def SampleRate()
		return @nRate

	# Frames the producer could not supply in time. Zero is the answer you
	# want, and it is counted rather than guessed.
	def Underruns()
		if @nStream = 0  return 0 ok
		return StzEngineSoundStreamUnderruns(@nStream)

	#-- the moves -----------------------------------------------------------

	def Play()
		if NOT This._Move(:play)  return This ok
		@nBaseFrames = 0
		@nStopAtFrame = 0
		if NOT This._OpenDevice()
			This._Move(:stop)
			return This
		ok
		This._Fire(@fOnStarted)
		return This

	def PlayQ()
		This.Play()
		return This

	# Play, and stop by itself after pnSeconds. The stop happens in Tick(),
	# so it needs someone to be ticking -- RunFor and DriveWith both do.
	def PlayFor(pnSeconds)
		This.Play()
		if This.IsPlaying()
			@nStopAtFrame = floor(pnSeconds * @nRate)
		ok
		return This

	def PlayForQ(pnSeconds)
		This.PlayFor(pnSeconds)
		return This

	def Pause()
		if NOT This._Move(:pause)  return This ok
		# the fade FIRST, then the silence -- the other order is the click
		This._RampMasterTo(0.0)
		sleep(@nFadeMs / 1000)
		@nBaseFrames = This.PositionInFrames()
		This._CloseDevice()
		return This

	def PauseQ()
		This.Pause()
		return This

	# The graph carries on from where it was: pausing did not rewind it, so
	# an envelope half way through its decay is still half way through it.
	def Resume()
		if NOT This._Move(:resume)  return This ok
		if NOT This._OpenDevice()
			This._Move(:stop)
			return This
		ok
		This._RampMasterTo(1.0)
		return This

	def ResumeQ()
		This.Resume()
		return This

	def Stop()
		if NOT This._Move(:stop)  return This ok
		This._RampMasterTo(0.0)
		sleep(@nFadeMs / 1000)
		@nBaseFrames = This.PositionInFrames()
		This._CloseDevice()
		This._Fire(@fOnFinished)
		return This

	def StopQ()
		This.Stop()
		return This

	# Back to the top: the graph rewinds and the clock goes with it. Only
	# legal when stopped, because rewinding under a running device is a jump.
	def Rewind()
		if NOT This.IsStopped()
			@cLastError = "Rewind: stop first -- rewinding a running graph is a jump"
			@nRefusals++
			return This
		ok
		@oGraph.Rewind()
		@nBaseFrames = 0
		return This

	def RewindQ()
		This.Rewind()
		return This

	#-- being driven --------------------------------------------------------

	# One step. Cheap on purpose: it reads a counter and decides whether the
	# sound has run out. Call it as often as you like.
	def Tick()
		if NOT This.IsPlaying()  return This ok
		@nLastFrames = This.PositionInFrames()
		This._Fire(@fOnTick)
		if @nStopAtFrame > 0 and @nLastFrames >= @nStopAtFrame
			This.Stop()
		ok
		return This

	# Tick until it stops, without a reactive loop. This DOES occupy the
	# thread -- it is the honest version of PlayFor for a script that has
	# nothing else to do, and it still reports the position while it runs.
	def RunToEnd()
		while This.IsPlaying()
			This.Tick()
			sleep(0.02)
		end
		return This

	def RunFor(pnSeconds)
		This.PlayFor(pnSeconds)
		This.RunToEnd()
		return This

	# THE REACTIVE CONVERGENCE. The transport does not own a loop; it owns a
	# STEP. Hand it a stzReactive and the loop that already exists calls the
	# step, alongside every timer, stream and task that loop is already
	# carrying -- which is the whole point of there being one loop.
	def DriveWith(poReactive)
		if NOT isObject(poReactive)
			@cLastError = "DriveWith needs a stzReactive"
			@nRefusals++
			return This
		ok
		_me_ = This
		poReactive.RunEvery(0.02, func { _me_.Tick() })
		return This

	def DriveWithQ(poReactive)
		This.DriveWith(poReactive)
		return This

	#-- what to call --------------------------------------------------------

	def OnStarted(f)
		@fOnStarted = f
		return This

	def OnFinished(f)
		@fOnFinished = f
		return This

	def OnTick(f)
		@fOnTick = f
		return This

	#-- housekeeping --------------------------------------------------------

	def Release()
		This._CloseDevice()
		if isObject(@oFsm)
			@oFsm.Destroy()
			@oFsm = NULL
		ok

	#-- private -------------------------------------------------------------

	# Ask the state machine, and READ WHETHER IT MOVED.
	#
	# stzStateMachine refuses an event it has no transition for by STAYING PUT
	# and returning the state it is still in -- it does not raise. The first
	# draft of this method assumed a raise, caught nothing, and treated every
	# refusal as a success: "resume" from stopped opened a second device on a
	# graph that already had one, and the process died on the spot. A face that
	# reads a return value it did not check is a face that will do that.
	#
	# This works because NO legal move here is a self-loop -- every one of the
	# five transitions leaves the state it started in. Add a self-loop and this
	# test stops distinguishing "went round" from "refused"; declare it in a
	# counter instead if that day comes.
	def _Move(pEvent)
		if NOT isObject(@oFsm)  return FALSE ok
		_was_ = @oFsm.CurrentState()
		_now_ = @oFsm.Send("" + pEvent)
		if _now_ = _was_
			@nRefusals++
			@cLastError = "cannot " + pEvent + " while " + _was_
			return FALSE
		ok
		@cLastError = ""
		return TRUE

	def _OpenDevice()
		if NOT @oGraph.Prepare()
			@cLastError = @oGraph.LastError()
			return FALSE
		ok
		if NOT StzAudioDevEngineLoaded() or StzEngineAudioDevIsAvailable() = 0
			@cLastError = "no audio device on this machine"
			return FALSE
		ok
		@nStream = StzEngineSoundStreamStart(@oGraph.GraphId(), 16384)
		if @nStream = 0
			@cLastError = StzEngineSoundGraphLastError()
			return FALSE
		ok
		sleep(0.12)             # let the producer get ahead of the device
		@nDevice = StzEngineAudioDevPlaybackOpen(
			StzEngineSoundStreamRingPtr(@nStream), 256)
		if @nDevice = 0
			@cLastError = StzEngineAudioDevLastError()
			StzEngineSoundStreamStop(@nStream)
			@nStream = 0
			return FALSE
		ok
		StzEngineAudioDevPlaybackStart(@nDevice)
		return TRUE

	# CONSUMER FIRST, ALWAYS. The device callback reads the ring; the producer
	# owns it. Free the ring while a callback is still in flight and the
	# reader is dereferencing freed memory.
	def _CloseDevice()
		if @nDevice != 0
			StzEngineAudioDevPlaybackStop(@nDevice)
			StzEngineAudioDevPlaybackClose(@nDevice)
			@nDevice = 0
		ok
		if @nStream != 0
			StzEngineSoundStreamStop(@nStream)
			@nStream = 0
		ok

	def _RampMasterTo(pnGain)
		if @nMaster = 0  return ok
		StzEngineSoundGraphSetGain(@oGraph.GraphId(), @nMaster, pnGain, @nFadeMs)

	def _Fire(f)
		if isNull(f)  return ok
		try
			call f()
		catch
		done
