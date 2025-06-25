// stzExterServer - Softanza External Code Integration System
// Unified platform for executing code in multiple languages, LLMs, and SQL

load "httplib.ring"
load "jsonlib.ring"

Class stzExterServer
    // Server configuration
    servers = []
    host = "127.0.0.1"
    startupTimeout = 5   // Seconds to wait for servers to start
    
    // Supabase configuration
    supabase_url = ""
    supabase_key = ""
    supabase_client = NULL
    
    func init(cHost)
	if cHost = "" { cHost = "127.0.0.1" }
        self.host = cHost
        
        // Define standard language servers
        addServer("ring", host, 5000, "ring ringserver.ring", "Ring")
        addServer("python", host, 5001, "python server.py", "Python")
        addServer("nodejs", host, 5002, "node server.js", "Node.js")
        addServer("julia", host, 5003, "julia server.jl", "Julia")
        addServer("r", host, 5004, "Rscript plumber.R", "R")
        addServer("prolog", host, 5005, "swipl -s server.pl", "Prolog")
        addServer("c", host, 5006, "./c_server", "C")
        addServer("csharp", host, 5007, "dotnet run", "C#")
        addServer("java", host, 5008, "java -jar excis-java.jar", "Java")

        
        // Define LLM servers
        addServer("lightllm", host, 5010, "python lightllm_server.py", "LightLLM", "llm")
        addServer("ollama", host, 5011, "ollama serve", "Ollama", "llm")
        addServer("vllm", host, 5012, "python vllm_server.py", "vLLM", "llm")
        
        // Define SQL servers
        addServer("sqlite", host, 5020, "node sqlite_server.js", "SQLite", "sql")
        addServer("postgresql", host, 5021, "node postgresql_server.js", "PostgreSQL", "sql")
        addServer("mysql", host, 5022, "node mysql_server.js", "MySQL", "sql")
        
        // Define Supabase servers
        addServer("supabase", host, 5030, "node supabase_server.js", "Supabase", "baas")
    
    func addServer(id, host, port, startCmd, name, category)
	if category = "" { category = "code" }
        server = new stzExterLangServer(id, host, port, startCmd, name, category)
        add(servers, server)
    
    func startAllServers
        for server in servers
            server.start()
        next
        
        // Wait for servers to be ready
        See "Waiting for language servers to start..." + nl
        for i = 1 to startupTimeout
            allReady = true
            for server in servers
                if !server.checkHealth()
                    allReady = false
                ok
            next
            if allReady
                See "All servers are ready!" + nl
                return true
            ok
            sleep(1)  // Wait 1 second
        next
        See "Warning: Some servers may not be ready yet." + nl
        return false
    
    func startServer(cServerID)
        for server in servers
            if server.id = cServerID
                return server.start()
            ok
        next
        stzraise("Unknown server ID: " + cServerID)
    
    func executeCode(language, code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        for server in servers
            if server.id = language
                return server.execute(code, params)
            ok
        next
        stzraise("Unsupported language: " + language)
    
    func executePython(code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return executeCode("python", code, params)
    
    func executeNodeJS(code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return executeCode("nodejs", code, params)
    
    func executeJulia(code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return executeCode("julia", code, params)
    
    func executeR(code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return executeCode("r", code, params)
    
    func executeProlog(code, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return executeCode("prolog", code, params)
    
    func executeLLM(model, prompt, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        if model = "lightllm" or model = "ollama" or model = "vllm"
            return executeCode(model, prompt, params)
        ok
        raise("Unsupported LLM model: " + model)
    
    func executeSQL(dialect, query, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        if dialect = "sqlite" or dialect = "postgresql" or dialect = "mysql"
            return executeCode(dialect, query, params)
        ok
        raise("Unsupported SQL dialect: " + dialect)
    
    func getServersByCategory(category)
        result = []
        for server in servers
            if server.category = category
                add(result, server)
            ok
        next
        return result
    
    func getAvailableLanguages
        result = []
        for server in servers
            if server.category = "code"
                server_info = new Map()
                server_info["id"] = server.id
                server_info["name"] = server.name
                server_info["status"] = server.checkHealth()
                add(result, server_info)
            ok
        next
        return result
    
    func getLLMServers
        return getServersByCategory("llm")
    
    func getSQLServers
        return getServersByCategory("sql")
    
    func getCodeServers
        return getServersByCategory("code")
    
    func getBaaSServers
        return getServersByCategory("baas")
    
    func getServerHealth(cServerID)
        for server in servers
            if server.id = cServerID
                return server.checkHealth()
            ok
        next
        return false
    
    func getAllServersHealth
        result = new Map()
        for server in servers
            result[server.id] = server.checkHealth()
        next
        return result
    
    func shutdown
        See "Shutting down all servers..." + nl
        for server in servers
            server.stop()
        next
        See "All servers shut down." + nl
    
    func shutdownServer(cServerID)
        for server in servers
            if server.id = cServerID
                return server.stop()
            ok
        next
        return false
    
    // Supabase integration methods
    
    func configureSupabase(url, key)
        self.supabase_url = url
        self.supabase_key = key
        return self
    
    func supabase()
        if !getServerHealth("supabase")
            startServer("supabase")
        ok
        
        return new stzSupabaseClient(self)
    
    func auth()
        return supabase().auth()
    
    func db()
        return supabase().db()
    
    func storage()
        return supabase().storage()
    
    func realtime()
        return supabase().realtime()
    
    func functions()
        return supabase().functions()
    
    func vector()
        return supabase().vector()

Class stzExterLangServer
    id = ""
    host = ""
    port = 0
    startCmd = ""
    name = ""
    category = "code"  // Default category is code
    process = NULL
    isRunning = false
    
    func init(id, host, port, startCmd, name, category)
	if category = "" { category = "code" }
        self.id = id
        self.host = host
        self.port = port
        self.startCmd = startCmd
        self.name = name
        self.category = category
    
    func start
        if isRunning
            See name + " server is already running." + nl
            return true
        ok
        
        See "Starting " + name + " server..." + nl
        process = system(startCmd + " > " + id + "_server.log 2>&1 &")
        
        // Check if server started
        for i = 1 to 10  // Try 10 times
            if checkHealth()
                See name + " server started successfully." + nl
                isRunning = true
                return true
            ok
            sleep(0.5)  // Wait 0.5 second between attempts
        next
        See "Warning: " + name + " server may not have started correctly." + nl
        return false
    
    func checkHealth
        try
            http = new HttpClient()
            http.timeout = 1  // 1 second timeout for health check
            response = http.gett("http://" + host + ":" + string(port) + "/health")
            isRunning = (response.statuscode = 200)
            return isRunning
        catch
            isRunning = false
            return false
        end
    
    func execute(code, params)
        if !isRunning and !start()
            return Json('{"status": "error", "error": "Server not running and could nott start"}')
        ok
            
        request = new Map()
        request["code"] = code
        
        if isObject(params)
            request["params"] = params
        ok
        
        try
            http = new HttpClient()
            http.timeout = 30  // 30 seconds timeout
            json_request = list2json(request)
            url = "http://" + host + ":" + string(port) + "/execute"
            
            response = http.postJson(url, json_request)
            
            if response.statuscode = 200
                return json2list(response.body)
            else
                return json('{"status": "error", "error": "HTTP error: "' + response.statuscode +'}')
            ok
        catch e
            return Json('{"status": "error", "error":' + e.getMessage() + '}')
        end
    
    func stop
        if !isRunning
            See name + " server is not running." + nl
            return true
        ok
        
        See "Stopping " + name + " server..." + nl
        
        // Send shutdown signal to server
        try
            http = new HttpClient()
            http.gett("http://" + host + ":" + string(port) + "/shutdown")
        catch
            // Ignore errors during shutdown
        end
        
        // Verify server stopped
        for i = 1 to 5  // Try 5 times
            if !checkHealth()
                isRunning = false
                See name + " server stopped successfully." + nl
                return true
            ok
            sleep(0.5)  // Wait 0.5 second between attempts
        next
        
        // Force kill if necessary
        if isRunning
            system("pkill -f '" + startCmd + "'")
            isRunning = false
            See name + " server force stopped." + nl
        ok
        
        return true

Class stzSupabaseClient
    server = NULL
    
    func init(oServer)
        self.server = oServer
    
    func executeSupabase(method, endpoint, params)
	if NOT isList(params) { stzraise("Incorrect param type! params must be a list.") }
        if !server.getServerHealth("supabase")
            server.startServer("supabase")
        ok
        
        // Add Supabase config to params
        if !isObject(params)
            params = []
        ok
        
        params["supabase_url"] = server.supabase_url
        params["supabase_key"] = server.supabase_key
        
        // Create request for Supabase server
        request = [
            "method": method,
            "endpoint": endpoint,
            "params": params
        ]
        
        return server.executeCode("supabase", list2json(request), [])
    
    func auth()
        return new stzSupabaseAuth(self)
    
    func db()
        return new stzSupabaseDB(self)
    
    func storage()
        return new stzSupabaseStorage(self)
    
    func realtime()
        return new stzSupabaseRealtime(self)
    
    func functions()
        return new stzSupabaseFunctions(self)
    
    func vector()
        return new stzSupabaseVector(self)

Class stzSupabaseAuth
    client = NULL
    
    func init(oClient)
        self.client = oClient
    
    func signUp(email, password, options)
	if not isList(options) { stzraise("Incorrect param type! options must be a list.") }
        return client.executeSupabase("POST", "/auth/v1/signup", [
            "email": email,
            "password": password,
            "options": options
        ])
    
    func signIn(email, password)
        return client.executeSupabase("POST", "/auth/v1/token", [
            "email": email,
            "password": password,
            "grant_type": "password"
        ])
    
    func signOut(jwt)
        return client.executeSupabase("POST", "/auth/v1/logout", [
            "jwt": jwt
        ])
    
    func getUser(jwt)
        return client.executeSupabase("GET", "/auth/v1/user", [
            "jwt": jwt
        ])

Class stzSupabaseDB
    client = NULL
    
    func init(oClient)
        self.client = oClient
    
    func select(table, columns, filters)
	if columns = "" { columns = '*' }
	if not isList(filters) { staraise("Incorrect param type! filters must be a list.") }
        return client.executeSupabase("GET", "/rest/v1/" + table, [
            "select": columns,
            "filters": filters
        ])
    
    func insert(table, data)
        return client.executeSupabase("POST", "/rest/v1/" + table, [
            "data": data
        ])
    
    func update(table, data, filters)
        return client.executeSupabase("PATCH", "/rest/v1/" + table, [
            "data": data,
            "filters": filters
        ])
    
    func delete(table, filters)
        return client.executeSupabase("DELETE", "/rest/v1/" + table, [
            "filters": filters
        ])
    
    func rpc(funktion, params)
	if not isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return client.executeSupabase("POST", "/rest/v1/rpc/" + funktion, params)

Class stzSupabaseStorage
    client = NULL
    
    func init(oClient)
        self.client = oClient
    
    func listBuckets()
        return client.executeSupabase("GET", "/storage/v1/bucket", [])
    
    func createBucket(name, isPublic)
	if not isNumber(isPublic) { stzraise("Incorrect param type! isPublic  must be a number.") }
	if isPublic != 1 { isPublic = 0 }
        return client.executeSupabase("POST", "/storage/v1/bucket", [
            "name": name,
            "public": isPublic
        ])
    
    func upload(bucket, path, data, contentType)
	if contentType = '' { contentType = "application/octet-stream" }
        return client.executeSupabase("POST", "/storage/v1/object/" + bucket + "/" + path, [
            "data": data,
            "contentType": contentType
        ])
    
    func download(bucket, path)
        return client.executeSupabase("GET", "/storage/v1/object/" + bucket + "/" + path, [])
    
    func remove(bucket, path)
        return client.executeSupabase("DELETE", "/storage/v1/object/" + bucket + "/" + path, [])

Class stzSupabaseRealtime
    client = NULL
    subscriptions = []
    
    func init(oClient)
        self.client = oClient
    
    func subscribe(table, callback)
        id = len(subscriptions) + 1
        
        result = client.executeSupabase("POST", "/realtime/v1/subscribe", [
            "table": table,
            "subscription_id": string(id)
        ])
        
        if result["status"] = "success"
            subscription = [
                "id": id,
                "table": table,
                "callback": callback
            ]
            add(subscriptions, subscription)
        ok
        
        return result
    
    func unsubscribe(id)
        for i = 1 to len(subscriptions)
            if subscriptions[i]["id"] = id
                result = client.executeSupabase("POST", "/realtime/v1/unsubscribe", [
                    "subscription_id": string(id)
                ])
                
                del(subscriptions, i)
                return result
            ok
        next
        
        return Json('{"status": "error", "error": "Subscription not found"}')

Class stzSupabaseFunctions
    client = NULL
    
    func init(oClient)
        self.client = oClient
    
    func invoke(name, params)
	if not isList(params) { stzraise("Incorrect param type! params must be a list.") }
        return client.executeSupabase("POST", "/functions/v1/" + name, params)

Class stzSupabaseVector
    client = NULL
    
    func init(oClient)
        self.client = oClient
    
    func create(collection, dimensions, metric)
	if metric = '' { metric = "cosine" }
        return client.executeSupabase("POST", "/vector/v1/collections", [
            "name": collection,
            "dimensions": dimensions,
            "metric": metric
        ])
    
    func insert(collection, vectors, metadata)
	if not isList(metadata) { stzraise("Incorrect param type! metadata must be a list.") }
        return client.executeSupabase("POST", "/vector/v1/collections/" + collection + "/vectors", [
            "vectors": vectors,
            "metadata": metadata
        ])
    
    func query(collection, queryVector, topK, filters)
	if not isNumber(topK) { stzraise("Incorrect param type! topK must be a number.") }
	if topK = 0 { topK = 10 }
	if not isList(metadata) { stzraise("Incorrect param type! metadata must be a list.") }
        return client.executeSupabase("POST", "/vector/v1/collections/" + collection + "/query", [
            "query_vector": queryVector,
            "top_k": topK,
            "filters": filters
        ])
