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
    bDebug = FALSE
    
    def init(cHostOrPort)
        # Allow init with just port number
        if isNumber(cHostOrPort)
            nPort = cHostOrPort
        else
            cHost = cHostOrPort
        ok
        
        # Initialize HTTP server
        oServer = new Server
        
    def route cMethod, cPath, cAction
        aRoutes + [cMethod, cPath, cAction]
        if bDebug see "Route added: " + cMethod + " " + cPath + nl ok
        
    def gett(cPath, cAction)
        oServer.route("Get", cPath, cAction)
        
    def postt(cPath, cAction)
        oServer.route("Post", cPath, cAction)
        
    def use(cMiddleware)
        aMiddleware + cMiddleware
        if bDebug see "Middleware added" + nl ok
        
    def handleRequest()
        # Execute middleware chain
        for middleware in aMiddleware
            try 
                eval(middleware)
            catch
                if bDebug see "Middleware error: " + cCatchError + nl ok
            done
        next
        
    def setupRoutes()
        for route in aRoutes
            cMethod = route[1]
            cPath = route[2]
            cAction = route[3]
            
            oServer.route(cMethod, cPath, "app.handleRequest() " + cAction)
        next
        
    def setDebug lValue
        bDebug = lValue
        
    def start
        setupRoutes()
        
        if bDebug
            ? "Server starting on " + cHost + ":" + nPort
            ? "Debug mode: ON"
            ? "Routes configured: " + len(aRoutes)
        ok
        
        try
            oServer.listen(cHost, nPort)
        catch
            ? "Server error: " + cCatchError
        done
        
    def stop()
        if bDebug ? "Server stopping..." ok
        oServer.stop()
        
    def response(cContent, cType)
        oServer.setContent(cContent, cType)
        
    def json(cData)
        response(List2Json(cData), "application/json")
        
    def html(cContent)
        response(cContent, "text/html")
        
    # Helper methods
    def getQuery()
        return oServer.Cookies()
        
    def getParam(cName)
        return oServer[cName]
