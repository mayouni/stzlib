#================================================================#
#  STZAUTHSTORE -- where stzAuth's users + sessions LIVE           #
#================================================================#

/*--- The persistence seam for authentication (auth plan, phase 1)

stzAuth kept its users and sessions in Ring lists -- they vanished when the
process ended. Better Auth's load-bearing idea is a database ADAPTER: the auth
core knows nothing about the store; you swap the backend. Softanza already has
this exact seam (stzVaultResolver's duck-typed Resolve; the service-virtualization
port), so stzAuth persists through an AUTH STORE -- any object exposing:

    PutUser(user, hash) / UserHash(user) -> "" / HasUser / DeleteUser / CountUsers
    PutSession(token, user, expiresAt) / Session(token) -> [ user, expiresAt ] / []
    DeleteSession / DeleteUserSessions / CountSessions / Sessions() -> [ [t,u,e], ... ]

Two implementations ship: stzAuthMemoryStore (the default -- today's behaviour,
for dev and tests) and stzAuthDbStore (over stzDatabase -> sqlite, durable).
In production you point stzAuth at a db store and nothing else changes.

WHY THE DB STORE IS COPY-SAFE. Ring copies objects on `=`, so a store HELD in an
stzAuth attribute is a copy -- but stzAuthDbStore's state is a stzDatabase, whose
sqlite connection is an ENGINE HANDLE, so a copied wrapper still writes the SAME
database (the stzAppBackend insight). The default memory store is created by
stzAuth itself and only mutated through its own methods, so it stays consistent
too. Only a memory store PASSED IN from outside would diverge from the caller's
copy -- which is why you pass a DB store to production, never a shared in-memory
one.
*/

func StzAuthMemoryStoreQ()
	return new stzAuthMemoryStore()

func StzAuthDbStoreQ(pcPath)
	return new stzAuthDbStore(pcPath)


  #=========================================================#
 #  IN-MEMORY STORE (default) -- the reference implementation #
#=========================================================#

# Keeps the users, sessions, two-factor rows, challenges, roles, passkeys and locks of stzAuth in Ring lists, for development and tests.
#
# It is the default store of stzAuth and the reference for the store contract: PutUser, UserHash,
# PutSession, Session and the rest. Nothing outlives the process; stzAuthDbStore answers the same
# calls over sqlite. Pass a database store, never a shared memory one, to production: Ring copies an
# object on assignment, so a memory store handed in from outside diverges from the caller's copy.
#
#   receiver   o1 = new stzAuthMemoryStore()
#   example    o1.PutUser("alice", "hash-of-alice")
#              o1.GrantRole("alice", "editor")
#              ? o1.HasUser("alice")
#              #--> 1
#              ? @@( o1.RolesOf("alice") )
#              #--> [ "editor" ]
#   see        stzAuthDbStore, stzAuth, StzAuthMemoryStoreQ
class stzAuthMemoryStore from stzObject

	@aUsers      = []  # [ [ user, hash ], ... ]
	@aSessions   = []  # [ [ token, user, expiresAt ], ... ]
	@a2fa        = []  # [ [ user, secretB32, confirmed(0/1), [ recoveryHash, ... ] ], ... ]
	@aChallenges = []  # [ [ handle, kind, email, codehash, expiresAt ], ... ]
	@aPasskeys   = []  # [ [ credId, user, kty, k1, k2, signCount ], ... ]
	@aRoles      = []  # [ [ user, role ], ... ] -- the authz grants
	@aLocks      = []  # [ [ user, reason, lockedAtSecs ], ... ] -- administrative locks

	# Builds an empty in-memory store, the default place stzAuth keeps users and sessions; nothing outlives the process.
	#
	#   returns    nothing; the object is built
	#   see        stzAuthDbStore, StzAuthMemoryStoreQ
	def init()
		@aUsers      = []
		@aSessions   = []
		@a2fa        = []
		@aChallenges = []
		@aPasskeys   = []
		@aRoles      = []
		@aLocks      = []

	# Locks a user until someone unlocks them, recording the reason and the time; a lock already held is replaced.
	#
	#   pcUser     the user to lock
	#   pcReason   the reason, as text
	#   pnAt       the time of the lock, in seconds
	#   returns    nothing; the lock is kept
	#   note       a lock stays until DeleteLock, unlike a failure lockout that expires
	#   see        LockOf, DeleteLock
	#@ aka  -- administrative locks (containment) -------------------------------
	def PutLock(pcUser, pcReason, pnAt)
		This.DeleteLock(pcUser)
		@aLocks + [ "" + pcUser, "" + pcReason, pnAt ]

	# Lifts the lock of a user; a user with no lock changes nothing.
	#
	#   pcUser     the user to unlock
	#   returns    nothing
	#   see        PutLock, LockOf
	def DeleteLock(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aLocks)
		for _i_ = 1 to _n_
			if @aLocks[_i_][1] != _u_
				_aNew_ + @aLocks[_i_]
			ok
		next
		@aLocks = _aNew_

	# Returns the lock of a user, as a hashlist of its reason and its time.
	#
	#   pcUser     the user to look up
	#   returns    a hashlist [ :reason, :at ], or an empty list when the user is not locked
	#   see        PutLock, DeleteLock
	#@ aka  [ :reason, :at ] or [] when the user is not locked.
	def LockOf(pcUser)
		_u_ = "" + pcUser
		_n_ = len(@aLocks)
		for _i_ = 1 to _n_
			if @aLocks[_i_][1] = _u_
				return [ :reason = @aLocks[_i_][2], :at = @aLocks[_i_][3] ]
			ok
		next
		return []

	# Stores a user with a password hash, replacing the hash of a user that is already stored.
	#
	#   pcUser     the user name, matched exactly and with case
	#   pcHash     the password hash to keep, as text
	#   returns    nothing
	#   note       the hash is stored as given and never computed here
	#   see        UserHash, HasUser, DeleteUser
	#@ aka  -- users -----------------------------------------------------------
	def PutUser(pcUser, pcHash)
		_u_ = "" + pcUser
		_i_ = This._UserIndex(_u_)
		if _i_ > 0
			@aUsers[_i_][2] = "" + pcHash
		else
			@aUsers + [ _u_, "" + pcHash ]
		ok

	# Returns the password hash stored for a user.
	#
	#   pcUser     the user name
	#   returns    a text; an empty text when the user is unknown
	#   see        PutUser, HasUser
	def UserHash(pcUser)
		_i_ = This._UserIndex("" + pcUser)
		if _i_ = 0
			return ""
		ok
		return @aUsers[_i_][2]

	# TRUE if a user of that exact name is stored.
	#
	#   pcUser     the user name, matched with case
	#   returns    TRUE or FALSE
	#   see        PutUser, CountUsers
	def HasUser(pcUser)
		return This._UserIndex("" + pcUser) > 0

	# Removes a user and its hash; an unknown user changes nothing.
	#
	#   pcUser     the user name to remove
	#   returns    nothing
	#   note       the sessions, roles and passkeys of that user are kept; remove them with their
	#              own Delete calls
	#   see        PutUser, DeleteUserSessions
	def DeleteUser(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aUsers)
		for _i_ = 1 to _n_
			if @aUsers[_i_][1] != _u_
				_aNew_ + @aUsers[_i_]
			ok
		next
		@aUsers = _aNew_

	# Returns how many users are stored.
	#
	#   returns    a number
	#   see        HasUser, PutUser
	def CountUsers()
		return len(@aUsers)

	# Stores a session under a token, with the user it belongs to, its times and the device that opened it.
	#
	#   pcToken    the session token, as text
	#   paRec      a hashlist [ :user, :expires, :created, :ip, :ua, :lastseen ], everything but the
	#              token
	#   returns    nothing
	#   warning    a second call with a token already stored adds a second row instead of replacing
	#              the first, so Session keeps answering the first and CountSessions grows; the
	#              sqlite store replaces the row
	#   see        Session, TouchSession, DeleteSession
	#@ aka  -- sessions --------------------------------------------------------
	def PutSession(pcToken, paRec)
		@aSessions + [ :token = "" + pcToken, :user = paRec[:user],
		               :expires = paRec[:expires], :created = paRec[:created],
		               :ip = paRec[:ip], :ua = paRec[:ua], :lastseen = paRec[:lastseen] ]

	# Returns the record of a session.
	#
	#   pcToken    the session token to look up
	#   returns    a hashlist [ :token, :user, :expires, :created, :ip, :ua, :lastseen ], or an
	#              empty list when the token is unknown
	#   see        PutSession, SessionsOf
	#@ aka  the full record (with :token) or [] when the token is unknown.
	def Session(pcToken)
		_t_ = "" + pcToken
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:token] = _t_
				return @aSessions[_i_]
			ok
		next
		return []

	# Sets the last-seen time of a session, which is what an idle timeout compares; an unknown token changes nothing.
	#
	#   pcToken      the session token
	#   pnLastSeen   the new last-seen time, in seconds
	#   returns      nothing
	#   see          Session, PutSession
	#@ aka  update a session's last-seen stamp (idle-timeout sliding window). Rebuilds the row rather than mutating a hashlist field in place (that INSERTS a key).
	def TouchSession(pcToken, pnLastSeen)
		_t_ = "" + pcToken
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:token] = _t_
				_r_ = @aSessions[_i_]
				@aSessions[_i_] = [ :token = _r_[:token], :user = _r_[:user],
				                    :expires = _r_[:expires], :created = _r_[:created],
				                    :ip = _r_[:ip], :ua = _r_[:ua], :lastseen = pnLastSeen ]
				return
			ok
		next

	# Removes the session of a token, which logs that device out; an unknown token changes nothing.
	#
	#   pcToken    the session token to remove
	#   returns    nothing
	#   see        DeleteUserSessions, PutSession
	def DeleteSession(pcToken)
		_t_ = "" + pcToken
		_aNew_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:token] != _t_
				_aNew_ + @aSessions[_i_]
			ok
		next
		@aSessions = _aNew_

	# Removes every session of a user, which logs the user out of all devices.
	#
	#   pcUser     the user whose sessions go
	#   returns    nothing
	#   see        DeleteSession, SessionsOf
	def DeleteUserSessions(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:user] != _u_
				_aNew_ + @aSessions[_i_]
			ok
		next
		@aSessions = _aNew_

	# Returns how many sessions are stored, whatever their user.
	#
	#   returns    a number
	#   see        Sessions, SessionsOf
	def CountSessions()
		return len(@aSessions)

	# Returns every stored session record, for a purge or a listing.
	#
	#   returns    a list of session hashlists
	#   see        SessionsOf, CountSessions
	#@ aka  all session records -- for purge / enumeration.
	def Sessions()
		return @aSessions

	# Returns the session records of one user, which is what a devices view lists.
	#
	#   pcUser     the user whose sessions to list
	#   returns    a list of session hashlists; an empty list when the user has none
	#   see        Sessions, Session
	#@ aka  the records belonging to one user.
	def SessionsOf(pcUser)
		_u_ = "" + pcUser
		_out_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:user] = _u_
				_out_ + @aSessions[_i_]
			ok
		next
		return _out_

	# Stores the two-factor secret of a user with its confirmed flag and its recovery-code hashes, replacing any earlier row of that user.
	#
	#   pcUser        the user name
	#   pcSecret      the base32 secret of the authenticator
	#   pnConfirmed   1 once the user proved a first code, 0 before
	#   paHashes      a list of the recovery-code hashes, never the plain codes
	#   returns       nothing
	#   see           Totp, SetTotpConfirmed, SetTotpRecovery
	#@ aka  -- two-factor (TOTP) ----------------------------------------------
	def PutTotp(pcUser, pcSecret, pnConfirmed, paHashes)
		_u_ = "" + pcUser
		_i_ = This._TotpIndex(_u_)
		_rec_ = [ _u_, "" + pcSecret, pnConfirmed, paHashes ]
		if _i_ > 0
			@a2fa[_i_] = _rec_
		else
			@a2fa + _rec_
		ok

	# Returns the two-factor row of a user.
	#
	#   pcUser     the user name
	#   returns    a hashlist [ :secret, :confirmed, :recovery ], or an empty list when the user has
	#              none
	#   see        PutTotp, DeleteTotp
	def Totp(pcUser)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ = 0
			return []
		ok
		_r_ = @a2fa[_i_]
		return [ :secret = _r_[2], :confirmed = _r_[3], :recovery = _r_[4] ]

	# Sets the confirmed flag of a user's two-factor row; a user with no row changes nothing.
	#
	#   pcUser        the user name
	#   pnConfirmed   1 to enforce the secret, 0 to hold it back
	#   returns       nothing
	#   see           PutTotp, Totp
	def SetTotpConfirmed(pcUser, pnConfirmed)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ > 0
			@a2fa[_i_][3] = pnConfirmed
		ok

	# Replaces the recovery-code hashes of a user's two-factor row; a user with no row changes nothing.
	#
	#   pcUser     the user name
	#   paHashes   the new list of recovery-code hashes
	#   returns    nothing
	#   see        PutTotp, Totp
	def SetTotpRecovery(pcUser, paHashes)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ > 0
			@a2fa[_i_][4] = paHashes
		ok

	# Removes the two-factor row of a user; a user with no row changes nothing.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        PutTotp, Totp
	def DeleteTotp(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@a2fa)
		for _i_ = 1 to _n_
			if @a2fa[_i_][1] != _u_
				_aNew_ + @a2fa[_i_]
			ok
		next
		@a2fa = _aNew_

	# Stores a short-lived passwordless challenge under a handle, replacing the one that holds the same handle.
	#
	#   pcHandle     the lookup key of the challenge
	#   pcKind       the kind of challenge, such as otp or magic
	#   pcEmail      the address the challenge was sent to
	#   pcCodeHash   the hash of the code, empty when the token is the secret
	#   pnExpires    the time the challenge ends, in seconds
	#   returns      nothing
	#   see          Challenge, DeleteChallenge
	#@ aka  -- passwordless challenges (magic-link / email-OTP) ----------------
	def PutChallenge(pcHandle, pcKind, pcEmail, pcCodeHash, pnExpires)
		_h_ = "" + pcHandle
		_i_ = This._ChallengeIndex(_h_)
		_rec_ = [ _h_, "" + pcKind, "" + pcEmail, "" + pcCodeHash, pnExpires ]
		if _i_ > 0
			@aChallenges[_i_] = _rec_
		else
			@aChallenges + _rec_
		ok

	# Returns the challenge held under a handle.
	#
	#   pcHandle   the lookup key
	#   returns    a hashlist [ :kind, :email, :codehash, :expires ], or an empty list when the
	#              handle is unknown
	#   see        PutChallenge, DeleteChallenge
	def Challenge(pcHandle)
		_i_ = This._ChallengeIndex("" + pcHandle)
		if _i_ = 0
			return []
		ok
		_r_ = @aChallenges[_i_]
		return [ :kind = _r_[2], :email = _r_[3], :codehash = _r_[4], :expires = _r_[5] ]

	# Removes the challenge held under a handle, which spends it; an unknown handle changes nothing.
	#
	#   pcHandle   the lookup key
	#   returns    nothing
	#   see        PutChallenge, Challenge
	def DeleteChallenge(pcHandle)
		_h_ = "" + pcHandle
		_aNew_ = []
		_n_ = len(@aChallenges)
		for _i_ = 1 to _n_
			if @aChallenges[_i_][1] != _h_
				_aNew_ + @aChallenges[_i_]
			ok
		next
		@aChallenges = _aNew_

	# Gives a user a role; granting a role the user already has changes nothing.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    nothing
	#   see        RevokeRole, HasRole, RolesOf
	#@ aka  -- authz roles (the authn->authz bridge) ---------------------------
	def GrantRole(pcUser, pcRole)
		_u_ = "" + pcUser
		_r_ = "" + pcRole
		if NOT This.HasRole(_u_, _r_)
			@aRoles + [ _u_, _r_ ]
		ok

	# Takes one role away from a user; a role the user lacks changes nothing.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    nothing
	#   see        GrantRole, DeleteUserRoles
	def RevokeRole(pcUser, pcRole)
		_u_ = "" + pcUser
		_r_ = "" + pcRole
		_aNew_ = []
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			if NOT (@aRoles[_i_][1] = _u_ and @aRoles[_i_][2] = _r_)
				_aNew_ + @aRoles[_i_]
			ok
		next
		@aRoles = _aNew_

	# TRUE if the user holds that role.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    TRUE or FALSE
	#   see        GrantRole, RolesOf
	def HasRole(pcUser, pcRole)
		_u_ = "" + pcUser
		_r_ = "" + pcRole
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			if @aRoles[_i_][1] = _u_ and @aRoles[_i_][2] = _r_
				return 1
			ok
		next
		return 0

	# Returns the roles of a user.
	#
	#   pcUser     the user name
	#   returns    a list of text; an empty list when the user has none
	#   see        GrantRole, HasRole
	def RolesOf(pcUser)
		_u_ = "" + pcUser
		_out_ = []
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			if @aRoles[_i_][1] = _u_
				_out_ + @aRoles[_i_][2]
			ok
		next
		return _out_

	# Takes every role away from a user.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        RevokeRole, RolesOf
	def DeleteUserRoles(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aRoles)
		for _i_ = 1 to _n_
			if @aRoles[_i_][1] != _u_
				_aNew_ + @aRoles[_i_]
			ok
		next
		@aRoles = _aNew_

	# Stores a passkey credential with its owner, its public key and its signature counter, replacing the credential of the same id.
	#
	#   pcCredId   the credential id
	#   pcUser     the user that owns it
	#   pcKty      the key type
	#   pcK1       the first part of the public key
	#   pcK2       the second part of the public key
	#   pnCount    the signature counter
	#   returns    nothing
	#   see        Passkey, PasskeysOf, SetPasskeyCounter
	#@ aka  -- passkeys (WebAuthn credentials) ---------------------------------
	def PutPasskey(pcCredId, pcUser, pcKty, pcK1, pcK2, pnCount)
		_c_ = "" + pcCredId
		_i_ = This._PasskeyIndex(_c_)
		_rec_ = [ _c_, "" + pcUser, "" + pcKty, "" + pcK1, "" + pcK2, pnCount ]
		if _i_ > 0
			@aPasskeys[_i_] = _rec_
		else
			@aPasskeys + _rec_
		ok

	# Returns one passkey credential.
	#
	#   pcCredId   the credential id
	#   returns    a hashlist [ :credentialid, :user, :keytype, :key1, :key2, :signcount ], or an
	#              empty list when the id is unknown
	#   see        PutPasskey, PasskeysOf
	def Passkey(pcCredId)
		_i_ = This._PasskeyIndex("" + pcCredId)
		if _i_ = 0
			return []
		ok
		_r_ = @aPasskeys[_i_]
		return [ :credentialId = _r_[1], :user = _r_[2], :keyType = _r_[3],
		         :key1 = _r_[4], :key2 = _r_[5], :signCount = _r_[6] ]

	# Returns the passkey credentials of one user, one per enrolled device.
	#
	#   pcUser     the user name
	#   returns    a list of passkey hashlists; an empty list when the user has none
	#   see        Passkey, PutPasskey
	def PasskeysOf(pcUser)
		_u_ = "" + pcUser
		_out_ = []
		_n_ = len(@aPasskeys)
		for _i_ = 1 to _n_
			if @aPasskeys[_i_][2] = _u_
				_out_ + This.Passkey(@aPasskeys[_i_][1])
			ok
		next
		return _out_

	# Sets the signature counter of a passkey; an unknown id changes nothing.
	#
	#   pcCredId   the credential id
	#   pnCount    the new counter
	#   returns    nothing
	#   see        Passkey, PutPasskey
	def SetPasskeyCounter(pcCredId, pnCount)
		_i_ = This._PasskeyIndex("" + pcCredId)
		if _i_ > 0
			@aPasskeys[_i_][6] = pnCount
		ok

	# Removes one passkey credential; an unknown id changes nothing.
	#
	#   pcCredId   the credential id
	#   returns    nothing
	#   see        DeleteUserPasskeys, PutPasskey
	def DeletePasskey(pcCredId)
		_c_ = "" + pcCredId
		_aNew_ = []
		_n_ = len(@aPasskeys)
		for _i_ = 1 to _n_
			if @aPasskeys[_i_][1] != _c_
				_aNew_ + @aPasskeys[_i_]
			ok
		next
		@aPasskeys = _aNew_

	# Removes every passkey credential of a user.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        DeletePasskey, PasskeysOf
	def DeleteUserPasskeys(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aPasskeys)
		for _i_ = 1 to _n_
			if @aPasskeys[_i_][2] != _u_
				_aNew_ + @aPasskeys[_i_]
			ok
		next
		@aPasskeys = _aNew_

	  #-- internals -------------------------------------------------------

	def _PasskeyIndex(pcCredId)
		_n_ = len(@aPasskeys)
		for _i_ = 1 to _n_
			if @aPasskeys[_i_][1] = pcCredId
				return _i_
			ok
		next
		return 0

	def _UserIndex(pcUser)
		_n_ = len(@aUsers)
		for _i_ = 1 to _n_
			if @aUsers[_i_][1] = pcUser
				return _i_
			ok
		next
		return 0

	def _TotpIndex(pcUser)
		_n_ = len(@a2fa)
		for _i_ = 1 to _n_
			if @a2fa[_i_][1] = pcUser
				return _i_
			ok
		next
		return 0

	def _ChallengeIndex(pcHandle)
		_n_ = len(@aChallenges)
		for _i_ = 1 to _n_
			if @aChallenges[_i_][1] = pcHandle
				return _i_
			ok
		next
		return 0


  #=========================================================#
 #  SQLITE STORE -- durable, over stzDatabase                #
#=========================================================#

# Keeps the users, sessions, two-factor rows, challenges, roles, passkeys and locks of stzAuth in a sqlite database, so they outlive the process.
#
# It answers the same calls as stzAuthMemoryStore. Its only state is a stzDatabase, whose connection
# is an engine handle, so a copied store still writes the same database. Every statement binds its
# values and none is spliced into SQL text. Give it a file path to be durable, or :memory: for a
# real sqlite that lives only in the process.
#
#   receiver   o1 = new stzAuthDbStore(":memory:")
#   example    o1.PutUser("alice", "hash-of-alice")
#              o1.GrantRole("alice", "editor")
#              ? o1.HasUser("alice")
#              #--> 1
#              ? @@( o1.RolesOf("alice") )
#              #--> [ "editor" ]
#   see        stzAuthMemoryStore, stzAuth, StzAuthDbStoreQ, stzDatabase
class stzAuthDbStore from stzObject

	@oDb = ""

	# Opens a sqlite database and creates the auth tables when they are absent, so users and sessions outlive the process.
	#
	#   pcPath     a sqlite file path, or :memory: for a database that lives only in the process
	#   returns    nothing; the object is built
	#   see        stzAuthMemoryStore, StzAuthDbStoreQ
	#@ aka  pcPath = a file path (durable) or ":memory:" (a real sqlite, but process- local). The tables are created on first use.
	def init(pcPath)
		@oDb = new stzDatabase("" + pcPath)
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authusers (usr TEXT PRIMARY KEY, hash TEXT)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authsessions (token TEXT PRIMARY KEY, " +
		          "usr TEXT, expires INTEGER, created INTEGER, ip TEXT, ua TEXT, lastseen INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS auth2fa (usr TEXT PRIMARY KEY, " +
		          "secret TEXT, confirmed INTEGER, recovery TEXT)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authchallenges (handle TEXT PRIMARY KEY, " +
		          "kind TEXT, email TEXT, codehash TEXT, expires INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authpasskeys (credid TEXT PRIMARY KEY, " +
		          "usr TEXT, kty TEXT, k1 TEXT, k2 TEXT, signcount INTEGER)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authroles (usr TEXT, role TEXT, " +
		          "PRIMARY KEY (usr, role))")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authlocks (usr TEXT PRIMARY KEY, reason TEXT, lockedat INTEGER)")

	# Returns the stzDatabase the store writes to, to read or inspect the tables.
	#
	#   returns    a stzDatabase
	#   see        init
	def DatabaseQ()
		return @oDb

	# Stores a user with a password hash, replacing the hash of a user that is already stored.
	#
	#   pcUser     the user name, matched exactly and with case
	#   pcHash     the password hash to keep, as text
	#   returns    nothing
	#   note       the hash is stored as given and never computed here
	#   see        UserHash, HasUser, DeleteUser
	#@ aka  -- users -----------------------------------------------------------
	def PutUser(pcUser, pcHash)
		@oDb.ExecWith("INSERT OR REPLACE INTO authusers (usr, hash) VALUES (?, ?)",
		              [ "" + pcUser, "" + pcHash ])

	# Returns the password hash stored for a user.
	#
	#   pcUser     the user name
	#   returns    a text; an empty text when the user is unknown
	#   see        PutUser, HasUser
	def UserHash(pcUser)
		_r_ = @oDb.RowsWith("SELECT hash FROM authusers WHERE usr = ?", [ "" + pcUser ])
		if len(_r_) = 0
			return ""
		ok
		return "" + _r_[1][1]

	# TRUE if a user of that exact name is stored.
	#
	#   pcUser     the user name, matched with case
	#   returns    TRUE or FALSE
	#   see        PutUser, CountUsers
	def HasUser(pcUser)
		return ring_number(@oDb.ValueWith("SELECT COUNT(*) FROM authusers WHERE usr = ?",
		       [ "" + pcUser ])) > 0

	# Removes a user and its hash; an unknown user changes nothing.
	#
	#   pcUser     the user name to remove
	#   returns    nothing
	#   note       the sessions, roles and passkeys of that user are kept; remove them with their
	#              own Delete calls
	#   see        PutUser, DeleteUserSessions
	def DeleteUser(pcUser)
		@oDb.ExecWith("DELETE FROM authusers WHERE usr = ?", [ "" + pcUser ])

	# Returns how many users are stored.
	#
	#   returns    a number
	#   see        HasUser, PutUser
	def CountUsers()
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authusers"))

	# Stores a session under a token, with the user it belongs to, its times and the device that opened it.
	#
	#   pcToken    the session token, as text
	#   paRec      a hashlist [ :user, :expires, :created, :ip, :ua, :lastseen ], everything but the
	#              token
	#   returns    nothing
	#   see        Session, TouchSession, DeleteSession
	#@ aka  -- sessions --------------------------------------------------------
	def PutSession(pcToken, paRec)
		@oDb.ExecWith("INSERT OR REPLACE INTO authsessions (token, usr, expires, created, ip, ua, lastseen) " +
		              "VALUES (?, ?, ?, ?, ?, ?, ?)",
		              [ "" + pcToken, "" + paRec[:user], ring_number(paRec[:expires]),
		                ring_number(paRec[:created]), "" + paRec[:ip], "" + paRec[:ua],
		                ring_number(paRec[:lastseen]) ])

	# Returns the record of a session.
	#
	#   pcToken    the session token to look up
	#   returns    a hashlist [ :token, :user, :expires, :created, :ip, :ua, :lastseen ], or an
	#              empty list when the token is unknown
	#   see        PutSession, SessionsOf
	def Session(pcToken)
		_r_ = @oDb.RowsWith("SELECT usr, expires, created, ip, ua, lastseen FROM authsessions WHERE token = ?",
		                    [ "" + pcToken ])
		if len(_r_) = 0
			return []
		ok
		return This._Rec("" + pcToken, _r_[1])

	# Sets the last-seen time of a session, which is what an idle timeout compares; an unknown token changes nothing.
	#
	#   pcToken      the session token
	#   pnLastSeen   the new last-seen time, in seconds
	#   returns      nothing
	#   see          Session, PutSession
	def TouchSession(pcToken, pnLastSeen)
		@oDb.ExecWith("UPDATE authsessions SET lastseen = ? WHERE token = ?",
		              [ ring_number(pnLastSeen), "" + pcToken ])

	# Removes the session of a token, which logs that device out; an unknown token changes nothing.
	#
	#   pcToken    the session token to remove
	#   returns    nothing
	#   see        DeleteUserSessions, PutSession
	def DeleteSession(pcToken)
		@oDb.ExecWith("DELETE FROM authsessions WHERE token = ?", [ "" + pcToken ])

	# Removes every session of a user, which logs the user out of all devices.
	#
	#   pcUser     the user whose sessions go
	#   returns    nothing
	#   see        DeleteSession, SessionsOf
	def DeleteUserSessions(pcUser)
		@oDb.ExecWith("DELETE FROM authsessions WHERE usr = ?", [ "" + pcUser ])

	# Returns how many sessions are stored, whatever their user.
	#
	#   returns    a number
	#   see        Sessions, SessionsOf
	def CountSessions()
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authsessions"))

	# Returns every stored session record, for a purge or a listing.
	#
	#   returns    a list of session hashlists
	#   see        SessionsOf, CountSessions
	def Sessions()
		return This._RowsToRecs(@oDb.Rows("SELECT token, usr, expires, created, ip, ua, lastseen FROM authsessions"))

	# Returns the session records of one user, which is what a devices view lists.
	#
	#   pcUser     the user whose sessions to list
	#   returns    a list of session hashlists; an empty list when the user has none
	#   see        Sessions, Session
	def SessionsOf(pcUser)
		return This._RowsToRecs(@oDb.RowsWith("SELECT token, usr, expires, created, ip, ua, lastseen " +
		       "FROM authsessions WHERE usr = ?", [ "" + pcUser ]))

	# Stores the two-factor secret of a user with its confirmed flag and its recovery-code hashes, replacing any earlier row of that user.
	#
	#   pcUser        the user name
	#   pcSecret      the base32 secret of the authenticator
	#   pnConfirmed   1 once the user proved a first code, 0 before
	#   paHashes      a list of the recovery-code hashes, never the plain codes
	#   returns       nothing
	#   see           Totp, SetTotpConfirmed, SetTotpRecovery
	#@ aka  -- two-factor (TOTP) ----------------------------------------------
	def PutTotp(pcUser, pcSecret, pnConfirmed, paHashes)
		@oDb.ExecWith("INSERT OR REPLACE INTO auth2fa (usr, secret, confirmed, recovery) VALUES (?, ?, ?, ?)",
		              [ "" + pcUser, "" + pcSecret, ring_number(pnConfirmed),
		                This._JoinHashes(paHashes) ])

	# Returns the two-factor row of a user.
	#
	#   pcUser     the user name
	#   returns    a hashlist [ :secret, :confirmed, :recovery ], or an empty list when the user has
	#              none
	#   see        PutTotp, DeleteTotp
	def Totp(pcUser)
		_r_ = @oDb.RowsWith("SELECT secret, confirmed, recovery FROM auth2fa WHERE usr = ?", [ "" + pcUser ])
		if len(_r_) = 0
			return []
		ok
		return [ :secret = "" + _r_[1][1], :confirmed = ring_number(_r_[1][2]),
		         :recovery = This._SplitHashes("" + _r_[1][3]) ]

	# Sets the confirmed flag of a user's two-factor row; a user with no row changes nothing.
	#
	#   pcUser        the user name
	#   pnConfirmed   1 to enforce the secret, 0 to hold it back
	#   returns       nothing
	#   see           PutTotp, Totp
	def SetTotpConfirmed(pcUser, pnConfirmed)
		@oDb.ExecWith("UPDATE auth2fa SET confirmed = ? WHERE usr = ?",
		              [ ring_number(pnConfirmed), "" + pcUser ])

	# Replaces the recovery-code hashes of a user's two-factor row; a user with no row changes nothing.
	#
	#   pcUser     the user name
	#   paHashes   the new list of recovery-code hashes
	#   returns    nothing
	#   see        PutTotp, Totp
	def SetTotpRecovery(pcUser, paHashes)
		@oDb.ExecWith("UPDATE auth2fa SET recovery = ? WHERE usr = ?",
		              [ This._JoinHashes(paHashes), "" + pcUser ])

	# Removes the two-factor row of a user; a user with no row changes nothing.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        PutTotp, Totp
	def DeleteTotp(pcUser)
		@oDb.ExecWith("DELETE FROM auth2fa WHERE usr = ?", [ "" + pcUser ])

	# Stores a short-lived passwordless challenge under a handle, replacing the one that holds the same handle.
	#
	#   pcHandle     the lookup key of the challenge
	#   pcKind       the kind of challenge, such as otp or magic
	#   pcEmail      the address the challenge was sent to
	#   pcCodeHash   the hash of the code, empty when the token is the secret
	#   pnExpires    the time the challenge ends, in seconds
	#   returns      nothing
	#   see          Challenge, DeleteChallenge
	#@ aka  -- passwordless challenges (magic-link / email-OTP) ----------------
	def PutChallenge(pcHandle, pcKind, pcEmail, pcCodeHash, pnExpires)
		@oDb.ExecWith("INSERT OR REPLACE INTO authchallenges (handle, kind, email, codehash, expires) " +
		              "VALUES (?, ?, ?, ?, ?)",
		              [ "" + pcHandle, "" + pcKind, "" + pcEmail, "" + pcCodeHash,
		                ring_number(pnExpires) ])

	# Returns the challenge held under a handle.
	#
	#   pcHandle   the lookup key
	#   returns    a hashlist [ :kind, :email, :codehash, :expires ], or an empty list when the
	#              handle is unknown
	#   see        PutChallenge, DeleteChallenge
	def Challenge(pcHandle)
		_r_ = @oDb.RowsWith("SELECT kind, email, codehash, expires FROM authchallenges WHERE handle = ?",
		                    [ "" + pcHandle ])
		if len(_r_) = 0
			return []
		ok
		return [ :kind = "" + _r_[1][1], :email = "" + _r_[1][2],
		         :codehash = "" + _r_[1][3], :expires = ring_number(_r_[1][4]) ]

	# Removes the challenge held under a handle, which spends it; an unknown handle changes nothing.
	#
	#   pcHandle   the lookup key
	#   returns    nothing
	#   see        PutChallenge, Challenge
	def DeleteChallenge(pcHandle)
		@oDb.ExecWith("DELETE FROM authchallenges WHERE handle = ?", [ "" + pcHandle ])

	# Stores a passkey credential with its owner, its public key and its signature counter, replacing the credential of the same id.
	#
	#   pcCredId   the credential id
	#   pcUser     the user that owns it
	#   pcKty      the key type
	#   pcK1       the first part of the public key
	#   pcK2       the second part of the public key
	#   pnCount    the signature counter
	#   returns    nothing
	#   see        Passkey, PasskeysOf, SetPasskeyCounter
	#@ aka  -- passkeys (WebAuthn credentials) ---------------------------------
	def PutPasskey(pcCredId, pcUser, pcKty, pcK1, pcK2, pnCount)
		@oDb.ExecWith("INSERT OR REPLACE INTO authpasskeys (credid, usr, kty, k1, k2, signcount) " +
		              "VALUES (?, ?, ?, ?, ?, ?)",
		              [ "" + pcCredId, "" + pcUser, "" + pcKty, "" + pcK1, "" + pcK2,
		                ring_number(pnCount) ])

	# Returns one passkey credential.
	#
	#   pcCredId   the credential id
	#   returns    a hashlist [ :credentialid, :user, :keytype, :key1, :key2, :signcount ], or an
	#              empty list when the id is unknown
	#   see        PutPasskey, PasskeysOf
	def Passkey(pcCredId)
		_r_ = @oDb.RowsWith("SELECT usr, kty, k1, k2, signcount FROM authpasskeys WHERE credid = ?",
		                    [ "" + pcCredId ])
		if len(_r_) = 0
			return []
		ok
		return [ :credentialId = "" + pcCredId, :user = "" + _r_[1][1], :keyType = "" + _r_[1][2],
		         :key1 = "" + _r_[1][3], :key2 = "" + _r_[1][4], :signCount = ring_number(_r_[1][5]) ]

	# Returns the passkey credentials of one user, one per enrolled device.
	#
	#   pcUser     the user name
	#   returns    a list of passkey hashlists; an empty list when the user has none
	#   see        Passkey, PutPasskey
	def PasskeysOf(pcUser)
		_rows_ = @oDb.RowsWith("SELECT credid, usr, kty, k1, k2, signcount FROM authpasskeys WHERE usr = ?",
		                       [ "" + pcUser ])
		_out_ = []
		_n_ = len(_rows_)
		for _i_ = 1 to _n_
			_out_ + [ :credentialId = "" + _rows_[_i_][1], :user = "" + _rows_[_i_][2],
			          :keyType = "" + _rows_[_i_][3], :key1 = "" + _rows_[_i_][4],
			          :key2 = "" + _rows_[_i_][5], :signCount = ring_number(_rows_[_i_][6]) ]
		next
		return _out_

	# Sets the signature counter of a passkey; an unknown id changes nothing.
	#
	#   pcCredId   the credential id
	#   pnCount    the new counter
	#   returns    nothing
	#   see        Passkey, PutPasskey
	def SetPasskeyCounter(pcCredId, pnCount)
		@oDb.ExecWith("UPDATE authpasskeys SET signcount = ? WHERE credid = ?",
		              [ ring_number(pnCount), "" + pcCredId ])

	# Removes one passkey credential; an unknown id changes nothing.
	#
	#   pcCredId   the credential id
	#   returns    nothing
	#   see        DeleteUserPasskeys, PutPasskey
	def DeletePasskey(pcCredId)
		@oDb.ExecWith("DELETE FROM authpasskeys WHERE credid = ?", [ "" + pcCredId ])

	# Removes every passkey credential of a user.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        DeletePasskey, PasskeysOf
	def DeleteUserPasskeys(pcUser)
		@oDb.ExecWith("DELETE FROM authpasskeys WHERE usr = ?", [ "" + pcUser ])

	# Locks a user until someone unlocks them, recording the reason and the time; a lock already held is replaced.
	#
	#   pcUser     the user to lock
	#   pcReason   the reason, as text
	#   pnAt       the time of the lock, in seconds
	#   returns    nothing; the lock is kept
	#   note       a lock stays until DeleteLock, unlike a failure lockout that expires
	#   see        LockOf, DeleteLock
	#@ aka  -- administrative locks (containment) -------------------------------
	def PutLock(pcUser, pcReason, pnAt)
		@oDb.ExecWith("INSERT OR REPLACE INTO authlocks (usr, reason, lockedat) VALUES (?, ?, ?)",
		              [ "" + pcUser, "" + pcReason, ring_number("" + pnAt) ])

	# Lifts the lock of a user; a user with no lock changes nothing.
	#
	#   pcUser     the user to unlock
	#   returns    nothing
	#   see        PutLock, LockOf
	def DeleteLock(pcUser)
		@oDb.ExecWith("DELETE FROM authlocks WHERE usr = ?", [ "" + pcUser ])

	# Returns the lock of a user, as a hashlist of its reason and its time.
	#
	#   pcUser     the user to look up
	#   returns    a hashlist [ :reason, :at ], or an empty list when the user is not locked
	#   see        PutLock, DeleteLock
	def LockOf(pcUser)
		_r_ = @oDb.RowsWith("SELECT reason, lockedat FROM authlocks WHERE usr = ?", [ "" + pcUser ])
		if len(_r_) = 0
			return []
		ok
		return [ :reason = "" + _r_[1][1], :at = ring_number(_r_[1][2]) ]

	# Gives a user a role; granting a role the user already has changes nothing.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    nothing
	#   see        RevokeRole, HasRole, RolesOf
	#@ aka  -- authz roles (the authn->authz bridge) ---------------------------
	def GrantRole(pcUser, pcRole)
		@oDb.ExecWith("INSERT OR IGNORE INTO authroles (usr, role) VALUES (?, ?)",
		              [ "" + pcUser, "" + pcRole ])

	# Takes one role away from a user; a role the user lacks changes nothing.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    nothing
	#   see        GrantRole, DeleteUserRoles
	def RevokeRole(pcUser, pcRole)
		@oDb.ExecWith("DELETE FROM authroles WHERE usr = ? AND role = ?", [ "" + pcUser, "" + pcRole ])

	# TRUE if the user holds that role.
	#
	#   pcUser     the user name
	#   pcRole     the role name
	#   returns    TRUE or FALSE
	#   see        GrantRole, RolesOf
	def HasRole(pcUser, pcRole)
		return ring_number(@oDb.ValueWith("SELECT COUNT(*) FROM authroles WHERE usr = ? AND role = ?",
		       [ "" + pcUser, "" + pcRole ])) > 0

	# Returns the roles of a user.
	#
	#   pcUser     the user name
	#   returns    a list of text; an empty list when the user has none
	#   see        GrantRole, HasRole
	def RolesOf(pcUser)
		_r_ = @oDb.RowsWith("SELECT role FROM authroles WHERE usr = ?", [ "" + pcUser ])
		_out_ = []
		_n_ = len(_r_)
		for _i_ = 1 to _n_
			_out_ + ("" + _r_[_i_][1])
		next
		return _out_

	# Takes every role away from a user.
	#
	#   pcUser     the user name
	#   returns    nothing
	#   see        RevokeRole, RolesOf
	def DeleteUserRoles(pcUser)
		@oDb.ExecWith("DELETE FROM authroles WHERE usr = ?", [ "" + pcUser ])

	  #-- internals -------------------------------------------------------

	# a SELECT row [ usr, expires, created, ip, ua, lastseen ] + token -> the
	# session record hashlist.
	def _Rec(pcToken, paRow)
		return [ :token = "" + pcToken, :user = "" + paRow[1],
		         :expires = ring_number(paRow[2]), :created = ring_number(paRow[3]),
		         :ip = "" + paRow[4], :ua = "" + paRow[5], :lastseen = ring_number(paRow[6]) ]

	# rows of [ token, usr, expires, created, ip, ua, lastseen ] -> records.
	def _RowsToRecs(paRows)
		_out_ = []
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			_out_ + This._Rec("" + paRows[_i_][1], [ paRows[_i_][2], paRows[_i_][3],
			         paRows[_i_][4], paRows[_i_][5], paRows[_i_][6], paRows[_i_][7] ])
		next
		return _out_

	# recovery-hash list <-> one comma-joined column. A hash is "salt:hash" (hex
	# only), so a comma can never occur inside one. (The comma was chosen when
	# stzDatabase.Rows split on tab/newline; rows now arrive as lists, but a
	# stored column keeps its format.)
	def _JoinHashes(paHashes)
		_out_ = ""
		_n_ = len(paHashes)
		for _i_ = 1 to _n_
			if _i_ > 1
				_out_ += ","
			ok
			_out_ += "" + paHashes[_i_]
		next
		return _out_

	def _SplitHashes(pcJoined)
		if ring_trim("" + pcJoined) = ""
			return []
		ok
		_parts_ = StzSplit("" + pcJoined, ",")
		_out_ = []
		_n_ = len(_parts_)
		for _i_ = 1 to _n_
			if ring_trim("" + _parts_[_i_]) != ""
				_out_ + _parts_[_i_]
			ok
		next
		return _out_
