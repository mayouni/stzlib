# The Payments Port
### Charter: payment as a normal service of any Softanza platform in the UEMOA, shaped on the PI-SPI API Business

Plane `stzlib-payments`, rung PY0. Written 2026-10-04 from the API Business
reference **v1.5.0 (2026-08-27)** read at `https://developer.pispi.bceao.int`
(the OpenAPI document at `/api-spec/openapi.yml` and the 284 files it
references, fetched to closure), from the Payments Compass of 2026-10-04, and
from this repository at `origin/main` 010743cce. Where this charter and the
reference disagree, the reference is right and the divergence is a finding;
where this charter and the repository disagree, the repository is right.

Every example below is Ring that will RUN once PY2 lands. Until then the
examples are the contract's specification, not its proof. A guard named
beside each rung turns the example into evidence.

---

## 0. The one fact that makes this a standard and not a vendor

On 2025-09-30 the BCEAO put the **PI-SPI** into service: the Plateforme
Interopérable du Système de Paiement Instantané, a hub the central bank
operates itself. ISO 20022 messages, account aliases, one interoperable EMV
QR, request-to-pay, no direct debit, a payment irrevocable in at most 20
seconds. Its rulebook obliges **every participant** (bank, microfinance,
e-money issuer, payment institution) to expose **one standardised API
Business** to its business clients, and says no other channel is authorised
for automation. 24 participant APIs were homologated on 2026-09-17, 175
participants authorised on 2026-09-30, and the hub is mandatory for
interoperable e-money from 2026-11-02. BIA Niger's API Business is
homologated (the author, 2026-10-04), and BIA is DIKO's main bank.

So the port is shaped on the API Business and on nothing else. A platform
needs a business account at a homologated participant and this library. The
participant changes the base URL; the contract does not change.

---

## 1. What this port is, in one paragraph

A payments port is the object a platform talks to when money must move or
be asked for. It speaks the PI-SPI verbs (section 2), carries money as an
amount WITH a currency (section 4), names every movement by the platform's
own `txId` and the hub's `end2endId` (section 3), answers errors in the RFC
7807 shape the hub uses (section 5), and exists in four postures that one
registry law governs: a Softanza twin, the BCEAO conformance sandbox, a
local real, and a live participant (section 6). Money leaving the platform
is a plan a human commits, never a method call (section 7). A webhook is
believed only after its signature is verified (section 8). The library takes
no fee, holds no funds, and never creates an account (section 9).

---

## 2. The verbs

The port's verbs are the API Business operations, named in Softanza's
English, with the hub's French resource names kept in the table so a reader
of the reference and a reader of the code find each other.

| port verb | API Business operation | scope | hub idempotency |
|---|---|---|---|
| `ResolveAlias(cAlias)` | `GET /alias/{cle}` | `enrolement_alias.read` | read |
| `Pay(oOrder)` | `POST /paiements-envoyes` | `paiement.write` | duplicate `txId` is REJETE / DU03 |
| `ConfirmPayment(cTxId, bYes)` | `PUT /paiements-envoyes/{txId}/confirmations` | `paiement.write` | 403 after the opposite answer |
| `RequestPayment(oRequest)` | `POST /demandes-paiements` | `demande_paiement.write` | duplicate `txId` is REJETE / DU03 |
| `ConfirmRequest(cTxId, bYes)` | `PUT /demandes-paiements/{txId}/confirmations` | `demande_paiement.write` | 403 after the opposite answer |
| `AnswerRequest(cEnd2EndId, bAccept, cReason)` | `PUT /demandes-paiements-recues/{end2endId}/reponses` | `demande_paiement_reponse.write` | idempotent on the same answer |
| `ReturnFunds(cEnd2EndId)` | `PUT /paiements/{end2endId}/retours` | `retour_fonds.write` | idempotent: a sent return answers IRREVOCABLE again |
| `RequestCancellation(cEnd2EndId, cMotif)` | `POST /paiements/{end2endId}/annulations` | `demande_annulation.write` | NOT idempotent: each call is a new request |
| `AnswerCancellation(cEnd2EndId, bAccept)` | `PUT /paiements/{end2endId}/annulations/reponses` | `demande_annulation_reponse.write` | idempotent on the same answer |
| `PayInBulk(oBatch)` | `POST /paiements-groupes` | `paiement_groupe.write` | duplicate `instructionId` refused |
| `ConfirmBulk(cInstructionId, bYes)` | `PUT /paiements-groupes/{instructionId}/confirmations` | `paiement_groupe.write` | 403 after the opposite answer |
| `RequestPaymentsInBulk(oBatch)` | `POST /demandes-paiements-groupes` | `demande_paiement_groupe.write` | duplicate `instructionId` refused |
| `StatusOf(cEnd2EndId)` | `GET /paiements/{end2endId}` | `paiement.read` | read; answers IRREVOCABLE or REJETE only, 20 s after the send, up to 90 days |
| `SentPayment(cTxId)` / `ReceivedPayment(cTxId)` | `GET /paiements-envoyes/{txId}` / `GET /paiements-recus/{txId}` | `paiement.read` | read |
| `SentPayments(aFilter)` / `ReceivedPayments(aFilter)` | `GET /paiements-envoyes` / `GET /paiements-recus` | `paiement.read` | read, paged, filtered |
| `Bulk(cInstructionId)` | `GET /paiements-groupes/{instructionId}` | `paiement_groupe.read` | read |
| `Requests(aFilter)` / `ReceivedRequests(aFilter)` | `GET /demandes-paiements` / `GET /demandes-paiements-recues` | `demande_paiement.read` | read |
| `Accounts()` / `Account(cNumero)` | `GET /comptes` / `GET /comptes/{numero}` | `compte.read` | read |
| `Aliases(cNumero)` / `CreateAlias(cNumero, oAlias)` / `DeleteAlias(cNumero, cCle)` | `GET`/`POST /comptes/{numero}/alias`, `DELETE .../alias/{cle}` | `alias.read` / `alias.write` / `alias.delete` | 409 on an existing alias |
| `TransferBetweenAccounts(cTxId, cFrom, cTo, oAmount)` | `POST /comptes/transactions` | `compte_transaction.write` | 409 on a duplicate `txId` |
| `Participants()` | `GET /participants` | `participant.read` | read; the only participant list the code may carry is this one, dated |
| `RegisterWebhook(oHook)` / `Webhooks()` / `ChangeWebhook(cId, oChange)` / `DeleteWebhook(cId)` / `RenewWebhookSecret(cId, cExpiresAt)` | `/webhooks`, `/webhooks/{id}`, `/webhooks/{id}/secrets` | `webhook.*` | at most 20 hooks; 403 on the 21st |
| `ReceiveWebhook(cBody, cSignature)` | the callback the participant POSTs to the platform | none (inbound) | section 8 |

**The card verbs are one adapter, not the port.** `Authorize / Capture /
Refund` survive in `stzCardPaymentsAdapter` (the renamed body of today's
`stzPaymentsSandbox`) so the 49 checks of `payments_port_narrated` keep
passing. They are the shape of a card gateway, and a card gateway is one
thing a platform may bind to the same registry name. They are not the shape
of money in the UEMOA.

Every block below is RUN by `charter_examples.py` (next to the guards): each `?` line carries
its expected output after `#-->`, and a block whose output differs fails. The blocks of this
section share one session and one twin, in order.

*Builders are named for what they say, not for brevity:* `FromAlias`, `ToAlias`, `WithAmount`,
`Motive` (`For` is a Ring keyword). Two Ring traps the examples avoid, found while building PY2:
a `return Q().Method()` chain inside a *function* crashes the VM silently (assign first, then
return), and a call result cannot be indexed with a key, so read it into a variable.

### 2a. Pay

```ring
load "../../stzBase.ring"

oHub = StzPiSpiSandboxQ()                            # the twin; IsSandbox() is 1
oPay = StzPaymentsPortQ(oHub)
oPay.AllowUngovernedPayouts()                        # these examples drive the twin directly; section 7 is the governed path

oOrder = StzPaymentOrderQ()
oOrder.WithTxId("DIKO-2026-000417")                  # the platform's id, unique
oOrder.FromAlias(oHub.BusinessAlias())               # payeurAlias: the account debited
oOrder.ToAlias(oHub.Alias("fatou"))                  # payeAlias
oOrder.WithAmount( StzAmountQ("150000", "XOF") )     # 150 000 FCFA, zero decimals
oOrder.Motive("Facture 2026-045")                    # motif, at most 140 characters
oOrder.Documented("INV-2026-045", "CINV")            # refDocNumero, refDocType
oOrder.WithoutConfirmation()                         # confirmation: false

aR = oPay.Pay(oOrder)
? aR[:statut]        #--> ENVOYE
? aR[:end2endId]     #--> ENEB00120261005090001TWIN0000000001

oHub.AdvanceSeconds(25)                              # the twin's clock: the hub takes up to 20 s
aS = oPay.StatusOf(aR[:end2endId])
? aS[:statut]        #--> IRREVOCABLE
```

`ENVOYE` is the hub's own word and it is *pending*: the money has left the balance and nothing
is final. `IRREVOCABLE` or `REJETE` arrives 20 seconds later, by a signed webhook (section 8) or
by asking, and the port never invents a word such as "pending" or "success".

### 2b. Request to pay

```ring
oRtp = StzPaymentRequestQ()
oRtp.WithTxId("DIKO-RTP-000091")
oRtp.FromAlias(oHub.Alias("fatou"))                  # the payer we ask
oRtp.ToAlias(oHub.BusinessAlias())                   # where we want the money
oRtp.WithAmount( StzAmountQ("350000", "XOF") )
oRtp.InCategory("401")                               # 500 on-site, 521 e-commerce, 401 invoice
oRtp.PayableBy("2026-10-31")
oRtp.AnswerableBy("2026-10-20")
oRtp.Motive("Facture #INV-2026-045")
oRtp.WithoutConfirmation()

aQ = oPay.RequestPayment(oRtp)
? aQ[:statut]        #--> ENVOYE
oHub.AdvanceSeconds(25)
aQ2 = oPay.RequestedPayment("DIKO-RTP-000091")
? aQ2[:statut]       #--> IRREVOCABLE
? oHub.Balance()     #--> 50200000
```

IRREVOCABLE here means the payer paid; `REJETE` means the payer refused (with a reason such as `ARFR`).

### 2c. Answering a request we received

```ring
eIn = oHub.SimulateIncomingRequest("kdi", 9000, "Devis 12")
aIn = oPay.ReceivedRequests([ ["statut", "ENVOYE"] ])
? len(aIn)           #--> 1
aA = oPay.AnswerRequest(eIn, FALSE, "AM09")          # refuse: wrong amount
? aA[:statut]        #--> REJETE
? aA[:statutRaison]  #--> AM09
```

Accepting is *money out* (it pays the request), so it belongs to section 7; rejecting needs one of
`BE05 AM09 APAR RR07 FR01`.

### 2d. Return and cancellation

```ring
eRecu = oHub.SimulateIncomingPayment("fatou", 40000, "Don")
aRet = oPay.ReturnFunds(eRecu)                       # we were paid; we give it back: a NEW movement
? aRet[:retourStatut]        #--> INITIE

oHub.AdvanceSeconds(25)
aSent = oPay.SentPayment("DIKO-2026-000417")         # the payment of 2a, irrevocable by now
aQa = oPay.RequestCancellation(aSent[:end2endId], "DUPL")   # we paid twice: we ASK, the payee may refuse
? aQa[:annulationStatut]     #--> ENVOYE

eAsk = oHub.SimulateIncomingPayment("kdi", 8000, "x")
oHub.SimulateCancellationRequest(eAsk, "AM09")       # someone asks US to cancel
aAns = oPay.AnswerCancellation(eAsk, TRUE)           # TRUE starts our return
? aAns[:annulationStatut]    #--> ACCEPTE
```

### 2e. Bulk

```ring
oBatch = StzPaymentBatchQ()
oBatch.WithInstructionId("DIKO-SAL-2026-10")         # one id for the whole batch
oBatch.FromAlias(oHub.BusinessAlias())
oBatch.Motive("Salaires octobre 2026")
oBatch.WithConfirmation()

o1 = StzPaymentOrderQ()
o1.WithTxId("DIKO-SAL-2026-10-001")
o1.ToAlias(oHub.Alias("fatou"))
o1.WithAmount( StzAmountQ("150000", "XOF") )
oBatch.Add(o1)

o2 = StzPaymentOrderQ()
o2.WithTxId("DIKO-SAL-2026-10-002")
o2.ToAlias(oHub.Alias("boutique"))
o2.WithAmount( StzAmountQ("200000", "XOF") )
oBatch.Add(o2)

aB = oPay.PayInBulk(oBatch)
? aB[:statut]                #--> INITIE
? aB[:transactionsTotal]     #--> 2
oPay.ConfirmBulk("DIKO-SAL-2026-10", TRUE)
oHub.AdvanceSeconds(25)
aB2 = oPay.Bulk("DIKO-SAL-2026-10")
? aB2[:statut]                      #--> CONFIRME
? aB2[:transactionsIrrevocables]    #--> 2
```

Every `txId` inside a batch is still unique for the platform; the batch's
`instructionId` is unique too. The reference recommends 500 to 5,000 items
per batch and about 310 bytes per item.

---

## 3. Identifiers

| name | who mints it | where it appears | law |
|---|---|---|---|
| `txId` | the platform | every order, request, bulk item, intra transfer | at most 35 characters; **unique for the platform, forever**; the hub rejects a repeat with `DU03` (409 for intra transfers) |
| `end2endId` | the hub | every payment, request, return, cancellation, webhook event | the key for status, return, cancellation and answer verbs |
| `instructionId` | the platform | a bulk payment or bulk request | unique for the platform; the hub refuses a repeat |
| `payeAlias` / `payeurAlias` | the participant, on enrolment | orders, requests | a UUID-shaped account alias; the hub also accepts an IBAN or an account number with a `payeParticipant` member code `(BJ|BF|CI|GW|ML|NE|SN|TG)[BCDEF][0-9]{3}` |

**TxId is the platform's idempotency key, and the port makes it so.** The
hub does not return the first submission's state on a replay; it REJECTS
the replay with `DU03` (read at `PaiementImmediatReponse.yml` and
`PaiementStatutRaison.yml`). A platform that retries after a timeout must
therefore not reach the hub twice. The port keeps a journal keyed by `txId`:
a re-submission with a known `txId` answers the recorded state and sends
nothing. The twin proves both halves: asked twice through the port it pays
once and answers the same state; asked twice at the hub face it answers
`DU03` the second time. Ruling 6 of the launch prompt is kept at the port
level and its wire-level mechanism is corrected here.

```ring
nBefore = oHub.NumberOfPayments("ENVOYE")
aAgain = oPay.Pay(oOrder)                            # the order of 2a, sent again
? aAgain[:replayed]                                  #--> 1
? aAgain[:end2endId] = aR[:end2endId]                #--> 1
? oHub.NumberOfPayments("ENVOYE") - nBefore          #--> 0
```

---

## 4. Money

**An amount carries a currency, and the currency carries its minor-unit
exponent from ISO 4217.** `StzAmountQ("5000", "XOF")` is 5,000 francs CFA;
XOF has exponent 0, so `StzAmountQ("50.5", "XOF")` is refused. EUR has
exponent 2, TND has 3. An amount without a currency does not exist; adding
XOF to EUR is refused; a fraction of a franc is refused.

```ring
a = StzAmountQ("150000", "XOF")
? a.Currency()        #--> XOF
? a.Exponent()        #--> 0
? a.MinorUnits()      #--> 150000
? a.Display()         #--> 150 000 FCFA

try
	b = StzAmountQ("50.5", "XOF")                    # XOF has no fraction
catch
	? "refused"       #--> refused
done

c = StzAmountQ("12.50", "EUR")
? c.MinorUnits()      #--> 1250

try
	d = a.Plus(c)                                    # cross-currency arithmetic
catch
	? "refused"       #--> refused
done
```

What this does NOT change:

- `StzMoneyQ(value)` keeps its two places and its 27 checks
  (`numeric_regime_narrated`). It is a numeric REGIME; the port never calls
  it. A currency-bearing amount is a different thing from a number that
  rounds to two places.
- `stzCurrency` stays as it is. Measured on 2026-10-04: `StzCurrencyQ("Niger")`
  answers `west_african_cfa_franc | FractionalUnit = Centime | Base = 100`.
  That is a historical NAME (the centime of the CFA franc exists on paper
  and has not circulated for decades) and a historical base, not the ISO
  4217 exponent, which is 0. `StzCurrencyQ("XOF")` raises R3 today: the
  class knows country and currency names, not ISO codes, and the error path
  it takes calls a function that is not loaded. Neither is this plane's to
  fix; PY1 gives the amount its own exponent table, taken from ISO 4217,
  and reports both facts to the i18n owner.
- **On the wire, XOF has no `devise` field.** The reference's request
  schemas (`PaiementRequestCommun.yml`, `DemandePaiementRequestBase.yml`,
  bulk items) carry `montant: number` and no currency; every amount is in
  XOF by the hub's rule ("Tous les montants sont exprimés en francs CFA
  (XOF)"). The currency therefore lives in the AMOUNT the platform holds,
  and the live adapter refuses to serialise any amount whose currency is not
  the hub's. The `"devise": "XOF"` of the launch prompt's example comes from
  the portal's security guide page, which disagrees with the reference
  (section 11).

Hub ceilings, as data in the twin and the live adapter, dated 2026-08-27:
a business sends up to 10,000,000 XOF to a person or merchant and up to
100,000,000 XOF to a business or government entity; it receives up to
5,000,000 from a person or merchant and up to 100,000,000 from a business or
government. A refused ceiling is `AM02`.

---

## 5. States and errors

### 5a. The status words, from the reference and nowhere else

| object | `statut` values | source file |
|---|---|---|
| a sent payment | `INITIE` -> `ENVOYE` -> `IRREVOCABLE` \| `REJETE`; `ANNULE` if the platform cancels at confirmation | `schemas/paiement/PaiementStatut.yml` |
| a request to pay | `INITIE` -> `ENVOYE` -> `IRREVOCABLE` \| `REJETE`; `ANNULE` | `schemas/demandes-de-paiement/DemandePaiementStatut.yml` |
| a return of funds (`retourStatut`) | `INITIE` -> `ENVOYE` -> `IRREVOCABLE` \| `REJETE` | `schemas/paiement/RetourStatut.yml` |
| a cancellation request (`annulationStatut`) | `INITIE` -> `ENVOYE` -> `ACCEPTE` \| `REJETE` | `schemas/paiement/AnnulationStatut.yml` |
| a bulk payment or bulk request | `INITIE` -> `CONFIRME` \| `ANNULE`; `CONFIRME` directly when no confirmation was asked | `PaiementEnMasseReponseStatut.yml`, `DemandePaiementEnMasseStatutReponse.yml` |
| an intra-account transfer | `INITIE` -> `IRREVOCABLE` \| `REJETE` | `schemas/compte/CompteTransfertIntraReponse.yml` |
| an account | `OUVERT`, `BLOQUE`, `CLOTURE` | `schemas/compte/CompteSolde.yml` |
| a participant | `JOIN`, `ENBL`, `DSBL`, `DLTD` | `schemas/participant/ParticipantStatut.yml` |
| a confirmation answer | `ENVOYE` \| `ANNULE` | `PaiementImmediatConfirmationReponse.yml` |

**Pending is a state.** `INITIE` and `ENVOYE` are both pending from the
platform's side: money has not moved irrevocably. The hub answers the POST
within 20 seconds, but `IRREVOCABLE` or `REJETE` may arrive only by webhook.
The port exposes `IsFinal(cStatut)` -- TRUE for `IRREVOCABLE`, `REJETE`,
`ANNULE`, `ACCEPTE` -- and nothing in the library ever invents a word such
as "pending" or "success" for a status; the hub's word is the status.

### 5b. The reason codes (`statutRaison`, `retourStatutRaison`, `annulationStatutRaison`, a webhook's `motif`)

ISO 20022 external reason codes, four letters. The complete lists are in the
reference files named above; the port carries them as data with a date and
a `Meaning(cCode)` that answers the reference's French sentence. The ones a
platform meets first:

| code | meaning |
|---|---|
| `DU03` | the `txId` is not unique |
| `BE23` | the alias, IBAN or account of the payee is invalid |
| `AC01` | no such account at the destination participant (IBAN / account route) |
| `AB05` | the destination participant did not answer the identity check in time |
| `AG07` | insufficient funds on the debited account |
| `AM02` | amount above the authorised maximum |
| `AM21` | amount above the limit agreed between participant and client |
| `FF10` | internal error at the participant |
| `FR01` | refused for suspected fraud |
| `RR04` | regulatory reason (a listed beneficiary) |
| `AEXR` / `ALAC` / `ARFR` / `ARJR` / `APAR` | the request to pay already expired / was accepted / refused / rejected / paid |
| `CUST` | the payee refused the cancellation; or a return made at the payee's own decision |
| `ARDT` | already returned |

Cancellation motifs a platform SENDS: `AC03` wrong payee, `AM09` wrong
amount, `SVNR` service not rendered, `DUPL` paid twice, `FRAD` fraud.

### 5c. The error shape

Every error the hub returns is an RFC 7807 problem, media type
`application/problem+json`: `type` (a URI, `about:blank` throughout the
reference), `title`, `status`, `detail`, optional `instance`, and the
extension `invalid-params: [ { name, reason } ]`. The HTTP statuses the
reference uses: 400 malformed, 401 missing authorisation, 403 forbidden by
state (the opposite answer already given, a 90-day window passed, a 21st
webhook), 404 unknown resource, 409 already exists, 429 quota exceeded, 500,
502, 503.

The port raises `stzPaymentsProblem` carrying exactly these fields, so a
platform reads `oProblem.Status()`, `.Title()`, `.Detail()`,
`.InvalidParams()`. The twin answers every refusal in this shape, including
its rate-limit refusal (429, the sandbox quota of 100 calls a minute and
10,000 a day; production 1,000 and 100,000, read at the portal's security
guide, not in the OpenAPI document).

```ring
oBig = StzPaymentOrderQ()
oBig.WithTxId("BIG-1")
oBig.FromAlias(oHub.BusinessAlias())
oBig.ToAlias(oHub.Alias("fatou"))                    # a person: at most 10 000 000 FCFA
oBig.WithAmount( StzAmountQ("20000000", "XOF") )
oBig.WithoutConfirmation()
try
	oPay.Pay(oBig)
catch
	oP = StzLastPaymentsProblem()
	? oP.Status()        #--> 403
	? oP.Title()         #--> Forbidden
	? oP.Detail()        #--> Plafond de paiement depasse
done
```

---

## 6. Four postures, one law

The service registry (`stzServiceRegistry`) knew three postures: `:sandbox` a fake that must
not ship, `:local` a genuine local equivalent that may ship, `:live` a remote service reached
with a credential. Payments adds a fourth, because the BCEAO sandbox is neither a fake nor the
real thing: it is the GENUINE hub protocol over VIRTUAL money, with simulated participants and
simulated customers, free, reached with real OAuth credentials and an API key (mTLS is off in
the sandbox).

| posture | what it is | may ship? | credential |
|---|---|---|---|
| `:sandbox` | `stzPiSpiSandbox`, the Softanza twin: in-process, deterministic, signs its own webhooks, answers every verb | never | none |
| `:conformance` | the BCEAO sandbox at `https://sandbox.api.pi-bceao.com/piz/v1`, scopes prefixed `piz/`, mTLS off | never | client id and secret, API key |
| `:local` | not applicable to payments; listed so the registry's law stays one law | -- | -- |
| `:live` | a homologated participant's base URL; today BIA Niger | yes | client id and secret, API key, mTLS key and certificate from the BCEAO CA, webhook HMAC secret |

Two invariants joined the registry's five (PY3), each a guard that failed before:

- **conformance-in-production** (ERROR): the BCEAO sandbox bound while the phase is `:production`.
  Virtual money in production is the same mistake as a fake in production and is caught by the
  same gate. A conformance run is what a platform does BEFORE going live, so in development it is
  expected and the surface is sound.
- **live-without-certificate** (ERROR): a `:live` binding whose mTLS certificate is not in the
  store, has no value, or has lapsed. The adapter says it needs one (`RequiresCertificate()` and
  `CertificateSecretName()`), or the binding names it (`BindLiveWithCertificate`). Refused at
  `IsSound()`, BEFORE the first call, in any phase, from the store alone, exactly where
  `live-without-secret` already refuses a missing API key. A certificate that carries no expiry is
  accepted: the store cannot say it lapsed.

A third, new in PY4: **ungoverned-payouts-in-production** (ERROR), a port that was told to skip the
payout plan (`AllowUngovernedPayouts()`) bound in a production phase. `live-without-secret` was
widened to the conformance posture, and to a descriptor that is in the
store but has no value: a name is not a credential. A graph rule joins them,
`production-part-uses-conformance` in `stzServiceRule`, so "which PART of my solution depends on
virtual money?" is answered while the phase is still development.

```ring
oStore = StzSecretStoreQ("diko")
oClient = StzPispiSecretQ("bia", "client")
oClient.FromLiteral(StzEngineCryptoRandomHex(8))     # generated here; a real one comes from the environment or a vault
oStore.Register(oClient)

oReg = StzServiceRegistryQ("diko")
oReg.Declare(:payments)
oGoverned = StzPaymentsPortQ(oHub)                   # governed, as every port is by default
oReg.Bind(:payments, oGoverned)                      # a port over the twin
? oReg.PostureOf(:payments)                          #--> sandbox
oReg.SetPhase(:production)
? oReg.IsSoundVia(oStore)                            #--> 0
aS = oReg.FindingsVia(oStore)
? aS[1][:invariant]                                  #--> sandbox-in-production

oReg.BindConformance(:payments, oGoverned, "pispi-bia-client")   # the BCEAO's sandbox: real protocol, virtual money
? oReg.PostureOf(:payments)                          #--> conformance
aC = oReg.FindingsVia(oStore)
? aC[1][:invariant]                                  #--> conformance-in-production

oReg.BindLiveWithCertificate(:payments, oGoverned, "pispi-bia-client", "pispi-bia-mtls-cert")
? oReg.PostureOf(:payments)                          #--> live
? oReg.IsSoundVia(oStore)                            #--> 0
aL = oReg.FindingsVia(oStore)
? aL[1][:invariant]                                  #--> live-without-certificate

oCert = StzPispiSecretQ("bia", "mtls-cert")
oCert.FromLiteral(StzEngineCryptoRandomHex(8))
oCert.SetExpiry( StzEngineTimeNowMs() / 1000 + 365 * 86400 )
oStore.Register(oCert)
? oReg.IsSoundVia(oStore)                            #--> 1
```

(The stand-in above binds the port itself as the live adapter, only to show the invariants; the
live adapter is PY5.)

---

## 7. Money out is governed

Receiving money needs no decision; sending it does. A payout is never a method call. It is a
**plan**, and a plan has a life:

| step | who | what happens |
|---|---|---|
| proposed | anyone, an agent included | the plan is REHEARSED into a workbench (`stzAgentWorkbench` over `stzVirtualFileSystem`): a twin of the disk that holds the plan as a document and changes nothing real |
| judged | a policy | **data, read from the rehearsed document**, never a constant in the port; the verdict is in the house shape `[ rule, subject, where, severity, message ]` and joins `stzRuleReport`, the one CI gate |
| committed | an actor that may change reality | across a scope, into a REAL file: the durable journal of what was authorised, visas and all. An LLM can propose and cannot do this |
| released | the port | told exactly which payouts to allow and for how much; it refuses every other |

**DIKO's rule, four visas above 100 000 FCFA, is the first policy**: `StzDikoPayoutPolicyQ()`.
It says ABOVE: exactly 100 000 needs none. A visa is a role and a name, and **the policy counts
people**: the same person signing twice, in any case, is one visa. A plan's weight is the SUM of what
it pays, so a payroll cannot be split into small lines inside one plan to slip under; splitting it
across several plans is a different policy (a rule over a period). Another platform writes another
policy (`StzPayoutPolicyQ("shop").RequireVisasAbove(500000, 2)`, `ProposerCannotVisa()`) and the port
does not change: the port's source holds no threshold and does not speak of visas, and a guard reads the
file to prove it.

**What is money out.** `Pay`, `PayInBulk`, `ReturnFunds`, and the *accepting* answers to a request to
pay (it pays) and to a cancellation (it returns funds). Each is refused by the PORT, before any request
exists and so before the hub hears of it, unless a committed plan authorised that exact payout:

- `payout-without-plan`: no plan authorised it. The ledger hears `payout.unplanned`, an error.
- `payout-amount-differs`: the plan authorised another amount. For a return or an acceptance the port
  asks the hub what it holds, so a plan cannot name an amount the hub does not.
- `payout-already-released`: an authorisation is for ONE payout, and a new plan is needed to send again.

Asking for money, declining to pay, cancelling a bulk, and moving money between the platform's own
accounts are not money out and need no plan. An authorisation belongs to the port that holds it.

**A committing actor** is the actor the library already knows: `effectful` and not `sandboxed`
(`HumanActor`, `PIActor`), the test the registry's `MayGoLive` applies. The capability lattice is closed
(effectful, sensing, compute, inference), so there is no `commit_payout` capability to grant; the gate is
the one every commit in the library passes, and an `LLMActor` fails it.

**What is judged is what would be committed.** The policy reads the rehearsed DOCUMENT, and the commit
refuses (`rehearsal-differs`) when that document is not what the plan now serialises to: visas added
after the rehearsal, or a document edited in the workbench by someone who was not a visa-giver, cannot
reach the port. **One plan, one workbench**, because a commit crosses everything its workbench rehearsed.

A refused commit never raises: it answers `[ committed, reason, detail, results, file ]` with a reason
of `policy`, `rehearsal-differs`, `actor`, `crossing`, `already-committed` or `unknown-plan`, writes a
journal row and a `payout.refused` event. A commit writes the file, a journal row and a
`payout.committed` event, and releases each item; an item the port refuses is that item's result and the
others still go, because each is a separate movement of money.

**The port is governed by default.** Turning it off, `AllowUngovernedPayouts()`, is a loud, named act, is
what a test of the twin does, and is refused in a production phase by the registry
(`ungoverned-payouts-in-production`).

```ring
cDir = CurrentDir() + "/_charter_payouts"
StzDirDeleteAll(cDir)
StzDirCreatePath(cDir)

oTreasury = StzPaymentsPortQ(oHub)                   # governed: the default
oDesk = StzPayoutDeskQ(oTreasury, StzDikoPayoutPolicyQ(), cDir)

oSalary = StzPaymentOrderQ()
oSalary.WithTxId("SAL-2026-10-1")
oSalary.FromAlias(oHub.BusinessAlias())
oSalary.ToAlias(oHub.Alias("fatou"))
oSalary.WithAmount( StzAmountQ("350000", "XOF") )
oSalary.WithoutConfirmation()

try
	oTreasury.Pay(oSalary)                           # no plan: the port refuses before the hub hears of it
catch
	? "refused"                                      #--> refused
done

oPlan = StzPayoutPlanQ()
oPlan.WithId("SAL-2026-10")
oPlan.ProposedBy("treasury-agent")
oPlan.Paying(oSalary)
oPlan.Visa("comptable", "A. Issoufou")
oPlan.Visa("DAF", "M. Garba")
oPlan.Visa("DG", "H. Maiga")

nBench = StzOpenAgentWorkbench()
oDesk.Rehearse(oPlan, nBench)                        # into the twin of the disk: nothing real moves
oReport = oDesk.Judge(nBench, "SAL-2026-10")
? oReport.IsSound()                                  #--> 0
aErr = oReport.Errors()
? aErr[1][:rule]                                     #--> payout-over-100000-needs-4-visas

oPlan.Visa("CA", "S. Abdou")
oDesk.Rehearse(oPlan, nBench)
oReport = oDesk.Judge(nBench, "SAL-2026-10")
? oReport.IsSound()                                  #--> 1

aLlm = oDesk.Commit(nBench, "SAL-2026-10", LLMActor("assistant"))
? aLlm[:reason]                                      #--> actor

aOk = oDesk.Commit(nBench, "SAL-2026-10", HumanActor("tresorier"))
? aOk[:committed]                                    #--> 1
aRes = aOk[:results]
? aRes[1][:statut]                                   #--> ENVOYE
? StzFileExists(cDir + "/SAL-2026-10.plan.json")     #--> 1
StzCloseAgentWorkbench(nBench)
StzDirDeleteAll(cDir)
```

---

## 8. Webhooks

The participant POSTs to the platform's `callbackUrl` an
`application/json` body of shape `{ "data": [ event, ... ], "meta": { "total": n } }`,
each event carrying `evCode`, `evDate`, `end2endId`, `montant` (required),
and `txId`, `instructionId`, `client`, `alias`, `motif`, `refDocType`,
`refDocNumero` when they apply. The header `X-Signature` carries the
**HMAC-SHA256 of the request body** under the webhook's `secret`, which the
hub returned once at `POST /webhooks` and renews at
`POST /webhooks/{id}/secrets` with a `dateExpiration`. The callback runs
under mTLS with a participant certificate from the BCEAO CA. The platform
answers 204 within 5 seconds, 401 when the signature is wrong, 500 on its
own failure.

The twelve event codes the reference describes:

| family | codes |
|---|---|
| payment orders | `PAIEMENT_RECU`, `PAIEMENT_ENVOYE`, `PAIEMENT_REJETE` |
| requests to pay | `RTP_RECU`, `RTP_REJETE`, `RTP_REPONSE_REJETE` |
| returns and cancellations | `ANNULATION_DEMANDE`, `ANNULATION_REPONSE_REJETE`, `RETOUR_ENVOYE`, `RETOUR_REJETE`, `RETOUR_RECU`, `ANNULATION_REJETE` |

The reference disagrees with itself: the prose lists twelve, the enum
`WebhooksEvents.yml` (what a webhook can SUBSCRIBE to) lists ten, without
`RTP_REPONSE_REJETE` and `ANNULATION_REPONSE_REJETE`. The port accepts all
twelve on receipt and offers the ten on registration (section 11).

**Verified before believed.** `ReceiveWebhook(cBody, cSignature)` checks the HMAC-SHA256 of the
body against the secret(s) the port was given (at `RegisterWebhook` and `RenewWebhookSecret`),
with a constant-time comparison; the unsigned, mis-signed, malformed or replayed event (same
`end2endId`, `evCode` and `evDate` already seen) is refused with 401, and only a verified one
reaches the platform's handler. The HMAC runs in the engine (`stz_crypto`), never in Ring.
The verifier is `stzRequestSigner.VerifyWebhook` (PY3): the body-only form `SignBody`/`VerifyBody`
beside the canonical-string form the grid already used, over every key the port holds (a hub that
renews a secret leaves both valid until the old one lapses). A refusal is ONE ledger line, not one
per key tried: `webhook.unsigned`, `webhook.signature.forged`, `webhook.replayed`,
`webhook.malformed`. The secret can come from the store through the governed door,
`UseWebhookSecretFrom(oStore, name, oActor)`, which only an effectful, non-sandboxed actor passes
and the store audits either way.

```ring
oPay.RegisterWebhook( StzWebhookQ().CallingBack("https://diko.example/pispi").OnEvents(["PAIEMENT_ENVOYE"]) )
# the hub returned the secret once; the port kept it to verify what the hub sends

oNext = StzPaymentOrderQ()
oNext.WithTxId("DIKO-2026-000418")
oNext.FromAlias(oHub.BusinessAlias())
oNext.ToAlias(oHub.Alias("fatou"))
oNext.WithAmount( StzAmountQ("5000", "XOF") )
oNext.WithoutConfirmation()
oPay.Pay(oNext)
oHub.AdvanceSeconds(25)                              # the payment turns final: the hub signs and queues its event

aEv = oPay.ReceiveWebhook(oHub.LastCallbackBody(), oHub.LastCallbackSignature())
? aEv[:accepted]                                     #--> 1
aEvents = aEv[:events]
? aEvents[1][:evCode]                                #--> PAIEMENT_ENVOYE

aBad = oPay.ReceiveWebhook(oHub.LastCallbackBody(), "deadbeef")
? aBad[:accepted]                                    #--> 0
? aBad[:status]                                      #--> 401
```

---

## 9. Secrets and certificates

Five descriptors in `stzSecretStore`, named `pispi-<participant>-<part>`, never a value in a
versioned file, a memo or a guard (a guard that needs one GENERATES it):

| descriptor | what it holds | expiry |
|---|---|---|
| `pispi-<participant>-client` | OAuth client id and client secret | the participant's; rotation is a store `Rotate()` |
| `pispi-<participant>-api-key` | the `x-api-key` value | the participant's |
| `pispi-<participant>-mtls-key` | the private key of the client certificate | with the certificate |
| `pispi-<participant>-mtls-cert` | the client certificate from the BCEAO CA, 365 days in the sandbox | its `notAfter` |
| `pispi-<participant>-webhook-secret` | the HMAC secret of one webhook | the `dateExpiration` the platform set at renewal |

`StzPispiRegisterDescriptors(oStore, "bia")` registers the five as NAMES with no value
(`stzPispiSecret`, a `stzToken` underneath, so it carries an expiry and the sealed store keeps it:
a descriptor comes back from a sealed file with its kind and its expiry). The value arrives from
an environment variable, a file or a vault. A part that is not one of the five is refused.

**Expiry is a detection the security ledger raises, not a check the port runs at call time.**
`stzSecretExpiryWatch` (a periodic `Name_()` and `Cycle()`, hostable on any `stzAgentHost`) reads
the store and writes `secret.expiring` (inside the warning window, 30 days by default, the
portal's own advice) and `secret.expired` into the ledger **once per change of state**: a second
cycle announces nothing twice, and a renewed secret is forgotten so its next lapse is announced
afresh. `StzPaymentsDetectionSet()` raises them in the house shape, with the secret named, so they
join `stzRuleReport`, the one CI gate. A watch holds the store as it was handed over (Ring copies
an object on assignment), so a host hands it the current store each cycle with `Watch(oStore)`.

The OAuth token itself is not a secret descriptor: it is a bearer the live adapter obtains at
`POST /oauth/token` (`grant_type=client_credentials`, `scope` a space-separated list) with
`expires_in` 3600, caches in memory, and refreshes before expiry. It is **certificate-bound**: a
token taken under one mTLS certificate is refused with another.

---

## 9b. The live adapter, and the three stages

`stzPispiHttpAdapter` is the other backend of the port: the same `Request(method, path, query, body)` the
twin answers in-process, over the wire, to ANY participant. The base URL is configuration, the contract is
the BCEAO's, and nothing in it names a bank; it promises no homologation (ruling 13).

For every call it does, in this order: an **OAuth 2.0 client-credentials** token (asked for with the scopes it
was configured with, prefixed `piz/` in the BCEAO's sandbox, cached for the process, refreshed a minute early,
dropped and retried ONCE on a 401, because a revoked token and a stale one look the same); the **API key** in
`x-api-key`; **mutual TLS** when the participant requires it (the certificate and key are PEM files the engine
reads, named by a file-sourced secret descriptor so the private key never enters Ring, through
`stzReactor.TlsRequest`); JSON written by a **schema-aware encoder** (arrays and booleans are the contract's);
the query as `[ "montant[gte]", "4000" ]` pairs, percent-encoded where the wire needs it and not on the
reference's brackets; and an RFC 7807 problem comes back as the same `[ status, problem ]` the twin gives, so
the port raises the same `stzPaymentsProblem`.

**A transport failure is not a payment problem.** When a request was sent and its response was lost, the
platform cannot know whether money moved. The adapter RAISES a transport error, and the port journals the
`txId` (and `instructionId`) so the next attempt READS the payment from the hub first; a 404 means the first
attempt never arrived, and only then is it sent for real.

`stzPiSpiHttpFront` is the twin served over HTTP behind `stzAppServer`, with what a participant puts in
front of the contract: a token endpoint, the API key, the scope each operation needs, and (in a second
process) mutual TLS. Its `/_twin/...` control surface, off unless `EnableControl()` is called, is for a test to
drive the twin behind the wire.

```ring live
oAd = StzPispiHttpAdapterQ()
oAd.WithParticipant("bia")
oAd.WithBaseUrl("https://<the participant's base URL, version included>")
oAd.WithSecretsFrom(oStore, oActor)        # client and API key, through the governed door
oAd.WithCertificateFrom(oStore)            # production: descriptors that point at the PEM files
oAd.AsLive()                               # or AsConformance() for the BCEAO's sandbox
oPay = StzPaymentsPortQ(oAd)               # the port cannot tell it from the twin
```

| stage | what | status |
|---|---|---|
| (a) | the twin served over HTTP, plain and mutual TLS, in real server processes: tokens, scopes, all verbs, paging and filters, the twelve events verified by the port, a lost response, the registry's verdicts | **run**: `payments_live_adapter_narrated.ring` |
| (b) | the BCEAO's sandbox, under DIKO's account, the author as mandataire | **UNPERCEIVED**: `payments_conformance_run.ring` needs credentials only the author holds and a named person to watch a payment land in the sandbox dashboard |
| (c) | BIA in production | never from this plane, only inside DIKO's amendment |

---

## 10. The don'ts, in this plane's own words

- **No fee, ever.** Softanza takes nothing on any transaction, anywhere, in
  any form. No percentage, no per-call charge, no Softanza account in the
  money flow. The `montantFrais` the hub returns is the PARTICIPANT's fee
  under its own contract with the platform; the port shows it and never
  adds to it.
- **No holding of funds, no netting, no float.** Those are licensed roles
  (aggregator, wallet, payment institution). The port moves money between
  accounts that belong to the platform and its counterparties; it never
  owns an account.
- **No account, no form, no portal submission by this desk.** The author
  is the only one who opens an account, as DIKO's mandataire, on DIKO's
  behalf. A rung that needs credentials nobody has stops at the twin and
  reports *unperceived*.
- **No vendor shape.** Not Stripe, not Swan, not an aggregator. The EUR
  adapter for RestoLean is a later desk and Amor's decision; it will be a
  second adapter on this same port, with its own currency exponent.
- **No direct debit.** The hub has none. A platform that wants to be paid
  sends a request to pay and waits for the payer's acceptance.
- **No cancellation of a payment.** A payment is irrevocable. What exists
  is a cancellation REQUEST the payee may refuse, and a RETURN that is a
  new movement, each within 90 days.
- **No invented status word.** The hub's `statut` is the state.
- **No amount without a currency, no fractional franc, no cross-currency
  arithmetic.**
- **No credential in a file, no cryptography in Ring, no second HTTP
  client.** Client TLS exists in ONE place: `stzReactor.TlsRequest`, the mbedTLS
  client of `MTLS_PLAN.md` slice 3, which presents a PEM certificate. The live
  adapter uses it. (`stzHttpClient.SetClientCert` does NOT work on Windows: see
  section 11, item 12, which corrects what this line said until 2026-10-05.)
- **No participant list in code without a date on it.** `GET /participants`
  is the list; anything cached from it carries the day it was read.
- **No homologation promised that the BCEAO has not published.** The live
  adapter targets BIA Niger because BIA's API is homologated; a second
  participant is a configuration, not a claim.

---

## 11. Divergences found while reading, 2026-10-04

Reported here and in the memo of the day; each one either corrects the
launch prompt from the reference or records the reference disagreeing with
the portal's own guide pages. The reference (`openapi.yml` v1.5.0) wins.

1. **The payment path and payload.** The prompt (and the portal's security
   guide page) show `POST /v1/paiements` with
   `{"montant":5000,"devise":"XOF","destinataire":{"alias":"+22567123456"}}`.
   The reference has `POST /paiements-envoyes` under the server
   `.../piz/v1`, body `PaiementImmediatRequest`: `txId`, `payeurAlias`,
   `montant`, `confirmation` required; payee as `payeAlias` OR
   `payeIban + payeParticipant` OR `payeCompte + payeParticipant`; no
   `devise` field; `additionalProperties: false`, so a `devise` would be
   REFUSED with 400. The guide page is stale against the reference.
2. **The list path.** The reference's own introduction shows
   `GET /paiements-immediats?statut=IRREVOCABLE`; the paths section has
   `/paiements-envoyes` and `/paiements-recus` (split in v1.3.0). The
   introduction prose is stale against the paths.
3. **TxId replay.** The prompt's ruling 6 says a re-submission returns the
   same state. The hub rejects it as `DU03` (`REJETE`). Kept as a PORT law
   with a journal; the hub's behaviour is reproduced by the twin's hub face.
4. **Webhook events: twelve or ten.** Prose and guide list twelve; the
   subscription enum lists ten (no `RTP_REPONSE_REJETE`, no
   `ANNULATION_REPONSE_REJETE`).
5. **API key header.** Guide: `X-API-Key`; reference: `x-api-key`. HTTP
   header names are case-insensitive; the adapter sends the reference's
   spelling.
6. **Rate limits** (sandbox 100/min, 10,000/day; production 1,000/min,
   100,000/day) are on the portal's security guide, not in the OpenAPI
   document, which only defines the 429 problem.
7. **Base URLs.** Reference `servers:` names only the sandbox
   `https://sandbox.api.pi-bceao.com/piz/v1`; the OAuth `tokenUrl` is a
   placeholder `https://spi.example.com/oauth/token`; the guide uses
   `https://api.pispi.bceao.int/...`. In production the base URL is the
   participant's: the adapter takes it as configuration and promises none.
8. **Payment ceilings** by client type (section 4) are in the
   `PaiementEnvoye` tag prose, not in any schema; the twin carries them as
   dated data.
9. **Request-to-pay request bodies carry no currency and no `devise`
   either**; e-commerce requests must have `dateLimitePaiement` under 3
   minutes; on-site requests expire within 24 h; a request's default answer
   window is 90 days.
10. **Returns and cancellations are bounded at 90 days** from the payment
    date; `StatusOf` answers only within 90 days and only 20 s after the
    send.
11. **Repository side:** `StzCurrencyQ("XOF")` raises R3 (`stzcurrencyerror`
    not loaded on the error path; no ISO-code lookup exists), and the
    country table gives the CFA franc `Centime` / base 100. The amount
    type of PY1 does not read `stzCurrency` for the exponent. Both reported
    to the i18n owner through Central; not fixed from this plane.
12. **CORRECTED 2026-10-05, BY MEASUREMENT: `stzHttpClient.SetClientCert` does not present a client
    certificate on this Windows build.** This item said "mTLS exists end to end through `SetClientCert`",
    read from the code (`sslcert` reaches `CURLOPT_SSLCERT`) and never run. Run against the cluster
    plane's own mutual-TLS worker, `stzHttpClient` with the certificate answers code -1 with no body, and
    `stzReactor.TlsGet` with the same certificate is served. `MTLS_PLAN.md` slice 3 says why: the vendored
    curl uses Schannel, which wants a Windows certificate-store reference and not a PEM. The client that
    works is `stzReactor.TlsRequest`; the live adapter uses it, and no HTTP client was built. Its limits,
    which the adapter handles: one request per connection, a response framed by Content-Length or read
    until the peer closes (2 s idle), a 4 MB cap (a chunked body arrives with its markers and the adapter
    decodes it). The mbedTLS client also verifies a real public server against the operating system's roots,
    so the BCEAO sandbox, which has mTLS off, needs no certificate and no CA file. Reported to Central
    before the adapter was written, as the launch prompt required; a premise that was only read is now run.
13. **Bulk prose names a path that does not exist.** `POST /paiements-groupes` says to read the
    items at `GET /paiements?instructionId={id}`; the paths section has no `/paiements` list, only
    `/paiements-envoyes` and `/paiements-recus`. The twin filters `/paiements-envoyes` by
    `instructionId`.
14. **One field, two names.** A bulk item identifies a non-bank payee by `payeOther`; a single
    payment calls the same thing `payeCompte`. The port's builder says `ToAccount` and writes the
    right name for each.
15. **A ceiling breach is two different answers.** The reference's own example for
    `POST /paiements-envoyes` is a 403 problem ("Plafond de paiement depasse"), while `AM02` exists
    as a rejection reason. The twin answers 403 for a single payment and `AM02` for a bulk item,
    where a 403 would reject the whole batch.
16. **Booleans in Ring lists are 1 and 0.** Ring has no boolean type; `confirmation`, `decision`
    and `programme` travel as 1 and 0 and the HTTP boundary (PY5) maps them to true and false.
17. **The security event catalog is closed, and PY3 added to it.** `stzSecurityEvent` raises on a kind
    it does not know (`SOFTANZA_INCIDENT_ANALYSIS.md` 6.1). Six kinds were added, additively:
    `webhook.unsigned`, `webhook.signature.forged`, `webhook.replayed`, `webhook.malformed`,
    `secret.expiring`, `secret.expired`; and two invariants to `StzSecurityInvariantNames()`. The
    guard that pins the catalog asserts "at least 25 kinds", and stood. Reported to Central because
    the catalog is the security plane's, not this one's.
18. **A retry that reformats is not a replay of the BODY and is one of the EVENT.** A hub that
    re-signs the same event in a re-serialised envelope defeats a body-level replay cache, so the
    port also remembers events (`end2endId`, `evCode`, `evDate`).
19. **There is no `commit_payout` capability to grant.** The actor lattice is closed (effectful, sensing,
    compute, inference) and the launch prompt's sketch assumed otherwise. A committing actor is the one
    every commit in the library already means: effectful and not sandboxed.
20. **A commit crosses everything its workbench rehearsed**, so the desk takes one plan per workbench.
21. **The security event catalog gained three kinds** (`payout.committed`, `payout.refused`,
    `payout.unplanned`), additively, with `StzSecurityInvariantNames()` gaining
    `ungoverned-payouts-in-production`. Reported to the security desk with the PY3 kinds.
22. **The engine's HTTP client ejects a host that refuses a few connections** ("host ejected by outlier
    detector", code -1), so polling a server that is still starting makes it unreachable for the rest of
    the run. A guard waits for the server's own announcement (a log line) and never polls it over HTTP.
    This applies to the plain-HTTP path of the adapter (the twin in development); the production path is
    https through `TlsRequest`, which has no such ejector.
23. **The certificate-bound token is not modelled by the HTTP front.** The real hub refuses a token taken
    under one mTLS certificate when it is used under another. The engine does not expose the peer
    certificate to a handler, so the front cannot see which certificate a call came on. The front says so.
24. **`ListToJson` cannot write the contract's bodies**: `[]` becomes `{}`, and a one-pair array becomes an
    object. The adapter writes its JSON with a small schema-aware encoder, and reads with `StzJsonToList`,
    which maps `true`/`false` to 1/0, the convention the whole port already uses.

---

## 12. The rungs, and the guard of each

| rung | delivers | guard that fails before and passes after |
|---|---|---|
| PY0 | this charter | -- (examples run at PY2) |
| PY1 | `StzAmountQ(value, currency)` with the ISO 4217 exponent; `numeric_regime_narrated` (27) unchanged | `base/test/number/money_currency_narrated.ring` |
| PY2 | `stzPaymentsPort` on the PI-SPI verbs; `stzPiSpiSandbox` the twin; card verbs in `stzCardPaymentsAdapter`; `payments_port_narrated` (49) unchanged | `base/test/system/pispi_twin_narrated.ring` |
| PY3 | `:conformance` posture, the two invariants, the webhook verifier, five secret descriptors, expiry as a detection | `service_registry_narrated` extended; `payments_webhooks_narrated.ring`; `payments_secrets_narrated.ring` |
| PY4 | payout plan, four-visa rule, payout journal, `payout-without-plan` refused by the port | `payments_governance_narrated.ring` |
| PY5 | the live adapter, generic over the participant: (a) against the twin over HTTP behind `stzAppServer`, plain and mutual TLS; (b) conformance under DIKO's sandbox account, *unperceived* until a named person sees a payment land; (c) BIA in production only inside DIKO's amendment | `payments_live_adapter_narrated.ring` (a); `payments_conformance_run.ring` (b, UNPERCEIVED without credentials) |
| PY6 | the chapter: a dynamic QR, a customer pays, the webhook lands and is verified, a supplier is paid under four visas, and the registry refuses it all in production while the twin is bound | `doc/narrations/stz-getting-paid-and-paying-narration.md`, run by `test/system/payments_chapter.py` (14 blocks, 30 values). The dynamic QR is the request to pay of category 500; the EMV picture of it is the BCEAO SDK's and is not built here |

Baseline measured 2026-10-04 on the worktree at 010743cce, each guard run
from inside its topic directory: `payments_port_narrated` 49/49,
`service_registry_narrated` 51/51, `service_delivery_narrated` 53/53,
`numeric_regime_narrated` 27/27, `request_signing_narrated` 29/29.

The perception gate applies to money as it applied to sound: a payment
nobody has made is a STATE, not a failure. Until a named person has watched
a payment land in the BCEAO sandbox dashboard, every rung reports
*unperceived*, and says so in those words.
