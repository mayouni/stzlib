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
	@nSessionTTL = 3600  # seconds a session lives (0 = never expires)
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
		return This.LoginAt(pcUser, pcPassword, This._NowSecs())

	# deterministic form (explicit 'now') for tests.
	def LoginAt(pcUser, pcPassword, pnNow)
		_u_ = ring_trim("" + pcUser)
		if This.IsLockedOutAt(_u_, pnNow)
			return ""
		ok
		if NOT This.Authenticate(_u_, pcPassword)
			This._RecordFailure(_u_, pnNow)
			return ""
		ok
		This._ClearFailures(_u_)
		_tok_ = StzEngineCryptoRandomHex(32)
		_exp_ = 0
		if @nSessionTTL > 0
			_exp_ = pnNow + @nSessionTTL
		ok
		@oStore.PutSession(_tok_, _u_, _exp_)
		return _tok_

	# the user behind a live session token, or "" if unknown / ended / EXPIRED
	# (checked against the wall clock).
	def UserOfSession(pcToken)
		return This.UserOfSessionAt(pcToken, This._NowSecs())

	# same, against an explicit 'now' (epoch seconds) -- deterministic for tests.
	def UserOfSessionAt(pcToken, pnNowSecs)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return ""
		ok
		if _s_[2] > 0 and pnNowSecs >= _s_[2]
			return ""
		ok
		return _s_[1]

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
		if _s_[2] > 0
			_oTok_.SetExpiry(_s_[2])
		ok
		return _oTok_

	# the epoch-seconds a session expires at (0 = never), or -1 if unknown.
	def SessionExpiresAt(pcToken)
		_s_ = @oStore.Session("" + pcToken)
		if len(_s_) = 0
			return -1
		ok
		return _s_[2]

	# drop expired sessions (housekeeping) -> the number pruned.
	def PurgeExpiredAt(pnNowSecs)
		_aS_ = @oStore.Sessions()
		_nP_ = 0
		_n_ = len(_aS_)
		for _i_ = 1 to _n_
			if _aS_[_i_][3] > 0 and pnNowSecs >= _aS_[_i_][3]
				@oStore.DeleteSession(_aS_[_i_][1])
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

	# end EVERY session for a user without removing the account ("log out
	# everywhere") -- distinct from Unregister.
	def RevokeAllSessions(pcUser)
		@oStore.DeleteUserSessions(ring_trim("" + pcUser))
		return This

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
