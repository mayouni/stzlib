
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

# Sends HTTP requests for a reactive engine, asynchronously through a reactor when it has one and blocking otherwise.
#
# Get_, Post, Put_ and Delete take the address, the body where there is one, and a function for
# success and one for failure. With a reactor set by SetReactor, http and https requests are
# submitted as jobs and return a job number at once; the run loop calls DrainPending, which delivers
# each finished job to its callback, a 2xx status to onSuccess with the body and anything else to
# onError. Without a reactor, or for another kind of address, each verb runs a blocking stzHttpTask
# and returns it. None of the four verbs was run for this reference because they reach the network;
# the example uses what makes no request.
#
#   receiver   oEngine = new stzReactive() o1 = new stzReactiveHttp(oEngine)
#   example    ? o1.PendingCount()
#              #--> 0
#              ? o1.DrainPending()
#              #--> 0
#              o1.SetReactor(NULL)
#              ? o1.PendingCount()
#              #--> 0
#   see        stzHttpTask, stzReactor, stzHttpClient
class stzReactiveHttp from stzObject

	@oEngine = ""
	@oReactor = ""
	@aPending = []   # [ [ nJobId, fOnSuccess, fOnError ], ... ]

	# Builds an HTTP client for a reactive engine, with no reactor, so its requests are blocking until SetReactor gives one.
	#
	#   engine     the reactive engine the blocking tasks are registered with
	#   returns    nothing; the client is built
	#   see        SetReactor, Get_
	def Init(engine)
		@oEngine = engine

	# Sets the reactor that makes requests asynchronous, or removes it.
	#
	#   poReactor   a stzReactor, or NULL to go back to blocking requests
	#   returns     the client itself, so calls chain
	#   note        with a reactor, http and https requests are submitted as jobs and return at
	#               once; without one, or for any other address, each verb runs a blocking task
	#   see         PendingCount, DrainPending
	#@ aka  The reactor is what makes the request path ASYNC -- _CanAsync answers FALSE without one and every verb falls back to the blocking task. NULL is therefore a legitimate value: it means "no reactor, go blocking".
	def SetReactor(poReactor)
		if poReactor != "" and NOT isObject(poReactor)
			return This
		ok
		@oReactor = poReactor
		return This

	# Returns how many asynchronous requests have not been drained yet.
	#
	#   returns    a number; 0 for a new client
	#   see        DrainPending, Get_
	def PendingCount()
		return len(@aPending)

	# Sends a GET request and calls onSuccess with the body or onError with the failure text.
	#
	#   url         the address
	#   onSuccess   a function taking the response body
	#   onError     a function taking the failure text
	#   returns     a stzHttpTask, already executed, on the blocking path; the job number on the
	#               asynchronous path, -1 when the reactor refused it
	#   note        on the asynchronous path the callbacks run later, from DrainPending in the run
	#               loop; the failure text is HTTP request failed, with the status in parentheses
	#               when there is one
	#   warning     not run: it reaches the network
	#   see         Post, DrainPending, SetReactor
	def Get_(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("GET", url, $HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask($HTTP_TASK_GET, url, $HTTP_GET, $HTTP_RESPONSE_NULL, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	# Sends a POST request with a body and calls onSuccess with the response body or onError with the failure text.
	#
	#   url         the address
	#   data        the body to send
	#   onSuccess   a function taking the response body
	#   onError     a function taking the failure text
	#   returns     a stzHttpTask on the blocking path; the job number on the asynchronous path
	#   note        success is a status from 200 to 299
	#   warning     not run: it reaches the network
	#   see         Get_, Put_
	def Post(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("POST", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask($HTTP_TASK_POST, url, $HTTP_POST, data, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	# Sends a PUT request with a body and calls onSuccess with the response body or onError with the failure text.
	#
	#   url         the address
	#   data        the body to send
	#   onSuccess   a function taking the response body
	#   onError     a function taking the failure text
	#   returns     a stzHttpTask on the blocking path; the job number on the asynchronous path
	#   warning     not run: it reaches the network
	#   see         Post, Delete
	def Put_(url, data, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("PUT", url, data, onSuccess, onError)
		ok
		_task_ = new stzHttpTask($HTTP_TASK_PUT, url, $HTTP_PUT, data, @oEngine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		@oEngine.AddTask(_task_)
		_task_.Execute()
		return _task_

	# Sends a DELETE request and calls onSuccess with the response body or onError with the failure text.
	#
	#   url         the address
	#   onSuccess   a function taking the response body
	#   onError     a function taking the failure text
	#   returns     a stzHttpTask on the blocking path; the job number on the asynchronous path
	#   note        on the blocking path a delete answered with no body counts as a failure
	#   warning     not run: it reaches the network
	#   see         Get_, Put_
	def Delete(url, onSuccess, onError)
		if This._CanAsync(url)
			return This._SubmitAsync("DELETE", url, $HTTP_RESPONSE_NULL, onSuccess, onError)
		ok
		_task_ = new stzHttpTask($HTTP_TASK_DELETE, url, $HTTP_DELETE, $HTTP_RESPONSE_NULL, @oEngine)
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
				call onError($HTTP_ERROR_UNKNOWN_METHOD + " " + StzUpper("" + cMethod))
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
				call onError($HTTP_ERROR_REQUEST_FAILED)
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

	# Delivers every finished asynchronous request to its callback, for the run loop to call each tick.
	#
	#   returns    the number of requests delivered; 0 when none was pending or none had finished
	#   note       a 2xx status calls onSuccess with the body, any other status or a failed job
	#              calls onError; a job still in flight stays pending; run with nothing pending it
	#              answered 0
	#   see        PendingCount, SetReactor
	#@ aka  Called by the run loop each tick: dispatch every finished job. The curl path returns the BODY directly (headers stripped) and reports the HTTP status; success = a 2xx code (same callback contract as the blocking download() path).
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
					call _fErr_($HTTP_ERROR_REQUEST_FAILED)
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

# Holds one HTTP request, its method, address and body, with a status, a body result and an error, run by the blocking path.
#
# A task of the reactive client when no reactor is set. Execute sends the request through the engine
# and records completed with the response body for a 2xx status, or error with the message HTTP
# request failed, the status in parentheses when one was received. Anything but GET, POST, PUT or
# DELETE makes no request and ends in error. Then_ and Catch_ come from stzReactiveTask. The four
# Perform methods are the requests; none was run for this reference because they reach the network.
# The example runs the one path that makes no request.
#
#   receiver   oEngine = new stzReactive() o1 = new stzHttpTask(HTTP_TASK_GET,
#              "http://example.invalid/", "PATCH", "", oEngine)
#   example    ? o1.Status()
#              #--> pending
#              o1.Execute()
#              ? o1.Status()
#              #--> error
#              ? o1.Error()
#              #--> HTTP request failed
#              ? o1.HasFailed()
#              #--> 1
#   see        stzReactiveHttp, stzReactiveTask, stzHttpClient
class stzHttpTask from stzReactiveTask

	@url = $HTTP_RESPONSE_EMPTY
	@method = $HTTP_GET
	@data = $HTTP_RESPONSE_NULL
	@lastStatus = 0   # HTTP status of the blocking request, 0 = never got one
	
	# Builds a task for one HTTP request with its method, address and body, in the pending state.
	#
	#   id         the task's identifier, such as http_get
	#   url        the address
	#   method     GET, POST, PUT or DELETE as the HTTP_GET, HTTP_POST, HTTP_PUT and HTTP_DELETE
	#              constants
	#   data       the body to send, or an empty text
	#   engine     the reactive engine it belongs to
	#   returns    nothing; the task is built and no request is made
	#   note       the error mode is the default, ERROR_LOG
	#   see        Execute, stzReactiveHttp
	def Init(id, url, method, data, engine)
		super.Init(id, $HTTP_RESPONSE_NULL, engine, $DEFAULT_ERROR_HANDLING)
		@url = url
		@method = method
		@data = data
		
	# Sends the request by the blocking path and records the outcome on the task.
	#
	#   returns    nothing; read the outcome with Status, Result and Error
	#   note       success is a 2xx status with a body: the status is completed, the body is the
	#              result and Then_ is called; anything else is an error whose message is HTTP
	#              request failed, with the status in parentheses when one was received, and Catch_
	#              is called
	#   warning    not run against a real address: it reaches the network; a method that is none of
	#              the four makes no request and ends the task in error with the message HTTP
	#              request failed, which was run
	#   see        PerformHttpGet, Init
	def Execute()
	    # (S0 fix, 2026-07-14): store the status on the TASK, not in a
	    # local -- the old code wrote _status_ locally and dropped it,
	    # so task status was unreliable for HTTP.
	    @status = $TASK_RUNNING
	    
	    # Use Ring's built-in HTTP capabilities
	    if @method = $HTTP_GET
	        _result_ = PerformHttpGet(@url)
	    elseif @method = $HTTP_POST
	        _result_ = PerformHttpPost(@url, @data)
	    elseif @method = $HTTP_PUT
	        _result_ = PerformHttpPut(@url, @data)
	    elseif @method = $HTTP_DELETE
	        _result_ = PerformHttpDelete(@url)
	    else
	        _result_ = $HTTP_RESPONSE_NULL
	    ok
	    
	    # Check if we got a valid result
	    if _result_ != $HTTP_RESPONSE_NULL and _result_ != $HTTP_RESPONSE_EMPTY
	        @result = _result_
	        @status = $TASK_COMPLETED
	        if @onComplete != $HTTP_RESPONSE_NULL
	            call @onComplete(@result)
	        ok
	    else
	        @status = $TASK_ERROR

	        # Recorded on the task, not only handed to a handler that may not
	        # exist. Error() is inherited from stzReactiveTask, and an inherited
	        # accessor that answers "" for a task that failed is worse than no
	        # accessor at all. The status comes through the same helper the
	        # async drain uses, so both paths word a failure the same way.
	        @errorMsg = StzHttpFailureText(@lastStatus)
	        if @onError != $HTTP_RESPONSE_NULL
	            call @onError(@errorMsg)
	        ok
	    ok
			
	# Sends a GET request through the engine and returns the body, or an empty text on failure.
	#
	#   url        the address to fetch
	#   returns    the response body as text; an empty text for a status outside 200 to 299 or an
	#              empty body
	#   note       the status of the response is kept on the task for the failure message; this
	#              blocking path is what the client uses when it has no reactor
	#   warning    not run: it reaches the network
	#   see        Execute, PerformHttpPost
	#@ aka  THE BLOCKING PATH, ENGINE-BACKED.
	def PerformHttpGet(url)
	    return This._EngineRequest(0, url, $HTTP_RESPONSE_EMPTY)

	# Sends a POST request with a body through the engine and returns the response body, or an empty text on failure.
	#
	#   url        the address to post to
	#   data       the body to send, text
	#   returns    the response body as text; an empty text for a status outside 200 to 299 or an
	#              empty body
	#   note       a body that is not text is sent as an empty body
	#   warning    not run: it reaches the network
	#   see        Execute, PerformHttpGet
	def PerformHttpPost(url, data)
	    return This._EngineRequest(1, url, data)

	# Sends a PUT request with a body through the engine and returns the response body, or an empty text on failure.
	#
	#   url        the address to put to
	#   data       the body to send, text
	#   returns    the response body as text; an empty text for a status outside 200 to 299 or an
	#              empty body
	#   note       a body that is not text is sent as an empty body
	#   warning    not run: it reaches the network
	#   see        Execute, PerformHttpPost
	def PerformHttpPut(url, data)
	    return This._EngineRequest(2, url, data)

	# Sends a DELETE request through the engine and returns the response body, or an empty text on failure.
	#
	#   url        the address to delete
	#   returns    the response body as text; an empty text for a status outside 200 to 299 or an
	#              empty body
	#   note       a successful delete that answers with no body counts as a failure here
	#   warning    not run: it reaches the network
	#   see        Execute, PerformHttpGet
	def PerformHttpDelete(url)
	    return This._EngineRequest(3, url, $HTTP_RESPONSE_EMPTY)

	# One door for all four. The codes are the engine's own -- GET 0, POST 1,
	# PUT 2, DELETE 3 -- the same numbering the reactor's SubmitHttp takes and
	# the same _MethodCode produces. Zero timeouts mean "engine default".
	def _EngineRequest(pnCode, purl, pData)
	    _cBody_ = $HTTP_RESPONSE_EMPTY
	    if isString(pData)
	        _cBody_ = pData
	    ok

	    _cOut_ = StzEngineHttpRequestEx(pnCode, "" + purl, "", "", _cBody_, 0, 0, "")
	    @lastStatus = StzEngineHttpLastStatus()

	    # A non-2xx is a failure here, as it is on the async path. Returning the
	    # body would make Execute() call the SUCCESS handler with an error page.
	    if @lastStatus < 200 or @lastStatus > 299
	        return $HTTP_RESPONSE_EMPTY
	    ok
	    if _cOut_ = $HTTP_RESPONSE_NULL
	        return $HTTP_RESPONSE_EMPTY
	    ok
	    return _cOut_
