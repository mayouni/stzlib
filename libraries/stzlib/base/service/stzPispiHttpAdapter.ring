#================================================================#
#  STZPISPIHTTPADAPTER -- the live adapter of the PI-SPI port (PY5)    #
#================================================================#

/*--- The same contract as the twin, over HTTP, for any participant.

The port speaks verbs to a BACKEND with one method, Request(method, path, query, body) ->
[ status, body ] (see stzPaymentsPort.ring). The twin is one backend, in-process. This is the
other: it carries the same four things over the wire to a participant's API Business, and the
port cannot tell them apart.

    oAd = StzPispiHttpAdapterQ()
    oAd.WithParticipant("bia")
    oAd.WithBaseUrl("https://api.example-bank.ne/piz/v1")
    oAd.WithSecretsFrom(oStore, oActor)           # client, API key: through the governed door
    oAd.WithCertificateFrom(oStore)               # mTLS: descriptors that point at PEM files
    oAd.AsLive()
    oPay = StzPaymentsPortQ(oAd)

It is GENERIC OVER THE PARTICIPANT: the base URL is configuration, the contract is the BCEAO's,
and nothing here names a bank. It promises no homologation (ruling 13): which participant's API
is homologated is the BCEAO's list, and BIA Niger's is the first one this was built for.

WHAT IT DOES FOR EVERY CALL
  * OAUTH 2.0 CLIENT CREDENTIALS. POST to the token URL with grant_type, client_id, client_secret
    and the scopes it was configured with (prefixed, "piz/", in the BCEAO's sandbox). The token is
    cached for the process and refreshed a minute before it lapses; a 401 on a call drops it and
    retries ONCE with a fresh one, because a revoked token and a stale one look the same.
  * THE API KEY, in x-api-key, on every call.
  * mTLS, when the participant requires it (production): the client certificate and key are PEM
    FILES the engine reads; the descriptor in the secret store carries the PATH (a file-sourced
    secret), so the private key never enters Ring. It goes through stzReactor.TlsRequest, the
    mbedTLS client of MTLS_PLAN slice 3. stzHttpClient.SetClientCert cannot do this on Windows
    (Schannel wants a certificate-store reference, not a PEM): measured 2026-10-05, code -1.
  * JSON, schema-aware: ListToJson turns [] into {} and a one-pair array into an object, so the
    body is written by a small encoder that knows which keys are arrays (transactions, events)
    and which are booleans (confirmation, decision, programme), and 1/0 become true/false.
  * PAGING AND FILTERS: the query is a list of [ "montant[gte]", "4000" ] pairs, percent-encoded
    where the wire needs it and not on the brackets the reference uses.
  * ERRORS: an RFC 7807 problem comes back as the same [ status, problem ] the twin gives, so the
    port raises the same stzPaymentsProblem. A transport failure (no response) is NOT a problem
    the hub gave: it RAISES a "transport" error, and the port journals the txId so a retry READS
    the payment before it sends it again.

THE LIMITS OF THE ENGINE'S TLS CLIENT, which this adapter handles: one request per connection, a
response framed by Content-Length or read until the peer closes (2 s idle), a 4 MB response cap,
so a CHUNKED body arrives with its chunk markers and is decoded here.

STAGE AND PERCEPTION. Against the twin served over HTTP (stzPiSpiHttpFront) this is proven by
payments_live_adapter_narrated. Against the BCEAO's sandbox under DIKO's account it has NOT been
run, and says UNPERCEIVED until a named person has watched a payment land in the sandbox
dashboard. Against BIA in production it is never run from this plane.
*/

$aPiTokens = []            # [ adapterId, token, expiresAtMs, fetched ]
$nPiAdapterSeq = 0
$oPiTlsReactor = ""        # one client reactor for the process, made on first use
$aPayWebhookRoutes = []    # [ path, oPort ]

func StzPispiHttpAdapterQ()
	return new stzPispiHttpAdapter()

# the BCEAO's scopes, each operation's own (the reference's OAuth2 scheme)
func StzPispiAllScopes()
	return [ "compte.read", "compte_transaction.write", "compte_transaction.read", "alias.write", "alias.read",
		"alias.delete", "enrolement_alias.read", "participant.read", "webhook.read", "webhook.write",
		"webhook.delete", "demande_paiement.write", "demande_paiement.read", "demande_paiement_reponse.write",
		"demande_paiement_groupe.write", "demande_paiement_groupe.read", "paiement.write", "paiement.read",
		"paiement_groupe.write", "paiement_groupe.read", "retour_fonds.write", "demande_annulation.write",
		"demande_annulation_reponse.write" ]

#---------------------------------------------------------------------#
#  the wire codec                                                      #
#---------------------------------------------------------------------#

# percent-encode what the wire needs; brackets, commas and colons stay, as the reference writes them
func _StzPiPctEncode(pc)
	_cOut_ = ""
	_n_ = len(pc)
	for _i_ = 1 to _n_
		_c_ = pc[_i_]
		_b_ = ascii(_c_)
		if ( _b_ >= 48 and _b_ <= 57 ) or ( _b_ >= 65 and _b_ <= 90 ) or ( _b_ >= 97 and _b_ <= 122 ) or
		   _c_ = "-" or _c_ = "." or _c_ = "_" or _c_ = "~" or _c_ = "[" or _c_ = "]" or _c_ = "," or _c_ = ":"
			_cOut_ += _c_
		else
			_h_ = StzEngineCryptoHexEncode(_c_)
			_cOut_ += "%" + upper(_h_)
		ok
	next
	return _cOut_

func _StzPiPctDecode(pc)
	_cOut_ = ""
	_n_ = len(pc)
	_i_ = 1
	while _i_ <= _n_
		_c_ = pc[_i_]
		if _c_ = "%" and _i_ + 2 <= _n_
			_cOut_ += StzEngineCryptoHexDecode(pc[_i_ + 1] + pc[_i_ + 2])
			_i_ = _i_ + 3
		else
			_cOut_ += _c_
			_i_++
		ok
	end
	return _cOut_

func _StzPiJsonStr(pc)
	_cOut_ = '"'
	_n_ = len(pc)
	for _i_ = 1 to _n_
		_c_ = pc[_i_]
		_b_ = ascii(_c_)
		if _c_ = '"'
			_cOut_ += '\"'
		but _c_ = "\"
			_cOut_ += "\\"
		but _b_ = 10
			_cOut_ += "\n"
		but _b_ = 13
			_cOut_ += "\r"
		but _b_ = 9
			_cOut_ += "\t"
		but _b_ < 32
			_cOut_ += " "
		else
			_cOut_ += _c_
		ok
	next
	return _cOut_ + '"'

func _StzPiIsPairs(pa)
	if NOT isList(pa) or len(pa) = 0
		return 0
	ok
	for _i_ = 1 to len(pa)
		if NOT isList(pa[_i_]) or len(pa[_i_]) != 2 or NOT isString(pa[_i_][1])
			return 0
		ok
	next
	return 1

func _StzPiIsArrayKey(pcKey)
	_k_ = lower(pcKey)
	return _k_ = "data" or _k_ = "events" or _k_ = "transactions" or _k_ = "invalid-params"

func _StzPiIsBoolKey(pcKey)
	_k_ = lower(pcKey)
	return _k_ = "confirmation" or _k_ = "decision" or _k_ = "programme" or _k_ = "debitdiffere"

# a Ring value as JSON text. pbArray says the list under it is an ARRAY (the key's hint).
func _StzPiJsonOf(pxValue, pbArray, pcKey)
	if isNumber(pxValue)
		if _StzPiIsBoolKey(pcKey)
			if pxValue = 0
				return "false"
			ok
			return "true"
		ok
		return "" + pxValue
	ok
	if isString(pxValue)
		return _StzPiJsonStr(pxValue)
	ok
	if NOT isList(pxValue)
		return "null"
	ok
	if len(pxValue) = 0
		if pbArray
			return "[]"
		ok
		return "{}"
	ok
	if _StzPiIsPairs(pxValue) and NOT pbArray
		_c_ = "{"
		for _i_ = 1 to len(pxValue)
			if _i_ > 1
				_c_ += ","
			ok
			_k_ = pxValue[_i_][1]
			_c_ += _StzPiJsonStr(_k_) + ":" + _StzPiJsonOf(pxValue[_i_][2], _StzPiIsArrayKey(_k_), _k_)
		next
		return _c_ + "}"
	ok
	_c_ = "["
	for _i_ = 1 to len(pxValue)
		if _i_ > 1
			_c_ += ","
		ok
		_c_ += _StzPiJsonOf(pxValue[_i_], 0, "")
	next
	return _c_ + "]"

func StzPispiJson(paBody)
	if NOT isList(paBody) or len(paBody) = 0
		return ""
	ok
	return _StzPiJsonOf(paBody, 0, "")

# "HTTP/1.1 200 OK" ... headers ... body, as the engine's TLS client returns it: [ status, headersText, body ]
func _StzPiParseHttp(pcRaw)
	_p_ = StzFindFirst(char(13) + char(10) + char(13) + char(10), pcRaw)
	if _p_ = 0
		return [ 0, "", "" ]
	ok
	_cHead_ = StzLeft(pcRaw, _p_ - 1)
	_cBody_ = StzMidToEnd(pcRaw, _p_ + 4)
	_nSp_ = StzFindFirst(" ", _cHead_)
	_nStatus_ = ring_number(StzMid(_cHead_, _nSp_ + 1, 3))
	if StzFindFirst("transfer-encoding: chunked", lower(_cHead_)) > 0
		_cBody_ = _StzPiDechunk(_cBody_)
	ok
	return [ _nStatus_, _cHead_, _cBody_ ]

func _StzPiDechunk(pc)
	_cOut_ = ""
	_p_ = 1
	_n_ = len(pc)
	while _p_ <= _n_
		_e_ = StzFindFirst(char(13) + char(10), StzMidToEnd(pc, _p_))
		if _e_ = 0
			exit
		ok
		_cSize_ = ring_trim(StzMid(pc, _p_, _e_ - 1))
		_sc_ = StzFindFirst(";", _cSize_)
		if _sc_ > 0
			_cSize_ = StzLeft(_cSize_, _sc_ - 1)
		ok
		_nSize_ = StzHexToNumber(_cSize_)
		if _nSize_ <= 0
			exit
		ok
		_cOut_ += StzMid(pc, _p_ + _e_ + 1, _nSize_)
		_p_ = _p_ + _e_ + 1 + _nSize_ + 2
	end
	return _cOut_

func StzHexToNumber(pcHex)
	_n_ = 0
	for _i_ = 1 to len(pcHex)
		_b_ = ascii(lower(pcHex[_i_]))
		if _b_ >= 48 and _b_ <= 57
			_n_ = _n_ * 16 + (_b_ - 48)
		but _b_ >= 97 and _b_ <= 102
			_n_ = _n_ * 16 + (_b_ - 87)
		else
			return -1
		ok
	next
	return _n_

# scheme, host, port, path from "https://host:8443/a/b"
func _StzPiSplitUrl(pcUrl)
	_cScheme_ = "http"
	_c_ = pcUrl
	_p_ = StzFindFirst("://", _c_)
	if _p_ > 0
		_cScheme_ = lower(StzLeft(_c_, _p_ - 1))
		_c_ = StzMidToEnd(_c_, _p_ + 3)
	ok
	_cPath_ = ""
	_s_ = StzFindFirst("/", _c_)
	if _s_ > 0
		_cPath_ = StzMidToEnd(_c_, _s_)
		_c_ = StzLeft(_c_, _s_ - 1)
	ok
	_nPort_ = 80
	if _cScheme_ = "https"
		_nPort_ = 443
	ok
	_cHost_ = _c_
	_k_ = StzFindFirst(":", _c_)
	if _k_ > 0
		_cHost_ = StzLeft(_c_, _k_ - 1)
		_nPort_ = ring_number(StzMidToEnd(_c_, _k_ + 1))
	ok
	return [ _cScheme_, _cHost_, _nPort_, _cPath_ ]

# the platform's webhook endpoint: POST <path> on an stzAppServer, answering what the hub expects
# of a callback -- 204 when the event is believed, 401 for a bad signature or a replay, 400 for a
# signed body that is not an event. The port does the verifying; this is only the door.
func StzPaymentsWebhookRoute(poServer, pcPath, poPort)
	$aPayWebhookRoutes + [ pcPath, poPort ]
	poServer.Post(pcPath, "StzPaymentsWebhookHandle")
	return poServer

func StzPaymentsWebhookHandle(poReq, poResp)
	_oPort_ = ""
	for _i_ = 1 to len($aPayWebhookRoutes)
		if $aPayWebhookRoutes[_i_][1] = poReq.Path()
			_oPort_ = $aPayWebhookRoutes[_i_][2]
		ok
	next
	if NOT isObject(_oPort_)
		poResp.Status(404, "Not Found").Send("")
		return
	ok
	_aR_ = _oPort_.ReceiveWebhook(poReq.Body(), poReq.Header("X-Signature"))
	if _StzPiGet(_aR_, "accepted", 0) = 1
		poResp.Status(204, "No Content").Send("")
		return
	ok
	if _StzPiGet(_aR_, "reason", "") = "malformed"
		poResp.Status(400, "Bad Request").Send("")
		return
	ok
	poResp.Status(401, "Unauthorized").Send("")


  #=====================#
 #  THE ADAPTER        #
#=====================#

class stzPispiHttpAdapter from stzObject

	@nId = 0
	@cParticipant = ""
	@cBase = ""
	@cTokenUrl = ""
	@aScopes = []
	@cScopePrefix = ""
	@oStore = ""
	@oActor = ""
	@cClientName = ""
	@cApiKeyName = ""
	@cCertName = ""
	@cKeyName = ""
	@cCert = ""
	@cKey = ""
	@cCa = ""
	@nPosture = 0        # 0 unset, 1 conformance, 2 live

	def init()
		$nPiAdapterSeq = $nPiAdapterSeq + 1
		@nId = $nPiAdapterSeq
		@aScopes = StzPispiAllScopes()
		$aPiTokens + [ @nId, "", 0, 0, 0 ]

	  #-- configuration (each setter answers the adapter) ------------------

	# names the five secrets: pispi-<participant>-client, -api-key, -mtls-cert, -mtls-key
	def WithParticipant(pcParticipant)
		@cParticipant = StzLower(ring_trim("" + pcParticipant))
		@cClientName = StzPispiSecretName(@cParticipant, "client")
		@cApiKeyName = StzPispiSecretName(@cParticipant, "api-key")
		@cCertName = StzPispiSecretName(@cParticipant, "mtls-cert")
		@cKeyName = StzPispiSecretName(@cParticipant, "mtls-key")
		return This

	# the participant's API Business base URL, version included: https://host/piz/v1
	def WithBaseUrl(pcUrl)
		@cBase = "" + pcUrl
		while ring_len(@cBase) > 0 and @cBase[ring_len(@cBase)] = "/"
			@cBase = StzLeft(@cBase, ring_len(@cBase) - 1)
		end
		return This

	# defaults to scheme://host:port/oauth/token of the base URL
	def WithTokenUrl(pcUrl)
		@cTokenUrl = "" + pcUrl
		return This

	# the scopes to ask for; fewer scopes is a narrower token
	def WithScopes(paScopes)
		@aScopes = paScopes
		return This

	# "piz/" in the BCEAO's sandbox
	def WithScopePrefix(pcPrefix)
		@cScopePrefix = "" + pcPrefix
		return This

	# the credentials, through the store's governed door. Ring copied the store when it was handed
	# over: hand it again after a rotation.
	def WithSecretsFrom(poStore, poActor)
		@oStore = poStore
		@oActor = poActor
		return This

	# the mTLS identity is two PEM files; a descriptor with a FILE source names where
	def WithCertificateFrom(poStore)
		@oStore = poStore
		return This

	def WithCertificateFiles(pcCert, pcKey)
		@cCert = "" + pcCert
		@cKey = "" + pcKey
		return This

	# the CA that signs the participant's server certificate; empty means the operating system's roots
	def WithCaFile(pcCa)
		@cCa = "" + pcCa
		return This

	def AsConformance()
		@nPosture = 1
		return This

	def AsLive()
		@nPosture = 2
		return This

	  #-- what the registry asks of an adapter ---------------------------------

	def IsSandbox()
		return 0

	def IsConformance()
		return @nPosture = 1

	# a live participant requires the client certificate; the BCEAO's sandbox does not
	def RequiresCertificate()
		return @nPosture = 2

	def CertificateSecretName()
		return @cCertName

	def ClientSecretName()
		return @cClientName

	def ApiKeySecretName()
		return @cApiKeyName

	def Participant()
		return @cParticipant

	  #-- test hooks and stats ---------------------------------------------------

	# FAULT INJECTION: the next request is sent and its response is lost, as a dropped connection
	# loses it. Money may have moved; the platform cannot know. The port's journal is what handles it.
	def DropNextResponse()
		$aPiTokens[This._TokenRow()][5] = 1
		return This

	def TokensFetched()
		return $aPiTokens[This._TokenRow()][4]

	def ForgetToken()
		$aPiTokens[This._TokenRow()][2] = ""
		$aPiTokens[This._TokenRow()][3] = 0
		return This

	  #-- THE CONTRACT ------------------------------------------------------------

	# [ status, body ]: the same shape the twin gives. A 401 drops the token and tries ONCE more.
	def Request(pcMethod, pcPath, paQuery, paBody)
		_aQ_ = []
		if isList(paQuery)
			_aQ_ = paQuery
		ok
		_aB_ = []
		if isList(paBody)
			_aB_ = paBody
		ok
		_cTok_ = This._Token()
		_aR_ = This._Send(pcMethod, pcPath, _aQ_, _aB_, _cTok_)
		if _aR_[1] = 401
			This.ForgetToken()
			_cTok_ = This._Token()
			_aR_ = This._Send(pcMethod, pcPath, _aQ_, _aB_, _cTok_)
		ok
		return _aR_

	  #-- OAuth: client credentials, cached, refreshed a minute early ------------

	def _TokenRow()
		for _i_ = 1 to ring_len($aPiTokens)
			if $aPiTokens[_i_][1] = @nId
				return _i_
			ok
		next
		$aPiTokens + [ @nId, "", 0, 0, 0 ]
		return ring_len($aPiTokens)

	def _Token()
		_k_ = This._TokenRow()
		if $aPiTokens[_k_][2] != "" and StzEngineTimeNowMs() < $aPiTokens[_k_][3] - 60000
			return $aPiTokens[_k_][2]
		ok
		_aCred_ = This._ClientCredentials()
		_cScope_ = ""
		for _i_ = 1 to ring_len(@aScopes)
			if _i_ > 1
				_cScope_ += " "
			ok
			_cScope_ += @cScopePrefix + @aScopes[_i_]
		next
		_cForm_ = "grant_type=client_credentials&client_id=" + _StzPiPctEncode(_aCred_[1]) +
			"&client_secret=" + _StzPiPctEncode(_aCred_[2]) + "&scope=" + _StzPiPctEncode(_cScope_)
		_cUrl_ = @cTokenUrl
		if _cUrl_ = ""
			_aU_ = _StzPiSplitUrl(@cBase)
			_cUrl_ = _aU_[1] + "://" + _aU_[2] + ":" + _aU_[3] + "/oauth/token"
		ok
		_aR_ = This._Transport("POST", _cUrl_, _cForm_, "application/x-www-form-urlencoded", "")
		if _aR_[1] != 200
			StzRaise("stzPispiHttpAdapter token: the token endpoint answered " + _aR_[1] + ", not 200: " + StzLeft(_aR_[2], 200))
		ok
		_a_ = StzJsonToList(_aR_[2])
		_cTok_ = "" + _StzPiGet(_a_, "access_token", "")
		if _cTok_ = ""
			StzRaise("stzPispiHttpAdapter token: the answer carries no access_token.")
		ok
		_nTtl_ = ring_number("" + _StzPiGet(_a_, "expires_in", 3600))
		$aPiTokens[_k_][2] = _cTok_
		$aPiTokens[_k_][3] = StzEngineTimeNowMs() + _nTtl_ * 1000
		$aPiTokens[_k_][4] = $aPiTokens[_k_][4] + 1
		return _cTok_

	# [ clientId, clientSecret ] from the store: the secret holds "clientId:clientSecret"
	def _ClientCredentials()
		if NOT isObject(@oStore) or NOT isObject(@oActor)
			StzRaise("stzPispiHttpAdapter: no credentials. Give it the store and an actor: WithSecretsFrom(oStore, oActor).")
		ok
		_c_ = @oStore.Reveal(@cClientName, @oActor)
		_p_ = StzFindFirst(":", _c_)
		if _p_ = 0
			StzRaise("stzPispiHttpAdapter: the '" + @cClientName + "' secret must hold clientId:clientSecret.")
		ok
		return [ StzLeft(_c_, _p_ - 1), StzMidToEnd(_c_, _p_ + 1) ]

	def _ApiKey()
		if NOT isObject(@oStore) or NOT isObject(@oActor)
			return ""
		ok
		return @oStore.Reveal(@cApiKeyName, @oActor)

	  #-- the mTLS identity: PEM FILES the engine reads ---------------------------

	def _CertPath()
		if isObject(@oStore) and @cCertName != "" and @oStore.Has(@cCertName)
			if @oStore.Secret(@cCertName).SourceKind() = "file"
				return @oStore.Secret(@cCertName).SourceLocator()
			ok
		ok
		return @cCert

	def _KeyPath()
		if isObject(@oStore) and @cKeyName != "" and @oStore.Has(@cKeyName)
			if @oStore.Secret(@cKeyName).SourceKind() = "file"
				return @oStore.Secret(@cKeyName).SourceLocator()
			ok
		ok
		return @cKey

	  #-- one call ----------------------------------------------------------------

	def _Send(pcMethod, pcPath, paQuery, paBody, pcToken)
		_cUrl_ = @cBase + pcPath
		_cQ_ = ""
		for _i_ = 1 to ring_len(paQuery)
			if _i_ > 1
				_cQ_ += "&"
			ok
			_cQ_ += _StzPiPctEncode("" + paQuery[_i_][1]) + "=" + _StzPiPctEncode("" + paQuery[_i_][2])
		next
		if _cQ_ != ""
			_cUrl_ += "?" + _cQ_
		ok
		_cBody_ = StzPispiJson(paBody)
		_aRaw_ = This._Transport(pcMethod, _cUrl_, _cBody_, "application/json", pcToken)
		if $aPiTokens[This._TokenRow()][5] = 1
			$aPiTokens[This._TokenRow()][5] = 0
			StzRaise("stzPispiHttpAdapter transport: the response to " + pcMethod + " " + pcPath +
				" was lost; the request may have been processed.")
		ok
		_nStatus_ = _aRaw_[1]
		_cText_ = _aRaw_[2]
		if _nStatus_ = 204 or _cText_ = ""
			return [ _nStatus_, "" ]
		ok
		if NOT StzJsonIsValid(_cText_)
			return [ _nStatus_, [ [ "type", "about:blank" ], [ "title", "Not JSON" ], [ "status", _nStatus_ ],
				[ "detail", "the participant answered a body that is not JSON: " + StzLeft(_cText_, 160) ] ] ]
		ok
		return [ _nStatus_, StzJsonToList(_cText_) ]

	# [ status, bodyText ] over plain HTTP or the engine's TLS client
	def _Transport(pcMethod, pcUrl, pcBody, pcContentType, pcToken)
		_aU_ = _StzPiSplitUrl(pcUrl)
		_cApiKey_ = This._ApiKey()
		if _aU_[1] = "https"
			_cCRLF_ = char(13) + char(10)
			_cReq_ = pcMethod + " " + _aU_[4] + " HTTP/1.1" + _cCRLF_ + "Host: " + _aU_[2] + _cCRLF_ +
				"Accept: application/json" + _cCRLF_
			if pcToken != ""
				_cReq_ += "Authorization: Bearer " + pcToken + _cCRLF_
			ok
			if _cApiKey_ != "" and pcToken != ""
				_cReq_ += "x-api-key: " + _cApiKey_ + _cCRLF_
			ok
			if pcBody != ""
				_cReq_ += "Content-Type: " + pcContentType + _cCRLF_ + "Content-Length: " + ring_len(pcBody) + _cCRLF_
			ok
			_cReq_ += "Connection: close" + _cCRLF_ + _cCRLF_ + pcBody
			if NOT isObject($oPiTlsReactor)
				$oPiTlsReactor = new stzReactor()
			ok
			_cRaw_ = $oPiTlsReactor.TlsRequest(_aU_[2], _aU_[3], _cReq_, This._CertPath(), This._KeyPath(), @cCa, 1)
			_nSt_ = $oPiTlsReactor.TlsClientStatus()
			if _nSt_ != 0
				StzRaise("stzPispiHttpAdapter transport: TLS to " + _aU_[2] + ":" + _aU_[3] + " failed (engine status " + _nSt_ + ").")
			ok
			if _cRaw_ = ""
				StzRaise("stzPispiHttpAdapter transport: " + _aU_[2] + ":" + _aU_[3] + " closed without a response; " +
					"if it requires a client certificate, none was accepted.")
			ok
			_aP_ = _StzPiParseHttp(_cRaw_)
			return [ _aP_[1], _aP_[3] ]
		ok
		_oH_ = new stzHttpClient()
		if pcToken != ""
			_oH_.SetHeader("Authorization", "Bearer " + pcToken)
			if _cApiKey_ != ""
				_oH_.SetHeader("x-api-key", _cApiKey_)
			ok
		ok
		_oH_.SetHeader("Accept", "application/json")
		_nM_ = $STZ_HTTP_METHOD_GET
		if pcMethod = "POST"
			_nM_ = $STZ_HTTP_METHOD_POST
		but pcMethod = "PUT"
			_nM_ = $STZ_HTTP_METHOD_PUT
		but pcMethod = "DELETE"
			_nM_ = $STZ_HTTP_METHOD_DELETE
		ok
		_oH_._Perform(_nM_, pcUrl, pcContentType, pcBody)
		_nC_ = _oH_.ResponseCode()
		if _nC_ <= 0
			StzRaise("stzPispiHttpAdapter transport: no response from " + _aU_[2] + ":" + _aU_[3] + ".")
		ok
		return [ _nC_, _oH_.ResponseBody() ]
