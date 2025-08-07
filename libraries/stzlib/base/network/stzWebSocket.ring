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
        curl_handle = curl_easy_init()
        curl_easy_setopt_2(curl_handle, CURLOPT_URL, cUrl)
        curl_easy_setopt_1(curl_handle, CURLOPT_CONNECT_ONLY, 2)
        
        result = curl_easy_perform(curl_handle)
        if result = CURLE_OK
            is_connected = True
            ClearErrors()
            if on_open_callback != ""
                call on_open_callback()
            ok
        else
            last_error = "WebSocket connection failed"
            error_code = result
        ok
        return This
    
    def Send(cMessage)
        return This.SendText(cMessage)
    
    def SendText(cText)
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        
        result = curl_ws_send(curl_handle, cText, 0, CURLWS_TEXT)
        if result[1] != CURLE_OK
            last_error = "Failed to send message"
            error_code = result[1]
        ok
        return This
    
    def SendBinary(aData)
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        
        # Convert array to binary string
        binary_string = ""
        for byte in aData
            binary_string += char(byte)
        next
        
        result = curl_ws_send(curl_handle, binary_string, 0, CURLWS_BINARY)
        if result[1] != CURLE_OK
            last_error = "Failed to send binary data"
            error_code = result[1]
        ok
        return This
    
    def Receive()
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        
        result = curl_ws_recv(curl_handle, 1024)
        if result[1] = CURLE_OK
            last_message = result[2]
            # Determine message type based on WebSocket frame
            message_type = "TEXT"  # Simplified - would need proper frame parsing
            ClearErrors()
            
            if on_message_callback != ""
                call on_message_callback()
            ok
        else
            if result[1] != CURLE_AGAIN
                last_error = "Failed to receive message"
                error_code = result[1]
            ok
        ok
        return This
    
    def Close()
        if is_connected and curl_handle != NULL
            # Send close frame
            curl_ws_send(curl_handle, "", 0, CURLWS_CLOSE)
            curl_easy_cleanup(curl_handle)
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
