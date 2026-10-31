load "../../stzBase.ring"
load "../_narrated.ring"

# stzWebSocket (base/network/stzWebSocket.ring) over the engine's WebSocket client (engine/src/ws.zig),
# proved against the engine's loopback echo server in this same process. Run from inside this folder:
#
#     rnxc stzWebSocket_narrated.ring            every scene
#     rnxc stzWebSocket_narrated.ring 7          one scene, as a probe
#
# LOOPBACK ONLY: no address but 127.0.0.1 is ever dialed. The wss scene uses the throwaway test
# certificates in engine/src/mtls_certs (a CA, and a node certificate for localhost / 127.0.0.1).
#
# Every scene asserts the MECHANISM, not only the outcome: a pong is counted by the server that
# received it, a refusal names the frame at fault and the close code the client sent, a payload is
# compared by length and every byte in the engine. Every positive carries a negative sibling. Each
# scene prints its wall time. ASCII only on the console.

$aWsOnly = []
if len(sysargv) >= 3
	$aWsOnly = [ 0 + sysargv[3] ]
ok

$oW = ""
$oB = ""
$nWsOpen = 0
$nWsClose = 0
$nWsMsg = 0
$nWsErr = 0
$cWsSeen = ""
$nWsScene = 0
$tWsScene = 0
$bWsRun = 0
$nWsPort = StzEngineWsEchoStart(0, 0, "", "")
$cWsUrl = "ws://127.0.0.1:" + $nWsPort + "/echo"
$cWsCerts = "../../../engine/src/mtls_certs/"
$aWsSizes = [ 0, 1, 125, 126, 65535, 65536 ]
$aWsRefusals = []
$aWsStrict = []
$nWsT0 = 0
$nWsN = 0
$nWsI = 0
$nWsK = 0
$cWsBig = ""
$cWsPat = ""
$cWsText = ""
$aWsLines = []
$nWsLoops = 0
$nWsEngine = 0
$nWsTlsPort = 0
$nWsElapsed = 0
$cWsRaised = ""
$hWsA = ""
$hWsB = ""

? "echo server on port " + $nWsPort

# ---------------------------------------------------------------------------------------------------------------
if WsScene("1. the handshake succeeds: the key is checked, the subprotocol agreed, the headers reach the server")
	WsNew()
	$oW.SetSubprotocols("chat, superchat").AddHeader("X-Softanza", "guard").OnOpen("WsCbOpen").OnError("WsCbErr")
	$oW.Connect($cWsUrl)
	Then("IsOpen is 1", $oW.IsOpen(), 1)
	Then("IsConnected agrees", $oW.IsConnected(), 1)
	Then("LastError is empty", WsEq($oW.LastError(), ""), 1)
	Then("OnOpen ran exactly once", $nWsOpen, 1)
	Then("NEGATIVE: OnError did not run", $nWsErr, 0)
	Then("the server picked the first subprotocol offered", WsEq($oW.Subprotocol(), "chat"), 1)
	Then("the echo server counted one connection", StzEngineWsEchoConnections(), 1)
	$oW.SendText("!headers")
	$oW.Receive()
	Then("the server shows the request head it received", $oW.HasMessage(), 1)
	Then("...with Sec-WebSocket-Protocol: chat, superchat in it", WsHas($oW.LastMessage(), "Sec-WebSocket-Protocol: chat, superchat"), 1)
	Then("...with the extra header", WsHas($oW.LastMessage(), "X-Softanza: guard"), 1)
	Then("...with Sec-WebSocket-Version: 13", WsHas($oW.LastMessage(), "Sec-WebSocket-Version: 13"), 1)
	Then("...and a 24-character key (16 random bytes in base64)", len(WsHeaderOf($oW.LastMessage(), "Sec-WebSocket-Key")), 24)
	Then("NEGATIVE: the request names no extension", WsHas($oW.LastMessage(), "Sec-WebSocket-Extensions"), 0)
	$oW.Close()
	Then("Close ends it", $oW.IsOpen(), 0)
	WsNew()
	$oW.Connect($cWsUrl)
	Then("with nothing offered, no subprotocol is agreed", WsEq($oW.Subprotocol(), ""), 1)
	$oW.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("2. every refusal of the handshake is NAMED, nothing opens, OnError runs once")
	$aWsRefusals = [
		[ 1, "handshake: status 403 not 101" ],
		[ 2, "handshake: Sec-WebSocket-Accept mismatch" ],
		[ 3, "handshake: no Upgrade header" ],
		[ 4, "handshake: no Connection header" ],
		[ 5, "handshake: Sec-WebSocket-Accept missing" ],
		[ 6, "handshake: subprotocol not offered: nope" ],
		[ 7, "handshake: extension not negotiated: permessage-deflate" ],
		[ 8, "handshake: Upgrade is not websocket" ]
	]
	$nWsN = len($aWsRefusals)
	for $nWsI = 1 to $nWsN
		StzEngineWsEchoSetHandshakeMode($aWsRefusals[$nWsI][1])
		WsNew()
		$oW.SetSubprotocols("chat").OnOpen("WsCbOpen").OnError("WsCbErr")
		$cWsRaised = WsTry("connect")
		Given("handshake mode " + $aWsRefusals[$nWsI][1])
		Then("  nothing raised", WsEq($cWsRaised, ""), 1)
		Then("  IsOpen stays 0", $oW.IsOpen(), 0)
		Then("  LastError is exactly [" + $aWsRefusals[$nWsI][2] + "]", WsEq($oW.LastError(), $aWsRefusals[$nWsI][2]), 1)
		Then("  the error code is -1", $oW.ErrorCode(), -1)
		Then("  OnError ran once", $nWsErr, 1)
		Then("  NEGATIVE: OnOpen did not run", $nWsOpen, 0)
		Then("  a send afterwards says Not connected", WsEq($oW.SendText("x").LastError(), "Not connected"), 1)
	next
	StzEngineWsEchoSetHandshakeMode(0)
	WsNew()
	$oW.OnError("WsCbErr")
	$oW.Connect($cWsUrl)
	Then("NEGATIVE: with the mode back to 0 the same client connects", $oW.IsOpen(), 1)
	Then("...and OnError did not run", $nWsErr, 0)
	$oW.Close()

	When("there is no listener on the port")
	WsNew()
	$oW.OnError("WsCbErr")
	$oW.Connect("ws://127.0.0.1:1/nothing")
	Then("IsOpen stays 0", $oW.IsOpen(), 0)
	Then("LastError names the refusal", WsEq($oW.LastError(), "connect failed: ConnectionRefused"), 1)
	Then("OnError ran once", $nWsErr, 1)

	When("the address is not a ws or wss address")
	WsNew()
	$oW.Connect("http://127.0.0.1/x")
	Then("the scheme is named", WsEq($oW.LastError(), "Bad WebSocket scheme: http (use ws:// or wss://)"), 1)
	$oW.Connect("127.0.0.1/x")
	Then("no scheme is none", WsEq($oW.LastError(), "Bad WebSocket scheme: none (use ws:// or wss://)"), 1)
	$oW.Connect("ws:///x")
	Then("no host is named", WsEq($oW.LastError(), "Bad WebSocket address: no host after ws://"), 1)
	$oW.Connect("ws://127.0.0.1:abc/x")
	Then("a port that is not a number is named", WsEq($oW.LastError(), "Bad WebSocket address: the port is not a number"), 1)
	Then("NEGATIVE: none of them opened anything", $oW.IsOpen(), 0)

	When("Connect is given something that is not a text")
	WsNew()
	$oW.OnError("WsCbErr")
	$cWsRaised = ""
	try
		$oW.Connect(42)
	catch
		$cWsRaised = cCatchError
	done
	Then("it raises, saying a url is text", WsHas($cWsRaised, "a url is text"), 1)
	Then("NEGATIVE: and OnError did not run on a raise", $nWsErr, 0)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("3. text and binary echo at 0, 1, 125, 126, 65535 and 65536 bytes, byte-exact, NUL and 0xFF included")
	WsNew()
	$oW.OnMessage("WsCbMsg").Connect($cWsUrl)
	$nWsN = len($aWsSizes)
	for $nWsI = 1 to $nWsN
		$nWsN = $aWsSizes[$nWsI]
		$cWsPat = StzEngineWsPattern($nWsN, $nWsI)
		Given("a binary payload of " + $nWsN + " bytes")
		Then("  it has that length", len($cWsPat), $nWsN)
		$oW.SendBinary($cWsPat)
		$oW.Receive()
		Then("  the echo is BINARY", WsEq($oW.MessageType(), "BINARY"), 1)
		Then("  of the same length", len($oW.LastMessage()), $nWsN)
		Then("  and every byte agrees (compared in the engine)", StzEngineWsBytesEqual($oW.LastMessage(), $cWsPat), 1)
		if $nWsN > 0
			$cWsText = StzEngineWsPattern($nWsN, $nWsI + 100)
			Then("  NEGATIVE: a different pattern of the same length does not agree", StzEngineWsBytesEqual($oW.LastMessage(), $cWsText), 0)
		ok
		$cWsText = copy("a", $nWsN)
		$oW.SendText($cWsText)
		$oW.Receive()
		Then("  a text of " + $nWsN + " letters comes back TEXT", WsEq($oW.MessageType(), "TEXT"), 1)
		Then("  of the same length", len($oW.LastMessage()), $nWsN)
		Then("  and equal", StzEngineWsBytesEqual($oW.LastMessage(), $cWsText), 1)
	next
	Then("OnMessage ran once per message, " + (2 * len($aWsSizes)) + " times", $nWsMsg, 2 * len($aWsSizes))
	Then("the engine sent one frame per message, plus none", StzEngineWsFramesSent(WsHandleOf($oW)), 2 * len($aWsSizes))

	When("a payload holds a NUL, a 0xFF and a 0xFE byte")
	$cWsPat = char(0) + char(255) + "A" + char(0) + char(254) + char(0)
	Then("the payload has 6 bytes", len($cWsPat), 6)
	$oW.SendBinary($cWsPat)
	$oW.Receive()
	Then("6 bytes come back", len($oW.LastMessage()), 6)
	Then("every byte agrees", StzEngineWsBytesEqual($oW.LastMessage(), $cWsPat), 1)
	Then("the first byte is NUL", ascii($oW.LastMessage()[1]), 0)
	Then("the second is 255", ascii($oW.LastMessage()[2]), 255)
	Then("NEGATIVE: a payload differing in the last byte only does not agree", StzEngineWsBytesEqual($oW.LastMessage(), char(0) + char(255) + "A" + char(0) + char(254) + char(1)), 0)

	When("SendBinary is given a list of byte values")
	$oW.SendBinary([ 0, 255, 65, 0, 254, 0 ])
	$oW.Receive()
	Then("the same 6 bytes come back", StzEngineWsBytesEqual($oW.LastMessage(), $cWsPat), 1)
	Then("...and Send of a list is a binary send", WsEq($oW.Send([ 1, 2 ]).Receive().MessageType(), "BINARY"), 1)

	When("the text is Hebrew, Arabic and an emoji")
	$cWsText = "שלום" + " " + "مرحبا" + " " + char(240) + char(159) + char(152) + char(128)
	$oW.SendText($cWsText)
	$oW.Receive()
	Then("the text comes back byte-exact", StzEngineWsBytesEqual($oW.LastMessage(), $cWsText), 1)
	Then("...as TEXT", WsEq($oW.MessageType(), "TEXT"), 1)
	Then("...and its byte length is the UTF-8 length, " + len($cWsText), len($oW.LastMessage()), len($cWsText))

	When("SendText is given bytes that are not UTF-8")
	$nWsK = StzEngineWsFramesSent(WsHandleOf($oW))
	$oW.SendText(char(255) + char(254))
	Then("it is refused by name", WsHas($oW.LastError(), "not valid UTF-8"), 1)
	Then("NEGATIVE: no frame was sent", StzEngineWsFramesSent(WsHandleOf($oW)), $nWsK)
	Then("...and the session is still open", $oW.IsOpen(), 1)
	Then("...while the same bytes go out as binary", StzEngineWsBytesEqual($oW.SendBinary(char(255) + char(254)).Receive().LastMessage(), char(255) + char(254)), 1)
	$oW.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("4. fragmentation both ways: the server reassembles the client's fragments, the client the server's")
	$hWsA = StzEngineWsNew()
	Then("a raw engine client connects", StzEngineWsConnect($hWsA, $cWsUrl), 1)
	$cWsText = copy("fragment ", 50)
	$nWsK = StzEngineWsEchoMessages()
	StzEngineWsSendFragmented($hWsA, 1, $cWsText, 7)
	Then("seven frames went out for one message", StzEngineWsFramesSent($hWsA), 7)
	Then("the server echoes one TEXT message", StzEngineWsRecv($hWsA, 3000), 1)
	Then("...equal to the whole text", StzEngineWsBytesEqual(StzEngineWsLastPayload($hWsA), $cWsText), 1)
	Then("the server counted one message, not seven", StzEngineWsEchoMessages() - $nWsK, 1)
	$cWsPat = StzEngineWsPattern(70000, 9)
	StzEngineWsSendFragmented($hWsA, 2, $cWsPat, 3)
	Then("70000 binary bytes in three fragments echo as one BINARY", StzEngineWsRecv($hWsA, 5000), 2)
	Then("...byte-exact", StzEngineWsBytesEqual(StzEngineWsLastPayload($hWsA), $cWsPat), 1)
	StzEngineWsSend($hWsA, 1, "!frag:4:abcdefghijklmnop")
	Then("the server's four fragments arrive as one TEXT", StzEngineWsRecv($hWsA, 3000), 1)
	Then("...reassembled in order", WsEq(StzEngineWsLastPayload($hWsA), "abcdefghijklmnop"), 1)
	StzEngineWsSend($hWsA, 1, "!fragbig:9000:3")
	Then("9000 bytes in three fragments arrive as one BINARY", StzEngineWsRecv($hWsA, 3000), 2)
	Then("...of 9000 bytes", len(StzEngineWsLastPayload($hWsA)), 9000)
	Then("NEGATIVE: a continuation with no message started is refused", WsRawRefused($hWsA, "!cont", "continuation without a start"), 1)
	Then("...with close code 1002", StzEngineWsCloseCode($hWsA), 1002)
	StzEngineWsFree($hWsA)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("5. ping and pong: the client's ping is answered, the server's ping is answered without a word")
	StzEngineWsEchoResetCounters()
	WsNew()
	$oW.Connect($cWsUrl)
	$oW.SendPing("are you there")
	$oW.Receive()
	Then("the pong surfaces as PONG", WsEq($oW.MessageType(), "PONG"), 1)
	Then("...carrying the ping's payload", WsEq($oW.LastMessage(), "are you there"), 1)
	Then("NEGATIVE: a pong is not a message", $oW.HasMessage(), 0)
	Then("the server counted one ping", StzEngineWsEchoPings(), 1)
	Then("before any server ping, the client counted none", $oW.PingsReceived(), 0)
	$oW.SendText("!ping:hey")
	$oW.Receive()
	Then("the text pinged arrives after the ping", WsEq($oW.LastMessage(), "pinged"), 1)
	Then("the client counted one ping", $oW.PingsReceived(), 1)
	Then("...and sent one pong on its own", $oW.PongsSent(), 1)
	Then("...which the server received (its counter)", StzEngineWsEchoPongs(), 1)
	$oW.SendPing(copy("p", 125))
	$oW.Receive()
	Then("a 125-byte ping is the longest allowed and is answered", len($oW.LastMessage()), 125)
	$oW.SendPing(copy("p", 126))
	Then("NEGATIVE: a 126-byte ping is refused by name", WsHas($oW.LastError(), "over 125 bytes"), 1)
	Then("...and the session stays open", $oW.IsOpen(), 1)
	$oW.SendText("!nopong")
	$oW.Receive()
	$oW.SendPing("lost")
	$oW.ReceiveWithTimeout(300)
	Then("NEGATIVE: with the server not answering, nothing comes within 300 ms", WsEq($oW.MessageType(), ""), 1)
	Then("...and that is not an error", $oW.HasError(), 0)
	Then("...the server still counted the ping", StzEngineWsEchoPings(), 3)
	$oW.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("6. the close handshake both ways: codes and reasons, OnClose exactly once, Close idempotent")
	WsNew()
	$oW.OnClose("WsCbClose").OnError("WsCbErr").Connect($cWsUrl)
	$oW.CloseWith(4000, "done for today")
	Then("IsOpen is 0", $oW.IsOpen(), 0)
	Then("CloseCode is the code sent, 4000", $oW.CloseCode(), 4000)
	Then("CloseReason is the reason sent", WsEq($oW.CloseReason(), "done for today"), 1)
	Then("ClosedByPeer is 0: this side closed first", $oW.ClosedByPeer(), 0)
	Then("the server answered the close (the handshake completed)", StzEngineWsCloseHandshakeDone(WsHandleOf($oW)), 1)
	Then("OnClose ran exactly once", $nWsClose, 1)
	$oW.Close()
	$oW.Close().CloseWith(1000, "")
	Then("Close again is idempotent: OnClose still once", $nWsClose, 1)
	Then("...and the code is unchanged", $oW.CloseCode(), 4000)
	Then("NEGATIVE: OnError never ran", $nWsErr, 0)
	Then("NEGATIVE: a send after Close says Not connected", WsEq($oW.SendText("x").LastError(), "Not connected"), 1)

	When("the server starts the close")
	WsNew()
	$oW.OnClose("WsCbClose").OnError("WsCbErr").Connect($cWsUrl)
	$oW.SendText("!close:4001:server says bye")
	$oW.Receive()
	Then("Receive reports CLOSE", WsEq($oW.MessageType(), "CLOSE"), 1)
	Then("CloseCode is the server's, 4001", $oW.CloseCode(), 4001)
	Then("CloseReason is the server's", WsEq($oW.CloseReason(), "server says bye"), 1)
	Then("ClosedByPeer is 1", $oW.ClosedByPeer(), 1)
	Then("IsOpen is 0", $oW.IsOpen(), 0)
	Then("OnClose ran once", $nWsClose, 1)
	Then("NEGATIVE: that is not an error", $oW.HasError(), 0)
	Then("NEGATIVE: OnError did not run", $nWsErr, 0)
	$oW.Close()
	Then("Close after the server's close changes nothing", $nWsClose, 1)

	When("the server drops the socket with no close frame")
	WsNew()
	$oW.OnClose("WsCbClose").OnError("WsCbErr").Connect($cWsUrl)
	$oW.SendText("!drop")
	$oW.Receive()
	Then("it is an error", $oW.HasError(), 1)
	Then("...named", WsEq($oW.LastError(), "connection closed without a close frame"), 1)
	Then("...with code 1006", $oW.CloseCode(), 1006)
	Then("...the error code carries it too", $oW.ErrorCode(), 1006)
	Then("OnError ran once", $nWsErr, 1)
	Then("...and OnClose ran once: the session ended", $nWsClose, 1)
	Then("IsOpen is 0", $oW.IsOpen(), 0)

	When("the server sends a close frame with a 1-byte body, then one with code 999")
	Then("a 1-byte body is refused with 1002", WsRefused("!close1", "protocol: close frame with a 1-byte body", 1002), 1)
	Then("code 999 is refused with 1002", WsRefused("!closebad", "protocol: bad close code 999", 1002), 1)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("7. strictness: every bad server frame closes the session with a NAMED error and the right code")
	$aWsStrict = [
		[ "!masked",       "protocol: masked server frame",              1002 ],
		[ "!rsv",          "protocol: reserved bits set",                1002 ],
		[ "!badop",        "protocol: bad opcode 3",                     1002 ],
		[ "!bigctrl",      "protocol: control frame over 125 bytes",     1002 ],
		[ "!fragctrl",     "protocol: fragmented control frame",         1002 ],
		[ "!cont",         "protocol: continuation without a start",     1002 ],
		[ "!badutf8",      "protocol: invalid UTF-8 in text (1007)",     1007 ],
		[ "!badutf8frag",  "protocol: invalid UTF-8 in text (1007)",     1007 ],
		[ "!garbage",      "protocol: reserved bits set",                1002 ],
		[ "!cut",          "connection closed mid-frame",                1006 ]
	]
	$nWsN = len($aWsStrict)
	for $nWsI = 1 to $nWsN
		Then("[" + $aWsStrict[$nWsI][1] + "] is refused as [" + $aWsStrict[$nWsI][2] + "] with " + $aWsStrict[$nWsI][3],
			WsRefused($aWsStrict[$nWsI][1], $aWsStrict[$nWsI][2], $aWsStrict[$nWsI][3]), 1)
	next
	Then("NEGATIVE: a good text frame right after is not refused", WsRefused("plain text", "", 0), 1)

	When("a frame declares 2^40 bytes")
	Then("it is refused from its header, with 1009", WsRefused("!huge", "protocol: frame over max 16777216 bytes (1009)", 1009), 1)

	When("the limit is set to 1000 bytes")
	WsNew()
	$oW.SetMaxMessageSize(1000).OnError("WsCbErr").OnClose("WsCbClose").Connect($cWsUrl)
	$oW.SendText("!big:5000")
	$oW.Receive()
	Then("a 5000-byte frame is refused", WsEq($oW.LastError(), "protocol: frame over max 1000 bytes (1009)"), 1)
	Then("...with close code 1009", $oW.CloseCode(), 1009)
	Then("OnError once, OnClose once", $nWsErr + $nWsClose, 2)
	WsNew()
	$oW.SetMaxMessageSize(1000).Connect($cWsUrl)
	$oW.SendText("!fragbig:3000:6")
	$oW.Receive()
	Then("3000 bytes in six fragments of 500 are refused as they add up", WsEq($oW.LastError(), "protocol: message over max 1000 bytes (1009)"), 1)
	Then("...with 1009", $oW.CloseCode(), 1009)
	WsNew()
	$oW.SetMaxMessageSize(2000).Connect($cWsUrl)
	$oW.SendText("!text:2000")
	$oW.Receive()
	Then("NEGATIVE: exactly the limit passes", len($oW.LastMessage()), 2000)
	$oW.SendText("!text:2001")
	$oW.Receive()
	Then("...and one more byte does not", $oW.CloseCode(), 1009)
	Then("the default limit is 16 MiB", (new stzWebSocket).MaxMessageSize(), 16777216)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("8. Receive with a timeout: nothing yet is not an error, and the wait is bounded")
	WsNew()
	$oW.OnError("WsCbErr").OnMessage("WsCbMsg").Connect($cWsUrl)
	$nWsT0 = clock()
	$oW.ReceiveWithTimeout(0)
	Then("a poll returns at once with nothing", $oW.HasMessage(), 0)
	Then("...MessageType empty", WsEq($oW.MessageType(), ""), 1)
	Then("...no error", $oW.HasError(), 0)
	$nWsT0 = clock()
	$oW.ReceiveWithTimeout(200)
	$nWsElapsed = (clock() - $nWsT0) * 1000 / clockspersecond()
	Then("a 200 ms wait returns with nothing", $oW.HasMessage(), 0)
	Then("...after at least 150 ms (" + $nWsElapsed + " ms)", $nWsElapsed >= 150, 1)
	Then("...and under 1500 ms", $nWsElapsed < 1500, 1)
	Then("NEGATIVE: OnMessage did not run", $nWsMsg, 0)
	Then("the session is still open", $oW.IsOpen(), 1)
	$oW.SendText("after the wait")
	$oW.ReceiveWithTimeout(3000)
	Then("a message sent afterwards arrives", WsEq($oW.LastMessage(), "after the wait"), 1)
	Then("the default Receive waits Timeout seconds, 30", $oW.Timeout(), 30)
	$oW.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("9. two clients share nothing, and callbacks run exactly once each")
	WsNew()
	$oB = new stzWebSocket
	$oW.OnMessage("WsCbMsg").OnClose("WsCbClose").Connect($cWsUrl)
	$oB.Connect($cWsUrl)
	Then("both are open", $oW.IsOpen() + $oB.IsOpen(), 2)
	$oW.SendText("from A")
	$oB.SendText("from B")
	$oB.Receive()
	$oW.Receive()
	Then("A got A's", WsEq($oW.LastMessage(), "from A"), 1)
	Then("B got B's", WsEq($oB.LastMessage(), "from B"), 1)
	Then("A's OnMessage ran once", $nWsMsg, 1)
	Then("NEGATIVE: B has no callback, so nothing ran for B", $nWsMsg, 1)
	$oW.Close()
	Then("closing A leaves B open", $oB.IsOpen(), 1)
	Then("A's OnClose ran once", $nWsClose, 1)
	$oB.SendText("still here")
	$oB.Receive()
	Then("B still echoes", WsEq($oB.LastMessage(), "still here"), 1)
	Then("NEGATIVE: A's LastMessage is untouched", WsEq($oW.LastMessage(), "from A"), 1)
	$oB.Close()
	Then("NEGATIVE: B closing did not run A's OnClose again", $nWsClose, 1)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("10. a client that is not open: every send and Receive says Not connected, nothing raises, Close is safe")
	WsNew()
	$oW.OnError("WsCbErr").OnClose("WsCbClose")
	Then("SendText", WsEq($oW.SendText("a").LastError(), "Not connected"), 1)
	Then("SendBinary", WsEq($oW.SendBinary([ 1 ]).LastError(), "Not connected"), 1)
	Then("SendPing", WsEq($oW.SendPing("a").LastError(), "Not connected"), 1)
	Then("Receive", WsEq($oW.Receive().LastError(), "Not connected"), 1)
	Then("Send of a text", WsEq($oW.Send("a").LastError(), "Not connected"), 1)
	Then("NEGATIVE: no callback ran", $nWsErr + $nWsClose, 0)
	Then("Close before any Connect does nothing and raises nothing", WsEq(WsTry("close"), ""), 1)
	Then("...OnClose did not run", $nWsClose, 0)
	Then("LastMessage is empty", WsEq($oW.LastMessage(), ""), 1)
	Then("MessageType is empty", WsEq($oW.MessageType(), ""), 1)
	Then("CloseCode is 0", $oW.CloseCode(), 0)
	Then("Subprotocol is empty", WsEq($oW.Subprotocol(), ""), 1)
	Then("PingsReceived is 0", $oW.PingsReceived(), 0)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("11. wss on the loopback: a verified TLS session with the test CA, refused without it")
	StzEngineWsEchoStop()
	$nWsTlsPort = StzEngineWsEchoStart(0, 1, $cWsCerts + "node.crt.pem", $cWsCerts + "node.key.pem")
	Then("the TLS echo server started (" + StzEngineWsEchoLastError() + ")", $nWsTlsPort > 0, 1)
	WsNew()
	$oW.OnError("WsCbErr").Connect("wss://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("NEGATIVE: with the system's trust store only, the test CA is not trusted", $oW.IsOpen(), 0)
	Then("...and the refusal is named", WsHas($oW.LastError(), "certificate verification failed"), 1)
	Then("...OnError ran once", $nWsErr, 1)
	WsNew()
	$oW.SetCaFile($cWsCerts + "ca.crt.pem").OnError("WsCbErr").Connect("wss://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("with the test CA the session opens", $oW.IsOpen(), 1)
	Then("...LastError is empty", WsEq($oW.LastError(), ""), 1)
	$cWsPat = StzEngineWsPattern(70000, 5)
	$oW.SendBinary($cWsPat)
	$oW.Receive()
	Then("70000 bytes echo byte-exact over TLS", StzEngineWsBytesEqual($oW.LastMessage(), $cWsPat), 1)
	$oW.SendText("שלום over tls")
	$oW.Receive()
	Then("text echoes over TLS", WsEq($oW.LastMessage(), "שלום over tls"), 1)
	$oW.SendPing("tls ping")
	$oW.Receive()
	Then("ping works over TLS", WsEq($oW.MessageType(), "PONG"), 1)
	$oW.CloseWith(1000, "bye tls")
	Then("the close handshake completes over TLS", StzEngineWsCloseHandshakeDone(WsHandleOf($oW)), 1)
	Then("...IsOpen is 0", $oW.IsOpen(), 0)
	WsNew()
	$oW.SetCaFile($cWsCerts + "ca.crt.pem").Connect("wss://localhost:" + $nWsTlsPort + "/tls")
	if $oW.IsOpen()
		Then("localhost, also in the certificate, opens too", $oW.IsOpen(), 1)
	else
		? "  (localhost did not resolve to 127.0.0.1 here: " + $oW.LastError() + " -- SKIPPED by name)"
	ok
	$oW.Close()
	WsNew()
	$oW.AllowInsecure().Connect("wss://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("with verification turned off by name, it opens without the CA", $oW.IsOpen(), 1)
	$oW.Close()
	WsNew()
	$oW.SetCaFile($cWsCerts + "server.crt.pem").OnError("WsCbErr").Connect("wss://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("NEGATIVE: a CA file that did not sign the server's certificate is refused", $oW.IsOpen(), 0)
	Then("...by name", WsHas($oW.LastError(), "certificate verification failed"), 1)
	WsNew()
	$oW.SetCaFile($cWsCerts + "missing.pem").Connect("wss://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("NEGATIVE: a CA file that does not exist is named", WsHas($oW.LastError(), "CA file unreadable"), 1)
	WsNew()
	$oW.Connect("ws://127.0.0.1:" + $nWsTlsPort + "/tls")
	Then("NEGATIVE: plain ws to the TLS port does not open", $oW.IsOpen(), 0)
	StzEngineWsEchoStop()
	$nWsPort = StzEngineWsEchoStart(0, 0, "", "")
	$cWsUrl = "ws://127.0.0.1:" + $nWsPort + "/echo"
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("12. throughput, as numbers: 1 KB echoes per second, and one 4 MiB message")
	WsNew()
	$oW.Connect($cWsUrl)
	$cWsPat = StzEngineWsPattern(1024, 11)
	$nWsN = 2000
	$nWsT0 = clock()
	for $nWsI = 1 to $nWsN
		$oW.SendBinary($cWsPat)
		$oW.Receive()
	next
	$nWsElapsed = (clock() - $nWsT0) / clockspersecond()
	? "  " + $nWsN + " echoes of 1 KB in " + $nWsElapsed + " s = " + floor($nWsN / $nWsElapsed) + " echoes/s"
	Then("every one came back (the last is byte-exact)", StzEngineWsBytesEqual($oW.LastMessage(), $cWsPat), 1)
	Then("the engine counted " + $nWsN + " frames", StzEngineWsFramesSent(WsHandleOf($oW)), $nWsN)
	$cWsBig = StzEngineWsPattern(4 * 1024 * 1024, 12)
	$nWsT0 = clock()
	$oW.SendBinary($cWsBig)
	$oW.Receive()
	$nWsElapsed = (clock() - $nWsT0) / clockspersecond()
	? "  one 4 MiB message echoed in " + $nWsElapsed + " s"
	Then("4 MiB came back", len($oW.LastMessage()), 4 * 1024 * 1024)
	Then("...byte-exact", StzEngineWsBytesEqual($oW.LastMessage(), $cWsBig), 1)
	Then("...in under 5 s", $nWsElapsed < 5, 1)
	$oW.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("13. the face is thin: it names the engine and loops over no payload byte")
	$cWsText = read("../../network/stzWebSocket.ring")
	$aWsLines = str2list($cWsText)
	$nWsLoops = 0
	$nWsEngine = 0
	$nWsN = len($aWsLines)
	for $nWsI = 1 to $nWsN
		$cWsPat = trim($aWsLines[$nWsI])
		if $cWsPat = "" or left($cWsPat, 1) = "#"  loop  ok
		if left(lower($cWsPat), 4) = "for " or left(lower($cWsPat), 6) = "while "  $nWsLoops++  ok
		if substr(lower($cWsPat), "stzenginews") > 0  $nWsEngine++  ok
	next
	Then("no line of code is a loop: no byte is walked in Ring", $nWsLoops, 0)
	Then("the code calls the engine on many lines", $nWsEngine > 15, 1)
	Then("NEGATIVE: the old placeholder message is gone", substr($cWsText, "No WebSocket transport"), 0)
	Then("NEGATIVE: no curl function is named", substr(lower($cWsText), "curl_"), 0)
	WsEndScene()
ok

WsEndScene()
StzEngineWsEchoStop()
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

func WsNew()
	$oW = new stzWebSocket
	WsReset()

func WsReset()
	$nWsOpen = 0
	$nWsClose = 0
	$nWsMsg = 0
	$nWsErr = 0
	$cWsSeen = ""

func WsCbOpen()
	$nWsOpen++

func WsCbClose()
	$nWsClose++

func WsCbMsg()
	$nWsMsg++

func WsCbErr()
	$nWsErr++
	$cWsSeen = $oW.LastError()

func WsTry(cWhat)
	cOut = ""
	try
		if cWhat = "connect"  $oW.Connect($cWsUrl)  ok
		if cWhat = "close"  $oW.Close()  ok
	catch
		cOut = cCatchError
	done
	return cOut

# a fresh client sends a command, and the answer must be a NAMED refusal with that close code;
# an empty name means the frame must be accepted as a plain echo
func WsRefused(cCommand, cName, nCode)
	WsNew()
	$oW.OnError("WsCbErr").OnClose("WsCbClose").Connect($cWsUrl)
	$oW.SendText(cCommand)
	$oW.Receive()
	if cName = ""
		if $oW.HasError() = 0 and $oW.IsOpen() = 1 and $oW.HasMessage() = 1 and $nWsErr = 0
			$oW.Close()
			return 1
		ok
		? "      (expected an echo, got error [" + $oW.LastError() + "] open=" + $oW.IsOpen() + ")"
		return 0
	ok
	if WsEq($oW.LastError(), cName) and $oW.CloseCode() = nCode and $oW.IsOpen() = 0 and $nWsErr = 1 and $nWsClose = 1 and $oW.ErrorCode() = nCode
		return 1
	ok
	? "      (got error [" + $oW.LastError() + "] code " + $oW.CloseCode() + " open=" + $oW.IsOpen() + " onerror=" + $nWsErr + " onclose=" + $nWsClose + ")"
	return 0

func WsRawRefused(h, cCommand, cName)
	StzEngineWsSend(h, 1, cCommand)
	if StzEngineWsRecv(h, 3000) != -1  return 0  ok
	return WsHas(StzEngineWsLastError(h), cName)

func WsHandleOf(o)
	return o.EngineHandle()

func WsHeaderOf(cHead, cName)
	aL = str2list(cHead)
	nL2 = len(aL)
	for i = 1 to nL2
		if left(lower(aL[i]), len(cName) + 1) = lower(cName) + ":"
			return trim(substr(aL[i], len(cName) + 2))
		ok
	next
	return ""

# an EXACT, case-sensitive comparison through the engine (Ring's = on text ignores case)
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
