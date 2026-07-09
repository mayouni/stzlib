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
_TASK_PENDING_ = "pending"
_TASK_RUNNING_ = "running"
_TASK_COMPLETED_ = "completed"
_TASK_ERROR_ = "error"
_TASK_CANCELLED_ = "cancelled"

# HTTP Tasks
_HTTP_TASK_GET_ = "http_get"
_HTTP_TASK_POST_ = "http_post"
_HTTP_TASK_PUT_ = "http_put"
_HTTP_TASK_DELETE_ = "http_delete"

class stzReactiveTask from stzObject

	# Task properties
	#----------------
	# Stores task metadata, function, status, and
	# callbacks for asynchronous execution.

	_taskId_ = ""
	_taskFunc_ = NULL
	onComplete = NULL
	onError = NULL
	_status_ = _TASK_PENDING_
	_result_ = NULL
	_engine_ = NULL
	_errorHandling_ = DEFAULT_ERROR_HANDLING

	def init(id, f, _engine_, errorMode)
		# Initializes a task with an ID, function, and engine reference.
		_taskId_ = id
		_taskFunc_ = f
		this.engine = _engine_
		_status_ = _TASK_PENDING_
		
		if errorMode != NULL
			_errorHandling_ = errorMode
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
			_status_ = _TASK_RUNNING_
			if isString(_taskFunc_)
				_result_ = call _taskFunc_()
			else
				_result_ = _taskFunc_()
			ok
			_status_ = _TASK_COMPLETED_
			if onComplete != NULL
				onComplete(_result_)
			ok

		catch
			_status_ = _TASK_ERROR_
			_errorMsg_ = "Task execution failed"
			
			if _errorHandling_ = ERROR_THROW
				raise(_errorMsg_)
			but _errorHandling_ = ERROR_LOG
				? _errorMsg_
			but _errorHandling_ = ERROR_CALLBACK and onError != NULL
				onError(_errorMsg_)
			ok
		done
		
	def Cleanup()
		# Cleans up task resources (overridable in sub
