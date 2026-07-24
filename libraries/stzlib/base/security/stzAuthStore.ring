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

	@aUsers    = []    # [ [ user, hash ], ... ]
	@aSessions = []    # [ [ token, user, expiresAt ], ... ]

	def init()
		@aUsers    = []
		@aSessions = []

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

	def PutSession(pcToken, pcUser, pnExpiresAt)
		@aSessions + [ "" + pcToken, "" + pcUser, pnExpiresAt ]

	# [ user, expiresAt ] or [] when the token is unknown.
	def Session(pcToken)
		_t_ = "" + pcToken
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][1] = _t_
				return [ @aSessions[_i_][2], @aSessions[_i_][3] ]
			ok
		next
		return []

	def DeleteSession(pcToken)
		_t_ = "" + pcToken
		_aNew_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][1] != _t_
				_aNew_ + @aSessions[_i_]
			ok
		next
		@aSessions = _aNew_

	def DeleteUserSessions(pcUser)
		_u_ = "" + pcUser
		_aNew_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][2] != _u_
				_aNew_ + @aSessions[_i_]
			ok
		next
		@aSessions = _aNew_

	def CountSessions()
		return len(@aSessions)

	# [ [ token, user, expiresAt ], ... ] -- for purge / enumeration.
	def Sessions()
		return @aSessions

	  #-- internals -------------------------------------------------------

	def _UserIndex(pcUser)
		_n_ = len(@aUsers)
		for _i_ = 1 to _n_
			if @aUsers[_i_][1] = pcUser
				return _i_
			ok
		next
		return 0


  #=========================================================#
 #  SQLITE STORE -- durable, over stzDatabase                #
#=========================================================#

class stzAuthDbStore from stzObject

	@oDb = NULL

	# pcPath = a file path (durable) or ":memory:" (a real sqlite, but process-
	# local). The tables are created on first use.
	def init(pcPath)
		@oDb = new stzDatabase("" + pcPath)
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authusers (usr TEXT PRIMARY KEY, hash TEXT)")
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authsessions (token TEXT PRIMARY KEY, usr TEXT, expires INTEGER)")

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

	def PutSession(pcToken, pcUser, pnExpiresAt)
		@oDb.Exec("INSERT OR REPLACE INTO authsessions (token, usr, expires) VALUES ('" +
		          This._Esc(pcToken) + "', '" + This._Esc(pcUser) + "', " +
		          ring_number(pnExpiresAt) + ")")

	def Session(pcToken)
		_r_ = @oDb.Rows("SELECT usr, expires FROM authsessions WHERE token = '" +
		                This._Esc(pcToken) + "'")
		if len(_r_) = 0
			return []
		ok
		return [ "" + _r_[1][1], ring_number(_r_[1][2]) ]

	def DeleteSession(pcToken)
		@oDb.Exec("DELETE FROM authsessions WHERE token = '" + This._Esc(pcToken) + "'")

	def DeleteUserSessions(pcUser)
		@oDb.Exec("DELETE FROM authsessions WHERE usr = '" + This._Esc(pcUser) + "'")

	def CountSessions()
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM authsessions"))

	def Sessions()
		_out_ = []
		_r_ = @oDb.Rows("SELECT token, usr, expires FROM authsessions")
		_n_ = len(_r_)
		for _i_ = 1 to _n_
			_out_ + [ "" + _r_[_i_][1], "" + _r_[_i_][2], ring_number(_r_[_i_][3]) ]
		next
		return _out_

	  #-- internals -------------------------------------------------------

	# SQL-escape: single quotes doubled. Usernames are user input; hashes/tokens
	# are our own controlled values, but escaped anyway for one safe path.
	def _Esc(pcVal)
		return StzReplace("" + pcVal, "'", "''")
