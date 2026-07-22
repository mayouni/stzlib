#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSECRETSTORE            #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The central place a Softanza project (an app or a platform) governs its
# secrets. Without it, secrets are scattered inline objects -- created at a
# call site, passed around, impossible to enumerate or audit. A stzSecretStore
# is the ONE registry:
#
#   * secrets are REGISTERED once, by name -- the project's whole credential
#     surface is enumerable (Names()) and inspectable (all self-redacting);
#   * every reveal goes through ONE governed door -- Reveal(name, actor) applies
#     the same actor gate a stzSecret enforces (only an effectful, non-sandboxed
#     actor; an LLM is refused) AND records the access;
#   * the ACCESS LOG makes misuse visible -- who read (or was refused) which
#     secret, in order. A refused access is a signal, not a silent failure.
#
# So a deployment site references a secret by NAME from the store rather than
# holding an inline key, and one audit trail covers the whole project. This is
# the "eliminate leak / misuse risk" story: secrets have a home, a gate, and a
# record. See stzSecret (the value) and stzSystemActor (the authority).

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSecretStoreQ(pcName)
	return new stzSecretStore(pcName)


  #=================#
 #  STZSECRETSTORE #
#=================#

class stzSecretStore from stzObject

	@cName = ""
	@aSecrets = []   # [ [ name, secretObject ], ... ]
	@aLog = []       # [ [ seq, actorName, secretName, outcome ], ... ]  -- the audit trail

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	  #-- the registry -----------------------------------------------------

	# register a secret under its own Name(). Registering a name that exists
	# REPLACES it -- that is rotation (RotateQ is the explicit alias).
	def Register(poSecret)
		if NOT isObject(poSecret)
			StzRaise("stzSecretStore.Register expects a stzSecret (or a kind of one).")
		ok
		_nm_ = StzLower(ring_trim("" + poSecret.Name()))
		_i_ = This._Index(_nm_)
		if _i_ > 0
			@aSecrets[_i_][2] = poSecret
		else
			@aSecrets + [ _nm_, poSecret ]
		ok
		return This

	# rotate a secret: replace whatever is registered under poNewSecret's name.
	def RotateQ(poNewSecret)
		return This.Register(poNewSecret)

	# revoke (remove) a secret by name.
	def Revoke(pcName)
		_nm_ = StzLower(ring_trim("" + pcName))
		_aNew_ = []
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			if @aSecrets[_i_][1] != _nm_
				_aNew_ + @aSecrets[_i_]
			ok
		next
		@aSecrets = _aNew_
		return This

	  #-- safe reads (never leak a value) ---------------------------------

	def Has(pcName)
		return This._Index(StzLower(ring_trim("" + pcName))) > 0

	def NumberOfSecrets()
		return len(@aSecrets)

	# the project's whole credential surface, by name -- safe to show/log.
	def Names()
		_out_ = []
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			_out_ + @aSecrets[_i_][1]
		next
		return _out_

	# the secret OBJECT (still self-redacting -- holding it does not reveal it).
	def Secret(pcName)
		_i_ = This._Index(StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return NULL
		ok
		return @aSecrets[_i_][2]

	# the redacted descriptor of a registered secret (never its value).
	def DescriptorOf(pcName)
		_s_ = This.Secret(pcName)
		if NOT isObject(_s_)
			return "<no secret '" + pcName + "'>"
		ok
		return _s_.Descriptor()

	  #-- the ONE governed door to a value (gate + audit) -----------------

	# reveal a secret's plaintext -- GATED (only an effectful, non-sandboxed
	# actor) and AUDITED (the access is recorded either way). This is the only
	# path a value leaves the store, so the log is complete.
	def Reveal(pcName, poActor)
		return This.RevealVia(pcName, NULL, poActor)

	# reveal through a vault RESOLVER (for a :vault-sourced secret), still gated
	# and AUDITED by the store. For a non-vault secret the resolver is ignored, so
	# this is a safe superset of Reveal.
	def RevealVia(pcName, poResolver, poActor)
		_nm_ = StzLower(ring_trim("" + pcName))
		_i_ = This._Index(_nm_)
		if _i_ = 0
			StzRaise("stzSecretStore: no secret named '" + pcName + "'.")
		ok
		_sec_ = @aSecrets[_i_][2]
		if NOT _sec_.IsRevealableBy(poActor)
			This._Audit(poActor, _nm_, "refused")
			_who_ = "an unauthorized actor"
			if isObject(poActor)
				_who_ = "actor '" + poActor.Name() + "' (posture " + poActor.Posture() + ")"
			ok
			StzRaise("stzSecretStore: " + _who_ + " may not reveal secret '" + pcName +
				"'. Only an effectful, non-sandboxed actor can.")
		ok
		This._Audit(poActor, _nm_, "granted")
		return _sec_.RevealVia(poResolver, poActor)

	# may this actor reveal this secret? (no side effect, no audit entry.)
	def IsRevealableBy(pcName, poActor)
		_s_ = This.Secret(pcName)
		if NOT isObject(_s_)
			return FALSE
		ok
		return _s_.IsRevealableBy(poActor)

	  #-- the audit trail (governance made visible) -----------------------

	# [ [ seq, actor, secret, outcome ], ... ] -- who read (or was refused) what.
	def AccessLog()
		return @aLog

	def NumberOfAccesses()
		return len(@aLog)

	# refused reveals -- a misuse signal worth watching.
	def RefusedAccesses()
		_c_ = 0
		_n_ = len(@aLog)
		for _i_ = 1 to _n_
			if @aLog[_i_][4] = "refused"
				_c_++
			ok
		next
		return _c_

	def Show()
		? "Secret store '" + @cName + "': " + len(@aSecrets) + " secret(s), " +
			len(@aLog) + " access(es), " + This.RefusedAccesses() + " refused"
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			? "  " + @aSecrets[_i_][2].Descriptor()
		next

	  #-- internals -------------------------------------------------------

	def _Index(pcName)
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			if @aSecrets[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	def _Audit(poActor, pcName, pcOutcome)
		_who_ = "?"
		if isObject(poActor)
			_who_ = "" + poActor.Name()
		ok
		@aLog + [ len(@aLog) + 1, _who_, pcName, pcOutcome ]
