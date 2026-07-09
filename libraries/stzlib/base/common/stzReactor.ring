/*
	Softanza reactor -- gap-analysis Tier 2.

	An async I/O event loop backed by vendored libuv (epoll/kqueue/IOCP),
	running on its own engine thread. Ring stays synchronous: you submit
	work and await/poll results through a handle idiom -- no callbacks
	cross into Ring.

		oR = new stzReactor
		# fire-and-await a timer
		_nId_ = oR.SubmitTimer(50)
		oR.AwaitTimer(_nId_, 2000)              # 0 = fired

		# async TCP request/response in one call
		_cReq_ = "GET / HTTP/1.0" + nl + "Host: example.com" + nl +
		       "Connection: close" + nl + nl
		_cBody_ = oR.TcpRequest("example.com", 80, _cReq_, 15000)
		? oR.TcpLastStatus()                  # 0 = ok

		oR.Destroy()

	The handle is created lazily on first use, so both `new stzReactor`
	and `new stzReactor()` work (paren-less `new` skips init in Ring).
*/

func StzReactor()
	return new stzReactor()

class stzReactor from stzObject

	pHandle = NULL
	_bReady_  = FALSE

	def init()
		This._Ensure()

	def _Ensure()
		if _bReady_ = FALSE
			pHandle = StzEngineReactorCreate()
			_bReady_ = TRUE
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
	def AwaitTimer(_nId_, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorAwait(pHandle, _nId_, nTimeoutMs)

	def Poll(_nId_)
		This._Ensure()
		return StzEngineReactorPoll(pHandle, _nId_)

	def Pending()
		This._Ensure()
		return StzEngineReactorPending(pHandle)

	# ── async TCP request/response ───────────────────────────

	def SubmitTcp(cHost, nPort, cPayload)
		This._Ensure()
		return StzEngineReactorSubmitTcp(pHandle, cHost, nPort, cPayload)

	# Block up to nTimeoutMs for the response body (empty on error/timeout).
	def AwaitTcp(_nId_, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorTcpAwait(pHandle, _nId_, nTimeoutMs)

	def PollTcp(_nId_)
		This._Ensure()
		return StzEngineReactorTcpPoll(pHandle, _nId_)

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
		if _bReady_ = TRUE
			StzEngineReactorDestroy(pHandle)
			pHandle = NULL
			_bReady_ = FALSE
		ok
		return This
