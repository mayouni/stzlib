# =============================================================================
# WEBSOCKET CLIENT - cURL WebSocket support
# =============================================================================

# Declares a WebSocket client built on libcurl, which cannot open a connection today because libcurl is no longer loaded.
#
# The rest of the network layer moved to the in-tree engine, but this class still calls curl
# functions (curl_easy_init, curl_ws_send, curl_ws_recv) that the library does not define. Connect
# therefore raises error R3, no connection is ever open, and every other call answers as an
# unconnected client: the send and receive calls set LastError to Not connected. The callback
# setters store names that are never called. Use stzTcpClient for a raw socket until the class is
# rewired to the engine.
#
#   receiver   o1 = new stzWebSocket()
#   example    ? o1.IsOpen()
#              #--> 0
#              o1.SendText("hi")
#              ? o1.LastError()
#              #--> Not connected
#   see        stzTcpClient, stzNetwork
class stzWebSocket from stzNetwork
    @is_connected = 0
    @last_message = ""
    @message_type = ""
    @on_message_callback = ""
    @on_open_callback = ""
    @on_close_callback = ""
    @on_error_callback = ""
    
    # Raises error R3 today instead of opening a WebSocket connection.
    #
    #   cUrl       the ws or wss address meant to be opened
    #   returns    nothing; it raises
    #   note       nothing in the class can be used to talk to a server today
    #   warning    raises error R3 because it calls curl_easy_init, a libcurl function that the
    #              library no longer loads; the class still wraps libcurl while the rest of the
    #              network layer moved to the engine, and even with libcurl the later calls would
    #              not see the handle, which Connect keeps in a local variable
    #   see        IsOpen
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
    
    # Sets LastError to Not connected, because no connection can be opened today.
    #
    #   cText      the text meant to be sent
    #   returns    the object itself, so calls chain
    #   note       it would raise error R3 if a connection could be marked open
    #   warning    the send itself calls curl_ws_send, which is not loaded either
    #   see        Connect, SendBinary
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
    
    # Sets LastError to Not connected, because no connection can be opened today.
    #
    #   aData      a list of byte values meant to be sent
    #   returns    the object itself, so calls chain
    #   note       it would raise error R3 if a connection could be marked open
    #   warning    the send itself calls curl_ws_send, which is not loaded either
    #   see        Connect, SendText
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
    
    # Sets LastError to Not connected, because no connection can be opened today.
    #
    #   returns    the object itself, so calls chain
    #   note       it would raise error R3 if a connection could be marked open
    #   warning    the receive itself calls curl_ws_recv, which is not loaded either
    #   see        Connect, LastMessage
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
    
    # Does nothing today, because no connection can be open.
    #
    #   returns    the object itself, so calls chain
    #   see        Connect, IsOpen
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
    
    # TRUE if the connection is open; always FALSE today.
    #
    #   returns    TRUE or FALSE
    #   see        Connect
    def IsOpen()
        return @is_connected
    
    # Stores the name of a function meant to run when a message arrives.
    #
    #   cCallback   the name of a function
    #   returns     the object itself, so calls chain
    #   note        never called today
    #   see         OnOpen
    def OnMessage(cCallback)
        @on_message_callback = cCallback
        return This
    
    # Stores the name of a function meant to run when the connection opens.
    #
    #   cCallback   the name of a function
    #   returns     the object itself, so calls chain
    #   note        never called today
    #   see         OnMessage
    def OnOpen(cCallback)
        @on_open_callback = cCallback
        return This
    
    # Stores the name of a function meant to run when the connection closes.
    #
    #   cCallback   the name of a function
    #   returns     the object itself, so calls chain
    #   note        never called today
    #   see         OnOpen
    def OnClose(cCallback)
        @on_close_callback = cCallback
        return This
    
    # Stores the name of a function meant to run on a failure.
    #
    #   cCallback   the name of a function
    #   returns     the object itself, so calls chain
    #   note        never called today
    #   see         OnOpen
    def OnError(cCallback)
        @on_error_callback = cCallback
        return This
    
    # Returns the text of the last received message.
    #
    #   returns    a text; empty today
    #   see        Receive
    def LastMessage()
        return @last_message
    
    # Returns the type of the last received message.
    #
    #   returns    a text; empty before a receive, and TEXT after one
    #   see        LastMessage
    def MessageType()
        return @message_type
