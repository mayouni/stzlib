load "../../stzBase.ring"
load "../_narrated.ring"

# R8 WIRE mTLS (rung #6, slices 2-4) -- the full node-to-node security stack
# end to end: the reactor SERVER terminates TLS (slice 2), the reactor CLIENT
# presents a cert + validates the peer (slice 3), and the FEDERATION runs its
# governed transport over that mutually-authenticated, encrypted channel
# (slice 4). This suite spawns a REAL mutual-TLS worker process and drives it
# as a TLS client, then over a governed federation.
#
# Certs (engine/src/mtls_certs/, throwaway TEST-ONLY): ca.* = the trust
# anchor; node.* = a leaf signed by the CA (SANs localhost/127.0.0.1), used
# as BOTH the server cert and the client cert; server.* = an UNRELATED
# self-signed cert (the "wrong CA" for the negative test).

$cCertDir = $cEngineDir + "/src/mtls_certs"
$cNodeCrt = $cCertDir + "/node.crt.pem"
$cNodeKey = $cCertDir + "/node.key.pem"
$cCACrt   = $cCertDir + "/ca.crt.pem"
$cWrongCA = $cCertDir + "/server.crt.pem"
$nPort    = 45700 + (StzEngineTimeNowMs() % 250)

# spawn ONE mutual-TLS worker (requires a client cert) for the whole suite
$oClient  = new stzReactor()
$oSpawner = new stzReactor()
$nSrvJob  = SpawnMtlsWorker($nPort)
WaitTlsReady($oClient, $nPort, 20000)

# =====================================================================
#  SLICE 2+3: the reactor TLS client vs the reactor TLS server (mutual)
# =====================================================================

Scenario("a genuine mutual-TLS request is served over the encrypted channel")
	Given("a live worker that terminates TLS and requires a client cert")
	When("the client presents its cert and validates the server against the CA")
	cR = $oClient.TlsGet("127.0.0.1", $nPort, "/health", $cNodeCrt, $cNodeKey, $cCACrt, TRUE)
	Then("the transport succeeded", $oClient.TlsClientStatus(), 0)
	Then("the protected endpoint was served over mTLS", StzFindFirst("ok:mtls", cR) > 0, TRUE)
EndScenario()

Scenario("a client WITHOUT a cert is refused by the server (mutual enforced)")
	Given("the same mutual-TLS worker")
	When("the client offers NO certificate")
	cR = $oClient.TlsGet("127.0.0.1", $nPort, "/health", "", "", $cCACrt, TRUE)
	# TLS 1.3: the client handshake completes (status 0) but the server
	# refuses to serve -> the RESPONSE BODY is the authoritative signal.
	Then("the protected endpoint is NOT served (empty response)", len(cR), 0)
	Then("nothing leaked (no ok:mtls)", StzFindFirst("ok:mtls", cR), 0)
EndScenario()

Scenario("a client that does not TRUST the server aborts the handshake")
	Given("the same worker, but the client verifies against the WRONG CA")
	When("the client tries to validate the server's cert against an unrelated CA")
	cR = $oClient.TlsGet("127.0.0.1", $nPort, "/health", $cNodeCrt, $cNodeKey, $cWrongCA, TRUE)
	Then("the handshake is aborted", $oClient.TlsClientStatus(), -2)
	Then("nothing was served", len(cR), 0)
EndScenario()

# =====================================================================
#  SLICE 4: the FEDERATION transport runs over mTLS (governed + signed)
# =====================================================================

Scenario("a governed federated call is transported over mutual TLS")
	Given("a federation whose member is the live mTLS worker")
	$oFed = new stzComputeFederation("secure-grid")
	$oFed.Join("worker", "127.0.0.1:" + $nPort, [ :math ])
	$oFed.Bond("web", :math)
	$oFed.GovDeclareRisk("use-math", 1).GovGrant("web", "use-math").GovSetAuthority("web", :Delegated)
	$oFed.RegisterKey("web", "grid-shared-secret")     # per-request signing too
	$oFed.SetMutualTls($cNodeCrt, $cNodeKey, $cCACrt)  # + mutual TLS transport
	Then("the federation reports it runs over mTLS", $oFed.IsMtls(), TRUE)

	When("web makes a governed, signed federated call over the mTLS channel")
	cR = $oFed.FederatedCall("web", :math, "/work", "")
	Then("the worker served it (HTTP 200 over mTLS)", $oFed.CallLastStatus(), 200)
	Then("the response body came back through the secure channel",
		StzFindFirst("worker:ok", cR) > 0, TRUE)
	Then("the call was ALSO signed (the full stack)", len($oFed.LastSignature()) > 0, TRUE)
	Then("the Why records the mTLS transport", StzFindFirst("mTLS", $oFed.Why()) > 0, TRUE)
	$oFed.Shutdown()
EndScenario()

Scenario("governance still gates an mTLS federation (transport != authorization)")
	Given("an mTLS federation where the caller lacks authority")
	$oG = new stzComputeFederation("gated-grid")
	$oG.Join("worker", "127.0.0.1:" + $nPort, [ :neural ])
	$oG.SetMutualTls($cNodeCrt, $cNodeKey, $cCACrt)
	$oG.Bond("web", :neural)
	$oG.GovDeclareRisk("use-neural", 4)   # critical
	$oG.GovGrant("web", "use-neural").GovSetAuthority("web", :Delegated)  # 2 << 4
	When("web calls a critically-governed facet over mTLS")
	$oG.FederatedCall("web", :neural, "/work", "")
	Then("governance refuses BEFORE transport (mTLS does not bypass it)",
		$oG.CallLastStatus() < 0, TRUE)
	$oG.Shutdown()
EndScenario()

# =====================================================================
#  DETERMINISTIC: config + connect-failure edges (no live server)
# =====================================================================

Scenario("TLS setup + connect failures are clean, not crashes")
	Given("a fresh reactor")
	oD = new stzReactor()
	Then("listening TLS with a missing cert file fails with a negative code",
		oD.ListenHttpsServer("127.0.0.1", 0, $cCertDir + "/nope.pem", $cNodeKey) < 0, TRUE)
	When("a TLS client connects to a dead port")
	cR = oD.TlsGet("127.0.0.1", 1, "/x", $cNodeCrt, $cNodeKey, $cCACrt, TRUE)
	Then("it reports a connect failure", oD.TlsClientStatus(), -1)
	Then("with an empty body", len(cR), 0)
	oD.Destroy()
EndScenario()

# tear down the spawned worker (force-kill so it never orphans)
$oSpawner.KillSpawnHard($nSrvJob)
$oSpawner.Destroy()
$oClient.Destroy()

Summary()


# -- helpers (after Summary; Ring hoists func defs) -------------------

func SpawnMtlsWorker nPort
	cScript = $cCertDir + "/.mtls_worker_gen.ring"
	nl = char(10)
	cCode = 'load "' + MtlsBaseRing() + '"' + nl +
		'oS = new stzAppServer()' + nl +
		'oS.Get_("/health", func oReq, oResp { oResp.Text("ok:mtls") })' + nl +
		'oS.Get_("/work",   func oReq, oResp { oResp.Text("worker:ok") })' + nl +
		'oS.StartTls(' + nPort + ', "127.0.0.1", "' + $cNodeCrt + '", "' +
			$cNodeKey + '", "' + $cCACrt + '", TRUE)' + nl +
		'oS.RunFor(25000)' + nl +
		'oS.Stop()' + nl
	write(cScript, cCode)
	return $oSpawner.SubmitSpawn([ MtlsRingExe(), cScript ])

func WaitTlsReady oClient, nPort, nTimeoutMs
	nDeadline = StzEngineTimeNowMs() + nTimeoutMs
	while StzEngineTimeNowMs() < nDeadline
		cR = oClient.TlsGet("127.0.0.1", nPort, "/health", $cNodeCrt, $cNodeKey, $cCACrt, TRUE)
		if StzFindFirst("ok:mtls", cR) > 0  return TRUE  ok
		nJ = oClient.SubmitTimer(300)
		oClient.AwaitTimer(nJ, 600)
	end
	return FALSE

func MtlsRingExe
	aA = sysargv
	nLen = len(aA)
	for i = 1 to nLen
		c = StzLower("" + aA[i])
		if StzFindFirst("ring.exe", c) > 0 or c = "ring"  return "" + aA[i]  ok
	next
	return "ring"

func MtlsBaseRing
	nSlash = 0
	nL = len($cEngineDir)
	for i = 1 to nL
		if $cEngineDir[i] = "/"  nSlash = i  ok
	next
	return StzLeft($cEngineDir, nSlash - 1) + "/base/stzBase.ring"
