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

# Serves the twin of the PI-SPI hub over HTTP, with a token endpoint, an API key and scopes, so a live adapter has a real server to talk to.
#
# UNPERCEIVED, the live adapter this front exists to test. stzPispiHttpAdapter is proven against
# this twin over real HTTP, plain and with mutual TLS, and has NOT been run against the BCEAO's
# sandbox: a green run against the front says the adapter and the twin agree, not that a
# participant's hub agrees, and no payment made through the adapter has been watched landing in a
# real dashboard. The front puts the twin's single Request() behind an application server and adds
# what a participant puts in front of the contract: an OAuth2 client-credentials token endpoint, an
# x-api-key, a scope for each operation, and optional mutual TLS. It moves no money, the twin holds
# virtual francs. The token is not bound to the certificate it was taken under, which the real hub's
# is, because the engine does not show the peer certificate to a handler. EnableControl adds /_twin/
# routes for a test, with no credential asked. All its state is process-wide, so run one front per
# process, and run it in a process of its own since RunFor blocks its caller.
#
#   receiver   o1 = new stzPiSpiHttpFront()
#   example    ? o1.Hub().Balance()
#              #--> 50000000
#              ? o1.Hub().IsSandbox()
#              #--> 1
#   see        stzPispiHttpAdapter, stzPiSpiSandbox, stzAppServer
class stzPiSpiHttpFront from stzObject

	@oServer = ""

	# Builds a front over a new twin hub, with an application server that routes every GET, POST, PUT and DELETE path to the contract handler.
	#
	#   returns    nothing; the object is built
	#   note       it moves no money, the twin holds virtual francs
	#   warning    the front keeps its settings and its tokens in process-wide tables, so a second
	#              front in the same process shares the first one's credentials and counters and
	#              only takes over the hub; run one front per process, which is read from the code
	#              and not run
	#   see        WithCredentials, Start, Hub
	def init()
		_oHub_ = new stzPiSpiSandbox()
		$aPiFront["hub"] = _oHub_.Id()
		@oServer = new stzAppServer()
		@oServer.Get_("/*", "StzPiFrontHandle")
		@oServer.Post("/*", "StzPiFrontHandle")
		@oServer.Put_("/*", "StzPiFrontHandle")
		@oServer.Delete("/*", "StzPiFrontHandle")

	# Sets the OAuth client and the API key the front demands before it serves a call.
	#
	#   pcClientId       the client id the token endpoint accepts
	#   pcClientSecret   the client secret it accepts
	#   pcApiKey         the key every API call must send in x-api-key
	#   returns          the front itself, so calls chain
	#   note             the values are test values the caller generates, never a participant's
	#                    credentials
	#   warning          with no API key set every API call is refused with a 401 problem
	#   see              WithScopePrefix, Start
	def WithCredentials(pcClientId, pcClientSecret, pcApiKey)
		$aPiFront["clientId"] = "" + pcClientId
		$aPiFront["clientSecret"] = "" + pcClientSecret
		$aPiFront["apiKey"] = "" + pcApiKey
		return This

	# Sets the text that every scope of a token must carry, which is piz/ in the BCEAO's sandbox.
	#
	#   pcPrefix   the text such as piz/, an empty text for none
	#   returns    the front itself, so calls chain
	#   warning    a call whose token lacks the prefixed scope its operation needs is refused with a
	#              401 problem naming the scope
	#   see        WithCredentials, WithBasePath
	def WithScopePrefix(pcPrefix)
		$aPiFront["prefix"] = "" + pcPrefix
		return This

	# Sets the path under which the contract is served, /piz/v1 unless changed.
	#
	#   pcBase     the path prefix such as /piz/v1
	#   returns    the front itself, so calls chain
	#   warning    any other path, apart from the token endpoint and the control routes, answers a
	#              404 problem
	#   see        WithScopePrefix, Start
	def WithBasePath(pcBase)
		$aPiFront["base"] = "" + pcBase
		return This

	# Sets how many seconds a token issued from now on stays valid, 3600 unless changed.
	#
	#   pnSeconds   the lifetime in seconds, which the token response reports as expires_in
	#   returns     the front itself, so calls chain
	#   warning     the adapter refreshes a token a minute before it lapses, so a lifetime under a
	#               minute makes it fetch one for every call
	#   see         WithCredentials, EnableControl
	def WithTokenLifetime(pnSeconds)
		$aPiFront["ttl"] = pnSeconds
		return This

	# Turns on the /_twin/ routes with which a test drives the twin behind the wire.
	#
	#   returns    the front itself, so calls chain
	#   note       they advance the clock, settle what is pending, make a customer pay, ask or
	#              cancel, change how a customer answers, read the queued webhooks and the counters;
	#              a server that holds real money never enables them
	#   warning    those routes ask for no credential at all, so anyone who can reach the port can
	#              advance the clock, make the twin pay or ask, and revoke tokens, and loopback only
	#              is a matter of the host given to Start and is not enforced here
	#   see        Hub, Start
	def EnableControl()
		$aPiFront["control"] = 1
		return This

	# Returns a face onto the twin the front serves, for a caller in the same process.
	#
	#   returns    an stzPiSpiSandbox on the same hub
	#   warning    the face shares its state with the served twin, so a payment made through it is
	#              seen over HTTP
	#   see        stzPiSpiSandbox, Start
	#@ aka  the twin behind it, for a caller in the same process
	def Hub()
		_oH_ = new stzPiSpiSandbox()
		_oH_.AdoptHub($aPiFront["hub"])
		return _oH_

	# Binds the front to a port and an address and returns 1, without serving anything until RunFor is called.
	#
	#   pnPort     the port to listen on, 0 for any free one
	#   pcHost     the address to bind, an empty text meaning 127.0.0.1
	#   returns    1
	#   note       UNPERCEIVED, for the live adapter this front is built to serve:
	#              stzPispiHttpAdapter is proven against this twin over real HTTP and has NOT been
	#              run against the BCEAO's sandbox, so a green run here says the adapter and the
	#              twin agree, not that a participant's hub agrees
	#   warning    raises an error when the port cannot be bound or the front already runs
	#   see        Port, RunFor, Stop, StartTls
	def Start(pnPort, pcHost)
		return @oServer.Start(pnPort, pcHost)

	# Binds the front to a port and an address behind TLS, with mutual TLS when a CA is given, and returns 1.
	#
	#   pnPort            the port to listen on, 0 for any free one
	#   pcHost            the address to bind, an empty text meaning 127.0.0.1
	#   pcCert            the server certificate PEM file
	#   pcKey             the server private key PEM file
	#   pcCa              the CA PEM file that checks client certificates, an empty text for none
	#   pbRequireClient   TRUE to demand a client certificate, so that a client without one gets no
	#                     response at all
	#   returns           1
	#   note              UNPERCEIVED: mutual TLS is proven only between the adapter and this twin
	#                     with the engine's throwaway test certificates, never against the BCEAO's
	#                     sandbox or a participant
	#   warning           raises an error for a certificate, key or CA file that cannot be used,
	#                     naming the code -13, -14 or -17; the token is not bound to the certificate
	#                     it was fetched under, as the real hub's is, because the engine does not
	#                     show the peer certificate to a handler
	#   see               Start, Port, RunFor
	#@ aka  one-way or MUTUAL TLS: a non-empty CA turns on client-certificate checks, pbRequireClient demands one
	def StartTls(pnPort, pcHost, pcCert, pcKey, pcCa, pbRequireClient)
		return @oServer.StartTls(pnPort, pcHost, pcCert, pcKey, pcCa, pbRequireClient)

	# Returns the port the front listens on, the real one when 0 was asked for.
	#
	#   returns    a number, 0 before the first start
	#   see        Start, StartTls
	def Port()
		return @oServer.Port()

	# Serves requests for the given time and then returns, the call that makes the front answer.
	#
	#   pnMs       how long to serve, in milliseconds
	#   returns    the front itself, so calls chain
	#   warning    it blocks its caller, so an adapter running in the same process cannot be served:
	#              run the front in a process of its own, as the library's live-adapter guard does
	#   see        Start, Stop
	def RunFor(pnMs)
		@oServer.RunFor(pnMs)
		return This

	# Closes the listener and keeps the routes for a later start.
	#
	#   returns    the front itself, so calls chain
	#   warning    a front that is not running is left as it is
	#   see        Start, RunFor
	def Stop()
		@oServer.Stop()
		return This
