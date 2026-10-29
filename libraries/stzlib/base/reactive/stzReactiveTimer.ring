
# Reaxis timers.
# M-DEP4 slice 1 (2026-06-13) removed the old libuv wrapper; timers
# became CheckAndTick() objects advanced by the manager's poll loop.
# F5 (2026-07-14) re-based the MANAGER onto stzReactor: the wait
# between ticks is now a real libuv timer awaited on the engine loop
# thread (callbacks still dispatch on the Ring thread -- Ring is not
# thread-safe, so no callback ever crosses from libuv into Ring). The
# pure-Ring sleep() poll remains the documented no-DLL fallback.

# Holds a timer that calls a function every interval, or once, advanced by a timer manager's loop on the engine's clock.
#
# The timer does not run by itself: a stzTimerManager loop calls CheckAndTick, which fires the
# function when the interval has passed since the last firing, on the engine's monotonic clock in
# milliseconds, and answers whether the timer is still active so the manager can prune finished one-
# shots. A one-shot timer stops itself after firing. Start takes the time now as the starting point;
# Tick calls the function at once whatever the clock says.
#
#   receiver   $nFired = 0 o1 = new stzReactiveTimer("beat", 30, func { $nFired++ }, new
#              stzReactive(), 0)
#   example    ? o1.CheckAndTick()
#              #--> 0
#              o1.Tick()
#              ? $nFired
#              #--> 1
#              o1.Start()
#              ? o1.CheckAndTick()
#              #--> 1
#              ? $nFired
#              #--> 1
#              StzEngineTimeSleepMs(60)
#              ? o1.CheckAndTick()
#              #--> 1
#              ? $nFired
#              #--> 2
#              o1.Stop()
#              ? o1.CheckAndTick()
#              #--> 0
#   see        stzRingTimer, stzTimerManager, stzReactive
class stzReactiveTimer from stzObject

	@timerId = ""
	@interval = $ONE_SECOND  # milliseconds
	@callback = ""
	@oEngine = ""
	@timerHandle = ""     # kept as NULL sentinel for API parity
	@isActive = 0
	@isOneTime = 0
	@startTime = 0
	@lastTick = 0

	# Builds a timer that calls a function every interval, or once, when started and driven by a timer manager.
	#
	#   id           the timer's identifier
	#   intervalMs   the time between calls in milliseconds
	#   f            the function to call
	#   engine       the reactive engine it belongs to
	#   oneTime      1 for a timer that fires once and stops, 0 or an empty text for one that
	#                repeats
	#   returns      nothing; the timer is built stopped
	#   note         it does not run by itself: a stzTimerManager loop calls CheckAndTick
	#   see          Start, CheckAndTick, stzTimerManager
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

	# Starts the timer, taking the time now as its starting point.
	#
	#   returns    nothing; the timer becomes active
	#   note       starting an active timer does nothing, and the interval counts from the start
	#   see        Stop, CheckAndTick
	def Start()
		if not @isActive
			@isActive = 1
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			@startTime = StzEngineTimeNowMs()
			@lastTick = @startTime
		ok

	# Stops the timer, so CheckAndTick no longer fires it.
	#
	#   returns    nothing; the timer becomes inactive
	#   see        Start, Cleanup
	def Stop()
		@isActive = 0

	# Calls the timer's function now, whatever the clock says.
	#
	#   returns    nothing
	#   note       it fires even when the timer is stopped and does not change the timer's state
	#   see        CheckAndTick
	def Tick()
		if @callback != ""
			call @callback()
		ok

	# Calls the function if the interval has passed since the last call, for a manager's loop to call.
	#
	#   returns    1 while the timer stays active, 0 when it is stopped or has just fired as a one-
	#              shot
	#   note       a repeating timer measures from the time of its last firing; a call before the
	#              interval has passed does nothing and answers 1; a one-shot stops itself after
	#              firing
	#   see        Start, Tick
	#@ aka  Drive the timer from the manager's poll loop. Returns isActive so the manager can prune completed one-shot timers.
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

	# Stops the timer when its owner lets go of it.
	#
	#   returns    nothing
	#   see        Stop
	def Cleanup()
		Stop()

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

# Holds a timer in pure Ring that calls a function every interval, or once, advanced by a timer manager's loop.
#
# The same contract as stzReactiveTimer, with an owner object kept for the caller: CheckAndTick
# fires the function when the interval has passed since the last firing on the engine's clock,
# answers 1 while the timer stays active and 0 when it is stopped or has just fired as a one-shot.
# It decides whether to stop a one-shot before it calls the function, because the function may stop
# the whole timer system.
#
#   receiver   $nFired = 0 o1 = new stzRingTimer("once", 20, func { $nFired++ }, new stzReactive(),
#              1, "")
#   example    o1.Start()
#              ? o1.CheckAndTick()
#              #--> 1
#              ? $nFired
#              #--> 0
#              StzEngineTimeSleepMs(50)
#              ? o1.CheckAndTick()
#              #--> 0
#              ? $nFired
#              #--> 1
#              ? o1.CheckAndTick()
#              #--> 0
#              ? $nFired
#              #--> 1
#   see        stzReactiveTimer, stzTimerManager
class stzRingTimer from stzObject

	@timerId = ""
	@interval = $ONE_SECOND    # milliseconds
	@callback = ""
	@oEngine = ""
	@obj = ""
	@isActive = 0
	@isOneTime = 0
	@startTime = 0
	@lastTick = 0
	
	# Builds a timer in pure Ring that calls a function every interval, or once, when driven by a timer manager.
	#
	#   id           the timer's identifier
	#   intervalMs   the time between calls in milliseconds
	#   f            the function to call
	#   engine       the reactive engine it belongs to
	#   oneTime      1 for a timer that fires once, 0 or an empty text for one that repeats
	#   obj          the object the timer belongs to, kept for the owner
	#   returns      nothing; the timer is built stopped
	#   note         it does not run by itself: a stzTimerManager loop calls CheckAndTick
	#   see          Start, CheckAndTick
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
		
	# Starts the timer, taking the time now as its starting point.
	#
	#   returns    nothing; the timer becomes active
	#   note       starting an active timer does nothing
	#   see        Stop, CheckAndTick
	def Start()
		if not @isActive
			@isActive = 1
			# Engine-side monotonic clock so every host language
			# observes identical semantics (M-DEP4 hardening).
			@startTime = StzEngineTimeNowMs()
			@lastTick = @startTime
		ok
		
	# Stops the timer, so CheckAndTick no longer fires it.
	#
	#   returns    nothing; the timer becomes inactive
	#   see        Start, Cleanup
	def Stop()
		@isActive = 0
		
	# Calls the function if the interval has passed since the last call, for a manager's loop to call.
	#
	#   returns    1 while the timer stays active, 0 when it is stopped or has just fired as a one-
	#              shot
	#   note       a call before the interval has passed does nothing and answers 1; it decides
	#              whether to stop a one-shot before calling the function, because the function may
	#              stop the whole timer system
	#   see        Start, Stop
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

	# Stops the timer when its owner lets go of it.
	#
	#   returns    nothing
	#   see        Stop
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

# Runs a loop that ticks timers every few milliseconds, drains pending HTTP requests and stops when there is nothing left to do.
#
# Add started timers with AddTimer and call RunLoop. Each pass ticks every timer, drops the finished
# one-shots, drains the pending asynchronous requests of the stzReactiveHttp you hand in, advances
# detached timers and waits SetCheckFrequency milliseconds, on a real timer of the reactor if
# SetReactor gave one and a sleep otherwise. The loop ends when no timer remains and the patience, a
# count of idle passes, is used up, or when Stop is called. The manager keeps copies of its timers,
# so a callback stopping its own copy does not stop the manager's, and a loop with a repeating timer
# runs until the manager itself is stopped.
#
#   receiver   $nFired = 0 oEngine = new stzReactive() o1 = new stzTimerManager()
#              o1.SetCheckFrequency(5) o2 = new stzReactiveTimer("first", 20, func { $nFired += 1 },
#              oEngine, 1) o3 = new stzReactiveTimer("second", 40, func { $nFired += 10 }, oEngine,
#              1) o2.Start() o3.Start() o1.AddTimer(o2) o1.AddTimer(o3)
#   example    o1.RunLoop("")
#              ? $nFired
#              #--> 11
#   see        stzReactiveTimer, stzRingTimer, stzReactiveHttp, stzReactor
class stzTimerManager from stzObject

	@timers = []
	@isRunning = 0
	@shouldStop = 0
	@checkFrequency = $DEFAULT_TIMER_CHECK  # How often to check @timers (ms)
	@emptyLoopPatience = $DEFAULT_PATIENCE  # How long to wait when no @timers
	@oReactor = ""       # F5: engine loop backing the waits (NULL = poller)

	# Builds a manager with no timers, a 10 ms wait between ticks and no patience for an idle loop.
	#
	#   returns    nothing; the object is built
	#   note       the manager's loop keeps copies of the timers it is given
	#   see        AddTimer, RunLoop
	def init()
		@timers = []
		@isRunning = 0
		@shouldStop = 0
		@checkFrequency = $DEFAULT_TIMER_CHECK
		@emptyLoopPatience = $DEFAULT_PATIENCE

	# Sets how long the loop waits between ticks, in milliseconds.
	#
	#   freq       the wait in milliseconds, above 0
	#   returns    the manager itself, so calls chain
	#   note       the wait is a real timer on the reactor when SetReactor gave one, and a sleep
	#              otherwise
	#   see        SetPatience, RunLoop
	#@ aka  HOW LONG THE LOOP WAITS BETWEEN TICKS, in milliseconds.
	def SetCheckFrequency(freq)
		if NOT isNumber(freq)
			return This
		ok
		if freq <= 0
			return This
		ok
		@checkFrequency = freq
		return This

	# Sets how many idle passes the loop tolerates before it stops.
	#
	#   patience   a count of passes with no timer, no pending request and no detached timer, 0 or
	#              more
	#   returns    the manager itself, so calls chain
	#   note       the default 0 stops as soon as there is no work, like libuv; a count, not a
	#              duration
	#   see        SetCheckFrequency, RunLoop
	#@ aka  HOW MANY consecutive idle iterations the loop tolerates before it stops. A count, not a duration -- RunLoop compares it against _emptyLoopCount_. Zero is meaningful and is the default (PATIENCE_NONE, mirroring libuv's uv_run: return as soon as there is no work), so only negatives and non-numbers are refused.
	def SetPatience(patience)
		if NOT isNumber(patience)
			return This
		ok
		if patience < 0
			return This
		ok
		@emptyLoopPatience = patience
		return This

	# Gives the manager a reactor to wait on between ticks.
	#
	#   poReactor   a stzReactor, or an empty text for the plain sleep
	#   returns     the manager itself, so calls chain
	#   note        the stored reactor is a copy that shares the engine handle
	#   see         SetCheckFrequency, RunLoop
	#@ aka  NOTE: the stored reactor is a COPY (Ring attribute assignment copies objects) that SHARES the engine handle -- safe because the handle is never destroyed while a system lives (see stzReactive. Stop). The http drain is NOT stored for the same reason: a copy's aPending would be a dead snapshot; RunLoop takes the LIVE object as a parameter instead (params are by-reference).
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
			sleep(@checkFrequency / $MS_PER_SECOND)
		ok

	# Adds a timer to the manager's list.
	#
	#   _timer_    a stzReactiveTimer or stzRingTimer, started by the caller
	#   returns    nothing; the timer is added
	#   note       the manager stores a copy, so later changes to the caller's timer do not reach
	#              it; the timer must have been started or it never fires
	#   see        RemoveTimer, RunLoop
	def AddTimer(_timer_)
		@timers + _timer_
		
	# Stops a timer by its id and removes it.
	#
	#   timerId    the id the timer was built with
	#   returns    nothing
	#   note       an unknown id does nothing; when no timer is left the loop is told to stop
	#   see        AddTimer, StopAllTimers
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

	# Runs the loop that ticks the timers and drains requests until no work is left or Stop is called.
	#
	#   poHttpDrain   the live stzReactiveHttp whose pending requests are drained each pass, or an
	#                 empty text for none
	#   returns       nothing; it returns when the loop has stopped
	#   note          it ends when no timer remains, no request is pending and the patience is used
	#                 up, or when Stop is called; a callback that stops a repeating timer copy does
	#                 not stop the manager's own copy, so a loop with a repeating timer runs until
	#                 Stop or StopAllTimers is called on the manager itself
	#   see           Stop, SetPatience, AddTimer
	#@ aka  poHttpDrain = the LIVE stzReactiveHttp object (by-ref param; an attribute copy would drain a dead snapshot). NULL = no http.
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
		
	# Tells the loop to end and stops every timer in it.
	#
	#   returns    nothing
	#   note       once stopped, RunLoop returns at once
	#   see        RunLoop, StopAllTimers
	def Stop()
		@shouldStop = 1
		@isRunning = 0
		_nTimers1Len_ = len(@timers)
		for _iLoopTimers1_ = 1 to _nTimers1Len_
			_timer_ = @timers[_iLoopTimers1_]
			_timer_.Stop()
		next

	# Stops every timer, empties the list and stops the loop.
	#
	#   returns    nothing
	#   see        Stop, RemoveTimer
	def StopAllTimers()
	    # Stop all timers and clear the list
	    _nLen_ = len(@timers)
	    for i = 1 to _nLen_
	        @timers[i].Stop()
	    next
	    @timers = []
	    @isRunning = 0
