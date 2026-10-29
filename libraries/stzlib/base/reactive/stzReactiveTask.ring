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
$TASK_PENDING = "pending"
$TASK_RUNNING = "running"
$TASK_COMPLETED = "completed"
$TASK_ERROR = "error"
TASK_CANCELLED = "cancelled"

# HTTP Tasks
$HTTP_TASK_GET = "http_get"
$HTTP_TASK_POST = "http_post"
$HTTP_TASK_PUT = "http_put"
$HTTP_TASK_DELETE = "http_delete"

# Holds one piece of asynchronous work, a function with a status, a result, an error and handlers, as the base of every reactive task.
#
# A task is pending until Execute runs its function once; it then records completed with the result,
# or error with the real reason, for example Error (R1) : Can't divide by zero. Then_ sets the
# handler for success and Catch_ the one for failure. The error mode decides what a failure does:
# ERROR_LOG prints it, ERROR_THROW raises it again, ERROR_CALLBACK calls the Catch_ function and
# ERROR_IGNORE stays silent, and the reason is on the task in every mode, readable with Error.
# Complete and Fail let a caller that did the work itself report through the same surface. The class
# is the base of stzHttpTask and stzFunctionTask and is not meant for the final programmer.
#
#   receiver   oEngine = new stzReactive() o1 = new stzReactiveTask("t1", func { return 6 * 7 },
#              oEngine, "") o2 = new stzReactiveTask("t2", func { return 1 / 0 }, oEngine,
#              ERROR_IGNORE)
#   example    ? o1.Status()
#              #--> pending
#              o1.Execute()
#              ? o1.Status()
#              #--> completed
#              ? o1.Result()
#              #--> 42
#              o2.Execute()
#              ? o2.HasFailed()
#              #--> 1
#              ? o2.Error()
#              #--> Error (R1) : Can't divide by zero
#              ? o2.WasReported()
#              #--> 0
#              o3 = new stzReactiveTask("t3", "", oEngine, "")
#              o3.Complete("from outside")
#              ? o3.Result()
#              #--> from outside
#   see        stzFunctionTask, stzHttpTask, stzReactiveFunc
class stzReactiveTask from stzObject

	# Task properties
	#----------------
	# Stores task metadata, function, status, and
	# callbacks for asynchronous execution.

	@taskId = ""
	@taskFunc = ""
	@onComplete = ""
	@onError = ""
	@status = $TASK_PENDING
	@result = ""
	@oEngine = ""
	@errorHandling = $DEFAULT_ERROR_HANDLING
	@errorMsg = ""
	@bReported = 0

	# Builds a task with an id, the function it will run and the reactive engine it belongs to, in the pending state.
	#
	#   id          the task's identifier
	#   f           the function to run, an anonymous func or a function name
	#   engine      the reactive engine, kept for subclasses
	#   errorMode   how a failure is reported: ERROR_LOG, ERROR_THROW, ERROR_CALLBACK or
	#               ERROR_IGNORE, or an empty text for the default ERROR_LOG
	#   returns     nothing; the task is built and not run
	#   note        the class is meant for subclasses such as stzHttpTask and stzFunctionTask and
	#               not for the final programmer
	#   see         Execute, Then_, Catch_
	def init(id, f, engine, errorMode)
		# Initializes a task with an ID, function, and engine reference.
		@taskId = id
		@taskFunc = f
		@oEngine = engine
		@status = $TASK_PENDING
		
		if errorMode != ""
			@errorHandling = errorMode
		ok
		
	# Sets the function called with the result when the task completes.
	#
	#   completeFunc   a function taking the result
	#   returns        the task itself, so calls chain
	#   note           an error in the callback itself is caught like any failure of the task
	#   see            Catch_, Execute
	def Then_(completeFunc)
		# Sets the callback for task completion.
		@onComplete = completeFunc
		return self
		
	# Sets the function called with the error message when the task fails.
	#
	#   errorFunc   a function taking the message text
	#   returns     the task itself, so calls chain
	#   note        it is called only in ERROR_CALLBACK mode
	#   see         Then_, Execute
	def Catch_(errorFunc)
		# Sets the callback for task errors.
		@onError = errorFunc
		return self
		
	# Runs the task's function once, records the outcome on the task and calls the handlers.
	#
	#   returns    nothing; read the outcome with Status, Result and Error
	#   note       on success the status is completed and the result is kept; on failure the status
	#              is error and the real reason, such as Error (R1) : Can't divide by zero, is kept;
	#              the log mode prints the reason, throw raises it again, callback calls the Catch_
	#              function, ignore stays silent
	#   see        Status, Result, Error
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
			@status = $TASK_RUNNING
			@result = call @taskFunc()
			@status = $TASK_COMPLETED
			if @onComplete != ""
				call @onComplete(@result)
			ok

		catch
			@status = $TASK_ERROR

			# The REAL reason, not a fixed sentence. CatchError() is Ring's, and
			# it answers "Error (R1) : Can't divide by zero" where this used to
			# say "Task execution failed" for every failure there is.
			@errorMsg = CatchError()
			if NOT (isString(@errorMsg) and @errorMsg != $EMPTY_ERROR_MSG)
				@errorMsg = $DEFAULT_TASK_ERROR_MSG
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

			if @errorHandling = $ERROR_THROW
				@bReported = 1
				raise(@errorMsg)

			but @errorHandling = $ERROR_CALLBACK and @onError != ""
				@bReported = 1
				call @onError(@errorMsg)

			but @errorHandling != $ERROR_IGNORE
				# ERROR_LOG is the documented default and prints by design.
				# The message is on the object either way -- see Error() -- so
				# stdout is no longer the only channel, and ERROR_IGNORE can
				# stay genuinely silent without losing the reason.
				@bReported = 1
				? @errorMsg
			ok
		done

	# Returns where the task is in its life.
	#
	#   returns    pending, running, completed or error, as text
	#   see        Succeeded, HasFailed
	#@ aka  -- WHAT HAPPENED, AFTER THE FACT ------------------------------------------
	def Status()
		return @status

	# Returns what the task's function returned.
	#
	#   returns    the result; an empty text before the task completes
	#   see        Status, Succeeded
	def Result()
		return @result

	# Returns the reason the task failed.
	#
	#   returns    the message as text; an empty text when it has not failed
	#   see        HasFailed, WasReported
	#@ aka  "" when the task has not failed.
	def Error()
		return @errorMsg

	# TRUE if the task ended in error.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Error, Succeeded
	def HasFailed()
		return @status = $TASK_ERROR

	# TRUE if the failure reached somebody: a raise, a handler or the console.
	#
	#   returns    1 or 0; only the ignore mode answers 0 for a failed task
	#   note       in ERROR_CALLBACK mode with no Catch_ function the failure is printed, so it is
	#              still reported; a task that has not failed answers 0
	#   see        HasFailed, Error
	#@ aka  Did the failure reach anyone -- a raise, a handler, or stdout? Only ERROR_IGNORE answers FALSE, and it is the one mode that asked to. Without this the fallback arm had no observable effect at all: removing it left every assertion green, because recording a reason is not reporting it.
	def WasReported()
		return @bReported

	# TRUE if the task completed.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Status, HasFailed
	def Succeeded()
		return @status = $TASK_COMPLETED

	# Records a successful outcome that was produced outside Execute.
	#
	#   pResult    the result to keep
	#   returns    the task itself, so calls chain
	#   note       it sets the status to completed and clears the error, so a caller that did the
	#              work itself reports through the same surface
	#   see        Fail, Result
	#@ aka  -- AN OUTCOME PRODUCED OUTSIDE Execute() -----------------------------------
	def Complete(pResult)
		@status = $TASK_COMPLETED
		@result = pResult
		@errorMsg = ""
		return This

	# Records a failed outcome that was produced outside Execute.
	#
	#   pcMsg      the reason, turned into text
	#   returns    the task itself, so calls chain
	#   note       it sets the status to error and marks the failure as reported
	#   see        Complete, Error
	def Fail(pcMsg)
		@status = $TASK_ERROR
		@errorMsg = "" + pcMsg
		@bReported = 1      # the caller is reporting it, right here
		return This

	# Releases task resources; the base task has none, subclasses may override it.
	#
	#   returns    nothing
	#   see        Execute
	def Cleanup()
		# Cleans up task resources (overridable in sub
