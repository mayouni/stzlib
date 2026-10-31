# =============================================================================
# WEBSOCKET CLIENT -- placeholder until the engine has a WebSocket transport
# =============================================================================

# Holds a WebSocket client that checks an address and reports that this build cannot open a connection.
#
# The engine has plain TCP (stzTcpClient) and an HTTPS client, but no WebSocket transport and no TLS
# socket. The class is a placeholder for the engine WebSocket client that is owed to the engine
# owner: RFC 6455 framing over the engine TCP socket, with TLS for wss. Until that lands, a caller can
# rely on this and nothing more. Connect never opens a connection and never raises on a text: it
# checks the ws or wss address, sets LastError to a named message, leaves IsOpen false and runs the
# error callback if one is set. Send, SendText, SendBinary and Receive on a client that is not open
# set LastError to Not connected and send or read nothing. Close does nothing, and the close callback
# runs only for a connection that was open, which cannot happen today. Every method that does not
# answer a value returns the client itself, so calls chain. No call reaches the network, and the
# class no longer calls libcurl. Use stzTcpClient for a raw socket.
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

    # Checks a ws or wss address, records that this build has no WebSocket transport and runs the error callback.
    #
    #   cUrl       the ws or wss address meant to be opened, such as ws://localhost:8080/chat
    #   returns    the client itself, so calls chain
    #   note       it never opens a connection, so IsOpen stays false; the error code is -1
    #   warning    a text that is not a ws or wss address sets LastError to Bad WebSocket scheme
    #              followed by the scheme found, or none, and a ws or wss address with no host sets
    #              Bad WebSocket address; a good address sets LastError to No WebSocket transport in
    #              this build; none of them raises, but a cUrl that is not a text raises
    #   see        IsOpen, OnError, stzTcpClient
    #   example    o1.Connect("ws://localhost:8080/chat")
    #              ? o1.IsOpen()
    #              #--> 0
    #              ? o1.LastError()
    #              #--> No WebSocket transport in this build: the engine has none yet, use stzTcpClient for a raw socket
    def Connect(cUrl)
        if NOT isString(cUrl)
            StzRaise("Incorrect param type! cUrl must be a string (a url is text).")
        ok

        _nSep_ = StzFindFirst("://", cUrl)
        _cScheme_ = ""
        if _nSep_ > 0
            _cScheme_ = StzLower(StzLeft(cUrl, _nSep_ - 1))
        ok

        if _cScheme_ != "ws" and _cScheme_ != "wss"
            _cShown_ = _cScheme_
            if _cShown_ = ""
                _cShown_ = "none"
            ok
            @last_error = "Bad WebSocket scheme: " + _cShown_ + " (use ws:// or wss://)"
        else
            _cHost1_ = StzMidToEnd(cUrl, _nSep_ + 3)
            _cFirst_ = ""
            if _cHost1_ != ""
                _cFirst_ = StzLeft(_cHost1_, 1)
            ok
            if _cFirst_ = "" or _cFirst_ = "/" or _cFirst_ = "?" or _cFirst_ = "#"
                @last_error = "Bad WebSocket address: no host after " + _cScheme_ + "://"
            else
                @last_error = "No WebSocket transport in this build: the engine has none yet, use stzTcpClient for a raw socket"
            ok
        ok
        @error_code = -1

        if isString(@on_error_callback) and @on_error_callback != ""
            call @on_error_callback()
        ok
        return This

    # Sends text on the open connection; it forwards to SendText.
    #
    #   cMessage   the text to send
    #   returns    the client itself, so calls chain
    #   warning    without a connection it sets LastError to Not connected and sends nothing
    #   see        SendText, SendBinary
    def Send(cMessage)
        return This.SendText(cMessage)

    # Sends a text frame on the open connection, or sets LastError to Not connected when there is none.
    #
    #   cText      the text to send
    #   returns    the client itself, so calls chain
    #   note       no connection can be open in this build, so the call always sets LastError
    #   see        Send, SendBinary, Connect
    def SendText(cText)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        @last_error = "No WebSocket transport in this build"
        @error_code = -1
        return This

    # Sends a binary frame on the open connection, or sets LastError to Not connected when there is none.
    #
    #   aData      a list of byte values to send
    #   returns    the client itself, so calls chain
    #   note       no connection can be open in this build, so the call always sets LastError
    #   see        SendText, Connect
    def SendBinary(aData)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        @last_error = "No WebSocket transport in this build"
        @error_code = -1
        return This

    # Reads the next message from the open connection, or sets LastError to Not connected when there is none.
    #
    #   returns    the client itself, so calls chain
    #   note       no connection can be open in this build, so LastMessage stays empty
    #   see        LastMessage, MessageType, Connect
    def Receive()
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        @last_error = "No WebSocket transport in this build"
        @error_code = -1
        return This

    # Ends an open session and runs the function stored by OnClose; with nothing open it does nothing.
    #
    #   returns    the client itself, so calls chain
    #   note       safe to call any number of times, and before Connect; the stored function runs
    #              once, only for a session that was open, which cannot happen in this build
    #   see        Connect, IsOpen, OnClose
    def Close()
        if @is_connected
            @is_connected = 0
            if isString(@on_close_callback) and @on_close_callback != ""
                call @on_close_callback()
            ok
        ok
        return This

    # TRUE if the connection is open; always FALSE in this build.
    #
    #   returns    TRUE or FALSE
    #   see        Connect, Close
    def IsOpen()
        return @is_connected

    # Stores the name of a function to run when a message arrives.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   note        it never runs in this build, because no message can arrive
    #   see         OnOpen, Receive
    def OnMessage(cCallback)
        @on_message_callback = cCallback
        return This

    # Stores the name of a function to run when the connection opens.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   note        it never runs in this build, because no connection can open
    #   see         OnMessage, Connect
    def OnOpen(cCallback)
        @on_open_callback = cCallback
        return This

    # Stores the name of a function to run when an open connection ends.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   note        it never runs in this build, because no connection can open
    #   see         OnOpen, Close
    def OnClose(cCallback)
        @on_close_callback = cCallback
        return This

    # Stores the name of a function to run when Connect fails.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   note        Connect runs it after setting LastError, on every failure, which is every call here
    #   see         OnOpen, Connect, LastError
    def OnError(cCallback)
        @on_error_callback = cCallback
        return This

    # Returns the text of the last received message.
    #
    #   returns    a text; empty in this build, because nothing can be received
    #   see        Receive, MessageType
    def LastMessage()
        return @last_message

    # Returns the type of the last received message.
    #
    #   returns    a text; empty in this build, because nothing can be received
    #   see        LastMessage, Receive
    def MessageType()
        return @message_type
