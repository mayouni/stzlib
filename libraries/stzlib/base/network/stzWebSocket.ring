# =============================================================================
# WEBSOCKET CLIENT -- RFC 6455 over the in-tree engine (engine/src/ws.zig)
#
# The engine does the whole protocol: the opening handshake and its checks,
# client masking, the 7/16/64-bit length forms, fragmentation both ways, the
# automatic pong, UTF-8 and size checks, the close handshake, and TLS for wss
# (mbedTLS, the certificate verified against the system's trust store or a CA
# file). This class is the thin face: it keeps the handle, the last message
# and the error slot, and runs the callbacks. No byte of a payload is ever
# looped over in Ring.
# =============================================================================

$nStzWsEchoPort = 0

# Starts the loopback WebSocket echo server on a port, or reports the one already running.
#
# The echo server lives in the engine and exists for guards and documentation examples: it
# echoes text and binary, answers pings and completes the close handshake on 127.0.0.1. One
# server runs per process; a second call returns the port of the first.
#
#   nPort      the port to listen on, where 0 means any free port
#   returns    the bound port as a number, or -1 when the server could not start
#   note       stop it with StzWsLoopbackEchoStop when the example is done
#   see        stzWebSocket, StzWsLoopbackEchoStop
#   example    ? StzWsLoopbackEcho(47321)
#              #--> 47321
#              StzWsLoopbackEchoStop()
func StzWsLoopbackEcho(nPort)
	if $nStzWsEchoPort > 0
		return $nStzWsEchoPort
	ok
	_nPort_ = StzEngineWsEchoStart(nPort, 0, "", "")
	if _nPort_ > 0
		$nStzWsEchoPort = _nPort_
	ok
	return _nPort_

# Stops the loopback echo server started by StzWsLoopbackEcho; with none running it does nothing.
#
#   returns    nothing
#   see        StzWsLoopbackEcho
func StzWsLoopbackEchoStop()
	if $nStzWsEchoPort > 0
		StzEngineWsEchoStop()
		$nStzWsEchoPort = 0
	ok

# Holds a WebSocket client that opens a ws or wss session, sends text or bytes, reads messages and closes.
#
# Every call is synchronous and none raises on a legal call: a failure sets LastError and the
# error code and runs the function stored by OnError. Connect opens the socket, runs the RFC 6455
# handshake and refuses a wrong status, Upgrade, Connection or Sec-WebSocket-Accept by name.
# Receive waits up to the Timeout for the next message and reads one; a ping from the server is
# answered on the way without a word, and a frame that breaks the protocol closes the session with
# the matching close code, which CloseCode reports. Payloads are byte-exact across the boundary,
# a NUL or an 0xFF byte included. The documentation ran against the engine's loopback echo
# server in the same process, never against another machine.
#
#   receiver   o1 = new stzWebSocket()
#              StzWsLoopbackEcho(47321)
#   example    ? o1.IsOpen()
#              #--> 0
#              o1.Connect("ws://127.0.0.1:47321/chat")
#              ? o1.IsOpen()
#              #--> 1
#              o1.SendText("hello")
#              o1.Receive()
#              ? o1.LastMessage()
#              #--> hello
#              ? o1.MessageType()
#              #--> TEXT
#              o1.Close()
#              ? o1.CloseCode()
#              #--> 1000
#              StzWsLoopbackEchoStop()
#   see        stzTcpClient, stzNetwork
class stzWebSocket from stzNetwork
	@hWs = ""                  # engine client handle, made on the first Connect
	@is_connected = 0
	@last_message = ""
	@message_type = ""
	@has_message = 0
	@on_message_callback = ""
	@on_open_callback = ""
	@on_close_callback = ""
	@on_error_callback = ""
	@close_code = 0
	@close_reason = ""
	@closed_by_peer = 0
	@max_message_size = 16777216
	@connect_timeout_ms = 5000
	@subprotocols = ""
	@extra_headers = ""
	@ca_file = ""
	@insecure = 0
	@close_wait_ms = 2000
	@subprotocol_agreed = ""   # kept when the engine handle is freed at the end of a session
	@pings_seen = 0
	@pongs_made = 0
	@handshake_done = 0

	# Builds a client that is not open, with the default limits and no callbacks.
	#
	#   returns    nothing; the object is built
	#   see        Connect
	def init()

	# Opens a ws or wss session: the socket, the TLS handshake for wss, then the RFC 6455 handshake.
	#
	#   cUrl       the address, such as ws://localhost:8080/chat or wss://host/socket
	#   returns    the client itself, so calls chain
	#   note       on success IsOpen is TRUE and the function stored by OnOpen runs; on a failure
	#              IsOpen stays FALSE, LastError names the cause, the error code is -1 and the
	#              function stored by OnError runs once
	#   warning    a text that is not a ws or wss address sets LastError to Bad WebSocket scheme
	#              followed by the scheme found, or none; a refused handshake sets a message that
	#              starts with handshake: and names the header or status at fault; a refusal does
	#              not raise, but a cUrl that is not a text does
	#   see        IsOpen, Close, OnError, SetConnectTimeout
	#   example    o1.Connect("http://localhost/chat")
	#              ? o1.IsOpen()
	#              #--> 0
	#              ? o1.LastError()
	#              #--> Bad WebSocket scheme: http (use ws:// or wss://)
	def Connect(cUrl)
		if NOT isString(cUrl)
			StzRaise("Incorrect param type! cUrl must be a string (a url is text).")
		ok
		if @is_connected
			This.Close()
		ok
		This._EnsureHandle()
		StzEngineWsSetMaxMessage(@hWs, @max_message_size)
		StzEngineWsSetConnectTimeout(@hWs, @connect_timeout_ms)
		StzEngineWsSetSubprotocols(@hWs, @subprotocols)
		StzEngineWsSetHeaders(@hWs, @extra_headers)
		StzEngineWsSetCaFile(@hWs, @ca_file)
		StzEngineWsSetInsecure(@hWs, @insecure)
		StzEngineWsSetCloseWait(@hWs, @close_wait_ms)
		@close_code = 0
		@close_reason = ""
		@closed_by_peer = 0
		@has_message = 0
		@subprotocol_agreed = ""
		@pings_seen = 0
		@pongs_made = 0
		@handshake_done = 0
		if StzEngineWsConnect(@hWs, cUrl) = 1
			@is_connected = 1
			ClearErrors()
			This._Run(@on_open_callback)
		else
			@is_connected = 0
			_cWhy_ = StzEngineWsLastError(@hWs)
			This._Release()
			This._Fail(_cWhy_, -1)
		ok
		return This

	# Sends a message on the open session: a text as a text frame, a list of bytes as a binary frame.
	#
	#   pMessage   a text, or a list of numbers from 0 to 255
	#   returns    the client itself, so calls chain
	#   warning    without an open session it sets LastError to Not connected and sends nothing
	#   see        SendText, SendBinary
	def Send(pMessage)
		if isList(pMessage)
			return This.SendBinary(pMessage)
		ok
		return This.SendText(pMessage)

	# Sends a text frame, masked by the engine, on the open session.
	#
	#   cText      the text to send; it must be UTF-8
	#   returns    the client itself, so calls chain
	#   warning    without an open session it sets LastError to Not connected; a text that is not
	#              UTF-8 is refused with LastError saying so and nothing is sent
	#   see        Send, SendBinary, Receive
	#   example    o1.Connect("ws://127.0.0.1:47321/chat")
	#              o1.SendText("salut")
	#              ? o1.Receive().LastMessage()
	#              #--> salut
	#              o1.Close()
	def SendText(cText)
		if NOT isString(cText)
			StzRaise("Incorrect param type! cText must be a string.")
		ok
		if not @is_connected
			@last_error = "Not connected"
			return This
		ok
		if StzEngineWsSend(@hWs, 1, cText) = 1
			ClearErrors()
		else
			This._Fail(StzEngineWsLastError(@hWs), -1)
		ok
		return This

	# Sends a binary frame on the open session, from a byte string or a list of byte values.
	#
	#   pData      a text whose bytes are the payload, or a list of numbers from 0 to 255
	#   returns    the client itself, so calls chain
	#   note       a list is turned into bytes by the engine in one call; every byte value crosses
	#              intact, 0 and 255 included
	#   warning    without an open session it sets LastError to Not connected and sends nothing
	#   see        SendText, Receive, MessageType
	#   example    o1.Connect("ws://127.0.0.1:47321/chat")
	#              o1.SendBinary([ 0, 255, 65 ])
	#              o1.Receive()
	#              ? o1.MessageType()
	#              #--> BINARY
	#              ? len(o1.LastMessage())
	#              #--> 3
	#              o1.Close()
	def SendBinary(pData)
		if not @is_connected
			@last_error = "Not connected"
			return This
		ok
		_cBytes_ = pData
		if isList(pData)
			_cBytes_ = StzEngineWsBytesFromList(pData)
		but NOT isString(pData)
			StzRaise("Incorrect param type! pData must be a string of bytes or a list of numbers.")
		ok
		if StzEngineWsSend(@hWs, 2, _cBytes_) = 1
			ClearErrors()
		else
			This._Fail(StzEngineWsLastError(@hWs), -1)
		ok
		return This

	# Sends a ping frame with a short payload; the server's pong is read by the next Receive.
	#
	#   cData      the payload, at most 125 bytes
	#   returns    the client itself, so calls chain
	#   warning    without an open session it sets LastError to Not connected; a payload over 125
	#              bytes is refused with LastError saying so
	#   see        Receive, MessageType, PingsReceived
	#   example    o1.Connect("ws://127.0.0.1:47321/chat")
	#              o1.SendPing("are you there")
	#              o1.Receive()
	#              ? o1.MessageType()
	#              #--> PONG
	#              o1.Close()
	def SendPing(cData)
		if not @is_connected
			@last_error = "Not connected"
			return This
		ok
		if StzEngineWsPing(@hWs, cData) = 1
			ClearErrors()
		else
			This._Fail(StzEngineWsLastError(@hWs), -1)
		ok
		return This

	# Waits up to the Timeout, in seconds, for the next message and reads it into LastMessage.
	#
	#   returns    the client itself, so calls chain
	#   note       it forwards to ReceiveWithTimeout with Timeout times 1000 milliseconds
	#   see        ReceiveWithTimeout, LastMessage, MessageType, HasMessage
	def Receive()
		return This.ReceiveWithTimeout(This.Timeout() * 1000)

	# Waits up to that many milliseconds for the next message and reads it into LastMessage.
	#
	#   nMs        the longest wait in milliseconds; 0 looks once and returns at once
	#   returns    the client itself, so calls chain
	#   note       with nothing to read HasMessage is FALSE, MessageType is empty and no error is
	#              set; a text or binary message runs the function stored by OnMessage; a pong
	#              gives MessageType PONG; a close from the server gives MessageType CLOSE, closes
	#              the session, fills CloseCode and CloseReason and runs the function stored by
	#              OnClose
	#   warning    without an open session it sets LastError to Not connected; a frame that breaks
	#              the protocol closes the session, sets LastError to a message starting with
	#              protocol: and the error code to the close code sent (1002, 1007 or 1009), and
	#              runs the functions stored by OnError and then OnClose
	#   see        Receive, LastMessage, MessageType, CloseCode
	#   example    o1.Connect("ws://127.0.0.1:47321/chat")
	#              o1.ReceiveWithTimeout(50)
	#              ? o1.HasMessage()
	#              #--> 0
	#              o1.Close()
	def ReceiveWithTimeout(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@has_message = 0
		@message_type = ""
		if not @is_connected
			@last_error = "Not connected"
			return This
		ok
		_nKind_ = StzEngineWsRecv(@hWs, nMs)
		if _nKind_ = 0
			ClearErrors()
		but _nKind_ = 1 or _nKind_ = 2
			@last_message = StzEngineWsLastPayload(@hWs)
			if _nKind_ = 1
				@message_type = "TEXT"
			else
				@message_type = "BINARY"
			ok
			@has_message = 1
			ClearErrors()
			This._Run(@on_message_callback)
		but _nKind_ = 3
			@last_message = StzEngineWsLastPayload(@hWs)
			@message_type = "PONG"
			ClearErrors()
		but _nKind_ = 4
			@message_type = "CLOSE"
			This._ReadCloseState()
			@is_connected = 0
			This._Release()
			ClearErrors()
			This._Run(@on_close_callback)
		else
			This._ReadCloseState()
			@is_connected = 0
			_cWhy_ = StzEngineWsLastError(@hWs)
			This._Release()
			This._Fail(_cWhy_, @close_code)
			This._Run(@on_close_callback)
		ok
		return This

	# Ends an open session with the normal close code 1000 and runs the function stored by OnClose.
	#
	#   returns    the client itself, so calls chain
	#   note       it forwards to CloseWith(1000, ""); safe to call any number of times and before
	#              Connect, where it does nothing
	#   see        CloseWith, IsOpen, OnClose
	def Close()
		return This.CloseWith(1000, "")

	# Ends an open session with a close code and a reason, waiting a bounded time for the server's answer.
	#
	#   nCode      the close code, 1000 for a normal close, 3000 to 4999 for an application's own
	#   cReason    a short UTF-8 text, at most 123 bytes
	#   returns    the client itself, so calls chain
	#   note       after it IsOpen is FALSE; CloseCode holds the code sent and ClosedByPeer is FALSE;
	#              the function stored by OnClose runs once, only for a session that was open
	#   warning    with nothing open it does nothing, raises nothing and leaves LastError alone
	#   see        Close, CloseCode, CloseReason, ClosedByPeer
	#   example    o1.Connect("ws://127.0.0.1:47321/chat")
	#              o1.CloseWith(4000, "done for today")
	#              ? o1.IsOpen()
	#              #--> 0
	#              ? o1.CloseCode()
	#              #--> 4000
	def CloseWith(nCode, cReason)
		if @is_connected
			StzEngineWsClose(@hWs, nCode, cReason)
			This._ReadCloseState()
			@is_connected = 0
			This._Release()
			This._Run(@on_close_callback)
		ok
		return This

	# TRUE if the session is open.
	#
	#   returns    TRUE or FALSE
	#   see        Connect, Close
	def IsOpen()
		return @is_connected

	# TRUE if the session is open; it is the same answer as IsOpen.
	#
	#   returns    TRUE or FALSE
	#   note       unlike the base class, it reports the socket, not whether a request has run
	#   see        IsOpen
	def IsConnected()
		return @is_connected

	# Stores the name of a function to run when Receive reads a text or binary message.
	#
	#   cCallback   the name of a function that takes no parameter
	#   returns     the client itself, so calls chain
	#   see         OnOpen, Receive
	def OnMessage(cCallback)
		@on_message_callback = cCallback
		return This

	# Stores the name of a function to run when Connect opens the session.
	#
	#   cCallback   the name of a function that takes no parameter
	#   returns     the client itself, so calls chain
	#   see         OnMessage, Connect
	def OnOpen(cCallback)
		@on_open_callback = cCallback
		return This

	# Stores the name of a function to run when an open session ends, by either side.
	#
	#   cCallback   the name of a function that takes no parameter
	#   returns     the client itself, so calls chain
	#   see         OnOpen, Close
	def OnClose(cCallback)
		@on_close_callback = cCallback
		return This

	# Stores the name of a function to run when Connect, a send or a Receive fails.
	#
	#   cCallback   the name of a function that takes no parameter
	#   returns     the client itself, so calls chain
	#   note        it runs after LastError is set, once per failure; a callback that is the
	#               empty text or not a text is skipped
	#   see         OnOpen, Connect, LastError
	def OnError(cCallback)
		@on_error_callback = cCallback
		return This

	# Returns the payload of the last message read: a text, or the bytes of a binary frame.
	#
	#   returns    a text; empty before a read
	#   note       a binary payload keeps every byte, so len gives its size in bytes
	#   see        Receive, MessageType
	def LastMessage()
		return @last_message

	# Returns the kind of the last Receive: TEXT, BINARY, PONG, CLOSE, or empty when nothing came.
	#
	#   returns    a text
	#   see        LastMessage, Receive
	def MessageType()
		return @message_type

	# TRUE if the last Receive read a text or a binary message.
	#
	#   returns    TRUE or FALSE
	#   see        Receive, MessageType
	def HasMessage()
		return @has_message

	# Returns the close code of the ended session: the server's, or the one sent by CloseWith.
	#
	#   returns    a number; 0 while no session has ended, 1005 when the server sent none
	#   note       after a protocol failure it is the code the client sent: 1002 for a bad frame,
	#              1007 for text that is not UTF-8, 1009 for a message over the limit, 1006 when
	#              the connection dropped without a close frame
	#   see        CloseReason, ClosedByPeer, CloseWith
	def CloseCode()
		return @close_code

	# Returns the reason text that came with the close frame, or the one sent by CloseWith.
	#
	#   returns    a text, empty when there was none
	#   see        CloseCode, CloseWith
	def CloseReason()
		return @close_reason

	# TRUE if the server started the close handshake of the ended session.
	#
	#   returns    TRUE or FALSE; FALSE when this client closed first or no session has ended
	#   see        CloseCode, Receive
	def ClosedByPeer()
		return @closed_by_peer

	# TRUE if the peer answered a close frame, so both sides took part in ending the session.
	#
	#   returns    TRUE or FALSE; FALSE while the session is open or when the connection simply dropped
	#   see        CloseCode, ClosedByPeer, CloseWith
	def CloseHandshakeDone()
		return @handshake_done

	# Returns the subprotocol the server picked from the ones offered, or empty when none was agreed.
	#
	#   returns    a text
	#   see        SetSubprotocols
	def Subprotocol()
		if @hWs = ""
			return @subprotocol_agreed
		ok
		return StzEngineWsSubprotocol(@hWs)

	# Sets the largest message, in bytes, that Receive accepts; a larger one closes the session with 1009.
	#
	#   nBytes     the limit in bytes; the default is 16777216, 16 MiB
	#   returns    the client itself, so calls chain
	#   note       it applies to the next Connect; a frame declaring a larger length is refused
	#              from its header, before any memory is set aside for it
	#   see        MaxMessageSize, Receive, CloseCode
	#   example    o1.SetMaxMessageSize(4096)
	#              ? o1.MaxMessageSize()
	#              #--> 4096
	def SetMaxMessageSize(nBytes)
		if NOT isNumber(nBytes)
			StzRaise("Incorrect param type! nBytes must be a number.")
		ok
		@max_message_size = nBytes
		return This

		def SetMaxMessageSizeQ(nBytes)
			return This.SetMaxMessageSize(nBytes)

	# Returns the largest message, in bytes, that Receive accepts.
	#
	#   returns    a number
	#   see        SetMaxMessageSize
	def MaxMessageSize()
		return @max_message_size

	# Sets how long a close waits, in milliseconds, for the other side's close frame before dropping the socket.
	#
	#   nMs        the wait in milliseconds; the default is 2000
	#   returns    the client itself, so calls chain
	#   note       it applies at once to an open session and to the next Connect; a program that is
	#              both ends of a session in one thread sets it short, since the other end cannot
	#              answer while this one waits
	#   see        CloseWith, CloseTimeout
	#   example    o1.SetCloseTimeout(100)
	#              ? o1.CloseTimeout()
	#              #--> 100
	def SetCloseTimeout(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@close_wait_ms = nMs
		if @hWs != ""
			StzEngineWsSetCloseWait(@hWs, nMs)
		ok
		return This

		def SetCloseTimeoutQ(nMs)
			return This.SetCloseTimeout(nMs)

	# Returns how long a close waits for the other side's close frame, in milliseconds.
	#
	#   returns    a number
	#   see        SetCloseTimeout
	def CloseTimeout()
		return @close_wait_ms

	# Sets how long Connect waits, in milliseconds, for the socket, the TLS handshake and the server's answer.
	#
	#   nMs        the wait in milliseconds; the default is 5000
	#   returns    the client itself, so calls chain
	#   see        ConnectTimeout, Connect
	#   example    o1.SetConnectTimeout(2000)
	#              ? o1.ConnectTimeout()
	#              #--> 2000
	def SetConnectTimeout(nMs)
		if NOT isNumber(nMs)
			StzRaise("Incorrect param type! nMs must be a number.")
		ok
		@connect_timeout_ms = nMs
		return This

		def SetConnectTimeoutQ(nMs)
			return This.SetConnectTimeout(nMs)

	# Returns how long Connect waits, in milliseconds.
	#
	#   returns    a number
	#   see        SetConnectTimeout
	def ConnectTimeout()
		return @connect_timeout_ms

	# Sets the subprotocols offered at the next Connect, as a comma-separated text.
	#
	#   cList      the names, such as chat, superchat
	#   returns    the client itself, so calls chain
	#   note       a server answering with a name that was not offered is refused by name
	#   see        Subprotocol, Connect
	#   example    o1.SetSubprotocols("chat, superchat")
	#              ? o1.Subprotocols()
	#              #--> chat, superchat
	def SetSubprotocols(cList)
		if NOT isString(cList)
			StzRaise("Incorrect param type! cList must be a string.")
		ok
		@subprotocols = cList
		return This

		def SetSubprotocolsQ(cList)
			return This.SetSubprotocols(cList)

	# Returns the subprotocols offered at Connect, as given to SetSubprotocols.
	#
	#   returns    a text
	#   see        SetSubprotocols
	def Subprotocols()
		return @subprotocols

	# Adds a header sent with the handshake request of the next Connect.
	#
	#   cName      the header name, such as Authorization or Origin
	#   cValue     its value
	#   returns    the client itself, so calls chain
	#   see        Headers, Connect
	#   example    o1.AddHeader("Origin", "http://example.org")
	#              ? o1.Headers()
	#              #--> Origin: http://example.org
	def AddHeader(cName, cValue)
		if NOT (isString(cName) and isString(cValue))
			StzRaise("Incorrect param types! cName and cValue must be strings.")
		ok
		if @extra_headers != ""
			@extra_headers += char(10)
		ok
		@extra_headers += cName + ": " + cValue
		return This

		def AddHeaderQ(cName, cValue)
			return This.AddHeader(cName, cValue)

	# Returns the headers added for the handshake, one per line.
	#
	#   returns    a text, empty when none was added
	#   see        AddHeader
	def Headers()
		return @extra_headers

	# Sets the PEM file whose certificates are trusted for a wss session, in place of the system's store.
	#
	#   cPath      the path of a PEM file holding one or more certificates
	#   returns    the client itself, so calls chain
	#   note       the host name is still checked against the server's certificate
	#   see        CaFile, AllowInsecure
	#   example    o1.SetCaFile("ca.crt.pem")
	#              ? o1.CaFile()
	#              #--> ca.crt.pem
	def SetCaFile(cPath)
		if NOT isString(cPath)
			StzRaise("Incorrect param type! cPath must be a string.")
		ok
		@ca_file = cPath
		return This

		def SetCaFileQ(cPath)
			return This.SetCaFile(cPath)

	# Returns the PEM file trusted for wss, or empty when the system's store is used.
	#
	#   returns    a text
	#   see        SetCaFile
	def CaFile()
		return @ca_file

	# Turns certificate verification off for wss, which a caller must ask for by name.
	#
	#   returns    the client itself, so calls chain
	#   warning    with it on, any server can stand in for the one named; keep it to a test
	#   see        IsInsecure, SetCaFile
	#   example    ? o1.IsInsecure()
	#              #--> 0
	#              o1.AllowInsecure()
	#              ? o1.IsInsecure()
	#              #--> 1
	def AllowInsecure()
		@insecure = 1
		return This

		def AllowInsecureQ()
			return This.AllowInsecure()

	# TRUE if certificate verification is off for wss.
	#
	#   returns    TRUE or FALSE
	#   see        AllowInsecure
	def IsInsecure()
		return @insecure

	# Returns how many pings the server sent during the open or last session, each answered by a pong.
	#
	#   returns    a number
	#   see        PongsSent, SendPing
	def PingsReceived()
		if @hWs = ""
			return @pings_seen
		ok
		return StzEngineWsPingsReceived(@hWs)

	# Returns how many pongs the engine sent on the client's behalf during the open or last session.
	#
	#   returns    a number
	#   see        PingsReceived
	def PongsSent()
		if @hWs = ""
			return @pongs_made
		ok
		return StzEngineWsPongsSent(@hWs)

	# Returns the error code of the last failure: -1 for a refused Connect or send, a close code after a protocol failure.
	#
	#   returns    a number; 0 after ClearErrors or a success
	#   see        LastError, CloseCode
	def ErrorCode()
		return @error_code

	# Returns the engine's handle of this client, for a guard that drives the engine directly.
	#
	#   returns    a number; the empty text before the first Connect
	#   note       the handle belongs to the client, which frees it; never pass it to StzEngineWsFree
	#   status     internal
	#   see        Connect
	def EngineHandle()
		return @hWs

	def _EnsureHandle()
		if @hWs = ""
			@hWs = StzEngineWsNew()
		ok

	def _ReadCloseState()
		@close_code = StzEngineWsCloseCode(@hWs)
		@close_reason = StzEngineWsCloseReason(@hWs)
		@closed_by_peer = StzEngineWsCloseByPeer(@hWs)
		@handshake_done = StzEngineWsCloseHandshakeDone(@hWs)

	# Gives the engine handle back once a session has ended, keeping what the caller can still ask.
	def _Release()
		if @hWs != ""
			@subprotocol_agreed = StzEngineWsSubprotocol(@hWs)
			@pings_seen = StzEngineWsPingsReceived(@hWs)
			@pongs_made = StzEngineWsPongsSent(@hWs)
			StzEngineWsFree(@hWs)
			@hWs = ""
		ok

	# Takes over an open server-side connection handed out by the engine; the server class calls it.
	def _Adopt(hClient)
		@hWs = hClient
		@is_connected = 1
		@last_message = ""
		@message_type = ""
		@has_message = 0
		@close_code = 0
		@close_reason = ""
		@closed_by_peer = 0
		@handshake_done = 0
		ClearErrors()

	def _Fail(cMessage, nCode)
		@last_error = cMessage
		@error_code = nCode
		This._Run(@on_error_callback)

	def _Run(cCallback)
		if isString(cCallback) and cCallback != ""
			call cCallback()
		ok
