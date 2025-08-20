#-----------------------------------------------------------#
#  REACTIVE FUNCTION WRAPPER - Makes any function reactive  #
#-----------------------------------------------------------#

class stzReactiveFuncWrapper

	originalFunc = NULL
	engine = NULL
	
	def Init(f, engine)
		originalFunc = f
		this.engine = engine
		
	def Call_(params)
		task = new stzFunctionTask("func_call", originalFunc, params, engine)
		engine.AddTask(task)
		return task
		
	# CallAsync() for normal operations
	# CallAsyncChunked() when they know they have heavy
	# computations that should yield control to other operations

	def CallAsync(params, onComplete, onError)
		task = new stzFunctionTask("func_call_async", originalFunc, params, engine)
		task.Then_(onComplete)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

class stzFunctionTask from stzReactiveTask

	@f = NULL
	params = []
	
	def Init(id, f, params, engine)
		super.Init(id, NULL, engine)
		this.@f = f
		this.params = params
		
	def Execute()
		try
			status = "running"
			if len(params) = 0
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
				# Add more cases as needed
				other
					result = call @f() # Fallback
				end
			ok
			status = "completed"
			if onComplete != NULL
				call onComplete(result)
			ok

		catch
			status = "error"
			if onError != NULL
				# Pass the actual error message instead of generic text
				errorMsg = CatchError()
				if isString(errorMsg) and errorMsg != ""
					call onError(errorMsg)
				else
					call onError("Function execution failed")
				ok
			ok
		done
