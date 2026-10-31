load "../../stzBase.ring"
load "../_narrated.ring"

# stzWebSocket (base/network/stzWebSocket.ring) -- the two register rows, Connect and Close. Run from inside this
# folder:
#     ring stzWebSocket_defects_narrated.ring
#
# The register said: Connect "raises error R3 today instead of opening a WebSocket connection" because it called
# curl_easy_init, a libcurl function the library no longer loads; and Close "does nothing today, because no
# connection can be open".
#
# THE QUESTION BEFORE THE FIX: can the class be repaired here? The engine has plain TCP (stzTcpClient) and an HTTPS
# client, but no WebSocket transport and no TLS socket. A WebSocket client is RFC 6455 framing over a socket, with
# TLS for wss: it belongs in the engine, which is the product, and an engine rebuild is not this batch. So the class
# is made HONEST and SAFE, and no transport is written in Ring.
#
# THE RULES the guard holds the class to, written before the code:
#   Connect(text)     never raises on a text, never opens anything, never touches the network. IsOpen stays 0.
#                     It returns the client, so calls chain. It replaces LastError and sets the error code (-1).
#     ws:// or wss:// followed by a host   LastError = "No WebSocket transport in this build: the engine has none
#                     yet, use stzTcpClient for a raw socket". The scheme is read without regard to case.
#     any other scheme, or none            LastError = "Bad WebSocket scheme: <scheme> (use ws:// or wss://)",
#                     the scheme in lower case, or the word none when the text has no ://
#     ws or wss and no host                LastError = "Bad WebSocket address: no host after <scheme>://"
#   Connect(not a text)   raises, saying cUrl must be a string (a url is text); the object is left as it was and
#                     the error callback is NOT run.
#   OnError callback  runs once per Connect of a text, AFTER LastError is set, with no argument. It does not run on
#                     a raise, on Send, SendText, SendBinary or Receive, or when none was set. A callback that is
#                     the empty text, or is not a text, is not called and raises nothing.
#   Send, SendText, SendBinary, Receive on a client that is not open   LastError = "Not connected", the client is
#                     returned, nothing else changes, no callback runs. (Unchanged.)
#   Close             idempotent, never raises, safe before any Connect, returns the client, leaves LastError alone.
#                     It runs the OnClose callback only for a client that WAS open; none can be open today, so a
#                     subclass that marks itself open stands in for the future engine transport and shows that the
#                     right behaviour is inherited.
#   No curl: no line of code in the class names a curl function or the undefined local _curl_handle_.
#   Two clients share nothing.
#
# Every positive carries a negative sibling. No call reaches the network. ASCII only on the console.

$cWsNoTransport = "No WebSocket transport in this build: the engine has none yet, use stzTcpClient for a raw socket"
$cWsSrc = "../../network/stzWebSocket.ring"
$oW = ""
$oF = ""
$oA = ""
$oB = ""
$nWsErr = 0
$nWsErrTwo = 0
$nWsErrA = 0
$nWsOpen = 0
$nWsClose = 0
$nWsMsg = 0
$cWsSeen = ""
$cWsOut = ""
$cWsRaised = ""

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. a fresh client: every public method answers, none raises, and the answers are the honest ones")
try
	Given("a client that was never asked anything")
	WsNew()
	Then("IsOpen is 0", $oW.IsOpen(), 0)
	Then("IsConnected (inherited from stzNetwork) is 0", $oW.IsConnected(), 0)
	Then("LastError is empty", WsEq($oW.LastError(), ""), 1)
	Then("HasError is 0", $oW.HasError(), 0)
	Then("LastMessage is empty", WsEq($oW.LastMessage(), ""), 1)
	Then("MessageType is empty", WsEq($oW.MessageType(), ""), 1)
	Then("Timeout (inherited) is the default 30", $oW.Timeout(), 30)

	When("each of Send, SendText, SendBinary and Receive is called on it")
	for $nWsI = 1 to 4
		WsNew()
		$cWsRaised = ""
		try
			if $nWsI = 1  $oW.Send("hi")  ok
			if $nWsI = 2  $oW.SendText("hi")  ok
			if $nWsI = 3  $oW.SendBinary([ 1, 2, 3 ])  ok
			if $nWsI = 4  $oW.Receive()  ok
		catch
			$cWsRaised = cCatchError
		done
		Then(WsNames()[$nWsI] + " raises nothing", WsEq($cWsRaised, ""), 1)
		Then(WsNames()[$nWsI] + " sets LastError to Not connected, exactly", WsEq($oW.LastError(), "Not connected"), 1)
		Then(WsNames()[$nWsI] + " leaves IsOpen at 0", $oW.IsOpen(), 0)
		Then("NEGATIVE: " + WsNames()[$nWsI] + " does not claim a missing transport (the client is simply not open)",
			WsHas($oW.LastError(), "transport"), 0)
		Then(WsNames()[$nWsI] + " leaves LastMessage empty", WsEq($oW.LastMessage(), ""), 1)
	next

	When("the calls are chained, Send then SendText then SendBinary then Receive")
	WsNew()
	Then("each returns the client, so the chain ends on it",
		$oW.Send("a").SendText("b").SendBinary([ 65 ]).Receive().LastError(), "Not connected")

	When("Close is called on a fresh client")
	WsNew()
	$cWsRaised = ""
	try
		$oW.Close()
	catch
		$cWsRaised = cCatchError
	done
	Then("Close raises nothing", WsEq($cWsRaised, ""), 1)
	Then("...leaves LastError empty (it reports nothing)", WsEq($oW.LastError(), ""), 1)
	Then("...and IsOpen is 0", $oW.IsOpen(), 0)
	Then("...and it returns the client", $oW.Close().IsOpen(), 0)

	When("the four callback setters and the two readers are called on a fresh client")
	WsNew()
	Then("OnMessage, OnOpen, OnClose and OnError all return the client",
		$oW.OnMessage("WsCbMsg").OnOpen("WsCbOpen").OnClose("WsCbClose").OnError("WsCbErr").IsOpen(), 0)
	Then("and storing a callback runs it never", $nWsErr + $nWsOpen + $nWsClose + $nWsMsg, 0)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. Connect on a good ws or wss address: no raise, nothing opened, a named reason")
try
	aGood = [ "ws://localhost:8080/chat", "wss://example.org/socket", "ws://127.0.0.1", "wss://host:443/a/b?x=1#f",
	          "WS://Upper.Example/x", "Wss://Mixed.Example" ]
	for $nWsI = 1 to len(aGood)
		WsNew()
		$cWsRaised = WsTryConnect(aGood[$nWsI])
		Given("the address " + aGood[$nWsI])
		Then("  Connect raises nothing", WsEq($cWsRaised, ""), 1)
		Then("  IsOpen stays 0", $oW.IsOpen(), 0)
		Then("  IsConnected (inherited) stays 0: no request was recorded", $oW.IsConnected(), 0)
		Then("  LastError is the no-transport message, exactly", WsEq($oW.LastError(), $cWsNoTransport), 1)
		Then("  HasError is 1", $oW.HasError(), 1)
		Then("  NEGATIVE: it is not a scheme complaint", WsHas($oW.LastError(), "Bad WebSocket"), 0)
	next

	When("the message is read for what it promises")
	Then("it says plainly that this build has no transport", WsHas($cWsNoTransport, "No WebSocket transport in this build"), 1)
	Then("it points at stzTcpClient for a raw socket", WsHas($cWsNoTransport, "stzTcpClient"), 1)

	When("Connect is chained")
	WsNew()
	Then("Connect returns the client, so IsOpen can follow it", $oW.Connect("ws://h/x").IsOpen(), 0)
	Then("...and so can Close", $oW.Connect("ws://h/x").Close().IsOpen(), 0)
	Then("NEGATIVE: a chained Connect of a bad address also returns the client", $oW.Connect("http://h").IsOpen(), 0)

	When("Connect is called twice with the same address")
	WsNew()
	$oW.Connect("ws://h/x")
	$oW.Connect("ws://h/x")
	Then("the second call changes nothing: the same exact message", WsEq($oW.LastError(), $cWsNoTransport), 1)
	Then("...and IsOpen is still 0", $oW.IsOpen(), 0)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. Connect on an address that is not a ws or wss address: the bad scheme is NAMED")
try
	aBad = [
		[ "http://example.org/x",   "Bad WebSocket scheme: http (use ws:// or wss://)" ],
		[ "https://example.org/x",  "Bad WebSocket scheme: https (use ws:// or wss://)" ],
		[ "ftp://example.org",      "Bad WebSocket scheme: ftp (use ws:// or wss://)" ],
		[ "HTTP://Example.org",     "Bad WebSocket scheme: http (use ws:// or wss://)" ],
		[ "wsx://example.org",      "Bad WebSocket scheme: wsx (use ws:// or wss://)" ],
		[ "w://example.org",        "Bad WebSocket scheme: w (use ws:// or wss://)" ],
		[ "example.org/chat",       "Bad WebSocket scheme: none (use ws:// or wss://)" ],
		[ "ws:/example.org",        "Bad WebSocket scheme: none (use ws:// or wss://)" ],
		[ "ws//example.org",        "Bad WebSocket scheme: none (use ws:// or wss://)" ],
		[ "",                       "Bad WebSocket scheme: none (use ws:// or wss://)" ],
		[ "42",                     "Bad WebSocket scheme: none (use ws:// or wss://)" ],
		[ "://example.org",         "Bad WebSocket scheme: none (use ws:// or wss://)" ]
	]
	for $nWsI = 1 to len(aBad)
		WsNew()
		$cWsRaised = WsTryConnect(aBad[$nWsI][1])
		Given("the address [" + aBad[$nWsI][1] + "]")
		Then("  Connect raises nothing", WsEq($cWsRaised, ""), 1)
		Then("  LastError names the scheme, exactly", WsEq($oW.LastError(), aBad[$nWsI][2]), 1)
		Then("  IsOpen stays 0", $oW.IsOpen(), 0)
		Then("  NEGATIVE: it never claims a transport message for a bad address", WsHas($oW.LastError(), "No WebSocket transport"), 0)
	next

	When("a ws or wss address has no host")
	aNoHost = [ [ "ws://", "ws" ], [ "wss://", "wss" ], [ "ws:///path", "ws" ], [ "wss://?q=1", "wss" ], [ "ws://#frag", "ws" ] ]
	for $nWsI = 1 to len(aNoHost)
		WsNew()
		$cWsRaised = WsTryConnect(aNoHost[$nWsI][1])
		Then("[" + aNoHost[$nWsI][1] + "] raises nothing", WsEq($cWsRaised, ""), 1)
		Then("[" + aNoHost[$nWsI][1] + "] says no host after the scheme, exactly",
			WsEq($oW.LastError(), "Bad WebSocket address: no host after " + aNoHost[$nWsI][2] + "://"), 1)
		Then("NEGATIVE: [" + aNoHost[$nWsI][1] + "] is not called a scheme problem", WsHas($oW.LastError(), "Bad WebSocket scheme"), 0)
	next

	When("a good address follows a bad one on the same client")
	WsNew()
	$oW.Connect("http://h")
	$oW.Connect("ws://h/x")
	Then("the latest answer replaces the earlier one", WsEq($oW.LastError(), $cWsNoTransport), 1)
	When("a bad address follows a good one")
	$oW.Connect("ftp://h")
	Then("...and the other way round", WsEq($oW.LastError(), "Bad WebSocket scheme: ftp (use ws:// or wss://)"), 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. Connect on something that is not a text: it raises, and leaves the client exactly as it was")
try
	aNot = [ [ "a number", 42 ], [ "a decimal", 1.5 ], [ "a list", [ "ws://h" ] ], [ "an empty list", [] ] ]
	for $nWsI = 1 to len(aNot)
		WsNew()
		$oW.OnError("WsCbErr")
		$oW.Connect("http://first")
		WsReset()
		$cWsBefore = $oW.LastError()
		$cWsRaised = WsTryConnect(aNot[$nWsI][2])
		Given("a client that already holds a bad-scheme error, asked to connect to " + aNot[$nWsI][1])
		Then("  it raises", WsEq($cWsRaised, ""), 0)
		Then("  the message says a url is text", WsHas($cWsRaised, "a url is text"), 1)
		Then("  the message names the parameter, cUrl", WsHas($cWsRaised, "cUrl"), 1)
		Then("  LastError is untouched", WsEq($oW.LastError(), $cWsBefore), 1)
		Then("  IsOpen is still 0", $oW.IsOpen(), 0)
		Then("  the error callback did NOT run on a raise", $nWsErr, 0)
	next
	When("the text is a digit string")
	WsNew()
	Then("NEGATIVE: the text 42 does not raise: it is a text, and a bad scheme", WsEq(WsTryConnect("42"), ""), 1)
	Then("NEGATIVE: and the number 42 does", WsEq(WsTryConnect(42), ""), 0)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. the callbacks: OnError runs once per Connect of a text, after LastError is set; the others never run")
try
	When("OnError is set and Connect is asked for a good address")
	WsNew()
	$oW.OnError("WsCbErr").OnOpen("WsCbOpen").OnClose("WsCbClose").OnMessage("WsCbMsg")
	WsReset()
	$oW.Connect("ws://h/x")
	Then("OnError ran exactly once", $nWsErr, 1)
	Then("...and LastError was already set when it ran (it read the no-transport message)", WsEq($cWsSeen, $cWsNoTransport), 1)
	Then("NEGATIVE: OnOpen did not run: nothing opened", $nWsOpen, 0)
	Then("NEGATIVE: OnClose did not run", $nWsClose, 0)
	Then("NEGATIVE: OnMessage did not run", $nWsMsg, 0)

	When("Connect is asked for a bad scheme")
	WsReset()
	$oW.Connect("http://h")
	Then("OnError ran once", $nWsErr, 1)
	Then("...having read the scheme message", WsEq($cWsSeen, "Bad WebSocket scheme: http (use ws:// or wss://)"), 1)

	When("Connect is asked for an address with no host")
	WsReset()
	$oW.Connect("wss://")
	Then("OnError ran once", $nWsErr, 1)
	Then("...having read the address message", WsEq($cWsSeen, "Bad WebSocket address: no host after wss://"), 1)

	When("Connect is asked for the empty text")
	WsReset()
	$oW.Connect("")
	Then("OnError ran once", $nWsErr, 1)

	When("Connect is called three times")
	WsReset()
	$oW.Connect("ws://h").Connect("ws://h").Connect("nope")
	Then("OnError ran three times, once per call", $nWsErr, 3)

	When("Send, SendText, SendBinary, Receive and Close are called on the same client")
	WsReset()
	$oW.Send("a").SendText("b").SendBinary([ 1 ]).Receive().Close()
	Then("NEGATIVE: OnError did not run for them: a not-connected answer is LastError only (unchanged)", $nWsErr, 0)
	Then("NEGATIVE: and no other callback ran", $nWsOpen + $nWsClose + $nWsMsg, 0)

	When("no OnError was set")
	WsNew()
	WsReset()
	$oW.Connect("ws://h")
	$oW.Connect("http://h")
	Then("NEGATIVE: no callback runs, and nothing raised", $nWsErr + $nWsOpen + $nWsClose + $nWsMsg, 0)
	Then("...yet LastError was set", $oW.HasError(), 1)

	When("OnError is the empty text")
	WsNew()
	$oW.OnError("")
	WsReset()
	$cWsRaised = WsTryConnect("ws://h")
	Then("the empty text is not called: nothing raised", WsEq($cWsRaised, ""), 1)
	Then("...and no callback ran", $nWsErr, 0)

	When("OnError was given something that is not a text (a number)")
	WsNew()
	$oW.OnError(5)
	$cWsRaised = WsTryConnect("ws://h")
	Then("it is not called: nothing raised", WsEq($cWsRaised, ""), 1)
	Then("...and LastError was still set", WsEq($oW.LastError(), $cWsNoTransport), 1)
	WsNew()
	$oW.OnError([ "WsCbErr" ])
	WsReset()
	$cWsRaised = WsTryConnect("ws://h")
	Then("a list is not called either: nothing raised", WsEq($cWsRaised, ""), 1)
	Then("NEGATIVE: and the named function did not run", $nWsErr, 0)

	When("OnError is replaced")
	WsNew()
	$oW.OnError("WsCbErr").OnError("WsCbErrTwo")
	WsReset()
	$oW.Connect("ws://h")
	Then("only the latest runs", $nWsErr, 0)
	Then("...the second one ran", $nWsErrTwo, 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. Close: idempotent, safe before any Connect, and OnClose runs only for a connection that was open")
try
	When("OnClose is set, and Close is called with nothing ever opened")
	WsNew()
	$oW.OnClose("WsCbClose")
	WsReset()
	$cWsRaised = WsTryClose()
	Then("Close raises nothing", WsEq($cWsRaised, ""), 1)
	Then("NEGATIVE: OnClose did NOT run: the client was never open", $nWsClose, 0)
	Then("IsOpen is 0", $oW.IsOpen(), 0)

	When("Close is called again, and again")
	$oW.Close()
	$oW.Close().Close()
	Then("it is idempotent: still no OnClose", $nWsClose, 0)
	Then("...and IsOpen is 0", $oW.IsOpen(), 0)

	When("Connect fails, then Close is called")
	WsNew()
	$oW.OnClose("WsCbClose")
	WsReset()
	$oW.Connect("ws://h/x")
	$oW.Close()
	Then("NEGATIVE: a failed Connect opened nothing, so Close does not run OnClose", $nWsClose, 0)
	Then("Close leaves the Connect error in LastError", WsEq($oW.LastError(), $cWsNoTransport), 1)
	Then("IsOpen is 0", $oW.IsOpen(), 0)

	When("Close is called on a client with no OnClose, and one whose OnClose is empty or not a text")
	WsNew()
	Then("no callback: Close returns the client", $oW.Close().IsOpen(), 0)
	$oW.OnClose("")
	Then("empty callback: Close raises nothing", WsEq(WsTryClose(), ""), 1)
	$oW.OnClose(7)
	Then("number callback: Close raises nothing", WsEq(WsTryClose(), ""), 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. what a future engine transport inherits: a client that IS open closes once and runs OnClose once")
try
	Given("a subclass that marks itself open, standing in for the engine transport (no network)")
	$oF = new stzWsFakeOpen
	Then("before MakeOpen it is not open", $oF.IsOpen(), 0)
	$oF.MakeOpen()
	Then("after MakeOpen it is open", $oF.IsOpen(), 1)
	$oPlain = new stzWebSocket
	Then("NEGATIVE: a plain client is not", $oPlain.IsOpen(), 0)

	When("OnClose is set and Close is called")
	$oF.OnClose("WsCbClose")
	WsReset()
	$cWsRaised = ""
	try
		$oF.Close()
	catch
		$cWsRaised = cCatchError
	done
	Then("Close raises nothing", WsEq($cWsRaised, ""), 1)
	Then("OnClose ran exactly once", $nWsClose, 1)
	Then("IsOpen is now 0", $oF.IsOpen(), 0)

	When("Close is called again")
	$oF.Close()
	$oF.Close()
	Then("idempotent: OnClose did not run a second time", $nWsClose, 1)

	When("an open client has no OnClose, or an empty one")
	$oF = new stzWsFakeOpen
	$oF.MakeOpen()
	Then("with none set, Close raises nothing and closes", WsEq(WsTryCloseF(), ""), 1)
	Then("...IsOpen is 0", $oF.IsOpen(), 0)
	$oF = new stzWsFakeOpen
	$oF.MakeOpen()
	$oF.OnClose("")
	WsReset()
	Then("with the empty text, Close raises nothing and closes", WsEq(WsTryCloseF(), ""), 1)
	Then("NEGATIVE: and the empty text is not called", $nWsClose, 0)
	Then("...IsOpen is 0", $oF.IsOpen(), 0)

	When("an open client is asked to send or receive (the engine transport owes these; none exists)")
	$oF = new stzWsFakeOpen
	$oF.MakeOpen()
	WsReset()
	$cWsRaised = ""
	try
		$oF.SendText("hi")
		$oF.SendBinary([ 1, 2 ])
		$oF.Receive()
	catch
		$cWsRaised = cCatchError
	done
	Then("none raises (no curl function is reached)", WsEq($cWsRaised, ""), 1)
	Then("LastError says there is no transport, not that the client is not connected", WsEq($oF.LastError(), "No WebSocket transport in this build"), 1)
	Then("NEGATIVE: it is not the not-connected answer", WsEq($oF.LastError(), "Not connected"), 0)
	Then("LastMessage stays empty", WsEq($oF.LastMessage(), ""), 1)
	Then("the client is still open: sending does not close it", $oF.IsOpen(), 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. two clients share nothing")
try
	$oA = new stzWebSocket
	$oB = new stzWebSocket
	$oA.OnError("WsCbErrA")
	WsReset()
	$oA.Connect("http://h")
	Then("A holds its own error", WsEq($oA.LastError(), "Bad WebSocket scheme: http (use ws:// or wss://)"), 1)
	Then("NEGATIVE: B holds none", WsEq($oB.LastError(), ""), 1)
	Then("A's callback ran for A", $nWsErrA, 1)
	$oB.Connect("ws://h")
	Then("NEGATIVE: B has no callback, so A's did not run for B", $nWsErrA, 1)
	Then("B holds the no-transport message", WsEq($oB.LastError(), $cWsNoTransport), 1)
	Then("NEGATIVE: and A's error is untouched by B", WsEq($oA.LastError(), "Bad WebSocket scheme: http (use ws:// or wss://)"), 1)
	$oB.Send("x")
	Then("B's Not connected does not reach A", WsEq($oA.LastError(), "Bad WebSocket scheme: http (use ws:// or wss://)"), 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. the class no longer calls curl, and no line of its code reaches the engine or the network")
try
	$cWsText = read($cWsSrc)
	Given("the class source, read as text (" + len($cWsText) + " bytes)")
	Then("it was read", len($cWsText) > 1000, 1)
	$aWsLines = str2list($cWsText)
	$nWsCurl = 0
	$nWsEngine = 0
	$nWsCode = 0
	for $nWsI = 1 to len($aWsLines)
		$cWsLine = trim($aWsLines[$nWsI])
		if $cWsLine = "" or left($cWsLine, 1) = "#"  loop  ok
		$nWsCode++
		$cWsLow = lower($cWsLine)
		# the parameter cUrl holds the letters curl, so the scan looks for the library's own spellings
		if substr($cWsLow, "curl_") > 0 or substr($cWsLow, "curlopt_") > 0 or substr($cWsLow, "curle_") > 0 or substr($cWsLow, "curlws_") > 0
			$nWsCurl++
		ok
		if substr($cWsLow, "stzengine") > 0  $nWsEngine++  ok
	next
	Then("there are lines of code to check", $nWsCode > 40, 1)
	Then("no line of code names a curl function or _curl_handle_", $nWsCurl, 0)
	Then("no line of code calls the engine (TCP, HTTP or otherwise): this build has no transport", $nWsEngine, 0)
	Then("NEGATIVE: the scan is not blind, the word curl is in the comments of this very file",
		substr(lower($cWsText), "libcurl") > 0, 1)
catch
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
done
EndScenario()

Summary()

# --- helpers, kept below the scenarios ----------------------------------------------------------------------------

func WsNames()
	return [ "Send", "SendText", "SendBinary", "Receive" ]

func WsNew()
	$oW = new stzWebSocket
	WsReset()

func WsReset()
	$nWsErr = 0
	$nWsErrTwo = 0
	$nWsErrA = 0
	$nWsOpen = 0
	$nWsClose = 0
	$nWsMsg = 0
	$cWsSeen = ""

func WsCbErr()
	$nWsErr++
	$cWsSeen = $oW.LastError()

func WsCbErrTwo()
	$nWsErrTwo++

func WsCbErrA()
	$nWsErrA++

func WsCbOpen()
	$nWsOpen++

func WsCbClose()
	$nWsClose++

func WsCbMsg()
	$nWsMsg++

func WsTryConnect(x)
	$cWsOut = ""
	try
		$oW.Connect(x)
	catch
		$cWsOut = cCatchError
	done
	return $cWsOut

func WsTryClose()
	$cWsOut = ""
	try
		$oW.Close()
	catch
		$cWsOut = cCatchError
	done
	return $cWsOut

func WsTryCloseF()
	$cWsOut = ""
	try
		$oF.Close()
	catch
		$cWsOut = cCatchError
	done
	return $cWsOut

# an EXACT, case-sensitive comparison: Ring's = on text ignores case, so a contract text is compared with strcmp
func WsEq(a, b)
	if isString(a) and isString(b)
		if strcmp(a, b) = 0  return 1  ok
		? "      (exact compare failed)  got [" + a + "]  wanted [" + b + "]"
		return 0
	ok
	return a = b

func WsHas(cHay, cNeedle)
	if StzFindFirst(cNeedle, cHay) > 0  return 1  ok
	return 0

# a client that marks itself open: stands in for the engine transport the class is a placeholder for
class stzWsFakeOpen from stzWebSocket

	def MakeOpen()
		@is_connected = 1
		return This
