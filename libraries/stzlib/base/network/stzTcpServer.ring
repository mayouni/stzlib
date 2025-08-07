# =============================================================================
# TCP SERVER - libuv-based async TCP server
# =============================================================================

class stzTcpServer from stzNetwork
    server = NULL
    @loop = NULL
    clients = []
    is_listening = False
    on_client_connect_callback = ""
    on_client_disconnect_callback = ""
    on_client_message_callback = ""
    on_error_callback = ""
    
    def init()
        super.init()
        @loop = uv_defaulLoop()
        server = new_uv_tcp_t()
        uv_tcp_init(@loop, server)
    
    def Listen(nPort, cHost)
	if cHost = ""
		cHost = "127.0.0.1"
	ok

        addr = new_sockaddr_in()
        uv_ip4_addr(cHost, nPort, addr)
        uv_tcp_bind(server, addr, 0)
        
        result = uv_listen(server, 128, "HandleNewConnection()")
        if result = 0
            is_listening = True
            ClearErrors()
            uv_run(@loop, UV_RUN_DEFAULT)
        else
            last_error = "Failed to listen on port " + nPort
            error_code = result
        ok
        return This
    
    def HandleNewConnection()
        aPara = uv_Eventpara(server, :connect)
        nStatus = aPara[2]
        
        if nStatus < 0
            last_error = "New connection error"
            error_code = nStatus
            return
        ok
        
        client = new_uv_tcp_t()
        uv_tcp_init(@loop, client)
        
        if uv_accept(server, client) = 0
            clients + client
            uv_read_start(client, uv_myalloccallback(), "HandleClientMessage()")
            
            if on_client_connect_callback != ""
                call on_client_connect_callback()
            ok
        ok
    
    def HandleClientMessage()
        # Implementation similar to TCP client's HandleRead
        aPara = uv_Eventpara(client, :read)
        nRead = aPara[2]
        buf = aPara[3]
        
        if nRead > 0
            received_data = uv_buf2str(buf)
            if on_client_message_callback != ""
                call on_client_message_callback()
            ok
        ok
    
    def Stop_()
        is_listening = False
        if server != NULL
            # Stop server and cleanup
            clients = []
        ok
        return This
    
    def IsListening()
        return is_listening
    
    def Clients()
        return clients
    
    def ClientCount()
        return len(clients)
    
    def BroadcastTo(aClients, cData)
        for client in aClients
            buf = new_uv_buf_t()
            set_uv_buf_t_len(buf, len(cData))
            set_uv_buf_t_base(buf, varptr("cData", :char))
            
            write_req = new_uv_write_t()
            uv_write(write_req, client, buf, 1, "HandleWrite()")
        next
        return This
    
    def BroadcastToAll(cData)
        return This.BroadcastTo(clients, cData)
    
    def KickClient(oClient)
        # Remove client from list and close connection
        new_clients = []
        for client in clients
            if client != oClient
                new_clients + client
            ok
        next
        clients = new_clients
        return This
    
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
