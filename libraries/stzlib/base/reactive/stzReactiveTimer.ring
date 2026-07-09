
# Polling-based timer (formerly a libuv wrapper).
# M-DEP4 slice 1 (2026-06-13): the libuv integration has been removed
# and the class is now backed by Ring's `clock()` + `clocksPerSecond()`
# polling -- the same paradigm stzRingTimer uses. CheckAndTick() must
# be called by the manager to advance the timer; there is no
# preemptive thread today. Real async will arrive when the
# cross-platform Zig event loop ships in a later slice.

class stzReactiveTimer from stzObject

	timerId = ""
	interval = ONE_SECOND  # milliseconds
	callback = NULL
	engine = NULL
	timerHandle = NULL     # kept as NULL sentinel for API parity
	isActive = false
	isOneTime = false
	startTime = 0
	lastTick = 0

	def Init(id, intervalMs, f, engine, oneTime)
		timerId = id
		interval = intervalMs
		callback = f
		this.engine = engine

		# Honor the constructor's oneTime arg (default FALSE on NULL).
		if oneTime = NULL
			isOneTime = false
		else
			isOneTime = oneTime
		ok

	def Start()
		if not isActive
			isActive = true
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			startTime = StzEngineTimeNowMs()
			lastTick = startTime
		ok

	def Stop()
		isActive = false

	def Tick()
		if callback != NULL
			call callback()
		ok

	# Drive the timer from the manager's poll loop. Returns isActive
	# so the manager can prune completed one-shot timers.
	def CheckAndTick()
		if not isActive
			return false
		ok
		# Engine clock returns milliseconds directly -- no
		# clocksPerSecond conversion needed.
		_currentTime_ = StzEngineTimeNowMs()
		_elapsed_ = _currentTime_ - lastTick
		if _elapsed_ >= interval
			if callback != NULL
				call callback()
			ok
			if isOneTime
				Stop()
				return false
			else
				lastTick = _currentTime_
			ok
		ok
		return isActive

	def Cleanup()
		Stop()

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

class stzRingTimer from stzObject

	timerId = ""
	interval = ONE_SECOND    # milliseconds
	callback = NULL
	engine = NULL
	obj = NULL
	isActive = false
	isOneTime = false
	startTime = 0
	lastTick = 0
	
	def init(id, intervalMs, f, engine, oneTime, obj)
		timerId = id
		interval = intervalMs
		callback = f
		this.engine = engine
		this.obj = obj
		isOneTime = oneTime
		if isOneTime = NULL
			isOneTime = false
		ok
		isActive = false
		
	def Start()
		if not isActive
			isActive = true
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			startTime = StzEngineTimeNowMs()
			lastTick = startTime
		ok
		
	def Stop()
		isActive = false
		
	def CheckAndTick()
	    if not isActive
	        return false
	    ok
	    
	    # Start() seeds startTime/lastTick from StzEngineTimeNowMs() (a
	    # wall-clock ms value). CheckAndTick MUST read the same clock --
	    # the old code used clock() (CPU ticks), so currentTime - lastTick
	    # was hugely negative and the timer NEVER fired: every RunAfter/
	    # RunEvery test hung forever. clock() also doesn't advance during
	    # the poll loop's sleep() (it measures CPU, not wall time).
	    _currentTime_ = StzEngineTimeNowMs()
	    _elapsed_ = _currentTime_ - lastTick

	    if _elapsed_ < interval
	        return true   # still active, just not due yet
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
	    _bOnce_ = isOneTime
	    lastTick = _currentTime_
	    if _bOnce_
	        Stop()
	    ok

	    if callback != NULL
	        call callback()
	    ok

	    if _bOnce_
	        return false
	    ok
	    return true

	def Cleanup()
		Stop()

# Timer manager to check all active timers

class stzTimerManager from stzObject

	timers = []
	isRunning = false
	shouldStop = false
	checkFrequency = DEFAULT_TIMER_CHECK  # How often to check timers (ms)
	emptyLoopPatience = DEFAULT_PATIENCE  # How long to wait when no timers

	def init()
		timers = []
		isRunning = false
		shouldStop = false
		checkFrequency = DEFAULT_TIMER_CHECK
		emptyLoopPatience = DEFAULT_PATIENCE

	def SetCheckFrequency(freq)
		checkFrequency = freq

	def SetPatience(patience)
		emptyLoopPatience = patience

	def AddTimer(_timer_)
		timers + _timer_
		
	def RemoveTimer(timerId)
	    for i = len(timers) to 1 step -1  # Iterate backwards
	        if timers[i].timerId = timerId
	            timers[i].Stop()
	            del(timers, i)
	            exit
	        ok
	    next
	    
	    # Stop run loop if no active timers
	    if len(timers) = 0
	        isRunning = false
	    ok

	def RunLoop()
	    isRunning = true
	    _emptyLoopCount_ = 0
	    
	    while isRunning and not shouldStop
	        _activeCount_ = 0

	        # Process timers safely by collecting completed ones first
	        _completedIndices_ = []
	        _nLenTimers_ = len(timers)

	        for i = 1 to _nLenTimers_
	            # A callback may have removed timers (StopAllTimers clears
	            # the list mid-iteration), so re-check the bound each step.
	            if i > len(timers)
	                exit
	            ok
	            # Call through the index, NOT a `timer = timers[i]` copy:
	            # Ring returns a COPY on list-element assignment, so a copy
	            # would never persist CheckAndTick's lastTick update -- the
	            # repeating timer then re-fired every poll (~10ms) instead
	            # of every interval. (One-shot timers happened to survive.)
	            if timers[i].CheckAndTick()
	                _activeCount_++
	            else
	                # Mark for removal if it's a one-time timer
	                if timers[i].isOneTime
	                    _completedIndices_ + i
	                ok
	            ok
	            # A callback may have stopped the whole system; bail now
	            # rather than index into a cleared list.
	            if not isRunning or shouldStop
	                exit
	            ok
	        next
	        
	        # Remove completed timers in reverse order to maintain indices
	        for i = len(_completedIndices_) to 1 step -1
	            _index_ = _completedIndices_[i]
	            if _index_ >= 1 and _index_ <= len(timers)
	                del(timers, _index_)
	            ok
	        next
	        
	        # Use configurable check frequency instead of fixed delay
	        _sleepTime_ = checkFrequency / MS_PER_SECOND  # Convert to seconds
	        sleep(_sleepTime_)
	        
	        # Don't exit immediately if no timers - wait based on patience level
	        if len(timers) = 0
	            _emptyLoopCount_++
	            if _emptyLoopCount_ > emptyLoopPatience
	                isRunning = false
	            ok
	        else
	            _emptyLoopCount_ = 0  # Reset counter when we have timers
	        ok
	        
	        # Exit if shouldStop flag is set
	        if shouldStop
	            isRunning = false
	        ok
	    end
		
	def Stop()
		shouldStop = true
		isRunning = false
		_nTimers1Len_ = len(timers)
		for _iLoopTimers1_ = 1 to _nTimers1Len_
			_timer_ = timers[_iLoopTimers1_]
			_timer_.Stop()
		next

	def StopAllTimers()
	    # Stop all timers and clear the list
	    _nLen_ = len(timers)
	    for i = 1 to _nLen_
	        timers[i].Stop()
	    next
	    timers = []
	    isRunning = false
