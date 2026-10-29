# REAXIS -- the DECLARATIVE reactive-programming SURFACE.
#
# THE MODULE'S TWO LAYERS (read this once):
#   * REAXIS  (this file + stzReactive{Stream,Object,Func,Http,Task,
#     Timer}) = the "what": streams, Watch/Computed, RunLoop, the
#     pipeline DSL. The paradigm surface.
#   * REACTOR (stzReactor + stzReactorPool) = the "how": the real
#     async I/O runtime over VENDORED LIBUV, on its own engine thread.
#
# F5 (2026-07-14): Reaxis now RUNS ON Reactor. The system owns a
# stzReactor; the timer manager's inter-tick waits are real libuv
# timers awaited on the engine loop thread, and reactive HTTP submits
# through the reactor (async, drained on the same loop). Callbacks
# still DISPATCH on the Ring thread -- Ring is not thread-safe, so no
# callback ever crosses from libuv into Ring. When stz_reactor.dll is
# absent ($pStzReactorHandle = NULL) the old cooperative sleep-poller
# runs instead -- the documented no-DLL fallback (LAW 2).

#=====================#
#  MAIN REACTIVE API  #
#=====================#

# ENTRY OBJECT: stzReactiveSystem (the container). stzReactive is the
# documented SHORT ALIAS (same class). [Was three names; the redundant
# stzReactiveEngine alias was dropped 2026-07-14 for clarity.]

# Is the short name of stzReactiveSystem, so every method and every form is the same.
#
# Use whichever name reads better at the call site; the class adds nothing of its own.
#
#   receiver   o1 = new stzReactive()
#   example    ? isObject( o1.ReactorQ() )
#              #--> 1
#   see        stzReactiveSystem
class stzReactive from stzReactiveSystem
# Declarative reactive programming: schedules timers and tasks, makes functions and objects reactive, makes streams and non-blocking HTTP calls, and runs them all in one loop.
#
# Create one system, register what should happen (RunAfter, RunEvery, CreateTimer, CreateTask,
# HttpGet, the stream makers), then call Start: the loop runs the pending tasks, ticks the timers
# and drains the HTTP answers until nothing is left, the patience runs out or a callback calls Stop.
# The system sits on a stzReactor when the engine library is present, and falls back to a polling
# loop when it is not. Callbacks always run on the Ring thread. Timers are named by the id that
# RunAfter and RunEvery answer; StopTimer and StopAllTimers end them. Reactivate wraps a function or
# an object so that calls take success and error handlers. StopSafe and its five spellings ask the
# loop to end at the close of the pass that is running, from inside a callback. BindObjects binds
# the reactive objects you pass, once: the target takes the source value of the moment of binding.
#
#   receiver   o1 = new stzReactiveSystem()
#   example    ? isObject( o1.ReactorQ() )
#              #--> 1
#   see        stzReactor, stzReactiveObject, stzReactiveStream, stzTimerManager
class stzReactiveSystem from stzObject

	# F5: the reactor backing this system (a real libuv loop on an
	# engine thread), or NULL when stz_reactor.dll is absent and the
	# cooperative poller fallback runs instead.
	@oReactor = ""

	# Core engine state
	#------------------
	# Manages the internal state of the reactive system,
	# tracking timers, tasks, streams, and handlers.

	@timerManager = ""
	@tasks = []
	@streams = []

	@isRunning = $ENGINE_STOPPED

	# Set by StopSafe on the live system and read by the loop, which is handed the system itself.
	@bStopNext = 0

	# Reactive components
	#--------------------

	http = ""
	oDataStream = ""          # BRACE-ASSIGNABLE from user code (Rs { oDataStream = ... }) -- must stay bare, like stzApp's DSL slots
	@oHttpStream = ""

	#-----------------------------------------#
	#  INITIALIZATION OF THE REACTIVE SYSTEM  #
	#-----------------------------------------#

	# Builds a reactive system with a timer manager and an HTTP client, both backed by a stzReactor when the engine library is present.
	#
	#   returns    nothing; the object is built
	#   see        LibuvLoop, ReactorQ, Start
	#@ aka  Sets up the timer manager and core reactive components, preparing the system for asynchronous operations.
	def init()

		@timerManager = new stzTimerManager()
		http = new stzReactiveHttp(self)

		# F5: run on the reactor when the engine DLL is present; the
		# poller fallback needs no reactor at all. (SetReactor stores
		# COPIES that share the engine handle -- safe because the
		# handle is never destroyed while the system lives.)
		@oReactor = ""
		if $pStzReactorHandle != ""
			@oReactor = new stzReactor()
			@timerManager.SetReactor(@oReactor)
			http.SetReactor(@oReactor)
		ok

		@tasks = []
		@streams = []

		@isRunning = $ENGINE_STOPPED
		@bStopNext = 0

	# Returns the engine handle of the reactor behind the system, or "" when no reactor backs it.
	#
	#   returns    the engine handle, of type StzReactor; "" when the engine library is absent
	#   see        ReactorQ
	#@ aka  The real libuv loop handle backing this system (NULL in the no-DLL poller fallback). Real again since F5.
	def LibuvLoop()
		if @oReactor != ""
			return @oReactor.Handle()
		ok
		return ""

	# Returns the stzReactor that backs the system, so it can be chained; "" when there is none.
	#
	#   returns    a stzReactor, or "" when the engine library is absent
	#   note       the system never destroys this reactor; call Destroy on it once no loop runs
	#   see        LibuvLoop, init
	#@ aka  The backing reactor as a chainable stz object (Q-convention); NULL in the poller fallback.
	def ReactorQ()
		return @oReactor

	#----------------------------------------------------------#
	#  STARTING AND STOPPING THE REACTIVE SYSTEM (LIBUV LOOP)  #
	#----------------------------------------------------------#

	# Runs every pending task, then loops over the timers until none is left, the patience runs out or Stop is called.
	#
	#   returns    nothing; it comes back when the loop has ended
	#   note       an idle system ends after about 30 ms, but a repeating timer that nobody stops
	#              keeps the loop alive for ever; callbacks run on the Ring thread, one at a time
	#   see        Stop, RunAfter, RunEvery, CreateTask
	#@ aka  Controls the lifecycle of the event loop, managing the execution and cleanup of asynchronous operations.
	def Start()
	    # Initiates the reactive system and runs the event loop.
	    if @isRunning = $ENGINE_STOPPED
	        @isRunning = $ENGINE_RUNNING
	        @bStopNext = 0

	        # (Removed an unconditional sleep(0.1) here -- it added a flat
	        # 100ms to every RunLoop with no functional purpose.)

	        # Execute any pending chunked tasks
	        _nLenTasks_ = len(@tasks)
	        for i = 1 to _nLenTasks_
	            if @tasks[i].@status = $TASK_PENDING
	                @tasks[i].Execute()
	            ok
	        next
	
		# Run timer-based loop for other reactive components. The
		# LIVE system rides along as the by-ref drain param, so the loop
		# drains the http completions (an attribute copy would see a
		# dead snapshot -- the Ring aliasing doctrine) and reads the
		# stop request StopSafe made on this same live object.
	        @timerManager.RunLoop(This)
	        @isRunning = $ENGINE_STOPPED
	    ok

		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		#< @FunctionAlternativeForms
		def Run()
			This.Start()
		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		def RunLoop()
			This.Start()
		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		def Execute()
			This.Start()
		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		def ExecuteLoop()
			This.Start()

		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		#@ aka  --
		def RunReactiveLoop()
			This.Start()

		# Runs the loop; another spelling of the start call.
		#
		#   returns    nothing; it comes back when the loop has ended
		#   see        Start, Stop
		def ExecuteReactiveLoop()
			This.Start()

	# Marks the system as stopped, which ends a running loop, and cleans up every task and stream; the timers stay registered.
	#
	#   returns    nothing; the system changes
	#   note       the reactor is kept alive on purpose, because timer callbacks may call this while
	#              the loop runs
	#   see        Start, StopAllTimers, StopTimer
		#>
	def Stop()
		# Stops the system and cleans up tasks, streams, and handlers.
		@isRunning = $ENGINE_STOPPED
		@bStopNext = 0
		@timerManager.Stop()

		# Clean up all tasks
		_nLenTasks_ = len(@tasks)
		for i = 1 to _nLenTasks_
			@tasks[i].Cleanup()
		next

		# Clean up streams
		_nLenStreams_ = len(@streams)
		for i = 1 to _nLenStreams_
			@streams[i].Cleanup()
		next

		# Stops the system and ends a running loop; another spelling of the stop call.
		#
		#   returns    nothing; the system changes
		#   see        Stop
		#< @FunctionAlternativeForms
		#@ aka  F5: the reactor is deliberately NOT destroyed here. The manager/http hold handle-sharing COPIES (Ring attribute assignment copies objects), so destroying from Stop() -- which timer callbacks may invoke MID-LOOP -- would leave those copies submitting on a freed loop (use-after-free). The idle loop thread is reclaimed at process exit; callers needing eager teardown may ReactorQ().Destroy() once no l
		def StopLoop()
			This.Stop()

		# Stops the system and ends a running loop; another spelling of the stop call.
		#
		#   returns    nothing; the system changes
		#   see        Stop
		def StopExecution()
			This.Stop()

		# Stops the system and ends a running loop; another spelling of the stop call.
		#
		#   returns    nothing; the system changes
		#   see        Stop
		def StopLoopExecution()
			This.Stop()
	# Asks the running loop to stop at the end of the current pass, which is safe to call from a callback.
	#
	#   returns    nothing; a request is noted on the system
	#   note       the loop reads the request after the timers of the pass have ticked, then does what
	#              Stop does; a request made while no loop runs is dropped when Start begins
	#   warning    call it on the system itself, by the name your own variable gives it: a copy of the
	#              system (a stored attribute, an item of a list) notes the request on itself and the
	#              loop never reads it
	#   see        Stop, Start
		#>
	def StopSafe()
		# Notes the request on this live system; the loop it is running in reads it
		# at the end of the pass, through DrainPending. (It used to schedule a
		# callback calling a bare Stop(): a Ring lambda is a GLOBAL function, so
		# that Stop() was the profiler's, which raises the STOPPED banner.)
		@bStopNext = 1

		# Asks the running loop to stop at the end of the current pass; another spelling of the safe stop.
		#
		#   returns    nothing; a request is noted on the system
		#   see        StopSafe, Stop
		#< @FunctionAlternativeForms
		def SafeStopLoop()
			This.StopSafe()

		# Asks the running loop to stop at the end of the current pass; another spelling of the safe stop.
		#
		#   returns    nothing; a request is noted on the system
		#   see        StopSafe, Stop
		def SafeStopExecution()
			This.StopSafe()

		# Asks the running loop to stop at the end of the current pass; another spelling of the safe stop.
		#
		#   returns    nothing; a request is noted on the system
		#   see        StopSafe, Stop
		def SafeStopLoopExecution()
			This.StopSafe()

		# Asks the running loop to stop at the end of the current pass; another spelling of the safe stop.
		#
		#   returns    nothing; a request is noted on the system
		#   see        StopSafe, Stop
		def StopNext()
			This.StopSafe()

		# Asks the running loop to stop at the end of the current pass; another spelling of the safe stop.
		#
		#   returns    nothing; a request is noted on the system
		#   see        StopSafe, Stop
		def StopNextLoop()
			This.StopSafe()
		#>

	#--------------------------------------------------------------#
	#  GENERAL REACTIVE METHOD - REACTIVATES A FUNCTION OR OBJECT  #
	#--------------------------------------------------------------#

	# Wraps a function name or an object so that it can be called without blocking; anything else raises an error.
	#
	#   p          a function name as text, an anonymous function, an object, or NULL
	#   returns    a stzReactiveFunc for a function name or a function, a stzReactiveObject for an
	#              object or NULL
	#   see        ReactivateFunction, ReactivateObject, MakeReactive
	#@ aka  Enables functions or objects to participate in the asynchronous event loop with reactive behavior.
	def Reactivate(p)
		# Wraps a function or object in a reactive context.
		if IsNull(p) or isObject(p)
			return new stzReactiveObject(p, self)
		but @IsFunction(p)
			return ReactivateFunction(p)
		else
			raise("Parameter must be either a function name (string) or an object or a null.")
		ok

		# Wraps a function name or an object for non-blocking calls; another spelling of the reactivate call.
		#
		#   param      a function name as text, an anonymous function, an object, or NULL
		#   returns    a stzReactiveFunc for a function, a stzReactiveObject for an object or NULL
		#   see        Reactivate
		#< @FunctionAlternativeForm
		def MakeReactive(param)
			return Reactivate(param)
		#>

	#----------------------#
	#  REACTIVE FUNCTIONS  #
	#----------------------#

	# Wraps a named function in a stzReactiveFunc, whose calls take success and error handlers; a name that is not text raises an error.
	#
	#   cFuncName   the name of an existing function, as text
	#   returns     a stzReactiveFunc
	#   see         Reactivate, MakeFunctionReactive
	#@ aka  Wraps functions for asynchronous, event-driven execution within the reactive system.
	def ReactivateFunction(cFuncName)
		# Wraps a named function in a reactive wrapper.
		if NOT isString(cFuncName)
			raise("Function name must be a string")
		ok
		return new stzReactiveFunc(cFuncName, self)

		# Wraps a named function for non-blocking calls; another spelling of the function wrap.
		#
		#   cFuncName   the name of an existing function, as text
		#   returns     a stzReactiveFunc
		#   see         ReactivateFunction
		#< @FunctionAlternativeForm
		def MakeFunctionReactive(cFuncName)
			return ReactivateFunction(cFuncName)
		#>

	#--------------------#
	#  REACTIVE OBJECTS  #
	#--------------------#

	# Wraps an object in a stzReactiveObject, which watches its attributes and reacts to changes.
	#
	#   p          the object to wrap
	#   returns    a stzReactiveObject
	#   see        Reactivate, ReactiveObject
	#@ aka  Manages reactive objects for data binding and asynchronous updates in the event loop.
	def ReactivateObject(p)
		# Wraps an object in a reactive wrapper.
		return new stzReactiveObject(p, self)

		# Wraps an object in a reactive wrapper; another spelling of the object wrap.
		#
		#   p          the object to wrap
		#   returns    a stzReactiveObject
		#   see        ReactivateObject
		#< @FunctionAlternativeForm
		def MakeReactiveObject(p)
			return new stzReactiveObject(p, self)
	# Creates an empty reactive object, with no attribute yet, to which attributes are added by SetAttribute.
	#
	#   returns    a stzReactiveObject
	#   see        ReactivateObject, CreateReactiveObject
		#>
	def ReactiveObject()
		# Creates a reactive object with no initial state.
		return new stzReactiveObject("", self)

		# Creates an empty reactive object; another spelling of the empty creation.
		#
		#   returns    a stzReactiveObject
		#   see        ReactiveObject
		#< @FunctionAlternativeForm
		def CreateReactiveObject()
			return new stzReactiveObject("", self)
	# Binds a target attribute to a source attribute of two reactive objects, giving the target the source value at once.
	#
	#   poSource        the reactive object whose attribute is read, from ReactiveObject or ReactivateObject
	#   pcSourceAttr    the attribute of the source, as text
	#   poTarget        the reactive object whose attribute should follow
	#   pcTargetAttr    the attribute of the target, as text; "" for the same name as the source
	#   _bindingMode_   accepted and not used; pass ""
	#   returns         1 when the binding was made; 0 when an argument is not a reactive object, and
	#                   then nothing changes
	#   note            the two objects YOU pass are the ones that change: the target receives the value
	#                   and the source keeps the binding; to bind a plain object, make it reactive first
	#                   with ReactivateObject and keep the wrapper it answers
	#   warning         the target holds the value of the moment of binding: a later change of the source
	#                   does not reach it, because BindTo keeps a copy of its target; a plain object
	#                   cannot be bound, since Ring copies an object it is handed
	#   see             ReactiveObject, ReactivateObject
		#>
	def BindObjects(poSource, pcSourceAttr, poTarget, pcTargetAttr, _bindingMode_)
		# Binds the reactive objects the caller passed, by calling BindTo on the
		# PARAMETERS themselves (they reach the live objects). Wrapping them in
		# new stzReactiveObject bound COPIES, which is what this used to do.
		_bBothReactive_ = 0
		if isObject(poSource) and isObject(poTarget)
			if strcmp(ring_lower(ring_classname(poSource)), "stzreactiveobject") = 0
				if strcmp(ring_lower(ring_classname(poTarget)), "stzreactiveobject") = 0
					_bBothReactive_ = 1
				ok
			ok
		ok
		if NOT _bBothReactive_
			return 0
		ok

		poSource.BindTo(poTarget, pcSourceAttr, pcTargetAttr)
		return 1

	#--------------------#
	#  REACTIVE STREAMS  #
	#--------------------#

	# Creates and manages streams for processing asynchronous data
	# flows from various sources (timers, network, etc.).

	def CreateStreamXT(id, _sourceType_)
		# Creates a generic stream with a specified ID and source type.
		if _sourceType_ = ""
			_sourceType_ = $DEFAULT_STREAM_SOURCE
		ok
		
		_stream_ = new stzReactiveStream(id, _sourceType_, self)
		_stream_.Start()
		AddStream(_stream_)
		return _stream_

	# Creates a manual stream, starts it and registers it with the system; values are pushed into it by hand.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateNetworkStream, CreateTimerStream, AddStream
	def CreateStream(id)
		return This.CreateStreamXT(id, "manual")

	# Creates a stream marked as network sourced, starts it and registers it with the system.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateStream
	def CreateNetworkStream(id)
		return This.CreateStreamXT(id, "network")

	# Creates a stream marked as sensor sourced, starts it and registers it with the system.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateStream
	def CreateSensorStream(id)
		return This.CreateStreamXT(id, "sensor")

	# Creates a stream marked as file sourced, starts it and registers it with the system.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateStream
	def CreateFileStream(id)
		return This.CreateStreamXT(id, "file")

	# Creates a stream marked as timer sourced, starts it and registers it with the system.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateStream
	def CreateTimerStream(id)
		return This.CreateStreamXT(id, "timer")

	# Creates a stream marked as libuv sourced, starts it and registers it with the system.
	#
	#   id         the stream id, as text
	#   returns    a stzReactiveStream
	#   see        CreateStream
	def CreateLibuvStream(id)
		return This.CreateStreamXT(id, "libuv")

	#-------------------#
	#  REACTIVE TIMERS  #
	#-------------------#

	# Creates a repeating timer with an id and registers it with the timer manager; its callback runs every interval while the loop runs.
	#
	#   id           the timer id, as text
	#   intervalMs   the time between two calls, in milliseconds
	#   _callback_   the function to call at each tick, with no argument
	#   returns      a stzReactiveTimer
	#   note         CreateTimerXT with a last argument of 1 makes a one-shot timer; the timer only
	#                ticks while Start runs
	#   see          RunEvery, StopTimer, StopAllTimers
	#@ aka  Manages timers for scheduling delayed or periodic tasks in the reactive system.
	def CreateTimer(id, intervalMs, _callback_) # Runs every second
		return This.CreateTimerXT(id, intervalMs, _callback_, 0)

	def CreateTimerXT(id, intervalMs, _callback_, _oneTime_) # runs once after 5 seconds

	    if _oneTime_ = ""
	        _oneTime_ = 0
	    ok

	    _timer_ = new stzReactiveTimer(id, intervalMs, _callback_, self, _oneTime_)
	    @timerManager.AddTimer(_timer_)
	    _timer_.Start()

	    return _timer_

	# Creates a task around a function and registers it, so Start runs it once.
	#
	#   id         the task id, as text
	#   f          the function to run, a name or an anonymous function
	#   returns    a stzReactiveTask
	#   see        Start, AddTask
	def CreateTask(id, f)
		# Creates an asynchronous task with a specified function.
		_task_ = new stzReactiveTask(id, f, self, "")
		This.AddTask(_task_)
		return _task_

	# Milliseconds from a value and a unit name, or -1 when it cannot be
	# converted.
	#
	# RunAfterXT and RunEveryXT each carried their own copy of this switch, and
	# both ended at `ok` with no else -- so a unit neither recognised became
	# MILLISECONDS without a word. RunAfterXT(5, :hours) scheduled five
	# milliseconds instead of five hours: off by a factor of 3,600,000, silently.
	# Hours are converted now, and a unit this cannot convert is refused rather
	# than quietly turned into the smallest one there is.
	#
	# (seconds and minutes scale UP, not down -- the old code divided, so
	# RunAfterXT(1, :seconds) asked for 0.001ms and fired instantly.)
	def _DelayInMs(_nValue_, _cUnit_)
		if NOT isNumber(_nValue_)
			return -1
		ok
		if _nValue_ < 0
			return -1
		ok
		if isNull(_cUnit_)
			return _nValue_
		ok

		_c_ = StzLower("" + _cUnit_)
		if _c_ = "ms" or _c_ = "millisecond" or _c_ = "milliseconds"
			return _nValue_
		ok
		if _c_ = "second" or _c_ = "seconds"
			return _nValue_ * $SECOND
		ok
		if _c_ = "minute" or _c_ = "minutes"
			return _nValue_ * $MINUTE
		ok
		if _c_ = "hour" or _c_ = "hours"
			return _nValue_ * $HOUR
		ok
		return -1

	def RunAfterXT(_nDelay_, _cUnit_, _callback_)
		_nMs_ = This._DelayInMs(_nDelay_, _cUnit_)
		if _nMs_ < 0
			return ""
		ok
		return This.RunAfter(_nMs_, _callback_)

		# This alias had NO BODY. It was declared and the next line was the
		# next method, so every call did nothing and answered nothing --
		# scheduling no timer at all, where SetTimeout one screen down
		# delegates correctly.
		def SetTimeoutXT(_nDelay_, _cUnit_, _callback_)
			return This.RunAfterXT(_nDelay_, _cUnit_, _callback_)

	# Schedules a callback once after a delay and returns the timer id; the callback runs while the loop runs.
	#
	#   _delay_      the delay in milliseconds, "" for none
	#   _callback_   the function to call, with no argument
	#   returns      the timer id, as text such as "timeout_617987"
	#   note         the two arguments may be given in either order when one is a number; SetTimeout
	#                is the same call
	#   see          RunEvery, StopTimer, RunAfterXT
	def RunAfter(_delay_, _callback_)
		# Sets a one-time timer with a delay and callback.
		if CheckParams()
			if isNumber(_callback_) and NOT isNumber(_delay_)
				_tempval_ = _delay_
				_delay_ = _callback_
				_callback_ = _tempval_
			ok
		ok

		if _delay_ = ""
			_delay_ = $IMMEDIATE
		ok

		_timerId_ = "timeout_" + StzEngineRandomInt(0, 999999)
		_timer_ = new stzRingTimer(_timerId_, _delay_, _callback_, self, 1, self)
		_timer_.Start()
		This.AddTimer(_timer_)
		return _timerId_

		def SetTimeout(_delay_, _callback_)
			return This.RunAfter(_delay_, _callback_)

	def RunEveryXT(_nInterval_, _cUnit_, _callback_)
		_nMs_ = This._DelayInMs(_nInterval_, _cUnit_)
		if _nMs_ < 0
			return ""
		ok
		return This.RunEvery(_nMs_, _callback_)

	# Schedules a callback at every interval and returns the timer id, which StopTimer takes; the callback runs while the loop runs.
	#
	#   _interval_   the time between two calls, in milliseconds, "" for the default
	#   _callback_   the function to call, with no argument
	#   returns      the timer id, as text such as "interval_709795"
	#   note         SetInterval is the same call
	#   see          RunAfter, StopTimer, StopAllTimers
	def RunEvery(_interval_, _callback_)
		# Sets a periodic timer with an interval and callback.
		if CheckParams()
			if isNumber(_callback_) and NOT isNumber(_interval_)
				_tempval_ = _interval_
				_interval_ = _callback_
				_callback_ = _tempval_
			ok
		ok

		if _interval_ = ""
			_interval_ = $DEFAULT_TIMER_DELAY
		ok

		_timerId_ = "interval_" + StzEngineRandomInt(0, 999999)
		_timer_ = new stzRingTimer(_timerId_, _interval_, _callback_, self, 0, self)
		_timer_.Start()
		This.AddTimer(_timer_)

		# THE ID, not the object -- as RunAfter answers, and as every caller
		# already assumed: the demos name this `intervalId` and `cIntervalID`.
		# Handing back the object handed back something that could not control
		# the timer: AddTimer stores a COPY, so Stop() on the returned object
		# stopped a copy while the manager kept firing the real one.
		return _timerId_

		def SetInterval(_interval_, _callback_)
			return This.RunEvery(_interval_, _callback_)

	# Stops one timer, given by its id or by the timer object, by removing it from the timer manager.
	#
	#   _timer_    a timer id as text, or a timer object
	#   returns    the system itself
	#   note       an unknown id is ignored
	#   see        StopAllTimers, RunEvery, RunAfter
	#@ aka  Stops the timer whether it is named by id or handed as an object.
	def StopTimer(_timer_)
		if isString(_timer_)
			@timerManager.RemoveTimer(_timer_)
		else
			_timer_.Stop()
			@timerManager.RemoveTimer(_timer_.@timerId)
		ok
		return This

	# Stops and removes every timer of the timer manager, so a loop that waits only for timers ends.
	#
	#   returns    nothing; the timers are removed
	#   see        StopTimer, Stop
	def StopAllTimers()
	   @timerManager.StopAllTimers()

	#--------------------------#
	#  REACTIVE HTTP REQUESTS  #
	#--------------------------#

	# Starts an asynchronous GET and returns at once; the success or error handler runs while the loop runs.
	#
	#   url         the address, with its http:// or https:// start
	#   onSuccess   the function called with the response body
	#   onError     the function called with an error text
	#   returns     the job number of the request; a task object when the address is not http or
	#               https or no reactor backs the system
	#   see         HttpPost, HttpGetXT, Start
	#@ aka  Handles asynchronous HTTP GET and POST requests for network communication.
	def HttpGet(url, onSuccess, onError)
		return This.HttpGetXT(url, onSuccess, onError, $DEFAULT_ERROR_HANDLING)

	def HttpGetXT(url, onSuccess, onError, _errorHandling_)
		# Performs an asynchronous HTTP GET request.
		if _errorHandling_ = ""
			_errorHandling_ = $DEFAULT_ERROR_HANDLING
		ok
		return http.Get_(url, onSuccess, onError) # Get is a reserved keyword by Ring

	# Starts an asynchronous POST with a body and returns at once; the success or error handler runs while the loop runs.
	#
	#   url         the address, with its http:// or https:// start
	#   data        the request body, as text
	#   onSuccess   the function called with the response body
	#   onError     the function called with an error text
	#   returns     the job number of the request; a task object when the address is not http or
	#               https or no reactor backs the system
	#   see         HttpGet, HttpPostXT, Start
	#@ aka  --
	def HttpPost(url, data, onSuccess, onError)
		return This.HttpPostXT(url, data, onSuccess, onError, $DEFAULT_ERROR_HANDLING)

	def HttpPostXT(url, data, onSuccess, onError, _errorHandling_)
		# Performs an asynchronous HTTP POST request with data.
		if _errorHandling_ = ""
			_errorHandling_ = $DEFAULT_ERROR_HANDLING
		ok
		return http.Post(url, data, onSuccess, onError)

	#--------------------#
	#  BUFFER UTILITIES  #
	#--------------------#

	# Returns the buffer unchanged, since libuv buffers are plain texts in Ring; kept so old code still runs.
	#
	#   buffer     the buffer, which is already a text
	#   returns    the same text
	#   see        StringToLibUVBuffer
	#@ aka  Converts between libuv buffers and strings for easier data processing in network operations.
	def LibUVBufferToString(buffer)
		# libuv is gone; Ring buffers ARE strings, so this is identity.
		return buffer

	# Returns the text unchanged, since libuv buffers are plain texts in Ring; kept so old code still runs.
	#
	#   str        the text to hand over
	#   returns    the same text
	#   see        LibUVBufferToString
	def StringToLibUVBuffer(str)
		# libuv is gone; Ring buffers ARE strings, so this is identity.
		return str

	#--------------------#
	#  INTERNAL METHODS  #
	#--------------------#

	# Appends a task object to the list the system runs at Start.
	#
	#   _task_     the task object to keep
	#   returns    nothing; the system changes
	#   see        CreateTask, AddStream
	#@ aka  Manages tasks, streams, and timers for internal system operations.
	def AddTask(_task_)
		# Adds a task to the internal task list.
		@tasks + _task_
		
	# Appends a stream object to the list the system cleans up at Stop.
	#
	#   _stream_   the stream object to keep
	#   returns    nothing; the system changes
	#   see        CreateStream, AddTask
	def AddStream(_stream_)
		# Adds a stream to the internal stream list.
		@streams + _stream_
		
	# Registers a timer object with the timer manager, which keeps its own copy.
	#
	#   _timer_    the timer object to register
	#   returns    nothing; the manager changes
	#   see        CreateTimer, StopTimer
	def AddTimer(_timer_)
		# Adds a timer to the timer manager.
		@timerManager.AddTimer(_timer_)

	# Delivers the finished HTTP answers, then honours a stop asked for with StopSafe; the loop calls it once per pass.
	#
	#   returns    nothing
	#   warning    internal: Start hands the system itself to the loop as its drain, so that this runs
	#              on the live system and sees the request StopSafe noted
	#   see        StopSafe, PendingCount, Start
	def DrainPending()
		http.DrainPending()
		if @bStopNext
			@bStopNext = 0
			This.Stop()
		ok

	# Returns how many asynchronous HTTP requests have not been delivered yet; the loop asks it once per pass.
	#
	#   returns    a number; 0 when none is waiting
	#   warning    internal: the loop treats the system as its drain, see DrainPending
	#   see        DrainPending, HttpGet
	def PendingCount()
		return http.PendingCount()
