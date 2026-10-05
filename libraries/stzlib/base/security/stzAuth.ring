#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZAUTH                   #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# USER authentication (base/security/, serving the stzApp domain) -- the
# counterpart to stzSecret. Where a
# stzSecret guards a MACHINE credential (an API key, a deploy key), stzAuth
# answers "is this the user they claim to be?" for the PEOPLE using an app.
#
# It holds a credential store (username -> a salted password HASH, never the
# plaintext) and issues opaque SESSION tokens:
#
#   * passwords are hashed with Argon2id (StzHashPassword) and verified by the
#     engine (StzVerifyPassword); a PBKDF2 hash stored before 2026-09-29 is still
#     accepted and upgraded on the next successful login -- the same engine crypto stzSecret and
#     stzPlatform use;
#   * a session is a random 256-bit hex token (StzEngineCryptoRandomHex),
#     mapped back to its user until Logout.
#
# The store never holds a plaintext password, and Show() never prints a hash.
# See stzSecret for the machine-credential side of the same story.

  #=============#
 #  FUNCTIONS  #
#=============#

func StzAuthQ()
	return new stzAuth()


  #==========#
 #  STZAUTH #
#==========#

# Authenticates the users of an app: keeps salted password hashes, opens and ends sessions, and resolves a login into roles and an actor.
#
# It holds a credential store (user name to a salted Argon2id hash, never the plaintext) and issues
# opaque 64-character session tokens. Around the password it offers a second factor (TOTP with
# recovery codes), passwordless doors (magic link, emailed code, passkey), external sign-in (OpenID
# Connect, SAML), a brute-force lockout, an administrative lock, password reset by mail, and roles
# that turn a live session into the stzSystemActor that governance reasons about. The store is in
# memory unless SetStore is given a database store. Every flow has an At form that takes the moment
# as epoch seconds, which makes expiry and lockout testable; the plain forms read the clock.
# Failures answer an empty text, 0 or [ ] instead of raising, except for a missing mail port,
# relying party, provider or client, which raise.
#
#   receiver   o1 = new stzAuth(); o1.Register("alice", "demo-pass-one")
#   example    ? o1.Authenticate("alice", "demo-pass-one")
#              #--> 1
#              ? o1.Authenticate("alice", "wrong")
#              #--> 0
#   see        stzSecret, stzTotp, stzSystemActor
class stzAuth from stzObject

	@oStore = ""       # the persistence seam (users + sessions) -- see stzAuthStore
	@nSessionTTL = 3600  # ABSOLUTE lifetime: seconds from login (0 = never expires)
	@nIdleTTL = 0        # IDLE lifetime: seconds of inactivity before death (0 = off)
	@cDummyHash = ""     # a real hash used to equalize timing for unknown users

	# SAML 2.0: enterprise SSO through a corporate identity provider
	@oSamlSp = ""            # an stzSamlServiceProvider (config + replay guard)
	@cSamlWhy = ""

	# PASSKEYS (WebAuthn): sign in with a device key instead of a secret
	@oPasskeyRp = ""         # an stzPasskeyServer (config: rp id + origin)
	@cPasskeyWhy = ""          # why the last passkey operation was refused

	# EXTERNAL identity (OIDC): sign in with a provider, verified locally
	@oOidc = ""              # an stzOidcClient (config only -- a copy is fine)
	@bOidcAutoProvision = 1 # create the account on a first external login
	@cOidcWhy = ""             # why the last external login was refused

	# passwordless (magic-link / email-OTP) over a mail PORT (service-virtualization)
	@oMailPort = ""          # any object with Send(to, subject, body); NULL = unbound
	@cMagicLinkBaseUrl = ""    # the app URL a magic link points at ("" = a softanza:// uri)
	@nPasswordlessTTL = 900    # how long a magic link / OTP is valid (seconds, 15 min)
	@nResetTTL = 1800          # how long a password-reset link is valid (seconds, 30 min)
	@nMinPasswordLen = 8       # a reset refuses a shorter new password

	# brute-force lockout (in-memory, per submitted username). Not durable across
	# restarts by design -- rate-limit state, not identity data; a shared/durable
	# limiter is a later hardening. Kept here so it never leaks into the store.
	@aFailures = []      # [ [ user, count, lockedUntil ], ... ]
	@nMaxAttempts = 5
	@nLockoutSecs = 900  # 15 minutes

	# authn->authz: role DEFINITIONS (name -> capability KINDS + posture). App
	# config, re-declared per process (the per-user GRANTS are what's durable). A
	# login resolves a user's granted roles into a stzSystemActor -- the very
	# subject the governance lattice, org chart, and graph-rules reason about.
	@aRoleDefs = []      # [ [ name, [ kinds ], posture ], ... ]

	# Builds an authenticator with an empty in-memory store, the four built-in roles and a one-hour session lifetime.
	#
	#   returns    nothing; the object is built
	#   note       defaults: sessions last 3600 s, no idle limit, 5 failed logins lock a user out
	#              for 900 s, magic links and codes last 900 s, reset links 1800 s, a new password
	#              needs 8 characters
	#   see        SetStore, Register
	def init()
		@oStore = new stzAuthMemoryStore()   # durable store injected via SetStore
		@cDummyHash = StzHashPassword("softanza-timing-equalizer")
		@aFailures = []
		This._DefineBuiltinRoles()

	# Replaces the store that keeps users and sessions, for example by a database store; the old content is not copied.
	#
	#   poStore    The store that keeps users and sessions: a stzAuthMemoryStore or a
	#              stzAuthDbStore.
	#   returns    nothing; the store is replaced
	#   note       the default store lives in memory and is lost with the object; a database store
	#              persists to the path it was built with
	#   see        StoreQ, SetStoreQ
	#@ aka  Persist through a chosen store (e.g. StzAuthDbStoreQ("auth.db")). The default is in-memory. Pass a DB store for durability -- its sqlite is an engine handle, so the held copy still writes the same database.
	def SetStore(poStore)
		This.SetStoreQ(poStore)

	def SetStoreQ(poStore)
		@oStore = poStore
		return This

	# Returns the store object that holds the users and the sessions.
	#
	#   returns    a store object
	#   see        SetStore
	def StoreQ()
		return @oStore

	# Sets how many seconds a session opened from now on lasts; 0 means it never expires.
	#
	#   pnSeconds   A duration, in seconds.
	#   returns     nothing; the setting changes
	#   note        sessions already open keep the expiry they were given
	#   see         SessionTTL, SetIdleTTL
	#@ aka  how long a new session lives, in seconds (0 = no expiry). Existing sessions keep the TTL they were issued with.
	def SetSessionTTL(pnSeconds)
		This.SetSessionTTLQ(pnSeconds)

	def SetSessionTTLQ(pnSeconds)
		@nSessionTTL = pnSeconds
		return This

	# Returns the lifetime, in seconds, given to new sessions; 0 means no expiry.
	#
	#   returns    a number, 3600 by default
	#   see        SetSessionTTL
	def SessionTTL()
		return @nSessionTTL

	# Sets how many seconds without use end a session; 0 turns the idle limit off.
	#
	#   pnSeconds   A duration, in seconds.
	#   returns     nothing; the setting changes
	#   note        each successful check of a session slides its idle window, and the limit is
	#               applied to sessions already open
	#   see         IdleTTL, SetSessionTTL
	#@ aka  idle timeout: a session dies if untouched for this many seconds (0 = off). Every successful validation slides the window (touches last-seen).
	def SetIdleTTL(pnSeconds)
		This.SetIdleTTLQ(pnSeconds)

	def SetIdleTTLQ(pnSeconds)
		@nIdleTTL = pnSeconds
		return This

	# Returns the idle limit, in seconds, of the sessions; 0 means there is none.
	#
	#   returns    a number, 0 by default
	#   see        SetIdleTTL
	def IdleTTL()
		return @nIdleTTL

	# Binds the object that sends the mail of the magic-link, email-code and reset flows.
	#
	#   poPort     The mail port: any object with Send(to, subject, body), such as a stzMailSandbox.
	#   returns    nothing; the port is bound
	#   note       any object with Send(to, subject, body) will do; stzMailSandbox captures the
	#              messages in memory instead of sending them
	#   see        MailPortQ, HasMailPort
	#@ aka  -- passwordless config (mail port + magic-link) --------------------
	def SetMailPort(poPort)
		This.SetMailPortQ(poPort)

	def SetMailPortQ(poPort)
		@oMailPort = poPort
		return This

	# Returns the bound mail port, or an empty text when none is bound.
	#
	#   returns    the mail port object, or an empty text
	#   see        SetMailPort, HasMailPort
	def MailPortQ()
		return @oMailPort

	# TRUE if a mail port is bound, as the passwordless and reset requests need.
	#
	#   returns    TRUE or FALSE
	#   see        SetMailPort
	def HasMailPort()
		return isObject(@oMailPort)

	# Sets the app URL that magic links and reset links point at; an empty text gives a softanza:// address.
	#
	#   pcUrl      The base URL of the app, as text; an empty text gives a softanza:// address.
	#   returns    nothing; the setting changes
	#   note       the token is appended as ?token= (magic link) or ?reset= (reset), or with & when
	#              the URL already has a query
	#   see        MagicLinkBaseUrl, RequestMagicLink
	#@ aka  the app URL a magic link points at; the token is appended as ?token=... (or &token=... if the URL already has a query). "" -> a softanza:// URI.
	def SetMagicLinkBaseUrl(pcUrl)
		This.SetMagicLinkBaseUrlQ(pcUrl)

	def SetMagicLinkBaseUrlQ(pcUrl)
		@cMagicLinkBaseUrl = "" + pcUrl
		return This

	# Returns the app URL that magic links and reset links point at; an empty text means none was set.
	#
	#   returns    a text
	#   see        SetMagicLinkBaseUrl
	def MagicLinkBaseUrl()
		return @cMagicLinkBaseUrl

	# Sets how many seconds a magic link or an emailed code stays valid.
	#
	#   pnSeconds   A duration, in seconds.
	#   returns     nothing; the setting changes
	#   note        the default is 900 seconds, which the mail states in minutes
	#   see         PasswordlessTTL, RequestMagicLink, RequestEmailOtp
	#@ aka  how long a magic link / email-OTP stays valid (seconds).
	def SetPasswordlessTTL(pnSeconds)
		This.SetPasswordlessTTLQ(pnSeconds)

	def SetPasswordlessTTLQ(pnSeconds)
		@nPasswordlessTTL = pnSeconds
		return This

	# Returns how many seconds a magic link or an emailed code stays valid.
	#
	#   returns    a number, 900 by default
	#   see        SetPasswordlessTTL
	def PasswordlessTTL()
		return @nPasswordlessTTL

	# Sets how many failed logins lock a user out for a while.
	#
	#   pnMax      The number of failed attempts that triggers a lockout.
	#   returns    nothing; the setting changes
	#   note       the counter lives in memory per user name and is cleared by a successful login
	#   see        MaxAttempts, SetLockoutSeconds, FailedAttempts
	#@ aka  -- brute-force lockout config --------------------------------------
	def SetMaxAttempts(pnMax)
		This.SetMaxAttemptsQ(pnMax)

	def SetMaxAttemptsQ(pnMax)
		@nMaxAttempts = pnMax
		return This

	# Returns how many failed logins lock a user out.
	#
	#   returns    a number, 5 by default
	#   see        SetMaxAttempts
	def MaxAttempts()
		return @nMaxAttempts

	# Sets how many seconds a lockout from failed logins lasts.
	#
	#   pnSecs     A duration, in seconds.
	#   returns    nothing; the setting changes
	#   see        LockoutSeconds, SetMaxAttempts
	def SetLockoutSeconds(pnSecs)
		This.SetLockoutSecondsQ(pnSecs)

	def SetLockoutSecondsQ(pnSecs)
		@nLockoutSecs = pnSecs
		return This

	# Returns how many seconds a lockout from failed logins lasts.
	#
	#   returns    a number, 900 by default
	#   see        SetLockoutSeconds
	def LockoutSeconds()
		return @nLockoutSecs

	# Adds a user with a password, of which only a salted hash is kept; raises an error for an empty name or a name already taken.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   returns      the stzAuth itself, so calls chain
	#   note         the name is trimmed and compared with case, so Alice and alice are two users
	#   see          RegisterPasswordless, IsRegistered, ChangePassword
	#@ aka  -- the credential store --------------------------------------------
	def Register(pcUser, pcPassword)
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			StzRaise("stzAuth.Register: a user name is required.")
		ok
		if @oStore.HasUser(_u_)
			StzRaise("stzAuth.Register: user '" + _u_ + "' already exists.")
		ok
		@oStore.PutUser(_u_, StzHashPassword("" + pcPassword))
		return This

	# Adds a user that has no usable password, reachable only by magic link, emailed code or external login.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   note       an empty password never logs in; a name already taken raises an error
	#   see        Register, RequestMagicLink
	#@ aka  register an account with NO usable password -- reachable only through a passwordless factor (magic-link / email-OTP). The stored hash is of a random value nobody holds, so Login can never succeed for it.
	def RegisterPasswordless(pcUser)
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			StzRaise("stzAuth.RegisterPasswordless: a user name is required.")
		ok
		if @oStore.HasUser(_u_)
			StzRaise("stzAuth.RegisterPasswordless: user '" + _u_ + "' already exists.")
		ok
		@oStore.PutUser(_u_, StzHashPassword(StzEngineCryptoRandomHex(32)))
		return This

	# TRUE if a user of that name exists.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    TRUE or FALSE
	#   note       the name is trimmed and compared with case
	#   see        Register, NumberOfUsers
	def IsRegistered(pcUser)
		return @oStore.HasUser(ring_trim("" + pcUser))

	# Returns how many users are registered.
	#
	#   returns    a number
	#   see        Register, IsRegistered
	def NumberOfUsers()
		return @oStore.CountUsers()

	# Replaces a user's password when the current one is given; FALSE for a wrong current password or an unknown user.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcOld      the current password, as text
	#   pcNew      the new password, as text
	#   returns    TRUE or FALSE
	#   note       open sessions are not ended; ResetPassword is the flow that ends them
	#   see        Register, ResetPassword
	#@ aka  change a password (the current one must be presented). TRUE on success.
	def ChangePassword(pcUser, pcOld, pcNew)
		_u_ = ring_trim("" + pcUser)
		_h_ = @oStore.UserHash(_u_)
		if _h_ = "" or NOT StzVerifyPassword("" + pcOld, _h_)
			return 0
		ok
		@oStore.PutUser(_u_, StzHashPassword("" + pcNew))
		return 1

	# Removes a user together with their sessions, second factor, roles and passkeys.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   note       an unknown user changes nothing and raises no error
	#   see        Register, RevokeAllSessions
	#@ aka  remove a user (and end any of their sessions).
	def Unregister(pcUser)
		_u_ = ring_trim("" + pcUser)
		@oStore.DeleteUser(_u_)
		@oStore.DeleteUserSessions(_u_)
		@oStore.DeleteTotp(_u_)
		@oStore.DeleteUserRoles(_u_)
		@oStore.DeleteUserPasskeys(_u_)
		This._ClearFailures(_u_)
		return This

	# Checks a user's password without opening a session.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   returns      TRUE or FALSE
	#   note         a failed check is not counted toward the lockout and a locked account still
	#                passes; only the Login forms apply both; an unknown user costs as much work as
	#                a wrong password; an old hash is upgraded on success
	#   see          Login, ChangePassword
	#@ aka  -- authentication + sessions ---------------------------------------
	def Authenticate(pcUser, pcPassword)
		_u_ = ring_trim("" + pcUser)
		_h_ = @oStore.UserHash(_u_)
		if _h_ = ""
			StzVerifyPassword("" + pcPassword, @cDummyHash)   # equalize timing
			return 0
		ok
		if NOT StzVerifyPassword("" + pcPassword, _h_)
			return 0
		ok
		if StzPasswordNeedsRehash(_h_)
			@oStore.PutUser(_u_, StzHashPassword("" + pcPassword))
		ok
		return 1

	# Checks the password and opens a session; answers the session token, or an empty text when the login fails.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   returns      a text: a 64-character token, or an empty text
	#   note         an empty text means a wrong password, a lockout or a confirmed second factor,
	#                and does not say which; a user with a second factor must use LoginTwoFactor
	#   see          LoginAt, LoginWith, LoginTwoFactor
	#@ aka  authenticate AND, on success, open a session -> returns an opaque token ("" on failure OR lockout -- indistinguishable, so it leaks nothing).
	def Login(pcUser, pcPassword)
		return This.LoginWithAt(pcUser, pcPassword, "", "", This._NowSecs())

	# Checks the password and opens a session as of the given moment; answers the token, or an empty text.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   pnNow        The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns      a text: a 64-character token, or an empty text
	#   note         it makes the expiry and the lockout deterministic
	#   see          Login, LoginWithAt
	#@ aka  deterministic form (explicit 'now') for tests.
	def LoginAt(pcUser, pcPassword, pnNow)
		return This.LoginWithAt(pcUser, pcPassword, "", "", pnNow)

	# Checks the password and opens a session that remembers the address and the client of the request.
	#
	#   pcUser        The user name, as text; it is trimmed and compared with case.
	#   pcPassword    The password, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   returns       a text: a 64-character token, or an empty text
	#   note          the address and the client are listed by SessionsOf, so a device can be
	#                 revoked
	#   see           Login, SessionsOf
	#@ aka  same, capturing the DEVICE CONTEXT (ip + user-agent) so the session can be listed and revoked per device.
	def LoginWith(pcUser, pcPassword, pcIp, pcUserAgent)
		return This.LoginWithAt(pcUser, pcPassword, pcIp, pcUserAgent, This._NowSecs())

	# Checks the password and opens a session as of the given moment, remembering the address and the client.
	#
	#   pcUser        The user name, as text; it is trimmed and compared with case.
	#   pcPassword    The password, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   pnNow         The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns       a text: a 64-character token, or an empty text
	#   note          every other Login form calls this one
	#   see           LoginWith, LoginAt
	def LoginWithAt(pcUser, pcPassword, pcIp, pcUserAgent, pnNow)
		_u_ = ring_trim("" + pcUser)
		if This.IsLockedOutAt(_u_, pnNow)
			return ""
		ok
		if NOT This.Authenticate(_u_, pcPassword)
			This._RecordFailure(_u_, pnNow)
			return ""
		ok
		This._ClearFailures(_u_)
		# 2FA is ENFORCED: a user with a confirmed second factor cannot open a
		# session with a password alone -- the caller must use LoginTwoFactor.
		# (Check RequiresTwoFactor to know which door to use.) This keeps the
		# common single-factor path unchanged for every user without 2FA.
		if This.HasTotp(_u_)
			return ""
		ok
		return This._OpenSession(_u_, pnNow, "" + pcIp, "" + pcUserAgent)

	# mint a session token + persist its record. The single place a session is
	# opened -- shared by the password path and the two-factor path.
	def _OpenSession(pcUser, pnNow, pcIp, pcUa)
		_tok_ = StzEngineCryptoRandomHex(32)
		@oStore.PutSession(_tok_, This._NewRec(pcUser, pnNow, pcIp, pcUa))
		return _tok_

	# Checks the password and the second-factor code and opens a session; a user without a second factor needs only the password.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   pcCode       The second-factor code, as text: the six digits of the authenticator app or a
	#                recovery code.
	#   returns      a text: a 64-character token, or an empty text
	#   note         a wrong code or a wrong password counts toward the lockout; a one-time recovery
	#                code is accepted as the code
	#   see          Login, VerifyTotp, EnableTotp
	#@ aka  -- two-factor login ------------------------------------------------
	def LoginTwoFactor(pcUser, pcPassword, pcCode)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, "", "", This._NowSecs())

	# Checks the password and the code and opens a session as of the given moment.
	#
	#   pcUser       The user name, as text; it is trimmed and compared with case.
	#   pcPassword   The password, as text.
	#   pcCode       The second-factor code, as text: the six digits of the authenticator app or a
	#                recovery code.
	#   pnNow        The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns      a text: a 64-character token, or an empty text
	#   see          LoginTwoFactor, LoginTwoFactorWithAt
	def LoginTwoFactorAt(pcUser, pcPassword, pcCode, pnNow)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, "", "", pnNow)

	# Checks the password and the code and opens a session that remembers the address and the client.
	#
	#   pcUser        The user name, as text; it is trimmed and compared with case.
	#   pcPassword    The password, as text.
	#   pcCode        The second-factor code, as text: the six digits of the authenticator app or a
	#                 recovery code.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   returns       a text: a 64-character token, or an empty text
	#   see           LoginTwoFactor, SessionsOf
	def LoginTwoFactorWith(pcUser, pcPassword, pcCode, pcIp, pcUserAgent)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, pcIp, pcUserAgent, This._NowSecs())

	# Checks the password and the code and opens a session as of the given moment, remembering the address and the client.
	#
	#   pcUser        The user name, as text; it is trimmed and compared with case.
	#   pcPassword    The password, as text.
	#   pcCode        The second-factor code, as text: the six digits of the authenticator app or a
	#                 recovery code.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   pnNow         The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns       a text: a 64-character token, or an empty text
	#   see           LoginTwoFactorWith
	def LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, pcIp, pcUserAgent, pnNow)
		_u_ = ring_trim("" + pcUser)
		if This.IsLockedOutAt(_u_, pnNow)
			return ""
		ok
		if NOT This.Authenticate(_u_, pcPassword)
			This._RecordFailure(_u_, pnNow)
			return ""
		ok
		if This.HasTotp(_u_)
			if NOT This.VerifyTotpAt(_u_, pcCode, pnNow)
				This._RecordFailure(_u_, pnNow)   # a bad 2nd factor counts toward lockout
				return ""
			ok
		ok
		This._ClearFailures(_u_)
		return This._OpenSession(_u_, pnNow, "" + pcIp, "" + pcUserAgent)

	# build a fresh session record (absolute expiry from now, metadata, lastseen).
	def _NewRec(pcUser, pnNow, pcIp, pcUa)
		_exp_ = 0
		if @nSessionTTL > 0
			_exp_ = pnNow + @nSessionTTL
		ok
		return [ :user = "" + pcUser, :expires = _exp_, :created = pnNow,
		         :ip = "" + pcIp, :ua = "" + pcUa, :lastseen = pnNow ]

	# Returns the user behind a live session token; an empty text when it is unknown, ended, expired, idle or the account is locked.
	#
	#   pcToken    The token, as text.
	#   returns    a text: the user name, or an empty text
	#   note       each successful check slides the idle window; the clock is the wall clock
	#   see        UserOfSessionAt, IsValidSession
	#@ aka  the user behind a live session token, or "" if unknown / ended / EXPIRED (checked against the wall clock).
	def UserOfSession(pcToken)
		return This.UserOfSessionAt(pcToken, This._NowSecs())

	# Returns the user behind a session token as of the given moment, or an empty text when the session is not live then.
	#
	#   pcToken     The token, as text.
	#   pnNowSecs   The moment to act at, in epoch seconds.
	#   returns     a text: the user name, or an empty text
	#   note        the session is dead from its expiry second on
	#   see         UserOfSession
	#@ aka  same, against an explicit 'now' (epoch seconds) -- deterministic for tests. Checks BOTH the absolute expiry and (when enabled) the idle window, and slides the idle window by touching last-seen on a valid access.
	def UserOfSessionAt(pcToken, pnNowSecs)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return ""
		ok
		if _s_[:expires] > 0 and pnNowSecs >= _s_[:expires]
			return ""
		ok
		if @nIdleTTL > 0 and (pnNowSecs - _s_[:lastseen]) >= @nIdleTTL
			return ""
		ok
		# a locked account's sessions stop working at once, before (and
		# whether or not) anyone revokes them
		if len(@oStore.LockOf("" + _s_[:user])) > 0
			return ""
		ok
		if @nIdleTTL > 0
			@oStore.TouchSession("" + pcToken, pnNowSecs)   # slide the idle window
		ok
		return _s_[:user]

	# TRUE if the token belongs to a live session.
	#
	#   pcToken    The token, as text.
	#   returns    TRUE or FALSE
	#   see        UserOfSession, IsValidSessionAt
	def IsValidSession(pcToken)
		return This.UserOfSession(pcToken) != ""

	# TRUE if the token belongs to a session that is live at the given moment.
	#
	#   pcToken     The token, as text.
	#   pnNowSecs   The moment to act at, in epoch seconds.
	#   returns     TRUE or FALSE
	#   see         UserOfSessionAt, IsValidSession
	def IsValidSessionAt(pcToken, pnNowSecs)
		return This.UserOfSessionAt(pcToken, pnNowSecs) != ""

	# Returns the session as a stzToken that carries its expiry; an empty text when the token is unknown.
	#
	#   pcToken    The token, as text.
	#   returns    a stzToken, or an empty text
	#   see        SessionInfo, SessionExpiresAt
	#@ aka  the session as a stzToken (its expiry, its kind), or NULL if unknown -- reconstructed from the stored token + expiry.
	def SessionToken(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return ""
		ok
		_oTok_ = new stzToken("session")
		_oTok_.FromLiteral("" + pcToken)
		if _s_[:expires] > 0
			_oTok_.SetExpiry(_s_[:expires])
		ok
		return _oTok_

	# Returns the moment a session expires, in epoch seconds; 0 when it never expires, -1 when the token is unknown.
	#
	#   pcToken    The token, as text.
	#   returns    a number
	#   see        SessionTTL, SessionInfo
	#@ aka  the epoch-seconds a session expires at (0 = never), or -1 if unknown.
	def SessionExpiresAt(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return -1
		ok
		return _s_[:expires]

	# Deletes the sessions that are past their expiry or idle limit at the given moment, and returns how many.
	#
	#   pnNowSecs   The moment to act at, in epoch seconds.
	#   returns     a number
	#   note        an expired session stays counted by NumberOfSessions until it is purged
	#   see         PurgeExpired, NumberOfSessions
	#@ aka  drop expired sessions (housekeeping) -> the number pruned. Prunes BOTH absolute-expired and (when idle timeout is on) idle-expired sessions.
	def PurgeExpiredAt(pnNowSecs)
		_aS_ = @oStore.Sessions()
		_nP_ = 0
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			_dead_ = 0
			if _aS_[_i_][:expires] > 0 and pnNowSecs >= _aS_[_i_][:expires]
				_dead_ = 1
			ok
			if @nIdleTTL > 0 and (pnNowSecs - _aS_[_i_][:lastseen]) >= @nIdleTTL
				_dead_ = 1
			ok
			if _dead_
				# Incident I2: the row is about to be deleted, so this is the
				# last moment anyone can say the session existed. An expiry is
				# `info` -- routine, not adversarial -- but "when did this
				# user's session end" is a question every session-hijack
				# post-mortem asks, and the deleted row cannot answer it.
				# The TOKEN is a credential and is never written; the user
				# and the address the session was opened from are descriptors.
				StzNoteFactFrom("auth.session.expired", "" + _aS_[_i_][:user],
					"user:" + _aS_[_i_][:user], "the session reached its expiry",
					"" + _aS_[_i_][:ip])
				@oStore.DeleteSession(_aS_[_i_][:token])
				_nP_++
			ok
		next
		return _nP_

	# Deletes the sessions that are past their expiry or idle limit now, and returns how many.
	#
	#   returns    a number
	#   see        PurgeExpiredAt
	def PurgeExpired()
		return This.PurgeExpiredAt(This._NowSecs())

	# Returns how many sessions the store holds, expired ones included until they are purged.
	#
	#   returns    a number
	#   see        PurgeExpired, SessionsOf
	def NumberOfSessions()
		return @oStore.CountSessions()

	# Ends one session; an unknown token changes nothing.
	#
	#   pcToken    The token, as text.
	#   returns    the stzAuth itself, so calls chain
	#   see        RevokeSession, RevokeAllSessions
	def Logout(pcToken)
		This._NoteSessionEnd("" + pcToken, "the user signed out")
		@oStore.DeleteSession("" + pcToken)
		return This

	# Ends one session, as the per-device sign out of a devices list; an unknown token changes nothing.
	#
	#   pcToken    The token, as text.
	#   returns    the stzAuth itself, so calls chain
	#   see        Logout, SessionsOf
	#@ aka  revoke ONE session (per-device "sign out this device"). Alias of Logout, named for the device-management flow.
	def RevokeSession(pcToken)
		This._NoteSessionEnd("" + pcToken, "the session was revoked")
		@oStore.DeleteSession("" + pcToken)
		return This

	# Ends every session of a user without removing the account.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   note       each ended session leaves a note in the security ledger when one is open
	#   see        Logout, Unregister
	#@ aka  end EVERY session for a user without removing the account ("log out everywhere") -- distinct from Unregister.
	def RevokeAllSessions(pcUser)
		_u_ = ring_trim("" + pcUser)
		# "log out everywhere" is what a user does AFTER they suspect a
		# compromise, so it is one of the more informative facts in the
		# whole ledger -- and Unregister-adjacent code deletes the rows
		# that could otherwise have told the story. One event per device
		# ended, because "how many sessions did they have" is the question
		# that follows.
		_aS_ = @oStore.SessionsOf(_u_)
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			StzNoteFactFrom("auth.session.revoked", _u_, "user:" + _u_,
				"every session was revoked at once", "" + _aS_[_i_][:ip])
		next
		@oStore.DeleteUserSessions(_u_)
		return This

	# Incident I2. Called BEFORE the row is deleted -- afterwards nobody can
	# say whose session it was. The token never enters the ledger: it is a
	# bearer credential, and writing it into evidence would turn the
	# evidence file into a way in.
	def _NoteSessionEnd(pcToken, pcWhat)
		_r_ = @oStore.Session("" + pcToken)
		if len(_r_) = 0
			return
		ok
		StzNoteFactFrom("auth.session.revoked", "" + _r_[:user],
			"user:" + _r_[:user], pcWhat, "" + _r_[:ip])

	# Returns the live sessions of a user as descriptors, for a view of the devices.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a list of hash lists [ :token, :user, :created, :ip, :userAgent, :expires,
	#              :lastSeen ]; [ ] when none
	#   note       the token in each descriptor is the secret that opens the session
	#   see        SessionsOfAt, RevokeSession
	#@ aka  -- the "your devices" surface + fixation defense -------------------
	def SessionsOf(pcUser)
		return This.SessionsOfAt(pcUser, This._NowSecs())

	# Returns the sessions of a user that are live at the given moment, as descriptors.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a list of hash lists, as SessionsOf gives
	#   see        SessionsOf
	def SessionsOfAt(pcUser, pnNow)
		_out_ = []
		_aR_ = @oStore.SessionsOf(ring_trim("" + pcUser))
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			_r_ = _aR_[_i_]
			# skip ones already dead (absolute or idle)
			if _r_[:expires] > 0 and pnNow >= _r_[:expires]
				loop
			ok
			if @nIdleTTL > 0 and (pnNow - _r_[:lastseen]) >= @nIdleTTL
				loop
			ok
			_out_ + [ :token = _r_[:token], :user = _r_[:user], :created = _r_[:created],
			          :ip = _r_[:ip], :userAgent = _r_[:ua], :expires = _r_[:expires],
			          :lastSeen = _r_[:lastseen] ]
		next
		return _out_

	# Returns the descriptor of one session, or [ ] when the token is unknown.
	#
	#   pcToken    The token, as text.
	#   returns    a hash list [ :token, :user, :created, :ip, :userAgent, :expires, :lastSeen ]; [
	#              ] when unknown
	#   note       it answers even for a session that has expired but is not yet purged
	#   see        SessionsOf, SessionToken
	#@ aka  one session's public descriptor, or [] if unknown.
	def SessionInfo(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return []
		ok
		return [ :token = _s_[:token], :user = _s_[:user], :created = _s_[:created],
		         :ip = _s_[:ip], :userAgent = _s_[:ua], :expires = _s_[:expires],
		         :lastSeen = _s_[:lastseen] ]

	# Replaces a live session's token by a new one for the same user and device, and voids the old one.
	#
	#   pcToken    The token, as text.
	#   returns    a text: the new token, or an empty text when the old one is not live
	#   note       call it after a privilege change so that the old token cannot be replayed; the
	#              new expiry counts from now
	#   see        RotateSessionAt, RevokeSession
	#@ aka  ROTATE a session's token (session-fixation defense): after a privilege change -- 2FA, password change, elevation -- issue a NEW token for the same user + device, void the OLD one, and return the new token ("" if invalid). The pre-elevation token can no longer be replayed.
	def RotateSession(pcToken)
		return This.RotateSessionAt(pcToken, This._NowSecs())

	# Replaces a session's token by a new one as of the given moment, voiding the old one.
	#
	#   pcToken    The token, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a text: the new token, or an empty text
	#   note       the new session lives a full session lifetime from the given moment, whatever
	#              time the old one had left
	#   see        RotateSession
	def RotateSessionAt(pcToken, pnNow)
		_u_ = This.UserOfSessionAt("" + pcToken, pnNow)
		if _u_ = ""
			return ""
		ok
		_s_ = @oStore.Session("" + pcToken)
		_new_ = StzEngineCryptoRandomHex(32)
		@oStore.PutSession(_new_, This._NewRec(_u_, pnNow, _s_[:ip], _s_[:ua]))
		@oStore.DeleteSession("" + pcToken)
		return _new_

	# TRUE if the user has a confirmed second factor, which logins then require.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    TRUE or FALSE
	#   note       a pending enrollment does not count
	#   see        EnableTotp, ConfirmTotp, RequiresTwoFactor
	#@ aka  -- two-factor authentication (TOTP) --------------------------------
	def HasTotp(pcUser)
		_rec_ = @oStore.Totp(ring_trim("" + pcUser))
		return (len(_rec_) > 0) and (_rec_[:confirmed] = 1)

	# app-facing alias: does signing this user in require a second factor?
	def RequiresTwoFactor(pcUser)
		return This.HasTotp(pcUser)

	# Starts the second-factor enrollment of a user and answers the secret and the otpauth URI to show as a QR code.
	#
	#   pcUser     the user name of an existing user, as text
	#   pcIssuer   The name of the app shown in the authenticator, as text.
	#   returns    a hash list [ :secret, :uri ]
	#   note       nothing is enforced until ConfirmTotp; a pending enrollment is replaced by a new
	#              secret; the secret is shown once
	#   warning    Raises an error for an unknown user, and for a user whose second factor is
	#              already confirmed
	#   see        ConfirmTotp, DisableTotp
	#@ aka  begin enrollment: mint a secret, store it UNCONFIRMED, and return [ :secret, :uri ]. Render :uri as a QR code for the user's app; :secret is the same key for manual entry. Nothing is enforced until ConfirmTotp. Raises if a CONFIRMED factor already exists (disable it first); a still-pending enrollment is simply replaced.
	def EnableTotp(pcUser, pcIssuer)
		_u_ = ring_trim("" + pcUser)
		if NOT @oStore.HasUser(_u_)
			StzRaise("stzAuth.EnableTotp: no such user '" + _u_ + "'.")
		ok
		if This.HasTotp(_u_)
			StzRaise("stzAuth.EnableTotp: 2FA already active for '" + _u_ + "' -- disable it first.")
		ok
		_oT_ = new stzTotp()
		@oStore.PutTotp(_u_, _oT_.Secret(), 0, [])
		return [ :secret = _oT_.Secret(),
		         :uri = _oT_.ProvisioningUri(_u_, "" + pcIssuer) ]

	# Finishes the enrollment when the code from the app is right, enforcing the factor and answering ten recovery codes.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   returns    a list of ten recovery codes, each 16 hex characters; [ ] when the code is wrong
	#              or there is no enrollment
	#   note       show the codes once: only their hashes are kept
	#   see        ConfirmTotpAt, VerifyTotp, RegenerateRecoveryCodes
	#@ aka  finish enrollment: verify the app's current code. On success the factor is confirmed (now enforced) and a fresh set of one-time recovery codes is returned -- show them to the user ONCE (only their hashes are stored). Returns [] on a bad code (enrollment stays pending).
	def ConfirmTotp(pcUser, pcCode)
		return This.ConfirmTotpAt(pcUser, pcCode, This._NowSecs())

	# Finishes the enrollment as of the given moment and answers the ten recovery codes, or [ ] for a wrong code.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a list of ten recovery codes; [ ] when the code is wrong
	#   see        ConfirmTotp
	def ConfirmTotpAt(pcUser, pcCode, pnNow)
		_u_ = ring_trim("" + pcUser)
		_rec_ = @oStore.Totp(_u_)
		if len(_rec_) = 0
			return []
		ok
		_oT_ = StzTotpFromSecretQ(_rec_[:secret])
		if NOT _oT_.VerifyAt(pcCode, pnNow)
			return []
		ok
		@oStore.SetTotpConfirmed(_u_, 1)
		return This._IssueRecoveryCodes(_u_)

	# TRUE if the code is the current authenticator code or an unused recovery code of a user whose factor is confirmed.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   returns    TRUE or FALSE
	#   note       a recovery code is consumed by a successful check and can be typed in upper case
	#              or with spaces; FALSE when the factor is not confirmed
	#   see        VerifyTotpAt, LoginTwoFactor, RecoveryCodesRemaining
	#@ aka  verify a TOTP code (or a one-time recovery code) for a confirmed user.
	def VerifyTotp(pcUser, pcCode)
		return This.VerifyTotpAt(pcUser, pcCode, This._NowSecs())

	# TRUE if the code is the authenticator code at the given moment or an unused recovery code.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    TRUE or FALSE
	#   see        VerifyTotp
	def VerifyTotpAt(pcUser, pcCode, pnNow)
		_u_ = ring_trim("" + pcUser)
		_rec_ = @oStore.Totp(_u_)
		if (len(_rec_) = 0) or (_rec_[:confirmed] != 1)
			return 0
		ok
		_oT_ = StzTotpFromSecretQ(_rec_[:secret])
		if _oT_.VerifyAt(pcCode, pnNow)
			return 1
		ok
		return This._ConsumeRecoveryCode(_u_, pcCode, _rec_[:recovery])

	# Removes the user's second factor with its secret and recovery codes; plain logins work again.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   note       a user without a second factor changes nothing
	#   see        EnableTotp, HasTotp
	#@ aka  turn 2FA off (removes the secret + every recovery code).
	def DisableTotp(pcUser)
		@oStore.DeleteTotp(ring_trim("" + pcUser))
		return This

	# Issues a new set of ten recovery codes for a confirmed second factor and cancels the old ones.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a list of ten recovery codes, each 16 hex characters
	#   note       show the codes once: only their hashes are kept
	#   warning    Raises an error for a user whose second factor is not confirmed
	#   see        RecoveryCodesRemaining, ConfirmTotp
	#@ aka  issue a FRESH set of recovery codes (the old set stops working). Returns the plaintext to show once. Only for a confirmed factor.
	def RegenerateRecoveryCodes(pcUser)
		_u_ = ring_trim("" + pcUser)
		if NOT This.HasTotp(_u_)
			StzRaise("stzAuth.RegenerateRecoveryCodes: no confirmed 2FA for '" + _u_ + "'.")
		ok
		return This._IssueRecoveryCodes(_u_)

	# Returns how many recovery codes of a user are still unused.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a number; 0 for a user without a second factor
	#   see        VerifyTotp, RegenerateRecoveryCodes
	#@ aka  how many unused recovery codes remain.
	def RecoveryCodesRemaining(pcUser)
		_rec_ = @oStore.Totp(ring_trim("" + pcUser))
		if len(_rec_) = 0
			return 0
		ok
		return len(_rec_[:recovery])

	# Mails a one-time sign-in link to a registered user, and answers 1 whether or not the user exists.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   returns    the number 1, always
	#   note       the answer is the same for an unknown address, so it does not reveal who has an
	#              account; only the sha256 of the token is stored
	#   warning    Raises an error when no mail port is bound
	#   see        RedeemMagicLink, SetMailPort, SetMagicLinkBaseUrl
	#@ aka  -- passwordless: magic link ----------------------------------------
	def RequestMagicLink(pcEmail)
		return This.RequestMagicLinkAt(pcEmail, This._NowSecs())

	# Mails the one-time sign-in link as of the given moment, which sets how long it stays valid.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    the number 1, always
	#   warning    Raises an error when no mail port is bound
	#   see        RequestMagicLink
	def RequestMagicLinkAt(pcEmail, pnNow)
		if NOT This.HasMailPort()
			StzRaise("stzAuth.RequestMagicLink: no mail port bound -- call SetMailPort.")
		ok
		_u_ = ring_trim("" + pcEmail)
		if @oStore.HasUser(_u_)
			_tok_ = StzEngineCryptoRandomHex(32)
			@oStore.PutChallenge(StzEngineCryptoSha256(_tok_), "magiclink", _u_, "",
			                     pnNow + @nPasswordlessTTL)
			@oMailPort.Send(_u_, "Your sign-in link",
			    "Click to sign in: " + This._MagicLinkUrl(_tok_) + char(10) +
			    "This link expires in " + floor(@nPasswordlessTTL / 60) + " minutes.")
		ok
		return 1

	# Exchanges a magic-link token for a session; an empty text when it is unknown, used, expired, or the user has a second factor.
	#
	#   pcToken    The token, as text.
	#   returns    a text: a 64-character token, or an empty text
	#   note       the link works once, whatever the outcome; the clock is the wall clock
	#   see        RequestMagicLink, RedeemMagicLinkAt
	#@ aka  redeem a magic-link token -> a session token ("" if invalid / expired / for a user who since vanished, or whose 2FA forbids the shortcut).
	def RedeemMagicLink(pcToken)
		return This.RedeemMagicLinkWithAt(pcToken, "", "", This._NowSecs())

	# Exchanges a magic-link token for a session as of the given moment.
	#
	#   pcToken    The token, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a text: a 64-character token, or an empty text
	#   see        RedeemMagicLink
	def RedeemMagicLinkAt(pcToken, pnNow)
		return This.RedeemMagicLinkWithAt(pcToken, "", "", pnNow)

	# Exchanges a magic-link token for a session that remembers the address and the client.
	#
	#   pcToken       The token, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   returns       a text: a 64-character token, or an empty text
	#   see           RedeemMagicLink, SessionsOf
	def RedeemMagicLinkWith(pcToken, pcIp, pcUserAgent)
		return This.RedeemMagicLinkWithAt(pcToken, pcIp, pcUserAgent, This._NowSecs())

	# Exchanges a magic-link token for a session as of the given moment, remembering the address and the client.
	#
	#   pcToken       The token, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   pnNow         The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns       a text: a 64-character token, or an empty text
	#   see           RedeemMagicLinkWith
	def RedeemMagicLinkWithAt(pcToken, pcIp, pcUserAgent, pnNow)
		_handle_ = StzEngineCryptoSha256(ring_trim("" + pcToken))
		_ch_ = @oStore.Challenge(_handle_)
		if (len(_ch_) = 0) or (_ch_[:kind] != "magiclink")
			return ""
		ok
		@oStore.DeleteChallenge(_handle_)                 # one-time, whatever the outcome
		if (_ch_[:expires] > 0) and (pnNow >= _ch_[:expires])
			return ""
		ok
		return This._PasswordlessSession(_ch_[:email], pnNow, "" + pcIp, "" + pcUserAgent)

	# Sets how many seconds a password-reset link stays valid, and returns the object.
	#
	#   pnSeconds   A duration, in seconds.
	#   returns     the stzAuth itself, so calls chain
	#   note        the default is 1800 seconds; unlike the other setters it returns the object
	#   see         RequestPasswordReset
	#@ aka  -- password reset (threat-model R8) ---------------------------------
	def SetPasswordResetTTL(pnSeconds)
		@nResetTTL = pnSeconds
		return This

	# Mails a one-time reset link to a registered user, and answers 1 whether or not the user exists.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   returns    the number 1, always
	#   note       a newer request cancels the older link; the answer does not reveal who has an
	#              account
	#   warning    Raises an error when no mail port is bound
	#   see        ResetPassword, SetMailPort
	def RequestPasswordReset(pcEmail)
		return This.RequestPasswordResetAt(pcEmail, This._NowSecs())

	# Mails the reset link as of the given moment, which sets how long it stays valid.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    the number 1, always
	#   warning    Raises an error when no mail port is bound
	#   see        RequestPasswordReset
	def RequestPasswordResetAt(pcEmail, pnNow)
		if NOT This.HasMailPort()
			StzRaise("stzAuth.RequestPasswordReset: no mail port bound -- call SetMailPort.")
		ok
		_u_ = ring_trim("" + pcEmail)
		if @oStore.HasUser(_u_)
			# one live link per user: the pointer challenge names the current
			# handle, so a new request can retire the previous one
			_ptr_ = @oStore.Challenge("pwreset:" + _u_)
			if len(_ptr_) > 0
				@oStore.DeleteChallenge("" + _ptr_[:codehash])
			ok
			_tok_ = StzEngineCryptoRandomHex(32)
			_handle_ = StzEngineCryptoSha256(_tok_)
			@oStore.PutChallenge(_handle_, "pwreset", _u_, "", pnNow + @nResetTTL)
			@oStore.PutChallenge("pwreset:" + _u_, "pwresetptr", _u_, _handle_, pnNow + @nResetTTL)
			@oMailPort.Send(_u_, "Reset your password",
			    "To choose a new password, open: " + This._ResetUrl(_tok_) + char(10) +
			    "This link works once and expires in " + floor(@nResetTTL / 60) + " minutes." + char(10) +
			    "If you did not ask for this, ignore this message: nothing has changed.")
		ok
		return 1

	# Sets a new password with a reset-link token, ends every session of the user and clears their failed logins; 1 on success, 0 otherwise.
	#
	#   pcToken         The token, as text.
	#   pcNewPassword   The new password, as text; at least 8 characters.
	#   returns         1 or 0
	#   note            0 for an unknown, used or expired token, a password under 8 characters, or
	#                   an account locked by LockAccount; the token is burned by the first try, so a
	#                   refused short password needs a new link; nobody is signed in by it
	#   see             RequestPasswordReset, ChangePassword
	#@ aka  Redeem a reset link. 1 when the password was changed, 0 otherwise -- unknown, used, expired, a new password too short, or a locked account.
	def ResetPassword(pcToken, pcNewPassword)
		return This.ResetPasswordAt(pcToken, pcNewPassword, This._NowSecs())

	# Sets a new password with a reset-link token as of the given moment; 1 on success, 0 otherwise.
	#
	#   pcToken         The token, as text.
	#   pcNewPassword   The new password, as text; at least 8 characters.
	#   pnNow           The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns         1 or 0
	#   see             ResetPassword
	def ResetPasswordAt(pcToken, pcNewPassword, pnNow)
		_handle_ = StzEngineCryptoSha256(ring_trim("" + pcToken))
		_ch_ = @oStore.Challenge(_handle_)
		if (len(_ch_) = 0) or (_ch_[:kind] != "pwreset")
			return 0
		ok
		@oStore.DeleteChallenge(_handle_)               # one-time, whatever the outcome
		_u_ = "" + _ch_[:email]
		@oStore.DeleteChallenge("pwreset:" + _u_)
		if (_ch_[:expires] > 0) and (pnNow >= _ch_[:expires])
			return 0
		ok
		if NOT @oStore.HasUser(_u_)
			return 0
		ok
		if len(@oStore.LockOf(_u_)) > 0
			StzNoteRefusal("auth.password.reset", _u_, "user:" + _u_,
				"refused: the account is locked by containment -- a reset cannot reopen it")
			return 0
		ok
		if len("" + pcNewPassword) < @nMinPasswordLen
			return 0
		ok
		@oStore.PutUser(_u_, StzHashPassword("" + pcNewPassword))
		This.RevokeAllSessions(_u_)
		This._ClearFailures(_u_)
		StzNoteGrant("auth.password.reset", _u_, "user:" + _u_)
		return 1

	def _ResetUrl(pcToken)
		if @cMagicLinkBaseUrl = ""
			return "softanza://reset?reset=" + pcToken
		ok
		_sep_ = "?"
		if StzFindFirst("?", @cMagicLinkBaseUrl) > 0
			_sep_ = "&"
		ok
		return @cMagicLinkBaseUrl + _sep_ + "reset=" + pcToken

	# Mails a six-digit one-time code to a registered user, and answers 1 whether or not the user exists.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   returns    the number 1, always
	#   note       one code is pending per address and a new request replaces it; only a hash of the
	#              code is stored
	#   warning    Raises an error when no mail port is bound
	#   see        VerifyEmailOtp, SetMailPort
	#@ aka  -- passwordless: email OTP -----------------------------------------
	def RequestEmailOtp(pcEmail)
		return This.RequestEmailOtpAt(pcEmail, This._NowSecs())

	# Mails the six-digit code as of the given moment, which sets how long it stays valid.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    the number 1, always
	#   warning    Raises an error when no mail port is bound
	#   see        RequestEmailOtp
	def RequestEmailOtpAt(pcEmail, pnNow)
		if NOT This.HasMailPort()
			StzRaise("stzAuth.RequestEmailOtp: no mail port bound -- call SetMailPort.")
		ok
		_u_ = ring_trim("" + pcEmail)
		if @oStore.HasUser(_u_)
			_code_ = This._RandomOtp()
			@oStore.PutChallenge("otp:" + _u_, "emailotp", _u_, StzHashSecret(_code_),
			                     pnNow + @nPasswordlessTTL)
			@oMailPort.Send(_u_, "Your sign-in code",
			    "Your code is: " + _code_ + char(10) +
			    "It expires in " + floor(@nPasswordlessTTL / 60) + " minutes.")
		ok
		return 1

	# Exchanges the emailed code for a session; an empty text for a wrong, used or expired code, a lockout, or a user with a second factor.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   returns    a text: a 64-character token, or an empty text
	#   note       a wrong code counts toward the lockout; the code works once; the clock is the
	#              wall clock
	#   see        RequestEmailOtp, VerifyEmailOtpAt
	#@ aka  verify an emailed OTP -> a session token ("" on any failure / lockout / a 2FA user).
	def VerifyEmailOtp(pcEmail, pcCode)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, "", "", This._NowSecs())

	# Exchanges the emailed code for a session as of the given moment.
	#
	#   pcEmail    The user name of the account, which is its email address, as text.
	#   pcCode     The second-factor code, as text: the six digits of the authenticator app or a
	#              recovery code.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a text: a 64-character token, or an empty text
	#   see        VerifyEmailOtp
	def VerifyEmailOtpAt(pcEmail, pcCode, pnNow)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, "", "", pnNow)

	# Exchanges the emailed code for a session that remembers the address and the client.
	#
	#   pcEmail       The user name of the account, which is its email address, as text.
	#   pcCode        The second-factor code, as text: the six digits of the authenticator app or a
	#                 recovery code.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   returns       a text: a 64-character token, or an empty text
	#   see           VerifyEmailOtp, SessionsOf
	def VerifyEmailOtpWith(pcEmail, pcCode, pcIp, pcUserAgent)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, pcIp, pcUserAgent, This._NowSecs())

	# Exchanges the emailed code for a session as of the given moment, remembering the address and the client.
	#
	#   pcEmail       The user name of the account, which is its email address, as text.
	#   pcCode        The second-factor code, as text: the six digits of the authenticator app or a
	#                 recovery code.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   pnNow         The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns       a text: a 64-character token, or an empty text
	#   see           VerifyEmailOtpWith
	def VerifyEmailOtpWithAt(pcEmail, pcCode, pcIp, pcUserAgent, pnNow)
		_u_ = ring_trim("" + pcEmail)
		if This.IsLockedOutAt(_u_, pnNow)
			return ""
		ok
		_handle_ = "otp:" + _u_
		_ch_ = @oStore.Challenge(_handle_)
		if (len(_ch_) = 0) or (_ch_[:kind] != "emailotp")
			return ""
		ok
		if (_ch_[:expires] > 0) and (pnNow >= _ch_[:expires])
			@oStore.DeleteChallenge(_handle_)
			return ""
		ok
		if NOT StzVerifySecret(ring_trim("" + pcCode), _ch_[:codehash])
			This._RecordFailure(_u_, pnNow)               # a bad code counts toward lockout
			return ""
		ok
		@oStore.DeleteChallenge(_handle_)                 # one-time
		This._ClearFailures(_u_)
		return This._PasswordlessSession(_ch_[:email], pnNow, "" + pcIp, "" + pcUserAgent)

	# Defines or redefines a role as capability kinds with a trust posture; raises an error for an empty name, kind or posture.
	#
	#   pcName      the role name, as text
	#   paKinds     The capability kinds, as a list of text drawn from effectful, sensing, compute
	#               and inference.
	#   pcPosture   The trust posture: trusted, external or sandboxed.
	#   returns     the stzAuth itself, so calls chain
	#   note        four roles exist from the start: admin, member, viewer and assistant; redefining
	#               a name replaces the old definition
	#   see         GrantRole, RoleDefinition, ActorForUser
	#@ aka  -- authn -> authz: roles, and the ACTOR a login yields -------------
	def DefineRole(pcName, paKinds, pcPosture)
		_n_ = StzLower(ring_trim("" + pcName))
		if _n_ = ""
			StzRaise("stzAuth.DefineRole: a role name is required.")
		ok
		# a probe actor validates kinds + posture (it raises on anything invalid)
		# and normalises them.
		_probe_ = new stzSystemActor(_n_, paKinds)
		_probe_.SetPosture(pcPosture)
		_rec_ = [ _n_, _probe_.Kinds(), _probe_.Posture() ]
		_i_ = This._RoleDefIndex(_n_)
		if _i_ > 0
			@aRoleDefs[_i_] = _rec_
		else
			@aRoleDefs + _rec_
		ok
		return This

	# TRUE if a role of that name is defined.
	#
	#   pcName     the role name, as text
	#   returns    TRUE or FALSE
	#   see        DefineRole, RoleNames
	def HasRoleDefined(pcName)
		return This._RoleDefIndex(StzLower(ring_trim("" + pcName))) > 0

	# Returns the names of the defined roles, in lower case, in the order they were defined.
	#
	#   returns    a list of text; admin, member, viewer, assistant come first
	#   see        DefineRole, RoleDefinition
	def RoleNames()
		_out_ = []
		_n_ = len(@aRoleDefs)
		for _i_ = 1 to _n_
			_out_ + @aRoleDefs[_i_][1]
		next
		return _out_

	# Returns a role as a hash list of its name, its capability kinds and its posture; [ ] when it is not defined.
	#
	#   pcName     the role name, as text
	#   returns    a hash list [ :name, :kinds, :posture ]; [ ] when not defined
	#   see        DefineRole, RoleNames
	def RoleDefinition(pcName)
		_i_ = This._RoleDefIndex(StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return []
		ok
		_r_ = @aRoleDefs[_i_]
		return [ :name = _r_[1], :kinds = _r_[2], :posture = _r_[3] ]

	# Gives a defined role to an existing user; raises an error for an unknown user or an undefined role.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcRole     The role name, as text; case is ignored.
	#   returns    the stzAuth itself, so calls chain
	#   note       granting a role the user already holds changes nothing; the role name is compared
	#              in lower case
	#   see        RevokeRole, RolesOf, DefineRole
	#@ aka  grant a role to a user (durable). The role must be defined and the user must exist. Returns This.
	def GrantRole(pcUser, pcRole)
		_u_ = ring_trim("" + pcUser)
		_r_ = StzLower(ring_trim("" + pcRole))
		if NOT @oStore.HasUser(_u_)
			StzRaise("stzAuth.GrantRole: no such user '" + _u_ + "'.")
		ok
		if NOT This.HasRoleDefined(_r_)
			StzRaise("stzAuth.GrantRole: role '" + _r_ + "' is not defined (see DefineRole).")
		ok
		@oStore.GrantRole(_u_, _r_)
		return This

	# Takes a role away from a user; a role the user does not hold changes nothing.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcRole     The role name, as text; case is ignored.
	#   returns    the stzAuth itself, so calls chain
	#   see        GrantRole, RolesOf
	def RevokeRole(pcUser, pcRole)
		@oStore.RevokeRole(ring_trim("" + pcUser), StzLower(ring_trim("" + pcRole)))
		return This

	# TRUE if the user holds the role.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcRole     The role name, as text; case is ignored.
	#   returns    TRUE or FALSE
	#   note       the role name is compared in lower case
	#   see        GrantRole, RolesOf
	def HasRole(pcUser, pcRole)
		return @oStore.HasRole(ring_trim("" + pcUser), StzLower(ring_trim("" + pcRole)))

	# Returns the names of the roles a user holds, in the order they were granted.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a list of text; [ ] for a user with no role
	#   see        GrantRole, HasRole
	def RolesOf(pcUser)
		return @oStore.RolesOf(ring_trim("" + pcUser))

	# Returns the stzSystemActor of a user: the union of the capability kinds of their roles, at the most restrictive posture among them.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a stzSystemActor named for the user
	#   note       a user with no role gets an actor with no capability, sandboxed, so it is
	#              authenticated and permitted nothing
	#   see        ActorOf, GrantRole
	#@ aka  the ACTOR a user resolves to: a stzSystemActor named for the user, holding the UNION of its roles' capability kinds, at the MOST RESTRICTIVE posture among them. A user with no roles is a capability-less, sandboxed actor -- properly authenticated, yet permitted nothing (least privilege by default).
	def ActorForUser(pcUser)
		_u_ = ring_trim("" + pcUser)
		_aRoles_ = @oStore.RolesOf(_u_)
		_aKinds_ = []
		_cPosture_ = "trusted"
		_bHas_ = 0
		_n_ = len(_aRoles_)
		for _i_ = 1 to _n_
			_def_ = This.RoleDefinition(_aRoles_[_i_])
			if len(_def_) = 0
				loop
			ok
			_bHas_ = 1
			_m_ = len(_def_[:kinds])
			for _j_ = 1 to _m_
				if This._InList(_def_[:kinds][_j_], _aKinds_) = 0
					_aKinds_ + _def_[:kinds][_j_]
				ok
			next
			_cPosture_ = This._MinPosture(_cPosture_, _def_[:posture])
		next
		_oActor_ = new stzSystemActor(_u_, _aKinds_)
		if _bHas_
			_oActor_.SetPosture(_cPosture_)
		else
			_oActor_.SetPosture("sandboxed")   # no roles -> least privilege
		ok
		return _oActor_

	# Returns the actor behind a live session; an empty text when the session is not live.
	#
	#   pcToken    The token, as text.
	#   returns    a stzSystemActor, or an empty text
	#   note       the clock is the wall clock
	#   see        ActorOfAt, ActorForUser
	#@ aka  the actor behind a LIVE session (NULL if the session is invalid / expired).
	def ActorOf(pcToken)
		return This.ActorOfAt(pcToken, This._NowSecs())

	# Returns the actor behind a session as of the given moment; an empty text when the session is not live then.
	#
	#   pcToken    The token, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    a stzSystemActor, or an empty text
	#   see        ActorOf
	def ActorOfAt(pcToken, pnNow)
		_u_ = This.UserOfSessionAt(pcToken, pnNow)
		if _u_ = ""
			return ""
		ok
		return This.ActorForUser(_u_)

	# reads better at the call site.
	def SessionActor(pcToken)
		return This.ActorOf(pcToken)

	def SessionActorAt(pcToken, pnNow)
		return This.ActorOfAt(pcToken, pnNow)

	# TRUE if the session is live and its user holds the capability kind.
	#
	#   pcToken    The token, as text.
	#   pcKind     The capability kind to test: effectful, sensing, compute or inference.
	#   returns    TRUE or FALSE
	#   note       FALSE for an invalid session
	#   see        SessionCanAt, SessionIsEffectful
	#@ aka  does the logged-in user hold a capability kind? (FALSE for an invalid session.)
	def SessionCan(pcToken, pcKind)
		return This.SessionCanAt(pcToken, pcKind, This._NowSecs())

	# TRUE if the session is live at the given moment and its user holds the capability kind.
	#
	#   pcToken    The token, as text.
	#   pcKind     The capability kind to test: effectful, sensing, compute or inference.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    TRUE or FALSE
	#   see        SessionCan
	def SessionCanAt(pcToken, pcKind, pnNow)
		_a_ = This.ActorOfAt(pcToken, pnNow)
		if _a_ = ""
			return 0
		ok
		return _a_.Can(pcKind)

	# TRUE if the session is live and its user may cause effects; an assistant role alone cannot.
	#
	#   pcToken    The token, as text.
	#   returns    TRUE or FALSE
	#   see        SessionCan, SessionIsEffectfulAt
	#@ aka  can this session cause EFFECTS? An assistant/LLM-role session holds only 'inference', so it is authenticated yet effect-less.
	def SessionIsEffectful(pcToken)
		return This.SessionCan(pcToken, "effectful")

	# TRUE if the session is live at the given moment and its user may cause effects.
	#
	#   pcToken    The token, as text.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    TRUE or FALSE
	#   see        SessionIsEffectful
	def SessionIsEffectfulAt(pcToken, pnNow)
		return This.SessionCanAt(pcToken, "effectful", pnNow)

	# the identity behind a session -- the SAME string the governance lattice and
	# the org chart key on (a governance actor name / an org-chart person id). "" if
	# the session is invalid.
	def SessionPerson(pcToken)
		return This.UserOfSession(pcToken)

	def SessionPersonAt(pcToken, pnNow)
		return This.UserOfSessionAt(pcToken, pnNow)

	# TRUE if the session is live and the governance model permits its user to take the action.
	#
	#   pcToken        The token, as text.
	#   pcAction       the name of the governed action, as text
	#   poGovernance   The stzGovernance that decides whether the action is permitted; it is not
	#                  kept.
	#   returns        TRUE or FALSE
	#   note           an invalid session never proceeds, whatever the governance says
	#   see            SessionMayProceedAt, ActorOf
	#@ aka  a session-gated governance decision: the session must be LIVE and the governance instance (passed by reference, never held) must permit the action for this user. Bridges authn to the existing authz engine.
	def SessionMayProceed(pcToken, pcAction, poGovernance)
		return This.SessionMayProceedAt(pcToken, pcAction, poGovernance, This._NowSecs())

	# TRUE if the session is live at the given moment and the governance model permits the action.
	#
	#   pcToken        The token, as text.
	#   pcAction       the name of the governed action, as text
	#   poGovernance   The stzGovernance that decides whether the action is permitted; it is not
	#                  kept.
	#   pnNow          The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns        TRUE or FALSE
	#   see            SessionMayProceed
	def SessionMayProceedAt(pcToken, pcAction, poGovernance, pnNow)
		_u_ = This.UserOfSessionAt(pcToken, pnNow)
		if _u_ = ""
			return 0
		ok
		return poGovernance.MayProceed(_u_, pcAction) = 1

	# Binds the SAML service provider that verifies the responses of the corporate identity provider.
	#
	#   poSp       The stzSamlServiceProvider that verifies the responses.
	#   returns    nothing; the provider is bound
	#   note       LoginWithSaml raises an error until one is bound
	#   see        SamlServiceProviderQ, LoginWithSaml
	#@ aka  -- SAML 2.0 single sign-on -----------------------------------------
	def SetSamlServiceProvider(poSp)
		This.SetSamlServiceProviderQ(poSp)

	def SetSamlServiceProviderQ(poSp)
		@oSamlSp = poSp
		return This

	# Returns the bound SAML service provider, or an empty text when none is bound.
	#
	#   returns    a stzSamlServiceProvider, or an empty text
	#   see        SetSamlServiceProvider
	def SamlServiceProviderQ()
		return @oSamlSp

	# TRUE if a SAML service provider is bound.
	#
	#   returns    TRUE or FALSE
	#   see        SetSamlServiceProvider
	def HasSamlServiceProvider()
		return isObject(@oSamlSp)

	# Returns why the last SAML login was refused; an empty text when it succeeded or none was tried.
	#
	#   returns    a text
	#   see        LoginWithSaml
	def SamlWhy()
		return @cSamlWhy

	# Returns the local user name a verified SAML identity maps to, which is its NameID, usually the corporate email.
	#
	#   paIdentity   The identity that the verification returned, as a hash list.
	#   returns      a text
	#   note         an identity without a NameID gives an empty text
	#   see          LoginWithSaml, OidcUserNameFor
	#@ aka  the local user name a SAML subject maps to (its NameID -- typically the corporate email).
	def SamlUserNameFor(paIdentity)
		return "" + paIdentity[:nameID]

	# Verifies a SAML response and opens a session for its subject, creating the account on a first login.
	#
	#   pcBase64Response   The SAML response posted by the browser, base64 encoded.
	#   returns            a text: a 64-character token, or an empty text with SamlWhy giving the
	#                      reason
	#   note               not exercised here with a signed response: read from the body; a locked
	#                      account or a user with a second factor is refused; the clock is the wall
	#                      clock
	#   warning            Raises an error when no SAML service provider is bound, or when the
	#                      provider trusts no identity provider
	#   see                SetSamlServiceProvider, SamlWhy
	def LoginWithSaml(pcBase64Response)
		return This.LoginWithSamlWithAt(pcBase64Response, "", "", This._NowSecs())

	# Verifies a SAML response as of the given moment and opens a session for its subject.
	#
	#   pcBase64Response   The SAML response posted by the browser, base64 encoded.
	#   pnNow              The moment to act at, in epoch seconds; the forms without At read the
	#                      clock.
	#   returns            a text: a 64-character token, or an empty text
	#   note               the same response cannot be replayed
	#   warning            Raises an error when no SAML service provider is bound
	#   see                LoginWithSaml
	def LoginWithSamlAt(pcBase64Response, pnNow)
		return This.LoginWithSamlWithAt(pcBase64Response, "", "", pnNow)

	# Verifies a SAML response and opens a session that remembers the address and the client.
	#
	#   pcBase64Response   The SAML response posted by the browser, base64 encoded.
	#   pcIp               The address the request came from, as text, kept with the session.
	#   pcUserAgent        The client description (user agent), as text, kept with the session.
	#   returns            a text: a 64-character token, or an empty text
	#   warning            Raises an error when no SAML service provider is bound
	#   see                LoginWithSaml
	def LoginWithSamlWith(pcBase64Response, pcIp, pcUserAgent)
		return This.LoginWithSamlWithAt(pcBase64Response, pcIp, pcUserAgent, This._NowSecs())

	# Verifies a SAML response as of the given moment and opens a session remembering the address and the client.
	#
	#   pcBase64Response   The SAML response posted by the browser, base64 encoded.
	#   pcIp               The address the request came from, as text, kept with the session.
	#   pcUserAgent        The client description (user agent), as text, kept with the session.
	#   pnNow              The moment to act at, in epoch seconds; the forms without At read the
	#                      clock.
	#   returns            a text: a 64-character token, or an empty text
	#   warning            Raises an error when no SAML service provider is bound
	#   see                LoginWithSamlWith
	def LoginWithSamlWithAt(pcBase64Response, pcIp, pcUserAgent, pnNow)
		if NOT This.HasSamlServiceProvider()
			StzRaise("stzAuth.LoginWithSaml: no SAML service provider bound -- call SetSamlServiceProvider.")
		ok
		_id_ = @oSamlSp.ConsumeResponseAt("" + pcBase64Response, pnNow)
		if NOT _id_[:ok]
			@cSamlWhy = _id_[:why]
			return ""
		ok
		_u_ = This.SamlUserNameFor(_id_)
		if _u_ = ""
			@cSamlWhy = "the assertion carries no usable identity"
			return ""
		ok
		if NOT @oStore.HasUser(_u_)
			if NOT @bOidcAutoProvision
				@cSamlWhy = "no local account for '" + _u_ + "' (auto-provisioning is off)"
				return ""
			ok
			This.RegisterPasswordless(_u_)
		ok
		if This.IsLockedOutAt(_u_, pnNow)
			@cSamlWhy = "the account is locked out"
			return ""
		ok
		if This.HasTotp(_u_)
			@cSamlWhy = "this account requires its local second factor"
			return ""
		ok
		@cSamlWhy = ""
		return This._OpenSession(_u_, pnNow, "" + pcIp, "" + pcUserAgent)

	# Binds the relying party that passkeys are checked against: the domain and the exact origin of the app.
	#
	#   pcRpId     The relying party id, the domain the credentials are bound to, as text.
	#   pcOrigin   The exact origin the browser reports, as text.
	#   returns    nothing; the relying party is bound
	#   note       both values are required, the origin check is what makes a passkey unphishable
	#   see        PasskeyRelyingPartyQ, NewPasskeyChallenge
	#@ aka  -- PASSKEYS (WebAuthn) ---------------------------------------------
	def SetPasskeyRelyingParty(pcRpId, pcOrigin)
		This.SetPasskeyRelyingPartyQ(pcRpId, pcOrigin)

	def SetPasskeyRelyingPartyQ(pcRpId, pcOrigin)
		@oPasskeyRp = new stzPasskeyServer(pcRpId, pcOrigin)
		return This

	# Returns the bound passkey relying party, or an empty text when none is bound.
	#
	#   returns    a stzPasskeyServer, or an empty text
	#   see        SetPasskeyRelyingParty
	def PasskeyRelyingPartyQ()
		return @oPasskeyRp

	# TRUE if a passkey relying party is bound.
	#
	#   returns    TRUE or FALSE
	#   see        SetPasskeyRelyingParty
	def HasPasskeyRelyingParty()
		return isObject(@oPasskeyRp)

	# Returns why the last passkey operation was refused; an empty text after a success.
	#
	#   returns    a text
	#   see        RegisterPasskey, LoginWithPasskey
	def PasskeyWhy()
		return @cPasskeyWhy

	# Returns a fresh random challenge for one passkey exchange, registration or login.
	#
	#   returns    a text: 64 hex characters
	#   note       the app keeps it for that one exchange, which stops a captured response from
	#              being replayed
	#   warning    Raises an error when no passkey relying party is bound
	#   see        RegisterPasskey, LoginWithPasskey
	#@ aka  a fresh challenge for either ceremony -- the app holds it for that one exchange, which is what stops a captured response being replayed.
	def NewPasskeyChallenge()
		This._RequirePasskeyRp()
		return @oPasskeyRp.NewChallenge()

	# Enrolls a device for a user from its attestation; TRUE on success, FALSE with PasskeyWhy explaining.
	#
	#   pcUser                the user name of an existing user, as text
	#   pcAttObjB64           The attestation object returned by the authenticator, base64 encoded.
	#   pcClientDataB64       The client data returned by the browser, base64 encoded.
	#   pcExpectedChallenge   The challenge the app issued for this one exchange, as text.
	#   returns               TRUE or FALSE
	#   note                  a wrong challenge or an unknown user is refused; only the public key
	#                         is stored
	#   warning               Raises an error when no passkey relying party is bound
	#   see                   NewPasskeyChallenge, PasskeysOf, PasskeyWhy
	#@ aka  enroll a device for a user. TRUE on success (PasskeyWhy explains a refusal).
	def RegisterPasskey(pcUser, pcAttObjB64, pcClientDataB64, pcExpectedChallenge)
		This._RequirePasskeyRp()
		_u_ = ring_trim("" + pcUser)
		if NOT @oStore.HasUser(_u_)
			@cPasskeyWhy = "no such user '" + _u_ + "'"
			return 0
		ok
		_r_ = @oPasskeyRp.RegisterCredential(pcAttObjB64, pcClientDataB64, pcExpectedChallenge)
		if NOT _r_[:ok]
			@cPasskeyWhy = _r_[:why]
			return 0
		ok
		@oStore.PutPasskey(_r_[:credentialId], _u_, _r_[:keyType], _r_[:key1], _r_[:key2], _r_[:signCount])
		@cPasskeyWhy = ""
		return 1

	# Returns the devices a user has enrolled, as public data only.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a list of hash lists, one per device, with :credentialId and :keyType; [ ] when
	#              none
	#   see        RegisterPasskey, RemovePasskey
	#@ aka  the devices a user has enrolled (public data only -- never a private key).
	def PasskeysOf(pcUser)
		return @oStore.PasskeysOf(ring_trim("" + pcUser))

	# Returns how many devices a user has enrolled.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a number
	#   see        PasskeysOf, HasPasskey
	def NumberOfPasskeys(pcUser)
		return len(This.PasskeysOf(pcUser))

	# TRUE if the user has at least one device enrolled.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    TRUE or FALSE
	#   see        NumberOfPasskeys
	def HasPasskey(pcUser)
		return This.NumberOfPasskeys(pcUser) > 0

	# Un-enrolls one device by its credential id; an unknown id changes nothing.
	#
	#   pcCredentialId   The id of the credential, as text.
	#   returns          the stzAuth itself, so calls chain
	#   see              RemoveAllPasskeys, PasskeysOf
	#@ aka  un-enroll one device (losing a key should not cost the account).
	def RemovePasskey(pcCredentialId)
		@oStore.DeletePasskey("" + pcCredentialId)
		return This

	# Un-enrolls every device of a user.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   see        RemovePasskey
	def RemoveAllPasskeys(pcUser)
		@oStore.DeleteUserPasskeys(ring_trim("" + pcUser))
		return This

	# Opens a session when the device's signature over the challenge is valid; an empty text otherwise, with PasskeyWhy giving the reason.
	#
	#   pcCredId              The id of the credential, as text.
	#   pcAuthDataB64         The authenticator data returned by the device, base64 encoded.
	#   pcClientDataB64       The client data returned by the browser, base64 encoded.
	#   pcSigB64              The signature returned by the device, base64 encoded.
	#   pcExpectedChallenge   The challenge the app issued for this one exchange, as text.
	#   returns               a text: a 64-character token, or an empty text
	#   note                  a replayed assertion is refused because the signature counter did not
	#                         advance; a passkey satisfies the second factor by itself; the clock is
	#                         the wall clock
	#   warning               Raises an error when no passkey relying party is bound
	#   see                   NewPasskeyChallenge, RegisterPasskey
	#@ aka  sign in with a device -> a session token, or "" (PasskeyWhy explains).
	def LoginWithPasskey(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge)
		return This.LoginWithPasskeyWithAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64,
		           pcExpectedChallenge, "", "", This._NowSecs())

	# Checks the device's signature as of the given moment and opens a session; an empty text otherwise.
	#
	#   pcCredId              The id of the credential, as text.
	#   pcAuthDataB64         The authenticator data returned by the device, base64 encoded.
	#   pcClientDataB64       The client data returned by the browser, base64 encoded.
	#   pcSigB64              The signature returned by the device, base64 encoded.
	#   pcExpectedChallenge   The challenge the app issued for this one exchange, as text.
	#   pnNow                 The moment to act at, in epoch seconds; the forms without At read the
	#                         clock.
	#   returns               a text: a 64-character token, or an empty text
	#   warning               Raises an error when no passkey relying party is bound
	#   see                   LoginWithPasskey
	def LoginWithPasskeyAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge, pnNow)
		return This.LoginWithPasskeyWithAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64,
		           pcExpectedChallenge, "", "", pnNow)

	# Checks the device's signature as of the given moment and opens a session remembering the address and the client.
	#
	#   pcCredId              The id of the credential, as text.
	#   pcAuthDataB64         The authenticator data returned by the device, base64 encoded.
	#   pcClientDataB64       The client data returned by the browser, base64 encoded.
	#   pcSigB64              The signature returned by the device, base64 encoded.
	#   pcExpectedChallenge   The challenge the app issued for this one exchange, as text.
	#   pcIp                  The address the request came from, as text, kept with the session.
	#   pcUserAgent           The client description (user agent), as text, kept with the session.
	#   pnNow                 The moment to act at, in epoch seconds; the forms without At read the
	#                         clock.
	#   returns               a text: a 64-character token, or an empty text
	#   warning               Raises an error when no passkey relying party is bound
	#   see                   LoginWithPasskeyAt
	def LoginWithPasskeyWithAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge, pcIp, pcUserAgent, pnNow)
		This._RequirePasskeyRp()
		_cred_ = @oStore.Passkey("" + pcCredId)
		if len(_cred_) = 0
			@cPasskeyWhy = "unknown credential"
			return ""
		ok
		_u_ = _cred_[:user]
		if This.IsLockedOutAt(_u_, pnNow)
			@cPasskeyWhy = "the account is locked out"
			return ""
		ok
		_r_ = @oPasskeyRp.VerifyAssertion(_cred_, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge)
		if NOT _r_[:ok]
			@cPasskeyWhy = _r_[:why]
			This._RecordFailure(_u_, pnNow)
			return ""
		ok
		# the counter only moves FORWARD -- that is the clone signal
		if _r_[:signCount] > 0
			@oStore.SetPasskeyCounter("" + pcCredId, _r_[:signCount])
		ok
		This._ClearFailures(_u_)
		@cPasskeyWhy = ""
		# A passkey IS a strong factor (device possession + the user gesture the
		# authenticator attests), so unlike a magic link it satisfies 2FA on its own.
		return This._OpenSession(_u_, pnNow, "" + pcIp, "" + pcUserAgent)

	def _RequirePasskeyRp()
		if NOT This.HasPasskeyRelyingParty()
			StzRaise("stzAuth: no passkey relying party bound -- call SetPasskeyRelyingParty(rpId, origin).")
		ok

	# Binds the OpenID Connect client that verifies the id-tokens of an external provider.
	#
	#   poClient   The stzOidcClient that verifies the id-tokens.
	#   returns    nothing; the client is bound
	#   note       LoginWithOidc raises an error until one is bound
	#   see        OidcClientQ, LoginWithOidc
	#@ aka  -- EXTERNAL identity: sign in with an OIDC provider ----------------
	def SetOidcClient(poClient)
		This.SetOidcClientQ(poClient)

	def SetOidcClientQ(poClient)
		@oOidc = poClient
		return This

	# Returns the bound OpenID Connect client, or an empty text when none is bound.
	#
	#   returns    a stzOidcClient, or an empty text
	#   see        SetOidcClient
	def OidcClientQ()
		return @oOidc

	# TRUE if an OpenID Connect client is bound.
	#
	#   returns    TRUE or FALSE
	#   see        SetOidcClient
	def HasOidcClient()
		return isObject(@oOidc)

	# Sets whether the first sign-in of an external identity creates its local account; 0 admits only existing users.
	#
	#   pbOn       1 to turn the behaviour on, 0 to turn it off.
	#   returns    nothing; the setting changes
	#   note       it is also read by the SAML login
	#   see        OidcAutoProvision, LoginWithOidc
	#@ aka  create a local account the first time an external identity signs in (the usual want). Turn it off to admit only pre-provisioned users.
	def SetOidcAutoProvision(pbOn)
		This.SetOidcAutoProvisionQ(pbOn)

	def SetOidcAutoProvisionQ(pbOn)
		@bOidcAutoProvision = pbOn
		return This

	# Returns whether the first sign-in of an external identity creates its local account.
	#
	#   returns    1 or 0, 1 by default
	#   see        SetOidcAutoProvision
	def OidcAutoProvision()
		return @bOidcAutoProvision

	# Returns why the last external login was refused; an empty text after a success.
	#
	#   returns    a text
	#   see        LoginWithOidc
	#@ aka  why the last external login was refused ("" when it succeeded).
	def OidcWhy()
		return @cOidcWhy

	# Returns the local user name of an external identity: its email, else the issuer and the subject joined by a bar.
	#
	#   paIdentity   The identity that the verification returned, as a hash list.
	#   returns      a text
	#   note         that joined form cannot collide with a local user name
	#   see          LoginWithOidc, SamlUserNameFor
	#@ aka  the local user name an external identity maps to: its verified email when the provider asserts one, else "issuer|subject" (always unique, never collides with a local account name).
	def OidcUserNameFor(paIdentity)
		if isList(paIdentity) and ("" + paIdentity[:email]) != ""
			return "" + paIdentity[:email]
		ok
		if NOT This.HasOidcClient()
			return ""
		ok
		return @oOidc.Issuer() + "|" + paIdentity[:subject]

	# Verifies an id-token and opens a session for its subject, creating a password-less account on a first login.
	#
	#   pcIdToken   The id-token issued by the provider, as text.
	#   pcNonce     The nonce sent with the sign-in request, as text.
	#   returns     a text: a 64-character token, or an empty text with OidcWhy giving the reason
	#   note        a wrong nonce, a locked account, a user with a second factor, or auto-
	#               provisioning off for a new user is refused; the clock is the wall clock
	#   warning     Raises an error when no OpenID Connect client is bound
	#   see         SetOidcClient, OidcWhy
	def LoginWithOidc(pcIdToken, pcNonce)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, "", "", This._NowSecs())

	# Verifies an id-token as of the given moment and opens a session for its subject.
	#
	#   pcIdToken   The id-token issued by the provider, as text.
	#   pcNonce     The nonce sent with the sign-in request, as text.
	#   pnNow       The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns     a text: a 64-character token, or an empty text
	#   warning     Raises an error when no OpenID Connect client is bound
	#   see         LoginWithOidc
	def LoginWithOidcAt(pcIdToken, pcNonce, pnNow)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, "", "", pnNow)

	# Verifies an id-token and opens a session that remembers the address and the client.
	#
	#   pcIdToken     The id-token issued by the provider, as text.
	#   pcNonce       The nonce sent with the sign-in request, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   returns       a text: a 64-character token, or an empty text
	#   warning       Raises an error when no OpenID Connect client is bound
	#   see           LoginWithOidc
	def LoginWithOidcWith(pcIdToken, pcNonce, pcIp, pcUserAgent)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, pcIp, pcUserAgent, This._NowSecs())

	# Verifies an id-token as of the given moment and opens a session remembering the address and the client.
	#
	#   pcIdToken     The id-token issued by the provider, as text.
	#   pcNonce       The nonce sent with the sign-in request, as text.
	#   pcIp          The address the request came from, as text, kept with the session.
	#   pcUserAgent   The client description (user agent), as text, kept with the session.
	#   pnNow         The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns       a text: a 64-character token, or an empty text
	#   warning       Raises an error when no OpenID Connect client is bound
	#   see           LoginWithOidcWith
	#@ aka  -> a session token, or "" (with OidcWhy() explaining).
	def LoginWithOidcWithAt(pcIdToken, pcNonce, pcIp, pcUserAgent, pnNow)
		if NOT This.HasOidcClient()
			StzRaise("stzAuth.LoginWithOidc: no OIDC client bound -- call SetOidcClient.")
		ok
		_id_ = @oOidc.VerifyIdTokenAt("" + pcIdToken, "" + pcNonce, pnNow)
		if NOT _id_[:ok]
			@cOidcWhy = _id_[:why]
			return ""
		ok
		_u_ = This.OidcUserNameFor(_id_)
		if _u_ = ""
			@cOidcWhy = "the token carries no usable identity"
			return ""
		ok
		if NOT @oStore.HasUser(_u_)
			if NOT @bOidcAutoProvision
				@cOidcWhy = "no local account for '" + _u_ + "' (auto-provisioning is off)"
				return ""
			ok
			# an externally-authenticated account holds no usable password: the
			# provider is the only way in.
			This.RegisterPasswordless(_u_)
		ok
		if This.IsLockedOutAt(_u_, pnNow)
			@cOidcWhy = "the account is locked out"
			return ""
		ok
		# a local second factor still stands: the provider proved the identity,
		# not possession of OUR factor (same rule as the passwordless flows).
		if This.HasTotp(_u_)
			@cOidcWhy = "this account requires its local second factor"
			return ""
		ok
		@cOidcWhy = ""
		return This._OpenSession(_u_, pnNow, "" + pcIp, "" + pcUserAgent)

	# TRUE if the user is locked out now, by too many failed logins or by LockAccount.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    TRUE or FALSE
	#   see        IsLockedOutAt, FailedAttempts, LockAccount
	#@ aka  -- lockout queries -------------------------------------------------
	def IsLockedOut(pcUser)
		return This.IsLockedOutAt(ring_trim("" + pcUser), This._NowSecs())

	# TRUE if the user is locked out at the given moment, by too many failed logins or by LockAccount.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pnNow      The moment to act at, in epoch seconds; the forms without At read the clock.
	#   returns    TRUE or FALSE
	#   note       a lockout from failed logins ends by itself after the lockout seconds; an
	#              administrative lock does not
	#   see        IsLockedOut
	def IsLockedOutAt(pcUser, pnNow)
		# an administrative lock (LockAccount) closes every login path
		if len(@oStore.LockOf("" + pcUser)) > 0
			return 1
		ok
		_i_ = This._FailureIndex("" + pcUser)
		if _i_ = 0
			return 0
		ok
		return @aFailures[_i_][2] >= @nMaxAttempts and pnNow < @aFailures[_i_][3]

	# Closes a user's account until UnlockAccount: every login path refuses it and its sessions stop working.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   pcReason   why the account is locked, as text
	#   returns    the stzAuth itself, so calls chain
	#   note       the sessions are not deleted: they work again after UnlockAccount; Authenticate
	#              still accepts the password
	#   see        UnlockAccount, IsAccountLocked
	#@ aka  -- the administrative lock (containment's :LockAccount) -------------
	def LockAccount(pcUser, pcReason)
		_u_ = ring_trim("" + pcUser)
		@oStore.PutLock(_u_, "" + pcReason, This._NowSecs())
		StzNoteRefusal("auth.account.locked", _u_, "user:" + _u_, "" + pcReason)
		return This

	# Reopens an account closed by LockAccount; the sessions that were not purged work again.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    the stzAuth itself, so calls chain
	#   see        LockAccount, IsAccountLocked
	def UnlockAccount(pcUser)
		_u_ = ring_trim("" + pcUser)
		@oStore.DeleteLock(_u_)
		StzNoteGrant("auth.account.unlocked", _u_, "user:" + _u_)
		return This

	# TRUE if the account has been closed by LockAccount.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    TRUE or FALSE
	#   note       failed logins alone do not make it TRUE; IsLockedOut covers both
	#   see        LockAccount, IsLockedOut
	def IsAccountLocked(pcUser)
		return len(@oStore.LockOf(ring_trim("" + pcUser))) > 0

	# Returns why and since when an account is locked as a hash list; [ ] when it is not locked.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a hash list [ :reason, :at ]; [ ] when not locked
	#   see        LockAccount, IsAccountLocked
	#@ aka  [ :reason, :at ] or [] -- why and since when the account is locked.
	def AccountLock(pcUser)
		return @oStore.LockOf(ring_trim("" + pcUser))

	# Returns how many failed logins the user has had since their last success.
	#
	#   pcUser     The user name, as text; it is trimmed and compared with case.
	#   returns    a number
	#   note       the counter is in memory and a successful login resets it to 0
	#   see        MaxAttempts, IsLockedOut
	def FailedAttempts(pcUser)
		_i_ = This._FailureIndex(ring_trim("" + pcUser))
		if _i_ = 0
			return 0
		ok
		return @aFailures[_i_][2]

	# Prints one line giving the number of users and of live sessions held by the store.
	#
	#   returns    nothing; a line is printed
	#   note       it never prints a hash or a token
	#   see        NumberOfUsers, NumberOfSessions
	def Show()
		? "Auth store: " + @oStore.CountUsers() + " user(s), " +
		  @oStore.CountSessions() + " live session(s)"

	  #-- internals -------------------------------------------------------

	# wall-clock now, in epoch SECONDS (StzEngineTimeNowMs is epoch ms).
	def _NowSecs()
		return floor(StzEngineTimeNowMs() / 1000)

	def _FailureIndex(pcUser)
		_n_ = len(@aFailures)
		for _i_ = 1 to _n_
			if @aFailures[_i_][1] = pcUser
				return _i_
			ok
		next
		return 0

	def _RecordFailure(pcUser, pnNow)
		_i_ = This._FailureIndex("" + pcUser)
		if _i_ = 0
			@aFailures + [ "" + pcUser, 1, 0 ]
			_i_ = len(@aFailures)
		else
			@aFailures[_i_][2] = @aFailures[_i_][2] + 1
		ok
		# The counter here is a LOCKOUT mechanism -- deliberately
		# in-memory, and wiped the moment the user succeeds. The ledger
		# keeps the history the counter throws away (incident I2): each
		# failure as its own timestamped event, which is what a
		# credential-stuffing detection needs to count over a window.
		StzNoteRefusal("auth.login.failed", "" + pcUser, "user:" + pcUser,
			"authentication failed (attempt " + @aFailures[_i_][2] + ")")
		if @aFailures[_i_][2] >= @nMaxAttempts
			@aFailures[_i_][3] = pnNow + @nLockoutSecs
			StzNoteRefusal("auth.lockout.engaged", "" + pcUser, "user:" + pcUser,
				"" + @aFailures[_i_][2] + " failures locked the account for " +
				@nLockoutSecs + "s")
		ok

	def _ClearFailures(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aFailures)
		for _i_ = 1 to _n_
			if @aFailures[_i_][1] != _u_
				_aNew_ + @aFailures[_i_]
			ok
		next
		@aFailures = _aNew_

	  #-- recovery codes --------------------------------------------------

	# generate a fresh set of 10 recovery codes, store their HASHES (replacing any
	# prior set), and return the plaintext codes. Each is 64-bit, single-use.
	def _IssueRecoveryCodes(pcUser)
		_plain_ = []
		_hashes_ = []
		for _i_ = 1 to 10
			_code_ = StzEngineCryptoRandomHex(8)   # 16 hex chars
			_plain_ + _code_
			_hashes_ + StzHashSecret(_code_)
		next
		@oStore.SetTotpRecovery("" + pcUser, _hashes_)
		return _plain_

	# check a submitted code against the stored recovery HASHES; on a match CONSUME
	# it (drop that hash so it cannot be reused) and return TRUE.
	def _ConsumeRecoveryCode(pcUser, pcCode, paHashes)
		_sub_ = This._CanonRecovery(pcCode)
		if _sub_ = ""
			return 0
		ok
		_n_ = len(paHashes)
		for _i_ = 1 to _n_
			if StzVerifySecret(_sub_, paHashes[_i_])
				_aNew_ = []
				for _j_ = 1 to _n_
					if _j_ != _i_
						_aNew_ + paHashes[_j_]
					ok
				next
				@oStore.SetTotpRecovery("" + pcUser, _aNew_)
				return 1
			ok
		next
		return 0

	# canonicalize a recovery code: lower-case, keep only hex characters (so it may
	# be typed with spaces or in upper-case).
	def _CanonRecovery(pcCode)
		_s_ = "" + pcCode
		_out_ = ""
		_n_ = len(_s_)
		for _i_ = 1 to _n_
			_a_ = ascii(_s_[_i_])
			if _a_ >= 65 and _a_ <= 70
				_a_ = _a_ + 32                       # A-F -> a-f
			ok
			if (_a_ >= 48 and _a_ <= 57) or (_a_ >= 97 and _a_ <= 102)
				_out_ += char(_a_)
			ok
		next
		return _out_

	  #-- passwordless internals ------------------------------------------

	# open a session at the end of a passwordless flow -- but never for a user who
	# has since been removed, and never bypassing a confirmed 2FA (the possession
	# factor proves the email, not the second factor).
	def _PasswordlessSession(pcEmail, pnNow, pcIp, pcUa)
		_u_ = "" + pcEmail
		if NOT @oStore.HasUser(_u_)
			return ""
		ok
		if This.HasTotp(_u_)
			return ""
		ok
		return This._OpenSession(_u_, pnNow, pcIp, pcUa)

	# build the URL a magic link points at (the token as a query parameter).
	def _MagicLinkUrl(pcToken)
		if @cMagicLinkBaseUrl = ""
			return "softanza://magiclink?token=" + pcToken
		ok
		_sep_ = "?"
		if StzFindFirst("?", @cMagicLinkBaseUrl) > 0
			_sep_ = "&"
		ok
		return @cMagicLinkBaseUrl + _sep_ + "token=" + pcToken

	# a 6-digit numeric code from CSPRNG bytes (uniform enough for a rate-limited,
	# one-time, short-lived OTP; brute force is bounded by the lockout).
	def _RandomOtp()
		_hex_ = StzEngineCryptoRandomHex(5)   # 10 hex chars
		_n_ = 0
		_len_ = len(_hex_)
		for _i_ = 1 to _len_
			_a_ = ascii(_hex_[_i_])
			_d_ = 0
			if _a_ >= 48 and _a_ <= 57
				_d_ = _a_ - 48
			but _a_ >= 97 and _a_ <= 102
				_d_ = _a_ - 87
			ok
			_n_ = (_n_ * 16 + _d_) % 1000000
		next
		_s_ = "" + _n_
		while len(_s_) < 6
			_s_ = "0" + _s_
		end
		return _s_

	  #-- authz internals -------------------------------------------------

	def _DefineBuiltinRoles()
		@aRoleDefs = []
		This.DefineRole("admin",     [ "effectful", "compute", "sensing" ], "trusted")
		This.DefineRole("member",    [ "compute", "sensing" ],             "trusted")
		This.DefineRole("viewer",    [ "sensing" ],                        "external")
		This.DefineRole("assistant", [ "inference" ],                      "sandboxed")

	def _RoleDefIndex(pcName)
		_n_ = len(@aRoleDefs)
		for _i_ = 1 to _n_
			if @aRoleDefs[_i_][1] = pcName
				return _i_
			ok
		next
		return 0

	# the more restrictive of two postures (sandboxed < external < trusted).
	def _MinPosture(pcA, pcB)
		if This._PostureRank(pcB) < This._PostureRank(pcA)
			return pcB
		ok
		return pcA

	def _PostureRank(pcPosture)
		if pcPosture = "sandboxed"
			return 0
		ok
		if pcPosture = "external"
			return 1
		ok
		return 2   # trusted

	def _InList(pItem, paList)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pItem
				return _i_
			ok
		next
		return 0
