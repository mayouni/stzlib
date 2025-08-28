#=================#
#  REACTIVE TASK  #
#=================#

# Core Abstraction for Async Operations

# Manages asynchronous tasks lifecycle with execution,
# completion, and error handling capabilities.

# Base Class for Everything Async: stzReactiveTask sets up
# the task lifecycle (e.g., TASK_PENDING, TASK_RUNNING,
# TASK_COMPLETED), error handling (ERROR_LOG, ERROR_THROW),
# and callback chaining (Then_(), Catch_()).


# Subclasses like stzHttpTask (for HTTP requests) and
# stzFunctionTask (for wrapped functions) inherit these
# superpowers to do their specific jobs.

# Used by those subclasses and not intended, by design, to
# be used aon by the final programmer

#-----------------#
#  TASK CONSTANTS #
#-----------------#

# Task Status
TASK_PENDING = "pending"
TASK_RUNNING = "running"
TASK_COMPLETED = "completed"
TASK_ERROR = "error"
TASK_CANCELLED = "cancelled"

# HTTP Tasks
HTTP_TASK_GET = "http_get"
HTTP_TASK_POST = "http_post"
HTTP_TASK_PUT = "http_put"
HTTP_TASK_DELETE = "http_delete"

class stzReactiveTask

	# Task properties
	#----------------
	# Stores task metadata, function, status, and
	# callbacks for asynchronous execution.

	taskId = ""
	taskFunc = NULL
	onComplete = NULL
	onError = NULL
	status = TASK_PENDING
	result = NULL
	engine = NULL
	errorHandling = DEFAULT_ERROR_HANDLING

	def init(id, f, engine, errorMode)
		# Initializes a task with an ID, function, and engine reference.
		taskId = id
		taskFunc = f
		this.engine = engine
		status = TASK_PENDING
		
		if errorMode != NULL
			errorHandling = errorMode
		ok
		
	def Then_(completeFunc)
		# Sets the callback for task completion.
		onComplete = completeFunc
		return self
		
	def Catch_(errorFunc)
		# Sets the callback for task errors.
		onError = errorFunc
		return self
		
	def Execute()
		# Executes the task, handling success and error cases.
		try
			status = TASK_RUNNING
			if isString(taskFunc)
				result = call taskFunc()
			else
				result = taskFunc()
			ok
			status = TASK_COMPLETED
			if onComplete != NULL
				onComplete(result)
			ok

		catch
			status = TASK_ERROR
			errorMsg = "Task execution failed"
			
			if errorHandling = ERROR_THROW
				raise(errorMsg)
			but errorHandling = ERROR_LOG
				? errorMsg
			but errorHandling = ERROR_CALLBACK and onError != NULL
				onError(errorMsg)
			ok
		done
		
	def Cleanup()
		# Cleans up task resources (overridable in sub
