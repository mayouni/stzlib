/*
	Softanza cancellation token -- gap-analysis Tier 1 item 4.

	Wraps an engine CancelToken handle (engine/src/cancel.zig, shipped
	in stz_pool.dll). A caller flips the token; a pool worker checks it
	before running a submitted job and surfaces a cancellation status
	(StzEnginePoolLastStatus() = -5) instead of executing.

	Usage:
		_oTok_ = new stzCancelToken
		_nId_  = StzEnginePoolSubmitWithCancel(pPool, 0, cUrl, _oTok_.Handle())
		_oTok_.Cancel()                 # ask the worker to skip the job
		...
		_oTok_.Destroy()                # free the engine handle

	The handle is an opaque engine pointer; pass _oTok_.Handle() to the
	pool submit call. Construct paren-less (new stzCancelToken) inside
	Scenario blocks to avoid the C27 parse trap.
*/

func StzCancelToken()
	return new stzCancelToken()

class stzCancelToken from stzObject

	pHandle = NULL
	# Plain boolean guard -- reliable, unlike comparing a cpointer to
	# NULL (Ring's typed null trips `= NULL` / isPointer). Paren-less
	# `new stzCancelToken` does NOT run init(), so every method lazily
	# ensures the handle exists before using it.
	_bReady_ = FALSE

	def init()
		This._Ensure()

	def _Ensure()
		if _bReady_ = FALSE
			pHandle = StzEngineCancelCreate()
			_bReady_ = TRUE
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
		if _bReady_ = TRUE
			StzEngineCancelDestroy(pHandle)
			pHandle = NULL
			_bReady_ = FALSE
		ok
		return This
