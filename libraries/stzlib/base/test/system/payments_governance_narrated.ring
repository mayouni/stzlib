load "../../stzBase.ring"
load "../_narrated.ring"

# PY4 of the payments plane: MONEY OUT IS A PLAN A HUMAN COMMITS.
#
# Receiving money needs no decision; sending it does. So a payout -- one payment, a bulk of
# salaries, a return of funds, the acceptance of somebody's request to pay -- is never a method
# call. It is a PLAN:
#
#     proposed    by anyone, an agent included, REHEARSED in a workbench (a twin of the disk)
#     judged      by a policy, which is DATA read from the rehearsed document and is not a
#                 constant in the port: DIKO's is four visas above 100 000 FCFA
#     committed   by an actor that may change reality, across a scope, into a real file that IS
#                 the durable journal of what was authorised
#     released    by the port, which refuses every payout that no committed plan authorised, and
#                 refuses one whose amount is not the amount that was authorised
#
# "Expression is free; admission is governed." An LLM can propose a payout and cannot commit it.
#
# The port is governed BY DEFAULT. Turning it off is a loud, named act, and a registry that is
# asked about production refuses a port that did.

cDir = CurrentDir() + "/_py4_payouts"

Scenario("a port refuses money out that skips a plan -- and the hub never hears of it")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	Then("a port is governed by default", oPay.IsGoverned(), TRUE)

	bRefused = FALSE
	cWhy = ""
	try
		oPay.Pay( MkOrder(oHub, "G-1", "fatou", 150000) )
	catch
		bRefused = TRUE
		cWhy = cCatchError
	done
	Then("a payment with no committed plan is refused by the PORT", bRefused, TRUE)
	Then("...saying so in the words the ledger uses", StzFindFirst("payout-without-plan", cWhy) > 0, TRUE)
	Then("...before any request existed: the hub saw nothing", oHub.NumberOfPayments("ENVOYE"), 0)
	Then("...and not a franc moved", oHub.Balance(), 50000000)
	Then("the ledger heard it, as an error", len(oLed.OfKind("payout.unplanned")), 1)

	oBatch = StzPaymentBatchQ()
	oBatch.WithInstructionId("G-BULK")
	oBatch.FromAlias(oHub.BusinessAlias())
	oBatch.WithoutConfirmation()
	oBatch.Add( MkOrder(oHub, "G-B1", "fatou", 1000) )
	bBulk = FALSE
	try
		oPay.PayInBulk(oBatch)
	catch
		bBulk = TRUE
	done
	Then("a bulk without a plan is refused too", bBulk, TRUE)
	Then("...and the hub saw no instruction", len(pzVal(pzNth(oHub.Request("GET", "/paiements-groupes", [], []), 2), "data")), 0)

	When("asking for money, or declining to pay, is not money out")
	oHub.SimulateIncomingRequest("fatou", 2000, "x")
	Then("a request to pay needs no plan", pzVal(oPay.RequestPayment( MkRtp(oHub, "G-R1", "fatou", 3000) ), "statut"), "ENVOYE")
	eReq = pzVal(pzNth(oPay.ReceivedRequests([]), 1), "end2endId")
	Then("rejecting a request needs no plan", pzVal(oPay.AnswerRequest(eReq, FALSE, "AM09"), "statut"), "REJETE")
	Then("moving money between the platform's own accounts needs none either",
		pzVal(oPay.TransferBetweenAccounts("G-T1", oHub.BusinessAccount(), "NE2344256727788288833", StzAmountQ("1000", "XOF")), "statut"), "IRREVOCABLE")
	StzCloseSecurityLedger()
EndScenario()

Scenario("authorising a payout is an ADMISSION, and it is exact")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oHuman = HumanActor("tresorier")
	oLlm = LLMActor("assistant")

	bLlm = FALSE
	try
		oPay.AuthorisePayout(oLlm, "P-1", "pay", "G-1", 150000)
	catch
		bLlm = TRUE
	done
	Then("an LLM actor cannot authorise a payout", bLlm, TRUE)
	Then("...and the ledger heard the attempt", len(oLed.OfKind("payout.refused")), 1)
	Then("nothing was authorised", len(oPay.AuthorisedPayouts()), 0)

	Then("an effectful, trusted actor can", oPay.AuthorisePayout(oHuman, "P-1", "pay", "G-1", 150000), TRUE)
	Then("...and the authorisation is on record", len(oPay.AuthorisedPayouts()), 1)
	aR = oPay.Pay( MkOrder(oHub, "G-1", "fatou", 150000) )
	Then("the authorised payment goes", aR["statut"], "ENVOYE")
	Then("...and the money leaves", oHub.Balance(), 49850000)

	oPay.AuthorisePayout(oHuman, "P-1", "pay", "G-3", 5000)
	bAmount = FALSE
	cWhy = ""
	try
		oPay.Pay( MkOrder(oHub, "G-3", "fatou", 6000) )
	catch
		bAmount = TRUE
		cWhy = cCatchError
	done
	Then("an amount that is not the amount authorised is refused", bAmount, TRUE)
	Then("...naming the difference", StzFindFirst("payout-amount-differs", cWhy) > 0, TRUE)
	Then("...and nothing more left", oHub.Balance(), 49850000)

	bOther = FALSE
	try
		oPay.Pay( MkOrder(oHub, "G-4", "fatou", 5000) )
	catch
		bOther = TRUE
	done
	Then("an authorisation is for ONE payment: another txId is refused", bOther, TRUE)

	oOther = StzPaymentsPortQ(oHub)
	bPort = FALSE
	try
		oOther.Pay( MkOrder(oHub, "G-3", "fatou", 5000) )
	catch
		bPort = TRUE
	done
	Then("...and it belongs to the port that holds it", bPort, TRUE)

	aAgain = oPay.Pay( MkOrder(oHub, "G-1", "fatou", 150000) )
	Then("a replay of the authorised payment answers from the journal", aAgain["replayed"], 1)
	Then("...and pays nothing again", oHub.Balance(), 49850000)
	Then("the authorisation was used once", pzVal(pzNth(oPay.AuthorisedPayouts(), 1), "used"), 1)
	StzCloseSecurityLedger()
EndScenario()

Scenario("the policy is DATA: DIKO's four visas above 100 000 FCFA, judged by the rule report")
	oHub = StzPiSpiSandboxQ()
	oPolicy = StzDikoPayoutPolicyQ()

	oSmall = StzPayoutPlanQ()
	oSmall.WithId("S-1")
	oSmall.ProposedBy("treasury-agent")
	oSmall.Paying( MkOrder(oHub, "S-1-1", "fatou", 100000) )
	Then("a payout of exactly 100 000 needs no visa: the rule says ABOVE", len(oPolicy.JudgePlan(oSmall)), 0)

	oBig = StzPayoutPlanQ()
	oBig.WithId("S-2")
	oBig.ProposedBy("treasury-agent")
	oBig.Paying( MkOrder(oHub, "S-2-1", "fatou", 100001) )
	aF = oPolicy.JudgePlan(oBig)
	Then("one franc more and it needs four visas: no visa is a finding", len(aF), 1)
	Then("...in the house shape, named for the rule", aF[1]["rule"], "payout-over-100000-needs-4-visas")
	Then("...an error", aF[1]["severity"], "error")
	Then("...pointing at the plan", aF[1]["where"], "S-2")
	Then("...with the subject payouts", aF[1]["subject"], "payouts")
	Then("...saying how many it has and how many it needs", StzFindFirst("needs 4", aF[1]["message"]) > 0 and StzFindFirst("has 0", aF[1]["message"]) > 0, TRUE)

	oBig.Visa("comptable", "A. Issoufou")
	oBig.Visa("DAF", "M. Garba")
	oBig.Visa("DG", "H. Maiga")
	Then("three visas are not four", len(oPolicy.JudgePlan(oBig)), 1)
	oBig.Visa("DG", "h. maiga")
	Then("the same person twice, in another case, is still three", len(oPolicy.JudgePlan(oBig)), 1)
	Then("...the plan counts people, not signatures", oBig.NumberOfDistinctVisas(), 3)
	oBig.Visa("CA", "S. Abdou")
	Then("a fourth person makes it four", len(oPolicy.JudgePlan(oBig)), 0)

	oRep = StzRuleReportQ("payouts")
	oRep.Ingest( oPolicy.JudgePlan(oSmall) )
	Then("an empty verdict is a sound report", oRep.IsSound(), TRUE)
	oNo = StzPayoutPlanQ()
	oNo.WithId("S-3")
	oNo.Paying( MkOrder(oHub, "S-3-1", "fatou", 500000) )
	oRep2 = StzRuleReportQ("payouts")
	oRep2.Ingest( oPolicy.JudgePlan(oNo) )
	Then("a plan short of visas makes the ONE CI gate unsound", oRep2.IsSound(), FALSE)
	Then("...with one error", len(oRep2.Errors()), 1)

	When("the threshold changes, the port does not")
	oOther = StzPayoutPolicyQ("small-shop")
	oOther.RequireVisasAbove(500000, 2)
	oMid = StzPayoutPlanQ()
	oMid.WithId("S-4")
	oMid.Paying( MkOrder(oHub, "S-4-1", "fatou", 400000) )
	Then("another policy judges the same plan another way", len(oOther.JudgePlan(oMid)), 0)
	Then("...and DIKO's still wants its four", len(oPolicy.JudgePlan(oMid)), 1)
	cPort = StzFileRead("../../service/stzPaymentsPort.ring")
	Then("the port's source holds no threshold", StzFindFirst("100000", cPort), 0)
	Then("...and never speaks of visas", StzFindFirst("visa", StzLower(cPort)), 0)

	oEmpty = StzPayoutPlanQ()
	oEmpty.WithId("S-5")
	aE = oPolicy.JudgePlan(oEmpty)
	Then("a plan that pays nothing is refused outright", aE[1]["rule"], "payout-plan-empty")

	When("a policy may also keep the proposer out of the visas")
	oSep = StzPayoutPolicyQ("separation")
	oSep.ProposerCannotVisa()
	oP = StzPayoutPlanQ()
	oP.WithId("S-6")
	oP.ProposedBy("A. Issoufou")
	oP.Paying( MkOrder(oHub, "S-6-1", "fatou", 1000) )
	oP.Visa("comptable", "a. issoufou")
	Then("the proposer's own visa is a finding", pzVal(pzNth(oSep.JudgePlan(oP), 1), "rule"), "payout-proposer-cannot-visa")
EndScenario()

Scenario("an agent rehearses the payout in a workbench; the disk does not move")
	StzDirDeleteAll(cDir)
	StzDirCreatePath(cDir)
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oDesk = StzPayoutDeskQ(oPay, StzDikoPayoutPolicyQ(), cDir)
	nBench = StzOpenAgentWorkbench()
	oBench = StzAgentWorkbenchQ(nBench)

	oPlan = StzPayoutPlanQ()
	oPlan.WithId("SAL-1")
	oPlan.ProposedBy("treasury-agent")
	oPlan.Paying( MkOrder(oHub, "SAL-1-1", "fatou", 150000) )
	oPlan.Visa("comptable", "A. Issoufou")
	oPlan.Visa("DAF", "M. Garba")
	cFile = cDir + "/SAL-1.plan.json"

	oDesk.Rehearse(oPlan, nBench)
	Then("the plan is a document in the workbench", oBench.Exists(cFile), 1)
	Then("...and NOT on the disk", StzFileExists(cFile), 0)
	Then("the document says what would be paid", StzFindFirst("SAL-1-1", oBench.ContentOf(cFile)) > 0, TRUE)
	Then("...and who has visaed it", StzFindFirst("A. Issoufou", oBench.ContentOf(cFile)) > 0, TRUE)
	Then("...and carries the proposer", StzFindFirst("treasury-agent", oBench.ContentOf(cFile)) > 0, TRUE)
	Then("no credential, no secret is in it", StzFindFirst("secret", StzLower(oBench.ContentOf(cFile))), 0)

	oRep = oDesk.Judge(nBench, "SAL-1")
	Then("it is judged from the REHEARSED document, and two visas are short", oRep.IsSound(), FALSE)
	Then("...the report is the shared rule report", oRep.Name(), "payouts")
	Then("...with one error", len(oRep.Errors()), 1)

	oPlan.Visa("DG", "H. Maiga")
	oPlan.Visa("CA", "S. Abdou")
	Then("visas added to the plan alone do not reach the rehearsal", oDesk.Judge(nBench, "SAL-1").IsSound(), FALSE)
	oDesk.Rehearse(oPlan, nBench)
	Then("rehearsing again overwrites the document", oDesk.Judge(nBench, "SAL-1").IsSound(), TRUE)
	Then("...and the disk still did not move", StzFileExists(cFile), 0)
	Then("...nor did the platform's balance", oHub.Balance(), 50000000)
	StzCloseAgentWorkbench(nBench)
EndScenario()

Scenario("a plan is committed by an actor who may -- and only then does money leave")
	StzOpenSecurityLedger(256)
	oLed = StzSecurityLedgerQ()
	StzDirDeleteAll(cDir)
	StzDirCreatePath(cDir)
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	oDesk = StzPayoutDeskQ(oPay, StzDikoPayoutPolicyQ(), cDir)
	nBench = StzOpenAgentWorkbench()

	oPlan = StzPayoutPlanQ()
	oPlan.WithId("SAL-2")
	oPlan.ProposedBy("treasury-agent")
	oPlan.Paying( MkOrder(oHub, "SAL-2-1", "fatou", 150000) )
	oPlan.Paying( MkOrder(oHub, "SAL-2-2", "kdi", 200000) )
	oPlan.Visa("comptable", "A. Issoufou")
	oPlan.Visa("DAF", "M. Garba")
	oPlan.Visa("DG", "H. Maiga")
	oDesk.Rehearse(oPlan, nBench)
	cFile = cDir + "/SAL-2.plan.json"
	oLlm = LLMActor("assistant")
	oHuman = HumanActor("tresorier")

	aA = oDesk.Commit(nBench, "SAL-2", oHuman)
	Then("with three visas the policy refuses, whoever commits", aA["committed"], 0)
	Then("...saying it was the policy", aA["reason"], "policy")
	Then("...no file was written", StzFileExists(cFile), 0)
	Then("...nothing was authorised at the port", len(oPay.AuthorisedPayouts()), 0)
	Then("...and the money did not move", oHub.Balance(), 50000000)
	Then("...the refusal is on the ledger", len(oLed.OfKind("payout.refused")), 1)

	oPlan.Visa("CA", "S. Abdou")
	oDesk.Rehearse(oPlan, nBench)
	aB = oDesk.Commit(nBench, "SAL-2", oLlm)
	Then("with four visas an LLM actor still cannot commit it", aB["committed"], 0)
	Then("...the reason is the actor", aB["reason"], "actor")
	Then("...and it names the missing capability", StzFindFirst("effectful", aB["detail"]) > 0, TRUE)
	Then("...no file, no money", StzFileExists(cFile) + (oHub.Balance() != 50000000), 0)

	When("the rehearsed document is edited in the workbench after it was visaed")
	oBench = StzAgentWorkbenchQ(nBench)
	cDoc = oBench.ContentOf(cFile)
	oBench.WriteFile(cFile, StzReplace(cDoc, "200000", "2000000"))
	aC = oDesk.Commit(nBench, "SAL-2", oHuman)
	Then("the plan to be paid differs from the plan that was visaed: refused", aC["committed"], 0)
	Then("...for that reason", aC["reason"], "rehearsal-differs")
	oDesk.Rehearse(oPlan, nBench)

	aD = oDesk.Commit(nBench, "SAL-2", oHuman)
	Then("a human commits the visaed plan", aD["committed"], 1)
	Then("...the plan is now a REAL file, the durable journal of what was authorised", StzFileExists(cFile), 1)
	Then("...and it names the visas", StzFindFirst("S. Abdou", StzFileRead(cFile)) > 0, TRUE)
	Then("...both payments left", len(aD["results"]), 2)
	Then("...the hub's own word for the first", aD["results"][1]["statut"], "ENVOYE")
	Then("...and for the second", aD["results"][2]["statut"], "ENVOYE")
	Then("...350 000 FCFA is out", oHub.Balance(), 49650000)
	Then("...every authorisation was used", pzVal(pzNth(oPay.AuthorisedPayouts(), 1), "used") + pzVal(pzNth(oPay.AuthorisedPayouts(), 2), "used"), 2)
	Then("the ledger heard the commit", len(oLed.OfKind("payout.committed")), 1)
	aJ = oDesk.Journal()
	Then("the desk's journal holds the four attempts, in order", len(aJ), 4)
	Then("...refused, refused, refused, committed", aJ[1]["outcome"] + "," + aJ[2]["outcome"] + "," + aJ[3]["outcome"] + "," + aJ[4]["outcome"],
		"refused,refused,refused,committed")
	Then("...each with its actor", aJ[4]["actor"], "tresorier")
	Then("...and its total", aJ[4]["total"], 350000)

	aAgain = oDesk.Commit(nBench, "SAL-2", oHuman)
	Then("committing the same plan twice is refused: it was already committed", aAgain["committed"], 0)
	Then("...for that reason", aAgain["reason"], "already-committed")
	Then("...so the balance did not move", oHub.Balance(), 49650000)

	oDetect = StzPaymentsDetectionSet()
	Then("the ledger's detections raise no unplanned payout, there was none", ring_find(oDetect.FiredNames(oLed), "unplanned-payout"), 0)
	StzCloseAgentWorkbench(nBench)
	StzCloseSecurityLedger()
EndScenario()

Scenario("every verb that moves money out is governed, and one that only asks is not")
	oHub = StzPiSpiSandboxQ()
	oPay = StzPaymentsPortQ(oHub)
	StzDirDeleteAll(cDir)
	StzDirCreatePath(cDir)
	oDesk = StzPayoutDeskQ(oPay, StzDikoPayoutPolicyQ(), cDir)
	nBench = StzOpenAgentWorkbench()
	oHuman = HumanActor("tresorier")

	e1 = oHub.SimulateIncomingPayment("fatou", 40000, "Don")
	bRet = FALSE
	try
		oPay.ReturnFunds(e1)
	catch
		bRet = TRUE
	done
	Then("returning funds without a plan is refused", bRet, TRUE)
	oRet = StzPayoutPlanQ()
	oRet.WithId("RET-1")
	oRet.Returning(e1, 40000)
	nBench = StzOpenAgentWorkbench()      # one plan, one workbench
	oDesk.Rehearse(oRet, nBench)
	aR = oDesk.Commit(nBench, "RET-1", oHuman)
	Then("a plan to return it, under the threshold, commits with no visa", aR["committed"], 1)
	Then("...the return started", aR["results"][1]["retourStatut"], "INITIE")
	Then("...and the money left", oHub.Balance(), 50000000)

	eReq = oHub.SimulateIncomingRequest("kdi", 9000, "Devis")
	bAcc = FALSE
	try
		oPay.AnswerRequest(eReq, TRUE, "")
	catch
		bAcc = TRUE
	done
	Then("accepting a request to pay (it PAYS) is refused without a plan", bAcc, TRUE)
	oA = StzPayoutPlanQ()
	oA.WithId("ACC-1")
	oA.AcceptingRequest(eReq, 9000)
	nBench = StzOpenAgentWorkbench()      # one plan, one workbench
	oDesk.Rehearse(oA, nBench)
	aA = oDesk.Commit(nBench, "ACC-1", oHuman)
	Then("a plan to accept it commits", aA["committed"], 1)
	Then("...and the request became IRREVOCABLE", aA["results"][1]["statut"], "IRREVOCABLE")
	Then("...9 000 FCFA is out", oHub.Balance(), 49991000)

	eC = oHub.SimulateIncomingPayment("kdi", 8000, "x")
	oHub.SimulateCancellationRequest(eC, "AM09")
	bCan = FALSE
	try
		oPay.AnswerCancellation(eC, TRUE)
	catch
		bCan = TRUE
	done
	Then("accepting a cancellation (it RETURNS funds) is refused without a plan", bCan, TRUE)
	Then("...refusing one is not money out", pzVal(oPay.AnswerCancellation(eC, FALSE), "annulationStatut"), "REJETE")
	eC2 = oHub.SimulateIncomingPayment("kdi", 8000, "y")
	oHub.SimulateCancellationRequest(eC2, "FRAD")
	oC = StzPayoutPlanQ()
	oC.WithId("CAN-1")
	oC.AcceptingCancellation(eC2, 8000)
	nBench = StzOpenAgentWorkbench()      # one plan, one workbench
	oDesk.Rehearse(oC, nBench)
	aC = oDesk.Commit(nBench, "CAN-1", oHuman)
	Then("a plan to accept it commits", aC["committed"], 1)
	Then("...the cancellation was accepted", aC["results"][1]["annulationStatut"], "ACCEPTE")

	e3 = oHub.SimulateIncomingPayment("fatou", 40000, "Don 2")
	oW = StzPayoutPlanQ()
	oW.WithId("RET-2")
	oW.Returning(e3, 39999)
	nBench = StzOpenAgentWorkbench()      # one plan, one workbench
	oDesk.Rehearse(oW, nBench)
	aW = oDesk.Commit(nBench, "RET-2", oHuman)
	Then("a plan whose amount is not the amount the hub holds commits as a plan", aW["committed"], 1)
	Then("...but the PORT refuses the movement", StzFindFirst("payout-amount-differs", aW["results"][1]["error"]) > 0, TRUE)

	oBatch = StzPaymentBatchQ()
	oBatch.WithInstructionId("BULK-1")
	oBatch.FromAlias(oHub.BusinessAlias())
	oBatch.WithoutConfirmation()
	oBatch.Add( MkOrder(oHub, "BK-1", "fatou", 60000) )
	oBatch.Add( MkOrder(oHub, "BK-2", "kdi", 70000) )
	oB = StzPayoutPlanQ()
	oB.WithId("BULK-PLAN")
	oB.PayingBulk(oBatch)
	Then("a bulk is one plan item with the SUM of its items", oB.TotalAmount(), 130000)
	nBench = StzOpenAgentWorkbench()
	oDesk.Rehearse(oB, nBench)
	aB1 = oDesk.Commit(nBench, "BULK-PLAN", oHuman)
	Then("130 000 is above the threshold: the policy wants four visas", aB1["reason"], "policy")
	oB.Visa("comptable", "A. Issoufou")
	oB.Visa("DAF", "M. Garba")
	oB.Visa("DG", "H. Maiga")
	oB.Visa("CA", "S. Abdou")
	oDesk.Rehearse(oB, nBench)
	aB2 = oDesk.Commit(nBench, "BULK-PLAN", oHuman)
	Then("with four it commits", aB2["committed"], 1)
	Then("...the bulk went as one instruction", aB2["results"][1]["statut"], "CONFIRME")
	Then("...with both items sent", aB2["results"][1]["transactionsEnvoyees"], 2)

	oConf = StzPaymentBatchQ()
	oConf.WithInstructionId("BULK-2")
	oConf.FromAlias(oHub.BusinessAlias())
	oConf.WithConfirmation()
	oConf.Add( MkOrder(oHub, "BK-3", "fatou", 1000) )
	oHub.Request("POST", "/paiements-groupes", [], oConf.AsBody())
	bConf = FALSE
	try
		oPay.ConfirmBulk("BULK-2", TRUE)
	catch
		bConf = TRUE
	done
	Then("confirming a bulk that no plan authorised is refused", bConf, TRUE)
	Then("...cancelling it is allowed: that is not money out", pzVal(oPay.ConfirmBulk("BULK-2", FALSE), "statut"), "ANNULE")
	StzCloseAgentWorkbench(nBench)
EndScenario()

Scenario("an ungoverned port is a loud, named act -- and the registry refuses it in production")
	oHub = StzPiSpiSandboxQ()
	oGov = StzPaymentsPortQ(oHub)
	oFree = StzPaymentsPortQ(oHub)
	oFree.AllowUngovernedPayouts()
	Then("a port that was told to skip governance says so", oFree.AllowsUngovernedPayouts(), TRUE)
	Then("...a governed one says it does not", oGov.AllowsUngovernedPayouts(), FALSE)
	Then("an ungoverned port pays without a plan", pzVal(oFree.Pay( MkOrder(oHub, "U-1", "fatou", 1000) ), "statut"), "ENVOYE")

	oReg = StzServiceRegistryQ("diko")
	oReg.Bind(:payments, oFree)
	Then("in development it is allowed: that is what a test of the twin does", StzFindFirst("ungoverned", @@(oReg.Findings())), 0)
	oReg.SetPhase(:production)
	aF = oReg.Findings()
	Then("in production the registry names it", StzFindFirst("ungoverned-payouts-in-production", @@(aF)) > 0, TRUE)
	oReg2 = StzServiceRegistryQ("diko2")
	oReg2.Bind(:payments, oGov)
	oReg2.SetPhase(:production)
	Then("a governed port is not named for it", StzFindFirst("ungoverned", @@(oReg2.Findings())), 0)
	Then("the invariant is a documented one", StzFindFirst("ungoverned-payouts-in-production", @@(StzSecurityInvariantNames())) > 0, TRUE)
EndScenario()

StzDirDeleteAll(cDir)
Summary()

# --- helpers -------------------------------------------------------------

func MkOrder(oHub, cTx, cWho, nAmount)
	oO = StzPaymentOrderQ()
	oO.WithTxId(cTx)
	oO.FromAlias(oHub.BusinessAlias())
	oO.ToAlias(oHub.Alias(cWho))
	oO.WithAmount(StzAmountQ("" + nAmount, "XOF"))
	oO.WithoutConfirmation()
	return oO

func MkRtp(oHub, cTx, cWho, nAmount)
	oRq = StzPaymentRequestQ()
	oRq.WithTxId(cTx)
	oRq.FromAlias(oHub.Alias(cWho))
	oRq.ToAlias(oHub.BusinessAlias())
	oRq.WithAmount(StzAmountQ("" + nAmount, "XOF"))
	oRq.InCategory("401")
	oRq.PayableBy("2026-10-31")
	oRq.WithoutConfirmation()
	return oRq

func pzVal(aList, cKey)
	return _StzPiGet(aList, cKey, "")

func pzNth(aList, n)
	return aList[n]
