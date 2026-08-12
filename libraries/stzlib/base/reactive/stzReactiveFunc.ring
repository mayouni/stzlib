
#-----------------------------------------------------------#
#  REACTIVE FUNCTION WRAPPER - Makes any function reactive  #
#-----------------------------------------------------------#

class stzReactiveFunc from stzObject

	@originalFunc = ""
	# @-sigil'd: a BARE `engine` here is bound to a user global of the
	# same name at construction time, so the attribute is never created
	# and the next `this.engine` dies R12 "property not found". Proven:
	# a script holding `engine = "..."` could not even run
	# `new stzReactive()`.
	@oEngine = ""

	def Init(f, engine)
		@originalFunc = f
		@oEngine = engine

	# THE SYNCHRONOUS CALL. It has to actually call.
	#
	# This built the task, handed it to AddTask, and returned it unexecuted. Its
	# async sibling below calls Execute() on the local task; this one relied on
	# the engine running it later, and the engine never saw it: @oEngine is an
	# attribute, so AddTask appends to a COPY of the reactive system. Measured --
	# the real engine's task list stayed at zero, and after Start() the wrapped
	# function had run zero times. Call_ did nothing whatsoever.
	#
	# AddTask is kept because CallAsync does the same and both are equally
	# copy-bound; that is the engine-identity problem, not this method's, and
	# papering over it here would hide it. Execute() on the LOCAL task is what
	# makes the result real, which is exactly how CallAsync has always worked.
	def Call_(params) #TODO //#WARNING May confuse user with the normal Ring call() function
		_task_ = new stzFunctionTask(FUNC_CALL_SYNC, @originalFunc, params, @oEngine)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_
		
	# CallAsync() for normal operations
	#TODO // CallAsyncChunked() when they know they have heavy
	# computations that should yield control to other operations

	def CallAsync(params, onComplete, onError)

		_task_ = new stzFunctionTask(FUNC_CALL_ASYNC, @originalFunc, params, @oEngine)
		_task_.Then_(onComplete)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

class stzFunctionTask from stzReactiveTask

	@f = ""
	@params = []
	
	def Init(id, f, params, engine)
		super.Init(id, "", engine, DEFAULT_ERROR_HANDLING)
		this.@f = f
		@params = params
		
	def Execute()
		# THE STATUS AND THE REASON LIVE ON THE TASK, not in locals. Writing
		# _status_ here dropped it the moment Execute() returned, so every
		# accessor inherited from stzReactiveTask -- Status(), Result(),
		# Error(), HasFailed() -- answered as though the task had never run.
		# stzHttpTask had exactly this fix applied in July ("store the status on
		# the TASK, not in a local"); its sibling here was missed.
		try
			@status = TASK_RUNNING

			# THE SHAPE IS CHECKED BEFORE THE SWITCH, so a refusal says what
			# was wrong. Anything but a list used to reach len() and surface
			# as "Bad parameter type!", and more than MAX_FUNCTION_PARAMS fell
			# to an `other` arm that called the function with NO arguments --
			# reported as "Calling function with LESS number of parameters",
			# the opposite of what had happened.
			if NOT isList(@params)
				raise(FUNC_ERROR_PARAMS_NOT_LIST)
			ok
			if len(@params) > MAX_FUNCTION_PARAMS
				raise(FUNC_ERROR_TOO_MANY_PARAMS + " " + len(@params) +
				      " (the limit is " + MAX_FUNCTION_PARAMS + ")")
			ok

			if len(@params) = NO_PARAMS
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
					raise(FUNC_ERROR_TOO_MANY_PARAMS + " " + len(@params))
				end
			ok
			@result = _result_
			@status = TASK_COMPLETED
			if @onComplete != ""
				call @onComplete(@result)
			ok

		catch
			@status = TASK_ERROR

			# The real reason, recorded whether or not anyone is listening. It
			# used to be read only INSIDE the "is a handler registered" branch,
			# so a task with no Catch_() kept nothing at all -- and there was no
			# accessor to have asked with.
			@errorMsg = CatchError()
			if NOT (isString(@errorMsg) and @errorMsg != EMPTY_ERROR_MSG)
				@errorMsg = DEFAULT_ERROR_MSG
			ok

			if @onError != ""
				call @onError(@errorMsg)
			ok
		done
