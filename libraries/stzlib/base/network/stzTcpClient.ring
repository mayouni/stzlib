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

# Holds a blocking TCP client connection that connects, sends text, reads text and closes, through the in-tree engine.
#
# Every call is synchronous: Connect, Send and Receive return when the operation has finished, and
# the callbacks set with OnConnect, OnReceive, OnClose and OnError run synchronously just after it.
# A failure never raises; the client records it in LastError and calls the error callback. Receive
# and ReceiveWithMax block with no timeout until data arrives or the peer closes, so call them only
# when data is expected. The documentation was run against a listener started in the same process on
# the loopback address and stopped afterwards, never against another machine.
#
#   receiver   o1 = new stzTcpClient()
#   example    ? o1.IsConnected()
#              #--> 0
#              o1.Send("hello")
#              ? o1.LastError()
#              #--> Not connected
#              ? o1.LocalAddress()
#              #--> 127.0.0.1
#   see        stzTcpServer, stzNetwork, stzHttpClient
class stzTcpClient from stzNetwork
    @hClient = ""              # opaque engine TCP handle
    @is_connected = 0
    @on_connect_callback = ""
    @on_receive_callback = ""
    @on_close_callback = ""
    @on_error_callback = ""
    @received_data = ""

    # Builds a TCP client that is not connected and has no callbacks.
    #
    #   returns    nothing; the object is built
    #   see        Connect
    def init()
    # Opens a blocking TCP connection to a host and port, and fires the connect or the error callback.
    #
    #   cHost      the host name or address
    #   nPort      the port number
    #   returns    the client itself, so calls chain
    #   note       the callbacks are names of functions, called with no argument
    #   warning    a refusal or an unresolvable host does not raise: the client stays unconnected
    #              and LastError names the cause, such as connect failed: ConnectionRefused
    #   see        Send, Receive, IsConnected
    #@ aka  stzNetwork.init takes no args; nothing more to wire up.
    def Connect(cHost, nPort)
        @hClient = StzEngineTcpConnect(cHost, nPort)
        # The engine returns a null-pointer (not literal NULL) on
        # failure. Cross-check via LastError -- empty means success.
        if StzEngineTcpLastError() = ""
            @is_connected = 1
            ClearErrors()
            if @on_connect_callback != ""
                call @on_connect_callback()
            ok
        else
            @is_connected = 0
            @last_error = StzEngineTcpLastError()
            @error_code = -1
            if @on_error_callback != ""
                call @on_error_callback()
            ok
        ok
        return This

    # Sends text on the open connection, reporting a failure through LastError and the error callback.
    #
    #   cData      the text to send
    #   returns    the client itself, so calls chain
    #   warning    without a connection it sets LastError to Not connected and sends nothing
    #   see        Receive, Connect
    def Send(cData)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        _nSent_ = StzEngineTcpSend(@hClient, cData)
        if _nSent_ < 0
            @last_error = StzEngineTcpLastError()
            @error_code = _nSent_
            if @on_error_callback != ""
                call @on_error_callback()
            ok
        ok
        return This

    # Reads at most 8192 bytes from the connection into ReceivedData and fires the receive callback.
    #
    #   returns    the client itself, so calls chain
    #   warning    it blocks until data arrives or the peer closes, with no timeout; an empty
    #              ReceivedData and no error means the peer closed
    #   see        ReceiveWithMax, ReceivedData
    def Receive()
        return This.ReceiveWithMax(8192)

    # Reads at most that many bytes from the connection into ReceivedData and fires the receive callback.
    #
    #   nMaxBytes   the most bytes to read in this call
    #   returns     the client itself, so calls chain
    #   warning     it blocks until data arrives or the peer closes, with no timeout; a message
    #               longer than the limit is read by several calls
    #   see         Receive, ReceivedData
    def ReceiveWithMax(nMaxBytes)
        if not @is_connected
            @last_error = "Not connected"
            return This
        ok
        @received_data = StzEngineTcpRecv(@hClient, nMaxBytes)
        if @received_data = ""
            # Either EOF or error -- LastError lets the caller decide.
            @last_error = StzEngineTcpLastError()
            if @last_error != "" and @on_error_callback != ""
                call @on_error_callback()
            ok
        else
            ClearErrors()
            if @on_receive_callback != ""
                call @on_receive_callback()
            ok
        ok
        return This

    # Returns what the last Receive read.
    #
    #   returns    a text; empty before a read and after the peer closed
    #   see        Receive
    def ReceivedData()
        return @received_data

    # Closes the connection and fires the close callback; closing a client that is not connected does nothing.
    #
    #   returns    the client itself, so calls chain
    #   see        Connect
    def Close()
        if @is_connected and @hClient != ""
            StzEngineTcpClose(@hClient)
            @hClient = ""
            @is_connected = 0
            if @on_close_callback != ""
                call @on_close_callback()
            ok
        ok
        return This

    # Sets the function called after a successful Connect.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   note        choose a function name of your own: a name the library already defines as a
    #               function with parameters fails with a wrong-parameter error
    #   see         OnReceive, OnClose, OnError
    def OnConnect(cCallback)
        @on_connect_callback = cCallback
        return This

    # Sets the function called after a Receive that read data.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   see         OnConnect, ReceivedData
    def OnReceive(cCallback)
        @on_receive_callback = cCallback
        return This

    # Sets the function called after Close shuts an open connection.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   see         OnConnect, Close
    def OnClose(cCallback)
        @on_close_callback = cCallback
        return This

    # Sets the function called when a Connect, Send or Receive fails.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the client itself, so calls chain
    #   see         OnConnect, LastError
    def OnError(cCallback)
        @on_error_callback = cCallback
        return This

    # TRUE if the connection is open.
    #
    #   returns    TRUE or FALSE
    #   note       unlike the base class, it reports the socket, not whether a request has run
    #   see        Connect, Close
    def IsConnected()
        return @is_connected

    # Returns the local address, which is always the text 127.0.0.1.
    #
    #   returns    the text 127.0.0.1
    #   note       do not rely on it
    #   warning    the value is a fixed placeholder: the engine does not report the real local
    #              address
    #   see        RemoteAddress
    def LocalAddress()
        # std.net doesn't yet expose this through the bridge; engine
        # slice 3 can add it if a caller needs it.
        return "127.0.0.1"

    # Returns the remote address, which is always the text 0.0.0.0.
    #
    #   returns    the text 0.0.0.0
    #   note       do not rely on it
    #   warning    the value is a fixed placeholder: the engine does not report the peer's address
    #   see        LocalAddress
    def RemoteAddress()
        return "0.0.0.0"
