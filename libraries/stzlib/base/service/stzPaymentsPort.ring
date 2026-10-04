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
  * AMOUNTS CARRY A CURRENCY. An order is built with StzAmountQ, and the hub speaks XOF only, so
    another currency is refused before a request exists.
  * AN ERROR IS A PROBLEM. A status of 400 or more raises, and StzLastPaymentsProblem() answers
    the RFC 7807 fields the hub returned: status, title, detail, invalid-params.
  * A WEBHOOK IS VERIFIED BEFORE IT IS BELIEVED. ReceiveWebhook checks the HMAC-SHA256 of the body
    against X-Signature, refuses the unsigned, the mis-signed and the replayed, and answers the
    HTTP status the callback owes the participant (204 or 401).

Boolean fields travel as 1 and 0 inside Ring lists (confirmation, decision, programme); the HTTP
boundary of the live adapter turns them into true and false.

STATE IS SHARED, because Ring copies a registry's binding on every fetch: the journal, the
secrets and the seen events live in global tables keyed by the port's id.

The CARD verbs (Authorize, Capture, Refund) are one ADAPTER, in stzCardPaymentsAdapter.ring. They
are the shape of a card gateway, not of money in the UEMOA.

The charter is SOFTANZA_PAYMENTS_PORT.md, next to this file.
*/

$nPayPortSeq = 0
$aPayJournal = []
$aPaySecrets = []
$aPaySeen = []
$aPayRefused = []
$aPayEvents = []
$aPayLastProblem = []

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

# constant-time equality by double HMAC: re-key both sides with a fresh random secret
func _StzPaySecureEq(pcA, pcB)
	if StzLen("" + pcA) != StzLen("" + pcB)
		return 0
	ok
	_k_ = StzEngineCryptoRandomHex(16)
	return StzWebhookSignature(pcA, _k_) = StzWebhookSignature(pcB, _k_)

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

class stzPaymentsProblem from stzObject

	@aBody = []

	def init(paBody)
		if isList(paBody)
			@aBody = paBody
		ok

	def Status()
		return _StzPiGet(@aBody, "status", 0)

	def Title()
		return _StzPiGet(@aBody, "title", "")

	def Detail()
		return _StzPiGet(@aBody, "detail", "")

	def Type()
		return _StzPiGet(@aBody, "type", "about:blank")

	# [ [ name, reason ] ... ] as the hub gave them, reshaped to a list of two-key records
	def InvalidParams()
		return _StzPiGet(@aBody, "invalid-params", [])

	def Content()
		return @aBody

#---------------------------------------------------------------------#
#  builders: what a platform says, as the wire says it                 #
#---------------------------------------------------------------------#

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

	def init()
		# nothing to prepare: a builder starts empty and says what it needs

	def WithTxId(pcTx)
		@cTx = "" + pcTx
		return This

	# the platform's alias, the account that is debited
	def FromAlias(pcAlias)
		@cFrom = "" + pcAlias
		return This

	def ToAlias(pcAlias)
		@cTo = "" + pcAlias
		return This

	def ToIban(pcIban, pcParticipant)
		@cIban = "" + pcIban
		@cParticipant = "" + pcParticipant
		return This

	def ToAccount(pcCompte, pcParticipant)
		@cCompte = "" + pcCompte
		@cParticipant = "" + pcParticipant
		return This

	def WithAmount(poAmount)
		_StzPayRequireAmount(poAmount)
		@nMontant = poAmount.MinorUnits()
		return This

	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	def Documented(pcNumber, pcType)
		@cDocNo = "" + pcNumber
		@cDocType = "" + pcType
		return This

	def WithConfirmation()
		@nConfirm = 1
		return This

	def WithoutConfirmation()
		@nConfirm = 0
		return This

	def TxId()
		return @cTx

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

	# an item of a bulk: no payer, no confirmation, those belong to the batch
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

	def init()
		# nothing to prepare: a builder starts empty and says what it needs

	def WithTxId(pcTx)
		@cTx = "" + pcTx
		return This

	# the payer we ask
	def FromAlias(pcAlias)
		@cPayer = "" + pcAlias
		return This

	# where we want the money to land: the platform's alias
	def ToAlias(pcAlias)
		@cPayee = "" + pcAlias
		return This

	def WithAmount(poAmount)
		_StzPayRequireAmount(poAmount)
		@nMontant = poAmount.MinorUnits()
		return This

	# 500 on-site, 521 e-commerce, 401 invoice
	def InCategory(pcCategory)
		@cCategory = "" + pcCategory
		return This

	def PayableBy(pcDate)
		@cPayBy = "" + pcDate
		return This

	def AnswerableBy(pcDate)
		@cAnswerBy = "" + pcDate
		return This

	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	def Documented(pcNumber, pcType)
		@cDocNo = "" + pcNumber
		@cDocType = "" + pcType
		return This

	def WithConfirmation()
		@nConfirm = 1
		return This

	def WithoutConfirmation()
		@nConfirm = 0
		return This

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

# a bulk: ONE instructionId for the whole batch, one txId per item
class stzPaymentBatch from stzObject

	@cId = ""
	@cFrom = ""
	@cTo = ""
	@cMotif = ""
	@cCategory = "401"
	@nConfirm = 0
	@aItems = []

	def init()
		# nothing to prepare: a builder starts empty and says what it needs

	def WithInstructionId(pcId)
		@cId = "" + pcId
		return This

	# for a bulk PAYMENT: the platform's alias that is debited
	def FromAlias(pcAlias)
		@cFrom = "" + pcAlias
		return This

	# for a bulk REQUEST: the platform's alias that is paid
	def ToAlias(pcAlias)
		@cTo = "" + pcAlias
		return This

	def InCategory(pcCategory)
		@cCategory = "" + pcCategory
		return This

	def Motive(pcMotif)
		@cMotif = "" + pcMotif
		return This

	def WithConfirmation()
		@nConfirm = 1
		return This

	def WithoutConfirmation()
		@nConfirm = 0
		return This

	def Add(poItem)
		@aItems + poItem.AsItem()
		return This

	def InstructionId()
		return @cId

	def NumberOfItems()
		return ring_len(@aItems)

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

	def AsBody()
		_a_ = This._Head("payeurAlias", @cFrom)
		_a_ + [ "transactions", @aItems ]
		return _a_

	def AsRequestBody()
		_a_ = This._Head("payeAlias", @cTo)
		_a_ + [ "categorie", @cCategory ]
		_a_ + [ "transactions", @aItems ]
		return _a_

class stzWebhook from stzObject

	@cUrl = ""
	@cAlias = ""
	@aEvents = []

	def init()
		# nothing to prepare: a builder starts empty and says what it needs

	def CallingBack(pcUrl)
		@cUrl = "" + pcUrl
		return This

	def OnEvents(paEvents)
		@aEvents = paEvents
		return This

	def ForAlias(pcAlias)
		@cAlias = "" + pcAlias
		return This

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

class stzPaymentsPort from stzObject

	@nId = 0
	@oBackend = ""

	def init(poBackend)
		if NOT isObject(poBackend) or NOT isMethod(poBackend, "Request")
			StzRaise("A payments port needs a backend with Request(method, path, query, body): the twin, or a live adapter.")
		ok
		$nPayPortSeq = $nPayPortSeq + 1
		@nId = $nPayPortSeq
		@oBackend = poBackend

	# a port declares what its backend is -- see stzServiceRegistry
	def IsSandbox()
		if isMethod(@oBackend, "IsSandbox")
			return @oBackend.IsSandbox()
		ok
		return 0

	def Backend()
		return @oBackend

	def IsFinal(pcStatut)
		return StzPaymentsIsFinal(pcStatut)

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

	def _Journal(pcKind, pcKey)
		for _i_ = 1 to ring_len($aPayJournal)
			if $aPayJournal[_i_][1] = @nId and $aPayJournal[_i_][2] = pcKind and $aPayJournal[_i_][3] = pcKey
				return _i_
			ok
		next
		return 0

	def _Remember(pcKind, pcKey, pcE2E)
		$aPayJournal + [ @nId, pcKind, pcKey, pcE2E ]

	def JournalSize()
		_n_ = 0
		for _i_ = 1 to ring_len($aPayJournal)
			if $aPayJournal[_i_][1] = @nId
				_n_++
			ok
		next
		return _n_

	  #-- aliases, accounts, participants -------------------------------

	def ResolveAlias(pcAlias)
		return This._Call("GET", "/alias/" + pcAlias, [], [])

	def Accounts()
		_a_ = This._Call("GET", "/comptes", [], [])
		return _a_[ "data" ]

	def Account(pcNumero)
		return This._Call("GET", "/comptes/" + pcNumero, [], [])

	def Aliases(pcNumero)
		_a_ = This._Call("GET", "/comptes/" + pcNumero + "/alias", [], [])
		return _a_[ "data" ]

	def CreateAlias(pcNumero, pcType)
		return This._Call("POST", "/comptes/" + pcNumero + "/alias", [], [ [ "type", pcType ] ])

	def DeleteAlias(pcNumero, pcCle)
		This._Call("DELETE", "/comptes/" + pcNumero + "/alias/" + pcCle, [], [])
		return 1

	def Participants()
		_a_ = This._Call("GET", "/participants", [], [])
		return _a_[ "data" ]

	# the platform's own accounts: [ txId, payeurNumero, payeNumero, montant ] as an amount
	def TransferBetweenAccounts(pcTxId, pcFrom, pcTo, poAmount)
		_StzPayRequireAmount(poAmount)
		return This._Call("POST", "/comptes/transactions", [], [ [ "txId", pcTxId ], [ "payeurNumero", pcFrom ],
			[ "payeNumero", pcTo ], [ "montant", poAmount.MinorUnits() ] ])

	  #-- payments -------------------------------------------------------

	# THE JOURNAL: a txId already sent answers its CURRENT state and sends nothing.
	def Pay(poOrder)
		_cTx_ = poOrder.TxId()
		_aBody_ = poOrder.AsBody()
		_j_ = This._Journal("pay", _cTx_)
		if _j_ > 0
			_a_ = This._Call("GET", "/paiements-envoyes/" + _cTx_, [], [])
			_a_ + [ "replayed", 1 ]
			return _a_
		ok
		_a_ = This._Call("POST", "/paiements-envoyes", [], _aBody_)
		if NOT ( _StzPiGet(_a_, "statut", "") = "REJETE" and _StzPiGet(_a_, "statutRaison", "") = "DU03" )
			This._Remember("pay", _cTx_, _StzPiGet(_a_, "end2endId", ""))
		ok
		_a_ + [ "replayed", 0 ]
		return _a_

	def ConfirmPayment(pcTxId, pbYes)
		return This._Call("PUT", "/paiements-envoyes/" + pcTxId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	def SentPayment(pcTxId)
		return This._Call("GET", "/paiements-envoyes/" + pcTxId, [], [])

	def ReceivedPayment(pcTxId)
		return This._Call("GET", "/paiements-recus/" + pcTxId, [], [])

	def SentPayments(paFilter)
		_a_ = This._Call("GET", "/paiements-envoyes", paFilter, [])
		return _a_[ "data" ]

	def ReceivedPayments(paFilter)
		_a_ = This._Call("GET", "/paiements-recus", paFilter, [])
		return _a_[ "data" ]

	# the whole envelope, for a caller that pages: [ [ "data", ... ], [ "meta", ... ] ]
	def SentPaymentsPage(paFilter)
		return This._Call("GET", "/paiements-envoyes", paFilter, [])

	# the state of any payment by end2endId: the hub answers IRREVOCABLE or REJETE once it has
	# decided, and the twin shows ENVOYE while it has not
	def StatusOf(pcEnd2EndId)
		return This._Call("GET", "/paiements/" + pcEnd2EndId, [], [])

	def ReturnFunds(pcEnd2EndId)
		return This._Call("PUT", "/paiements/" + pcEnd2EndId + "/retours", [], [])

	def RequestCancellation(pcEnd2EndId, pcMotif)
		return This._Call("POST", "/paiements/" + pcEnd2EndId + "/annulations", [], [ [ "raison", pcMotif ] ])

	def AnswerCancellation(pcEnd2EndId, pbAccept)
		return This._Call("PUT", "/paiements/" + pcEnd2EndId + "/annulations/reponses", [], [ [ "decision", This._Bool(pbAccept) ] ])

	  #-- requests to pay ------------------------------------------------

	def RequestPayment(poRequest)
		_cTx_ = poRequest.TxId()
		_aBody_ = poRequest.AsBody()
		if This._Journal("rtp", _cTx_) > 0
			_a_ = This._Call("GET", "/demandes-paiements/" + _cTx_, [], [])
			_a_ + [ "replayed", 1 ]
			return _a_
		ok
		_a_ = This._Call("POST", "/demandes-paiements", [], _aBody_)
		if NOT ( _StzPiGet(_a_, "statut", "") = "REJETE" and _StzPiGet(_a_, "statutRaison", "") = "DU03" )
			This._Remember("rtp", _cTx_, _StzPiGet(_a_, "end2endId", ""))
		ok
		_a_ + [ "replayed", 0 ]
		return _a_

	def ConfirmRequest(pcTxId, pbYes)
		return This._Call("PUT", "/demandes-paiements/" + pcTxId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	# a request we RECEIVED: accepting pays it, so it is money out; rejecting needs a reason
	def AnswerRequest(pcEnd2EndId, pbAccept, pcReason)
		_a_ = [ [ "decision", This._Bool(pbAccept) ] ]
		if NOT pbAccept
			_a_ + [ "raison", pcReason ]
		ok
		return This._Call("PUT", "/demandes-paiements-recues/" + pcEnd2EndId + "/reponses", [], _a_)

	def Requests(paFilter)
		_a_ = This._Call("GET", "/demandes-paiements", paFilter, [])
		return _a_[ "data" ]

	def RequestedPayment(pcTxId)
		return This._Call("GET", "/demandes-paiements/" + pcTxId, [], [])

	def ReceivedRequests(paFilter)
		_a_ = This._Call("GET", "/demandes-paiements-recues", paFilter, [])
		return _a_[ "data" ]

	  #-- bulk ------------------------------------------------------------

	# one instructionId for the batch; answered 202, so the port reads the status back
	def PayInBulk(poBatch)
		_cId_ = poBatch.InstructionId()
		_aBody_ = poBatch.AsBody()
		if This._Journal("bulk", _cId_) > 0
			_a_ = This.Bulk(_cId_)
			_a_ + [ "replayed", 1 ]
			return _a_
		ok
		This._Call("POST", "/paiements-groupes", [], _aBody_)
		This._Remember("bulk", _cId_, "")
		_a_ = This.Bulk(_cId_)
		_a_ + [ "replayed", 0 ]
		return _a_

	def ConfirmBulk(pcInstructionId, pbYes)
		return This._Call("PUT", "/paiements-groupes/" + pcInstructionId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	def Bulk(pcInstructionId)
		return This._Call("GET", "/paiements-groupes/" + pcInstructionId, [], [])

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

	def BulkRequests(pcInstructionId)
		return This._Call("GET", "/demandes-paiements-groupes/" + pcInstructionId, [], [])

	def ConfirmBulkRequests(pcInstructionId, pbYes)
		return This._Call("PUT", "/demandes-paiements-groupes/" + pcInstructionId + "/confirmations", [], [ [ "decision", This._Bool(pbYes) ] ])

	  #-- webhooks the platform registers --------------------------------

	# the hub answers the secret ONCE: the port keeps it to verify what the hub sends
	def RegisterWebhook(poHook)
		_a_ = This._Call("POST", "/webhooks", [], poHook.AsBody())
		This.SetWebhookSecret(_StzPiGet(_a_, "secret", ""))
		return _a_

	def Webhooks()
		_a_ = This._Call("GET", "/webhooks", [], [])
		return _a_[ "data" ]

	def Webhook(pcId)
		return This._Call("GET", "/webhooks/" + pcId, [], [])

	def ChangeWebhook(pcId, paChange)
		return This._Call("PUT", "/webhooks/" + pcId, [], paChange)

	def DeleteWebhook(pcId)
		This._Call("DELETE", "/webhooks/" + pcId, [], [])
		return 1

	# the new secret takes over at pcExpiresAt, so both are accepted until then
	def RenewWebhookSecret(pcId, pcExpiresAt)
		_a_ = This._Call("POST", "/webhooks/" + pcId + "/secrets", [], [ [ "dateExpiration", pcExpiresAt ] ])
		This.SetWebhookSecret(_StzPiGet(_a_, "secret", ""))
		return _a_

	  #-- webhooks the hub sends -------------------------------------------

	# a secret the port will accept a signature under. PY3 moves this into the secret store.
	def SetWebhookSecret(pcSecret)
		if pcSecret != ""
			$aPaySecrets + [ @nId, pcSecret ]
		ok
		return This

	def _Refuse(pcWhy)
		$aPayRefused + [ @nId, pcWhy ]
		return [ [ "accepted", 0 ], [ "status", 401 ], [ "reason", pcWhy ], [ "events", [] ] ]

	# Verified BEFORE believed: unsigned, mis-signed, malformed and replayed are all refused.
	# Answers [ accepted, status, reason, events ]: status is what the callback owes the hub.
	def ReceiveWebhook(pcBody, pcSignature)
		if NOT isString(pcSignature) or pcSignature = ""
			return This._Refuse("unsigned")
		ok
		_bSigned_ = 0
		for _i_ = 1 to ring_len($aPaySecrets)
			if $aPaySecrets[_i_][1] = @nId and _StzPaySecureEq(pcSignature, StzWebhookSignature(pcBody, $aPaySecrets[_i_][2]))
				_bSigned_ = 1
				exit
			ok
		next
		if _bSigned_ = 0
			return This._Refuse("bad-signature")
		ok
		if NOT StzJsonIsValid(pcBody)
			return This._Refuse("malformed")
		ok
		_a_ = StzJsonToList(pcBody)
		_aData_ = _StzPiGet(_a_, "data", [])
		if NOT isList(_aData_) or ring_len(_aData_) = 0
			return This._Refuse("malformed")
		ok
		# a replay is an event already seen: same end2endId, same code, same date
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
			return This._Refuse("replay")
		ok
		return [ [ "accepted", 1 ], [ "status", 204 ], [ "reason", "" ], [ "events", _aNew_ ] ]

	def RefusedWebhooks()
		_a_ = []
		for _i_ = 1 to ring_len($aPayRefused)
			if $aPayRefused[_i_][1] = @nId
				_a_ + $aPayRefused[_i_][2]
			ok
		next
		return _a_

	# every event the port has accepted, oldest first
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
