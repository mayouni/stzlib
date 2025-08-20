load "libuv.ring"

#-----------------------------------------------------------#
#  MAIN REACTIVE API - Simple interface for common patterns #
#-----------------------------------------------------------#

class stzReactive

	engine = NULL
	http = NULL
	fs = NULL
	oDataStream = NULL
	oHttpStream = NULL

	reactiveObjects = []
	objectWatchManager = NULL

	def Init()
	    engine = new stzReactiveEngine()
	    engine.mainReactive = self
	    engine.Init()
	    http = new stzReactiveHttp(engine)
	    fs = new stzReactiveFileSystem(engine)

	   # Initialize reactive object system
	   objectWatchManager = new stzReactiveObjectManager(engine)
	   reactiveObjects = []

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
	
	def Reactivate(param)
		if isObject(param)
			return ReactivateObject(param)
		elseif isString(param)
			return ReactivateFunction(param)
		else
			raise("Parameter must be either a function name (string) or an object")
		ok

		def MakeReactive(param)
			return Reactivate(param)

	# Reactivate a function by name
	def ReactivateFunction(cFuncName)
		if CheckParams()
			if NOT isString(cFuncName)
				raise("Function name must be a string")
			ok
		ok
		
		return new stzReactiveFuncWrapper(cFuncName, engine)

		def MakeFunctionReactive(cFuncName)
			return ReactivateFunction(cFuncName)

	# Reactivate an existing object instance
	def ReactivateObject(oObject)
		if CheckParams()
			if NOT isObject(oObject)
				raise("Parameter must be an object")
			ok
		ok
		
		oWrapper = new stzReactiveObjectWrapper(oObject, engine, objectWatchManager)
		reactiveObjects + oWrapper
		return oWrapper

		def MakeObjectReactive(oObject)
			return ReactivateObject(oObject)

	# Create a new reactive object (when no existing object to wrap)
	def CreateReactiveObject()
		oReactiveObj = new stzReactiveObject(engine, objectWatchManager)
		reactiveObjects + oReactiveObj
		return oReactiveObj


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

	# Create reactive property binding between objects
	def BindObjects(oSource, cSourceProp, oTarget, cTargetProp)
		objectWatchManager.CreateBinding(oSource, cSourceProp, oTarget, cTargetProp)

#------------------------#
#  CORE REACTIVE ENGINE  #
#------------------------#

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
