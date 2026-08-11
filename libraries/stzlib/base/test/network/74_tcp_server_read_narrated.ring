# THE SERVER CAN HEAR -- a regression guard for tcp_recv on accepted sockets.
#
# WHY THIS GUARD EXISTS, and why nothing caught the bug for so long:
#
# stz_tcp's tcp_recv used Zig's Stream.read. On Windows that goes through
# ReadFile, and ReadFile does NOT work on a socket returned by accept() -- it
# fails with the unmapped error "Unexpected". WRITING was fine. So the symptom
# was a server that could answer but never hear: every Send worked, every
# server-side Receive returned "recv failed: Unexpected".
#
# The whole TCP suite missed it because no test ever read from the SERVER side.
# The tests accept, send, close, and check error strings -- all of which pass
# with a completely deaf server. And engine/src/testserver.zig, the one std.net
# server in the tree that does read, always used std.posix.recv on the raw
# handle, so the HTTP-client suite exercised a different code path entirely.
#
# The fix is that same call in tcp.zig. This guard is the assertion that was
# missing: a server reads what a client sent, byte for byte.
#
# Found while building the sound plane's web studio, which needed a socket to
# read one HTTP request -- the first thing in this repo ever to ask stz_tcp's
# server side to listen.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "== stz_tcp: a server must be able to READ, not only write =="
? ""

# One process, no threads: listen first, connect second, accept third. connect()
# completes as soon as the SYN lands in the listen backlog, so it does not need
# the accept to have happened yet -- which is what makes this single-threaded.
oServer = new stzTcpServer()
oServer.Listen(8743, "127.0.0.1")
Chk("the server is listening", oServer.IsListening())

oClient = new stzTcpClient()
oClient.Connect("127.0.0.1", 8743)
Chk("a client connects", oClient.IsConnected())

cSent = "GET /hello?x=1 HTTP/1.1" + char(13) + char(10) + "Host: test" + char(13) + char(10) + char(13) + char(10)
oClient.Send(cSent)

oAccepted = oServer.AcceptOne()
Chk("the server accepts it", oAccepted != NULL)

# ---------------------------------------------------------------------------
? ""
? "-- the assertion the whole suite was missing --"

cGot = ""
for i = 1 to 40
	oAccepted.Receive()
	cChunk = oAccepted.ReceivedData()
	if len(cChunk) > 0
		cGot += cChunk
		exit
	ok
	sleep(0.02)
next

? "   server received " + len(cGot) + " bytes"
Chk("the server READ something at all", len(cGot) > 0)
Chk("and it is exactly what the client sent", cGot = cSent)
Chk("no error was recorded on the read", oAccepted.LastError() = "")

# ---------------------------------------------------------------------------
? ""
? "-- the negative sibling: writing was NEVER broken, so prove it separately --"
? "   If this guard only checked that the server works, a future regression"
? "   that broke WRITING would still look like the same failure."

cReply = "HTTP/1.1 200 OK" + char(13) + char(10) + "Content-Length: 2" + char(13) + char(10) + char(13) + char(10) + "ok"
oAccepted.Send(cReply)
cBack = ""
for i = 1 to 40
	oClient.Receive()
	cChunk = oClient.ReceivedData()
	if len(cChunk) > 0
		cBack += cChunk
		exit
	ok
	sleep(0.02)
next
Chk("the client reads the server's reply", len(cBack) > 0)
Chk("and the reply arrived intact", cBack = cReply)

oAccepted.Close()
oClient.Close()
oServer.Close()

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
