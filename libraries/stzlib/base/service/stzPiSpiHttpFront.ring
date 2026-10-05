#================================================================#
#  STZPISPIHTTPFRONT -- the twin of the hub, served over HTTP (PY5a)   #
#================================================================#

/*--- A participant's API Business that you can run on your own machine.

The twin answers the contract in-process through ONE method, Request(). This puts that method
behind stzAppServer and adds what a participant puts in front of it, so the live adapter has
something real to talk to, and a platform can develop against a URL:

    oFront = StzPiSpiHttpFrontQ()
    oFront.WithCredentials("diko-client", "diko-secret", "diko-api-key")   # test values the caller generates
    oFront.WithScopePrefix("piz/")
    oFront.EnableControl()                       # /_twin/..., for tests; loopback only
    oFront.Start(8443, "127.0.0.1")              # or StartTls(...) for mutual TLS
    oFront.RunFor(60000)

WHAT IT ENFORCES, as the reference describes a participant
  * POST /oauth/token, OAuth 2.0 client credentials: the client id and secret must match, and a
    token carries the scopes that were asked for, a lifetime, and a number
  * every API call needs `Authorization: Bearer <token>` and `x-api-key`, an unexpired token that has
    not been revoked, and the SCOPE its operation needs (compte.read, paiement.write, retour_fonds.write...,
    prefixed in the BCEAO's sandbox). Anything else is the reference's 401 problem
  * the business API is the twin's, unchanged: payments, requests, returns, cancellations, bulk,
    accounts, aliases, webhooks, paging, filters, RFC 7807 errors, the quota

OVER MUTUAL TLS (StartTls with a CA and RequireClient), a client that presents no certificate gets
no response at all. The certificate-bound token of the real hub (a token taken under one
certificate refused under another) is NOT modelled: the engine does not expose the peer certificate
to a handler, and that is said here rather than implied.

THE CONTROL SURFACE, /_twin/..., exists only after EnableControl() and is for a test to drive the
twin that is behind the wire: advance its clock, settle what is pending, make a customer pay or ask
or cancel, change how a customer's side answers, read the signed webhooks it queued, change the
token lifetime, revoke tokens, read the counters. A server that holds real money never enables it.

All state is process-global, because a named handler function is what stzAppServer calls and a
closure cannot hold an object; one front per process.
*/

$aPiFront = [ [ "hub", 0 ], [ "clientId", "" ], [ "clientSecret", "" ], [ "apiKey", "" ], [ "prefix", "" ],
	[ "ttl", 3600 ], [ "control", 0 ], [ "issued", 0 ], [ "served", 0 ], [ "refused", 0 ], [ "base", "/piz/v1" ] ]
$aPiFrontTokens = []       # [ token, scopesText, expiresAtMs, revoked ]

func StzPiSpiHttpFrontQ()
	return new stzPiSpiHttpFront()

# the scope an operation needs, from the reference's OAuth2 scheme; "" for an unknown route
func _StzPiScopeFor(pcMethod, paSeg)
	_n_ = len(paSeg)
	if _n_ = 0
		return ""
	ok
	_r_ = lower(paSeg[1])
	_m_ = upper(pcMethod)
	_w_ = 0
	if _m_ != "GET"
		_w_ = 1
	ok
	if _r_ = "comptes"
		if _n_ >= 2 and lower(paSeg[2]) = "transactions"
			if _w_
				return "compte_transaction.write"
			ok
			return "compte_transaction.read"
		ok
		if _n_ >= 3 and lower(paSeg[3]) = "alias"
			if _m_ = "DELETE"
				return "alias.delete"
			ok
			if _w_
				return "alias.write"
			ok
			return "alias.read"
		ok
		return "compte.read"
	ok
	if _r_ = "alias"
		return "enrolement_alias.read"
	ok
	if _r_ = "participants"
		return "participant.read"
	ok
	if _r_ = "webhooks"
		if _m_ = "DELETE"
			return "webhook.delete"
		ok
		if _w_
			return "webhook.write"
		ok
		return "webhook.read"
	ok
	if _r_ = "demandes-paiements"
		if _w_
			return "demande_paiement.write"
		ok
		return "demande_paiement.read"
	ok
	if _r_ = "demandes-paiements-recues"
		if _w_
			return "demande_paiement_reponse.write"
		ok
		return "demande_paiement.read"
	ok
	if _r_ = "demandes-paiements-groupes"
		if _w_
			return "demande_paiement_groupe.write"
		ok
		return "demande_paiement_groupe.read"
	ok
	if _r_ = "paiements-envoyes" or _r_ = "paiements-recus"
		if _w_
			return "paiement.write"
		ok
		return "paiement.read"
	ok
	if _r_ = "paiements-groupes"
		if _w_
			return "paiement_groupe.write"
		ok
		return "paiement_groupe.read"
	ok
	if _r_ = "paiements"
		if _n_ >= 3 and lower(paSeg[3]) = "retours"
			return "retour_fonds.write"
		ok
		if _n_ >= 3 and lower(paSeg[3]) = "annulations"
			if _n_ >= 4
				return "demande_annulation_reponse.write"
			ok
			return "demande_annulation.write"
		ok
		return "paiement.read"
	ok
	return ""

func _StzPiFrontGet(pcKey)
	return _StzPiGet($aPiFront, pcKey, "")

func _StzPiFrontSet(pcKey, pxVal)
	$aPiFront[pcKey] = pxVal

func _StzPiStatusText(n)
	if n = 200  return "OK"  ok
	if n = 201  return "Created"  ok
	if n = 202  return "Accepted"  ok
	if n = 204  return "No Content"  ok
	if n = 400  return "Bad Request"  ok
	if n = 401  return "Unauthorized"  ok
	if n = 403  return "Forbidden"  ok
	if n = 404  return "Not Found"  ok
	if n = 409  return "Conflict"  ok
	if n = 429  return "Too Many Requests"  ok
	return "Error"

func _StzPiFrontReply(poResp, pnStatus, pxBody)
	poResp.Status(pnStatus, _StzPiStatusText(pnStatus))
	if pnStatus = 204 or NOT isList(pxBody) or len(pxBody) = 0
		poResp.Send("")
		return
	ok
	if pnStatus >= 400
		poResp.Header("Content-Type", "application/problem+json")
	else
		poResp.Header("Content-Type", "application/json")
	ok
	poResp.Send(StzPispiJson(pxBody))

func _StzPiFrontProblem(poResp, pnStatus, pcDetail)
	_a_ = _StzPiProblem(pnStatus, pcDetail, [])
	_StzPiFrontReply(poResp, pnStatus, _a_[2])

# the form body of a token request: [ [ key, value ], ... ], decoded
func _StzPiFormPairs(pcBody)
	_aOut_ = []
	_a_ = split(pcBody, "&")
	for _i_ = 1 to len(_a_)
		_p_ = StzFindFirst("=", _a_[_i_])
		if _p_ > 0
			_aOut_ + [ _StzPiPctDecode(StzLeft(_a_[_i_], _p_ - 1)), _StzPiPctDecode(StzMidToEnd(_a_[_i_], _p_ + 1)) ]
		ok
	next
	return _aOut_

func _StzPiFrontToken(poReq, poResp)
	_aF_ = _StzPiFormPairs(poReq.Body())
	if _StzPiGet(_aF_, "grant_type", "") != "client_credentials"
		_StzPiFrontProblem(poResp, 400, "grant_type must be client_credentials")
		return
	ok
	if _StzPiGet(_aF_, "client_id", "") != _StzPiFrontGet("clientId") or
	   _StzPiGet(_aF_, "client_secret", "") != _StzPiFrontGet("clientSecret")
		_StzPiFrontSet("refused", _StzPiFrontGet("refused") + 1)
		_StzPiFrontProblem(poResp, 401, "invalid client credentials")
		return
	ok
	_cScope_ = "" + _StzPiGet(_aF_, "scope", "")
	_n_ = _StzPiFrontGet("issued") + 1
	_StzPiFrontSet("issued", _n_)
	_cTok_ = "tok-" + _n_ + "-" + StzEngineCryptoRandomHex(8)
	_nTtl_ = _StzPiFrontGet("ttl")
	$aPiFrontTokens + [ _cTok_, _cScope_, StzEngineTimeNowMs() + _nTtl_ * 1000, 0 ]
	_StzPiFrontReply(poResp, 200, [ [ "access_token", _cTok_ ], [ "token_type", "Bearer" ], [ "expires_in", _nTtl_ ],
		[ "scope", _cScope_ ] ])

# the token's row, or 0 when it is unknown, expired or revoked
func _StzPiFrontTokenRow(pcToken)
	for _i_ = 1 to len($aPiFrontTokens)
		if $aPiFrontTokens[_i_][1] = pcToken
			if $aPiFrontTokens[_i_][4] = 1 or StzEngineTimeNowMs() >= $aPiFrontTokens[_i_][3]
				return 0
			ok
			return _i_
		ok
	next
	return 0

# THE HANDLER every method and path comes to
func StzPiFrontHandle(poReq, poResp)
	_cPath_ = poReq.Path()
	_cM_ = upper(poReq.Method())
	if _cPath_ = "/oauth/token" and _cM_ = "POST"
		_StzPiFrontToken(poReq, poResp)
		return
	ok
	if StzLeft(_cPath_, 7) = "/_twin/"
		if _StzPiFrontGet("control") != 1
			_StzPiFrontProblem(poResp, 404, "no such route")
			return
		ok
		_StzPiFrontControl(poReq, poResp, StzMidToEnd(_cPath_, 8))
		return
	ok
	_cBase_ = _StzPiFrontGet("base")
	if StzLeft(_cPath_, len(_cBase_)) != _cBase_
		_StzPiFrontProblem(poResp, 404, "no such route")
		return
	ok
	_cApi_ = StzMidToEnd(_cPath_, len(_cBase_) + 1)
	_aSeg_ = _StzPiSegments(_cApi_)

	# the transport gate: API key, then a live token, then the scope the operation needs
	if poReq.Header("x-api-key") != _StzPiFrontGet("apiKey") or _StzPiFrontGet("apiKey") = ""
		_StzPiFrontSet("refused", _StzPiFrontGet("refused") + 1)
		_StzPiFrontProblem(poResp, 401, "Autorisations insuffisantes")
		return
	ok
	_cAuth_ = poReq.Header("Authorization")
	_cTok_ = ""
	if lower(StzLeft(_cAuth_, 7)) = "bearer "
		_cTok_ = StzMidToEnd(_cAuth_, 8)
	ok
	_k_ = _StzPiFrontTokenRow(_cTok_)
	if _k_ = 0
		_StzPiFrontSet("refused", _StzPiFrontGet("refused") + 1)
		_StzPiFrontProblem(poResp, 401, "Autorisations insuffisantes")
		return
	ok
	_cNeed_ = _StzPiScopeFor(_cM_, _aSeg_)
	if _cNeed_ != ""
		_cHas_ = " " + $aPiFrontTokens[_k_][2] + " "
		if StzFindFirst(" " + _StzPiFrontGet("prefix") + _cNeed_ + " ", _cHas_) = 0
			_StzPiFrontSet("refused", _StzPiFrontGet("refused") + 1)
			_StzPiFrontProblem(poResp, 401, "Autorisations insuffisantes: le scope " + _cNeed_ + " est requis")
			return
		ok
	ok

	# through the twin
	_aQ_ = []
	_aRaw_ = poReq.Query("")
	for _i_ = 1 to len(_aRaw_)
		_aQ_ + [ _StzPiPctDecode(_aRaw_[_i_][1]), _StzPiPctDecode(_aRaw_[_i_][2]) ]
	next
	_aBody_ = []
	if poReq.Body() != "" and StzJsonIsValid(poReq.Body())
		_aBody_ = StzJsonToList(poReq.Body())
	ok
	_oHub_ = new stzPiSpiSandbox()
	_oHub_.AdoptHub(_StzPiFrontGet("hub"))
	_aR_ = _oHub_.Request(_cM_, _cApi_, _aQ_, _aBody_)
	_StzPiFrontSet("served", _StzPiFrontGet("served") + 1)
	_StzPiFrontReply(poResp, _aR_[1], _aR_[2])

func _StzPiFrontHub()
	_oH_ = new stzPiSpiSandbox()
	_oH_.AdoptHub(_StzPiFrontGet("hub"))
	return _oH_

# /_twin/<verb>: the control surface a test uses to drive the twin behind the wire
func _StzPiFrontControl(poReq, poResp, pcVerb)
	_oHub_ = _StzPiFrontHub()
	_aB_ = []
	if poReq.Body() != "" and StzJsonIsValid(poReq.Body())
		_aB_ = StzJsonToList(poReq.Body())
	ok
	if pcVerb = "advance"
		_oHub_.AdvanceSeconds(ring_number("" + _StzPiGet(_aB_, "seconds", 0)))
		_StzPiFrontReply(poResp, 200, [ [ "now", _oHub_.Now() ] ])
		return
	ok
	if pcVerb = "settle"
		_oHub_.SettleEverything()
		_StzPiFrontReply(poResp, 200, [ [ "now", _oHub_.Now() ] ])
		return
	ok
	if pcVerb = "incoming-payment"
		_e_ = _oHub_.SimulateIncomingPayment(_StzPiGet(_aB_, "who", ""), ring_number("" + _StzPiGet(_aB_, "amount", 0)), "" + _StzPiGet(_aB_, "motif", ""))
		_StzPiFrontReply(poResp, 200, [ [ "end2endId", _e_ ] ])
		return
	ok
	if pcVerb = "incoming-request"
		_e_ = _oHub_.SimulateIncomingRequest(_StzPiGet(_aB_, "who", ""), ring_number("" + _StzPiGet(_aB_, "amount", 0)), "" + _StzPiGet(_aB_, "motif", ""))
		_StzPiFrontReply(poResp, 200, [ [ "end2endId", _e_ ] ])
		return
	ok
	if pcVerb = "cancellation-request"
		_oHub_.SimulateCancellationRequest("" + _StzPiGet(_aB_, "end2endId", ""), "" + _StzPiGet(_aB_, "motif", ""))
		_StzPiFrontReply(poResp, 200, [ [ "ok", 1 ] ])
		return
	ok
	if pcVerb = "fail-next-answer"
		_oHub_.FailNextAnswer()
		_StzPiFrontReply(poResp, 200, [ [ "ok", 1 ] ])
		return
	ok
	if pcVerb = "rate-limit"
		_oHub_.SetRateLimit(ring_number("" + _StzPiGet(_aB_, "perMin", 100)), ring_number("" + _StzPiGet(_aB_, "perDay", 10000)))
		_StzPiFrontReply(poResp, 200, [ [ "ok", 1 ] ])
		return
	ok
	if pcVerb = "counterparty"
		_oHub_.SetCounterparty(_StzPiGet(_aB_, "who", ""), _StzPiGet(_aB_, "pay", "ok"), _StzPiGet(_aB_, "rtp", "pay"), _StzPiGet(_aB_, "cancel", "accept"))
		_StzPiFrontReply(poResp, 200, [ [ "ok", 1 ] ])
		return
	ok
	if pcVerb = "state"
		_StzPiFrontReply(poResp, 200, [ [ "now", _oHub_.Now() ], [ "balance", _oHub_.Balance() ],
			[ "deliveries", _oHub_.NumberOfDeliveries() ], [ "undelivered", _oHub_.NumberOfUndelivered() ],
			[ "tokensIssued", _StzPiFrontGet("issued") ], [ "served", _StzPiFrontGet("served") ],
			[ "refused", _StzPiFrontGet("refused") ] ])
		return
	ok
	if pcVerb = "deliveries"
		_a_ = _oHub_.TakeUndelivered()
		_StzPiFrontReply(poResp, 200, [ [ "data", _a_ ] ])
		return
	ok
	if pcVerb = "alias"
		_StzPiFrontReply(poResp, 200, [ [ "business", _oHub_.BusinessAlias() ], [ "fatou", _oHub_.Alias("fatou") ],
			[ "kdi", _oHub_.Alias("kdi") ], [ "boutique", _oHub_.Alias("boutique") ], [ "blocked", _oHub_.Alias("blocked") ],
			[ "stubborn", _oHub_.Alias("stubborn") ], [ "account", _oHub_.BusinessAccount() ] ])
		return
	ok
	if pcVerb = "token-ttl"
		_StzPiFrontSet("ttl", ring_number("" + _StzPiGet(_aB_, "seconds", 3600)))
		_StzPiFrontReply(poResp, 200, [ [ "ttl", _StzPiFrontGet("ttl") ] ])
		return
	ok
	if pcVerb = "revoke-tokens"
		for _i_ = 1 to len($aPiFrontTokens)
			$aPiFrontTokens[_i_][4] = 1
		next
		_StzPiFrontReply(poResp, 200, [ [ "ok", 1 ] ])
		return
	ok
	_StzPiFrontProblem(poResp, 404, "no such control verb: " + pcVerb)


  #=================#
 #  THE FRONT      #
#=================#

class stzPiSpiHttpFront from stzObject

	@oServer = ""

	def init()
		_oHub_ = new stzPiSpiSandbox()
		$aPiFront["hub"] = _oHub_.Id()
		@oServer = new stzAppServer()
		@oServer.Get_("/*", "StzPiFrontHandle")
		@oServer.Post("/*", "StzPiFrontHandle")
		@oServer.Put_("/*", "StzPiFrontHandle")
		@oServer.Delete("/*", "StzPiFrontHandle")

	def WithCredentials(pcClientId, pcClientSecret, pcApiKey)
		$aPiFront["clientId"] = "" + pcClientId
		$aPiFront["clientSecret"] = "" + pcClientSecret
		$aPiFront["apiKey"] = "" + pcApiKey
		return This

	def WithScopePrefix(pcPrefix)
		$aPiFront["prefix"] = "" + pcPrefix
		return This

	def WithBasePath(pcBase)
		$aPiFront["base"] = "" + pcBase
		return This

	def WithTokenLifetime(pnSeconds)
		$aPiFront["ttl"] = pnSeconds
		return This

	def EnableControl()
		$aPiFront["control"] = 1
		return This

	# the twin behind it, for a caller in the same process
	def Hub()
		_oH_ = new stzPiSpiSandbox()
		_oH_.AdoptHub($aPiFront["hub"])
		return _oH_

	def Start(pnPort, pcHost)
		return @oServer.Start(pnPort, pcHost)

	# one-way or MUTUAL TLS: a non-empty CA turns on client-certificate checks, pbRequireClient demands one
	def StartTls(pnPort, pcHost, pcCert, pcKey, pcCa, pbRequireClient)
		return @oServer.StartTls(pnPort, pcHost, pcCert, pcKey, pcCa, pbRequireClient)

	def Port()
		return @oServer.Port()

	def RunFor(pnMs)
		@oServer.RunFor(pnMs)
		return This

	def Stop()
		@oServer.Stop()
		return This
