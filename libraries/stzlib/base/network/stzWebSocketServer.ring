# =============================================================================
# WEBSOCKET SERVER -- RFC 6455 over the in-tree engine (engine/src/ws_server.zig)
#
# The engine listens, runs each client's opening handshake (and answers a bad
# one on the wire with 400, 403 or 426), reads masked frames and writes plain
# ones. What it hands to Ring is an open connection: a stzWebSocketConnection,
# which answers the same messages as the client class. Nothing here loops over
# a payload byte.
# =============================================================================

# Holds a WebSocket listener that accepts clients one at a time and hands each back as an open connection.
#
# Listen starts the listener and returns at once; the application then calls Accept or AcceptWithin
# in its own loop and drives each connection it gets. A client that opens a socket and says nothing
# holds Accept for up to the handshake timeout, which SetHandshakeTimeout shortens. A request that
# is not a valid opening handshake is answered on the wire and refused by name; it never reaches
# the application and the count Refused goes up. ListenSecure serves wss from a PEM certificate and
# key. The documentation ran against a client in the same process on the loopback address, never
# against another machine.
#
#   receiver   o1 = new stzWebSocketServer()
#   example    ? o1.IsListening()
#              #--> 0
#              o1.Listen(47322, "127.0.0.1")
#              ? o1.IsListening()
#              #--> 1
#              o1.AcceptWithin(50)
#              ? o1.AcceptTimedOut()
#              #--> 1
#              o1.StopListening()
#              ? o1.IsListening()
#              #--> 0
#   see        stzWebSocket, stzWebSocketConnection
class stzWebSocketServer from stzNetwork
	@hServer = ""
	@is_listening = 0
	@port = 0
	@timed_out = 0
	@accepted = 0
	@refused = 0
	@on_error_callback = ""
	@max_message_size = 16777216
	@subprotocols = ""
	@origins = ""
	@handshake_ms = 5000
	@close_wait_ms = 2000
	@compression = 0

	# Builds a server that is not listening and has no callback.
	#
	#   returns    nothing; the object is built
	#   see        Listen
	def init()

	# Starts accepting plain ws clients on a port and returns at once.
	#
	#   nPort      the port number; 0 picks a free one, which Port then reports
	#   cHost      the address to listen on; an empty text means 127.0.0.1, this machine only
	#   returns    the server itself, so calls chain
	#   note       to serve other machines pass 0.0.0.0 on purpose; the default keeps it local
	#   warning    a failure does not raise: IsListening stays FALSE and LastError says why
	#   see        ListenSecure, Accept, StopListening
	def Listen(nPort, cHost)
		return This._Bind(nPort, cHost, "", "")

	# Starts accepting wss clients on a port, presenting a PEM certificate and its private key.
	#
	#   nPort      the port number; 0 picks a free one
	#   cHost      the address to listen on; an empty text means 127.0.0.1
	#   cCertFile  the path of the PEM certificate file
	#   cKeyFile   the path of the PEM private key file, which must not be protected by a password
	#   returns    the server itself, so calls chain
	#   warning    a missing or unreadable file sets LastError to the file's name and does not listen
	#   see        Listen, Accept
	def ListenSecure(nPort, cHost, cCertFile, cKeyFile)
		if NOT (isString(cCertFile) and isString(cKeyFile))
			StzRaise("Incorrect param types! cCertFile and cKeyFile must be strings.")
		ok
		if NOT fexists(cCertFile)
			This._Fail("certificate file not found: " + cCertFile)
			return This
		ok
		if NOT fexists(cKeyFile)
			This._Fail("key file not found: " + cKeyFile)
			return This
		ok
		return This._Bind(nPort, cHost, cCertFile, cKeyFile)

	# Waits the Timeout, in seconds, for a client and returns its open connection.
	#
	#   returns    a stzWebSocketConnection; an empty text on timeout or when the client was refused
	#   note       it forwards to AcceptWithin with Timeout times 1000 milliseconds
	#   see        AcceptWithin
	def Accept()
		return This.AcceptWithin(This.Timeout() * 1000)

	# Waits up to that many milliseconds for a client and returns its open connection.
	#
	#   nMs        the longest wait in milliseconds; 0 looks once and returns at once
	#   returns    a stzWebSocketConnection; an empty text when nobody came or the client was refused
	#   note       after a timeout AcceptTimedOut is TRUE and LastError is empty; after a refusal
	#              LastError names the cause, such as handshake: Origin not allowed, and Refused
	#              has counted it
	#   warning    without a listener it sets LastError to Not listening
	#   see        AcceptTimedOut, Refused
	def AcceptWithin(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@timed_out = 0
		if not @is_listening
			@last_error = "Not listening"
			return ""
		ok
		return This._Wrap(StzEngineWsServerAccept(@hServer, nMs))

	# Starts waiting for a client on a background thread and returns at once; EndAccept collects it.
	#
	#   nMs        the longest wait in milliseconds, above 0
	#   returns    the server itself, so calls chain
	#   note       it lets one program be both ends of a session: begin the accept, connect a
	#              stzWebSocket to Port, then call EndAccept; only one accept can be waiting
	#   warning    without a listener it sets LastError to Not listening; StopListening waits for
	#              the thread, at most the milliseconds given
	#   see        EndAccept, AcceptWithin
	def BeginAccept(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		if not @is_listening
			@last_error = "Not listening"
			return This
		ok
		if StzEngineWsServerBeginAccept(@hServer, nMs) = 0
			This._Fail("accept not started: one is already waiting, or the wait was not above 0")
		else
			ClearErrors()
		ok
		return This

	# Waits for the accept BeginAccept started and returns the connection it got.
	#
	#   returns    a stzWebSocketConnection; an empty text when nobody came, the client was refused,
	#              or no accept was started
	#   note       it reports as AcceptWithin does: AcceptTimedOut after a timeout, LastError after
	#              a refusal
	#   see        BeginAccept, AcceptTimedOut
	def EndAccept()
		@timed_out = 0
		if not @is_listening
			@last_error = "Not listening"
			return ""
		ok
		return This._Wrap(StzEngineWsServerEndAccept(@hServer))

	# Sets how long a connection waits, in milliseconds, for the client's close frame when it closes first.
	#
	#   nMs        the wait in milliseconds; the default is 2000
	#   returns    the server itself, so calls chain
	#   note       it applies to connections accepted after the call
	#   see        CloseTimeout
	def SetCloseTimeout(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@close_wait_ms = nMs
		return This

	# Returns how long an accepted connection waits for the client's close frame, in milliseconds.
	#
	#   returns    a number
	#   see        SetCloseTimeout
	def CloseTimeout()
		return @close_wait_ms

	# TRUE if the last Accept or AcceptWithin ended because nobody connected in time.
	#
	#   returns    TRUE or FALSE
	#   see        AcceptWithin
	def AcceptTimedOut()
		return @timed_out

	# TRUE if the server is listening.
	#
	#   returns    TRUE or FALSE
	#   see        Listen, StopListening
	def IsListening()
		return @is_listening

	# Returns the port the server listens on, which is the real one when Listen was given 0.
	#
	#   returns    a number; 0 when not listening
	#   see        Listen
	def Port()
		return @port

	# Returns how many clients completed the handshake since Listen.
	#
	#   returns    a number
	#   see        Refused
	def Accepted()
		return @accepted

	# Returns how many clients were refused at the handshake since Listen.
	#
	#   returns    a number
	#   see        Accepted, AcceptWithin
	def Refused()
		if @hServer = ""
			return @refused
		ok
		return StzEngineWsServerRefused(@hServer)

	# Stops listening; connections already accepted stay open until they are closed.
	#
	#   returns    the server itself, so calls chain
	#   note       safe to call any number of times and before Listen
	#   see        Listen, IsListening
	def StopListening()
		if @hServer != ""
			@refused = StzEngineWsServerRefused(@hServer)
			StzEngineWsServerClose(@hServer)
			@hServer = ""
		ok
		@is_listening = 0
		@port = 0
		return This

		def Close()
			return This.StopListening()

	# Sets the largest message, in bytes, that an accepted connection receives; a larger one closes it with 1009.
	#
	#   nBytes     the limit in bytes; the default is 16777216, 16 MiB
	#   returns    the server itself, so calls chain
	#   note       it applies to connections accepted after the call
	#   see        MaxMessageSize
	def SetMaxMessageSize(nBytes)
		if NOT isNumber(nBytes)
			StzRaise("Incorrect param type! nBytes must be a number.")
		ok
		@max_message_size = nBytes
		if @is_listening
			StzEngineWsServerSetMaxMessage(@hServer, nBytes)
		ok
		return This

	# Returns the largest message, in bytes, that an accepted connection receives.
	#
	#   returns    a number
	#   see        SetMaxMessageSize
	def MaxMessageSize()
		return @max_message_size

	# Sets the subprotocols this server speaks, as a comma-separated text; a client offering one gets the first match.
	#
	#   cList      the names, such as chat, superchat
	#   returns    the server itself, so calls chain
	#   note       with none set no subprotocol is ever agreed, even when a client offers some
	#   see        stzWebSocketConnection
	def SetSubprotocols(cList)
		if NOT isString(cList)
			StzRaise("Incorrect param type! cList must be a string.")
		ok
		@subprotocols = cList
		if @is_listening
			StzEngineWsServerSetSubprotocols(@hServer, cList)
		ok
		return This

	# Sets the Origin values a browser may connect from, as a comma-separated text; others get 403.
	#
	#   cList      the origins, such as http://app.example, http://localhost:8080
	#   returns    the server itself, so calls chain
	#   note       a request with no Origin header comes from a program, not a browser page, and is
	#              let in either way; with none set every origin is allowed
	#   warning    this is the defence against a web page opening a socket to a local server on the
	#              visitor's behalf; set it for any server a browser can reach
	#   see        Refused
	def SetAllowedOrigins(cList)
		if NOT isString(cList)
			StzRaise("Incorrect param type! cList must be a string.")
		ok
		@origins = cList
		if @is_listening
			StzEngineWsServerSetOrigins(@hServer, cList)
		ok
		return This

	# Agrees to permessage-deflate (RFC 7692) with the clients that offer it, for the connections that follow.
	#
	#   returns    the server itself, so calls chain
	#   note       it applies at once to a listening server; a client that offers parameters the
	#              engine cannot honor, such as an 8-bit window, is let in without compression
	#   warning    it is off by default; a received message is inflated under SetMaxMessageSize, so a
	#              small frame that would expand beyond it closes that connection with 1009
	#   see        DisableCompression, SetMaxMessageSize
	#   example    o1.EnableCompression()
	#              ? o1.IsCompressionEnabled()
	#              #--> 1
	def EnableCompression()
		@compression = 1
		if @is_listening
			StzEngineWsServerSetCompression(@hServer, 1)
		ok
		return This

	# Stops agreeing to permessage-deflate for the connections that follow.
	#
	#   returns    the server itself, so calls chain
	#   see        EnableCompression
	def DisableCompression()
		@compression = 0
		if @is_listening
			StzEngineWsServerSetCompression(@hServer, 0)
		ok
		return This

	# TRUE if the server agrees to permessage-deflate when a client offers it.
	#
	#   returns    TRUE or FALSE
	#   see        EnableCompression
	def IsCompressionEnabled()
		return @compression

	# Sets how long a client may take to send its opening request, in milliseconds.
	#
	#   nMs        the wait in milliseconds; the default is 5000
	#   returns    the server itself, so calls chain
	#   note       Accept is single-threaded, so this is the longest a silent client can hold it
	#   see        Accept
	def SetHandshakeTimeout(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@handshake_ms = nMs
		if @is_listening
			StzEngineWsServerSetHandshakeTimeout(@hServer, nMs)
		ok
		return This

	# Stores the name of a function to run when Listen or Accept fails or refuses a client.
	#
	#   cCallback   the name of a function that takes no parameter
	#   returns     the server itself, so calls chain
	#   note        it runs after LastError is set; a callback that is empty or not a text is skipped
	#   see         Listen, LastError
	def OnError(cCallback)
		@on_error_callback = cCallback
		return This

	def _Bind(nPort, cHost, cCert, cKey)
		if NOT isNumber(nPort)
			StzRaise("Incorrect param type! nPort must be a number.")
		ok
		if NOT isString(cHost)
			StzRaise("Incorrect param type! cHost must be a string.")
		ok
		if @is_listening
			This.StopListening()
		ok
		@hServer = StzEngineWsServerListen(cHost, nPort, cCert, cKey)
		if @hServer = 0
			@hServer = ""
			@is_listening = 0
			This._Fail("listen failed: the port is in use or the address cannot be bound")
			return This
		ok
		@is_listening = 1
		@port = StzEngineWsServerPort(@hServer)
		StzEngineWsServerSetMaxMessage(@hServer, @max_message_size)
		StzEngineWsServerSetSubprotocols(@hServer, @subprotocols)
		StzEngineWsServerSetOrigins(@hServer, @origins)
		StzEngineWsServerSetHandshakeTimeout(@hServer, @handshake_ms)
		StzEngineWsServerSetCompression(@hServer, @compression)
		@accepted = 0
		@refused = 0
		ClearErrors()
		return This

	def _Wrap(hClient)
		if hClient = 0
			if StzEngineWsServerTimedOut(@hServer) = 1
				@timed_out = 1
				ClearErrors()
			else
				This._Fail(StzEngineWsServerLastError(@hServer))
			ok
			return ""
		ok
		ClearErrors()
		@accepted++
		_oConn_ = new stzWebSocketConnection
		_oConn_._Adopt(hClient)
		_oConn_.RequestTarget()
		_oConn_.SetTimeout(This.Timeout())
		_oConn_.SetCloseTimeout(@close_wait_ms)
		return _oConn_

	def _Fail(cMessage)
		@last_error = cMessage
		@error_code = -1
		if isString(@on_error_callback) and @on_error_callback != ""
			call @on_error_callback()
		ok

# Holds one open WebSocket session a server accepted, answering every message of the client class.
#
# A stzWebSocketServer hands it out already open: Receive, ReceiveWithTimeout, SendText, SendBinary,
# SendPing, Close and the rest behave as on a client, except that frames go out unmasked and a
# frame that arrives unmasked closes the session with 1002. RequestTarget and RequestHeader tell
# what the client asked for. Connect is not for a server side: it sets LastError and opens nothing.
#
#   receiver   o1 = new stzWebSocketConnection()
#   example    ? o1.IsOpen()
#              #--> 0
#   see        stzWebSocketServer, stzWebSocket
class stzWebSocketConnection from stzWebSocket
	@request_target = ""

	# Returns the path and query the client asked for, such as /room?x=1.
	#
	#   returns    a text; empty before the connection was accepted
	#   see        RequestHeader
	def RequestTarget()
		if @hWs != ""
			@request_target = StzEngineWsRequestTarget(@hWs)
		ok
		return @request_target

	# Returns the value of a header of the client's opening request, such as Origin or User-Agent.
	#
	#   cName      the header name, in any case
	#   returns    a text; empty when the client sent none, and always empty once the session has ended
	#   see        RequestTarget
	def RequestHeader(cName)
		if NOT isString(cName)
			StzRaise("Incorrect param type! cName must be a string.")
		ok
		if @hWs = ""
			return ""
		ok
		return StzEngineWsRequestHeader(@hWs, cName)

	# Refuses to connect, since this session was accepted by a server and is not a client.
	#
	#   cUrl       ignored
	#   returns    the connection itself, so calls chain
	#   warning    it sets LastError and runs the error callback; it does not touch the open session
	#   see        stzWebSocket
	def Connect(cUrl)
		This._Fail("A server-side connection is accepted, not connected: use stzWebSocket.Connect on a client", -1)
		return This
