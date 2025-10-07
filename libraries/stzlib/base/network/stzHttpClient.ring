# =============================================================================
# HTTP CLIENT - cURL-based, fluent HTTP operations  
# =============================================================================

# Global variables for parallel requests
parallel_results = []
parallel_completed = 0  
parallel_total = 0
parallel_loop = NULL

func CreateParallelRequest(cUrl, nIndex)
    # Parse URL
    url_parts = ParseUrl(cUrl)
    
    # Create connection
    tcp_handle = new_uv_tcp_t()
    connect_req = new_uv_connect_t()
    addr = new_sockaddr_in()
    
    uv_tcp_init(parallel_loop, tcp_handle)
    uv_ip4_addr(url_parts[1], url_parts[2], addr)  # host, port
    
    # Store request index in TCP handle for later retrieval
    set_uv_tcp_data(tcp_handle, nIndex)

    # Build HTTP request
    http_request = "GET " + url_parts[3] + " HTTP/1.1" + char(13) + char(10) +
                   "Host: " + url_parts[1] + char(13) + char(10) +
                   "User-Agent: Softanza-HTTP/1.0" + char(13) + char(10) +
                   "Connection: close" + char(13) + char(10) +
                   char(13) + char(10)
    
    # Store request data globally indexed by handle
    set_request_data(tcp_handle, [
        :index = nIndex,
        :url = cUrl,
        :request = http_request,
        :response = "",
        :connected = false
    ])

    uv_tcp_connect(connect_req, tcp_handle, addr, "OnParallelConnect()")
    destroy_sockaddr_in(addr)

func OnParallelConnect()
    connect_req = get_uv_event_handle()
    tcp_handle = get_uv_connect_t_handle(connect_req)
    nIndex = get_uv_tcp_data(tcp_handle)
    request_data = get_request_data(tcp_handle)
    
    # Check connection status
    if get_uv_event_status() < 0
        CompleteParallelRequest(nIndex, "", 0, "Connection failed")
        cleanup_handle(tcp_handle)
        return
    ok
    
    # Mark as connected and send HTTP request
    request_data[:connected] = true
    set_request_data(tcp_handle, request_data)
    
    # Create write buffer
    write_req = new_uv_write_t()
    buf = new_uv_buf_t()
    http_req = request_data[:request]
    set_uv_buf_t_len(buf, len(http_req))
    set_uv_buf_t_base(buf, varptr("http_req", :char))
    
    uv_write(write_req, tcp_handle, buf, 1, "OnParallelWrite()")

func OnParallelWrite()
    write_req = get_uv_event_handle()
    tcp_handle = get_uv_write_t_handle(write_req)
    
    if get_uv_event_status() < 0
        nIndex = get_uv_tcp_data(tcp_handle)
        CompleteParallelRequest(nIndex, "", 0, "Write failed")
        cleanup_handle(tcp_handle)
        return
    ok
    
    # Start reading response
    uv_read_start(tcp_handle, uv_myalloccallback(), "OnParallelRead()")
    destroy_uv_write_t(write_req)

func OnParallelRead()
    tcp_handle = get_uv_event_handle()
    nRead = get_uv_event_nread()
    buf = get_uv_event_buf()
    
    nIndex = get_uv_tcp_data(tcp_handle)
    request_data = get_request_data(tcp_handle)
    
    if nRead > 0
        # Append data to response
        data_chunk = uv_buf2str(uv_buf_init(get_uv_buf_t_base(buf), nRead))
        request_data[:response] += data_chunk
        set_request_data(tcp_handle, request_data)
    elseif nRead < 0
        # Connection closed - parse response and complete
        response_parts = ParseHttpResponse(request_data[:response])
        CompleteParallelRequest(nIndex, response_parts[3], response_parts[1], "")
        cleanup_handle(tcp_handle)
    ok

func CompleteParallelRequest(nIndex, cBody, nCode, cError)
    parallel_results[nIndex] = [
        :body = cBody,
        :code = nCode, 
        :headers = "",
        :error = cError
    ]
    
    parallel_completed++
    
    if parallel_completed >= parallel_total
        uv_stop(parallel_loop)
    ok

func cleanup_handle(tcp_handle)
    uv_close(tcp_handle, NULL)

func ParseUrl(cUrl) # TODO Exists already in stzString and may be in stzUrl
    url = cUrl
    port = 80
    
    # Remove protocol
    if left(url, 7) = "http://"
        url = substr(url, 8)
    elseif left(url, 8) = "https://"
        url = substr(url, 9) 
        port = 443
    ok
    
    # Extract host and path
    slash_pos = substr(url, "/")
    if slash_pos > 0
        host = left(url, slash_pos - 1)
        path = substr(url, slash_pos)
    else
        host = url
        path = "/"
    ok
    
    # Extract port
    colon_pos = substr(host, ":")
    if colon_pos > 0
        port = 0 + substr(host, colon_pos + 1)
        host = left(host, colon_pos - 1)
    ok
    
    return [host, port, path]

func ParseHttpResponse(cResponse)
    if len(cResponse) = 0
        return [0, "", "", ""]
    ok
    
    # Find headers/body separator
    double_crlf = char(13) + char(10) + char(13) + char(10)
    body_start = substr(cResponse, double_crlf)
    
    if body_start > 0
        headers_part = left(cResponse, body_start - 1)
        body_part = substr(cResponse, body_start + 4)
    else
        headers_part = cResponse
        body_part = ""
    ok
    
    # Extract status code
    status_code = 200
    first_line_end = substr(headers_part, char(13) + char(10))
    if first_line_end > 0
        status_line = left(headers_part, first_line_end - 1)
        parts = split(status_line, " ")
        if len(parts) >= 2
            status_code = 0 + parts[2]
        ok
    ok
    
    return [status_code, headers_part, body_part]

class stzHttpClient from stzNetwork
    headers_list = []
    cookies_list = []
    last_response = ""
    last_response_code = 0
    last_response_headers = ""
    
    def init()
        super.init()
        curl_handle = curl_easy_init()
        if curl_handle = NULL
            last_error = "Failed to initialize curl handle"
            error_code = -1
            return
        ok
        This.SetDefaults()
    
    def SetDefaults()
        curl_easy_setopt(curl_handle, CURLOPT_TIMEOUT, timeout_seconds)
        curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1)
        curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, 1)
        curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "Softanza-HTTP/1.0")
        return This
    
    def SetUserAgent(cAgent)
        curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, cAgent)
        return This
    
    def SetHeader(cName, cValue)
        headers_list + (cName + ": " + cValue)
        This.ApplyHeaders()
        return This
    
    def SetHeaders(aHeaders)
        headers_list = aHeaders
        This.ApplyHeaders()
        return This
    
    def ApplyHeaders()
        if len(headers_list) = 0 return ok
        header_slist = NULL
        for header in headers_list
            header_slist = curl_slist_append(header_slist, header)
        next
        curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, header_slist)
    
    def SetCookie(cName, cValue)
        cookies_list + (cName + "=" + cValue)
        This.ApplyCookies()
        return This
    
    def SetCookies(aCookies)
        cookies_list = aCookies
        This.ApplyCookies()
        return This
    
    def ApplyCookies()
        if len(cookies_list) = 0 return ok
        cookie_string = ""
        for i = 1 to len(cookies_list)
            cookie_string += cookies_list[i]
            if i < len(cookies_list)
                cookie_string += "; "
            ok
        next
        curl_easy_setopt(curl_handle, CURLOPT_COOKIE, cookie_string)
    
    def FollowRedirects(bFollow)
        curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, iff(bFollow, 1, 0))
        return This
    
    def VerifySSL(bVerify)
        curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, iff(bVerify, 1, 0))
        return This
    
    def SetProxy(cProxy)
        curl_easy_setopt(curl_handle, CURLOPT_PROXY, cProxy)
        return This
    
    def SetAuth(cUser, cPass)
        curl_easy_setopt(curl_handle, CURLOPT_USERNAME, cUser)
        curl_easy_setopt(curl_handle, CURLOPT_PASSWORD, cPass)
        return This
    
    def Get_(cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_HTTPGET, 1)
        return This.PerformRequest()
    
    def Post(cUrl, cData)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, cData)
        curl_easy_setopt(curl_handle, CURLOPT_POST, 1)
        return This.PerformRequest()
    
    def Put_(cUrl, cData)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, cData)
        curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "PUT")
        return This.PerformRequest()
    
    def Delete(cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "DELETE")
        return This.PerformRequest()
    
    def Head(cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_NOBODY, 1)
        return This.PerformRequest()
    
    def Options(cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt(curl_handle, CURLOPT_CUSTOMREQUEST, "OPTIONS")
        return This.PerformRequest()
    
    def PerformRequest()
        try
            last_response = curl_easy_perform_silent(curl_handle)
            last_response_code = curl_getResponseCode(curl_handle)
            ClearErrors()
            return This
        catch
            last_error = "Request failed"
            error_code = -1
            return This
        done
    
    def Response()
        return [
            :body = last_response,
            :code = last_response_code,
            :headers = last_response_headers,
            :info = This.ConnectionInfo()
        ]
    
    def ResponseCode()
        return last_response_code
    
    def ResponseBody()
        return last_response
    
    def ResponseHeaders()
        return last_response_headers
    
    def ResponseTime()
        if curl_handle = NULL return 0 ok
        return curl_getTotalTime(curl_handle)
    
    def PostForm(cUrl, aFormData)
        form_string = ""
        for i = 1 to len(aFormData) step 2
            if i > 1 form_string += "&" ok
            form_string += URLEncode(aFormData[i]) + "=" + URLEncode(aFormData[i+1])
        next
        return This.Post(cUrl, form_string)
    
    def PostJson(cUrl, cJson)
        This.SetHeader("Content-Type", "application/json")
        return This.Post(cUrl, cJson)
    
    def DownloadFile(cUrl, cLocalPath)
        #TODO // Implementation would use CURLOPT_WRITEDATA for file writing
        # Simplified version using response body
	if not HasError()
            This.Get_(cUrl)
            write(cLocalPath, ResponseBody())
        ok
        return This
    
    def GetMany(aUrls)
	    # Initialize global state
	    parallel_results = []
	    parallel_completed = 0
	    parallel_total = len(aUrls)
	    parallel_loop = uv_default_loop()
	    
	    # Resize results array
	    for i = 1 to parallel_total
	        parallel_results + [:body = "", :code = 0, :headers = "", :error = ""]
	    next
	    
	    # Create parallel requests
	    for i = 1 to len(aUrls)
	        CreateParallelRequest(aUrls[i], i)
	    next
	    
	    # Run event loop until all complete
	    uv_run(parallel_loop, UV_RUN_DEFAULT)
	    
	    return parallel_results
    
    # Alternative simpler sequential implementation if LibUV is not available
    def GetManySequential(aUrls)
        results = []
        for i = 1 to len(aUrls)
            This.Get_(aUrls[i])
            results + This.Response()
        next
        return results


#=========================#
#  stzHttpParallelClient  #
#=========================#

# Based on LibUV extension
# Made specifically to be used by GetMany() in stzNetwork class
# As a replacement to the lacking curl_multi_ini() and curl_multi_perform()
# functions form RingCurl extensions (#TODO Inform Mahmoud to add them)

class stzHttpParallelClient

    results = []
    completed_requests = 0
    total_requests = 0
    myloop = NULL
    
    def GetMany(aUrls)
        results = []
        completed_requests = 0
        total_requests = len(aUrls)
        myloop = uv_default_loop()
        
        # Create parallel requests
        for i = 1 to len(aUrls)
            url = aUrls[i]
            This.CreateHttpRequest(url, i)
        next
        
        # Run event loop until all requests complete
        uv_run(myloop, UV_RUN_DEFAULT)
        
        return results
    
    def CreateHttpRequest(cUrl, nIndex)
        # Parse URL components
        url_parts = This.ParseUrl(cUrl)
        
        # Create TCP connection
        tcp_handle = new_uv_tcp_t()
        connect_req = new_uv_connect_t()
        addr = new_sockaddr_in()
        
        uv_tcp_init(myloop, tcp_handle)
        uv_ip4_addr(url_parts[:host], url_parts[:port], addr)
        
        # Store request context
        request_data = [
            :index = nIndex,
            :url = cUrl,
            :host = url_parts[:host],
            :path = url_parts[:path],
            :tcp = tcp_handle,
            :connect = connect_req,
            :response = "",
            :headers_sent = false
        ]
        
        # Store context for callback access
        set_uv_connect_context(connect_req, request_data)
        
        uv_tcp_connect(connect_req, tcp_handle, addr, "OnConnect()")
        
        destroy_sockaddr_in(addr)
    
    def OnConnect()
        aPara = uv_Eventpara(connect_req, :connect)
        req = aPara[1]
        nStatus = aPara[2]
        
        request_data = get_uv_connect_context(req)
        
        if nStatus < 0
            This.CompleteRequest(request_data[:index], "", nStatus)
            return
        ok
        
        # Send HTTP request
        http_request = "GET " + request_data[:path] + " HTTP/1.1" + char(13) + char(10) +
                      "Host: " + request_data[:host] + char(13) + char(10) +
                      "User-Agent: Softanza-HTTP/1.0" + char(13) + char(10) +
                      "Connection: close" + char(13) + char(10) +
                      char(13) + char(10)
        
        # Create write request
        write_req = new_uv_write_t()
        buf = new_uv_buf_t()
        set_uv_buf_t_len(buf, len(http_request))
        set_uv_buf_t_base(buf, varptr("http_request", :char))
        
        tcp = get_uv_connect_t_handle(req)
        set_uv_write_context(write_req, request_data)
        
        uv_write(write_req, tcp, buf, 1, "OnWrite()")
    
    def OnWrite()
        aPara = uv_Eventpara(write_req, :write)
        req = aPara[1]
        nStatus = aPara[2]
        
        request_data = get_uv_write_context(req)
        
        if nStatus < 0
            This.CompleteRequest(request_data[:index], "", nStatus)
            return
        ok
        
        # Start reading response
        uv_read_start(request_data[:tcp], uv_myalloccallback(), "OnRead()")
        destroy_uv_write_t(req)
    
    def OnRead()
        aPara = uv_Eventpara(tcp_handle, :read)
        nRead = aPara[2]
        buf = aPara[3]
        
        # Get request data from TCP handle context
        request_data = get_uv_tcp_context(tcp_handle)
        
        if nRead > 0
            # Append data to response
            data = uv_buf2str(uv_buf_init(get_uv_buf_t_base(buf), nRead))
            request_data[:response] += data
        elseif nRead < 0
            # Connection closed or error - complete request
            This.CompleteRequest(request_data[:index], request_data[:response], 0)
            This.CleanupRequest(request_data)
        ok
    
    def CompleteRequest(nIndex, cResponse, nStatus)
        # Parse response to extract status code and body
        response_parts = This.ParseHttpResponse(cResponse)
        
        results[nIndex] = [
            :body = response_parts[:body],
            :code = response_parts[:status_code],
            :headers = response_parts[:headers],
            :error_code = nStatus
        ]
        
        completed_requests++
        
        # Stop event loop when all requests complete
        if completed_requests >= total_requests
            uv_stop(myloop)
        ok
    
    def CleanupRequest(request_data)
        if HasKey(request_data, :tcp)
            uv_close(request_data[:tcp], NULL)
            destroy_uv_tcp_t(request_data[:tcp])
        ok
        
        if HasKey(request_data, :connect)
            destroy_uv_connect_t(request_data[:connect])
        ok
    
    def ParseUrl(cUrl)
        # Simple URL parser - extend as needed
        url = cUrl
        protocol = "http"
        port = 80
        
        if left(url, 7) = "http://"
            url = substr(url, 8)
        elseif left(url, 8) = "https://"
            url = substr(url, 9)
            port = 443
        ok
        
        # Extract host and path
        slash_pos = substr(url, "/")
        if slash_pos > 0
            host = left(url, slash_pos - 1)
            path = substr(url, slash_pos)
        else
            host = url
            path = "/"
        ok
        
        # Extract port if specified
        colon_pos = substr(host, ":")
        if colon_pos > 0
            port = 0 + substr(host, colon_pos + 1)
            host = left(host, colon_pos - 1)
        ok
        
        return [:host = host, :port = port, :path = path]
    
    def ParseHttpResponse(cResponse)
        if len(cResponse) = 0
            return [:status_code = 0, :headers = "", :body = ""]
        ok
        
        # Split headers and body
        double_crlf = char(13) + char(10) + char(13) + char(10)
        body_start = substr(cResponse, double_crlf)
        
        if body_start > 0
            headers_part = left(cResponse, body_start - 1)
            body_part = substr(cResponse, body_start + 4)
        else
            headers_part = cResponse
            body_part = ""
        ok
        
        # Extract status code from first line
        status_code = 200
        first_line_end = substr(headers_part, char(13) + char(10))
        if first_line_end > 0
            status_line = left(headers_part, first_line_end - 1)
            # Extract status code (format: HTTP/1.1 200 OK)
            parts = split(status_line, " ")
            if len(parts) >= 2
                status_code = 0 + parts[2]
            ok
        ok
        
        return [:status_code = status_code, :headers = headers_part, :body = body_part]
