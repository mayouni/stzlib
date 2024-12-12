# Simple Application server in Ring
# Dedicated to serve Softanza as an API
# Work in Progress

load "httplib.ring"
load "stdlib.ring"
load "jsonlib.ring"

class RingAppServer 
    
    # Server instance
    oServer
    
    # Application routes storage
    aRoutes = []
    
    # Middleware storage
    aMiddleware = []
    
    # Configuration
    cHost = "localhost"
    nPort = 8080
    lDebug _FALSE_
    
    func init cHostOrPort
        # Allow init with just port number
        if isNumber(cHostOrPort)
            nPort = cHostOrPort
        else
            cHost = cHostOrPort
        ok
        
        # Initialize HTTP server
        oServer = new Server
        
    func route cMethod, cPath, cAction
        aRoutes + [cMethod, cPath, cAction]
        if lDebug see "Route added: " + cMethod + " " + cPath + nl ok
        
    func gett(cPath, cAction)
        oServer.route("Get", cPath, cAction)
        
    func postt(cPath, cAction)
        oServer.route("Post", cPath, cAction)
        
    func use(cMiddleware)
        aMiddleware + cMiddleware
        if lDebug see "Middleware added" + nl ok
        
    func handleRequest()
        # Execute middleware chain
        for middleware in aMiddleware
            try 
                eval(middleware)
            catch
                if lDebug see "Middleware error: " + cCatchError + nl ok
            done
        next
        
    func setupRoutes()
        for route in aRoutes
            cMethod = route[1]
            cPath = route[2]
            cAction = route[3]
            
            oServer.route(cMethod, cPath, "app.handleRequest() " + cAction)
        next
        
    func setDebug lValue
        lDebug = lValue
        
    func start
        setupRoutes()
        
        if lDebug
            ? "Server starting on " + cHost + ":" + nPort
            ? "Debug mode: ON"
            ? "Routes configured: " + len(aRoutes)
        ok
        
        try
            oServer.listen(cHost, nPort)
        catch
            ? "Server error: " + cCatchError
        done
        
    func stop()
        if lDebug ? "Server stopping..." ok
        oServer.stop()
        
    func response(cContent, cType)
        oServer.setContent(cContent, cType)
        
    func json(cData)
        response(List2Json(cData), "application/json")
        
    func html(cContent)
        response(cContent, "text/html")
        
    # Helper methods
    func getQuery()
        return oServer.Cookies()
        
    func getParam(cName)
        return oServer[cName]
