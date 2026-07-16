load "../../stzBase.ring"
load "../_narrated.ring"

# R7 -- stzAppServer REBUILT on the reactor (the service host spine).
#
# The pre-engine skeleton is gone: Start() binds a real HTTP/1.1
# listener on stzReactor (vendored libuv, engine thread), ServeOne/
# RunFor drain framed-request EVENTS, handlers compose stzAppResponse,
# and the reactor writes the bytes back. One host, three topologies
# exercised here: WEB routes, the MBaaS floor over data/stzDatabase,
# and an IoT raw-stream listener feeding the same database.
#
# Offline by construction: a second stzReactor plays the HTTP client
# (submit is non-blocking -> serve -> await), so one process holds
# both ends with no deadlock and no public network.

$CRLF = char(13) + char(10)

oSrv = new stzAppServer()
oClient = new stzReactor()

Scenario("the host binds a real HTTP listener on the reactor")
	Given("a fresh stzAppServer and an ephemeral port request")
	When("Start(0) runs")
	oSrv.Start(0, "127.0.0.1")
	Then("the server reports running", oSrv.IsRunning(), TRUE)
	Then("a real bound port is known", oSrv.Port() > 0, TRUE)
EndScenario()

Scenario("a WEB route serves a request end-to-end")
	Given("a GET /greet route answering in plain text")
	oSrv.Get_("/greet", func oReq, oResp {
		oResp.Text("hello " + oReq.Query("name"))
	})
	When("a client sends GET /greet?name=softanza")
	cReq = "GET /greet?name=softanza HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	When("the host serves one event")
	bServed = oSrv.ServeOne(3000)
	Then("one request was handled", bServed, TRUE)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the client got a 200", StzFindFirst(cBody, "200 OK") > 0, TRUE)
	Then("with the query-driven body", StzFindFirst(cBody, "hello softanza") > 0, TRUE)
	Then("and a Content-Length header", StzFindFirst(cBody, "Content-Length:") > 0, TRUE)
EndScenario()

Scenario("a POST route sees the framed body")
	Given("a POST /echo route that returns the body it received")
	oSrv.Post("/echo", func oReq, oResp {
		oResp.Text("echo:" + oReq.Body())
	})
	cPayload = "ping-42"
	cReq = "POST /echo HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Content-Length: " + len(cPayload) + $CRLF +
	       "Connection: close" + $CRLF + $CRLF + cPayload
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the body made the round trip", StzFindFirst(cBody, "echo:ping-42") > 0, TRUE)
EndScenario()

Scenario("the built-in /health probe answers without any user route")
	cReq = "GET /health HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("health reports 200", StzFindFirst(cBody, "200 OK") > 0, TRUE)
	Then("as json with a status field", StzFindFirst(cBody, '"status":"healthy"') > 0, TRUE)
EndScenario()

Scenario("an unknown route is an honest 404")
	cReq = "GET /nowhere HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the client got a 404", StzFindFirst(cBody, "404 Not Found") > 0, TRUE)
EndScenario()

Scenario("MBaaS floor: an exposed table serves REST over sqlite")
	Given("an in-memory stzDatabase with a sensor table, exposed")
	$oDb = new stzDatabase(":memory:")
	$oDb.Exec("CREATE TABLE sensor(device TEXT, temp REAL)")
	oSrv.Expose($oDb, "sensor")

	When("a device POSTs a form-encoded reading to /api/sensor")
	cForm = "device=probe-1&temp=21.5"
	cReq = "POST /api/sensor HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Content-Length: " + len(cForm) + $CRLF +
	       "Connection: close" + $CRLF + $CRLF + cForm
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the insert is confirmed with 201", StzFindFirst(cBody, "201 Created") > 0, TRUE)
	Then("the row is really in sqlite", $oDb.Value("SELECT device FROM sensor"), "probe-1")

	When("a client GETs /api/sensor")
	cReq = "GET /api/sensor HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the rows come back as json", StzFindFirst(cBody, '"rows":[["probe-1","21.5"]]') > 0, TRUE)

	When("a client GETs /api/sensor/count")
	cReq = "GET /api/sensor/count HTTP/1.1" + $CRLF +
	       "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the count is numeric json", StzFindFirst(cBody, '"count":1') > 0, TRUE)
EndScenario()

Scenario("MBaaS full CRUD: read / update / delete ONE row by id")
	Given("an id-keyed 'item' table exposed for full REST")
	$oDb.Exec("CREATE TABLE item(id INTEGER PRIMARY KEY, name TEXT, qty INTEGER)")
	oSrv.Expose($oDb, "item")

	When("a client POSTs a new item")
	cForm = "name=widget&qty=5"
	cReq = "POST /api/item HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Content-Length: " + len(cForm) + $CRLF + "Connection: close" + $CRLF + $CRLF + cForm
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("it is created (201) and sqlite auto-assigned id=1",
		StzFindFirst(cBody, "201 Created") > 0 and $oDb.Value("SELECT id FROM item") = "1", TRUE)

	When("a client GETs /api/item/1 (read ONE by id)")
	cReq = "GET /api/item/1 HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("the single row comes back keyed as {row}",
		StzFindFirst(cBody, '"row":["1","widget","5"]') > 0, TRUE)

	When("a client PUTs an update to /api/item/1")
	cForm = "qty=9"
	cReq = "PUT /api/item/1 HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Content-Length: " + len(cForm) + $CRLF + "Connection: close" + $CRLF + $CRLF + cForm
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("one row was updated", StzFindFirst(cBody, '"updated":1') > 0, TRUE)
	Then("the change is really in sqlite", $oDb.Value("SELECT qty FROM item WHERE id=1"), "9")

	When("a client GETs a NON-existent id")
	cReq = "GET /api/item/999 HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("an honest 404 for a missing row", StzFindFirst(cBody, "404 Not Found") > 0, TRUE)

	When("a client DELETEs /api/item/1")
	cReq = "DELETE /api/item/1 HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	cBody = oClient.AwaitTcp(nJob, 5000)
	Then("one row was deleted", StzFindFirst(cBody, '"deleted":1') > 0, TRUE)
	Then("the row is gone from sqlite", ring_number($oDb.Value("SELECT COUNT(*) FROM item")), 0)
EndScenario()

Scenario("IoT floor: a raw listener feeds the same database")
	Given("a raw (non-HTTP) listener whose handler persists telemetry")
	nRawSid = oSrv.ListenRaw(0, func oHost, nSid, nConn, cData {
		nSep = StzFindFirst(cData, ":")
		cDev = StzLeft(cData, nSep - 1)
		cVal = StzMidToEnd(cData, nSep + 1)
		$oDb.Exec("INSERT INTO sensor (device, temp) VALUES ('" + cDev + "', '" + cVal + "')")
		oHost.RawWrite(nSid, nConn, "ok", TRUE)
	})
	Then("the raw listener bound its own port", oSrv.RawPort(nRawSid) > 0, TRUE)
	When("a device streams a raw reading (no HTTP anywhere)")
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.RawPort(nRawSid), "probe-2:19.0")
	oSrv.ServeOne(3000)
	cAck = oClient.AwaitTcp(nJob, 5000)
	Then("the device got the ack", cAck, "ok")
	Then("the telemetry row landed in sqlite",
		$oDb.Value("SELECT device FROM sensor WHERE temp='19.0'"), "probe-2")
EndScenario()

Scenario("lifecycle: the host stops cleanly")
	Given("the running server with two listeners")
	When("Stop() runs")
	oSrv.Stop()
	Then("the server reports stopped", oSrv.IsRunning(), FALSE)
	$oDb.Close()
	oClient.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
