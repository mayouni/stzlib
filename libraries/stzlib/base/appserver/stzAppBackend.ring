#======================================================#
#  STZAPPBACKEND - LIVE CROSS-PART STATE               #
#======================================================#

/*--- The solution's parts stop being islands (2026-07-23)

stzAppTopology gives each part a ROLE over a named DATASET -- but those
datasets are STATIC in-memory lists. An order "created" on the phone
never reaches the admin's dashboard: each part reads its own frozen
copy of the model. The emulator can only ever render a rehearsal.

stzAppBackend closes that gap. It is the solution's LIVE backend: it
owns the shared state, serves it over a REAL running stzAppServer, and
lets every part read and write it over REAL HTTP. What one part writes,
another part sees -- because there is now exactly one copy of the state
and it lives outside them both.

	oB = new stzAppBackend("restolean", oTopology)
	oB.Start(0)                                     # ephemeral port

	oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
	? oB.Dashboard(:admin)[2]                       # the total INCLUDES it

	oB.Stop()

WHY SQLITE IS THE SUBSTRATE (the load-bearing design choice). Ring copies
objects on `=`, so shared state held in a Ring attribute fragments into
private copies -- the trap that killed the stzLog object sink and forced
stzSecretStore's by-reference reveal. A stzDatabase is immune: its sqlite
connection is an ENGINE HANDLE, so a copied wrapper still addresses the
SAME database. Putting the live state in sqlite means the copy trap
cannot fragment it, no matter how many parts, servers, or handlers hold a
wrapper. The MODEL (the topology) is copied on purpose -- it is a static
snapshot; only the STATE has to be shared.

ONE PROCESS, BOTH ENDS. A second stzReactor plays the parts' HTTP client:
SubmitTcp (non-blocking) -> ServeOne -> AwaitTcp. So a round trip is
genuinely over the loopback -- framed HTTP, the MBaaS floor, real sqlite
-- with no deadlock and no public network. Offline by construction, the
same discipline the reactor guard uses.

TWO MODES, ONE API (location transparency -- the point of the remote work):

	# LOCAL: this process owns the state and serves it to itself
	oB.Start(0)

	# REMOTE: the state lives in ANOTHER PROCESS (or another host)
	oB.ConnectTo("127.0.0.1", 8080)

	# ...and from here the part code is IDENTICAL either way
	oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
	? oB.Dashboard(:admin)[2]

The difference is confined to _Roundtrip. LOCAL pumps its own server between
submit and await, because nothing else will. REMOTE must NOT pump: the far
process runs its own loop, so the client is a plain curl-backed HTTP request
(SubmitHttp/AwaitHttp) that blocks on the wire. Pumping a server you do not
own is precisely the bug this seam exists to avoid.

HOSTING ONE. SpawnRemote() serialises the model to a file, generates a host
script (an absolute stzBase load, so the child's cwd cannot matter -- the
lesson the cluster's generated worker already encodes), and launches a real
`ring` child process that Start()s the backend and Serve()s until its TTL.
The parts then ConnectTo() it over real TCP. Nothing is simulated: two OS
processes, one socket, one sqlite.

REMOTE LIMITS, stated honestly: the curl client submits GET and POST only, so
the remote surface is Create/Rows/RowCount/Dashboard -- the part-facing API --
not the MBaaS PUT/DELETE item routes. State lives in the HOST process, so a
remote backend's sqlite is not visible to the connecting process except
through HTTP, which is the entire point.

GOVERNED LIKE EVERY OTHER CROSSING. A cross-part WRITE is an effect, so
it obeys the library's one rule: expression is free, admission is
governed. Bind an actor with SetActor (SetActorQ to chain) and only an effectful actor may
commit -- an LLMActor can read the whole solution and write none of it.
Reads are sensing and stay open. Every crossing is recorded in Traffic(),
so who-wrote-what-across-parts is auditable the way stzSecretStore audits
reveals.

SCOPE SIGILS: attributes are @-prefixed and method temps are _x_ wrapped
(bare class-head attributes capture same-named user globals in Ring 1.27).
*/

func StzAppBackendQ(pcName, poTopology)
	return new stzAppBackend(pcName, poTopology)

# This machine's first ROUTABLE IPv4 address -- where a backend bound to
# 0.0.0.0 is actually reachable from another host. A 0.0.0.0 bind answers on
# every interface but is not an address you can dial, so something has to name
# the routable one.
#
# BEST-EFFORT AND HONEST ABOUT IT: it asks the OS (ipconfig on Windows,
# `hostname -I` elsewhere) and takes the first non-loopback IPv4 it finds. A
# machine with several NICs may have a different one in mind, so a caller that
# cares should pass the address explicitly to ConnectTo()/ReachAt(). Falls back
# to 127.0.0.1 when nothing routable is found, which keeps a laptop with no
# network from failing outright -- it just cannot be reached from elsewhere.
func StzLanIpv4()
	_cOut_ = ""
	try
		_oS_ = new stzSystemCall("ipconfig")
		_oS_.Run()
		_cOut_ = _oS_.Output()
	catch
		_cOut_ = ""
	done
	# Emptiness is a BYTE-length test, not ring_trim: ipconfig's UTF-16 buffer is
	# all NUL-interleaved, and ring_trim(that) is "" even though it holds 900+
	# bytes -- trimming it would fire the fallback and clobber the good output.
	if len(_cOut_) = 0
		try
			_oS2_ = new stzSystemCall("hostname -I")
			_oS2_.Run()
			_cOut_ = _oS2_.Output()
		catch
			_cOut_ = ""
		done
	ok
	# Windows ipconfig emits UTF-16 -- NUL-interleaved bytes. Those NULs MUST be
	# stripped with Ring BYTE ops here: handing the raw buffer to the engine (via
	# StzReplace/StzSplit) fails its utf-8 validation and the whole string comes
	# back EMPTY (the binary-through-a-text-boundary trap). So sanitise to a
	# digits-and-dots token stream with substr/ascii, THEN it is safe.
	_cClean_ = ""
	_nB_ = len("" + _cOut_)
	for _i_ = 1 to _nB_
		_b_ = substr("" + _cOut_, _i_, 1)
		_nA_ = ascii(_b_)
		if (_nA_ >= ascii("0") and _nA_ <= ascii("9")) or _b_ = "."
			_cClean_ += _b_
		else
			_cClean_ += " "     # every non-address byte becomes a separator
		ok
	next
	_a_ = StzSplit(_cClean_, " ")
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_c_ = ring_trim(_a_[_i_])
		if _StzLooksIpv4(_c_) and StzLeft(_c_, 4) != "127." and StzLeft(_c_, 8) != "169.254."
			return _c_
		ok
	next
	return "127.0.0.1"

# four dot-separated numeric groups -- enough to pick an address out of
# command output without pulling a regex in for it
func _StzLooksIpv4(pcTok)
	_a_ = StzSplit("" + pcTok, ".")
	if len(_a_) != 4
		return FALSE
	ok
	for _i_ = 1 to 4
		_c_ = _a_[_i_]
		if _c_ = "" or NOT StzIsDigit(_c_)
			return FALSE
		ok
	next
	return TRUE

  #==========================================================#
 #  MODEL FILE: escaping + the loader a host process uses    #
#==========================================================#

# Percent-escaping, so a cell may contain the record separator, a newline, or
# anything else. DECODE ORDER MATTERS: "%25" is decoded LAST. After encoding,
# every "%" in the output begins a real escape triple, and steps 1-3 emit no
# "%" of their own -- so an escaped percent can never be re-read as an escape.
# (Decoding it first is the classic multi-pass bug that double-decoded HTML
# entities in this same library.)

func _StzModelEsc(pValue)
	_c_ = "" + pValue
	_c_ = StzReplace(_c_, "%", "%25")
	_c_ = StzReplace(_c_, "|", "%7C")
	_c_ = StzReplace(_c_, char(10), "%0A")
	_c_ = StzReplace(_c_, char(13), "%0D")
	return _c_

func _StzModelUnesc(pValue)
	_c_ = "" + pValue
	_c_ = StzReplace(_c_, "%7C", "|")
	_c_ = StzReplace(_c_, "%0A", char(10))
	_c_ = StzReplace(_c_, "%0D", char(13))
	_c_ = StzReplace(_c_, "%25", "%")
	return _c_

# Rebuild a stzAppTopology from the file SaveModelTo() wrote. This is what the
# generated host script calls, so a backend PROCESS serves the very model the
# parts were written against.
func StzLoadAppTopologyFrom(pcPath)
	_cRaw_ = read(pcPath)
	_aLines_ = StzSplit(_cRaw_, char(10))
	_cName_ = "hosted"
	_aDs_ = []       # [ [ name, [ rows ] ], ... ]
	_aCols_ = []     # [ [ name, [ cols ] ], ... ]
	_aRoles_ = []    # [ [ part, role, dataset ], ... ]
	_nL_ = len(_aLines_)
	for _i_ = 1 to _nL_
		_cL_ = ring_trim(_aLines_[_i_])
		if _cL_ = ""
			loop
		ok
		_f_ = StzSplit(_cL_, "|")
		if len(_f_) < 2
			loop
		ok
		if _f_[1] = "N"
			_cName_ = _StzModelUnesc(_f_[2])

		but _f_[1] = "C"
			_c_ = []
			_nF_ = len(_f_)
			for _j_ = 3 to _nF_
				_c_ + _StzModelUnesc(_f_[_j_])
			next
			_aCols_ + [ _StzModelUnesc(_f_[2]), _c_ ]

		but _f_[1] = "R"
			_row_ = []
			_nF_ = len(_f_)
			_j_ = 3
			while _j_ + 1 <= _nF_
				_v_ = _StzModelUnesc(_f_[_j_ + 1])
				if _f_[_j_] = "n"
					_row_ + ring_number(_v_)
				else
					_row_ + _v_
				ok
				_j_ += 2
			end
			_cDs_ = _StzModelUnesc(_f_[2])
			_nIdx_ = 0
			_nD_ = len(_aDs_)
			for _j_ = 1 to _nD_
				if _aDs_[_j_][1] = _cDs_
					_nIdx_ = _j_
					exit
				ok
			next
			if _nIdx_ = 0
				_aDs_ + [ _cDs_, [ _row_ ] ]
			else
				_aDs_[_nIdx_][2] + _row_
			ok

		but _f_[1] = "P" and len(_f_) >= 4
			_aRoles_ + [ _StzModelUnesc(_f_[2]), _StzModelUnesc(_f_[3]),
			             _StzModelUnesc(_f_[4]) ]
		ok
	next

	_oT_ = new stzAppTopology(_cName_)
	# a dataset declared with columns but no rows must still exist as a table
	_nC_ = len(_aCols_)
	for _i_ = 1 to _nC_
		_nIdx_ = 0
		_nD_ = len(_aDs_)
		for _j_ = 1 to _nD_
			if _aDs_[_j_][1] = _aCols_[_i_][1]
				_nIdx_ = _j_
				exit
			ok
		next
		if _nIdx_ = 0
			_aDs_ + [ _aCols_[_i_][1], [] ]
		ok
	next
	_nD_ = len(_aDs_)
	for _i_ = 1 to _nD_
		_oT_.AddDataset(_aDs_[_i_][1], _aDs_[_i_][2])
	next
	for _i_ = 1 to _nC_
		_oT_.SetDatasetColumns(_aCols_[_i_][1], _aCols_[_i_][2])
	next
	_nR_ = len(_aRoles_)
	for _i_ = 1 to _nR_
		_oT_.SetPartRole(_aRoles_[_i_][1], _aRoles_[_i_][2], _aRoles_[_i_][3])
	next
	return _oT_

class stzAppBackend from stzObject

	@cName = ""
	@oTopology = NULL      # the MODEL -- a snapshot copy, deliberately
	@oDb = NULL            # the LIVE state (engine handle: copy-proof)
	@oServer = NULL        # the running host
	@oClient = NULL        # a second reactor: the parts' HTTP client
	@bRunning = FALSE
	@nPort = 0
	@aTraffic = []         # [ [ part, verb, dataset, status ], ... ]
	@oActor = NULL
	@bGoverned = FALSE

	# -- remote mode --
	@bRemote = FALSE       # TRUE = a client onto a backend in another process
	@cHost = "127.0.0.1"
	@cBindHost = ""        # the interface a HOST-mode backend bound
	@cSignKeyId = ""       # shared-secret identity for the crossing
	@cSignSecret = ""
	@nMaxSkewMs = 30000
	@nLastStatus = 0       # the status of the last crossing, either mode
	@cModelPath = ""       # where SpawnRemote wrote the model
	@cHostScript = ""      # the generated host script
	@nSpawnJob = 0         # the child process job on @oClient

	def init(pcName, poTopology)
		@cName = "" + pcName
		@oTopology = poTopology
		@aTraffic = []

	  #--------------------#
	 #  BACKEND LIFECYCLE  #
	#--------------------#

	# Materialise every dataset of the model as a real sqlite table (seeded
	# with the model's rows), expose each for REST CRUD, and bind the host.
	# nPortNum 0 = ephemeral. After this, the state is LIVE: it no longer
	# lives in the model, it lives in the database the parts share.
	def Start(pnPortNum)
		return This.StartOn("127.0.0.1", pnPortNum)

	# Bind a CHOSEN interface, so a backend can be reached from another MACHINE:
	#   StartOn("127.0.0.1", p)  loopback -- this process and its children only
	#   StartOn("0.0.0.0",   p)  every interface -- reachable across the network
	#   StartOn("10.0.0.7",  p)  one specific NIC
	#
	# LEAVING THE LOOPBACK REQUIRES A KEY. On 127.0.0.1 the callers are this
	# machine; on a real interface they are whoever can route to the port, and an
	# unauthenticated MBaaS floor would take a POST from any of them. So a
	# non-loopback bind without SetSigningKey() is REFUSED here rather than
	# quietly exposed -- governed by construction, not by a later audit finding.
	def StartOn(pcHostAddr, pnPortNum)
		if @bRunning
			stzraise("stzAppBackend '" + @cName + "' is already live on port " + @nPort)
		ok
		_cH_ = ring_trim("" + pcHostAddr)
		if _cH_ = ""
			_cH_ = "127.0.0.1"
		ok
		if NOT This._IsLoopback(_cH_) and @cSignKeyId = ""
			stzraise("stzAppBackend '" + @cName + "' refuses to bind " + _cH_ +
			         " unauthenticated -- a backend that leaves the loopback is reachable " +
			         "by anything that can route to it. Call SetSigningKey(id, secret) first.")
		ok
		@oDb = new stzDatabase(":memory:")
		@oServer = new stzAppServer()
		_aNames_ = @oTopology.DatasetNames()
		_n_ = len(_aNames_)
		for _i_ = 1 to _n_
			This._Materialise(_aNames_[_i_])
			@oServer.Expose(@oDb, _aNames_[_i_])
		next
		@oServer.Start(pnPortNum, _cH_)
		if @cSignKeyId != ""
			@oServer.RequireSignedRequests(This._NewSigner(), @nMaxSkewMs)
		ok
		@cBindHost = _cH_
		@nPort = @oServer.Port()
		@oClient = new stzReactor()
		@bRunning = TRUE
		return This

	# The interface this backend is bound to (host mode).
	def BindHost()
		return @cBindHost

	def _IsLoopback(pcHost)
		_c_ = StzLower(ring_trim("" + pcHost))
		return _c_ = "127.0.0.1" or _c_ = "localhost" or _c_ = "::1"

	# Serve the backend to whoever connects, for nMs. This is what a HOSTING
	# process runs after Start(): the loop that answers remote parts. (A local
	# backend never needs it -- it pumps one event per crossing instead.)
	def Serve(pnMs)
		This._RequireLive("Serve")
		if @bRemote
			stzraise("stzAppBackend.Serve() is for the HOST process -- a connected client has nothing to serve.")
		ok
		@oServer.RunFor(pnMs)
		return This

	  #-----------------------------------------#
	 #  REMOTE MODE: a backend in another host  #
	#-----------------------------------------#

	# Attach to a backend ALREADY RUNNING somewhere else. No database and no
	# server are created here -- this object becomes a pure client, and every
	# part-scoped call below goes over the wire instead of over the loopback.
	def ConnectTo(pcHostAddr, pnPortNum)
		if @bRunning
			stzraise("stzAppBackend '" + @cName + "' is already live -- Stop() before connecting elsewhere.")
		ok
		@cHost = "" + pcHostAddr
		@nPort = pnPortNum
		@bRemote = TRUE
		@oClient = new stzReactor()
		@bRunning = TRUE
		return This

	# The shared secret that authenticates the crossing. Set it on BOTH sides:
	# the HOST uses it to require a signature, the CLIENT to produce one. It is
	# the same secret, so this one call serves both roles -- which is also why a
	# real deployment must deliver it out of band (env, vault, stzSecretStore),
	# never in the model file or the command line.
	def SetSigningKey(pcKeyId, pcSecret)
		This.SetSigningKeyQ(pcKeyId, pcSecret)

	def SetSigningKeyQ(pcKeyId, pcSecret)
		if ring_trim("" + pcKeyId) = "" or ring_trim("" + pcSecret) = ""
			stzraise("stzAppBackend.SetSigningKey: both a key id and a secret are required.")
		ok
		@cSignKeyId = "" + pcKeyId
		@cSignSecret = "" + pcSecret
		return This

	def IsSigned()
		return @cSignKeyId != ""

	def SetMaxSkew(pnMs)
		This.SetMaxSkewQ(pnMs)

	def SetMaxSkewQ(pnMs)
		if pnMs < 1
			stzraise("stzAppBackend.SetMaxSkew: the freshness window must be >= 1ms.")
		ok
		@nMaxSkewMs = pnMs
		return This

	# A signer carrying this backend's key. Built fresh per role: the host's
	# verifier and the client's signer are separate ledgers by design (in the
	# real topology they are separate processes).
	def _NewSigner()
		_oS_ = new stzRequestSigner("backend-" + @cName)
		_oS_.AddKey(@cSignKeyId, @cSignSecret)
		return _oS_

	# The envelope, as query parameters appended to a path.
	def _AuthQuery(pcMethod, pcPath, pcBody)
		if @cSignKeyId = ""
			return ""
		ok
		_oS_ = This._NewSigner()
		_aEnv_ = _oS_.SignNow(@cSignKeyId, pcMethod, pcPath, pcBody)
		_c_ = "_kid=" + _aEnv_[:kid] + "&_ts=" + _aEnv_[:ts] +
		      "&_nonce=" + _aEnv_[:nonce] + "&_sig=" + _aEnv_[:sig]
		if StzFindFirst("?", pcPath) > 0
			return "&" + _c_
		ok
		return "?" + _c_

	# The HTTP status of the last crossing, either mode (0 = it never completed).
	# 401 here means the far side refused the signature.
	def LastStatus()
		return @nLastStatus

	def IsRemote()
		return @bRemote

	def Endpoint()
		return @cHost + ":" + @nPort

	# Is the far backend actually answering? (stzAppServer serves /health with
	# no route declared, so this needs nothing from the model.)
	def IsReachable(pnTimeoutMs)
		if NOT @bRunning
			return FALSE
		ok
		if NOT @bRemote
			return TRUE
		ok
		# the probe is signed too -- this listener exempts nothing
		_cP_ = "/health" + This._AuthQuery("GET", "/health", "")
		_nJ_ = @oClient.SubmitHttp(0, "http://" + This.Endpoint() + _cP_, "")
		if _nJ_ < 1
			return FALSE
		ok
		@oClient.AwaitHttp(_nJ_, pnTimeoutMs)
		# JobState -2 = DRAINED. HttpLastStatus is a global that goes stale on a
		# timeout, so a status read without this check can report a prior 200.
		if @oClient.JobState(_nJ_) != -2
			return FALSE
		ok
		return @oClient.HttpLastStatus() = 200

	# Launch this model as a backend PROCESS of its own and return its endpoint.
	# The child gets the serialised model + port + TTL on its command line, and
	# self-terminates when the TTL expires (so a forgotten host cannot outlive
	# the run). The spawning reactor is owned by THIS object, so the child's
	# lifetime is tied to something the caller holds.
	def SpawnRemote(pnPortNum, pnTtlMs)
		return This.SpawnRemoteOn("127.0.0.1", pnPortNum, pnTtlMs)

	# Launch the host bound to a CHOSEN interface, so the spawned backend is
	# reachable from other machines rather than only from this one. The child
	# enforces the same leave-the-loopback-needs-a-key rule, because it runs the
	# very same StartOn().
	#
	# The secret is handed over in the ENVIRONMENT (STZ_BACKEND_SECRET), not in
	# argv -- see _GenerateHostScript.
	def SpawnRemoteOn(pcBindHost, pnPortNum, pnTtlMs)
		if @bRunning
			stzraise("stzAppBackend '" + @cName + "' is already live -- SpawnRemote() launches a separate host.")
		ok
		_cBind_ = ring_trim("" + pcBindHost)
		if _cBind_ = ""
			_cBind_ = "127.0.0.1"
		ok
		if NOT This._IsLoopback(_cBind_) and @cSignKeyId = ""
			stzraise("stzAppBackend '" + @cName + "' refuses to spawn a host on " + _cBind_ +
			         " unauthenticated -- call SetSigningKey(id, secret) first.")
		ok
		@cModelPath = This._ScratchPath("model")
		This.SaveModelTo(@cModelPath)
		This._GenerateHostScript()
		_cKid_ = "-"
		if @cSignKeyId != ""
			_cKid_ = @cSignKeyId
			sysset("STZ_BACKEND_SECRET", @cSignSecret)
		ok
		@oClient = new stzReactor()
		@nSpawnJob = @oClient.SubmitSpawn([ This._RingExecutable(), @cHostScript,
		                                    @cModelPath, "" + pnPortNum, "" + pnTtlMs,
		                                    _cBind_, _cKid_, "STZ_BACKEND_SECRET" ])
		# a 0.0.0.0 host is REACHED at a routable address, not at 0.0.0.0
		if _cBind_ = "0.0.0.0"
			@cHost = "127.0.0.1"
		else
			@cHost = _cBind_
		ok
		@cBindHost = _cBind_
		@nPort = pnPortNum
		return This.Endpoint()

	# The commands that would start this backend on a GENUINELY REMOTE machine,
	# returned for inspection BEFORE anything runs -- the same rehearse-then-
	# commit shape stzDeployment uses for its :Server backend. Generating them
	# needs no host; running them needs one reachable account, which is the only
	# infra-gated step in the whole remote story.
	#
	# THE SECRET IS NEVER IN THE COMMAND. argv is world-readable in the remote
	# process table, so the launch line only NAMES the environment variable; the
	# value must already be in the remote environment (deploy it from a vault or
	# stzSecretStore out of band). A backend that leaks its own key while
	# starting has authenticated nothing.
	def RemoteLaunchCommands(pcSshTarget, pcRemoteDir, pnPortNum, pnTtlMs)
		if @cSignKeyId = ""
			stzraise("stzAppBackend.RemoteLaunchCommands: a backend launched on another " +
			         "machine is off the loopback by definition -- call SetSigningKey(id, secret) first.")
		ok
		_cT_ = ring_trim("" + pcSshTarget)
		_cD_ = ring_trim("" + pcRemoteDir)
		if _cT_ = "" or _cD_ = ""
			stzraise("stzAppBackend.RemoteLaunchCommands: both an ssh target and a remote directory are required.")
		ok
		# materialise what has to travel
		@cModelPath = This._ScratchPath("model")
		This.SaveModelTo(@cModelPath)
		This._GenerateHostScript()
		_a_ = []
		_a_ + ("ssh " + _cT_ + " mkdir -p " + _cD_)
		_a_ + ("scp " + @cModelPath + " " + _cT_ + ":" + _cD_ + "/model")
		_a_ + ("scp " + @cHostScript + " " + _cT_ + ":" + _cD_ + "/host.ring")
		_a_ + ("ssh " + _cT_ + " ring " + _cD_ + "/host.ring " + _cD_ + "/model " +
		       pnPortNum + " " + pnTtlMs + " 0.0.0.0 " + @cSignKeyId + " STZ_BACKEND_SECRET")
		return _a_

	# A legible account of what a remote launch would do, and what it needs.
	def ExplainRemoteLaunch(pcSshTarget, pcRemoteDir, pnPortNum, pnTtlMs)
		_out_ = []
		_out_ + ("Remote launch of backend '" + @cName + "' on " + pcSshTarget)
		_out_ + ("  bind      : 0.0.0.0:" + pnPortNum + " (reachable from other machines)")
		_out_ + ("  auth      : signed crossings, key id '" + @cSignKeyId + "'")
		_out_ + ("  secret    : from the remote env var STZ_BACKEND_SECRET -- never in argv")
		_out_ + ("  lifetime  : self-terminates after " + pnTtlMs + "ms")
		_out_ + "  commands  :"
		_aC_ = This.RemoteLaunchCommands(pcSshTarget, pcRemoteDir, pnPortNum, pnTtlMs)
		_n_ = len(_aC_)
		for _i_ = 1 to _n_
			_out_ + ("    " + _i_ + ". " + _aC_[_i_])
		next
		_out_ + "  nothing has run yet -- these are the commands, not their effects"
		return _out_

	# Point this client at a different address for the SAME backend -- e.g. a
	# host bound to 0.0.0.0 that another machine reaches at a routable IP.
	def ReachAt(pcHostAddr)
		This.ReachAtQ(pcHostAddr)

	def ReachAtQ(pcHostAddr)
		@cHost = ring_trim("" + pcHostAddr)
		return This

	# Wait until the spawned host answers /health (it must load stzBase and bind
	# first). Returns TRUE once it does.
	def WaitReady(pnTimeoutMs)
		_nDeadline_ = StzEngineTimeNowMs() + pnTimeoutMs
		# the probe is a real client, so it needs the real key -- an unsigned
		# probe against a signed host is a 401, and WaitReady would wait out its
		# whole timeout on a backend that was up all along.
		_oProbe_ = new stzAppBackend(@cName, @oTopology)
		if @cSignKeyId != ""
			_oProbe_.SetSigningKey(@cSignKeyId, @cSignSecret)
		ok
		_oProbe_.ConnectTo(@cHost, @nPort)
		while StzEngineTimeNowMs() < _nDeadline_
			if _oProbe_.IsReachable(1000)
				_oProbe_.Stop()
				return TRUE
			ok
			_nT_ = @oClient.SubmitTimer(200)
			@oClient.AwaitTimer(_nT_, 500)
		end
		_oProbe_.Stop()
		return FALSE

	def Stop()
		if NOT @bRunning and @nSpawnJob = 0
			return This
		ok
		if @bRemote
			# a client owns no state -- only its reactor
			@oClient.Destroy()
			@oClient = NULL
			@bRemote = FALSE
			@bRunning = FALSE
			return This
		ok
		if @nSpawnJob != 0
			# a spawn manager: the child self-terminates on its TTL
			@oClient.Destroy()
			@oClient = NULL
			@nSpawnJob = 0
			return This
		ok
		@oServer.Stop()
		@oClient.Destroy()
		@oDb.Close()
		@oClient = NULL
		@bRunning = FALSE
		return This

	def IsLive()
		return @bRunning

	def Port()
		return @nPort

	def Name()
		return @cName

	  #-------------------------------------#
	 #  THE PARTS' VIEW OF THE LIVE STATE  #
	#-------------------------------------#

	# A part WRITES: a real HTTP POST to the running backend, which the MBaaS
	# floor turns into a sqlite INSERT. Returns TRUE on 201.
	# paFields: [ [ "dish", "Couscous" ], [ "qty", 2 ] ]
	def Create(pcPart, pcDataset, paFields)
		This._RequireLive("Create")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		if NOT This._MayCommit()
			@aTraffic + [ _p_, "POST", _ds_, 403 ]
			stzraise("stzAppBackend: part '" + _p_ + "' may not write '" + _ds_ +
			         "' -- the acting actor is not effectful (expression is free; admission is governed).")
		ok
		This._Roundtrip("POST", "/api/" + _ds_, This._FormBody(paFields))
		@aTraffic + [ _p_, "POST", _ds_, @nLastStatus ]
		return @nLastStatus = 201

	# A part READS: a real HTTP GET. Returns [ [ cell, cell ], ... ].
	def Rows(pcPart, pcDataset)
		This._RequireLive("Rows")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		_cResp_ = This._Roundtrip("GET", "/api/" + _ds_, "")
		@aTraffic + [ _p_, "GET", _ds_, @nLastStatus ]
		return This._ParseRowsJson(_cResp_)

	def RowCount(pcPart, pcDataset)
		This._RequireLive("RowCount")
		_p_ = StzLower(ring_trim("" + pcPart))
		_ds_ = StzLower(ring_trim("" + pcDataset))
		_cResp_ = This._Roundtrip("GET", "/api/" + _ds_ + "/count", "")
		@aTraffic + [ _p_, "GET", _ds_ + "/count", @nLastStatus ]
		return This._CountJson(_cResp_)

	# The part's dashboard, computed over LIVE rows fetched from the running
	# backend -- the SAME aggregation the static model runs (stzTable SumCol /
	# MaxColumn: the part's declared :PivotTable), but over state another part
	# may have written a moment ago. Returns [ rows, total, topDish, topRev ].
	def Dashboard(pcPart)
		This._RequireLive("Dashboard")
		_ds_ = @oTopology.DatasetNameOf(pcPart)
		if _ds_ = ""
			_ds_ = "orders"
		ok
		_aLive_ = This.Rows(pcPart, _ds_)
		# cells cross JSON as strings -- qty must be numeric for the sum.
		# ring_number(), never 0+str (that coercion is poisoned after a raise).
		_aOrders_ = []
		_n_ = len(_aLive_)
		for _i_ = 1 to _n_
			if len(_aLive_[_i_]) >= 2
				_aOrders_ + [ _aLive_[_i_][1], ring_number(_aLive_[_i_][2]) ]
			ok
		next
		return @oTopology.DashboardFromOrders(_aOrders_)

	  #---------------------------------#
	 #  GOVERNANCE + CROSS-PART AUDIT  #
	#---------------------------------#

	# Bind the acting actor: cross-part WRITES then require an effectful one
	# (an LLMActor reads the whole solution and commits none of it). Reads are
	# sensing and stay open. Unbound = ungoverned (dev).
	def SetActor(poActor)
		This.SetActorQ(poActor)

	def SetActorQ(poActor)
		@oActor = poActor
		@bGoverned = TRUE
		return This

	def IsGoverned()
		return @bGoverned

	# [ [ part, verb, dataset, status ], ... ] -- every crossing, in order.
	def Traffic()
		return @aTraffic

	def TrafficCount()
		return len(@aTraffic)

	# the crossings a given part made
	def TrafficOf(pcPart)
		_p_ = StzLower(ring_trim("" + pcPart))
		_out_ = []
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			if @aTraffic[_i_][1] = _p_
				_out_ + @aTraffic[_i_]
			ok
		next
		return _out_

	def RefusedCrossings()
		_out_ = []
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			if @aTraffic[_i_][4] = 403
				_out_ + @aTraffic[_i_]
			ok
		next
		return _out_

	# a legible account of the live backend (a list of lines, per the plane's
	# Explain() convention).
	def Explain()
		_out_ = []
		_out_ + ("Live backend '" + @cName + "' -- " + This._StateWord() +
		         ", port " + @nPort + ", " + len(@aTraffic) + " crossing(s)")
		if @bGoverned
			_out_ + ("  governed: writes require an effectful actor")
		ok
		_n_ = len(@aTraffic)
		for _i_ = 1 to _n_
			_out_ + ("  #" + _i_ + " " + @aTraffic[_i_][1] + " " + @aTraffic[_i_][2] +
			         " " + @aTraffic[_i_][3] + " -> " + @aTraffic[_i_][4])
		next
		return _out_

	def Show()
		_a_ = This.Explain()
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			? _a_[_i_]
		next
		return This

	  #-------------------------------------------#
	 #  MODEL SERIALISATION (for a host process)  #
	#-------------------------------------------#

	# Write the MODEL (never the state) so another process can rebuild it:
	#   N|<name>
	#   C|<dataset>|<col>|<col>...
	#   R|<dataset>|<n|s>|<cell>|<n|s>|<cell>...
	#   P|<part>|<role>|<dataset>
	#
	# Cells carry their TYPE (n/s) rather than being sniffed on the way back in:
	# a price must stay a NUMBER for the revenue maths, and "looks numeric" is
	# exactly how "007" silently becomes 7 -- a defect this library already paid
	# for once in the CSV reader. Fields are percent-escaped (see _StzModelEsc).
	def SaveModelTo(pcPath)
		_cNL_ = char(10)
		_cOut_ = "N|" + _StzModelEsc(@oTopology.Name()) + _cNL_
		_aNames_ = @oTopology.DatasetNames()
		_nD_ = len(_aNames_)
		for _i_ = 1 to _nD_
			_cDs_ = _aNames_[_i_]
			_aCols_ = @oTopology.ColumnsOf(_cDs_)
			_cLine_ = "C|" + _StzModelEsc(_cDs_)
			_nC_ = len(_aCols_)
			for _j_ = 1 to _nC_
				_cLine_ += ("|" + _StzModelEsc(_aCols_[_j_]))
			next
			_cOut_ += (_cLine_ + _cNL_)
			_aRows_ = @oTopology.Dataset(_cDs_)
			_nR_ = len(_aRows_)
			for _j_ = 1 to _nR_
				_cLine_ = "R|" + _StzModelEsc(_cDs_)
				_nW_ = len(_aRows_[_j_])
				for _k_ = 1 to _nW_
					if isNumber(_aRows_[_j_][_k_])
						_cLine_ += ("|n|" + _StzModelEsc(_aRows_[_j_][_k_]))
					else
						_cLine_ += ("|s|" + _StzModelEsc(_aRows_[_j_][_k_]))
					ok
				next
				_cOut_ += (_cLine_ + _cNL_)
			next
		next
		_aParts_ = @oTopology.PartNames()
		_nP_ = len(_aParts_)
		for _i_ = 1 to _nP_
			_cOut_ += ("P|" + _StzModelEsc(_aParts_[_i_]) + "|" +
			           _StzModelEsc(@oTopology.RoleOf(_aParts_[_i_])) + "|" +
			           _StzModelEsc(@oTopology.DatasetNameOf(_aParts_[_i_])) + _cNL_)
		next
		write(pcPath, _cOut_)
		return This

	  #--------------#
	 #  INTERNALS   #
	#--------------#

	# Generated, never shipped as a fixed file: the stzBase load must be an
	# ABSOLUTE literal so the child's working directory cannot matter (the
	# lesson the cluster's generated worker already encodes).
	#
	# THE HOST SCRIPT'S VARIABLES MUST NOT USE THE _x_ SIGIL. The sigil protects
	# class ATTRIBUTES from same-named user globals, but a SCRIPT global named
	# _n_ / _a_ / _i_ collides with the METHOD TEMPS of the very classes it
	# calls -- and the corruption is SILENT. A first cut used _a_/_n_ here, and
	# Start()'s `_n_ = len(_aNames_)` expose loop quietly did nothing: the child
	# bound its port and served /health perfectly while every /api route 404'd,
	# because no dataset had been exposed. Host-prefixed plain names cannot
	# collide with any method temp in the library.
	# The host entry, generated (not shipped) so the stzBase load is an absolute
	# literal whatever the child's cwd is -- the lesson the cluster's generated
	# worker already encodes.
	#
	# The BIND HOST and the KEY ID arrive as arguments; the SECRET arrives in the
	# environment variable named by argument 5, never on the command line -- an
	# argv is world-readable in the process table, and a shared secret in there
	# would undo the authentication it exists to provide.
	def _GenerateHostScript()
		@cHostScript = This._ScratchPath("host") + ".ring"
		_cNL_ = char(10)
		_cS_ = 'load "' + This._StzBasePath() + '"' + _cNL_ +
		       'hostArgv = sysargv' + _cNL_ +
		       'hostArgc = len(hostArgv)' + _cNL_ +
		       'hostSecEnv = hostArgv[hostArgc]' + _cNL_ +
		       'hostKeyId = hostArgv[hostArgc-1]' + _cNL_ +
		       'hostBind = hostArgv[hostArgc-2]' + _cNL_ +
		       'hostTtl = number(hostArgv[hostArgc-3])' + _cNL_ +
		       'hostPort = number(hostArgv[hostArgc-4])' + _cNL_ +
		       'hostModel = hostArgv[hostArgc-5]' + _cNL_ +
		       'hostTopo = StzLoadAppTopologyFrom(hostModel)' + _cNL_ +
		       'hostBack = new stzAppBackend(hostTopo.Name(), hostTopo)' + _cNL_ +
		       'if hostKeyId != "-"' + _cNL_ +
		       '    hostBack.SetSigningKey(hostKeyId, sysget(hostSecEnv))' + _cNL_ +
		       'ok' + _cNL_ +
		       'hostBack.StartOn(hostBind, hostPort)' + _cNL_ +
		       'hostBack.Serve(hostTtl)' + _cNL_ +
		       'hostBack.Stop()' + _cNL_
		write(@cHostScript, _cS_)
		return @cHostScript

	# Both generated files sit beside this module, dot-prefixed, exactly where
	# the cluster puts its generated worker.
	def _ScratchPath(pcTag)
		return $cEngineDir + "/../base/appserver/.stzbackend_" + pcTag + "_" + @cName

	def _StzBasePath()
		_nSlash_ = 0
		_nL_ = len($cEngineDir)
		for _i_ = 1 to _nL_
			if $cEngineDir[_i_] = "/"
				_nSlash_ = _i_
			ok
		next
		return StzLeft($cEngineDir, _nSlash_ - 1) + "/base/stzBase.ring"

	# The ring interpreter running US -- so the child is the same build.
	def _RingExecutable()
		_a_ = sysargv
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_c_ = StzLower("" + _a_[_i_])
			if StzFindFirst("ring.exe", _c_) > 0 or StzRight(_c_, 5) = "/ring" or _c_ = "ring"
				return "" + _a_[_i_]
			ok
		next
		return "ring"

	def _StateWord()
		if @bRunning
			return "live"
		ok
		return "stopped"

	def _RequireLive(pcWhat)
		if NOT @bRunning
			stzraise("stzAppBackend." + pcWhat + "() needs a live backend -- Start() first.")
		ok
		return TRUE

	def _MayCommit()
		if NOT @bGoverned
			return TRUE
		ok
		if @oActor = NULL
			return TRUE
		ok
		return @oActor.IsEffectful()

	# CREATE the dataset's table, then seed it with the model's rows: the
	# state STARTS from the model and lives on independently of it.
	def _Materialise(pcDataset)
		_cols_ = @oTopology.ColumnsOf(pcDataset)
		_nC_ = len(_cols_)
		if _nC_ = 0
			return FALSE
		ok
		_cDef_ = ""
		for _i_ = 1 to _nC_
			if _i_ > 1
				_cDef_ += ", "
			ok
			_cDef_ += ("" + _cols_[_i_] + " TEXT")
		next
		@oDb.Exec("CREATE TABLE " + pcDataset + "(" + _cDef_ + ")")
		_rows_ = @oTopology.Dataset(pcDataset)
		_nR_ = len(_rows_)
		for _i_ = 1 to _nR_
			This._Insert(pcDataset, _cols_, _rows_[_i_])
		next
		return TRUE

	def _Insert(pcTable, paCols, paRow)
		_nW_ = len(paRow)
		if _nW_ > len(paCols)
			_nW_ = len(paCols)
		ok
		if _nW_ = 0
			return FALSE
		ok
		_cC_ = ""
		_cV_ = ""
		for _i_ = 1 to _nW_
			if _i_ > 1
				_cC_ += ", "
				_cV_ += ", "
			ok
			_cC_ += ("" + paCols[_i_])
			_cV_ += ("'" + StzReplace("" + paRow[_i_], "'", "''") + "'")
		next
		@oDb.Exec("INSERT INTO " + pcTable + " (" + _cC_ + ") VALUES (" + _cV_ + ")")
		return TRUE

	# [ [ k, v ], ... ] -> "k=v&k=v"
	def _FormBody(paFields)
		_c_ = ""
		_n_ = len(paFields)
		for _i_ = 1 to _n_
			if _i_ > 1
				_c_ += "&"
			ok
			_c_ += ("" + paFields[_i_][1] + "=" + paFields[_i_][2])
		next
		return _c_

	# ONE real HTTP round trip. The ONLY place the two modes differ.
	#
	# LOCAL  : submit (non-blocking) -> pump our own server -> await. Nothing
	#          else would ever run the loop, so we must.
	# REMOTE : a plain curl request that blocks on the wire. We must NOT pump
	#          -- the far process runs its own loop, and ServeOne() here would
	#          be driving a server that is not the one answering.
	#
	# Sets @nLastStatus either way: locally from the raw status line, remotely
	# from HttpLastStatus guarded by a DRAIN check (that global goes stale on a
	# timeout, so an unguarded read can report a previous request's 200).
	def _Roundtrip(pcMethod, pcPath, pcBody)
		# sign BEFORE the envelope is appended: the signature covers the method,
		# the path as the far side will see it minus the envelope, and the body.
		_cPath_ = pcPath + This._AuthQuery(pcMethod, pcPath, pcBody)
		if @bRemote
			_nMethod_ = 0                                  # curl GET
			if pcMethod = "POST"  _nMethod_ = 1  ok        # curl POST
			_nJob_ = @oClient.SubmitHttp(_nMethod_, "http://" + This.Endpoint() + _cPath_, pcBody)
			if _nJob_ < 1
				@nLastStatus = 0
				return ""
			ok
			_cResp_ = @oClient.AwaitHttp(_nJob_, 5000)
			if @oClient.JobState(_nJob_) != -2
				@nLastStatus = 0                           # never completed
				return ""
			ok
			@nLastStatus = @oClient.HttpLastStatus()
			return _cResp_                                 # the BODY (no status line)
		ok
		_cCRLF_ = char(13) + char(10)
		_cReq_ = pcMethod + " " + _cPath_ + " HTTP/1.1" + _cCRLF_ + "Host: local" + _cCRLF_
		if pcBody != ""
			_cReq_ += ("Content-Length: " + len(pcBody) + _cCRLF_)
		ok
		_cReq_ += ("Connection: close" + _cCRLF_ + _cCRLF_ + pcBody)
		_nJob_ = @oClient.SubmitTcp("127.0.0.1", @nPort, _cReq_)
		@oServer.ServeOne(3000)
		_cRaw_ = @oClient.AwaitTcp(_nJob_, 5000)
		@nLastStatus = This._StatusOf(_cRaw_)
		return _cRaw_                                      # the RAW response

	# --- response parsing, SPLIT-ONLY ------------------------------------
	# These deliberately use ONLY StzSplit / StzReplace and never a positional
	# slice. StzMidToEnd / StzMid / StzLeft / StzRight feed CODEPOINT indices
	# to a BYTE-addressed engine slice, so on any multibyte payload they return
	# empty or a truncated string (verified 2026-07-23: StzLeft("cafe-kuskus"
	# with real accents, 4) = "", StzMidToEnd(arabic, 2) = ""). A dish name in
	# Arabic is an ordinary value here, so slicing is simply not usable.

	# "HTTP/1.1 201 Created" -> 201
	def _StatusOf(pcResp)
		_aLines_ = StzSplit(pcResp, char(13) + char(10))
		if len(_aLines_) = 0
			return 0
		ok
		_aParts_ = StzSplit(_aLines_[1], " ")
		if len(_aParts_) < 2
			return 0
		ok
		return ring_number(ring_trim(_aParts_[2]))

	# '{"count":3}' -> 3
	def _CountJson(pcResp)
		_aA_ = StzSplit(pcResp, '"count":')
		if len(_aA_) < 2
			return 0
		ok
		_aB_ = StzSplit(_aA_[2], "}")
		if len(_aB_) = 0
			return 0
		ok
		return ring_number(ring_trim(_aB_[1]))

	# '{"rows":[["a","b"],["c","d"]]}' -> [ [ "a", "b" ], [ "c", "d" ] ]
	# Shape-specific by design: the producer is stzAppServer._RowsJson, so the
	# grammar is known. LIMITATION (documented, not hidden): a cell containing
	# a comma or the sequence ],[ would split wrongly -- fine for the domain
	# values this carries; a general JSON parse is the upgrade path.
	def _ParseRowsJson(pcResp)
		_out_ = []
		_aA_ = StzSplit(pcResp, '"rows":[')
		if len(_aA_) < 2
			return _out_
		ok
		_aB_ = StzSplit(_aA_[2], "]}")
		if len(_aB_) = 0
			return _out_
		ok
		_cBody_ = ring_trim(_aB_[1])
		if _cBody_ = ""
			return _out_
		ok
		_aRows_ = StzSplit(_cBody_, "],[")
		_n_ = len(_aRows_)
		for _i_ = 1 to _n_
			_cRow_ = StzReplace(StzReplace(_aRows_[_i_], "[", ""), "]", "")
			_aCells_ = StzSplit(_cRow_, ",")
			_row_ = []
			_m_ = len(_aCells_)
			for _j_ = 1 to _m_
				_row_ + This._Unquote(_aCells_[_j_])
			next
			_out_ + _row_
		next
		return _out_

	# '"kuskus"' -> kuskus  (split on the quote: [ "", value, "" ])
	def _Unquote(pcCell)
		_c_ = ring_trim("" + pcCell)
		_a_ = StzSplit(_c_, '"')
		if len(_a_) >= 3
			_c_ = _a_[2]
		but len(_a_) = 2
			_c_ = _a_[1] + _a_[2]
		ok
		return StzReplace(_c_, '\"', '"')
