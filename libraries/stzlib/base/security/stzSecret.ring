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

class stzSecret from stzObject

	@cName    = ""
	@cKind    = "secret"    # semantic kind: secret / apikey / password / deploykey / token
	@cSource  = "unset"     # literal / env / file / vault / unset
	@cLocator = ""          # env var NAME / file PATH / vault REF  (SAFE to show)
	@cLiteral = ""          # only for the :literal source (dev/test) -- never shown

	def init(pcName)
		@cName = "" + pcName

	  #-- source setters (Q-fluent: return the object AFTER acting) --------

	# dev/test only: the value inline. Still redacted in every output; only
	# Reveal(effectfulActor) returns it.
	def FromLiteralQ(pcValue)
		@cSource  = "literal"
		@cLiteral = "" + pcValue
		@cLocator = "(inline)"
		return This

	def FromEnvQ(pcVarName)
		@cSource  = "env"
		@cLocator = ring_trim("" + pcVarName)
		return This

	def FromFileQ(pcPath)
		@cSource  = "file"
		@cLocator = "" + pcPath
		return This

	def FromVaultQ(pcRef)
		@cSource  = "vault"
		@cLocator = "" + pcRef
		return This

	def SetKindQ(pcKind)
		@cKind = StzLower(ring_trim("" + pcKind))
		return This

	  #-- SAFE reads (never leak the value) --------------------------------

	def Name()
		return @cName

	def Kind()
		return @cKind

	def SourceKind()
		return @cSource

	# the POINTER to where the secret lives -- an env var NAME, a file PATH, a
	# vault REF. Safe to show: it is not the secret. (For :literal it is
	# "(inline)", never the value.)
	def SourceLocator()
		return @cLocator

	# the redacted, safe representation used EVERYWHERE the secret is displayed
	# or serialised. No value ever appears here.
	def Descriptor()
		_src_ = @cSource
		if @cLocator != "" and @cSource != "literal"
			_src_ += ":" + @cLocator
		ok
		return "<secret '" + @cName + "' (" + @cKind + ") from " + _src_ + ">"

	def Masked()
		return StzSecretMask()

	def Show()
		? This.Descriptor()

	  #-- the GOVERNED reveal -- the ONLY path to plaintext ----------------

	# may this actor read the plaintext? Only an effectful, non-sandboxed actor.
	def IsRevealableBy(poActor)
		if NOT isObject(poActor)
			return FALSE
		ok
		return poActor.IsEffectful() and poActor.Posture() != "sandboxed"

	# resolve + return the plaintext -- GATED. An LLMActor (inference-only) is
	# refused; a HumanActor (effectful, trusted) succeeds.
	def Reveal(poActor)
		if NOT This.IsRevealableBy(poActor)
			_who_ = "an unauthorized actor"
			if isObject(poActor)
				_who_ = "actor '" + poActor.Name() + "' (posture " + poActor.Posture() + ")"
			ok
			StzRaise("Refused: " + _who_ + " may not reveal secret '" + @cName +
				"'. Only an effectful, non-sandboxed actor can read a secret.")
		ok
		return This._Resolve()

		def RevealFor(poActor)
			return This.Reveal(poActor)

	# does the secret resolve to a non-empty value? Governed (it touches the
	# value, so the same gate as reveal).
	def IsResolvableBy(poActor)
		if NOT This.IsRevealableBy(poActor)
			return FALSE
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
			StzRaise("Secret '" + @cName + "': vault backend not wired yet (locator '" + @cLocator + "').")
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

# a password -- you rarely reveal it; you HASH it (salted PBKDF2) and verify
# against the hash. The hash is safe to persist.
class stzPassword from stzSecret

	def init(pcName)
		@cName = "" + pcName
		@cKind = "password"

	# a salted, one-way hash (salt:hash) of the resolved password -- safe to
	# store. Governed (resolving the password needs an effectful actor).
	def HashedBy(poActor)
		return StzHashSecret(This.Reveal(poActor))

	# verify a candidate against this password (governed).
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

# a bearer / access token -- may carry an expiry (epoch seconds; 0 = no expiry).
class stzToken from stzSecret

	@nExpiresAt = 0

	def init(pcName)
		@cName = "" + pcName
		@cKind = "token"

	def SetExpiryQ(nEpoch)
		@nExpiresAt = nEpoch
		return This

	def ExpiresAt()
		return @nExpiresAt

	# expired at a given "now" (epoch seconds)? A 0 expiry never expires. The
	# caller passes the clock -- the class holds no wall-clock of its own.
	def IsExpiredAt(nNowEpoch)
		if @nExpiresAt = 0
			return FALSE
		ok
		return nNowEpoch >= @nExpiresAt
