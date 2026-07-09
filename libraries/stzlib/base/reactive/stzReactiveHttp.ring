
#-------------------------------------------#
#  REACTIVE HTTP CLIENT - For web requests  #
#-------------------------------------------#

class stzReactiveHttp from stzObject

	_engine_ = NULL
	
	def Init(_engine_)
		this.engine = _engine_
		
	def Get_(_url_, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_GET, _url_, HTTP_GET, HTTP_RESPONSE_NULL, _engine_)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		_engine_.AddTask(_task_)
		_task_.Execute()
		return _task_
		
	def Post(_url_, _data_, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_POST, _url_, HTTP_POST, _data_, _engine_)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		_engine_.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Put_(_url_, _data_, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_PUT, _url_, HTTP_PUT, _data_, _engine_)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		_engine_.AddTask(_task_)
		_task_.Execute()
		return _task_

	def Delete(_url_, onSuccess, onError)
		_task_ = new stzHttpTask(HTTP_TASK_DELETE, _url_, HTTP_DELETE, HTTP_RESPONSE_NULL, _engine_)
		_task_.Then_(onSuccess)
		_task_.Catch_(onError)
		_engine_.AddTask(_task_)
		_task_.Execute()
		return _task_

class stzHttpTask from stzReactiveTask

	_url_ = HTTP_RESPONSE_EMPTY
	_method_ = HTTP_GET
	_data_ = HTTP_RESPONSE_NULL
	
	def Init(id, _url_, _method_, _data_, _engine_)
		super.Init(id, HTTP_RESPONSE_NULL, _engine_, DEFAULT_ERROR_HANDLING)
		this.url = _url_
		this.method = _method_
		this.data = _data_
		
	def Execute()
	    _status_ = TASK_RUNNING
	    
	    # Use Ring's built-in HTTP capabilities
	    if _method_ = HTTP_GET
	        _result_ = PerformHttpGet(_url_)
	    elseif _method_ = HTTP_POST
	        _result_ = PerformHttpPost(_url_, _data_)
	    elseif _method_ = HTTP_PUT
	        _result_ = PerformHttpPut(_url_, _data_)
	    elseif _method_ = HTTP_DELETE
	        _result_ = PerformHttpDelete(_url_)
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
	def PerformHttpGet(_url_)
	    _result_ = download(_url_)
	    if _result_ = HTTP_RESPONSE_NULL
	        _result_ = HTTP_RESPONSE_EMPTY
	    ok
	    return _result_

	def PerformHttpPost(_url_, _data_)
	    return PerformHttpWithData(_url_, HTTP_POST, _data_)

	def PerformHttpPut(_url_, _data_)
	    return PerformHttpWithData(_url_, HTTP_PUT, _data_)

	def PerformHttpDelete(_url_)
	    return PerformHttpWithData(_url_, HTTP_DELETE, HTTP_RESPONSE_NULL)

	def PerformHttpWithData(_url_, _method_, _data_)
	    # Initialize curl
	    _curl_ = curl_easy_init()
	    if _curl_ = HTTP_RESPONSE_NULL
	        return HTTP_RESPONSE_EMPTY
	    ok
	    
	    # Set basic options
	    curl_easy_setopt(_curl_, CURLOPT_USERAGENT, USER_AGENT_REACTIVE)
	    curl_easy_setopt(_curl_, CURLOPT_URL, _url_)
	    curl_easy_setopt(_curl_, CURLOPT_TIMEOUT, CURL_TIMEOUT_DEFAULT)
	    curl_easy_setopt(_curl_, CURLOPT_CONNECTTIMEOUT, CURL_CONNECT_TIMEOUT_DEFAULT)
	    
	    # Set method-specific options
	    if _method_ = HTTP_POST
	        curl_easy_setopt(_curl_, CURLOPT_POST, 1)
	    elseif _method_ = HTTP_PUT
	        curl_easy_setopt(_curl_, CURLOPT_CUSTOMREQUEST, HTTP_PUT)
	    elseif _method_ = HTTP_DELETE
	        curl_easy_setopt(_curl_, CURLOPT_CUSTOMREQUEST, HTTP_DELETE)
	    ok
	    
	    # Set POST/PUT data
	    if _data_ != HTTP_RESPONSE_NULL and _data_ != HTTP_RESPONSE_EMPTY
	        if isString(_data_)
	            postData = _data_
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
