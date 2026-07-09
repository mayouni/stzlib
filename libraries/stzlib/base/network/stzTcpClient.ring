# =============================================================================
# TCP CLIENT -- engine-backed synchronous TCP (M-DEP4 slice 2).
# Previously a libuv async wrapper; rewired 2026-06-13 to the in-tree
# Zig engine (libraries/stzlib/engine/src/tcp.zig) which uses std.net
# for blocking connect / send / recv / close.
#
# The public surface (Connect/Send/Receive/Close + OnX callback
# setters) is preserved so callers do not need to change. Callbacks
# now fire synchronously after the corresponding operation returns;
# the async libuv loop is gone.
# =============================================================================

class stzTcpClient from stzNetwork
    @hClient = NULL              # opaque engine TCP handle
    _is_connected_ = False
    _on_connect_callback_ = ""
    _on_receive_callback_ = ""
    _on_close_callback_ = ""
    _on_error_callback_ = ""
    _received_data_ = ""

    def init()
        # stzNetwork.init takes no args; nothing more to wire up.

    def Connect(cHost, nPort)
        @hClient = StzEngineTcpConnect(cHost, nPort)
        # The engine returns a null-pointer (not literal NULL) on
        # failure. Cross-check via LastError -- empty means success.
        if StzEngineTcpLastError() = ""
            _is_connected_ = True
            ClearErrors()
            if _on_connect_callback_ != ""
                call _on_connect_callback_()
            ok
        else
            _is_connected_ = False
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = -1
            if _on_error_callback_ != ""
                call _on_error_callback_()
            ok
        ok
        return This

    def Send(cData)
        if not _is_connected_
            _last_error_ = "Not connected"
            return This
        ok
        _nSent_ = StzEngineTcpSend(@hClient, cData)
        if _nSent_ < 0
            _last_error_ = StzEngineTcpLastError()
            _error_code_ = _nSent_
            if _on_error_callback_ != ""
                call _on_error_callback_()
            ok
        ok
        return This

    def Receive()
        return This.ReceiveWithMax(8192)

    def ReceiveWithMax(nMaxBytes)
        if not _is_connected_
            _last_error_ = "Not connected"
            return This
        ok
        _received_data_ = StzEngineTcpRecv(@hClient, nMaxBytes)
        if _received_data_ = ""
            # Either EOF or error -- LastError lets the caller decide.
            _last_error_ = StzEngineTcpLastError()
            if _last_error_ != "" and _on_error_callback_ != ""
                call _on_error_callback_()
            ok
        else
            ClearErrors()
            if _on_receive_callback_ != ""
                call _on_receive_callback_()
            ok
        ok
        return This

    def ReceivedData()
        return _received_data_

    def Close()
        if _is_connected_ and @hClient != NULL
            StzEngineTcpClose(@hClient)
            @hClient = NULL
            _is_connected_ = False
            if _on_close_callback_ != ""
                call _on_close_callback_()
            ok
        ok
        return This

    def OnConnect(cCallback)
        _on_connect_callback_ = cCallback
        return This

    def OnReceive(cCallback)
        _on_receive_callback_ = cCallback
        return This

    def OnClose(cCallback)
        _on_close_callback_ = cCallback
        return This

    def OnError(cCallback)
        _on_error_callback_ = cCallback
        return This

    def IsConnected()
        return _is_connected_

    def LocalAddress()
        # std.net doesn't yet expose this through the bridge; engine
        # slice 3 can add it if a caller needs it.
        return "127.0.0.1"

    def RemoteAddress()
        return "0.0.0.0"
