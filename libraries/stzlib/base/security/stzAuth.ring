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

	@aUsers    = []    # [ [ user, passwordHash ], ... ]
	@aSessions = []    # [ [ token, user ], ... ]

	def init()
		@aUsers    = []
		@aSessions = []

	  #-- the credential store --------------------------------------------

	# register a user with a password -- stores ONLY the salted hash.
	def Register(pcUser, pcPassword)
		_u_ = ring_trim("" + pcUser)
		if _u_ = ""
			StzRaise("stzAuth.Register: a user name is required.")
		ok
		if This._IndexOfUser(_u_) > 0
			StzRaise("stzAuth.Register: user '" + _u_ + "' already exists.")
		ok
		@aUsers + [ _u_, StzHashSecret("" + pcPassword) ]
		return This

	def IsRegistered(pcUser)
		return This._IndexOfUser(ring_trim("" + pcUser)) > 0

	def NumberOfUsers()
		return len(@aUsers)

	# change a password (the current one must be presented). TRUE on success.
	def ChangePassword(pcUser, pcOld, pcNew)
		_i_ = This._IndexOfUser(ring_trim("" + pcUser))
		if _i_ = 0 or NOT StzVerifySecret("" + pcOld, @aUsers[_i_][2])
			return FALSE
		ok
		@aUsers[_i_][2] = StzHashSecret("" + pcNew)
		return TRUE

	# remove a user (and end any of their sessions).
	def Unregister(pcUser)
		_u_ = ring_trim("" + pcUser)
		@aUsers    = This._Without(@aUsers, _u_, 1)
		@aSessions = This._Without(@aSessions, _u_, 2)
		return This

	  #-- authentication + sessions ---------------------------------------

	# verify a user's password. TRUE/FALSE -- no session side effect.
	def Authenticate(pcUser, pcPassword)
		_i_ = This._IndexOfUser(ring_trim("" + pcUser))
		if _i_ = 0
			return FALSE
		ok
		return StzVerifySecret("" + pcPassword, @aUsers[_i_][2])

	# authenticate AND, on success, open a session -> returns an opaque token
	# ("" on failure).
	def Login(pcUser, pcPassword)
		if NOT This.Authenticate(pcUser, pcPassword)
			return ""
		ok
		_tok_ = StzEngineCryptoRandomHex(32)
		@aSessions + [ _tok_, ring_trim("" + pcUser) ]
		return _tok_

	# the user behind a live session token, or "" if unknown / ended.
	def UserOfSession(pcToken)
		_t_ = "" + pcToken
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][1] = _t_
				return @aSessions[_i_][2]
			ok
		next
		return ""

	def IsValidSession(pcToken)
		return This.UserOfSession(pcToken) != ""

	def NumberOfSessions()
		return len(@aSessions)

	def Logout(pcToken)
		_t_ = "" + pcToken
		_aNew_ = []
		_n_ = len(@aSessions)
		for _i_ = 1 to _n_
			if @aSessions[_i_][1] != _t_
				_aNew_ + @aSessions[_i_]
			ok
		next
		@aSessions = _aNew_
		return This

	def Show()
		? "Auth store: " + len(@aUsers) + " user(s), " + len(@aSessions) + " live session(s)"

	  #-- internals -------------------------------------------------------

	def _IndexOfUser(pcUser)
		_n_ = len(@aUsers)
		for _i_ = 1 to _n_
			if @aUsers[_i_][1] = pcUser
				return _i_
			ok
		next
		return 0

	# a copy of paList without rows whose column nCol equals pcVal.
	def _Without(paList, pcVal, nCol)
		_aNew_ = []
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_][nCol] != pcVal
				_aNew_ + paList[_i_]
			ok
		next
		return _aNew_
