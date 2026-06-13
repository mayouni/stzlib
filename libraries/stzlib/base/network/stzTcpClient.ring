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
    is_connected = False
    on_connect_callback = ""
    on_receive_callback = ""
    on_close_callback = ""
    on_error_callback = ""
    received_data = ""

    def init()
        # stzNetwork.init takes no args; nothing more to wire up.

    def Connect(cHost, nPort)
        @hClient = StzEngineTcpConnect(cHost, nPort)
        # The engine returns a null-pointer (not literal NULL) on
        # failure. Cross-check via LastError -- empty means success.
        if StzEngineTcpLastError() = ""
            is_connected = True
            ClearErrors()
            if on_connect_callback != ""
                call on_connect_callback()
            ok
        else
            is_connected = False
            last_error = StzEngineTcpLastError()
            error_code = -1
            if on_error_callback != ""
                call on_error_callback()
            ok
        ok
        return This

    def Send(cData)
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        nSent = StzEngineTcpSend(@hClient, cData)
        if nSent < 0
            last_error = StzEngineTcpLastError()
            error_code = nSent
            if on_error_callback != ""
                call on_error_callback()
            ok
        ok
        return This

    def Receive()
        return This.ReceiveWithMax(8192)

    def ReceiveWithMax(nMaxBytes)
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        received_data = StzEngineTcpRecv(@hClient, nMaxBytes)
        if received_data = ""
            # Either EOF or error -- LastError lets the caller decide.
            last_error = StzEngineTcpLastError()
            if last_error != "" and on_error_callback != ""
                call on_error_callback()
            ok
        else
            ClearErrors()
            if on_receive_callback != ""
                call on_receive_callback()
            ok
        ok
        return This

    def ReceivedData()
        return received_data

    def Close()
        if is_connected and @hClient != NULL
            StzEngineTcpClose(@hClient)
            @hClient = NULL
            is_connected = False
            if on_close_callback != ""
                call on_close_callback()
            ok
        ok
        return This

    def OnConnect(cCallback)
        on_connect_callback = cCallback
        return This

    def OnReceive(cCallback)
        on_receive_callback = cCallback
        return This

    def OnClose(cCallback)
        on_close_callback = cCallback
        return This

    def OnError(cCallback)
        on_error_callback = cCallback
        return This

    def IsConnected()
        return is_connected

    def LocalAddress()
        # std.net doesn't yet expose this through the bridge; engine
        # slice 3 can add it if a caller needs it.
        return "127.0.0.1"

    def RemoteAddress()
        return "0.0.0.0"
