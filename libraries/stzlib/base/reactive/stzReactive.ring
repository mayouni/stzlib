# Softanza Reactive Programming System
# A simple, learnable reactive system using Ring's LibUV capabilities

load "libuv.ring"

# =============================================================================
# MAIN REACTIVE API - Simple interface for common patterns (IMPROVED)
# =============================================================================

class stzReactive

	engine = NULL
	http = NULL
	fs = NULL
	dataStream = NULL
	httpStream = NULL

	def Init()
	    engine = new stzReactiveEngine()
	    engine.mainReactive = self
	    engine.Init()
	    http = new stzReactiveHttp(engine)
	    fs = new stzReactiveFileSystem(engine)
			
	def Start()
		engine.Start()
		
	def Stop()
		if engine != NULL and engine.isRunning
			engine.timerManager.isRunning = false
			engine.Stop()
		ok

	def StopSafe()
		# Schedule stop for next tick to avoid self-reference issues
		SetTimeout(func() {
			Stop()
		}, 1)
	
	# Make any function reactive
	def MakeReactive(f)
		return new stzReactiveFuncWrapper(f, engine)
		
		def Reactivate(f)
			return new stzReactiveFuncWrapper(f, engine)

	# Create a reactive stream (IMPROVED)
	def CreateStream(id, sourceType)
		if sourceType = NULL
			sourceType = "manual"
		ok
		
		stream = new stzReactiveStream(id, sourceType, engine)
		stream.Start()
		engine.AddStream(stream)
		return stream
		
	# Create a timer
	def CreateTimer(id, interval, callback)
		timer = new stzReactiveTimer(id, interval, callback, engine)
		engine.AddTimer(timer)
		return timer
		
	# Create a task
	def CreateTask(id, f)
		task = new stzReactiveTask(id, f, engine)
		engine.AddTask(task)
		return task

	# HTTP shortcuts
	def HttpGet(url, onSuccess, onError)
		return http.Get_(url, onSuccess, onError)
		
	def HttpPost(url, data, onSuccess, onError)
		return http.Post(url, data, onSuccess, onError)
		
	# File system shortcuts
	def ReadFile(path, onSuccess, onError)
		return fs.ReadFile(path, onSuccess, onError)
		
	def WriteFile(path, content, onSuccess, onError)
		return fs.WriteFile(path, content, onSuccess, onError)
		
	def WatchFile(path, onChange)
		return fs.WatchFile(path, onChange)

	def SetTimeout(callback, delay)
	    timerId = "timeout_" + string(random(999999))
	    timer = new stzRingTimer(timerId, delay, callback, engine, true, self)  # Add self
	    timer.Start()
	    engine.AddTimer(timer)
	    return timerId

	def SetInterval(callback, interval)
	    timerId = "interval_" + string(random(999999))
	    timer = new stzRingTimer(timerId, interval, callback, engine, false, self)
	    timer.Start()
	    engine.AddTimer(timer)
	    return timer  # Return timer object instead of just ID

	def ClearInterval(timer)
		if isString(timer)
			# Handle string ID case
			engine.timerManager.RemoveTimer(timer)
		else
			# Handle timer object case
			timer.Stop()
			engine.timerManager.RemoveTimer(timer.timerId)
		ok
		# Don't auto-stop engine here - let it be done explicitly

# =============================================================================
# CORE REACTIVE ENGINE
# =============================================================================

class stzReactiveEngine

	# Core engine state
	timerManager = NULL
	tasks = []
	streams = []
	isRunning = false
	mainReactive = NULL

	def Init()
		timerManager = new stzTimerManager()
		timerManager.Init()
		tasks = []
		streams = []
		isRunning = false
		
	def Start()
		if not isRunning

			isRunning = true

			# Give a moment for timers to be set up before starting the loop
			sleep(0.1)

			# Execute any pending chunked tasks
			for task in tasks
			    if task.status = "pending"
			        task.Execute()
			    ok
			next

			timerManager.RunLoop()
			isRunning = false
		ok
		
	def Stop()
		isRunning = false
		timerManager.Stop()
		# Clean up all resources
		for task in tasks
			task.Cleanup()
		next
		for stream in streams  
			stream.Cleanup()
		next
		
	def AddTask(task)
		tasks + task
		
	def AddStream(stream)
		streams + stream
		
	def AddTimer(timer)
		timerManager.AddTimer(timer)

# =============================================================================
# REACTIVE TASK - Core abstraction for async operations
# =============================================================================

class stzReactiveTask

	# Task properties
	taskId = ""
	taskFunc = NULL
	onComplete = NULL
	onError = NULL
	status = "pending"  # pending, running, completed, error
	result = NULL
	engine = NULL
	
	def Init(id, f, engine)
		taskId = id
		taskFunc = f
		this.engine = engine
		status = "pending"
		
	def Then_(completeFunc)
		onComplete = completeFunc
		return self
		
	def Catch_(errorFunc)
		onError = errorFunc
		return self
		
	def Execute()
		try
			status = "running"
			if isString(taskFunc)
				result = call taskFunc()
			else
				result = call taskFunc()
			ok
			status = "completed"
			if onComplete != NULL
				call onComplete(result)
			ok
		catch
			status = "error"
			if onError != NULL
				call onError("Task execution failed")
			ok
		done
		
	def Cleanup()
		# Override in subclasses for specific cleanup

# =============================================================================
# REACTIVE STREAM - For continuous data flow (IMPROVED)
# =============================================================================

class stzReactiveStream

	streamId = ""
	sourceType = "manual"  # manual, libuv, timer
	dataBuffer = []
	subscribers = []
	errorHandlers = []
	completeHandlers = []
	engine = NULL
	isActive = false
	isCompleted = false

	# Transformation functions to apply
	transforms = []

	# LibUV handle (only for libuv-backed streams)
	uvHandle = NULL

	def Init(id, sourceType, engine)
		streamId = id
		this.sourceType = sourceType
		this.engine = engine
		dataBuffer = []
		subscribers = []
		errorHandlers = []
		completeHandlers = []
		transforms = []
		isActive = true
		isCompleted = false

	# Store map transformation
	def Map(mapFunction)
		transforms + [:map, mapFunction]
		return self
		
	# Store filter transformation
	def Filter(filterFunction)
		transforms + [:filter, filterFunction]
		return self
		
	# Store reduce transformation
	def Reduce(reduceFunction, initialValue)
		transforms + [:reduce, reduceFunction, initialValue]
		return self
		
	def Subscribe(subscriber)
		subscribers + subscriber
		return self

		def OnData(subscriber)
			return Subscribe(subscriber)
		
	def OnError(errorHandler)
		errorHandlers + errorHandler
		return self
		
	def OnComplete(completeHandler)
		completeHandlers + completeHandler
		return self
	        
	def Emit(data)
	    if not isActive or isCompleted
	        return
	    ok
	    
	    dataBuffer + data
	    
	    # Apply transforms
	    processedData = [data]
	    for transform in transforms
	        transformType = transform[1]
	        switch transformType
	        case :map
	            mapFunc = transform[2]
	            processedData = @Map(processedData, mapFunc)
	        case :filter
	            filterFunc = transform[2]
	            processedData = @Filter(processedData, filterFunc)
	        end
	    next
	    
	    # Emit to local subscribers
	    for subscriber in subscribers
	        for item in processedData
	            call subscriber(item)
	        next
	    next


	def EmitError(error)
		if not isActive or isCompleted
			return
		ok
		
		# Call error handlers
		for errorHandler in errorHandlers
			call errorHandler(error)
		next
		
		# Stop the stream on error
		Stop()

	def Complete()
		if isCompleted
			return
		ok
		
		isCompleted = true
		
		# Apply final transformations to all buffered data if needed
		# (This allows for operations like Reduce that need all data)
		processedData = dataBuffer
		hasReduceTransform = false
		
		for transform in transforms
			transformType = transform[1]
			switch transformType
			case :reduce
				reduceFunc = transform[2]
				initialValue = transform[3]
				processedData = [ @Reduce(processedData, reduceFunc, initialValue)]
				hasReduceTransform = true
			end
		next
		
		# Only emit final reduced result if we had a reduce transform
		if hasReduceTransform
			for subscriber in subscribers
				for item in processedData
					call subscriber(item)
				next
			next
		ok
		
		# Call completion handlers
		for completeHandler in completeHandlers
			call completeHandler()
		next
		
		Stop()

		def End_()
			This.Complete()

		def Close()
			This.Complete()

	def Start()
		isActive = true
		isCompleted = false
		return self
		
	def Stop()
		isActive = false
		return self
		
	def Cleanup()
		Stop()
		if uvHandle != NULL and sourceType = "libuv"
			# Clean up LibUV resources
			uvHandle = NULL
		ok

# =============================================================================
# REACTIVE TIMER - For time-based operations
# =============================================================================

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


#---

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

# =============================================================================
# REACTIVE HTTP CLIENT - For web requests
# =============================================================================

class stzReactiveHttp

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def Get_(url, onSuccess, onError)
		task = new stzHttpTask(:http_get, url, "GET", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def Post(url, data, onSuccess, onError)
		task = new stzHttpTask(:http_post, url, "POST", data, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

class stzHttpTask from stzReactiveTask

	url = ""
	method = "GET"
	data = NULL
	
	def Init(id, url, method, data, engine)
		super.Init(id, NULL, engine)
		this.url = url
		this.method = method
		this.data = data
		
	def Execute()
	    status = "running"
	    
	    # Use Ring's built-in HTTP capabilities
	    if method = "GET"
	        result = PerformHttpGet(url)
	    else
	        result = PerformHttpPost(url, data)
	    ok
	    
	    # Check if we got a valid result
	    if result != NULL and result != ""
	        status = "completed"
	        if onComplete != NULL
	            call onComplete(result)
	        ok
	    else
	        status = "error"
	        if onError != NULL
	            call onError("HTTP request failed")
	        ok
	    ok
			
	# Helper methods for HTTP operations
	def PerformHttpGet(url)
	    result = download(url)
	    if result = NULL
	        result = ""
	    ok
	    return result

	def PerformHttpPost(url, data)
	    # Initialize curl
	    curl = curl_easy_init()
	    if curl = NULL
	        return ""
	    ok
	    
	    # Set basic options
	    curl_easy_setopt(curl, CURLOPT_USERAGENT, "stzReactive/1.0")
	    curl_easy_setopt(curl, CURLOPT_URL, url)
	    
	    # Set POST data
	    if data != NULL and data != ""
	        if isString(data)
	            postData = data
	        else
	            # Convert list/object to query string format
	            postData = ""
	            # Simple conversion - extend as needed
	        ok
	        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData)
	    ok
	    
	    # Perform request and get response content
	    result = curl_easy_perform_silent(curl)
	    
	    # Cleanup
	    curl_easy_cleanup(curl)
	    
	    # Return result or empty string on failure
	    if result = NULL
	        result = ""
	    ok
	    return result

# =============================================================================
# REACTIVE FILE SYSTEM - For file operations
# =============================================================================

class stzReactiveFileSystem

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def ReadFile(filePath, onSuccess, onError)
		task = new stzFileTask("file_read", filePath, "read", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def WriteFile(filePath, content, onSuccess, onError)
		task = new stzFileTask("file_write", filePath, "write", content, engine)
		task.Then_(onSuccess) 
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def WatchFile(filePath, onChange)
		watcher = new stzFileWatcher(filePath, onChange, engine)
		engine.AddStream(watcher)
		watcher.Start()
		return watcher

class stzFileTask from stzReactiveTask

	filePath = ""
	operation = "read"
	content = NULL
	
	def Init(id, path, op, data, engine)
		super.Init(id, NULL, engine)
		filePath = path
		operation = op
		content = data
		
	def Execute()
		try
			status = "running"
			if operation = "read"
				result = read(filePath)
			else
				write(filePath, content)
				result = "File written successfully"
			ok
			status = "completed"
			if onComplete != NULL
				call onComplete(result)
			ok
		catch
			status = "error"
			if onError != NULL
				call onError("File operation failed")
			ok
		done

class stzFileWatcher from stzReactiveStream

	filePath = ""
	
	def Init(path, changeCallback, engine)
		super.Init("file_watch_" + path, "timer", engine)
		filePath = path
		Subscribe(changeCallback)
		
	def Start()
		super.Start()
		# In real implementation, use LibUV file system events
		# For now, simulate with timer-based polling
		watcher = new stzReactiveTimer("watcher_" + filePath, 1000, Method(:CheckFile), engine)
		engine.AddTimer(watcher)
		watcher.Start()
		
	def CheckFile()
		# Simplified file change detection
		# In real implementation, use proper file system events
		Emit("File changed: " + filePath)

# =============================================================================
# REACTIVE FUNCTION WRAPPER - Makes any function reactive
# =============================================================================

class stzReactiveFuncWrapper

	originalFunc = NULL
	engine = NULL
	
	def Init(f, engine)
		originalFunc = f
		this.engine = engine
		
	def Call_(params)
		task = new stzFunctionTask("func_call", originalFunc, params, engine)
		engine.AddTask(task)
		return task
		
	# CallAsync() for normal operations
	# CallAsyncChunked() when they know they have heavy
	# computations that should yield control to other operations

	def CallAsync(params, onComplete, onError)
		task = new stzFunctionTask("func_call_async", originalFunc, params, engine)
		task.Then_(onComplete)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

class stzFunctionTask from stzReactiveTask

	@f = NULL
	params = []
	
	def Init(id, f, params, engine)
		super.Init(id, NULL, engine)
		this.@f = f
		this.params = params
		
	def Execute()
		try
			status = "running"
			if len(params) = 0
				result = call @f()
			else
				# Handle parameters - Ring requires individual params
				switch len(params)
				case 1
					result = call @f(params[1])
				case 2
					result = call @f(params[1], params[2])
				case 3
					result = call @f(params[1], params[2], params[3])
				# Add more cases as needed
				other
					result = call @f() # Fallback
				end
			ok
			status = "completed"
			if onComplete != NULL
				call onComplete(result)
			ok
		catch
			status = "error"
			if onError != NULL
				call onError("Function execution failed")
			ok
		done
