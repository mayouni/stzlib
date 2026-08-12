
# Reaxis timers.
# M-DEP4 slice 1 (2026-06-13) removed the old libuv wrapper; timers
# became CheckAndTick() objects advanced by the manager's poll loop.
# F5 (2026-07-14) re-based the MANAGER onto stzReactor: the wait
# between ticks is now a real libuv timer awaited on the engine loop
# thread (callbacks still dispatch on the Ring thread -- Ring is not
# thread-safe, so no callback ever crosses from libuv into Ring). The
# pure-Ring sleep() poll remains the documented no-DLL fallback.

class stzReactiveTimer from stzObject

	@timerId = ""
	@interval = ONE_SECOND  # milliseconds
	@callback = ""
	@oEngine = ""
	@timerHandle = ""     # kept as NULL sentinel for API parity
	@isActive = 0
	@isOneTime = 0
	@startTime = 0
	@lastTick = 0

	def Init(id, intervalMs, f, engine, oneTime)
		@timerId = id
		@interval = intervalMs
		@callback = f
		@oEngine = engine

		# Honor the constructor's oneTime arg (default FALSE on NULL).
		if oneTime = ""
			@isOneTime = 0
		else
			@isOneTime = oneTime
		ok

	def Start()
		if not @isActive
			@isActive = 1
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			@startTime = StzEngineTimeNowMs()
			@lastTick = @startTime
		ok

	def Stop()
		@isActive = 0

	def Tick()
		if @callback != ""
			call @callback()
		ok

	# Drive the timer from the manager's poll loop. Returns isActive
	# so the manager can prune completed one-shot timers.
	def CheckAndTick()
		if not @isActive
			return 0
		ok
		# Engine clock returns milliseconds directly -- no
		# clocksPerSecond conversion needed.
		_currentTime_ = StzEngineTimeNowMs()
		_elapsed_ = _currentTime_ - @lastTick
		if _elapsed_ >= @interval
			if @callback != ""
				call @callback()
			ok
			if @isOneTime
				Stop()
				return 0
			else
				@lastTick = _currentTime_
			ok
		ok
		return @isActive

	def Cleanup()
		Stop()

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

class stzRingTimer from stzObject

	@timerId = ""
	@interval = ONE_SECOND    # milliseconds
	@callback = ""
	@oEngine = ""
	@obj = ""
	@isActive = 0
	@isOneTime = 0
	@startTime = 0
	@lastTick = 0
	
	def init(id, intervalMs, f, engine, oneTime, obj)
		@timerId = id
		@interval = intervalMs
		@callback = f
		@oEngine = engine
		@obj = obj
		@isOneTime = oneTime
		if @isOneTime = ""
			@isOneTime = 0
		ok
		@isActive = 0
		
	def Start()
		if not @isActive
			@isActive = 1
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			@startTime = StzEngineTimeNowMs()
			@lastTick = @startTime
		ok
		
	def Stop()
		@isActive = 0
		
	def CheckAndTick()
	    if not @isActive
	        return 0
	    ok
	    
	    # Start() seeds startTime/lastTick from StzEngineTimeNowMs() (a
	    # wall-clock ms value). CheckAndTick MUST read the same clock --
	    # the old code used clock() (CPU ticks), so currentTime - lastTick
	    # was hugely negative and the timer NEVER fired: every RunAfter/
	    # RunEvery test hung forever. clock() also doesn't advance during
	    # the poll loop's sleep() (it measures CPU, not wall time).
	    _currentTime_ = StzEngineTimeNowMs()
	    _elapsed_ = _currentTime_ - @lastTick

	    if _elapsed_ < @interval
	        return 1   # still active, just not due yet
	    ok

	    # The callback may re-enter the timer system (StopTimer / Stop /
	    # StopAllTimers), which clears `timers` and leaves Ring's object
	    # scope invalid -- ANY attribute read after `call callback()`
	    # (even This.isActive) then raises R24/R13. So decide everything
	    # BEFORE the call: snapshot one-time-ness, advance lastTick (fixed
	    # rate), stop one-shots up front, and return a value that needs no
	    # post-callback attribute read. A repeating timer reports "active";
	    # if the callback stopped the system, the manager loop sees its own
	    # isRunning flag drop and exits.
	    _bOnce_ = @isOneTime
	    @lastTick = _currentTime_
	    if _bOnce_
	        Stop()
	    ok

	    if @callback != ""
	        call @callback()
	    ok

	    if _bOnce_
	        return 0
	    ok
	    return 1

	def Cleanup()
		Stop()

# Timer manager to check all active timers
#
# F5 (2026-07-14): the manager now RUNS ON THE REACTOR when the engine
# DLL is present -- the inter-tick wait is a REAL libuv timer awaited
# on the engine loop thread (SubmitTimer/AwaitTimer), not a Ring
# sleep(). The pure-Ring sleep remains the documented no-DLL fallback
# (LAW 2). The manager also drains the reactive-http pending set each
# tick, so async HTTP callbacks dispatch from the same loop.

class stzTimerManager from stzObject

	@timers = []
	@isRunning = 0
	@shouldStop = 0
	@checkFrequency = DEFAULT_TIMER_CHECK  # How often to check @timers (ms)
	@emptyLoopPatience = DEFAULT_PATIENCE  # How long to wait when no @timers
	@oReactor = ""       # F5: engine loop backing the waits (NULL = poller)

	def init()
		@timers = []
		@isRunning = 0
		@shouldStop = 0
		@checkFrequency = DEFAULT_TIMER_CHECK
		@emptyLoopPatience = DEFAULT_PATIENCE

	# HOW LONG THE LOOP WAITS BETWEEN TICKS, in milliseconds.
	#
	# It used to take anything. Zero was the dangerous one: _WaitTick does
	# sleep(@checkFrequency / MS_PER_SECOND), so a frequency of 0 is no wait at
	# all -- 200 idle iterations in 2ms instead of 2000, a loop spinning flat
	# out on a knob whose entire job is to make it wait. A non-number was the
	# confusing one: it survived the setter and raised R41 "Invalid numeric
	# string" inside RunLoop, nowhere near the call that caused it.
	#
	# A refused value leaves the old one alone. Answering a bad value by
	# destroying a good one is its own defect.
	def SetCheckFrequency(freq)
		if NOT isNumber(freq)
			return This
		ok
		if freq <= 0
			return This
		ok
		@checkFrequency = freq
		return This

	# HOW MANY consecutive idle iterations the loop tolerates before it stops.
	# A count, not a duration -- RunLoop compares it against _emptyLoopCount_.
	# Zero is meaningful and is the default (PATIENCE_NONE, mirroring libuv's
	# uv_run: return as soon as there is no work), so only negatives and
	# non-numbers are refused.
	def SetPatience(patience)
		if NOT isNumber(patience)
			return This
		ok
		if patience < 0
			return This
		ok
		@emptyLoopPatience = patience
		return This

	# NOTE: the stored reactor is a COPY (Ring attribute assignment
	# copies objects) that SHARES the engine handle -- safe because the
	# handle is never destroyed while a system lives (see stzReactive.
	# Stop). The http drain is NOT stored for the same reason: a copy's
	# aPending would be a dead snapshot; RunLoop takes the LIVE object
	# as a parameter instead (params are by-reference).
	def SetReactor(poReactor)
		@oReactor = poReactor
		return This

	# The inter-tick wait: a real libuv timer on the engine loop when
	# the reactor is present; Ring sleep() as the no-DLL fallback.
	def _WaitTick()
		if @oReactor != ""
			_nId_ = @oReactor.SubmitTimer(@checkFrequency)
			if _nId_ > 0
				@oReactor.AwaitTimer(_nId_, @checkFrequency + 1000)
			ok
		else
			sleep(@checkFrequency / MS_PER_SECOND)
		ok

	def AddTimer(_timer_)
		@timers + _timer_
		
	def RemoveTimer(timerId)
	    for i = len(@timers) to 1 step -1  # Iterate backwards
	        if @timers[i].@timerId = timerId
	            @timers[i].Stop()
	            del(@timers, i)
	            exit
	        ok
	    next
	    
	    # Stop run loop if no active timers
	    if len(@timers) = 0
	        @isRunning = 0
	    ok

	# poHttpDrain = the LIVE stzReactiveHttp object (by-ref param; an
	# attribute copy would drain a dead snapshot). NULL = no http.
	def RunLoop(poHttpDrain)
	    @isRunning = 1
	    _emptyLoopCount_ = 0
	    
	    while @isRunning and not @shouldStop
	        _activeCount_ = 0

	        # Process timers safely by collecting completed ones first.
	        #
	        # BY ID, NOT BY INDEX. CheckAndTick RUNS the callback, and a
	        # callback can stop timers -- StopTimer really removes them now --
	        # so the list can be shorter one line after the bound was checked.
	        # An index collected before a tick then names a different timer, or
	        # none at all: this loop raised R2 the moment a demo stopped its
	        # timers from inside one of them.
	        _acCompletedIds_ = []
	        _nLenTimers_ = len(@timers)

	        for i = 1 to _nLenTimers_
	            # A callback may have removed timers (StopAllTimers clears
	            # the list mid-iteration), so re-check the bound each step.
	            if i > len(@timers)
	                exit
	            ok
	            # Call through the index, NOT a `timer = timers[i]` copy:
	            # Ring returns a COPY on list-element assignment, so a copy
	            # would never persist CheckAndTick's lastTick update -- the
	            # repeating timer then re-fired every poll (~10ms) instead
	            # of every interval. (One-shot timers happened to survive.)
	            if @timers[i].CheckAndTick()
	                _activeCount_++
	            else
	                # Mark for removal if it's a one-time timer. The tick just
	                # ran a callback, so the bound is re-checked before this
	                # index is used again.
	                if i <= len(@timers) and @timers[i].@isOneTime
	                    _acCompletedIds_ + @timers[i].@timerId
	                ok
	            ok
	            # A callback may have stopped the whole system; bail now
	            # rather than index into a cleared list.
	            if not @isRunning or @shouldStop
	                exit
	            ok
	        next
	        
	        # Remove the completed one-shots by the id each of them gave, which
	        # survives any shuffling the callbacks did. Deliberately not
	        # RemoveTimer(): that stops the whole loop when the list empties,
	        # and whether an idle loop keeps going is the patience setting's
	        # decision, not this one's.
	        _nDone_ = len(_acCompletedIds_)
	        for _iDone_ = 1 to _nDone_
	            for _k_ = len(@timers) to 1 step -1
	                if @timers[_k_].@timerId = _acCompletedIds_[_iDone_]
	                    del(@timers, _k_)
	                    exit
	                ok
	            next
	        next
	        
	        # F5: drain async HTTP completions on the same loop, so
	        # reactive-http callbacks fire between timer ticks.
	        _nHttpPending_ = 0
	        if poHttpDrain != ""
	            poHttpDrain.DrainPending()
	            _nHttpPending_ = poHttpDrain.PendingCount()
	        ok

	        # F5: advance the global DETACHED timer table (timers that
	        # reactive objects registered -- see stzReactiveGlobals).
	        _nDetached_ = StzReaxisTickDetached()

	        # The inter-tick wait (engine timer, or sleep as fallback)
	        This._WaitTick()

	        # Don't exit immediately if no work - wait based on patience
	        # level. In-flight HTTP and detached timers count as work.
	        if len(@timers) = 0 and _nHttpPending_ = 0 and _nDetached_ = 0
	            _emptyLoopCount_++
	            if _emptyLoopCount_ > @emptyLoopPatience
	                @isRunning = 0
	            ok
	        else
	            _emptyLoopCount_ = 0  # Reset counter when we have work
	        ok
	        
	        # Exit if shouldStop flag is set
	        if @shouldStop
	            @isRunning = 0
	        ok
	    end
		
	def Stop()
		@shouldStop = 1
		@isRunning = 0
		_nTimers1Len_ = len(@timers)
		for _iLoopTimers1_ = 1 to _nTimers1Len_
			_timer_ = @timers[_iLoopTimers1_]
			_timer_.Stop()
		next

	def StopAllTimers()
	    # Stop all timers and clear the list
	    _nLen_ = len(@timers)
	    for i = 1 to _nLen_
	        @timers[i].Stop()
	    next
	    @timers = []
	    @isRunning = 0
