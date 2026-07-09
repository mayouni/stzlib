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
    _clients_ = []                 # accepted clients (stzTcpClient instances)
    _is_listening_ = False
    _on_client_connect_callback_ = ""
    _on_client_disconnect_callback_ = ""
    _on_client_message_callback_ = ""
    _on_error_callback_ = ""

    def init()
        # stzNetwork.init takes no args; nothing to wire up here.

    def Listen(nPort, cHost)
        if cHost = "" cHost = "0.0.0.0" ok
        @hServer = StzEngineTcpListen(cHost, nPort)
        # Engine returns a null-pointer on failure; LastError tells.
        if StzEngineTcpLastError() = ""
            _is_listening_ = True
            ClearErrors()
        else
            _is_listening_ = False
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = -1
            if _on_error_callback_ != ""
                call _on_error_callback_()
            ok
        ok
        return This

    # Blocks until a client connects; returns the wrapped stzTcpClient
    # (or NULL on listener error). Caller is responsible for closing
    # the client when done.
    def AcceptOne()
        if not _is_listening_
            _last_error_ = "Not listening"
            return NULL
        ok
        pClient = StzEngineTcpAccept(@hServer)
        if StzEngineTcpLastError() != ""
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = -1
            if _on_error_callback_ != ""
                call _on_error_callback_()
            ok
            return NULL
        ok
        _oClient_ = new stzTcpClient
        # Patch the engine handle into the client wrapper so the
        # caller can Send/Receive/Close through the normal API.
        _oClient_.@hClient = pClient
        _oClient_.is_connected = True
        _clients_ + _oClient_
        if _on_client_connect_callback_ != ""
            call _on_client_connect_callback_()
        ok
        return _oClient_

    def StopListening()
        if _is_listening_ and @hServer != NULL
            StzEngineTcpServerClose(@hServer)
            @hServer = NULL
            _is_listening_ = False
        ok
        return This

    def Close()
        return This.StopListening()

    def OnClientConnect(cCallback)
        _on_client_connect_callback_ = cCallback
        return This

    def OnClientDisconnect(cCallback)
        _on_client_disconnect_callback_ = cCallback
        return This

    def OnClientMessage(cCallback)
        _on_client_message_callback_ = cCallback
        return This

    def OnError(cCallback)
        _on_error_callback_ = cCallback
        return This

    def IsListening()
        return _is_listening_

    def NumberOfClients()
        return len(_clients_)
