#--------------------------------------------------------------#
#     SOFTANZA LIBRARY (V0.9) - STZEXPOSURERESPONDER           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# The hour is spent with the door shut -- SOFTANZA_ONE_HOUR.md, B5 (rung W6).
#
# An advisory matched (stzAdvisoryFeed) says a component we run is exposed.
# A patch takes hours to days; refusing the path to the component takes a
# call. This responder never patches: it SHUTS A DOOR and writes
# exposure.closed with the advisory id as origin, which is the moment
# StzTimeToSafe measures against the one-hour budget.
#
# A door here is a check that runs BEFORE the effect, in the one place every
# path to it passes:
#
#   :listener   StzNoteListener -- every Listen/Start in the library calls it
#               before the socket opens. Shut by class, or "*" for all.
#   :exposed    the same door, refusing only a bind beyond loopback: the
#               narrowest shut, a local service keeps running.
#   :fetch      stzHttpClient._Perform -- the client's one request path (curl,
#               nghttp2, mbedTLS behind it). Shut by host, or "*" for all.
#   :model      the model-call doors of the neural and image planes. Shut by
#               model file or architecture, or "*" for all.
#   :secret     a secret in a stzSecretStore, revoked through the store.
#
# A refused effect raises after writing capability.refused with the
# advisory id as origin, so the ledger shows the door doing its work.
#
# What it does NOT do, said so nobody reads it in:
#   * an engine domain cannot be unloaded in a running process: its DLL is
#     loaded at load time and the VM holds its functions. An advisory that
#     reaches a domain with no door above maps to :none, and the responder
#     writes NOTHING closed -- the hour is then not closed, and the report
#     says so (W7's load-on-need manifest is where a domain deny can live);
#   * a listener ALREADY open stays open: the door refuses new binds, and
#     StillOpen() names the sockets whose owner must stop them;
#   * the model doors sit where the record is written, after the model ran:
#     a shut model withholds the answer, it does not prevent the run
#     (routed to stzlib-intelligence to move the check before the run).

# the shut doors: [ [ kind, name, advisoryId, how ], ... ]
$aStzShutDoors = []

# THE DOOR CHECK: every governed door calls this before its effect. Raises,
# after recording the refusal, when a shut door covers the effect.
#
#   pcKind    listener, exposed, fetch or model
#   pcName    the class, host, or model the effect reaches
#   pcActor   the class at the door
#   pbBeyondLoopback   for a listener: 1 when the bind is reachable from another machine
func StzDoorCheck(pcKind, pcName, pcActor, pbBeyondLoopback)
	_n_ = len($aStzShutDoors)
	if _n_ = 0  return  ok
	_cName_ = StzLower("" + pcName)
	for _i_ = 1 to _n_
		_r_ = $aStzShutDoors[_i_]
		_bHit_ = 0
		if _r_[1] = pcKind and (_r_[2] = "*" or _r_[2] = _cName_)
			_bHit_ = 1
		ok
		if pcKind = "listener" and _r_[1] = "exposed" and pbBeyondLoopback = 1 and (_r_[2] = "*" or _r_[2] = _cName_)
			_bHit_ = 1
		ok
		if _bHit_ = 1
			StzNoteRefusalFrom("capability.refused", "" + pcActor, "" + pcName,
				"door shut by stzExposureResponder (" + _r_[1] + " " + _r_[2] + "): " + _r_[4], _r_[3])
			stzraise("" + pcActor + ": the " + pcKind + " door to " + pcName + " is shut while advisory " + _r_[3] +
				" is open (" + _r_[4] + ") -- see StzShutDoors()")
		ok
	next

func StzShutDoors()
	return $aStzShutDoors

func StzNumberOfShutDoors()
	return len($aStzShutDoors)

# Opens every door, without a record: for a guard's setup only. A program
# reopens through stzExposureResponder.Reopen, which writes exposure.reopened.
func StzForgetShutDoors()
	$aStzShutDoors = []

# The host of a URL, lowercased: http://Example.org:8080/x -> example.org
func StzUrlHost(pcUrl)
	_c_ = StzLower("" + pcUrl)
	_k_ = StzFindFirst("://", _c_)
	if _k_ > 0  _c_ = StzRight(_c_, len(_c_) - _k_ - 2)  ok
	_k_ = StzFindFirst("/", _c_)
	if _k_ > 0  _c_ = StzLeft(_c_, _k_ - 1)  ok
	_k_ = StzFindFirst("@", _c_)
	if _k_ > 0  _c_ = StzRight(_c_, len(_c_) - _k_)  ok
	if StzLeft(_c_, 1) = "["
		_k_ = StzFindFirst("]", _c_)
		if _k_ > 0  return StzLeft(_c_, _k_)  ok
	ok
	_k_ = StzFindFirst(":", _c_)
	if _k_ > 0  _c_ = StzLeft(_c_, _k_ - 1)  ok
	return _c_

func StzExposureResponderQ()
	return new stzExposureResponder()


  #========================#
 #  STZEXPOSURERESPONDER  #
#========================#

# Shuts the door to an exposed component while its patch is built, and records the moment in the ledger.
#
# Each Shut method adds a door to the process's shut list and writes exposure.closed with the advisory
# id as origin. Respond reads a feed's matches and shuts, for each, the doors its reach table names;
# a component that no in-process door reaches is reported, and nothing closed is written for it.
#
#   receiver   o1 = new stzExposureResponder()
#   example    o1.ShutFetch("TEST-2026-0002", "*", "curl advisory: no outbound HTTP until rebuilt")
#              ? StzNumberOfShutDoors()
#              #--> 1
#              o1.Reopen("TEST-2026-0002")
#              ? StzNumberOfShutDoors()
#              #--> 0
#   see        stzAdvisoryFeed, StzTimeToSafe, StzDoorCheck
class stzExposureResponder from stzObject

	@aReach   = []    # [ [ component, kind, name ], ... ] -- what a component's advisory shuts
	@aActions = []    # the last Respond: [ [ advisoryId, component, kind, name, closed ], ... ]

	# Builds a responder holding the default reach table of what each vendored library and engine domain reaches.
	#
	#   returns    nothing; the object is built
	#   see        SetReach, Reach
	def init()
		This._DefaultReach()

	  #-- shutting, one door at a time ------------------------------------------#

	# Refuses every new listener of a class (or "*" for all), whatever its address.
	#
	#   pcAdvisoryId   the advisory the shut answers; the ledger chains by it
	#   pcClass        stzTcpServer, stzWebSocketServer, stzReactor.http ... or *
	#   pcHow          one line a reader of the ledger needs: why, and until what
	#   returns        the responder, so calls chain
	def ShutListeners(pcAdvisoryId, pcClass, pcHow)
		return This._Shut("listener", pcClass, pcAdvisoryId, pcHow)

	# Refuses every new listener bound beyond loopback; a loopback bind still opens.
	#
	#   note       the narrowest shut: the service keeps running for this machine while no other can reach it
	def ShutExposedListeners(pcAdvisoryId, pcClass, pcHow)
		return This._Shut("exposed", pcClass, pcAdvisoryId, pcHow)

	# Refuses every outbound HTTP request to a host (or "*" for all) through stzHttpClient.
	def ShutFetch(pcAdvisoryId, pcHost, pcHow)
		return This._Shut("fetch", pcHost, pcAdvisoryId, pcHow)

	# Refuses the answer of every call to a model (file or architecture, or "*") at the model doors.
	#
	#   warning    the door runs after the model did: the answer is withheld, the run is not prevented
	def ShutModel(pcAdvisoryId, pcModel, pcHow)
		return This._Shut("model", pcModel, pcAdvisoryId, pcHow)

	# Revokes a secret in a store -- the capability that reaches the exposed component.
	#
	#   poStore    the stzSecretStore holding it
	#   pcName     the secret's name in the store
	#   note       Revoke wipes a value the store generated; the revocation is the store's, the record is ours
	def RevokeSecret(pcAdvisoryId, poStore, pcName, pcHow)
		poStore.Revoke(pcName)
		StzNoteExposureClosed(pcAdvisoryId, "secret:" + pcName, "secret revoked: " + pcHow)
		return This

	# Opens every door an advisory shut, and records it: after guard.green, or when the advisory was wrong.
	#
	#   returns    the number of doors opened
	def Reopen(pcAdvisoryId)
		_aKeep_ = []
		_nOpened_ = 0
		_n_ = len($aStzShutDoors)
		for _i_ = 1 to _n_
			_r_ = $aStzShutDoors[_i_]
			if _r_[3] = "" + pcAdvisoryId
				_nOpened_++
				StzNoteFactFrom("exposure.reopened", "stzExposureResponder", _r_[1] + " " + _r_[2],
					"door opened", "" + pcAdvisoryId)
			else
				_aKeep_ + _r_
			ok
		next
		$aStzShutDoors = _aKeep_
		return _nOpened_

	  #-- the reach table ---------------------------------------------------------#

	# Says which door an advisory on a component shuts. A program adds what it knows about itself.
	#
	#   pcComponent   the component as the exposure spells it: curl, stz_http, a model file
	#   pcKind        listener, exposed, fetch, model -- or none, to say no in-process door reaches it
	#   pcName        the door's name: a class, a host, a model, or *
	#   returns       the responder, so calls chain
	def SetReach(pcComponent, pcKind, pcName)
		@aReach + [ StzLower("" + pcComponent), "" + pcKind, StzLower("" + pcName) ]
		return This

	# Returns the reach table: which doors an advisory on each component shuts, as [ component, kind, name ] rows.
	#
	#   returns    a list of rows in lower case; the kind none says no in-process door reaches that component
	#   see        SetReach, DoorsFor
	def Reach()
		return @aReach

	# Returns the doors an advisory on a component shuts, as rows [ kind, name ]; [] when none is known.
	def DoorsFor(pcComponent)
		_c_ = StzLower("" + pcComponent)
		_a_ = []
		_n_ = len(@aReach)
		for _i_ = 1 to _n_
			if @aReach[_i_][1] = _c_ and @aReach[_i_][2] != "none"
				_a_ + [ @aReach[_i_][2], @aReach[_i_][3] ]
			ok
		next
		return _a_

	  #-- responding to a feed ----------------------------------------------------#

	# Shuts, for every match of a feed, the doors its reach table names, and writes exposure.closed for each.
	#
	#   poFeed     a stzAdvisoryFeed after Match
	#   returns    the number of matches whose door was shut
	#   note       a model file matched by name shuts that model's door even with no table row; a match no door
	#              reaches is in Unreached(), with nothing closed written -- the hour is not claimed for it
	#   see        Actions, Unreached, StzTimeToSafe
	def Respond(poFeed)
		@aActions = []
		_nClosed_ = 0
		_aM_ = poFeed.Matches()
		_n_ = len(_aM_)
		for _i_ = 1 to _n_
			_cId_ = _aM_[_i_][1]
			_cComp_ = _aM_[_i_][2]
			_aD_ = This.DoorsFor(_cComp_)
			if len(_aD_) = 0 and _aM_[_i_][3] = "present"
				_aD_ = [ [ "model", _cComp_ ] ]      # a model file: its own door
			ok
			if len(_aD_) = 0
				@aActions + [ _cId_, _cComp_, "none", "", 0 ]
				loop
			ok
			_nD_ = len(_aD_)
			for _j_ = 1 to _nD_
				This._Shut(_aD_[_j_][1], _aD_[_j_][2], _cId_, "advisory on " + _cComp_ + " (" + _aM_[_i_][3] + ")")
				@aActions + [ _cId_, _cComp_, _aD_[_j_][1], _aD_[_j_][2], 1 ]
			next
			_nClosed_++
		next
		return _nClosed_

	# Returns what the last Respond did, as [ advisoryId, component, kind, name, closed ] rows.
	#
	#   returns    a list of rows, [] before any Respond; closed is 1 when a door was shut and 0 when no door
	#              reaches the component (kind none)
	#   see        Respond, Unreached
	def Actions()
		return @aActions

	# Returns the matches no in-process door reaches, as rows [ advisoryId, component ]: a person acts on these.
	def Unreached()
		_a_ = []
		_n_ = len(@aActions)
		for _i_ = 1 to _n_
			if @aActions[_i_][5] = 0  _a_ + [ @aActions[_i_][1], @aActions[_i_][2] ]  ok
		next
		return _a_

	# Returns the listeners already open that a shut door now covers, as rows [ class, host, port, loopback ].
	#
	#   note       the door refuses new binds only; these sockets are stopped by their owner
	def StillOpen()
		_a_ = []
		_aL_ = StzListeners()
		_nL_ = len(_aL_)
		_nS_ = len($aStzShutDoors)
		for _i_ = 1 to _nL_
			_cC_ = StzLower(_aL_[_i_][1])
			for _j_ = 1 to _nS_
				_r_ = $aStzShutDoors[_j_]
				if (_r_[2] = "*" or _r_[2] = _cC_) and
				   (_r_[1] = "listener" or (_r_[1] = "exposed" and _aL_[_i_][4] = 0))
					_a_ + _aL_[_i_]
					exit
				ok
			next
		next
		return _a_

	  #-- internals ---------------------------------------------------------------

	def _Shut(pcKind, pcName, pcAdvisoryId, pcHow)
		if NOT StzSecurityLedgerIsOpen()  StzOpenSecurityLedger(4096)  ok
		_cName_ = StzLower("" + pcName)
		# one row per door and advisory: shutting twice records once
		_n_ = len($aStzShutDoors)
		for _i_ = 1 to _n_
			_r_ = $aStzShutDoors[_i_]
			if _r_[1] = pcKind and _r_[2] = _cName_ and _r_[3] = "" + pcAdvisoryId
				return This
			ok
		next
		$aStzShutDoors + [ pcKind, _cName_, "" + pcAdvisoryId, "" + pcHow ]
		StzNoteExposureClosed(pcAdvisoryId, pcKind + " " + _cName_, pcKind + " door shut: " + pcHow)
		return This

	# What an advisory on each vendored library and engine domain reaches, read
	# from what links it (engine/build.zig, 2026-11-05) and which door every
	# path passes: curl is linked by stz_http and stz_reactor, libuv by
	# stz_reactor, mbedTLS by stz_ws, stz_reactor and stz_crypto, zlib by
	# stz_ws among others. A path no door governs is not covered -- mbedTLS's
	# hashing in stz_crypto stays reachable under a mbedtls shut -- and a
	# library with no door at all is said to be none, not left out: Respond
	# then reports it instead of guessing.
	def _DefaultReach()
		@aReach = [
			[ "curl",        "fetch",   "*" ],
			[ "nghttp2",     "fetch",   "*" ],
			[ "mbedtls",     "fetch",   "*" ],
			[ "mbedtls",     "exposed", "*" ],
			[ "libuv",       "exposed", "*" ],
			[ "ggml",        "model",   "*" ],
			[ "stz_http",    "fetch",   "*" ],
			[ "stz_tcp",     "exposed", "*" ],
			[ "stz_reactor", "fetch",   "*" ],
			[ "stz_ws",      "exposed", "*" ],
			[ "stz_reactor", "exposed", "*" ],
			[ "stz_neural",  "model",   "*" ],
			[ "stz_image",   "model",   "*" ],
			[ "zlib",        "exposed", "stzwebsocketserver" ],
			[ "sqlite",      "none",    "" ],
			[ "pcre2",       "none",    "" ],
			[ "stb",         "none",    "" ],
			[ "libwebp",     "none",    "" ],
			[ "quirc",       "none",    "" ]
		]
