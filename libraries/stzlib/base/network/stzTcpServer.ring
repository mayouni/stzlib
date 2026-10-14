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

# Holds a blocking TCP listener that accepts clients one at a time and hands each back as a connected stzTcpClient.
#
# Listen starts the listener and returns at once; the application then calls AcceptOne, or
# AcceptOneWithin to give up after a time, in its own loop. There is no event loop: the Disconnect
# and Message callbacks are stored and never called. Pass 127.0.0.1 as the host for a local test,
# because an empty host listens on every interface. The documentation was run only against a client
# in the same process on the loopback address, stopped afterwards.
#
#   receiver   o1 = new stzTcpServer()
#   example    ? o1.IsListening()
#              #--> 0
#              o1.Listen(47315, "127.0.0.1")
#              ? o1.IsListening()
#              #--> 1
#              o1.AcceptOneWithin(50)
#              ? o1.AcceptTimedOut()
#              #--> 1
#              o1.StopListening()
#              ? o1.IsListening()
#              #--> 0
#   see        stzTcpClient, stzNetwork
class stzTcpServer from stzNetwork
    @hServer = ""              # opaque engine TCP server handle
    @clients = []                 # accepted @clients (stzTcpClient instances)
    @is_listening = 0
    @on_client_connect_callback = ""
    @on_client_disconnect_callback = ""
    @on_client_message_callback = ""
    @on_error_callback = ""

    # Builds a TCP server that is not listening and has no callbacks.
    #
    #   returns    nothing; the object is built
    #   see        Listen
    def init()
    # Starts listening on a port and returns at once, firing the error callback on failure.
    #
    #   nPort      the port number
    #   cHost      the address to listen on, where an empty text means 0.0.0.0, every network
    #              interface
    #   returns    the server itself, so calls chain
    #   note       for a local test pass 127.0.0.1, since an empty host opens the port to the
    #              network
    #   warning    a failure does not raise: IsListening stays FALSE and LastError says why; a
    #              second listener on a port already bound reported listening too on this Windows
    #              machine, with no error
    #   see        AcceptOne, StopListening, IsListening
    #@ aka  stzNetwork.init takes no args; nothing to wire up here.
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

    # Blocks until a client connects and returns it wrapped as a connected stzTcpClient.
    #
    #   returns    a stzTcpClient; an empty text when the server is not listening or the accept
    #              failed, with LastError saying why
    #   note       the client is kept in the server's list as well
    #   warning    it waits for ever when nobody connects; keep each accepted client and close it
    #   see        AcceptOneWithin, Listen
    #@ aka  Blocks until a client connects; returns the wrapped stzTcpClient (or NULL on listener error). Caller is responsible for closing the client when done.
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

    # Waits at most that many milliseconds for a client and returns it, or an empty text if none came.
    #
    #   nMs        the longest wait in milliseconds
    #   returns    a stzTcpClient; an empty text on timeout or error
    #   note       after a timeout LastError is accept timed out, which AcceptTimedOut tests
    #   see        AcceptTimedOut, AcceptOne
    #@ aka  Accept, but give up after nMs and return NULL.
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

    # TRUE if the last wait for a client ended by timeout and not by failure.
    #
    #   returns    TRUE or FALSE
    #   see        AcceptOneWithin
    #@ aka  TRUE when the last AcceptOneWithin() simply saw nothing in time, as opposed to failing.
    def AcceptTimedOut()
        return @last_error = "accept timed out"

    # Closes the listening socket; calling it on a server that is not listening does nothing.
    #
    #   returns    the server itself, so calls chain
    #   note       accepted clients stay open until they are closed
    #   see        Listen, IsListening
    def StopListening()
        if @is_listening and @hServer != ""
            StzEngineTcpServerClose(@hServer)
            @hServer = ""
            @is_listening = 0
        ok
        return This

    def Close()
        return This.StopListening()

    # Sets the function called each time a client is accepted.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the server itself, so calls chain
    #   note        choose a function name of your own: a name the library already defines as a
    #               function with parameters fails with a wrong-parameter error
    #   see         AcceptOne, OnError
    def OnClientConnect(cCallback)
        @on_client_connect_callback = cCallback
        return This

    # Stores a function name meant to run when a client disconnects.
    #
    #   cCallback   the name of a function
    #   returns     the server itself, so calls chain
    #   note        it is kept but not used
    #   warning     the server never calls it today
    #   see         OnClientConnect
    def OnClientDisconnect(cCallback)
        @on_client_disconnect_callback = cCallback
        return This

    # Stores a function name meant to run when a client sends a message.
    #
    #   cCallback   the name of a function
    #   returns     the server itself, so calls chain
    #   note        read each client's data with its own Receive
    #   warning     the server never calls it today
    #   see         OnClientConnect
    def OnClientMessage(cCallback)
        @on_client_message_callback = cCallback
        return This

    # Sets the function called when Listen or an accept fails.
    #
    #   cCallback   the name of a function that takes no parameter
    #   returns     the server itself, so calls chain
    #   see         Listen, LastError
    def OnError(cCallback)
        @on_error_callback = cCallback
        return This

    # TRUE if the server is listening.
    #
    #   returns    TRUE or FALSE
    #   see        Listen, StopListening
    def IsListening()
        return @is_listening

    # Returns how many clients the server has accepted.
    #
    #   returns    a number
    #   see        AcceptOne
    def NumberOfClients()
        return len(@clients)
