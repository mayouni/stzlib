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
#
# A kind of the form "<family>-<part>" belongs to whoever defines the function
# StzSecretFromKind_<family>(name, part): the payments plane defines
# StzSecretFromKind_pispi, so "pispi-mtls-cert" is built as a stzPispiSecret.
# The store names no family itself. A family whose function is not loaded is
# read as a plain secret that keeps its kind, never refused: a sealed file
# written by a build with payments loaded stays readable without it.
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
	but _StzSecretKindFactory(_cKind_) != ""
		_cF_ = _StzSecretKindFactory(_cKind_)
		_s_ = call _cF_(paRec[2], StzMidToEnd(_cKind_, StzFindFirst("-", _cKind_) + 1))
		if len(paRec) >= 5 and ring_number(paRec[5]) > 0 and isMethod(_s_, "setexpiry")
			_s_.SetExpiry(ring_number(paRec[5]))
		ok
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



# The factory function for a kind's family, or "" when there is none loaded.
func _StzSecretKindFactory(pcKind)
	_n_ = StzFindFirst("-", pcKind)
	if _n_ < 2  return ""  ok
	_cF_ = "stzsecretfromkind_" + StzLower(StzLeft(pcKind, _n_ - 1))
	if ring_find(functions(), _cF_) = 0  return ""  ok
	return _cF_

  #=================#
 #  STZSECRETSTORE #
#=================#

# Holds a project's secrets in one registry, with one governed and audited door through which a value can leave.
#
# Secrets are registered once by name, so the whole credential surface is enumerable and every entry
# is self-redacting. Reveal applies the actor gate (only an effectful, non-sandboxed actor passes; a
# language-model actor is refused) and records the attempt in the access log and in the security
# ledger, by the secret's name and never its value. RotateToFresh renews a value the store owns, and
# refuses a secret that lives in an environment variable, a file or a vault, naming where to rotate
# it. SaveSealedTo writes the store as one authenticated-encryption blob, and
# StzSecretStoreFromSealedFile reads it back. The store keeps a copy of what it registers.
#
#   receiver   o1 = new stzSecretStore("billing")
#   example    o1.Register(StzApiKeyQ("stripe").FromEnvQ("INVENTED_STRIPE_ENV"))
#              ? o1.DescriptorOf("stripe")
#              #--> <secret 'stripe' (apikey) from env:INVENTED_STRIPE_ENV>
#   see        stzSecurityPosture, stzSecurityLedger, StzSecretStoreFromSealedFile
class stzSecretStore from stzObject

	@cName = ""
	@aSecrets = []   # [ [ name, secretObject ], ... ]
	@aLog = []       # [ [ seq, actorName, secretName, outcome ], ... ]  -- the audit trail

	# Builds an empty store, the one registry in which a project governs its secrets.
	#
	#   pcName     the store's name, bound into sealed files as their authenticated context
	#   returns    nothing; the object is built
	#   see        Register, Reveal
	def init(pcName)
		@cName = "" + pcName

	# Returns the store's name.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Adds a secret under its own name, in lower case; a name already registered is replaced, which is rotation.
	#
	#   poSecret   the stzSecret, or a kind of one such as stzApiKey, to register
	#   returns    the store itself, so calls chain
	#   note       secrets are enumerable by Names and show only their descriptor
	#   warning    a non-object raises an error; the store keeps a COPY of the secret, so changing
	#              the original afterwards does not reach it; replacing a name leaves no entry in
	#              the access log and none in the ledger
	#   see        Rotate, Revoke, Reveal
	#@ aka  -- the registry -----------------------------------------------------
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

	# Replaces the secret registered under the new secret's name, or adds it when the name is new.
	#
	#   poNewSecret   the stzSecret that takes the place of the registered one
	#   returns       nothing; use RotateQ to chain
	#   note          RotateQ is the same call and returns the store
	#   warning       the replacement leaves no entry in the access log and none in the ledger
	#   see           Register, RotateToFresh
	#@ aka  rotate a secret: replace whatever is registered under poNewSecret's name.
	def Rotate(poNewSecret)
		This.RotateQ(poNewSecret)

	def RotateQ(poNewSecret)
		return This.Register(poNewSecret)

	# Replaces the value of a secret the store owns with 32 fresh random bytes as 64 hex characters, keeping its kind and name.
	#
	#   pcName     the name of the registered secret to renew
	#   poActor    the actor that performs the rotation, which must be effectful and not sandboxed
	#   returns    the store itself, so calls chain
	#   note       the access log gets a rotated entry and the ledger a secret.rotated grant; a
	#              token's expiry is cleared (rotate_secret_narrated)
	#   warning    raises an error for an unknown name, for a refused actor and for a secret whose
	#              source is an environment variable, a file or a vault, naming where to rotate it;
	#              an actor that is not an object also fails closed, but with R13 Object is required
	#              and no refusal is recorded
	#   see        Rotate, Reveal, Revoke
	#@ aka  ROTATE IN PLACE, to a fresh random value -- containment's :RotateSecret. Only a secret whose value THIS store holds (a :literal) can be regenerated here: a key it issues, a token it signs with. A secret that lives in an environment variable, a file or a vault is not this store's to change -- that REFUSES loudly, naming where to rotate it, rather than pretending. Creating a credential is an effect,
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

	# Removes a secret by name; an unknown name changes nothing.
	#
	#   pcName     the name of the secret to remove
	#   returns    the store itself, so calls chain
	#   note       the name is matched without regard to case
	#   warning    the removal leaves no entry in the access log and none in the ledger
	#   see        Register, Has
	#@ aka  revoke (remove) a secret by name.
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

	# TRUE if a secret of that name is registered.
	#
	#   pcName     the secret's name, matched without regard to case
	#   returns    TRUE or FALSE
	#   see        Secret, Names
	#@ aka  -- safe reads (never leak a value) ---------------------------------
	def Has(pcName)
		return This._Index(StzLower(ring_trim("" + pcName))) > 0

	# Returns how many secrets are registered.
	#
	#   returns    a number
	#   see        Names, Has
	def NumberOfSecrets()
		return len(@aSecrets)

	# Returns the names of the registered secrets, in lower case, in the order registered: the project's whole credential surface.
	#
	#   returns    a list of text
	#   note       safe to show or log, because no value is in it
	#   see        Has, DescriptorOf
	#@ aka  the project's whole credential surface, by name -- safe to show/log.
	def Names()
		_out_ = []
		_n_ = len(@aSecrets)
		for _i_ = 1 to _n_
			_out_ + @aSecrets[_i_][1]
		next
		return _out_

	# Returns the stored secret object, which is still self-redacting.
	#
	#   pcName     the secret's name, matched without regard to case
	#   returns    a stzSecret, or an empty text when the name is unknown
	#   note       holding it reveals nothing, and it is a copy: changing it does not change the
	#              store
	#   see        DescriptorOf, Reveal
	#@ aka  the secret OBJECT (still self-redacting -- holding it does not reveal it).
	def Secret(pcName)
		_i_ = This._Index(StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return ""
		ok
		return @aSecrets[_i_][2]

	# Returns the redacted descriptor of a registered secret, never its value.
	#
	#   pcName     the secret's name, matched without regard to case
	#   returns    a text such as <secret 'stripe' (apikey) from env:STRIPE_KEY>, or <no secret
	#              'name'> when unknown
	#   see        Secret, Names
	#@ aka  the redacted descriptor of a registered secret (never its value).
	def DescriptorOf(pcName)
		_s_ = This.Secret(pcName)
		if NOT isObject(_s_)
			return "<no secret '" + pcName + "'>"
		ok
		return _s_.Descriptor()

	# Returns a secret's plaintext through the store's governed door: only an effectful, non-sandboxed actor passes, and each try is audited.
	#
	#   pcName     the name of the secret to read
	#   poActor    the actor asking, an object that must be effectful and not sandboxed
	#   returns    a text, the secret's value
	#   note       a granted read is logged and recorded as secret.reveal.granted, with the secret's
	#              name and never its value
	#   warning    raises an error for an unknown name, which is not logged, and for a refused
	#              actor, which is logged as refused and recorded in the ledger as
	#              secret.reveal.refused
	#   see        RevealVia, IsRevealableBy, AccessLog
	#@ aka  -- the ONE governed door to a value (gate + audit) -----------------
	def Reveal(pcName, poActor)
		return This.RevealVia(pcName, "", poActor)

	# Reveals a secret through a vault resolver for a vault-sourced secret, still gated and audited; for any other secret the resolver is ignored.
	#
	#   pcName       the name of the secret to read
	#   poResolver   the vault resolver object, or an empty text when the secret is not vault-
	#                sourced
	#   poActor      the actor asking, an object that must be effectful and not sandboxed
	#   returns      a text, the secret's value
	#   note         a superset of Reveal, which calls it with no resolver
	#   warning      an unknown name and a refused actor raise errors, as for Reveal
	#   see          Reveal, IsRevealableBy
	#@ aka  reveal through a vault RESOLVER (for a :vault-sourced secret), still gated and AUDITED by the store. For a non-vault secret the resolver is ignored, so this is a safe superset of Reveal.
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

	# TRUE if the actor could reveal that secret; asking changes nothing and leaves no audit entry.
	#
	#   pcName     the secret's name
	#   poActor    the actor to test
	#   returns    TRUE or FALSE; FALSE for an unknown name or an actor that is not an object
	#   see        Reveal, Secret
	#@ aka  may this actor reveal this secret? (no side effect, no audit entry.)
	def IsRevealableBy(pcName, poActor)
		_s_ = This.Secret(pcName)
		if NOT isObject(_s_)
			return 0
		ok
		return _s_.IsRevealableBy(poActor)

	# Writes the whole store to a file as one encrypted blob keyed by a key secret; literal values are sealed, other sources by pointer only.
	#
	#   pcPath        the file to write, overwritten
	#   poKeySecret   the stzSecret whose 64-hex value keys the seal
	#   poActor       the actor performing the seal, effectful and not sandboxed
	#   returns       the store itself, so calls chain
	#   note          an environment, file or vault secret is saved as its pointer, so its plaintext
	#                 never leaves its source; the store's name is bound as context, so a file
	#                 cannot pass for another store's
	#   warning       a refused actor raises an error and is recorded; an actor that is not an
	#                 object also fails closed, but with R13 Object is required and no refusal is
	#                 recorded
	#   see           StzSecretStoreFromSealedFile, SaveSealedToVia, Reveal
	#@ aka  -- the audit trail (governance made visible) -----------------------
	def SaveSealedTo(pcPath, poKeySecret, poActor)
		return This.SaveSealedToVia(pcPath, poKeySecret, "", poActor)

	# Writes the sealed store as SaveSealedTo does, with the key secret fetched through a vault resolver.
	#
	#   pcPath        the file to write, overwritten
	#   poKeySecret   the stzSecret that keys the seal
	#   poResolver    the vault resolver object, or an empty text
	#   poActor       the actor performing the seal, effectful and not sandboxed
	#   returns       the store itself, so calls chain
	#   note          the file reads back with StzSecretStoreFromSealedFile
	#   warning       same as SaveSealedTo
	#   see           SaveSealedTo, StzSecretStoreFromSealedFileVia
	#@ aka  As SaveSealedTo, with the KEY fetched through a vault resolver (R4).
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
			if isMethod(_s_, "ExpiresAt")  _nExp_ = _s_.ExpiresAt()  ok
			# values travel hex-encoded: a tab or a newline inside a value is data
			_cBody_ += _s_.Kind() + char(9) + _s_.Name() + char(9) + _cSrc_ + char(9) +
				StzEngineCryptoHexEncode(_cVal_) + char(9) + _nExp_ + char(10)
		next
		_cBlob_ = StzSeal(_cKey_, _cBody_, "stzsecrets:" + @cName)
		write("" + pcPath, "stzsecrets v1" + char(10) + "store=" + @cName + char(10) + _cBlob_ + char(10))
		return This

	# Returns the audit trail: who read, or was refused, which secret, in order.
	#
	#   returns    a list of [ number, actor, secret, outcome ] rows, outcome granted, refused or
	#              rotated
	#   note       an unknown name is not logged; the log lives in the object and dies with it,
	#              which is why each entry also reaches the ledger
	#   see        NumberOfAccesses, RefusedAccesses
	def AccessLog()
		return @aLog

	# Returns how many entries the audit trail holds.
	#
	#   returns    a number
	#   see        AccessLog, RefusedAccesses
	def NumberOfAccesses()
		return len(@aLog)

	# Returns how many reveals were refused, a misuse signal worth watching.
	#
	#   returns    a number
	#   see        AccessLog, stzSecurityPosture
	#@ aka  refused reveals -- a misuse signal worth watching.
	def RefusedAccesses()
		_c_ = 0
		_n_ = len(@aLog)
		for _i_ = 1 to _n_
			if @aLog[_i_][4] = "refused"
				_c_++
			ok
		next
		return _c_

	# Prints a summary line of the store, then the redacted descriptor of each secret.
	#
	#   returns    nothing; it prints
	#   note       no value is printed
	#   see        DescriptorOf, AccessLog
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
