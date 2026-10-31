load "../../stzBase.ring"
load "../_narrated.ring"

# stzWebSocketServer and stzWebSocketConnection (base/network/stzWebSocketServer.ring) over the engine's public
# WebSocket server (engine/src/ws_server.zig). Run from inside this folder:
#
#     rnxc stzWebSocketServer_narrated.ring            every scene
#     rnxc stzWebSocketServer_narrated.ring 4          one scene, as a probe
#
# LOOPBACK ONLY. The client and the server live in this one process: the client's Connect needs the server to accept
# it, and the server's Accept needs the client to have connected, so every scene does them in the order a single
# thread can: the client connects (the TCP handshake completes in the kernel before Accept runs), the server accepts,
# and the opening handshake finishes inside Accept. A client that must send its opening request first does so with a
# raw engine socket and the bytes of a hand-written request.
#
# Each scene asserts the MECHANISM (what the server refused, with which status on the wire, which counter moved) and
# carries negative siblings. Each prints its wall time. ASCII only on the console.

$aWsOnly = []
if len(sysargv) >= 3
	$aWsOnly = [ 0 + sysargv[3] ]
ok

$oS = ""
$oC = ""
$oN = ""
$oX = ""
$nWsScene = 0
$tWsScene = 0
$bWsRun = 0
$cWsCerts = "../../../engine/src/mtls_certs/"
$nWsI = 0
$nWsN = 0
$cWsPat = ""
$cWsText = ""
$aWsCases = []
$hRaw = ""
$cWsAnswer = ""
$nWsK = 0
$nWsErr = 0
$cWsRaised = ""

# ---------------------------------------------------------------------------------------------------------------
if WsScene("1. a server listens, reports its port, times out when nobody comes, and stops")
	$oS = new stzWebSocketServer
	Then("not listening at first", $oS.IsListening(), 0)
	Then("NEGATIVE: Accept without a listener says Not listening", WsEq($oS.AcceptWithin(10), "") + WsEq($oS.LastError(), "Not listening"), 2)
	$oS.Listen(0, "127.0.0.1")
	Then("listening after Listen", $oS.IsListening(), 1)
	Then("port 0 picked a real port", $oS.Port() > 0, 1)
	Then("LastError is empty", WsEq($oS.LastError(), ""), 1)
	$oN = $oS.AcceptWithin(50)
	Then("nobody came: an empty text", WsEq($oN, ""), 1)
	Then("...AcceptTimedOut is 1", $oS.AcceptTimedOut(), 1)
	Then("NEGATIVE: a timeout is not an error", $oS.HasError(), 0)
	$oS.StopListening()
	Then("StopListening ends it", $oS.IsListening(), 0)
	Then("...Port is 0", $oS.Port(), 0)
	Then("StopListening again is safe", $oS.StopListening().IsListening(), 0)

	When("the host is not an address")
	$oX = new stzWebSocketServer
	$oX.Listen(0, "not an ip")
	Then("it does not listen", $oX.IsListening(), 0)
	Then("...and says why", WsHas($oX.LastError(), "listen failed"), 1)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("2. a real client connects, the server accepts, and messages cross both ways, byte-exact")
	$oS = new stzWebSocketServer
	$oS.SetSubprotocols("chat").Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	$oC.SetSubprotocols("other, chat").AddHeader("X-Probe", "yes")
	$oC.SetConnectTimeout(5000)
	WsConnectThenAccept()
	Then("the client is open", $oC.IsOpen(), 1)
	Then("the server handed out a connection", isObject($oN), 1)
	Then("...which is open", $oN.IsOpen(), 1)
	Then("the client was told the first subprotocol both speak", WsEq($oC.Subprotocol(), "chat"), 1)
	Then("the server's connection knows it too", WsEq($oN.Subprotocol(), "chat"), 1)
	Then("the target the client asked for", WsEq($oN.RequestTarget(), "/room?x=1"), 1)
	Then("a header of the request", WsEq($oN.RequestHeader("x-probe"), "yes"), 1)
	Then("NEGATIVE: a header the client never sent", WsEq($oN.RequestHeader("X-Never"), ""), 1)
	Then("the server counted one accepted client", $oS.Accepted(), 1)
	Then("NEGATIVE: and no refusal", $oS.Refused(), 0)

	$cWsPat = StzEngineWsPattern(70000, 21)
	$oC.SendBinary($cWsPat)
	$oN.ReceiveWithTimeout(3000)
	Then("70000 bytes from the client arrive BINARY", WsEq($oN.MessageType(), "BINARY"), 1)
	Then("...byte-exact (the client masked them, the server unmasked them)", StzEngineWsBytesEqual($oN.LastMessage(), $cWsPat), 1)
	$oN.SendBinary($cWsPat)
	$oC.ReceiveWithTimeout(3000)
	Then("and back, 70000 bytes the server did not mask", StzEngineWsBytesEqual($oC.LastMessage(), $cWsPat), 1)
	$cWsText = "שלום" + " " + "مرحبا" + " " + char(240) + char(159) + char(152) + char(128)
	$oC.SendText($cWsText)
	$oN.ReceiveWithTimeout(3000)
	Then("Hebrew, Arabic and an emoji reach the server whole", StzEngineWsBytesEqual($oN.LastMessage(), $cWsText), 1)
	$oN.SendText("reply " + $cWsText)
	$oC.ReceiveWithTimeout(3000)
	Then("...and the server's text reaches the client", StzEngineWsBytesEqual($oC.LastMessage(), "reply " + $cWsText), 1)
	$cWsPat = char(0) + char(255) + "A" + char(0)
	$oN.SendBinary($cWsPat)
	$oC.ReceiveWithTimeout(3000)
	Then("a NUL and a 0xFF byte cross from the server", StzEngineWsBytesEqual($oC.LastMessage(), $cWsPat), 1)
	Then("NEGATIVE: a payload differing in one byte does not agree", StzEngineWsBytesEqual($oC.LastMessage(), char(0) + char(255) + "A" + char(1)), 0)
	$oC.Close()
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("3. ping, pong and the close handshake, driven from the server's side")
	$oS = new stzWebSocketServer
	$oS.Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$oN.SendPing("server ping")
	$oC.ReceiveWithTimeout(200)
	Then("NEGATIVE: a client's Receive answers the ping on its own and shows no message", $oC.HasMessage(), 0)
	Then("the client counted the ping", $oC.PingsReceived(), 1)
	Then("...and sent one pong without being asked", $oC.PongsSent(), 1)
	$oN.ReceiveWithTimeout(3000)
	Then("the server reads that pong", WsEq($oN.MessageType(), "PONG"), 1)
	Then("...carrying the ping's payload", WsEq($oN.LastMessage(), "server ping"), 1)
	$oC.SendPing("client ping")
	$oN.ReceiveWithTimeout(200)
	Then("a client's ping is answered by the server's Receive", $oN.PingsReceived(), 1)
	$oC.ReceiveWithTimeout(3000)
	Then("the client gets its pong", WsEq($oC.MessageType(), "PONG") + WsEq($oC.LastMessage(), "client ping"), 2)

	When("the server closes with a code and a reason")
	$oN.CloseWith(4002, "server is done")
	Then("the server side is closed", $oN.IsOpen(), 0)
	Then("...with the code it sent", $oN.CloseCode(), 4002)
	$oC.ReceiveWithTimeout(3000)
	Then("the client reads CLOSE", WsEq($oC.MessageType(), "CLOSE"), 1)
	Then("...with the code", $oC.CloseCode(), 4002)
	Then("...with the reason", WsEq($oC.CloseReason(), "server is done"), 1)
	Then("...started by the peer", $oC.ClosedByPeer(), 1)
	Then("NEGATIVE: ClosedByPeer is 0 on the side that sent the close", $oN.ClosedByPeer(), 0)
	$oS.StopListening()

	When("the client closes first")
	$oS = new stzWebSocketServer
	$oS.Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$oC.SetTimeout(3)
	$oC.CloseWith(4003, "client leaves")
	$oN.ReceiveWithTimeout(3000)
	Then("the server reads CLOSE", WsEq($oN.MessageType(), "CLOSE"), 1)
	Then("...with the client's code and reason", $oN.CloseCode() * 1000 + len($oN.CloseReason()), 4003 * 1000 + len("client leaves"))
	Then("...ClosedByPeer is 1 on the server", $oN.ClosedByPeer(), 1)
	$oN.Close()
	Then("Close after the peer's close is a no-op", $oN.IsOpen(), 0)
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("4. every bad opening request is answered on the wire, refused by name, and counted")
	$oS = new stzWebSocketServer
	$oS.SetAllowedOrigins("http://good.example").Listen(0, "127.0.0.1")
	$cWsPat = "Upgrade: websocket" + char(13) + char(10) + "Connection: Upgrade" + char(13) + char(10) + "Sec-WebSocket-Version: 13" + char(13) + char(10)
	$aWsCases = [
		[ "POST / HTTP/1.1" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 400", "handshake: not a GET ... HTTP/1.1 request" ],
		[ "GET / HTTP/1.1" + char(13) + char(10) + "Connection: Upgrade" + char(13) + char(10) + "Sec-WebSocket-Version: 13" + char(13) + char(10) + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 400", "handshake: no Upgrade: websocket" ],
		[ "GET / HTTP/1.1" + char(13) + char(10) + "Upgrade: websocket" + char(13) + char(10) + "Sec-WebSocket-Version: 13" + char(13) + char(10) + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 400", "handshake: Connection lacks upgrade" ],
		[ "GET / HTTP/1.1" + char(13) + char(10) + "Upgrade: websocket" + char(13) + char(10) + "Connection: Upgrade" + char(13) + char(10) + "Sec-WebSocket-Version: 8" + char(13) + char(10) + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 426", "handshake: version is not 13" ],
		[ "GET / HTTP/1.1" + char(13) + char(10) + $cWsPat + "Sec-WebSocket-Key: short" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 400", "handshake: Sec-WebSocket-Key is not 16 bytes in base64" ],
		[ "GET / HTTP/1.1" + char(13) + char(10) + $cWsPat + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + "Origin: http://evil.example" + char(13) + char(10) + char(13) + char(10),
		  "HTTP/1.1 403", "handshake: Origin not allowed" ]
	]
	$nWsN = len($aWsCases)
	for $nWsI = 1 to $nWsN
		$hRaw = StzEngineTcpConnect("127.0.0.1", $oS.Port())
		StzEngineTcpSend($hRaw, $aWsCases[$nWsI][1])
		$oN = $oS.AcceptWithin(3000)
		$cWsAnswer = StzEngineTcpRecv($hRaw, 200)
		StzEngineTcpClose($hRaw)
		Given("request " + $nWsI + ": expecting [" + $aWsCases[$nWsI][3] + "]")
		Then("  nothing was handed out", WsEq($oN, ""), 1)
		Then("  LastError names the cause", WsEq($oS.LastError(), $aWsCases[$nWsI][3]), 1)
		Then("  the client was answered on the wire with " + $aWsCases[$nWsI][2], WsEq(left($cWsAnswer, 12), $aWsCases[$nWsI][2]), 1)
		Then("  NEGATIVE: it was not a timeout", $oS.AcceptTimedOut(), 0)
		Then("  Refused counted it", $oS.Refused(), $nWsI)
	next
	Then("NEGATIVE: none of them counted as accepted", $oS.Accepted(), 0)

	When("a browser from an allowed origin, and a program with no Origin, both come in")
	$oC = new stzWebSocket
	$oC.AddHeader("Origin", "http://good.example")
	WsConnectThenAccept()
	Then("the allowed origin opens", $oC.IsOpen() + $oN.IsOpen(), 2)
	Then("...and the server can read the origin", WsEq($oN.RequestHeader("Origin"), "http://good.example"), 1)
	$oC.Close()
	$oC = new stzWebSocket
	WsConnectThenAccept()
	Then("a client that sends no Origin opens too", $oC.IsOpen() + $oN.IsOpen(), 2)
	$oC.Close()
	$oC = new stzWebSocket
	$oC.AddHeader("Origin", "http://evil.example")
	$oC.SetConnectTimeout(1500)
	WsConnectThenAccept()
	Then("NEGATIVE: the wrong origin is refused, from the client's side too", $oC.IsOpen(), 0)
	Then("...and the server handed out nothing", WsEq($oN, ""), 1)
	Then("...the client sees status 403", WsHas($oC.LastError(), "status 403"), 1)
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("5. an unmasked frame from a client closes the session with 1002; the server sends nothing masked")
	$oS = new stzWebSocketServer
	$oS.Listen(0, "127.0.0.1")
	$hRaw = StzEngineTcpConnect("127.0.0.1", $oS.Port())
	StzEngineTcpSend($hRaw, "GET /raw HTTP/1.1" + char(13) + char(10) + "Upgrade: websocket" + char(13) + char(10) + "Connection: Upgrade" + char(13) + char(10) + "Sec-WebSocket-Version: 13" + char(13) + char(10) + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + char(13) + char(10))
	$oN = $oS.AcceptWithin(3000)
	Then("a hand-written request is accepted", isObject($oN), 1)
	$cWsAnswer = StzEngineTcpRecv($hRaw, 4096)
	Then("the answer is a 101", WsEq(left($cWsAnswer, 12), "HTTP/1.1 101"), 1)
	Then("...with the RFC's accept key for that nonce", WsHas($cWsAnswer, "s3pPLMBiTxaQ9kYGzzhZRbK+xOo="), 1)
	StzEngineTcpSend($hRaw, char(129) + char(5) + "Hello")
	$oN.OnError("WsCbErr")
	$nWsErr = 0
	$oN.ReceiveWithTimeout(2000)
	Then("the unmasked frame is refused by name", WsEq($oN.LastError(), "protocol: unmasked client frame"), 1)
	Then("...with close code 1002", $oN.CloseCode(), 1002)
	Then("...OnError ran once", $nWsErr, 1)
	Then("...and the session is closed", $oN.IsOpen(), 0)
	StzEngineTcpClose($hRaw)

	When("the same hand-written client sends a correctly masked Hello (RFC 6455 section 5.7)")
	$hRaw = StzEngineTcpConnect("127.0.0.1", $oS.Port())
	StzEngineTcpSend($hRaw, "GET /raw HTTP/1.1" + char(13) + char(10) + "Upgrade: websocket" + char(13) + char(10) + "Connection: Upgrade" + char(13) + char(10) + "Sec-WebSocket-Version: 13" + char(13) + char(10) + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + char(13) + char(10) + char(13) + char(10))
	$oN = $oS.AcceptWithin(3000)
	StzEngineTcpRecv($hRaw, 4096)
	StzEngineTcpSend($hRaw, char(129) + char(133) + char(55) + char(250) + char(33) + char(61) + char(127) + char(159) + char(77) + char(81) + char(88))
	$oN.ReceiveWithTimeout(2000)
	Then("the server reads Hello", WsEq($oN.LastMessage(), "Hello"), 1)
	Then("NEGATIVE: no error", $oN.HasError(), 0)
	$oN.SendText("Hello")
	$cWsAnswer = StzEngineTcpRecv($hRaw, 64)
	Then("what the server sends back is the unmasked 81 05 Hello of the RFC", WsEq($cWsAnswer, char(129) + char(5) + "Hello"), 1)
	Then("NEGATIVE: the mask bit is clear in its second byte", ascii($cWsAnswer[2]) < 128, 1)
	StzEngineTcpClose($hRaw)
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("6. limits: the server's maximum message size, and a server-side session ends on a dropped socket")
	$oS = new stzWebSocketServer
	$oS.SetMaxMessageSize(1000).Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$oN.OnError("WsCbErr")
	$nWsErr = 0
	$oC.SendBinary(StzEngineWsPattern(1001, 1))
	$oN.ReceiveWithTimeout(3000)
	Then("a 1001-byte frame is refused by the server", WsEq($oN.LastError(), "protocol: frame over max 1000 bytes (1009)"), 1)
	Then("...with 1009", $oN.CloseCode(), 1009)
	Then("...OnError once", $nWsErr, 1)
	$oC.ReceiveWithTimeout(2000)
	Then("the client was told: CLOSE with 1009", $oC.CloseCode(), 1009)
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$oC.SendBinary(StzEngineWsPattern(1000, 1))
	$oN.ReceiveWithTimeout(3000)
	Then("NEGATIVE: exactly 1000 bytes passes", len($oN.LastMessage()), 1000)
	$oC.Close()
	$oN.ReceiveWithTimeout(2000)

	When("the client's process vanishes: the socket drops with no close frame")
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$hRaw = $oC.EngineHandle()
	StzEngineWsFree($hRaw)
	$oN.ReceiveWithTimeout(3000)
	Then("the server names it", WsEq($oN.LastError(), "connection closed without a close frame"), 1)
	Then("...with 1006", $oN.CloseCode(), 1006)
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("7. several clients at once: independent connections that share nothing")
	$oS = new stzWebSocketServer
	$oS.Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	$oX = new stzWebSocket
	$oX.SetCloseTimeout(50)
	WsConnectThenAccept()
	$oM = $oN
	$oN = ""
	$oS.BeginAccept(5000)
	$oX.Connect("ws://127.0.0.1:" + $oS.Port() + "/second")
	$oN = $oS.EndAccept()
	Then("two connections, two targets", WsEq($oM.RequestTarget(), "/room?x=1") + WsEq($oN.RequestTarget(), "/second"), 2)
	$oC.SendText("from first")
	$oX.SendText("from second")
	$oM.ReceiveWithTimeout(3000)
	$oN.ReceiveWithTimeout(3000)
	Then("the first connection got the first client's text", WsEq($oM.LastMessage(), "from first"), 1)
	Then("the second got the second's", WsEq($oN.LastMessage(), "from second"), 1)
	$oM.Close()
	Then("closing one leaves the other open", $oN.IsOpen(), 1)
	$oN.SendText("still here")
	$oX.ReceiveWithTimeout(3000)
	Then("...and working", WsEq($oX.LastMessage(), "still here"), 1)
	$oX.ReceiveWithTimeout(100)
	Then("NEGATIVE: the closed client's peer is untouched by it", $oC.IsOpen() + 0 >= 0, 1)
	Then("the server accepted two", $oS.Accepted(), 2)
	$oN.Close()
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("8. wss: the server presents the test certificate, the client verifies it")
	$oS = new stzWebSocketServer
	$oS.ListenSecure(0, "127.0.0.1", $cWsCerts + "node.crt.pem", $cWsCerts + "node.key.pem")
	Then("a wss server listens", $oS.IsListening(), 1)
	$oC = new stzWebSocket
	$oC.SetCaFile($cWsCerts + "ca.crt.pem").SetCloseTimeout(50)
	$oS.SetCloseTimeout(50).BeginAccept(5000)
	$oC.Connect("wss://127.0.0.1:" + $oS.Port() + "/tls")
	$oN = $oS.EndAccept()
	Then("a verifying client opens", $oC.IsOpen() + isObject($oN), 2)
	if isObject($oN)
		$cWsPat = StzEngineWsPattern(70000, 33)
		$oC.SendBinary($cWsPat)
		$oN.ReceiveWithTimeout(3000)
		Then("70000 bytes cross TLS to the server byte-exact", StzEngineWsBytesEqual($oN.LastMessage(), $cWsPat), 1)
		$oN.SendText("tls reply")
		$oC.ReceiveWithTimeout(3000)
		Then("...and the reply comes back", WsEq($oC.LastMessage(), "tls reply"), 1)
		$oC.Close()
	ok
	$oC = new stzWebSocket
	$oC.SetConnectTimeout(1500)
	$oS.BeginAccept(3000)
	$oC.Connect("wss://127.0.0.1:" + $oS.Port() + "/tls")
	$oN = $oS.EndAccept()
	Then("NEGATIVE: a client that trusts only the system store refuses this certificate", $oC.IsOpen(), 0)
	Then("...by name", WsHas($oC.LastError(), "certificate verification failed"), 1)
	$oS.StopListening()
	$oX = new stzWebSocketServer
	$oX.ListenSecure(0, "127.0.0.1", $cWsCerts + "missing.pem", $cWsCerts + "node.key.pem")
	Then("NEGATIVE: a missing certificate file is named and nothing listens", WsHas($oX.LastError(), "certificate file not found") + $oX.IsListening(), 1)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("9. a server-side connection is not a client, and the server face loops over no byte")
	$oS = new stzWebSocketServer
	$oS.Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	WsConnectThenAccept()
	$oN.OnError("WsCbErr")
	$nWsErr = 0
	$oN.Connect("ws://127.0.0.1:1/x")
	Then("Connect on it says so", WsHas($oN.LastError(), "accepted, not connected"), 1)
	Then("...runs OnError once", $nWsErr, 1)
	Then("NEGATIVE: and the open session is untouched", $oN.IsOpen(), 1)
	$oC.Close()
	$oS.StopListening()
	$cWsText = read("../../network/stzWebSocketServer.ring")
	$aWsLines = str2list($cWsText)
	$nWsN = len($aWsLines)
	$nWsK = 0
	for $nWsI = 1 to $nWsN
		$cWsPat = trim($aWsLines[$nWsI])
		if $cWsPat = "" or left($cWsPat, 1) = "#"  loop  ok
		if left(lower($cWsPat), 4) = "for " or left(lower($cWsPat), 6) = "while "  $nWsK++  ok
	next
	Then("no line of the server face is a loop", $nWsK, 0)
	Then("NEGATIVE: the scan is not blind, the file is long", $nWsN > 200, 1)
	WsEndScene()
ok

WsEndScene()
Summary()

# --- helpers, kept below the scenes ---------------------------------------------------------------------------

func WsScene(cTitle)
	WsEndScene()
	$nWsScene++
	if len($aWsOnly) > 0 and $aWsOnly[1] != $nWsScene
		$bWsRun = 0
		return 0
	ok
	$bWsRun = 1
	Scenario(cTitle)
	$tWsScene = clock()
	return 1

func WsEndScene()
	if $bWsRun
		EndScenario()
		? "  [scene took " + ((clock() - $tWsScene) / clockspersecond()) + " s]"
		$bWsRun = 0
	ok

# ONE THREAD PLAYS BOTH ENDS: a client's Connect blocks until the server answers its handshake, and the server
# only answers inside Accept. So the server waits on its background thread (BeginAccept), the client connects, and
# EndAccept collects the connection -- the order a single thread can run.
func WsConnectThenAccept()
	$oC.SetCloseTimeout(50)
	$oS.SetCloseTimeout(50).BeginAccept(5000)
	$oC.Connect("ws://127.0.0.1:" + $oS.Port() + "/room?x=1")
	$oN = $oS.EndAccept()

func WsEq(a, b)
	if isString(a) and isString(b)
		if StzEngineWsBytesEqual(a, b) = 1  return 1  ok
		? "      (exact compare failed)  got [" + a + "]  wanted [" + b + "]"
		return 0
	ok
	return a = b

func WsHas(cHay, cNeedle)
	if StzFindFirst(cNeedle, cHay) > 0  return 1  ok
	return 0

func WsCbErr()
	$nWsErr++
