
#-----------------------------------------------------------#
#  REACTIVE FUNCTION WRAPPER - Makes any function reactive  #
#-----------------------------------------------------------#

class stzReactiveFunc

	originalFunc = NULL
	engine = NULL
	
	def Init(f, engine)
		originalFunc = f
		this.engine = engine
		
	def Call_(params) #TODO //#WARNING May confuse user with the normal Ring call() function
		task = new stzFunctionTask(FUNC_CALL_SYNC, originalFunc, params, engine)
		engine.AddTask(task)
		return task
		
	# CallAsync() for normal operations
	#TODO // CallAsyncChunked() when they know they have heavy
	# computations that should yield control to other operations

	def CallAsync(params, onComplete, onError)

		task = new stzFunctionTask(FUNC_CALL_ASYNC, originalFunc, params, engine)
		task.Then_(onComplete)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

class stzFunctionTask from stzReactiveTask

	@f = NULL
	params = []
	
	def Init(id, f, params, engine)
		super.Init(id, NULL, engine, DEFAULT_ERROR_HANDLING)
		this.@f = f
		this.params = params
		
	def Execute()
		try
			status = TASK_RUNNING
			if len(params) = NO_PARAMS
				result = call @f()
			else
				# Handle parameters - Ring requires individual params
				switch len(params)
				case 1
					result = call @f(params[1])
				case 2
					result = call @f(params[1], params[2])
				case 3
					result = call @f(params[1], params[2], params[3])
				case 4
					result = call @f(params[1], params[2], params[3], params[4])
				case 5
					result = call @f(params[1], params[2], params[3], params[4], params[5])
				case 6
					result = call @f(params[1], params[2], params[3], params[4], params[5], params[6])
				case 7
					result = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7])
				case 8
					result = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8])
				case 9
					result = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9])
				case 10
					result = call @f(params[1], params[2], params[3], params[4], params[5], params[6], params[7], params[8], params[9], params[10])
				other
					result = call @f() # Fallback for more than MAX_FUNCTION_PARAMS
				end
			ok
			status = TASK_COMPLETED
			if onComplete != NULL
				call onComplete(result)
			ok

		catch
			status = TASK_ERROR
			if onError != NULL
				# Pass the actual error message instead of generic text
				errorMsg = CatchError()
				if isString(errorMsg) and errorMsg != EMPTY_ERROR_MSG
					call onError(errorMsg)
				else
					call onError(DEFAULT_ERROR_MSG)
				ok
			ok
		done
