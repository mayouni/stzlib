
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
		# F5+TLS: both http AND https run async on the reactor now (curl
		# on a worker thread does native TLS -- no more blocking https).
		_cLow_ = StzLower("" + url)
		return (StzFindFirst("http://", _cLow_) = 1 or StzFindFirst("https://", _cLow_) = 1)

	# Submit an async request through the reactor's curl-backed HTTP job
	# (http + https, native TLS, redirects, real client). The job carries
	# the whole request; DrainPending dispatches the body on completion.
	def _SubmitAsync(cMethod, url, data, onSuccess, onError)
		_nCode_ = This._MethodCode(cMethod)
		_cBody_ = ""
		if isString(data) and data != ""
			_cBody_ = data
		ok
		_nJob_ = oReactor.SubmitHttp(_nCode_, "" + url, _cBody_)
		if _nJob_ < 1
			if onError != NULL
				call onError(HTTP_ERROR_REQUEST_FAILED)
			ok
			return -1
		ok
		aPending + [ _nJob_, onSuccess, onError ]
		return _nJob_

	def _MethodCode(cMethod)
		_cM_ = StzUpper("" + cMethod)
		if _cM_ = "GET"     return 0 ok
		if _cM_ = "POST"    return 1 ok
		if _cM_ = "PUT"     return 2 ok
		if _cM_ = "DELETE"  return 3 ok
		if _cM_ = "HEAD"    return 4 ok
		return 0

	# Called by the run loop each tick: dispatch every finished job. The
	# curl path returns the BODY directly (headers stripped) and reports
	# the HTTP status; success = a 2xx code (same callback contract as
	# the blocking download() path).
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
			_cBody_ = oReactor.PollHttp(_aEntry_[1])
			_nStatus_ = oReactor.HttpLastStatus()
			if _nStatus_ >= 200 and _nStatus_ < 300
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
