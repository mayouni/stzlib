
# Polling-based timer (formerly a libuv wrapper).
# M-DEP4 slice 1 (2026-06-13): the libuv integration has been removed
# and the class is now backed by Ring's `clock()` + `clocksPerSecond()`
# polling -- the same paradigm stzRingTimer uses. CheckAndTick() must
# be called by the manager to advance the timer; there is no
# preemptive thread today. Real async will arrive when the
# cross-platform Zig event loop ships in a later slice.

class stzReactiveTimer from stzObject

	_timerId_ = ""
	_interval_ = ONE_SECOND  # milliseconds
	_callback_ = NULL
	_engine_ = NULL
	_timerHandle_ = NULL     # kept as NULL sentinel for API parity
	_isActive_ = false
	_isOneTime_ = false
	_startTime_ = 0
	_lastTick_ = 0

	def Init(id, intervalMs, f, _engine_, oneTime)
		_timerId_ = id
		_interval_ = intervalMs
		_callback_ = f
		this.engine = _engine_

		# Honor the constructor's oneTime arg (default FALSE on NULL).
		if oneTime = NULL
			_isOneTime_ = false
		else
			_isOneTime_ = oneTime
		ok

	def Start()
		if not _isActive_
			_isActive_ = true
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			_startTime_ = StzEngineTimeNowMs()
			_lastTick_ = _startTime_
		ok

	def Stop()
		_isActive_ = false

	def Tick()
		if _callback_ != NULL
			call _callback_()
		ok

	# Drive the timer from the manager's poll loop. Returns isActive
	# so the manager can prune completed one-shot timers.
	def CheckAndTick()
		if not _isActive_
			return false
		ok
		# Engine clock returns milliseconds directly -- no
		# clocksPerSecond conversion needed.
		_currentTime_ = StzEngineTimeNowMs()
		_elapsed_ = _currentTime_ - _lastTick_
		if _elapsed_ >= _interval_
			if _callback_ != NULL
				call _callback_()
			ok
			if _isOneTime_
				Stop()
				return false
			else
				_lastTick_ = _currentTime_
			ok
		ok
		return _isActive_

	def Cleanup()
		Stop()

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

class stzRingTimer from stzObject

	_timerId_ = ""
	_interval_ = ONE_SECOND    # milliseconds
	_callback_ = NULL
	_engine_ = NULL
	_obj_ = NULL
	_isActive_ = false
	_isOneTime_ = false
	_startTime_ = 0
	_lastTick_ = 0
	
	def init(id, intervalMs, f, _engine_, oneTime, _obj_)
		_timerId_ = id
		_interval_ = intervalMs
		_callback_ = f
		this.engine = _engine_
		this.obj = _obj_
		_isOneTime_ = oneTime
		if _isOneTime_ = NULL
			_isOneTime_ = false
		ok
		_isActive_ = false
		
	def Start()
		if not _isActive_
			_isActive_ = true
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			_startTime_ = StzEngineTimeNowMs()
			_lastTick_ = _startTime_
		ok
		
	def Stop()
		_isActive_ = false
		
	def CheckAndTick()
	    if not _isActive_
	        return false
	    ok
	    
	    # Start() seeds startTime/lastTick from StzEngineTimeNowMs() (a
	    # wall-clock ms value). CheckAndTick MUST read the same clock --
	    # the old code used clock() (CPU ticks), so currentTime - lastTick
	    # was hugely negative and the timer NEVER fired: every RunAfter/
	    # RunEvery test hung forever. clock() also doesn't advance during
	    # the poll loop's sleep() (it measures CPU, not wall time).
	    _currentTime_ = StzEngineTimeNowMs()
	    _elapsed_ = _currentTime_ - _lastTick_

	    if _elapsed_ < _interval_
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
	    _bOnce_ = _isOneTime_
	    _lastTick_ = _currentTime_
	    if _bOnce_
	        Stop()
	    ok

	    if _callback_ != NULL
	        call _callback_()
	    ok

	    if _bOnce_
	        return false
	    ok
	    return true

	def Cleanup()
		Stop()

# Timer manager to check all active timers

class stzTimerManager from stzObject

	_timers_ = []
	_isRunning_ = false
	_shouldStop_ = false
	_checkFrequency_ = DEFAULT_TIMER_CHECK  # How often to check timers (ms)
	_emptyLoopPatience_ = DEFAULT_PATIENCE  # How long to wait when no timers

	def init()
		_timers_ = []
		_isRunning_ = false
		_shouldStop_ = false
		_checkFrequency_ = DEFAULT_TIMER_CHECK
		_emptyLoopPatience_ = DEFAULT_PATIENCE

	def SetCheckFrequency(freq)
		_checkFrequency_ = freq

	def SetPatience(patience)
		_emptyLoopPatience_ = patience

	def AddTimer(_timer_)
		_timers_ + _timer_
		
	def RemoveTimer(_timerId_)
	    for i = len(_timers_) to 1 step -1  # Iterate backwards
	        if _timers_[i].timerId = _timerId_
	            _timers_[i].Stop()
	            del(_timers_, i)
	            exit
	        ok
	    next
	    
	    # Stop run loop if no active timers
	    if len(_timers_) = 0
	        _isRunning_ = false
	    ok

	def RunLoop()
	    _isRunning_ = true
	    _emptyLoopCount_ = 0
	    
	    while _isRunning_ and not _shouldStop_
	        _activeCount_ = 0

	        # Process timers safely by collecting completed ones first
	        _completedIndices_ = []
	        _nLenTimers_ = len(_timers_)

	        for i = 1 to _nLenTimers_
	            # A callback may have removed timers (StopAllTimers clears
	            # the list mid-iteration), so re-check the bound each step.
	            if i > len(_timers_)
	                exit
	            ok
	            # Call through the index, NOT a `timer = timers[i]` copy:
	            # Ring returns a COPY on list-element assignment, so a copy
	            # would never persist CheckAndTick's lastTick update -- the
	            # repeating timer then re-fired every poll (~10ms) instead
	            # of every interval. (One-shot timers happened to survive.)
	            if _timers_[i].CheckAndTick()
	                _activeCount_++
	            else
	                # Mark for removal if it's a one-time timer
	                if _timers_[i].isOneTime
	                    _completedIndices_ + i
	                ok
	            ok
	            # A callback may have stopped the whole system; bail now
	            # rather than index into a cleared list.
	            if not _isRunning_ or _shouldStop_
	                exit
	            ok
	        next
	        
	        # Remove completed timers in reverse order to maintain indices
	        for i = len(_completedIndices_) to 1 step -1
	            _index_ = _completedIndices_[i]
	            if _index_ >= 1 and _index_ <= len(_timers_)
	                del(_timers_, _index_)
	            ok
	        next
	        
	        # Use configurable check frequency instead of fixed delay
	        _sleepTime_ = _checkFrequency_ / MS_PER_SECOND  # Convert to seconds
	        sleep(_sleepTime_)
	        
	        # Don't exit immediately if no timers - wait based on patience level
	        if len(_timers_) = 0
	            _emptyLoopCount_++
	            if _emptyLoopCount_ > _emptyLoopPatience_
	                _isRunning_ = false
	            ok
	        else
	            _emptyLoopCount_ = 0  # Reset counter when we have timers
	        ok
	        
	        # Exit if shouldStop flag is set
	        if _shouldStop_
	            _isRunning_ = false
	        ok
	    end
		
	def Stop()
		_shouldStop_ = true
		_isRunning_ = false
		_nTimers1Len_ = len(_timers_)
		for _iLoopTimers1_ = 1 to _nTimers1Len_
			_timer_ = _timers_[_iLoopTimers1_]
			_timer_.Stop()
		next

	def StopAllTimers()
	    # Stop all timers and clear the list
	    _nLen_ = len(_timers_)
	    for i = 1 to _nLen_
	        _timers_[i].Stop()
	    next
	    _timers_ = []
	    _isRunning_ = false
