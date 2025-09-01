load "libuv.ring"


#=====================#
#  MAIN REACTIVE API  #
#=====================#

# Provides a high-level abstraction for reactive programming
# simplifying asynchronous operations using libuv.

class stzReactiveEngine from stzReactiveSystem
class stzReactive from stzReactiveSystem
class stzReactiveSystem

	# Libuv internal loop
	@libuvLoop

	# Core engine state
	#------------------
	# Manages the internal state of the reactive system,
	# tracking timers, tasks, streams, and handlers.

	timerManager = NULL
	tasks = []
	streams = []

	isRunning = ENGINE_STOPPED

	# Reactive components
	#--------------------

	http = NULL
	oDataStream = NULL
	oHttpStream = NULL

	#-----------------------------------------#
	#  INITIALIZATION OF THE REACTIVE SYSTEM  #
	#-----------------------------------------#

	# Sets up the timer manager and core reactive components,
	# preparing the system for asynchronous operations.

	def init()

		# Initiates the reactive system and runs the event loop.
		@libuvLoop = uv_default_loop()

		timerManager = new stzTimerManager()
		http = new stzReactiveHttp(self)

		tasks = []
		streams = []

		isRunning = ENGINE_STOPPED


	def LibuvLoop()
		return @libuvLoop

	#----------------------------------------------------------#
	#  STARTING AND STOPPING THE REACTIVE SYSTEM (LIBUV LOOP)  #
	#----------------------------------------------------------#

	# Controls the lifecycle of the event loop, managing the
	# execution and cleanup of asynchronous operations.

	def Start()
	    # Initiates the reactive system and runs the event loop.
	    if isRunning = ENGINE_STOPPED
	        isRunning = ENGINE_RUNNING
	        sleep(0.1)
	
	        # Execute any pending chunked tasks
	        nLenTasks = len(tasks)
	        for i = 1 to nLenTasks
	            if tasks[i].status = TASK_PENDING
	                tasks[i].Execute()
	            ok
	        next
	
		# Run timer-based loop for other reactive components
	        timerManager.RunLoop()	        
	        isRunning = ENGINE_STOPPED
	    ok

		#< @FunctionAlternativeForms

		def Run()
			This.Start()
		def RunLoop()
			This.Start()
		def Execute()
			This.Start()
		def ExecuteLoop()
			This.Start()

		#--

		def RunReactiveLoop()
			This.Start()

		def ExecuteReactiveLoop()
			This.Start()

		#>

	def Stop()
		# Stops the system and cleans up tasks, streams, and handlers.
		isRunning = ENGINE_STOPPED
		timerManager.Stop()

		# Clean up all tasks
		nLenTasks = len(tasks)
		for i = 1 to nLenTasks
			tasks[i].Cleanup()
		next

		# Clean up streams
		nLenStreams = len(streams)
		for i = 1 to nLenStreams 
			streams[i].Cleanup()
		next

		#< @FunctionAlternativeForms

		def StopLoop()
			This.Stop()

		def StopExecution()
			This.Stop()

		def StopLoopExecution()
			This.Stop()
		#>

	def StopSafe()
		# Schedules system stop for the next tick to avoid self-reference issues.
		SetTimeout(IMMEDIATE + 1, func() {
			Stop()
		})
	
		#< @FunctionAlternativeForms

		def SafeStopLoop()
			This.StopSafe()

		def SafeStopExecution()
			This.StopSafe()

		def SafeStopLoopExecution()
			This.StopSafe()

		def StopNext()
			This.StopSafe()

		def StopNextLoop()
			This.StopSafe()
		#>

	#--------------------------------------------------------------#
	#  GENERAL REACTIVE METHOD - REACTIVATES A FUNCTION OR OBJECT  #
	#--------------------------------------------------------------#

	# Enables functions or objects to participate in the
	# asynchronous event loop with reactive behavior.

	def Reactivate(p)
		# Wraps a function or object in a reactive context.
		if isNull(p) or isObject(p)
			return new stzReactiveObject(p, self)
		but isFunction(p)
			return ReactivateFunction(p)
		else
			raise("Parameter must be either a function name (string) or an object or a null.")
		ok

		#< @FunctionAlternativeForm
		def MakeReactive(param)
			return Reactivate(param)
		#>

	#----------------------#
	#  REACTIVE FUNCTIONS  #
	#----------------------#

	# Wraps functions for asynchronous, event-driven
	# execution within the reactive system.

	def ReactivateFunction(cFuncName)
		# Wraps a named function in a reactive wrapper.
		if NOT isString(cFuncName)
			raise("Function name must be a string")
		ok
		return new stzReactiveFunc(cFuncName, self)

		#< @FunctionAlternativeForm
		def MakeFunctionReactive(cFuncName)
			return ReactivateFunction(cFuncName)
		#>

	#--------------------#
	#  REACTIVE OBJECTS  #
	#--------------------#

	# Manages reactive objects for data binding and
	# asynchronous updates in the event loop.

	def ReactivateObject(p)
		# Wraps an object in a reactive wrapper.
		return new stzReactiveObject(p, self)

		#< @FunctionAlternativeForm
		def MakeReactiveObject(p)
			return new stzReactiveObject(p, self)
		#>

	def ReactiveObject()
		# Creates a reactive object with no initial state.
		return new stzReactiveObject(NULL, self)

		#< @FunctionAlternativeForm
		def CreateReactiveObject()
			return new stzReactiveObject(NULL, self)
		#>

	def BindObjects(poSource, pcSourceAttr, poTarget, pcTargetAttr, bindingMode)
		# Binds attributes of two reactive objects for synchronized updates.
		if bindingMode = NULL
			bindingMode = DEFAULT_BINDING_MODE
		ok
		
		_oXSource_ = new stzReactiveObject(poSource, self)
		_oXTarget_ = new stzReactiveObject(poTarget, self)
		_oXSource_.BindTo(_oXTarget_, pcSourceAttr, pcTargetAttr)

	#--------------------#
	#  REACTIVE STREAMS  #
	#--------------------#

	# Creates and manages streams for processing asynchronous data
	# flows from various sources (timers, network, etc.).

	def CreateStreamXT(id, sourceType)
		# Creates a generic stream with a specified ID and source type.
		if sourceType = NULL
			sourceType = DEFAULT_STREAM_SOURCE
		ok
		
		stream = new stzReactiveStream(id, sourceType, self)
		stream.Start()
		AddStream(stream)
		return stream

	def CreateStream(id)
		return This.CreateStreamXT(id, "manual")

	def CreateNetworkStream(id)
		return This.CreateStreamXT(id, "network")

	def CreateSensorStream(id)
		return This.CreateStreamXT(id, "sensor")

	def CreateFileStream(id)
		return This.CreateStreamXT(id, "file")

	def CreateTimerStream(id)
		return This.CreateStreamXT(id, "timer")

	def CreateLibuvStream(id)
		return This.CreateStreamXT(id, "libuv")

	#-------------------#
	#  REACTIVE TIMERS  #
	#-------------------#

	# Manages timers for scheduling delayed or periodic
	# tasks in the reactive system.

	def CreateTimer(id, intervalMs, callback) # Runs every second
		return This.CreateTimerXT(id, intervalMs, callback, FALSE)

	def CreateTimerXT(id, intervalMs, callback, oneTime) # runs once after 5 seconds

	    if oneTime = NULL
	        oneTime = false
	    ok

	    timer = new stzReactiveTimer(id, intervalMs, callback, self, oneTime)
	    timerManager.AddTimer(timer)
	    timer.Start()

	    return timer

	def CreateTask(id, f)
		# Creates an asynchronous task with a specified function.
		task = new stzReactiveTask(id, f, self, NULL)
		This.AddTask(task)
		return task

	def RunAfterXT(nDelay, cUnit, callback)
		if isNull(cUnit)
			cUnit = "milliseconds"
		ok

		switch cUnit
		on "seconds"
			nDelay = nDelay / 1000

		on "minutes"
			nDelay = nDelay / 60000
		off

		return This.RunAfter(nDelay, callback)

		def SetTimeoutXT(nDelay, cUnit, callback)

	def RunAfter(delay, callback)
		# Sets a one-time timer with a delay and callback.
		if CheckParams()
			if isNumber(callback) and NOT isNumber(delay)
				tempval = delay
				delay = callback
				callback = tempval
			ok
		ok

		if delay = NULL
			delay = IMMEDIATE
		ok

		timerId = "timeout_" + random(999999)
		timer = new stzRingTimer(timerId, delay, callback, self, true, self)
		timer.Start()
		This.AddTimer(timer)
		return timerId

		def SetTimeout(delay, callback)
			return This.RunAfter(delay, callback)

	def RunEveryXT(nInterval, cUnit, callback)
		if isNull(cUnit)
			cUnit = "milliseconds"
		ok

		switch cUnit
		on "seconds"
			nInterval = nInterval / 1000

		on "minutes"
			nInterval = nInterval / 60000
		off

		return This.RunEvery(nInterval, callback)

	def RunEvery(interval, callback)
		# Sets a periodic timer with an interval and callback.
		if CheckParams()
			if isNumber(callback) and NOT isNumber(interval)
				tempval = interval
				interval = callback
				callback = tempval
			ok
		ok

		if interval = NULL
			interval = DEFAULT_TIMER_DELAY
		ok

		timerId = "interval_" + random(999999)
		timer = new stzRingTimer(timerId, interval, callback, self, false, self)
		timer.Start()
		AddTimer(timer)
		return timer

		def SetInterval(interval, callback)
			return This.RunEvery(interval, callback)

	def ClearInterval(timer)
		# Clears a periodic timer by ID or object.
		if isString(timer)
			timerManager.RemoveTimer(timer)
		else
			timer.Stop()
			timerManager.RemoveTimer(timer.timerId)
		ok

	#--------------------------#
	#  REACTIVE HTTP REQUESTS  #
	#--------------------------#

	# Handles asynchronous HTTP GET and POST requests
	# for network communication.

	def HttpGet(url, onSuccess, onError)
		return This.HttpGetXT(url, onSuccess, onError, DEFAULT_ERROR_HANDLING)

	def HttpGetXT(url, onSuccess, onError, errorHandling)
		# Performs an asynchronous HTTP GET request.
		if errorHandling = NULL
			errorHandling = DEFAULT_ERROR_HANDLING
		ok
		return http.Get_(url, onSuccess, onError) # Get is a reserved keyword by Ring

	#--

	def HttpPost(url, data, onSuccess, onError)
		return This.HttpPostXT(url, data, onSuccess, onError, DEFAULT_ERROR_HANDLING)

	def HttpPostXT(url, data, onSuccess, onError, errorHandling)
		# Performs an asynchronous HTTP POST request with data.
		if errorHandling = NULL
			errorHandling = DEFAULT_ERROR_HANDLING
		ok
		return http.Post(url, data, onSuccess, onError)

	#--------------------#
	#  BUFFER UTILITIES  #
	#--------------------#

	# Converts between libuv buffers and strings for
	# easier data processing in network operations.

	def LibUVBufferToString(buffer)
		# Converts a libuv buffer to a string.
		return uv_buf2str(buffer)

	def StringToLibUVBuffer(str)
		# Converts a string to a libuv buffer for writing.
		return uv_buf_init(str, len(str))

	#--------------------#
	#  INTERNAL METHODS  #
	#--------------------#

	# Manages tasks, streams, and timers
	# for internal system operations.

	def AddTask(task)
		# Adds a task to the internal task list.
		tasks + task
		
	def AddStream(stream)
		# Adds a stream to the internal stream list.
		streams + stream
		
	def AddTimer(timer)
		# Adds a timer to the timer manager.
		timerManager.AddTimer(timer)
