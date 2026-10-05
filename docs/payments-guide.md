# Taking and sending money from your application

*A practical guide for an application developer. You write a platform; you want customers to pay
it, and you want it to pay its suppliers, in francs CFA, over the BCEAO's PI-SPI instant-payment hub.*

This guide is a path, not a reference. Follow it top to bottom once, then keep the last two sections
open while you build. Every code block marked `ring` is **run** by `test/system/payments_guide.py`,
and every `#-->` is what it printed, so what you read here is what the library does.
Blocks marked `ring live` talk to a real hub and are never run by anybody but you.

---

## 0. What you are getting, and what you are not

You get **one port**. It speaks the PI-SPI contract (the BCEAO's "API Business") and nothing else: no
vendor's name appears in any verb. You write your application against the port, you test it against
the **twin** (a hub that lives inside your process and moves no money), and you go live by changing
**one line**: the thing the port talks to.

| you get | how it behaves |
|---|---|
| **Amounts that carry their currency** | `150 000 FCFA` cannot be built without `XOF`, and `50.5 XOF` is refused: a franc has no fraction |
| **Payments with an idempotency key** | send the same `txId` twice and the money moves once |
| **A QR payload** in the BCEAO's format | built and read back, checksum verified |
| **Webhooks verified before they are believed** | forged, unsigned and replayed calls are refused and noted |
| **Money out as a plan a human commits** | an agent can propose a payout; only a person's commit releases it |
| **A registry that refuses fakes in production** | the twin, and the BCEAO's sandbox, are refused when you say you are live |
| **A live adapter** | OAuth2, API key and mutual TLS, for any participant |

| you do **not** get | why |
|---|---|
| **A fee, in any form** | none is ever added by this library, by ruling |
| **An account** | the library never opens one; you open yours with your participant (a bank or an operator) |
| **A wallet, an aggregator, a payment institution** | the money is the participant's, and the hub moves it |
| **A promise that a given bank's API works** | the contract is the BCEAO's; which participant's API is homologated is the BCEAO's list |
| **The picture of a QR code** | the *string* is built here; the black-and-white matrix a camera reads is not (section 4) |

**Where this stands today, honestly.** Everything in sections 1 to 8 runs against the twin and is
tested. The live adapter is proven against the twin served over real HTTP, plain and with mutual
TLS. It has **not** yet been run against the BCEAO's sandbox, and no payment made through it has
been watched landing in a real dashboard. Until a named person has seen that, treat the live path as
**unperceived**: it is built, and it is not yet proven in the world. Section 9 says what you do about that.

---

## 1. The three things you touch

```
  your application
        |
     the PORT   <-- the verbs: Pay, RequestPayment, StatusOf, ReceiveWebhook ...
        |
   a BACKEND    <-- the twin (development)  |  the live adapter (production)
```

* the **port** (`StzPaymentsPortQ`) is what your code calls;
* the **twin** (`StzPiSpiSandboxQ`) is a complete hub in your process: aliases, balances, a clock you move
  by hand, customers who pay, webhooks it signs;
* the **registry** (`StzServiceRegistryQ`) is where you declare "my platform needs payments", bind
  what serves it, and say which phase you are in. It is what stops the twin reaching production.

---

## 2. Your first payment

Load the library (adjust the path to where your copy of `stzBase.ring` lives), start a twin, and put a
port in front of it.

```ring
load "../../stzBase.ring"

oHub = StzPiSpiSandboxQ()                            # a hub in your process; IsSandbox() is 1
oPay = StzPaymentsPortQ(oHub)                        # the port: the same verbs over any hub
oPay.AllowUngovernedPayouts()                        # for these first steps only; section 6 is the governed way
? oHub.IsSandbox()                                   #--> 1
```

An **order** says who pays whom, how much, and under which id. The `txId` is **yours**, it is unique,
and it is the key that makes a retry safe.

```ring
oOrder = StzPaymentOrderQ()
oOrder.WithTxId("APP-2026-000001")                   # your id: at most 35 characters
oOrder.FromAlias(oHub.BusinessAlias())               # the account debited: your platform's
oOrder.ToAlias(oHub.Alias("fatou"))                  # the payee, by PI-SPI alias
oOrder.WithAmount( StzAmountQ("25000", "XOF") )      # 25 000 FCFA
oOrder.Motive("Facture 2026-001")                    # shown to the payee, at most 140 characters
oOrder.WithoutConfirmation()

aR = oPay.Pay(oOrder)
? aR[:statut]                                        #--> ENVOYE
```

`ENVOYE` is not "done". The hub takes up to **twenty seconds** to make a payment final, and until
then it is *sent*. **Pending is a state, not an error:** never tell a customer a payment failed
because it has not finished. The twin has a clock you move by hand, so you do not wait:

```ring
oHub.AdvanceSeconds(25)
aS = oPay.StatusOf(aR[:end2endId])
? aS[:statut]                                        #--> IRREVOCABLE
```

`IRREVOCABLE` is the word that matters: the money is the payee's and the payer cannot take it back.
The only states you treat as final are `IRREVOCABLE` (it happened) and `REJETE` (it did not).

---

## 3. Money

Every amount is built with its currency, and the library refuses the rest:

```ring
a = StzAmountQ("150000", "XOF")
? a.Display()                                        #--> 150 000 FCFA
? a.MinorUnits()                                     #--> 150000

try
	b = StzAmountQ("50.5", "XOF")                    # a franc has no fraction
catch
	? "refused"                                      #--> refused
done

c = StzAmountQ("12.50", "EUR")                       # other currencies carry their own exponent
? c.MinorUnits()                                     #--> 1250

try
	d = a.Plus(c)                                    # francs plus euros is never an answer
catch
	? "refused"                                      #--> refused
done
```

Never carry money in your own code as a bare number: a `150000` that nobody can tell is francs or
centimes is how a payment goes wrong by a factor of a hundred. Keep the amount object until the last moment.

---

## 4. Getting paid: the QR and the webhook

### 4.1 Show a code

A **dynamic QR** is made for one sale. The string it carries is short and fixed by the BCEAO:
whose account is paid (your PI-SPI alias), how much, and a label you will reconcile on. The customer's
banking application reads it and makes an ordinary payment **to your alias**.

```ring
oQr = StzPispiQrQ()
oQr.WithAlias(oHub.BusinessAlias())                  # your PI-SPI alias: a UUID
oQr.InCountry("NE")                                  # BJ BF CI GW ML NE SN TG
oQr.AsDynamic()                                      # one sale; AsStatic() is a code you print once
oQr.WithReference("APP-2026-000002")                 # at most 25 characters: what the payer sees, what you reconcile on
oQr.WithAmount( StzAmountQ("18500", "XOF") )         # omit it and the payer types the amount
cQr = oQr.Payload()
? StzPispiQrParse(cQr)[:valid]                       #--> 1
```

`cQr` is a **string**. Putting it on a screen as a black-and-white code is a second step that
**this library does not do yet** (it needs a QR matrix encoder, which is being asked for). Until it
exists, hand the string to any QR-drawing component of your front end, or use the BCEAO's own
published SDK for the picture. Whatever draws it, the string is what the phone reads.

The builder refuses what would print a bad code: an alias that is not a UUID, a country outside
the union, a label over 25 characters or outside printable ASCII, an amount that is not whole
positive francs. The reader never raises on a bad string; it tells you what is wrong:

```ring
aBadQr = StzPispiQrParse("0002010102126304BEEF")
? aBadQr[:valid]                                     #--> 0
```

### 4.2 Hear about the payment

Do not poll. Register a **webhook**: you tell the hub where to call you and for which events, and it
signs every call with a secret it gives you once. The port keeps the secret and verifies what arrives.

```ring
oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://app.example/pispi").OnEvents(["PAIEMENT_RECU"]) )

eRecu = oHub.SimulateIncomingPayment("fatou", 18500, "APP-2026-000002")   # the twin: a customer scans and pays
aEv = oPay.ReceiveWebhook(oHub.LastCallbackBody(), oHub.LastCallbackSignature())
? aEv[:accepted]                                     #--> 1
aEvents = aEv[:events]
? aEvents[1][:evCode]                                #--> PAIEMENT_RECU
```

`SimulateIncomingPayment` is a **twin-only** helper: it plays the customer. In production the same call
reaches you as an HTTP POST on your callback URL. You wire that endpoint once:

```ring
oSrv = new stzAppServer()
StzPaymentsWebhookRoute(oSrv, "/pispi/webhook", oPay)   # POST /pispi/webhook is verified by the port
```

That route answers `204` to a good event, `401` to anything forged, unsigned or already believed, and
`400` to something that is not an event at all. **Answer fast and do your work afterwards:** the hub
retries a call it did not see acknowledged, and a retry of an event you already handled is refused as a
replay, which is what you want.

A call that is not what it claims to be is refused, and it is **noted in the security ledger** as well:

```ring
aBad = oPay.ReceiveWebhook(oHub.LastCallbackBody(), "deadbeef")
? aBad[:accepted]                                    #--> 0
? aBad[:status]                                      #--> 401
```

Reconcile on the label you put in the code: the payment you receive carries it as its `motif`.

```ring
aRecus = oPay.ReceivedPayments([])
? len(aRecus)                                        #--> 1
? aRecus[1][:motif]                                  #--> APP-2026-000002
```

---

## 5. Asking for money

When there is no code on a counter, but an invoice, you **ask**: a *request to pay*. The payer's
bank shows it to them, and they accept or refuse. Until they answer, it is pending.

```ring
oRtp = StzPaymentRequestQ()
oRtp.WithTxId("APP-RTP-000001")
oRtp.FromAlias(oHub.Alias("fatou"))                  # who is asked
oRtp.ToAlias(oHub.BusinessAlias())                   # where the money goes
oRtp.WithAmount( StzAmountQ("350000", "XOF") )
oRtp.InCategory("401")                               # 401 an invoice, 500 on the spot, 521 e-commerce
oRtp.PayableBy("2026-10-31")
oRtp.AnswerableBy("2026-10-20")
oRtp.Motive("Facture 2026-045")
oRtp.WithoutConfirmation()

aQ = oPay.RequestPayment(oRtp)
? aQ[:statut]                                        #--> ENVOYE
oHub.AdvanceSeconds(25)
? oPay.RequestedPayment("APP-RTP-000001")[:statut]   #--> IRREVOCABLE
```

And the other way: somebody asks **you**. You list what is waiting and answer it.

```ring
eIn = oHub.SimulateIncomingRequest("kdi", 9000, "Devis 12")
? len(oPay.ReceivedRequests([ ["statut", "ENVOYE"] ]))   #--> 1
aA = oPay.AnswerRequest(eIn, FALSE, "AM09")          # refuse: the amount is wrong
? aA[:statut]                                        #--> REJETE
```

Answering a request to pay is *sending money*, so on a governed port it is a payout and goes through
section 6. This example runs on the ungoverned port of section 2 and says so.

---

## 6. Paying out: a plan, not a call

Receiving money is a read of the world. Sending it is the one act in this guide that can hurt, so a
**governed** port (the default) refuses to send a payment on its own. It wants a **plan**:

1. **someone proposes it**: a clerk's script, an agent, a person;
2. **it is rehearsed** into a copy of the disk, so nothing real moves;
3. **a rule judges it**. The rule is *yours*: it is data, not a constant in the library. This example's rule
   is "above 100 000 francs, four visas from four distinct people";
4. **a person commits it**, and only then does the hub hear of it. An LLM can propose and cannot commit.

```ring
cDir = CurrentDir() + "/_guide_payouts"
StzDirDeleteAll(cDir)
StzDirCreatePath(cDir)

oTreasury = StzPaymentsPortQ(oHub)                   # governed: the default
oDesk = StzPayoutDeskQ(oTreasury, StzDikoPayoutPolicyQ(), cDir)

oSupplier = StzPaymentOrderQ()
oSupplier.WithTxId("APP-SUP-000001")
oSupplier.FromAlias(oHub.BusinessAlias())
oSupplier.ToAlias(oHub.Alias("boutique"))
oSupplier.WithAmount( StzAmountQ("350000", "XOF") )
oSupplier.Motive("Fournisseur, facture 2026-045")
oSupplier.WithoutConfirmation()

try
	oTreasury.Pay(oSupplier)                         # no plan: refused before the hub hears of it
catch
	? "refused"                                      #--> refused
done

oPlan = StzPayoutPlanQ()
oPlan.WithId("SUP-2026-10")
oPlan.ProposedBy("treasury-agent")
oPlan.Paying(oSupplier)
oPlan.Visa("comptable", "A. Issoufou")
oPlan.Visa("DAF", "M. Garba")
oPlan.Visa("DG", "H. Maiga")                         # three visas: not enough for 350 000

nBench = StzOpenAgentWorkbench()
oDesk.Rehearse(oPlan, nBench)                        # a copy of the disk: nothing real moves
oReport = oDesk.Judge(nBench, "SUP-2026-10")
? oReport.IsSound()                                  #--> 0
aErr = oReport.Errors()
? aErr[1][:rule]                                     #--> payout-over-100000-needs-4-visas
```

The verdict names the rule that fails. Collect the missing visa, rehearse again, and the plan is sound
(and still not a payment):

```ring
oPlan.Visa("CA", "S. Abdou")
oDesk.Rehearse(oPlan, nBench)
oReport = oDesk.Judge(nBench, "SUP-2026-10")
? oReport.IsSound()                                  #--> 1

aLlm = oDesk.Commit(nBench, "SUP-2026-10", LLMActor("assistant"))
? aLlm[:reason]                                      #--> actor

aOk = oDesk.Commit(nBench, "SUP-2026-10", HumanActor("tresorier"))
? aOk[:committed]                                    #--> 1
? aOk[:results][1][:statut]                          #--> ENVOYE
? StzFileExists(cDir + "/SUP-2026-10.plan.json")     #--> 1
StzCloseAgentWorkbench(nBench)
StzDirDeleteAll(cDir)
```

The committed plan stays on disk: who proposed it, who signed it, who committed it. That file is your
audit trail. Three things to know:

* **Your rule is yours.** `StzDikoPayoutPolicyQ()` is one platform's policy. Build yours with
  `StzPayoutPolicyQ("mine")`, `RequireVisasAbove(amount, count)` and, if you want separation of duties,
  `ProposerCannotVisa()`.
* **A plan's weight is the sum of what it pays**, so a payroll cannot be cut into small lines to slip
  under a threshold. Splitting a payroll across several plans needs a different rule (over a period); the
  library does not give you one by accident.
* **One plan, one workbench.** A commit crosses everything its workbench rehearsed.

---

## 7. When it goes wrong

### 7.1 The hub says no

A refusal from the hub arrives as a **problem** (RFC 7807): a status, a title, a detail. The port raises it, and
you read it:

```ring
oBig = StzPaymentOrderQ()
oBig.WithTxId("APP-BIG-1")
oBig.FromAlias(oHub.BusinessAlias())
oBig.ToAlias(oHub.Alias("fatou"))                    # a person: at most 10 000 000 FCFA
oBig.WithAmount( StzAmountQ("20000000", "XOF") )
oBig.WithoutConfirmation()
try
	oPay.Pay(oBig)
catch
	oP = StzLastPaymentsProblem()
	? oP.Status()                                    #--> 403
	? oP.Detail()                                    #--> Plafond de paiement depasse
done
```

A payment the **payee's bank** refuses is not an exception: it is a payment whose state became `REJETE`,
with the reason (an ISO 20022 code such as `AM04`, insufficient funds) in `statutRaison`. You learn of it by
status or by the `PAIEMENT_REJETE` event.

```ring
oHub.SetCounterparty("kdi", "AM04", "pay", "accept")   # the twin: this customer's bank rejects a payment to them
oBank = StzPaymentOrderQ()
oBank.WithTxId("APP-REJ-1")
oBank.FromAlias(oHub.BusinessAlias())
oBank.ToAlias(oHub.Alias("kdi"))
oBank.WithAmount( StzAmountQ("5000", "XOF") )
oBank.WithoutConfirmation()
aRej = oPay.Pay(oBank)
oHub.AdvanceSeconds(25)
aRejS = oPay.StatusOf(aRej[:end2endId])
? aRejS[:statut]                                     #--> REJETE
? aRejS[:statutRaison]                               #--> AM04
```

### 7.2 You do not know whether it happened

The network dropped after you sent. The money may or may not have moved. **Send the same order again.**
The `txId` is the key: the port reads before it sends, and if the hub already has it you get the first
result back and the money moves once.

```ring
nBefore = oHub.NumberOfPayments("ENVOYE")
aAgain = oPay.Pay(oOrder)                            # the order of section 2, sent again
? aAgain[:replayed]                                  #--> 1
? aAgain[:end2endId] = aR[:end2endId]                #--> 1
? oHub.NumberOfPayments("ENVOYE") - nBefore          #--> 0
```

Over a real network, a response that never comes is raised as a **transport** error (not a payment
problem), and the port remembers the `txId` so your retry reads the hub first. **Never generate a new
`txId` to retry.** A new id is a new payment.

### 7.3 A payment you want back

A payment is **irrevocable**: there is no "cancel". There are two other things, and both are *asks*:

* a **cancellation request**, which the payee may refuse (`RequestCancellation`);
* a **return of funds**, a *new* movement that sends the money back (`ReturnFunds`).

Each must be made within **90 days**. Both are payouts, so on a governed port they go through a plan.

---

## 8. Test your integration before it meets a bank

The twin has what a test needs, and none of it exists in production:

| you want to test | you do |
|---|---|
| a payment that is still pending, then final | `oHub.AdvanceSeconds(25)`, or `oHub.SettleEverything()` |
| a customer who pays you | `oHub.SimulateIncomingPayment("fatou", 40000, "motif")` |
| a customer who asks you | `oHub.SimulateIncomingRequest("kdi", 9000, "motif")` |
| a customer's bank that refuses | `oHub.SetCounterparty("kdi", "AM04", "pay", "accept")` |
| the hub's quota (429) | `oHub.SetRateLimit(3, 10000)` |
| the webhooks that went out | `oHub.Deliveries()`, `oHub.LastCallbackBody()`, `oHub.LastCallbackSignature()` |
| your balance | `oHub.Balance()` (in the hub's minor unit: francs) |

**Test the webhook endpoint over real HTTP too.** `StzPiSpiHttpFrontQ` serves the twin behind
`stzAppServer` with the OAuth2 token endpoint, the API key and, if you want, mutual TLS, in a real
server process. It is how the live adapter itself is tested, and it lets your own code talk to a
hub across a socket before it talks to a bank.

The library's own guards are the best worked examples; they are narrated and run in seconds:

```bash
cd libraries/stzlib/base/test/system
ring pispi_twin_narrated.ring          # every verb of the contract, 311 assertions
ring payments_governance_narrated.ring # money out as a plan
ring payments_webhooks_narrated.ring   # the four refusals of a webhook
ring payments_live_adapter_narrated.ring  # the adapter over real HTTP, plain and mutual TLS
ring payments_qr_narrated.ring         # the QR string
```

---

## 9. Going live

Going live changes **three things**, and the registry refuses to let you do it half-way.

### 9.1 Put your secrets in a store, not in a file

A live payment needs five secrets: the OAuth client, the API key, the mTLS private key and certificate, and
a webhook secret. **None of them is ever written in a source file, a log, a memo or a test.** They arrive
from the environment, a file outside your repository, or a vault:

```ring live
oStore = StzSecretStoreQ("myplatform")
StzPispiRegisterDescriptors(oStore, "bia")           # five NAMES, no values yet

oClient = StzPispiSecretQ("bia", "client")
oClient.FromEnv("PISPI_CLIENT")                      # "<client id>:<client secret>", read from the environment
oStore.Register(oClient)

oKey = StzPispiSecretQ("bia", "api-key")
oKey.FromEnv("PISPI_API_KEY")
oStore.Register(oKey)

oCert = StzPispiSecretQ("bia", "mtls-cert")
oCert.FromFile("/etc/myplatform/bia-client.crt")     # a PATH: the private key never enters your program
oCert.SetExpiry( 1830000000 )                        # the certificate's end, in epoch seconds (read it from the certificate)
oStore.Register(oCert)
```

A secret **expires**: the sandbox's certificate lasts a year, and a renewed webhook secret lapses on a
date you choose. The library does not check the date when you pay. A **watch** reads the store and tells the
security ledger, once, when something is about to expire (30 days by default) or has:

```ring live
oWatch = StzSecretExpiryWatchQ(oStore)
oWatch.Cycle()                                       # run it on a timer; give it the current store each time
```

### 9.2 Swap the twin for the adapter

```ring live
oAd = StzPispiHttpAdapterQ()
oAd.WithParticipant("bia")
oAd.WithBaseUrl("https://<your participant's API Business URL, version included>")
oAd.WithSecretsFrom(oStore, HumanActor("service"))   # the client and API key come through the governed door
oAd.WithCertificateFrom(oStore)                      # mutual TLS: descriptors that name PEM files
oAd.AsLive()                                         # AsConformance() for the BCEAO's sandbox

oPay = StzPaymentsPortQ(oAd)                         # NOTHING ELSE in your code changes
```

The adapter does the plumbing for every call: it asks for an OAuth token with the scopes it needs, caches
it and refreshes it before it lapses (and retries once on a 401), sends your API key, and presents your
certificate. The base URL is **configuration**: the contract is the BCEAO's, and nothing in the adapter
names a bank. For the BCEAO's sandbox, scopes are prefixed `piz/`:
`oAd.WithScopePrefix("piz/")`.

### 9.3 Declare it, bind it, and let the registry judge

```ring live
oReg = StzServiceRegistryQ("myplatform")
oReg.Declare(:payments)                              # "my platform needs payments"
oReg.BindLiveWithCertificate(:payments, oPay, "pispi-bia-client", "pispi-bia-mtls-cert")
oReg.SetPhase(:production)

if not oReg.IsSoundVia(oStore)
	? oReg.FindingsVia(oStore)                       # each finding names the invariant that failed
	# refuse to start
ok
```

In production the registry **refuses**: the twin (`sandbox-in-production`); the BCEAO's own sandbox,
which speaks the real protocol with virtual money (`conformance-in-production`); a live binding whose secret
is only a name (`live-without-secret`); and one whose certificate is missing or expired
(`live-without-certificate`). Make the check part of your start-up, so that a platform with the twin still bound
cannot take a customer's code, show them *paid*, and receive nothing.

### 9.4 Say that nobody has seen it yet

The adapter has been run against the twin over real HTTP and has not yet been run against the BCEAO's
sandbox. **Do the conformance run before you rely on it:** with credentials your participant gives you for the
sandbox, run `test/system/payments_conformance_run.ring` (it reads them from environment variables and
prints what is missing if you have none). Then a *person* opens the sandbox dashboard and watches a payment
land, and writes down who they are and what they saw. A counter cannot tell you that a payment
arrived. Until that has happened, your integration is built and **unperceived**.

---

## 10. A checklist before the first real franc

- [ ] every amount is a `StzAmountQ`, in `XOF`, never a bare number
- [ ] every payment has **your own** `txId`, and a retry reuses it
- [ ] you treat `ENVOYE` as pending, and only `IRREVOCABLE` as done
- [ ] your webhook route is mounted with `StzPaymentsWebhookRoute`, answers fast, and your handler does its work *after* acknowledging
- [ ] you reconcile on the label you put in the code, and on `end2endId`
- [ ] your payouts go through a plan, with a policy that is **yours** and a human who commits
- [ ] no secret is in a file, a log, a test or a message; they come from a store
- [ ] a watch runs on the store, and somebody reads what it says
- [ ] your start-up refuses to run in production when `IsSoundVia(...)` is `0`
- [ ] the conformance run was done and **a named person** saw a payment land in the sandbox
- [ ] nothing in your platform adds a fee to a payment

## 11. Never

* **Never invent a status word.** The hub's `statut` is the state. Do not store your own "paid".
* **Never retry with a new `txId`.** That is a second payment.
* **Never believe a webhook you did not verify**, and never skip the check "just in the test environment".
* **Never put the twin in production.** The registry will refuse it; do not look for a way around the registry.
* **Never promise a customer that a given bank is supported** because the contract is. Which participants'
  APIs are homologated is the BCEAO's published list, and it changes.

## 12. Where to look next

| you want | read |
|---|---|
| every verb with an example that runs | `libraries/stzlib/base/service/SOFTANZA_PAYMENTS_PORT.md` |
| the whole story told once, end to end | `libraries/stzlib/base/doc/narrations/stz-getting-paid-and-paying-narration.md` |
| what the library found that differs between the BCEAO's pages, its examples and its SDKs | the charter, section 11 |
| how a payout is judged | the charter, section 7, and `payments_governance_narrated.ring` |
| how a webhook is verified | the charter, section 8, and `payments_webhooks_narrated.ring` |
