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

class stzAuthMemoryStore from stzObject

	@aUsers      = []  # [ [ user, hash ], ... ]
	@aSessions   = []  # [ [ token, user, expiresAt ], ... ]
	@a2fa        = []  # [ [ user, secretB32, confirmed(0/1), [ recoveryHash, ... ] ], ... ]
	@aChallenges = []  # [ [ handle, kind, email, codehash, expiresAt ], ... ]
	@aPasskeys   = []  # [ [ credId, user, kty, k1, k2, signCount ], ... ]
	@aRoles      = []  # [ [ user, role ], ... ] -- the authz grants

	def init()
		@aUsers      = []
		@aSessions   = []
		@a2fa        = []
		@aChallenges = []
		@aPasskeys   = []
		@aRoles      = []

	  #-- users -----------------------------------------------------------

	def PutUser(pcUser, pcHash)
		_u_ = "" + pcUser
		_i_ = This._UserIndex(_u_)
		if _i_ > 0
			@aUsers[_i_][2] = "" + pcHash
		else
			@aUsers + [ _u_, "" + pcHash ]
		ok

	def UserHash(pcUser)
		_i_ = This._UserIndex("" + pcUser)
		if _i_ = 0
			return ""
		ok
		return @aUsers[_i_][2]

	def HasUser(pcUser)
		return This._UserIndex("" + pcUser) > 0

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

	def CountUsers()
		return len(@aUsers)

	  #-- sessions --------------------------------------------------------
	#
	# A session is a RECORD: [ :token, :user, :expires, :created, :ip, :ua,
	# :lastseen ] -- so a "your devices" view can list them, and idle timeout has
	# a lastseen to compare. paRec (to PutSession) carries everything but :token.

	def PutSession(pcToken, paRec)
		@aSessions + [ :token = "" + pcToken, :user = paRec[:user],
		               :expires = paRec[:expires], :created = paRec[:created],
		               :ip = paRec[:ip], :ua = paRec[:ua], :lastseen = paRec[:lastseen] ]

	# the full record (with :token) or [] when the token is unknown.
	def Session(pcToken)
		_t_ = "" + pcToken
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][:token] = _t_
				return @aSessions[_i_]
			ok
		next
		return []

	# update a session's last-seen stamp (idle-timeout sliding window). Rebuilds
	# the row rather than mutating a hashlist field in place (that INSERTS a key).
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

	def CountSessions()
		return len(@aSessions)

	# all session records -- for purge / enumeration.
	def Sessions()
		return @aSessions

	# the records belonging to one user.
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

	  #-- two-factor (TOTP) ----------------------------------------------
	#
	# One row per user with 2FA: the base32 secret, a confirmed flag (a secret is
	# stored unconfirmed at enrollment and only enforced once the user proves a
	# first code), and the list of one-time recovery-code HASHES (never plaintext).

	def PutTotp(pcUser, pcSecret, pnConfirmed, paHashes)
		_u_ = "" + pcUser
		_i_ = This._TotpIndex(_u_)
		_rec_ = [ _u_, "" + pcSecret, pnConfirmed, paHashes ]
		if _i_ > 0
			@a2fa[_i_] = _rec_
		else
			@a2fa + _rec_
		ok

	def Totp(pcUser)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ = 0
			return []
		ok
		_r_ = @a2fa[_i_]
		return [ :secret = _r_[2], :confirmed = _r_[3], :recovery = _r_[4] ]

	def SetTotpConfirmed(pcUser, pnConfirmed)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ > 0
			@a2fa[_i_][3] = pnConfirmed
		ok

	def SetTotpRecovery(pcUser, paHashes)
		_i_ = This._TotpIndex("" + pcUser)
		if _i_ > 0
			@a2fa[_i_][4] = paHashes
		ok

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

	  #-- passwordless challenges (magic-link / email-OTP) ----------------
	#
	# A short-lived, one-time challenge. handle = the lookup key (for magic-link,
	# sha256 of the emailed token so the raw token is never stored; for email-OTP,
	# "otp:"+email so a new request replaces the pending one). codehash is empty for
	# magic-link (the token IS the secret) and a salted hash of the code for OTP.

	def PutChallenge(pcHandle, pcKind, pcEmail, pcCodeHash, pnExpires)
		_h_ = "" + pcHandle
		_i_ = This._ChallengeIndex(_h_)
		_rec_ = [ _h_, "" + pcKind, "" + pcEmail, "" + pcCodeHash, pnExpires ]
		if _i_ > 0
			@aChallenges[_i_] = _rec_
		else
			@aChallenges + _rec_
		ok

	def Challenge(pcHandle)
		_i_ = This._ChallengeIndex("" + pcHandle)
		if _i_ = 0
			return []
		ok
		_r_ = @aChallenges[_i_]
		return [ :kind = _r_[2], :email = _r_[3], :codehash = _r_[4], :expires = _r_[5] ]

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

	  #-- authz roles (the authn->authz bridge) ---------------------------
	#
	# Per-user role GRANTS (durable). The role DEFINITIONS -- what capabilities a
	# role carries -- are app config held by stzAuth, not stored here.

	def GrantRole(pcUser, pcRole)
		_u_ = "" + pcUser
		_r_ = "" + pcRole
		if NOT This.HasRole(_u_, _r_)
			@aRoles + [ _u_, _r_ ]
		ok

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

	  #-- passkeys (WebAuthn credentials) ---------------------------------
	#
	# One row per CREDENTIAL, keyed by its id: a user may enroll several devices,
	# and each carries its own public key and signature counter.

	def PutPasskey(pcCredId, pcUser, pcKty, pcK1, pcK2, pnCount)
		_c_ = "" + pcCredId
		_i_ = This._PasskeyIndex(_c_)
		_rec_ = [ _c_, "" + pcUser, "" + pcKty, "" + pcK1, "" + pcK2, pnCount ]
		if _i_ > 0
			@aPasskeys[_i_] = _rec_
		else
			@aPasskeys + _rec_
		ok

	def Passkey(pcCredId)
		_i_ = This._PasskeyIndex("" + pcCredId)
		if _i_ = 0
			return []
		ok
		_r_ = @aPasskeys[_i_]
		return [ :credentialId = _r_[1], :user = _r_[2], :keyType = _r_[3],
		         :key1 = _r_[4], :key2 = _r_[5], :signCount = _r_[6] ]

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

	def SetPasskeyCounter(pcCredId, pnCount)
		_i_ = This._PasskeyIndex("" + pcCredId)
		if _i_ > 0
			@aPasskeys[_i_][6] = pnCount
		ok

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

class stzAuthDbStore from stzObject

	@oDb = ""

	# pcPath = a file path (durable) or ":memory:" (a real sqlite, but process-
	# local). The tables are created on first use.
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

	def DatabaseQ()
		return @oDb

	  #-- users -----------------------------------------------------------

	def PutUser(pcUser, pcHash)
		@oDb.Exec("INSERT OR REPLACE INTO authusers (usr, hash) VALUES ('" +
		          This._Esc(pcUser) + "', '" + This._Esc(pcHash) + "')")

	def UserHash(pcUser)
		_r_ = @oDb.Rows("SELECT hash FROM authusers WHERE usr = '" + This._Esc(pcUser) + "'")
		if len(_r_) = 0
			return ""
		ok
		return "" + _r_[1][1]

	def HasUser(pcUser)
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authusers WHERE usr = '" +
		       This._Esc(pcUser) + "'")) > 0

	def DeleteUser(pcUser)
		@oDb.Exec("DELETE FROM authusers WHERE usr = '" + This._Esc(pcUser) + "'")

	def CountUsers()
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authusers"))

	  #-- sessions --------------------------------------------------------

	def PutSession(pcToken, paRec)
		@oDb.Exec("INSERT OR REPLACE INTO authsessions (token, usr, expires, created, ip, ua, lastseen) VALUES ('" +
		          This._Esc(pcToken) + "', '" + This._Esc(paRec[:user]) + "', " +
		          ring_number(paRec[:expires]) + ", " + ring_number(paRec[:created]) + ", '" +
		          This._Esc(paRec[:ip]) + "', '" + This._Esc(paRec[:ua]) + "', " +
		          ring_number(paRec[:lastseen]) + ")")

	def Session(pcToken)
		_r_ = @oDb.Rows("SELECT usr, expires, created, ip, ua, lastseen FROM authsessions WHERE token = '" +
		                This._Esc(pcToken) + "'")
		if len(_r_) = 0
			return []
		ok
		return This._Rec("" + pcToken, _r_[1])

	def TouchSession(pcToken, pnLastSeen)
		@oDb.Exec("UPDATE authsessions SET lastseen = " + ring_number(pnLastSeen) +
		          " WHERE token = '" + This._Esc(pcToken) + "'")

	def DeleteSession(pcToken)
		@oDb.Exec("DELETE FROM authsessions WHERE token = '" + This._Esc(pcToken) + "'")

	def DeleteUserSessions(pcUser)
		@oDb.Exec("DELETE FROM authsessions WHERE usr = '" + This._Esc(pcUser) + "'")

	def CountSessions()
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authsessions"))

	def Sessions()
		return This._RowsToRecs(@oDb.Rows("SELECT token, usr, expires, created, ip, ua, lastseen FROM authsessions"))

	def SessionsOf(pcUser)
		return This._RowsToRecs(@oDb.Rows("SELECT token, usr, expires, created, ip, ua, lastseen FROM authsessions WHERE usr = '" +
		       This._Esc(pcUser) + "'"))

	  #-- two-factor (TOTP) ----------------------------------------------
	#
	# Recovery-code hashes are stored newline-joined in one TEXT column -- a hash
	# is "salt:hash" (hex only), so a newline can never occur inside one.

	def PutTotp(pcUser, pcSecret, pnConfirmed, paHashes)
		@oDb.Exec("INSERT OR REPLACE INTO auth2fa (usr, secret, confirmed, recovery) VALUES ('" +
		          This._Esc(pcUser) + "', '" + This._Esc(pcSecret) + "', " +
		          ring_number(pnConfirmed) + ", '" + This._Esc(This._JoinHashes(paHashes)) + "')")

	def Totp(pcUser)
		_r_ = @oDb.Rows("SELECT secret, confirmed, recovery FROM auth2fa WHERE usr = '" +
		                This._Esc(pcUser) + "'")
		if len(_r_) = 0
			return []
		ok
		return [ :secret = "" + _r_[1][1], :confirmed = ring_number(_r_[1][2]),
		         :recovery = This._SplitHashes("" + _r_[1][3]) ]

	def SetTotpConfirmed(pcUser, pnConfirmed)
		@oDb.Exec("UPDATE auth2fa SET confirmed = " + ring_number(pnConfirmed) +
		          " WHERE usr = '" + This._Esc(pcUser) + "'")

	def SetTotpRecovery(pcUser, paHashes)
		@oDb.Exec("UPDATE auth2fa SET recovery = '" + This._Esc(This._JoinHashes(paHashes)) +
		          "' WHERE usr = '" + This._Esc(pcUser) + "'")

	def DeleteTotp(pcUser)
		@oDb.Exec("DELETE FROM auth2fa WHERE usr = '" + This._Esc(pcUser) + "'")

	  #-- passwordless challenges (magic-link / email-OTP) ----------------

	def PutChallenge(pcHandle, pcKind, pcEmail, pcCodeHash, pnExpires)
		@oDb.Exec("INSERT OR REPLACE INTO authchallenges (handle, kind, email, codehash, expires) VALUES ('" +
		          This._Esc(pcHandle) + "', '" + This._Esc(pcKind) + "', '" + This._Esc(pcEmail) + "', '" +
		          This._Esc(pcCodeHash) + "', " + ring_number(pnExpires) + ")")

	def Challenge(pcHandle)
		_r_ = @oDb.Rows("SELECT kind, email, codehash, expires FROM authchallenges WHERE handle = '" +
		                This._Esc(pcHandle) + "'")
		if len(_r_) = 0
			return []
		ok
		return [ :kind = "" + _r_[1][1], :email = "" + _r_[1][2],
		         :codehash = "" + _r_[1][3], :expires = ring_number(_r_[1][4]) ]

	def DeleteChallenge(pcHandle)
		@oDb.Exec("DELETE FROM authchallenges WHERE handle = '" + This._Esc(pcHandle) + "'")

	  #-- passkeys (WebAuthn credentials) ---------------------------------

	def PutPasskey(pcCredId, pcUser, pcKty, pcK1, pcK2, pnCount)
		@oDb.Exec("INSERT OR REPLACE INTO authpasskeys (credid, usr, kty, k1, k2, signcount) VALUES ('" +
		          This._Esc(pcCredId) + "', '" + This._Esc(pcUser) + "', '" + This._Esc(pcKty) +
		          "', '" + This._Esc(pcK1) + "', '" + This._Esc(pcK2) + "', " + ring_number(pnCount) + ")")

	def Passkey(pcCredId)
		_r_ = @oDb.Rows("SELECT usr, kty, k1, k2, signcount FROM authpasskeys WHERE credid = '" +
		                This._Esc(pcCredId) + "'")
		if len(_r_) = 0
			return []
		ok
		return [ :credentialId = "" + pcCredId, :user = "" + _r_[1][1], :keyType = "" + _r_[1][2],
		         :key1 = "" + _r_[1][3], :key2 = "" + _r_[1][4], :signCount = ring_number(_r_[1][5]) ]

	def PasskeysOf(pcUser)
		_rows_ = @oDb.Rows("SELECT credid, usr, kty, k1, k2, signcount FROM authpasskeys WHERE usr = '" +
		         This._Esc(pcUser) + "'")
		_out_ = []
		_n_ = len(_rows_)
		for _i_ = 1 to _n_
			_out_ + [ :credentialId = "" + _rows_[_i_][1], :user = "" + _rows_[_i_][2],
			          :keyType = "" + _rows_[_i_][3], :key1 = "" + _rows_[_i_][4],
			          :key2 = "" + _rows_[_i_][5], :signCount = ring_number(_rows_[_i_][6]) ]
		next
		return _out_

	def SetPasskeyCounter(pcCredId, pnCount)
		@oDb.Exec("UPDATE authpasskeys SET signcount = " + ring_number(pnCount) +
		          " WHERE credid = '" + This._Esc(pcCredId) + "'")

	def DeletePasskey(pcCredId)
		@oDb.Exec("DELETE FROM authpasskeys WHERE credid = '" + This._Esc(pcCredId) + "'")

	def DeleteUserPasskeys(pcUser)
		@oDb.Exec("DELETE FROM authpasskeys WHERE usr = '" + This._Esc(pcUser) + "'")

	  #-- authz roles (the authn->authz bridge) ---------------------------

	def GrantRole(pcUser, pcRole)
		@oDb.Exec("INSERT OR IGNORE INTO authroles (usr, role) VALUES ('" +
		          This._Esc(pcUser) + "', '" + This._Esc(pcRole) + "')")

	def RevokeRole(pcUser, pcRole)
		@oDb.Exec("DELETE FROM authroles WHERE usr = '" + This._Esc(pcUser) +
		          "' AND role = '" + This._Esc(pcRole) + "'")

	def HasRole(pcUser, pcRole)
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authroles WHERE usr = '" +
		       This._Esc(pcUser) + "' AND role = '" + This._Esc(pcRole) + "'")) > 0

	def RolesOf(pcUser)
		_r_ = @oDb.Rows("SELECT role FROM authroles WHERE usr = '" + This._Esc(pcUser) + "'")
		_out_ = []
		_n_ = len(_r_)
		for _i_ = 1 to _n_
			_out_ + ("" + _r_[_i_][1])
		next
		return _out_

	def DeleteUserRoles(pcUser)
		@oDb.Exec("DELETE FROM authroles WHERE usr = '" + This._Esc(pcUser) + "'")

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

	# SQL-escape: single quotes doubled. Usernames are user input; hashes/tokens
	# are our own controlled values, but escaped anyway for one safe path.
	def _Esc(pcVal)
		return StzReplace("" + pcVal, "'", "''")

	# recovery-hash list <-> one comma-joined column. A hash is "salt:hash" (hex
	# only), so a comma can never occur inside one. Comma -- NOT newline/tab, which
	# stzDatabase.Rows uses as its row/column delimiters and would corrupt the read.
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
