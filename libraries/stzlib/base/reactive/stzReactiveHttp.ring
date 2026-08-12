
#-------------------------------------------#
#  HTTP CLIENT - For web requests           #
#-------------------------------------------#
# F5 + TLS (2026-07-14): http AND https requests DELEGATE TO THE
# REACTOR -- Get_/Post/etc. submit an async curl-backed job (native
# Schannel TLS on a libuv worker thread) and return immediately; the
# RunLoop drains completions (DrainPending) and dispatches onSuccess/
# onError on the Ring thread. Only the no-DLL fallback (no reactor
# present) still takes the blocking curl/download path. The old
# "https is an outbound-TLS gap" caveat is closed.

class stzReactiveHttp from stzObject

	@oEngine = ""
	@oReactor = ""
	@aPending = []   # [ [ nJobId, fOnSuccess, fOnError ], ... ]

	def Init(engine)
		@oEngine = engine

	# The reactor is what makes the request path ASYNC -- _CanAsync answers
	# FALSE without one and every verb falls back to the blocking task. NULL is
	# therefore a legitimate value: it means "no reactor, go blocking".
	#
	# Anything that is neither is refused rather than stored, because a bad
	# reactor does not fail here; it fails later inside _SubmitAsync or
	# DrainPending, a long way from the call that caused it.
	def SetReactor(poReactor)
		if poReactor != "" and NOT isObject(poReactor)
			return This
		ok
		@oReactor = poReactor
		return This

	def PendingCount()
		return len(@aPending)

	def Get_(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("GET", url, HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_GET, url, HTTP_GET, HTTP_RESPONSE_NULL, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Post(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("POST", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_POST, url, HTTP_POST, data, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Put_(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("PUT", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_PUT, url, HTTP_PUT, data, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Delete(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("DELETE", url, HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_DELETE, url, HTTP_DELETE, HTTP_RESPONSE_NULL, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	#--- F5: the async path over the reactor -------------------

	def _CanAsync(url)
		if @oReactor = ""
			return 0
		ok
		# F5+TLS: both http AND https run async on the reactor now (curl
		# on a worker thread does native TLS -- no more blocking https).
		_cLow_ = StzLower("" + url)
		return (StzFindFirst("http://", _cLow_) = 1 or StzFindFirst("https://", _cLow_) = 1)

	# Submit an async request through the reactor's curl-backed HTTP job
	# (http + https, native TLS, redirects, real client). The job carries
	# the whole request; DrainPending dispatches the body on completion.
	def _SubmitAsync(cMethod, url, data, onSuccess, onError)
		_nCode_ = This._MethodCode(cMethod)
		if _nCode_ < 0
			if onError != ""
				call onError(HTTP_ERROR_UNKNOWN_METHOD + " " + StzUpper("" + cMethod))
			ok
			return -1
		ok

		_cBody_ = ""
		if isString(data) and data != ""
			_cBody_ = data
		ok
		_nJob_ = @oReactor.SubmitHttp(_nCode_, "" + url, _cBody_)
		if _nJob_ < 1
			if onError != ""
				call onError(HTTP_ERROR_REQUEST_FAILED)
			ok
			return -1
		ok
		@aPending + [ _nJob_, onSuccess, onError ]
		return _nJob_

	# A verb this path cannot issue answers -1, not 0.
	#
	# The fallback used to be `return 0`, which is GET -- so an unrecognised
	# method silently became a different request than the one asked for. The
	# four public verbs all pass literals, so nothing reaches it today; that is
	# what makes it worth closing now rather than after something does.
	#
	# HEAD is mapped and the reactor supports it, though no public Head() method
	# offers it yet.
	def _MethodCode(cMethod)
		_cM_ = StzUpper("" + cMethod)
		if _cM_ = "GET"     return 0 ok
		if _cM_ = "POST"    return 1 ok
		if _cM_ = "PUT"     return 2 ok
		if _cM_ = "DELETE"  return 3 ok
		if _cM_ = "HEAD"    return 4 ok
		return -1

	# The failure text a callback receives. It keeps the familiar wording so a
	# caller matching on it still matches, and adds the STATUS when one is
	# known -- DrainPending has it in hand and used to throw it away, so a 404
	# and a 500 reached the caller as the same seven words.
	#
	# A refused connection has no status at all, and none is invented.
	def _HttpFailure(pnStatus)
		return StzHttpFailureText(pnStatus)

	# Called by the run loop each tick: dispatch every finished job. The
	# curl path returns the BODY directly (headers stripped) and reports
	# the HTTP status; success = a 2xx code (same callback contract as
	# the blocking download() path).
	def DrainPending()
		_nDone_ = 0
		for _i_ = len(@aPending) to 1 step -1
			_nState_ = @oReactor.JobState(@aPending[_i_][1])
			if _nState_ = -1
				loop   # still in flight
			ok
			_aEntry_ = @aPending[_i_]
			del(@aPending, _i_)
			_nDone_++
			# Ring's `call` needs a plain variable, not an indexed expr
			_fOk_ = _aEntry_[2]
			_fErr_ = _aEntry_[3]
			if _nState_ = -2
				if _fErr_ != ""
					call _fErr_(HTTP_ERROR_REQUEST_FAILED)
				ok
				loop
			ok
			_cBody_ = @oReactor.PollHttp(_aEntry_[1])
			_nStatus_ = @oReactor.HttpLastStatus()
			if _nStatus_ >= 200 and _nStatus_ < 300
				if _fOk_ != ""
					call _fOk_(_cBody_)
				ok
			else
				if _fErr_ != ""
					call _fErr_(This._HttpFailure(_nStatus_))
				ok
			ok
		next
		return _nDone_

class stzHttpTask from stzReactiveTask

	@url = HTTP_RESPONSE_EMPTY
	@method = HTTP_GET
	@data = HTTP_RESPONSE_NULL
	@lastStatus = 0   # HTTP status of the blocking request, 0 = never got one
	
	def Init(id, url, method, data, engine)
		super.Init(id, HTTP_RESPONSE_NULL, engine, DEFAULT_ERROR_HANDLING)
		@url = url
		@method = method
		@data = data
		
	def Execute()
	    # (S0 fix, 2026-07-14): store the status on the TASK, not in a
	    # local -- the old code wrote _status_ locally and dropped it,
	    # so task status was unreliable for HTTP.
	    @status = TASK_RUNNING
	    
	    # Use Ring's built-in HTTP capabilities
	    if @method = HTTP_GET
	        _result_ = PerformHttpGet(@url)
	    elseif @method = HTTP_POST
	        _result_ = PerformHttpPost(@url, @data)
	    elseif @method = HTTP_PUT
	        _result_ = PerformHttpPut(@url, @data)
	    elseif @method = HTTP_DELETE
	        _result_ = PerformHttpDelete(@url)
	    else
	        _result_ = HTTP_RESPONSE_NULL
	    ok
	    
	    # Check if we got a valid result
	    if _result_ != HTTP_RESPONSE_NULL and _result_ != HTTP_RESPONSE_EMPTY
	        @result = _result_
	        @status = TASK_COMPLETED
	        if @onComplete != HTTP_RESPONSE_NULL
	            call @onComplete(@result)
	        ok
	    else
	        @status = TASK_ERROR

	        # Recorded on the task, not only handed to a handler that may not
	        # exist. Error() is inherited from stzReactiveTask, and an inherited
	        # accessor that answers "" for a task that failed is worse than no
	        # accessor at all. The status comes through the same helper the
	        # async drain uses, so both paths word a failure the same way.
	        @errorMsg = StzHttpFailureText(@lastStatus)
	        if @onError != HTTP_RESPONSE_NULL
	            call @onError(@errorMsg)
	        ok
	    ok
			
	# THE BLOCKING PATH, ENGINE-BACKED.
	#
	# These called Ring's download() and then the raw libcurl.ring API --
	# curl_easy_init / curl_easy_setopt / CURLOPT_* / curl_easy_perform_silent.
	# The library dropped that extension when HTTP moved into the Zig engine
	# (stzHttpClient and stzNetwork both say so: "previously loaded
	# libcurl.ring"), and nothing loads it now. Every verb here raised R3
	# "Calling Function without definition" on its first line.
	#
	# This is the path taken when there is no reactor -- which is exactly what
	# SetReactor(NULL) selects, and what the reactor switch falls back TO. The
	# switch had an off position that could not work.
	def PerformHttpGet(url)
	    return This._EngineRequest(0, url, HTTP_RESPONSE_EMPTY)

	def PerformHttpPost(url, data)
	    return This._EngineRequest(1, url, data)

	def PerformHttpPut(url, data)
	    return This._EngineRequest(2, url, data)

	def PerformHttpDelete(url)
	    return This._EngineRequest(3, url, HTTP_RESPONSE_EMPTY)

	# One door for all four. The codes are the engine's own -- GET 0, POST 1,
	# PUT 2, DELETE 3 -- the same numbering the reactor's SubmitHttp takes and
	# the same _MethodCode produces. Zero timeouts mean "engine default".
	def _EngineRequest(pnCode, purl, pData)
	    _cBody_ = HTTP_RESPONSE_EMPTY
	    if isString(pData)
	        _cBody_ = pData
	    ok

	    _cOut_ = StzEngineHttpRequestEx(pnCode, "" + purl, "", "", _cBody_, 0, 0, "")
	    @lastStatus = StzEngineHttpLastStatus()

	    # A non-2xx is a failure here, as it is on the async path. Returning the
	    # body would make Execute() call the SUCCESS handler with an error page.
	    if @lastStatus < 200 or @lastStatus > 299
	        return HTTP_RESPONSE_EMPTY
	    ok
	    if _cOut_ = HTTP_RESPONSE_NULL
	        return HTTP_RESPONSE_EMPTY
	    ok
	    return _cOut_
