# =============================================================================
# TCP CLIENT - libuv-based async TCP
# =============================================================================

class stzTcpClient from stzNetwork
    socket = NULL
    @loop = NULL
    is_connected = False
    on_connect_callback = ""
    on_receive_callback = ""
    on_close_callback = ""
    on_error_callback = ""
    
    def init()
        super.init()
        @loop = uv_defaulLoop()
        socket = new_uv_tcp_t()
        uv_tcp_init(@loop, socket)
    
    def Connect(cHost, nPort)
        addr = new_sockaddr_in()
        uv_ip4_addr(cHost, nPort, addr)
        
        connect_req = new_uv_connect_t()
        uv_tcp_connect(connect_req, socket, addr, "HandleConnect()")
        
        uv_run(@loop, UV_RUN_DEFAULT)
        return This
    
    def HandleConnect()
        aPara = uv_Eventpara(connect_req, :connect)
        nStatus = aPara[2]
        
        if nStatus = 0
            is_connected = True
            ClearErrors()
            if on_connect_callback != ""
                call on_connect_callback()
            ok
        else
            last_error = "Connection failed"
            error_code = nStatus
            if on_error_callback != ""
                call on_error_callback()
            ok
        ok
    
    def Send(cData)
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        
        buf = new_uv_buf_t()
        set_uv_buf_t_len(buf, len(cData))
        set_uv_buf_t_base(buf, varptr("cData", :char))
        
        write_req = new_uv_write_t()
        uv_write(write_req, socket, buf, 1, "HandleWrite()")
        return This
    
    def HandleWrite()
        # Write completion handler
        aPara = uv_Eventpara(socket, :write)
        nStatus = aPara[2]
        if nStatus < 0
            last_error = "Write failed"
            error_code = nStatus
        ok
    
    def Receive()
        if not is_connected
            last_error = "Not connected"
            return This
        ok
        
        uv_read_start(socket, uv_myalloccallback(), "HandleRead()")
        return This
    
    def HandleRead()
        aPara = uv_Eventpara(socket, :read)
        nRead = aPara[2]
        buf = aPara[3]
        
        if nRead > 0
            received_data = uv_buf2str(buf)
            ClearErrors()
            if on_receive_callback != ""
                call on_receive_callback()
            ok
        elseif nRead < 0
            last_error = "Read error"
            error_code = nRead
            if on_error_callback != ""
                call on_error_callback()
            ok
        ok
    
    def Close()
        if is_connected and socket != NULL
            # Close the socket
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
        # Would implement getting local socket address
        return "127.0.0.1"
    
    def RemoteAddress()
        # Would implement getting remote socket address
        return "0.0.0.0"
