#---------------------------------------------------------------------------#
#  STZLIVE -- live loops: redefine one while it plays, and the change lands  #
#  on the next cycle, never in the middle of one (MU3)                       #
#---------------------------------------------------------------------------#
#
#     oL = StzLiveQ(120)                         # a cycle is one bar: 4 beats
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

$aStzLiveSessions = []

func StzLiveQ(pnBpm)
	_o_ = new stzLive()     # WITH the parentheses: bare "new stzLive" does not run init
	_o_.SetTempo(pnBpm)
	return _o_

# The one function a reactive timer calls: every session that asked to be
# driven gets one tick.
func StzLiveTickAll()
	for _p_ in $aStzLiveSessions
		pointer2object(_p_).Tick()
	next

class stzLive

	@nTempo = 120
	@nRate = 48000
	@nCh = 2
	@nRing = 16384
	@cDefault = "piano"
	@oClock = NULL          # a stzScore used only for its FrameOf -- one arithmetic
	@oR = NULL              # the renderer: each distinct note once
	@oGraph = NULL
	@nTl = 0
	@oT = NULL              # the transport, on a device
	@bRunning = FALSE
	@aLoops = []            # [ name, tag, [ [fromCycle, pattern|NULL, instrument, version] ], nextCycle ]
	@aLedger = []           # [ cycle, name, version ] -- what was POSTED for a cycle
	@aConsole = []          # [ cycle, heardFrame, text ] -- what was HEARD
	@aLandings = []         # [ name, version, landingCycle, heardCycleAtCall ]
	@nHeardCycle = -1
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

	def init()
		@oClock = StzScoreQ()
		@oR = new stzScoreRenderer(@oClock)

	#-- settings ------------------------------------------------------------

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
		@oR = new stzScoreRenderer(@oClock)
		return This

	def Tempo()
		return @nTempo

	def SetDefaultInstrument(pcName)
		@cDefault = lower("" + pcName)
		return This

	# Drain the ring here instead of on a sound card, for `pnSeconds` at most,
	# and keep what came out. Paced: drain at the wall clock's rate; unpaced:
	# as fast as WaitCycles asks.
	#
	# WHAT IT CANNOT STAND IN FOR: a device drains on ITS OWN thread, so while
	# this thread is busy rendering a new loop's notes the card keeps playing
	# what was posted. Here THIS thread is the consumer, so it stalls with the
	# render and nothing is consumed. Whether a render while playing costs a
	# note its frame is therefore a DEVICE question, and the guard asks it on
	# the device.
	def CaptureInsteadOfDevice(pnSeconds, pbPaced)
		if @bRunning
			This._Refuse("CaptureInsteadOfDevice: choose before the loops start")
			return This
		ok
		@bCapture = TRUE
		@bPaced = pbPaced
		@nCapSeconds = pnSeconds
		return This

	def Capture()
		return @oCap

	def OnCycle(f)
		@fOnCycle = f
		return This

	#-- the loops -----------------------------------------------------------

	# Define or redefine a loop. Returns the cycle it lands on (0-based), or
	# -1 when refused -- and a refused redefinition leaves the old one playing.
	#
	# NAMED LiveLoop, NOT Loop. The plan's section 4 writes oM.Loop(...), and
	# that line cannot be written in Ring: `loop` is a keyword (it is Ring's
	# `continue`), and a method may not take its name. LiveLoop is also Sonic
	# Pi's word for the same thing (live_loop).
	def LiveLoop(pName, pcPattern)
		return This.LiveLoopOn(pName, pcPattern, "")

	def LiveLoopOn(pName, pcPattern, pInstrument)
		_oP_ = StzPatternQ(pcPattern)
		if NOT _oP_.IsValid()
			This._Refuse("Loop " + pName + ": " + _oP_.LastError())
			return -1
		ok
		return This._Define(lower("" + pName), _oP_, "" + pInstrument)

	# A loop given a pattern object -- one already transformed by the algebra.
	def LiveLoopOf(pName, poPattern, pInstrument)
		if NOT isObject(poPattern) or NOT poPattern.IsValid()
			This._Refuse("LiveLoopOf: needs a valid stzPattern")
			return -1
		ok
		return This._Define(lower("" + pName), poPattern, "" + pInstrument)

	# The plan's line: every n cycles, the loop transformed. A redefinition
	# like any other -- it lands on a boundary.
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

	# Stop one loop at the next boundary it can land on.
	def Silence(pName)
		_c_ = lower("" + pName)
		_i_ = This._LoopIndex(_c_)
		if _i_ = 0
			This._Refuse("Silence: no loop named '" + pName + "'")
			return -1
		ok
		return This._Land(_i_, NULL, "")

	def Hush()
		_k_ = -1
		for _i_ = 1 to len(@aLoops)
			_k_ = This._Land(_i_, NULL, "")
		next
		return _k_

	#-- running -------------------------------------------------------------

	def Start()
		if @bRunning  return TRUE ok
		if len(@aLoops) = 0
			This._Refuse("Start: there are no loops yet")
			return FALSE
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

	# Post what is due, drain (capture mode), and report what is heard.
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

	# Play for `pnCycles` more cycles of HEARD time, ticking all the while.
	def WaitCycles(pnCycles)
		if NOT @bRunning
			if NOT This.Start()  return This ok
		ok
		_target_ = This.HeardFrames() + floor(pnCycles * This.CycleFrames() + 0.5)
		while This.HeardFrames() < _target_
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

	# The reactive plane drives it instead: one timer, every 20 ms, for every
	# session registered -- see StzLiveTickAll above for why it is global.
	def DriveWith(poReactive)
		if NOT isObject(poReactive)
			This._Refuse("DriveWith needs a stzReactive")
			return This
		ok
		if NOT @bRunning
			if NOT This.Start()  return This ok
		ok
		$aStzLiveSessions + object2pointer(This)
		poReactive.RunEvery(20, func { StzLiveTickAll() })
		return This

	def Stop()
		for _i_ = len($aStzLiveSessions) to 1 step -1
			if $aStzLiveSessions[_i_] = object2pointer(This)
				del($aStzLiveSessions, _i_)
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
		return This

	# Free the notes and the graph -- only once stopped: the timeline reads
	# the notes' samples directly.
	def Release()
		This.Stop()
		if isObject(@oGraph)
			@oGraph.Release()
			@oGraph = NULL
		ok
		@oR.Release()

	#-- what happened -------------------------------------------------------

	def IsRunning()
		return @bRunning

	def CycleFrames()
		return 4 * 60 / @nTempo * @nRate

	def FrameOfCycle(pnCycle)
		return @oClock.FrameOf(4 * pnCycle, @nRate)

	# Frames the listener has been given: the device's consumed frames, or
	# what capture mode has drained.
	def HeardFrames()
		if @bCapture  return @nHeard ok
		if isObject(@oT)  return @oT.PositionInFrames() ok
		return 0

	def HeardCycle()
		return @nHeardCycle

	def RenderFrames()
		if @nTl = 0  return 0 ok
		return StzEngineSoundGraphTimelineNow(@oGraph.GraphId(), @nTl)

	# [ cycle, heardFrame, text ] -- one line per cycle as it was HEARD
	def ConsoleLog()
		return @aConsole

	def Ledger()
		return @aLedger

	# [ name, version, landingCycle, heardCycleAtCall ]
	def Landings()
		return @aLandings

	def Late()
		return This._Ctr(1)

	def Cancelled()
		return This._Ctr(6)

	# Withdrawals the engine refused because the note was already sounding --
	# a change that would have landed MID-CYCLE. MU3's kill criterion is that
	# this stays 0.
	def MidCycleChanges()
		return This._Ctr(7)

	def NotesRenderedLive()
		return @nRenderedLive

	def SecondsRendering()
		return @nSecondsRendering

	def DrainShortfall()
		return @nDrainShort

	def Underruns()
		return @nUnderruns

	def OnDevice()
		return NOT @bCapture

	def Renderer()
		return @oR

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	#-- private -------------------------------------------------------------

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
		_oI_ = StzInstrumentQ(_inst_)
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
			@aLoops + [ pcName, @nTagNext, [], 0 ]
			@nTagNext++
			_i_ = len(@aLoops)
		ok
		return This._Land(_i_, poPattern, _inst_)

	# Put a new version on loop i from the first cycle it can land on.
	def _Land(pnI, poPattern, pcInst)
		_K_ = 0
		if @bRunning  _K_ = This._LandingCycle() ok
		_aV_ = @aLoops[pnI][3]
		_ver_ = len(_aV_) + 1
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
			_ver_ = 1
			if len(_aV_) > 0  _ver_ = _aV_[len(_aV_)][4] + 1 ok
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
