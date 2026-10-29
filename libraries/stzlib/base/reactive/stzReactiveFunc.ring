
#-----------------------------------------------------------#
#  REACTIVE FUNCTION WRAPPER - Makes any function reactive  #
#-----------------------------------------------------------#

# Wraps a function so that each call is a task recording its status, result and error, with optional handlers.
#
# Call_ calls the wrapped function now with a list of up to ten parameters and answers the executed
# task. CallAsync takes handlers for success and failure; despite its name it runs the task at once
# on the calling thread and the handlers run before it returns. A failure inside the function is
# recorded on the task with its real reason and passed to the error handler. The wrapper keeps its
# engine as a copy, so tasks added to the engine are not seen by the original. It is not Ring's call
# function.
#
#   receiver   oEngine = new stzReactive() o1 = new stzReactiveFunc(func a, b { return a + b },
#              oEngine)
#   example    oTask = o1.Call_([ 2, 3 ])
#              ? oTask.Result()
#              #--> 5
#              ? oTask.Status()
#              #--> completed
#              oBad = o1.Call_(7)
#              ? oBad.Status()
#              #--> error
#              ? oBad.Error()
#              #--> Reactive call params must be a list
#   see        stzFunctionTask, stzReactiveTask, stzReactive
class stzReactiveFunc from stzObject

	@originalFunc = ""
	# @-sigil'd: a BARE `engine` here is bound to a user global of the
	# same name at construction time, so the attribute is never created
	# and the next `this.engine` dies R12 "property not found". Proven:
	# a script holding `engine = "..."` could not even run
	# `new stzReactive()`.
	@oEngine = ""

	# Wraps a function so it can be called as a task that records its outcome.
	#
	#   f          the function to wrap
	#   engine     the reactive engine the tasks are registered with
	#   returns    nothing; the wrapper is built
	#   note       the engine is kept as a copy, so a task added to it is not seen by the original
	#              engine
	#   see        Call_, CallAsync
	def Init(f, engine)
		@originalFunc = f
		@oEngine = engine

	# Calls the wrapped function now with a list of parameters and returns the task holding the outcome.
	#
	#   params     the arguments, a list of up to 10 values
	#   returns    a stzFunctionTask already executed: read its Status, Result and Error
	#   note       the call is synchronous and is not run by the engine later: the task is executed
	#              here, which is what makes the result real; it is not Ring's call function
	#   warning    a params value that is not a list, or more than 10, leaves a task in error with
	#              the reason Reactive call params must be a list or Reactive call has too many
	#              params
	#   see        CallAsync, Init
	#@ aka  THE SYNCHRONOUS CALL. It has to actually call.
	def Call_(params) #TODO //#WARNING May confuse user with the normal Ring call() function
		_task_ = new stzFunctionTask($FUNC_CALL_SYNC, @originalFunc, params, @oEngine)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_
		
	# Calls the wrapped function with handlers for success and for failure, and returns the task.
	#
	#   params       the arguments, a list of up to 10 values
	#   onComplete   a function taking the result
	#   onError      a function taking the error text
	#   returns      a stzFunctionTask already executed
	#   note         despite the name it runs the task at once on the calling thread, as Call_ does;
	#                the handlers run before it returns
	#   warning      a failure inside the function is passed to onError with its real reason, such
	#                as Error (R1) : Can't divide by zero, and the task is left in error
	#   see          Call_, Init
	#TODO // CallAsyncChunked() when they know they have heavy
	#@ aka  CallAsync() for normal operations computations that should yield control to other operations
	def CallAsync(params, onComplete, onError)

		_task_ = new stzFunctionTask($FUNC_CALL_ASYNC, @originalFunc, params, @oEngine)
		_task_.Then_(onComplete)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

# Holds one call of a function with a list of up to ten parameters, recording its status, result and error.
#
# It is the task a stzReactiveFunc makes. Execute calls the function with the parameters and records
# completed with the result, or error with the real reason; it refuses a params value that is not a
# list and more than ten parameters with a message saying so. Then_ and Catch_ come from
# stzReactiveTask. The error mode is the default, which prints a failure to the console.
#
#   receiver   oEngine = new stzReactive() o1 = new stzFunctionTask("add", func a, b { return a + b
#              }, [ 2, 3 ], oEngine)
#   example    ? o1.Status()
#              #--> pending
#              o1.Execute()
#              ? o1.Status()
#              #--> completed
#              ? o1.Result()
#              #--> 5
#              ? o1.Succeeded()
#              #--> 1
#   see        stzReactiveFunc, stzReactiveTask
class stzFunctionTask from stzReactiveTask

	@f = ""
	@params = []
	
	# Builds a task that will call a function with a list of parameters, in the pending state.
	#
	#   id         the task's identifier
	#   f          the function to call
	#   params     the arguments, a list of up to 10 values
	#   engine     the reactive engine it belongs to
	#   returns    nothing; the task is built and not run
	#   note       the error mode is the default, ERROR_LOG
	#   see        Execute, stzReactiveFunc
	def Init(id, f, params, engine)
		super.Init(id, "", engine, $DEFAULT_ERROR_HANDLING)
		this.@f = f
		@params = params
		
	# Calls the function with the parameters and records the outcome on the task.
	#
	#   returns    nothing; read the outcome with Status, Result and Error
	#   note       on success the status is completed, the result is kept and Then_ is called; on
	#              failure the status is error, the reason is on the task, and the console prints it
	#              in the default mode
	#   warning    a params value that is not a list records the error Reactive call params must be
	#              a list; more than 10 records Reactive call has too many params: N (the limit is
	#              10); a failure inside the function records its real reason
	#   see        Init
	def Execute()
		# THE STATUS AND THE REASON LIVE ON THE TASK, not in locals. Writing
		# _status_ here dropped it the moment Execute() returned, so every
		# accessor inherited from stzReactiveTask -- Status(), Result(),
		# Error(), HasFailed() -- answered as though the task had never run.
		# stzHttpTask had exactly this fix applied in July ("store the status on
		# the TASK, not in a local"); its sibling here was missed.
		try
			@status = $TASK_RUNNING

			# THE SHAPE IS CHECKED BEFORE THE SWITCH, so a refusal says what
			# was wrong. Anything but a list used to reach len() and surface
			# as "Bad parameter type!", and more than MAX_FUNCTION_PARAMS fell
			# to an `other` arm that called the function with NO arguments --
			# reported as "Calling function with LESS number of parameters",
			# the opposite of what had happened.
			if NOT isList(@params)
				raise($FUNC_ERROR_PARAMS_NOT_LIST)
			ok
			if len(@params) > $MAX_FUNCTION_PARAMS
				raise($FUNC_ERROR_TOO_MANY_PARAMS + " " + len(@params) +
				      " (the limit is " + $MAX_FUNCTION_PARAMS + ")")
			ok

			if len(@params) = $NO_PARAMS
				_result_ = call @f()
			else
				# Handle parameters - Ring requires individual params
				switch len(@params)
				case 1
					_result_ = call @f(@params[1])
				case 2
					_result_ = call @f(@params[1], @params[2])
				case 3
					_result_ = call @f(@params[1], @params[2], @params[3])
				case 4
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4])
				case 5
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5])
				case 6
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5], @params[6])
				case 7
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5], @params[6], @params[7])
				case 8
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5], @params[6], @params[7], @params[8])
				case 9
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5], @params[6], @params[7], @params[8], @params[9])
				case 10
					_result_ = call @f(@params[1], @params[2], @params[3], @params[4], @params[5], @params[6], @params[7], @params[8], @params[9], @params[10])
				other
					# Unreachable: the count is refused above. Kept as a
					# guard, and it refuses rather than silently calling
					# with no arguments.
					raise($FUNC_ERROR_TOO_MANY_PARAMS + " " + len(@params))
				end
			ok
			@result = _result_
			@status = $TASK_COMPLETED
			if @onComplete != ""
				call @onComplete(@result)
			ok

		catch
			@status = $TASK_ERROR

			# The real reason, recorded whether or not anyone is listening. It
			# used to be read only INSIDE the "is a handler registered" branch,
			# so a task with no Catch_() kept nothing at all -- and there was no
			# accessor to have asked with.
			@errorMsg = CatchError()
			if NOT (isString(@errorMsg) and @errorMsg != $EMPTY_ERROR_MSG)
				@errorMsg = $DEFAULT_ERROR_MSG
			ok

			if @onError != ""
				call @onError(@errorMsg)
			ok
		done
