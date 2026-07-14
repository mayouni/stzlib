load "../../stzBase.ring"
load "../_narrated.ring"

# R7 finish -- async HTTP/HTTPS on the reactor (the TLS slice). A full
# request runs on a libuv WORKER thread via curl (native Schannel TLS
# on Windows) and is drained through the job idiom -- so https:// is
# genuinely async, with no TLS state machine reimplemented on the loop.
# The reactive-HTTP surface no longer has to block on TLS.
#
# The local plumbing (offline) is asserted strictly by pumping a
# plaintext app server while the worker fetches. The live-HTTPS
# scenario really exercises TLS when the network is up, and degrades to
# a single "offline" pass otherwise (the reactor.zig LIVE-NETWORK
# convention).

$oRct = new stzReactor()

Scenario("submitting is non-blocking; the worker runs off the loop")
	Given("a request to a local plaintext server")
	$oSrv = new stzAppServer()
	$oSrv.Get_("/hi", func oReq, oResp { oResp.Text("local-ok") })
	$oSrv.Start(0, "127.0.0.1")
	cUrl = "http://127.0.0.1:" + $oSrv.Port() + "/hi"
	When("SubmitHttp is called")
	nJob = $oRct.SubmitHttp(0, cUrl, "")
	Then("a job id comes back immediately", nJob > 0, TRUE)
	Then("no status yet (worker still running or queued)",
		$oRct.HttpLastStatus() <= 0, TRUE)

	When("the app server is pumped while the worker fetches")
	# completion is detected via JobState (a non-draining peek) -- NOT the
	# HttpLastStatus global, which persists across jobs and would read
	# stale in a later scenario.
	cBody = ""
	for i = 1 to 400
		$oSrv.ServeOne(5)
		if $oRct.JobState(nJob) = 0
			cBody = $oRct.PollHttp(nJob)
			exit
		ok
	next
	Then("the request completed with HTTP 200", $oRct.HttpLastStatus(), 200)
	Then("and the body is the server's response", StzFindFirst(cBody, "local-ok") > 0, TRUE)
	$oSrv.Stop()
EndScenario()

Scenario("a POST body reaches a local echo route")
	Given("a plaintext /echo route returning the request body")
	$oSrv2 = new stzAppServer()
	$oSrv2.Post("/echo", func oReq, oResp { oResp.Text("got:" + oReq.Body()) })
	$oSrv2.Start(0, "127.0.0.1")
	cUrl = "http://127.0.0.1:" + $oSrv2.Port() + "/echo"
	nJob = $oRct.SubmitHttp(1, cUrl, "payload-42")
	cBody = ""
	for i = 1 to 400
		$oSrv2.ServeOne(5)
		if $oRct.JobState(nJob) = 0
			cBody = $oRct.PollHttp(nJob)
			exit
		ok
	next
	Then("the POST body made the round trip", StzFindFirst(cBody, "got:payload-42") > 0, TRUE)
	$oSrv2.Stop()
EndScenario()

Scenario("LIVE HTTPS: native TLS delivers a page (or offline pass)")
	Given("an https:// GET to a public host")
	cHtml = $oRct.HttpGet("https://example.com", 15000)
	nStatus = $oRct.HttpLastStatus()
	if nStatus = 200
		Then("TLS handshake + fetch succeeded (200)", nStatus, 200)
		Then("the decrypted body is HTML",
			StzFindFirst(StzLower(cHtml), "<html") > 0, TRUE)
	else
		Then("offline: the path completed without crashing (status <= 0)",
			nStatus <= 0, TRUE)
	ok
EndScenario()

Scenario("a bad host errors without crashing")
	Given("an unresolvable host")
	$oRct.HttpGet("http://nonexistent.invalid.softanza.test/", 5000)
	Then("the status is a non-2xx / error (< 200 or negative)",
		$oRct.HttpLastStatus() < 200, TRUE)
EndScenario()

Scenario("teardown")
	$oRct.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()
