load "../../stzBase.ring"
load "../_narrated.ring"

# stzReactiveHttp -- THE REACTOR SWITCH, AND WHAT A FAILURE IS ALLOWED TO SAY.
#
# The class has exactly one setter, SetReactor, and it is the switch between two
# entirely different request paths: with a reactor every verb goes async through
# the reactor's curl-backed job; without one, _CanAsync answers FALSE and the
# request falls back to a blocking task. So this suite checks the switch by what
# it SWITCHES, not by reading the attribute back.
#
# Everything below runs on the loopback against a listener this file starts, so
# there is no network dependency and no flakiness from one.

pr()

CRLF = char(13) + char(10)

Scenario("The reactor switch changes which path a request takes")

	Given("a reactive http client with no reactor")
	oRs = new stzReactiveSystem()
	oBlocking = new stzReactiveHttp(oRs)

	# The two paths are told apart by what the verb ANSWERS: the async path
	# returns a numeric job id, the blocking path returns a task object. That is
	# the mechanism, and it cannot be satisfied by a stored attribute.
	Then("a request without a reactor comes back as a task object",
	     isObject(oBlocking.Get_("http://127.0.0.1:1/x", NULL, NULL)), TRUE)

	Given("the same client given a reactor")
	oRct = new stzReactor()
	oAsync = new stzReactiveHttp(oRs)
	oAsync.SetReactor(oRct)
	uAnswer = oAsync.Get_("http://127.0.0.1:1/x", NULL, NULL)
	Then("the request comes back as a job id instead", isNumber(uAnswer), TRUE)
	Then("...and it is queued", oAsync.PendingCount(), 1)

	# THE NEGATIVE SIBLING for the URL test inside _CanAsync: a scheme the async
	# path does not handle must still fall back rather than be submitted.
	Then("a non-http scheme still goes the blocking way",
	     isObject(oAsync.Get_("ftp://example.invalid/x", NULL, NULL)), TRUE)
EndScenario()

Scenario("A failure says WHICH failure")

	# DrainPending had the HTTP status in hand -- it reads HttpLastStatus()
	# straight after the poll -- and handed the callback a fixed string, so a 404
	# and a 500 arrived as the same seven words. The status is in the message now.

	Given("a listener on the loopback that answers 404")
	oRct2 = new stzReactor()
	oRs2 = new stzReactiveSystem()
	oH = new stzReactiveHttp(oRs2)
	oH.SetReactor(oRct2)
	nSid = oRct2.ListenHttp("127.0.0.1", 0)
	nPort = oRct2.ServerPort(nSid)
	Then("it bound a port", nPort > 0, TRUE)

	When("a request is made and the server answers 404")
	cSeen = "(never)"
	oH.Get_("http://127.0.0.1:" + nPort + "/missing",
		func b { cSeen = "OK:" + b },
		func e { cSeen = "ERR:" + e })
	ServeOnce(oRct2, oH, nSid, "404 Not Found", "not here")

	Then("the error callback ran, not the success one", StzLeft(cSeen, 4), "ERR:")
	Then("...and the message names the status", StzFindFirst("status 404", cSeen) > 0, TRUE)
	Then("...while keeping the familiar wording", StzFindFirst("HTTP request failed", cSeen) > 0, TRUE)

	# THE NEGATIVE SIBLING, and the one that makes the assertion above mean
	# something: a 2xx must reach the SUCCESS callback with its body. Without it,
	# a client that failed every request would pass the checks above.
	Given("the same listener answering 200")
	cOk = "(never)"
	oH.Get_("http://127.0.0.1:" + nPort + "/here",
		func b { cOk = "OK:" + b },
		func e { cOk = "ERR:" + e })
	ServeOnce(oRct2, oH, nSid, "200 OK", "hello!!!")

	Then("the success callback ran", StzLeft(cOk, 3), "OK:")
	Then("...carrying the body", StzFindFirst("hello!!!", cOk) > 0, TRUE)
	Then("...and no status is bolted onto a success", StzFindFirst("status", cOk), 0)
EndScenario()

Scenario("No status is invented when there is none")

	# A refused connection never produced one. The message must stay exactly as
	# it was rather than gain a fabricated "(status 0)" -- the point of reporting
	# the status is that it is true, not that it is present.

	Given("a request to a port nothing is listening on")
	oRct3 = new stzReactor()
	oRs3 = new stzReactiveSystem()
	oH3 = new stzReactiveHttp(oRs3)
	oH3.SetReactor(oRct3)
	cRef = "(never)"
	oH3.Get_("http://127.0.0.1:1/nothing", func b { cRef = "OK:" + b }, func e { cRef = "ERR:" + e })

	When("the job finishes without ever reaching a server")
	DrainUntilDone(oH3, 8000)

	Then("the failure is reported", StzLeft(cRef, 4), "ERR:")
	Then("...with no status attached", StzFindFirst("status", cRef), 0)
EndScenario()

Scenario("A verb the path cannot issue is refused, not quietly changed")

	# _MethodCode used to end `return 0`, which is GET -- so an unrecognised verb
	# became a different request than the one asked for, silently. The four public
	# verbs all pass literals, so nothing reaches it today; that is exactly what
	# makes it worth closing before something does.

	Given("the method table")
	oRs4 = new stzReactiveSystem()
	oM = new stzReactiveHttp(oRs4)

	Then("GET maps to its code", oM._MethodCode("GET"), 0)
	Then("...and DELETE to its own", oM._MethodCode("DELETE"), 3)
	Then("...and HEAD is mapped, though no Head() offers it yet", oM._MethodCode("HEAD"), 4)

	# The refusal, and the reason it matters: -1 is not 0, and 0 is GET.
	Then("an unsupported verb is refused", oM._MethodCode("PATCH"), -1)
	Then("...and does NOT come back as GET", oM._MethodCode("PATCH") != oM._MethodCode("GET"), TRUE)

	# ...and the refusal reaches the caller rather than being swallowed.
	When("a request is submitted with that verb")
	oRct4 = new stzReactor()
	oM.SetReactor(oRct4)
	cWhy = "(never)"
	nRes = oM._SubmitAsync("PATCH", "http://127.0.0.1:1/x", "", NULL, func e { cWhy = "" + e })

	Then("the submission fails", nRes, -1)
	Then("...telling the caller which verb", StzFindFirst("PATCH", cWhy) > 0, TRUE)
	Then("...and that it is the method at fault", StzFindFirst("method not supported", StzLower(cWhy)) > 0, TRUE)
	Then("...and nothing was queued", oM.PendingCount(), 0)
EndScenario()

Scenario("SetReactor chains, and refuses what is not a reactor")

	Given("a client with a working reactor")
	oRs5 = new stzReactiveSystem()
	oS = new stzReactiveHttp(oRs5)
	oRct5 = new stzReactor()

	Then("the setter answers with the object", isObject(oS.SetReactor(oRct5)), TRUE)
	Then("...and the async path is on", isNumber(oS.Get_("http://127.0.0.1:1/x", NULL, NULL)), TRUE)

	When("it is handed something that is not a reactor")
	oS.SetReactor("not a reactor")
	Then("the refusal keeps the working one", isNumber(oS.Get_("http://127.0.0.1:1/x", NULL, NULL)), TRUE)

	# THE NEGATIVE SIBLING: NULL is not a mistake, it is the documented way to
	# say "no reactor, go blocking", so it must still be accepted.
	When("it is handed NULL")
	oS.SetReactor(NULL)
	Then("NULL is accepted and turns the async path off",
	     isObject(oS.Get_("http://127.0.0.1:1/x", NULL, NULL)), TRUE)
EndScenario()

Scenario("The switch has an off position, and it now works")

	# SetReactor(NULL) selects the blocking path, and that path called Ring's
	# download() and then the raw libcurl.ring API -- curl_easy_init,
	# CURLOPT_*, curl_easy_perform_silent. The library dropped that extension
	# when HTTP moved into the Zig engine, so every verb raised R3 "Calling
	# Function without definition" on its first line. The reactor switch had an
	# off position that could not work at all.
	#
	# The request below cannot reach a server -- an in-process listener would
	# deadlock, since a blocking call leaves nobody to pump it -- so what is
	# asserted is that the path RUNS and reports, where it used to raise.

	Given("a client with no reactor at all")
	oRs6 = new stzReactiveSystem()
	oB = new stzReactiveHttp(oRs6)

	When("a request is made to somewhere nothing answers")
	oTask = oB.Get_("http://127.0.0.1:1/nothing", NULL, NULL)

	Then("it comes back as a task, not a raise", isObject(oTask), TRUE)
	Then("...which ran and failed rather than crashing", oTask.HasFailed(), TRUE)
	Then("...and says so through the inherited accessor",
	     StzFindFirst("HTTP request failed", oTask.Error()) > 0, TRUE)

	# No status was ever obtained, so none is invented -- the same rule the
	# async path follows, through the same helper.
	Then("...with no status attached", StzFindFirst("status", oTask.Error()), 0)

	# THE NEGATIVE SIBLING: the other three verbs went through
	# PerformHttpWithData, a different dead function, so GET working proves
	# nothing about them.
	Then("POST also runs", isObject(oB.Post("http://127.0.0.1:1/x", "d", NULL, NULL)), TRUE)
	Then("PUT also runs", isObject(oB.Put_("http://127.0.0.1:1/x", "d", NULL, NULL)), TRUE)
	Then("DELETE also runs", isObject(oB.Delete("http://127.0.0.1:1/x", NULL, NULL)), TRUE)
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

# Answer the one pending request with a status line and body, then drain it.
# Content-Length must match the body exactly: a length one byte too long leaves
# curl waiting for a byte that never arrives, and the request fails for a reason
# that has nothing to do with the status being tested.
func ServeOnce(poReactor, poHttp, pnSid, pcStatusLine, pcBody)
	_cCRLF_ = char(13) + char(10)
	_cResp_ = "HTTP/1.1 " + pcStatusLine + _cCRLF_ +
	          "Content-Length: " + len(pcBody) + _cCRLF_ +
	          "Connection: close" + _cCRLF_ + _cCRLF_ + pcBody
	_bServed_ = FALSE
	for _i_ = 1 to 400
		_aEv_ = poReactor.ServerAwait(pnSid, 20)
		if len(_aEv_) > 0 and _aEv_[1] = :data and NOT _bServed_
			poReactor.ServerWrite(pnSid, _aEv_[2], _cResp_, TRUE)
			_bServed_ = TRUE
		ok
		if poHttp.DrainPending() > 0
			return TRUE
		ok
	next
	return FALSE

# Drain until the pending job completes or the budget runs out.
func DrainUntilDone(poHttp, pnBudgetMs)
	_n0_ = StzEngineWatchTimestampNs()
	while (StzEngineWatchTimestampNs() - _n0_) / 1000000 < pnBudgetMs
		if poHttp.DrainPending() > 0
			return TRUE
		ok
	end
	return FALSE
