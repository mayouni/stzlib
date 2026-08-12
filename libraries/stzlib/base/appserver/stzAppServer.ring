#======================================================#
#  STZAPPSERVER - THE REACTOR-DRIVEN SERVICE HOST      #
#======================================================#

/*--- The computational server paradigm, made real (R7, 2026-07-14)

stzAppServer treats Softanza as a PERSISTENT COMPUTATIONAL ENGINE
rather than a per-request library: the Zig engine (Unicode, NLP,
graphs, neural, sqlite) is resident and warm; the server's only job
is to move requests onto it and results back out.

THE SPINE (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10): one reactor-
driven host on stzReactor -- the vendored-libuv event loop running on
an engine thread. The engine does async accept + per-connection read
streams + HTTP/1.1 framing; Ring stays synchronous and drains EVENTS:

	oSrv = new stzAppServer()
	oSrv.Get_("/greet", func oReq, oResp { oResp.Text("hello") })
	oSrv.Start(8080, "127.0.0.1")
	oSrv.RunFor(60000)       # serve for a minute (or Run() = forever)
	oSrv.Stop()

No callback ever crosses from libuv into Ring; no libuv call ever
happens off the loop thread. That is the runtime doctrine (5.4) the
pre-engine skeleton violated by riding the Reaxis cooperative poller.

ONE HOST, FOUR TOPOLOGIES (the 5.10 convergence):
- WEB      : Get_/Post/Put_/Delete routes over the HTTP listener
- MBaaS    : Expose(oDb, "table") -> FULL REST CRUD (list/read/create/
             update/delete by id) over data/stzDatabase, injection-safe
             (GET list / GET count / POST insert), sqlite in the engine
- IoT      : ListenRaw(nPort, fHandler) -> raw per-connection byte
             streams (no HTTP framing) for device telemetry
- AGENTS   : HostAgents() attaches an stzAgentHost that SHARES this
             server's reactor -- "the agent host IS the same host",
             made literal. The serve loop interleaves: a bounded slice
             on the socket, then tick whatever is due, so agents no
             longer starve on an idle socket. Timer- and event-driven
             supervision both ride it. /agents is READ-ONLY (control
             is in-process and governed).

COLLAPSE RULINGS (5.10): stzContextPool folded into stzReactorPool
(real threads; the "context" abstraction predates the resident
engine); stzComputeEngine's preloads are subsumed by the engine being
resident by construction. Both classes are now DELETED -- a ruling that
leaves the superseded code loadable has not really been applied.

SCOPE SIGILS: attributes are @-prefixed and method temps are _x_
wrapped -- bare class-head attributes CAPTURE same-named user globals
in Ring 1.27 (verified 2026-07-14: a user global `oClient` was
clobbered at `new stzAppResponse(...)`, then R12 on the attribute).
*/

func StzAppServerQ()
	return new stzAppServer()

class stzAppServer from stzObject

	# Core infrastructure
	@oReactor = ""          # the libuv loop (owned)
	@oRouter = ""
	@nServerId = 0            # HTTP listener id on the reactor
	@nBoundPort = 0
	@cHost = "127.0.0.1"
	@bRunning = 0

	# IoT raw listeners: [ [ nSid, nPort, fHandler ], ... ]
	@aRawListeners = []

	# MBaaS resources: [ [ cTable, oDb ], ... ]
	@aResources = []

	# Monitoring
	@nRequestCount = 0
	@nStartMs = 0

	# Perf observation (perf P3): a stzPerfMonitor this server records
	# into per request (R + X + errors) and ticks while serving. The
	# stored monitor is a Ring COPY -- harmless by design: metric state
	# is engine-side, so the caller's face reads what this face records.
	@oPerfMon = ""
	# Per-route family face (perf P8, set by ObserveRoutes): held
	# directly so the per-request path hits this face's child cache.
	@oRouteFam = ""

	# Hosted agents (R5): an stzAgentHost sharing THIS server's loop
	@oAgentHost = ""
	@nAgentSliceMs = 20       # max ms spent parked on the socket per tick pass

	# Request authentication (for a listener that is NOT on the loopback)
	@oSigner = ""           # an stzRequestSigner holding the shared secret(s)
	@nMaxSkewMs = 30000
	@cAuthWhy = ""

	# The mounted USER-authentication router (auth plan phase 6): stzAuth's whole
	# surface -- password, 2FA, passwordless, the authz actor -- as HTTP endpoints.
	@oAuth = ""             # the server's stzAuth (see MountAuth on copy semantics)
	@cAuthPrefix = "/auth"
	@bAuthMounted = 0
	@bSecureCookies = 0   # add Secure to auth cookies (set TRUE behind TLS)

	# The mounted OIDC PROVIDER: this server IS an identity provider for other apps
	@oOp = ""
	@cOpPrefix = "/oidc"
	@bOpMounted = 0

	def init()
		# paren-less: stzAppRouter has no own init(), and the inherited
		# stzObject.init(pObject) wants an argument
		@oRouter = new stzAppRouter

	  #--------------------#
	 #  SERVER LIFECYCLE  #
	#--------------------#

	# Bind the HTTP listener. nPortNum 0 = ephemeral (see Port()).
	# Raises on bind failure -- no silent half-started server.
	def Start(nPortNum, cHostAddr)
		if @bRunning
			stzraise("stzAppServer is already running on port " + @nBoundPort)
		ok
		if cHostAddr = "" or cHostAddr = ""
			cHostAddr = "127.0.0.1"
		ok
		@cHost = cHostAddr
		@oReactor = new stzReactor()
		_nSid_ = @oReactor.ListenHttp(@cHost, nPortNum)
		if _nSid_ < 1
			stzraise("stzAppServer could not bind " + @cHost + ":" + nPortNum +
			         " (uv error " + _nSid_ + ")")
		ok
		@nServerId = _nSid_
		@nBoundPort = @oReactor.ServerPort(_nSid_)
		@bRunning = 1
		@nStartMs = StzEngineTimeNowMs()
		return 1

	# Serve over TLS: the reactor terminates TLS per connection (server cert
	# cCertPath + key cKeyPath) BELOW the router, so every handler runs on
	# the DECRYPTED request and responses are encrypted transparently -- the
	# routing/handler code is byte-for-byte identical to plain Start(). A
	# non-empty cCaPath enables client-cert checks; bRequireClient = TRUE
	# demands a valid client cert (mutual TLS). Same bind semantics as Start.
	def StartTls(nPortNum, cHostAddr, cCertPath, cKeyPath, cCaPath, bRequireClient)
		if @bRunning
			stzraise("stzAppServer is already running on port " + @nBoundPort)
		ok
		if cHostAddr = "" or cHostAddr = ""
			cHostAddr = "127.0.0.1"
		ok
		@cHost = cHostAddr
		@oReactor = new stzReactor()
		_nSid_ = @oReactor.ListenHttpTls(@cHost, nPortNum, cCertPath, cKeyPath, cCaPath, bRequireClient)
		if _nSid_ < 1
			stzraise("stzAppServer could not start TLS on " + @cHost + ":" + nPortNum +
			         " (error " + _nSid_ + "; -13=bad cert, -14=bad key, -17=bad CA)")
		ok
		@nServerId = _nSid_
		@nBoundPort = @oReactor.ServerPort(_nSid_)
		@bRunning = 1
		@nStartMs = StzEngineTimeNowMs()
		return 1

	# One-way HTTPS convenience (server cert only, no client cert).
	def StartHttps(nPortNum, cHostAddr, cCertPath, cKeyPath)
		return This.StartTls(nPortNum, cHostAddr, cCertPath, cKeyPath, "", 0)

	def Stop()
		if NOT @bRunning
			return This
		ok
		@oReactor.ServerStop(@nServerId)
		_nLen_ = len(@aRawListeners)
		for _i_ = 1 to _nLen_
			@oReactor.ServerStop(@aRawListeners[_i_][1])
		next
		@oReactor.Destroy()
		@oReactor = ""
		@nServerId = 0
		@aRawListeners = []
		@bRunning = 0
		return This

	def IsRunning()
		return @bRunning

	def Port()
		return @nBoundPort

	def Host()
		return @cHost

	def Uptime()
		if @nStartMs = 0
			return 0
		ok
		return (StzEngineTimeNowMs() - @nStartMs) / 1000

	def RequestCount()
		return @nRequestCount

	# The underlying reactor as a chainable stz object (Q-convention).
	def ReactorQ()
		return @oReactor

	  #-----------------#
	 #  THE SERVE LOOP #
	#-----------------#

	# Drain events until ONE data event (an HTTP request or a raw chunk)
	# has been handled, or nTimeoutMs elapses. Returns TRUE if work was
	# done. Accept/closed events are drained silently along the way.
	def ServeOne(nTimeoutMs)
		if NOT @bRunning
			stzraise("stzAppServer.ServeOne() called on a stopped server -- Start() first.")
		ok
		# perf P3: the observed server samples its own senses at the
		# monitor's cadence (Tick is a cheap due-check when not due).
		if @oPerfMon != ""
			@oPerfMon.Tick()
		ok
		_nDeadline_ = StzEngineTimeNowMs() + nTimeoutMs
		while 1
			# HTTP listener (non-blocking drain)
			_aEv_ = @oReactor.ServerPoll(@nServerId)
			if len(_aEv_) > 0
				if This._HandleHttpEvent(_aEv_)
					return 1
				ok
				loop
			ok
			# raw listeners (IoT)
			_bDidWork_ = 0
			_nLen_ = len(@aRawListeners)
			for _i_ = 1 to _nLen_
				_aEvR_ = @oReactor.ServerPoll(@aRawListeners[_i_][1])
				if len(_aEvR_) > 0
					if This._HandleRawEvent(@aRawListeners[_i_], _aEvR_)
						_bDidWork_ = 1
					ok
				ok
			next
			if _bDidWork_
				return 1
			ok
			if StzEngineTimeNowMs() >= _nDeadline_
				return 0
			ok
			# nothing pending: park briefly on the HTTP listener
			_aEv_ = @oReactor.ServerAwait(@nServerId, 10)
			if len(_aEv_) > 0
				if This._HandleHttpEvent(_aEv_)
					return 1
				ok
			ok
		end

	# Serve every event that arrives within nMs (a bounded Run()).
	#
	# With agents hosted, the serve slice is BOUNDED: ServeOne(nLeft) would
	# otherwise park on the socket for the whole remaining time whenever no
	# request arrives, and the agents -- which live on this same loop -- would
	# never tick. So we serve for at most @nAgentSliceMs, then tick whatever is
	# due, and repeat. Requests and perceive-decide-act interleave on ONE loop.
	def RunFor(nMs)
		_nDeadline_ = StzEngineTimeNowMs() + nMs
		while StzEngineTimeNowMs() < _nDeadline_
			_nLeft_ = _nDeadline_ - StzEngineTimeNowMs()
			if _nLeft_ < 1
				exit
			ok
			if @oAgentHost = ""
				This.ServeOne(_nLeft_)
			else
				_nSlice_ = @nAgentSliceMs
				if _nSlice_ > _nLeft_
					_nSlice_ = _nLeft_
				ok
				This.ServeOne(_nSlice_)
				@oAgentHost.TickDue()
			ok
		end
		return This

	# Serve forever (until the process is killed or Stop() is called
	# from a handler). The documented blocking entry point.
	def Run()
		while @bRunning
			if @oAgentHost = ""
				This.ServeOne(1000)
			else
				This.ServeOne(@nAgentSliceMs)
				@oAgentHost.TickDue()
			ok
		end
		return This

	  #---------------------#
	 #  ROUTING INTERFACE  #
	#---------------------#

	def Get_(cPath, fHandler)
		@oRouter.AddRoute("GET", cPath, fHandler)
		return This

	def Post(cPath, fHandler)
		@oRouter.AddRoute("POST", cPath, fHandler)
		return This

	def Put_(cPath, fHandler)
		@oRouter.AddRoute("PUT", cPath, fHandler)
		return This

	def Delete(cPath, fHandler)
		@oRouter.AddRoute("DELETE", cPath, fHandler)
		return This

	# Observe this server with a perf monitor (perf P3). From this call
	# on, every request records its response time R into the timer
	# 'http.request.ms', its arrival into the counter 'http.requests'
	# (throughput X = its measured rate), and 5xx outcomes into
	# 'http.errors'; GET /metrics serves the monitor's Prometheus
	# exposition, and /health widens with the process senses. The
	# monitor's watched senses (memory/cpu) are ticked by the serve
	# loop at the monitor's own cadence -- a served app samples itself.
	def Observe(poMonitor)
		if NOT poMonitor.HasMetric("http.request.ms")
			poMonitor.NewTimer("http.request.ms")
		ok
		if NOT poMonitor.HasMetric("http.requests")
			poMonitor.NewCounter("http.requests")
		ok
		if NOT poMonitor.HasMetric("http.errors")
			poMonitor.NewCounter("http.errors")
		ok
		@oPerfMon = poMonitor
		return This

	def IsObserved()
		return @oPerfMon != ""

	# Per-route observation (perf P8): Observe() PLUS a timer FAMILY
	# 'http.route.ms' labeled [method, route, class] -- one child per
	# route the traffic actually exercises, each with its own
	# percentiles ('class' is the status class: 2xx/4xx/5xx).
	# Cardinality rides the family's bound: unruly path spaces land in
	# the overflow child instead of exploding the registry.
	def ObserveRoutes(poMonitor)
		This.Observe(poMonitor)
		if NOT poMonitor.HasMetric("http.route.ms")
			poMonitor.NewTimerXT("http.route.ms", [ "method", "route", "class" ])
		ok
		@oPerfMon = poMonitor          # re-copy: the family must ride this face
		@oRouteFam = poMonitor.MetricQ("http.route.ms")
		return This

	def Use(cPath, fMiddleware)
		@oRouter.AddMiddleware(cPath, fMiddleware)
		return This

	def Static(cPath, cDirectory)
		@oRouter.AddStaticRoute(cPath, cDirectory)
		return This

	  #--------------------------------#
	 #  MBaaS: REST OVER stzDatabase  #
	#--------------------------------#

	# Expose a table of an open stzDatabase as a REST resource -- the FULL
	# CRUD floor, keyed by the "id" column (override with ExposeWithKey):
	#   GET    /api/<table>         -> {"rows":[[...],...]}   (list)
	#   GET    /api/<table>/count   -> {"count":N}
	#   GET    /api/<table>/<id>    -> {"row":[...]} or 404   (read one)
	#   POST   /api/<table>         -> body "col=val&.." inserts; 201
	#   PUT    /api/<table>/<id>    -> body "col=val&.." updates; {"updated":N}
	#   DELETE /api/<table>/<id>    -> {"deleted":N}
	# Values + the id are SQL-escaped (injection-safe).
	def Expose(oDb, cTable)
		@aResources + [ cTable, oDb, "id" ]
		return This

	# Same, but with a custom primary-key column (e.g. "uuid", "rowid").
	def ExposeWithKey(oDb, cTable, cKeyCol)
		@aResources + [ cTable, oDb, "" + cKeyCol ]
		return This

	  #------------------------------------------------#
	 #  REQUEST AUTHENTICATION (off-loopback listeners) #
	#------------------------------------------------#

	# Require every request to carry a valid HMAC signature. On the loopback a
	# server can reasonably trust its callers; the moment it binds a real
	# interface it cannot, and an unauthenticated MBaaS floor would accept a
	# POST from anyone who can route to the port. This is the same rule the rest
	# of the library applies -- expression is free, admission is governed --
	# enforced at the transport edge.
	#
	# The envelope travels as query parameters (_kid/_ts/_nonce/_sig), because
	# the curl-backed client submits a method, a URL and a body -- it has no
	# custom-header channel. A MAC is not a secret, so carrying it in the URL is
	# sound (the same shape as a presigned URL); the SECRET never leaves either
	# side. stzRequestSigner supplies freshness (clock-skew window both ways),
	# replay rejection (a nonce is accepted once) and constant-time comparison.
	#
	# EVERY request must be signed, /health included. An exemption is a hole to
	# get wrong later, and a liveness probe that reports uptime and a request
	# count is not nothing. A client that holds the key can sign its probe.
	#
	# NOTE (Ring aliasing): the stored signer is this server's COPY, so the
	# replay-nonce ledger it maintains is the SERVER's. That is correct here --
	# signer and verifier are different roles, and in the real topology they are
	# different processes sharing only the secret.
	def RequireSignedRequests(poSigner, pnMaxSkewMs)
		This.RequireSignedRequestsQ(poSigner, pnMaxSkewMs)

	def RequireSignedRequestsQ(poSigner, pnMaxSkewMs)
		if pnMaxSkewMs < 1
			stzraise("stzAppServer.RequireSignedRequests: the skew window must be >= 1ms.")
		ok
		@oSigner = poSigner
		@nMaxSkewMs = pnMaxSkewMs
		return This

	def RequiresSignedRequests()
		return @oSigner != ""

	  #--------------------------------------#
	 #  USER AUTHENTICATION ROUTER (stzAuth)  #
	#--------------------------------------#

	# Mount stzAuth as HTTP endpoints (auth plan phase 6) -- the whole surface the
	# earlier phases built, reachable by a browser or a client:
	#
	#   POST <prefix>/login          user=&password=[&code=]  -> session cookie
	#   POST <prefix>/2fa/verify     user=&password=&code=    -> session cookie
	#   POST <prefix>/logout                                  -> cookie cleared
	#   GET  <prefix>/session                                 -> who + capabilities
	#   POST <prefix>/magic-link     email=                   -> 202 (always)
	#   GET  <prefix>/magic-link/redeem?token=                -> session cookie
	#   POST <prefix>/otp            email=                   -> 202 (always)
	#   POST <prefix>/otp/verify     email=&code=             -> session cookie
	#
	# The session token travels as an HttpOnly + SameSite=Strict cookie (script
	# cannot read it, and a cross-site form cannot ride it), plus a readable CSRF
	# cookie that a cookie-authenticated POST must echo in X-CSRF-Token.
	#
	# RING COPY SEMANTICS (read this): `=` and list insertion both COPY an object,
	# so the server holds ITS OWN stzAuth. Configure and register BEFORE mounting.
	# For a view shared with the caller (and durability), give the stzAuth a
	# stzAuthDbStore: its sqlite is an engine handle, so the server's copy reads and
	# writes the SAME database -- a login through HTTP is then visible to the
	# caller's object, and vice versa.
	def MountAuth(poAuth)
		This.MountAuthAtQ(poAuth, "/auth")

	def MountAuthQ(poAuth)
		return This.MountAuthAtQ(poAuth, "/auth")

	def MountAuthAt(poAuth, pcPrefix)
		This.MountAuthAtQ(poAuth, pcPrefix)

	def MountAuthAtQ(poAuth, pcPrefix)
		if NOT isObject(poAuth)
			stzraise("stzAppServer.MountAuth: an stzAuth object is required.")
		ok
		_p_ = "" + pcPrefix
		if _p_ = ""  _p_ = "/auth"  ok
		if StzFindFirst("/", _p_) != 1
			_p_ = "/" + _p_
		ok
		@oAuth = poAuth
		@cAuthPrefix = _p_
		@bAuthMounted = 1
		return This

	def AuthIsMounted()
		return @bAuthMounted

	def AuthPrefix()
		return @cAuthPrefix

	# Add Secure to the auth cookies -- TRUE whenever the listener is TLS, so the
	# session cookie never travels in clear text.
	def SetSecureCookies(pbOn)
		This.SetSecureCookiesQ(pbOn)

	def SetSecureCookiesQ(pbOn)
		@bSecureCookies = pbOn
		return This

	def SecureCookies()
		return @bSecureCookies

	  #-------------------------------------------#
	 #  OIDC PROVIDER (this server as an IdP)     #
	#-------------------------------------------#

	# Publish an stzOidcProvider over HTTP, so other applications can "sign in
	# with" THIS server:
	#
	#   GET  /.well-known/openid-configuration   (always at the standard path)
	#   GET  <prefix>/jwks                       the public signing keys
	#   GET  <prefix>/authorize                  -> 302 to the app with a code
	#   POST <prefix>/token                      code + secret + PKCE -> tokens
	#
	# /authorize needs a signed-in user, and takes it from the SESSION COOKIE the
	# mounted auth router issues -- so this server's own login becomes the login
	# for every app that trusts it. With no session it answers 401 (the app in
	# front redirects to its login page and comes back).
	def MountOidcProvider(poProvider)
		This.MountOidcProviderAtQ(poProvider, "/oidc")

	def MountOidcProviderQ(poProvider)
		return This.MountOidcProviderAtQ(poProvider, "/oidc")

	def MountOidcProviderAt(poProvider, pcPrefix)
		This.MountOidcProviderAtQ(poProvider, pcPrefix)

	def MountOidcProviderAtQ(poProvider, pcPrefix)
		if NOT isObject(poProvider)
			stzraise("stzAppServer.MountOidcProvider: an stzOidcProvider is required.")
		ok
		_p_ = "" + pcPrefix
		if _p_ = ""  _p_ = "/oidc"  ok
		if StzFindFirst("/", _p_) != 1  _p_ = "/" + _p_  ok
		@oOp = poProvider
		@cOpPrefix = _p_
		@bOpMounted = 1
		return This

	def OidcProviderIsMounted()
		return @bOpMounted

	def OidcProviderPrefix()
		return @cOpPrefix

	# Why the last request was refused ("" when none was).
	def AuthWhy()
		return @cAuthWhy

	# TRUE when the request may proceed.
	def _RequestIsAuthorized(oReq)
		if @oSigner = ""
			return 1
		ok
		_cKid_ = "" + oReq.Query("_kid")
		_cSig_ = "" + oReq.Query("_sig")
		if _cKid_ = "" or _cSig_ = ""
			@cAuthWhy = "unsigned request (this listener requires a signature)"
			return 0
		ok
		_cNonce_ = "" + oReq.Query("_nonce")
		_nTs_ = ring_number("" + oReq.Query("_ts"))
		_bOk_ = @oSigner.VerifyNow(_cKid_, oReq.Method(),
		            This._PathWithoutAuth(oReq.Path()), oReq.Body(),
		            _nTs_, _cNonce_, _cSig_, @nMaxSkewMs)
		if _bOk_
			@cAuthWhy = ""
		else
			@cAuthWhy = @oSigner.Why()
		ok
		return _bOk_

	# The path with any query string removed.
	def _BarePath(pcPath)
		_a_ = StzSplit("" + pcPath, "?")
		if len(_a_) = 0
			return "" + pcPath
		ok
		return _a_[1]

	# The path the signature covers: everything EXCEPT the envelope params, so
	# signing is not circular while any real query parameter stays covered.
	def _PathWithoutAuth(pcPath)
		_aParts_ = StzSplit("" + pcPath, "?")
		if len(_aParts_) < 2
			return "" + pcPath
		ok
		_cKept_ = ""
		_aPairs_ = StzSplit(_aParts_[2], "&")
		_n_ = len(_aPairs_)
		for _i_ = 1 to _n_
			_aKV_ = StzSplit(_aPairs_[_i_], "=")
			if len(_aKV_) = 0
				loop
			ok
			_cK_ = _aKV_[1]
			if _cK_ = "_kid" or _cK_ = "_ts" or _cK_ = "_nonce" or _cK_ = "_sig"
				loop
			ok
			if _cKept_ != ""
				_cKept_ += "&"
			ok
			_cKept_ += _aPairs_[_i_]
		next
		if _cKept_ = ""
			return _aParts_[1]
		ok
		return _aParts_[1] + "?" + _cKept_

	  #-------------------------------------------#
	 #  AGENTS: the agent host IS the same host   #
	#-------------------------------------------#

	# Host agents on THIS server's loop. The agent host shares the server's
	# reactor rather than owning one, so a hosted agent's perceive-decide-act
	# cycle and the HTTP listener are the same libuv loop -- which is what
	# "the agent host is the same host" was always meant to mean.
	#
	# WHY EVERYTHING GOES THROUGH THE SERVER. Ring copies objects on `=`, so
	# the host stored here is the server's own copy: a caller who kept the
	# original would watch a snapshot that never ticks. That is why the
	# supervision and read methods below DELEGATE instead of handing the host
	# out -- the same cure stzAgentHost itself applies to its agents, and
	# stzSuperApp to its governance. Reach the live host only through these.
	def HostAgents()
		if NOT @bRunning
			stzraise("stzAppServer.HostAgents() needs a running server -- Start() first (the agents share ITS loop).")
		ok
		_oH_ = new stzAgentHost()
		_oH_.SetReactor(@oReactor)     # share the loop; do not own one
		@oAgentHost = _oH_
		return This

	# Adopt a host configured elsewhere (e.g. one carrying a decommission
	# governance declared up front). It is REPARENTED onto this server's loop,
	# and the caller's reference goes stale by the rule above.
	def AdoptAgentHost(poHost)
		if NOT @bRunning
			stzraise("stzAppServer.AdoptAgentHost() needs a running server -- Start() first.")
		ok
		poHost.SetReactor(@oReactor)
		@oAgentHost = poHost
		return This

	def IsHostingAgents()
		return @oAgentHost != ""

	# How long a single serve slice may park on the socket before due agents
	# are ticked. Smaller = crisper agent timing, more loop turns.
	def SetAgentSlice(pnMs)
		This.SetAgentSliceQ(pnMs)

	def SetAgentSliceQ(pnMs)
		if pnMs < 1
			stzraise("stzAppServer.SetAgentSliceQ: the slice must be >= 1ms.")
		ok
		@nAgentSliceMs = pnMs
		return This

	def AgentSlice()
		return @nAgentSliceMs

	#-- supervision, delegated to the live host -------------------------

	def SuperviseAgent(poAgent, pnTickMs)
		This._RequireAgentHost("SuperviseAgent")
		@oAgentHost.Supervise(poAgent, pnTickMs)
		return This

	def SuperviseAgentOnEvent(poAgent, pcChannel)
		This._RequireAgentHost("SuperviseAgentOnEvent")
		@oAgentHost.SuperviseOnEvent(poAgent, pcChannel)
		return This

	def NumberOfAgents()
		if @oAgentHost = ""
			return 0
		ok
		return @oAgentHost.NumberOfAgents()

	def AgentNames()
		_out_ = []
		if @oAgentHost = ""
			return _out_
		ok
		_nN_ = @oAgentHost.NumberOfAgents()
		for _i_ = 1 to _nN_
			_out_ + @oAgentHost.NameAt(_i_)
		next
		return _out_

	def AgentTicks(pcName)
		if @oAgentHost = ""
			return 0
		ok
		return @oAgentHost.TicksOf(pcName)

	def AgentIsActive(pcName)
		if @oAgentHost = ""
			return 0
		ok
		return @oAgentHost.IsActive(pcName)

	def AgentIsRetired(pcName)
		if @oAgentHost = ""
			return 0
		ok
		return @oAgentHost.IsRetired(pcName)

	def AgentTrace()
		if @oAgentHost = ""
			return []
		ok
		return @oAgentHost.Trace()

	#-- control. IN-PROCESS ONLY, deliberately (see _ServeAgents) -------

	def PauseAgent(pcName)
		This._RequireAgentHost("PauseAgent")
		@oAgentHost.Cancel(pcName)
		return This

	def ResumeAgent(pcName)
		This._RequireAgentHost("ResumeAgent")
		@oAgentHost.Resume(pcName)
		return This

	# Governed teardown: refused until the agent's declared obligations are
	# fulfilled (R4b). Returns FALSE with AgentWhy() explaining the refusal.
	def RetireAgent(pcName)
		This._RequireAgentHost("RetireAgent")
		return @oAgentHost.Retire(pcName)

	def AgentWhy()
		if @oAgentHost = ""
			return ""
		ok
		return @oAgentHost.Why()

	def DeclareAgentDecommission(pcName, pacObligations)
		This._RequireAgentHost("DeclareAgentDecommission")
		@oAgentHost.DeclareDecommission(pcName, pacObligations)
		return This

	def FulfillAgentObligation(pcName, pcObligation)
		This._RequireAgentHost("FulfillAgentObligation")
		@oAgentHost.FulfillObligation(pcName, pcObligation)
		return This

	def _RequireAgentHost(pcWhat)
		if @oAgentHost = ""
			stzraise("stzAppServer." + pcWhat + "() needs hosted agents -- call HostAgents() first.")
		ok
		return 1

	  #----------------------------#
	 #  IoT: RAW STREAM LISTENER  #
	#----------------------------#

	# A raw TCP listener (no HTTP framing): fHandler is called as
	#   call fHandler(oServer, nSid, nConn, cBytes)
	# for every chunk a device sends; reply with RawWrite(). Requires a
	# running server (the listener joins the same reactor).
	def ListenRaw(nPortNum, fHandler)
		if NOT @bRunning
			stzraise("ListenRaw() needs a running server -- Start() first.")
		ok
		_nSid_ = @oReactor.Listen(@cHost, nPortNum)
		if _nSid_ < 1
			stzraise("stzAppServer could not bind raw listener on port " +
			         nPortNum + " (uv error " + _nSid_ + ")")
		ok
		@aRawListeners + [ _nSid_, @oReactor.ServerPort(_nSid_), fHandler ]
		return _nSid_

	def RawPort(nSid)
		return @oReactor.ServerPort(nSid)

	def RawWrite(nSid, nConn, cData, bCloseAfter)
		return @oReactor.ServerWrite(nSid, nConn, cData, bCloseAfter)

	  #--------------------#
	 #  REQUEST HANDLING  #
	#--------------------#

	# Returns TRUE when the event was a request that got a response.
	def _HandleHttpEvent(aEv)
		if aEv[1] != :data
			return 0   # accept/closed: connection registry only
		ok
		_nConn_ = aEv[2]
		@nRequestCount++
		# Snapshot the reactor + server id BEFORE dispatch. A handler that
		# re-enters objects (e.g. a Commons route calling into stzPlatform)
		# leaves Ring's object scope pointing elsewhere, so a BARE @nServerId
		# / @oReactor read AFTER `call fHandler()` raises R24 (the trap). Read
		# them into locals up front and the write is safe whatever the
		# handler did. The perf monitor obeys the SAME discipline.
		_oRct_ = @oReactor
		_nSid_ = @nServerId
		_oPerf_ = @oPerfMon
		_oRFam_ = @oRouteFam
		_nT0_ = StzEngineWatchTimestampNs()   # the request bracket opens (perf P3)
		_oResp_ = new stzAppResponse("")
		_bClose_ = 1
		_cTraceHdr_ = ""
		_cReqPath_ = ""
		_cReqMethod_ = ""
		try
			_oReq_ = This.ParseHttpRequest(aEv[3])
			_bClose_ = _oReq_.WantsClose()
			_cReqPath_ = This._BarePath(_oReq_.Path())
			_cReqMethod_ = _oReq_.Method()
			# perf P7: W3C trace identity per request when the observed
			# monitor traces. A valid incoming traceparent joins the
			# caller's trace (child span); otherwise a fresh trace opens
			# here. The response echoes the header so callers correlate.
			if _oPerf_ != ""
				if _oPerf_.IsTracing()
					_cIn_ = _oReq_.Header("traceparent")
					if _cIn_ != "" and StzEngineTraceIsValid(_cIn_) = 1
						_cTraceHdr_ = StzEngineTraceChild(_cIn_)
					else
						_cTraceHdr_ = StzEngineTraceNew()
					ok
					_oResp_.Header("traceparent", _cTraceHdr_)
					# perf P9: the request opens a TRACE SCOPE --
					# anything the handler logs (any stzLog, anywhere)
					# stamps this request's trace id automatically.
					StzEnginePerfTraceScopeSet(_cTraceHdr_)
				ok
			ok
			This._Dispatch(_oReq_, _oResp_)
		catch
			_oResp_.Status(400, "Bad Request").Text("Bad request: " + cCatchError)
		done
		if NOT _oResp_.IsSent()
			_oResp_.Text("")   # handler set nothing: empty 200
		ok
		_oRct_.ServerWrite(_nSid_, _nConn_, _oResp_.HttpBytes(), _bClose_)
		# Incident I2: the transport VERDICT is a security event. Reading it
		# here rather than at each `Status(401, ...)` site is deliberate --
		# there are nine of those inside this file alone, plus every route a
		# user writes, and a seam that only sees the library's own refusals
		# would miss exactly the ones an application added. One place, after
		# the response is final, sees them all.
		# Only 401 and 403 carry a security meaning: a 404 is a typo, a 500
		# is a bug. The path is the subject; nothing from the request body
		# or its headers is written, so a credential in an Authorization
		# header cannot reach the ledger through this door.
		_nSt_ = _oResp_.StatusCode()
		if _nSt_ = 401
			StzNoteRefusalFrom("http.request.unauthorized", "(anonymous)",
				_cReqMethod_ + " " + _cReqPath_, "the transport gate refused the request",
				"http")
		but _nSt_ = 403
			StzNoteRefusalFrom("http.request.forbidden", "(anonymous)",
				_cReqMethod_ + " " + _cReqPath_, "policy refused the request", "http")
		ok
		# The bracket closes AFTER the write is submitted: R covers
		# parse + gate + route + handler + render + write handoff.
		if _oPerf_ != ""
			_nMs_ = (StzEngineWatchTimestampNs() - _nT0_) / 1000000
			_oPerf_.MetricQ("http.request.ms").Record(_nMs_)
			_oPerf_.MetricQ("http.requests").Increment()
			if _oResp_.StatusCode() >= 500
				_oPerf_.MetricQ("http.errors").Increment()
			ok
			if _cTraceHdr_ != ""
				_oPerf_.RecordTrace(StzEngineTraceId(_cTraceHdr_), _cReqPath_,
					_oResp_.StatusCode(), _nMs_)
			ok
			# perf P8: per-route timing -- one family child per
			# [method, route, status-class] the traffic exercises.
			if _oRFam_ != "" and _cReqPath_ != ""
				_cCls_ = "" + floor(_oResp_.StatusCode() / 100) + "xx"
				_oRFam_.Child([ _cReqMethod_, _cReqPath_, _cCls_ ]).Record(_nMs_)
			ok
		ok
		# perf P9: the request's trace scope closes with its bracket.
		if _cTraceHdr_ != ""
			StzEnginePerfTraceScopeClear()
		ok
		return 1

	def _Dispatch(oReq, oResp)
		try
			# the transport gate runs BEFORE routing: an unsigned caller must
			# not reach a route, the MBaaS floor, or the agent surface.
			if NOT This._RequestIsAuthorized(oReq)
				oResp.Status(401, "Unauthorized").Json([ "error", @cAuthWhy ])
				return
			ok
			_aM_ = @oRouter.MatchRoute(oReq.Method(), oReq.Path())
			if _aM_[:matched]
				oReq.SetParams(_aM_[:params])
				_fHandler_ = _aM_[:handler]
				call _fHandler_(oReq, oResp)
			but This._ServeResource(oReq, oResp)
				# handled by the MBaaS floor
			but This._ServeAgents(oReq, oResp)
				# handled by the agent-observability surface
			but This._ServeAuth(oReq, oResp)
				# handled by the mounted user-authentication router
			but This._ServeOidcProvider(oReq, oResp)
				# handled by the mounted identity-provider surface
			# compare the path WITHOUT its query: a signed probe arrives as
			# "/health?_kid=..&_sig=..", and an exact match would miss it.
			but oReq.Method() = "GET" and This._BarePath(oReq.Path()) = "/health"
				# perf P3: /health carries the process senses; an OBSERVED
				# server adds its measured R percentiles and throughput.
				_aH_ = [
					"status", "healthy",
					"engine", "softanza-resident",
					"uptime_s", This.Uptime(),
					"requests_served", @nRequestCount,
					"rss_bytes", StzEnginePerfMemRss(),
					"cpu_ms", StzEnginePerfCpuNs() / 1000000
				]
				if @oPerfMon != ""
					_oT_ = @oPerfMon.MetricQ("http.request.ms")
					_aH_ + "p50_ms"
					_aH_ + _oT_.P50()
					_aH_ + "p95_ms"
					_aH_ + _oT_.P95()
					_aH_ + "p99_ms"
					_aH_ + _oT_.P99()
					_aH_ + "rate_per_s"
					_aH_ + @oPerfMon.MetricQ("http.requests").RatePerSecond()
				ok
				oResp.Json(_aH_)
			# perf P3: the OBSERVED server speaks Prometheus natively --
			# point a scraper at /metrics and every metric (senses + the
			# request instruments + the app's own) arrives in exposition
			# format. Signed like every other path when signing is on.
			but oReq.Method() = "GET" and This._BarePath(oReq.Path()) = "/metrics" and @oPerfMon != ""
				oResp.Text(@oPerfMon.Prometheus())
			else
				oResp.NotFound("Route not found: " + oReq.Method() + " " + oReq.Path())
			ok
		catch
			oResp.InternalError("Handler error: " + cCatchError)
		done

	# MBaaS floor. Returns TRUE when the path targeted an exposed table.
	def _ServeResource(oReq, oResp)
		if StzFindFirst("/api/", oReq.Path()) != 1
			return 0
		ok
		_cRest_ = StzMidToEnd(oReq.Path(), 6)     # after "/api/"
		# strip any query string ("/api/t?x=1" -> "/api/t")
		_nQ_ = StzFindFirst("?", _cRest_)
		if _nQ_ > 0  _cRest_ = StzLeft(_cRest_, _nQ_ - 1)  ok
		_cSub_ = ""
		_nSlash_ = StzFindFirst("/", _cRest_)
		if _nSlash_ > 0
			_cSub_ = StzMidToEnd(_cRest_, _nSlash_ + 1)
			_cRest_ = StzLeft(_cRest_, _nSlash_ - 1)
		ok
		# resolve the exposed table -> its db + key column
		_oDb_ = ""
		_cKey_ = "id"
		_nLen_ = len(@aResources)
		for _i_ = 1 to _nLen_
			if @aResources[_i_][1] = _cRest_
				_oDb_ = @aResources[_i_][2]
				_cKey_ = @aResources[_i_][3]
				exit
			ok
		next
		if _oDb_ = ""
			return 0
		ok
		_cTable_ = _cRest_

		# ---- COLLECTION routes: /api/<table> (and /count) ------------------
		if _cSub_ = "" or _cSub_ = "count"
			if oReq.Method() = "GET" and _cSub_ = "count"
				# ring_number(), not 0+str (the 0+str coercion is poisoned
				# after any caught raise -- Ring trap).
				oResp.Header("Content-Type", "application/json")
				oResp.Send('{"count":' + ring_number(_oDb_.Value("SELECT COUNT(*) FROM " + _cTable_)) + '}')
				return 1
			but oReq.Method() = "GET"
				# rows are ARRAYS of cells -- serialize directly.
				oResp.Header("Content-Type", "application/json")
				oResp.Send('{"rows":' + This._RowsJson(_oDb_.Rows("SELECT * FROM " + _cTable_)) + '}')
				return 1
			but oReq.Method() = "POST"
				_aPairs_ = This._ParseFormBody(oReq.Body())
				if len(_aPairs_) = 0
					oResp.Status(400, "Bad Request").Json([ "error", "empty form body" ])
					return 1
				ok
				_cCols_ = ""
				_cVals_ = ""
				_nPLen_ = len(_aPairs_)
				for _j_ = 1 to _nPLen_
					if _j_ > 1
						_cCols_ += ", "
						_cVals_ += ", "
					ok
					_cCols_ += _aPairs_[_j_][1]
					_cVals_ += "'" + This._SqlEscape(_aPairs_[_j_][2]) + "'"
				next
				_oDb_.Exec("INSERT INTO " + _cTable_ + " (" + _cCols_ + ") VALUES (" + _cVals_ + ")")
				oResp.Status(201, "Created").Json([ "inserted", 1 ])
				return 1
			ok
			oResp.Status(405, "Method Not Allowed").Json([ "error", "method not allowed" ])
			return 1
		ok

		# ---- ITEM routes: /api/<table>/<id> (read/update/delete one) -------
		# id is SQL-escaped + quoted; SQLite type-affinity matches '5' to an
		# INTEGER key, so this is both injection-safe and correct.
		_cId_ = "'" + This._SqlEscape(_cSub_) + "'"
		_cWhere_ = " WHERE " + _cKey_ + " = " + _cId_
		if oReq.Method() = "GET"
			_aR_ = _oDb_.Rows("SELECT * FROM " + _cTable_ + _cWhere_)
			if len(_aR_) = 0
				oResp.Status(404, "Not Found").Json([ "error", "no " + _cTable_ + " with " + _cKey_ + " " + _cSub_ ])
				return 1
			ok
			oResp.Header("Content-Type", "application/json")
			oResp.Send('{"row":' + This._RowJson(_aR_[1]) + '}')
			return 1
		but oReq.Method() = "PUT"
			_aPairs_ = This._ParseFormBody(oReq.Body())
			if len(_aPairs_) = 0
				oResp.Status(400, "Bad Request").Json([ "error", "empty form body" ])
				return 1
			ok
			# guard: the row must exist (so we can report updated=0 honestly)
			_nBefore_ = ring_number(_oDb_.Value("SELECT COUNT(*) FROM " + _cTable_ + _cWhere_))
			if _nBefore_ = 0
				oResp.Status(404, "Not Found").Json([ "error", "no " + _cTable_ + " with " + _cKey_ + " " + _cSub_ ])
				return 1
			ok
			_cSet_ = ""
			_nPLen_ = len(_aPairs_)
			for _j_ = 1 to _nPLen_
				if _j_ > 1  _cSet_ += ", "  ok
				_cSet_ += _aPairs_[_j_][1] + " = '" + This._SqlEscape(_aPairs_[_j_][2]) + "'"
			next
			_oDb_.Exec("UPDATE " + _cTable_ + " SET " + _cSet_ + _cWhere_)
			oResp.Json([ "updated", _nBefore_ ])
			return 1
		but oReq.Method() = "DELETE"
			_nBefore_ = ring_number(_oDb_.Value("SELECT COUNT(*) FROM " + _cTable_ + _cWhere_))
			_oDb_.Exec("DELETE FROM " + _cTable_ + _cWhere_)
			oResp.Json([ "deleted", _nBefore_ ])
			return 1
		ok
		oResp.Status(405, "Method Not Allowed").Json([ "error", "method not allowed" ])
		return 1

	  #--------------------------------------------#
	 #  THE AGENT SURFACE -- READ-ONLY, BY DESIGN  #
	#--------------------------------------------#

	# GET /agents          -> every hosted agent, with its live tick count
	# GET /agents/trace    -> the perceive-act trace
	# GET /agents/<name>   -> one agent, or 404
	#
	# DELIBERATELY READ-ONLY. Pausing, resuming and retiring an agent are
	# EFFECTS, and this library's rule is that expression is free but admission
	# is governed -- an unauthenticated socket carries no actor, so it may not
	# commit. Control therefore stays in-process (PauseAgent / RetireAgent),
	# where an actor and the R4b decommission contract gate it. A deployment
	# that wants remote control adds its own route behind its own auth, and
	# thereby states who is allowed to do it.
	#
	# Returns TRUE when the path was an /agents path (so _Dispatch stops).
	def _ServeAgents(oReq, oResp)
		if @oAgentHost = ""
			return 0
		ok
		_cPath_ = oReq.Path()
		if _cPath_ != "/agents" and StzFindFirst("/agents/", _cPath_) != 1
			return 0
		ok
		if oReq.Method() != "GET"
			oResp.Status(405, "Method Not Allowed").Json([
				"error", "the agent surface is read-only; control is in-process and governed" ])
			return 1
		ok
		if _cPath_ = "/agents"
			oResp.Header("Content-Type", "application/json")
			oResp.Send('{"agents":' + This._AgentsJson() + "}")
			return 1
		ok
		# split, don't slice: "/agents/" is ASCII but an agent NAME need not be
		_aSeg_ = StzSplit(_cPath_, "/agents/")
		_cName_ = ""
		if len(_aSeg_) >= 2
			_cName_ = _aSeg_[2]
		ok
		if _cName_ = "trace"
			oResp.Header("Content-Type", "application/json")
			oResp.Send('{"trace":' + This._AgentTraceJson() + "}")
			return 1
		ok
		if NOT @oAgentHost.IsSupervising(_cName_)
			oResp.Status(404, "Not Found").Json([ "error", "no agent '" + _cName_ + "'" ])
			return 1
		ok
		oResp.Header("Content-Type", "application/json")
		oResp.Send('{"agent":' + This._OneAgentJson(_cName_) + "}")
		return 1

	def _AgentsJson()
		_cOut_ = "["
		_nN_ = @oAgentHost.NumberOfAgents()
		for _i_ = 1 to _nN_
			if _i_ > 1
				_cOut_ += ","
			ok
			_cOut_ += This._OneAgentJson(@oAgentHost.NameAt(_i_))
		next
		return _cOut_ + "]"

	def _OneAgentJson(pcName)
		return '{"name":"' + This._JsonEsc(pcName) +
		       '","active":' + This._Bool01(@oAgentHost.IsActive(pcName)) +
		       ',"retired":' + This._Bool01(@oAgentHost.IsRetired(pcName)) +
		       ',"ticks":' + @oAgentHost.TicksOf(pcName) +
		       ',"channel":"' + This._JsonEsc(@oAgentHost.ChannelOf(pcName)) + '"}'

	def _AgentTraceJson()
		_aT_ = @oAgentHost.Trace()
		_cOut_ = "["
		_nN_ = len(_aT_)
		for _i_ = 1 to _nN_
			if _i_ > 1
				_cOut_ += ","
			ok
			_cOut_ += ('{"at":' + _aT_[_i_][1] +
			           ',"agent":"' + This._JsonEsc("" + _aT_[_i_][2]) +
			           '","acted":' + _aT_[_i_][3] +
			           ',"why":"' + This._JsonEsc("" + _aT_[_i_][4]) + '"}')
		next
		return _cOut_ + "]"

	def _Bool01(pbVal)
		if pbVal
			return "1"
		ok
		return "0"

	def _JsonEsc(pcVal)
		return StzReplace("" + pcVal, '"', '\"')

	# one row [cell,cell,...] -> ["cell","cell",...]
	def _RowJson(aRow)
		_cOut_ = "["
		_nLen_ = len(aRow)
		for _i_ = 1 to _nLen_
			if _i_ > 1  _cOut_ += ","  ok
			_cOut_ += '"' + StzReplace("" + aRow[_i_], '"', '\"') + '"'
		next
		return _cOut_ + "]"

	  #-------------------------------------------#
	 #  THE OIDC PROVIDER SURFACE (this = an IdP) #
	#-------------------------------------------#

	def _ServeOidcProvider(oReq, oResp)
		if NOT @bOpMounted
			return 0
		ok
		_cPath_ = This._BarePath(oReq.Path())
		_cM_ = oReq.Method()

		# discovery lives at the STANDARD well-known path, never behind a prefix
		if _cM_ = "GET" and _cPath_ = "/.well-known/openid-configuration"
			oResp.Header("Content-Type", "application/json").Send(@oOp.DiscoveryJson())
			return 1
		ok
		if StzFindFirst(@cOpPrefix, _cPath_) != 1
			return 0
		ok
		_cSub_ = StzMidToEnd(_cPath_, len(@cOpPrefix) + 1)
		if _cSub_ = ""  _cSub_ = "/"  ok

		if _cM_ = "GET" and _cSub_ = "/jwks"
			oResp.Header("Content-Type", "application/json").Send(@oOp.JwksJson())
			return 1
		ok
		if _cM_ = "GET" and _cSub_ = "/authorize"
			This._OpAuthorize(oReq, oResp)
			return 1
		ok
		if _cM_ = "POST" and _cSub_ = "/token"
			This._OpToken(oReq, oResp, This._ParseFormBody(oReq.Body()))
			return 1
		ok
		return 0

	# the FRONT channel: the browser arrives carrying OUR session cookie.
	def _OpAuthorize(oReq, oResp)
		_u_ = ""
		if @bAuthMounted
			_u_ = @oAuth.UserOfSession(This._CookieValue(oReq, "stzsession"))
		ok
		if _u_ = ""
			oResp.Status(401, "Unauthorized").Json([ "error", "login_required",
			    "error_description", "sign in to this provider first" ])
			return
		ok
		_aR_ = @oOp.Authorize([
		    :clientId = This._UrlDecode("" + oReq.Query("client_id")),
		    :redirectUri = This._UrlDecode("" + oReq.Query("redirect_uri")),
		    :state = This._UrlDecode("" + oReq.Query("state")),
		    :nonce = This._UrlDecode("" + oReq.Query("nonce")),
		    :codeChallenge = This._UrlDecode("" + oReq.Query("code_challenge")) ], _u_)
		if NOT _aR_[:ok]
			# a bad client or an unregistered redirect must NEVER be redirected to
			# -- that is exactly how a code gets delivered to an attacker.
			oResp.Status(400, "Bad Request").Json([ "error", _aR_[:error],
			                                        "error_description", _aR_[:why] ])
			return
		ok
		oResp.Status(302, "Found").Header("Location", _aR_[:redirectTo]).Send("")

	# the BACK channel: the app's own server calls this with its secret.
	def _OpToken(oReq, oResp, aForm)
		_aT_ = @oOp.ExchangeCode(
		    This._UrlDecode(This._FormValue(aForm, "client_id")),
		    This._UrlDecode(This._FormValue(aForm, "client_secret")),
		    This._UrlDecode(This._FormValue(aForm, "code")),
		    This._UrlDecode(This._FormValue(aForm, "redirect_uri")),
		    This._UrlDecode(This._FormValue(aForm, "code_verifier")))
		if NOT _aT_[:ok]
			oResp.Status(400, "Bad Request").Json([ "error", _aT_[:error],
			                                        "error_description", _aT_[:why] ])
			return
		ok
		# a token response must never be cached
		oResp.Header("Cache-Control", "no-store").Json([
		    "access_token", _aT_[:accessToken],
		    "id_token", _aT_[:idToken],
		    "token_type", _aT_[:tokenType],
		    "expires_in", _aT_[:expiresIn] ])

	  #----------------------------------------#
	 #  THE AUTH ROUTER (mounted stzAuth, P6)  #
	#----------------------------------------#

	# Serve the mounted auth endpoints. Returns TRUE when the path was ours.
	def _ServeAuth(oReq, oResp)
		if NOT @bAuthMounted
			return 0
		ok
		_cPath_ = This._BarePath(oReq.Path())
		if StzFindFirst(@cAuthPrefix, _cPath_) != 1
			return 0
		ok
		# the prefix is ASCII, so slicing past it is safe
		_cSub_ = StzMidToEnd(_cPath_, len(@cAuthPrefix) + 1)
		if _cSub_ = ""  _cSub_ = "/"  ok
		_cM_ = oReq.Method()
		_aF_ = This._ParseFormBody(oReq.Body())

		if _cM_ = "POST" and (_cSub_ = "/login" or _cSub_ = "/2fa/verify")
			This._AuthLogin(oReq, oResp, _aF_)
			return 1
		ok
		if _cM_ = "POST" and _cSub_ = "/logout"
			This._AuthLogout(oReq, oResp, _aF_)
			return 1
		ok
		if _cM_ = "GET" and _cSub_ = "/session"
			This._AuthSession(oReq, oResp)
			return 1
		ok
		if _cM_ = "POST" and _cSub_ = "/magic-link"
			@oAuth.RequestMagicLink(This._UrlDecode(This._FormValue(_aF_, "email")))
			# ALWAYS the same answer -- no account enumeration over HTTP either
			oResp.Status(202, "Accepted").Json([ "ok", 1, "sent", 1 ])
			return 1
		ok
		if _cM_ = "GET" and _cSub_ = "/magic-link/redeem"
			This._AuthOpen(oReq, oResp,
			    @oAuth.RedeemMagicLinkWith(This._UrlDecode("" + oReq.Query("token")),
			        This._ClientIp(oReq), "" + oReq.Header("User-Agent")))
			return 1
		ok
		if _cM_ = "POST" and _cSub_ = "/otp"
			@oAuth.RequestEmailOtp(This._UrlDecode(This._FormValue(_aF_, "email")))
			oResp.Status(202, "Accepted").Json([ "ok", 1, "sent", 1 ])
			return 1
		ok
		if _cM_ = "POST" and _cSub_ = "/otp/verify"
			This._AuthOpen(oReq, oResp,
			    @oAuth.VerifyEmailOtpWith(This._UrlDecode(This._FormValue(_aF_, "email")),
			        This._UrlDecode(This._FormValue(_aF_, "code")),
			        This._ClientIp(oReq), "" + oReq.Header("User-Agent")))
			return 1
		ok
		return 0

	# password (+ optional second factor) -> a session cookie.
	def _AuthLogin(oReq, oResp, aForm)
		_u_ = This._UrlDecode(This._FormValue(aForm, "user"))
		_pw_ = This._UrlDecode(This._FormValue(aForm, "password"))
		_code_ = This._UrlDecode(This._FormValue(aForm, "code"))
		# tell an honest client WHICH door it needs, without leaking whether the
		# password was right (the check is on the account, not the credential).
		if @oAuth.RequiresTwoFactor(_u_) and _code_ = ""
			oResp.Status(401, "Unauthorized").Json([ "error", "two-factor required",
			                                         "twofactor", 1 ])
			return
		ok
		This._AuthOpen(oReq, oResp,
		    @oAuth.LoginTwoFactorWith(_u_, _pw_, _code_,
		        This._ClientIp(oReq), "" + oReq.Header("User-Agent")))

	# the ONE place a flow turns a session token into a response: set the cookies
	# on success, answer 401 identically on every failure.
	def _AuthOpen(oReq, oResp, pcToken)
		if pcToken = ""
			oResp.Status(401, "Unauthorized").Json([ "error", "invalid credentials" ])
			return
		ok
		_csrf_ = StzEngineCryptoRandomHex(16)
		This._SetAuthCookie(oResp, "stzsession", pcToken, 1)
		This._SetAuthCookie(oResp, "stzcsrf", _csrf_, 0)   # readable: to be echoed
		oResp.Json([ "ok", 1,
		             "user", @oAuth.UserOfSession(pcToken),
		             "csrf", _csrf_ ])

	# end the session the cookie names. A cookie is AMBIENT authority, so a
	# cookie-authenticated logout must echo the CSRF token; a caller that passes the
	# token explicitly in the body is not ambient and needs no such proof.
	def _AuthLogout(oReq, oResp, aForm)
		_body_ = This._UrlDecode(This._FormValue(aForm, "token"))
		if _body_ != ""
			@oAuth.RevokeSession(_body_)
			oResp.Json([ "ok", 1 ])
			return
		ok
		_tok_ = This._CookieValue(oReq, "stzsession")
		if _tok_ = ""
			oResp.Status(401, "Unauthorized").Json([ "error", "no session" ])
			return
		ok
		if "" + oReq.Header("X-CSRF-Token") != This._CookieValue(oReq, "stzcsrf")
			oResp.Status(403, "Forbidden").Json([ "error", "csrf check failed" ])
			return
		ok
		@oAuth.RevokeSession(_tok_)
		This._ClearAuthCookie(oResp, "stzsession")
		This._ClearAuthCookie(oResp, "stzcsrf")
		oResp.Json([ "ok", 1 ])

	# who the caller is -- and what the AUTHZ layer says they may do (phase 5).
	def _AuthSession(oReq, oResp)
		_tok_ = This._CookieValue(oReq, "stzsession")
		_u_ = @oAuth.UserOfSession(_tok_)
		if _u_ = ""
			oResp.Status(401, "Unauthorized").Json([ "error", "no session" ])
			return
		ok
		_oAct_ = @oAuth.ActorOf(_tok_)
		_caps_ = ""
		if isObject(_oAct_)
			_aK_ = _oAct_.Kinds()
			_nK_ = len(_aK_)
			for _i_ = 1 to _nK_
				if _i_ > 1  _caps_ += ","  ok
				_caps_ += "" + _aK_[_i_]
			next
		ok
		oResp.Json([ "user", _u_,
		             "capabilities", _caps_,
		             "posture", _oAct_.Posture(),
		             "effectful", This._Bool01(@oAuth.SessionIsEffectful(_tok_)),
		             "roles", This._JoinList(@oAuth.RolesOf(_u_)) ])

	  #-- auth router helpers ---------------------------------------------

	# HttpOnly keeps a session cookie out of script; SameSite=Strict keeps it off
	# cross-site requests; Secure (behind TLS) keeps it off clear text.
	def _SetAuthCookie(oResp, pcName, pcValue, pbHttpOnly)
		_c_ = pcName + "=" + pcValue + "; Path=/; SameSite=Strict"
		if pbHttpOnly
			_c_ += "; HttpOnly"
		ok
		if @bSecureCookies
			_c_ += "; Secure"
		ok
		oResp.Header("Set-Cookie", _c_)

	def _ClearAuthCookie(oResp, pcName)
		oResp.Header("Set-Cookie", pcName + "=; Path=/; Max-Age=0; SameSite=Strict")

	# read one cookie out of the request's Cookie header ("" when absent).
	def _CookieValue(oReq, pcName)
		_h_ = "" + oReq.Header("Cookie")
		if _h_ = ""
			return ""
		ok
		_aP_ = StzSplit(_h_, ";")
		_n_ = len(_aP_)
		for _i_ = 1 to _n_
			_aKV_ = StzSplit(ring_trim("" + _aP_[_i_]), "=")
			if len(_aKV_) >= 2 and ring_trim("" + _aKV_[1]) = pcName
				return ring_trim("" + _aKV_[2])
			ok
		next
		return ""

	def _FormValue(aPairs, pcKey)
		_n_ = len(aPairs)
		for _i_ = 1 to _n_
			if aPairs[_i_][1] = pcKey
				return "" + aPairs[_i_][2]
			ok
		next
		return ""

	def _ClientIp(oReq)
		_f_ = "" + oReq.Header("X-Forwarded-For")
		if _f_ != ""
			return _f_
		ok
		return ""

	def _JoinList(paList)
		_out_ = ""
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if _i_ > 1  _out_ += ","  ok
			_out_ += "" + paList[_i_]
		next
		return _out_

	# percent-decoding (+ '+' as space). Byte-wise on purpose: the escapes are
	# ASCII, so decoding bytes reassembles correct UTF-8 for a non-ASCII value.
	def _UrlDecode(pcS)
		_s_ = "" + pcS
		if StzFindFirst("%", _s_) = 0 and StzFindFirst("+", _s_) = 0
			return _s_
		ok
		_out_ = ""
		_n_ = len(_s_)
		_i_ = 1
		while _i_ <= _n_
			_ch_ = _s_[_i_]
			if _ch_ = "+"
				_out_ += " "
				_i_++
			but _ch_ = "%" and _i_ + 2 <= _n_
				_out_ += char(This._HexPair(_s_[_i_ + 1], _s_[_i_ + 2]))
				_i_ += 3
			else
				_out_ += _ch_
				_i_++
			ok
		end
		return _out_

	def _HexPair(pcHi, pcLo)
		return This._HexDigit(pcHi) * 16 + This._HexDigit(pcLo)

	def _HexDigit(pcC)
		_a_ = ascii(pcC)
		if _a_ >= 48 and _a_ <= 57    return _a_ - 48 ok
		if _a_ >= 97 and _a_ <= 102   return _a_ - 87 ok
		if _a_ >= 65 and _a_ <= 70    return _a_ - 55 ok
		return 0

	# SPLIT-ONLY, never a positional slice: StzLeft/StzMidToEnd feed CODEPOINT
	# indices to a BYTE-addressed engine slice, so "dish=<arabic>" came back
	# truncated to half its bytes (verified 2026-07-23) -- every non-ASCII form
	# value POSTed to the MBaaS floor was silently corrupted. Splitting on "="
	# is codepoint-correct AND handles a value that itself contains "=".
	def _ParseFormBody(cBody)
		_aOut_ = []
		if cBody = ""
			return _aOut_
		ok
		_aPairs_ = StzSplit(cBody, "&")
		_nLen_ = len(_aPairs_)
		for _i_ = 1 to _nLen_
			_aKV_ = StzSplit(_aPairs_[_i_], "=")
			if len(_aKV_) >= 2
				_cVal_ = _aKV_[2]
				_nK_ = len(_aKV_)
				for _j_ = 3 to _nK_
					_cVal_ += ("=" + _aKV_[_j_])
				next
				_aOut_ + [ _aKV_[1], _cVal_ ]
			ok
		next
		return _aOut_

	def _SqlEscape(cVal)
		return StzReplace("" + cVal, "'", "''")

	# [[cell,cell],...] -> [["cell","cell"],...] (rows stay ARRAYS)
	def _RowsJson(aRows)
		_cOut_ = "["
		_nLen_ = len(aRows)
		for _i_ = 1 to _nLen_
			if _i_ > 1 _cOut_ += "," ok
			_cOut_ += "["
			_nCells_ = len(aRows[_i_])
			for _j_ = 1 to _nCells_
				if _j_ > 1 _cOut_ += "," ok
				_cOut_ += '"' + StzReplace("" + aRows[_i_][_j_], '"', '\"') + '"'
			next
			_cOut_ += "]"
		next
		return _cOut_ + "]"

	# IoT raw event. aListener = [ nSid, nPort, fHandler ].
	def _HandleRawEvent(aListener, aEv)
		if aEv[1] != :data
			return 0
		ok
		_fHandler_ = aListener[3]
		call _fHandler_(This, aListener[1], aEv[2], aEv[3])
		return 1

	  #--------------#
	 #  UTILITIES   #
	#--------------#

	# Parse one complete HTTP/1.1 request (the engine frames it: full
	# headers + Content-Length body, CRLF line endings).
	def ParseHttpRequest(cRawRequest)
		_cCRLF_ = char(13) + char(10)
		# split, don't slice: a multibyte BODY made StzMidToEnd compute its
		# length in codepoints and apply it as bytes, truncating the tail.
		_aHB_ = StzSplit(cRawRequest, _cCRLF_ + _cCRLF_)
		if len(_aHB_) < 2
			stzraise("Malformed HTTP request (no header terminator)")
		ok
		_cHead_ = _aHB_[1]
		_cBody_ = _aHB_[2]
		_nHB_ = len(_aHB_)
		for _k_ = 3 to _nHB_
			_cBody_ += (_cCRLF_ + _cCRLF_ + _aHB_[_k_])
		next
		_aLines_ = StzSplit(_cHead_, _cCRLF_)
		if len(_aLines_) = 0
			stzraise("Empty request")
		ok
		_aParts_ = @split(_aLines_[1], " ")
		if len(_aParts_) < 3
			stzraise("Invalid request line: " + _aLines_[1])
		ok
		_cMethod_ = StzUpper(_aParts_[1])
		_cPath_ = _aParts_[2]
		_cProtocol_ = StzUpper(_aParts_[3])
		_aHeaders_ = []
		_nLen_ = len(_aLines_)
		for _i_ = 2 to _nLen_
			_nColon_ = StzFindFirst(":", _aLines_[_i_])
			if _nColon_ > 0
				_aHeaders_ + [ trim(StzLeft(_aLines_[_i_], _nColon_ - 1)),
				               trim(StzMidToEnd(_aLines_[_i_], _nColon_ + 1)) ]
			ok
		next
		_oReq_ = new stzAppRequest(_cMethod_, _cPath_, _aHeaders_, _cBody_)
		_oReq_.SetProtocol(_cProtocol_)
		return _oReq_
