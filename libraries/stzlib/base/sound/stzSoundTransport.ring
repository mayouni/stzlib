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

# NO CLOSURES IN RING (STZLIB-TRANSPORT-DRIVEWITH-01, fixed 2026-09-30). A
# reactive timer's callback cannot see a method's locals, so the first
# DriveWith -- which captured `_me_` -- failed with "uninitialized variable"
# on its first tick; it also asked RunEvery for 0.02, and RunEvery counts
# MILLISECONDS. Neither was ever guarded: the guard's "reactive" scene called
# RunToEnd. A driven transport is now registered by POINTER, and the timer
# calls one global function -- stzSoundLive's shape, found by MU3.
# (declared BEFORE the first func: Ring runs a loaded file's statements only
# up to its first definition, and a global after it is never created)
$aStzSoundTransportDriven = []

func StzSoundTransportOfQ(poGraph)
	return new stzSoundTransport(poGraph)

func StzSoundTransportTickAll()
	_a_ = $aStzSoundTransportDriven      # a copy: a Tick that ends the sound unregisters it
	for _p_ in _a_
		pointer2object(_p_).Tick()
	next

# Plays, pauses, resumes and stops a sound graph on the audio device, and keeps a clock the rest of the library can read.
#
# The legal moves are declared once in a state machine: stopped to playing, playing to paused,
# paused to playing, and playing or paused to stopped. Any other move is refused and counted, never
# obeyed. The position comes from the frames the device has consumed, not from a wall clock, so it
# cannot drift from what is heard. Pause and Stop fade the master gain over 10 ms first, because
# cutting the device is an audible click. There is no seek, only Rewind to the top. Play, PlayFor,
# Resume and RunFor open an audio device and were not run in this reference; the examples use only
# the refused moves of a stopped transport. Nobody has heard the fades (UNPERCEIVED).
#
#   receiver   o1 = new stzSoundTransport(StzSoundGraphOfQ(2, 44100).AddOscillatorQ(:Sine, 440,
#              0.5))
#   example    ? o1.State()
#              #--> stopped
#              o1.Pause()
#              ? o1.LastError()
#              #--> cannot pause while stopped
#              ? o1.Refusals()
#              #--> 1
#   see        stzSoundGraph, stzSoundScheduler, stzStateMachine
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

	# Builds a transport over a graph, with a master gain added for fades and a state machine that starts stopped.
	#
	#   poGraph    the stzSoundGraph to start, pause and stop
	#   returns    nothing; the object is built
	#   note       nothing starts and no device is opened here
	#   warning    a non-graph is refused, with LastError set; the master gain is added to the graph
	#              before it is prepared, which is why the graph gains a node
	#   see        StzSoundTransportOfQ, State
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

	# Returns what the transport is doing now.
	#
	#   returns    a text: stopped, playing or paused
	#   warning    stopped for a transport that was built without a graph
	#   see        IsPlaying, IsPaused, IsStopped
	#@ aka  -- what it is doing ----------------------------------------------------
	def State()
		if NOT isObject(@oFsm)  return "stopped" ok
		return @oFsm.CurrentState()

	# TRUE if the transport is in the playing state.
	#
	#   returns    TRUE or FALSE
	#   see        State, Play
	def IsPlaying()
		return This.State() = "playing"

	# TRUE if the transport is in the paused state.
	#
	#   returns    TRUE or FALSE
	#   see        State, Resume
	def IsPaused()
		return This.State() = "paused"

	# TRUE if the transport is in the stopped state, as it is when built.
	#
	#   returns    TRUE or FALSE
	#   see        State, Play
	def IsStopped()
		return This.State() = "stopped"

	# Returns the reason the last move was refused or failed, or an empty text.
	#
	#   returns    a text such as cannot pause while stopped
	#   warning    a successful move clears it
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many moves the state machine refused.
	#
	#   returns    a number
	#   warning    a transport that is driven wrongly says so in this number instead of misbehaving
	#   see        LastError
	#@ aka  How many moves the state machine refused. A transport that is being driven wrongly says so in a number rather than misbehaving quietly.
	def Refusals()
		return @nRefusals

	# Returns the frames the device has consumed, not the frames the graph has produced.
	#
	#   returns    a number of frames; 0 before any play
	#   warning    the producer runs a ring ahead of the device, so the device's count is what has
	#              been heard
	#   see        PositionInSeconds, Underruns
	#@ aka  -- THE CLOCK -----------------------------------------------------------
	def PositionInFrames()
		if @nStream = 0  return @nBaseFrames ok
		return @nBaseFrames + StzEngineSoundStreamFramesRead(@nStream)

	# Returns the device's position in seconds, from its frames and the graph's rate.
	#
	#   returns    a number of seconds
	#   see        PositionInFrames, SampleRate
	def PositionInSeconds()
		return This.PositionInFrames() / @nRate

	# Returns the sample rate of the graph the transport drives, in hertz.
	#
	#   returns    a number; 48000 when the transport was built without a graph
	#   see        PositionInSeconds
	def SampleRate()
		return @nRate

	# Returns the frames the producer could not supply in time.
	#
	#   returns    a number; 0 is the answer to want, and 0 when nothing is playing
	#   see        PositionInFrames
	#@ aka  Frames the producer could not supply in time. Zero is the answer you want, and it is counted rather than guessed.
	def Underruns()
		if @nStream = 0  return 0 ok
		return StzEngineSoundStreamUnderruns(@nStream)

	# Starts the graph on the audio device from the top and returns at once.
	#
	#   returns    the transport itself, so calls chain
	#   note       with no device the move is undone and LastError says there is no audio device
	#   warning    not run in this reference: it opens an audio device; from any state but stopped
	#              it is refused by the state machine, counted, and LastError names the state
	#   see        PlayFor, Pause, Stop
	#@ aka  -- the moves -----------------------------------------------------------
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

	# Starts the graph on the audio device and arranges for it to stop by itself after a number of seconds.
	#
	#   pnSeconds   how long to play before stopping
	#   returns     the transport itself, so calls chain
	#   note        a value of 0 or less means play until stopped
	#   warning     not run in this reference: it opens an audio device; the stop happens in Tick,
	#               so something must be ticking
	#   see         Play, RunFor
	#@ aka  Play, and stop by itself after pnSeconds. The stop happens in Tick(), so it needs someone to be ticking -- RunFor and DriveWith both do.
	def PlayFor(pnSeconds)
		This.Play()
		if This.IsPlaying()
			@nStopAtFrame = floor(pnSeconds * @nRate)
		ok
		return This

	def PlayForQ(pnSeconds)
		This.PlayFor(pnSeconds)
		return This

	# Fades the master gain to silence over 10 ms, closes the device and remembers the position.
	#
	#   returns    the transport itself, so calls chain
	#   note       the fade comes first, because cutting the device dead is an audible click
	#   warning    the move is refused and counted when the transport is not playing, which is the
	#              only case run in this reference
	#   see        Resume, Stop
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

	# Reopens the device after a pause, fades the master gain back up and goes on from where the graph was.
	#
	#   returns    the transport itself, so calls chain
	#   note       the graph is not rewound, so an envelope half way through its decay goes on
	#   warning    refused and counted unless the transport is paused, which is the only case run in
	#              this reference; its device path was not run
	#   see        Pause, Play
	#@ aka  The graph carries on from where it was: pausing did not rewind it, so an envelope half way through its decay is still half way through it.
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

	# Fades the master gain to silence, closes the device, takes the transport out of any reactive loop and calls the finished handler.
	#
	#   returns    the transport itself, so calls chain
	#   note       a stopped transport that was driven is no longer ticked
	#   warning    refused and counted when already stopped, which is the only case run in this
	#              reference
	#   see        Rewind, OnFinished
	def Stop()
		This._Undrive()
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

	# Takes the graph back to its top and the position back to 0, only while stopped.
	#
	#   returns    the transport itself, so calls chain
	#   note       there is no seek: the engine can only rewind to the start
	#   warning    refused and counted when not stopped, since rewinding under a running device is a
	#              jump
	#   see        Stop, PositionInFrames
	#@ aka  Back to the top: the graph rewinds and the clock goes with it. Only legal when stopped, because rewinding under a running device is a jump.
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

	# Reads the device position, calls the tick handler and stops the transport once the stop time passed to PlayFor is reached.
	#
	#   returns    the transport itself, so calls chain
	#   note       cheap enough to call as often as you like
	#   warning    does nothing unless the transport is playing, which is the only case run in this
	#              reference
	#   see        RunToEnd, DriveWith
	#@ aka  -- being driven --------------------------------------------------------
	def Tick()
		if NOT This.IsPlaying()  return This ok
		@nLastFrames = This.PositionInFrames()
		This._Fire(@fOnTick)
		if @nStopAtFrame > 0 and @nLastFrames >= @nStopAtFrame
			This.Stop()
		ok
		return This

	# Ticks every 20 ms until the transport is no longer playing.
	#
	#   returns    the transport itself, so calls chain
	#   note       blocks the calling thread while it plays
	#   warning    returns at once when the transport is not playing
	#   see        Tick, RunFor
	#@ aka  Tick until it stops, without a reactive loop. This DOES occupy the thread -- it is the honest version of PlayFor for a script that has nothing else to do, and it still reports the position while it runs.
	def RunToEnd()
		while This.IsPlaying()
			This.Tick()
			sleep(0.02)
		end
		return This

	# Plays for a number of seconds and waits, ticking, until the transport has stopped.
	#
	#   pnSeconds   how long to play
	#   returns     the transport itself, so calls chain
	#   note        it occupies the thread, like RunToEnd
	#   warning     not run in this reference: it opens an audio device
	#   see         PlayFor, RunToEnd
	def RunFor(pnSeconds)
		This.PlayFor(pnSeconds)
		This.RunToEnd()
		return This

	# Registers the transport so that a reactive loop steps it every 20 ms, alongside its other timers.
	#
	#   poReactive   the stzReactive whose loop should call the transport
	#   returns      the transport itself, so calls chain
	#   note         the transport is registered by pointer in a global list, and Stop or Release
	#                removes it
	#   warning      a non-reactive argument is refused, with LastError set and the refusal counted;
	#                registering twice adds it once; the loop was not run in this reference
	#   see          Tick, OnTick
	#@ aka  THE REACTIVE CONVERGENCE. The transport does not own a loop; it owns a STEP. Hand it a stzReactive and the loop that already exists calls the step, alongside every timer, stream and task that loop is already carrying -- which is the whole point of there being one loop.
	def DriveWith(poReactive)
		if NOT isObject(poReactive)
			@cLastError = "DriveWith needs a stzReactive"
			@nRefusals++
			return This
		ok
		_p_ = object2pointer(This)
		for _q_ in $aStzSoundTransportDriven
			if _q_ = _p_  return This ok          # driven already
		next
		$aStzSoundTransportDriven + _p_
		poReactive.RunEvery(20, func { StzSoundTransportTickAll() })
		return This

	def DriveWithQ(poReactive)
		This.DriveWith(poReactive)
		return This

	# Sets the function to call when the transport has started.
	#
	#   f          the function to call, with no arguments
	#   returns    the transport itself, so calls chain
	#   warning    a function that raises is swallowed silently
	#   see        OnFinished, OnTick
	#@ aka  -- what to call --------------------------------------------------------
	def OnStarted(f)
		@fOnStarted = f
		return This

	# Sets the function to call when the transport has stopped.
	#
	#   f          the function to call, with no arguments
	#   returns    the transport itself, so calls chain
	#   warning    a function that raises is swallowed silently
	#   see        OnStarted
	def OnFinished(f)
		@fOnFinished = f
		return This

	# Sets the function to call at every step of a playing transport.
	#
	#   f          the function to call, with no arguments
	#   returns    the transport itself, so calls chain
	#   warning    a function that raises is swallowed silently
	#   see        Tick, DriveWith
	def OnTick(f)
		@fOnTick = f
		return This

	# Takes the transport out of any reactive loop, closes the device and discards the state machine.
	#
	#   returns    nothing
	#   warning    afterwards State answers stopped
	#   see        Stop
	#@ aka  -- housekeeping --------------------------------------------------------
	def Release()
		This._Undrive()
		This._CloseDevice()
		if isObject(@oFsm)
			@oFsm.Destroy()
			@oFsm = NULL
		ok

	#-- private -------------------------------------------------------------

	# out of the driven list: a stopped or released transport is never ticked
	# through a pointer that may outlive it
	def _Undrive()
		_p_ = object2pointer(This)
		for _i_ = len($aStzSoundTransportDriven) to 1 step -1
			if $aStzSoundTransportDriven[_i_] = _p_  del($aStzSoundTransportDriven, _i_) ok
		next

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
