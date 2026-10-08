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

# The secret store's kind factory for the "pispi-" family: a sealed file holding a
# payments descriptor is read back as a stzPispiSecret, expiry included. The store
# finds this by name, so it never has to name the payments plane.
func StzSecretFromKind_pispi(pcName, pcPart)
	return new stzPispiSecret(pcName, pcPart)

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

	_d6_ = new stzDetection("unplanned-payout")
	_d6_.WhenKind("payout.unplanned").OnAnyOccurrence()
	_d6_.Explaining("money out reached the port with no committed plan, or for an amount the plan did not authorise")
	_oS_.Add(_d6_)

	_d7_ = new stzDetection("payout-refused")
	_d7_.WhenKind("payout.refused").OnAnyOccurrence()
	_d7_.AsWarning()
	_d7_.Explaining("a payout plan was refused -- by the policy, by the actor, or because the rehearsal was altered")
	_oS_.Add(_d7_)

	return _oS_


  #=====================#
 #  A PAYMENTS SECRET  #
#=====================#

# Describes one of the five secrets a live payment needs, by name and kind, as a token that can expire.
#
# The five parts are the OAuth client, the API key, the mTLS private key, its certificate and a
# webhook secret. A descriptor is a stzToken underneath, because a token is the one kind of secret
# the store already knows how to expire, and its kind says which part it is. It carries no value
# until a source is given: the value comes from an environment variable, a file outside the
# repository or a vault, and is shown by no output. Use invented values in a test and never write a
# real one in a source file, a memo or an example. A descriptor that is only a name is refused by
# the registry in production, as is one whose certificate has lapsed.
#
#   receiver   o1 = new stzPispiSecret("pispi-bia-mtls-cert", "mtls-cert")
#   example    o1.FromEnv("INVENTED_MTLS_CERT_PATH")
#              ? o1.Kind()
#              #--> pispi-mtls-cert
#              ? o1.Part()
#              #--> mtls-cert
#              ? o1.Descriptor()
#              #--> <secret 'pispi-bia-mtls-cert' (pispi-mtls-cert) from env:INVENTED_MTLS_CERT_PATH>
#   see        stzSecretStore, stzToken, stzSecretExpiryWatch
class stzPispiSecret from stzToken

	@cPart = ""

	# Builds an unset descriptor for one of the five parts of a live payment: a name and a kind, and no value.
	#
	#   pcName     the name the descriptor is registered under in the store
	#   pcPart     one of client, api-key, mtls-key, mtls-cert or webhook-secret, in any case
	#   returns    nothing; the object is built
	#   note       a descriptor with no value is a name, not a credential: give it a source with
	#              FromEnv, FromFile or FromVault, and its kind becomes pispi- followed by the part
	#   warning    raises an error naming the five parts when pcPart is anything else, an empty text
	#              included
	#   see        Part, StzPispiSecretQ
	def init(pcName, pcPart)
		_p_ = StzLower(ring_trim("" + pcPart))
		if ring_find(StzPispiSecretParts(), _p_) = 0
			StzRaise("stzPispiSecret: '" + pcPart + "' is not one of the five parts of a live payment " +
				"(client, api-key, mtls-key, mtls-cert, webhook-secret).")
		ok
		@cName = "" + pcName
		@cPart = _p_
		@cKind = "pispi-" + _p_

	# Returns which of the five elements of a live payment this descriptor stands for, in lower case.
	#
	#   returns    a text: client, api-key, mtls-key, mtls-cert or webhook-secret
	#   see        init, Kind
	def Part()
		return @cPart


  #=================#
 #  THE EXPIRY WATCH  #
#=================#

# Reads a store of secrets on a tick and tells the security ledger, once, which are about to expire or have.
#
# Expiry is a detection, not a check at call time: the port never looks at a date. Each cycle
# compares every expiring secret in the store with the clock and writes secret.expiring or
# secret.expired once per change of state, naming the secret and never its value. The default window
# is thirty days. The watch holds the store as it was handed over, so a host that runs it
# periodically hands it the current store each cycle. It is a periodic thing with a name and a
# Cycle, hostable on any agent host. Use invented secrets in a test.
#
#   receiver   o1 = new stzSecretExpiryWatch(StzSecretStoreQ("billing"))
#   example    oCert = StzPispiSecretQ("bia", "mtls-cert")
#              oCert.FromEnv("INVENTED_MTLS_CERT_PATH")
#              oCert.SetExpiry(1800000000 + 10 * 86400)
#              oStore = StzSecretStoreQ("billing")
#              oStore.Register(oCert)
#              o1.Watch(oStore)
#              o1.AsOf(1800000000)
#              ? o1.Cycle()
#              #--> 1
#              ? o1.Cycle()
#              #--> 0
#   see        stzPispiSecret, stzSecretStore, stzSecurityLedger
class stzSecretExpiryWatch from stzObject

	@oStore = ""
	@nWarnDays = 30
	@nAsOf = 0
	@aState = []     # [ [ secretName, "expiring" | "expired" ], ... ] -- what was already announced

	# Builds a watch over the secrets of a store, to announce in the security ledger those about to expire or already expired.
	#
	#   poStore    the stzSecretStore to read
	#   returns    nothing; the object is built
	#   note       a secret registered after this call is not seen: hand the watch the current store
	#              with Watch before each cycle
	#   see        Cycle, Watch
	def init(poStore)
		@oStore = poStore

	# Returns the name under which a host schedules this watch on its tick.
	#
	#   returns    the text secret-expiry
	#   see        Cycle
	def Name_()
		return "secret-expiry"

	# Replaces the store this object reads with the current one, keeping what it has already announced.
	#
	#   poStore    the stzSecretStore to read from now on
	#   returns    the watch itself, so calls chain
	#   note       Ring copies an object on assignment, which is why a host calls this each cycle
	#   see        Cycle, init
	#@ aka  Hand the watch the CURRENT store: Ring copied the one it was built with.
	def Watch(poStore)
		@oStore = poStore
		return This

	# Sets how many days before its end a secret counts as expiring; thirty days when never set.
	#
	#   pnDays     the length of the warning window, in days
	#   returns    the watch itself, so calls chain
	#   see        Cycle, AsOf
	def WarnWithinDays(pnDays)
		@nWarnDays = pnDays
		return This

	# Fixes the moment the watch judges against, so a test does not depend on the clock; 0 returns to the engine clock.
	#
	#   pnEpoch    the moment as epoch seconds, 0 for the engine clock
	#   returns    the watch itself, so calls chain
	#   see        Cycle, WarnWithinDays
	#@ aka  judge as of this epoch second (0 = the engine's clock): the testable form
	def AsOf(pnEpoch)
		@nAsOf = pnEpoch
		return This

	# Writes one security-ledger event for each secret whose state changed since the last run, and answers how many it wrote.
	#
	#   returns    a number: 0 when nothing changed
	#   note       an expiring secret goes in the ledger as secret.expiring, a lapsed one as
	#              secret.expired, by the secret's name and never its value; a renewed secret is
	#              forgotten, so its next lapse is announced afresh
	#   warning    a secret with no expiry date, or of a kind that has none, is never judged; the
	#              state changes are expiring then expired, and the second cycle on an unchanged
	#              store writes nothing
	#   see        Watch, WarnWithinDays, AsOf
	#@ aka  Writes one ledger event for each secret whose STATE changed since the last cycle, answers how many. A secret that goes back to being fine (renewed) is forgotten, so the next lapse is announced afresh.
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
