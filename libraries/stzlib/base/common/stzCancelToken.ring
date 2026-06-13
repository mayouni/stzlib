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

class stzCancelToken

	pHandle = NULL
	# Plain boolean guard -- reliable, unlike comparing a cpointer to
	# NULL (Ring's typed null trips `= NULL` / isPointer). Paren-less
	# `new stzCancelToken` does NOT run init(), so every method lazily
	# ensures the handle exists before using it.
	bReady = FALSE

	def init()
		This._Ensure()

	def _Ensure()
		if bReady = FALSE
			pHandle = StzEngineCancelCreate()
			bReady = TRUE
		ok

	# The opaque engine handle, to hand to StzEnginePoolSubmitWithCancel.
	def Handle()
		This._Ensure()
		return pHandle

	# Ask any operation carrying this token to stop.
	def Cancel()
		This._Ensure()
		StzEngineCancelSignal(pHandle)
		return This

	# Alias for Cancel() -- matches the engine verb name.
	def Signal()
		This._Ensure()
		StzEngineCancelSignal(pHandle)
		return This

	def IsCancelled()
		This._Ensure()
		return StzEngineCancelIsCancelled(pHandle) = 1

	# Free the engine handle. The token must not be used afterwards.
	def Destroy()
		if bReady = TRUE
			StzEngineCancelDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
		ok
		return This
