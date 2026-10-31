load "../../stzBase.ring"
load "../_narrated.ring"

# permessage-deflate (RFC 7692) in the WebSocket client and server: stzWebSocket.EnableCompression and
# stzWebSocketServer.EnableCompression over engine/src/ws_deflate.zig. Run from inside this folder:
#
#     rnxc stzWebSocketDeflate_narrated.ring            every scene
#     rnxc stzWebSocketDeflate_narrated.ring 4          one scene, as a probe
#
# LOOPBACK ONLY, one process playing both ends (the server accepts on a background thread while the client connects:
# BeginAccept / Connect / EndAccept). The compression is proved three ways, and the first two do not depend on the code
# under test to be right about itself:
#   - the WIRE, against bytes an independent zlib run produced (Python's, reproduced here as hex): the RFC 7692 section
#     7.2.3 example "Hello" is f2 48 cd c9 c9 07 00, a hundred letters a are 4a 4c a4 3d 00 00, and a hand-written
#     client sends those through a raw socket while the server's reply is read back as raw bytes;
#   - the STRICTNESS: every frame the extension forbids or cannot decode closes the session with a NAMED error and the
#     close code the RFC asks for, and a decompression bomb is refused at the limit, not after it is built;
#   - the SIZES: what a large message costs on the wire is read back from both ends and must be the same number.
# Each scene prints its wall time. ASCII only on the console.

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
$nWsI = 0
$nWsN = 0
$nWsK = 0
$nWsErr = 0
$cWsBig = ""
$cWsText = ""
$cWsAnswer = ""
$cWsRaw = ""
$hRaw = ""
$aWsCases = []
$nWsEcho = 0

# ---------------------------------------------------------------------------------------------------------------
if WsScene("1. the extension is negotiated only when both sides agree, and a refusal never breaks the session")
	WsPair(0, 0, 0)
	Then("neither side asked: not compressed", $oC.IsCompressed() + $oN.IsCompressed(), 0)
	Then("NEGATIVE: and the session works", WsRoundTrip("plain"), 1)
	WsPair(1, 0, 0)
	Then("the client asked, the server did not: not compressed", $oC.IsCompressed() + $oN.IsCompressed(), 0)
	Then("NEGATIVE: and the session works all the same", WsRoundTrip("client only"), 1)
	WsPair(0, 1, 0)
	Then("the server would, the client did not ask: not compressed", $oC.IsCompressed() + $oN.IsCompressed(), 0)
	WsPair(1, 1, 0)
	Then("both agreed: the client is compressed", $oC.IsCompressed(), 1)
	Then("...and so is the server's connection", $oN.IsCompressed(), 1)
	Then("...and a message still round-trips", WsRoundTrip("both agreed"), 1)
	WsPair(2, 1, 0)
	Then("a lean client (no context takeover) is accepted too", $oC.IsCompressed() + $oN.IsCompressed(), 2)

	When("the switches are read and turned off")
	$oX = new stzWebSocket
	Then("off by default", $oX.IsCompressionEnabled(), 0)
	Then("EnableCompressionQ chains", $oX.EnableCompressionQ().IsCompressionEnabled(), 1)
	Then("EnableLeanCompression is on too", $oX.DisableCompression().EnableLeanCompression().IsCompressionEnabled(), 1)
	Then("DisableCompression turns it off", $oX.DisableCompression().IsCompressionEnabled(), 0)
	$oS = new stzWebSocketServer
	Then("a server is off by default", $oS.IsCompressionEnabled(), 0)
	Then("EnableCompression turns it on", $oS.EnableCompression().IsCompressionEnabled(), 1)
	Then("DisableCompression turns it off", $oS.DisableCompression().IsCompressionEnabled(), 0)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("2. large messages cross the wire compressed, small ones and noise do not, and every byte comes back")
	WsPair(1, 1, 0)
	$cWsBig = copy("abcdefgh", 25000)
	Then("a 200000-letter text", len($cWsBig), 200000)
	$oC.SendText($cWsBig)
	$oN.ReceiveWithTimeout(5000)
	Then("the server read it whole", StzEngineWsBytesEqual($oN.LastMessage(), $cWsBig), 1)
	Then("...as TEXT", WsEq($oN.MessageType(), "TEXT"), 1)
	Then("200000 bytes cost under 2000 on the wire", $oC.LastSentWireSize() < 2000, 1)
	Then("the server read the same number of wire bytes the client wrote", $oN.LastReceivedWireSize(), $oC.LastSentWireSize())
	$oN.SendText($cWsBig)
	$oC.ReceiveWithTimeout(5000)
	Then("the reply comes back whole too", StzEngineWsBytesEqual($oC.LastMessage(), $cWsBig), 1)
	Then("...compressed the same way", $oC.LastReceivedWireSize(), $oN.LastSentWireSize())

	When("the payload is noise")
	$cWsText = StzEngineWsPattern(100000, 7)
	$oC.SendBinary($cWsText)
	$oN.ReceiveWithTimeout(5000)
	Then("it still arrives byte-exact", StzEngineWsBytesEqual($oN.LastMessage(), $cWsText), 1)
	Then("NEGATIVE: but it cannot shrink: at least 90 percent of it is still on the wire", $oC.LastSentWireSize() >= 90000, 1)

	When("the message is under 64 bytes")
	$oC.SendText("tiny")
	$oN.ReceiveWithTimeout(3000)
	Then("it arrives", WsEq($oN.LastMessage(), "tiny"), 1)
	Then("NEGATIVE: and it was sent as it is, 4 bytes", $oC.LastSentWireSize(), 4)

	When("the text is Hebrew, Arabic and an emoji, repeated to pass the threshold")
	$cWsText = copy("שלום" + " " + "مرحبا" + " " + char(240) + char(159) + char(152) + char(128) + " ", 30)
	$oC.SendText($cWsText)
	$oN.ReceiveWithTimeout(3000)
	Then("the server read it byte-exact", StzEngineWsBytesEqual($oN.LastMessage(), $cWsText), 1)
	Then("...from fewer wire bytes than the text has", $oC.LastSentWireSize() < len($cWsText), 1)

	When("the message goes out in three frames, compressed first")
	$cWsBig = copy("abcdefgh", 25000)
	StzEngineWsSendFragmented($oC.EngineHandle(), 2, $cWsBig, 3)
	$oN.ReceiveWithTimeout(5000)
	Then("the server reassembled and inflated one BINARY message", WsEq($oN.MessageType(), "BINARY"), 1)
	Then("...byte-exact", StzEngineWsBytesEqual($oN.LastMessage(), $cWsBig), 1)
	Then("...from the compressed total on the wire", $oN.LastReceivedWireSize() < 2000, 1)
	$oC.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("3. context takeover: the window carries between messages, and lean compression does not")
	$cWsText = copy("ZYXWVUTS", 40)
	WsPair(1, 1, 0)
	$oC.SendText($cWsText)
	$nWsK = $oC.LastSentWireSize()
	$oN.ReceiveWithTimeout(3000)
	$oC.SendText($cWsText)
	Then("with takeover the second copy is cheaper than the first", $oC.LastSentWireSize() < $nWsK, 1)
	$oN.ReceiveWithTimeout(3000)
	Then("...and still decodes to the text", StzEngineWsBytesEqual($oN.LastMessage(), $cWsText), 1)
	$oC.Close()
	WsPair(2, 1, 0)
	$oC.SendText($cWsText)
	$nWsK = $oC.LastSentWireSize()
	$oN.ReceiveWithTimeout(3000)
	$oC.SendText($cWsText)
	Then("NEGATIVE: lean, the second copy costs exactly what the first did", $oC.LastSentWireSize(), $nWsK)
	$oN.ReceiveWithTimeout(3000)
	Then("...and decodes just the same", StzEngineWsBytesEqual($oN.LastMessage(), $cWsText), 1)
	$oC.Close()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("4. the wire, against bytes an independent zlib produced: RFC 7692's Hello and a hundred letters a")
	$oS = new stzWebSocketServer
	$oS.EnableCompression().SetCloseTimeout(50).Listen(0, "127.0.0.1")
	$hRaw = WsRawHandshake($oS.Port(), 1)
	$oN = $oS.AcceptWithin(3000)
	$cWsAnswer = StzEngineTcpRecv($hRaw, 4096)
	Then("the server answered 101", WsEq(left($cWsAnswer, 12), "HTTP/1.1 101"), 1)
	Then("...agreeing to permessage-deflate", WsHas($cWsAnswer, "Sec-WebSocket-Extensions: permessage-deflate" + char(13) + char(10)), 1)
	Then("...with no parameter it was not asked for", WsHas($cWsAnswer, "no_context_takeover") + WsHas($cWsAnswer, "window_bits"), 0)
	Then("the connection says it is compressed", $oN.IsCompressed(), 1)
	StzEngineTcpSend($hRaw, WsBytes("c18737fa213dc5b2ecf4fefd21"))
	$oN.ReceiveWithTimeout(3000)
	Then("the RFC's compressed Hello (RSV1 set, masked) is read as Hello", WsEq($oN.LastMessage(), "Hello"), 1)
	Then("...as TEXT", WsEq($oN.MessageType(), "TEXT"), 1)
	Then("...from 7 bytes on the wire", $oN.LastReceivedWireSize(), 7)
	$oN.SendText(copy("a", 100))
	$cWsAnswer = StzEngineTcpRecv($hRaw, 64)
	Then("a hundred letters a leave as c1 06 4a 4c a4 3d 00 00 (RSV1, 6 bytes, not masked)", StzEngineWsBytesEqual($cWsAnswer, WsBytes("c1064a4ca43d0000")), 1)
	Then("NEGATIVE: those are not the plain frame", StzEngineWsBytesEqual($cWsAnswer, char(129) + char(100) + copy("a", 100)), 0)
	$oN.SendText("Hello")
	$cWsAnswer = StzEngineTcpRecv($hRaw, 64)
	Then("NEGATIVE: 5 letters leave plain, 81 05 Hello", StzEngineWsBytesEqual($cWsAnswer, char(129) + char(5) + "Hello"), 1)
	StzEngineTcpClose($hRaw)

	When("the same compressed frame reaches a server that did not agree")
	$oS.StopListening()
	$oS = new stzWebSocketServer
	$oS.SetCloseTimeout(50).Listen(0, "127.0.0.1")
	$hRaw = WsRawHandshake($oS.Port(), 1)
	$oN = $oS.AcceptWithin(3000)
	$cWsAnswer = StzEngineTcpRecv($hRaw, 4096)
	Then("NEGATIVE: the 101 names no extension", WsHas($cWsAnswer, "Sec-WebSocket-Extensions"), 0)
	StzEngineTcpSend($hRaw, WsBytes("c18737fa213dc5b2ecf4fefd21"))
	$oN.ReceiveWithTimeout(2000)
	Then("RSV1 without a negotiated extension is refused by name", WsEq($oN.LastError(), "protocol: reserved bits set"), 1)
	Then("...with 1002", $oN.CloseCode(), 1002)
	StzEngineTcpClose($hRaw)
	$oS.StopListening()
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("5. strictness: what the extension forbids or cannot decode closes the session with a named error")
	$aWsCases = [
		[ "RSV1 on a ping",                  "c98037fa213d",                          "protocol: reserved bits set",                                       1002 ],
		[ "RSV1 on a continuation frame",    "408037fa213d",                          "protocol: reserved bits set",                                       1002 ],
		[ "compressed data that is garbage", "c28837fa213dc805dec2c805dec2",          "protocol: bad compressed data (1007)",                              1007 ],
		[ "compressed text that is not UTF-8", "c18937fa213dcd05ced24820013d37",      "protocol: invalid UTF-8 in text (1007)",                            1007 ]
	]
	$nWsN = len($aWsCases)
	for $nWsI = 1 to $nWsN
		$oS = new stzWebSocketServer
		$oS.EnableCompression().SetCloseTimeout(50).Listen(0, "127.0.0.1")
		$hRaw = WsRawHandshake($oS.Port(), 1)
		$oN = $oS.AcceptWithin(3000)
		StzEngineTcpRecv($hRaw, 4096)
		$oN.OnError("WsCbErr")
		$nWsErr = 0
		StzEngineTcpSend($hRaw, WsBytes($aWsCases[$nWsI][2]))
		$oN.ReceiveWithTimeout(2000)
		Given($aWsCases[$nWsI][1])
		Then("  refused by name", WsEq($oN.LastError(), $aWsCases[$nWsI][3]), 1)
		Then("  with close code " + $aWsCases[$nWsI][4], $oN.CloseCode(), $aWsCases[$nWsI][4])
		Then("  OnError ran once", $nWsErr, 1)
		Then("  the session is closed", $oN.IsOpen(), 0)
		StzEngineTcpClose($hRaw)
		$oS.StopListening()
	next
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("6. a decompression bomb is refused at the limit: a few hundred bytes cannot make the server build gigabytes")
	WsPair(1, 1, 10000)
	$oC.SendBinary(copy(char(0), 1048576))
	Then("a megabyte of NUL costs the client under 10000 bytes on the wire", $oC.LastSentWireSize() < 10000, 1)
	$oN.OnError("WsCbErr")
	$nWsErr = 0
	$oN.ReceiveWithTimeout(3000)
	Then("the server refuses it after inflating, naming the limit", WsEq($oN.LastError(), "protocol: message over max 10000 bytes after decompression (1009)"), 1)
	Then("...with 1009", $oN.CloseCode(), 1009)
	Then("...OnError once", $nWsErr, 1)
	$oC.ReceiveWithTimeout(3000)
	Then("the client is told: CLOSE with 1009", $oC.CloseCode(), 1009)

	WsPair(1, 1, 10000)
	$oC.SendBinary(copy(char(0), 10000))
	$oN.ReceiveWithTimeout(3000)
	Then("NEGATIVE: exactly 10000 bytes inflate and pass", len($oN.LastMessage()), 10000)
	$oC.SendBinary(copy(char(0), 10001))
	$oN.ReceiveWithTimeout(3000)
	Then("...and 10001 do not", $oN.CloseCode(), 1009)
	WsEndScene()
ok

# ---------------------------------------------------------------------------------------------------------------
if WsScene("7. a client refuses an extension answer it did not ask for, by name")
	$nWsEcho = StzEngineWsEchoStart(0, 0, "", "")
	$aWsCases = [
		[ 9,  "handshake: server answered client_max_window_bits, which was not offered" ],
		[ 10, "handshake: extension refused: permessage-deflate; bogus" ],
		[ 11, "handshake: extension refused: x-other" ],
		[ 12, "handshake: extension refused: permessage-deflate; server_max_window_bits=7" ]
	]
	$nWsN = len($aWsCases)
	for $nWsI = 1 to $nWsN
		StzEngineWsEchoSetHandshakeMode($aWsCases[$nWsI][1])
		$oC = new stzWebSocket
		$oC.EnableCompression().OnError("WsCbErr")
		$nWsErr = 0
		$oC.Connect("ws://127.0.0.1:" + $nWsEcho + "/x")
		Given("handshake mode " + $aWsCases[$nWsI][1])
		Then("  nothing opened", $oC.IsOpen(), 0)
		Then("  refused by name", WsEq($oC.LastError(), $aWsCases[$nWsI][2]), 1)
		Then("  OnError ran once", $nWsErr, 1)
	next
	StzEngineWsEchoSetHandshakeMode(0)
	$oC = new stzWebSocket
	$oC.EnableCompression()
	$oC.Connect("ws://127.0.0.1:" + $nWsEcho + "/x")
	Then("NEGATIVE: a server that answers no extension is fine: open, not compressed", $oC.IsOpen() - $oC.IsCompressed(), 1)
	$oC.SetCloseTimeout(50).Close()
	StzEngineWsEchoStop()
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

# a listening server and a connected client, one thread playing both ends: the server waits on its background thread
# while the client connects, then EndAccept collects the connection. nClient: 0 plain, 1 compression, 2 lean
# compression. nServer: 0 plain, 1 compression. nMax: the server's message limit, 0 for the default.
func WsPair(nClient, nServer, nMax)
	if isObject($oS)  $oS.StopListening()  ok
	$oS = new stzWebSocketServer
	if nServer = 1  $oS.EnableCompression()  ok
	if nMax > 0  $oS.SetMaxMessageSize(nMax)  ok
	$oS.SetCloseTimeout(50).Listen(0, "127.0.0.1")
	$oC = new stzWebSocket
	if nClient = 1  $oC.EnableCompression()  ok
	if nClient = 2  $oC.EnableLeanCompression()  ok
	$oC.SetCloseTimeout(50)
	$oS.BeginAccept(5000)
	$oC.Connect("ws://127.0.0.1:" + $oS.Port() + "/z")
	$oN = $oS.EndAccept()

func WsRoundTrip(cText)
	$oC.SendText(cText)
	$oN.ReceiveWithTimeout(3000)
	if NOT StzEngineWsBytesEqual($oN.LastMessage(), cText)  return 0  ok
	$oN.SendText(cText)
	$oC.ReceiveWithTimeout(3000)
	return StzEngineWsBytesEqual($oC.LastMessage(), cText)

func WsRawHandshake(nPort, bExt)
	h = StzEngineTcpConnect("127.0.0.1", nPort)
	cCrlf = char(13) + char(10)
	cReq = "GET /raw HTTP/1.1" + cCrlf + "Upgrade: websocket" + cCrlf + "Connection: Upgrade" + cCrlf + "Sec-WebSocket-Version: 13" + cCrlf + "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + cCrlf
	if bExt  cReq += "Sec-WebSocket-Extensions: permessage-deflate" + cCrlf  ok
	StzEngineTcpSend(h, cReq + cCrlf)
	return h

# the bytes a hex text spells; test data, so a loop is fine here
func WsBytes(cHex)
	cOut = ""
	nLen = len(cHex)
	for i = 1 to nLen step 2
		cOut += char(StzHex2Dec(cHex[i] + cHex[i + 1]))
	next
	return cOut

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
