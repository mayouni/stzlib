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
#   * passwords are hashed with PBKDF2 (StzHashSecret) and verified in
#     constant time (StzVerifySecret) -- the same engine crypto stzSecret and
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

	def init()
		@oStore = new stzAuthMemoryStore()   # durable store injected via SetStore
		@cDummyHash = StzHashSecret("softanza-timing-equalizer")
		@aFailures = []
		This._DefineBuiltinRoles()

	# Persist through a chosen store (e.g. StzAuthDbStoreQ("auth.db")). The
	# default is in-memory. Pass a DB store for durability -- its sqlite is an
	# engine handle, so the held copy still writes the same database.
	def SetStore(poStore)
		This.SetStoreQ(poStore)

	def SetStoreQ(poStore)
		@oStore = poStore
		return This

	def StoreQ()
		return @oStore

	# how long a new session lives, in seconds (0 = no expiry). Existing sessions
	# keep the TTL they were issued with.
	def SetSessionTTL(pnSeconds)
		This.SetSessionTTLQ(pnSeconds)

	def SetSessionTTLQ(pnSeconds)
		@nSessionTTL = pnSeconds
		return This

	def SessionTTL()
		return @nSessionTTL

	# idle timeout: a session dies if untouched for this many seconds (0 = off).
	# Every successful validation slides the window (touches last-seen).
	def SetIdleTTL(pnSeconds)
		This.SetIdleTTLQ(pnSeconds)

	def SetIdleTTLQ(pnSeconds)
		@nIdleTTL = pnSeconds
		return This

	def IdleTTL()
		return @nIdleTTL

	  #-- passwordless config (mail port + magic-link) --------------------

	# bind the mail PORT passwordless flows send through -- a stzMailSandbox in dev
	# (captured + assertable), your SMTP adapter at deploy. Any object with
	# Send(to, subject, body) works.
	def SetMailPort(poPort)
		This.SetMailPortQ(poPort)

	def SetMailPortQ(poPort)
		@oMailPort = poPort
		return This

	def MailPortQ()
		return @oMailPort

	def HasMailPort()
		return isObject(@oMailPort)

	# the app URL a magic link points at; the token is appended as ?token=...
	# (or &token=... if the URL already has a query). "" -> a softanza:// URI.
	def SetMagicLinkBaseUrl(pcUrl)
		This.SetMagicLinkBaseUrlQ(pcUrl)

	def SetMagicLinkBaseUrlQ(pcUrl)
		@cMagicLinkBaseUrl = "" + pcUrl
		return This

	def MagicLinkBaseUrl()
		return @cMagicLinkBaseUrl

	# how long a magic link / email-OTP stays valid (seconds).
	def SetPasswordlessTTL(pnSeconds)
		This.SetPasswordlessTTLQ(pnSeconds)

	def SetPasswordlessTTLQ(pnSeconds)
		@nPasswordlessTTL = pnSeconds
		return This

	def PasswordlessTTL()
		return @nPasswordlessTTL

	  #-- brute-force lockout config --------------------------------------

	def SetMaxAttempts(pnMax)
		This.SetMaxAttemptsQ(pnMax)

	def SetMaxAttemptsQ(pnMax)
		@nMaxAttempts = pnMax
		return This

	def MaxAttempts()
		return @nMaxAttempts

	def SetLockoutSeconds(pnSecs)
		This.SetLockoutSecondsQ(pnSecs)

	def SetLockoutSecondsQ(pnSecs)
		@nLockoutSecs = pnSecs
		return This

	def LockoutSeconds()
		return @nLockoutSecs

	  #-- the credential store --------------------------------------------

	# register a user with a password -- stores ONLY the salted hash.
	def Register(pcUser, pcPassword)
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			StzRaise("stzAuth.Register: a user name is required.")
		ok
		if @oStore.HasUser(_u_)
			StzRaise("stzAuth.Register: user '" + _u_ + "' already exists.")
		ok
		@oStore.PutUser(_u_, StzHashSecret("" + pcPassword))
		return This

	# register an account with NO usable password -- reachable only through a
	# passwordless factor (magic-link / email-OTP). The stored hash is of a random
	# value nobody holds, so Login can never succeed for it.
	def RegisterPasswordless(pcUser)
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			StzRaise("stzAuth.RegisterPasswordless: a user name is required.")
		ok
		if @oStore.HasUser(_u_)
			StzRaise("stzAuth.RegisterPasswordless: user '" + _u_ + "' already exists.")
		ok
		@oStore.PutUser(_u_, StzHashSecret(StzEngineCryptoRandomHex(32)))
		return This

	def IsRegistered(pcUser)
		return @oStore.HasUser(ring_trim("" + pcUser))

	def NumberOfUsers()
		return @oStore.CountUsers()

	# change a password (the current one must be presented). TRUE on success.
	def ChangePassword(pcUser, pcOld, pcNew)
		_u_ = ring_trim("" + pcUser)
		_h_ = @oStore.UserHash(_u_)
		if _h_ = "" or NOT StzVerifySecret("" + pcOld, _h_)
			return 0
		ok
		@oStore.PutUser(_u_, StzHashSecret("" + pcNew))
		return 1

	# remove a user (and end any of their sessions).
	def Unregister(pcUser)
		_u_ = ring_trim("" + pcUser)
		@oStore.DeleteUser(_u_)
		@oStore.DeleteUserSessions(_u_)
		@oStore.DeleteTotp(_u_)
		@oStore.DeleteUserRoles(_u_)
		@oStore.DeleteUserPasskeys(_u_)
		This._ClearFailures(_u_)
		return This

	  #-- authentication + sessions ---------------------------------------

	# verify a user's password. TRUE/FALSE -- no session side effect.
	#
	# TIMING-SAFE: an unknown user is verified against a DUMMY hash so it costs
	# the same PBKDF2 work as a wrong password. Otherwise a fast "no such user"
	# vs a slow "wrong password" is a username-enumeration oracle.
	def Authenticate(pcUser, pcPassword)
		_h_ = @oStore.UserHash(ring_trim("" + pcUser))
		if _h_ = ""
			StzVerifySecret("" + pcPassword, @cDummyHash)   # equalize timing
			return 0
		ok
		return StzVerifySecret("" + pcPassword, _h_)

	# authenticate AND, on success, open a session -> returns an opaque token
	# ("" on failure OR lockout -- indistinguishable, so it leaks nothing).
	def Login(pcUser, pcPassword)
		return This.LoginWithAt(pcUser, pcPassword, "", "", This._NowSecs())

	# deterministic form (explicit 'now') for tests.
	def LoginAt(pcUser, pcPassword, pnNow)
		return This.LoginWithAt(pcUser, pcPassword, "", "", pnNow)

	# same, capturing the DEVICE CONTEXT (ip + user-agent) so the session can be
	# listed and revoked per device.
	def LoginWith(pcUser, pcPassword, pcIp, pcUserAgent)
		return This.LoginWithAt(pcUser, pcPassword, pcIp, pcUserAgent, This._NowSecs())

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

	  #-- two-factor login ------------------------------------------------
	#
	# Password AND second factor in one call. For a user WITHOUT 2FA the code is
	# ignored (password alone opens the session), so an app may always route login
	# through here. For a 2FA user, a valid TOTP (or one-time recovery) code is
	# required. Returns a session token, or "" on any failure / lockout.

	def LoginTwoFactor(pcUser, pcPassword, pcCode)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, "", "", This._NowSecs())

	def LoginTwoFactorAt(pcUser, pcPassword, pcCode, pnNow)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, "", "", pnNow)

	def LoginTwoFactorWith(pcUser, pcPassword, pcCode, pcIp, pcUserAgent)
		return This.LoginTwoFactorWithAt(pcUser, pcPassword, pcCode, pcIp, pcUserAgent, This._NowSecs())

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

	# the user behind a live session token, or "" if unknown / ended / EXPIRED
	# (checked against the wall clock).
	def UserOfSession(pcToken)
		return This.UserOfSessionAt(pcToken, This._NowSecs())

	# same, against an explicit 'now' (epoch seconds) -- deterministic for tests.
	# Checks BOTH the absolute expiry and (when enabled) the idle window, and
	# slides the idle window by touching last-seen on a valid access.
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
		if @nIdleTTL > 0
			@oStore.TouchSession("" + pcToken, pnNowSecs)   # slide the idle window
		ok
		return _s_[:user]

	def IsValidSession(pcToken)
		return This.UserOfSession(pcToken) != ""

	def IsValidSessionAt(pcToken, pnNowSecs)
		return This.UserOfSessionAt(pcToken, pnNowSecs) != ""

	# the session as a stzToken (its expiry, its kind), or NULL if unknown --
	# reconstructed from the stored token + expiry.
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

	# the epoch-seconds a session expires at (0 = never), or -1 if unknown.
	def SessionExpiresAt(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return -1
		ok
		return _s_[:expires]

	# drop expired sessions (housekeeping) -> the number pruned. Prunes BOTH
	# absolute-expired and (when idle timeout is on) idle-expired sessions.
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

	def PurgeExpired()
		return This.PurgeExpiredAt(This._NowSecs())

	def NumberOfSessions()
		return @oStore.CountSessions()

	def Logout(pcToken)
		This._NoteSessionEnd("" + pcToken, "the user signed out")
		@oStore.DeleteSession("" + pcToken)
		return This

	# revoke ONE session (per-device "sign out this device"). Alias of Logout,
	# named for the device-management flow.
	def RevokeSession(pcToken)
		This._NoteSessionEnd("" + pcToken, "the session was revoked")
		@oStore.DeleteSession("" + pcToken)
		return This

	# end EVERY session for a user without removing the account ("log out
	# everywhere") -- distinct from Unregister.
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

	  #-- the "your devices" surface + fixation defense -------------------

	# every live session of a user, as public descriptors -- the data a "your
	# active devices" view lists (token to revoke by, plus when/where/what).
	#   [ [ :token, :user, :created, :ip, :userAgent, :expires, :lastSeen ], ... ]
	def SessionsOf(pcUser)
		return This.SessionsOfAt(pcUser, This._NowSecs())

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

	# one session's public descriptor, or [] if unknown.
	def SessionInfo(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return []
		ok
		return [ :token = _s_[:token], :user = _s_[:user], :created = _s_[:created],
		         :ip = _s_[:ip], :userAgent = _s_[:ua], :expires = _s_[:expires],
		         :lastSeen = _s_[:lastseen] ]

	# ROTATE a session's token (session-fixation defense): after a privilege
	# change -- 2FA, password change, elevation -- issue a NEW token for the same
	# user + device, void the OLD one, and return the new token ("" if invalid).
	# The pre-elevation token can no longer be replayed.
	def RotateSession(pcToken)
		return This.RotateSessionAt(pcToken, This._NowSecs())

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

	  #-- two-factor authentication (TOTP) --------------------------------
	#
	# A user may add an authenticator-app second factor. Enrollment is TWO steps so
	# a mis-scanned secret can never lock the user out: EnableTotp issues a secret
	# stored UNCONFIRMED (not yet enforced -- plain Login still works); ConfirmTotp
	# proves the app is in sync, enforces the factor, and hands back one-time
	# recovery codes. From then on a plain Login is refused for that user and
	# LoginTwoFactor is the only door. The factor is stzTotp; per-user state (secret
	# + recovery-code hashes) lives in the store.

	# whether a user has a CONFIRMED (enforced) second factor.
	def HasTotp(pcUser)
		_rec_ = @oStore.Totp(ring_trim("" + pcUser))
		return (len(_rec_) > 0) and (_rec_[:confirmed] = 1)

	# app-facing alias: does signing this user in require a second factor?
	def RequiresTwoFactor(pcUser)
		return This.HasTotp(pcUser)

	# begin enrollment: mint a secret, store it UNCONFIRMED, and return
	# [ :secret, :uri ]. Render :uri as a QR code for the user's app; :secret is the
	# same key for manual entry. Nothing is enforced until ConfirmTotp. Raises if a
	# CONFIRMED factor already exists (disable it first); a still-pending enrollment
	# is simply replaced.
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

	# finish enrollment: verify the app's current code. On success the factor is
	# confirmed (now enforced) and a fresh set of one-time recovery codes is
	# returned -- show them to the user ONCE (only their hashes are stored). Returns
	# [] on a bad code (enrollment stays pending).
	def ConfirmTotp(pcUser, pcCode)
		return This.ConfirmTotpAt(pcUser, pcCode, This._NowSecs())

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

	# verify a TOTP code (or a one-time recovery code) for a confirmed user.
	def VerifyTotp(pcUser, pcCode)
		return This.VerifyTotpAt(pcUser, pcCode, This._NowSecs())

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

	# turn 2FA off (removes the secret + every recovery code).
	def DisableTotp(pcUser)
		@oStore.DeleteTotp(ring_trim("" + pcUser))
		return This

	# issue a FRESH set of recovery codes (the old set stops working). Returns the
	# plaintext to show once. Only for a confirmed factor.
	def RegenerateRecoveryCodes(pcUser)
		_u_ = ring_trim("" + pcUser)
		if NOT This.HasTotp(_u_)
			StzRaise("stzAuth.RegenerateRecoveryCodes: no confirmed 2FA for '" + _u_ + "'.")
		ok
		return This._IssueRecoveryCodes(_u_)

	# how many unused recovery codes remain.
	def RecoveryCodesRemaining(pcUser)
		_rec_ = @oStore.Totp(ring_trim("" + pcUser))
		if len(_rec_) = 0
			return 0
		ok
		return len(_rec_[:recovery])

	  #-- passwordless: magic link ----------------------------------------
	#
	# Send a one-time sign-in LINK to the user's email. The emailed token is random
	# (256-bit); only its sha256 is stored, so a leaked store never yields a usable
	# link. ENUMERATION-SAFE: the call behaves identically whether or not the email
	# has an account -- a link is minted and sent only for a real user, but the
	# return is always the same. Requires a bound mail port.

	def RequestMagicLink(pcEmail)
		return This.RequestMagicLinkAt(pcEmail, This._NowSecs())

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

	# redeem a magic-link token -> a session token ("" if invalid / expired / for a
	# user who since vanished, or whose 2FA forbids the shortcut).
	def RedeemMagicLink(pcToken)
		return This.RedeemMagicLinkWithAt(pcToken, "", "", This._NowSecs())

	def RedeemMagicLinkAt(pcToken, pnNow)
		return This.RedeemMagicLinkWithAt(pcToken, "", "", pnNow)

	def RedeemMagicLinkWith(pcToken, pcIp, pcUserAgent)
		return This.RedeemMagicLinkWithAt(pcToken, pcIp, pcUserAgent, This._NowSecs())

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

	  #-- passwordless: email OTP -----------------------------------------
	#
	# Email a short numeric code (6 digits) the user types back. The code is salted-
	# hashed at rest and one pending code exists per email (a new request replaces
	# it). A wrong code counts toward the brute-force lockout. Enumeration-safe, and
	# requires a bound mail port.

	def RequestEmailOtp(pcEmail)
		return This.RequestEmailOtpAt(pcEmail, This._NowSecs())

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

	# verify an emailed OTP -> a session token ("" on any failure / lockout / a 2FA
	# user).
	def VerifyEmailOtp(pcEmail, pcCode)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, "", "", This._NowSecs())

	def VerifyEmailOtpAt(pcEmail, pcCode, pnNow)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, "", "", pnNow)

	def VerifyEmailOtpWith(pcEmail, pcCode, pcIp, pcUserAgent)
		return This.VerifyEmailOtpWithAt(pcEmail, pcCode, pcIp, pcUserAgent, This._NowSecs())

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

	  #-- authn -> authz: roles, and the ACTOR a login yields -------------
	#
	# The payoff of the whole auth story. A successful login produces not just a
	# session but the ACTOR the governance system already reasons about: a
	# stzSystemActor carrying a capability set (the effectful / sensing / compute /
	# inference lattice) derived from the user's roles, at a trust posture. The SAME
	# username is the governance actor (stzGovernance.MayProceed) and the org-chart
	# person (separation-of-duties). Roles are DEFINED here (capability bundles, app
	# config) and GRANTED per user (durable). Four roles ship by default; an
	# 'assistant' (LLM-backed) role holds only 'inference', so its session is
	# authenticated yet cannot cause effects -- the agentic-safety invariant,
	# extended to identity.

	# define a role = a capability bundle. kinds are drawn from the lattice
	# (effectful / sensing / compute / inference); posture is trusted / external /
	# sandboxed. Re-defining a role replaces it. Returns This.
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

	def HasRoleDefined(pcName)
		return This._RoleDefIndex(StzLower(ring_trim("" + pcName))) > 0

	def RoleNames()
		_out_ = []
		_n_ = len(@aRoleDefs)
		for _i_ = 1 to _n_
			_out_ + @aRoleDefs[_i_][1]
		next
		return _out_

	def RoleDefinition(pcName)
		_i_ = This._RoleDefIndex(StzLower(ring_trim("" + pcName)))
		if _i_ = 0
			return []
		ok
		_r_ = @aRoleDefs[_i_]
		return [ :name = _r_[1], :kinds = _r_[2], :posture = _r_[3] ]

	# grant a role to a user (durable). The role must be defined and the user must
	# exist. Returns This.
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

	def RevokeRole(pcUser, pcRole)
		@oStore.RevokeRole(ring_trim("" + pcUser), StzLower(ring_trim("" + pcRole)))
		return This

	def HasRole(pcUser, pcRole)
		return @oStore.HasRole(ring_trim("" + pcUser), StzLower(ring_trim("" + pcRole)))

	def RolesOf(pcUser)
		return @oStore.RolesOf(ring_trim("" + pcUser))

	# the ACTOR a user resolves to: a stzSystemActor named for the user, holding the
	# UNION of its roles' capability kinds, at the MOST RESTRICTIVE posture among
	# them. A user with no roles is a capability-less, sandboxed actor -- properly
	# authenticated, yet permitted nothing (least privilege by default).
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

	# the actor behind a LIVE session (NULL if the session is invalid / expired).
	def ActorOf(pcToken)
		return This.ActorOfAt(pcToken, This._NowSecs())

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

	# does the logged-in user hold a capability kind? (FALSE for an invalid session.)
	def SessionCan(pcToken, pcKind)
		return This.SessionCanAt(pcToken, pcKind, This._NowSecs())

	def SessionCanAt(pcToken, pcKind, pnNow)
		_a_ = This.ActorOfAt(pcToken, pnNow)
		if _a_ = ""
			return 0
		ok
		return _a_.Can(pcKind)

	# can this session cause EFFECTS? An assistant/LLM-role session holds only
	# 'inference', so it is authenticated yet effect-less.
	def SessionIsEffectful(pcToken)
		return This.SessionCan(pcToken, "effectful")

	def SessionIsEffectfulAt(pcToken, pnNow)
		return This.SessionCanAt(pcToken, "effectful", pnNow)

	# the identity behind a session -- the SAME string the governance lattice and
	# the org chart key on (a governance actor name / an org-chart person id). "" if
	# the session is invalid.
	def SessionPerson(pcToken)
		return This.UserOfSession(pcToken)

	def SessionPersonAt(pcToken, pnNow)
		return This.UserOfSessionAt(pcToken, pnNow)

	# a session-gated governance decision: the session must be LIVE and the
	# governance instance (passed by reference, never held) must permit the action
	# for this user. Bridges authn to the existing authz engine.
	def SessionMayProceed(pcToken, pcAction, poGovernance)
		return This.SessionMayProceedAt(pcToken, pcAction, poGovernance, This._NowSecs())

	def SessionMayProceedAt(pcToken, pcAction, poGovernance, pnNow)
		_u_ = This.UserOfSessionAt(pcToken, pnNow)
		if _u_ = ""
			return 0
		ok
		return poGovernance.MayProceed(_u_, pcAction) = 1

	  #-- SAML 2.0 single sign-on -----------------------------------------
	#
	# The enterprise counterpart to OIDC: the corporate IdP authenticates the
	# employee and POSTs back a signed assertion; stzAuth verifies it (engine-side
	# XML-DSig, then issuer / audience / validity / replay -- see
	# stzSamlServiceProvider) and opens a normal session. As with OIDC, the user
	# that comes out is an ordinary Softanza citizen with the same governance
	# actor -- SSO is a way IN, not a separate kind of account.

	def SetSamlServiceProvider(poSp)
		This.SetSamlServiceProviderQ(poSp)

	def SetSamlServiceProviderQ(poSp)
		@oSamlSp = poSp
		return This

	def SamlServiceProviderQ()
		return @oSamlSp

	def HasSamlServiceProvider()
		return isObject(@oSamlSp)

	def SamlWhy()
		return @cSamlWhy

	# the local user name a SAML subject maps to (its NameID -- typically the
	# corporate email).
	def SamlUserNameFor(paIdentity)
		return "" + paIdentity[:nameID]

	def LoginWithSaml(pcBase64Response)
		return This.LoginWithSamlWithAt(pcBase64Response, "", "", This._NowSecs())

	def LoginWithSamlAt(pcBase64Response, pnNow)
		return This.LoginWithSamlWithAt(pcBase64Response, "", "", pnNow)

	def LoginWithSamlWith(pcBase64Response, pcIp, pcUserAgent)
		return This.LoginWithSamlWithAt(pcBase64Response, pcIp, pcUserAgent, This._NowSecs())

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

	  #-- PASSKEYS (WebAuthn) ---------------------------------------------
	#
	# A passkey replaces the password with a key pair the user's DEVICE holds: the
	# private half never leaves the authenticator, so there is nothing to phish,
	# reuse, or steal in a breach. Registration stores the public key; login is a
	# signature over a fresh challenge. The relying-party judgement (origin,
	# challenge, user presence, the cloned-authenticator counter) lives in
	# stzPasskeyServer; the credentials live in the store, one row per DEVICE.

	# bind the relying party: the domain credentials are bound to, and the exact
	# origin the browser reports. The origin check is what makes a passkey
	# unphishable, so both are required.
	def SetPasskeyRelyingParty(pcRpId, pcOrigin)
		This.SetPasskeyRelyingPartyQ(pcRpId, pcOrigin)

	def SetPasskeyRelyingPartyQ(pcRpId, pcOrigin)
		@oPasskeyRp = new stzPasskeyServer(pcRpId, pcOrigin)
		return This

	def PasskeyRelyingPartyQ()
		return @oPasskeyRp

	def HasPasskeyRelyingParty()
		return isObject(@oPasskeyRp)

	def PasskeyWhy()
		return @cPasskeyWhy

	# a fresh challenge for either ceremony -- the app holds it for that one
	# exchange, which is what stops a captured response being replayed.
	def NewPasskeyChallenge()
		This._RequirePasskeyRp()
		return @oPasskeyRp.NewChallenge()

	# enroll a device for a user. TRUE on success (PasskeyWhy explains a refusal).
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

	# the devices a user has enrolled (public data only -- never a private key).
	def PasskeysOf(pcUser)
		return @oStore.PasskeysOf(ring_trim("" + pcUser))

	def NumberOfPasskeys(pcUser)
		return len(This.PasskeysOf(pcUser))

	def HasPasskey(pcUser)
		return This.NumberOfPasskeys(pcUser) > 0

	# un-enroll one device (losing a key should not cost the account).
	def RemovePasskey(pcCredentialId)
		@oStore.DeletePasskey("" + pcCredentialId)
		return This

	def RemoveAllPasskeys(pcUser)
		@oStore.DeleteUserPasskeys(ring_trim("" + pcUser))
		return This

	# sign in with a device -> a session token, or "" (PasskeyWhy explains).
	def LoginWithPasskey(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge)
		return This.LoginWithPasskeyWithAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64,
		           pcExpectedChallenge, "", "", This._NowSecs())

	def LoginWithPasskeyAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64, pcExpectedChallenge, pnNow)
		return This.LoginWithPasskeyWithAt(pcCredId, pcAuthDataB64, pcClientDataB64, pcSigB64,
		           pcExpectedChallenge, "", "", pnNow)

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

	  #-- EXTERNAL identity: sign in with an OIDC provider ----------------
	#
	# "Sign in with Google / Okta / Entra". The provider proves who the user is
	# and hands back an id-token; stzAuth VERIFIES it locally (signature against
	# the provider's published key, then issuer / audience / expiry / nonce -- see
	# stzOidcClient) and, only then, opens a normal Softanza session. From that
	# point the user is indistinguishable from any other: the same session, the
	# same roles, the same governance ACTOR (phase 5). An external identity is a
	# way IN, not a separate kind of citizen.

	def SetOidcClient(poClient)
		This.SetOidcClientQ(poClient)

	def SetOidcClientQ(poClient)
		@oOidc = poClient
		return This

	def OidcClientQ()
		return @oOidc

	def HasOidcClient()
		return isObject(@oOidc)

	# create a local account the first time an external identity signs in (the
	# usual want). Turn it off to admit only pre-provisioned users.
	def SetOidcAutoProvision(pbOn)
		This.SetOidcAutoProvisionQ(pbOn)

	def SetOidcAutoProvisionQ(pbOn)
		@bOidcAutoProvision = pbOn
		return This

	def OidcAutoProvision()
		return @bOidcAutoProvision

	# why the last external login was refused ("" when it succeeded).
	def OidcWhy()
		return @cOidcWhy

	# the local user name an external identity maps to: its verified email when
	# the provider asserts one, else "issuer|subject" (always unique, never
	# collides with a local account name).
	def OidcUserNameFor(paIdentity)
		if isList(paIdentity) and ("" + paIdentity[:email]) != ""
			return "" + paIdentity[:email]
		ok
		if NOT This.HasOidcClient()
			return ""
		ok
		return @oOidc.Issuer() + "|" + paIdentity[:subject]

	def LoginWithOidc(pcIdToken, pcNonce)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, "", "", This._NowSecs())

	def LoginWithOidcAt(pcIdToken, pcNonce, pnNow)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, "", "", pnNow)

	def LoginWithOidcWith(pcIdToken, pcNonce, pcIp, pcUserAgent)
		return This.LoginWithOidcWithAt(pcIdToken, pcNonce, pcIp, pcUserAgent, This._NowSecs())

	# -> a session token, or "" (with OidcWhy() explaining).
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

	  #-- lockout queries -------------------------------------------------

	def IsLockedOut(pcUser)
		return This.IsLockedOutAt(ring_trim("" + pcUser), This._NowSecs())

	def IsLockedOutAt(pcUser, pnNow)
		_i_ = This._FailureIndex("" + pcUser)
		if _i_ = 0
			return 0
		ok
		return @aFailures[_i_][2] >= @nMaxAttempts and pnNow < @aFailures[_i_][3]

	def FailedAttempts(pcUser)
		_i_ = This._FailureIndex(ring_trim("" + pcUser))
		if _i_ = 0
			return 0
		ok
		return @aFailures[_i_][2]

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
