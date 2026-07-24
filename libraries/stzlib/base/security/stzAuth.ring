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

	@oStore = NULL       # the persistence seam (users + sessions) -- see stzAuthStore
	@nSessionTTL = 3600  # ABSOLUTE lifetime: seconds from login (0 = never expires)
	@nIdleTTL = 0        # IDLE lifetime: seconds of inactivity before death (0 = off)
	@cDummyHash = ""     # a real hash used to equalize timing for unknown users

	# brute-force lockout (in-memory, per submitted username). Not durable across
	# restarts by design -- rate-limit state, not identity data; a shared/durable
	# limiter is a later hardening. Kept here so it never leaks into the store.
	@aFailures = []      # [ [ user, count, lockedUntil ], ... ]
	@nMaxAttempts = 5
	@nLockoutSecs = 900  # 15 minutes

	def init()
		@oStore = new stzAuthMemoryStore()   # durable store injected via SetStore
		@cDummyHash = StzHashSecret("softanza-timing-equalizer")
		@aFailures = []

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

	def IsRegistered(pcUser)
		return @oStore.HasUser(ring_trim("" + pcUser))

	def NumberOfUsers()
		return @oStore.CountUsers()

	# change a password (the current one must be presented). TRUE on success.
	def ChangePassword(pcUser, pcOld, pcNew)
		_u_ = ring_trim("" + pcUser)
		_h_ = @oStore.UserHash(_u_)
		if _h_ = "" or NOT StzVerifySecret("" + pcOld, _h_)
			return FALSE
		ok
		@oStore.PutUser(_u_, StzHashSecret("" + pcNew))
		return TRUE

	# remove a user (and end any of their sessions).
	def Unregister(pcUser)
		_u_ = ring_trim("" + pcUser)
		@oStore.DeleteUser(_u_)
		@oStore.DeleteUserSessions(_u_)
		@oStore.DeleteTotp(_u_)
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
			return FALSE
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
			return NULL
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
			_dead_ = FALSE
			if _aS_[_i_][:expires] > 0 and pnNowSecs >= _aS_[_i_][:expires]
				_dead_ = TRUE
			ok
			if @nIdleTTL > 0 and (pnNowSecs - _aS_[_i_][:lastseen]) >= @nIdleTTL
				_dead_ = TRUE
			ok
			if _dead_
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
		@oStore.DeleteSession("" + pcToken)
		return This

	# revoke ONE session (per-device "sign out this device"). Alias of Logout,
	# named for the device-management flow.
	def RevokeSession(pcToken)
		@oStore.DeleteSession("" + pcToken)
		return This

	# end EVERY session for a user without removing the account ("log out
	# everywhere") -- distinct from Unregister.
	def RevokeAllSessions(pcUser)
		@oStore.DeleteUserSessions(ring_trim("" + pcUser))
		return This

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
			return FALSE
		ok
		_oT_ = StzTotpFromSecretQ(_rec_[:secret])
		if _oT_.VerifyAt(pcCode, pnNow)
			return TRUE
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

	  #-- lockout queries -------------------------------------------------

	def IsLockedOut(pcUser)
		return This.IsLockedOutAt(ring_trim("" + pcUser), This._NowSecs())

	def IsLockedOutAt(pcUser, pnNow)
		_i_ = This._FailureIndex("" + pcUser)
		if _i_ = 0
			return FALSE
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
		if @aFailures[_i_][2] >= @nMaxAttempts
			@aFailures[_i_][3] = pnNow + @nLockoutSecs
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
			return FALSE
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
				return TRUE
			ok
		next
		return FALSE

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
