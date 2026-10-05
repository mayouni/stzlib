load "../../stzBase.ring"
load "../_narrated.ring"

# PY3 of the payments plane, part one: A WEBHOOK IS VERIFIED BEFORE IT IS BELIEVED.
#
# The hub tells the platform that money moved by POSTing an event to a callback URL. Anyone who
# can reach that URL can POST too, so the event carries X-Signature, the HMAC-SHA256 of its body
# under a secret the hub returned once. A platform that believes an unsigned event will ship
# goods for a payment that never happened.
#
# THE VERIFIER LIVES ON stzRequestSigner, beside the canonical-string form the grid already
# uses, because it is the same job (a keyed MAC, compared in constant time, with a replay
# cache and a ledger line for every refusal) over a different message. The HMAC runs in the
# engine; there is no Ring-side cryptography here.
#
# FOUR REFUSALS, each a different attacker and each written to the security ledger, because a
# refusal nobody can read later is a refusal nobody can learn from:
#     unsigned        no signature at all
#     forged          a signature that does not recompute (tampered body, or wrong secret)
#     replayed        a body already believed, presented again
#     malformed       signed correctly, and not an event envelope
#
# No secret is written in this file: the twin generates them.

Scenario("the body-only form: the MAC of the raw body under the key's secret")
	oS = new stzRequestSigner("webhooks")
	oS.AddKey("hook-1", "key")
	cMsg = "The quick brown fox jumps over the lazy dog"
	Then("it is HMAC-SHA256 in hex, matching the published vector",
		oS.SignBody("hook-1", cMsg), "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")
	cSig = oS.SignBody("hook-1", cMsg)
	Then("a body verifies against its own signature", oS.VerifyBody("hook-1", cMsg, cSig), TRUE)
	Then("a body changed by one character does not", oS.VerifyBody("hook-1", cMsg + ".", cSig), FALSE)
	Then("...and says why", StzFindFirst("mismatch", oS.Why()) > 0, TRUE)
	Then("a signature of the right length and the wrong value does not",
		oS.VerifyBody("hook-1", cMsg, StzReplace(cSig, "f7bc", "0000")), FALSE)
	Then("an empty signature is UNSIGNED", oS.VerifyBody("hook-1", cMsg, ""), FALSE)
	Then("...and says so", oS.Why(), "unsigned")
	Then("a key the signer does not hold verifies nothing", oS.VerifyBody("ghost", cMsg, cSig), FALSE)

	bRaised = FALSE
	try
		oS.SignBody("ghost", cMsg)
	catch
		bRaised = TRUE
	done
	Then("and nobody can sign as a key it holds no secret for", bRaised, TRUE)
EndScenario()

Scenario("which of several secrets signed it -- and ONE ledger line when none did")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	oS = new stzRequestSigner("webhooks")
	oS.AddKey("hook-old", "secret-one")
	oS.AddKey("hook-new", "secret-two")
	cBody = '{"data":[{"evCode":"PAIEMENT_RECU","end2endId":"E1","evDate":"d1"}],"meta":{"total":1}}'
	nNow = 1000000

	Then("an event signed with the OLD secret is believed and names it",
		oS.VerifyWebhook(cBody, oS.SignBody("hook-old", cBody), nNow, 60000), "hook-old")
	cBody2 = '{"data":[{"evCode":"PAIEMENT_RECU","end2endId":"E2","evDate":"d2"}],"meta":{"total":1}}'
	Then("one signed with the NEW secret is believed too", oS.VerifyWebhook(cBody2, oS.SignBody("hook-new", cBody2), nNow, 60000), "hook-new")
	Then("nothing was written to the ledger for the honest ones", oLed.Count(), 0)

	Then("a forged signature is refused", oS.VerifyWebhook(cBody2, "00ff00ff", nNow + 1, 60000), "")
	Then("...with ONE ledger line, not one per key it was tried against", len(oLed.OfKind("webhook.signature.forged")), 1)
	aForged = oLed.OfKind("webhook.signature.forged")
	Then("...naming the signer that refused it", aForged[1][:actor], "webhooks")

	Then("an unsigned event is refused", oS.VerifyWebhook(cBody2, "", nNow + 2, 60000), "")
	Then("...and noted as unsigned", len(oLed.OfKind("webhook.unsigned")), 1)

	cSigRe = oS.SignBody("hook-new", cBody2)
	Then("the same body presented again inside the window is a replay", oS.VerifyWebhook(cBody2, cSigRe, nNow + 3, 60000), "")
	Then("...says so", StzFindFirst("replay", oS.Why()) > 0, TRUE)
	Then("...and noted as replayed", len(oLed.OfKind("webhook.replayed")), 1)
	Then("outside the window it is a fresh delivery again", oS.VerifyWebhook(cBody2, cSigRe, nNow + 200000, 60000), "hook-new")

	oSet = StzPaymentsDetectionSet()
	aFired = oSet.FiredNames(oLed)
	Then("the detections raise the three signals", len(aFired), 3)
	Then("...forged is one", ring_find(aFired, "forged-webhook") > 0, TRUE)
	Then("...replayed another", ring_find(aFired, "replayed-webhook") > 0, TRUE)
	Then("...unsigned the third", ring_find(aFired, "unsigned-webhook") > 0, TRUE)
	aF = oSet.CheckAgainst(oLed)
	Then("a forged webhook is an ERROR", pzSeverity(aF, "forged-webhook"), "error")
	Then("a replayed one is an ERROR", pzSeverity(aF, "replayed-webhook"), "error")
	Then("an unsigned one is a WARNING: a probe, not yet a break-in", pzSeverity(aF, "unsigned-webhook"), "warning")
	StzCloseSecurityLedger()
EndScenario()

Scenario("the port verifies through the signer, and the hub's secret never leaves the port")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	cSecret = oHub.LastWebhookSecret()

	oOrder = StzPaymentOrderQ()
	oOrder.WithTxId("WH-1")
	oOrder.FromAlias(oHub.BusinessAlias())
	oOrder.ToAlias(oHub.Alias("fatou"))
	oOrder.WithAmount(StzAmountQ("5000", "XOF"))
	oOrder.WithoutConfirmation()
	oPay.Pay(oOrder)
	oHub.AdvanceSeconds(25)
	cBody = oHub.LastCallbackBody()
	cSig = oHub.LastCallbackSignature()

	aOk = oPay.ReceiveWebhook(cBody, cSig)
	Then("the hub's own delivery is accepted", aOk["accepted"], 1)
	Then("...answering the 204 the hub expects", aOk["status"], 204)
	Then("...and the ledger heard nothing, there was nothing to report", oLed.Count(), 0)

	Then("the same delivery again is refused as a replay", oPay.ReceiveWebhook(cBody, cSig)["reason"], "replay")
	Then("...and the ledger heard it", len(oLed.OfKind("webhook.replayed")), 1)

	Then("a tampered body is refused as a bad signature", oPay.ReceiveWebhook(StzReplace(cBody, "5000", "9000"), cSig)["reason"], "bad-signature")
	Then("an unsigned event is refused", oPay.ReceiveWebhook(cBody, "")["reason"], "unsigned")
	Then("a signature under a guessed secret is refused", oPay.ReceiveWebhook(cBody, StzWebhookSignature(cBody, "guess"))["reason"], "bad-signature")
	Then("the ledger heard the forgeries: two", len(oLed.OfKind("webhook.signature.forged")), 2)
	Then("...and the unsigned one", len(oLed.OfKind("webhook.unsigned")), 1)

	When("the hub re-signs the SAME event in a different envelope (a retry that reformats)")
	cRe = StzReplace(cBody, '"meta"', ' "meta"')
	aRe = oPay.ReceiveWebhook(cRe, StzWebhookSignature(cRe, cSecret))
	Then("the signature is valid, and the EVENT is still seen once only", aRe["reason"], "replay")
	Then("...and the platform's handler believed one event in all", len(oPay.Events()), 1)

	When("a body that is signed correctly but is not an event envelope arrives")
	cJunk = "not json at all"
	aJ = oPay.ReceiveWebhook(cJunk, StzWebhookSignature(cJunk, cSecret))
	Then("it is refused as malformed", aJ["reason"], "malformed")
	Then("...and noted", len(oLed.OfKind("webhook.malformed")), 1)
	cEmpty = '{"data":[],"meta":{"total":0}}'
	Then("an envelope with no event is malformed too", oPay.ReceiveWebhook(cEmpty, StzWebhookSignature(cEmpty, cSecret))["reason"], "malformed")
	Then("the port kept every refusal, in order", len(oPay.RefusedWebhooks()), 7)
	StzCloseSecurityLedger()
EndScenario()

Scenario("the secret comes from the store, through the governed door")
	oHub = StzPiSpiSandboxQ()
	oSetup = StzPaymentsPortQ(oHub)
	oSetup.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	cSecret = oHub.LastWebhookSecret()

	oStore = StzSecretStoreQ("diko")
	oSec = StzPispiSecretQ("bia", "webhook-secret")
	oSec.FromLiteral(cSecret)
	oStore.Register(oSec)
	oHuman = HumanActor("dana")
	oLlm = LLMActor("assistant")

	oPort = StzPaymentsPortQ(oHub)
	oOrder = StzPaymentOrderQ()
	oOrder.WithTxId("WH-2")
	oOrder.FromAlias(oHub.BusinessAlias())
	oOrder.ToAlias(oHub.Alias("fatou"))
	oOrder.WithAmount(StzAmountQ("1000", "XOF"))
	oOrder.WithoutConfirmation()
	oSetup.Pay(oOrder)
	oHub.AdvanceSeconds(25)
	cBody = oHub.LastCallbackBody()
	cSig = oHub.LastCallbackSignature()

	Then("a port that was never given the secret believes nothing", oPort.ReceiveWebhook(cBody, cSig)["reason"], "bad-signature")
	bRefused = FALSE
	try
		oPort.UseWebhookSecretFrom(oStore, "pispi-bia-webhook-secret", oLlm)
	catch
		bRefused = TRUE
	done
	Then("an LLM actor cannot load it", bRefused, TRUE)
	Then("...and the store logged the refusal", oStore.RefusedAccesses(), 1)
	Then("an effectful actor can", oPort.UseWebhookSecretFrom(oStore, "pispi-bia-webhook-secret", oHuman) != "", TRUE)
	Then("...and that reveal is on the store's access log too", oStore.NumberOfAccesses(), 2)
	Then("now the hub's delivery is believed", oPort.ReceiveWebhook(cBody, cSig)["accepted"], 1)

	bMissing = FALSE
	try
		oPort.UseWebhookSecretFrom(oStore, "pispi-bia-no-such-secret", oHuman)
	catch
		bMissing = TRUE
	done
	Then("naming a secret the store does not hold raises", bMissing, TRUE)
EndScenario()

Summary()

# --- helpers -------------------------------------------------------------

func pzSeverity(aFindings, cRule)
	for i = 1 to len(aFindings)
		if _StzPiGet(aFindings[i], "rule", "") = cRule
			return _StzPiGet(aFindings[i], "severity", "")
		ok
	next
	return ""
