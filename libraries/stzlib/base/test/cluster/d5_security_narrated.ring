# DISTRIBUTION D5 -- governance + security integration, BY REUSE.
#
# The kill criterion is structural: any new crypto primitive or a
# second signer = refused by construction. Everything below runs on
# what already exists -- stzRequestSigner (HMAC-SHA256 + freshness +
# nonce replay cache) authenticates senders; the stzSystemActor
# capability lattice authorizes them (the load-bearing rule included:
# an LLM actor can NEVER hold :effectful); the mbedTLS termination
# that already serves HTTPS carries the STZM plane over mutual TLS.
#
# Refusals are never silent: every rejection is COUNTED on the node
# (stz.info) and surfaces to an asker as the observable :Denied.

load "../../stzBase.ring"
load "../_narrated.ring"

$oSpawner = new stzReactor()

nBase = 47100 + (StzEngineTimeNowMs() % 200)
$nPortW = nBase
$nPortTls = nBase + 1

$cWebSecret = "d5-web-" + StzEngineTimeNowMs()
$cBotSecret = "d5-bot-" + StzEngineTimeNowMs()

cExe = D5RingExe()
nJobW = $oSpawner.SubmitSpawn([ cExe, "_d5_worker.ring", "" + $nPortW,
	$cWebSecret, $cBotSecret ])

# the guard's keyring -- the SAME signer class, the SAME secrets
$oSigner = new stzRequestSigner("d5-guard")
$oSigner.AddKey("web", $cWebSecret)
$oSigner.AddKey("bot", $cBotSecret)

# the default plane signs as the trusted "web" caller
NodeRegister("worker", "127.0.0.1", $nPortW)
StzNodePlane().SecureWith($oSigner, "web")

Scenario("a signed Ask is authenticated and served")
	Given("a worker requiring signed messages, and a plane signing as 'web'")
	Then("the worker boots", D5AwaitBoot("worker", 20000), TRUE)
	vR = Ask("worker", [ "work", "x" ], 3000)
	Then("the admitted, signed, capable ask is SERVED", vR, "did:x")
	vR = Ask("worker", [ "ping", 42 ], 3000)
	Then("plain signed traffic flows too", D5PackEq(vR, [ "pong", 42 ]), TRUE)
EndScenario()

Scenario("an UNSIGNED message is refused, counted, and observable")
	Given("a second plane with NO signer")
	oPlain = new stzNodeRegistry()
	oPlain.Register("worker", "127.0.0.1", $nPortW)
	When("it asks the same worker")
	vR = oPlain.Ask("worker", [ "ping", 1 ], 3000)
	Then("the verdict is :Denied -- observable, not a silent timeout",
		oPlain.LastStatus(), :Denied)
	vInfo = Ask("worker", [ "stz.info" ], 3000)
	Then("the rejection was COUNTED on the node (exactly 1)", vInfo[7], 1)
	$oPlain = oPlain
EndScenario()

Scenario("a TAMPERED message fails the MAC")
	Given("a genuine envelope signed over one message, delivered with another")
	aEnv = $oSigner.SignNow("web", "STZM", "work",
		StzEngineStzmPack([ "work", "good" ], 0, 0, 0))
	vWire = [ "stz.signed", aEnv, [ "work", "evil" ] ]
	When("the tampered wire form is asked through the unsigned plane")
	vR = $oPlain.Ask("worker", vWire, 3000)
	Then("the verdict is :Denied", $oPlain.LastStatus(), :Denied)
	vInfo = Ask("worker", [ "stz.info" ], 3000)
	Then("the tamper was COUNTED (rejections now 2)", vInfo[7], 2)
EndScenario()

Scenario("a REPLAYED envelope is refused the second time")
	Given("one correctly signed message, captured verbatim")
	aEnv = $oSigner.SignNow("web", "STZM", "work",
		StzEngineStzmPack([ "work", "once" ], 0, 0, 0))
	vWire = [ "stz.signed", aEnv, [ "work", "once" ] ]
	When("it is delivered twice")
	vR = $oPlain.Ask("worker", vWire, 3000)
	Then("the FIRST delivery is served", vR, "did:once")
	vR = $oPlain.Ask("worker", vWire, 3000)
	Then("the SECOND is refused (nonce replay)", $oPlain.LastStatus(), :Denied)
	vInfo = Ask("worker", [ "stz.info" ], 3000)
	Then("and counted (rejections now 3)", vInfo[7], 3)
EndScenario()

Scenario("the capability lattice gates admission: an LLM cannot do WORK")
	Given("a plane signing as 'bot' -- a verified identity that is an LLM actor")
	oBot = new stzNodeRegistry()
	oBot.Register("worker", "127.0.0.1", $nPortW)
	oBot.SecureWith($oSigner, "bot")
	When("the bot asks for the :effectful-admitted 'work' tag")
	vR = oBot.Ask("worker", [ "work", "y" ], 3000)
	Then("authenticated but NOT authorized: :Denied", oBot.LastStatus(), :Denied)
	vInfo = Ask("worker", [ "stz.info" ], 3000)
	Then("the capability denial was counted (exactly 1)", vInfo[8], 1)
	When("the same bot asks an UNADMITTED tag (ping)")
	vR = oBot.Ask("worker", [ "ping", 7 ], 3000)
	Then("expression is free where no capability is demanded",
		D5PackEq(vR, [ "pong", 7 ]), TRUE)
	oBot.Destroy()
EndScenario()

Scenario("the STZM plane rides MUTUAL TLS on the existing channel")
	Given("an STZM listener terminating TLS with the house test certs")
	cCertDir = $cEngineDir + "/src/mtls_certs"
	oA = new stzReactor()
	nSrv = oA.ListenStzmTls("127.0.0.1", $nPortTls, cCertDir + "/node.crt.pem",
		cCertDir + "/node.key.pem", cCertDir + "/ca.crt.pem", TRUE)
	Then("the TLS listener is up", nSrv > 0, TRUE)
	When("a channel dials it presenting the node cert, verifying the CA")
	oB = new stzReactor()
	nCh = oB.ConnectStzmTls("127.0.0.1", $nPortTls, cCertDir + "/node.crt.pem",
		cCertDir + "/node.key.pem", cCertDir + "/ca.crt.pem", TRUE)
	nConn = oB.WaitLinkUp(nCh, 10000)
	Then("link-up means the HANDSHAKE completed", nConn > 0, TRUE)
	cFrame = StzEngineStzmPack([ "ping", 5 ], 0, 77, 0)
	oB.ServerWrite(nCh, nConn, cFrame, FALSE)
	cGot = ""
	nSrvConn = 0
	nDl = StzEngineWatchTimestampMs() + 8000
	while StzEngineWatchTimestampMs() < nDl
		aEv = oA.ServerPoll(nSrv)
		if len(aEv) = 3 and aEv[1] = :data
			nSrvConn = aEv[2]
			cGot = aEv[3]
			exit
		ok
	end
	Then("the frame crossed the encrypted link intact", cGot = cFrame, TRUE)
	oA.ServerWrite(nSrv, nSrvConn, cGot, FALSE)
	cBack = ""
	while StzEngineWatchTimestampMs() < nDl
		aEv = oB.ServerPoll(nCh)
		if len(aEv) = 3 and aEv[1] = :data
			cBack = aEv[3]
			exit
		ok
	end
	Then("and echoed back byte-identical over TLS", cBack = cFrame, TRUE)
	When("a PLAINTEXT channel dials the TLS port and speaks STZM")
	nPl = oB.ConnectStzm("127.0.0.1", $nPortTls)
	nPlConn = oB.WaitLinkUp(nPl, 3000)
	oB.ServerWrite(nPl, nPlConn, cFrame, FALSE)
	bEject = FALSE
	nDl2 = StzEngineWatchTimestampMs() + 6000
	while StzEngineWatchTimestampMs() < nDl2
		aEv = oB.ServerPoll(nPl)
		if len(aEv) = 3 and aEv[1] = :closed
			bEject = TRUE
			exit
		ok
	end
	Then("it is EJECTED at the handshake -- plaintext cannot join a TLS plane",
		bEject, TRUE)
	oB.ServerStop(nPl)
	When("a channel verifies the peer against the WRONG trust anchor")
	nWr = oB.ConnectStzmTls("127.0.0.1", $nPortTls, cCertDir + "/node.crt.pem",
		cCertDir + "/node.key.pem", cCertDir + "/server.crt.pem", TRUE)
	Then("the handshake aborts -- no link", oB.WaitLinkUp(nWr, 5000), 0)
	oB.ServerStop(nWr)
	oB.ServerStop(nCh)
	oA.ServerStop(nSrv)
	oB.Destroy()
	oA.Destroy()
EndScenario()

Scenario("teardown")
	Given("a SIGNED stz.stop (an unsigned one would be refused)")
	Send("worker", [ "stz.stop" ])
	cOut = $oSpawner.AwaitSpawn(nJobW, 8000)
	Then("the worker stopped cleanly",
		StzFindFirst("d5-worker: done", cOut) > 0, TRUE)
	$oPlain.Destroy()
	StzNodePlane().Destroy()
	$oSpawner.Destroy()
	Then("teardown completes without crash", TRUE, TRUE)
EndScenario()

Summary()

#--- helpers ---------------------------------------------------------

func D5RingExe()
	_aA_ = sysargv
	_nLen_ = len(_aA_)
	for _i_ = 1 to _nLen_
		_c_ = StzLower("" + _aA_[_i_])
		if StzFindFirst("ring.exe", _c_) > 0 or _c_ = "ring"
			return "" + _aA_[_i_]
		ok
	next
	return "ring"

func D5AwaitBoot(cAddr, nTimeoutMs)
	_nDl_ = StzEngineWatchTimestampMs() + nTimeoutMs
	while StzEngineWatchTimestampMs() < _nDl_
		Ask(cAddr, [ "stz.info" ], 1000)
		if NodeAskStatus() = :Ok
			return TRUE
		ok
	end
	return FALSE

func D5PackEq(vA, vB)
	return StzEngineStzmPack(vA, 0, 1, 0) = StzEngineStzmPack(vB, 0, 1, 0)
