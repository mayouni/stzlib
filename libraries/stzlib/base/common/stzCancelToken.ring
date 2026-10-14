/*
	Softanza cancellation token -- gap-analysis Tier 1 item 4.

	Wraps an engine CancelToken handle (engine/src/cancel.zig, shipped
	in stz_pool.dll). A caller flips the token; a pool worker checks it
	before running a submitted job and surfaces a cancellation status
	(StzEnginePoolLastStatus() = -5) instead of executing.

	Usage:
		oTok = new stzCancelToken
		nId  = StzEnginePoolSubmitWithCancel(pPool, 0, cUrl, oTok.Handle())
		oTok.Cancel()                 # ask the worker to skip the job
		...
		oTok.Destroy()                # free the engine handle

	The handle is an opaque engine pointer; pass oTok.Handle() to the
	pool submit call. Construct paren-less (new stzCancelToken) inside
	Scenario blocks to avoid the C27 parse trap.
*/

func StzCancelToken()
	return new stzCancelToken()

# Holds a cancellation flag in the engine: one side raises it, the other side polls it and stops early.
#
# A token starts lowered. Cancel() (or Signal()) raises it and IsCancelled() reads it; the flag
# lives in the engine, so it can be passed to long-running engine work without a callback into Ring.
# Destroy() frees it.
#
#   receiver   o1 = new stzCancelToken()
#   example    ? o1.IsCancelled()
#              #--> 0
#              o1.Cancel()
#              ? o1.IsCancelled()
#              #--> 1
#   see        stzRetryBudget
class stzCancelToken from stzObject

	pHandle = ""
	# Plain boolean guard -- reliable, unlike comparing a cpointer to
	# NULL (Ring's typed null trips `= NULL` / isPointer). Paren-less
	# `new stzCancelToken` does NOT run init(), so every method lazily
	# ensures the handle exists before using it.
	bReady = 0

	# Builds a cancel token, an engine flag that one party raises and another polls to stop a long job early.
	#
	#   returns    nothing; the object is built
	def init()
		This._Ensure()

	def _Ensure()
		if bReady = 0
			pHandle = StzEngineCancelCreate()
			bReady = 1
		ok

	# Returns the engine pointer of the token, to hand to an engine call that accepts a cancel handle.
	#
	#   returns    a pointer
	#   see        Cancel
	#@ aka  The opaque engine handle, to hand to StzEnginePoolSubmitWithCancel.
	def Handle()
		This._Ensure()
		return pHandle

	# Raises the cancel flag, so every holder of the token sees IsCancelled() answer TRUE from now on.
	#
	#   returns    the token itself, so calls chain
	#   note       raising the flag twice changes nothing
	#   see        IsCancelled, Signal
	#@ aka  Ask any operation carrying this token to stop.
	def Cancel()
		This._Ensure()
		StzEngineCancelSignal(pHandle)
		return This

	# Raises the cancel flag, exactly as the call that has the other name does.
	#
	#   returns    the token itself, so calls chain
	#   see        Cancel, IsCancelled
	#@ aka  Alias for Cancel() -- matches the engine verb name.
	def Signal()
		This._Ensure()
		StzEngineCancelSignal(pHandle)
		return This

	# TRUE if the flag has been raised.
	#
	#   returns    TRUE or FALSE
	#   see        Cancel, Signal
	def IsCancelled()
		This._Ensure()
		return StzEngineCancelIsCancelled(pHandle) = 1

	# Frees the engine flag of the token and marks it unusable.
	#
	#   returns    the token itself, so calls chain
	#   note       a later call that needs the handle builds a new flag
	#   see        init
	#@ aka  Free the engine handle. The token must not be used afterwards.
	def Destroy()
		if bReady = 1
			StzEngineCancelDestroy(pHandle)
			pHandle = ""
			bReady = 0
		ok
		return This
