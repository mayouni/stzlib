load "../../stzBase.ring"
load "../_narrated.ring"

# PY3 of the payments plane, part two: THE SECRETS A LIVE PAYMENT NEEDS, AND THEIR EXPIRY.
#
# A live payment through a participant's API Business needs five things nobody may keep in a
# versioned file: the OAuth client credentials, the API key, the private key and certificate
# of the mTLS client identity (from the BCEAO's CA, valid 365 days in the sandbox), and the HMAC
# secret of each webhook. They live in the secret store, under names that say whose they are,
# and the ones that EXPIRE are watched: an expiring certificate is the outage nobody schedules.
#
# EXPIRY IS A DETECTION, NOT A CHECK AT CALL TIME. The port does not look at dates; the store
# knows them, a watch writes what it finds into the security ledger, and a detection raises it.
# The portal's own guidance is an alert under 30 days.
#
# No credential, test or real, is written in this file: every secret below is GENERATED here.

nNow = 1791190800                       # 2026-10-05T09:00:00Z, the twin's clock
nDay = 86400

Scenario("five secrets, named for whose they are")
	Then("a name says the participant and the part", StzPispiSecretName("BIA", "mtls-cert"), "pispi-bia-mtls-cert")
	Then("the five parts are the five things a live payment needs", len(StzPispiSecretParts()), 5)
	Then("...the OAuth client", StzFindFirst("client", @@(StzPispiSecretParts())) > 0, TRUE)
	Then("...the API key", StzFindFirst("api-key", @@(StzPispiSecretParts())) > 0, TRUE)
	Then("...the private key", StzFindFirst("mtls-key", @@(StzPispiSecretParts())) > 0, TRUE)
	Then("...the certificate", StzFindFirst("mtls-cert", @@(StzPispiSecretParts())) > 0, TRUE)
	Then("...and the webhook secret", StzFindFirst("webhook-secret", @@(StzPispiSecretParts())) > 0, TRUE)

	aD = StzPispiDescriptors("bia")
	Then("a participant gets five descriptors", len(aD), 5)
	Then("...each named for the participant", aD[1].Name(), "pispi-bia-client")
	Then("...of its own kind", aD[4].Kind(), "pispi-mtls-cert")
	Then("...and none of them holds a value yet", aD[2].SourceKind(), "unset")

	oStore = StzSecretStoreQ("diko")
	StzPispiRegisterDescriptors(oStore, "bia")
	Then("the store lists all five by name", oStore.NumberOfSecrets(), 5)
	Then("...a platform's whole credential surface for BIA", oStore.Has("pispi-bia-webhook-secret"), TRUE)

	bRaised = FALSE
	try
		oBad = StzPispiSecretQ("bia", "password")
	catch
		bRaised = TRUE
	done
	Then("a part that is not one of the five is refused", bRaised, TRUE)
EndScenario()

Scenario("a value is revealed only to an actor who may, and never shows in a descriptor")
	oStore = StzSecretStoreQ("diko")
	cValue = StzEngineCryptoRandomHex(16)
	oKey = StzPispiSecretQ("bia", "api-key")
	oKey.FromLiteral(cValue)
	oStore.Register(oKey)
	oHuman = HumanActor("dana")
	oLlm = LLMActor("assistant")
	Then("the descriptor never contains the value", StzFindFirst(cValue, oStore.DescriptorOf("pispi-bia-api-key")), 0)
	Then("...nor does the store's report", StzFindFirst(cValue, oKey.Masked()), 0)
	Then("an effectful actor may reveal it", oStore.Reveal("pispi-bia-api-key", oHuman), cValue)
	bRefused = FALSE
	try
		oStore.Reveal("pispi-bia-api-key", oLlm)
	catch
		bRefused = TRUE
	done
	Then("an LLM actor may not", bRefused, TRUE)
	Then("...and the refusal is on the store's access log", oStore.RefusedAccesses(), 1)
EndScenario()

Scenario("expiry is WATCHED, and the ledger raises it")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	oStore = StzSecretStoreQ("diko")

	oCert = StzPispiSecretQ("bia", "mtls-cert")
	oCert.FromLiteral(StzEngineCryptoRandomHex(16))
	oCert.SetExpiry(nNow + 10 * nDay)
	oStore.Register(oCert)
	oHook = StzPispiSecretQ("bia", "webhook-secret")
	oHook.FromLiteral(StzEngineCryptoRandomHex(16))
	oHook.SetExpiry(nNow + 400 * nDay)
	oStore.Register(oHook)
	oApi = StzPispiSecretQ("bia", "api-key")
	oApi.FromLiteral(StzEngineCryptoRandomHex(16))
	oApi.SetExpiry(nNow - 3 * nDay)
	oStore.Register(oApi)
	oCli = StzPispiSecretQ("bia", "client")
	oCli.FromLiteral(StzEngineCryptoRandomHex(16))
	oStore.Register(oCli)

	oWatch = StzSecretExpiryWatchQ(oStore)
	oWatch.WarnWithinDays(30)
	oWatch.AsOf(nNow)
	Then("a watch is a periodic thing and says its name", oWatch.Name_(), "secret-expiry")
	Then("one cycle finds the two that matter", oWatch.Cycle(), 2)
	Then("...a certificate under 30 days is EXPIRING", len(oLed.OfKind("secret.expiring")), 1)
	Then("...an API key already past its date is EXPIRED", len(oLed.OfKind("secret.expired")), 1)
	Then("...and a secret with 400 days left, or none, is left alone", oLed.Count(), 2)

	oSet = StzPaymentsDetectionSet()
	aF = oSet.CheckAgainst(oLed)
	Then("the detections raise them in the house shape", len(aF), 2)
	aE = FindingOf(aF, "secret-expired")
	aW = FindingOf(aF, "secret-expiring")
	Then("the expired one is an ERROR", pzVal(aE, "severity"), "error")
	Then("...naming the secret", StzFindFirst("pispi-bia-api-key", pzVal(aE, "where")) > 0, TRUE)
	Then("the expiring one is a WARNING", pzVal(aW, "severity"), "warning")
	Then("...naming the certificate", StzFindFirst("pispi-bia-mtls-cert", pzVal(aW, "where")) > 0, TRUE)
	Then("...and the subject is security, so it joins the one CI gate", pzVal(aW, "subject"), "security")

	Then("a second cycle announces nothing twice", oWatch.Cycle(), 0)
	Then("...so the ledger still holds two", oLed.Count(), 2)

	When("the certificate is renewed by registering its successor")
	oNew = StzPispiSecretQ("bia", "mtls-cert")
	oNew.FromLiteral(StzEngineCryptoRandomHex(16))
	oNew.SetExpiry(nNow + 365 * nDay)
	oStore.Rotate(oNew)
	oWatch.Watch(oStore)           # Ring copied the store when the watch was built: hand it the current one
	Then("the watch has nothing to say", oWatch.Cycle(), 0)

	When("time passes: fifteen days later the webhook secret is still fine, the new certificate too")
	oWatch.AsOf(nNow + 15 * nDay)
	Then("nothing new", oWatch.Cycle(), 0)
	When("and 350 days later the renewed certificate is inside its last month")
	oWatch.AsOf(nNow + 350 * nDay)
	Then("it is announced once, and the webhook secret (50 days left) is not", oWatch.Cycle(), 1)
	Then("...as expiring, the second time the ledger heard it", len(oLed.OfKind("secret.expiring")), 2)
	StzCloseSecurityLedger()
EndScenario()

Scenario("sealed at rest, a descriptor keeps its kind and its expiry")
	cStore = "_py3_secrets_store.tmp"
	oKey = StzSecretQ("master-key")
	oKey.FromLiteral(StzNewSealKey())
	oStore = StzSecretStoreQ("diko")
	oCert = StzPispiSecretQ("bia", "mtls-cert")
	oCert.FromLiteral("CERT-" + StzEngineCryptoRandomHex(8))
	oCert.SetExpiry(nNow + 365 * nDay)
	oStore.Register(oCert)
	oHuman = HumanActor("dana")
	oStore.SaveSealedTo(cStore, oKey, oHuman)
	oBack = StzSecretStoreFromSealedFile(cStore, oKey, oHuman)
	Then("the descriptor came back", oBack.Has("pispi-bia-mtls-cert"), TRUE)
	Then("...of its own kind", oBack.Secret("pispi-bia-mtls-cert").Kind(), "pispi-mtls-cert")
	Then("...with the expiry it had", oBack.Secret("pispi-bia-mtls-cert").ExpiresAt(), nNow + 365 * nDay)
	Then("...and an expiry survives, so the watch still works after a restart", oBack.Secret("pispi-bia-mtls-cert").IsExpiredAt(nNow + 366 * nDay), TRUE)
	if fexists(cStore)  remove(cStore)  ok
EndScenario()

Summary()

# --- helpers -------------------------------------------------------------

func pzVal(aList, cKey)
	return _StzPiGet(aList, cKey, "")

func FindingOf(aFindings, cRule)
	for i = 1 to len(aFindings)
		if pzVal(aFindings[i], "rule") = cRule
			return aFindings[i]
		ok
	next
	return []
