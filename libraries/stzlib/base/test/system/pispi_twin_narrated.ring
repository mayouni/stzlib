load "../../stzBase.ring"
load "../_narrated.ring"

# PY2 of the payments plane: THE TWIN OF THE HUB, AND THE PORT THAT SPEAKS ITS VERBS.
#
# A platform that pays through Softanza must meet the same contract in test and in production,
# so the twin implements the REST contract of the BCEAO's API Business v1.5.0 in-process, and
# the port speaks its verbs to it through ONE method, Request(method, path, query, body).
#
# WHAT THIS GUARD REFUSES TO ACCEPT, each a thing a permissive fake would let through:
#   * a payment that is final the instant it is sent (the hub's is pending for 20 seconds)
#   * a txId replay that pays twice, or that the hub answers with the first state (it answers
#     DU03; it is the PORT's journal that returns the first state)
#   * a field the schema does not know (the reference says additionalProperties: false)
#   * a cancellation treated as a refund, or as idempotent
#   * a webhook that is believed before its signature is checked
#
# Every figure below is in francs CFA, the only currency of the hub, and the platform starts
# with 50,000,000 virtual francs.

Scenario("the twin is a sandbox, and its clock is its own")
	oHub = StzPiSpiSandboxQ()
	Then("it declares itself a sandbox", oHub.IsSandbox(), 1)
	Then("its clock starts where the guard says it does", oHub.Now(), "2026-10-05T09:00:00.000Z")
	oPay = StzPaymentsPortQ(oHub)
	Then("a port over the twin is a sandbox too", oPay.IsSandbox(), 1)
	Then("the platform starts with 50 000 000 virtual francs", oHub.Balance(), 50000000)

	bRaised = FALSE
	try
		oBad = StzPaymentsPortQ("not a backend")
	catch
		bRaised = TRUE
	done
	Then("a port refuses a backend that cannot Request()", bRaised, TRUE)

	oHub.AdvanceSeconds(44290799)
	Then("the clock crosses a leap day without a slip", oHub.Now(), "2028-02-29T23:59:59.000Z")
	oHub.AdvanceSeconds(1)
	Then("...and rolls into March", oHub.Now(), "2028-03-01T00:00:00.000Z")
EndScenario()

Scenario("a payment is PENDING, then final -- and the money leaves at SEND")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	aR = oPay.Pay( MkOrder(oHub, "T-1", "fatou", 150000) )
	Then("the hub's own word is the state: ENVOYE", aR["statut"], "ENVOYE")
	Then("...which is NOT final", oPay.IsFinal(aR["statut"]), FALSE)
	Then("the hub names the payee it found", aR["payeNom"], "Fatou Diop")
	Then("...and her country", aR["payePays"], "SN")
	Then("the end2endId is 35 characters, like the reference's", len(aR["end2endId"]), 35)
	Then("...starting with E", left(aR["end2endId"], 1), "E")
	Then("the money has already left the balance", oHub.Balance(), 49850000)
	Then("the order was not replayed", aR["replayed"], 0)

	oHub.AdvanceSeconds(10)
	Then("ten seconds later it is still pending", pzVal(oPay.StatusOf(aR["end2endId"]), "statut"), "ENVOYE")
	oHub.AdvanceSeconds(15)
	aS = oPay.StatusOf(aR["end2endId"])
	Then("after twenty seconds the hub has decided: IRREVOCABLE", aS["statut"], "IRREVOCABLE")
	Then("...and that IS final", oPay.IsFinal(aS["statut"]), TRUE)
	Then("...with the date it became irrevocable", len(aS["dateIrrevocabilite"]) > 0, TRUE)
	Then("the balance did not move again", oHub.Balance(), 49850000)

	When("the same payment is read by its txId")
	Then("the sent payment answers the same end2endId", pzVal(oPay.SentPayment("T-1"), "end2endId"), aR["end2endId"])
	Then("...and it is not among the received ones", len(oPay.ReceivedPayments([])), 0)
EndScenario()

Scenario("TxId is the platform's idempotency key")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oOrder = MkOrder(oHub, "T-REPLAY", "fatou", 5000)
	aA = oPay.Pay(oOrder)
	aB = oPay.Pay(oOrder)
	Then("a re-submission through the port is a replay", aB["replayed"], 1)
	Then("...answering the same end2endId", aB["end2endId"], aA["end2endId"])
	Then("...and the hub received ONE payment, not two", oHub.NumberOfPayments("ENVOYE"), 1)
	Then("...so the money left once", oHub.Balance(), 49995000)
	Then("the journal holds one entry", oPay.JournalSize(), 1)

	oHub.AdvanceSeconds(25)
	aC = oPay.Pay(oOrder)
	Then("a replay after settlement answers the CURRENT state", aC["statut"], "IRREVOCABLE")
	Then("...and still pays nothing", oHub.Balance(), 49995000)

	When("the same txId reaches the HUB directly, bypassing the journal")
	aRaw = oHub.Request("POST", "/paiements-envoyes", [], oOrder.AsBody())
	Then("the hub answers 200", aRaw[1], 200)
	Then("...but REJECTS it: its answer is not the first state", aRaw[2]["statut"], "REJETE")
	Then("...with DU03, the txId is not unique", aRaw[2]["statutRaison"], "DU03")
	Then("...and the original is untouched, still one payment", oHub.NumberOfPayments("ENVOYE"), 1)
	Then("DU03 means what the reference says", StzPaymentsReasonMeaning("DU03"), "the txId is not unique")
EndScenario()

Scenario("the customer's side may reject, and the money comes back")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	aR = oPay.Pay( MkOrder(oHub, "T-BLK", "blocked", 80000) )
	Then("it is accepted for sending", aR["statut"], "ENVOYE")
	Then("...and debited", oHub.Balance(), 49920000)
	oHub.AdvanceSeconds(25)
	aS = oPay.StatusOf(aR["end2endId"])
	Then("the payee's participant rejects it", aS["statut"], "REJETE")
	Then("...with the blocked-account reason", aS["statutRaison"], "AC06")
	Then("...which the port can explain", oPay.ReasonMeaning(aS["statutRaison"]), "blocked account")
	Then("the money is back", oHub.Balance(), 50000000)
EndScenario()

Scenario("verification refuses before anything is sent")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	aU = oPay.Pay( MkOrder(oHub, "T-NOBODY", "nobody-has-this-alias", 1000) )
	Then("an unknown alias is REJETE at once", aU["statut"], "REJETE")
	Then("...with BE23, an invalid payee", aU["statutRaison"], "BE23")
	Then("...and nothing was debited", oHub.Balance(), 50000000)

	oIban = StzPaymentOrderQ().WithTxId("T-IBAN").FromAlias(oHub.BusinessAlias()).ToIban("ZZ00NOSUCHIBAN", "SNB015").WithAmount(StzAmountQ("1000", "XOF")).WithoutConfirmation()
	aI = oPay.Pay(oIban)
	Then("an unknown IBAN is REJETE with AC01, no such account", aI["statutRaison"], "AC01")

	oOk = StzPaymentOrderQ().WithTxId("T-IBAN2").FromAlias(oHub.BusinessAlias()).ToIban("SN0150101307430029018", "SNB015").WithAmount(StzAmountQ("1000", "XOF")).WithoutConfirmation()
	Then("a known IBAN is paid through its participant", pzVal(oPay.Pay(oOk), "statut"), "ENVOYE")

	aF = oPay.Pay( MkOrder(oHub, "T-BROKE", "kdi", 60000000) )
	Then("more than the balance is REJETE with AG07", aF["statutRaison"], "AG07")
	Then("...and the balance is untouched by it", oHub.Balance(), 49999000)

	bBig = FALSE
	oHub2 = StzPiSpiSandboxQ()
	oPay2 = StzPaymentsPortQ(oHub2)
	try
		oPay2.Pay( MkOrder(oHub2, "T-HUGE", "fatou", 20000000) )
	catch
		bBig = TRUE
	done
	Then("above the ceiling for a person it is a 403 PROBLEM, not a rejected payment", bBig, TRUE)
	oP = StzLastPaymentsProblem()
	Then("...status 403", oP.Status(), 403)
	Then("...titled Forbidden", oP.Title(), "Forbidden")
	Then("...saying the ceiling was exceeded", oP.Detail(), "Plafond de paiement depasse")
	Then("...and naming the field in invalid-params", pzVal(pzNth(oP.InvalidParams(), 1), "name"), "montant")
	Then("a business may receive up to 100 000 000", pzVal(oPay2.Pay( MkOrder(oHub2, "T-OKB", "kdi", 30000000) ), "statut"), "ENVOYE")
EndScenario()

Scenario("the schema is the law: an unknown or missing field is a 400")
	oHub = StzPiSpiSandboxQ()
	aOk = [ ["txId", "S-1"], ["payeurAlias", oHub.BusinessAlias()], ["payeAlias", oHub.Alias("fatou")], ["montant", 5000], ["confirmation", 0] ]

	aDev = aOk
	aDev + ["devise", "XOF"]
	aR = oHub.Request("POST", "/paiements-envoyes", [], aDev)
	Then("a field the reference does not know (devise) is refused", aR[1], 400)
	Then("...as an RFC 7807 problem about:blank", aR[2]["type"], "about:blank")
	Then("...naming the field", aR[2]["invalid-params"][1]["name"], "devise")

	aNoTx = [ ["payeurAlias", oHub.BusinessAlias()], ["payeAlias", oHub.Alias("fatou")], ["montant", 5000], ["confirmation", 0] ]
	Then("a missing txId is a 400", pzNth(oHub.Request("POST", "/paiements-envoyes", [], aNoTx), 1), 400)

	aFrac = [ ["txId", "S-2"], ["payeurAlias", oHub.BusinessAlias()], ["payeAlias", oHub.Alias("fatou")], ["montant", 50.5], ["confirmation", 0] ]
	Then("a fractional franc is a 400", pzNth(oHub.Request("POST", "/paiements-envoyes", [], aFrac), 1), 400)
	aNeg = [ ["txId", "S-3"], ["payeurAlias", oHub.BusinessAlias()], ["payeAlias", oHub.Alias("fatou")], ["montant", 0], ["confirmation", 0] ]
	Then("a zero amount is a 400", pzNth(oHub.Request("POST", "/paiements-envoyes", [], aNeg), 1), 400)

	aTwo = aOk
	aTwo[1][2] = "S-4"
	aTwo + ["payeIban", "SN0150101307430029018"]
	Then("two routes to the payee at once is a 400", pzNth(oHub.Request("POST", "/paiements-envoyes", [], aTwo), 1), 400)

	aNoConf = [ ["txId", "S-5"], ["payeurAlias", oHub.BusinessAlias()], ["payeAlias", oHub.Alias("fatou")], ["montant", 5000] ]
	Then("confirmation is required by the schema", pzNth(oHub.Request("POST", "/paiements-envoyes", [], aNoConf), 1), 400)
	Then("nothing was stored by any of them", oHub.NumberOfPayments("ENVOYE"), 0)

	Then("an unknown route is a 404 problem", pzNth(oHub.Request("GET", "/virements", [], []), 1), 404)

	bEur = FALSE
	oPay = StzPaymentsPortQ(oHub)
	try
		oE = StzPaymentOrderQ().WithTxId("E-1").FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias("fatou")).WithAmount(StzAmountQ("12.50", "EUR")).WithoutConfirmation()
	catch
		bEur = TRUE
	done
	Then("the port's order refuses euros: the hub speaks XOF only", bEur, TRUE)

	bNoTx = FALSE
	try
		oPay.Pay( StzPaymentOrderQ().FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias("fatou")).WithAmount(StzAmountQ("1", "XOF")).WithoutConfirmation() )
	catch
		bNoTx = TRUE
	done
	Then("an order without a txId never leaves the platform", bNoTx, TRUE)
EndScenario()

Scenario("two-step confirmation: INITIE, then a decision that is final")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	aR = oPay.Pay( MkOrderConfirm(oHub, "C-1", "fatou", 20000) )
	Then("the hub asks first: INITIE", aR["statut"], "INITIE")
	Then("...having found the payee's name", aR["payeNom"], "Fatou Diop")
	Then("...and nothing is debited yet", oHub.Balance(), 50000000)

	aC = oPay.ConfirmPayment("C-1", TRUE)
	Then("confirming sends it: ENVOYE", aC["statut"], "ENVOYE")
	Then("...and debits it", oHub.Balance(), 49980000)
	Then("confirming again is idempotent: 200 with the current state", pzVal(oPay.ConfirmPayment("C-1", TRUE), "statut"), "ENVOYE")
	Then("...without debiting again", oHub.Balance(), 49980000)

	bLate = FALSE
	try
		oPay.ConfirmPayment("C-1", FALSE)
	catch
		bLate = TRUE
	done
	Then("cancelling after confirming is a 403", bLate, TRUE)
	Then("...saying it is already confirmed", StzLastPaymentsProblem().Detail(), "Impossible d'annuler un paiement deja confirme")

	oPay.Pay( MkOrderConfirm(oHub, "C-2", "fatou", 7000) )
	Then("declining a pending payment cancels it", pzVal(oPay.ConfirmPayment("C-2", FALSE), "statut"), "ANNULE")
	Then("...declining again is idempotent", pzVal(oPay.ConfirmPayment("C-2", FALSE), "statut"), "ANNULE")
	bBack = FALSE
	try
		oPay.ConfirmPayment("C-2", TRUE)
	catch
		bBack = TRUE
	done
	Then("confirming after declining is a 403", bBack, TRUE)
	Then("...saying it is already cancelled", StzLastPaymentsProblem().Detail(), "Impossible de confirmer un paiement deja annule")

	bGone = FALSE
	try
		oPay.ConfirmPayment("NO-SUCH", TRUE)
	catch
		bGone = TRUE
	done
	Then("an unknown txId is a 404", bGone, TRUE)
	Then("...with the status in the problem", StzLastPaymentsProblem().Status(), 404)

	oPay.Pay( MkOrderConfirm(oHub, "C-3", "fatou", 3000) )
	oHub.AdvanceSeconds(86401)
	bExpired = FALSE
	try
		oPay.ConfirmPayment("C-3", TRUE)
	catch
		bExpired = TRUE
	done
	Then("after 24 hours a confirmation is too late", bExpired, TRUE)
	Then("...says the 24-hour delay was exceeded", StzLastPaymentsProblem().Detail(), "Le delai de confirmation de 24 heures a ete depasse")
EndScenario()

Scenario("a webhook is signed by the hub and verified BEFORE it is believed")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi").OnEvents(["PAIEMENT_ENVOYE", "PAIEMENT_REJETE"]) )
	aHooks = oPay.Webhooks()
	Then("the hub holds one webhook", len(aHooks), 1)
	Then("...and its list never shows the secret", _StzPiHas(aHooks[1], "secret"), FALSE)
	cSecret = oHub.LastWebhookSecret()
	Then("the secret was returned once, at creation", len(cSecret) > 0, TRUE)

	aR = oPay.Pay( MkOrder(oHub, "W-1", "fatou", 5000) )
	Then("nothing is sent while the payment is pending", oHub.NumberOfDeliveries(), 0)
	oHub.AdvanceSeconds(25)
	Then("once final, exactly one event goes out", oHub.NumberOfDeliveries(), 1)
	cBody = oHub.LastCallbackBody()
	cSig = oHub.LastCallbackSignature()
	aEv = StzJsonToList(cBody)
	Then("it is a { data, meta } envelope", pzVal(pzVal(aEv, "meta"), "total"), 1)
	Then("the event says what happened", pzVal(pzNth(pzVal(aEv, "data"), 1), "evCode"), "PAIEMENT_ENVOYE")
	Then("...to which payment", pzVal(pzNth(pzVal(aEv, "data"), 1), "end2endId"), aR["end2endId"])
	Then("...for how much", pzVal(pzNth(pzVal(aEv, "data"), 1), "montant"), 5000)
	Then("...and for whom", pzVal(pzNth(pzVal(aEv, "data"), 1), "client"), "Fatou Diop")

	# a comparison proves SAMENESS, not rightness: the engine's HMAC is checked against a vector
	oVec = new stzStringCrypto("The quick brown fox jumps over the lazy dog")
	Then("the engine's HMAC-SHA256 matches the published vector",
		oVec.HmacSha256("key"), "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")
	oMac = new stzStringCrypto(cBody)
	Then("the X-Signature is the HMAC-SHA256 of the body under the secret", cSig, oMac.HmacSha256(cSecret))

	aOk = oPay.ReceiveWebhook(cBody, cSig)
	Then("a signed event is accepted", aOk["accepted"], 1)
	Then("...and the callback owes the hub a 204", aOk["status"], 204)
	Then("...and the port recorded it", len(oPay.Events()), 1)

	aReplay = oPay.ReceiveWebhook(cBody, cSig)
	Then("the same event again is a REPLAY and is refused", aReplay["reason"], "replay")
	Then("...with the 401 the hub expects", aReplay["status"], 401)

	cTamper = StzReplace(cBody, "5000", "5001")
	Then("a body altered in transit is refused", pzVal(oPay.ReceiveWebhook(cTamper, cSig), "reason"), "bad-signature")
	Then("an event under the wrong signature is refused", pzVal(oPay.ReceiveWebhook(cBody, "deadbeef"), "reason"), "bad-signature")
	Then("an unsigned event is refused", pzVal(oPay.ReceiveWebhook(cBody, ""), "reason"), "unsigned")
	oOther = StzPaymentsPortQ(oHub)
	Then("a port that was never given the secret refuses it too", pzVal(oOther.ReceiveWebhook(cBody, cSig), "reason"), "bad-signature")
	Then("the port logged what it refused", len(oPay.RefusedWebhooks()), 4)
	Then("...and delivered nothing it refused", len(oPay.Events()), 1)

	When("a rejection happens, the subscribed event is PAIEMENT_REJETE")
	oPay.Pay( MkOrder(oHub, "W-2", "blocked", 3000) )
	oHub.AdvanceSeconds(25)
	Then("the rejection is delivered", LastEv(oHub), "PAIEMENT_REJETE")
	Then("DeliverTo hands every undelivered event to a handler", oHub.DeliverTo(oPay), 2)
	Then("...which had seen the first and so believed only the new one: two events in all", len(oPay.Events()), 2)
	Then("...and refused the first as a replay", oPay.RefusedWebhooks()[5], "replay")
EndScenario()

Scenario("a request to pay is the payee's move; the payer decides")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	aR = oPay.RequestPayment( MkRtp(oHub, "R-1", "fatou", 25000, "401") )
	Then("the request is sent: ENVOYE", aR["statut"], "ENVOYE")
	Then("...in the invoice category", aR["categorie"], "401")
	Then("...to the payer the hub found", aR["payeurNom"], "Fatou Diop")
	Then("no money has moved", oHub.Balance(), 50000000)
	oHub.AdvanceSeconds(25)
	Then("the payer pays it: IRREVOCABLE", pzVal(oPay.RequestedPayment("R-1"), "statut"), "IRREVOCABLE")
	Then("...and the money arrives", oHub.Balance(), 50025000)
	Then("...as a RECEIVED payment of the same end2endId", pzVal(pzNth(oPay.ReceivedPayments([]), 1), "end2endId"), aR["end2endId"])
	Then("the platform is told: PAIEMENT_RECU", LastEv(oHub), "PAIEMENT_RECU")

	oPay.RequestPayment( MkRtp(oHub, "R-2", "blocked", 20000, "401") )
	oHub.AdvanceSeconds(25)
	aB = oPay.RequestedPayment("R-2")
	Then("a payer who refuses makes it REJETE", aB["statut"], "REJETE")
	Then("...with the reason ARFR, already refused", aB["statutRaison"], "ARFR")
	Then("...and the platform is told: RTP_REJETE", LastEv(oHub), "RTP_REJETE")
	Then("...with no money moved", oHub.Balance(), 50025000)

	aRe = oPay.RequestPayment( MkRtp(oHub, "R-1", "fatou", 25000, "401") )
	Then("a replay of a request answers the current state", aRe["replayed"], 1)
	Then("...and the hub kept one", len(oPay.Requests([])), 2)
	aRaw = oHub.Request("POST", "/demandes-paiements", [], MkRtp(oHub, "R-1", "fatou", 25000, "401").AsBody())
	Then("at the hub a repeated txId is REJETE / DU03", aRaw[2]["statutRaison"], "DU03")

	bCat = FALSE
	try
		oPay.RequestPayment( MkRtp(oHub, "R-3", "fatou", 1000, "999") )
	catch
		bCat = TRUE
	done
	Then("an unknown category is a 400", bCat, TRUE)
	oNoDate = StzPaymentRequestQ().WithTxId("R-4").FromAlias(oHub.Alias("fatou")).ToAlias(oHub.BusinessAlias()).WithAmount(StzAmountQ("1000", "XOF")).InCategory("521").WithoutConfirmation()
	bDate = FALSE
	try
		oPay.RequestPayment(oNoDate)
	catch
		bDate = TRUE
	done
	Then("an e-commerce request without its payment deadline is a 400", bDate, TRUE)
	oWrong = StzPaymentRequestQ().WithTxId("R-5").FromAlias(oHub.Alias("fatou")).ToAlias(oHub.Alias("kdi")).WithAmount(StzAmountQ("1000", "XOF")).InCategory("401").PayableBy("2026-10-31").WithoutConfirmation()
	bWho = FALSE
	try
		oPay.RequestPayment(oWrong)
	catch
		bWho = TRUE
	done
	Then("asking to be paid on somebody else's alias is a 400", bWho, TRUE)

	oPay.RequestPayment( MkRtpConfirm(oHub, "R-6", "fatou", 4000) )
	Then("a request may ask the hub to confirm first", pzVal(oPay.RequestedPayment("R-6"), "statut"), "INITIE")
	Then("confirming sends it", pzVal(oPay.ConfirmRequest("R-6", TRUE), "statut"), "ENVOYE")
	oPay.RequestPayment( MkRtpConfirm(oHub, "R-7", "fatou", 4000) )
	Then("declining cancels it", pzVal(oPay.ConfirmRequest("R-7", FALSE), "statut"), "ANNULE")
	bBack = FALSE
	try
		oPay.ConfirmRequest("R-7", TRUE)
	catch
		bBack = TRUE
	done
	Then("confirming a cancelled request is a 403", bBack, TRUE)
EndScenario()

Scenario("a request we RECEIVED: accepting pays it, and the answer is final")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	e1 = oHub.SimulateIncomingRequest("fatou", 25000, "Facture 77")
	Then("the platform is told: RTP_RECU", LastEv(oHub), "RTP_RECU")
	aIn = oPay.ReceivedRequests([ ["statut", "ENVOYE"] ])
	Then("one request is waiting", len(aIn), 1)
	Then("...from the sender the twin made up", pzVal(pzNth(aIn, 1), "end2endId"), e1)
	Then("...for 25 000", pzVal(pzNth(aIn, 1), "montant"), 25000)
	Then("...named", pzVal(pzNth(aIn, 1), "payeNom"), "Fatou Diop")

	aA = oPay.AnswerRequest(e1, TRUE, "")
	Then("accepting marks it IRREVOCABLE", aA["statut"], "IRREVOCABLE")
	Then("...and pays: a payment left the platform", oHub.NumberOfPayments("ENVOYE"), 1)
	Then("...debiting 25 000", oHub.Balance(), 49975000)
	Then("accepting again is idempotent", pzVal(oPay.AnswerRequest(e1, TRUE, ""), "statut"), "IRREVOCABLE")
	Then("...and pays nothing twice", oHub.NumberOfPayments("ENVOYE"), 1)
	bFlip = FALSE
	try
		oPay.AnswerRequest(e1, FALSE, "AM09")
	catch
		bFlip = TRUE
	done
	Then("rejecting after accepting is a 403", bFlip, TRUE)
	Then("...saying it was already accepted", StzLastPaymentsProblem().Detail(), "Impossible de rejeter une demande de paiement deja acceptee")

	e2 = oHub.SimulateIncomingRequest("kdi", 9000, "Devis")
	aR = oPay.AnswerRequest(e2, FALSE, "AM09")
	Then("rejecting needs a reason and records it", aR["statutRaison"], "AM09")
	Then("...as REJETE", aR["statut"], "REJETE")
	Then("...and pays nothing", oHub.Balance(), 49975000)
	bBack = FALSE
	try
		oPay.AnswerRequest(e2, TRUE, "")
	catch
		bBack = TRUE
	done
	Then("accepting after rejecting is a 403", bBack, TRUE)

	e3 = oHub.SimulateIncomingRequest("fatou", 1000, "x")
	bNoWhy = FALSE
	try
		oPay.AnswerRequest(e3, FALSE, "")
	catch
		bNoWhy = TRUE
	done
	Then("a rejection without a valid reason is a 400", bNoWhy, TRUE)
	oHub.FailNextAnswer()
	oPay.AnswerRequest(e3, FALSE, "FR01")
	Then("when the hub refuses our answer the platform is told: RTP_REPONSE_REJETE", LastEv(oHub), "RTP_REPONSE_REJETE")
EndScenario()

Scenario("a return is a NEW movement, and it is idempotent")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	e = oHub.SimulateIncomingPayment("fatou", 40000, "Don")
	Then("a payment received raises the balance", oHub.Balance(), 50040000)
	Then("...and is told as PAIEMENT_RECU", LastEv(oHub), "PAIEMENT_RECU")
	aR = oPay.ReturnFunds(e)
	Then("returning it starts a return: INITIE", aR["retourStatut"], "INITIE")
	Then("...and the money leaves at once", oHub.Balance(), 50000000)
	Then("returning again changes nothing", pzVal(oPay.ReturnFunds(e), "retourStatut"), "INITIE")
	Then("...nor the balance", oHub.Balance(), 50000000)
	oHub.AdvanceSeconds(25)
	Then("the return becomes irrevocable", pzVal(oPay.StatusOf(e), "retourStatut"), "IRREVOCABLE")
	Then("...and the platform is told: RETOUR_ENVOYE", LastEv(oHub), "RETOUR_ENVOYE")
	Then("returning once more still answers IRREVOCABLE", pzVal(oPay.ReturnFunds(e), "retourStatut"), "IRREVOCABLE")
	Then("...without returning twice", oHub.Balance(), 50000000)

	aSent = oPay.Pay( MkOrder(oHub, "RET-1", "fatou", 1000) )
	bSent = FALSE
	try
		oPay.ReturnFunds(aSent["end2endId"])
	catch
		bSent = TRUE
	done
	Then("a payment WE sent cannot be returned by us", bSent, TRUE)
	Then("...it is not found, as the reference says", StzLastPaymentsProblem().Status(), 404)

	eOld = oHub.SimulateIncomingPayment("fatou", 2000, "Vieux")
	oHub.AdvanceSeconds(91 * 86400)
	bOld = FALSE
	try
		oPay.ReturnFunds(eOld)
	catch
		bOld = TRUE
	done
	Then("after 90 days a return is forbidden", bOld, TRUE)
	Then("...with the reference's own detail", StzLastPaymentsProblem().Detail(), "Delai de retour de fonds depasse")

	eBlk = oHub.SimulateIncomingPayment("blocked", 6000, "x")
	oPay.ReturnFunds(eBlk)
	oHub.AdvanceSeconds(25)
	aB = oPay.StatusOf(eBlk)
	Then("a return the other side rejects is REJETE", aB["retourStatut"], "REJETE")
	Then("...with its reason", aB["retourStatutRaison"], "AC06")
	Then("...and the platform is told: RETOUR_REJETE", LastEv(oHub), "RETOUR_REJETE")
	Then("a rejected return is sent again when asked again", pzVal(oPay.ReturnFunds(eBlk), "retourStatut"), "INITIE")
EndScenario()

Scenario("a cancellation is a REQUEST the payee may refuse -- and it is not idempotent")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	a1 = oPay.Pay( MkOrder(oHub, "CAN-1", "fatou", 30000) )
	bPend = FALSE
	try
		oPay.RequestCancellation(a1["end2endId"], "DUPL")
	catch
		bPend = TRUE
	done
	Then("a payment that is not yet irrevocable cannot be cancelled", bPend, TRUE)
	Then("...AG01 in the reference's words", StzLastPaymentsProblem().Detail(), "Transaction non irrevocable")
	oHub.AdvanceSeconds(25)

	aQ = oPay.RequestCancellation(a1["end2endId"], "DUPL")
	Then("a request is sent, nothing is refunded", aQ["annulationStatut"], "ENVOYE")
	Then("...with the motive we gave", aQ["annulationMotif"], "DUPL")
	Then("the money has not come back", oHub.Balance(), 49970000)
	oHub.AdvanceSeconds(25)
	aS = oPay.StatusOf(a1["end2endId"])
	Then("a payee who accepts makes it ACCEPTE", aS["annulationStatut"], "ACCEPTE")
	Then("...and returns the funds as a new movement", aS["retourStatut"], "IRREVOCABLE")
	Then("...so the money is back", oHub.Balance(), 50000000)
	Then("...and the platform is told: RETOUR_RECU", LastEv(oHub), "RETOUR_RECU")
	bTwice = FALSE
	try
		oPay.RequestCancellation(a1["end2endId"], "DUPL")
	catch
		bTwice = TRUE
	done
	Then("a payment already returned cannot be cancelled again", bTwice, TRUE)

	a2 = oPay.Pay( MkOrder(oHub, "CAN-2", "stubborn", 20000) )
	oHub.AdvanceSeconds(25)
	oPay.RequestCancellation(a2["end2endId"], "SVNR")
	oHub.AdvanceSeconds(25)
	aR = oPay.StatusOf(a2["end2endId"])
	Then("a payee who refuses makes it REJETE", aR["annulationStatut"], "REJETE")
	Then("...as the customer's decision", aR["annulationStatutRaison"], "CUST")
	Then("...so the money stays gone", oHub.Balance(), 49980000)
	Then("...and the platform is told: ANNULATION_REJETE", LastEv(oHub), "ANNULATION_REJETE")
	n1 = CountEv(oHub, "ANNULATION_REJETE")
	aAgain = oPay.RequestCancellation(a2["end2endId"], "SVNR")
	Then("asking again is a NEW request, not a replay", aAgain["annulationStatut"], "ENVOYE")
	oHub.AdvanceSeconds(25)
	Then("...refused again, and told again", CountEv(oHub, "ANNULATION_REJETE"), n1 + 1)

	bMotive = FALSE
	try
		oPay.RequestCancellation(a2["end2endId"], "ZZZZ")
	catch
		bMotive = TRUE
	done
	Then("an unknown motive is a 400", bMotive, TRUE)
	bGone = FALSE
	try
		oPay.RequestCancellation("NOPE", "DUPL")
	catch
		bGone = TRUE
	done
	Then("an unknown payment is a 404", bGone, TRUE)
EndScenario()

Scenario("a cancellation we RECEIVE: we may accept it (and return) or refuse it")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	e1 = oHub.SimulateIncomingPayment("fatou", 15000, "x")
	bNone = FALSE
	try
		oPay.AnswerCancellation(e1, TRUE)
	catch
		bNone = TRUE
	done
	Then("answering a request that was never made is a 404", bNone, TRUE)
	oHub.SimulateCancellationRequest(e1, "AM09")
	Then("the platform is told: ANNULATION_DEMANDE", LastEv(oHub), "ANNULATION_DEMANDE")
	Then("...and the payment shows the request", pzVal(oPay.StatusOf(e1), "annulationStatut"), "ENVOYE")
	aA = oPay.AnswerCancellation(e1, TRUE)
	Then("accepting records it", aA["annulationStatut"], "ACCEPTE")
	Then("...and starts the return", aA["retourStatut"], "INITIE")
	Then("...taking the money back out", oHub.Balance(), 50000000)
	Then("accepting twice is idempotent", pzVal(oPay.AnswerCancellation(e1, TRUE), "annulationStatut"), "ACCEPTE")
	bFlip = FALSE
	try
		oPay.AnswerCancellation(e1, FALSE)
	catch
		bFlip = TRUE
	done
	Then("refusing after accepting is a 403", bFlip, TRUE)

	e2 = oHub.SimulateIncomingPayment("kdi", 8000, "y")
	oHub.SimulateCancellationRequest(e2, "FRAD")
	aR = oPay.AnswerCancellation(e2, FALSE)
	Then("refusing records REJETE", aR["annulationStatut"], "REJETE")
	Then("...as the customer's decision", aR["annulationStatutRaison"], "CUST")
	Then("...and keeps the money", oHub.Balance(), 50008000)
	bBack = FALSE
	try
		oPay.AnswerCancellation(e2, TRUE)
	catch
		bBack = TRUE
	done
	Then("accepting after refusing is a 403", bBack, TRUE)

	e3 = oHub.SimulateIncomingPayment("fatou", 500, "z")
	oHub.SimulateCancellationRequest(e3, "DUPL")
	oHub.FailNextAnswer()
	oPay.AnswerCancellation(e3, FALSE)
	Then("when the hub refuses our answer the platform is told: ANNULATION_REPONSE_REJETE", LastEv(oHub), "ANNULATION_REPONSE_REJETE")
EndScenario()

Scenario("a bulk carries one instructionId, one txId per item, and answers 202")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oPay.Pay( MkOrder(oHub, "B-DUP", "fatou", 1000) )
	nBefore = oHub.Balance()
	oBatch = StzPaymentBatchQ().WithInstructionId("SAL-1").FromAlias(oHub.BusinessAlias()).Motive("Salaires octobre").WithConfirmation()
	oBatch.Add( MkOrder(oHub, "B-1", "fatou", 150000) )
	oBatch.Add( MkOrder(oHub, "B-DUP", "kdi", 200000) )
	oBatch.Add( MkOrder(oHub, "B-3", "nobody-has-this-alias", 1000) )
	aR = oPay.PayInBulk(oBatch)
	Then("a bulk with confirmation is INITIE", aR["statut"], "INITIE")
	Then("...with every item counted", aR["transactionsTotal"], 3)
	Then("...one valid, awaiting confirmation", aR["transactionsInitiees"], 1)
	Then("...two rejected by the hub's own checks", aR["transactionsRejetees"], 2)
	Then("nothing has been debited yet", oHub.Balance(), nBefore)

	aItems = oPay.SentPayments([ ["instructionId", "SAL-1"] ])
	Then("every item is a payment of its own", len(aItems), 3)
	Then("...each with its own end2endId", pzVal(pzNth(aItems, 1), "end2endId") != pzVal(pzNth(aItems, 2), "end2endId"), TRUE)
	Then("...and the instructionId that ties them", pzVal(pzNth(aItems, 2), "instructionId"), "SAL-1")
	aRej = oPay.SentPayments([ ["instructionId", "SAL-1"], ["statut", "REJETE"] ])
	Then("the repeated txId is rejected DU03", pzVal(pzNth(aRej, 1), "statutRaison"), "DU03")
	Then("...and the unknown alias BE23", pzVal(pzNth(aRej, 2), "statutRaison"), "BE23")

	aC = oPay.ConfirmBulk("SAL-1", TRUE)
	Then("confirming makes it CONFIRME", aC["statut"], "CONFIRME")
	Then("...sending only the valid item", aC["transactionsEnvoyees"], 1)
	Then("...and debiting only it", oHub.Balance(), nBefore - 150000)
	oHub.AdvanceSeconds(25)
	Then("...which becomes irrevocable", pzVal(oPay.Bulk("SAL-1"), "transactionsIrrevocables"), 1)
	Then("confirming again is idempotent", pzVal(oPay.ConfirmBulk("SAL-1", TRUE), "statut"), "CONFIRME")
	bCancel = FALSE
	try
		oPay.ConfirmBulk("SAL-1", FALSE)
	catch
		bCancel = TRUE
	done
	Then("cancelling a confirmed bulk is a 403", bCancel, TRUE)

	aReplay = oPay.PayInBulk(oBatch)
	Then("the same batch through the port is a replay", aReplay["replayed"], 1)
	Then("...sending nothing again", len(oPay.SentPayments([ ["instructionId", "SAL-1"] ])), 3)
	aRaw = oHub.Request("POST", "/paiements-groupes", [], oBatch.AsBody())
	Then("the same instructionId at the hub is a 409", aRaw[1], 409)
	Then("...naming the field", aRaw[2]["invalid-params"][1]["name"], "instructionId")

	oFree = StzPaymentBatchQ().WithInstructionId("SAL-2").FromAlias(oHub.BusinessAlias()).WithoutConfirmation()
	oFree.Add( MkOrder(oHub, "F-1", "fatou", 10000) )
	oFree.Add( MkOrder(oHub, "F-2", "kdi", 20000) )
	nMid = oHub.Balance()
	aF = oPay.PayInBulk(oFree)
	Then("a bulk without confirmation is CONFIRME at once", aF["statut"], "CONFIRME")
	Then("...with both items sent", aF["transactionsEnvoyees"], 2)
	Then("...and debited", oHub.Balance(), nMid - 30000)
	aOut = oHub.Request("POST", "/paiements-groupes", [], MkBulkBody("SAL-4", oHub))
	Then("the raw POST answers 202 Accepted", aOut[1], 202)

	oCan = StzPaymentBatchQ().WithInstructionId("SAL-3").FromAlias(oHub.BusinessAlias()).WithConfirmation()
	oCan.Add( MkOrder(oHub, "K-1", "fatou", 1000) )
	oCan.Add( MkOrder(oHub, "K-2", "kdi", 2000) )
	oPay.PayInBulk(oCan)
	Then("a bulk can be cancelled before it is confirmed", pzVal(oPay.ConfirmBulk("SAL-3", FALSE), "statut"), "ANNULE")
	Then("...and its items are ANNULE", len(oPay.SentPayments([ ["instructionId", "SAL-3"], ["statut", "ANNULE"] ])), 2)
	bRe = FALSE
	try
		oPay.ConfirmBulk("SAL-3", TRUE)
	catch
		bRe = TRUE
	done
	Then("confirming a cancelled bulk is a 403", bRe, TRUE)

	aBadItem = [ ["instructionId", "SAL-9"], ["payeurAlias", oHub.BusinessAlias()], ["transactions", [ [ ["montant", 100], ["payeAlias", oHub.Alias("fatou")] ] ] ] ]
	aRb = oHub.Request("POST", "/paiements-groupes", [], aBadItem)
	Then("an item without a txId is a 400", aRb[1], 400)
	Then("...naming the item and the field", aRb[2]["invalid-params"][1]["name"], "transactions[1].txId")
	aEmpty = [ ["instructionId", "SAL-10"], ["payeurAlias", oHub.BusinessAlias()], ["transactions", []] ]
	Then("an empty bulk is a 400", pzNth(oHub.Request("POST", "/paiements-groupes", [], aEmpty), 1), 400)
EndScenario()

Scenario("a bulk of requests to pay")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oBatch = StzPaymentBatchQ().WithInstructionId("RTP-1").ToAlias(oHub.BusinessAlias()).InCategory("401").WithoutConfirmation()
	oBatch.Add( MkRtp(oHub, "BR-1", "fatou", 10000, "401") )
	oBatch.Add( MkRtp(oHub, "BR-2", "blocked", 20000, "401") )
	aR = oPay.RequestPaymentsInBulk(oBatch)
	Then("without confirmation it is CONFIRME at once", aR["statut"], "CONFIRME")
	Then("...with both requests sent", aR["transactionsEnvoyees"], 2)
	oHub.AdvanceSeconds(25)
	aS = oPay.BulkRequests("RTP-1")
	Then("the payer who pays makes one irrevocable", aS["transactionsIrrevocables"], 1)
	Then("...and the payer who refuses one rejected", aS["transactionsRejetees"], 1)
	Then("...so only the paying one brought money", oHub.Balance(), 50010000)
	Then("the same instructionId through the port is a replay", pzVal(oPay.RequestPaymentsInBulk(oBatch), "replayed"), 1)
	aRaw = oHub.Request("POST", "/demandes-paiements-groupes", [], oBatch.AsRequestBody())
	Then("...and at the hub a 409", aRaw[1], 409)

	oConf = StzPaymentBatchQ().WithInstructionId("RTP-2").ToAlias(oHub.BusinessAlias()).InCategory("401").WithConfirmation()
	oConf.Add( MkRtp(oHub, "BR-3", "fatou", 5000, "401") )
	Then("with confirmation it waits: INITIE", pzVal(oPay.RequestPaymentsInBulk(oConf), "statut"), "INITIE")
	Then("confirming releases it", pzVal(oPay.ConfirmBulkRequests("RTP-2", TRUE), "transactionsEnvoyees"), 1)
EndScenario()

Scenario("the quota is part of the contract: a 429, then it passes")
	oHub = StzPiSpiSandboxQ()
	oHub.SetRateLimit(5, 10000)
	oPay = StzPaymentsPortQ(oHub)
	For i = 1 to 5
		oHub.Request("GET", "/comptes", [], [])
	Next
	aR = oHub.Request("GET", "/comptes", [], [])
	Then("the sixth call in a minute is refused", aR[1], 429)
	Then("...as a problem titled Too Many Requests", aR[2]["title"], "Too Many Requests")
	bRaised = FALSE
	try
		oPay.Accounts()
	catch
		bRaised = TRUE
	done
	Then("the port raises it", bRaised, TRUE)
	Then("...and the problem says 429", StzLastPaymentsProblem().Status(), 429)
	oHub.AdvanceSeconds(61)
	Then("a minute later the hub answers again", pzNth(oHub.Request("GET", "/comptes", [], []), 1), 200)

	oDay = StzPiSpiSandboxQ()
	oDay.SetRateLimit(1000, 8)
	For i = 1 to 8
		oDay.Request("GET", "/comptes", [], [])
	Next
	oDay.AdvanceSeconds(120)
	Then("the daily quota still holds after a minute", pzNth(oDay.Request("GET", "/comptes", [], []), 1), 429)
	oDay.AdvanceSeconds(86400)
	Then("...and lifts a day later", pzNth(oDay.Request("GET", "/comptes", [], []), 1), 200)
EndScenario()

Scenario("every list pages, filters and sorts the way the reference says")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	For i = 1 to 5
		oPay.Pay( MkOrder(oHub, "L-" + i, "fatou", i * 1000) )
	Next
	oHub.AdvanceSeconds(25)
	aP = oHub.Request("GET", "/paiements-envoyes", [ ["size", "2"], ["page", "2"], ["sort", "montant"] ], [])
	Then("page 2 of size 2 holds items 3 and 4", pzVal(pzNth(aP[2]["data"], 1), "montant"), 3000)
	Then("...and the second is 4000", pzVal(pzNth(aP[2]["data"], 2), "montant"), 4000)
	Then("meta counts them all", aP[2]["meta"]["total"], 5)
	Then("...names the page and size", aP[2]["meta"]["page"], 2)
	Then("...points to the next page", aP[2]["meta"]["next"], 3)
	Then("...and the previous", aP[2]["meta"]["prev"], 1)
	aD = oHub.Request("GET", "/paiements-envoyes", [ ["sort", "-montant"] ], [])
	Then("a leading minus sorts descending", pzVal(pzNth(aD[2]["data"], 1), "montant"), 5000)
	Then("montant[gte]=4000 keeps two", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["montant[gte]", "4000"] ], []), 2), "meta"), "total"), 2)
	Then("montant[lt]=2000 keeps one", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["montant[lt]", "2000"] ], []), 2), "meta"), "total"), 1)
	Then("txId[beginsWith] keeps all five", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["txId[beginsWith]", "L-"] ], []), 2), "meta"), "total"), 5)
	Then("txId[contains] keeps one", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["txId[contains]", "-3"] ], []), 2), "meta"), "total"), 1)
	Then("txId[in] keeps the listed ones", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["txId[in]", "L-1,L-2"] ], []), 2), "meta"), "total"), 2)
	Then("motif[exists]=false keeps all, none had one", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["motif[exists]", "false"] ], []), 2), "meta"), "total"), 5)
	Then("statut[ne]=REJETE keeps all five", pzVal(pzVal(pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["statut[ne]", "REJETE"] ], []), 2), "meta"), "total"), 5)
	Then("statut=IRREVOCABLE keeps all five", len(oPay.SentPayments([ ["statut", "IRREVOCABLE"] ])), 5)
	Then("the list items never leak the twin's private keys", _StzPiHas(pzNth(oPay.SentPayments([]), 1), "_hub"), FALSE)
	Then("a size of 0 is a 400", pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["size", "0"] ], []), 1), 400)
	Then("a size of 101 is a 400", pzNth(oHub.Request("GET", "/paiements-envoyes", [ ["size", "101"] ], []), 1), 400)
EndScenario()

Scenario("webhooks are managed: at most 20, a secret renewed on a date")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	aA = oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/a").OnEvents(["PAIEMENT_RECU"]) )
	Then("a new webhook has an id", aA["id"], "wh-1")
	bDup = FALSE
	try
		oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/a").OnEvents(["PAIEMENT_RECU"]) )
	catch
		bDup = TRUE
	done
	Then("the same webhook twice is a 409", bDup, TRUE)
	bHttp = FALSE
	try
		oPay.RegisterWebhook( StzWebhookQ().CallingBack("http://diko.example/plain") )
	catch
		bHttp = TRUE
	done
	Then("a callback must be HTTPS", bHttp, TRUE)
	bEvent = FALSE
	try
		oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/b").OnEvents(["NOT_AN_EVENT"]) )
	catch
		bEvent = TRUE
	done
	Then("an unknown event is a 400", bEvent, TRUE)
	Then("a webhook can be read", pzVal(oPay.Webhook("wh-1"), "callbackUrl"), "https://diko.example/a")
	aC = oPay.ChangeWebhook("wh-1", [ ["events", ["RTP_RECU"]] ])
	Then("...and changed", pzNth(pzVal(aC, "events"), 1), "RTP_RECU")
	Then("...with a modification date", len(pzVal(aC, "dateModification")) > 0, TRUE)
	Then("deleting it answers 204 and removes it", oPay.DeleteWebhook("wh-1"), 1)
	bGone = FALSE
	try
		oPay.Webhook("wh-1")
	catch
		bGone = TRUE
	done
	Then("...so it is a 404 afterwards", bGone, TRUE)

	For i = 1 to 20
		oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/h" + i) )
	Next
	bMax = FALSE
	try
		oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/h21") )
	catch
		bMax = TRUE
	done
	Then("a business may hold at most 20 webhooks", bMax, TRUE)
	Then("...the 21st is a 403", StzLastPaymentsProblem().Status(), 403)

	oHub2 = StzPiSpiSandboxQ()
	oPort = StzPaymentsPortQ(oHub2)
	aH = oPort.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi") )
	cOld = oHub2.LastWebhookSecret()
	aN = oPort.RenewWebhookSecret(aH["id"], "2026-10-05T09:30:00Z")
	cNew = oHub2.LastWebhookSecret()
	Then("renewing returns a different secret", cNew != cOld, TRUE)
	oPort.Pay( MkOrder(oHub2, "S-1", "fatou", 1000) )
	oHub2.AdvanceSeconds(25)
	cB1 = oHub2.LastCallbackBody()
	oM1 = new stzStringCrypto(cB1)
	Then("until the expiry date the OLD secret still signs", oHub2.LastCallbackSignature(), oM1.HmacSha256(cOld))
	oHub2.AdvanceSeconds(2000)
	oPort.Pay( MkOrder(oHub2, "S-2", "fatou", 1000) )
	oHub2.AdvanceSeconds(25)
	cB2 = oHub2.LastCallbackBody()
	oM2 = new stzStringCrypto(cB2)
	Then("after it the NEW secret signs", oHub2.LastCallbackSignature(), oM2.HmacSha256(cNew))
	Then("a port that holds both accepts both", oHub2.DeliverTo(oPort), 2)
	Then("...and believed both", len(oPort.Events()), 2)
EndScenario()

Scenario("accounts, aliases, participants, and money between one's own accounts")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	cAcc = oHub.BusinessAccount()
	Then("the platform has two accounts", len(oPay.Accounts()), 2)
	aA = oPay.Account(cAcc)
	Then("...the current one holding 50 000 000", aA["solde"], 50000000)
	Then("...of type CACC", aA["type"], "CACC")
	Then("...open", aA["statut"], "OUVERT")
	bNo = FALSE
	try
		oPay.Account("NOPE")
	catch
		bNo = TRUE
	done
	Then("an unknown account is a 404", bNo, TRUE)

	Then("the platform starts with one alias", len(oPay.Aliases(cAcc)), 1)
	aN = oPay.CreateAlias(cAcc, "SHID")
	Then("a new alias is created", aN["type"], "SHID")
	Then("...on the account", aN["compte"], cAcc)
	Then("...so there are two", len(oPay.Aliases(cAcc)), 2)
	Then("an alias can be deleted", oPay.DeleteAlias(cAcc, aN["cle"]), 1)
	Then("...leaving one", len(oPay.Aliases(cAcc)), 1)
	bDel = FALSE
	try
		oPay.DeleteAlias(cAcc, aN["cle"])
	catch
		bDel = TRUE
	done
	Then("deleting it twice is a 404", bDel, TRUE)
	bType = FALSE
	try
		oPay.CreateAlias(cAcc, "XXXX")
	catch
		bType = TRUE
	done
	Then("an unknown alias type is a 400", bType, TRUE)
	For i = 1 to 4
		oPay.CreateAlias(cAcc, "SHID")
	Next
	bCap = FALSE
	try
		oPay.CreateAlias(cAcc, "SHID")
	catch
		bCap = TRUE
	done
	Then("an account holds at most five aliases", bCap, TRUE)

	aWho = oPay.ResolveAlias(oHub.Alias("fatou"))
	Then("an alias resolves to a client", pzVal(pzVal(aWho, "client"), "nom"), "Fatou Diop")
	Then("...with its category", pzVal(pzVal(aWho, "client"), "categorie"), "P")
	bUnknown = FALSE
	try
		oPay.ResolveAlias("00000000-0000-4000-8000-000000000000")
	catch
		bUnknown = TRUE
	done
	Then("an unknown alias is a 404", bUnknown, TRUE)

	cSav = "NE2344256727788288833"
	aT = oPay.TransferBetweenAccounts("TR-1", cAcc, cSav, StzAmountQ("500000", "XOF"))
	Then("a transfer between own accounts is IRREVOCABLE at once", aT["statut"], "IRREVOCABLE")
	Then("...the current account lost 500 000", pzVal(oPay.Account(cAcc), "solde"), 49500000)
	Then("...the savings account gained them", pzVal(oPay.Account(cSav), "solde"), 1500000)
	Then("more than the balance is REJETE with AG07", pzVal(oPay.TransferBetweenAccounts("TR-2", cAcc, cSav, StzAmountQ("90000000", "XOF")), "statutRaison"), "AG07")
	bTx = FALSE
	try
		oPay.TransferBetweenAccounts("TR-1", cAcc, cSav, StzAmountQ("1", "XOF"))
	catch
		bTx = TRUE
	done
	Then("a repeated txId is a 409", bTx, TRUE)

	Then("the twin lists five virtual participants", len(oPay.Participants()), 5)
	Then("...one of them suspended", pzVal(pzVal(pzNth(oHub.Request("GET", "/participants", [ ["statut", "DSBL"] ], []), 2), "meta"), "total"), 1)
EndScenario()

Scenario("the card adapter survives, as one adapter among others")
	oCard = StzCardPaymentsAdapterQ()
	Then("the card adapter is a sandbox", oCard.IsSandbox(), 1)
	aA = oCard.Authorize(4200, "tok_visa")
	Then("it still authorizes", aA[:ok], TRUE)
	Then("...under its historical name too", StzPaymentsSandboxQ().IsSandbox(), 1)
	Then("IRREVOCABLE is final", StzPaymentsIsFinal("IRREVOCABLE"), TRUE)
	Then("REJETE is final", StzPaymentsIsFinal("REJETE"), TRUE)
	Then("ENVOYE is not", StzPaymentsIsFinal("ENVOYE"), FALSE)
	Then("INITIE is not", StzPaymentsIsFinal("INITIE"), FALSE)
	Then("a reason code has a meaning", StzPaymentsReasonMeaning("AC06"), "blocked account")
	Then("...and an unknown one has none", StzPaymentsReasonMeaning("ZZZZ"), "")
EndScenario()

Summary()

# --- helpers -------------------------------------------------------------

# NOTE: `return Q().Method()` inside a function crashes the Ring VM silently, so the
# chain is assigned first and the variable returned.
func MkOrder(oHub, cTx, cWho, nAmount)
	oO = StzPaymentOrderQ().WithTxId(cTx).FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias(cWho)).WithAmount(StzAmountQ("" + nAmount, "XOF")).WithoutConfirmation()
	return oO

func MkOrderConfirm(oHub, cTx, cWho, nAmount)
	oO = StzPaymentOrderQ().WithTxId(cTx).FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias(cWho)).WithAmount(StzAmountQ("" + nAmount, "XOF")).WithConfirmation()
	return oO

# a value by key, and an item by position, of whatever a call answered
func pzVal(aList, cKey)
	return _StzPiGet(aList, cKey, "")

func pzNth(aList, n)
	return aList[n]

func MkRtp(oHub, cTx, cWho, nAmount, cCat)
	oRq = StzPaymentRequestQ().WithTxId(cTx).FromAlias(oHub.Alias(cWho)).ToAlias(oHub.BusinessAlias()).WithAmount(StzAmountQ("" + nAmount, "XOF")).InCategory(cCat).PayableBy("2026-10-31").WithoutConfirmation()
	return oRq

func MkRtpConfirm(oHub, cTx, cWho, nAmount)
	oRq = StzPaymentRequestQ().WithTxId(cTx).FromAlias(oHub.Alias(cWho)).ToAlias(oHub.BusinessAlias()).WithAmount(StzAmountQ("" + nAmount, "XOF")).InCategory("401").PayableBy("2026-10-31").WithConfirmation()
	return oRq

func MkBulkBody(cId, oHub)
	oB = StzPaymentBatchQ().WithInstructionId(cId).FromAlias(oHub.BusinessAlias()).WithoutConfirmation()
	oB.Add( MkOrder(oHub, "MB-" + cId, "fatou", 100) )
	return oB.AsBody()

# the evCode of the newest webhook the hub queued, and how many of one code it queued
func LastEv(oHub)
	aD = oHub.Deliveries()
	if len(aD) = 0
		return ""
	ok
	return pzVal(aD[len(aD)], "evCode")

func CountEv(oHub, cCode)
	aD = oHub.Deliveries()
	n = 0
	for i = 1 to len(aD)
		if pzVal(aD[i], "evCode") = cCode
			n++
		ok
	next
	return n
