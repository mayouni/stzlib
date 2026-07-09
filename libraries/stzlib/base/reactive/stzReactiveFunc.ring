
#-----------------------------------------------------------#
#  REACTIVE FUNCTION WRAPPER - Makes any function reactive  #
#-----------------------------------------------------------#

class stzReactiveFunc from stzObject

	originalFunc = NULL
	engine = NULL
	
	def Init(f, engine)
		originalFunc = f
		this.engine = engine
		
	def Call_(params) #TODO //#WARNING May confuse user with the normal Ring call() function
		_task_ = new stzFunctionTask(FUNC_CALL_SYNC, originalFunc, params, engine)
		engine.AddTask(_task_)
		return _task_
		
	# CallAsync() for normal operations
	#TODO // CallAsyncChunked() when they know they have heavy
	# computations that should yield control to other operations

	def CallAsync(params, onComplete, onError)

		_task_ = new stzFunctionTask(FUNC_CALL_ASYNC, originalFunc, params, engine)
		_task_.Then_(onComplete)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

class stzFunctionTask from stzReactiveTask

	@f = NULL
	params = []
	
	def Init(id, f, params, engine)
		super.Init(id, NULL, engine, DEFAULT_ERROR_HANDLING)
		this.@f = f
		this.params = params
		
	def Execute()
		try
			_status_ = TASK_RUNNING
			if len(params) = NO_PARAMS
				_result_ = call @f()
			else
				# Handle parameters - Ring requires individual params
				switch len(params)
				case 1
					_result_ = call @f(params[1])
				case 2
					_result_ = call @f(params[1], params[2])
				case 3
					_result_ = call @f(params[1], params[2], params[3])
				case 4
					_result_ = call @f(params[1], params[2], params[3], params[4])
				case 5
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5])
				case 6
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5], params[6])
				case 7
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7])
				case 8
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
				case 9
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
				case 10
					_result_ = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], params[10])
				other
					_result_ = call @f() # Fallback for more than MAX_FUNCTION_PARAMS
				end
			ok
			_status_ = TASK_COMPLETED
			if onComplete != NULL
				call onComplete(_result_)
			ok

		catch
			_status_ = TASK_ERROR
			if onError != NULL
				# Pass the actual error message instead of generic text
				_errorMsg_ = CatchError()
				if isString(_errorMsg_) and _errorMsg_ != EMPTY_ERROR_MSG
					call onError(_errorMsg_)
				else
					call onError(DEFAULT_ERROR_MSG)
				ok
			ok
		done
