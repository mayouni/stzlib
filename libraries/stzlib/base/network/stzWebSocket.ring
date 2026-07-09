# =============================================================================
# WEBSOCKET CLIENT - cURL WebSocket support
# =============================================================================

class stzWebSocket from stzNetwork
    is_connected = False
    last_message = ""
    message_type = ""
    on_message_callback = ""
    on_open_callback = ""
    on_close_callback = ""
    on_error_callback = ""
    
    def Connect(cUrl)
        _curl_handle_ = curl_easy_init()
        curl_easy_setopt_2(_curl_handle_, CURLOPT_URL, cUrl)
        curl_easy_setopt_1(_curl_handle_, CURLOPT_CONNECT_ONLY, 2)
        
        _result_ = curl_easy_perform(_curl_handle_)
        if _result_ = CURLE_OK
            is_connected = True
            ClearErrors()
            if on_open_callback != ""
                call on_open_callback()
            ok
        else
            _last_error_ = "WebSocket connection failed"
            _error_code_ = _result_
        ok
        return This
    
    def Send(cMessage)
        return This.SendText(cMessage)
    
    def SendText(cText)
        if not is_connected
            _last_error_ = "Not connected"
            return This
        ok
        
        _result_ = curl_ws_send(_curl_handle_, cText, 0, CURLWS_TEXT)
        if _result_[1] != CURLE_OK
            _last_error_ = "Failed to send message"
            _error_code_ = _result_[1]
        ok
        return This
    
    def SendBinary(aData)
        if not is_connected
            _last_error_ = "Not connected"
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
            _last_error_ = "Failed to send binary data"
            _error_code_ = _result_[1]
        ok
        return This
    
    def Receive()
        if not is_connected
            _last_error_ = "Not connected"
            return This
        ok
        
        _result_ = curl_ws_recv(_curl_handle_, 1024)
        if _result_[1] = CURLE_OK
            last_message = _result_[2]
            # Determine message type based on WebSocket frame
            message_type = "TEXT"  # Simplified - would need proper frame parsing
            ClearErrors()
            
            if on_message_callback != ""
                call on_message_callback()
            ok
        else
            if _result_[1] != CURLE_AGAIN
                _last_error_ = "Failed to receive message"
                _error_code_ = _result_[1]
            ok
        ok
        return This
    
    def Close()
        if is_connected and _curl_handle_ != NULL
            # Send close frame
            curl_ws_send(_curl_handle_, "", 0, CURLWS_CLOSE)
            curl_easy_cleanup(_curl_handle_)
            is_connected = False
            
            if on_close_callback != ""
                call on_close_callback()
            ok
        ok
        return This
    
    def IsOpen()
        return is_connected
    
    def OnMessage(cCallback)
        on_message_callback = cCallback
        return This
    
    def OnOpen(cCallback)
        on_open_callback = cCallback
        return This
    
    def OnClose(cCallback)
        on_close_callback = cCallback
        return This
    
    def OnError(cCallback)
        on_error_callback = cCallback
        return This
    
    def LastMessage()
        return last_message
    
    def MessageType()
        return message_type
