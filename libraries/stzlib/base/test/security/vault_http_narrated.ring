load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-VAULT-HTTP-01 -- threat-model risk R4: secrets come from a real
# secret manager, through the Vault HTTP API.
#
# The vault seam existed (any object with Resolve(locator)), but the only
# resolver shipped was an in-memory stand-in. stzVaultHttpResolver speaks
# the Vault HTTP API (HashiCorp Vault, OpenBao): KV v1 and v2, the token in
# X-Vault-Token, revealed per request and never held; plain http only to
# loopback.
#
# The vault here is a STAND-IN in its own process: a real stzAppServer
# answering Vault's routes and checking the token the way Vault does, over
# real HTTP. What it cannot show is a real Vault's behaviour beyond those
# routes -- that check waits for a real Vault.

$cToken = "hvs.drill-" + StzEngineTimeNowMs()
$cSealKey = StzNewSealKey()
$nPort = 48200 + (StzEngineTimeNowMs() % 300)
$cAddr = "http://127.0.0.1:" + $nPort
$oHuman = HumanActor("oncall")
$oService = HumanActor("billing-service")
$oLlm = LLMActor("assistant")
$oSpawner = new stzReactor()
$nJob = SpawnFakeVault()
$bUp = WaitVault(20000)

# the token is a secret of its own -- here from a literal, in production FromEnvQ("VAULT_TOKEN")
$oTok = StzSecretQ("vault-token").FromLiteralQ($cToken)
$oVault = StzVaultHttpResolver($cAddr, $oTok, $oService)

Scenario("a KV v2 secret is read through the Vault HTTP API")
	Then("the stand-in vault is up", $bUp, 1)
	oDb = StzSecretQ("db").FromVaultQ("secret/data/prod/db#password")
	Then("RevealVia returns the field's value", oDb.RevealVia($oVault, $oHuman), "hunter2-from-vault")
	Then("another field of the same secret", $oVault.Resolve("secret/data/prod/db#user"), "app")
	Then("the vault answered 200", $oVault.LastStatus(), 200)
EndScenario()

Scenario("a KV v1 secret is read too")
	Then("its field comes back", $oVault.Resolve("kv1/app/stripe#key"), "sk_test_from_v1")
EndScenario()

Scenario("what the vault refuses is RAISED, never returned as empty")
	oBad = StzVaultHttpResolver($cAddr, StzSecretQ("t").FromLiteralQ("hvs.wrong"), $oService)
	Then("a wrong token raises", Raises(oBad, "secret/data/prod/db#password"), 1)
	Then("...and the status was 403", oBad.LastStatus(), 403)
	Then("a missing secret raises", Raises($oVault, "secret/data/prod/nothing#x"), 1)
	Then("a missing FIELD raises", Raises($oVault, "secret/data/prod/db#nofield"), 1)
	Then("Has() says no for a missing secret", $oVault.Has("secret/data/prod/nothing#x"), 0)
	Then("Has() says yes for a present field", $oVault.Has("secret/data/prod/db#password"), 1)
	cMsg = ""
	try  oBad.Resolve("secret/data/prod/db#password")  catch  cMsg = cCatchError  done
	Then("the refusal never quotes the token", StzFindFirst("hvs.", cMsg), 0)
EndScenario()

Scenario("a token never crosses the network in clear")
	Then("plain http to a remote host is refused at construction",
		ConstructRaises("http://vault.example.com:8200"), 1)
	Then("https is accepted", ConstructRaises("https://vault.example.com:8200"), 0)
	Then("plain http to loopback is accepted (a local agent)", ConstructRaises("http://127.0.0.1:8200"), 0)
	Then("the resolver does not hold the token as a value",
		StzFindFirst($cToken, @@($oVault.@oToken.Descriptor())), 0)
EndScenario()

Scenario("the actor gates still hold")
	oDb = StzSecretQ("db").FromVaultQ("secret/data/prod/db#password")
	bRaised = 0
	try  oDb.RevealVia($oVault, $oLlm)  catch  bRaised = 1  done
	Then("an LLM asking for the secret is refused before the vault is called", bRaised, 1)
	oAsLlm = StzVaultHttpResolver($cAddr, $oTok, $oLlm)
	bRaised = 0
	try  oAsLlm.Resolve("secret/data/prod/db#password")  catch  bRaised = 1  done
	Then("a resolver acting AS an LLM cannot even read its token", bRaised, 1)
EndScenario()

Scenario("a sealed secret store takes its key from the vault")
	oKey = StzSecretQ("seal-key").FromVaultQ("secret/data/prod/sealkey#key")
	oS = StzSecretStoreQ("billing")
	oS.Register(StzApiKeyQ("stripe").FromLiteralQ("sk_live_sealed"))
	oS.SaveSealedToVia("_tmp_vault_sealed.stzsecrets", oKey, $oVault, $oHuman)
	oBack = StzSecretStoreFromSealedFileVia("_tmp_vault_sealed.stzsecrets", oKey, $oVault, $oHuman)
	Then("the store opens with the vault's key", oBack.Reveal("stripe", $oHuman), "sk_live_sealed")
	remove("_tmp_vault_sealed.stzsecrets")
EndScenario()

$oSpawner.KillSpawnHard($nJob)
$oSpawner.Destroy()
if fexists("_tmp_fakevault_gen.ring")  remove("_tmp_fakevault_gen.ring")  ok

Summary()

# -- helpers (after the main code) ------------------------------------

func Raises oResolver, cLocator
	try
		oResolver.Resolve(cLocator)
	catch
		return 1
	done
	return 0

func ConstructRaises cAddr
	try
		StzVaultHttpResolver(cAddr, $oTok, $oService)
	catch
		return 1
	done
	return 0

# A stand-in for Vault: Vault's KV routes and its token check, in its own
# process, over real HTTP. $-prefixed globals only (the drill's lesson:
# a top-level _n_ is a global that library loops overwrite).
func SpawnFakeVault
	q = char(34)
	nl = char(10)
	cV2 = "{" + q + "data" + q + ":{" + q + "data" + q + ":{" + q + "password" + q + ":" + q + "hunter2-from-vault" + q + "," + q + "user" + q + ":" + q + "app" + q + "}," + q + "metadata" + q + ":{" + q + "version" + q + ":3}}}"
	cV1 = "{" + q + "data" + q + ":{" + q + "key" + q + ":" + q + "sk_test_from_v1" + q + "}}"
	cSk = "{" + q + "data" + q + ":{" + q + "data" + q + ":{" + q + "key" + q + ":" + q + $cSealKey + q + "}}}"
	cDenied = "{" + q + "errors" + q + ":[" + q + "permission denied" + q + "]}"
	c = 'load "../../stzBase.ring"' + nl
	c += '$cVaultToken = "' + $cToken + '"' + nl
	c += '$oFakeVault = new stzAppServer()' + nl
	c += '$oFakeVault.Get_("/v1/sys/health", func oReq, oResp { oResp.Text("{}") })' + nl
	c += AddRoute("/v1/secret/data/prod/db", cV2, cDenied)
	c += AddRoute("/v1/kv1/app/stripe", cV1, cDenied)
	c += AddRoute("/v1/secret/data/prod/sealkey", cSk, cDenied)
	c += '$oFakeVault.Start(' + $nPort + ', "127.0.0.1")' + nl
	c += '$oFakeVault.RunFor(40000)' + nl
	c += '$oFakeVault.Stop()' + nl
	# ABSOLUTE paths: the child does not start in this folder
	cScript = currentdir() + "/_tmp_fakevault_gen.ring"
	c = StzReplace(c, 'load "../../stzBase.ring"', 'load "' + currentdir() + '/../../stzBase.ring"')
	write(cScript, c)
	return $oSpawner.SubmitSpawn([ exefilename(), cScript ])

func AddRoute cPath, cOk, cDenied
	nl = char(10)
	return '$oFakeVault.Get_("' + cPath + '", func oReq, oResp {' + nl +
		'    if oReq.Header("X-Vault-Token") = $cVaultToken  oResp.Text(' + "'" + cOk + "'" + ')' + nl +
		'    else  oResp.Status(403, "Forbidden").Text(' + "'" + cDenied + "'" + ')  ok })' + nl

# Readiness through a RAW TCP request, not stzHttpClient: the engine's HTTP
# pool ejects a host after failed connections, so polling a server that is
# still starting through it keeps failing after the server is up.
func WaitVault nTimeoutMs
	cReq = "GET /v1/sys/health HTTP/1.1" + char(13) + char(10) + "Host: local" + char(13) + char(10) +
		"Connection: close" + char(13) + char(10) + char(13) + char(10)
	nEnd = StzEngineTimeNowMs() + nTimeoutMs
	while StzEngineTimeNowMs() < nEnd
		nJ = $oSpawner.SubmitTcp("127.0.0.1", $nPort, cReq)
		if StzFindFirst("200 OK", $oSpawner.AwaitTcp(nJ, 1500)) > 0  return 1  ok
		StzEngineTimeSleepMs(250)
	end
	return 0
