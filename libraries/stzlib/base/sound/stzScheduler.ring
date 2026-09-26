#---------------------------------------------------------------------------#
#  STZSCHEDULER -- a score, played live, every note at its frame (MU2)       #
#---------------------------------------------------------------------------#
#
#     oP = StzSchedulerQ(oScore)
#     oP.Play()                # returns at once; the notes are posted ahead
#     oP.RunToEnd()            # (no DriveWith yet: a live loop driven by the
#                              #  reactive plane is MU3's, and untested code is
#                              #  a claim without a guard)
#     ? oP.Late()              # notes that missed their frame -- 0, or a bug
#
# WHY A SCHEDULER AND NOT A LOOP OF triggerNode. MU0 spike 2 measured what the
# plane had: a request honoured at the top of the next block, worst 9.48 ms
# late. MU2's kill criterion is 1 ms. So the engine gained a TIMELINE node
# (soundgraph.zig), and this class does the one thing the timeline cannot do
# for itself: post each note BEFORE the producer thread reaches its frame.
#
# HOW FAR AHEAD, and the number is derived, not tuned. The producer renders up
# to a ring's worth (16384 frames, 341 ms) ahead of what the device has played,
# and it keeps doing so between two of our ticks. So a note must be posted at
# least a ring plus one tick before its frame. The lookahead is the ring plus
# half a second: a tick may be up to ~0.5 s late (a slow note render, a busy
# machine) before a single note is late -- and if one is, the engine COUNTS it
# and Late() says so.
#
# PRIME BEFORE START. The first engine test posted nothing until the stream
# ran, and its first note was late: the producer fills the whole ring the
# instant it starts. Play() posts the first window, THEN starts the device.
#
# THE NOTES ARE RENDERED FIRST, all of them, before anything plays. A wind
# instrument tunes itself by listening (MU1) and can take a large fraction of
# a second per note; doing that inside the playing loop would make the loop
# late by construction. A live loop that renders AS it plays is MU3's problem,
# and it is named there, not solved here by hoping.

func StzSchedulerQ(poScore)
	return new stzScheduler(poScore)

class stzScheduler

	@oScore = NULL
	@oR = NULL              # the renderer: notes, and where each one lands
	@oGraph = NULL
	@nTl = 0                # the timeline node
	@oT = NULL              # the transport, when playing on a device
	@nRing = 16384
	@nLookahead = 0         # frames; 0 = derive it (ring + 0.5 s)
	@nNext = 1              # the next plan entry to post
	@nPlaced = 0
	@nRefusedPosts = 0
	@nUnderruns = 0         # read from the device's ring while it still exists
	@cLastError = ""
	@nRefusals = 0
	@bPrepared = FALSE

	def init(poScore)
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		if NOT isObject(poScore)
			@cLastError = "a scheduler needs a stzScore"
			@nRefusals++
			return
		ok
		@oScore = poScore
		@oR = new stzScoreRenderer(poScore)

	#-- settings ------------------------------------------------------------

	# Frames of lookahead. Set it small only to PROVE the engine counts
	# lateness -- the negative sibling in the guard does exactly that.
	def SetLookahead(pnFrames)
		@nLookahead = pnFrames
		return This

	def Lookahead()
		if @nLookahead > 0  return @nLookahead ok
		return @nRing + floor(0.5 * @oR.Rate())

	def SetGain(pnGain)
		@oR.SetGain(pnGain)
		return This

	#-- the instruments' work, done first ----------------------------------

	def Prepare()
		if @bPrepared  return TRUE ok
		if NOT isObject(@oScore)  return FALSE ok
		_aP_ = @oR.Plan()
		if len(_aP_) = 0
			@cLastError = "the score has no notes that could be rendered: " + @oR.LastError()
			@nRefusals++
			return FALSE
		ok
		@oGraph = StzSoundGraphOfQ(@oR.Channels(), @oR.Rate())
		@nTl = @oGraph.AddTimeline()
		if @nTl = 0
			@cLastError = @oGraph.LastError()
			@nRefusals++
			return FALSE
		ok
		@bPrepared = TRUE
		return TRUE

	def NotesRendered()
		return @oR.NotesRendered()

	def SecondsRendering()
		return @oR.SecondsRendering()

	#-- live, on the device -------------------------------------------------

	def Play()
		if NOT This.Prepare()  return This ok
		@oT = StzSoundTransportOfQ(@oGraph)
		This._Post(This.Lookahead())               # prime, THEN start
		@oT.Play()
		if NOT @oT.IsPlaying()
			@cLastError = @oT.LastError()
			@nRefusals++
		ok
		return This

	def PlayQ()
		return This.Play()

	# Post what is due, let the transport keep its clock, and stop once the
	# last note has played out on the device.
	def Tick()
		if NOT isObject(@oT)  return This ok
		if NOT @oT.IsPlaying()  return This ok
		This._Post(This._Now() + This.Lookahead())
		@oT.Tick()
		@nUnderruns = @oT.Underruns()
		if @nNext > len(@oR.Plan()) and @oT.PositionInFrames() >= @oR.EndFrame()
			@oT.Stop()
		ok
		return This

	def IsPlaying()
		if NOT isObject(@oT)  return FALSE ok
		return @oT.IsPlaying()

	def RunToEnd()
		while This.IsPlaying()
			This.Tick()
			sleep(0.02)
		end
		return This

	#-- live, with no device ------------------------------------------------
	#
	# The SAME real-time path -- a producer thread rendering the graph into a
	# ring, this thread posting notes ahead of it -- with this thread also
	# draining the ring instead of a sound card. It runs as fast as the machine
	# can, which is HARDER for the scheduler than a device: the producer is
	# never waiting for the speaker. What comes out is returned as a sound, so
	# a guard can hold it against the offline render sample for sample.

	def RenderThroughRing()
		if NOT This.Prepare()  return NULL ok
		_total_ = @oR.EndFrame()
		_rate_ = @oR.Rate()
		_nch_ = @oR.Channels()
		_cap_ = new stzSound("")
		_cap_.MakeSilence(_total_ / _rate_, _nch_, _rate_)
		_total_ = _cap_.Frames()
		if NOT @oGraph.Prepare()
			@cLastError = @oGraph.LastError()
			@nRefusals++
			return NULL
		ok
		This._Post(This.Lookahead())               # prime, THEN start
		_s_ = StzEngineSoundStreamStart(@oGraph.GraphId(), @nRing)
		if _s_ = 0
			@cLastError = StzEngineSoundGraphLastError()
			@nRefusals++
			return NULL
		ok
		_chunk_ = 4096
		_tmp_ = StzEngineSoundNewSilent(_chunk_, _nch_, _rate_)
		_got_ = 0
		while _got_ < _total_
			This._Post(This._Now() + This.Lookahead())
			_want_ = _total_ - _got_
			if _want_ > _chunk_  _want_ = _chunk_ ok
			if StzEngineSoundStreamReadable(_s_) < _want_
				sleep(0.001)
				loop
			ok
			if _want_ < _chunk_
				StzEngineSoundFree(_tmp_)
				_tmp_ = StzEngineSoundNewSilent(_want_, _nch_, _rate_)
			ok
			StzEngineSoundStreamDrain(_s_, _want_, _tmp_)
			StzEngineSoundMixInto(_cap_.BufferId(), _tmp_, _got_ + 1, 1)
			_got_ += _want_
		end
		StzEngineSoundFree(_tmp_)
		StzEngineSoundStreamStop(_s_)
		return _cap_

	#-- what happened -------------------------------------------------------

	def Placed()
		return This._Ctr(0)

	# Notes whose frame the producer had already rendered when they arrived.
	def Late()
		return This._Ctr(1)

	def LateMaxInMs()
		_f_ = This._Ctr(2)
		if _f_ <= 0  return 0 ok
		return _f_ * 1000 / @oR.Rate()

	def PostsRefused()
		return @nRefusedPosts

	# Frames the device asked for and the ring could not supply, as of the
	# last tick -- the producer falling behind, which is a different failure
	# from a note posted late, and counted separately.
	def Underruns()
		return @nUnderruns

	def Plan()
		return @oR.Plan()

	def Renderer()
		return @oR

	def LastError()
		return @cLastError

	def Refusals()
		return @nRefusals

	# Free the notes. Only once nothing is playing: the timeline reads their
	# samples directly, and a freed note under a playing timeline is a read
	# of freed memory.
	def Release()
		if isObject(@oT)
			@oT.Stop()
			@oT.Release()
			@oT = NULL
		ok
		if isObject(@oGraph)
			@oGraph.Release()
			@oGraph = NULL
		ok
		if isObject(@oR)  @oR.Release() ok

	#-- private -------------------------------------------------------------

	def _Now()
		return StzEngineSoundGraphTimelineNow(@oGraph.GraphId(), @nTl)

	def _Ctr(pnWhich)
		if NOT isObject(@oGraph) or @nTl = 0  return 0 ok
		return StzEngineSoundGraphTimelineCounter(@oGraph.GraphId(), @nTl, pnWhich)

	# Post every planned note whose frame is before `pnUntil`. A refusal (all
	# 512 slots busy) leaves the note to be posted on the next tick rather
	# than dropping it; if that makes it late, Late() counts it.
	def _Post(pnUntil)
		_aP_ = @oR.Plan()
		_n_ = len(_aP_)
		while @nNext <= _n_
			_p_ = _aP_[@nNext]
			if _p_[1] >= pnUntil  exit ok
			if StzEngineSoundGraphTimelinePlace(@oGraph.GraphId(), @nTl, _p_[2],
			                                    _p_[1] + 1, @oR.Gain()) != 0
				@nRefusedPosts++
				@cLastError = StzEngineSoundGraphLastError()
				exit
			ok
			@nPlaced++
			@nNext++
		end
