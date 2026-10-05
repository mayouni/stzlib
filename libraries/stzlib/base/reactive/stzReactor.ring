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
			oR.ServerWrite(nSid, aEv[2], cHttpResponse, 1)
		ok
		oR.ServerStop(nSid)

		oR.Destroy()

	The handle is created lazily on first use, so both `new stzReactor`
	and `new stzReactor()` work (paren-less `new` skips init in Ring).
*/

func StzReactor()
	return new stzReactor()

# Runs timers, TCP and HTTP clients, child programs and servers on a libuv event loop that lives on a thread of its own, and hands the results to Ring by polling.
#
# Ring stays synchronous: you submit work and get a job id back at once, then Poll, Await or
# JobState that id, and no callback ever crosses into Ring. The calls come in families: Submit,
# Await, Poll and a LastStatus reader for timers, TCP, spawned programs and HTTP, plus one-call
# forms (TcpRequest, Spawn, HttpGet, HttpPost). A listener (Listen, ListenHttp, ListenStzm and the
# TLS forms) queues events that ServerPoll or ServerAwait drain as [ :accept, nConn, "" ], [ :data,
# nConn, cBytes ] or [ :closed, nConn, "" ]; ServerWrite and ServerCloseConn answer on a connection,
# and the Connect calls dial out and give a channel that is used the same way. A job id is spent
# once it is drained. The last-status readers (TcpLastStatus, SpawnLastStatus, HttpLastStatus,
# TlsClientStatus) hold one value for the whole process. The loop starts at the first call and
# Destroy stops it. Known gap today: Spawn and SubmitSpawn raise error R21 when given a plain text
# instead of a list.
#
#   receiver   o1 = new stzReactor()
#   example    ? o1.AwaitTimer( o1.SubmitTimer(20), 2000 )
#              #--> 0
#   see        stzReactiveSystem, stzReactorPool, stzAppServer
class stzReactor from stzObject

	@pHandle = ""
	@bReady  = 0

	# Builds a reactor and starts its event loop on a thread of its own, unless the loop already runs.
	#
	#   returns    nothing; the object is built
	#   note       the loop starts at the first call of any method, so a reactor made with new
	#              stzReactor and no parentheses works too
	#   see        Handle, Destroy
	def init()
		This._Ensure()

	def _Ensure()
		if @bReady = 0
			@pHandle = StzEngineReactorCreate()
			@bReady = 1
		ok

	# Returns the engine handle of the loop, starting the loop first when it is not running.
	#
	#   returns    the engine handle, of type StzReactor
	#   see        Destroy, Version
	def Handle()
		This._Ensure()
		return @pHandle

	# Returns the version of libuv, the event-loop library the engine is built on, as text.
	#
	#   returns    text such as "1.52.1"
	#   see        Handle
	def Version()
		return StzEngineReactorVersion()

	# Starts a timer on the loop and returns at once with the job id; the timer fires after the delay without blocking Ring.
	#
	#   nDelayMs   the delay before the timer fires, in milliseconds
	#   returns    a job id, a number from 1 up
	#   see        AwaitTimer, Poll, JobState
	#@ aka  ── timers ───────────────────────────────────────────────
	def SubmitTimer(nDelayMs)
		This._Ensure()
		return StzEngineReactorSubmitTimer(@pHandle, nDelayMs)

	# Waits up to the timeout for a timer to fire, then drains the job so its id is spent.
	#
	#   nId          the job id given by the submit call
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      0 when the job finished, -1 when the wait timed out, -2 when the id is unknown
	#                or was already drained
	#   see          SubmitTimer, Poll
	#@ aka  Block up to nTimeoutMs for the timer; returns 0 (fired), -1 (running/timeout) or -2 (unknown id).
	def AwaitTimer(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorAwait(@pHandle, nId, nTimeoutMs)

	# Checks a job without waiting and drains it when it is done; a drained id is unknown afterwards.
	#
	#   nId        the job id given by the submit call
	#   returns    0 when the job is done, -1 while it still runs, -2 when the id is unknown or was
	#              already drained
	#   see        AwaitTimer, JobState
	def Poll(nId)
		This._Ensure()
		return StzEngineReactorPoll(@pHandle, nId)

	# Peeks at a job without draining it, so the result can still be fetched afterwards.
	#
	#   nId        the job id given by the submit call
	#   returns    0 when the result is ready, -1 while the job runs, -2 when the id is unknown
	#   see        Poll, Pending
	#@ aka  Non-draining peek: -2 unknown, -1 running, 0 ready-to-fetch.
	def JobState(nId)
		This._Ensure()
		return StzEngineReactorJobState(@pHandle, nId)

	# Returns how many submitted jobs the loop has not yet started.
	#
	#   returns    a number; 0 when the loop has taken every job
	#   see        JobState, Poll
	def Pending()
		This._Ensure()
		return StzEngineReactorPending(@pHandle)

	# Opens a TCP connection to a host, sends the payload and returns at once with the job id; the answer is fetched later.
	#
	#   cHost      the host name or dotted address to connect to
	#   nPort      the TCP port
	#   cPayload   the bytes to send, as text
	#   returns    a job id, 0 or a negative number when the job could not be queued
	#   see        AwaitTcp, PollTcp, TcpRequest, TcpLastStatus
	#@ aka  ── async TCP request/response ───────────────────────────
	def SubmitTcp(cHost, nPort, cPayload)
		This._Ensure()
		return StzEngineReactorSubmitTcp(@pHandle, cHost, nPort, cPayload)

	# Waits up to the timeout for the answer of a TCP request and returns its bytes; an empty text means failure or timeout.
	#
	#   nId          the job id given by SubmitTcp
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the response bytes as text; "" when the wait timed out, the id is unknown or
	#                the connection failed
	#   note         read TcpLastStatus to tell an empty answer from a failure
	#   see          SubmitTcp, PollTcp, TcpLastStatus
	#@ aka  Block up to nTimeoutMs for the response body (empty on error/timeout).
	def AwaitTcp(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorTcpAwait(@pHandle, nId, nTimeoutMs)

	# Fetches the answer of a TCP request without waiting; the text is empty while the request is still running.
	#
	#   nId        the job id given by SubmitTcp
	#   returns    the response bytes as text; "" while the job runs, or when it failed or is
	#              unknown
	#   note       an empty text cannot tell running from failed: ask JobState first
	#   see        AwaitTcp, TcpLastStatus
	def PollTcp(nId)
		This._Ensure()
		return StzEngineReactorTcpPoll(@pHandle, nId)

	# Returns the outcome of the last TCP request that was fetched, whichever job it was.
	#
	#   returns    0 when the request succeeded, a negative libuv error code otherwise, such as
	#              -4078 for a refused connection
	#   note       one value shared by the whole process, so read it right after the fetch
	#   see        AwaitTcp, PollTcp
	def TcpLastStatus()
		return StzEngineReactorTcpLastStatus()

	# Sends a payload to a host over TCP and waits for the whole answer in one call.
	#
	#   cHost        the host name or dotted address to connect to
	#   nPort        the TCP port
	#   cPayload     the bytes to send, as text
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the response bytes as text; "" when the request could not be queued, timed out
	#                or failed
	#   see          SubmitTcp, AwaitTcp, TcpLastStatus
	#@ aka  Submit + await an async TCP request in one call; returns the body.
	def TcpRequest(cHost, nPort, cPayload, nTimeoutMs)
		This._Ensure()
		nId = StzEngineReactorSubmitTcp(@pHandle, cHost, nPort, cPayload)
		if nId < 1 return "" ok
		return StzEngineReactorTcpAwait(@pHandle, nId, nTimeoutMs)

	# Starts a program on the loop and returns at once with the job id; the program runs off the Ring thread and its output is fetched later.
	#
	#   acArgv     the program followed by its arguments, as a list of text
	#   returns    a job id, 0 or a negative number when the job could not be queued
	#   note       pass [ "program", "arg1" ]; the engine receives the arguments joined with line
	#              breaks
	#   warning    known defect: a plain text instead of a list raises error R21, because the wrap
	#              into a list is skipped inside the method
	#   see        AwaitSpawn, PollSpawn, Spawn
	#@ aka  ── async process spawn (polyglot fleet) ─────────────────
	def SubmitSpawn(acArgv)
		This._Ensure()
		if isString(acArgv)
			acArgv = [ acArgv ]
		ok
		cJoined = ""
		_nLen_ = len(acArgv)
		for i = 1 to _nLen_
			if i > 1  cJoined += char(10)  ok
			cJoined += "" + acArgv[i]
		next
		return StzEngineReactorSubmitSpawn(@pHandle, cJoined)

	# Waits up to the timeout for a started program to end and returns what it printed on its standard output.
	#
	#   nId          the job id given by SubmitSpawn
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the program output as text; "" when it printed nothing, timed out or the id is
	#                unknown
	#   note         the exit code comes from SpawnLastStatus
	#   see          SubmitSpawn, SpawnLastStatus
	#@ aka  Block up to nTimeoutMs for the child; returns its stdout.
	def AwaitSpawn(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorSpawnAwait(@pHandle, nId, nTimeoutMs)

	# Fetches the output of a started program without waiting; the text is empty while the program still runs.
	#
	#   nId        the job id given by SubmitSpawn
	#   returns    the program output as text; "" while it runs, once drained or when the id is
	#              unknown
	#   see        AwaitSpawn, SpawnLastStatus
	def PollSpawn(nId)
		This._Ensure()
		return StzEngineReactorSpawnPoll(@pHandle, nId)

	# Returns the exit code of the last program whose output was fetched, whichever job it was.
	#
	#   returns    the exit code, a number; 0 when the program succeeded
	#   note       one value shared by the whole process, so read it right after the fetch
	#   see        AwaitSpawn, PollSpawn
	def SpawnLastStatus()
		return StzEngineReactorSpawnLastStatus()

	# Sends a signal to a program started by SubmitSpawn; on Windows any signal ends the program with TerminateProcess.
	#
	#   nId        the job id given by SubmitSpawn
	#   nSignum    the signal number: 9 to kill, 15 to ask it to stop
	#   returns    0 when the signal was sent; -2 when no such job, -3 when it has already exited,
	#              -4 when the job is not a spawn
	#   see        KillSpawnHard, SubmitSpawn
	#@ aka  Force-kill a spawned child by job id: send nSignum (default SIGKILL=9; SIGTERM=15). On Windows libuv maps these to TerminateProcess. Returns 0 on success, negative on error (-2 not found, -3 already exited, -4 not a spawn / no handle). The kill is mutex-guarded in the engine so it can't race the loop thread reaping the process on its own exit.
	def KillSpawn(nId, nSignum)
		This._Ensure()
		return StzEngineReactorSpawnKill(@pHandle, nId, nSignum)

	# Forces a started program to end by sending signal 9, the stop for a program that hangs.
	#
	#   nId        the job id given by SubmitSpawn
	#   returns    0 when the signal was sent; -2 when no such job, -3 when it has already exited,
	#              -4 when the job is not a spawn
	#   see        KillSpawn, AwaitSpawn
	#@ aka  SIGKILL by default (the forceful stop for a wedged child).
	def KillSpawnHard(nId)
		This._Ensure()
		return StzEngineReactorSpawnKill(@pHandle, nId, 9)

	# Runs a program and waits for it to end, returning what it printed; the exit code is then in SpawnLastStatus.
	#
	#   acArgv       the program followed by its arguments, as a list of text
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the program output as text; "" when the job could not be queued or timed out
	#   note         pass [ "cmd", "/c", "echo hi" ] on Windows or [ "/bin/sh", "-c", "echo hi" ]
	#                elsewhere
	#   warning      known defect: a plain text instead of a list raises error R21, because the wrap
	#                into a list is skipped inside SubmitSpawn
	#   see          SubmitSpawn, SpawnLastStatus
	#@ aka  Submit + await in one call; returns the child's stdout.
	def Spawn(acArgv, nTimeoutMs)
		This._Ensure()
		nId = This.SubmitSpawn(acArgv)
		if nId < 1  return ""  ok
		return StzEngineReactorSpawnAwait(@pHandle, nId, nTimeoutMs)

	# Starts an HTTP or HTTPS request on a worker thread and returns at once with the job id; https works through the system TLS.
	#
	#   nMethod    the verb as a number: 0 GET, 1 POST, 2 PUT, 3 DELETE, 4 HEAD, 5 OPTIONS, 6 PATCH
	#   cUrl       the address, with its http:// or https:// start
	#   cBody      the request body, as text, "" for none
	#   returns    a job id, 0 or a negative number when the job could not be queued
	#   see        AwaitHttp, PollHttp, HttpGet, HttpPost
	#@ aka  ── async HTTP / HTTPS (native TLS, off the loop thread) ──
	def SubmitHttp(nMethod, cUrl, cBody)
		This._Ensure()
		return StzEngineReactorSubmitCurl(@pHandle, nMethod, cUrl, cBody)

	# Waits up to the timeout for an HTTP request to finish and returns the response body; an empty text means failure or timeout.
	#
	#   nId          the job id given by SubmitHttp
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the response body as text; "" when it failed, timed out or the id is unknown
	#   see          SubmitHttp, HttpLastStatus
	def AwaitHttp(nId, nTimeoutMs)
		This._Ensure()
		return StzEngineReactorCurlAwait(@pHandle, nId, nTimeoutMs)

	# Fetches the response body of an HTTP request without waiting; the text is empty while it still runs.
	#
	#   nId        the job id given by SubmitHttp
	#   returns    the response body as text; "" while the job runs, or when it failed or is unknown
	#   see        AwaitHttp, HttpLastStatus
	def PollHttp(nId)
		This._Ensure()
		return StzEngineReactorCurlPoll(@pHandle, nId)

	# Returns the HTTP status code of the last request that was fetched, or a negative number when it failed to get an answer.
	#
	#   returns    a status code such as 200, or -1 when the request failed
	#   note       one value shared by the whole process, so read it right after the fetch
	#   see        AwaitHttp, PollHttp
	#@ aka  HTTP status code of the last drained request (or < 0 on error).
	def HttpLastStatus()
		return StzEngineReactorCurlLastStatus()

	# Fetches a web address with a GET and waits for the body in one call.
	#
	#   cUrl         the address, with its http:// or https:// start
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the response body as text; "" when the request failed or timed out
	#   see          HttpPost, SubmitHttp, HttpLastStatus
	#@ aka  Submit + await a GET in one call; returns the response body.
	def HttpGet(cUrl, nTimeoutMs)
		This._Ensure()
		nId = StzEngineReactorSubmitCurl(@pHandle, 0, cUrl, "")
		if nId < 1  return ""  ok
		return StzEngineReactorCurlAwait(@pHandle, nId, nTimeoutMs)

	# Sends a body to a web address with a POST and waits for the response body in one call.
	#
	#   cUrl         the address, with its http:// or https:// start
	#   cBody        the request body, as text
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the response body as text; "" when the request failed or timed out
	#   see          HttpGet, SubmitHttp, HttpLastStatus
	#@ aka  Submit + await a POST with a body; returns the response body.
	def HttpPost(cUrl, cBody, nTimeoutMs)
		This._Ensure()
		nId = StzEngineReactorSubmitCurl(@pHandle, 1, cUrl, cBody)
		if nId < 1  return ""  ok
		return StzEngineReactorCurlAwait(@pHandle, nId, nTimeoutMs)

	# Opens a raw TCP listener on the loop; each :data event carries a chunk of the stream, as it arrived.
	#
	#   cHost      the address to listen on, such as "127.0.0.1"
	#   nPort      the TCP port
	#   returns    the server id, a number above 0; a negative libuv error code when the bind
	#              failed, such as -4091 for a busy port
	#   see        ServerPort, ServerAwait, ServerStop, ListenHttp
	#@ aka  ── server side: listen / events / write / close ─────────
	def Listen(cHost, nPort)
		This._Ensure()
		return StzEngineReactorListen(@pHandle, cHost, nPort, 0)

	# Opens an HTTP/1.1 listener on the loop; each :data event carries one whole request, headers and body.
	#
	#   cHost      the address to listen on, such as "127.0.0.1"
	#   nPort      the TCP port
	#   returns    the server id, a number above 0; a negative libuv error code when the bind failed
	#   see        Listen, ServerAwait, ServerWrite, ListenHttpTls
	#@ aka  HTTP/1.1 listener: :data events carry complete requests.
	def ListenHttp(cHost, nPort)
		This._Ensure()
		return StzEngineReactorListen(@pHandle, cHost, nPort, 1)

	# Opens a listener for the STZM message plane; each :data event carries one whole frame, ready for StzmUnpack.
	#
	#   cHost      the address to listen on, such as "127.0.0.1"
	#   nPort      the TCP port
	#   returns    the server id, a number above 0; a negative libuv error code when the bind failed
	#   see        ListenStzmTls, ConnectStzm, ServerAwait
	#@ aka  STZM message-plane listener (distribution D0): each :data event is ONE complete STZM frame (header + payload). Unpack with StzmUnpack().
	def ListenStzm(cHost, nPort)
		This._Ensure()
		return StzEngineReactorListen(@pHandle, cHost, nPort, 2)

	# Opens an STZM listener that ends TLS itself, so the frames Ring drains are already decrypted.
	#
	#   cHost            the address to listen on
	#   nPort            the TCP port
	#   cCertPath        the server certificate file, PEM
	#   cKeyPath         the private key file, PEM
	#   cCaPath          the CA file used to check client certificates, "" for no check
	#   bRequireClient   TRUE to refuse a client without a valid certificate
	#   returns          the server id, a number above 0; a negative error code when the bind or the
	#                    TLS setup failed, -13 was seen for a missing certificate file
	#   see              ListenStzm, ConnectStzmTls, ListenHttpTls
	#@ aka  TLS-terminating STZM listener (D5): the same framed message plane over the same mbedTLS termination the HTTPS listener uses. A non-empty cCaPath verifies client certs; bRequireClient makes a valid one MANDATORY (mutual TLS node links).
	def ListenStzmTls(cHost, nPort, cCertPath, cKeyPath, cCaPath, bRequireClient)
		This._Ensure()
		_nReq_ = 0
		if bRequireClient  _nReq_ = 1  ok
		return StzEngineReactorListenTls(@pHandle, cHost, nPort, 2,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nReq_)

	# Dials a peer and keeps the link as a channel; the channel id comes back at once and the link-up arrives as an :accept event.
	#
	#   cHost      the peer address
	#   nPort      the peer TCP port
	#   returns    a channel id, a number above 0; the channel then takes ServerWrite, ServerPoll
	#              and ServerStop like a listener
	#   see        WaitLinkUp, ConnectRaw, ListenStzm
	#@ aka  Persistent CLIENT CHANNEL to a peer (distribution D0). The dial is async: the channel id comes back immediately; link-up arrives as an :accept event on ServerPoll/Await (a failed dial as :closed). The channel then speaks the SAME calls a listener does -- ServerWrite to send, ServerPoll to receive, ServerStop to hang up. A link is a link, whichever side dialed.
	def ConnectStzm(cHost, nPort)
		This._Ensure()
		return StzEngineReactorConnect(@pHandle, cHost, nPort, 2)

	# Dials a peer and keeps the link as a channel of raw stream chunks; the link-up arrives as an :accept event.
	#
	#   cHost      the peer address
	#   nPort      the peer TCP port
	#   returns    a channel id, a number above 0
	#   warning    a refused dial still returns an id: the failure arrives later as a :closed event
	#   see        ConnectStzm, WaitLinkUp, ServerStop
	#@ aka  Raw-stream client channel (:data events carry stream chunks).
	def ConnectRaw(cHost, nPort)
		This._Ensure()
		return StzEngineReactorConnect(@pHandle, cHost, nPort, 0)

	# Dials a peer over TLS and keeps the link as a channel; the link-up event comes only when the handshake has completed.
	#
	#   cHost       the peer address
	#   nPort       the peer TCP port
	#   cCertPath   the client certificate file to present, "" for none
	#   cKeyPath    the private key file for it, "" for none
	#   cCaPath     the CA file that must vouch for the peer, "" for the system roots
	#   bVerify     TRUE to verify the peer, or :InsecureNoVerify to skip the check
	#   returns     a channel id, a number above 0
	#   see         ConnectStzm, ListenStzmTls, WaitLinkUp
	#@ aka  STZM channel over CLIENT-role TLS (the mTLS counterpart of ListenTls, on the persistent link): this node PRESENTS cCertPath/cKeyPath for the peer's mutual check ("" for none) and VALIDATES the peer -- see _TlsVerifyMode() for what bVerify may be. Link-up (:accept) fires only when the handshake COMPLETES -- an up channel is a SECURE channel.
	def ConnectStzmTls(cHost, nPort, cCertPath, cKeyPath, cCaPath, bVerify)
		This._Ensure()
		_nV_ = This._TlsVerifyMode(bVerify)
		return StzEngineReactorConnectTls(@pHandle, cHost, nPort, 2,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nV_)

	# Waits up to the timeout for a channel to come up and returns the connection id to write on.
	#
	#   nChanId      the channel id given by ConnectStzm, ConnectRaw or ConnectStzmTls
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      the connection id, a number above 0; 0 when the dial failed or timed out
	#   warning      the first event of the channel is consumed by the wait, so a later ServerAwait
	#                does not see the :accept again
	#   see          ConnectStzm, ServerWrite
	#@ aka  Block up to nTimeoutMs for the channel's link-up. Returns the conn id (> 0) to write on, or 0 (dial failed or timed out).
	def WaitLinkUp(nChanId, nTimeoutMs)
		This._Ensure()
		aEv = This.ServerAwait(nChanId, nTimeoutMs)
		if len(aEv) = 3 and aEv[1] = :accept
			return aEv[2]
		ok
		return 0

	# Opens an HTTPS listener that ends TLS itself, so the requests Ring drains are already decrypted and replies are encrypted for it.
	#
	#   cHost            the address to listen on
	#   nPort            the TCP port
	#   cCertPath        the server certificate file, PEM
	#   cKeyPath         the private key file, PEM
	#   cCaPath          the CA file used to check client certificates, "" for no check
	#   bRequireClient   TRUE to refuse a client without a valid certificate
	#   returns          the server id, a number above 0; a negative error code when the bind or the
	#                    TLS setup failed, -13 was seen for a missing certificate file
	#   see              ListenHttpsServer, ListenHttp, TlsRequest
	#@ aka  TLS-terminating HTTP listener: each connection runs an mbedTLS handshake (server cert cCertPath + key cKeyPath) before the plaintext HTTP framing -- so the events Ring drains are DECRYPTED requests and ServerWrite responses are encrypted transparently. A non-empty cCaPath turns on client-cert verification; bRequireClient = TRUE makes a valid client cert MANDATORY (mutual TLS). Returns the server i
	def ListenHttpTls(cHost, nPort, cCertPath, cKeyPath, cCaPath, bRequireClient)
		This._Ensure()
		_nReq_ = 0
		if bRequireClient  _nReq_ = 1  ok
		return StzEngineReactorListenTls(@pHandle, cHost, nPort, 1,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nReq_)

	# Opens an HTTPS listener with a server certificate only, asking nothing of the client.
	#
	#   cHost       the address to listen on
	#   nPort       the TCP port
	#   cCertPath   the server certificate file, PEM
	#   cKeyPath    the private key file, PEM
	#   returns     the server id, a number above 0; a negative error code when the bind or the TLS
	#               setup failed
	#   see         ListenHttpTls, ListenHttp
	#@ aka  One-way server TLS convenience (no client cert): serve HTTPS with just a server cert + key.
	def ListenHttpsServer(cHost, nPort, cCertPath, cKeyPath)
		return This.ListenHttpTls(cHost, nPort, cCertPath, cKeyPath, "", 0)

	#--- TLS CLIENT (the mTLS counterpart to ListenHttpTls) ---------------#

	# Sends raw HTTP bytes to a host over TLS and returns the answer, checking the server certificate and, when asked, presenting a client one.
	#
	#   cHost       the host name, also sent as SNI
	#   nPort       the TCP port
	#   cRequest    the raw HTTP request, as text
	#   cCertPath   the client certificate file to present, "" for none
	#   cKeyPath    the private key file for it, "" for none
	#   cCaPath     the CA file that must vouch for the server, "" for the system roots
	#   bVerify     TRUE to verify the server, or :InsecureNoVerify to skip the check
	#   returns     the response bytes as text; "" on failure, and then TlsClientStatus says why
	#   note        an empty answer from a server that wanted a client certificate does not show in
	#               the status under TLS 1.3: judge by the body
	#   see         TlsGet, TlsClientStatus
	#@ aka  Send cRequest (raw HTTP bytes) to cHost:nPort over TLS and return the response bytes ("" on failure -- see TlsClientStatus). This node PRESENTS the client cert cCertPath/cKeyPath (for the peer's mutual check; pass "" for none), and VALIDATES the peer's server cert (hostname checked via SNI) -- see _TlsVerifyMode() for bVerify. A dedicated mbedTLS transport (PEM certs + mutual auth), separate from 
	def TlsRequest(cHost, nPort, cRequest, cCertPath, cKeyPath, cCaPath, bVerify)
		This._Ensure()
		_nV_ = This._TlsVerifyMode(bVerify)
		return StzEngineReactorTlsRequest("" + cHost, nPort, "" + cRequest,
			"" + cCertPath, "" + cKeyPath, "" + cCaPath, _nV_)

	# Sends a GET for a path over TLS and returns the answer, with the same certificate and verify rules as the raw request.
	#
	#   cHost       the host name, also sent as SNI
	#   nPort       the TCP port
	#   cPath       the path to ask for, such as "/"
	#   cCertPath   the client certificate file to present, "" for none
	#   cKeyPath    the private key file for it, "" for none
	#   cCaPath     the CA file that must vouch for the server, "" for the system roots
	#   bVerify     TRUE to verify the server, or :InsecureNoVerify to skip the check
	#   returns     the response bytes as text; "" on failure, and then TlsClientStatus says why
	#   see         TlsRequest, TlsClientStatus
	#@ aka  Convenience: build + send a GET over TLS. Same cert/verify semantics.
	def TlsGet(cHost, nPort, cPath, cCertPath, cKeyPath, cCaPath, bVerify)
		_cCRLF_ = char(13) + char(10)
		_cReq_ = "GET " + cPath + " HTTP/1.1" + _cCRLF_ +
			"Host: " + cHost + _cCRLF_ +
			"Connection: close" + _cCRLF_ + _cCRLF_
		return This.TlsRequest(cHost, nPort, _cReq_, cCertPath, cKeyPath, cCaPath, bVerify)

	# The client verification policy fails CLOSED. bVerify is one of:
	#   TRUE               the peer MUST validate -- against cCaPath when
	#                      given, else against the operating system's
	#                      trusted roots (no anchor at all: status -19)
	#   :InsecureNoVerify  no verification, because the caller NAMED it
	#   FALSE              REFUSED (status -18): switching verification off
	#                      is a named mode, never a boolean one can drift into
	def _TlsVerifyMode(bVerify)
		if isString(bVerify)
			if StzLower(bVerify) = "insecurenoverify"  return -1  ok
			return 0
		ok
		if bVerify = 1  return 1  ok
		return 0

	# Returns the outcome code of the last TLS request, which says why that request returned an empty text.
	#
	#   returns    0 when it went through; -1 connect, -2 handshake, -3 certificate check, -4 setup,
	#              -18 verification refused, -19 no trust anchor
	#   see        TlsRequest, TlsGet
	#@ aka  Result of the last TlsRequest: 0 ok, -1 connect, -2 handshake (an untrusted/invalid peer SERVER cert aborts here), -3 cert verify, -4 setup, -18 verification switched off without :InsecureNoVerify, -19 no trust anchor. NOTE: a server rejecting a MISSING client cert is enforced SERVER-side -- under TLS 1.3 the client's handshake still completes (status 0) but the protected response comes back EMPTY
	def TlsClientStatus()
		return StzEngineReactorTlsClientStatus()

	# Returns the port a listener is really bound to, which is how a port of 0 is learned.
	#
	#   nServerId   the server id given by a Listen call
	#   returns     the port number; -2 when the server id is unknown
	#   see         Listen, ListenHttp
	#@ aka  Actual bound port (useful after nPort = 0).
	def ServerPort(nServerId)
		This._Ensure()
		return StzEngineReactorServerPort(@pHandle, nServerId)

	# Returns how many connections a listener holds open now.
	#
	#   nServerId   the server id given by a Listen call
	#   returns     a number; -2 when the server id is unknown
	#   see         ServerStop, ServerCloseConn
	def ServerConns(nServerId)
		This._Ensure()
		return StzEngineReactorServerConns(@pHandle, nServerId)

	# Takes one event off a listener or channel without waiting; an empty list means none is queued.
	#
	#   nServerId   the server id or channel id
	#   returns     [ :accept, nConn, "" ], [ :data, nConn, cBytes ], [ :closed, nConn, "" ], or [ ]
	#               when there is no event
	#   see         ServerAwait, ServerWrite
	#@ aka  Drain one event without blocking; [] if none.
	def ServerPoll(nServerId)
		This._Ensure()
		nKind = StzEngineReactorServerPoll(@pHandle, nServerId)
		return This._ServerEvent(nKind)

	# Waits up to the timeout for one event of a listener or channel and takes it.
	#
	#   nServerId    the server id or channel id
	#   nTimeoutMs   the longest wait, in milliseconds
	#   returns      [ :accept, nConn, "" ], [ :data, nConn, cBytes ], [ :closed, nConn, "" ], or [
	#                ] on timeout
	#   see          ServerPoll, ServerWrite, WaitLinkUp
	#@ aka  Block up to nTimeoutMs for one event; [] on timeout.
	def ServerAwait(nServerId, nTimeoutMs)
		This._Ensure()
		nKind = StzEngineReactorServerAwait(@pHandle, nServerId, nTimeoutMs)
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

	# Queues bytes to a connection of a listener or channel, and closes it once they are sent when asked.
	#
	#   nServerId     the server id or channel id
	#   nConnId       the connection id taken from an event
	#   cData         the bytes to send, as text
	#   bCloseAfter   1 to close the connection after the write, 0 to keep it open
	#   returns       0 when the write was queued, -1 when the server id is unknown or the loop is
	#                 stopping
	#   note          an unknown connection id is not reported: the answer is still 0
	#   warning       only the value 1 (TRUE) closes the connection; any other value keeps it open
	#   see           ServerCloseConn, ServerAwait
	#@ aka  Write to a connection; bCloseAfter closes it once the write lands.
	def ServerWrite(nServerId, nConnId, cData, bCloseAfter)
		This._Ensure()
		nClose = 0
		if bCloseAfter = 1
			nClose = 1
		ok
		return StzEngineReactorServerWrite(@pHandle, nServerId, nConnId, cData, nClose)

	# Queues the closing of one connection of a listener or channel.
	#
	#   nServerId   the server id or channel id
	#   nConnId     the connection id taken from an event
	#   returns     0 when the close was queued, -1 when the server id is unknown
	#   note        an unknown connection id is not reported: the answer is still 0
	#   see         ServerWrite, ServerStop
	def ServerCloseConn(nServerId, nConnId)
		This._Ensure()
		return StzEngineReactorServerCloseConn(@pHandle, nServerId, nConnId)

	# Limits how many data events a listener may queue and says what happens to the next one; every drop is counted.
	#
	#   nServerId   the server id
	#   nCap        the most data events held, 0 for no limit
	#   cPolicy     what to do on overflow: :DropOldest, :DropNewest or :Refuse, which also closes
	#               the connection
	#   returns     0 when set, -2 when the server id is unknown
	#   note        any other policy text is taken as the default policy, with no error
	#   see         ServerOverflow, ServerPendingData
	#@ aka  Bounded inbox (distribution D1): cap the QUEUED data events with a declared overflow policy -- :DropOldest / :DropNewest / :Refuse (reject and hang up, so the sender observes it). nCap 0 = unbounded. Overflow is COUNTED (ServerOverflow), never silent.
	def ServerSetInbox(nServerId, nCap, cPolicy)
		This._Ensure()
		nPol = 0
		if cPolicy = :DropOldest
			nPol = 1
		but cPolicy = :DropNewest
			nPol = 2
		but cPolicy = :Refuse
			nPol = 3
		ok
		return StzEngineReactorServerSetInbox(@pHandle, nServerId, nCap, nPol)

	# Returns how many data events the listener dropped or refused since it started because its inbox was full.
	#
	#   nServerId   the server id
	#   returns     a number; -1 when the server id is unknown
	#   see         ServerSetInbox, ServerPendingData
	def ServerOverflow(nServerId)
		This._Ensure()
		return StzEngineReactorServerOverflow(@pHandle, nServerId)

	# Returns how many data events wait in a listener's inbox for ServerPoll or ServerAwait.
	#
	#   nServerId   the server id
	#   returns     a number; -1 when the server id is unknown
	#   see         ServerSetInbox, ServerOverflow
	def ServerPendingData(nServerId)
		This._Ensure()
		return StzEngineReactorServerPendingData(@pHandle, nServerId)

	# Closes a listener or channel and every connection it holds.
	#
	#   nServerId   the server id or channel id
	#   returns     0 when the stop was queued, -1 when the server id is unknown
	#   note        stopping a server twice may answer 0 both times: the id leaves the table only
	#               after the loop closed its handles
	#   see         Listen, ServerCloseConn
	def ServerStop(nServerId)
		This._Ensure()
		return StzEngineReactorServerStop(@pHandle, nServerId)

	# Stops the loop and releases the engine handle; the next call of any method starts a new loop.
	#
	#   returns    the reactor itself, so it can be chained
	#   see        init, Handle
	#@ aka  ── teardown ─────────────────────────────────────────────
	def Destroy()
		if @bReady = 1
			StzEngineReactorDestroy(@pHandle)
			@pHandle = ""
			@bReady = 0
		ok
		return This
