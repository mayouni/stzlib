load "libuv.ring"


#-----------------------------------------------------------#
#  MAIN REACTIVE API - Simple interface for common patterns #
#-----------------------------------------------------------#

class stzReactive from stzReactiveSystem
class stzReactiveSystem

   # Core engine state
   timerManager = NULL
   tasks = []
   streams = []
   fileWatchers = []
   isRunning = ENGINE_STOPPED

   # Reactive components
   http = NULL
   fs = NULL
   oDataStream = NULL
   oHttpStream = NULL

   def Init()
   	timerManager = new stzTimerManager()
   	timerManager.Init()
   	tasks = []
   	streams = []
   	isRunning = ENGINE_STOPPED
   	http = new stzReactiveHttp(self)
   	fs = new stzReactiveFileSystem(self)

   def Start()
   	if isRunning = ENGINE_STOPPED
   		isRunning = ENGINE_RUNNING
   		sleep(0.1)

   		# Execute any pending chunked tasks
   		for task in tasks
   			if task.status = TASK_PENDING
   				task.Execute()
   			ok
   		next

   		timerManager.RunLoop()
   		isRunning = ENGINE_STOPPED
   	ok
   	
   def Stop()
   	isRunning = ENGINE_STOPPED
   	timerManager.Stop()

   	# Clean up all tasks
   	for task in tasks
   		task.Cleanup()
   	next

	# Clean up streams
   	for stream in streams  
   		stream.Cleanup()
   	next

	# Clean up file watchers
	for watcher in fileWatchers
	    watcher.Stop()
	next

   def StopSafe()
   	# Schedule stop for next tick to avoid self-reference issues
   	SetTimeout(IMMEDIATE + 1, func() {
   		Stop()
   	})
   
   # Primary factory methods
   def Reactivate(param)
   	if isNull(param) or isObject(param)
   		return new stzReactiveObject(param, self)
   	elseif isFunction(param)
   		return ReactivateFunction(param)
   	else
   		raise("Parameter must be either a function name (string) or an object or a null.")
   	ok

   def ReactivateObject(p)
   	return new stzReactiveObject(p, self)

   def ReactiveObject()
   	return new stzReactiveObject(NULL, self)

   def ReactivateFunction(cFuncName)
   	if NOT isString(cFuncName)
   		raise("Function name must be a string")
   	ok
   	return new stzReactiveFuncWrapper(cFuncName, self)

   # Aliases
   def MakeReactive(param)
   	return Reactivate(param)

   def MakeReactiveObject(p)
   	return new stzReactiveObject(p, self)

   def CreateReactiveObject()
   	return new stzReactiveObject(NULL, self)

   def MakeFunctionReactive(cFuncName)
   	return ReactivateFunction(cFuncName)

   #-------------------------------------------------------#
   #  ENHANCED STREAM API - Rich streaming functionality   #
   #-------------------------------------------------------#

   def CreateStream(id, sourceType)
   	if sourceType = NULL
   		sourceType = DEFAULT_STREAM_SOURCE
   	ok
   	
   	stream = new stzReactiveStream(id, sourceType, self)
   	stream.Start()
   	AddStream(stream)
   	return stream

   # Manual data stream creation
   def CreateDataStream(id)
   	return CreateStream(id, STREAM_MANUAL)

   # Timer-based stream creation
   def CreateTimerStream(id, intervalMs)
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

   # Event-driven stream creation
   def CreateEventStream(id)
   	return CreateStream(id, STREAM_EVENT)

   # File monitoring stream
   def CreateFileStream(id, filePath)
   	stream = CreateStream(id, STREAM_FILE)
   	
   	# Set up file watcher
   	WatchFile(filePath, func(change) {
   		if stream.isActive = STREAM_ACTIVE
   			stream.Emit(change)
   		ok
   	})
   	
   	return stream

   # HTTP response stream
   def CreateHttpStream(id, url, method, data)
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

   # Create stream from array/list data
   def CreateStreamFromData(id, dataList, emitDelay)
   	if emitDelay = NULL
   		emitDelay = VERY_SHORT  # 100ms between items
   	ok
   	
   	stream = CreateStream(id, STREAM_MANUAL)
   	
   	# Emit each item with configurable delay
   	for i = 1 to len(dataList)
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

   # Stream utilities and shortcuts
   def Stream(id, sourceType)
   	return CreateStream(id, sourceType)

   def DataStream(id)
   	return CreateDataStream(id)

   def TimerStream(id, intervalMs)
   	return CreateTimerStream(id, intervalMs)

   def EventStream(id)
   	return CreateEventStream(id)

   def FileStream(id, filePath)
   	return CreateFileStream(id, filePath)

   def HttpStream(id, url, method, data)
   	return CreateHttpStream(id, url, method, data)

   def StreamFromData(id, dataList, emitDelay)
   	return CreateStreamFromData(id, dataList, emitDelay)

   # Stream composition utilities
   def MergeStreams(streamList, errorHandling)
   	if len(streamList) = 0
   		return NULL
   	ok
   	
   	if errorHandling = NULL
   		errorHandling = DEFAULT_ERROR_HANDLING
   	ok
   	
   	mergedId = "merged_" + string(random(999999))
   	mergedStream = CreateStream(mergedId, STREAM_MANUAL)
   	
   	# Subscribe to all input streams
   	for stream in streamList
   		stream.OnData(func(data) {
   			mergedStream.Emit(data)
   		})
   		
   		stream.OnError(func(error) {
   			if errorHandling = ERROR_THROW
   				mergedStream.EmitError(error)
   			elseif errorHandling = ERROR_LOG
   				# Log error but continue
   				? "Stream error: " + error
   			ok
   		})
   		
   		stream.OnComplete(func() {
   			# Check if all streams are completed
   			allCompleted = STREAM_COMPLETED
   			for s in streamList
   				if s.isCompleted != STREAM_COMPLETED
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
   	if len(streamList) = 0
   		return NULL
   	ok
   	
   	if syncMode = NULL
   		syncMode = DEFAULT_ASYNC_MODE
   	ok
   	
   	combinedId = "combined_" + string(random(999999))
   	combinedStream = CreateStream(combinedId, STREAM_MANUAL)
   	
   	# Store latest values from each stream
   	latestValues = []
   	for i = 1 to len(streamList)
   		latestValues + NULL
   	next
   	
   	# Subscribe to all streams
   	for i = 1 to len(streamList)
   		stream = streamList[i]
   		stream.OnData(func(data) {
   			latestValues[i] = data
   			
   			# Check if we have values from all streams
   			allHaveValues = true
   			for value in latestValues
   				if value = NULL
   					allHaveValues = false
   					exit
   				ok
   			next
   			
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

   # Convenience methods for quick stream operations
   def MapStream(sourceStream, mapFunc)
   	return sourceStream.Map(mapFunc)

   def FilterStream(sourceStream, filterFunc)
   	return sourceStream.Filter(filterFunc)

   def ReduceStream(sourceStream, reduceFunc, initialValue)
   	return sourceStream.Reduce(reduceFunc, initialValue)

   def DebounceStream(sourceStream, delayMs)
   	if delayMs = NULL
   		delayMs = SHORT_DELAY
   	ok
   	return sourceStream.Debounce(delayMs)

   def ThrottleStream(sourceStream, intervalMs)
   	if intervalMs = NULL
   		intervalMs = SHORT_DELAY
   	ok
   	return sourceStream.Throttle(intervalMs)

   def DistinctStream(sourceStream)
   	return sourceStream.Distinct()

   #-------------------------------------------------------#
   #  EXISTING METHODS (with enhanced constants)          #
   #-------------------------------------------------------#

   def CreateTimer(id, interval, callback)
   	if interval = NULL
   		interval = DEFAULT_TIMER_DELAY
   	ok
   	timer = new stzReactiveTimer(id, interval, callback, self)
   	AddTimer(timer)
   	return timer
 
   def CreateTask(id, f)
   	task = new stzReactiveTask(id, f, self)
   	AddTask(task)
   	return task

   def BindObjects(poSource, pcSourceAttr, poTarget, pcTargetAttr, bindingMode)
   	if bindingMode = NULL
   		bindingMode = DEFAULT_BINDING_MODE
   	ok
   	
   	_oXSource_ = new stzReactiveObject(poSource, self)
   	_oXTarget_ = new stzReactiveObject(poTarget, self)
   	_oXSource_.BindTo(_oXTarget_, pcSourceAttr, pcTargetAttr)

   # Timing utilities with expressive defaults
   def SetTimeout(delay, callback)
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

   	timerId = "timeout_" + string(random(999999))
   	timer = new stzRingTimer(timerId, delay, callback, self, true, self)
   	timer.Start()
   	AddTimer(timer)
   	return timerId

   def SetInterval(interval, callback)
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

   	timerId = "interval_" + string(random(999999))
   	timer = new stzRingTimer(timerId, interval, callback, self, false, self)
   	timer.Start()
   	AddTimer(timer)
   	return timer

   def ClearInterval(timer)
   	if isString(timer)
   		timerManager.RemoveTimer(timer)
   	else
   		timer.Stop()
   		timerManager.RemoveTimer(timer.timerId)
   	ok

   # HTTP shortcuts with expressive methods
   def HttpGet(url, onSuccess, onError, errorHandling)
   	if errorHandling = NULL
   		errorHandling = DEFAULT_ERROR_HANDLING
   	ok
   	return http.Get_(url, onSuccess, onError, errorHandling)
   	
   def HttpPost(url, data, onSuccess, onError, errorHandling)
   	if errorHandling = NULL
   		errorHandling = DEFAULT_ERROR_HANDLING
   	ok
   	return http.Post(url, data, onSuccess, onError, errorHandling)
   	
   # File system shortcuts with expressive file modes
   def ReadFile(path, onSuccess, onError, mode)
   	if mode = NULL
   		mode = FILE_READ_ONLY
   	ok
   	return fs.ReadFile(path, onSuccess, onError, mode)
   	
   def WriteFile(path, content, onSuccess, onError, mode)
   	if mode = NULL
   		mode = FILE_WRITE_ONLY
   	ok
   	return fs.WriteFile(path, content, onSuccess, onError, mode)
   	
   def WatchFile(path, onChange, errorHandling)
   	if errorHandling = NULL
   		errorHandling = DEFAULT_ERROR_HANDLING
   	ok
   	return fs.WatchFile(path, onChange, errorHandling)

   # Internal management
   def AddTask(task)
   	tasks + task
   	
   def AddStream(stream)
   	streams + stream
   	
   def AddTimer(timer)
   	timerManager.AddTimer(timer)

   def AddFileWatcher(watcher)
       fileWatchers + watcher

   def RemoveFileWatcher(watcherId)
       for i = 1 to len(fileWatchers)
           if fileWatchers[i].watcherId = watcherId
               fileWatchers[i].Stop()
               del(fileWatchers, i)
               exit
           ok
       next

#---------------------------------------------------------#
#  REACTIVE TASK - Core abstraction for async operations  #
#---------------------------------------------------------#

class stzReactiveTask

   # Task properties
   taskId = ""
   taskFunc = NULL
   onComplete = NULL
   onError = NULL
   status = TASK_PENDING
   result = NULL
   engine = NULL
   errorHandling = DEFAULT_ERROR_HANDLING
   
   def Init(id, f, engine, errorMode)
   	taskId = id
   	taskFunc = f
   	this.engine = engine
   	status = TASK_PENDING
   	
   	if errorMode != NULL
   		errorHandling = errorMode
   	ok
   	
   def Then_(completeFunc)
   	onComplete = completeFunc
   	return self
   	
   def Catch_(errorFunc)
   	onError = errorFunc
   	return self
   	
   def Execute()
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
   		elseif errorHandling = ERROR_LOG
   			? errorMsg
   		elseif errorHandling = ERROR_CALLBACK and onError != NULL
   			call onError(errorMsg)
   		ok
   	done
   	
   def Cleanup()
   	# Override in subclasses for specific cleanup
