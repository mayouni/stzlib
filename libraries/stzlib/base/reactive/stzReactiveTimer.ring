#----------------------------------------------#
#  REACTIVE TIMER - For time-based operations  #
#----------------------------------------------#

# Thin wrapper around libuv timer system
# ~> Delegates to Ring callbacks but leverages
# libuv's event loop integration

class stzReactiveTimer

	timerId = ""
	interval = 1000  # milliseconds
	callback = NULL
	engine = NULL
	timerHandle = NULL
	isActive = false
	
	def Init(id, intervalMs, f, engine)
		timerId = id
		interval = intervalMs
		callback = f
		this.engine = engine
		isActive = false
		
	def Start()
		if not isActive
			timerHandle = new_uv_timer_t()
			uv_timer_init(engine.myLoop, timerHandle)
			uv_timer_start(timerHandle, Method(:Tick), 0, interval)
			isActive = true
		ok
		
	def Stop()
		if isActive and timerHandle != NULL
			uv_timer_stop(timerHandle)
			isActive = false
		ok
		
	def Tick()
		if callback != NULL
			call callback()
		ok
		
	def Cleanup()
		Stop()
		if timerHandle != NULL
			destroy_uv_timer_t(timerHandle)
			timerHandle = NULL
		ok

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

# Pure Ring timer using clock()
# Direct object method access, handles timing logic in Ring's native paradigm

class stzRingTimer

	timerId = ""
	interval = 1000  # milliseconds
	callback = NULL
	engine = NULL
	obj = NULL
	isActive = false
	isOneTime = false
	startTime = 0
	lastTick = 0
	
	def Init(id, intervalMs, f, engine, oneTime, obj)
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
			startTime = clock()
			lastTick = startTime
		ok
		
	def Stop()
		isActive = false
		
	def CheckAndTick()
	    if not isActive
	        return false
	    ok
	    
	    currentTime = clock()
	    elapsed = (currentTime - lastTick) * 1000 / clocksPerSecond()
	    
	    if elapsed >= interval
	        if callback != NULL
	            call callback()
	        ok
	        
	        if isOneTime
	            Stop()
	            return false
	        else
	            lastTick = currentTime
	        ok
	    ok
	    
	    return isActive
		
	def Cleanup()
		Stop()

# Timer manager to check all active timers

class stzTimerManager

	timers = []
	isRunning = false
	shouldStop = false

	def Init()
		timers = []
		isRunning = false
		shouldStop = false

	def AddTimer(timer)
		timers + timer
		
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
	    emptyLoopCount = 0
	    
	    while isRunning and not shouldStop
	        activeCount = 0
	        
	        # Process timers safely by collecting completed ones first
	        completedIndices = []
	        
	        for i = 1 to len(timers)
	            timer = timers[i]
	            if timer.CheckAndTick()
	                activeCount++
	            else
	                # Mark for removal if it's a one-time timer
	                if timer.isOneTime
	                    completedIndices + i
	                ok
	            ok
	        next
	        
	        # Remove completed timers in reverse order to maintain indices
	        for i = len(completedIndices) to 1 step -1
	            index = completedIndices[i]
	            if index >= 1 and index <= len(timers)
	                del(timers, index)
	            ok
	        next
	        
	        # Small delay to prevent CPU spinning
	        sleep(0.01)
	        
	        # Don't exit immediately if no timers - wait for potential new ones
	        if len(timers) = 0
	            emptyLoopCount++
	            if emptyLoopCount > 50  # Wait about 0.5 seconds for new timers
	                isRunning = false
	            ok
	        else
	            emptyLoopCount = 0  # Reset counter when we have timers
	        ok
	        
	        # Exit if shouldStop flag is set
	        if shouldStop
	            isRunning = false
	        ok
	    end
		
	def Stop()
		isRunning = false
		for timer in timers
			timer.Stop()
		next
