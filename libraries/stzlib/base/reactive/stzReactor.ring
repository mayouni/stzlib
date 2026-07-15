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

	# Non-draining peek: -2 unknown, -1 running, 0 ready-to-fetch.
	def JobState(nId)
		This._Ensure()
		return StzEngineReactorJobState(pHandle, nId)

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

	# ── async process spawn (polyglot fleet) ─────────────────
	#
	# Run a subprocess on the loop, capture its stdout, report the exit
	# code -- non-Ring workers run OFF-THREAD, drained via the job
	# idiom. The command is the program followed by its arguments.

	# Submit; acArgv = [ program, arg1, arg2, ... ]. Returns a job id.
	def SubmitSpawn(acArgv)
		This._Ensure()
		if isString(acArgv)
			acArgv = [ acArgv ]
		ok
		cJoined = ""
		nLen = len(acArgv)
		for i = 1 to nLen
			if i > 1  cJoined += char(10)  ok
			cJoined += "" + acArgv[i]
		next
		return StzEngineReactorSubmitSpawn(pHandle, cJoined)

	# Block up to nTimeoutMs for the child; returns its stdout.
	def AwaitSpawn(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorSpawnAwait(pHandle, nId, nTimeoutMs)

	def PollSpawn(nId)
		This._Ensure()
		return StzEngineReactorSpawnPoll(pHandle, nId)

	def SpawnLastStatus()
		return StzEngineReactorSpawnLastStatus()

	# Force-kill a spawned child by job id: send nSignum (default SIGKILL=9;
	# SIGTERM=15). On Windows libuv maps these to TerminateProcess. Returns
	# 0 on success, negative on error (-2 not found, -3 already exited, -4
	# not a spawn / no handle). The kill is mutex-guarded in the engine so it
	# can't race the loop thread reaping the process on its own exit.
	def KillSpawn(nId, nSignum)
		This._Ensure()
		return StzEngineReactorSpawnKill(pHandle, nId, nSignum)

	# SIGKILL by default (the forceful stop for a wedged child).
	def KillSpawnHard(nId)
		This._Ensure()
		return StzEngineReactorSpawnKill(pHandle, nId, 9)

	# Submit + await in one call; returns the child's stdout.
	def Spawn(acArgv, nTimeoutMs)
		This._Ensure()
		nId = This.SubmitSpawn(acArgv)
		if nId < 1  return ""  ok
		return StzEngineReactorSpawnAwait(pHandle, nId, nTimeoutMs)

	# ── async HTTP / HTTPS (native TLS, off the loop thread) ──
	#
	# A full HTTP(S) request runs on a libuv WORKER thread via curl
	# (native Schannel TLS on Windows) and is drained through the job
	# idiom -- so https:// is genuinely async, no TLS state machine on
	# the loop. Methods: 0=GET 1=POST 2=PUT 3=DELETE 4=HEAD 5=OPTIONS
	# 6=PATCH.

	def SubmitHttp(nMethod, cUrl, cBody)
		This._Ensure()
		return StzEngineReactorSubmitCurl(pHandle, nMethod, cUrl, cBody)

	def AwaitHttp(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorCurlAwait(pHandle, nId, nTimeoutMs)

	def PollHttp(nId)
		This._Ensure()
		return StzEngineReactorCurlPoll(pHandle, nId)

	# HTTP status code of the last drained request (or < 0 on error).
	def HttpLastStatus()
		return StzEngineReactorCurlLastStatus()

	# Submit + await a GET in one call; returns the response body.
	def HttpGet(cUrl, nTimeoutMs)
		This._Ensure()
		nId = StzEngineReactorSubmitCurl(pHandle, 0, cUrl, "")
		if nId < 1  return ""  ok
		return StzEngineReactorCurlAwait(pHandle, nId, nTimeoutMs)

	# Submit + await a POST with a body; returns the response body.
	def HttpPost(cUrl, cBody, nTimeoutMs)
		This._Ensure()
		nId = StzEngineReactorSubmitCurl(pHandle, 1, cUrl, cBody)
		if nId < 1  return ""  ok
		return StzEngineReactorCurlAwait(pHandle, nId, nTimeoutMs)

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

	# TLS-terminating HTTP listener: each connection runs an mbedTLS
	# handshake (server cert cCertPath + key cKeyPath) before the plaintext
	# HTTP framing -- so the events Ring drains are DECRYPTED requests and
	# ServerWrite responses are encrypted transparently. A non-empty cCaPath
	# turns on client-cert verification; bRequireClient = TRUE makes a valid
	# client cert MANDATORY (mutual TLS). Returns the server id (>0) or a
	# negative error (TLS setup errors are -10..-17). Engine-terminated TLS.
	def ListenHttpTls(cHost, nPort, cCertPath, cKeyPath, cCaPath, bRequireClient)
		This._Ensure()
		_nReq_ = 0
		if bRequireClient  _nReq_ = 1  ok
		return StzEngineReactorListenTls(pHandle, cHost, nPort, 1,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nReq_)

	# One-way server TLS convenience (no client cert): serve HTTPS with just
	# a server cert + key.
	def ListenHttpsServer(cHost, nPort, cCertPath, cKeyPath)
		return This.ListenHttpTls(cHost, nPort, cCertPath, cKeyPath, "", FALSE)

	#--- TLS CLIENT (the mTLS counterpart to ListenHttpTls) ---------------#

	# Send cRequest (raw HTTP bytes) to cHost:nPort over TLS and return the
	# response bytes ("" on failure -- see TlsClientStatus). This node
	# PRESENTS the client cert cCertPath/cKeyPath (for the peer's mutual
	# check; pass "" for none), and VALIDATES the peer's server cert against
	# cCaPath when bVerify = TRUE (hostname checked via SNI). A dedicated
	# mbedTLS transport (PEM certs + mutual auth), separate from the curl
	# path used for general outbound HTTPS.
	def TlsRequest(cHost, nPort, cRequest, cCertPath, cKeyPath, cCaPath, bVerify)
		This._Ensure()
		_nV_ = 0
		if bVerify  _nV_ = 1  ok
		return StzEngineReactorTlsRequest("" + cHost, nPort, "" + cRequest,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nV_)

	# Convenience: build + send a GET over TLS. Same cert/verify semantics.
	def TlsGet(cHost, nPort, cPath, cCertPath, cKeyPath, cCaPath, bVerify)
		_cCRLF_ = char(13) + char(10)
		_cReq_ = "GET " + cPath + " HTTP/1.1" + _cCRLF_ +
			"Host: " + cHost + _cCRLF_ +
			"Connection: close" + _cCRLF_ + _cCRLF_
		return This.TlsRequest(cHost, nPort, _cReq_, cCertPath, cKeyPath, cCaPath, bVerify)

	# Result of the last TlsRequest: 0 ok, -1 connect, -2 handshake (an
	# untrusted/invalid peer SERVER cert aborts here), -3 cert verify, -4
	# setup. NOTE: a server rejecting a MISSING client cert is enforced
	# SERVER-side -- under TLS 1.3 the client's handshake still completes
	# (status 0) but the protected response comes back EMPTY. So the
	# authoritative "was I let in?" check is the RESPONSE body, not status.
	def TlsClientStatus()
		return StzEngineReactorTlsClientStatus()

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
