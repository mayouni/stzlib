# =============================================================================
# WEBSOCKET CLIENT - cURL WebSocket support
# =============================================================================

class stzWebSocket from stzNetwork
    _is_connected_ = False
    _last_message_ = ""
    _message_type_ = ""
    _on_message_callback_ = ""
    _on_open_callback_ = ""
    _on_close_callback_ = ""
    _on_error_callback_ = ""
    
    def Connect(cUrl)
        _curl_handle_ = curl_easy_init()
        curl_easy_setopt_2(_curl_handle_, CURLOPT_URL, cUrl)
        curl_easy_setopt_1(_curl_handle_, CURLOPT_CONNECT_ONLY, 2)
        
        _result_ = curl_easy_perform(_curl_handle_)
        if _result_ = CURLE_OK
            _is_connected_ = True
            ClearErrors()
            if _on_open_callback_ != ""
                call _on_open_callback_()
            ok
        else
            _last_error_ = "WebSocket connection failed"
            _error_code_ = _result_
        ok
        return This
    
    def Send(cMessage)
        return This.SendText(cMessage)
    
    def SendText(cText)
        if not _is_connected_
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
        if not _is_connected_
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
        if not _is_connected_
            _last_error_ = "Not connected"
            return This
        ok
        
        _result_ = curl_ws_recv(_curl_handle_, 1024)
        if _result_[1] = CURLE_OK
            _last_message_ = _result_[2]
            # Determine message type based on WebSocket frame
            _message_type_ = "TEXT"  # Simplified - would need proper frame parsing
            ClearErrors()
            
            if _on_message_callback_ != ""
                call _on_message_callback_()
            ok
        else
            if _result_[1] != CURLE_AGAIN
                _last_error_ = "Failed to receive message"
                _error_code_ = _result_[1]
            ok
        ok
        return This
    
    def Close()
        if _is_connected_ and _curl_handle_ != NULL
            # Send close frame
            curl_ws_send(_curl_handle_, "", 0, CURLWS_CLOSE)
            curl_easy_cleanup(_curl_handle_)
            _is_connected_ = False
            
            if _on_close_callback_ != ""
                call _on_close_callback_()
            ok
        ok
        return This
    
    def IsOpen()
        return _is_connected_
    
    def OnMessage(cCallback)
        _on_message_callback_ = cCallback
        return This
    
    def OnOpen(cCallback)
        _on_open_callback_ = cCallback
        return This
    
    def OnClose(cCallback)
        _on_close_callback_ = cCallback
        return This
    
    def OnError(cCallback)
        _on_error_callback_ = cCallback
        return This
    
    def LastMessage()
        return _last_message_
    
    def MessageType()
        return _message_type_
