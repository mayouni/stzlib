
#-------------------------------------------#
#  HTTP CLIENT - For web requests           #
#-------------------------------------------#
# F5 (2026-07-14): plain-http requests now DELEGATE TO THE REACTOR --
# Get_/Post/etc. submit an async TCP request on the libuv loop and
# return immediately; the RunLoop drains completions (DrainPending)
# and dispatches onSuccess/onError on the Ring thread. Two documented
# exceptions still take the BLOCKING curl/download path:
#   * https:// URLs (outbound TLS is an engine gap -- 5.10), and
#   * the no-DLL fallback (no reactor present).

class stzReactiveHttp from stzObject

	engine = NULL
	oReactor = NULL
	aPending = []   # [ [ nJobId, fOnSuccess, fOnError ], ... ]

	def Init(engine)
		this.engine = engine

	def SetReactor(poReactor)
		oReactor = poReactor

	def PendingCount()
		return len(aPending)

	def Get_(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("GET", url, HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_GET, url, HTTP_GET, HTTP_RESPONSE_NULL, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Post(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("POST", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_POST, url, HTTP_POST, data, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Put_(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("PUT", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_PUT, url, HTTP_PUT, data, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Delete(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("DELETE", url, HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask(HTTP_TASK_DELETE, url, HTTP_DELETE, HTTP_RESPONSE_NULL, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	#--- F5: the async path over the reactor -------------------

	def _CanAsync(url)
		if oReactor = NULL
			return FALSE
		ok
		return StzFindFirst(StzLower("" + url), "http://") = 1

	# Parse http://host[:port]/path, build the wire request, submit it
	# on the loop thread, remember the job. Returns the job id (>0).
	def _SubmitAsync(cMethod, url, data, onSuccess, onError)
		_cRest_ = StzMidToEnd("" + url, 8)          # after "http://"
		_cPath_ = "/"
		_nSlash_ = StzFindFirst(_cRest_, "/")
		if _nSlash_ > 0
			_cPath_ = StzMidToEnd(_cRest_, _nSlash_)
			_cRest_ = StzLeft(_cRest_, _nSlash_ - 1)
		ok
		_nPort_ = 80
		_nColon_ = StzFindFirst(_cRest_, ":")
		if _nColon_ > 0
			_nPort_ = ring_number(StzMidToEnd(_cRest_, _nColon_ + 1))
			_cRest_ = StzLeft(_cRest_, _nColon_ - 1)
		ok
		_cCRLF_ = char(13) + char(10)
		_cBody_ = ""
		if isString(data) and data != ""
			_cBody_ = data
		ok
		_cReq_ = cMethod + " " + _cPath_ + " HTTP/1.1" + _cCRLF_ +
		         "Host: " + _cRest_ + _cCRLF_ +
		         "User-Agent: " + USER_AGENT_REACTIVE + _cCRLF_ +
		         "Content-Length: " + len(_cBody_) + _cCRLF_ +
		         "Connection: close" + _cCRLF_ + _cCRLF_ + _cBody_
		_nJob_ = oReactor.SubmitTcp(_cRest_, _nPort_, _cReq_)
		if _nJob_ < 1
			if onError != NULL
				call onError(HTTP_ERROR_REQUEST_FAILED)
			ok
			return -1
		ok
		aPending + [ _nJob_, onSuccess, onError ]
		return _nJob_

	# Called by the run loop each tick: dispatch every finished job.
	# Success = 2xx status line; the callback receives the BODY (same
	# contract as the blocking download() path).
	def DrainPending()
		_nDone_ = 0
		for _i_ = len(aPending) to 1 step -1
			_nState_ = oReactor.JobState(aPending[_i_][1])
			if _nState_ = -1
				loop   # still in flight
			ok
			_aEntry_ = aPending[_i_]
			del(aPending, _i_)
			_nDone_++
			# Ring's `call` needs a plain variable, not an indexed expr
			_fOk_ = _aEntry_[2]
			_fErr_ = _aEntry_[3]
			if _nState_ = -2
				if _fErr_ != NULL
					call _fErr_(HTTP_ERROR_REQUEST_FAILED)
				ok
				loop
			ok
			_cResp_ = oReactor.PollTcp(_aEntry_[1])
			if oReactor.TcpLastStatus() != 0
				if _fErr_ != NULL
					call _fErr_(HTTP_ERROR_REQUEST_FAILED)
				ok
				loop
			ok
			# split status line + headers from the body
			_cCRLF_ = char(13) + char(10)
			_nHe_ = StzFindFirst(_cResp_, _cCRLF_ + _cCRLF_)
			_cBody_ = _cResp_
			_bOk_ = TRUE
			if _nHe_ > 0
				_cBody_ = StzMidToEnd(_cResp_, _nHe_ + 4)
				# 2xx = the digit right after the first space is "2"
				_nSp_ = StzFindFirst(_cResp_, " ")
				_bOk_ = (_nSp_ > 0 and StzLeft(StzMidToEnd(_cResp_, _nSp_ + 1), 1) = "2")
			ok
			if _bOk_
				if _fOk_ != NULL
					call _fOk_(_cBody_)
				ok
			else
				if _fErr_ != NULL
					call _fErr_(HTTP_ERROR_REQUEST_FAILED)
				ok
			ok
		next
		return _nDone_

class stzHttpTask from stzReactiveTask

	url = HTTP_RESPONSE_EMPTY
	method = HTTP_GET
	data = HTTP_RESPONSE_NULL
	
	def Init(id, url, method, data, engine)
		super.Init(id, HTTP_RESPONSE_NULL, engine, DEFAULT_ERROR_HANDLING)
		this.url = url
		this.method = method
		this.data = data
		
	def Execute()
	    # (S0 fix, 2026-07-14): store the status on the TASK, not in a
	    # local -- the old code wrote _status_ locally and dropped it,
	    # so task status was unreliable for HTTP.
	    status = TASK_RUNNING
	    
	    # Use Ring's built-in HTTP capabilities
	    if method = HTTP_GET
	        _result_ = PerformHttpGet(url)
	    elseif method = HTTP_POST
	        _result_ = PerformHttpPost(url, data)
	    elseif method = HTTP_PUT
	        _result_ = PerformHttpPut(url, data)
	    elseif method = HTTP_DELETE
	        _result_ = PerformHttpDelete(url)
	    else
	        _result_ = HTTP_RESPONSE_NULL
	    ok
	    
	    # Check if we got a valid result
	    if _result_ != HTTP_RESPONSE_NULL and _result_ != HTTP_RESPONSE_EMPTY
	        status = TASK_COMPLETED
	        if onComplete != HTTP_RESPONSE_NULL
	            call onComplete(_result_)
	        ok
	    else
	        status = TASK_ERROR
	        if onError != HTTP_RESPONSE_NULL
	            call onError(HTTP_ERROR_REQUEST_FAILED)
	        ok
	    ok
			
	# Helper methods for HTTP operations
	def PerformHttpGet(url)
	    _result_ = download(url)
	    if _result_ = HTTP_RESPONSE_NULL
	        _result_ = HTTP_RESPONSE_EMPTY
	    ok
	    return _result_

	def PerformHttpPost(url, data)
	    return PerformHttpWithData(url, HTTP_POST, data)

	def PerformHttpPut(url, data)
	    return PerformHttpWithData(url, HTTP_PUT, data)

	def PerformHttpDelete(url)
	    return PerformHttpWithData(url, HTTP_DELETE, HTTP_RESPONSE_NULL)

	def PerformHttpWithData(url, method, data)
	    # Initialize curl
	    _curl_ = curl_easy_init()
	    if _curl_ = HTTP_RESPONSE_NULL
	        return HTTP_RESPONSE_EMPTY
	    ok
	    
	    # Set basic options
	    curl_easy_setopt(_curl_, CURLOPT_USERAGENT, USER_AGENT_REACTIVE)
	    curl_easy_setopt(_curl_, CURLOPT_URL, url)
	    curl_easy_setopt(_curl_, CURLOPT_TIMEOUT, CURL_TIMEOUT_DEFAULT)
	    curl_easy_setopt(_curl_, CURLOPT_CONNECTTIMEOUT, CURL_CONNECT_TIMEOUT_DEFAULT)
	    
	    # Set method-specific options
	    if method = HTTP_POST
	        curl_easy_setopt(_curl_, CURLOPT_POST, 1)
	    elseif method = HTTP_PUT
	        curl_easy_setopt(_curl_, CURLOPT_CUSTOMREQUEST, HTTP_PUT)
	    elseif method = HTTP_DELETE
	        curl_easy_setopt(_curl_, CURLOPT_CUSTOMREQUEST, HTTP_DELETE)
	    ok
	    
	    # Set POST/PUT data
	    if data != HTTP_RESPONSE_NULL and data != HTTP_RESPONSE_EMPTY
	        if isString(data)
	            postData = data
	        else
	            # Convert list/object to query string format
	            postData = HTTP_RESPONSE_EMPTY
	            # Simple conversion - extend as needed
	        ok
	        curl_easy_setopt(_curl_, CURLOPT_POSTFIELDS, postData)
	    ok
	    
	    # Perform request and get response content
	    _result_ = curl_easy_perform_silent(_curl_)
	    
	    # Cleanup
	    curl_easy_cleanup(_curl_)
	    
	    # Return result or empty string on failure
	    if _result_ = HTTP_RESPONSE_NULL
	        _result_ = HTTP_RESPONSE_EMPTY
	    ok
	    return _result_
