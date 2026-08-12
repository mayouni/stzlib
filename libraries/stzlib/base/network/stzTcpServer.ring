# =============================================================================
# TCP SERVER -- engine-backed synchronous TCP (M-DEP4 slice 2).
# Previously a libuv async server; rewired 2026-06-13 to the in-tree
# Zig engine (libraries/stzlib/engine/src/tcp.zig). Listen / Accept /
# Close are blocking std.net operations.
#
# Listen(nPort, cHost) starts the listener and returns immediately.
# AcceptOne() blocks until a client connects and returns a wrapped
# stzTcpClient. The legacy async-loop driving Listen() is dropped --
# real preemptive server work needs the cross-platform Zig event
# loop (multi-month future arc); for now you call AcceptOne() in a
# Ring loop yourself.
# =============================================================================

class stzTcpServer from stzNetwork
    @hServer = ""              # opaque engine TCP server handle
    @clients = []                 # accepted @clients (stzTcpClient instances)
    @is_listening = 0
    @on_client_connect_callback = ""
    @on_client_disconnect_callback = ""
    @on_client_message_callback = ""
    @on_error_callback = ""

    def init()
        # stzNetwork.init takes no args; nothing to wire up here.

    def Listen(nPort, cHost)
        if cHost = "" cHost = "0.0.0.0" ok
        @hServer = StzEngineTcpListen(cHost, nPort)
        # Engine returns a null-pointer on failure; LastError tells.
        if StzEngineTcpLastError() = ""
            @is_listening = 1
            ClearErrors()
        else
            @is_listening = 0
            @last_error = StzEngineTcpLastError()
            @error_code = -1
            if @on_error_callback != ""
                call @on_error_callback()
            ok
        ok
        return This

    # Blocks until a client connects; returns the wrapped stzTcpClient
    # (or NULL on listener error). Caller is responsible for closing
    # the client when done.
    def AcceptOne()
        if not @is_listening
            @last_error = "Not listening"
            return ""
        ok
        pClient = StzEngineTcpAccept(@hServer)
        if StzEngineTcpLastError() != ""
            @last_error = StzEngineTcpLastError()
            @error_code = -1
            if @on_error_callback != ""
                call @on_error_callback()
            ok
            return ""
        ok
        _oClient_ = new stzTcpClient
        # Patch the engine handle into the client wrapper so the
        # caller can Send/Receive/Close through the normal API.
        _oClient_.@hClient = pClient
        _oClient_.@is_connected = 1
        @clients + _oClient_
        if @on_client_connect_callback != ""
            call @on_client_connect_callback()
        ok
        return _oClient_

    # Accept, but give up after nMs and return NULL.
    #
    # AcceptOne() blocks for ever, so a caller whose point is "nothing should
    # have connected" has no way to say so -- it hangs instead of answering.
    # A timeout reports itself as the error "accept timed out", distinct from a
    # real accept failure -- a null handle still arrives in Ring as a TcpClient
    # value, so the error string is the only thing that can be tested.
    def AcceptOneWithin(nMs)
        if not @is_listening
            @last_error = "Not listening"
            return ""
        ok
        pClient = StzEngineTcpAccept(@hServer, nMs)
        if StzEngineTcpLastError() != ""
            @last_error = StzEngineTcpLastError()
            return ""
        ok
        _oClient_ = new stzTcpClient
        _oClient_.@hClient = pClient
        _oClient_.@is_connected = 1
        @clients + _oClient_
        if @on_client_connect_callback != ""
            call @on_client_connect_callback()
        ok
        return _oClient_

    # TRUE when the last AcceptOneWithin() simply saw nothing in time, as
    # opposed to failing.
    def AcceptTimedOut()
        return @last_error = "accept timed out"

    def StopListening()
        if @is_listening and @hServer != ""
            StzEngineTcpServerClose(@hServer)
            @hServer = ""
            @is_listening = 0
        ok
        return This

    def Close()
        return This.StopListening()

    def OnClientConnect(cCallback)
        @on_client_connect_callback = cCallback
        return This

    def OnClientDisconnect(cCallback)
        @on_client_disconnect_callback = cCallback
        return This

    def OnClientMessage(cCallback)
        @on_client_message_callback = cCallback
        return This

    def OnError(cCallback)
        @on_error_callback = cCallback
        return This

    def IsListening()
        return @is_listening

    def NumberOfClients()
        return len(@clients)
