load "libuv.ring"

#=====================#
#  MAIN REACTIVE API  #
#=====================#

# Provides a high-level abstraction for reactive programming
# simplifying asynchronous operations using libuv.

class stzReactive from stzReactiveSystem
class stzReactiveSystem

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
	# Specialized interfaces for HTTP, file system, UDP, TCP,
	# signals, workers, and DNS operations.

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
		timerManager = new stzTimerManager()
		timerManager.Init()
		tasks = []
		streams = []
		isRunning = ENGINE_STOPPED

		http = new stzReactiveHttp(self)


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
		return new stzReactiveFuncWrapper(cFuncName, self)

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

	# Creates and manages streams for handling asynchronous data
	# flows from various sources (timers, files, network, etc.).

	def CreateStream(id, sourceType)
		# Creates a generic stream with a specified ID and source type.
		if sourceType = NULL
			sourceType = DEFAULT_STREAM_SOURCE
		ok
		
		stream = new stzReactiveStream(id, sourceType, self)
		stream.Start()
		AddStream(stream)
		return stream

	def ShutdownStream(stream, onShutdown, onError)
		# Gracefully shuts down a stream with shutdown and error callbacks.
		req = uv_shutdown_t_init()
		uv_shutdown(req, stream, 
			func() { call onShutdown() }, 
			func(err) { call onError(err) })

	def CreateDataStream(id)
		# Creates a manual data stream for custom data emission.
		return CreateStream(id, STREAM_MANUAL)

	def CreateTimerStream(id, intervalMs)
		# Creates a stream that emits data at specified intervals.
		if intervalMs = NULL
			intervalMs = DEFAULT_TIMER_DELAY
		ok
		
		stream = CreateStream(id, STREAM_TIMER)

		# Set up timer to emit data at intervals
		SetInterval(intervalMs, func() {
			if stream.isActive = STREAM_ACTIVE
				stream.Emit(now())
			ok
		})
		
		return stream


	def CreateHttpStream(id, url, method, data)
		# Creates a stream for HTTP GET/POST responses.
		if method = NULL
			method = HTTP_GET
		ok
		
		stream = CreateStream(id, STREAM_HTTP)

		# Make HTTP request and emit response
		if method = HTTP_GET
			HttpGet(url, 
				func(response) {
					stream.Emit(response)
					stream.Complete()
				},
				func(error) {
					stream.EmitError(error)
				})
		else
			HttpPost(url, data,
				func(response) {
					stream.Emit(response)
					stream.Complete()
				},
				func(error) {
					stream.EmitError(error)
				})
		ok
		
		return stream


	def CreateStreamFromData(id, dataList, emitDelay)
		# Creates a stream that emits data from a list with a delay.
		if emitDelay = NULL
			emitDelay = VERY_SHORT  # 100ms between items
		ok
		
		stream = CreateStream(id, STREAM_MANUAL)

		# Emit each item with configurable delay
		nLenData = len(dataList)
		for i = 1 to nLenData
			data = dataList[i]
			SetTimeout(i * emitDelay, func() {
				if stream.isActive = STREAM_ACTIVE
					stream.Emit(data)
					if i = len(dataList)
						stream.Complete()
					ok
				ok
			})
		next
		
		return stream

		#< @FunctionAlternativeForms

		def Stream(id, sourceType)
			return CreateStream(id, sourceType)

		def TimerStream(id, intervalMs)
			return CreateTimerStream(id, intervalMs)

		def HttpStream(id, url, method, data)
			return CreateHttpStream(id, url, method, data)

		def StreamFromData(id, dataList, emitDelay)
			return CreateStreamFromData(id, dataList, emitDelay)
		#>

	#----------------------#
	#  STREAM COMPOSITION  #
	#----------------------#

	# Combines and transforms streams for complex
	# asynchronous data flows in the reactive system.

	def MergeStreams(streamList, errorHandling)
		# Merges multiple streams into a single stream.
		if len(streamList) = 0
			return NULL
		ok
		
		if errorHandling = NULL
			errorHandling = DEFAULT_ERROR_HANDLING
		ok
		
		mergedId = "merged_" + random(999999)
		mergedStream = CreateStream(mergedId, STREAM_MANUAL)

		# Subscribe to all input streams
		nLenStreams = len(streamList)
		for i = 1 to nLenStreams
			streamList[i].OnData(func(data) {
				mergedStream.Emit(data)
			})
			
			streamList[i].OnError(func(error) {
				if errorHandling = ERROR_THROW
					mergedStream.EmitError(error)
				but errorHandling = ERROR_LOG
					# Log error but continue
					? "Stream error: " + error
				ok
			})
			
			streamList[i].OnComplete(func() {
				# Check if all streams are completed
				allCompleted = STREAM_COMPLETED
				nLenSt = len(streamList)
				for j = 1 to nLenSt
					if streamList[j].isCompleted != STREAM_COMPLETED
						allCompleted = STREAM_ACTIVE
						exit
					ok
				next
				
				if allCompleted = STREAM_COMPLETED
					mergedStream.Complete()
				ok
			})
		next
		
		return mergedStream

	def CombineStreams(streamList, combineFunc, syncMode)
		# Combines streams by applying a function to their latest values.
		if len(streamList) = 0
			return NULL
		ok
		
		if syncMode = NULL
			syncMode = DEFAULT_ASYNC_MODE
		ok
		
		combinedId = "combined_" + random(999999)
		combinedStream = CreateStream(combinedId, STREAM_MANUAL)

		# Store latest values from each stream
		latestValues = []
		nLenStreamList = len(streamList)
		for i = 1 to nLenStreamList
			latestValues + NULL
		next

		# Subscribe to all streams
		for i = 1 to nLenStreamList
			stream = streamList[i]
			stream.OnData(func(data) {
				latestValues[i] = data
				
				allHaveValues = true
				nLenVal = len(latestValues)
				for j = 1 to nLenVal
					if latestValues[j] = NULL
						allHaveValues = false
						exit
					ok
				next

				# Check if we have values from all streams
				if allHaveValues
					if syncMode = PROCESS_ASYNC
						SetTimeout(IMMEDIATE, func() {
							result = call combineFunc(latestValues)
							combinedStream.Emit(result)
						})
					else
						result = call combineFunc(latestValues)
						combinedStream.Emit(result)
					ok
				ok
			})
		next
		
		return combinedStream

	def MapStream(sourceStream, mapFunc)
		# Applies a mapping function to a stream's data.
		return sourceStream.Map(mapFunc)

	def FilterStream(sourceStream, filterFunc)
		# Filters a stream's data based on a predicate function.
		return sourceStream.Filter(filterFunc)

	def ReduceStream(sourceStream, reduceFunc, initialValue)
		# Reduces a stream's data to a single value using a reducer function.
		return sourceStream.Reduce(reduceFunc, initialValue)

	def DebounceStream(sourceStream, delayMs)
		# Delays stream emissions to prevent rapid successive updates.
		if delayMs = NULL
			delayMs = SHORT_DELAY
		ok
		return sourceStream.Debounce(delayMs)

	def ThrottleStream(sourceStream, intervalMs)
		# Limits stream emissions to a fixed interval.
		if intervalMs = NULL
			intervalMs = SHORT_DELAY
		ok
		return sourceStream.Throttle(intervalMs)

	def DistinctStream(sourceStream)
		# Filters out duplicate emissions from a stream.
		return sourceStream.Distinct()

	#-------------------#
	#  REACTIVE TIMERS  #
	#-------------------#

	# Manages timers for scheduling delayed or periodic
	# tasks in the reactive system.

	def CreateTimer(id, interval, callback)
		# Creates a timer with a specified interval and callback.
		if interval = NULL
			interval = DEFAULT_TIMER_DELAY
		ok
		timer = new stzReactiveTimer(id, interval, callback, self)
		AddTimer(timer)
		return timer

	def CreateTask(id, f)
		# Creates an asynchronous task with a specified function.
		task = new stzReactiveTask(id, f, self)
		AddTask(task)
		return task

	def SetTimeout(delay, callback)
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
		AddTimer(timer)
		return timerId

	def SetInterval(interval, callback)
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

	# Manages tasks, streams, timers, and file watchers
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

	def AddFileWatcher(watcher)
		# Adds a file watcher to the internal list.
		fileWatchers + watcher

	def RemoveFileWatcher(watcherId)
		# Removes a file watcher by ID from the internal list.
		nLenFileWatchers = len(fileWatchers)
		for i = 1 to nLenFileWatchers
			if fileWatchers[i].watcherId = watcherId
				fileWatchers[i].Stop()
				del(fileWatchers, i)
				exit
			ok
		next

#=================#
#  REACTIVE TASK  #
#=================#

# Core Abstraction for Async Operations

# Manages asynchronous tasks with execution, completion,
# and error handling capabilities.

class stzReactiveTask

	# Task properties
	#----------------
	# Stores task metadata, function, status, and
	# callbacks for asynchronous execution.

	taskId = ""
	taskFunc = NULL
	onComplete = NULL
	onError = NULL
	status = TASK_PENDING
	result = NULL
	engine = NULL
	errorHandling = DEFAULT_ERROR_HANDLING

	def init(id, f, engine, errorMode)
		# Initializes a task with an ID, function, and engine reference.
		taskId = id
		taskFunc = f
		this.engine = engine
		status = TASK_PENDING
		
		if errorMode != NULL
			errorHandling = errorMode
		ok
		
	def Then_(completeFunc)
		# Sets the callback for task completion.
		onComplete = completeFunc
		return self
		
	def Catch_(errorFunc)
		# Sets the callback for task errors.
		onError = errorFunc
		return self
		
	def Execute()
		# Executes the task, handling success and error cases.
		try
			status = TASK_RUNNING
			if isString(taskFunc)
				result = call taskFunc()
			else
				result = call taskFunc()
			ok
			status = TASK_COMPLETED
			if onComplete != NULL
				call onComplete(result)
			ok

		catch
			status = TASK_ERROR
			errorMsg = "Task execution failed"
			
			if errorHandling = ERROR_THROW
				raise(errorMsg)
			but errorHandling = ERROR_LOG
				? errorMsg
			but errorHandling = ERROR_CALLBACK and onError != NULL
				call onError(errorMsg)
			ok
		done
		
	def Cleanup()
		# Cleans up task resources (overridable in subclasses).
