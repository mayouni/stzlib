#================================================================#
#  STZPISPISANDBOX -- the Softanza twin of the PI-SPI hub (PY2)       #
#================================================================#

/*--- The twin answers the API Business the way a participant does.

A platform that pays through Softanza never meets a different contract in test and in
production: the twin implements the REST CONTRACT of the API Business v1.5.0 (paths,
bodies, status words, RFC 7807 problems, paging, filters, webhooks) in-process, and the
live adapter (PY5) speaks the same contract over HTTP. Both are reached through ONE
method:

    aR = oHub.Request("POST", "/paiements-envoyes", [], aBody)   # -> [ nHttpStatus, aBody ]

The payments port (stzPaymentsPort) turns verbs into these requests; the twin never
knows a verb. That is also what lets PY5 serve the twin over HTTP behind stzAppServer
with no second implementation: the server's handler is one call to Request().

IT IS A TWIN, NOT A STUB. It enforces what the reference enforces, so code that pays twice,
pays an alias that does not exist, confirms a cancelled payment, or sends a field the
schema refuses fails HERE, in a test, against a hub that behaves like the hub:

  * a txId replay is answered 200 with statut REJETE / DU03 -- the hub does NOT return the
    first state (the port's journal does, see stzPaymentsPort)
  * a payment is PENDING (ENVOYE) and becomes IRREVOCABLE or REJETE 20 seconds later,
    announced by a signed webhook; "20 seconds" is the twin's clock, not the wall's
  * a ceiling breach is a 403 problem, an unknown field a 400 (additionalProperties false),
    the quota a 429, a missing resource a 404, an opposite answer after a decision a 403
  * a cancellation is a REQUEST the payee may refuse; a return is a NEW movement; both
    within 90 days; a cancellation request is NOT idempotent, a return is
  * a bulk carries one instructionId, one txId per item, and answers 202

DETERMINISTIC BY CONSTRUCTION. A clock that starts at 2026-10-05T09:00:00Z and advances one
second per request (and by AdvanceSeconds); end2endIds numbered from a per-hub sequence; no
randomness except the webhook secret, which the hub returns once and which a guard reads
from the creation response. Counterparties are rules you write (AddCounterparty), not dice.

SHARED STATE, BECAUSE RING COPIES. A registry hands out a COPY of what was bound, so every
table lives in a global list and the object carries only its hub id. Records are
hashlists with the reference's own key spelling (string keys, never :symbols, because the
lexer lowercases a symbol and the wire is case-sensitive); keys beginning with "_" are the
twin's private bookkeeping and never leave it.

NO FEE, NO MONEY. The twin holds virtual francs. montantFrais is absent, because the
participant's fee is the participant's contract, and Softanza takes none.
*/

# Hub records and the tables the twin owns. All flat; every record carries "_hub".
$aPiHubs = []
$aPiCalls = []
$aPiAlias = []
$aPiAcc = []
$aPiPay = []
$aPiRtp = []
$aPiBulk = []
$aPiTx = []
$aPiHooks = []
$aPiOut = []

# 2026-10-05T09:00:00Z
$nPiEpoch0 = 1791190800

func StzPiSpiSandboxQ()
	return new stzPiSpiSandbox()

#---------------------------------------------------------------------#
#  small things                                                        #
#---------------------------------------------------------------------#

func _StzPiHas(paList, pcKey)
	_k_ = lower("" + pcKey)
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if lower("" + paList[_i_][1]) = _k_
			return 1
		ok
	next
	return 0

func _StzPiGet(paList, pcKey, pxDefault)
	_k_ = lower("" + pcKey)
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if lower("" + paList[_i_][1]) = _k_
			return paList[_i_][2]
		ok
	next
	return pxDefault

# a record without the twin's private "_" keys: what a client may see
func _StzPiPublic(paRec)
	_aOut_ = []
	_n_ = len(paRec)
	for _i_ = 1 to _n_
		_c_ = "" + paRec[_i_][1]
		if StzLeft(_c_, 1) != "_"
			_aOut_ + [ paRec[_i_][1], paRec[_i_][2] ]
		ok
	next
	return _aOut_

func _StzPi2(n)
	if n < 10
		return "0" + n
	ok
	return "" + n

func _StzPiDaysFromCivil(y, m, d)
	if m <= 2
		y = y - 1
	ok
	_era_ = floor(y / 400)
	_yoe_ = y - _era_ * 400
	_mp_ = m + 9
	if m > 2
		_mp_ = m - 3
	ok
	_doy_ = floor((153 * _mp_ + 2) / 5) + d - 1
	_doe_ = _yoe_ * 365 + floor(_yoe_ / 4) - floor(_yoe_ / 100) + _doy_
	return _era_ * 146097 + _doe_ - 719468

# epoch seconds -> "YYYY-MM-DDTHH:MM:SS.000Z"
func _StzPiIso(n)
	_days_ = floor(n / 86400)
	_secs_ = n - _days_ * 86400
	_z_ = _days_ + 719468
	_era_ = floor(_z_ / 146097)
	_doe_ = _z_ - _era_ * 146097
	_yoe_ = floor((_doe_ - floor(_doe_ / 1460) + floor(_doe_ / 36524) - floor(_doe_ / 146096)) / 365)
	_y_ = _yoe_ + _era_ * 400
	_doy_ = _doe_ - (365 * _yoe_ + floor(_yoe_ / 4) - floor(_yoe_ / 100))
	_mp_ = floor((5 * _doy_ + 2) / 153)
	_d_ = _doy_ - floor((153 * _mp_ + 2) / 5) + 1
	_m_ = _mp_ - 9
	if _mp_ < 10
		_m_ = _mp_ + 3
	ok
	if _m_ <= 2
		_y_ = _y_ + 1
	ok
	_hh_ = floor(_secs_ / 3600)
	_mi_ = floor((_secs_ - _hh_ * 3600) / 60)
	_ss_ = _secs_ - _hh_ * 3600 - _mi_ * 60
	return "" + _y_ + "-" + _StzPi2(_m_) + "-" + _StzPi2(_d_) + "T" + _StzPi2(_hh_) + ":" +
		_StzPi2(_mi_) + ":" + _StzPi2(_ss_) + ".000Z"

# "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM:SS[.mmm]Z" -> epoch seconds, or -1
func _StzPiEpochOf(pc)
	if NOT isString(pc) or len(pc) < 10
		return -1
	ok
	_y_ = ring_number(StzMid(pc, 1, 4))
	_m_ = ring_number(StzMid(pc, 6, 2))
	_d_ = ring_number(StzMid(pc, 9, 2))
	if _y_ < 1970 or _m_ < 1 or _m_ > 12 or _d_ < 1 or _d_ > 31
		return -1
	ok
	_t_ = _StzPiDaysFromCivil(_y_, _m_, _d_) * 86400
	if len(pc) >= 19
		_t_ = _t_ + ring_number(StzMid(pc, 12, 2)) * 3600 + ring_number(StzMid(pc, 15, 2)) * 60 +
			ring_number(StzMid(pc, 18, 2))
	ok
	return _t_

func _StzPiClock(nHub)
	return $aPiHubs[nHub]["clock"]

func _StzPiNow(nHub)
	return _StzPiIso($aPiHubs[nHub]["clock"])

# [ status, body ]
func _StzPiOk(pnStatus, paBody)
	return [ pnStatus, paBody ]

func _StzPiTitle(n)
	if n = 400  return "Bad Request"  ok
	if n = 401  return "Unauthorized"  ok
	if n = 403  return "Forbidden"  ok
	if n = 404  return "Not Found"  ok
	if n = 409  return "Conflict"  ok
	if n = 429  return "Too Many Requests"  ok
	if n = 503  return "Service Unavailable"  ok
	return "Error"

# an RFC 7807 problem; invalid-params only when there is something to say
func _StzPiProblem(pnStatus, pcDetail, paInvalid)
	_a_ = [ [ "type", "about:blank" ], [ "title", _StzPiTitle(pnStatus) ],
		[ "status", pnStatus ], [ "detail", pcDetail ] ]
	if isList(paInvalid) and len(paInvalid) > 0
		_a_ + [ "invalid-params", paInvalid ]
	ok
	return [ pnStatus, _a_ ]

func _StzPiBad(pcName, pcReason)
	return [ [ "name", pcName ], [ "reason", pcReason ] ]

func _StzPiRandHex(n)
	return StzEngineCryptoRandomHex(n)

# end2endId: E + member code + yyyymmddhhmmss + 14 characters = 35, like the reference's
func _StzPiE2E(nHub)
	_seq_ = $aPiHubs[nHub]["seq"] + 1
	$aPiHubs[nHub]["seq"] = _seq_
	_iso_ = _StzPiNow(nHub)
	_stamp_ = StzMid(_iso_, 1, 4) + StzMid(_iso_, 6, 2) + StzMid(_iso_, 9, 2) +
		StzMid(_iso_, 12, 2) + StzMid(_iso_, 15, 2) + StzMid(_iso_, 18, 2)
	_n_ = "" + _seq_
	while len(_n_) < 10
		_n_ = "0" + _n_
	end
	return "E" + $aPiHubs[nHub]["code"] + _stamp_ + "TWIN" + _n_

#---------------------------------------------------------------------#
#  a hub, and what is in it at birth                                   #
#---------------------------------------------------------------------#

# the platform's own alias, so every guard and example names the same payer
func _StzPiOwnAlias()
	return "9b1b3499-3e50-435b-b757-ac7a83d8aa96"

func _StzPiNewHub()
	_n_ = len($aPiHubs) + 1
	$aPiHubs + [ [ "id", _n_ ], [ "clock", $nPiEpoch0 ], [ "seq", 0 ], [ "perMin", 100 ],
		[ "perDay", 10000 ], [ "code", "NEB001" ], [ "failAnswer", 0 ], [ "hookSeq", 0 ] ]
	_StzPiSeedAccount(_n_, "NE2344256727788288822", "CACC", 50000000)
	_StzPiSeedAccount(_n_, "NE2344256727788288833", "SVGS", 1000000)
	# the platform itself, on its current account
	_StzPiSeedAlias(_n_, _StzPiOwnAlias(), "NE2344256727788288822", "Plateforme DIKO", "NE", "B", 1,
		"ok", "pay", "accept")
	# the simulated customers: each one is a RULE, not a dice
	_StzPiSeedAlias(_n_, "9b1b2499-3e50-435b-b757-ac7a83d8aa8c", "SN0150101307430029018", "Fatou Diop", "SN", "P", 0,
		"ok", "pay", "accept")
	_StzPiSeedAlias(_n_, "aaaa0001-0000-4000-8000-000000000001", "CI0010100000000000001", "Boutique ABC SARL", "SN", "C", 0,
		"ok", "pay", "accept")
	_StzPiSeedAlias(_n_, "bbbb0002-0000-4000-8000-000000000002", "CI0010100000000000002", "Kdi & Sisters", "CI", "B", 0,
		"ok", "pay", "accept")
	_StzPiSeedAlias(_n_, "cccc0003-0000-4000-8000-000000000003", "ML0010100000000000003", "Compte Bloque", "ML", "P", 0,
		"AC06", "ARFR", "accept")
	_StzPiSeedAlias(_n_, "dddd0004-0000-4000-8000-000000000004", "SN0010100000000000004", "Fournisseur Intraitable", "SN", "B", 0,
		"ok", "pay", "CUST")
	return _n_

func _StzPiSeedAccount(nHub, pcNumero, pcType, pnSolde)
	$aPiAcc + [ [ "_hub", nHub ], [ "numero", pcNumero ], [ "type", pcType ], [ "solde", pnSolde ],
		[ "statut", "OUVERT" ], [ "dateOuverture", "2025-11-02" ] ]

# pcPay: "ok" or the ISO reason the customer's side rejects a payment with
# pcRtp: "pay" or the reason it refuses a request to pay with
# pcCancel: "accept" or the reason it refuses a cancellation with
func _StzPiSeedAlias(nHub, pcCle, pcCompte, pcNom, pcPays, pcCat, pbOwn, pcPay, pcRtp, pcCancel)
	$aPiAlias + [ [ "_hub", nHub ], [ "cle", pcCle ], [ "type", "SHID" ], [ "compte", pcCompte ],
		[ "dateCreation", "2025-11-02T08:00:00.000Z" ], [ "_nom", pcNom ], [ "_pays", pcPays ],
		[ "_cat", pcCat ], [ "_own", pbOwn ], [ "_pay", pcPay ], [ "_rtp", pcRtp ], [ "_cancel", pcCancel ],
		[ "_iban", pcCompte ], [ "_participant", "" ] ]

func _StzPiAliasIndex(nHub, pcCle)
	_k_ = lower("" + pcCle)
	_n_ = len($aPiAlias)
	for _i_ = 1 to _n_
		if $aPiAlias[_i_]["_hub"] = nHub and lower($aPiAlias[_i_]["cle"]) = _k_
			return _i_
		ok
	next
	return 0

# the account an alias is attached to
func _StzPiAccountIndex(nHub, pcNumero)
	_n_ = len($aPiAcc)
	for _i_ = 1 to _n_
		if $aPiAcc[_i_]["_hub"] = nHub and $aPiAcc[_i_]["numero"] = pcNumero
			return _i_
		ok
	next
	return 0

func _StzPiOwnAccount(nHub)
	return _StzPiAccountIndex(nHub, "NE2344256727788288822")

#---------------------------------------------------------------------#
#  paging, filters, sorting -- the contract of every list              #
#---------------------------------------------------------------------#

# a query key is "prop" or "prop[op]"
func _StzPiMatches(pxValue, pbHas, pcOp, pcWanted)
	if pcOp = "exists"
		if lower(pcWanted) = "true"
			return pbHas
		ok
		return NOT pbHas
	ok
	if NOT pbHas
		return 0
	ok
	_s_ = "" + pxValue
	if isNumber(pxValue)
		_x_ = pxValue
		_w_ = ring_number(pcWanted)
		if pcOp = "eq"  return _x_ = _w_  ok
		if pcOp = "ne"  return _x_ != _w_  ok
		if pcOp = "gt"  return _x_ > _w_  ok
		if pcOp = "gte"  return _x_ >= _w_  ok
		if pcOp = "lt"  return _x_ < _w_  ok
		if pcOp = "lte"  return _x_ <= _w_  ok
	ok
	if pcOp = "eq"  return _s_ = pcWanted  ok
	if pcOp = "ne"  return _s_ != pcWanted  ok
	if pcOp = "gt"  return _s_ > pcWanted  ok
	if pcOp = "gte"  return _s_ >= pcWanted  ok
	if pcOp = "lt"  return _s_ < pcWanted  ok
	if pcOp = "lte"  return _s_ <= pcWanted  ok
	if pcOp = "contains"  return StzFindFirst(pcWanted, _s_) > 0  ok
	if pcOp = "notcontains"  return StzFindFirst(pcWanted, _s_) = 0  ok
	if pcOp = "beginswith"  return StzLeft(_s_, len(pcWanted)) = pcWanted  ok
	if pcOp = "in"
		_aW_ = split(pcWanted, ",")
		for _i_ = 1 to len(_aW_)
			if _s_ = _aW_[_i_]  return 1  ok
		next
		return 0
	ok
	return 0

# one-key sort over a list of records (stable by index), "-field" descending
func _StzPiSorted(paRecs, pcSort)
	if pcSort = ""
		return paRecs
	ok
	_desc_ = 0
	_f_ = pcSort
	if StzLeft(pcSort, 1) = "-"
		_desc_ = 1
		_f_ = StzMid(pcSort, 2, len(pcSort) - 1)
	ok
	_aKeys_ = []
	for _i_ = 1 to len(paRecs)
		_aKeys_ + [ _StzPiGet(paRecs[_i_], _f_, ""), _i_ ]
	next
	# insertion sort over the keys, stable
	for _i_ = 2 to len(_aKeys_)
		_cur_ = _aKeys_[_i_]
		_j_ = _i_ - 1
		while _j_ >= 1
			_swap_ = 0
			if _desc_ = 0 and _aKeys_[_j_][1] > _cur_[1]  _swap_ = 1  ok
			if _desc_ = 1 and _aKeys_[_j_][1] < _cur_[1]  _swap_ = 1  ok
			if _swap_ = 0  exit  ok
			_aKeys_[_j_ + 1] = _aKeys_[_j_]
			_j_ = _j_ - 1
		end
		_aKeys_[_j_ + 1] = _cur_
	next
	_aOut_ = []
	for _i_ = 1 to len(_aKeys_)
		_aOut_ + paRecs[_aKeys_[_i_][2]]
	next
	return _aOut_

# the list envelope: filters, sort, page, size, then { data, meta }
func _StzPiListed(paRecs, paQuery)
	_aKept_ = []
	for _i_ = 1 to len(paRecs)
		_ok_ = 1
		for _q_ = 1 to len(paQuery)
			_key_ = "" + paQuery[_q_][1]
			if _key_ = "page" or _key_ = "size" or _key_ = "sort"
				loop
			ok
			_op_ = "eq"
			_prop_ = _key_
			_p_ = StzFindFirst("[", _key_)
			if _p_ > 0
				_prop_ = StzLeft(_key_, _p_ - 1)
				_op_ = lower(StzMid(_key_, _p_ + 1, len(_key_) - _p_ - 1))
			ok
			if NOT _StzPiMatches(_StzPiGet(paRecs[_i_], _prop_, ""), _StzPiHas(paRecs[_i_], _prop_), _op_, "" + paQuery[_q_][2])
				_ok_ = 0
				exit
			ok
		next
		if _ok_ = 1
			_aKept_ + paRecs[_i_]
		ok
	next
	_aKept_ = _StzPiSorted(_aKept_, "" + _StzPiGet(paQuery, "sort", ""))
	_size_ = ring_number("" + _StzPiGet(paQuery, "size", 20))
	_page_ = ring_number("" + _StzPiGet(paQuery, "page", 1))
	if _size_ < 1 or _size_ > 100
		return _StzPiProblem(400, "size must be between 1 and 100",
			[ _StzPiBad("size", "The page size is an integer from 1 to 100") ])
	ok
	if _page_ < 1
		_page_ = 1
	ok
	_total_ = len(_aKept_)
	_from_ = (_page_ - 1) * _size_ + 1
	_aData_ = []
	for _i_ = _from_ to _from_ + _size_ - 1
		if _i_ > _total_
			exit
		ok
		_aData_ + _StzPiPublic(_aKept_[_i_])
	next
	_aMeta_ = [ [ "total", _total_ ], [ "page", _page_ ], [ "size", _size_ ] ]
	if _from_ + _size_ <= _total_
		_aMeta_ + [ "next", _page_ + 1 ]
	ok
	if _page_ > 1
		_aMeta_ + [ "prev", _page_ - 1 ]
	ok
	return _StzPiOk(200, [ [ "data", _aData_ ], [ "meta", _aMeta_ ] ])

#---------------------------------------------------------------------#
#  validation of a body: the schemas say additionalProperties: false    #
#---------------------------------------------------------------------#

# [ [ name, reason ], ... ]: an unknown field, a missing required one
func _StzPiCheckFields(paBody, paAllowed, paRequired)
	_aBad_ = []
	for _i_ = 1 to len(paBody)
		_k_ = lower("" + paBody[_i_][1])
		_known_ = 0
		for _j_ = 1 to len(paAllowed)
			if lower(paAllowed[_j_]) = _k_
				_known_ = 1
				exit
			ok
		next
		if _known_ = 0
			_aBad_ + _StzPiBad("" + paBody[_i_][1], "Champ non autorise")
		ok
	next
	for _j_ = 1 to len(paRequired)
		if NOT _StzPiHas(paBody, paRequired[_j_])
			_aBad_ + _StzPiBad(paRequired[_j_], "Champ obligatoire")
		ok
	next
	return _aBad_

func _StzPiRefDocOk(pcType)
	_a_ = [ "CINV", "CMCN", "DISP", "PUOR", "CONT", "HIRI", "INVS", "MSIN", "PROF", "QUOT", "SPRR", "TISH" ]
	for _i_ = 1 to len(_a_)
		if _a_[_i_] = pcType
			return 1
		ok
	next
	return 0

# montant, txId, motif, refDoc: the facts every order and request share
func _StzPiCheckCommon(paBody)
	_aBad_ = []
	if _StzPiHas(paBody, "montant")
		_m_ = _StzPiGet(paBody, "montant", 0)
		if NOT isNumber(_m_) or _m_ <= 0 or _m_ != floor(_m_)
			_aBad_ + _StzPiBad("montant", "Le montant est un nombre entier positif de francs CFA")
		ok
	ok
	if _StzPiHas(paBody, "txId")
		_t_ = "" + _StzPiGet(paBody, "txId", "")
		if len(_t_) < 1 or len(_t_) > 35
			_aBad_ + _StzPiBad("txId", "Le txId compte de 1 a 35 caracteres")
		ok
	ok
	if _StzPiHas(paBody, "motif") and len("" + _StzPiGet(paBody, "motif", "")) > 140
		_aBad_ + _StzPiBad("motif", "Le motif compte au plus 140 caracteres")
	ok
	if _StzPiHas(paBody, "refDocNumero") and len("" + _StzPiGet(paBody, "refDocNumero", "")) > 35
		_aBad_ + _StzPiBad("refDocNumero", "La reference compte au plus 35 caracteres")
	ok
	if _StzPiHas(paBody, "refDocType") and NOT _StzPiRefDocOk("" + _StzPiGet(paBody, "refDocType", ""))
		_aBad_ + _StzPiBad("refDocType", "Type de document inconnu")
	ok
	return _aBad_

func _StzPiBadRequest(paInvalid)
	return _StzPiProblem(400, "Format du message invalide", paInvalid)

#---------------------------------------------------------------------#
#  the money: one account, debited at SEND, credited back on a reject  #
#---------------------------------------------------------------------#

func _StzPiBalance(nHub)
	return $aPiAcc[_StzPiOwnAccount(nHub)]["solde"]

func _StzPiMove(nHub, pnDelta)
	_i_ = _StzPiOwnAccount(nHub)
	$aPiAcc[_i_]["solde"] = $aPiAcc[_i_]["solde"] + pnDelta

#---------------------------------------------------------------------#
#  events and webhooks                                                 #
#---------------------------------------------------------------------#

func _StzPiHookIndex(nHub, pcId)
	for _i_ = 1 to len($aPiHooks)
		if $aPiHooks[_i_]["_hub"] = nHub and $aPiHooks[_i_]["id"] = pcId
			return _i_
		ok
	next
	return 0

func _StzPiHookCount(nHub)
	_n_ = 0
	for _i_ = 1 to len($aPiHooks)
		if $aPiHooks[_i_]["_hub"] = nHub
			_n_++
		ok
	next
	return _n_

# the secret that signs NOW: a renewed secret takes over at its expiry date
func _StzPiHookSecret(nHub, pnHook)
	_sw_ = $aPiHooks[pnHook]["_switchAt"]
	if _sw_ > 0 and _StzPiClock(nHub) >= _sw_
		return $aPiHooks[pnHook]["_secret2"]
	ok
	return $aPiHooks[pnHook]["_secret"]

func _StzPiHmac(pcBody, pcSecret)
	_oC_ = new stzStringCrypto("" + pcBody)
	return _oC_.HmacSha256("" + pcSecret)

func _StzPiHookWants(pnHook, pcCode)
	_aEv_ = $aPiHooks[pnHook]["events"]
	if len(_aEv_) = 0
		return 1
	ok
	for _i_ = 1 to len(_aEv_)
		if _aEv_[_i_] = pcCode
			return 1
		ok
	next
	return 0

# an event for every hook that wants it, signed with the hook's secret
func _StzPiEmit(nHub, pcCode, paRec, pcClient, pcMotif)
	_aEv_ = [ [ "evCode", pcCode ], [ "evDate", _StzPiNow(nHub) ] ]
	if _StzPiHas(paRec, "txId")
		_aEv_ + [ "txId", _StzPiGet(paRec, "txId", "") ]
	ok
	_aEv_ + [ "end2endId", _StzPiGet(paRec, "end2endId", "") ]
	if _StzPiHas(paRec, "instructionId")
		_aEv_ + [ "instructionId", _StzPiGet(paRec, "instructionId", "") ]
	ok
	_aEv_ + [ "montant", _StzPiGet(paRec, "montant", 0) ]
	if pcClient != ""
		_aEv_ + [ "client", pcClient ]
	ok
	_aEv_ + [ "alias", _StzPiOwnAlias() ]
	if pcMotif != ""
		_aEv_ + [ "motif", pcMotif ]
	ok
	_cBody_ = ListToJson([ [ "data", [ _aEv_ ] ], [ "meta", [ [ "total", 1 ] ] ] ])
	for _h_ = 1 to len($aPiHooks)
		if $aPiHooks[_h_]["_hub"] != nHub
			loop
		ok
		if NOT _StzPiHookWants(_h_, pcCode)
			loop
		ok
		_al_ = $aPiHooks[_h_]["alias"]
		if _al_ != "" and _al_ != _StzPiOwnAlias()
			loop
		ok
		$aPiOut + [ [ "_hub", nHub ], [ "hookId", $aPiHooks[_h_]["id"] ],
			[ "callbackUrl", $aPiHooks[_h_]["callbackUrl"] ], [ "evCode", pcCode ],
			[ "body", _cBody_ ], [ "signature", _StzPiHmac(_cBody_, _StzPiHookSecret(nHub, _h_)) ],
			[ "delivered", 0 ] ]
	next

#---------------------------------------------------------------------#
#  directory lookups                                                   #
#---------------------------------------------------------------------#

# the payee of an order: by alias, by iban + participant, or by account number.
# [ aliasIndex, reason ] -- reason is "" when found, BE23 or AC01 when not
func _StzPiResolvePayee(nHub, paFields)
	if _StzPiHas(paFields, "payeAlias")
		_i_ = _StzPiAliasIndex(nHub, _StzPiGet(paFields, "payeAlias", ""))
		if _i_ = 0
			return [ 0, "BE23" ]
		ok
		return [ _i_, "" ]
	ok
	_cId_ = _StzPiGet(paFields, "payeIban", _StzPiGet(paFields, "payeCompte", ""))
	for _i_ = 1 to len($aPiAlias)
		if $aPiAlias[_i_]["_hub"] = nHub and $aPiAlias[_i_]["_iban"] = _cId_
			return [ _i_, "" ]
		ok
	next
	return [ 0, "AC01" ]

func _StzPiCeilingFor(pcCat)
	if pcCat = "B" or pcCat = "G"
		return 100000000
	ok
	return 10000000

#---------------------------------------------------------------------#
#  a payment: verified, then pending, then final                       #
#---------------------------------------------------------------------#

func _StzPiPayIndex(nHub, pcField, pcValue, pcSens)
	for _i_ = 1 to len($aPiPay)
		if $aPiPay[_i_]["_hub"] = nHub and $aPiPay[_i_]["_sens"] = pcSens
			if "" + $aPiPay[_i_][pcField] = pcValue
				return _i_
			ok
		ok
	next
	return 0

# any payment, sent or received, by end2endId
func _StzPiPayByE2E(nHub, pcE2E)
	for _i_ = 1 to len($aPiPay)
		if $aPiPay[_i_]["_hub"] = nHub and $aPiPay[_i_]["end2endId"] = pcE2E
			return _i_
		ok
	next
	return 0

# Builds the payment the request describes. [ index, record ]: index 0 means "not stored"
# (a txId repeat is answered, never recorded over the original).
func _StzPiNewPayment(nHub, paFields, pbConfirm, pcInstruction)
	_now_ = _StzPiNow(nHub)
	_rec_ = [ [ "_hub", nHub ], [ "_sens", "ENVOYE" ] ]
	for _i_ = 1 to len(paFields)
		_rec_ + [ paFields[_i_][1], paFields[_i_][2] ]
	next
	if pcInstruction != ""
		_rec_["instructionId"] = pcInstruction
	ok
	_rec_["confirmation"] = pbConfirm
	_rec_["categorie"] = "733"
	_rec_["end2endId"] = _StzPiE2E(nHub)
	_rec_["dateDemande"] = _now_
	_aR_ = _StzPiResolvePayee(nHub, paFields)
	_dup_ = _StzPiPayIndex(nHub, "txId", "" + _StzPiGet(paFields, "txId", ""), "ENVOYE")
	if _aR_[1] > 0
		_rec_["payeNom"] = $aPiAlias[_aR_[1]]["_nom"]
		_rec_["payePays"] = $aPiAlias[_aR_[1]]["_pays"]
		_rec_["_payeIndex"] = _aR_[1]
	ok
	if _dup_ > 0
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "DU03"
		_rec_["dateReponse"] = _now_
		# a repeat inside a bulk is one of the bulk's items, rejected; a lone repeat is only answered
		if pcInstruction != ""
			$aPiPay + _rec_
			return [ len($aPiPay), _rec_ ]
		ok
		return [ 0, _rec_ ]
	ok
	if _aR_[1] = 0
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = _aR_[2]
		_rec_["dateReponse"] = _now_
		$aPiPay + _rec_
		return [ len($aPiPay), _rec_ ]
	ok
	_m_ = _StzPiGet(paFields, "montant", 0)
	if _m_ > _StzPiBalance(nHub)
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "AG07"
		_rec_["dateReponse"] = _now_
		$aPiPay + _rec_
		return [ len($aPiPay), _rec_ ]
	ok
	if _m_ > _StzPiCeilingFor($aPiAlias[_aR_[1]]["_cat"])
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "AM02"
		_rec_["dateReponse"] = _now_
		$aPiPay + _rec_
		return [ len($aPiPay), _rec_ ]
	ok
	if pbConfirm
		_rec_["statut"] = "INITIE"
		_rec_["_expires"] = _StzPiClock(nHub) + 86400
	else
		_StzPiSend(nHub, _rec_)
	ok
	$aPiPay + _rec_
	return [ len($aPiPay), _rec_ ]

# the moment a payment leaves: debited now, final 20 seconds later
func _StzPiSend(nHub, rec)
	_now_ = _StzPiNow(nHub)
	rec["statut"] = "ENVOYE"
	if rec["confirmation"] = 0
		rec["dateConfirmation"] = rec["dateDemande"]
	else
		rec["dateConfirmation"] = _now_
	ok
	rec["dateEnvoi"] = _now_
	rec["_due"] = _StzPiClock(nHub) + 20
	_StzPiMove(nHub, 0 - rec["montant"])

# every pending thing whose time has come (or all of it, when forced)
func _StzPiSettle(nHub, pbForce)
	_t_ = _StzPiClock(nHub)
	for _i_ = 1 to len($aPiPay)
		if $aPiPay[_i_]["_hub"] != nHub
			loop
		ok
		if $aPiPay[_i_]["_sens"] = "ENVOYE" and $aPiPay[_i_]["statut"] = "ENVOYE" and
		   ( pbForce or $aPiPay[_i_]["_due"] <= _t_ )
			_StzPiSettlePay(nHub, _i_)
		ok
		if _StzPiHas($aPiPay[_i_], "_retDue") and $aPiPay[_i_]["_retDue"] > 0 and
		   ( pbForce or $aPiPay[_i_]["_retDue"] <= _t_ )
			_StzPiSettleReturn(nHub, _i_)
		ok
		if _StzPiHas($aPiPay[_i_], "_annDue") and $aPiPay[_i_]["_annDue"] > 0 and
		   ( pbForce or $aPiPay[_i_]["_annDue"] <= _t_ )
			_StzPiSettleCancel(nHub, _i_)
		ok
	next
	for _i_ = 1 to len($aPiRtp)
		if $aPiRtp[_i_]["_hub"] = nHub and $aPiRtp[_i_]["_sens"] = "ENVOYE" and
		   $aPiRtp[_i_]["statut"] = "ENVOYE" and
		   ( pbForce or $aPiRtp[_i_]["_due"] <= _t_ )
			_StzPiSettleRtp(nHub, _i_)
		ok
	next

func _StzPiSettlePay(nHub, i)
	_a_ = $aPiPay[i]["_payeIndex"]
	_beh_ = $aPiAlias[_a_]["_pay"]
	_now_ = _StzPiNow(nHub)
	$aPiPay[i]["_due"] = 0
	if _beh_ = "ok"
		$aPiPay[i]["statut"] = "IRREVOCABLE"
		$aPiPay[i]["dateIrrevocabilite"] = _now_
		_StzPiEmit(nHub, "PAIEMENT_ENVOYE", $aPiPay[i], $aPiPay[i]["payeNom"], _StzPiGet($aPiPay[i], "motif", ""))
	else
		$aPiPay[i]["statut"] = "REJETE"
		$aPiPay[i]["statutRaison"] = _beh_
		$aPiPay[i]["dateReponse"] = _now_
		_StzPiMove(nHub, $aPiPay[i]["montant"])
		_StzPiEmit(nHub, "PAIEMENT_REJETE", $aPiPay[i], $aPiPay[i]["payeNom"], _beh_)
	ok

#---------------------------------------------------------------------#
#  the router                                                          #
#---------------------------------------------------------------------#

# "/paiements/E123/retours" -> [ "paiements", "E123", "retours" ]
func _StzPiSegments(pcPath)
	_a_ = split(pcPath, "/")
	_aOut_ = []
	for _i_ = 1 to len(_a_)
		if _a_[_i_] != ""
			_aOut_ + _a_[_i_]
		ok
	next
	return _aOut_

func _StzPiNotFound(pcWhat)
	return _StzPiProblem(404, pcWhat, [])

func _StzPiForbidden(pcWhat)
	return _StzPiProblem(403, pcWhat, [])

# the one door: [ status, body ]. The quota first, then time, then the route.
func _StzPiRequest(nHub, pcMethod, pcPath, paQuery, paBody)
	$aPiHubs[nHub]["clock"] = $aPiHubs[nHub]["clock"] + 1
	_t_ = $aPiHubs[nHub]["clock"]
	# rate limit: calls in the last minute and the last day, this one included
	_nMin_ = 0
	_nDay_ = 0
	_aKeep_ = []
	for _i_ = 1 to len($aPiCalls)
		if $aPiCalls[_i_][1] = nHub
			if _t_ - $aPiCalls[_i_][2] < 86400
				_nDay_++
				if _t_ - $aPiCalls[_i_][2] < 60
					_nMin_++
				ok
			ok
		ok
	next
	if _nMin_ >= $aPiHubs[nHub]["perMin"] or _nDay_ >= $aPiHubs[nHub]["perDay"]
		return _StzPiProblem(429, "Depassement du quota d'appels API: envoi de trop de requetes en un temps donne.", [])
	ok
	$aPiCalls + [ nHub, _t_ ]
	_StzPiSettle(nHub, 0)
	return _StzPiRoute(nHub, upper(pcMethod), _StzPiSegments(pcPath), paQuery, paBody)

func _StzPiRoute(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_r_ = lower(paS[1])
	if _r_ = "paiements-envoyes"
		return _StzPiRoutePaymentsSent(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "paiements-recus"
		return _StzPiRoutePaymentsReceived(nHub, pcM, paS, paQuery)
	ok
	if _r_ = "paiements"
		return _StzPiRoutePaymentsById(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "paiements-groupes"
		return _StzPiRouteBulkPay(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "demandes-paiements"
		return _StzPiRouteRtp(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "demandes-paiements-recues"
		return _StzPiRouteRtpReceived(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "demandes-paiements-groupes"
		return _StzPiRouteBulkRtp(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "comptes"
		return _StzPiRouteAccounts(nHub, pcM, paS, paQuery, paBody)
	ok
	if _r_ = "alias" and _n_ = 2 and pcM = "GET"
		return _StzPiRouteAliasLookup(nHub, paS[2])
	ok
	if _r_ = "participants" and _n_ = 1 and pcM = "GET"
		return _StzPiRouteParticipants(paQuery)
	ok
	if _r_ = "webhooks"
		return _StzPiRouteWebhooks(nHub, pcM, paS, paBody)
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

#---------------------------------------------------------------------#
#  payments sent                                                       #
#---------------------------------------------------------------------#

func _StzPiOrderFields()
	return [ "txId", "payeurAlias", "montant", "confirmation", "payeAlias", "payeIban",
		"payeParticipant", "payeCompte", "refDocNumero", "refDocType", "motif", "programme" ]

# the exclusive routes to a payee: alias | iban+participant | compte+participant
func _StzPiCheckPayeeRoute(paBody)
	_a_ = _StzPiHas(paBody, "payeAlias")
	_i_ = _StzPiHas(paBody, "payeIban")
	_c_ = _StzPiHas(paBody, "payeCompte")
	_p_ = _StzPiHas(paBody, "payeParticipant")
	_aBad_ = []
	_byAlias_ = ( _a_ = 1 and _i_ = 0 and _c_ = 0 and _p_ = 0 )
	_byIban_ = ( _a_ = 0 and _i_ = 1 and _c_ = 0 and _p_ = 1 )
	_byCompte_ = ( _a_ = 0 and _i_ = 0 and _c_ = 1 and _p_ = 1 )
	if NOT ( _byAlias_ or _byIban_ or _byCompte_ )
		_aBad_ + _StzPiBad("payeAlias", "Identifier le beneficiaire par un seul parcours: alias, ou iban + participant, ou compte + participant")
	ok
	return _aBad_

func _StzPiRoutePaymentsSent(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "POST"
		_aBad_ = _StzPiCheckFields(paBody, _StzPiOrderFields(), [ "txId", "payeurAlias", "montant", "confirmation" ])
		_aC_ = _StzPiCheckCommon(paBody)
		for _i_ = 1 to len(_aC_)
			_aBad_ + _aC_[_i_]
		next
		if len(_aBad_) = 0
			_aBad_ = _StzPiCheckPayeeRoute(paBody)
		ok
		if len(_aBad_) = 0 and _StzPiAliasIndex(nHub, _StzPiGet(paBody, "payeurAlias", "")) = 0
			_aBad_ + _StzPiBad("payeurAlias", "Alias du payeur inconnu")
		ok
		if len(_aBad_) = 0 and NOT ( _StzPiGet(paBody, "confirmation", 0) = 0 or _StzPiGet(paBody, "confirmation", 0) = 1 )
			_aBad_ + _StzPiBad("confirmation", "Booleen attendu")
		ok
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		# a ceiling breach is a 403, not a rejected payment (the reference's own example)
		_aP_ = _StzPiResolvePayee(nHub, paBody)
		if _aP_[1] > 0 and _StzPiGet(paBody, "montant", 0) > _StzPiCeilingFor($aPiAlias[_aP_[1]]["_cat"])
			return _StzPiProblem(403, "Plafond de paiement depasse",
				[ _StzPiBad("montant", "Le montant depasse le montant maximal autorise") ])
		ok
		_aF_ = []
		for _i_ = 1 to len(paBody)
			if lower("" + paBody[_i_][1]) != "confirmation"
				_aF_ + [ paBody[_i_][1], paBody[_i_][2] ]
			ok
		next
		_aRes_ = _StzPiNewPayment(nHub, _aF_, _StzPiGet(paBody, "confirmation", 0), "")
		return _StzPiOk(200, _StzPiPublic(_aRes_[2]))
	ok
	if _n_ = 1 and pcM = "GET"
		return _StzPiListOf($aPiPay, nHub, "_sens", "ENVOYE", paQuery)
	ok
	if _n_ = 2 and pcM = "GET"
		_i_ = _StzPiPayIndex(nHub, "txId", paS[2], "ENVOYE")
		if _i_ = 0
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		return _StzPiOk(200, _StzPiPublic($aPiPay[_i_]))
	ok
	if _n_ = 3 and lower(paS[3]) = "confirmations" and pcM = "PUT"
		return _StzPiConfirmPayment(nHub, paS[2], paBody)
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

# the records of one table that belong to one hub and one side, as a list envelope
func _StzPiListOf(paTable, nHub, pcField, pcValue, paQuery)
	_a_ = []
	for _i_ = 1 to len(paTable)
		if paTable[_i_]["_hub"] = nHub
			if pcField = "" or paTable[_i_][pcField] = pcValue
				_a_ + paTable[_i_]
			ok
		ok
	next
	return _StzPiListed(_a_, paQuery)

func _StzPiConfirmPayment(nHub, pcTxId, paBody)
	_aBad_ = _StzPiCheckFields(paBody, [ "decision" ], [ "decision" ])
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	_i_ = _StzPiPayIndex(nHub, "txId", pcTxId, "ENVOYE")
	if _i_ = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_yes_ = _StzPiGet(paBody, "decision", 0)
	_st_ = $aPiPay[_i_]["statut"]
	if _yes_ = 1
		if _st_ = "ANNULE"
			return _StzPiForbidden("Impossible de confirmer un paiement deja annule")
		ok
		if _st_ = "INITIE"
			if _StzPiClock(nHub) > $aPiPay[_i_]["_expires"]
				return _StzPiForbidden("Le delai de confirmation de 24 heures a ete depasse")
			ok
			if $aPiPay[_i_]["montant"] > _StzPiBalance(nHub)
				$aPiPay[_i_]["statut"] = "REJETE"
				$aPiPay[_i_]["statutRaison"] = "AG07"
				$aPiPay[_i_]["dateReponse"] = _StzPiNow(nHub)
			else
				_StzPiSend(nHub, $aPiPay[_i_])
			ok
		ok
	else
		if _st_ = "INITIE"
			$aPiPay[_i_]["statut"] = "ANNULE"
		but _st_ != "ANNULE"
			return _StzPiForbidden("Impossible d'annuler un paiement deja confirme")
		ok
	ok
	return _StzPiOk(200, _StzPiPublic($aPiPay[_i_]))

func _StzPiRoutePaymentsReceived(nHub, pcM, paS, paQuery)
	if pcM != "GET"
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	if len(paS) = 1
		return _StzPiListOf($aPiPay, nHub, "_sens", "RECU", paQuery)
	ok
	_i_ = _StzPiPayIndex(nHub, "txId", paS[2], "RECU")
	if _i_ = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	return _StzPiOk(200, _StzPiPublic($aPiPay[_i_]))

#---------------------------------------------------------------------#
#  by end2endId: status, return, cancellation                          #
#---------------------------------------------------------------------#

func _StzPiGone()
	return _StzPiProblem(404, "Paiement inexistant ou deja archive",
		[ _StzPiBad("end2endId", "Le paiement avec cet identifiant n'existe pas ou a deja ete archive") ])

# more than 90 days since the payment became irrevocable
func _StzPiTooOld(nHub, pcIrrevocable)
	_e_ = _StzPiEpochOf(pcIrrevocable)
	if _e_ < 0
		return 0
	ok
	return _StzPiClock(nHub) - _e_ > 90 * 86400

func _StzPiRoutePaymentsById(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ < 2
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_i_ = _StzPiPayByE2E(nHub, paS[2])
	if _n_ = 2 and pcM = "GET"
		if _i_ = 0
			return _StzPiNotFound("Ce paiement n'a pas ete trouve")
		ok
		return _StzPiOk(200, _StzPiPublic($aPiPay[_i_]))
	ok
	if _n_ = 3 and lower(paS[3]) = "retours" and pcM = "PUT"
		return _StzPiReturnFunds(nHub, _i_)
	ok
	if _n_ = 3 and lower(paS[3]) = "annulations" and pcM = "POST"
		return _StzPiRequestCancellation(nHub, _i_, paBody)
	ok
	if _n_ = 4 and lower(paS[3]) = "annulations" and lower(paS[4]) = "reponses" and pcM = "PUT"
		return _StzPiAnswerCancellation(nHub, _i_, paBody)
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

# the payee returns what it received: a NEW movement, idempotent by end2endId
func _StzPiReturnFunds(nHub, i)
	if i = 0 or $aPiPay[i]["_sens"] != "RECU"
		return _StzPiGone()
	ok
	if _StzPiTooOld(nHub, _StzPiGet($aPiPay[i], "dateIrrevocabilite", ""))
		return _StzPiProblem(403, "Delai de retour de fonds depasse",
			[ _StzPiBad("end2endId", "Un paiement ne peut etre retourne plus de 90 jours apres la date de paiement") ])
	ok
	_rs_ = _StzPiGet($aPiPay[i], "retourStatut", "")
	if _rs_ = "INITIE" or _rs_ = "ENVOYE" or _rs_ = "IRREVOCABLE"
		return _StzPiOk(200, _StzPiPublic($aPiPay[i]))
	ok
	_StzPiStartReturn(nHub, i)
	return _StzPiOk(200, _StzPiPublic($aPiPay[i]))

func _StzPiStartReturn(nHub, i)
	_now_ = _StzPiNow(nHub)
	if $aPiPay[i]["montant"] > _StzPiBalance(nHub)
		$aPiPay[i]["retourStatut"] = "REJETE"
		$aPiPay[i]["retourStatutRaison"] = "AG07"
		$aPiPay[i]["retourDateDemande"] = _now_
		$aPiPay[i]["retourDateReponse"] = _now_
		return
	ok
	_StzPiMove(nHub, 0 - $aPiPay[i]["montant"])
	$aPiPay[i]["retourStatut"] = "INITIE"
	$aPiPay[i]["retourDateDemande"] = _now_
	$aPiPay[i]["_retDue"] = _StzPiClock(nHub) + 20

func _StzPiSettleReturn(nHub, i)
	$aPiPay[i]["_retDue"] = 0
	_beh_ = "ok"
	if _StzPiHas($aPiPay[i], "_payerIndex")
		_beh_ = $aPiAlias[$aPiPay[i]["_payerIndex"]]["_pay"]
	ok
	_now_ = _StzPiNow(nHub)
	if _beh_ = "ok"
		$aPiPay[i]["retourStatut"] = "IRREVOCABLE"
		$aPiPay[i]["retourDateIrrevocabilite"] = _now_
		_StzPiEmit(nHub, "RETOUR_ENVOYE", $aPiPay[i], _StzPiGet($aPiPay[i], "payeurNom", ""), "")
	else
		$aPiPay[i]["retourStatut"] = "REJETE"
		$aPiPay[i]["retourStatutRaison"] = _beh_
		$aPiPay[i]["retourDateReponse"] = _now_
		_StzPiMove(nHub, $aPiPay[i]["montant"])
		_StzPiEmit(nHub, "RETOUR_REJETE", $aPiPay[i], _StzPiGet($aPiPay[i], "payeurNom", ""), _beh_)
	ok

# the payer ASKS; the payee may refuse. Not idempotent: every call is a new request.
func _StzPiRequestCancellation(nHub, i, paBody)
	_aBad_ = _StzPiCheckFields(paBody, [ "raison" ], [ "raison" ])
	if len(_aBad_) = 0
		_m_ = [ "AC03", "AM09", "SVNR", "DUPL", "FRAD" ]
		_ok_ = 0
		for _j_ = 1 to len(_m_)
			if _m_[_j_] = "" + _StzPiGet(paBody, "raison", "")
				_ok_ = 1
			ok
		next
		if _ok_ = 0
			_aBad_ + _StzPiBad("raison", "Motif d'annulation inconnu")
		ok
	ok
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	if i = 0 or $aPiPay[i]["_sens"] != "ENVOYE"
		return _StzPiGone()
	ok
	if $aPiPay[i]["statut"] != "IRREVOCABLE"
		return _StzPiProblem(403, "Transaction non irrevocable",
			[ _StzPiBad("end2endId", "L'annulation ne peut pas etre demandee pour un transfert qui n'est pas irrevocable") ])
	ok
	if _StzPiTooOld(nHub, $aPiPay[i]["dateIrrevocabilite"])
		return _StzPiProblem(403, "Delai de demande d'annulation depasse",
			[ _StzPiBad("end2endId", "Une annulation ne peut etre demandee plus de 90 jours apres la date de paiement") ])
	ok
	if _StzPiGet($aPiPay[i], "annulationStatut", "") = "ACCEPTE" or _StzPiGet($aPiPay[i], "retourStatut", "") = "IRREVOCABLE"
		return _StzPiProblem(403, "Retour de fonds deja effectue",
			[ _StzPiBad("end2endId", "Les fonds ont deja ete retournes") ])
	ok
	$aPiPay[i]["annulationStatut"] = "ENVOYE"
	$aPiPay[i]["annulationMotif"] = _StzPiGet(paBody, "raison", "")
	$aPiPay[i]["annulationDateDemande"] = _StzPiNow(nHub)
	$aPiPay[i]["_annDue"] = _StzPiClock(nHub) + 20
	return _StzPiOk(200, _StzPiPublic($aPiPay[i]))

func _StzPiSettleCancel(nHub, i)
	$aPiPay[i]["_annDue"] = 0
	_a_ = $aPiPay[i]["_payeIndex"]
	_beh_ = $aPiAlias[_a_]["_cancel"]
	_now_ = _StzPiNow(nHub)
	$aPiPay[i]["annulationDateReponse"] = _now_
	if _beh_ = "accept"
		$aPiPay[i]["annulationStatut"] = "ACCEPTE"
		$aPiPay[i]["retourStatut"] = "IRREVOCABLE"
		$aPiPay[i]["retourDateIrrevocabilite"] = _now_
		_StzPiMove(nHub, $aPiPay[i]["montant"])
		_StzPiEmit(nHub, "RETOUR_RECU", $aPiPay[i], $aPiPay[i]["payeNom"], "CUST")
	else
		$aPiPay[i]["annulationStatut"] = "REJETE"
		$aPiPay[i]["annulationStatutRaison"] = _beh_
		_StzPiEmit(nHub, "ANNULATION_REJETE", $aPiPay[i], $aPiPay[i]["payeNom"], _beh_)
	ok

# we are the payee and were asked to cancel: accept (we return the funds) or refuse
func _StzPiAnswerCancellation(nHub, i, paBody)
	_aBad_ = _StzPiCheckFields(paBody, [ "decision" ], [ "decision" ])
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	if i = 0 or $aPiPay[i]["_sens"] != "RECU" or _StzPiGet($aPiPay[i], "annulationStatut", "") = ""
		return _StzPiProblem(404, "Demande d'annulation inexistante",
			[ _StzPiBad("end2endId", "Aucune demande d'annulation n'existe pour ce paiement") ])
	ok
	_yes_ = _StzPiGet(paBody, "decision", 0)
	_st_ = $aPiPay[i]["annulationStatut"]
	if _yes_ = 1
		if _st_ = "REJETE"
			return _StzPiForbidden("Impossible d'accepter une demande d'annulation deja refusee")
		ok
		if _st_ = "ENVOYE"
			$aPiPay[i]["annulationStatut"] = "ACCEPTE"
			$aPiPay[i]["annulationDateReponse"] = _StzPiNow(nHub)
			_StzPiStartReturn(nHub, i)
		ok
	else
		if _st_ = "ACCEPTE"
			return _StzPiForbidden("Impossible de refuser une demande d'annulation deja acceptee")
		ok
		if _st_ = "ENVOYE"
			$aPiPay[i]["annulationStatut"] = "REJETE"
			$aPiPay[i]["annulationStatutRaison"] = "CUST"
			$aPiPay[i]["annulationDateReponse"] = _StzPiNow(nHub)
		ok
	ok
	if $aPiHubs[nHub]["failAnswer"] = 1
		$aPiHubs[nHub]["failAnswer"] = 0
		_StzPiEmit(nHub, "ANNULATION_REPONSE_REJETE", $aPiPay[i], _StzPiGet($aPiPay[i], "payeurNom", ""), "FF10")
	ok
	return _StzPiOk(200, _StzPiPublic($aPiPay[i]))

#---------------------------------------------------------------------#
#  requests to pay                                                     #
#---------------------------------------------------------------------#

func _StzPiRtpFields()
	return [ "txId", "payeurAlias", "payeAlias", "logoUrl", "confirmation", "categorie",
		"dateLimitePaiement", "dateLimiteReponse", "montant", "montantAchat", "montantRetrait",
		"montantFrais", "remise", "debitDiffere", "motif", "refDocNumero", "refDocType" ]

func _StzPiRtpIndex(nHub, pcField, pcValue, pcSens)
	for _i_ = 1 to len($aPiRtp)
		if $aPiRtp[_i_]["_hub"] = nHub and $aPiRtp[_i_]["_sens"] = pcSens
			if "" + $aPiRtp[_i_][pcField] = pcValue
				return _i_
			ok
		ok
	next
	return 0

# [ index, record ] like a payment; a txId repeat is answered, never stored
func _StzPiNewRtp(nHub, paFields, pbConfirm, pcInstruction)
	_now_ = _StzPiNow(nHub)
	_rec_ = [ [ "_hub", nHub ], [ "_sens", "ENVOYE" ] ]
	for _i_ = 1 to len(paFields)
		_rec_ + [ paFields[_i_][1], paFields[_i_][2] ]
	next
	if pcInstruction != ""
		_rec_["instructionId"] = pcInstruction
	ok
	_rec_["confirmation"] = pbConfirm
	_rec_["end2endId"] = _StzPiE2E(nHub)
	_rec_["dateDemande"] = _now_
	_a_ = _StzPiAliasIndex(nHub, _StzPiGet(paFields, "payeurAlias", ""))
	if _a_ > 0
		_rec_["payeurNom"] = $aPiAlias[_a_]["_nom"]
		_rec_["payeurPays"] = $aPiAlias[_a_]["_pays"]
		_rec_["_payerIndex"] = _a_
	ok
	if _StzPiRtpIndex(nHub, "txId", "" + _StzPiGet(paFields, "txId", ""), "ENVOYE") > 0
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "DU03"
		_rec_["dateReponse"] = _now_
		if pcInstruction != ""
			$aPiRtp + _rec_
			return [ len($aPiRtp), _rec_ ]
		ok
		return [ 0, _rec_ ]
	ok
	if _a_ = 0
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "BE23"
		_rec_["dateReponse"] = _now_
		$aPiRtp + _rec_
		return [ len($aPiRtp), _rec_ ]
	ok
	if pbConfirm
		_rec_["statut"] = "INITIE"
		_rec_["_expires"] = _StzPiClock(nHub) + 86400
	else
		_rec_["statut"] = "ENVOYE"
		_rec_["dateConfirmation"] = _now_
		_rec_["dateEnvoi"] = _now_
		_rec_["_due"] = _StzPiClock(nHub) + 20
	ok
	$aPiRtp + _rec_
	return [ len($aPiRtp), _rec_ ]

func _StzPiCheckRtp(nHub, paBody, pbBulkItem)
	_aBad_ = []
	if pbBulkItem = 0
		_aBad_ = _StzPiCheckFields(paBody, _StzPiRtpFields(), [ "txId", "payeurAlias", "payeAlias", "montant", "confirmation", "categorie" ])
	ok
	_aC_ = _StzPiCheckCommon(paBody)
	for _i_ = 1 to len(_aC_)
		_aBad_ + _aC_[_i_]
	next
	if len(_aBad_) = 0 and pbBulkItem = 0
		_c_ = "" + _StzPiGet(paBody, "categorie", "")
		if _c_ != "500" and _c_ != "521" and _c_ != "401"
			_aBad_ + _StzPiBad("categorie", "Categorie inconnue: 500, 521 ou 401")
		ok
		if ( _c_ = "521" or _c_ = "401" ) and NOT _StzPiHas(paBody, "dateLimitePaiement")
			_aBad_ + _StzPiBad("dateLimitePaiement", "Champ obligatoire pour une demande e-commerce ou de facture")
		ok
		_a_ = _StzPiAliasIndex(nHub, _StzPiGet(paBody, "payeAlias", ""))
		if _a_ = 0 or $aPiAlias[_a_]["_own"] != 1
			_aBad_ + _StzPiBad("payeAlias", "L'alias du payeur (celui qui demande) doit etre un alias du client business")
		ok
	ok
	return _aBad_

func _StzPiRouteRtp(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "POST"
		_aBad_ = _StzPiCheckRtp(nHub, paBody, 0)
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		_aF_ = []
		for _i_ = 1 to len(paBody)
			if lower("" + paBody[_i_][1]) != "confirmation"
				_aF_ + [ paBody[_i_][1], paBody[_i_][2] ]
			ok
		next
		_aRes_ = _StzPiNewRtp(nHub, _aF_, _StzPiGet(paBody, "confirmation", 0), "")
		return _StzPiOk(200, _StzPiPublic(_aRes_[2]))
	ok
	if _n_ = 1 and pcM = "GET"
		return _StzPiListOf($aPiRtp, nHub, "_sens", "ENVOYE", paQuery)
	ok
	if _n_ = 2 and pcM = "GET"
		_i_ = _StzPiRtpIndex(nHub, "txId", paS[2], "ENVOYE")
		if _i_ = 0
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		return _StzPiOk(200, _StzPiPublic($aPiRtp[_i_]))
	ok
	if _n_ = 3 and lower(paS[3]) = "confirmations" and pcM = "PUT"
		return _StzPiConfirmRtp(nHub, paS[2], paBody)
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

func _StzPiConfirmRtp(nHub, pcTxId, paBody)
	_aBad_ = _StzPiCheckFields(paBody, [ "decision" ], [ "decision" ])
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	_i_ = _StzPiRtpIndex(nHub, "txId", pcTxId, "ENVOYE")
	if _i_ = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_st_ = $aPiRtp[_i_]["statut"]
	if _StzPiGet(paBody, "decision", 0) = 1
		if _st_ = "ANNULE"
			return _StzPiForbidden("Impossible de confirmer une demande deja annulee")
		ok
		if _st_ = "INITIE"
			if _StzPiClock(nHub) > $aPiRtp[_i_]["_expires"]
				return _StzPiForbidden("Le delai de confirmation de 24 heures a ete depasse")
			ok
			$aPiRtp[_i_]["statut"] = "ENVOYE"
			$aPiRtp[_i_]["dateConfirmation"] = _StzPiNow(nHub)
			$aPiRtp[_i_]["dateEnvoi"] = _StzPiNow(nHub)
			$aPiRtp[_i_]["_due"] = _StzPiClock(nHub) + 20
		ok
	else
		if _st_ = "INITIE"
			$aPiRtp[_i_]["statut"] = "ANNULE"
		but _st_ != "ANNULE"
			return _StzPiForbidden("Impossible d'annuler une demande deja confirmee")
		ok
	ok
	return _StzPiOk(200, _StzPiPublic($aPiRtp[_i_]))

# the payer answers: pays (a RECU payment, our balance rises) or refuses with its reason
func _StzPiSettleRtp(nHub, i)
	$aPiRtp[i]["_due"] = 0
	_beh_ = $aPiAlias[$aPiRtp[i]["_payerIndex"]]["_rtp"]
	_now_ = _StzPiNow(nHub)
	if _beh_ = "pay"
		$aPiRtp[i]["statut"] = "IRREVOCABLE"
		$aPiRtp[i]["dateIrrevocabilite"] = _now_
		_StzPiMove(nHub, $aPiRtp[i]["montant"])
		_rec_ = [ [ "_hub", nHub ], [ "_sens", "RECU" ], [ "txId", $aPiRtp[i]["txId"] ],
			[ "payeurAlias", $aPiRtp[i]["payeurAlias"] ], [ "payeAlias", $aPiRtp[i]["payeAlias"] ],
			[ "payeurNom", $aPiRtp[i]["payeurNom"] ], [ "payeurPays", $aPiRtp[i]["payeurPays"] ],
			[ "montant", $aPiRtp[i]["montant"] ], [ "categorie", $aPiRtp[i]["categorie"] ],
			[ "statut", "IRREVOCABLE" ], [ "end2endId", $aPiRtp[i]["end2endId"] ],
			[ "dateIrrevocabilite", _now_ ], [ "_payerIndex", $aPiRtp[i]["_payerIndex"] ] ]
		if _StzPiHas($aPiRtp[i], "motif")
			_rec_ + [ "motif", $aPiRtp[i]["motif"] ]
		ok
		if _StzPiHas($aPiRtp[i], "instructionId")
			_rec_ + [ "instructionId", $aPiRtp[i]["instructionId"] ]
		ok
		$aPiPay + _rec_
		_StzPiEmit(nHub, "PAIEMENT_RECU", $aPiRtp[i], $aPiRtp[i]["payeurNom"], _StzPiGet($aPiRtp[i], "motif", ""))
	else
		$aPiRtp[i]["statut"] = "REJETE"
		$aPiRtp[i]["statutRaison"] = _beh_
		$aPiRtp[i]["dateReponse"] = _now_
		_StzPiEmit(nHub, "RTP_REJETE", $aPiRtp[i], $aPiRtp[i]["payeurNom"], _beh_)
	ok

# requests we RECEIVED: we answer them. Accepting pays; the answer is idempotent.
func _StzPiRouteRtpReceived(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "GET"
		return _StzPiListOf($aPiRtp, nHub, "_sens", "RECU", paQuery)
	ok
	if _n_ >= 2
		_i_ = _StzPiRtpIndex(nHub, "end2endId", paS[2], "RECU")
		if _i_ = 0
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		if _n_ = 2 and pcM = "GET"
			return _StzPiOk(200, _StzPiPublic($aPiRtp[_i_]))
		ok
		if _n_ = 3 and lower(paS[3]) = "reponses" and pcM = "PUT"
			return _StzPiAnswerRtp(nHub, _i_, paBody)
		ok
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

func _StzPiAnswerRtp(nHub, i, paBody)
	_aBad_ = _StzPiCheckFields(paBody, [ "decision", "raison" ], [ "decision" ])
	if len(_aBad_) = 0 and _StzPiGet(paBody, "decision", 0) = 0
		_r_ = [ "BE05", "AM09", "APAR", "RR07", "FR01" ]
		_ok_ = 0
		for _j_ = 1 to len(_r_)
			if _r_[_j_] = "" + _StzPiGet(paBody, "raison", "")
				_ok_ = 1
			ok
		next
		if _ok_ = 0
			_aBad_ + _StzPiBad("raison", "Une raison est obligatoire pour rejeter: BE05, AM09, APAR, RR07 ou FR01")
		ok
	ok
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	_st_ = $aPiRtp[i]["statut"]
	if _StzPiGet(paBody, "decision", 0) = 1
		if _st_ = "REJETE"
			return _StzPiForbidden("Impossible d'accepter une demande de paiement deja rejetee")
		ok
		if _st_ = "ENVOYE"
			if $aPiRtp[i]["montant"] > _StzPiBalance(nHub)
				return _StzPiProblem(403, "Solde insuffisant", [ _StzPiBad("montant", "AG07") ])
			ok
			$aPiRtp[i]["statut"] = "IRREVOCABLE"
			_aF_ = [ [ "txId", "RTP-" + $aPiRtp[i]["end2endId"] ], [ "payeurAlias", $aPiRtp[i]["payeurAlias"] ],
				[ "payeAlias", $aPiRtp[i]["payeAlias"] ], [ "montant", $aPiRtp[i]["montant"] ] ]
			_aRes_ = _StzPiNewPayment(nHub, _aF_, 0, "")
			$aPiRtp[i]["_payE2E"] = _aRes_[2]["end2endId"]
		ok
	else
		if _st_ = "IRREVOCABLE"
			return _StzPiForbidden("Impossible de rejeter une demande de paiement deja acceptee")
		ok
		if _st_ = "ENVOYE"
			$aPiRtp[i]["statut"] = "REJETE"
			$aPiRtp[i]["statutRaison"] = _StzPiGet(paBody, "raison", "")
			$aPiRtp[i]["dateReponse"] = _StzPiNow(nHub)
		ok
	ok
	if $aPiHubs[nHub]["failAnswer"] = 1
		$aPiHubs[nHub]["failAnswer"] = 0
		_StzPiEmit(nHub, "RTP_REPONSE_REJETE", $aPiRtp[i], $aPiRtp[i]["payeAlias"], "FF10")
	ok
	return _StzPiOk(200, _StzPiPublic($aPiRtp[i]))

#---------------------------------------------------------------------#
#  bulk: one instructionId, one txId per item, answered 202            #
#---------------------------------------------------------------------#

func _StzPiBulkIndex(nHub, pcId, pcKind)
	for _i_ = 1 to len($aPiBulk)
		if $aPiBulk[_i_]["_hub"] = nHub and $aPiBulk[_i_]["_kind"] = pcKind and $aPiBulk[_i_]["instructionId"] = pcId
			return _i_
		ok
	next
	return 0

# the status of a bulk is DERIVED from its items, never stored twice
func _StzPiBulkStatus(nHub, i, pcKind)
	_id_ = $aPiBulk[i]["instructionId"]
	_tot_ = 0
	_ini_ = 0
	_env_ = 0
	_irr_ = 0
	_rej_ = 0
	if pcKind = "PAY"
		for _j_ = 1 to len($aPiPay)
			if $aPiPay[_j_]["_hub"] = nHub and _StzPiGet($aPiPay[_j_], "instructionId", "") = _id_ and $aPiPay[_j_]["_sens"] = "ENVOYE"
				_tot_++
				_s_ = $aPiPay[_j_]["statut"]
				if _s_ = "INITIE"  _ini_++  ok
				if _s_ = "ENVOYE"  _env_++  ok
				if _s_ = "IRREVOCABLE"  _irr_++  ok
				if _s_ = "REJETE"  _rej_++  ok
			ok
		next
	else
		for _j_ = 1 to len($aPiRtp)
			if $aPiRtp[_j_]["_hub"] = nHub and _StzPiGet($aPiRtp[_j_], "instructionId", "") = _id_ and $aPiRtp[_j_]["_sens"] = "ENVOYE"
				_tot_++
				_s_ = $aPiRtp[_j_]["statut"]
				if _s_ = "INITIE"  _ini_++  ok
				if _s_ = "ENVOYE"  _env_++  ok
				if _s_ = "IRREVOCABLE"  _irr_++  ok
				if _s_ = "REJETE"  _rej_++  ok
			ok
		next
	ok
	_a_ = _StzPiPublic($aPiBulk[i])
	_a_ + [ "transactionsTotal", _tot_ ]
	_a_ + [ "transactionsInitiees", _ini_ ]
	_a_ + [ "transactionsEnvoyees", _env_ ]
	_a_ + [ "transactionsIrrevocables", _irr_ ]
	_a_ + [ "transactionsRejetees", _rej_ ]
	return _a_

func _StzPiBulkItemFields(paItem, pcPayer, pcMotif, pcPayerKey)
	_aF_ = [ [ pcPayerKey, pcPayer ] ]
	for _i_ = 1 to len(paItem)
		_k_ = lower("" + paItem[_i_][1])
		if _k_ = "payeother"
			_aF_ + [ "payeCompte", paItem[_i_][2] ]
		else
			_aF_ + [ paItem[_i_][1], paItem[_i_][2] ]
		ok
	next
	if NOT _StzPiHas(_aF_, "motif") and pcMotif != ""
		_aF_ + [ "motif", pcMotif ]
	ok
	return _aF_

func _StzPiRouteBulkPay(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "POST"
		_aBad_ = _StzPiCheckFields(paBody, [ "instructionId", "payeurAlias", "confirmation", "motif", "transactions" ],
			[ "instructionId", "payeurAlias", "transactions" ])
		if len(_aBad_) = 0 and ( NOT isList(_StzPiGet(paBody, "transactions", 0)) or len(_StzPiGet(paBody, "transactions", [])) = 0 )
			_aBad_ + _StzPiBad("transactions", "Au moins une transaction est attendue")
		ok
		if len(_aBad_) = 0 and _StzPiAliasIndex(nHub, _StzPiGet(paBody, "payeurAlias", "")) = 0
			_aBad_ + _StzPiBad("payeurAlias", "Alias du payeur inconnu")
		ok
		_aT_ = _StzPiGet(paBody, "transactions", [])
		if len(_aBad_) = 0
			for _i_ = 1 to len(_aT_)
				_aB_ = _StzPiCheckFields(_aT_[_i_], [ "txId", "payeAlias", "payeIban", "payeOther", "payeParticipant", "montant", "motif", "refDocNumero", "refDocType" ], [ "txId", "montant" ])
				for _k_ = 1 to len(_aB_)
					_aBad_ + _StzPiBad("transactions[" + _i_ + "]." + _aB_[_k_][1][2], _aB_[_k_][2][2])
				next
				_aC_ = _StzPiCheckCommon(_aT_[_i_])
				for _k_ = 1 to len(_aC_)
					_aBad_ + _StzPiBad("transactions[" + _i_ + "]." + _aC_[_k_][1][2], _aC_[_k_][2][2])
				next
			next
		ok
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		_id_ = "" + _StzPiGet(paBody, "instructionId", "")
		if _StzPiBulkIndex(nHub, _id_, "PAY") > 0
			return _StzPiProblem(409, "Un paiement en masse avec cet instructionId existe deja",
				[ _StzPiBad("instructionId", "L'instructionId '" + _id_ + "' est deja utilise par un autre paiement en masse") ])
		ok
		_conf_ = _StzPiGet(paBody, "confirmation", 0)
		_now_ = _StzPiNow(nHub)
		_aRec_ = [ [ "_hub", nHub ], [ "_kind", "PAY" ], [ "instructionId", _id_ ], [ "statut", "CONFIRME" ],
			[ "dateDemande", _now_ ] ]
		if _conf_ = 1
			_aRec_["statut"] = "INITIE"
			_aRec_["_expires"] = _StzPiClock(nHub) + 86400
		else
			_aRec_["dateConfirmation"] = _now_
		ok
		$aPiBulk + _aRec_
		_b_ = len($aPiBulk)
		for _i_ = 1 to len(_aT_)
			_aF_ = _StzPiBulkItemFields(_aT_[_i_], _StzPiGet(paBody, "payeurAlias", ""), "" + _StzPiGet(paBody, "motif", ""), "payeurAlias")
			_StzPiNewPayment(nHub, _aF_, _conf_, _id_)
		next
		return _StzPiOk(202, _StzPiBulkStatus(nHub, _b_, "PAY"))
	ok
	if _n_ = 1 and pcM = "GET"
		_aL_ = []
		for _i_ = 1 to len($aPiBulk)
			if $aPiBulk[_i_]["_hub"] = nHub and $aPiBulk[_i_]["_kind"] = "PAY"
				_aL_ + $aPiBulk[_i_]
			ok
		next
		return _StzPiListed(_aL_, paQuery)
	ok
	return _StzPiBulkById(nHub, pcM, paS, paBody, "PAY")

func _StzPiBulkById(nHub, pcM, paS, paBody, pcKind)
	_n_ = len(paS)
	if _n_ < 2
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_b_ = _StzPiBulkIndex(nHub, paS[2], pcKind)
	if _b_ = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	if _n_ = 2 and pcM = "GET"
		return _StzPiOk(200, _StzPiBulkStatus(nHub, _b_, pcKind))
	ok
	if _n_ = 3 and lower(paS[3]) = "confirmations" and pcM = "PUT"
		_aBad_ = _StzPiCheckFields(paBody, [ "decision" ], [ "decision" ])
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		_st_ = $aPiBulk[_b_]["statut"]
		_id_ = $aPiBulk[_b_]["instructionId"]
		if _StzPiGet(paBody, "decision", 0) = 1
			if _st_ = "ANNULE"
				return _StzPiForbidden("Impossible de confirmer un lot deja annule")
			ok
			if _st_ = "INITIE"
				if _StzPiClock(nHub) > $aPiBulk[_b_]["_expires"]
					return _StzPiForbidden("Le delai de confirmation a ete depasse")
				ok
				$aPiBulk[_b_]["statut"] = "CONFIRME"
				$aPiBulk[_b_]["dateConfirmation"] = _StzPiNow(nHub)
				_StzPiBulkRelease(nHub, _id_, pcKind, 1)
			ok
		else
			if _st_ = "CONFIRME"
				return _StzPiForbidden("Impossible d'annuler un lot deja confirme")
			ok
			if _st_ = "INITIE"
				$aPiBulk[_b_]["statut"] = "ANNULE"
				_StzPiBulkRelease(nHub, _id_, pcKind, 0)
			ok
		ok
		return _StzPiOk(200, _StzPiBulkStatus(nHub, _b_, pcKind))
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

# confirm: the INITIE items go out (and are debited); cancel: they are ANNULE
func _StzPiBulkRelease(nHub, pcId, pcKind, pbSend)
	if pcKind = "PAY"
		for _j_ = 1 to len($aPiPay)
			if $aPiPay[_j_]["_hub"] = nHub and _StzPiGet($aPiPay[_j_], "instructionId", "") = pcId and $aPiPay[_j_]["statut"] = "INITIE"
				if pbSend = 0
					$aPiPay[_j_]["statut"] = "ANNULE"
				but $aPiPay[_j_]["montant"] > _StzPiBalance(nHub)
					$aPiPay[_j_]["statut"] = "REJETE"
					$aPiPay[_j_]["statutRaison"] = "AG07"
					$aPiPay[_j_]["dateReponse"] = _StzPiNow(nHub)
				else
					_StzPiSend(nHub, $aPiPay[_j_])
				ok
			ok
		next
	else
		for _j_ = 1 to len($aPiRtp)
			if $aPiRtp[_j_]["_hub"] = nHub and _StzPiGet($aPiRtp[_j_], "instructionId", "") = pcId and $aPiRtp[_j_]["statut"] = "INITIE"
				if pbSend = 0
					$aPiRtp[_j_]["statut"] = "ANNULE"
				else
					$aPiRtp[_j_]["statut"] = "ENVOYE"
					$aPiRtp[_j_]["dateConfirmation"] = _StzPiNow(nHub)
					$aPiRtp[_j_]["dateEnvoi"] = _StzPiNow(nHub)
					$aPiRtp[_j_]["_due"] = _StzPiClock(nHub) + 20
				ok
			ok
		next
	ok

func _StzPiRouteBulkRtp(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "POST"
		_aBad_ = _StzPiCheckFields(paBody, [ "instructionId", "payeAlias", "confirmation", "categorie", "motif", "transactions" ],
			[ "instructionId", "payeAlias", "transactions" ])
		if len(_aBad_) = 0 and ( NOT isList(_StzPiGet(paBody, "transactions", 0)) or len(_StzPiGet(paBody, "transactions", [])) = 0 )
			_aBad_ + _StzPiBad("transactions", "Au moins une transaction est attendue")
		ok
		_a_ = _StzPiAliasIndex(nHub, _StzPiGet(paBody, "payeAlias", ""))
		if len(_aBad_) = 0 and ( _a_ = 0 or $aPiAlias[_a_]["_own"] != 1 )
			_aBad_ + _StzPiBad("payeAlias", "L'alias qui demande doit etre un alias du client business")
		ok
		_aT_ = _StzPiGet(paBody, "transactions", [])
		if len(_aBad_) = 0
			for _i_ = 1 to len(_aT_)
				_aB_ = _StzPiCheckFields(_aT_[_i_], [ "txId", "payeurAlias", "montant", "motif", "refDocNumero", "refDocType" ], [ "txId", "payeurAlias", "montant" ])
				for _k_ = 1 to len(_aB_)
					_aBad_ + _StzPiBad("transactions[" + _i_ + "]." + _aB_[_k_][1][2], _aB_[_k_][2][2])
				next
			next
		ok
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		_id_ = "" + _StzPiGet(paBody, "instructionId", "")
		if _StzPiBulkIndex(nHub, _id_, "RTP") > 0
			return _StzPiProblem(409, "Une demande de paiement en masse avec cet instructionId existe deja",
				[ _StzPiBad("instructionId", "L'instructionId '" + _id_ + "' est deja utilise") ])
		ok
		_conf_ = _StzPiGet(paBody, "confirmation", 0)
		_now_ = _StzPiNow(nHub)
		_aRec_ = [ [ "_hub", nHub ], [ "_kind", "RTP" ], [ "instructionId", _id_ ], [ "statut", "CONFIRME" ],
			[ "dateDemande", _now_ ] ]
		if _conf_ = 1
			_aRec_["statut"] = "INITIE"
			_aRec_["_expires"] = _StzPiClock(nHub) + 86400
		else
			_aRec_["dateConfirmation"] = _now_
		ok
		$aPiBulk + _aRec_
		_b_ = len($aPiBulk)
		_cat_ = "" + _StzPiGet(paBody, "categorie", "401")
		for _i_ = 1 to len(_aT_)
			_aF_ = _StzPiBulkItemFields(_aT_[_i_], _StzPiGet(paBody, "payeAlias", ""), "" + _StzPiGet(paBody, "motif", ""), "payeAlias")
			_aF_ + [ "categorie", _cat_ ]
			_StzPiNewRtp(nHub, _aF_, _conf_, _id_)
		next
		return _StzPiOk(202, _StzPiBulkStatus(nHub, _b_, "RTP"))
	ok
	if _n_ = 1 and pcM = "GET"
		_aL_ = []
		for _i_ = 1 to len($aPiBulk)
			if $aPiBulk[_i_]["_hub"] = nHub and $aPiBulk[_i_]["_kind"] = "RTP"
				_aL_ + $aPiBulk[_i_]
			ok
		next
		return _StzPiListed(_aL_, paQuery)
	ok
	return _StzPiBulkById(nHub, pcM, paS, paBody, "RTP")

#---------------------------------------------------------------------#
#  accounts, aliases, participants                                     #
#---------------------------------------------------------------------#

func _StzPiRouteAccounts(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "GET"
		_a_ = []
		for _i_ = 1 to len($aPiAcc)
			if $aPiAcc[_i_]["_hub"] = nHub
				_a_ + [ [ "_hub", nHub ], [ "numero", $aPiAcc[_i_]["numero"] ], [ "type", $aPiAcc[_i_]["type"] ],
					[ "dateOuverture", $aPiAcc[_i_]["dateOuverture"] ], [ "statut", $aPiAcc[_i_]["statut"] ] ]
			ok
		next
		return _StzPiListed(_a_, paQuery)
	ok
	if _n_ >= 2 and lower(paS[2]) = "transactions"
		return _StzPiRouteTransfers(nHub, pcM, paQuery, paBody)
	ok
	if _n_ = 2 and pcM = "GET"
		_i_ = _StzPiAccountIndex(nHub, paS[2])
		if _i_ = 0
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		return _StzPiOk(200, [ [ "type", $aPiAcc[_i_]["type"] ], [ "numero", $aPiAcc[_i_]["numero"] ],
			[ "solde", $aPiAcc[_i_]["solde"] ], [ "statut", $aPiAcc[_i_]["statut"] ],
			[ "dateOuverture", $aPiAcc[_i_]["dateOuverture"] ] ])
	ok
	if _n_ >= 3 and lower(paS[3]) = "alias"
		return _StzPiRouteAliases(nHub, pcM, paS, paQuery, paBody)
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

func _StzPiRouteAliases(nHub, pcM, paS, paQuery, paBody)
	_n_ = len(paS)
	if _StzPiAccountIndex(nHub, paS[2]) = 0
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	if _n_ = 3 and pcM = "GET"
		_a_ = []
		for _i_ = 1 to len($aPiAlias)
			if $aPiAlias[_i_]["_hub"] = nHub and $aPiAlias[_i_]["compte"] = paS[2] and $aPiAlias[_i_]["_own"] = 1
				_a_ + $aPiAlias[_i_]
			ok
		next
		return _StzPiListed(_a_, paQuery)
	ok
	if _n_ = 3 and pcM = "POST"
		_aBad_ = _StzPiCheckFields(paBody, [ "type" ], [ "type" ])
		if len(_aBad_) = 0 and "" + _StzPiGet(paBody, "type", "") != "SHID" and "" + _StzPiGet(paBody, "type", "") != "MCOD"
			_aBad_ + _StzPiBad("type", "Type d'alias: SHID ou MCOD")
		ok
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		_cnt_ = 0
		for _i_ = 1 to len($aPiAlias)
			if $aPiAlias[_i_]["_hub"] = nHub and $aPiAlias[_i_]["compte"] = paS[2] and $aPiAlias[_i_]["_own"] = 1
				_cnt_++
			ok
		next
		if _cnt_ >= 5
			return _StzPiProblem(403, "Limite d'alias atteinte", [ _StzPiBad("compte", "Au plus 5 alias par compte") ])
		ok
		_seq_ = $aPiHubs[nHub]["seq"] + 1
		$aPiHubs[nHub]["seq"] = _seq_
		_n10_ = "" + _seq_
		while len(_n10_) < 12
			_n10_ = "0" + _n10_
		end
		_cle_ = "a11a0000-0000-4000-8000-" + _n10_
		_StzPiSeedAlias(nHub, _cle_, paS[2], "Plateforme DIKO", "NE", "B", 1, "ok", "pay", "accept")
		$aPiAlias[len($aPiAlias)]["type"] = _StzPiGet(paBody, "type", "SHID")
		$aPiAlias[len($aPiAlias)]["dateCreation"] = _StzPiNow(nHub)
		return _StzPiOk(201, _StzPiPublic($aPiAlias[len($aPiAlias)]))
	ok
	if _n_ = 4 and pcM = "DELETE"
		_i_ = _StzPiAliasIndex(nHub, paS[4])
		if _i_ = 0 or $aPiAlias[_i_]["_own"] != 1 or $aPiAlias[_i_]["compte"] != paS[2]
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		$aPiAlias[_i_]["_own"] = 0
		$aPiAlias[_i_]["cle"] = "deleted-" + $aPiAlias[_i_]["cle"]
		return _StzPiOk(204, "")
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

func _StzPiRouteAliasLookup(nHub, pcCle)
	_i_ = _StzPiAliasIndex(nHub, pcCle)
	if _i_ = 0
		return _StzPiNotFound("L'alias n'existe pas dans le systeme")
	ok
	return _StzPiOk(200, [ [ "client", [ [ "nom", $aPiAlias[_i_]["_nom"] ], [ "pays", $aPiAlias[_i_]["_pays"] ],
		[ "categorie", $aPiAlias[_i_]["_cat"] ] ] ], [ "alias", [ [ "cle", $aPiAlias[_i_]["cle"] ] ] ] ])

# VIRTUAL participants of the twin. This is NOT the BCEAO's list (GET /participants at the
# hub is), and it carries no claim about who is homologated.
func _StzPiRouteParticipants(paQuery)
	_a_ = [ [ [ "codeMembre", "NEB001" ], [ "nomMembre", "Banque Simulee Niger" ], [ "codeBanque", "NE001" ], [ "statut", "ENBL" ] ],
		[ [ "codeMembre", "NEE002" ], [ "nomMembre", "Emetteur Simule Niger" ], [ "statut", "ENBL" ] ],
		[ [ "codeMembre", "SNB015" ], [ "nomMembre", "Banque Exemple Senegal" ], [ "codeBanque", "SN015" ], [ "statut", "ENBL" ] ],
		[ [ "codeMembre", "CIE042" ], [ "nomMembre", "Emetteur Exemple Cote d'Ivoire" ], [ "statut", "ENBL" ] ],
		[ [ "codeMembre", "MLB099" ], [ "nomMembre", "Banque Simulee Suspendue" ], [ "codeBanque", "ML099" ], [ "statut", "DSBL" ] ] ]
	return _StzPiListed(_a_, paQuery)

func _StzPiRouteTransfers(nHub, pcM, paQuery, paBody)
	if pcM = "GET"
		return _StzPiListOf($aPiTx, nHub, "", "", paQuery)
	ok
	if pcM != "POST"
		return _StzPiNotFound("La ressource n'existe pas dans le systeme")
	ok
	_aBad_ = _StzPiCheckFields(paBody, [ "txId", "payeurNumero", "payeNumero", "montant" ], [ "txId", "payeurNumero", "payeNumero", "montant" ])
	_aC_ = _StzPiCheckCommon(paBody)
	for _i_ = 1 to len(_aC_)
		_aBad_ + _aC_[_i_]
	next
	if len(_aBad_) > 0
		return _StzPiBadRequest(_aBad_)
	ok
	for _i_ = 1 to len($aPiTx)
		if $aPiTx[_i_]["_hub"] = nHub and $aPiTx[_i_]["txId"] = "" + _StzPiGet(paBody, "txId", "")
			return _StzPiProblem(409, "Une transaction avec ce txId existe deja",
				[ _StzPiBad("txId", "Le txId est deja utilise") ])
		ok
	next
	_a_ = _StzPiAccountIndex(nHub, _StzPiGet(paBody, "payeurNumero", ""))
	_b_ = _StzPiAccountIndex(nHub, _StzPiGet(paBody, "payeNumero", ""))
	if _a_ = 0 or _b_ = 0
		return _StzPiNotFound("Un des comptes n'existe pas dans le systeme")
	ok
	_rec_ = [ [ "_hub", nHub ] ]
	for _i_ = 1 to len(paBody)
		_rec_ + [ paBody[_i_][1], paBody[_i_][2] ]
	next
	_rec_["dateEnvoi"] = _StzPiNow(nHub)
	_m_ = _StzPiGet(paBody, "montant", 0)
	if $aPiAcc[_a_]["statut"] != "OUVERT" or $aPiAcc[_b_]["statut"] != "OUVERT"
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "AC06"
	but _m_ > $aPiAcc[_a_]["solde"]
		_rec_["statut"] = "REJETE"
		_rec_["statutRaison"] = "AG07"
	else
		$aPiAcc[_a_]["solde"] = $aPiAcc[_a_]["solde"] - _m_
		$aPiAcc[_b_]["solde"] = $aPiAcc[_b_]["solde"] + _m_
		_rec_["statut"] = "IRREVOCABLE"
		_rec_["dateIrrevocabilite"] = _StzPiNow(nHub)
	ok
	$aPiTx + _rec_
	return _StzPiOk(200, _StzPiPublic(_rec_))

#---------------------------------------------------------------------#
#  webhooks: at most 20, a secret returned once, renewable             #
#---------------------------------------------------------------------#

func _StzPiEventNames()
	return [ "PAIEMENT_RECU", "PAIEMENT_ENVOYE", "PAIEMENT_REJETE", "RTP_RECU", "RTP_REJETE",
		"ANNULATION_DEMANDE", "ANNULATION_REJETE", "RETOUR_ENVOYE", "RETOUR_REJETE", "RETOUR_RECU" ]

func _StzPiCheckHook(paBody, pbCreate)
	_aBad_ = _StzPiCheckFields(paBody, [ "callbackUrl", "alias", "events" ], [])
	if pbCreate and NOT _StzPiHas(paBody, "callbackUrl")
		_aBad_ + _StzPiBad("callbackUrl", "Champ obligatoire")
	ok
	if _StzPiHas(paBody, "callbackUrl") and StzLeft("" + _StzPiGet(paBody, "callbackUrl", ""), 8) != "https://"
		_aBad_ + _StzPiBad("callbackUrl", "Le lien de rappel doit etre en HTTPS")
	ok
	if _StzPiHas(paBody, "events")
		_e_ = _StzPiGet(paBody, "events", [])
		_names_ = _StzPiEventNames()
		for _i_ = 1 to len(_e_)
			_ok_ = 0
			for _j_ = 1 to len(_names_)
				if _names_[_j_] = "" + _e_[_i_]
					_ok_ = 1
				ok
			next
			if _ok_ = 0
				_aBad_ + _StzPiBad("events", "Evenement inconnu: " + _e_[_i_])
			ok
		next
	ok
	return _aBad_

func _StzPiHookPublic(i, pbSecret)
	_a_ = [ [ "id", $aPiHooks[i]["id"] ], [ "callbackUrl", $aPiHooks[i]["callbackUrl"] ] ]
	if $aPiHooks[i]["alias"] != ""
		_a_ + [ "alias", $aPiHooks[i]["alias"] ]
	ok
	_a_ + [ "events", $aPiHooks[i]["events"] ]
	_a_ + [ "dateCreation", $aPiHooks[i]["dateCreation"] ]
	if pbSecret
		_a_ + [ "secret", $aPiHooks[i]["_secretShown"] ]
	else
		_a_ + [ "dateModification", $aPiHooks[i]["dateModification"] ]
	ok
	return _a_

func _StzPiRouteWebhooks(nHub, pcM, paS, paBody)
	_n_ = len(paS)
	if _n_ = 1 and pcM = "POST"
		_aBad_ = _StzPiCheckHook(paBody, 1)
		if len(_aBad_) > 0
			return _StzPiBadRequest(_aBad_)
		ok
		if _StzPiHookCount(nHub) >= 20
			return _StzPiForbidden("Un business peut configurer au plus 20 webhooks")
		ok
		_url_ = "" + _StzPiGet(paBody, "callbackUrl", "")
		_al_ = "" + _StzPiGet(paBody, "alias", "")
		_ev_ = _StzPiGet(paBody, "events", [])
		for _i_ = 1 to len($aPiHooks)
			if $aPiHooks[_i_]["_hub"] = nHub and $aPiHooks[_i_]["callbackUrl"] = _url_ and $aPiHooks[_i_]["alias"] = _al_ and
			   ListToJson($aPiHooks[_i_]["events"]) = ListToJson(_ev_)
				return _StzPiProblem(409, "La ressource existe deja.", [])
			ok
		next
		$aPiHubs[nHub]["hookSeq"] = $aPiHubs[nHub]["hookSeq"] + 1
		_sec_ = _StzPiRandHex(32)
		$aPiHooks + [ [ "_hub", nHub ], [ "id", "wh-" + $aPiHubs[nHub]["hookSeq"] ], [ "callbackUrl", _url_ ],
			[ "alias", _al_ ], [ "events", _ev_ ], [ "dateCreation", _StzPiNow(nHub) ],
			[ "dateModification", _StzPiNow(nHub) ], [ "_secret", _sec_ ], [ "_secretShown", _sec_ ],
			[ "_secret2", "" ], [ "_switchAt", 0 ] ]
		return _StzPiOk(201, _StzPiHookPublic(len($aPiHooks), 1))
	ok
	if _n_ = 1 and pcM = "GET"
		_a_ = []
		for _i_ = 1 to len($aPiHooks)
			if $aPiHooks[_i_]["_hub"] = nHub
				_a_ + _StzPiHookPublic(_i_, 0)
			ok
		next
		return _StzPiOk(200, [ [ "data", _a_ ], [ "meta", [ [ "total", len(_a_) ] ] ] ])
	ok
	if _n_ >= 2
		_i_ = _StzPiHookIndex(nHub, paS[2])
		if _i_ = 0
			return _StzPiNotFound("La ressource n'existe pas dans le systeme")
		ok
		if _n_ = 2 and pcM = "GET"
			return _StzPiOk(200, _StzPiHookPublic(_i_, 0))
		ok
		if _n_ = 2 and pcM = "DELETE"
			$aPiHooks[_i_]["_hub"] = 0
			return _StzPiOk(204, "")
		ok
		if _n_ = 2 and pcM = "PUT"
			_aBad_ = _StzPiCheckHook(paBody, 0)
			if len(_aBad_) = 0 and len(paBody) = 0
				_aBad_ + _StzPiBad("callbackUrl", "Au moins un champ a modifier")
			ok
			if len(_aBad_) > 0
				return _StzPiBadRequest(_aBad_)
			ok
			if _StzPiHas(paBody, "callbackUrl")
				$aPiHooks[_i_]["callbackUrl"] = "" + _StzPiGet(paBody, "callbackUrl", "")
			ok
			if _StzPiHas(paBody, "alias")
				$aPiHooks[_i_]["alias"] = "" + _StzPiGet(paBody, "alias", "")
			ok
			if _StzPiHas(paBody, "events")
				$aPiHooks[_i_]["events"] = _StzPiGet(paBody, "events", [])
			ok
			$aPiHooks[_i_]["dateModification"] = _StzPiNow(nHub)
			return _StzPiOk(200, _StzPiHookPublic(_i_, 0))
		ok
		if _n_ = 3 and lower(paS[3]) = "secrets" and pcM = "POST"
			_aBad_ = _StzPiCheckFields(paBody, [ "dateExpiration" ], [ "dateExpiration" ])
			_at_ = _StzPiEpochOf("" + _StzPiGet(paBody, "dateExpiration", ""))
			if len(_aBad_) = 0 and _at_ < 0
				_aBad_ + _StzPiBad("dateExpiration", "Date-heure ISO 8601 attendue")
			ok
			if len(_aBad_) > 0
				return _StzPiBadRequest(_aBad_)
			ok
			_new_ = _StzPiRandHex(32)
			$aPiHooks[_i_]["_secret2"] = _new_
			$aPiHooks[_i_]["_secretShown"] = _new_
			$aPiHooks[_i_]["_switchAt"] = _at_
			$aPiHooks[_i_]["dateModification"] = _StzPiNow(nHub)
			return _StzPiOk(200, _StzPiHookPublic(_i_, 1))
		ok
	ok
	return _StzPiNotFound("La ressource n'existe pas dans le systeme")

#---------------------------------------------------------------------#
#  the simulated customers, by the name a guard uses                   #
#---------------------------------------------------------------------#

func _StzPiWho(pcWho)
	_w_ = lower("" + pcWho)
	if _w_ = "business"   return _StzPiOwnAlias()  ok
	if _w_ = "fatou"      return "9b1b2499-3e50-435b-b757-ac7a83d8aa8c"  ok
	if _w_ = "boutique"   return "aaaa0001-0000-4000-8000-000000000001"  ok
	if _w_ = "kdi"        return "bbbb0002-0000-4000-8000-000000000002"  ok
	if _w_ = "blocked"    return "cccc0003-0000-4000-8000-000000000003"  ok
	if _w_ = "stubborn"   return "dddd0004-0000-4000-8000-000000000004"  ok
	return "" + pcWho

# a payment that arrives from a customer: our balance rises, PAIEMENT_RECU goes out
func _StzPiIncomingPayment(nHub, pcWho, pnMontant, pcMotif)
	_a_ = _StzPiAliasIndex(nHub, _StzPiWho(pcWho))
	if _a_ = 0
		StzRaise("The twin knows no customer '" + pcWho + "'.")
	ok
	_now_ = _StzPiNow(nHub)
	_e_ = _StzPiE2E(nHub)
	_rec_ = [ [ "_hub", nHub ], [ "_sens", "RECU" ], [ "txId", "IN-" + _e_ ],
		[ "payeurAlias", $aPiAlias[_a_]["cle"] ], [ "payeAlias", _StzPiOwnAlias() ],
		[ "payeurNom", $aPiAlias[_a_]["_nom"] ], [ "payeurPays", $aPiAlias[_a_]["_pays"] ],
		[ "montant", pnMontant ], [ "categorie", "400" ], [ "statut", "IRREVOCABLE" ],
		[ "end2endId", _e_ ], [ "dateDemande", _now_ ], [ "dateIrrevocabilite", _now_ ],
		[ "_payerIndex", _a_ ] ]
	if pcMotif != ""
		_rec_ + [ "motif", pcMotif ]
	ok
	_StzPiMove(nHub, pnMontant)
	$aPiPay + _rec_
	_StzPiEmit(nHub, "PAIEMENT_RECU", _rec_, $aPiAlias[_a_]["_nom"], pcMotif)
	return _e_

# a request to pay that arrives from a customer: RTP_RECU goes out
func _StzPiIncomingRequest(nHub, pcWho, pnMontant, pcMotif)
	_a_ = _StzPiAliasIndex(nHub, _StzPiWho(pcWho))
	if _a_ = 0
		StzRaise("The twin knows no customer '" + pcWho + "'.")
	ok
	_now_ = _StzPiNow(nHub)
	_e_ = _StzPiE2E(nHub)
	_rec_ = [ [ "_hub", nHub ], [ "_sens", "RECU" ], [ "txId", "RTPIN-" + _e_ ],
		[ "payeurAlias", _StzPiOwnAlias() ], [ "payeAlias", $aPiAlias[_a_]["cle"] ],
		[ "payeNom", $aPiAlias[_a_]["_nom"] ], [ "payePays", $aPiAlias[_a_]["_pays"] ],
		[ "montant", pnMontant ], [ "categorie", "401" ], [ "statut", "ENVOYE" ],
		[ "end2endId", _e_ ], [ "dateDemande", _now_ ],
		[ "dateLimiteReponse", _StzPiIso(_StzPiClock(nHub) + 90 * 86400) ] ]
	if pcMotif != ""
		_rec_ + [ "motif", pcMotif ]
	ok
	$aPiRtp + _rec_
	_StzPiEmit(nHub, "RTP_RECU", _rec_, $aPiAlias[_a_]["_nom"], pcMotif)
	return _e_

# a customer asks us to cancel a payment we received: ANNULATION_DEMANDE goes out
func _StzPiIncomingCancellation(nHub, pcE2E, pcMotif)
	_i_ = _StzPiPayByE2E(nHub, pcE2E)
	if _i_ = 0 or $aPiPay[_i_]["_sens"] != "RECU"
		StzRaise("The twin has no received payment " + pcE2E + ".")
	ok
	$aPiPay[_i_]["annulationStatut"] = "ENVOYE"
	$aPiPay[_i_]["annulationMotif"] = pcMotif
	$aPiPay[_i_]["annulationDateDemande"] = _StzPiNow(nHub)
	_StzPiEmit(nHub, "ANNULATION_DEMANDE", $aPiPay[_i_], _StzPiGet($aPiPay[_i_], "payeurNom", ""), pcMotif)

#---------------------------------------------------------------------#
#  the face                                                            #
#---------------------------------------------------------------------#

class stzPiSpiSandbox from stzObject

	@nId = 0

	def init()
		@nId = _StzPiNewHub()

	# a double declares itself -- see stzServiceRegistry
	def IsSandbox()
		return 1

	def Id()
		return @nId

	# a face onto a hub that already exists (state is global, so a face is only an id): how the
	# HTTP front's handler reaches the twin it serves
	def AdoptHub(pnId)
		@nId = pnId
		return This

	# THE contract: [ httpStatus, body ]. body is a list, or "" for a 204.
	def Request(pcMethod, pcPath, paQuery, paBody)
		_aQ_ = []
		if isList(paQuery)
			_aQ_ = paQuery
		ok
		_aB_ = []
		if isList(paBody)
			_aB_ = paBody
		ok
		return _StzPiRequest(@nId, pcMethod, pcPath, _aQ_, _aB_)

	  #-- time ----------------------------------------------------------

	def Now()
		return _StzPiNow(@nId)

	# the twin's clock moves only when asked, or by one second per request
	def AdvanceSeconds(pn)
		$aPiHubs[@nId]["clock"] = $aPiHubs[@nId]["clock"] + pn
		_StzPiSettle(@nId, 0)
		return This

	# everything pending becomes final now, as if 20 seconds had passed
	def SettleEverything()
		_StzPiSettle(@nId, 1)
		return This

	def SetRateLimit(pnPerMinute, pnPerDay)
		$aPiHubs[@nId]["perMin"] = pnPerMinute
		$aPiHubs[@nId]["perDay"] = pnPerDay
		return This

	  #-- the world it simulates ----------------------------------------

	def Alias(pcWho)
		return _StzPiWho(pcWho)

	def BusinessAlias()
		return _StzPiOwnAlias()

	def BusinessAccount()
		return "NE2344256727788288822"

	def Balance()
		return _StzPiBalance(@nId)

	# how a customer's side answers: a payment ("ok" or the reason it rejects with), a
	# request to pay ("pay" or the reason), a cancellation ("accept" or the reason)
	def SetCounterparty(pcWho, pcPay, pcRtp, pcCancel)
		_i_ = _StzPiAliasIndex(@nId, _StzPiWho(pcWho))
		if _i_ = 0
			StzRaise("The twin knows no customer '" + pcWho + "'.")
		ok
		$aPiAlias[_i_]["_pay"] = pcPay
		$aPiAlias[_i_]["_rtp"] = pcRtp
		$aPiAlias[_i_]["_cancel"] = pcCancel
		return This

	def AddCounterparty(pcAlias, pcName, pcCountry, pcCategory)
		_StzPiSeedAlias(@nId, pcAlias, "SIM" + ring_len($aPiAlias), pcName, pcCountry, pcCategory, 0, "ok", "pay", "accept")
		return This

	  #-- what arrives without being asked ------------------------------

	def SimulateIncomingPayment(pcWho, pnMontant, pcMotif)
		return _StzPiIncomingPayment(@nId, pcWho, pnMontant, pcMotif)

	def SimulateIncomingRequest(pcWho, pnMontant, pcMotif)
		return _StzPiIncomingRequest(@nId, pcWho, pnMontant, pcMotif)

	def SimulateCancellationRequest(pcEnd2EndId, pcMotif)
		_StzPiIncomingCancellation(@nId, pcEnd2EndId, pcMotif)
		return This

	# the hub rejects the NEXT answer we give (a request to pay, or a cancellation), so
	# RTP_REPONSE_REJETE and ANNULATION_REPONSE_REJETE can be seen
	def FailNextAnswer()
		$aPiHubs[@nId]["failAnswer"] = 1
		return This

	  #-- the webhooks it sends -----------------------------------------

	def NumberOfDeliveries()
		_n_ = 0
		for _i_ = 1 to ring_len($aPiOut)
			if $aPiOut[_i_]["_hub"] = @nId
				_n_++
			ok
		next
		return _n_

	def NumberOfUndelivered()
		_n_ = 0
		for _i_ = 1 to ring_len($aPiOut)
			if $aPiOut[_i_]["_hub"] = @nId and $aPiOut[_i_]["delivered"] = 0
				_n_++
			ok
		next
		return _n_

	# every delivery, oldest first: [ hookId, callbackUrl, evCode, body, signature, delivered ]
	def Deliveries()
		_a_ = []
		for _i_ = 1 to ring_len($aPiOut)
			if $aPiOut[_i_]["_hub"] = @nId
				_a_ + _StzPiPublic($aPiOut[_i_])
			ok
		next
		return _a_

	# hands each undelivered event to poHandler.ReceiveWebhook(body, signature), marks it
	# delivered, answers how many it handed over. The port is such a handler.
	def DeliverTo(poHandler)
		_n_ = 0
		for _i_ = 1 to ring_len($aPiOut)
			if $aPiOut[_i_]["_hub"] = @nId and $aPiOut[_i_]["delivered"] = 0
				$aPiOut[_i_]["delivered"] = 1
				poHandler.ReceiveWebhook($aPiOut[_i_]["body"], $aPiOut[_i_]["signature"])
				_n_++
			ok
		next
		return _n_

	# every undelivered webhook, oldest first, marked delivered: what a hub's delivery loop would POST.
	# [ hookId, callbackUrl, evCode, body, signature ] as records
	def TakeUndelivered()
		_a_ = []
		for _i_ = 1 to ring_len($aPiOut)
			if $aPiOut[_i_]["_hub"] = @nId and $aPiOut[_i_]["delivered"] = 0
				$aPiOut[_i_]["delivered"] = 1
				_a_ + [ [ "hookId", $aPiOut[_i_]["hookId"] ], [ "callbackUrl", $aPiOut[_i_]["callbackUrl"] ],
					[ "evCode", $aPiOut[_i_]["evCode"] ], [ "body", $aPiOut[_i_]["body"] ],
					[ "signature", $aPiOut[_i_]["signature"] ] ]
			ok
		next
		return _a_

	def LastCallbackBody()
		_a_ = This.Deliveries()
		if ring_len(_a_) = 0
			return ""
		ok
		return _a_[ring_len(_a_)]["body"]

	def LastCallbackSignature()
		_a_ = This.Deliveries()
		if ring_len(_a_) = 0
			return ""
		ok
		return _a_[ring_len(_a_)]["signature"]

	# the secret the hub returned when the newest webhook was created or renewed
	def LastWebhookSecret()
		for _i_ = ring_len($aPiHooks) to 1 step -1
			if $aPiHooks[_i_]["_hub"] = @nId
				return $aPiHooks[_i_]["_secretShown"]
			ok
		next
		return ""

	  #-- a count of what happened, for a test to assert on --------------

	def NumberOfPayments(pcSide)
		_n_ = 0
		for _i_ = 1 to ring_len($aPiPay)
			if $aPiPay[_i_]["_hub"] = @nId and $aPiPay[_i_]["_sens"] = pcSide
				_n_++
			ok
		next
		return _n_

	def Show()
		? "stzPiSpiSandbox #" + @nId + " at " + This.Now() + ": " + This.NumberOfPayments("ENVOYE") +
			" sent, " + This.NumberOfPayments("RECU") + " received, balance " + This.Balance() + " XOF, " +
			This.NumberOfDeliveries() + " webhook(s)"
