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
    @hServer = NULL              # opaque engine TCP server handle
    clients = []                 # accepted clients (stzTcpClient instances)
    is_listening = False
    on_client_connect_callback = ""
    on_client_disconnect_callback = ""
    on_client_message_callback = ""
    on_error_callback = ""

    def init()
        # stzNetwork.init takes no args; nothing to wire up here.

    def Listen(nPort, cHost)
        if cHost = "" cHost = "0.0.0.0" ok
        @hServer = StzEngineTcpListen(cHost, nPort)
        # Engine returns a null-pointer on failure; LastError tells.
        if StzEngineTcpLastError() = ""
            is_listening = True
            ClearErrors()
        else
            is_listening = False
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = -1
            if on_error_callback != ""
                call on_error_callback()
            ok
        ok
        return This

    # Blocks until a client connects; returns the wrapped stzTcpClient
    # (or NULL on listener error). Caller is responsible for closing
    # the client when done.
    def AcceptOne()
        if not is_listening
            _last_error_ = "Not listening"
            return NULL
        ok
        pClient = StzEngineTcpAccept(@hServer)
        if StzEngineTcpLastError() != ""
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = -1
            if on_error_callback != ""
                call on_error_callback()
            ok
            return NULL
        ok
        _oClient_ = new stzTcpClient
        # Patch the engine handle into the client wrapper so the
        # caller can Send/Receive/Close through the normal API.
        _oClient_.@hClient = pClient
        _oClient_.is_connected = True
        clients + _oClient_
        if on_client_connect_callback != ""
            call on_client_connect_callback()
        ok
        return _oClient_

    def StopListening()
        if is_listening and @hServer != NULL
            StzEngineTcpServerClose(@hServer)
            @hServer = NULL
            is_listening = False
        ok
        return This

    def Close()
        return This.StopListening()

    def OnClientConnect(cCallback)
        on_client_connect_callback = cCallback
        return This

    def OnClientDisconnect(cCallback)
        on_client_disconnect_callback = cCallback
        return This

    def OnClientMessage(cCallback)
        on_client_message_callback = cCallback
        return This

    def OnError(cCallback)
        on_error_callback = cCallback
        return This

    def IsListening()
        return is_listening

    def NumberOfClients()
        return len(clients)
