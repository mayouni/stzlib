# Getting Paid and Paying
### How a Softanza platform takes a customer's money and pays a supplier in the UEMOA, with nothing it cannot refuse

A platform that sells in Niger is paid in francs CFA, by people who hold an account at
a bank or a mobile-money operator that is not its own. Until the BCEAO's PI-SPI hub, each
of those was a separate door, a separate contract, and a separate vendor's idea of what a
payment is. The hub gives one contract for all of them, and Softanza's payment port speaks
that contract and nothing else: no vendor's name appears in a verb, and no fee is added by
this library, in any form, ever.

This narration is one story, run from top to bottom. Every code block is real, in the order
a platform meets them, and every `#-->` is what the block printed when the guard
`test/system/payments_chapter.py` ran this page. It runs against the **twin**, the hub
that Softanza ships in-process, so nobody's money moves while you read.

What this page does **not** claim, in the order it matters: no payment here was made at the
BCEAO, so *nobody has perceived* the live adapter pay anyone; the code's
payload is built and read here, but the black-and-white picture of it (the matrix a camera
reads) is a different layer, not built, and no PI-SPI application has scanned a payload
made here; and the platform is promised the BCEAO's contract, not the homologation of any
one participant.

---

## The platform opens an account on the twin

A platform needs three things before it takes a franc: a hub to talk to, the port that
speaks the contract, and a name for its own account. The twin starts with a business
alias, a handful of customers, and a clock that you move by hand, because the real hub
takes up to twenty seconds to make a payment final and a narration should not wait.

```ring
load "../../stzBase.ring"

oHub = StzPiSpiSandboxQ()                            # the twin of the hub; IsSandbox() is 1
oPay = StzPaymentsPortQ(oHub)                        # the port: the same verbs over any hub
? oHub.IsSandbox()                                   #--> 1
? oHub.Balance()                                     #--> 50000000
```

The balance is 50 000 000 in the hub's *minor unit*. For the franc CFA the minor unit is the
franc itself, since it has no centime, so that is fifty million francs of virtual money.
An amount in Softanza carries its currency from its birth and cannot be built without one:

```ring
a = StzAmountQ("150000", "XOF")
? a.Display()                                        #--> 150 000 FCFA
try
	b = StzAmountQ("50.5", "XOF")                    # a franc has no fraction
catch
	? "refused"                                      #--> refused
done
```

---

## The platform shows a dynamic QR

A dynamic QR is made for ONE sale. What the customer's camera reads is not a picture of
an order; it is a short string in the format the BCEAO published, and it says three things:
whose account is paid (the shop's PI-SPI alias), how much, and a label the shop will
reconcile on. The customer's own banking application reads it and makes an ordinary payment
to that alias. Nothing else travels in the code, and nobody in between takes a fee for carrying it.

```ring
oQr = StzPispiQrQ()
oQr.WithAlias(oHub.BusinessAlias())
oQr.InCountry("NE")
oQr.AsDynamic()                                      # made for one sale
oQr.WithReference("BOUTIQUE-2026-001")               # at most 25 characters: what the payer sees, what we reconcile on
oQr.WithAmount( StzAmountQ("18500", "XOF") )
cQr = oQr.Payload()
? StzFindFirst("int.bceao.pi", cQr) > 0              #--> 1

aRead = StzPispiQrParse(cQr)                         # any such string can be read back
? aRead[:valid]                                      #--> 1
aData = aRead[:data]
? aData[:qrType]                                     #--> DYNAMIC
? aData[:amount]                                     #--> 18500
```

A string whose checksum does not match is read as invalid, and the reader says why instead
of raising, since a till will meet strings it did not make. The picture of the string, the
black-and-white matrix, is drawn by a layer this page does not build; the string is what
the hub's world agrees on.

---

## The customer pays, and the platform hears of it

The platform does not poll. Before it showed the QR it told the hub where to call back, and
for which events. The hub keeps a secret for that endpoint, hands it over once, and signs
every call with it; the port keeps the secret and verifies what arrives.

```ring
oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://boutique.example/pispi").OnEvents(["PAIEMENT_RECU"]) )

eRecu = oHub.SimulateIncomingPayment("fatou", 18500, "BOUTIQUE-2026-001")   # the customer scanned and paid
aRecus = oPay.ReceivedPayments([])
? len(aRecus)                                        #--> 1
? aRecus[1][:statut]                                 #--> IRREVOCABLE
? aRecus[1][:motif]                                  #--> BOUTIQUE-2026-001
? oHub.Balance()                                     #--> 50018500
```

`IRREVOCABLE` is the hub's word for *the money is yours and cannot be taken back by the payer*.
The twin made the customer's payment final at once, as a real hub does for a payment received;
the balance rose by 18 500, and the hub called the platform:

```ring
aEv = oPay.ReceiveWebhook(oHub.LastCallbackBody(), oHub.LastCallbackSignature())
? aEv[:accepted]                                     #--> 1
aEvents = aEv[:events]
? aEvents[1][:evCode]                                #--> PAIEMENT_RECU
```

Pending is a state, not an error: a customer who has scanned and not yet confirmed has paid
nothing, and the platform must not treat the code as refused. The webhook is what says that
the money arrived.

A webhook is a door that anybody who knows the address can knock on, so what the platform
does with a call it did not verify is the point of the page. A call whose signature is wrong
is refused with a 401 and is noted in the security ledger; a call that arrives with no
signature at all is refused the same way:

```ring
aBad = oPay.ReceiveWebhook(oHub.LastCallbackBody(), "deadbeef")
? aBad[:accepted]                                    #--> 0
? aBad[:status]                                      #--> 401

aNone = oPay.ReceiveWebhook(oHub.LastCallbackBody(), "")
? aNone[:accepted]                                   #--> 0
```

---

## The platform pays a supplier, under four visas

Taking money in is a read of the world. Paying it out is the one act in this chapter that
can hurt, and Softanza treats it as a **plan a human commits**: an agent, or a clerk's
script, may *propose* the payment and rehearse it into a copy of the world, and a rule the
platform wrote judges it; only a named person's commit makes the hub hear of it. Here the
platform's rule is a plain one: over 100 000 francs, four visas.

First, the port is *governed*, which is its default. A payment sent straight at it, with no
plan behind it, is refused before the hub is told:

```ring
cDir = CurrentDir() + "/_chapter_payouts"
StzDirDeleteAll(cDir)
StzDirCreatePath(cDir)

oTreasury = StzPaymentsPortQ(oHub)
oDesk = StzPayoutDeskQ(oTreasury, StzDikoPayoutPolicyQ(), cDir)

oSupplier = StzPaymentOrderQ()
oSupplier.WithTxId("FOURN-2026-10-1")
oSupplier.FromAlias(oHub.BusinessAlias())
oSupplier.ToAlias(oHub.Alias("boutique"))
oSupplier.WithAmount( StzAmountQ("350000", "XOF") )
oSupplier.Motive("Facture fournisseur 2026-045")
oSupplier.WithoutConfirmation()

try
	oTreasury.Pay(oSupplier)
catch
	? "refused"                                      #--> refused
done
```

So the payment goes into a plan. Three visas are collected, which would be enough for a
smaller sum and is not enough here, and the desk says which rule it is that fails:

```ring
oPlan = StzPayoutPlanQ()
oPlan.WithId("FOURN-2026-10")
oPlan.ProposedBy("treasury-agent")
oPlan.Paying(oSupplier)
oPlan.Visa("comptable", "A. Issoufou")
oPlan.Visa("DAF", "M. Garba")
oPlan.Visa("DG", "H. Maiga")

nBench = StzOpenAgentWorkbench()
oDesk.Rehearse(oPlan, nBench)                        # into a copy of the disk: nothing real moves
oReport = oDesk.Judge(nBench, "FOURN-2026-10")
? oReport.IsSound()                                  #--> 0
aErr = oReport.Errors()
? aErr[1][:rule]                                     #--> payout-over-100000-needs-4-visas
```

The fourth visa is collected, the plan is rehearsed again, and the judgement changes. A plan
that is sound is still not a payment: the assistant that proposed it may not commit it, and
the desk says it is the *actor* that is wrong and not the plan:

```ring
oPlan.Visa("CA", "S. Abdou")
oDesk.Rehearse(oPlan, nBench)
oReport = oDesk.Judge(nBench, "FOURN-2026-10")
? oReport.IsSound()                                  #--> 1

aLlm = oDesk.Commit(nBench, "FOURN-2026-10", LLMActor("assistant"))
? aLlm[:reason]                                      #--> actor
```

Only a person's commit crosses. The treasurer commits, the hub is told for the first time,
and the plan stays on disk as the record of who proposed it, who signed, and who committed:

```ring
aOk = oDesk.Commit(nBench, "FOURN-2026-10", HumanActor("tresorier"))
? aOk[:committed]                                    #--> 1
aRes = aOk[:results]
? aRes[1][:statut]                                   #--> ENVOYE
? StzFileExists(cDir + "/FOURN-2026-10.plan.json")   #--> 1
StzCloseAgentWorkbench(nBench)
StzDirDeleteAll(cDir)

oHub.AdvanceSeconds(25)
aSent = oTreasury.SentPayment("FOURN-2026-10-1")
? aSent[:statut]                                     #--> IRREVOCABLE
```

---

## And in production, the twin is refused

Everything above ran against the twin, and a platform that went live with the twin still
bound would take a customer's QR, show them *paid*, and receive nothing. So a platform
declares its payment service in a registry, binds what it has, and the registry judges
that binding against the phase the platform says it is in. The twin is welcome in
development and is refused in production:

```ring
oStore = StzSecretStoreQ("boutique")
oClient = StzPispiSecretQ("bia", "client")
oClient.FromLiteral(StzEngineCryptoRandomHex(8))     # generated here; a real one comes from the environment or a vault
oStore.Register(oClient)

oReg = StzServiceRegistryQ("boutique")
oReg.Declare(:payments)
oReg.Bind(:payments, StzPaymentsPortQ(oHub))
? oReg.PostureOf(:payments)                          #--> sandbox
oReg.SetPhase(:production)
? oReg.IsSoundVia(oStore)                            #--> 0
aS = oReg.FindingsVia(oStore)
? aS[1][:invariant]                                  #--> sandbox-in-production
```

The BCEAO's own sandbox speaks the real protocol with virtual money. It is a stage, and it
is not the platform's money either, so it is refused in production too, under a name of its
own:

```ring
oReg.BindConformance(:payments, StzPaymentsPortQ(oHub), "pispi-bia-client")
? oReg.PostureOf(:payments)                          #--> conformance
aC = oReg.FindingsVia(oStore)
? aC[1][:invariant]                                  #--> conformance-in-production
```

A live binding is the last one, and it has its own condition: the production hub asks
the platform for a certificate of its own, issued by the BCEAO, and a binding that names no
such certificate in the store is refused. Naming it is not enough; it must exist in the
store, and it must not have expired:

```ring
oReg.BindLiveWithCertificate(:payments, StzPaymentsPortQ(oHub), "pispi-bia-client", "pispi-bia-mtls-cert")
? oReg.PostureOf(:payments)                          #--> live
aL = oReg.FindingsVia(oStore)
? aL[1][:invariant]                                  #--> live-without-certificate

oCert = StzPispiSecretQ("bia", "mtls-cert")
oCert.FromLiteral(StzEngineCryptoRandomHex(8))
oCert.SetExpiry( StzEngineTimeNowMs() / 1000 + 365 * 86400 )
oStore.Register(oCert)
? oReg.IsSoundVia(oStore)                            #--> 1
```

That last `1` is the registry's judgement of the *binding*, never a payment. This page has
bound the twin under a live name, to show the registry's three refusals and its one
acceptance, and a platform that wants the live hub replaces the twin with the live adapter
in that one line. Whether the BCEAO's sandbox, and then BIA Niger, pays when that is done is
a thing a person must watch happen, and until one has, it is *unperceived*.

---

## What the platform now has

- a code at the till in the BCEAO's own format, **built and read back with its checksum checked**,
- an event that is **verified before it is believed**, and noted when it is not,
- a payment out that **cannot leave without a plan a human committed**, under the rule the
  platform wrote, with the record of who signed it,
- and a registry that **refuses the twin in production**, three different ways.

The twin, the contract, and these refusals are the same on every platform that uses the
library. What is left to each platform is the part that is theirs: their own rule, their own
visas, and the one afternoon on which somebody makes a real payment and says that they saw it land.
