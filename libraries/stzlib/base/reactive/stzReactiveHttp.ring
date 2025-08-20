#-------------------------------------------#
#  REACTIVE HTTP CLIENT - For web requests  #
#-------------------------------------------#

class stzReactiveHttp

	engine = NULL
	
	def Init(engine)
		this.engine = engine
		
	def Get_(url, onSuccess, onError)
		task = new stzHttpTask(:http_get, url, "GET", NULL, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task
		
	def Post(url, data, onSuccess, onError)
		task = new stzHttpTask(:http_post, url, "POST", data, engine)
		task.Then_(onSuccess)
		task.Catch_(onError)
		engine.AddTask(task)
		task.Execute()
		return task

class stzHttpTask from stzReactiveTask

	url = ""
	method = "GET"
	data = NULL
	
	def Init(id, url, method, data, engine)
		super.Init(id, NULL, engine)
		this.url = url
		this.method = method
		this.data = data
		
	def Execute()
	    status = "running"
	    
	    # Use Ring's built-in HTTP capabilities
	    if method = "GET"
	        result = PerformHttpGet(url)
	    else
	        result = PerformHttpPost(url, data)
	    ok
	    
	    # Check if we got a valid result
	    if result != NULL and result != ""
	        status = "completed"
	        if onComplete != NULL
	            call onComplete(result)
	        ok
	    else
	        status = "error"
	        if onError != NULL
	            call onError("HTTP request failed")
	        ok
	    ok
			
	# Helper methods for HTTP operations
	def PerformHttpGet(url)
	    result = download(url)
	    if result = NULL
	        result = ""
	    ok
	    return result

	def PerformHttpPost(url, data)
	    # Initialize curl
	    curl = curl_easy_init()
	    if curl = NULL
	        return ""
	    ok
	    
	    # Set basic options
	    curl_easy_setopt(curl, CURLOPT_USERAGENT, "stzReactive/1.0")
	    curl_easy_setopt(curl, CURLOPT_URL, url)
	    
	    # Set POST data
	    if data != NULL and data != ""
	        if isString(data)
	            postData = data
	        else
	            # Convert list/object to query string format
	            postData = ""
	            # Simple conversion - extend as needed
	        ok
	        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData)
	    ok
	    
	    # Perform request and get response content
	    result = curl_easy_perform_silent(curl)
	    
	    # Cleanup
	    curl_easy_cleanup(curl)
	    
	    # Return result or empty string on failure
	    if result = NULL
	        result = ""
	    ok
	    return result
