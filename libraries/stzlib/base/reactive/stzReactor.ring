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

		# serve: HTTP/1.1 listener + event drain (R7 service host spine)
		nSid = oR.ListenHttp("127.0.0.1", 8080)
		aEv = oR.ServerAwait(nSid, 100)       # [:accept|:data|:closed, nConn, cBytes]
		if len(aEv) > 0 and aEv[1] = :data
			oR.ServerWrite(nSid, aEv[2], cHttpResponse, TRUE)
		ok
		oR.ServerStop(nSid)

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
		nId = StzEngineReactorSubmitTcp(pHandle, cHost, nPort, cPayload)
		if nId < 1 return "" ok
		return StzEngineReactorTcpAwait(pHandle, nId, nTimeoutMs)

	# ── server side: listen / events / write / close ─────────
	#
	# A listener lives on the loop thread; Ring drains EVENTS:
	#   [ :accept, nConn, "" ] / [ :data, nConn, cBytes ] /
	#   [ :closed, nConn, "" ] / [] when there is none.
	# In http mode each :data event is ONE complete framed HTTP/1.1
	# request (headers + Content-Length body, pipelining-safe).

	# Raw TCP stream listener (IoT/telemetry). nPort 0 = ephemeral.
	# Returns the server id (>0) or a negative uv error code.
	def Listen(cHost, nPort)
		This._Ensure()
		return StzEngineReactorListen(pHandle, cHost, nPort, 0)

	# HTTP/1.1 listener: :data events carry complete requests.
	def ListenHttp(cHost, nPort)
		This._Ensure()
		return StzEngineReactorListen(pHandle, cHost, nPort, 1)

	# Actual bound port (useful after nPort = 0).
	def ServerPort(nServerId)
		This._Ensure()
		return StzEngineReactorServerPort(pHandle, nServerId)

	def ServerConns(nServerId)
		This._Ensure()
		return StzEngineReactorServerConns(pHandle, nServerId)

	# Drain one event without blocking; [] if none.
	def ServerPoll(nServerId)
		This._Ensure()
		nKind = StzEngineReactorServerPoll(pHandle, nServerId)
		return This._ServerEvent(nKind)

	# Block up to nTimeoutMs for one event; [] on timeout.
	def ServerAwait(nServerId, nTimeoutMs)
		This._Ensure()
		nKind = StzEngineReactorServerAwait(pHandle, nServerId, nTimeoutMs)
		return This._ServerEvent(nKind)

	def _ServerEvent(nKind)
		if nKind = 1
			return [ :accept, StzEngineReactorServerLastConn(), "" ]
		but nKind = 2
			return [ :data, StzEngineReactorServerLastConn(), StzEngineReactorServerLastData() ]
		but nKind = 3
			return [ :closed, StzEngineReactorServerLastConn(), "" ]
		ok
		return []

	# Write to a connection; bCloseAfter closes it once the write lands.
	def ServerWrite(nServerId, nConnId, cData, bCloseAfter)
		This._Ensure()
		nClose = 0
		if bCloseAfter = TRUE
			nClose = 1
		ok
		return StzEngineReactorServerWrite(pHandle, nServerId, nConnId, cData, nClose)

	def ServerCloseConn(nServerId, nConnId)
		This._Ensure()
		return StzEngineReactorServerCloseConn(pHandle, nServerId, nConnId)

	def ServerStop(nServerId)
		This._Ensure()
		return StzEngineReactorServerStop(pHandle, nServerId)

	# ── teardown ─────────────────────────────────────────────

	def Destroy()
		if bReady = TRUE
			StzEngineReactorDestroy(pHandle)
			pHandle = NULL
			bReady = FALSE
		ok
		return This
