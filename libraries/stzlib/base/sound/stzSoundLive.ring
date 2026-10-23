#---------------------------------------------------------------------------#
#  STZLIVE -- live loops: redefine one while it plays, and the change lands  #
#  on the next cycle, never in the middle of one (MU3)                       #
#---------------------------------------------------------------------------#
#
#     oL = StzSoundLiveQ(120)                         # a cycle is one bar: 4 beats
#     oL.LiveLoop(:beat, "bd hh sn hh")          # the drum names itself
#     oL.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
#     oL.WaitCycles(4)                           # it plays; this returns after 4
#     ? oL.LiveLoopOn(:tune, "a4 c5 e5 c5", :Harp)   # -> the cycle it lands on
#     oL.WaitCycles(4)
#     oL.Stop()
#
# StzMusicQ() carries the same verbs (LiveLoop, Every, Silence, Hush, WaitCycles,
# Stop), so the plan's section-4 lines read as written.
#
# THE UNIT OF LIVENESS IS A CYCLE, and the rule is Sonic Pi's and Tidal's (plan
# 1.1): a redefinition lands at a cycle boundary. Here that is not a promise, it
# is how posting works. A loop's notes are posted a WHOLE cycle at a time, well
# ahead of the render; a redefinition WITHDRAWS that loop's notes from the
# first cycle the producer has not reached (the engine's timelineCancel, which
# refuses -- and counts -- any note already sounding), and reposts from that
# cycle with the new pattern. So the change lands on the first boundary the
# render has not passed. Loop() returns that cycle; nothing is guessed.
#
# THE CONSOLE READS WHAT IS HEARD, NOT WHAT IS POSTED. Notes are posted a ring
# (341 ms) plus a cycle plus half a second ahead of what the speaker is
# playing. A console that printed "cycle 5" when cycle 5 was POSTED would run
# more than a cycle ahead of the sound -- the disagreement VC4 paid for, and
# MU3's kill criterion. So OnCycle and the console log fire when the frames the
# device has CONSUMED cross a cycle boundary, and they report the LEDGER --
# what was posted for that cycle -- not the latest definition.
#
# RENDERING WHILE PLAYING, which MU2 avoided on purpose. Loop() renders the
# new pattern's notes (every distinct note over its period) BEFORE it touches
# what is playing; while it does, the already-posted cycles keep sounding. The
# horizon is deep enough (a ring + a cycle + 0.5 s) that a render of that long
# costs no note its frame -- and if one did, the engine counts it as late.
#
# NO CLOSURES IN RING. A reactive timer's callback cannot see a local, so
# DriveWith registers this session by POINTER in a global list and the timer
# calls one global function. (stzSoundTransport.DriveWith captured a local
# `_me_` and fails with "uninitialized variable" the first time it fires --
# found by MU3, and routed rather than changed here.)

$aStzSoundLiveSessions = []

func StzSoundLiveQ(pnBpm)
	_o_ = new stzSoundLive()     # WITH the parentheses: bare "new stzSoundLive" does not run init
	_o_.SetTempo(pnBpm)
	return _o_

# The one function a reactive timer calls: every session that asked to be
# driven gets one tick.
func StzSoundLiveTickAll()
	for _p_ in $aStzSoundLiveSessions
		pointer2object(_p_).Tick()
	next

# Runs named live loops that can be redefined while they play, each change landing on the next cycle boundary.
#
# A cycle is one bar of 4 beats. A loop's notes are posted a whole cycle at a time, well ahead of
# the render; a redefinition withdraws the loop's notes from the first cycle the producer has not
# reached and posts the new pattern from there, and the call returns that cycle. The console reports
# what was heard, not what was posted. Without CaptureInsteadOfDevice the session plays on a sound
# card through a transport, which was not run in this reference; with it, a producer thread renders
# into a ring that this session drains into a buffer, so no device is opened. In capture mode a wait
# longer than the buffer is cut where the buffer ends, and the cut is a refusal. The sound has not
# been heard by a person (UNPERCEIVED): it is checked by frame count, sample rate and peak level, not
# by listening.
#
#   receiver   o1 = StzSoundLiveQ(120)
#   example    o1.CaptureInsteadOfDevice(6, FALSE)
#              ? o1.OnDevice()
#              #--> 0
#              ? o1.LiveLoopOn(:tune, "c5 e5 g5 e5", :Harp)
#              #--> 0
#              o1.WaitCycles(1)
#              ? o1.HeardCycle()
#              #--> 1
#              ? o1.ConsoleLog()[1][3]
#              #--> cycle 0 | tune v1
#              o1.Stop()
#   see        stzMusic, stzSoundPattern, stzSoundTransport
class stzSoundLive

	@nTempo = 120
	@nRate = 48000
	@nCh = 2
	@nRing = 16384
	@cDefault = "piano"
	@oClock = NULL          # a stzSoundScore used only for its FrameOf -- one arithmetic
	@oR = NULL              # the renderer: each distinct note once
	@oGraph = NULL
	@nTl = 0
	@oT = NULL              # the transport, on a device
	@bRunning = FALSE
	@aLoops = []            # [ name, tag, [ [fromCycle, pattern|NULL, instrument, version] ], nextCycle, lastVersion ]
	@aLedger = []           # [ cycle, name, version ] -- what was POSTED for a cycle
	@aConsole = []          # [ cycle, heardFrame, text ] -- what was HEARD
	@aLandings = []         # [ name, version, landingCycle, heardCycleAtCall ]
	@nHeardCycle = -1
	@bStopped = 0           # a running performance was stopped: the next Start begins a clean run
	@fOnCycle = NULL
	@nTagNext = 1
	@nRenderedLive = 0      # notes rendered while playing (a pattern past its period)
	@nSecondsRendering = 0
	@cLastError = ""
	@nRefusals = 0
	# capture mode: the ring drained here instead of by a device
	@bCapture = FALSE
	@bPaced = FALSE
	@nCapSeconds = 0
	@oCap = NULL
	@nStream = 0
	@nHeard = 0
	@nT0 = 0
	@nDrainShort = 0        # paced capture: frames that were due and not there
	@nUnderruns = 0         # on a device: frames the card asked for and did not get
	@nWaitSlack = 30        # seconds a wait may overrun its own length before it gives up (monotonic clock)

	# Builds a live session at 120 beats per minute with no loops, started on a sound card unless capture is chosen.
	#
	#   returns    nothing; the object is built
	#   warning    build it with StzSoundLiveQ to set the speed in the same call; a cycle is one bar
	#              of 4 beats
	#   see        StzSoundLiveQ, CaptureInsteadOfDevice
	def init()
		@oClock = StzSoundScoreQ()
		@oR = new stzSoundScoreRenderer(@oClock)

	# Sets the speed of the session in beats per minute.
	#
	#   pnBpm      the speed in beats per minute, from 20 to 400
	#   returns    the session itself, so calls chain
	#   note       it builds a new renderer, because the notes of a loop are rendered at the speed
	#              in force
	#   warning    refused, with LastError set and the refusal counted, once the session runs, once
	#              any loop is defined, or for a value outside the range
	#   see        Tempo, CycleFrames
	#@ aka  -- settings ------------------------------------------------------------
	def SetTempo(pnBpm)
		if @bRunning
			This._Refuse("SetTempo: the tempo is set before the loops start -- a live tempo change is not in MU3")
			return This
		ok
		if NOT isNumber(pnBpm) or pnBpm < 20 or pnBpm > 400
			This._Refuse("SetTempo: beats per minute, 20 to 400")
			return This
		ok
		if len(@aLoops) > 0
			This._Refuse("SetTempo: set the tempo before the first Loop -- its notes are already rendered at this one")
			return This
		ok
		@nTempo = pnBpm
		@oClock.Tempo(pnBpm)
		# A NEW renderer: Ring COPIES an object handed to init, so the old
		# renderer holds its own clock and would never see this tempo
		@oR = new stzSoundScoreRenderer(@oClock)
		return This

	# Returns the speed of the session in beats per minute.
	#
	#   returns    a number, 120 until set
	#   see        SetTempo
	def Tempo()
		return @nTempo

	# Sets the instrument given to loops that name none and are made of pitched notes.
	#
	#   pcName     the instrument name, such as piano or harp, kept in lower case
	#   returns    the session itself, so calls chain
	#   note       an unknown name is refused later, when a loop is defined with it
	#   warning    a loop of strokes ignores it and takes the drum kit, or the darbouka for dum, tak
	#              and ka
	#   see        LiveLoop, LiveLoopOn
	def SetDefaultInstrument(pcName)
		@cDefault = lower("" + pcName)
		return This

	# Chooses to drain the sound into a buffer instead of a sound card, for at most a number of seconds.
	#
	#   pnSeconds   the length of the buffer that keeps what came out, a number above 0
	#   pbPaced     TRUE to drain at the pace of the wall clock, FALSE to drain as fast as
	#               WaitCycles asks
	#   returns     the session itself, so calls chain
	#   note        this is the only way to run the session without opening an audio device; a
	#               device drains on its own thread, so a render in capture mode stalls the drain
	#               and proves nothing about late notes; a second call before the start replaces
	#               the first
	#   warning     refused, with LastError set and the refusal counted, once the loops have started
	#               and for a length that is not a number above 0; the buffer is silent beyond what
	#               was heard, and a wait that would pass its end is cut there
	#   see         Capture, WaitCycles, OnDevice
	#@ aka  Drain the ring here instead of on a sound card, for `pnSeconds` at most, and keep what came out. Paced: drain at the wall clock's rate; unpaced: as fast as WaitCycles asks.
	def CaptureInsteadOfDevice(pnSeconds, pbPaced)
		if @bRunning
			This._Refuse("CaptureInsteadOfDevice: choose before the loops start")
			return This
		ok
		if NOT isNumber(pnSeconds) or pnSeconds <= 0
			This._Refuse("CaptureInsteadOfDevice: the length is a number of seconds above 0")
			return This
		ok
		@bCapture = TRUE
		@bPaced = pbPaced
		@nCapSeconds = pnSeconds
		return This

	# Returns the buffer that capture mode fills with what has been heard.
	#
	#   returns    a stzSound of the length given to CaptureInsteadOfDevice, with the same rate and
	#              channels as the session; an empty text before the loops start or when capture was
	#              not chosen
	#   warning    read it after WaitCycles; the sound has not been heard by a person
	#   see        CaptureInsteadOfDevice
	def Capture()
		return @oCap

	# Sets the function called each time a cycle boundary is heard, with the console line of that cycle.
	#
	#   f          the function, or its name, to call with one text argument
	#   returns    the session itself, so calls chain
	#   warning    it fires when the frames consumed cross a cycle boundary, not when the cycle is
	#              posted, so the console never runs ahead of the sound
	#   see        ConsoleLog, HeardCycle
	def OnCycle(f)
		@fOnCycle = f
		return This

	# Defines or redefines a loop from a pattern, naming the instrument itself.
	#
	#   pName       the loop's name, kept in lower case
	#   pcPattern   a pattern of note names and strokes, such as c5 e5 g5 e5 or bd hh sn hh
	#   returns     the cycle the loop lands on, counted from 0; -1 when refused
	#   note        a redefinition lands on the first cycle boundary the producer has not reached
	#   warning     a bad pattern, an unknown instrument, strokes on an instrument that is not
	#               struck or notes on a drum are refused with LastError set and the old version
	#               goes on playing; before the loops start a redefinition replaces and lands on
	#               cycle 0
	#   see         LiveLoopOn, LiveLoopOf, Silence
	#@ aka  -- the loops -----------------------------------------------------------
	def LiveLoop(pName, pcPattern)
		return This.LiveLoopOn(pName, pcPattern, "")

	# Defines or redefines a loop from a pattern, played on a chosen instrument.
	#
	#   pName         the loop's name, kept in lower case
	#   pcPattern     a pattern of note names and strokes
	#   pInstrument   the instrument name, or an empty text for the session's default
	#   returns       the cycle the loop lands on, counted from 0; -1 when refused
	#   note          while running, the notes of the loop from the landing cycle on are withdrawn
	#                 and posted again
	#   warning       refused like LiveLoop; every distinct note is rendered before anything already
	#                 posted is touched
	#   see           LiveLoop, LiveLoopOf
	def LiveLoopOn(pName, pcPattern, pInstrument)
		_oP_ = StzSoundPatternQ(pcPattern)
		if NOT _oP_.IsValid()
			This._Refuse("Loop " + pName + ": " + _oP_.LastError())
			return -1
		ok
		return This._Define(lower("" + pName), _oP_, "" + pInstrument)

	# Defines or redefines a loop from a pattern object that has already been transformed.
	#
	#   pName         the loop's name, kept in lower case
	#   poPattern     a valid stzSoundPattern
	#   pInstrument   the instrument name, or an empty text for the default
	#   returns       the cycle the loop lands on, counted from 0; -1 when refused
	#   warning       anything but a valid stzSoundPattern is refused, with LastError set
	#   see           LiveLoopOn
	#@ aka  A loop given a pattern object -- one already transformed by the algebra.
	def LiveLoopOf(pName, poPattern, pInstrument)
		if NOT isObject(poPattern) or NOT poPattern.IsValid()
			This._Refuse("LiveLoopOf: needs a valid stzSoundPattern")
			return -1
		ok
		return This._Define(lower("" + pName), poPattern, "" + pInstrument)

	# Redefines a loop as itself transformed every so many cycles.
	#
	#   pnN        the period of the transform in cycles
	#   pName      the name of an existing loop
	#   pXform     the transform to apply, such as rev
	#   returns    the cycle the loop lands on; -1 when refused
	#   note       the change lands on a cycle boundary like any redefinition
	#   warning    an unknown loop, a silenced loop or a transform the pattern refuses is refused
	#              with LastError set; the playing version is not touched
	#   see        LiveLoop, Silence
	#@ aka  The plan's line: every n cycles, the loop transformed. A redefinition like any other -- it lands on a boundary.
	def Every(pnN, pName, pXform)
		_i_ = This._LoopIndex(lower("" + pName))
		if _i_ = 0
			This._Refuse("Every: no loop named '" + pName + "'")
			return -1
		ok
		_aV_ = @aLoops[_i_][3]
		_last_ = _aV_[len(_aV_)]
		if isNull(_last_[2])
			This._Refuse("Every: '" + pName + "' is silent")
			return -1
		ok
		_oP_ = _last_[2]          # a COPY -- the playing version is untouched
		_oP_.Every(pnN, pXform)
		if _oP_.Refusals() > _last_[2].Refusals()
			This._Refuse("Every: " + _oP_.LastError())
			return -1
		ok
		return This._Define(lower("" + pName), _oP_, _last_[3])

	# Stops one loop from the first cycle boundary it can land on.
	#
	#   pName      the name of the loop to silence
	#   returns    the cycle on which the loop falls silent; -1 for an unknown loop
	#   warning    the loop stays defined and can be redefined later
	#   see        Hush, LiveLoop
	#@ aka  Stop one loop at the next boundary it can land on.
	def Silence(pName)
		_c_ = lower("" + pName)
		_i_ = This._LoopIndex(_c_)
		if _i_ = 0
			This._Refuse("Silence: no loop named '" + pName + "'")
			return -1
		ok
		return This._Land(_i_, NULL, "")

	# Silences every loop at the first cycle boundary each can land on.
	#
	#   returns    the cycle of the last loop's landing; -1 when there are no loops
	#   see        Silence
	def Hush()
		_k_ = -1
		for _i_ = 1 to len(@aLoops)
			_k_ = This._Land(_i_, NULL, "")
		next
		return _k_

	# Posts the first window of notes and starts the performance, on a sound card or into the capture buffer.
	#
	#   returns    TRUE if running; FALSE with LastError set when there are no loops or the engine
	#              refused
	#   note       asking again while running answers TRUE; starting again after Stop begins a clean
	#              run: the heard cycle is back to -1, the console and the ledger are emptied, every
	#              loop posts from cycle 0 in the version it has now, and the capture buffer is
	#              replaced, while the loops, the landings and the version numbers are kept
	#   warning    without CaptureInsteadOfDevice it opens an audio device through a transport,
	#              which was not run in this reference
	#   see        WaitCycles, DriveWith, Stop
	#@ aka  -- running -------------------------------------------------------------
	def Start()
		if @bRunning  return TRUE ok
		if len(@aLoops) = 0
			This._Refuse("Start: there are no loops yet")
			return FALSE
		ok
		if @bStopped
			This._StartClean()
		ok
		@oGraph = StzSoundGraphOfQ(@nCh, @nRate)
		@nTl = @oGraph.AddTimeline()
		if @nTl = 0
			This._Refuse(@oGraph.LastError())
			return FALSE
		ok
		This._Post()                              # PRIME, then start (MU2)
		if @bCapture
			if NOT @oGraph.Prepare()
				This._Refuse(@oGraph.LastError())
				return FALSE
			ok
			@oCap = new stzSound("")
			@oCap.MakeSilence(@nCapSeconds, @nCh, @nRate)
			@nStream = StzEngineSoundStreamStart(@oGraph.GraphId(), @nRing)
			if @nStream = 0
				This._Refuse(StzEngineSoundGraphLastError())
				return FALSE
			ok
			@nHeard = 0
			@nT0 = clock()
		else
			@oT = StzSoundTransportOfQ(@oGraph)
			This._Post()
			@oT.Play()
			if NOT @oT.IsPlaying()
				This._Refuse(@oT.LastError())
				return FALSE
			ok
		ok
		@bRunning = TRUE
		This._Heard()
		return TRUE

	# Posts what is due, drains the ring in paced capture mode and reports the cycles heard.
	#
	#   returns    the session itself, so calls chain
	#   note       a reactive loop calls it every 20 ms for a driven session
	#   warning    does nothing unless the session runs
	#   see        WaitCycles, DriveWith
	#@ aka  Post what is due, drain (capture mode), and report what is heard.
	def Tick()
		if NOT @bRunning  return This ok
		This._Post()
		if @bCapture and @bPaced
			_due_ = floor((clock() - @nT0) / clockspersecond() * @nRate)
			This._Drain(_due_ - @nHeard)
		ok
		if NOT @bCapture
			@oT.Tick()
			@nUnderruns = @oT.Underruns()
		ok
		This._Heard()
		return This

	# Lets the session run for a number of heard cycles, starting it first when needed, and then returns.
	#
	#   pnCycles   how many cycles of heard time to wait, a number from 0 up
	#   returns    the session itself, so calls chain
	#   note       the wait counts heard frames, not posted ones; in capture mode a wait that would
	#              pass the end of the buffer is cut there, with LastError set and the refusal
	#              counted, and what is heard is the whole buffer
	#   warning    a wait that does not move for 30 seconds more than its own length gives up the
	#              same way, with the refusal counted; a text or a negative number is refused;
	#              without capture it plays on a device, which was not run in this reference
	#   see        Start, Tick, CaptureInsteadOfDevice
	#@ aka  Play for `pnCycles` more cycles of HEARD time, ticking all the while.
	def WaitCycles(pnCycles)
		if NOT isNumber(pnCycles) or pnCycles < 0
			This._Refuse("WaitCycles: the number of cycles is a number from 0 up")
			return This
		ok
		if NOT @bRunning
			if NOT This.Start()  return This ok
		ok
		_target_ = This.HeardFrames() + floor(pnCycles * This.CycleFrames() + 0.5)
		if @bCapture and _target_ > @oCap.Frames()
			# the buffer cannot hold what was asked: wait for what it can hold
			_target_ = @oCap.Frames()
			This._Refuse("WaitCycles: the capture buffer of " + @nCapSeconds + " s ends before " + pnCycles +
			             " more cycles -- the wait was cut at its end, at frame " + _target_)
		ok
		# a deadline on the monotonic clock: a wait that cannot move gives up instead of spinning
		_nT0_ = StzEngineWatchTimestampNs()
		_nWait_ = _target_ - This.HeardFrames()
		if _nWait_ < 0  _nWait_ = 0 ok
		_nLimit_ = @nWaitSlack + 4 * _nWait_ / @nRate
		while This.HeardFrames() < _target_
			if (StzEngineWatchTimestampNs() - _nT0_) / 1000000000 > _nLimit_
				This._Refuse("WaitCycles: gave up after " + _nLimit_ + " s with " + This.HeardFrames() +
				             " of " + _target_ + " frames heard")
				exit
			ok
			This._Post()
			if @bCapture
				if @bPaced
					_due_ = floor((clock() - @nT0) / clockspersecond() * @nRate)
					if _due_ > _target_  _due_ = _target_ ok
					This._Drain(_due_ - @nHeard)
					sleep(0.002)
				else
					_want_ = _target_ - @nHeard
					if _want_ > 4096  _want_ = 4096 ok
					if StzEngineSoundStreamReadable(@nStream) >= _want_
						This._Drain(_want_)
					else
						sleep(0.001)
					ok
				ok
			else
				@oT.Tick()
				@nUnderruns = @oT.Underruns()
				sleep(0.005)
			ok
			This._Heard()
		end
		return This

	# Starts the session when needed and registers it so that a reactive loop steps it every 20 ms.
	#
	#   poReactive   the stzReactive whose loop should call the session
	#   returns      the session itself, so calls chain
	#   note         the session is registered by pointer in a global list and Stop removes it
	#   warning      anything but a stzReactive is refused, with LastError set; the reactive loop
	#                itself was not run in this reference
	#   see          Tick, Stop
	#@ aka  The reactive plane drives it instead: one timer, every 20 ms, for every session registered -- see StzSoundLiveTickAll above for why it is global.
	def DriveWith(poReactive)
		if NOT isObject(poReactive)
			This._Refuse("DriveWith needs a stzReactive")
			return This
		ok
		if NOT @bRunning
			if NOT This.Start()  return This ok
		ok
		$aStzSoundLiveSessions + object2pointer(This)
		poReactive.RunEvery(20, func { StzSoundLiveTickAll() })
		return This

	# Takes the session out of any reactive loop and stops the performance, keeping the loops and the logs.
	#
	#   returns    the session itself, so calls chain
	#   note       the heard frames, the heard cycle, the console, the ledger and the capture buffer
	#              stay readable until the next Start, which begins a clean run
	#   warning    does nothing to a session that is not running
	#   see        Release, Start
	def Stop()
		for _i_ = len($aStzSoundLiveSessions) to 1 step -1
			if $aStzSoundLiveSessions[_i_] = object2pointer(This)
				del($aStzSoundLiveSessions, _i_)
			ok
		next
		if NOT @bRunning  return This ok
		if @bCapture
			StzEngineSoundStreamStop(@nStream)
			@nStream = 0
		else
			@oT.Stop()
			@oT.Release()
			@oT = NULL
		ok
		@bRunning = FALSE
		@bStopped = 1
		return This

	# Stops the session, then frees the graph and the rendered notes.
	#
	#   returns    nothing
	#   warning    call it once nothing is playing, since the timeline reads the note samples
	#              directly
	#   see        Stop
	#@ aka  Free the notes and the graph -- only once stopped: the timeline reads the notes' samples directly.
	def Release()
		This.Stop()
		if isObject(@oGraph)
			@oGraph.Release()
			@oGraph = NULL
		ok
		@oR.Release()

	# TRUE if the performance has started and not been stopped.
	#
	#   returns    TRUE or FALSE
	#   see        Start, Stop
	#@ aka  -- what happened -------------------------------------------------------
	def IsRunning()
		return @bRunning

	# Returns how many frames one cycle of 4 beats lasts at the session's speed.
	#
	#   returns    a number of frames; 96000 at 120 beats per minute and 48000 Hz
	#   see        FrameOfCycle, Tempo
	def CycleFrames()
		return 4 * 60 / @nTempo * @nRate

	# Returns the frame at which a cycle begins.
	#
	#   pnCycle    the cycle number, counted from 0
	#   returns    a number of frames, counted from 0
	#   warning    computed with the same function the offline render uses
	#   see        CycleFrames
	def FrameOfCycle(pnCycle)
		return @oClock.FrameOf(4 * pnCycle, @nRate)

	# Returns the frames the listener has been given: those the device consumed, or those capture mode drained.
	#
	#   returns    a number of frames; 0 before the loops start
	#   warning    it can pass a cycle boundary by a few hundred frames, since draining is done in
	#              chunks
	#   see        HeardCycle, RenderFrames
	#@ aka  Frames the listener has been given: the device's consumed frames, or what capture mode has drained.
	def HeardFrames()
		if @bCapture  return @nHeard ok
		if isObject(@oT)  return @oT.PositionInFrames() ok
		return 0

	# Returns the number of the last cycle whose boundary has been heard.
	#
	#   returns    a number counted from 0; -1 before any
	#   see        ConsoleLog, OnCycle
	def HeardCycle()
		return @nHeardCycle

	# Returns how far the producer has rendered the timeline, in frames.
	#
	#   returns    a number of frames; 0 before the loops start
	#   warning    it runs ahead of HeardFrames by about a ring, a cycle and half a second
	#   see        HeardFrames
	def RenderFrames()
		if @nTl = 0  return 0 ok
		return StzEngineSoundGraphTimelineNow(@oGraph.GraphId(), @nTl)

	# Returns one row per cycle as it was heard.
	#
	#   returns    a list of [ cycle, heardFrame, text ] rows, the text such as cycle 1 and each
	#              loop with its version
	#   warning    the text reports what was posted for that cycle, not the latest definition
	#   see        Ledger, OnCycle
	#@ aka  [ cycle, heardFrame, text ] -- one line per cycle as it was HEARD
	def ConsoleLog()
		return @aConsole

	# Returns what was posted for each cycle.
	#
	#   returns    a list of [ cycle, loop name, version ] rows
	#   warning    rows for cycles from a landing cycle on are dropped when a loop is redefined and
	#              posted again
	#   see        ConsoleLog, Landings
	def Ledger()
		return @aLedger

	# Returns where each definition of a loop took effect.
	#
	#   returns    a list of [ loop name, version, landing cycle, cycle heard when it was asked ]
	#              rows, in the order the definitions were made
	#   note       the version of a loop counts its definitions, one row each, and never goes back:
	#              a loop defined three times before the start and once while running has v1, v2, v3
	#              and v4
	#   warning    before the loops start every landing is cycle 0 and the heard cycle is -1, and
	#              only the last definition made before the start is ever heard
	#   see        Ledger, LiveLoop
	#@ aka  [ name, version, landingCycle, heardCycleAtCall ]
	def Landings()
		return @aLandings

	# Returns how many notes reached the timeline after the producer had rendered their frame.
	#
	#   returns    a number; 0 is the answer to want
	#   warning    0 before the loops start
	#   see        Cancelled, MidCycleChanges
	def Late()
		return This._Ctr(1)

	# Returns how many notes were withdrawn before they sounded, by a redefinition.
	#
	#   returns    a number
	#   note       the engine applies a withdrawal on its own thread, so read it a cycle after the
	#              redefinition: read at once it can still be 0
	#   warning    measured: redefining a four-note loop at heard cycle 1 withdrew 4 notes
	#   see        MidCycleChanges
	def Cancelled()
		return This._Ctr(6)

	# Returns the withdrawals the engine refused because the note was already sounding, which would be a change in the middle of a cycle.
	#
	#   returns    a number; it should stay 0
	#   warning    it is the kill criterion of the live design
	#   see        Cancelled
	#@ aka  Withdrawals the engine refused because the note was already sounding -- a change that would have landed MID-CYCLE. MU3's kill criterion is that this stays 0.
	def MidCycleChanges()
		return This._Ctr(7)

	# Returns how many notes were rendered while the session was playing, because a pattern ran past its first period.
	#
	#   returns    a number
	#   see        SecondsRendering
	def NotesRenderedLive()
		return @nRenderedLive

	# Returns the wall time spent rendering the notes of the loops, in seconds.
	#
	#   returns    a number
	#   see        NotesRenderedLive
	def SecondsRendering()
		return @nSecondsRendering

	# Returns the frames that paced capture was due to drain and the ring did not yet hold.
	#
	#   returns    a number; 0 outside paced capture
	#   see        CaptureInsteadOfDevice, Underruns
	def DrainShortfall()
		return @nDrainShort

	# Returns the frames the sound card asked for and did not get, as of the last step.
	#
	#   returns    a number; 0 in capture mode
	#   see        DrainShortfall
	def Underruns()
		return @nUnderruns

	# TRUE if the session plays on a sound card, FALSE if capture was chosen.
	#
	#   returns    TRUE or FALSE; TRUE for a new session
	#   see        CaptureInsteadOfDevice
	def OnDevice()
		return NOT @bCapture

	# Returns the renderer that holds the notes of the loops.
	#
	#   returns    a stzSoundScoreRenderer
	#   see        stzSoundScoreRenderer
	def Renderer()
		return @oR

	# Returns the reason the last call was refused, or an empty text.
	#
	#   returns    a text
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many calls the session has refused.
	#
	#   returns    a number
	#   see        LastError
	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

	# A stopped session is started again: forget the run that ended, keep what was defined.
	# The loops keep their names, tags and version numbers, and each plays from cycle 0 in the
	# version it has now (a redefinition made while running is the loop's version for the new run);
	# the refusals count and the landings are the session's, not the run's.
	def _StartClean()
		@bStopped = 0
		if isObject(@oGraph)
			@oGraph.Release()
		ok
		@oGraph = NULL
		@nTl = 0
		@nHeardCycle = -1
		@aConsole = []
		@aLedger = []
		@nHeard = 0
		@nDrainShort = 0
		@nUnderruns = 0
		@nRenderedLive = 0
		@cLastError = ""
		_nLoops_ = len(@aLoops)
		for _i_ = 1 to _nLoops_
			_aV_ = @aLoops[_i_][3]
			_last_ = _aV_[len(_aV_)]
			@aLoops[_i_][3] = [ [ 0, _last_[2], _last_[3], _last_[4] ] ]
			@aLoops[_i_][4] = 0
		next

	def _Refuse(pcWhy)
		@nRefusals++
		@cLastError = pcWhy

	def _Ctr(pnWhich)
		if @nTl = 0  return 0 ok
		return StzEngineSoundGraphTimelineCounter(@oGraph.GraphId(), @nTl, pnWhich)

	def _LoopIndex(pcName)
		for _i_ = 1 to len(@aLoops)
			if @aLoops[_i_][1] = pcName  return _i_ ok
		next
		return 0

	def _Define(pcName, poPattern, pcInstrument)
		_inst_ = lower(pcInstrument)
		if _inst_ = ""
			_inst_ = @cDefault
			if poPattern.IsAllStrokes()
				_inst_ = "drumkit"
				if poPattern.HasStroke("dum") or poPattern.HasStroke("tak") or poPattern.HasStroke("ka")
					_inst_ = "darbouka"
				ok
			ok
		ok
		_oI_ = StzSoundInstrumentQ(_inst_)
		if NOT _oI_.IsUsable()
			This._Refuse("Loop " + pcName + ": " + _oI_.LastError())
			return -1
		ok
		# strokes need a drum; notes need a pitch
		_bStrokes_ = FALSE
		_bNotes_ = FALSE
		for _n_ in poPattern.DistinctNotes(poPattern.Period())
			if _n_[1] = "stroke"  _bStrokes_ = TRUE else _bNotes_ = TRUE ok
		next
		if _bStrokes_ and _oI_.Engine() != "membrane"
			This._Refuse("Loop " + pcName + ": strokes need a drum, and " + _inst_ + " is not struck")
			return -1
		ok
		if _bNotes_ and _oI_.PitchClass() = "none"
			This._Refuse("Loop " + pcName + ": " + _inst_ + " has no pitch -- give it strokes")
			return -1
		ok
		# RENDER FIRST, while what is posted keeps playing
		_t0_ = clock()
		for _n_ in poPattern.DistinctNotes(poPattern.Period())
			if This._Buffer(_n_[1], _n_[2], _n_[3], _inst_) = 0
				This._Refuse("Loop " + pcName + ": " + @oR.LastError())
				return -1
			ok
		next
		@nSecondsRendering += (clock() - _t0_) / clockspersecond()

		_i_ = This._LoopIndex(pcName)
		if _i_ = 0
			@aLoops + [ pcName, @nTagNext, [], 0, 0 ]
			@nTagNext++
			_i_ = len(@aLoops)
		ok
		return This._Land(_i_, poPattern, _inst_)

	# Put a new version on loop i from the first cycle it can land on.
	def _Land(pnI, poPattern, pcInst)
		_K_ = 0
		if @bRunning  _K_ = This._LandingCycle() ok
		# the version counts the definitions of this loop and never goes back, started or not
		_ver_ = @aLoops[pnI][5] + 1
		@aLoops[pnI][5] = _ver_
		if @bRunning
			StzEngineSoundGraphTimelineCancel(@oGraph.GraphId(), @nTl, @aLoops[pnI][2],
			                                  This.FrameOfCycle(_K_) + 1)
			# the cycles from K were posted with the old version; post them again
			if @aLoops[pnI][4] > _K_  @aLoops[pnI][4] = _K_ ok
			# and the ledger forgets what it said about them
			for _j_ = len(@aLedger) to 1 step -1
				if @aLedger[_j_][2] = @aLoops[pnI][1] and @aLedger[_j_][1] >= _K_
					del(@aLedger, _j_)
				ok
			next
		else
			# before the start, a redefinition simply replaces
			@aLoops[pnI][3] = []
		ok
		@aLoops[pnI][3] + [ _K_, poPattern, pcInst, _ver_ ]
		@aLandings + [ @aLoops[pnI][1], _ver_, _K_, @nHeardCycle ]
		This._Post()
		return _K_

	# The first cycle whose start the producer has not rendered, with a margin
	# for the blocks it may render while this thread is withdrawing: 0.1 s,
	# more than the 4096 frames a drain can free plus a block.
	def _LandingCycle()
		_now_ = This.RenderFrames() + 4800 + 512
		_c_ = floor(_now_ / This.CycleFrames())
		while This.FrameOfCycle(_c_) < _now_  _c_++ end
		return _c_

	# Post every loop's cycles whose START falls before the horizon.
	def _Post()
		if @nTl = 0  return ok
		_h_ = This.RenderFrames() + @nRing + This.CycleFrames() + floor(0.5 * @nRate)
		for _i_ = 1 to len(@aLoops)
			while This.FrameOfCycle(@aLoops[_i_][4]) < _h_
				This._PostCycle(_i_, @aLoops[_i_][4])
				@aLoops[_i_][4]++
			end
		next

	def _PostCycle(pnI, pnC)
		_aV_ = @aLoops[pnI][3]
		_v_ = 0
		for _j_ = 1 to len(_aV_)
			if _aV_[_j_][1] <= pnC  _v_ = _j_ ok
		next
		if _v_ = 0  return ok
		@aLedger + [ pnC, @aLoops[pnI][1], _aV_[_v_][4] ]
		if isNull(_aV_[_v_][2])  return ok
		_inst_ = _aV_[_v_][3]
		_tag_ = @aLoops[pnI][2]
		for _e_ in @aLoops[pnI][3][_v_][2].CycleEvents(pnC)
			_n0_ = @oR.NotesRendered()
			_b_ = This._Buffer(_e_[3], _e_[4], _e_[2], _inst_)
			if @oR.NotesRendered() > _n0_  @nRenderedLive++ ok
			if _b_ = 0  loop ok
			_f_ = @oClock.FrameOf(4 * (pnC + _e_[1]), @nRate)
			if StzEngineSoundGraphTimelinePlaceTagged(@oGraph.GraphId(), @nTl, _b_,
			                                          _f_ + 1, @oR.Gain(), _tag_) != 0
				This._Refuse("a note could not be placed: " + StzEngineSoundGraphLastError())
			ok
		next

	# one note, rendered once: [ start, beats, hz, instrument, velocity, stroke ]
	def _Buffer(pcKind, pcName, pnLen, pcInst)
		if pcKind = "stroke"
			return @oR.BufferFor([ 0, 4 * pnLen, 0, pcInst, 0.8, pcName ])
		ok
		return @oR.BufferFor([ 0, 4 * pnLen, StzNoteToHz(pcName), pcInst, 0.8, "" ])

	def _Drain(pnFrames)
		if pnFrames <= 0  return ok
		_room_ = @oCap.Frames() - @nHeard
		if pnFrames > _room_  pnFrames = _room_ ok
		if pnFrames <= 0  return ok
		_avail_ = StzEngineSoundStreamReadable(@nStream)
		if _avail_ < pnFrames
			@nDrainShort += pnFrames - _avail_
			pnFrames = _avail_
		ok
		if pnFrames <= 0  return ok
		_tmp_ = StzEngineSoundNewSilent(pnFrames, @nCh, @nRate)
		StzEngineSoundStreamDrain(@nStream, pnFrames, _tmp_)
		StzEngineSoundMixInto(@oCap.BufferId(), _tmp_, @nHeard + 1, 1)
		StzEngineSoundFree(_tmp_)
		@nHeard += pnFrames

	# Heard cycle boundaries crossed since the last look: one console line
	# each, from the LEDGER.
	def _Heard()
		_h_ = This.HeardFrames()
		while _h_ >= This.FrameOfCycle(@nHeardCycle + 1)
			@nHeardCycle++
			_txt_ = "cycle " + @nHeardCycle
			for _l_ in @aLoops
				_ver_ = 0
				for _e_ in @aLedger
					if _e_[1] = @nHeardCycle and _e_[2] = _l_[1]  _ver_ = _e_[3] ok
				next
				if _ver_ > 0  _txt_ += " | " + _l_[1] + " v" + _ver_ ok
			next
			@aConsole + [ @nHeardCycle, _h_, _txt_ ]
			if NOT isNull(@fOnCycle)
				_f_ = @fOnCycle
				call _f_(_txt_)
			ok
		end
