# load "libuv.ring" -- removed 2026-06-13 (M-DEP4 slice 1).
# The libuv-driven async runtime has been replaced with the
# pure-Ring poll-based fallback (stzRingTimer + clock()). The few
# uv_* call sites below are stubbed inline so the public surface
# stays stable; full async I/O lands in a later slice once the
# cross-platform Zig event loop is built.


#=====================#
#  MAIN REACTIVE API  #
#=====================#

# Provides a high-level abstraction for reactive programming
# simplifying asynchronous operations using libuv.

class stzReactiveEngine from stzReactiveSystem
class stzReactive from stzReactiveSystem
class stzReactiveSystem from stzObject

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

		# libuv default loop is no longer used; the polling timer
		# manager is the runtime now. We keep @libuvLoop as a NULL
		# sentinel so legacy callers that read the handle don't crash.
		@libuvLoop = NULL

		timerManager = new stzTimerManager()
		http = new stzReactiveHttp(self)

		tasks = []
		streams = []

		isRunning = ENGINE_STOPPED


	def LibuvLoop()
		# Compatibility: returns NULL since libuv is no longer wired.
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

	        # (Removed an unconditional sleep(0.1) here -- it added a flat
	        # 100ms to every RunLoop with no functional purpose.)

	        # Execute any pending chunked tasks
	        _nLenTasks_ = len(tasks)
	        for i = 1 to _nLenTasks_
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
		_nLenTasks_ = len(tasks)
		for i = 1 to _nLenTasks_
			tasks[i].Cleanup()
		next

		# Clean up streams
		_nLenStreams_ = len(streams)
		for i = 1 to _nLenStreams_ 
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
		if IsNull(p) or isObject(p)
			return new stzReactiveObject(p, self)
		but @IsFunction(p)
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

	def BindObjects(poSource, pcSourceAttr, poTarget, pcTargetAttr, _bindingMode_)
		# Binds attributes of two reactive objects for synchronized updates.
		if _bindingMode_ = NULL
			_bindingMode_ = DEFAULT_BINDING_MODE
		ok
		
		_oXSource_ = new stzReactiveObject(poSource, self)
		_oXTarget_ = new stzReactiveObject(poTarget, self)
		_oXSource_.BindTo(_oXTarget_, pcSourceAttr, pcTargetAttr)

	#--------------------#
	#  REACTIVE STREAMS  #
	#--------------------#

	# Creates and manages streams for processing asynchronous data
	# flows from various sources (timers, network, etc.).

	def CreateStreamXT(id, _sourceType_)
		# Creates a generic stream with a specified ID and source type.
		if _sourceType_ = NULL
			_sourceType_ = DEFAULT_STREAM_SOURCE
		ok
		
		_stream_ = new stzReactiveStream(id, _sourceType_, self)
		_stream_.Start()
		AddStream(_stream_)
		return _stream_

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

	def CreateTimer(id, intervalMs, _callback_) # Runs every second
		return This.CreateTimerXT(id, intervalMs, _callback_, FALSE)

	def CreateTimerXT(id, intervalMs, _callback_, _oneTime_) # runs once after 5 seconds

	    if _oneTime_ = NULL
	        _oneTime_ = false
	    ok

	    _timer_ = new stzReactiveTimer(id, intervalMs, _callback_, self, _oneTime_)
	    timerManager.AddTimer(_timer_)
	    _timer_.Start()

	    return _timer_

	def CreateTask(id, f)
		# Creates an asynchronous task with a specified function.
		_task_ = new stzReactiveTask(id, f, self, NULL)
		This.AddTask(_task_)
		return _task_

	def RunAfterXT(_nDelay_, _cUnit_, _callback_)
		if isNull(_cUnit_)
			_cUnit_ = "milliseconds"
		ok

		# Convert to milliseconds (the timer's native unit). seconds and
		# minutes scale UP, not down -- the old code divided, so
		# RunAfterXT(1, :seconds) asked for 0.001ms and fired instantly.
		if _cUnit_ = "seconds" or _cUnit_ = "second"
			_nDelay_ = _nDelay_ * 1000

		but _cUnit_ = "minutes" or _cUnit_ = "minute"
			_nDelay_ = _nDelay_ * 60000
		ok

		return This.RunAfter(_nDelay_, _callback_)

		def SetTimeoutXT(_nDelay_, _cUnit_, _callback_)

	def RunAfter(_delay_, _callback_)
		# Sets a one-time timer with a delay and callback.
		if CheckParams()
			if isNumber(_callback_) and NOT isNumber(_delay_)
				_tempval_ = _delay_
				_delay_ = _callback_
				_callback_ = _tempval_
			ok
		ok

		if _delay_ = NULL
			_delay_ = IMMEDIATE
		ok

		_timerId_ = "timeout_" + random(999999)
		_timer_ = new stzRingTimer(_timerId_, _delay_, _callback_, self, true, self)
		_timer_.Start()
		This.AddTimer(_timer_)
		return _timerId_

		def SetTimeout(_delay_, _callback_)
			return This.RunAfter(_delay_, _callback_)

	def RunEveryXT(_nInterval_, _cUnit_, _callback_)
		if isNull(_cUnit_)
			_cUnit_ = "milliseconds"
		ok

		# Convert to milliseconds (see RunAfterXT) -- scale up, not down.
		if _cUnit_ = "seconds" or _cUnit_ = "second"
			_nInterval_ = _nInterval_ * 1000

		but _cUnit_ = "minutes" or _cUnit_ = "minute"
			_nInterval_ = _nInterval_ * 60000
		ok

		return This.RunEvery(_nInterval_, _callback_)

	def RunEvery(_interval_, _callback_)
		# Sets a periodic timer with an interval and callback.
		if CheckParams()
			if isNumber(_callback_) and NOT isNumber(_interval_)
				_tempval_ = _interval_
				_interval_ = _callback_
				_callback_ = _tempval_
			ok
		ok

		if _interval_ = NULL
			_interval_ = DEFAULT_TIMER_DELAY
		ok

		_timerId_ = "interval_" + random(999999)
		_timer_ = new stzRingTimer(_timerId_, _interval_, _callback_, self, false, self)
		_timer_.Start()
		AddTimer(_timer_)
		return _timer_

		def SetInterval(_interval_, _callback_)
			return This.RunEvery(_interval_, _callback_)

	def StopTimer(_timer_)

		if isString(_timer_)
			timerManager.RemoveTimer(_timer_)
		else
			_timer_.Stop()
		ok

	def StopAllTimers()
	   timerManager.StopAllTimers()

	#--------------------------#
	#  REACTIVE HTTP REQUESTS  #
	#--------------------------#

	# Handles asynchronous HTTP GET and POST requests
	# for network communication.

	def HttpGet(url, onSuccess, onError)
		return This.HttpGetXT(url, onSuccess, onError, DEFAULT_ERROR_HANDLING)

	def HttpGetXT(url, onSuccess, onError, _errorHandling_)
		# Performs an asynchronous HTTP GET request.
		if _errorHandling_ = NULL
			_errorHandling_ = DEFAULT_ERROR_HANDLING
		ok
		return http.Get_(url, onSuccess, onError) # Get is a reserved keyword by Ring

	#--

	def HttpPost(url, data, onSuccess, onError)
		return This.HttpPostXT(url, data, onSuccess, onError, DEFAULT_ERROR_HANDLING)

	def HttpPostXT(url, data, onSuccess, onError, _errorHandling_)
		# Performs an asynchronous HTTP POST request with data.
		if _errorHandling_ = NULL
			_errorHandling_ = DEFAULT_ERROR_HANDLING
		ok
		return http.Post(url, data, onSuccess, onError)

	#--------------------#
	#  BUFFER UTILITIES  #
	#--------------------#

	# Converts between libuv buffers and strings for
	# easier data processing in network operations.

	def LibUVBufferToString(buffer)
		# libuv is gone; Ring buffers ARE strings, so this is identity.
		return buffer

	def StringToLibUVBuffer(str)
		# libuv is gone; Ring buffers ARE strings, so this is identity.
		return str

	#--------------------#
	#  INTERNAL METHODS  #
	#--------------------#

	# Manages tasks, streams, and timers
	# for internal system operations.

	def AddTask(_task_)
		# Adds a task to the internal task list.
		tasks + _task_
		
	def AddStream(_stream_)
		# Adds a stream to the internal stream list.
		streams + _stream_
		
	def AddTimer(_timer_)
		# Adds a timer to the timer manager.
		timerManager.AddTimer(_timer_)
