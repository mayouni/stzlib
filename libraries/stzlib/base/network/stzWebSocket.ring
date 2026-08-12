# =============================================================================
# WEBSOCKET CLIENT - cURL WebSocket support
# =============================================================================

class stzWebSocket from stzNetwork
    @is_connected = 0
    @last_message = ""
    @message_type = ""
    @on_message_callback = ""
    @on_open_callback = ""
    @on_close_callback = ""
    @on_error_callback = ""
    
    def Connect(cUrl)
        _curl_handle_ = curl_easy_init()
        curl_easy_setopt_2(_curl_handle_, CURLOPT_URL, cUrl)
        curl_easy_setopt_1(_curl_handle_, CURLOPT_CONNECT_ONLY, 2)
        
        _result_ = curl_easy_perform(_curl_handle_)
        if _result_ = CURLE_OK
            @is_connected = 1
            ClearErrors()
            if @on_open_callback != ""
                call @on_open_callback()
            ok
        else
            @last_error = "WebSocket connection failed"
            @error_code = _result_
        ok
        return This
    
    def Send(cMessage)
        return This.SendText(cMessage)
    
    def SendText(cText)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        
        _result_ = curl_ws_send(_curl_handle_, cText, 0, CURLWS_TEXT)
        if _result_[1] != CURLE_OK
            @last_error = "Failed to send message"
            @error_code = _result_[1]
        ok
        return This
    
    def SendBinary(aData)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        
        # Convert array to binary string
        _binary_string_ = ""
        _nData1Len_ = len(aData)
        for _iLoopData1_ = 1 to _nData1Len_
        	_byte_ = aData[_iLoopData1_]
            _binary_string_ += StzChar(_byte_)
        next
        
        _result_ = curl_ws_send(_curl_handle_, _binary_string_, 0, CURLWS_BINARY)
        if _result_[1] != CURLE_OK
            @last_error = "Failed to send binary data"
            @error_code = _result_[1]
        ok
        return This
    
    def Receive()
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        
        _result_ = curl_ws_recv(_curl_handle_, 1024)
        if _result_[1] = CURLE_OK
            @last_message = _result_[2]
            # Determine message type based on WebSocket frame
            @message_type = "TEXT"  # Simplified - would need proper frame parsing
            ClearErrors()
            
            if @on_message_callback != ""
                call @on_message_callback()
            ok
        else
            if _result_[1] != CURLE_AGAIN
                @last_error = "Failed to receive message"
                @error_code = _result_[1]
            ok
        ok
        return This
    
    def Close()
        if @is_connected and _curl_handle_ != ""
            # Send close frame
            curl_ws_send(_curl_handle_, "", 0, CURLWS_CLOSE)
            curl_easy_cleanup(_curl_handle_)
            @is_connected = 0
            
            if @on_close_callback != ""
                call @on_close_callback()
            ok
        ok
        return This
    
    def IsOpen()
        return @is_connected
    
    def OnMessage(cCallback)
        @on_message_callback = cCallback
        return This
    
    def OnOpen(cCallback)
        @on_open_callback = cCallback
        return This
    
    def OnClose(cCallback)
        @on_close_callback = cCallback
        return This
    
    def OnError(cCallback)
        @on_error_callback = cCallback
        return This
    
    def LastMessage()
        return @last_message
    
    def MessageType()
        return @message_type
