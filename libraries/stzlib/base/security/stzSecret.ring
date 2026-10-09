#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZSECRET                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# Softanza's take on CONFIDENTIAL data + access credentials. A secret is a
# value you HOLD but never REVEAL in the clear:
#
#   * it REDACTS itself in every output -- Show(), Descriptor(), and any site
#     config it lands in show "<secret 'name' (kind) from env:VAR>", never the
#     value;
#   * it RESOLVES its real value lazily from a SOURCE -- a literal (dev/test),
#     an environment variable, a file, or a vault (future);
#   * its reveal is GOVERNED -- only an EFFECTFUL, non-sandboxed actor
#     (HumanActor / PIActor) may read the plaintext. An LLMActor holds only
#     "inference", so IsEffectful() is false: it can REFERENCE a secret in a
#     plan it rehearses, but can NEVER reveal it.
#
# The same rule as the deployment crossing: expression is free, admission is
# governed (see stzSystemActor). Specialisations name the KIND of credential
# (apikey / password / deploykey / token) and add the one presentation each
# needs. Wired into stzDeploymentSite: a site's auth can BE a stzSecret, so the
# site config serialises the redacted DESCRIPTOR, never the key -- and a real
# backend calls site.ResolveAuth(actor) to get the live value at store/launch
# time, gated on the actor.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzSecretQ(pcName)
	return new stzSecret(pcName)

# a masked, fixed-width ASCII redaction -- never the value (the Windows console
# is ASCII-only, so no bullet glyphs).
func StzSecretMask()
	return "********"

# convenience factories for the specialised kinds.
func StzApiKeyQ(pcName)
	return new stzApiKey(pcName)

func StzPasswordQ(pcName)
	return new stzPassword(pcName)

func StzDeployKeyQ(pcName)
	return new stzDeployKey(pcName)

func StzTokenQ(pcName)
	return new stzToken(pcName)


  #============#
 #  STZSECRET #
#============#

# Holds a credential you use but never show: it redacts itself everywhere, and only an effectful actor can read the value.
#
# A secret has a name, a kind and a source: an inline literal for development, an environment
# variable, a file, or a vault reference. The value is resolved lazily, at reveal time. Show,
# Descriptor and any configuration it lands in print only the redacted descriptor. Reveal is the one
# door to the plaintext and it is governed: an effectful actor such as HumanActor passes, while an
# inference-only LLMActor can reference the secret in a plan but is refused, and the refusal is
# noted to the security ledger. stzApiKey, stzPassword, stzDeployKey and stzToken specialise it by
# kind.
#
#   receiver   o1 = new stzSecret("db-pass") o1.FromLiteral("invented-value")
#   example    ? o1.Descriptor()
#              #--> <secret 'db-pass' (secret) from literal>
#              ? o1.IsRevealableBy(HumanActor("alice"))
#              #--> 1
#              ? o1.IsRevealableBy(LLMActor("bot"))
#              #--> 0
#   see        stzSecretStore, stzSystemActor, stzToken, stzPassword
class stzSecret from stzObject

	@cName    = ""
	@cKind    = "secret"    # semantic kind: secret / apikey / password / deploykey / token
	@cSource  = "unset"     # literal / env / file / vault / unset
	@cLocator = ""          # env var NAME / file PATH / vault REF  (SAFE to show)
	@cLiteral = ""          # only for the :literal source (dev/test) -- never shown

	# Builds a secret with a name and no source yet, of kind secret.
	#
	#   pcName     the secret name, which appears in its descriptor
	#   returns    nothing; the object is built
	#   see        FromLiteral, FromEnv, FromFile, FromVault
	def init(pcName)
		@cName = "" + pcName

	# Sets the secret to a value held inline, for development and tests; it still appears redacted everywhere.
	#
	#   pcValue    the plaintext to hold, which only Reveal by an effectful actor gives back
	#   returns    nothing; use FromLiteralQ to chain
	#   note       the locator shows as (inline), never the value
	#   see        FromEnv, Reveal, Descriptor
	#@ aka  -- source setters (Q-fluent: return the object AFTER acting) --------
	def FromLiteral(pcValue)
		This.FromLiteralQ(pcValue)

	def FromLiteralQ(pcValue)
		@cSource  = "literal"
		@cLiteral = "" + pcValue
		@cLocator = "(inline)"
		return This

	# Sets the secret to be read from an environment variable when revealed.
	#
	#   pcVarName   the variable name, trimmed
	#   returns     nothing; use FromEnvQ to chain
	#   note        an unset variable reveals as an empty text, without an error
	#   see         FromFile, Reveal, SourceLocator
	def FromEnv(pcVarName)
		This.FromEnvQ(pcVarName)

	def FromEnvQ(pcVarName)
		@cSource  = "env"
		@cLocator = ring_trim("" + pcVarName)
		return This

	# Sets the secret to be read from a file when revealed, with surrounding whitespace trimmed.
	#
	#   pcPath     the file path
	#   returns    nothing; use FromFileQ to chain
	#   note       revealing raises an error naming the path while the file does not exist
	#   see        FromEnv, Reveal, SourceLocator
	def FromFile(pcPath)
		This.FromFileQ(pcPath)

	def FromFileQ(pcPath)
		@cSource  = "file"
		@cLocator = "" + pcPath
		return This

	# Sets the secret to be fetched from a vault by reference, through a resolver at reveal time.
	#
	#   pcRef      the vault reference, such as a path in the vault
	#   returns    nothing; use FromVaultQ to chain
	#   note       Reveal raises an error for such a secret; RevealVia is its door
	#   see        RevealVia, IsVaultSourced
	def FromVault(pcRef)
		This.FromVaultQ(pcRef)

	def FromVaultQ(pcRef)
		@cSource  = "vault"
		@cLocator = "" + pcRef
		return This

	# Sets the kind of credential the secret is, lower-cased and trimmed, and shown in its descriptor.
	#
	#   pcKind     the kind, such as apikey, password, deploykey or token
	#   returns    nothing; use SetKindQ to chain
	#   see        Kind, Descriptor
	def SetKind(pcKind)
		This.SetKindQ(pcKind)

	def SetKindQ(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	# Returns the name the secret was built with.
	#
	#   returns    a text
	#   see        Descriptor
	#@ aka  -- SAFE reads (never leak the value) --------------------------------
	def Name()
		return @cName

	# Returns the kind of credential, such as secret, apikey or token.
	#
	#   returns    a text; secret by default
	#   see        SetKind
	def Kind()
		return @cKind

	# Returns where the value comes from: literal, env, file, vault or unset.
	#
	#   returns    a text
	#   see        SourceLocator, IsVaultSourced
	def SourceKind()
		return @cSource

	# Returns the pointer to where the value lives: a variable name, a path or a vault reference.
	#
	#   returns    a text; (inline) for a literal and empty when unset; safe to show
	#   see        SourceKind, Descriptor
	#@ aka  the POINTER to where the secret lives -- an env var NAME, a file PATH, a vault REF. Safe to show: it is not the secret. (For :literal it is "(inline)", never the value.)
	def SourceLocator()
		return @cLocator

	# Returns the redacted line that stands for the secret in every output, with its name, kind and source but never the value.
	#
	#   returns    a text such as <secret 'db-pass' (secret) from env:DB_PASS>
	#   see        Masked, Show
	#@ aka  the redacted, safe representation used EVERYWHERE the secret is displayed or serialised. No value ever appears here.
	def Descriptor()
		_src_ = @cSource
		if @cLocator != "" and @cSource != "literal"
			_src_ += ":" + @cLocator
		ok
		return "<secret '" + @cName + "' (" + @cKind + ") from " + _src_ + ">"

	# Returns a fixed row of eight asterisks, which does not depend on the value.
	#
	#   returns    the text ********
	#   see        Descriptor
	def Masked()
		return StzSecretMask()

	# Prints the redacted descriptor of the secret.
	#
	#   returns    nothing; it prints
	#   see        Descriptor
	def Show()
		? This.Descriptor()

	# TRUE if the actor may read the plaintext: an effectful actor that is not sandboxed; asking leaves no trace.
	#
	#   poActor    the actor to test, such as HumanActor or LLMActor
	#   returns    TRUE or FALSE; FALSE for a value that is not an actor object
	#   see        Reveal, IsResolvableBy
	#@ aka  -- the GOVERNED reveal -- the ONLY path to plaintext ----------------
	def IsRevealableBy(poActor)
		if NOT isObject(poActor)
			return 0
		ok
		return poActor.IsEffectful() and poActor.Posture() != "sandboxed"

	# Returns the plaintext from the secret source, once the actor gate has passed.
	#
	#   poActor    the actor asking, which must be effectful and not sandboxed
	#   returns    a text, the secret value
	#   note       a refused read never touches the value
	#   warning    raises an error for a refused actor (an inference-only LLMActor or a value that
	#              is not an actor), and the refusal is noted to the security ledger as
	#              secret.reveal.refused; raises an error for a vault source or when no source is
	#              set
	#   see        RevealVia, IsRevealableBy, Descriptor
	#@ aka  resolve + return the plaintext -- GATED. An LLMActor (inference-only) is refused; a HumanActor (effectful, trusted) succeeds. A vault-sourced secret needs a resolver (see RevealVia).
	def Reveal(poActor)
		This._GateReveal(poActor)
		return This._Resolve()

		def RevealFor(poActor)
			return This.Reveal(poActor)

	# Returns the plaintext as Reveal does, fetching a vault-sourced secret through a resolver.
	#
	#   poResolver   any object with a Resolve method taking the vault reference, or an empty text
	#                for a secret that is not vault-sourced
	#   poActor      the actor asking, which must be effectful and not sandboxed
	#   returns      a text, the secret value
	#   note         for a secret that is not vault-sourced the resolver is ignored
	#   warning      raises an error for a refused actor and for a vault-sourced secret given no
	#                resolver object
	#   see          Reveal, FromVault, IsVaultSourced
	#@ aka  resolver-aware reveal: a vault-sourced secret is fetched THROUGH a resolver, passed by reference at reveal time (after the actor gate). ANY object with a Resolve(locator) method is a valid resolver -- your vault client, or the reference stzVaultResolver. For a non-vault secret the resolver is ignored and this behaves like Reveal(actor).
	def RevealVia(poResolver, poActor)
		This._GateReveal(poActor)
		if @cSource = "vault"
			if NOT isObject(poResolver)
				StzRaise("Secret '" + @cName + "' is vault-sourced ('" + @cLocator +
					"'). Pass a vault resolver: RevealVia(resolver, actor).")
			ok
			return poResolver.Resolve(@cLocator)
		ok
		return This._Resolve()

	# TRUE if the secret is fetched from a vault.
	#
	#   returns    TRUE or FALSE
	#   see        FromVault, RevealVia
	def IsVaultSourced()
		return @cSource = "vault"

	# raise unless this actor may read the plaintext (the shared reveal gate).
	def _GateReveal(poActor)
		if NOT This.IsRevealableBy(poActor)
			_who_ = "an unauthorized actor"
			_name_ = "(anonymous)"
			if isObject(poActor)
				_who_ = "actor '" + poActor.Name() + "' (posture " + poActor.Posture() + ")"
				_name_ = "" + poActor.Name()
			ok
			# Incident I2. A raise reaches whoever wrote the try/catch and
			# nobody else -- and a caller that swallows it makes the attempt
			# disappear entirely. This is the BARE secret's gate; the store's
			# gate was wired in I2's first pass, so a reveal refused here was
			# the one that still went unremembered. The secret's NAME is a
			# descriptor and safe to write; the value is never touched, which
			# is why this line can sit inside the reveal path at all.
			StzNoteRefusal("secret.reveal.refused", _name_, "secret:" + @cName,
				_who_ + " may not reveal this secret")
			StzRaise("Refused: " + _who_ + " may not reveal secret '" + @cName +
				"'. Only an effectful, non-sandboxed actor can read a secret.")
		ok

	# TRUE if the actor may reveal the secret and it resolves to a non-empty value; never true for a vault source.
	#
	#   poActor    the actor asking
	#   returns    TRUE or FALSE; FALSE for a refused actor and for a vault source
	#   warning    raises an error instead of answering FALSE when the file does not exist or no
	#              source is set, because it resolves the value to find out
	#   see        Reveal, IsRevealableBy
	#@ aka  does the secret resolve to a non-empty value? Governed. A vault-sourced secret needs a resolver, so it is not resolvable this way.
	def IsResolvableBy(poActor)
		if NOT This.IsRevealableBy(poActor)
			return 0
		ok
		if @cSource = "vault"
			return 0
		ok
		return This._Resolve() != ""

	  #-- internal resolution (source -> plaintext) -----------------------

	def _Resolve()
		if @cSource = "literal"
			return @cLiteral
		but @cSource = "env"
			return StzEngineSystemEnvGet(@cLocator)
		but @cSource = "file"
			if StzEngineFileExists(@cLocator) != 1
				StzRaise("Secret '" + @cName + "': file source not found -- " + @cLocator)
			ok
			return ring_trim(read(@cLocator))
		but @cSource = "vault"
			StzRaise("Secret '" + @cName + "' is vault-sourced ('" + @cLocator +
				"'). Reveal it through a resolver: RevealVia(resolver, actor).")
		else
			StzRaise("Secret '" + @cName + "' has no source set (call FromLiteralQ / FromEnvQ / FromFileQ).")
		ok
		return ""


  #============#
 #  STZAPIKEY #
#============#

# an API key -- presented to an HTTP consumer as a bearer Authorization header.
class stzApiKey from stzSecret

	def init(pcName)
		@cName = "" + pcName
		@cKind = "apikey"

	# "Bearer <key>" -- governed (needs the real key), so for an effectful actor.
	def AuthorizationHeader(poActor)
		return "Bearer " + This.Reveal(poActor)


  #=============#
 #  STZPASSWORD #
#=============#

# Holds a password as a secret that you hash and compare rather than reveal, both steps governed by the actor gate.
#
# It is a stzSecret of kind password. HashedBy gives a salted Argon2id hash that is safe to store,
# and Matches compares a candidate with the held password. Both read the plaintext, so both need an
# effectful, non-sandboxed actor and raise an error for any other.
#
#   receiver   o1 = new stzPassword("admin-login") o1.FromLiteral("invented-pw")
#   example    ? o1.Matches("invented-pw", HumanActor("alice"))
#              #--> 1
#              ? o1.Matches("other", HumanActor("alice"))
#              #--> 0
#              ? left(o1.HashedBy(HumanActor("alice")), 10)
#              #--> $argon2id$
#   see        stzSecret, stzSecretStore
class stzPassword from stzSecret

	# Builds a password secret with a name, of kind password and no source yet.
	#
	#   pcName     the password name, which appears in its descriptor
	#   returns    nothing; the object is built
	#   see        FromLiteral, HashedBy
	def init(pcName)
		@cName = "" + pcName
		@cKind = "password"

	# Returns a salted Argon2id hash of the password, safe to store.
	#
	#   poActor    the actor asking, which must be effectful and not sandboxed
	#   returns    a text beginning $argon2id$; each call salts afresh, so two hashes of the same
	#              password differ
	#   note       StzVerifyPassword checks a candidate against the hash
	#   warning    raises an error for a refused actor, as Reveal does
	#   see        Matches, Reveal
	#@ aka  a salted, one-way Argon2id hash of the resolved password -- safe to store. Governed (resolving the password needs an effectful actor).
	def HashedBy(poActor)
		return StzHashPassword(This.Reveal(poActor))

	# TRUE if the candidate equals the password; the comparison reads the plaintext.
	#
	#   pcCandidate   the text to compare with the password
	#   poActor       the actor asking, which must be effectful and not sandboxed
	#   returns       TRUE or FALSE
	#   note          the comparison is a plain equality, not a constant-time one
	#   warning       raises an error for a refused actor, rather than answering FALSE
	#   see           HashedBy, Reveal
	#@ aka  verify a candidate against this password (governed).
	def Matches(pcCandidate, poActor)
		return This.Reveal(poActor) = ("" + pcCandidate)


  #==============#
 #  STZDEPLOYKEY #
#==============#

# a deploy / SSH private key -- a credential the deployment backend hands to
# ssh/scp. A real backend writes the material to a private (chmod 600) file.
class stzDeployKey from stzSecret

	def init(pcName)
		@cName = "" + pcName
		@cKind = "deploykey"

	# the key material (governed).
	def KeyMaterial(poActor)
		return This.Reveal(poActor)


  #===========#
 #  STZTOKEN #
#===========#

# Holds a bearer or access token as a secret, with an optional expiry that the caller checks against its own clock.
#
# It is a stzSecret of kind token: redacted in every output, revealed only to an effectful actor. It
# adds an expiry in epoch seconds, where 0 means no expiry, and holds no clock of its own, so
# IsExpiredAt takes the moment to test.
#
#   receiver   o1 = new stzToken("session") o1.SetExpiry(1000)
#   example    ? o1.IsExpiredAt(999)
#              #--> 0
#              ? o1.IsExpiredAt(1000)
#              #--> 1
#              ? o1.Kind()
#              #--> token
#   see        stzSecret, stzSecretStore
class stzToken from stzSecret

	@nExpiresAt = 0

	# Builds a token secret with a name, of kind token and no expiry.
	#
	#   pcName     the token name, which appears in its descriptor
	#   returns    nothing; the object is built
	#   see        SetExpiry, FromLiteral
	def init(pcName)
		@cName = "" + pcName
		@cKind = "token"

	# Sets the moment the token expires, in epoch seconds; 0 means it never expires.
	#
	#   nEpoch     the expiry moment in epoch seconds
	#   returns    nothing; use SetExpiryQ to chain
	#   see        ExpiresAt, IsExpiredAt
	def SetExpiry(nEpoch)
		This.SetExpiryQ(nEpoch)

	def SetExpiryQ(nEpoch)
		@nExpiresAt = nEpoch
		return This

	# Returns the expiry moment, in epoch seconds.
	#
	#   returns    a number; 0 when the token never expires
	#   see        SetExpiry, IsExpiredAt
	def ExpiresAt()
		return @nExpiresAt

	# TRUE if the given moment is at or after the expiry; a token with expiry 0 is never expired.
	#
	#   nNowEpoch   the moment to test, in epoch seconds, which the caller reads from its own clock
	#   returns     TRUE or FALSE
	#   see         SetExpiry, ExpiresAt
	#@ aka  expired at a given "now" (epoch seconds)? A 0 expiry never expires. The caller passes the clock -- the class holds no wall-clock of its own.
	def IsExpiredAt(nNowEpoch)
		if @nExpiresAt = 0
			return 0
		ok
		return nNowEpoch >= @nExpiresAt
