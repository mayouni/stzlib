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
		@oDb.Exec("CREATE TABLE IF NOT EXISTS authsessions (token TEXT PRIMARY KEY, " +
		          "usr TEXT, expires INTEGER, created INTEGER, ip TEXT, ua TEXT, lastseen INTEGER)")

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
