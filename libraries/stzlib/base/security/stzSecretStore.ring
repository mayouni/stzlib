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

# Rebuild a store from a file written by SaveSealedTo. The key is itself a
# secret, revealed through the same governed door as any other: poActor must
# be effectful and not sandboxed. A wrong key or an altered file RAISES --
# and the refusal is recorded -- it never yields a half-read store.
func StzSecretStoreFromSealedFile(pcPath, poKeySecret, poActor)
	return StzSecretStoreFromSealedFileVia(pcPath, poKeySecret, "", poActor)

# As above, with the KEY fetched through a vault resolver (R4): a key
# secret sourced FromVault(...) is revealed via poResolver.
func StzSecretStoreFromSealedFileVia(pcPath, poKeySecret, poResolver, poActor)
	_cRaw_ = read("" + pcPath)
	_acL_ = StzSplit(_cRaw_, char(10))
	if len(_acL_) < 3 or ring_trim(_acL_[1]) != "stzsecrets v1"
		stzraise("Not a sealed secret store: " + pcPath)
	ok
	_cName_ = StzMidToEnd(ring_trim(_acL_[2]), 7)       # after "store="
	_cKey_ = poKeySecret.RevealVia(poResolver, poActor)
	try
		_cPlain_ = StzOpen(_cKey_, ring_trim(_acL_[3]), "stzsecrets:" + _cName_)
	catch
		StzNoteRefusal("secret.reveal.refused", "" + poActor.Name(), "store:" + _cName_,
			"the sealed store did not open -- wrong key, or the file was altered")
		stzraise("The sealed store '" + _cName_ + "' did not open: wrong key, or the file was altered.")
	done
	_o_ = new stzSecretStore(_cName_)
	_acRec_ = StzSplit(_cPlain_, char(10))
	_n_ = len(_acRec_)
	for _i_ = 1 to _n_
		if ring_trim(_acRec_[_i_]) = ""  loop  ok
		_a_ = StzSplit(_acRec_[_i_], char(9))
		_o_.Register(_StzSecretFromRecord(_a_))
	next
	return _o_

# [ kind, name, source, locator-or-value(hex), expiry ] -> a stzSecret of that kind
func _StzSecretFromRecord(paRec)
	_cKind_ = paRec[1]
	if _cKind_ = "apikey"
		_s_ = new stzApiKey(paRec[2])
	but _cKind_ = "password"
		_s_ = new stzPassword(paRec[2])
	but _cKind_ = "deploykey"
		_s_ = new stzDeployKey(paRec[2])
	but _cKind_ = "token"
		_s_ = new stzToken(paRec[2])
		if len(paRec) >= 5 and ring_number(paRec[5]) > 0  _s_.SetExpiry(ring_number(paRec[5]))  ok
	else
		_s_ = new stzSecret(paRec[2])
		_s_.SetKind(_cKind_)
	ok
	_cSrc_ = paRec[3]
	_cVal_ = StzEngineCryptoHexDecode(paRec[4])
	if _cSrc_ = "literal"
		_s_.FromLiteral(_cVal_)
	but _cSrc_ = "env"
		_s_.FromEnv(_cVal_)
	but _cSrc_ = "file"
		_s_.FromFile(_cVal_)
	but _cSrc_ = "vault"
		_s_.FromVault(_cVal_)
	ok
	return _s_


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
	def Rotate(poNewSecret)
		This.RotateQ(poNewSecret)

	def RotateQ(poNewSecret)
		return This.Register(poNewSecret)

	# ROTATE IN PLACE, to a fresh random value -- containment's :RotateSecret.
	# Only a secret whose value THIS store holds (a :literal) can be
	# regenerated here: a key it issues, a token it signs with. A secret that
	# lives in an environment variable, a file or a vault is not this store's
	# to change -- that REFUSES loudly, naming where to rotate it, rather than
	# pretending. Creating a credential is an effect, so poActor passes the
	# same gate as a reveal. The new value is 32 random bytes as 64 hex
	# characters; kind and name are kept (a token's expiry is cleared -- a new
	# value is a new credential). Returns This.
	def RotateToFresh(pcName, poActor)
		_s_ = This.Secret(pcName)
		if NOT isObject(_s_)
			stzraise("stzSecretStore '" + @cName + "': no secret '" + pcName + "' to rotate.")
		ok
		if NOT (isObject(poActor) and poActor.IsEffectful() and poActor.Posture() != "sandboxed")
			StzNoteRefusal("secret.reveal.refused", "" + poActor.Name(), "secret:" + _s_.Name(),
				"rotating a secret is an effect -- the actor may not")
			stzraise("Refused: only an effectful, non-sandboxed actor may rotate secret '" + _s_.Name() + "'.")
		ok
		if _s_.SourceKind() != "literal"
			stzraise("Secret '" + _s_.Name() + "' lives in its " + _s_.SourceKind() + " source (" +
				_s_.SourceLocator() + ") -- rotate it THERE; this store does not own its value.")
		ok
		_cKind_ = _s_.Kind()
		if _cKind_ = "apikey"
			_n_ = new stzApiKey(_s_.Name())
		but _cKind_ = "password"
			_n_ = new stzPassword(_s_.Name())
		but _cKind_ = "deploykey"
			_n_ = new stzDeployKey(_s_.Name())
		but _cKind_ = "token"
			_n_ = new stzToken(_s_.Name())
		else
			_n_ = new stzSecret(_s_.Name())
			_n_.SetKind(_cKind_)
		ok
		_n_.FromLiteral(StzEngineCryptoRandomHex(32))
		This.Register(_n_)
		This._Audit(poActor, _s_.Name(), "rotated")
		StzNoteGrant("secret.rotated", "" + poActor.Name(), "secret:" + _s_.Name())
		return This

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
			return ""
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
		return This.RevealVia(pcName, "", poActor)

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
			return 0
		ok
		return _s_.IsRevealableBy(poActor)

	  #-- the audit trail (governance made visible) -----------------------

	# [ [ seq, actor, secret, outcome ], ... ] -- who read (or was refused) what.
	  #-- sealed at rest (R3) ----------------------------------------------
	#
	# Write the whole store to pcPath as ONE authenticated-encryption blob
	# (XChaCha20-Poly1305), keyed by poKeySecret -- itself a stzSecret, whose
	# 64-hex value comes from wherever secrets come from (an environment
	# variable, a file, a vault). Literal values are sealed; env / file /
	# vault secrets are saved as their POINTER only -- the plaintext never
	# leaves its source. The store's name is bound as the aad, so one store's
	# file cannot be passed off as another's. Sealing reads every literal
	# value, so poActor passes the same gate as a reveal.
	def SaveSealedTo(pcPath, poKeySecret, poActor)
		return This.SaveSealedToVia(pcPath, poKeySecret, "", poActor)

	# As SaveSealedTo, with the KEY fetched through a vault resolver (R4).
	def SaveSealedToVia(pcPath, poKeySecret, poResolver, poActor)
		if NOT (isObject(poActor) and poActor.IsEffectful() and poActor.Posture() != "sandboxed")
			StzNoteRefusal("secret.reveal.refused", "" + poActor.Name(), "store:" + @cName,
				"sealing a store reads its secrets -- the actor may not")
			stzraise("Refused: sealing store '" + @cName + "' reads its secrets; only an effectful, non-sandboxed actor may.")
		ok
		_cKey_ = poKeySecret.RevealVia(poResolver, poActor)
		_cBody_ = ""
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			_s_ = @aSecrets[_i_][2]
			_cSrc_ = _s_.SourceKind()
			if _cSrc_ = "literal"
				_cVal_ = _s_.Reveal(poActor)
			else
				_cVal_ = _s_.SourceLocator()
			ok
			_nExp_ = 0
			if _s_.Kind() = "token"  _nExp_ = _s_.ExpiresAt()  ok
			# values travel hex-encoded: a tab or a newline inside a value is data
			_cBody_ += _s_.Kind() + char(9) + _s_.Name() + char(9) + _cSrc_ + char(9) +
				StzEngineCryptoHexEncode(_cVal_) + char(9) + _nExp_ + char(10)
		next
		_cBlob_ = StzSeal(_cKey_, _cBody_, "stzsecrets:" + @cName)
		write("" + pcPath, "stzsecrets v1" + char(10) + "store=" + @cName + char(10) + _cBlob_ + char(10))
		return This

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
		# The store's own log is the doctrine's exemplar ("the log is
		# complete") but it carries no clock and dies with the object.
		# The same fact now also reaches the ledger, timestamped,
		# chained and correlated (incident I2). The event carries the
		# secret's NAME, never its value -- the redaction law.
		if pcOutcome = "granted"
			StzNoteGrant("secret.reveal.granted", _who_, "secret:" + pcName)
		else
			_e_ = new stzSecurityEvent("secret.reveal.refused")
			_e_.ByActor(poActor)
			_e_.About("secret:" + pcName)
			_e_.Doing("reveal")
			_e_.Refused("the actor is not effectful (or is sandboxed)")
			StzRecordSecurityEvent(_e_)
		ok
