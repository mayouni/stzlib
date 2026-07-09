
#-------------------------------------------#
#  REACTIVE HTTP CLIENT - For web requests  #
#-------------------------------------------#

class stzReactiveHttp from stzObject

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def Get_(url, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_GET, url, HTTP_GET, HTTP_RESPONSE_NULL, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_
		
	def Post(url, data, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_POST, url, HTTP_POST, data, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Put_(url, data, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_PUT, url, HTTP_PUT, data, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Delete(url, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_DELETE, url, HTTP_DELETE, HTTP_RESPONSE_NULL, engine)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		engine.AddTask(_task_)
		_task_.Execute()
		return _task_

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
	    _status_ = TASK_RUNNING
	    
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
	        _status_ = TASK_COMPLETED
	        if onComplete != HTTP_RESPONSE_NULL
	            call onComplete(_result_)
	        ok
	    else
	        _status_ = TASK_ERROR
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
