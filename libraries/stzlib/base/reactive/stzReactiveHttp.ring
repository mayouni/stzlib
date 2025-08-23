
#-------------------------------------------#
#  REACTIVE HTTP CLIENT - For web requests  #
#-------------------------------------------#

class stzReactiveHttp

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def Get_(url, onSuccess, onError)
		task = new stzHttpTask(HTTP_TASK_GET, url, HTTP_GET, HTTP_RESPONSE_NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def Post(url, data, onSuccess, onError)
		task = new stzHttpTask(HTTP_TASK_POST, url, HTTP_POST, data, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def Put_(url, data, onSuccess, onError)
		task = new stzHttpTask(HTTP_TASK_PUT, url, HTTP_PUT, data, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

	def Delete(url, onSuccess, onError)
		task = new stzHttpTask(HTTP_TASK_DELETE, url, HTTP_DELETE, HTTP_RESPONSE_NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

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
	    status = TASK_RUNNING
	    
	    # Use Ring's built-in HTTP capabilities
	    if method = HTTP_GET
	        result = PerformHttpGet(url)
	    elseif method = HTTP_POST
	        result = PerformHttpPost(url, data)
	    elseif method = HTTP_PUT
	        result = PerformHttpPut(url, data)
	    elseif method = HTTP_DELETE
	        result = PerformHttpDelete(url)
	    else
	        result = HTTP_RESPONSE_NULL
	    ok
	    
	    # Check if we got a valid result
	    if result != HTTP_RESPONSE_NULL and result != HTTP_RESPONSE_EMPTY
	        status = TASK_COMPLETED
	        if onComplete != HTTP_RESPONSE_NULL
	            call onComplete(result)
	        ok
	    else
	        status = TASK_ERROR
	        if onError != HTTP_RESPONSE_NULL
	            call onError(HTTP_ERROR_REQUEST_FAILED)
	        ok
	    ok
			
	# Helper methods for HTTP operations
	def PerformHttpGet(url)
	    result = download(url)
	    if result = HTTP_RESPONSE_NULL
	        result = HTTP_RESPONSE_EMPTY
	    ok
	    return result

	def PerformHttpPost(url, data)
	    return PerformHttpWithData(url, HTTP_POST, data)

	def PerformHttpPut(url, data)
	    return PerformHttpWithData(url, HTTP_PUT, data)

	def PerformHttpDelete(url)
	    return PerformHttpWithData(url, HTTP_DELETE, HTTP_RESPONSE_NULL)

	def PerformHttpWithData(url, method, data)
	    # Initialize curl
	    curl = curl_easy_init()
	    if curl = HTTP_RESPONSE_NULL
	        return HTTP_RESPONSE_EMPTY
	    ok
	    
	    # Set basic options
	    curl_easy_setopt(curl, CURLOPT_USERAGENT, USER_AGENT_REACTIVE)
	    curl_easy_setopt(curl, CURLOPT_URL, url)
	    curl_easy_setopt(curl, CURLOPT_TIMEOUT, CURL_TIMEOUT_DEFAULT)
	    curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, CURL_CONNECT_TIMEOUT_DEFAULT)
	    
	    # Set method-specific options
	    if method = HTTP_POST
	        curl_easy_setopt(curl, CURLOPT_POST, 1)
	    elseif method = HTTP_PUT
	        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, HTTP_PUT)
	    elseif method = HTTP_DELETE
	        curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, HTTP_DELETE)
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
	        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData)
	    ok
	    
	    # Perform request and get response content
	    result = curl_easy_perform_silent(curl)
	    
	    # Cleanup
	    curl_easy_cleanup(curl)
	    
	    # Return result or empty string on failure
	    if result = HTTP_RESPONSE_NULL
	        result = HTTP_RESPONSE_EMPTY
	    ok
	    return result
