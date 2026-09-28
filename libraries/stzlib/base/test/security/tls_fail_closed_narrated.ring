load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-TLS-FAILCLOSED-01 -- the TLS CLIENT fails CLOSED.
#
# Both client paths (the one-shot TlsRequest and the persistent
# ConnectStzmTls channel) used to fail OPEN: with no CA path the engine
# set VERIFY_NONE, and with bVerify = FALSE it set VERIFY_OPTIONAL. Either
# way the client finished a handshake with ANY server and reported
# success. The policy now:
#
#   TRUE               verify -- against the given CA, else against the
#                      operating system's trusted roots
#   :InsecureNoVerify  no verification, because the caller NAMED it
#   FALSE              refused, status -18
#
# The server below presents the house TEST leaf (engine/src/mtls_certs,
# signed by a throwaway test CA that no operating system trusts). So a
# client that trusts the system roots MUST refuse it, and a client that
# is given the test CA MUST accept it -- the positive sibling of every
# refusal. Everything runs in-process: no worker is spawned.

$cCertDir = $cEngineDir + "/src/mtls_certs"
$cNodeCrt = $cCertDir + "/node.crt.pem"
$cNodeKey = $cCertDir + "/node.key.pem"
$cCACrt   = $cCertDir + "/ca.crt.pem"
$cWrongCA = $cCertDir + "/server.crt.pem"

$oSrv = new stzReactor()
$nSrv = $oSrv.ListenHttpsServer("127.0.0.1", 0, $cNodeCrt, $cNodeKey)
$nPort = $oSrv.ServerPort($nSrv)
$oCli = new stzReactor()

# =====================================================================
#  THE ONE-SHOT CLIENT (TlsRequest)
# =====================================================================

Scenario("a client given the right CA completes the handshake")
	Given("an HTTPS listener presenting a leaf signed by the test CA")
	Then("the listener is up", $nSrv > 0, 1)
	When("the client verifies against that CA")
	$oCli.TlsGet("127.0.0.1", $nPort, "/", "", "", $cCACrt, 1)
	Then("the handshake completed (status 0)", $oCli.TlsClientStatus(), 0)
EndScenario()

Scenario("a client with NO CA verifies against the system roots, and refuses a stranger")
	Given("the same listener, whose CA no operating system trusts")
	When("the client asks to verify but names no CA file")
	$oCli.TlsGet("127.0.0.1", $nPort, "/", "", "", "", 1)
	# before the fix: VERIFY_NONE -> status 0, a handshake with anybody.
	# -2 (and not -19) also proves the system roots LOADED.
	Then("the handshake is refused against the system roots (status -2)",
		$oCli.TlsClientStatus(), -2)
EndScenario()

Scenario("a client that passes FALSE is refused, not quietly unverified")
	Given("the same listener, and a CA file that does NOT sign its leaf")
	When("the client passes bVerify = FALSE")
	$oCli.TlsGet("127.0.0.1", $nPort, "/", "", "", $cWrongCA, 0)
	# before the fix: VERIFY_OPTIONAL -> status 0 with an untrusted peer
	Then("the request is refused before any connection (status -18)",
		$oCli.TlsClientStatus(), -18)
EndScenario()

Scenario("the wrong CA with verification ON aborts the handshake")
	When("the client verifies against a CA that did not sign the leaf")
	$oCli.TlsGet("127.0.0.1", $nPort, "/", "", "", $cWrongCA, 1)
	Then("the handshake is refused (status -2)", $oCli.TlsClientStatus(), -2)
EndScenario()

Scenario("the insecure mode exists, but only under its own name")
	When("the client names :InsecureNoVerify and gives no CA")
	$oCli.TlsGet("127.0.0.1", $nPort, "/", "", "", "", :InsecureNoVerify)
	Then("the handshake completes, because the caller chose it by name",
		$oCli.TlsClientStatus(), 0)
EndScenario()

# =====================================================================
#  THE PERSISTENT CHANNEL (ConnectStzmTls)
# =====================================================================

Scenario("a channel given the right CA comes up")
	Given("an STZM listener terminating TLS with the test leaf")
	$nStzm = $oSrv.ListenStzmTls("127.0.0.1", 0, $cNodeCrt, $cNodeKey, "", 0)
	$nStzmPort = $oSrv.ServerPort($nStzm)
	Then("the listener is up", $nStzm > 0, 1)
	When("a channel dials it verifying against the test CA")
	nCh = $oCli.ConnectStzmTls("127.0.0.1", $nStzmPort, "", "", $cCACrt, 1)
	Then("the channel links up (handshake completed)", $oCli.WaitLinkUp(nCh, 8000) > 0, 1)
	$oCli.ServerStop(nCh)
EndScenario()

Scenario("a channel with NO CA refuses a stranger")
	When("a channel asks to verify but names no CA file")
	nCh = $oCli.ConnectStzmTls("127.0.0.1", $nStzmPort, "", "", "", 1)
	# before the fix: VERIFY_NONE -> the link came up with anybody
	Then("the dial itself was accepted (system roots loaded)", nCh > 0, 1)
	Then("the channel never links up", $oCli.WaitLinkUp(nCh, 3000), 0)
	if nCh > 0  $oCli.ServerStop(nCh)  ok
EndScenario()

Scenario("a channel that passes FALSE is refused at setup")
	When("a channel passes bVerify = FALSE with a CA that does not sign the leaf")
	nCh = $oCli.ConnectStzmTls("127.0.0.1", $nStzmPort, "", "", $cWrongCA, 0)
	# before the fix: VERIFY_OPTIONAL -> a channel id, and a live link
	Then("the dial is refused with -18, no channel is created", nCh, -18)
	if nCh > 0  $oCli.ServerStop(nCh)  ok
EndScenario()

Scenario("a channel in the named insecure mode comes up")
	When("a channel names :InsecureNoVerify and gives no CA")
	nCh = $oCli.ConnectStzmTls("127.0.0.1", $nStzmPort, "", "", "", :InsecureNoVerify)
	Then("the channel links up, because the caller chose it by name",
		$oCli.WaitLinkUp(nCh, 8000) > 0, 1)
	if nCh > 0  $oCli.ServerStop(nCh)  ok
EndScenario()

$oSrv.ServerStop($nStzm)
$oSrv.ServerStop($nSrv)
$oCli.Destroy()
$oSrv.Destroy()

Summary()
