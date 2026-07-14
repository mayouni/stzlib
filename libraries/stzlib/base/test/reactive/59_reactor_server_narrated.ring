load "../../stzBase.ring"
load "../_narrated.ring"

# R7 -- the reactor SERVER surface (engine slice of the delivery plane).
#
# reactor.zig grew server-side variants: a TCP LISTENER living on the
# libuv loop thread, per-connection READ STREAMS, and HTTP/1.1 request
# FRAMING engine-side. Ring stays synchronous: it drains EVENTS
# (accept / data / closed) and queues writes/closes -- no callback ever
# crosses into Ring, no libuv call ever happens off-loop.
#
# The suite is fully offline: the reactor's own async TCP CLIENT plays
# the peer, so one loop thread runs both ends while Ring alternates
# between the two roles (submit is non-blocking, so no deadlock).

oReactor = new stzReactor()

Scenario("an HTTP listener binds and reports its port")
	Given("a reactor with a loop running on its own thread")
	When("we listen in http mode on 127.0.0.1 with port 0 (ephemeral)")
	nSid = oReactor.ListenHttp("127.0.0.1", 0)
	Then("a server id is returned", nSid > 0, TRUE)
	nPort = oReactor.ServerPort(nSid)
	Then("the actual bound port is known", nPort > 0, TRUE)
EndScenario()

Scenario("a full HTTP request/response round-trip on the loopback")
	Given("the listener above, and the reactor's async tcp client as peer")
	cReq = "GET /hello HTTP/1.1" + char(13) + char(10) +
	       "Host: local" + char(13) + char(10) +
	       "Connection: close" + char(13) + char(10) + char(13) + char(10)
	When("the client submits a request (non-blocking)")
	nJob = oReactor.SubmitTcp("127.0.0.1", nPort, cReq)
	Then("a client job id is returned", nJob > 0, TRUE)

	When("Ring drains server events until the framed request arrives")
	bAccepted = FALSE
	cGot = ""
	nConn = 0
	for i = 1 to 300
		aEv = oReactor.ServerAwait(nSid, 20)
		if len(aEv) = 0
			loop
		ok
		if aEv[1] = :accept
			bAccepted = TRUE
		but aEv[1] = :data
			nConn = aEv[2]
			cGot = aEv[3]
			exit
		ok
	next
	Then("an accept event was seen first", bAccepted, TRUE)
	Then("one COMPLETE framed request arrived", StzFindFirst(cGot, "GET /hello"), 1)
	Then("framing kept the terminating blank line",
		StzFindFirst(cGot, char(13)+char(10)+char(13)+char(10)) > 0, TRUE)

	When("the server writes a response with close-after")
	cResp = "HTTP/1.1 200 OK" + char(13) + char(10) +
	        "Content-Length: 2" + char(13) + char(10) +
	        "Connection: close" + char(13) + char(10) + char(13) + char(10) + "hi"
	nW = oReactor.ServerWrite(nSid, nConn, cResp, TRUE)
	Then("the write is queued", nW, 0)

	When("the client awaits its response body")
	cBody = oReactor.AwaitTcp(nJob, 10000)
	Then("the client received the status line", StzFindFirst(cBody, "200 OK") > 0, TRUE)
	Then("and the body", StzFindFirst(cBody, "hi") > 0, TRUE)
EndScenario()

Scenario("keep-alive framing: two pipelined requests become two events")
	Given("the same http listener")
	cTwo = "GET /a HTTP/1.1" + char(13) + char(10) +
	       "Host: x" + char(13) + char(10) + char(13) + char(10) +
	       "GET /b HTTP/1.1" + char(13) + char(10) +
	       "Host: x" + char(13) + char(10) + char(13) + char(10)
	When("a client sends BOTH requests in one packet")
	nJob2 = oReactor.SubmitTcp("127.0.0.1", nPort, cTwo)
	aReqs = []
	nConn2 = 0
	for i = 1 to 300
		aEv = oReactor.ServerAwait(nSid, 20)
		if len(aEv) = 0
			loop
		ok
		if aEv[1] = :data
			nConn2 = aEv[2]
			aReqs + aEv[3]
			if len(aReqs) = 2 exit ok
		ok
	next
	Then("exactly two framed requests were emitted", len(aReqs), 2)
	Then("the first is /a", StzFindFirst(aReqs[1], "GET /a"), 1)
	Then("the second is /b", StzFindFirst(aReqs[2], "GET /b"), 1)
	# answer both on the same kept-alive connection, closing on the last
	cR1 = "HTTP/1.1 200 OK" + char(13) + char(10) +
	      "Content-Length: 1" + char(13) + char(10) + char(13) + char(10) + "a"
	cR2 = "HTTP/1.1 200 OK" + char(13) + char(10) +
	      "Content-Length: 1" + char(13) + char(10) +
	      "Connection: close" + char(13) + char(10) + char(13) + char(10) + "b"
	oReactor.ServerWrite(nSid, nConn2, cR1, FALSE)
	oReactor.ServerWrite(nSid, nConn2, cR2, TRUE)
	cBoth = oReactor.AwaitTcp(nJob2, 10000)
	Then("the client saw both responses on one connection",
		StzFindFirst(cBoth, "a") > 0 and StzFindFirst(cBoth, "b") > 0, TRUE)
EndScenario()

Scenario("a POST body is framed by Content-Length")
	Given("the same http listener")
	cPost = "POST /ingest HTTP/1.1" + char(13) + char(10) +
	        "Host: x" + char(13) + char(10) +
	        "Content-Length: 9" + char(13) + char(10) +
	        "Connection: close" + char(13) + char(10) + char(13) + char(10) +
	        "temp=21.5"
	nJob3 = oReactor.SubmitTcp("127.0.0.1", nPort, cPost)
	cGot3 = ""
	nConn3 = 0
	for i = 1 to 300
		aEv = oReactor.ServerAwait(nSid, 20)
		if len(aEv) = 0
			loop
		ok
		if aEv[1] = :data
			nConn3 = aEv[2]
			cGot3 = aEv[3]
			exit
		ok
	next
	Then("the event contains the FULL body", StzFindFirst(cGot3, "temp=21.5") > 0, TRUE)
	cOk = "HTTP/1.1 204 No Content" + char(13) + char(10) +
	      "Content-Length: 0" + char(13) + char(10) +
	      "Connection: close" + char(13) + char(10) + char(13) + char(10)
	oReactor.ServerWrite(nSid, nConn3, cOk, TRUE)
	oReactor.AwaitTcp(nJob3, 10000)
EndScenario()

Scenario("raw stream mode delivers bytes as they arrive (IoT floor)")
	Given("a second listener in RAW mode (no http framing)")
	nSid2 = oReactor.Listen("127.0.0.1", 0)
	Then("it binds", nSid2 > 0, TRUE)
	nPort2 = oReactor.ServerPort(nSid2)
	When("a device-style client writes a raw line")
	nJob4 = oReactor.SubmitTcp("127.0.0.1", nPort2, "sensor-7:21.5;")
	cChunk = ""
	nConn4 = 0
	for i = 1 to 300
		aEv = oReactor.ServerAwait(nSid2, 20)
		if len(aEv) = 0
			loop
		ok
		if aEv[1] = :data
			nConn4 = aEv[2]
			cChunk = aEv[3]
			exit
		ok
	next
	Then("the raw bytes arrive unframed", cChunk, "sensor-7:21.5;")
	When("the server acks and closes")
	oReactor.ServerWrite(nSid2, nConn4, "ack", TRUE)
	cAck = oReactor.AwaitTcp(nJob4, 10000)
	Then("the device got the ack", cAck, "ack")
	oReactor.ServerStop(nSid2)
EndScenario()

Scenario("lifecycle: stop tears the server down cleanly")
	Given("the http listener from the start of the suite")
	nStop = oReactor.ServerStop(nSid)
	Then("stop is accepted", nStop, 0)
	When("the reactor itself is destroyed with everything settled")
	oReactor.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
