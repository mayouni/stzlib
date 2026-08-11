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

class stzReactiveTask from stzObject

	# Task properties
	#----------------
	# Stores task metadata, function, status, and
	# callbacks for asynchronous execution.

	@taskId = ""
	@taskFunc = ""
	@onComplete = ""
	@onError = ""
	@status = TASK_PENDING
	@result = ""
	@oEngine = ""
	@errorHandling = DEFAULT_ERROR_HANDLING
	@errorMsg = ""
	@bReported = 0

	def init(id, f, engine, errorMode)
		# Initializes a task with an ID, function, and engine reference.
		@taskId = id
		@taskFunc = f
		@oEngine = engine
		@status = TASK_PENDING
		
		if errorMode != ""
			@errorHandling = errorMode
		ok
		
	def Then_(completeFunc)
		# Sets the callback for task completion.
		@onComplete = completeFunc
		return self
		
	def Catch_(errorFunc)
		# Sets the callback for task errors.
		@onError = errorFunc
		return self
		
	def Execute()
		# Executes the task, handling success and error cases.
		#
		# THE call KEYWORD IS NOT OPTIONAL. Ring invokes a function held in a
		# variable only through `call`; without it the name is looked up as a
		# global function and raises R3. Both callback invocations below were
		# missing it.
		#
		# The failure that produced is worth stating exactly, because it is not
		# the obvious one. A Ring lambda IS a string -- `func { }` evaluates to
		# "_ring_anonymous_func_NNN" -- so the body dispatch took the isString
		# arm, which was already right, and the task DID run. It computed its
		# answer, set TASK_COMPLETED, and then raised R3 trying to hand the
		# result to Then_(). The catch below turned that into TASK_ERROR and
		# printed a fixed sentence. A task that had succeeded reported failure,
		# threw its result away, and said nothing about why.
		#
		# The dispatch that used to stand here asked whether the function was a
		# string and called it differently either way. Both arms need `call`, so
		# once the second was corrected the two were identical and the question
		# had no purpose.
		try
			@status = TASK_RUNNING
			@result = call @taskFunc()
			@status = TASK_COMPLETED
			if @onComplete != ""
				call @onComplete(@result)
			ok

		catch
			@status = TASK_ERROR

			# The REAL reason, not a fixed sentence. CatchError() is Ring's, and
			# it answers "Error (R1) : Can't divide by zero" where this used to
			# say "Task execution failed" for every failure there is.
			@errorMsg = CatchError()
			if NOT (isString(@errorMsg) and @errorMsg != EMPTY_ERROR_MSG)
				@errorMsg = DEFAULT_TASK_ERROR_MSG
			ok

			# ...and every mode reports. The old chain ended at `ok`, so a task
			# set to ERROR_CALLBACK with no Catch_() -- and any mode this chain
			# did not name -- dropped the failure without a word.
			#
			# The last arm is written as "not the mode that wants silence"
			# rather than "is the mode that logs", so that a mode nobody
			# foresaw lands on REPORT and not on swallow. That polarity is the
			# whole point: a fallback should fail loud.
			@bReported = 0

			if @errorHandling = ERROR_THROW
				@bReported = 1
				raise(@errorMsg)

			but @errorHandling = ERROR_CALLBACK and @onError != ""
				@bReported = 1
				call @onError(@errorMsg)

			but @errorHandling != ERROR_IGNORE
				# ERROR_LOG is the documented default and prints by design.
				# The message is on the object either way -- see Error() -- so
				# stdout is no longer the only channel, and ERROR_IGNORE can
				# stay genuinely silent without losing the reason.
				@bReported = 1
				? @errorMsg
			ok
		done

	#-- WHAT HAPPENED, AFTER THE FACT ------------------------------------------
	#
	# The class recorded a status, a result and (now) an error, and offered no
	# way to read any of them. A caller whose task failed could not ask what
	# went wrong; a caller whose task succeeded could not collect the answer
	# unless they had registered a handler first.

	def Status()
		return @status

	def Result()
		return @result

	# "" when the task has not failed.
	def Error()
		return @errorMsg

	def HasFailed()
		return @status = TASK_ERROR

	# Did the failure reach anyone -- a raise, a handler, or stdout? Only
	# ERROR_IGNORE answers FALSE, and it is the one mode that asked to. Without
	# this the fallback arm had no observable effect at all: removing it left
	# every assertion green, because recording a reason is not reporting it.
	def WasReported()
		return @bReported

	def Succeeded()
		return @status = TASK_COMPLETED

	#-- AN OUTCOME PRODUCED OUTSIDE Execute() -----------------------------------
	#
	# Not every task computes. stzReactiveObject.SetAsync already HAS the value
	# it is going to store, and its attempt to wrap one in a task function --
	# `func { return _newValue_ }` -- raised R24, because a Ring lambda cannot
	# read a caller's local. These two let a caller that did the work itself
	# still report it through the same task surface, so Status()/Result()/
	# Error() mean the same thing however the work happened.

	def Complete(pResult)
		@status = TASK_COMPLETED
		@result = pResult
		@errorMsg = ""
		return This

	def Fail(pcMsg)
		@status = TASK_ERROR
		@errorMsg = "" + pcMsg
		@bReported = 1      # the caller is reporting it, right here
		return This

	def Cleanup()
		# Cleans up task resources (overridable in sub
