/*
	Softanza reactor -- gap-analysis Tier 2.

	An async I/O event loop backed by vendored libuv (epoll/kqueue/IOCP),
	running on its own engine thread. Ring stays synchronous: you submit
	work and await/poll results through a handle idiom -- no callbacks
	cross into Ring.

		oR = new stzReactor
		# fire-and-await a timer
		nId = oR.SubmitTimer(50)
		oR.AwaitTimer(nId, 2000)              # 0 = fired

		# async TCP request/response in one call
		cReq = "GET / HTTP/1.0" + nl + "Host: example.com" + nl +
		       "Connection: close" + nl + nl
		cBody = oR.TcpRequest("example.com", 80, cReq, 15000)
		? oR.TcpLastStatus()                  # 0 = ok

		oR.Destroy()

	The handle is created lazily on first use, so both `new stzReactor`
	and `new stzReactor()` work (paren-less `new` skips init in Ring).
*/

func StzReactor()
	return new stzReactor()

class stzReactor from stzObject

	pHandle = NULL
	bReady  = FALSE

	def init()
		This._Ensure()

	def _Ensure()
		if bReady = FALSE
			pHandle = StzEngineReactorCreate()
			bReady = TRUE
		ok

	def Handle()
		This._Ensure()
		return pHandle

	def Version()
		return StzEngineReactorVersion()

	# ── timers ───────────────────────────────────────────────

	def SubmitTimer(nDelayMs)
		This._Ensure()
		return StzEngineReactorSubmitTimer(pHandle, nDelayMs)

	# Block up to nTimeoutMs for the timer; returns 0 (fired), -1
	# (running/timeout) or -2 (unknown id).
	def AwaitTimer(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorAwait(pHandle, nId, nTimeoutMs)

	def Poll(nId)
		This._Ensure()
		return StzEngineReactorPoll(pHandle, nId)

	def Pending()
		This._Ensure()
		return StzEngineReactorPending(pHandle)

	# ── async TCP request/response ───────────────────────────

	def SubmitTcp(cHost, nPort, cPayload)
		This._Ensure()
		return StzEngineReactorSubmitTcp(pHandle, cHost, nPort, cPayload)

	# Block up to nTimeoutMs for the response body (empty on error/timeout).
	def AwaitTcp(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorTcpAwait(pHandle, nId, nTimeoutMs)

	def PollTcp(nId)
		This._Ensure()
		return StzEngineReactorTcpPoll(pHandle, nId)

	def TcpLastStatus()
		return StzEngineReactorTcpLastStatus()

	# Submit + await an async TCP request in one call; returns the body.
	def TcpRequest(cHost, nPort, cPayload, nTimeoutMs)
		This._Ensure()
		_nId_ = StzEngineReactorSubmitTcp(pHandle, cHost, nPort, cPayload)
		if _nId_ < 1 return "" ok
		return StzEngineReactorTcpAwait(pHandle, _nId_, nTimeoutMs)

	# ── teardown ─────────────────────────────────────────────

	def Destroy()
		if bReady = TRUE
			StzEngineReactorDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
		ok
		return This
