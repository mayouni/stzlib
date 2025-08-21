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
   isRunning = false
   
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
   	isRunning = false
   	http = new stzReactiveHttp(self)
   	fs = new stzReactiveFileSystem(self)

   def Start()
   	if not isRunning
   		isRunning = true
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

   def StopSafe()
   	# Schedule stop for next tick to avoid self-reference issues
   	SetTimeout(1, func() {
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

   def CreateStream(id, sourceType)
   	if sourceType = NULL
   		sourceType = "manual"
   	ok
   	
   	stream = new stzReactiveStream(id, sourceType, self)
   	stream.Start()
   	AddStream(stream)
   	return stream
 
   def CreateTimer(id, interval, callback)
   	timer = new stzReactiveTimer(id, interval, callback, self)
   	AddTimer(timer)
   	return timer
 
   def CreateTask(id, f)
   	task = new stzReactiveTask(id, f, self)
   	AddTask(task)
   	return task

   def BindObjects(poSource, pcSourceAttr, poTarget, pcTargetAttr)
   	_oXSource_ = new stzReactiveObject(poSource, self)
   	_oXTarget_ = new stzReactiveObject(poTarget, self)
   	_oXSource_.BindTo(_oXTarget_, pcSourceAttr, pcTargetAttr)

   # Timing utilities
   def SetTimeout(delay, callback)
	if CheckParams()
		if isNumber(callback) and NOT isNumber(delay)
			tempval = delay
			delay = callback
			callback = tempval
		ok
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

   # Internal management
   def AddTask(task)
   	tasks + task
   	
   def AddStream(stream)
   	streams + stream
   	
   def AddTimer(timer)
   	timerManager.AddTimer(timer)

#---------------------------------------------------------#
#  REACTIVE TASK - Core abstraction for async operations  #
#---------------------------------------------------------#

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
