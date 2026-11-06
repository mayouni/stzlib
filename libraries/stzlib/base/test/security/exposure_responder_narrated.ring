load "../../stzBase.ring"
load "../_narrated.ring"

# SOFTANZA_ONE_HOUR.md, B5 (rung W6) -- the hour is spent with the door shut.
#
# A matched advisory makes the responder shut a door, and exposure.closed is
# the moment StzTimeToSafe measures. Every door is exercised through the class
# that owns it -- stzTcpServer, stzHttpClient, the image plane's model door --
# and every refusal happens BEFORE the effect: no socket opens, no byte leaves.
# Each refusal has a sibling that must still pass. Everything is a fixture:
# no address here is reachable, and no request is sent.
#
# NOT RUN on the Ring++ engine copy: the neural plane's door (_StzNeuralDoor
# names the model by asking stz_neural, which the copy does not carry). The
# image door is exercised because its check runs before any engine call.

Scenario("1. THE DRILL: an advisory on curl, matched, answered by a shut door, inside the hour")
	StzCloseSecurityLedger()
	StzForgetShutDoors()
	oX = new stzExposure()
	oF = new stzAdvisoryFeed()
	oF.SeedAdvisory("DRILL-2026-0601", "curl", "8.22", 9.1, 1)
	Then("the advisory reaches what we run", oF.Match(oX), 1)
	oResp = new stzExposureResponder()
	Then("the responder answers the match", oResp.Respond(oF), 1)
	aA = oResp.Actions()
	Then("...with the door the reach table names", aA[1][3] + " " + aA[1][4], "fetch *")
	Then("one door is shut", StzNumberOfShutDoors(), 1)
	aT = StzTimeToSafe("DRILL-2026-0601")
	Then("exposure.closed is in the ledger, chained to the advisory", aT[:closedAt] >= aT[:matchedAt] and aT[:closedAt] > 0, 1)
	aB = StzTimeToSafeBudget()
	? "  NUMBER time to door shut: " + aT[:msToClosed] + " ms (budget " + aB[:msToClosed] + " ms)"
	Then("NUMBER -- the door shut inside the one-hour budget", aT[:msToClosed] >= 0 and aT[:msToClosed] <= aB[:msToClosed], 1)
	Then("the gate is not green yet, so the advisory does not hold", StzTimeToSafeHolds("DRILL-2026-0601"), 0)
EndScenario()

Scenario("2. the fetch door refuses before any byte leaves, and says why")
	oC = new stzHttpClient()
	bRefused = 0
	cMsg = ""
	try
		oC.Get_("http://192.0.2.1/never")                 # TEST-NET-1: unroutable on purpose
	catch
		bRefused = 1
		cMsg = cCatchError
	done
	Then("stzHttpClient.Get_ is refused under the shut", bRefused, 1)
	Then("...naming the advisory", StzFindFirst("DRILL-2026-0601", cMsg) > 0, 1)
	Then("...and no request reached the engine (no status)", oC.@last_response_code, 0)
	aRf = StzSecurityLedgerQ().OfKind("capability.refused")
	Then("the refusal is a ledger record with the advisory as origin", aRf[len(aRf)][:origin], "DRILL-2026-0601")
	Then("...its subject the host asked for", aRf[len(aRf)][:subject], "192.0.2.1")
	n = oResp.Reopen("DRILL-2026-0601")
	Then("Reopen opens the one door", n, 1)
	Then("...and records it", len(StzSecurityLedgerQ().OfKind("exposure.reopened")), 1)
	oResp.ShutFetch("DRILL-2026-0602", "evil.example", "a host-scoped shut")
	bPass = 1
	try
		StzDoorCheck("fetch", StzUrlHost("https://api.osv.dev/v1/query"), "stzHttpClient", 0)
	catch
		bPass = 0
	done
	Then("a host-scoped shut leaves another host open (negative sibling)", bPass, 1)
	bRefused = 0
	try
		StzDoorCheck("fetch", StzUrlHost("https://user@EVIL.example:8443/x"), "stzHttpClient", 0)
	catch
		bRefused = 1
	done
	Then("...and refuses its own host however the URL spells it", bRefused, 1)
	oResp.Reopen("DRILL-2026-0602")
EndScenario()

Scenario("3. the listener door: shut beyond loopback, a local bind still opens")
	StzForgetListeners()
	oResp = new stzExposureResponder()
	oResp.ShutExposedListeners("DRILL-2026-0603", "*", "libuv advisory: no remote binds until rebuilt")
	oS = new stzTcpServer()
	bRefused = 0
	try
		oS.Listen(18099, "192.0.2.1")
	catch
		bRefused = 1
	done
	Then("stzTcpServer.Listen beyond loopback is refused", bRefused, 1)
	Then("...before the socket opened", oS.IsListening(), 0)
	Then("...and the listener was not recorded as open", len(StzListeners()), 0)
	bPass = 1
	try
		StzNoteListener("stzTcpServer", "127.0.0.1", 18099)
	catch
		bPass = 0
	done
	Then("a loopback bind passes the same door (negative sibling)", bPass, 1)
	oResp.Reopen("DRILL-2026-0603")
	oResp.ShutListeners("DRILL-2026-0604", "stzReactor.http", "every http listener of the reactor")
	bRefused = 0
	try
		StzNoteListener("stzReactor.http", "127.0.0.1", 18100)
	catch
		bRefused = 1
	done
	Then("a class shut refuses even loopback", bRefused, 1)
	bPass = 1
	try
		StzNoteListener("stzTcpServer", "127.0.0.1", 18101)
	catch
		bPass = 0
	done
	Then("...and only that class (negative sibling)", bPass, 1)
	oResp.Reopen("DRILL-2026-0604")
EndScenario()

Scenario("4. a socket already open is named, not pretended closed")
	StzForgetListeners()
	StzForgetShutDoors()
	StzNoteListener("stzWebSocketServer", "192.0.2.7", 18200)      # opened before the advisory
	StzNoteListener("stzTcpServer", "127.0.0.1", 18201)
	oResp = new stzExposureResponder()
	oResp.ShutExposedListeners("DRILL-2026-0605", "*", "remote binds refused")
	aS = oResp.StillOpen()
	Then("StillOpen names the exposed socket its owner must stop", len(aS), 1)
	Then("...the one beyond loopback", aS[1][1] + " " + aS[1][2], "stzWebSocketServer 192.0.2.7")
	oResp.Reopen("DRILL-2026-0605")
	StzForgetListeners()
EndScenario()

Scenario("5. the model door withholds the answer")
	oResp = new stzExposureResponder()
	oResp.ShutModel("DRILL-2026-0606", "owlvit-b32.gguf", "a crafted-file advisory on this model")
	bRefused = 0
	try
		_StzVisionDoor("FindByWords", "owlvit-b32.gguf", "a picture")
	catch
		# the door's own refusal, not the engine call after it (stz_image is absent from the copy)
		if StzFindFirst("DRILL-2026-0606", cCatchError) > 0  bRefused = 1  ok
	done
	Then("the image plane's door refuses the shut model, by the advisory's name", bRefused, 1)
	bPass = 1
	try
		StzDoorCheck("model", "mobilesam.gguf", "stzImage", 0)
	catch
		bPass = 0
	done
	Then("another model passes (negative sibling)", bPass, 1)
	oResp.Reopen("DRILL-2026-0606")
EndScenario()

Scenario("6. what no door reaches is reported, and no hour is claimed for it")
	StzCloseSecurityLedger()
	StzForgetShutDoors()
	oX = new stzExposure()
	oF = new stzAdvisoryFeed()
	oF.SeedAdvisory("DRILL-2026-0607", "sqlite", "3", 8.0, 0)
	oF.SeedAdvisory("DRILL-2026-0608", "libuv", "1.52", 7.0, 0)
	oF.Match(oX)
	oResp = new stzExposureResponder()
	Then("NUMBER -- of two matches, the one a door reaches is answered", oResp.Respond(oF), 1)
	aU = oResp.Unreached()
	Then("the other is reported for a person", len(aU), 1)
	Then("...naming sqlite", aU[1][2], "sqlite")
	aT7 = StzTimeToSafe("DRILL-2026-0607")
	aT8 = StzTimeToSafe("DRILL-2026-0608")
	Then("...with no exposure.closed written for it", aT7[:msToClosed], -1)
	Then("the reached one is closed", aT8[:msToClosed] >= 0, 1)
	oResp.Respond(oF)
	Then("responding twice shuts nothing twice", len(StzSecurityLedgerQ().OfKind("exposure.closed")), 1)
	oResp.SetReach("sqlite", "fetch", "*")
	oResp.Respond(oF)
	Then("a program's own reach row makes it reachable", len(oResp.Unreached()), 0)
	Then("the ledger chain is intact after every door", StzSecurityLedgerQ().Verify()[:intact], 1)
	oResp.Reopen("DRILL-2026-0607")
	oResp.Reopen("DRILL-2026-0608")
	Then("every door is open at the end", StzNumberOfShutDoors(), 0)
EndScenario()

Summary()
shutdown($_zst_fail)
