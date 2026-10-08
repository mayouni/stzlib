#================================================================#
#  STZPAYMENTSPORT -- the payments port, shaped on the PI-SPI (PY2)  #
#================================================================#

/*--- A payments port is the object a platform talks to when money must move or be asked for.

It speaks the verbs of the BCEAO's API Business -- resolve an alias, pay, request to pay,
answer a request, return funds, request a cancellation, pay in bulk, read a status, receive a
webhook -- and it speaks them to a BACKEND: any object with

    Request(cMethod, cPath, aQuery, aBody)  ->  [ nHttpStatus, aBody ]

The Softanza twin (stzPiSpiSandbox) is one such backend, in-process. The live adapter (PY5) is
another, over HTTP. The port cannot tell them apart, which is the point: the code a platform
tests against the twin is byte-identical to the code that talks to a participant.

    oHub = StzPiSpiSandboxQ()
    oPay = StzPaymentsPortQ(oHub)
    aR = oPay.Pay( StzPaymentOrderQ().WithTxId("T-1").From(oHub.BusinessAlias()).To(oHub.Alias("fatou"))
                      .WithAmount(StzAmountQ("150000", "XOF")).WithoutConfirmation() )
    aR[:statut]      #--> "ENVOYE"   (the hub's own word; never "pending", never "success")

WHAT THE PORT ADDS to the contract, and nothing else:

  * TXID IS THE PLATFORM'S IDEMPOTENCY KEY. The hub does not return the first state when a txId
    comes back, it REJECTS the replay with DU03. A platform that retries after a timeout must
    not reach the hub twice, so the port keeps a journal keyed by txId: a re-submission answers
    the CURRENT state of the original and sends nothing. aR[:replayed] says which it was.
  * MONEY OUT IS A PLAN A HUMAN COMMITS. Pay, PayInBulk, ReturnFunds and the ACCEPTING answers to a
    request or a cancellation (each of which moves money out) refuse, before any request exists,
    unless a committed plan authorised that exact payout for that exact amount
    (payout-without-plan, payout-amount-differs). The port knows no policy: how many people must
    approve what is the plan's business (stzPayouts.ring), and a platform that wants another rule
    changes the policy, never the port. Asking for money, declining to pay, and moving money
    between the platform's own accounts are not money out and need no plan.
  * AMOUNTS CARRY A CURRENCY. An order is built with StzAmountQ, and the hub speaks XOF only, so
    another currency is refused before a request exists.
  * AN ERROR IS A PROBLEM. A status of 400 or more raises, and StzLastPaymentsProblem() answers
    the RFC 7807 fields the hub returned: status, title, detail, invalid-params.
  * A WEBHOOK IS VERIFIED BEFORE IT IS BELIEVED. ReceiveWebhook hands the body and X-Signature to
    a stzRequestSigner (the HMAC runs in the engine, the comparison is constant-time), refuses the
    unsigned, the mis-signed, the replayed and the malformed, writes each refusal into the security
    ledger, and answers the HTTP status the callback owes the participant (204 or 401). The
    secrets it verifies with come from RegisterWebhook / RenewWebhookSecret, or from the secret
    store through the governed door (UseWebhookSecretFrom).

Boolean fields travel as 1 and 0 inside Ring lists (confirmation, decision, programme); the HTTP
boundary of the live adapter turns them into true and false.

STATE IS SHARED, because Ring copies a registry's binding on every fetch: the journal, the
signer (and so the secrets and its replay cache) and the seen events live in global tables keyed
by the port's id, and the signer is always called THROUGH the table so there is only one.

The CARD verbs (Authorize, Capture, Refund) are one ADAPTER, in stzCardPaymentsAdapter.ring. They
are the shape of a card gateway, not of money in the UEMOA.

The charter is SOFTANZA_PAYMENTS_PORT.md, next to this file.
*/

$nPayPortSeq = 0
$aPayJournal = []
$aPaySigners = []
$aPaySeen = []
$aPayRefused = []
$aPayEvents = []
$aPayLastProblem = []
$aPayGov = []          # [ portId, 1 when told to skip the plan ]
$aPayAuth = []         # [ portId, kind, key, amount, planId, used ]

$cPayReasons = "|DU03=the txId is not unique|BE23=the alias, IBAN or account of the payee is invalid" +
	"|AC01=no such account at the destination participant|AB05=the destination participant did not answer the identity check in time" +
	"|AB03=settlement timed out|AB04=settlement failed fatally|AB08=the payee's participant is offline|AB09=error at the payee's participant" +
	"|AC03=invalid payee account|AC04=closed account|AC06=blocked account|AC07=closed payee account" +
	"|AG01=transaction forbidden on this account type|AG07=insufficient funds on the debited account" +
	"|AG08=access rights do not allow this|AG10=the paying participant is suspended|AG11=the payee's participant is suspended" +
	"|AM02=amount above the authorised maximum|AM04=insufficient guarantee balance|AM09=wrong amount|AM21=amount above the agreed limit" +
	"|AEXR=the request to pay already expired|ALAC=the request to pay was already accepted|ARFR=the request to pay was already refused" +
	"|ARJR=the request to pay was already rejected|APAR=the request to pay was already paid|ARDT=already returned" +
	"|BE01=end customer inconsistent with the account|BE05=the initiating party is not recognised|FF10=internal error at the participant" +
	"|FR01=refused for suspected fraud|IRNR=the initial request to pay was never received|RR04=regulatory reason|RR07=invalid remittance information" +
	"|CUST=the payee's decision|DUPL=paid twice|SVNR=service not rendered|FRAD=fraudulent origin|MD06=refund requested by the end customer|"

func StzPaymentsPortQ(poBackend)
	return new stzPaymentsPort(poBackend)

func StzPaymentOrderQ()
	return new stzPaymentOrder()

func StzPaymentRequestQ()
	return new stzPaymentRequest()

func StzPaymentBatchQ()
	return new stzPaymentBatch()

func StzWebhookQ()
	return new stzWebhook()

# the HMAC-SHA256 of a webhook body, in hex: the engine's, never Ring's. The twin SIGNS with it
# and the port VERIFIES with it, so there is one definition of what "signed" means.
func StzWebhookSignature(pcBody, pcSecret)
	_oC_ = new stzStringCrypto("" + pcBody)
	return _oC_.HmacSha256("" + pcSecret)

# a status that will not change again
func StzPaymentsIsFinal(pcStatut)
	return pcStatut = "IRREVOCABLE" or pcStatut = "REJETE" or pcStatut = "ANNULE" or pcStatut = "ACCEPTE"

func StzLastPaymentsProblem()
	return new stzPaymentsProblem($aPayLastProblem)

# The reason codes a platform meets first, in the reference's own meaning. The full lists are the
# enums of PaiementStatutRaison, RetourStatutRaison, PaiementAnnulationStatutRaison and
# DemandePaiementStatutRaison in API Business v1.5.0 (read 2026-10-04).
func StzPaymentsReasonMeaning(pcCode)
	_k_ = "|" + upper("" + pcCode) + "="
	_p_ = StzFindFirst(_k_, $cPayReasons)
	if _p_ = 0
		return ""
	ok
	_s_ = _p_ + len(_k_)
	_e_ = _s_
	_n_ = len($cPayReasons)
	while _e_ <= _n_ and $cPayReasons[_e_] != "|"
		_e_++
	end
	return StzMid($cPayReasons, _s_, _e_ - _s_)

func _StzPayRequireAmount(poAmount)
	if NOT isObject(poAmount) or NOT isMethod(poAmount, "MinorUnits")
		StzRaise("An amount is built with StzAmountQ('5000', 'XOF'): a bare number carries no currency.")
	ok
	if poAmount.Currency() != "XOF"
		StzRaise("The hub speaks XOF only: " + poAmount.Currency() + " is refused before a request exists.")
	ok

#---------------------------------------------------------------------#
#  the problem the hub returned                                        #
#---------------------------------------------------------------------#

# Holds the refusal a hub returned, as the RFC 7807 fields: a status, a title, a detail and the fields found wrong.
#
# When a hub answers 400 or more, stzPaymentsPort raises an error and keeps the problem;
# StzLastPaymentsProblem hands it over. Read Status to decide what to do, Detail to log what the hub
# said, and InvalidParams to see which field of the message was refused. A payment that the payee's
# bank refuses is not a problem: it is a payment whose statut became REJETE.
#
#   receiver   oHub = StzPiSpiSandboxQ(); oPay = StzPaymentsPortQ(oHub);
#              oPay.AllowUngovernedPayouts(); try oPay.Pay(StzPaymentOrderQ().WithTxId("BIG-
#              1").FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias("fatou")).WithAmount(StzAmount
#              Q("20000000", "XOF")).WithoutConfirmation()) catch o1 = StzLastPaymentsProblem() done
#   example    ? o1.Status()
#              #--> 403
#              ? o1.Detail()
#              #--> Plafond de paiement depasse
#              ? o1.InvalidParams()[1][1][2]
#              #--> montant
#   see        stzPaymentsPort, StzLastPaymentsProblem
class stzPaymentsProblem from stzObject

	@aBody = []

	# Builds a problem from the body the hub returned with a refusal, a list of pairs in the RFC 7807 shape.
	#
	#   paBody     the problem as a list of [ key, value ] pairs
	#   returns    nothing; the object is built
	#   note       an application rarely builds one: StzLastPaymentsProblem hands over the one the
	#              port just recorded
	#   see        StzLastPaymentsProblem
	def init(paBody)
		if isList(paBody)
			@aBody = paBody
		ok

	# Returns the HTTP status the hub gave the refusal, such as 403 or 404.
	#
	#   returns    a number; 0 when the problem is empty
	#   see        Title, Detail
	def Status()
		return _StzPiGet(@aBody, "status", 0)

	# Returns the short, general name of the refusal, such as Forbidden.
	#
	#   returns    a text; an empty text when the hub gave none
	#   see        Detail, Status
	def Title()
		return _StzPiGet(@aBody, "title", "")

	# Returns the hub's sentence about this refusal, the one to log or show a developer, such as Plafond de paiement depasse.
	#
	#   returns    a text; an empty text when the hub gave none
	#   note       the twin writes it in French
	#   see        Title, InvalidParams
	def Detail()
		return _StzPiGet(@aBody, "detail", "")

	# Returns the problem's type address, which is about:blank when the hub gave none.
	#
	#   returns    a text
	#   see        Title
	def Type()
		return _StzPiGet(@aBody, "type", "about:blank")

	# Returns the fields the hub found wrong, each with the reason, for a refusal of a malformed message.
	#
	#   returns    a list of records [ name, reason ]; an empty list when the hub named none
	#   see        Detail, Content
	#@ aka  [ [ name, reason ] ... ] as the hub gave them, reshaped to a list of two-key records
	def InvalidParams()
		return _StzPiGet(@aBody, "invalid-params", [])

	# Returns the whole problem as a list of pairs, exactly as the hub returned it.
	#
	#   returns    a list of [ key, value ] pairs; an empty list when the problem is empty
	#   see        Status, InvalidParams
	def Content()
		return @aBody

#---------------------------------------------------------------------#
#  builders: what a platform says, as the wire says it                 #
#---------------------------------------------------------------------#

# Describes one payment to send, who is paid, how much and under which id, in the words the hub expects.
#
# Build it with its chained setters, then hand it to Pay of stzPaymentsPort. The txId is yours and
# unique, and a retry reuses it. The amount comes from StzAmountQ and only XOF is accepted. The
# payee is named by alias, by IBAN or by account, and one of WithConfirmation or WithoutConfirmation
# must be chosen. Building an order sends nothing: AsBody shows what would be sent.
#
#   receiver   o1 = StzPaymentOrderQ().WithTxId("APP-1").FromAlias("11111111-1111-4111-8111-
#              111111111111").ToAlias("22222222-2222-4222-8222-
#              222222222222").WithAmount(StzAmountQ("25000", "XOF")).WithoutConfirmation()
#   example    ? o1.TxId()
#              #--> APP-1
#              ? o1.Amount()
#              #--> 25000
#              ? @@(o1.AsBody()[3])
#              #--> [ "montant", 25000 ]
#   see        stzPaymentsPort, stzPaymentBatch, stzPaymentRequest, StzAmountQ
class stzPaymentOrder from stzObject

	@cTx = ""
	@cFrom = ""
	@cTo = ""
	@cIban = ""
	@cCompte = ""
	@cParticipant = ""
	@nMontant = 0
	@cMotif = ""
	@cDocNo = ""
	@cDocType = ""
	@nConfirm = -1

	# Builds an empty order, which is then told who pays whom, how much and under which id.
	#
	#   returns    nothing; the object is built
	#   see        WithTxId, AsBody
	def init()
	# Sets the platform's own unique identifier of the payment, the key that makes a retry safe.
	#
	#   pcTx       the platform's id, unique, kept to at most 35 characters by the hub
	#   returns    the order itself, so calls chain
	#   note       a retry reuses this id: a new id is a new payment
	#   see        TxId, FromAlias, stzPaymentsPort
	#@ aka  nothing to prepare: a builder starts empty and says what it needs
	def WithTxId(pcTx)
		@cTx = "" + pcTx
		return This

	# Sets the platform's own alias, the account that is debited.
	#
	#   pcAlias    the platform's PI-SPI alias, a UUID
	#   returns    the order itself, so calls chain
	#   note       stzPaymentsPort Pay refuses an order without it
	#   see        ToAlias, WithTxId
	#@ aka  the platform's alias, the account that is debited
	def FromAlias(pcAlias)
		@cFrom = "" + pcAlias
		return This

	# Sets the payee by PI-SPI alias, the usual route to a customer.
	#
	#   pcAlias    the payee's PI-SPI alias, a UUID
	#   returns    the order itself, so calls chain
	#   note       if several routes are set the alias wins, then the IBAN, then the account
	#   see        ToIban, ToAccount, FromAlias
	def ToAlias(pcAlias)
		@cTo = "" + pcAlias
		return This

	# Sets the payee by IBAN and by the participant that holds the account.
	#
	#   pcIban          the payee's IBAN
	#   pcParticipant   the code of the payee's participant, as Participants lists it
	#   returns         the order itself, so calls chain
	#   see             ToAlias, ToAccount, Participants
	def ToIban(pcIban, pcParticipant)
		@cIban = "" + pcIban
		@cParticipant = "" + pcParticipant
		return This

	# Sets the payee by account number and by the participant that holds the account.
	#
	#   pcCompte        the payee's account number
	#   pcParticipant   the code of the payee's participant, as Participants lists it
	#   returns         the order itself, so calls chain
	#   note            in a bulk item the account number travels as payeOther, the hub's other name
	#                   for it
	#   see             ToAlias, ToIban, AsItem
	def ToAccount(pcCompte, pcParticipant)
		@cCompte = "" + pcCompte
		@cParticipant = "" + pcParticipant
		return This

	# Sets the amount from an amount built with its currency, kept in whole francs.
	#
	#   poAmount   an amount built with StzAmountQ, in XOF
	#   returns    the order itself, so calls chain
	#   note       25000 francs is stored as 25000
	#   warning    raises an error for a bare number, which carries no currency, and for any
	#              currency but XOF, before a request exists
	#   see        Amount, StzAmountQ
	def WithAmount(poAmount)
		_StzPayRequireAmount(poAmount)
		@nMontant = poAmount.MinorUnits()
		return This

	# Sets the free text the payee sees on the payment, such as an invoice number.
	#
	#   pcMotif    the text shown to the payee, at most 140 characters
	#   returns    the order itself, so calls chain
	#   note       the hub shows it to the payee
	#   see        Documented
	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	# Attaches a reference document to the payment: its number and its type.
	#
	#   pcNumber   the document's number, such as an invoice number
	#   pcType     the document's type code
	#   returns    the order itself, so calls chain
	#   see        Motive
	def Documented(pcNumber, pcType)
		@cDocNo = "" + pcNumber
		@cDocType = "" + pcType
		return This

	# Makes the hub hold the payment until the platform confirms it.
	#
	#   returns    the order itself, so calls chain
	#   note       the payment then starts as INITIE, not ENVOYE; either this or WithoutConfirmation
	#              must be set
	#   see        WithoutConfirmation, ConfirmPayment
	def WithConfirmation()
		@nConfirm = 1
		return This

	# Makes the hub send the payment at once, with no confirmation step.
	#
	#   returns    the order itself, so calls chain
	#   note       either this or WithConfirmation must be set
	#   see        WithConfirmation
	def WithoutConfirmation()
		@nConfirm = 0
		return This

	# Returns the txId set on the order.
	#
	#   returns    a text; an empty text when none was set
	#   see        WithTxId
	def TxId()
		return @cTx

	# Returns the amount set on the order, in whole francs.
	#
	#   returns    a number; 0 when no amount was set
	#   see        WithAmount
	def Amount()
		return @nMontant

	# the payee, as the hub names the three routes
	def _Payee()
		if @cTo != ""
			return [ [ "payeAlias", @cTo ] ]
		ok
		if @cIban != ""
			return [ [ "payeIban", @cIban ], [ "payeParticipant", @cParticipant ] ]
		ok
		if @cCompte != ""
			return [ [ "payeCompte", @cCompte ], [ "payeParticipant", @cParticipant ] ]
		ok
		return []

	def _Common()
		_a_ = []
		if @cMotif != ""
			_a_ + [ "motif", @cMotif ]
		ok
		if @cDocNo != ""
			_a_ + [ "refDocNumero", @cDocNo ]
			_a_ + [ "refDocType", @cDocType ]
		ok
		return _a_

	# Returns the order as the message body the hub expects, a list of pairs, once every required part is set.
	#
	#   returns    a list of [ key, value ] pairs: txId, payeurAlias, montant, confirmation, the
	#              payee route, then motif and the document when set
	#   note       stzPaymentsPort Pay calls it for you
	#   warning    raises an error naming what is missing: the txId, the payer's alias, a payee, an
	#              amount, or the confirmation choice
	#   see        AsItem, stzPaymentsPort
	def AsBody()
		if @cTx = ""
			StzRaise("An order needs a txId: the platform's own unique identifier.")
		ok
		if @cFrom = ""
			StzRaise("An order needs the platform's alias (FromAlias): the account that is debited.")
		ok
		_aP_ = This._Payee()
		if ring_len(_aP_) = 0
			StzRaise("An order needs a payee: ToAlias(alias), ToIban(iban, participant) or ToAccount(compte, participant).")
		ok
		if @nMontant <= 0
			StzRaise("An order needs an amount: WithAmount(StzAmountQ('5000', 'XOF')).")
		ok
		if @nConfirm < 0
			StzRaise("An order says whether the hub should ask for confirmation: WithConfirmation() or WithoutConfirmation().")
		ok
		_a_ = [ [ "txId", @cTx ], [ "payeurAlias", @cFrom ], [ "montant", @nMontant ], [ "confirmation", @nConfirm ] ]
		for _i_ = 1 to ring_len(_aP_)
			_a_ + _aP_[_i_]
		next
		_aC_ = This._Common()
		for _i_ = 1 to ring_len(_aC_)
			_a_ + _aC_[_i_]
		next
		return _a_

	# Returns the order as one item of a bulk, which has no payer and no confirmation because the batch carries them.
	#
	#   returns    a list of [ key, value ] pairs: txId, montant, the payee route, then motif and
	#              the document when set
	#   note       stzPaymentBatch Add calls it for you
	#   warning    raises an error when the txId, the amount or the payee is missing
	#   see        AsBody, Add
	#@ aka  an item of a bulk: no payer, no confirmation, those belong to the batch
	def AsItem()
		if @cTx = "" or @nMontant <= 0
			StzRaise("A bulk item needs a txId and an amount.")
		ok
		_a_ = [ [ "txId", @cTx ], [ "montant", @nMontant ] ]
		_aP_ = This._Payee()
		if ring_len(_aP_) = 0
			StzRaise("A bulk item needs a payee.")
		ok
		for _i_ = 1 to ring_len(_aP_)
			if StzLower(_aP_[_i_][1]) = "payecompte"
				_a_ + [ "payeOther", _aP_[_i_][2] ]
			else
				_a_ + _aP_[_i_]
			ok
		next
		_aC_ = This._Common()
		for _i_ = 1 to ring_len(_aC_)
			_a_ + _aC_[_i_]
		next
		return _a_

# Describes one request to pay, who is asked, how much and for what, in the words the hub expects.
#
# Build it with its chained setters, then hand it to RequestPayment of stzPaymentsPort. The txId is
# yours and unique, and a retry reuses it. The amount comes from StzAmountQ and only XOF is
# accepted. The category says the kind of request: 500 on the spot, 521 e-commerce, 401 invoice, and
# the twin wants a PayableBy date for the last two. One of WithConfirmation or WithoutConfirmation
# must be chosen. Asking for money moves none, and building a request sends nothing.
#
#   receiver   o1 = StzPaymentRequestQ().WithTxId("APP-RTP-1").FromAlias("11111111-1111-4111-8111-
#              111111111111").ToAlias("22222222-2222-4222-8222-
#              222222222222").WithAmount(StzAmountQ("350000",
#              "XOF")).InCategory("401").PayableBy("2026-10-31").WithoutConfirmation()
#   example    ? o1.TxId()
#              #--> APP-RTP-1
#              ? @@(o1.AsBody()[6])
#              #--> [ "categorie", "401" ]
#              ? @@(o1.AsBody()[7])
#              #--> [ "dateLimitePaiement", "2026-10-31" ]
#   see        stzPaymentsPort, stzPaymentBatch, stzPaymentOrder, StzAmountQ
class stzPaymentRequest from stzObject

	@cTx = ""
	@cPayer = ""
	@cPayee = ""
	@nMontant = 0
	@cCategory = ""
	@cPayBy = ""
	@cAnswerBy = ""
	@cMotif = ""
	@cDocNo = ""
	@cDocType = ""
	@nConfirm = -1

	# Builds an empty request to pay, which is then told who is asked, how much and for what.
	#
	#   returns    nothing; the object is built
	#   see        WithTxId, AsBody
	def init()
	# Sets the platform's own unique identifier of the request, the key that makes a retry safe.
	#
	#   pcTx       the platform's id, unique
	#   returns    the request itself, so calls chain
	#   note       a retry reuses this id: a new id is a new request
	#   see        TxId, stzPaymentsPort
	#@ aka  nothing to prepare: a builder starts empty and says what it needs
	def WithTxId(pcTx)
		@cTx = "" + pcTx
		return This

	# Sets the alias of the payer who is asked to pay.
	#
	#   pcAlias    the payer's PI-SPI alias, a UUID
	#   returns    the request itself, so calls chain
	#   note       in a bulk of requests, each item names its own payer this way
	#   see        ToAlias
	#@ aka  the payer we ask
	def FromAlias(pcAlias)
		@cPayer = "" + pcAlias
		return This

	# Sets the platform's own alias, where the money should land.
	#
	#   pcAlias    the platform's PI-SPI alias, a UUID
	#   returns    the request itself, so calls chain
	#   see        FromAlias
	#@ aka  where we want the money to land: the platform's alias
	def ToAlias(pcAlias)
		@cPayee = "" + pcAlias
		return This

	# Sets the amount asked, from an amount built with its currency, kept in whole francs.
	#
	#   poAmount   an amount built with StzAmountQ, in XOF
	#   returns    the request itself, so calls chain
	#   note       350000 francs is stored as 350000
	#   warning    raises an error for a bare number, which carries no currency, and for any
	#              currency but XOF, before a request exists
	#   see        StzAmountQ
	def WithAmount(poAmount)
		_StzPayRequireAmount(poAmount)
		@nMontant = poAmount.MinorUnits()
		return This

	# Sets the kind of request: 500 on the spot, 521 e-commerce, 401 invoice.
	#
	#   pcCategory   the category code as text: 500, 521 or 401
	#   returns      the request itself, so calls chain
	#   note         the twin refuses an invoice or e-commerce request that has no PayableBy date
	#   see          PayableBy, AnswerableBy
	#@ aka  500 on-site, 521 e-commerce, 401 invoice
	def InCategory(pcCategory)
		@cCategory = "" + pcCategory
		return This

	# Sets the last date on which the payer may pay the request.
	#
	#   pcDate     the date as text, such as 2026-10-31
	#   returns    the request itself, so calls chain
	#   note       required by the hub for an invoice or e-commerce request
	#   see        AnswerableBy, InCategory
	def PayableBy(pcDate)
		@cPayBy = "" + pcDate
		return This

	# Sets the last date on which the payer may accept or refuse the request.
	#
	#   pcDate     the date as text, such as 2026-10-20
	#   returns    the request itself, so calls chain
	#   see        PayableBy
	def AnswerableBy(pcDate)
		@cAnswerBy = "" + pcDate
		return This

	# Sets the free text the payer sees on the request, such as an invoice number.
	#
	#   pcMotif    the text shown to the payer
	#   returns    the request itself, so calls chain
	#   see        Documented
	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	# Attaches a reference document to the request: its number and its type.
	#
	#   pcNumber   the document's number, such as an invoice number
	#   pcType     the document's type code
	#   returns    the request itself, so calls chain
	#   see        Motive
	def Documented(pcNumber, pcType)
		@cDocNo = "" + pcNumber
		@cDocType = "" + pcType
		return This

	# Makes the hub hold the request until the platform confirms it.
	#
	#   returns    the request itself, so calls chain
	#   note       the request then starts as INITIE; either this or WithoutConfirmation must be set
	#   see        WithoutConfirmation, ConfirmRequest
	def WithConfirmation()
		@nConfirm = 1
		return This

	# Makes the hub send the request at once, with no confirmation step.
	#
	#   returns    the request itself, so calls chain
	#   note       either this or WithConfirmation must be set
	#   see        WithConfirmation
	def WithoutConfirmation()
		@nConfirm = 0
		return This

	# Returns the txId set on the request.
	#
	#   returns    a text; an empty text when none was set
	#   see        WithTxId
	def TxId()
		return @cTx

	def _Common()
		_a_ = []
		if @cMotif != ""
			_a_ + [ "motif", @cMotif ]
		ok
		if @cDocNo != ""
			_a_ + [ "refDocNumero", @cDocNo ]
			_a_ + [ "refDocType", @cDocType ]
		ok
		return _a_

	# Returns the request as the message body the hub expects, a list of pairs, once every required part is set.
	#
	#   returns    a list of [ key, value ] pairs: txId, payeurAlias, payeAlias, montant,
	#              confirmation, categorie, the dates and motif when set
	#   note       stzPaymentsPort RequestPayment calls it for you
	#   warning    raises an error when the txId, payer, payee, amount or category is missing, or
	#              when the confirmation choice is not made
	#   see        AsItem, stzPaymentsPort
	def AsBody()
		if @cTx = "" or @cPayer = "" or @cPayee = "" or @nMontant <= 0 or @cCategory = ""
			StzRaise("A request to pay needs a txId, a payer (FromAlias), a payee (ToAlias), an amount (WithAmount) and a category (InCategory).")
		ok
		if @nConfirm < 0
			StzRaise("A request says whether the hub should ask for confirmation: WithConfirmation() or WithoutConfirmation().")
		ok
		_a_ = [ [ "txId", @cTx ], [ "payeurAlias", @cPayer ], [ "payeAlias", @cPayee ], [ "montant", @nMontant ],
			[ "confirmation", @nConfirm ], [ "categorie", @cCategory ] ]
		if @cPayBy != ""
			_a_ + [ "dateLimitePaiement", @cPayBy ]
		ok
		if @cAnswerBy != ""
			_a_ + [ "dateLimiteReponse", @cAnswerBy ]
		ok
		_aC_ = This._Common()
		for _i_ = 1 to ring_len(_aC_)
			_a_ + _aC_[_i_]
		next
		return _a_

	# Returns the request as one item of a bulk of requests, which carries only its txId, payer and amount.
	#
	#   returns    a list of [ key, value ] pairs: txId, payeurAlias, montant, then motif and the
	#              document when set
	#   note       stzPaymentBatch Add calls it for you
	#   warning    raises an error when the txId, the payer or the amount is missing
	#   see        AsBody, Add
	def AsItem()
		if @cTx = "" or @cPayer = "" or @nMontant <= 0
			StzRaise("A bulk request item needs a txId, a payer (FromAlias) and an amount.")
		ok
		_a_ = [ [ "txId", @cTx ], [ "payeurAlias", @cPayer ], [ "montant", @nMontant ] ]
		_aC_ = This._Common()
		for _i_ = 1 to ring_len(_aC_)
			_a_ + _aC_[_i_]
		next
		return _a_

# Gathers many payment orders, or many requests to pay, under one instructionId so that they travel as a single bulk.
#
# Give it an instructionId, the platform's own alias (FromAlias for payments, ToAlias for requests)
# and its items with Add, then hand it to PayInBulk or RequestPaymentsInBulk of stzPaymentsPort.
# Each item keeps its own txId, and the platform's alias and the confirmation belong to the batch.
# TotalAmount is the sum that a payout plan has to authorise for a bulk payment. Building a batch
# sends nothing.
#
#   receiver   o1 = StzPaymentBatchQ().WithInstructionId("PAIE-2026-10").FromAlias("11111111-1111-
#              4111-8111-111111111111").WithoutConfirmation(); o1.Add(StzPaymentOrderQ().WithTxId("P
#              AIE-1").ToAlias("22222222-2222-4222-8222-222222222222").WithAmount(StzAmountQ("1000",
#              "XOF"))); o1.Add(StzPaymentOrderQ().WithTxId("PAIE-2").ToAlias("33333333-3333-4333-
#              8333-333333333333").WithAmount(StzAmountQ("2500", "XOF")))
#   example    ? o1.NumberOfItems()
#              #--> 2
#              ? o1.TotalAmount()
#              #--> 3500
#   see        stzPaymentsPort, stzPaymentOrder, stzPaymentRequest
class stzPaymentBatch from stzObject

	@cId = ""
	@cFrom = ""
	@cTo = ""
	@cMotif = ""
	@cCategory = "401"
	@nConfirm = 0
	@aItems = []

	# Builds an empty batch, to which orders or requests are added under one instructionId.
	#
	#   returns    nothing; the object is built
	#   see        WithInstructionId, Add
	def init()
	# Sets the one identifier of the whole batch, the key that makes a retry safe.
	#
	#   pcId       the platform's instructionId, unique for the batch
	#   returns    the batch itself, so calls chain
	#   note       each item still carries its own txId
	#   see        InstructionId, stzPaymentsPort
	#@ aka  nothing to prepare: a builder starts empty and says what it needs
	def WithInstructionId(pcId)
		@cId = "" + pcId
		return This

	# Sets the platform's alias that is debited, for a batch of payments.
	#
	#   pcAlias    the platform's PI-SPI alias, a UUID
	#   returns    the batch itself, so calls chain
	#   note       a batch of requests uses ToAlias instead
	#   see        ToAlias, AsBody
	#@ aka  for a bulk PAYMENT: the platform's alias that is debited
	def FromAlias(pcAlias)
		@cFrom = "" + pcAlias
		return This

	# Sets the platform's alias that is paid, for a batch of requests to pay.
	#
	#   pcAlias    the platform's PI-SPI alias, a UUID
	#   returns    the batch itself, so calls chain
	#   note       a batch of payments uses FromAlias instead
	#   see        FromAlias, AsRequestBody
	#@ aka  for a bulk REQUEST: the platform's alias that is paid
	def ToAlias(pcAlias)
		@cTo = "" + pcAlias
		return This

	# Sets the category of a batch of requests to pay; a batch starts at 401, an invoice.
	#
	#   pcCategory   the category code as text: 500, 521 or 401
	#   returns      the batch itself, so calls chain
	#   note         a batch of payments does not send it
	#   see          AsRequestBody
	def InCategory(pcCategory)
		@cCategory = "" + pcCategory
		return This

	# Sets the free text the other side sees on the whole batch.
	#
	#   pcMotif    the text shown with the batch
	#   returns    the batch itself, so calls chain
	#   see        AsBody
	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	# Makes the hub hold the batch until the platform confirms it.
	#
	#   returns    the batch itself, so calls chain
	#   note       the batch then starts as INITIE
	#   see        WithoutConfirmation, ConfirmBulk
	def WithConfirmation()
		@nConfirm = 1
		return This

	# Makes the hub send the batch at once, which is how a batch starts.
	#
	#   returns    the batch itself, so calls chain
	#   see        WithConfirmation
	def WithoutConfirmation()
		@nConfirm = 0
		return This

	# Adds one payment order or one request to pay to the batch, as the item the hub expects.
	#
	#   poItem     a stzPaymentOrder for a batch of payments, or a stzPaymentRequest for a batch of
	#              requests
	#   returns    the batch itself, so calls chain
	#   note       the item is copied in at once, so changing the order afterwards does not reach
	#              the batch
	#   warning    raises an error when the item lacks what an item needs: its txId, its amount, and
	#              its payee or payer
	#   see        NumberOfItems, TotalAmount
	def Add(poItem)
		@aItems + poItem.AsItem()
		return This

	# Returns the instructionId set on the batch.
	#
	#   returns    a text; an empty text when none was set
	#   see        WithInstructionId
	def InstructionId()
		return @cId

	# Returns how many items the batch holds.
	#
	#   returns    a number
	#   see        Add
	def NumberOfItems()
		return ring_len(@aItems)

	# Returns the sum of the items' amounts in whole francs, the figure a payout plan must authorise for the batch.
	#
	#   returns    a number
	#   see        Add, stzPaymentsPort
	#@ aka  the sum of the items, in francs: what a plan authorises for the instruction
	def TotalAmount()
		_n_ = 0
		for _i_ = 1 to ring_len(@aItems)
			_n_ = _n_ + _StzPiGet(@aItems[_i_], "montant", 0)
		next
		return _n_

	def _Head(pcPayerKey, pcPayer)
		if @cId = ""
			StzRaise("A batch needs an instructionId: one identifier for the whole batch.")
		ok
		if pcPayer = ""
			StzRaise("A batch needs its own alias (" + pcPayerKey + ").")
		ok
		if ring_len(@aItems) = 0
			StzRaise("A batch needs at least one item.")
		ok
		_a_ = [ [ "instructionId", @cId ], [ pcPayerKey, pcPayer ], [ "confirmation", @nConfirm ] ]
		if @cMotif != ""
			_a_ + [ "motif", @cMotif ]
		ok
		return _a_

	# Returns the batch as the message body for a bulk payment, a list of pairs, once it is complete.
	#
	#   returns    a list of [ key, value ] pairs: instructionId, payeurAlias, confirmation, motif
	#              when set, then transactions
	#   note       stzPaymentsPort PayInBulk calls it for you
	#   warning    raises an error when the instructionId, the payer's alias or the items are
	#              missing
	#   see        AsRequestBody, stzPaymentsPort
	def AsBody()
		_a_ = This._Head("payeurAlias", @cFrom)
		_a_ + [ "transactions", @aItems ]
		return _a_

	# Returns the batch as the message body for a bulk of requests to pay, a list of pairs, once it is complete.
	#
	#   returns    a list of [ key, value ] pairs: instructionId, payeAlias, confirmation, motif
	#              when set, categorie, then transactions
	#   note       stzPaymentsPort RequestPaymentsInBulk calls it for you
	#   warning    raises an error when the instructionId, the platform's alias (ToAlias) or the
	#              items are missing
	#   see        AsBody, stzPaymentsPort
	def AsRequestBody()
		_a_ = This._Head("payeAlias", @cTo)
		_a_ + [ "categorie", @cCategory ]
		_a_ + [ "transactions", @aItems ]
		return _a_

# Describes a webhook to register: the https address the hub calls back and the events it should call about.
#
# Build it with CallingBack and OnEvents, then hand it to RegisterWebhook of stzPaymentsPort, which
# keeps the secret the hub answers and verifies every call with it. The hub signs each call, and
# ReceiveWebhook refuses a call that is unsigned, mis-signed, replayed or malformed. Building a
# webhook sends nothing.
#
#   receiver   o1 = StzWebhookQ().CallingBack("https://app.example/pispi").OnEvents([
#              "PAIEMENT_RECU" ])
#   example    ? @@(o1.AsBody())
#              #--> [ [ "callbackUrl", "https://app.example/pispi" ], [ "events", [ "PAIEMENT_RECU" ] ] ]
#   see        stzPaymentsPort
class stzWebhook from stzObject

	@cUrl = ""
	@cAlias = ""
	@aEvents = []

	# Builds an empty webhook description, to be told where the hub should call back and for which events.
	#
	#   returns    nothing; the object is built
	#   see        CallingBack, OnEvents
	def init()
	# Sets the address the hub will call when an event happens.
	#
	#   pcUrl      the callback URL, which the twin requires to start with https://
	#   returns    the webhook itself, so calls chain
	#   note       the twin refuses another scheme with a 400 problem naming callbackUrl
	#   see        OnEvents, AsBody
	#@ aka  nothing to prepare: a builder starts empty and says what it needs
	def CallingBack(pcUrl)
		@cUrl = "" + pcUrl
		return This

	# Sets the events the hub should call back about.
	#
	#   paEvents   a list of event codes, such as [ "PAIEMENT_RECU" ]
	#   returns    the webhook itself, so calls chain
	#   note       the twin refuses an unknown event with a 400 problem naming events; with no
	#              events set, none is sent
	#   see        CallingBack, AsBody
	def OnEvents(paEvents)
		@aEvents = paEvents
		return This

	# Limits the webhook to one alias of the platform.
	#
	#   pcAlias    the platform's PI-SPI alias, a UUID
	#   returns    the webhook itself, so calls chain
	#   note       left unset, no alias is sent
	#   see        CallingBack
	def ForAlias(pcAlias)
		@cAlias = "" + pcAlias
		return This

	# Returns the webhook as the message body the hub expects, a list of pairs.
	#
	#   returns    a list of [ key, value ] pairs: callbackUrl, then alias and events when set
	#   note       it never raises, so an empty webhook gives an empty callbackUrl that the hub then
	#              refuses; stzPaymentsPort RegisterWebhook calls it for you
	#   see        stzPaymentsPort
	def AsBody()
		_a_ = [ [ "callbackUrl", @cUrl ] ]
		if @cAlias != ""
			_a_ + [ "alias", @cAlias ]
		ok
		if ring_len(@aEvents) > 0
			_a_ + [ "events", @aEvents ]
		ok
		return _a_

#---------------------------------------------------------------------#
#  the port                                                            #
#---------------------------------------------------------------------#

# Speaks the BCEAO's PI-SPI payment verbs to a hub: sends money, asks for it, verifies webhooks and raises refusals as problems.
#
# An application sends money with Pay, asks for it with RequestPayment, hears about payments with
# RegisterWebhook and ReceiveWebhook, and reads a refusal with StzLastPaymentsProblem. The port
# speaks the verbs of the BCEAO's API Business to any backend that has a Request method, so the code
# tested against the twin (StzPiSpiSandboxQ) is the code that talks to a participant. WHERE THIS
# STANDS: behind the twin every verb runs and is tested; behind the live adapter
# (stzPispiHttpAdapter) the port has been proven against the twin served over real HTTP and has NOT
# been run against the BCEAO's sandbox, so treat that path as unperceived. WHAT THE PORT ADDS: a
# txId is an idempotency key, since sending it again answers the current state and sends nothing
# (replayed is 1); money out (Pay, PayInBulk, ReturnFunds, accepting a request or a cancellation)
# needs a committed plan on a governed port, which is how a port starts; an amount carries its
# currency and only XOF is spoken; a status of 400 or more raises, and StzLastPaymentsProblem reads
# it; a webhook is verified before it is believed. The amount is forwarded as built and nothing is
# added to it. The journal, the webhook secrets and the events already seen are kept per port in
# shared tables, so copies of a port agree. The card verbs (Authorize, Capture, Refund) are not
# here: they belong to stzCardPaymentsAdapter. The practical guide is docs/payments-guide.md.
#
#   receiver   oHub = StzPiSpiSandboxQ(); o1 = StzPaymentsPortQ(oHub); o1.AllowUngovernedPayouts()
#   example    oOrder = StzPaymentOrderQ().WithTxId("APP-2026-000001").FromAlias(oHub.BusinessAlias()).ToAlias(oHub.Alias("fatou")).WithAmount(StzAmountQ("25000", "XOF")).WithoutConfirmation()
#              aR = o1.Pay(oOrder)
#              ? aR[:statut]
#              #--> ENVOYE
#              oHub.AdvanceSeconds(25)
#              ? o1.StatusOf(aR[:end2endId])[:statut]
#              #--> IRREVOCABLE
#              o1.RegisterWebhook(StzWebhookQ().CallingBack("https://app.example/pispi").OnEvents([ "PAIEMENT_RECU" ]))
#              oHub.SimulateIncomingPayment("fatou", 18500, "APP-2026-000002")
#              aEv = o1.ReceiveWebhook(oHub.LastCallbackBody(), oHub.LastCallbackSignature())
#              ? aEv[:accepted]
#              #--> 1
#              ? aEv[:events][1][:motif]
#              #--> APP-2026-000002
#   see        stzPaymentOrder, stzPaymentRequest, stzPaymentBatch, stzWebhook, stzPaymentsProblem,
#              stzPiSpiSandbox, stzPispiHttpAdapter, stzPayoutDesk, stzServiceRegistry, StzAmountQ
class stzPaymentsPort from stzObject

	@nId = 0
	@oBackend = ""

	# Builds a port in front of a hub, the one object an application calls to send money, ask for it and hear about it.
	#
	#   poBackend   the hub to talk to: the twin (StzPiSpiSandboxQ), a live adapter, or any object
	#               with Request(method, path, query, body) answering [ status, body ]
	#   returns     nothing; the object is built
	#   note        the port keeps its journal, its webhook secrets and its plan authorisations per
	#               port, so two ports on one hub do not share them
	#   warning     raises an error when poBackend is not an object with a Request method
	#   see         stzPiSpiSandbox, stzPispiHttpAdapter, Pay
	def init(poBackend)
		if NOT isObject(poBackend) or NOT isMethod(poBackend, "Request")
			StzRaise("A payments port needs a backend with Request(method, path, query, body): the twin, or a live adapter.")
		ok
		$nPayPortSeq = $nPayPortSeq + 1
		@nId = $nPayPortSeq
		@oBackend = poBackend

	# TRUE if the backend is the in-process twin, which moves no money; a registry reads it to refuse the twin in production.
	#
	#   returns    TRUE or FALSE; FALSE when the backend does not say so
	#   note       the port only asks its backend
	#   see        IsConformance, Backend, stzServiceRegistry
	#@ aka  a port declares what its backend is -- see stzServiceRegistry
	def IsSandbox()
		if isMethod(@oBackend, "IsSandbox")
			return @oBackend.IsSandbox()
		ok
		return 0

	# TRUE if the backend talks to the BCEAO's sandbox, which speaks the real protocol with virtual money; a registry refuses it in production.
	#
	#   returns    TRUE or FALSE; FALSE when the backend does not say so
	#   note       UNPERCEIVED: the adapter that answers TRUE here has been proven against the twin
	#              over real HTTP and has not been run against the BCEAO's sandbox
	#   see        IsSandbox, RequiresCertificate, stzPispiHttpAdapter
	#@ aka  a conformance backend (the BCEAO's sandbox) says so, and the registry reads it off the port
	def IsConformance()
		if isMethod(@oBackend, "IsConformance")
			return @oBackend.IsConformance()
		ok
		return 0

	# TRUE if the backend presents a mutual-TLS client certificate, which a registry then expects to find in a secret store.
	#
	#   returns    TRUE or FALSE; FALSE when the backend does not say so
	#   note       UNPERCEIVED: only a live adapter answers TRUE, and no live adapter has been run
	#              against the BCEAO's sandbox
	#   see        CertificateSecretName, IsConformance, stzPispiHttpAdapter
	#@ aka  a live backend that presents an mTLS client certificate says so, and where it lives
	def RequiresCertificate()
		if isMethod(@oBackend, "RequiresCertificate")
			return @oBackend.RequiresCertificate()
		ok
		return 0

	# Returns the name of the secret that holds the backend's client certificate, so a registry can check it exists and has not expired.
	#
	#   returns    a text; an empty text when the backend has none
	#   note       UNPERCEIVED: only a live adapter names one, and none has been run against the
	#              BCEAO's sandbox
	#   see        RequiresCertificate, stzSecretStore
	def CertificateSecretName()
		if isMethod(@oBackend, "CertificateSecretName")
			return @oBackend.CertificateSecretName()
		ok
		return ""

	# Returns the hub object the port talks to, for a test that must drive the twin directly, such as moving its clock.
	#
	#   returns    the backend object exactly as it was given to the port
	#   note       in a test it is the twin, which has AdvanceSeconds and SimulateIncomingPayment
	#   see        init, IsSandbox
	def Backend()
		return @oBackend

	# Lets this port send money without a committed plan: the loud, named exception that a test of the twin uses.
	#
	#   returns    the port itself, so calls chain
	#   note       the exception belongs to this port only; every other port stays governed
	#   warning    a registry in a production phase refuses a port that did this (ungoverned-
	#              payouts-in-production)
	#   see        IsGoverned, AuthorisePayout, stzPayoutDesk
	#@ aka  -- governance: money out is a plan -------------------------------
	def AllowUngovernedPayouts()
		for _i_ = 1 to ring_len($aPayGov)
			if $aPayGov[_i_][1] = @nId
				$aPayGov[_i_][2] = 1
				return This
			ok
		next
		$aPayGov + [ @nId, 1 ]
		return This

	# TRUE if this port was told to send money without a plan.
	#
	#   returns    TRUE or FALSE
	#   see        AllowUngovernedPayouts, IsGoverned
	def AllowsUngovernedPayouts()
		for _i_ = 1 to ring_len($aPayGov)
			if $aPayGov[_i_][1] = @nId and $aPayGov[_i_][2] = 1
				return 1
			ok
		next
		return 0

	# TRUE if payouts on this port need a committed plan, which is how a port starts.
	#
	#   returns    TRUE or FALSE; the opposite of AllowsUngovernedPayouts
	#   note       asking for money, refusing a request and moving money between the platform's own
	#              accounts need no plan on a governed port
	#   see        AllowUngovernedPayouts, AuthorisePayout
	def IsGoverned()
		return NOT This.AllowsUngovernedPayouts()

	# Records that a committed plan allows one payout of one amount on this port, after checking that the actor may authorise money out.
	#
	#   poActor    the actor authorising, an object that must be effectful and not sandboxed
	#   pcPlanId   the plan that authorises, kept for the record
	#   pcKind     what is authorised: pay, bulk, return, answer-cancellation or answer-request
	#   pcKey      the txId of a payment, the instructionId of a bulk, or the end2endId for the
	#              other kinds
	#   pnAmount   the amount in francs that the payout must equal
	#   returns    1
	#   note       an application rarely calls it: stzPayoutDesk does when a person commits a plan;
	#              authorising the same kind and key again replaces the earlier row and makes it
	#              usable again
	#   warning    an actor that is not effectful, is sandboxed (a language-model actor) or is not
	#              an object raises payout-refused and is written to the security ledger as
	#              payout.refused
	#   see        AuthorisedPayouts, Pay, stzPayoutDesk
	#@ aka  An ADMISSION: only an effectful actor that is not sandboxed may authorise a payout, which is the test the registry's MayGoLive applies. An LLM can propose a plan and cannot do this. One authorisation is for one payout of one amount, held by THIS port.
	def AuthorisePayout(poActor, pcPlanId, pcKind, pcKey, pnAmount)
		_cWho_ = "?"
		if isObject(poActor)
			_cWho_ = "" + poActor.Name()
		ok
		if NOT isObject(poActor) or NOT poActor.IsEffectful() or poActor.Posture() = "sandboxed"
			StzNoteRefusal("payout.refused", _cWho_, "plan:" + pcPlanId, "the actor may not authorise a payout")
			StzRaise("payout-refused: only an effectful, non-sandboxed actor may authorise a payout (" + _cWho_ + " may not).")
		ok
		for _i_ = 1 to ring_len($aPayAuth)
			if $aPayAuth[_i_][1] = @nId and $aPayAuth[_i_][2] = pcKind and $aPayAuth[_i_][3] = pcKey
				$aPayAuth[_i_] = [ @nId, pcKind, pcKey, pnAmount, pcPlanId, 0 ]
				return 1
			ok
		next
		$aPayAuth + [ @nId, pcKind, pcKey, pnAmount, pcPlanId, 0 ]
		return 1

	# Returns the payouts a plan has authorised on this port, oldest first, each with whether it has been used.
	#
	#   returns    a list of records [ kind, key, amount, plan, used ]; used is 1 once the payout
	#              was sent
	#   see        AuthorisePayout, IsGoverned
	#@ aka  [ [ kind, key, amount, plan, used ], ... ] as records, oldest first
	def AuthorisedPayouts()
		_a_ = []
		for _i_ = 1 to ring_len($aPayAuth)
			if $aPayAuth[_i_][1] = @nId
				_a_ + [ [ "kind", $aPayAuth[_i_][2] ], [ "key", $aPayAuth[_i_][3] ], [ "amount", $aPayAuth[_i_][4] ],
					[ "plan", $aPayAuth[_i_][5] ], [ "used", $aPayAuth[_i_][6] ] ]
			ok
		next
		return _a_

	# The gate every money-out verb passes BEFORE it asks the hub anything. pnAmount < 0 means
	# "only that the plan exists" (a confirmation). Answers the row index, 0 when ungoverned.
	def _Gate(pcKind, pcKey, pnAmount, pbConsume)
		if This.AllowsUngovernedPayouts()
			return 0
		ok
		_k_ = 0
		for _i_ = 1 to ring_len($aPayAuth)
			if $aPayAuth[_i_][1] = @nId and $aPayAuth[_i_][2] = pcKind and $aPayAuth[_i_][3] = pcKey
				_k_ = _i_
				exit
			ok
		next
		_cWhat_ = pcKind + " " + pcKey
		if _k_ = 0
			StzNoteRefusal("payout.unplanned", "port:" + @nId, _cWhat_, "no committed plan authorised this payout")
			StzRaise("payout-without-plan: no committed plan authorised " + _cWhat_ + ".")
		ok
		if pnAmount >= 0 and $aPayAuth[_k_][4] != pnAmount
			StzNoteRefusal("payout.unplanned", "port:" + @nId, _cWhat_, "the amount is not the amount the plan authorised")
			StzRaise("payout-amount-differs: plan " + $aPayAuth[_k_][5] + " authorised " + $aPayAuth[_k_][4] +
				" for " + _cWhat_ + ", and " + pnAmount + " was asked.")
		ok
		if pbConsume and $aPayAuth[_k_][6] = 1
			StzNoteRefusal("payout.unplanned", "port:" + @nId, _cWhat_, "the authorisation was already used")
			StzRaise("payout-already-released: the authorisation for " + _cWhat_ + " was already used; a new plan is needed.")
		ok
		return _k_

	def _Release(pnRow)
		if pnRow > 0
			$aPayAuth[pnRow][6] = 1
		ok

	# the amount the HUB holds for something, so a plan cannot name an amount the hub does not
	def _AmountAt(pcPath)
		_a_ = This._Call("GET", pcPath, [], [])
		return _StzPiGet(_a_, "montant", 0)

	# TRUE if a payment status will not change again: IRREVOCABLE, REJETE, ANNULE or ACCEPTE.
	#
	#   pcStatut   the status word as the hub gave it, in capitals
	#   returns    TRUE or FALSE
	#   note       ENVOYE and INITIE are not final: pending is a state, not an error
	#   see        StatusOf, ReasonMeaning
	def IsFinal(pcStatut)
		return StzPaymentsIsFinal(pcStatut)

	# Returns the plain meaning of a reason code such as AM04, the one a rejected payment carries in statutRaison.
	#
	#   pcCode     the ISO 20022 reason code, matched without regard to case
	#   returns    a text; an empty text for a code it does not know
	#   note       it knows the codes a platform meets first, not every enum of the hub
	#   see        StatusOf, IsFinal
	def ReasonMeaning(pcCode)
		return StzPaymentsReasonMeaning(pcCode)

	  #-- the one crossing ----------------------------------------------

	# 2xx answers the body; 400 and more records the problem and RAISES
	def _Call(pcMethod, pcPath, paQuery, paBody)
		_aR_ = @oBackend.Request(pcMethod, pcPath, paQuery, paBody)
		if _aR_[1] >= 400
			$aPayLastProblem = _aR_[2]
			StzRaise("stzPaymentsProblem " + _aR_[1] + " " + _StzPiGet(_aR_[2], "title", "") + ": " +
				_StzPiGet(_aR_[2], "detail", ""))
		ok
		return _aR_[2]

	# A replay READS what the hub holds under the platform's own identifier. The hub answering 404
	# means the first attempt never arrived, so the answer is [] and the caller sends it for real;
	# any other failure is raised.
	def _Replay(pcPath)
		_aR_ = @oBackend.Request("GET", pcPath, [], [])
		if _aR_[1] = 404
			return []
		ok
		if _aR_[1] >= 400
			$aPayLastProblem = _aR_[2]
			StzRaise("stzPaymentsProblem " + _aR_[1] + " " + _StzPiGet(_aR_[2], "title", "") + ": " +
				_StzPiGet(_aR_[2], "detail", ""))
		ok
		return _aR_[2]

	# A TRANSPORT failure after the request was sent: the hub may have processed it and the platform
	# cannot know. Remember the identifier, so the next attempt READS before it sends, and raise.
	def _Lost(pcKind, pcKey, pcError)
		if StzFindFirst("stzPispiHttpAdapter transport", pcError) > 0
			This._Remember(pcKind, pcKey, "")
		ok
		StzRaise(pcError)

	def _Journal(pcKind, pcKey)
		for _i_ = 1 to ring_len($aPayJournal)
			if $aPayJournal[_i_][1] = @nId and $aPayJournal[_i_][2] = pcKind and $aPayJournal[_i_][3] = pcKey
				return _i_
			ok
		next
		return 0

	def _Remember(pcKind, pcKey, pcE2E)
		$aPayJournal + [ @nId, pcKind, pcKey, pcE2E ]

	# Returns how many transactions this port remembers by their identifier, the memory that makes a retry safe.
	#
	#   returns    a number
	#   note       one entry per txId or instructionId sent; a send the hub refused as a duplicate
	#              (DU03) is not remembered
	#   see        Pay, RequestPayment, PayInBulk
	def JournalSize()
		_n_ = 0
		for _i_ = 1 to ring_len($aPayJournal)
			if $aPayJournal[_i_][1] = @nId
				_n_++
			ok
		next
		return _n_

	# Returns who an alias belongs to before it is paid: the client's name, country and category, and the alias key.
	#
	#   pcAlias    the PI-SPI alias, a UUID
	#   returns    a record [ client, alias ]; client is [ nom, pays, categorie ]
	#   note       a 404 is read with StzLastPaymentsProblem
	#   warning    raises stzPaymentsProblem 404 for an alias the hub does not know
	#   see        Pay, Aliases
	#@ aka  -- aliases, accounts, participants -------------------------------
	def ResolveAlias(pcAlias)
		return This._Call("GET", "/alias/" + pcAlias, [], [])

	# Returns the platform's accounts at its participant, each with number, type, opening date and status.
	#
	#   returns    a list of records [ numero, type, dateOuverture, statut ]
	#   see        Account, Aliases
	def Accounts()
		_a_ = This._Call("GET", "/comptes", [], [])
		return _a_[ "data" ]

	# Returns one account with its balance, type and status.
	#
	#   pcNumero   the account number, as Accounts lists it
	#   returns    a record [ type, numero, solde, statut, dateOuverture ]
	#   note       solde is a whole number of francs
	#   see        Accounts, TransferBetweenAccounts
	def Account(pcNumero)
		return This._Call("GET", "/comptes/" + pcNumero, [], [])

	# Returns the aliases attached to an account, each with its key, type and creation date.
	#
	#   pcNumero   the account number
	#   returns    a list of records [ cle, type, compte, dateCreation ]
	#   see        CreateAlias, DeleteAlias, Accounts
	def Aliases(pcNumero)
		_a_ = This._Call("GET", "/comptes/" + pcNumero + "/alias", [], [])
		return _a_[ "data" ]

	# Adds a new alias to an account so that customers can be paid to it, and returns it.
	#
	#   pcNumero   the account number
	#   pcType     the alias type: SHID or MCOD
	#   returns    a record [ cle, type, compte, dateCreation ]
	#   note       the new alias key is in cle
	#   warning    any other type raises a 400 problem that names the field type
	#   see        Aliases, DeleteAlias
	def CreateAlias(pcNumero, pcType)
		return This._Call("POST", "/comptes/" + pcNumero + "/alias", [], [ [ "type", pcType ] ])

	# Removes an alias from an account so it can no longer be paid; an unknown key raises.
	#
	#   pcNumero   the account number
	#   pcCle      the alias key (cle), as Aliases lists it
	#   returns    1
	#   warning    an alias key the hub does not hold raises stzPaymentsProblem 404
	#   see        CreateAlias, Aliases
	def DeleteAlias(pcNumero, pcCle)
		This._Call("DELETE", "/comptes/" + pcNumero + "/alias/" + pcCle, [], [])
		return 1

	# Returns the hub's participants, banks and issuers, each with its code, name and whether it is enabled.
	#
	#   returns    a list of records [ codeMembre, nomMembre, codeBanque, statut ]; codeBanque is
	#              present for banks only, statut is ENBL or DSBL
	#   see        ToIban, ToAccount
	def Participants()
		_a_ = This._Call("GET", "/participants", [], [])
		return _a_[ "data" ]

	# Moves money between two of the platform's own accounts and returns the transfer, which is final at once.
	#
	#   pcTxId     the platform's own unique id for the transfer
	#   pcFrom     the number of the account debited
	#   pcTo       the number of the account credited
	#   poAmount   an amount built with StzAmountQ, in XOF
	#   returns    a record [ txId, payeurNumero, payeNumero, montant, dateEnvoi, statut,
	#              dateIrrevocabilite ]
	#   note       it is not money out, so it needs no plan on a governed port
	#   warning    a bare number or an amount in another currency raises an error before any request
	#              is made
	#   see        Accounts, Pay
	#@ aka  the platform's own accounts: [ txId, payeurNumero, payeNumero, montant ] as an amount
	def TransferBetweenAccounts(pcTxId, pcFrom, pcTo, poAmount)
		_StzPayRequireAmount(poAmount)
		return This._Call("POST", "/comptes/transactions", [], [ [ "txId", pcTxId ], [ "payeurNumero", pcFrom ],
			[ "payeNumero", pcTo ], [ "montant", poAmount.MinorUnits() ] ])

	# Sends money to a payee from an order and returns the payment as the hub states it, ENVOYE until it is final.
	#
	#   poOrder    a stzPaymentOrder with its txId, payer, payee, amount and confirmation set
	#   returns    a record with the hub's fields (statut, end2endId, montant, payeNom...) plus
	#              replayed, 1 when the txId had already been sent
	#   note       UNPERCEIVED behind a live adapter: that adapter has been proven against the twin
	#              over real HTTP and has not been run against the BCEAO's sandbox. ENVOYE is
	#              pending, not done: only IRREVOCABLE and REJETE are final. Sending the same txId
	#              again answers the current state and sends nothing, whatever the second order
	#              says. The amount is forwarded as built and nothing is added to it
	#   warning    on a governed port, the default, it raises payout-without-plan unless a committed
	#              plan authorised this txId, payout-amount-differs when the amount is not the
	#              planned one, and payout-already-released when the authorisation was used; a
	#              refusal by the hub raises stzPaymentsProblem, readable with
	#              StzLastPaymentsProblem
	#   see        StatusOf, ConfirmPayment, SentPayment, AuthorisePayout, stzPaymentOrder
	#@ aka  -- payments -------------------------------------------------------
	def Pay(poOrder)
		_cTx_ = poOrder.TxId()
		_aBody_ = poOrder.AsBody()
		_j_ = This._Journal("pay", _cTx_)
		if _j_ > 0
			_aRep_ = This._Replay("/paiements-envoyes/" + _cTx_)
			if ring_len(_aRep_) > 0
				_aRep_ + [ "replayed", 1 ]
				return _aRep_
			ok
		ok
		_nRow_ = This._Gate("pay", _cTx_, poOrder.Amount(), 1)
		try
			_a_ = This._Call("POST", "/paiements-envoyes", [], _aBody_)
		catch
			This._Lost("pay", _cTx_, cCatchError)
		done
		if NOT ( _StzPiGet(_a_, "statut", "") = "REJETE" and _StzPiGet(_a_, "statutRaison", "") = "DU03" )
			This._Remember("pay", _cTx_, _StzPiGet(_a_, "end2endId", ""))
			This._Release(_nRow_)
		ok
		_a_ + [ "replayed", 0 ]
		return _a_

	# Answers the confirmation step of a payment made with confirmation: yes sends it, no cancels it.
	#
	#   pcTxId     the txId of the payment waiting for confirmation
	#   pbYes      TRUE to send the payment, FALSE to cancel it
	#   returns    the payment record; statut is ENVOYE after yes and ANNULE after no
	#   note       the order must have been built with WithConfirmation
	#   warning    on a governed port a yes raises payout-without-plan when no plan authorised that
	#              txId; a no for a payment already confirmed raises a 403 problem
	#   see        Pay, ReturnFunds
	def ConfirmPayment(pcTxId, pbYes)
		if pbYes
			This._Gate("pay", pcTxId, -1, 0)
		ok
		return This._Call("PUT", "/paiements-envoyes/" + pcTxId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	# Returns one payment the platform sent, found by the txId it chose, with its current status.
	#
	#   pcTxId     the txId the platform gave the payment
	#   returns    a payment record
	#   warning    raises stzPaymentsProblem 404 for a txId the hub does not hold
	#   see        Pay, StatusOf, SentPayments
	def SentPayment(pcTxId)
		return This._Call("GET", "/paiements-envoyes/" + pcTxId, [], [])

	# Returns one payment the platform received, found by the txId the hub gave it.
	#
	#   pcTxId     the txId of the received payment, as ReceivedPayments lists it
	#   returns    a payment record
	#   note       the twin names incoming txIds IN- followed by the end2endId; the platform did not
	#              choose them
	#   warning    raises stzPaymentsProblem 404 for an unknown txId
	#   see        ReceivedPayments, SentPayment
	def ReceivedPayment(pcTxId)
		return This._Call("GET", "/paiements-recus/" + pcTxId, [], [])

	# Returns the payments the platform sent, filtered, as a list; the hub gives 20 per page unless asked otherwise.
	#
	#   paFilter   a list of [ key, value ] pairs: a field name, with an operator in brackets as in
	#              montant[gte], plus page, size (1 to 100) and sort (a leading minus sorts down)
	#   returns    a list of payment records
	#   note       pass [ ] for no filter; the paging data is dropped, SentPaymentsPage keeps it
	#   warning    a size outside 1 to 100 raises a 400 problem
	#   see        SentPaymentsPage, ReceivedPayments, Pay
	def SentPayments(paFilter)
		_a_ = This._Call("GET", "/paiements-envoyes", paFilter, [])
		return _a_[ "data" ]

	# Returns the payments the platform received, the list to reconcile on motif and end2endId.
	#
	#   paFilter   a list of [ key, value ] pairs as SentPayments takes them
	#   returns    a list of payment records
	#   note       motif carries the label the payer typed, such as the reference put in a QR code
	#   see        ReceivedPayment, ReceiveWebhook, SentPayments
	def ReceivedPayments(paFilter)
		_a_ = This._Call("GET", "/paiements-recus", paFilter, [])
		return _a_[ "data" ]

	# Returns the whole answer for the sent payments, data and meta, for a caller that pages through many.
	#
	#   paFilter   a list of [ key, value ] pairs as SentPayments takes them
	#   returns    a record [ data, meta ]; meta is [ total, page, size ]
	#   see        SentPayments
	#@ aka  the whole envelope, for a caller that pages: [ [ "data", ... ], [ "meta", ... ] ]
	def SentPaymentsPage(paFilter)
		return This._Call("GET", "/paiements-envoyes", paFilter, [])

	# Returns the current state of a payment by its end2endId: pending, final or rejected, with the reason code if rejected.
	#
	#   pcEnd2EndId   the hub's id for the payment, found in the answer of Pay
	#   returns       a payment record whose statut is ENVOYE while pending, then IRREVOCABLE or
	#                 REJETE; statutRaison holds the ISO code of a rejection
	#   note          a payment the payee's bank refuses is not an exception: it is a payment whose
	#                 statut became REJETE. The twin's clock moves by hand with AdvanceSeconds
	#   warning       raises stzPaymentsProblem 404 for an unknown id
	#   see           Pay, IsFinal, ReasonMeaning
	#@ aka  the state of any payment by end2endId: the hub answers IRREVOCABLE or REJETE once it has decided, and the twin shows ENVOYE while it has not
	def StatusOf(pcEnd2EndId)
		return This._Call("GET", "/paiements/" + pcEnd2EndId, [], [])

	# Sends back a payment received, as a new movement of the same amount; the hub allows it within 90 days.
	#
	#   pcEnd2EndId   the end2endId of the payment received
	#   returns       the received payment's record, with retourStatut set (INITIE just after)
	#   note          the amount authorised must equal the amount the hub holds for that payment
	#   warning       it is money out: a governed port raises payout-without-plan, and payout-
	#                 already-released on a second try with the same authorisation
	#   see           ReceivedPayments, RequestCancellation, AuthorisePayout
	def ReturnFunds(pcEnd2EndId)
		_nRow_ = 0
		if This.IsGoverned()
			_nRow_ = This._Gate("return", pcEnd2EndId, This._AmountAt("/paiements/" + pcEnd2EndId), 1)
		ok
		_a_ = This._Call("PUT", "/paiements/" + pcEnd2EndId + "/retours", [], [])
		This._Release(_nRow_)
		return _a_

	# Asks the payee to cancel a payment already sent; the payee may refuse, since a payment is irrevocable.
	#
	#   pcEnd2EndId   the end2endId of the payment to cancel
	#   pcMotif       the reason code, such as DUPL or FRAD
	#   returns       the sent payment's record, with annulationStatut and annulationMotif
	#   note          asking is not money out and needs no plan; the hub allows it within 90 days
	#   see           AnswerCancellation, ReturnFunds, StatusOf
	def RequestCancellation(pcEnd2EndId, pcMotif)
		return This._Call("POST", "/paiements/" + pcEnd2EndId + "/annulations", [], [ [ "raison", pcMotif ] ])

	# Answers a cancellation request that a payer made against a payment received: accepting gives the money back.
	#
	#   pcEnd2EndId   the end2endId of the payment the request concerns
	#   pbAccept      TRUE to accept, FALSE to refuse
	#   returns       the payment record, with annulationStatut ACCEPTE after an accept
	#   warning       accepting is money out: a governed port raises payout-without-plan unless a
	#                 plan authorised it; refusing needs no plan
	#   see           RequestCancellation, ReturnFunds
	def AnswerCancellation(pcEnd2EndId, pbAccept)
		_nRow_ = 0
		if pbAccept and This.IsGoverned()
			_nRow_ = This._Gate("answer-cancellation", pcEnd2EndId, This._AmountAt("/paiements/" + pcEnd2EndId), 1)
		ok
		_a_ = This._Call("PUT", "/paiements/" + pcEnd2EndId + "/annulations/reponses", [], [ [ "decision", This._Bool(pbAccept) ] ])
		This._Release(_nRow_)
		return _a_

	# Asks a payer for money with a request to pay and returns it as the hub states it, ENVOYE or INITIE until it is final.
	#
	#   poRequest   a stzPaymentRequest with its txId, payer, payee, amount and category set
	#   returns     a record with the hub's fields (statut, end2endId, montant...) plus replayed, 1
	#               when the txId had already been sent
	#   note        asking for money is not money out, so it needs no plan on a governed port.
	#               Sending the same txId again answers the current state and sends nothing.
	#               UNPERCEIVED behind a live adapter, which has not been run against the BCEAO's
	#               sandbox
	#   warning     the twin refuses an invoice or e-commerce request that lacks PayableBy, with a
	#               400 problem naming dateLimitePaiement
	#   see         RequestedPayment, ConfirmRequest, ReceivedPayments, stzPaymentRequest
	#@ aka  -- requests to pay ------------------------------------------------
	def RequestPayment(poRequest)
		_cTx_ = poRequest.TxId()
		_aBody_ = poRequest.AsBody()
		if This._Journal("rtp", _cTx_) > 0
			_aRep_ = This._Replay("/demandes-paiements/" + _cTx_)
			if ring_len(_aRep_) > 0
				_aRep_ + [ "replayed", 1 ]
				return _aRep_
			ok
		ok
		try
			_a_ = This._Call("POST", "/demandes-paiements", [], _aBody_)
		catch
			This._Lost("rtp", _cTx_, cCatchError)
		done
		if NOT ( _StzPiGet(_a_, "statut", "") = "REJETE" and _StzPiGet(_a_, "statutRaison", "") = "DU03" )
			This._Remember("rtp", _cTx_, _StzPiGet(_a_, "end2endId", ""))
		ok
		_a_ + [ "replayed", 0 ]
		return _a_

	# Answers the confirmation step of a request to pay made with confirmation: yes sends it, no cancels it.
	#
	#   pcTxId     the txId of the request waiting for confirmation
	#   pbYes      TRUE to send it, FALSE to cancel it
	#   returns    the request record; statut is ENVOYE after yes and ANNULE after no
	#   see        RequestPayment, ConfirmBulkRequests
	def ConfirmRequest(pcTxId, pbYes)
		return This._Call("PUT", "/demandes-paiements/" + pcTxId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	# Answers a request to pay that somebody sent to the platform: accepting pays it, refusing needs a reason code.
	#
	#   pcEnd2EndId   the end2endId of the request received
	#   pbAccept      TRUE to pay it, FALSE to refuse
	#   pcReason      the reason code sent when refusing, such as AM09 for a wrong amount, unused
	#                 when accepting
	#   returns       the request record; statut is REJETE after a refusal and IRREVOCABLE after an
	#                 accept
	#   warning       accepting is money out: a governed port raises payout-without-plan unless a
	#                 plan authorised it; refusing needs no plan
	#   see           ReceivedRequests, ConfirmRequest, AuthorisePayout
	#@ aka  a request we RECEIVED: accepting pays it, so it is money out; rejecting needs a reason
	def AnswerRequest(pcEnd2EndId, pbAccept, pcReason)
		_nRow_ = 0
		if pbAccept and This.IsGoverned()
			_nRow_ = This._Gate("answer-request", pcEnd2EndId, This._AmountAt("/demandes-paiements-recues/" + pcEnd2EndId), 1)
		ok
		_a_ = [ [ "decision", This._Bool(pbAccept) ] ]
		if NOT pbAccept
			_a_ + [ "raison", pcReason ]
		ok
		_aR_ = This._Call("PUT", "/demandes-paiements-recues/" + pcEnd2EndId + "/reponses", [], _a_)
		This._Release(_nRow_)
		return _aR_

	# Returns the requests to pay the platform sent, filtered, as a list.
	#
	#   paFilter   a list of [ key, value ] pairs as SentPayments takes them
	#   returns    a list of request records
	#   see        RequestedPayment, ReceivedRequests
	def Requests(paFilter)
		_a_ = This._Call("GET", "/demandes-paiements", paFilter, [])
		return _a_[ "data" ]

	# Returns one request to pay the platform sent, found by its txId, with its current status.
	#
	#   pcTxId     the txId the platform gave the request
	#   returns    a request record; statut is IRREVOCABLE once the payer has paid
	#   warning    raises stzPaymentsProblem 404 for an unknown txId
	#   see        RequestPayment, Requests
	def RequestedPayment(pcTxId)
		return This._Call("GET", "/demandes-paiements/" + pcTxId, [], [])

	# Returns the requests to pay that others sent to the platform: what is waiting for an answer.
	#
	#   paFilter   a list of [ key, value ] pairs, such as [ [ "statut", "ENVOYE" ] ] for the ones
	#              still open, or [ ] for all
	#   returns    a list of request records
	#   see        AnswerRequest, Requests
	def ReceivedRequests(paFilter)
		_a_ = This._Call("GET", "/demandes-paiements-recues", paFilter, [])
		return _a_[ "data" ]

	# Sends many payments as one batch under one instructionId and returns the batch status with its counts.
	#
	#   poBatch    a stzPaymentBatch whose items are payment orders
	#   returns    a record [ instructionId, statut, transactionsTotal, transactionsEnvoyees,
	#              transactionsIrrevocables, transactionsRejetees... ] plus replayed
	#   note       the hub accepts the batch without a payment-level answer, so the port reads the
	#              status back and returns that. Sending the same instructionId again answers the
	#              batch's current state. UNPERCEIVED behind a live adapter
	#   warning    on a governed port it raises payout-without-plan unless a plan authorised this
	#              instructionId for the sum of its items, and payout-amount-differs and payout-
	#              already-released work as for Pay
	#   see        Bulk, ConfirmBulk, stzPaymentBatch, AuthorisePayout
	#@ aka  -- bulk ------------------------------------------------------------
	def PayInBulk(poBatch)
		_cId_ = poBatch.InstructionId()
		_aBody_ = poBatch.AsBody()
		if This._Journal("bulk", _cId_) > 0
			_aRep_ = This._Replay("/paiements-groupes/" + _cId_)
			if ring_len(_aRep_) > 0
				_aRep_ + [ "replayed", 1 ]
				return _aRep_
			ok
		ok
		_nRow_ = This._Gate("bulk", _cId_, poBatch.TotalAmount(), 1)
		try
			This._Call("POST", "/paiements-groupes", [], _aBody_)
		catch
			This._Lost("bulk", _cId_, cCatchError)
		done
		This._Remember("bulk", _cId_, "")
		This._Release(_nRow_)
		_a_ = This.Bulk(_cId_)
		_a_ + [ "replayed", 0 ]
		return _a_

	# Answers the confirmation step of a bulk payment made with confirmation: yes releases its payments, no cancels the batch.
	#
	#   pcInstructionId   the instructionId of the batch waiting
	#   pbYes             TRUE to release, FALSE to cancel
	#   returns           the batch status; statut is CONFIRME after yes and ANNULE after no
	#   warning           on a governed port a yes raises payout-without-plan when no plan
	#                     authorised that instructionId
	#   see               PayInBulk, Bulk
	def ConfirmBulk(pcInstructionId, pbYes)
		if pbYes
			This._Gate("bulk", pcInstructionId, -1, 0)
		ok
		return This._Call("PUT", "/paiements-groupes/" + pcInstructionId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	# Returns the status of a bulk payment, with how many of its payments are initiated, sent, irrevocable and rejected.
	#
	#   pcInstructionId   the instructionId of the batch
	#   returns           a record [ instructionId, statut, dateDemande, transactionsTotal,
	#                     transactionsInitiees, transactionsEnvoyees, transactionsIrrevocables,
	#                     transactionsRejetees ]
	#   note              read it again after the hub has had time: the counts move from sent to
	#                     irrevocable
	#   see               PayInBulk, BulkRequests
	def Bulk(pcInstructionId)
		return This._Call("GET", "/paiements-groupes/" + pcInstructionId, [], [])

	# Asks many payers for money in one batch of requests to pay and returns the batch status.
	#
	#   poBatch    a stzPaymentBatch whose items are requests to pay, built with ToAlias for the
	#              platform's alias
	#   returns    a record with the batch status plus replayed, 1 when the instructionId had
	#              already been sent
	#   note       asking is not money out and needs no plan
	#   warning    unlike RequestPayment and PayInBulk it does not remember the instructionId after
	#              a transport failure, so a retry sends the batch again
	#   see        BulkRequests, ConfirmBulkRequests, stzPaymentBatch
	def RequestPaymentsInBulk(poBatch)
		_cId_ = poBatch.InstructionId()
		_aBody_ = poBatch.AsRequestBody()
		if This._Journal("bulkrtp", _cId_) > 0
			_a_ = This.BulkRequests(_cId_)
			_a_ + [ "replayed", 1 ]
			return _a_
		ok
		This._Call("POST", "/demandes-paiements-groupes", [], _aBody_)
		This._Remember("bulkrtp", _cId_, "")
		_a_ = This.BulkRequests(_cId_)
		_a_ + [ "replayed", 0 ]
		return _a_

	# Returns the status of a bulk of requests to pay, with its counts of initiated, sent, irrevocable and rejected requests.
	#
	#   pcInstructionId   the instructionId of the batch of requests
	#   returns           a record shaped like the answer of Bulk
	#   see               RequestPaymentsInBulk, Bulk
	def BulkRequests(pcInstructionId)
		return This._Call("GET", "/demandes-paiements-groupes/" + pcInstructionId, [], [])

	# Answers the confirmation step of a bulk of requests to pay made with confirmation: yes sends them, no cancels the batch.
	#
	#   pcInstructionId   the instructionId of the batch waiting
	#   pbYes             TRUE to send, FALSE to cancel
	#   returns           the batch status; statut is CONFIRME after yes and ANNULE after no
	#   see               RequestPaymentsInBulk, ConfirmBulk
	def ConfirmBulkRequests(pcInstructionId, pbYes)
		return This._Call("PUT", "/demandes-paiements-groupes/" + pcInstructionId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	# Tells the hub where to call back and for which events; the port keeps the secret the hub answers once, to verify what arrives.
	#
	#   poHook     a stzWebhook with the callback URL and the events to hear
	#   returns    the webhook record [ id, callbackUrl, events, dateCreation, secret ]
	#   note       the secret is in this answer only and Webhook never shows it again: keep the
	#              answer out of logs
	#   warning    the twin refuses a callback URL that is not https and an unknown event, each with
	#              a 400 problem that names the field
	#   see        ReceiveWebhook, Webhooks, RenewWebhookSecret, stzWebhook
	#@ aka  -- webhooks the platform registers --------------------------------
	def RegisterWebhook(poHook)
		_a_ = This._Call("POST", "/webhooks", [], poHook.AsBody())
		This.SetWebhookSecret(_StzPiGet(_a_, "secret", ""))
		return _a_

	# Returns the webhooks registered for the platform, each as the hub lists it.
	#
	#   returns    a list of webhook records
	#   see        Webhook, RegisterWebhook
	def Webhooks()
		_a_ = This._Call("GET", "/webhooks", [], [])
		return _a_[ "data" ]

	# Returns one registered webhook by its id: callback URL, events and dates, never the secret.
	#
	#   pcId       the webhook id the hub gave, such as wh-1
	#   returns    a webhook record
	#   warning    raises stzPaymentsProblem 404 for an unknown id
	#   see        Webhooks, ChangeWebhook
	def Webhook(pcId)
		return This._Call("GET", "/webhooks/" + pcId, [], [])

	# Changes the callback URL, alias or events of a registered webhook and returns the webhook as it now stands.
	#
	#   pcId       the webhook id
	#   paChange   a list of [ field, value ] pairs, from callbackUrl, alias and events
	#   returns    the webhook record, with dateModification
	#   see        Webhook, RegisterWebhook
	def ChangeWebhook(pcId, paChange)
		return This._Call("PUT", "/webhooks/" + pcId, [], paChange)

	# Removes a registered webhook so the hub stops calling it.
	#
	#   pcId       the webhook id
	#   returns    1
	#   note       the port keeps the secrets it already holds
	#   see        RegisterWebhook, Webhooks
	def DeleteWebhook(pcId)
		This._Call("DELETE", "/webhooks/" + pcId, [], [])
		return 1

	# Asks the hub for a new secret for a webhook and adds it to the keys the port verifies with; the old one stays accepted.
	#
	#   pcId          the webhook id
	#   pcExpiresAt   when the new secret takes over, as a date-time such as
	#                 2026-12-31T00:00:00.000Z
	#   returns       the webhook record, with the new secret shown once
	#   note          the port never drops the old key itself, so keys accumulate
	#   see           RegisterWebhook, SetWebhookSecret, ReceiveWebhook
	#@ aka  the new secret takes over at pcExpiresAt, so both are accepted until then
	def RenewWebhookSecret(pcId, pcExpiresAt)
		_a_ = This._Call("POST", "/webhooks/" + pcId + "/secrets", [], [ [ "dateExpiration", pcExpiresAt ] ])
		This.SetWebhookSecret(_StzPiGet(_a_, "secret", ""))
		return _a_

	  #-- webhooks the hub sends -------------------------------------------

	# the port's signer, found in the shared table (made on first use)
	def _SignerSlot()
		for _i_ = 1 to ring_len($aPaySigners)
			if $aPaySigners[_i_][1] = @nId
				return _i_
			ok
		next
		_o_ = new stzRequestSigner("webhooks")
		$aPaySigners + [ @nId, _o_ ]
		return ring_len($aPaySigners)

	# Adds a secret that the port will accept webhook signatures under and returns the id it gave that key.
	#
	#   pcSecret   the webhook secret as text
	#   returns    a text such as secret-1, secret-2...; an empty text when pcSecret is empty and
	#              nothing is added
	#   note       RegisterWebhook and RenewWebhookSecret call it for you, and a secret written as a
	#              literal belongs in a test only
	#   see        UseWebhookSecretFrom, RegisterWebhook, ReceiveWebhook
	#@ aka  A secret the port will accept a signature under: one key in the signer, named secret-N. A hub that renews a secret leaves both valid until the old one lapses, so keys accumulate. Answers the key's id.
	def SetWebhookSecret(pcSecret)
		if pcSecret = ""
			return ""
		ok
		_k_ = This._SignerSlot()
		_cId_ = "secret-" + ( ring_len($aPaySigners[_k_][2].Keys()) + 1 )
		$aPaySigners[_k_][2].AddKey(_cId_, pcSecret)
		return _cId_

	# Takes a webhook secret out of a secret store through its governed door and adds it as a key the port verifies with.
	#
	#   poStore        a stzSecretStore that holds the secret
	#   pcSecretName   the name the secret is registered under
	#   poActor        the actor asking, an object that must be effectful and not sandboxed
	#   returns        the id of the new key, such as secret-1
	#   note           the store audits the read either way
	#   warning        a refused actor or a name the store does not hold raises an error and the
	#                  port gains no key
	#   see            SetWebhookSecret, ReceiveWebhook, stzSecretStore
	#@ aka  THE GOVERNED DOOR: the secret comes out of the store through Reveal(), which only an effectful, non-sandboxed actor may call and which the store audits either way. A refused actor, or a name the store does not hold, RAISES and the port gains no key.
	def UseWebhookSecretFrom(poStore, pcSecretName, poActor)
		_c_ = poStore.Reveal(pcSecretName, poActor)
		return This.SetWebhookSecret(_c_)

	def _Refuse(pcWhy)
		$aPayRefused + [ @nId, pcWhy ]
		return [ [ "accepted", 0 ], [ "status", 401 ], [ "reason", pcWhy ], [ "events", [] ] ]

	# Verifies a call from the hub before believing it, and answers whether it is accepted, the HTTP status owed and its new events.
	#
	#   pcBody        the raw body of the call exactly as received
	#   pcSignature   the value of the X-Signature header
	#   returns       a record [ accepted, status, reason, events ]: accepted 1 with status 204 and
	#                 the new events, or accepted 0 with status 401 and a reason of unsigned, bad-
	#                 signature, replay or malformed
	#   note          UNPERCEIVED: only calls signed by the twin have been verified, and no callback
	#                 from a real hub has been seen. Every refusal is noted in the security ledger.
	#                 Answer 204 first and work afterwards, since the hub retries what it did not
	#                 see acknowledged
	#   warning       an event already believed is refused as a replay even when its envelope was
	#                 signed again, and a signed body that is not JSON or carries no event is
	#                 refused as malformed; none of these raises
	#   see           Events, RefusedWebhooks, SetWebhookSecret, RegisterWebhook
	#@ aka  Verified BEFORE believed: unsigned, mis-signed, replayed and malformed are all refused, and the signer writes the first three into the security ledger (the port writes the others). Answers [ accepted, status, reason, events ]: status is what the callback owes the hub.
	def ReceiveWebhook(pcBody, pcSignature)
		_k_ = This._SignerSlot()
		_cKid_ = $aPaySigners[_k_][2].VerifyWebhook(pcBody, pcSignature, StzEngineTimeNowMs(), 300000)
		if _cKid_ = ""
			_cWhy_ = $aPaySigners[_k_][2].Why()
			if _cWhy_ = "unsigned"
				return This._Refuse("unsigned")
			ok
			if StzFindFirst("replay", _cWhy_) > 0
				return This._Refuse("replay")
			ok
			return This._Refuse("bad-signature")
		ok
		if NOT StzJsonIsValid(pcBody)
			StzNoteRefusal("webhook.malformed", "port:" + @nId, "body:" + StzLen("" + pcBody) + " bytes", "signed, and not JSON")
			return This._Refuse("malformed")
		ok
		_a_ = StzJsonToList(pcBody)
		_aData_ = _StzPiGet(_a_, "data", [])
		if NOT isList(_aData_) or ring_len(_aData_) = 0
			StzNoteRefusal("webhook.malformed", "port:" + @nId, "body:" + StzLen("" + pcBody) + " bytes", "signed, and carries no event")
			return This._Refuse("malformed")
		ok
		# a replay is an EVENT already seen -- same end2endId, code and date -- even when the
		# envelope around it was re-signed and so is a different body
		_aNew_ = []
		for _i_ = 1 to ring_len(_aData_)
			_mark_ = "" + _StzPiGet(_aData_[_i_], "end2endId", "") + "|" + _StzPiGet(_aData_[_i_], "evCode", "") + "|" +
				_StzPiGet(_aData_[_i_], "evDate", "")
			_seen_ = 0
			for _j_ = 1 to ring_len($aPaySeen)
				if $aPaySeen[_j_][1] = @nId and $aPaySeen[_j_][2] = _mark_
					_seen_ = 1
					exit
				ok
			next
			if _seen_ = 0
				$aPaySeen + [ @nId, _mark_ ]
				_aNew_ + _aData_[_i_]
				$aPayEvents + [ @nId, _aData_[_i_] ]
			ok
		next
		if ring_len(_aNew_) = 0
			StzNoteRefusal("webhook.replayed", "port:" + @nId, "key:" + _cKid_, "every event in the envelope was already believed")
			return This._Refuse("replay")
		ok
		return [ [ "accepted", 1 ], [ "status", 204 ], [ "reason", "" ], [ "events", _aNew_ ] ]

	# Returns the reasons of the calls this port refused, oldest first.
	#
	#   returns    a list of text: unsigned, bad-signature, replay or malformed
	#   see        ReceiveWebhook, Events
	def RefusedWebhooks()
		_a_ = []
		for _i_ = 1 to ring_len($aPayRefused)
			if $aPayRefused[_i_][1] = @nId
				_a_ + $aPayRefused[_i_][2]
			ok
		next
		return _a_

	# Returns every event this port accepted, oldest first, each as the hub sent it.
	#
	#   returns    a list of event records [ evCode, evDate, txId, end2endId, montant, client,
	#              alias, motif ]
	#   note       reconcile on motif and end2endId
	#   see        ReceiveWebhook, ReceivedPayments
	#@ aka  every event the port has accepted, oldest first
	def Events()
		_a_ = []
		for _i_ = 1 to ring_len($aPayEvents)
			if $aPayEvents[_i_][1] = @nId
				_a_ + $aPayEvents[_i_][2]
			ok
		next
		return _a_

	def _Bool(pb)
		if pb
			return 1
		ok
		return 0
