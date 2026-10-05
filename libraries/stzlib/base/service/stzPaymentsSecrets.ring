#================================================================#
#  STZPAYMENTSSECRETS -- the five secrets of a live payment (PY3)     #
#================================================================#

/*--- What a platform keeps to pay through a participant's API Business, and what watches it.

A live payment needs five things nobody may keep in a versioned file, a memo or a guard:

    pispi-<participant>-client          the OAuth client id and secret (client credentials grant)
    pispi-<participant>-api-key         the key sent in x-api-key
    pispi-<participant>-mtls-key        the private key of the mTLS client identity
    pispi-<participant>-mtls-cert       its certificate, issued by the BCEAO's CA
    pispi-<participant>-webhook-secret  the HMAC secret of one webhook

Each is a descriptor in the platform's stzSecretStore, named for whose it is, and each CAN
EXPIRE: the sandbox's certificate lasts 365 days, a renewed webhook secret lapses on the date
the platform gave. A descriptor is a stzToken underneath, because a token is the one kind of
secret the store already knows how to expire; its kind says which part it is.

    oStore = StzSecretStoreQ("diko")
    StzPispiRegisterDescriptors(oStore, "bia")      # five names, no values yet

A descriptor with no value is a NAME, not a credential: the registry refuses a live binding
that points at one (live-without-secret), and refuses one whose certificate has lapsed
(live-without-certificate). The value arrives from wherever values arrive, an environment
variable, a file, a vault. A guard that needs one GENERATES it.

EXPIRY IS A DETECTION, NOT A CHECK AT CALL TIME. The port never looks at a date. A watch
(stzSecretExpiryWatch) reads the store, writes `secret.expiring` and `secret.expired` into the
security ledger once per change of state, and the detections of StzPaymentsDetectionSet raise
them in the house shape, so they join stzRuleReport, the one CI gate. The portal's own advice
is an alert under 30 days, which is the default window.

A WATCH HOLDS THE STORE AS IT WAS HANDED OVER. Ring copies an object on assignment, so a
watch does not see a secret registered afterwards. A host that runs the watch on a tick hands
it the current store each cycle (Watch(oStore)); the watch keeps what it has already
announced, so a second cycle says nothing twice and a renewed secret starts again clean.
*/

func StzPispiSecretParts()
	return [ "client", "api-key", "mtls-key", "mtls-cert", "webhook-secret" ]

func StzPispiSecretName(pcParticipant, pcPart)
	return "pispi-" + StzLower(ring_trim("" + pcParticipant)) + "-" + StzLower(ring_trim("" + pcPart))

# an UNSET descriptor of one part: a name and a kind, no value
func StzPispiSecretQ(pcParticipant, pcPart)
	return new stzPispiSecret(StzPispiSecretName(pcParticipant, pcPart), pcPart)

func StzPispiDescriptors(pcParticipant)
	_aOut_ = []
	_aP_ = StzPispiSecretParts()
	for _i_ = 1 to ring_len(_aP_)
		_o_ = StzPispiSecretQ(pcParticipant, _aP_[_i_])
		_aOut_ + _o_
	next
	return _aOut_

func StzPispiRegisterDescriptors(poStore, pcParticipant)
	_a_ = StzPispiDescriptors(pcParticipant)
	for _i_ = 1 to ring_len(_a_)
		poStore.Register(_a_[_i_])
	next
	return poStore

func StzSecretExpiryWatchQ(poStore)
	return new stzSecretExpiryWatch(poStore)

# The detections of the payments plane. Every one is OnAnyOccurrence: for a forged webhook or a
# lapsed certificate, one occurrence is already the story.
func StzPaymentsDetectionSet()
	_oS_ = new stzDetectionSet("payments")

	_d1_ = new stzDetection("secret-expiring")
	_d1_.WhenKind("secret.expiring").OnAnyOccurrence()
	_d1_.AsWarning()
	_d1_.Explaining("a payments secret is inside its warning window -- renew it before it lapses")
	_oS_.Add(_d1_)

	_d2_ = new stzDetection("secret-expired")
	_d2_.WhenKind("secret.expired").OnAnyOccurrence()
	_d2_.Explaining("a payments secret is past its expiry date -- the hub will refuse what it signs")
	_oS_.Add(_d2_)

	_d3_ = new stzDetection("forged-webhook")
	_d3_.WhenKind("webhook.signature.forged").OnAnyOccurrence()
	_d3_.Explaining("a webhook signature did not recompute -- tampered, or sent by someone without the secret")
	_oS_.Add(_d3_)

	_d4_ = new stzDetection("replayed-webhook")
	_d4_.WhenKind("webhook.replayed").OnAnyOccurrence()
	_d4_.Explaining("a webhook already believed was presented again")
	_oS_.Add(_d4_)

	_d5_ = new stzDetection("unsigned-webhook")
	_d5_.WhenKind("webhook.unsigned").OnAnyOccurrence()
	_d5_.AsWarning()
	_d5_.Explaining("a webhook arrived with no signature -- a probe of the callback URL")
	_oS_.Add(_d5_)

	return _oS_


  #=====================#
 #  A PAYMENTS SECRET  #
#=====================#

class stzPispiSecret from stzToken

	@cPart = ""

	def init(pcName, pcPart)
		_p_ = StzLower(ring_trim("" + pcPart))
		if ring_find(StzPispiSecretParts(), _p_) = 0
			StzRaise("stzPispiSecret: '" + pcPart + "' is not one of the five parts of a live payment " +
				"(client, api-key, mtls-key, mtls-cert, webhook-secret).")
		ok
		@cName = "" + pcName
		@cPart = _p_
		@cKind = "pispi-" + _p_

	def Part()
		return @cPart


  #=================#
 #  THE EXPIRY WATCH  #
#=================#

# A periodic thing, hostable on any stzAgentHost: Name_() and Cycle().
class stzSecretExpiryWatch from stzObject

	@oStore = ""
	@nWarnDays = 30
	@nAsOf = 0
	@aState = []     # [ [ secretName, "expiring" | "expired" ], ... ] -- what was already announced

	def init(poStore)
		@oStore = poStore

	def Name_()
		return "secret-expiry"

	# Hand the watch the CURRENT store: Ring copied the one it was built with.
	def Watch(poStore)
		@oStore = poStore
		return This

	def WarnWithinDays(pnDays)
		@nWarnDays = pnDays
		return This

	# judge as of this epoch second (0 = the engine's clock): the testable form
	def AsOf(pnEpoch)
		@nAsOf = pnEpoch
		return This

	# Writes one ledger event for each secret whose STATE changed since the last cycle,
	# answers how many. A secret that goes back to being fine (renewed) is forgotten, so the
	# next lapse is announced afresh.
	def Cycle()
		_nNow_ = @nAsOf
		if _nNow_ = 0
			_nNow_ = StzEngineTimeNowMs() / 1000
		ok
		_nWarn_ = @nWarnDays * 86400
		_aNames_ = @oStore.Names()
		_nEvents_ = 0
		for _i_ = 1 to ring_len(_aNames_)
			_s_ = @oStore.Secret(_aNames_[_i_])
			if NOT isMethod(_s_, "ExpiresAt")
				loop
			ok
			_nExp_ = _s_.ExpiresAt()
			_cState_ = ""
			if _nExp_ > 0
				if _nNow_ >= _nExp_
					_cState_ = "expired"
				but _nExp_ - _nNow_ <= _nWarn_
					_cState_ = "expiring"
				ok
			ok
			_k_ = This._StateIndex(_aNames_[_i_])
			_cPrev_ = ""
			if _k_ > 0
				_cPrev_ = @aState[_k_][2]
			ok
			if _cState_ = _cPrev_
				loop
			ok
			if _cState_ = ""
				del(@aState, _k_)
				loop
			ok
			if _k_ > 0
				@aState[_k_][2] = _cState_
			else
				@aState + [ _aNames_[_i_], _cState_ ]
			ok
			This._Announce(_aNames_[_i_], _cState_, _nExp_ - _nNow_)
			_nEvents_++
		next
		return _nEvents_

	def _StateIndex(pcName)
		for _i_ = 1 to ring_len(@aState)
			if @aState[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def _Announce(pcName, pcState, pnSecondsLeft)
		_cKind_ = "secret.expiring"
		_cWhat_ = "expires in " + ceil(pnSecondsLeft / 86400) + " day(s)"
		if pcState = "expired"
			_cKind_ = "secret.expired"
			_cWhat_ = "expired " + ceil((0 - pnSecondsLeft) / 86400) + " day(s) ago"
		ok
		_e_ = new stzSecurityEvent(_cKind_)
		_e_.ByActorNamed("secret:" + pcName, "")
		_e_.About("store:" + @oStore.Name())
		_e_.Observed(_cWhat_)
		StzRecordSecurityEvent(_e_)
