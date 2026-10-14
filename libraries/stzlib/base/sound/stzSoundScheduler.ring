#---------------------------------------------------------------------------#
#  STZSCHEDULER -- a score, played live, every note at its frame (MU2)       #
#---------------------------------------------------------------------------#
#
#     oP = StzSoundSchedulerQ(oScore)
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

func StzSoundSchedulerQ(poScore)
	return new stzSoundScheduler(poScore)

# Plays a score live, posting each note to an engine timeline just before its frame.
#
# The notes are rendered first, all of them, so no instrument tunes itself while the performance
# runs. Notes are then posted a ring plus half a second ahead of the producer, and the engine counts
# any that still arrive after their frame in Late. Play and RunToEnd use a sound card through a
# transport and were not run in this reference. RenderThroughRing runs the same real-time path with
# this thread draining the ring instead of a card, so it opens no device, and its output matched the
# offline render of the same score at every 97th sample. The sound has not been heard by a person
# (UNPERCEIVED): it is checked by frame count, sample rate and peak level, not by listening.
#
#   receiver   o1 = StzSoundSchedulerQ(StzSoundScoreOfQ("c e g c5"))
#   example    ? o1.Lookahead()
#              #--> 40384
#              ? o1.Prepare()
#              #--> 1
#              ? len(o1.Plan())
#              #--> 4
#              ? o1.RenderThroughRing().Frames()
#              #--> 115200
#              ? o1.Late()
#              #--> 0
#   see        stzSoundScore, stzSoundScoreRenderer, stzSoundTransport
class stzSoundScheduler

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

	# Builds a scheduler over a score, with a renderer for its notes and nothing started.
	#
	#   poScore    the stzSoundScore to perform
	#   returns    nothing; the object is built
	#   warning    anything but an object is refused, with LastError set, and the scheduler then
	#              holds no score; a library without the sound engine does the same
	#   see        StzSoundSchedulerQ, Prepare
	def init(poScore)
		if NOT StzSoundEngineLoaded()
			@cLastError = "stz_sound.dll is not loaded"
			return
		ok
		if NOT isObject(poScore)
			@cLastError = "a scheduler needs a stzSoundScore"
			@nRefusals++
			return
		ok
		@oScore = poScore
		@oR = new stzSoundScoreRenderer(poScore)

	# Sets how many frames ahead of the producer each note must be posted.
	#
	#   pnFrames   the lookahead in frames
	#   returns    the scheduler itself, so calls chain
	#   warning    a very small value is meant to prove that the engine counts notes that arrive
	#              after their frame
	#   see        Lookahead, Late
	#@ aka  -- settings ------------------------------------------------------------
	def SetLookahead(pnFrames)
		@nLookahead = pnFrames
		return This

	# Returns how many frames ahead of the producer notes are posted.
	#
	#   returns    a number of frames; the ring size plus half a second, 40384 at 48000 Hz, until
	#              SetLookahead changes it
	#   see        SetLookahead
	def Lookahead()
		if @nLookahead > 0  return @nLookahead ok
		return @nRing + floor(0.5 * @oR.Rate())

	# Sets the factor applied to every note when it is placed on the timeline.
	#
	#   pnGain     the gain per note, 0.6 by default
	#   returns    the scheduler itself, so calls chain
	#   warning    it changes the renderer's gain, which is read each time a note is posted
	#   see        stzSoundScoreRenderer
	def SetGain(pnGain)
		@oR.SetGain(pnGain)
		return This

	# Renders every note of the score and builds the graph with its timeline, once.
	#
	#   returns    TRUE if the scheduler is ready; FALSE for a score with no renderable note
	#   note       the notes are rendered first so that no instrument tunes itself while the
	#              performance runs
	#   warning    asking again answers TRUE without rendering again; a score of no notes is
	#              refused, with LastError set
	#   see        Plan, RenderThroughRing
	#@ aka  -- the instruments' work, done first ----------------------------------
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

	# Returns how many distinct notes the instruments have rendered.
	#
	#   returns    a number
	#   warning    a note that recurs counts once, but only after Prepare has run
	#   see        SecondsRendering, Plan
	def NotesRendered()
		return @oR.NotesRendered()

	# Returns the wall time spent rendering the notes, in seconds.
	#
	#   returns    a number
	#   see        NotesRendered
	def SecondsRendering()
		return @oR.SecondsRendering()

	# Posts the first window of notes, starts the score on the audio device and returns at once.
	#
	#   returns    the scheduler itself
	#   note       RunToEnd or Tick must follow to keep posting notes
	#   warning    not run in this reference: it opens an audio device through a transport; a
	#              refusal by the transport is copied into LastError and counted
	#   see        Tick, RunToEnd, RenderThroughRing
	#@ aka  -- live, on the device -------------------------------------------------
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

	# Posts the notes that have come due, keeps the transport's clock and stops it after the last note has played out.
	#
	#   returns    the scheduler itself
	#   note       cheap enough to call as often as you like
	#   warning    does nothing unless Play has started a transport; its device path was not run in
	#              this reference
	#   see        RunToEnd, Play
	#@ aka  Post what is due, let the transport keep its clock, and stop once the last note has played out on the device.
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

	# TRUE if a transport started by Play is still running.
	#
	#   returns    TRUE or FALSE; FALSE before Play
	#   see        Play, Tick
	def IsPlaying()
		if NOT isObject(@oT)  return FALSE ok
		return @oT.IsPlaying()

	# Ticks every 20 ms until the transport has stopped.
	#
	#   returns    the scheduler itself
	#   note       blocks the calling thread until the last note has played out
	#   warning    returns at once when nothing is running, which is the only case run in this
	#              reference
	#   see        Tick, Play
	def RunToEnd()
		while This.IsPlaying()
			This.Tick()
			sleep(0.02)
		end
		return This

	# Performs the score through the real-time path with no sound card and returns what came out as a sound.
	#
	#   returns    a stzSound as long as the score's last note; NULL for a score with no renderable
	#              note
	#   note       it runs faster than a device would, which is harder for the scheduler; the sound
	#              has not been heard by a person
	#   warning    a producer thread renders the graph into a ring while this thread posts notes
	#              ahead of it and drains the ring, so no audio device is opened; the result matched
	#              the offline render at every 97th sample
	#   see        Prepare, Late
	#@ aka  -- live, with no device ------------------------------------------------
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

	# Returns how many notes have been posted to the timeline.
	#
	#   returns    a number; 0 before anything is posted
	#   warning    read from the engine's timeline counters
	#   see        Late, PostsRefused
	#@ aka  -- what happened -------------------------------------------------------
	def Placed()
		return This._Ctr(0)

	# Returns how many notes reached the timeline after the producer had rendered their frame.
	#
	#   returns    a number; 0 is the answer to want
	#   warning    read from the engine's timeline counters
	#   see        LateMaxInMs, SetLookahead
	#@ aka  Notes whose frame the producer had already rendered when they arrived.
	def Late()
		return This._Ctr(1)

	# Returns the worst lateness of any note, in milliseconds.
	#
	#   returns    a number of milliseconds; 0 when no note was late
	#   see        Late
	def LateMaxInMs()
		_f_ = This._Ctr(2)
		if _f_ <= 0  return 0 ok
		return _f_ * 1000 / @oR.Rate()

	# Returns how many times the timeline refused a note because all its 512 slots were busy.
	#
	#   returns    a number
	#   warning    a refused note is retried on the next tick, not dropped
	#   see        Placed
	def PostsRefused()
		return @nRefusedPosts

	# Returns the frames the device asked for and the ring could not supply, as of the last Tick.
	#
	#   returns    a number; 0 when nothing has played on a device
	#   warning    the producer falling behind, counted apart from a note posted late
	#   see        Late
	#@ aka  Frames the device asked for and the ring could not supply, as of the last tick -- the producer falling behind, which is a different failure from a note posted late, and counted separately.
	def Underruns()
		return @nUnderruns

	# Returns one row per event giving the frame it starts at and the buffer that holds its note.
	#
	#   returns    a list of [ frame, bufferId ] rows in start order; [ ] for an empty score
	#   warning    the rows come from the renderer, which renders on first use
	#   see        Renderer, Prepare
	def Plan()
		return @oR.Plan()

	# Returns the renderer that holds the score's notes.
	#
	#   returns    a stzSoundScoreRenderer
	#   warning    it is the one the scheduler uses, not a copy to configure separately
	#   see        Plan, SetGain
	def Renderer()
		return @oR

	# Returns the reason the last failure gave, or an empty text.
	#
	#   returns    a text
	#   see        Refusals
	def LastError()
		return @cLastError

	# Returns how many times the scheduler refused to go on.
	#
	#   returns    a number
	#   see        LastError
	def Refusals()
		return @nRefusals

	# Stops any transport, frees the graph and frees the notes.
	#
	#   returns    nothing
	#   warning    call it only once nothing is playing, because the timeline reads the note samples
	#              directly
	#   see        Prepare, Play
	#@ aka  Free the notes. Only once nothing is playing: the timeline reads their samples directly, and a freed note under a playing timeline is a read of freed memory.
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
