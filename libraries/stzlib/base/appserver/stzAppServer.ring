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
- MBaaS    : Expose(oDb, "table") -> REST floor over data/stzDatabase
             (GET list / GET count / POST insert), sqlite in the engine
- IoT      : ListenRaw(nPort, fHandler) -> raw per-connection byte
             streams (no HTTP framing) for device telemetry
- AGENTS   : the same event loop is the R5 perceive-decide-act spine;
             agent hosting lands with the reactor-runtime slice (R5
             deferred work), NOT stubbed here.

COLLAPSE RULINGS (5.10): stzContextPool folded into stzReactorPool
(real threads; the "context" abstraction predates the resident
engine); stzComputeEngine's preloads are subsumed by the engine being
resident by construction. Both files remain as documented tombstones.

SCOPE SIGILS: attributes are @-prefixed and method temps are _x_
wrapped -- bare class-head attributes CAPTURE same-named user globals
in Ring 1.27 (verified 2026-07-14: a user global `oClient` was
clobbered at `new stzAppResponse(...)`, then R12 on the attribute).
*/

func StzAppServerQ()
	return new stzAppServer()

class stzAppServer from stzObject

	# Core infrastructure
	@oReactor = NULL          # the libuv loop (owned)
	@oRouter = NULL
	@nServerId = 0            # HTTP listener id on the reactor
	@nBoundPort = 0
	@cHost = "127.0.0.1"
	@bRunning = False

	# IoT raw listeners: [ [ nSid, nPort, fHandler ], ... ]
	@aRawListeners = []

	# MBaaS resources: [ [ cTable, oDb ], ... ]
	@aResources = []

	# Monitoring
	@nRequestCount = 0
	@nStartMs = 0

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
		if cHostAddr = NULL or cHostAddr = ""
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
		@bRunning = True
		@nStartMs = StzEngineTimeNowMs()
		return True

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
		@oReactor = NULL
		@nServerId = 0
		@aRawListeners = []
		@bRunning = False
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
		_nDeadline_ = StzEngineTimeNowMs() + nTimeoutMs
		while TRUE
			# HTTP listener (non-blocking drain)
			_aEv_ = @oReactor.ServerPoll(@nServerId)
			if len(_aEv_) > 0
				if This._HandleHttpEvent(_aEv_)
					return TRUE
				ok
				loop
			ok
			# raw listeners (IoT)
			_bDidWork_ = FALSE
			_nLen_ = len(@aRawListeners)
			for _i_ = 1 to _nLen_
				_aEvR_ = @oReactor.ServerPoll(@aRawListeners[_i_][1])
				if len(_aEvR_) > 0
					if This._HandleRawEvent(@aRawListeners[_i_], _aEvR_)
						_bDidWork_ = TRUE
					ok
				ok
			next
			if _bDidWork_
				return TRUE
			ok
			if StzEngineTimeNowMs() >= _nDeadline_
				return FALSE
			ok
			# nothing pending: park briefly on the HTTP listener
			_aEv_ = @oReactor.ServerAwait(@nServerId, 10)
			if len(_aEv_) > 0
				if This._HandleHttpEvent(_aEv_)
					return TRUE
				ok
			ok
		end

	# Serve every event that arrives within nMs (a bounded Run()).
	def RunFor(nMs)
		_nDeadline_ = StzEngineTimeNowMs() + nMs
		while StzEngineTimeNowMs() < _nDeadline_
			_nLeft_ = _nDeadline_ - StzEngineTimeNowMs()
			if _nLeft_ < 1
				exit
			ok
			This.ServeOne(_nLeft_)
		end
		return This

	# Serve forever (until the process is killed or Stop() is called
	# from a handler). The documented blocking entry point.
	def Run()
		while @bRunning
			This.ServeOne(1000)
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

	def Use(cPath, fMiddleware)
		@oRouter.AddMiddleware(cPath, fMiddleware)
		return This

	def Static(cPath, cDirectory)
		@oRouter.AddStaticRoute(cPath, cDirectory)
		return This

	  #--------------------------------#
	 #  MBaaS: REST OVER stzDatabase  #
	#--------------------------------#

	# Expose a table of an open stzDatabase as a REST resource:
	#   GET  /api/<table>        -> {"rows":[[...],...]}
	#   GET  /api/<table>/count  -> {"count":N}
	#   POST /api/<table>        -> body "col=val&col2=val2" inserts a row
	def Expose(oDb, cTable)
		@aResources + [ cTable, oDb ]
		return This

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
			return FALSE   # accept/closed: connection registry only
		ok
		_nConn_ = aEv[2]
		@nRequestCount++
		_oResp_ = new stzAppResponse(NULL)
		_bClose_ = TRUE
		try
			_oReq_ = This.ParseHttpRequest(aEv[3])
			_bClose_ = _oReq_.WantsClose()
			This._Dispatch(_oReq_, _oResp_)
		catch
			_oResp_.Status(400, "Bad Request").Text("Bad request: " + cCatchError)
		done
		if NOT _oResp_.IsSent()
			_oResp_.Text("")   # handler set nothing: empty 200
		ok
		@oReactor.ServerWrite(@nServerId, _nConn_, _oResp_.HttpBytes(), _bClose_)
		return TRUE

	def _Dispatch(oReq, oResp)
		try
			if @oRouter.HasRoute(oReq.Method(), oReq.Path())
				_fHandler_ = @oRouter.GetHandler(oReq.Method(), oReq.Path())
				call _fHandler_(oReq, oResp)
			but This._ServeResource(oReq, oResp)
				# handled by the MBaaS floor
			but oReq.Method() = "GET" and oReq.Path() = "/health"
				oResp.Json([
					"status", "healthy",
					"engine", "softanza-resident",
					"uptime_s", This.Uptime(),
					"requests_served", @nRequestCount
				])
			else
				oResp.NotFound("Route not found: " + oReq.Method() + " " + oReq.Path())
			ok
		catch
			oResp.InternalError("Handler error: " + cCatchError)
		done

	# MBaaS floor. Returns TRUE when the path targeted an exposed table.
	def _ServeResource(oReq, oResp)
		if StzFindFirst(oReq.Path(), "/api/") != 1
			return FALSE
		ok
		_cRest_ = StzMidToEnd(oReq.Path(), 6)     # after "/api/"
		_bCount_ = FALSE
		_nSlash_ = StzFindFirst(_cRest_, "/")
		if _nSlash_ > 0
			_cSub_ = StzMidToEnd(_cRest_, _nSlash_ + 1)
			_cRest_ = StzLeft(_cRest_, _nSlash_ - 1)
			if _cSub_ = "count"
				_bCount_ = TRUE
			else
				return FALSE
			ok
		ok
		_oDb_ = NULL
		_nLen_ = len(@aResources)
		for _i_ = 1 to _nLen_
			if @aResources[_i_][1] = _cRest_
				_oDb_ = @aResources[_i_][2]
				exit
			ok
		next
		if _oDb_ = NULL
			return FALSE
		ok
		_cTable_ = _cRest_
		if oReq.Method() = "GET"
			if _bCount_
				# ring_number(), not 0+str: the 0+str coercion is
				# poisoned after any caught raise (Ring trap).
				oResp.Header("Content-Type", "application/json")
				oResp.Send('{"count":' + ring_number(_oDb_.Value("SELECT COUNT(*) FROM " + _cTable_)) + '}')
			else
				# rows are ARRAYS of cells -- ObjectToJson would misread
				# a 2-cell row as a {k:v} object, so serialize directly
				oResp.Header("Content-Type", "application/json")
				oResp.Send('{"rows":' + This._RowsJson(_oDb_.Rows("SELECT * FROM " + _cTable_)) + '}')
			ok
			return TRUE
		but oReq.Method() = "POST"
			_aPairs_ = This._ParseFormBody(oReq.Body())
			if len(_aPairs_) = 0
				oResp.Status(400, "Bad Request").Json([ "error", "empty form body" ])
				return TRUE
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
			return TRUE
		ok
		oResp.Status(405, "Method Not Allowed").Json([ "error", "method not allowed" ])
		return TRUE

	def _ParseFormBody(cBody)
		_aOut_ = []
		if cBody = ""
			return _aOut_
		ok
		_aPairs_ = StzSplit(cBody, "&")
		_nLen_ = len(_aPairs_)
		for _i_ = 1 to _nLen_
			_nEq_ = StzFindFirst(_aPairs_[_i_], "=")
			if _nEq_ > 0
				_aOut_ + [ StzLeft(_aPairs_[_i_], _nEq_ - 1), StzMidToEnd(_aPairs_[_i_], _nEq_ + 1) ]
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
			return FALSE
		ok
		_fHandler_ = aListener[3]
		call _fHandler_(This, aListener[1], aEv[2], aEv[3])
		return TRUE

	  #--------------#
	 #  UTILITIES   #
	#--------------#

	# Parse one complete HTTP/1.1 request (the engine frames it: full
	# headers + Content-Length body, CRLF line endings).
	def ParseHttpRequest(cRawRequest)
		_cCRLF_ = char(13) + char(10)
		_nHeadEnd_ = StzFindFirst(cRawRequest, _cCRLF_ + _cCRLF_)
		if _nHeadEnd_ = 0
			stzraise("Malformed HTTP request (no header terminator)")
		ok
		_cHead_ = StzLeft(cRawRequest, _nHeadEnd_ - 1)
		_cBody_ = StzMidToEnd(cRawRequest, _nHeadEnd_ + 4)
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
			_nColon_ = StzFindFirst(_aLines_[_i_], ":")
			if _nColon_ > 0
				_aHeaders_ + [ trim(StzLeft(_aLines_[_i_], _nColon_ - 1)),
				               trim(StzMidToEnd(_aLines_[_i_], _nColon_ + 1)) ]
			ok
		next
		_oReq_ = new stzAppRequest(_cMethod_, _cPath_, _aHeaders_, _cBody_)
		_oReq_.SetProtocol(_cProtocol_)
		return _oReq_
