load "stzbase.ring"
load "stzreactive.ring"
load "stznetwork.ring"

#========================================#
#  STZAPPSERVER - PERSISTENT COMPUTATIONAL WEB ENGINE
#========================================#

/*--- Core Philosophy

stzAppServer transforms the traditional web server paradigm by treating
Softanza as a persistent computational engine rather than a per-request library.

TRADITIONAL APPROACH:          SOFTANZA APPROACH:
==================            ===================

Request arrives               Request arrives
  ↓                            ↓
Load libraries               Parse & route (lightweight)
  ↓                            ↓
Process request              Emit to persistent engine
  ↓                            ↓
Generate response            Process with pre-loaded Softanza
  ↓                            ↓
Cleanup & unload             Return result (reactive)
  ↓                            ↓
Send response                Send response

BENEFITS:
- No initialization overhead per request
- Rich computational power always available
- Event-driven, non-blocking architecture
- Memory-efficient through context pooling
- Scales with modern multi-core hardware

*/

#========================================#
#  BASE SERVER CLASS
#========================================#

class stzAppServer from stzNetwork

	# Core Infrastructure
	oReactiveSystem = NULL
	oTcpServer = NULL
	oComputeEngine = NULL
	oRouter = NULL
	oContextPool = NULL
	
	# Configuration
	nPort = 8080
	cHost = "127.0.0.1"
	bIsRunning = False
	nMaxConnections = 1000
	nWorkerThreads = 4
	
	# Monitoring
	nRequestCount = 0
	nActiveConnections = 0
	oStartTime = NULL

	def init()
		super.init()
		This.InitializeCore()
		This.LoadSoftanzaEngine()
		This.SetupDefaults()

	def InitializeCore()
		# Initialize the reactive system (libuv-based)
		oReactiveSystem = new stzReactiveSystem()
		
		# Initialize TCP server for HTTP
		oTcpServer = new stzTcpServer()
		
		# Initialize request router
		oRouter = new stzAppRouter()
		
		# Initialize Softanza context pool
		oContextPool = new stzContextPool()
		
		? "✓ Core infrastructure initialized"

	def LoadSoftanzaEngine()
		# Pre-load Softanza computational engine
		oComputeEngine = new stzComputeEngine()
		oComputeEngine {
			PreloadStringEngine()    # Unicode tables, patterns
			PreloadObjectSystem()    # Class definitions, methods
			PreloadCollections()     # Data structures, algorithms
			PreloadNLP()            # Language models (if available)
		}
		? "✓ Softanza computational engine loaded"

	def SetupDefaults()
		# Default route handlers
		This.Get("/", func oRequest, oResponse {
			oResponse.Json([
				:server = "stzAppServer",
				:version = "1.0.0",
				:engine = "Softanza Persistent Computational Engine",
				:status = "running",
				:uptime = This.Uptime(),
				:requests_served = nRequestCount
			])
		})
		
		This.Get("/health", func oRequest, oResponse {
			oResponse.Json([
				:status = "healthy",
				:active_connections = nActiveConnections,
				:memory_usage = This.MemoryUsage(),
				:compute_contexts = oContextPool.ActiveCount()
			])
		})

	#--- SERVER LIFECYCLE ---

	def Start()
		return This.Start_(nPort, cHost)

	def Start_(nPortNum, cHostAddr = "127.0.0.1")
		if bIsRunning
			This.Error("Server is already running")
			return False
		ok

		nPort = nPortNum
		cHost = cHostAddr
		oStartTime = clock()

		? "Starting stzAppServer..."
		? "• Host: " + cHost
		? "• Port: " + nPort
		? "• Max Connections: " + nMaxConnections
		? "• Worker Threads: " + nWorkerThreads

		# Configure TCP server for HTTP
		oTcpServer {
			OnClientConnect(func oClient {
				This.HandleNewConnection(oClient)
			})
			
			OnClientMessage(func oClient, cData {
				This.HandleHttpRequest(oClient, cData)
			})
			
			OnClientDisconnect(func oClient {
				This.HandleClientDisconnect(oClient)
			})
		}

		# Start listening
		if oTcpServer.Listen(nPort, cHost)
			bIsRunning = True
			? "✓ stzAppServer started successfully!"
			? "  Access your application at http://" + cHost + ":" + nPort
			
			# Start the reactive event loop
			oReactiveSystem.Start()
			return True
		else
			This.Error("Failed to start server on " + cHost + ":" + nPort)
			return False
		ok

	def Stop()
		if not bIsRunning return ok
		
		? "Stopping stzAppServer..."
		oTcpServer.Stop_()
		oReactiveSystem.Stop()
		bIsRunning = False
		? "✓ Server stopped"

	def IsRunning()
		return bIsRunning

	#--- REQUEST HANDLING ---

	def HandleNewConnection(oClient)
		nActiveConnections++
		if nActiveConnections > nMaxConnections
			This.RejectConnection(oClient, "Server at capacity")
			return
		ok

	def HandleHttpRequest(oClient, cRawRequest)
		nRequestCount++
		
		# Parse HTTP request reactively
		oReactiveSystem {
			# Parse request without blocking
			Xparse = Reactivate(func cData { 
				return This.ParseHttpRequest(cData) 
			})
			
			Xparse.CallAsync([cRawRequest],
				func oRequest {
					# Request parsed successfully
					This.RouteRequest(oClient, oRequest)
				},
				func cError {
					# Parse error
					This.SendErrorResponse(oClient, 400, "Bad Request: " + cError)
				}
			)
		}

	def RouteRequest(oClient, oRequest)
		# Create response object
		oResponse = new stzAppResponse(oClient)
		
		# Route to appropriate handler
		if oRouter.HasRoute(oRequest.Method(), oRequest.Path())
			# Get route handler
			fHandler = oRouter.GetHandler(oRequest.Method(), oRequest.Path())
			
			# Execute handler with Softanza compute context
			This.ExecuteWithContext(fHandler, oRequest, oResponse)
		else
			# No route found
			oResponse.NotFound("Route not found: " + oRequest.Method() + " " + oRequest.Path())
		ok

	def ExecuteWithContext(fHandler, oRequest, oResponse)
		# Get a Softanza context from the pool
		oContext = oContextPool.Acquire()
		
		# Execute handler reactively with persistent Softanza context
		oReactiveSystem {
			XExecute = Reactivate(func fFunc, oReq, oRes, oCtx {
				# Handler runs with full Softanza power
				oCtx.ExecuteHandler(fFunc, oReq, oRes)
				return "executed"
			})
			
			XExecute.CallAsync([fHandler, oRequest, oResponse, oContext],
				func cResult {
					# Handler completed successfully
					oContextPool.Release(oContext)
				},
				func cError {
					# Handler error
					oResponse.InternalError("Execution error: " + cError)
					oContextPool.Release(oContext)
				}
			)
		}

	#--- ROUTING INTERFACE ---

	def Get(cPath, fHandler)
		oRouter.AddRoute("GET", cPath, fHandler)
		return This

	def Post(cPath, fHandler)
		oRouter.AddRoute("POST", cPath, fHandler)
		return This

	def Put(cPath, fHandler)
		oRouter.AddRoute("PUT", cPath, fHandler)
		return This

	def Delete(cPath, fHandler)
		oRouter.AddRoute("DELETE", cPath, fHandler)
		return This

	def Use(cPath, fMiddleware)
		oRouter.AddMiddleware(cPath, fMiddleware)
		return This

	#--- STATIC FILES ---

	def Static(cPath, cDirectory)
		oRouter.AddStaticRoute(cPath, cDirectory)
		return This

	#--- UTILITIES ---

	def ParseHttpRequest(cRawRequest)
		# HTTP request parser
		aLines = split(cRawRequest, nl)
		if len(aLines) = 0
			raise("Empty request")
		ok
		
		# Parse request line
		cRequestLine = aLines[1]
		aParts = split(cRequestLine, " ")
		if len(aParts) < 3
			raise("Invalid request line")
		ok
		
		cMethod = upper(aParts[1])
		cPath = aParts[2]
		cProtocol = aParts[3]
		
		# Parse headers
		aHeaders = []
		cBody = ""
		nBodyStart = 0
		
		for i = 2 to len(aLines)
			if aLines[i] = ""
				nBodyStart = i + 1
				exit
			ok
			
			nColon = substr(aLines[i], ":")
			if nColon > 0
				cName = trim(left(aLines[i], nColon - 1))
				cValue = trim(substr(aLines[i], nColon + 1))
				aHeaders + [cName, cValue]
			ok
		next
		
		# Extract body if present
		if nBodyStart > 0 and nBodyStart <= len(aLines)
			for i = nBodyStart to len(aLines)
				cBody += aLines[i]
				if i < len(aLines) cBody += nl ok
			next
		ok
		
		return new stzAppRequest(cMethod, cPath, aHeaders, cBody)

	def SendErrorResponse(oClient, nCode, cMessage)
		cResponse = "HTTP/1.1 " + nCode + " " + cMessage + nl +
		           "Content-Type: text/plain" + nl +
		           "Content-Length: " + len(cMessage) + nl +
		           nl + cMessage
		           
		oTcpServer.SendTo(oClient, cResponse)
		oTcpServer.KickClient(oClient)

	def HandleClientDisconnect(oClient)
		nActiveConnections--

	def Uptime()
		if oStartTime = NULL return 0 ok
		return (clock() - oStartTime) / 1000  # Convert to seconds

	def MemoryUsage()
		return "N/A"  # Platform-specific implementation needed


#========================================#
#  REQUEST/RESPONSE OBJECTS
#========================================#

class stzAppRequest
	cMethod = ""
	cPath = ""
	aHeaders = []
	cBody = ""
	aParams = []
	aQuery = []

	def init(cMethodVal, cPathVal, aHeadersVal, cBodyVal)
		cMethod = cMethodVal
		cPath = cPathVal
		aHeaders = aHeadersVal
		cBody = cBodyVal
		This.ParseQuery()

	def Method()
		return cMethod

	def Path()
		return cPath

	def Headers()
		return aHeaders

	def Header(cName)
		for aHeader in aHeaders
			if lower(aHeader[1]) = lower(cName)
				return aHeader[2]
			ok
		next
		return ""

	def Body()
		return cBody

	def ParseQuery()
		nQuestion = substr(cPath, "?")
		if nQuestion > 0
			cQueryString = substr(cPath, nQuestion + 1)
			cPath = left(cPath, nQuestion - 1)
			
			aPairs = split(cQueryString, "&")
			for cPair in aPairs
				nEqual = substr(cPair, "=")
				if nEqual > 0
					cKey = left(cPair, nEqual - 1)
					cValue = substr(cPair, nEqual + 1)
					aQuery + [cKey, cValue]
				ok
			next
		ok

	def Query(cKey = NULL)
		if cKey = NULL return aQuery ok
		
		for aParam in aQuery
			if aParam[1] = cKey
				return aParam[2]
			ok
		next
		return ""

class stzAppResponse
	oClient = NULL
	bSent = False
	aHeaders = []
	nStatusCode = 200
	cStatusText = "OK"

	def init(oClientRef)
		oClient = oClientRef

	def Status(nCode, cText = "")
		nStatusCode = nCode
		if cText != "" cStatusText = cText ok
		return This

	def Header(cName, cValue)
		aHeaders + [cName, cValue]
		return This

	def Json(aData)
		cJson = This.ObjectToJson(aData)
		This.Header("Content-Type", "application/json")
		This.Send(cJson)

	def Text(cText)
		This.Header("Content-Type", "text/plain")
		This.Send(cText)

	def Html(cHtml)
		This.Header("Content-Type", "text/html")
		This.Send(cHtml)

	def Send(cContent)
		if bSent return ok
		
		cResponse = "HTTP/1.1 " + nStatusCode + " " + cStatusText + nl
		
		# Add headers
		This.Header("Content-Length", len(cContent))
		for aHeader in aHeaders
			cResponse += aHeader[1] + ": " + aHeader[2] + nl
		next
		
		cResponse += nl + cContent
		
		# Send via TCP server (need reference to server)
		# oTcpServer.SendTo(oClient, cResponse)
		bSent = True

	def NotFound(cMessage = "Not Found")
		This.Status(404, "Not Found").Text(cMessage)

	def InternalError(cMessage = "Internal Server Error")
		This.Status(500, "Internal Server Error").Text(cMessage)

	def ObjectToJson(obj)
		# Simplified JSON serializer - full implementation needed
		if isstring(obj) return '"' + obj + '"' ok
		if isnumber(obj) return "" + obj ok
		if islist(obj)
			if len(obj) = 0 return "[]" ok
			
			# Check if it's an associative array (object)
			if isstring(obj[1])
				cJson = "{"
				for i = 1 to len(obj) step 2
					if i > 1 cJson += "," ok
					cJson += '"' + obj[i] + '":' + This.ObjectToJson(obj[i+1])
				next
				cJson += "}"
				return cJson
			else
				# Regular array
				cJson = "["
				for i = 1 to len(obj)
					if i > 1 cJson += "," ok
					cJson += This.ObjectToJson(obj[i])
				next
				cJson += "]"
				return cJson
			ok
		ok
		return '""'  # fallback


#========================================#
#  ROUTER CLASS
#========================================#

class stzAppRouter
	aRoutes = []
	aMiddleware = []
	aStaticRoutes = []

	def AddRoute(cMethod, cPath, fHandler)
		aRoutes + [cMethod, cPath, fHandler]

	def HasRoute(cMethod, cPath)
		for aRoute in aRoutes
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return True
			ok
		next
		return False

	def GetHandler(cMethod, cPath)
		for aRoute in aRoutes
			if aRoute[1] = cMethod and aRoute[2] = cPath
				return aRoute[3]
			ok
		next
		return NULL

	def AddMiddleware(cPath, fMiddleware)
		aMiddleware + [cPath, fMiddleware]

	def AddStaticRoute(cPath, cDirectory)
		aStaticRoutes + [cPath, cDirectory]


#========================================#
#  COMPUTE ENGINE - PERSISTENT SOFTANZA
#========================================#

class stzComputeEngine
	bStringEngineLoaded = False
	bObjectSystemLoaded = False
	bCollectionsLoaded = False
	bNLPLoaded = False

	def PreloadStringEngine()
		? "  Loading Unicode tables and patterns..."
		# Pre-load stzString, stzChar, stzText optimizations
		# Unicode normalization tables, regex patterns, etc.
		bStringEngineLoaded = True

	def PreloadObjectSystem()
		? "  Loading object system and method tables..."
		# Pre-cache class definitions, method lookup tables
		# Softanza's rich object model ready for instantiation
		bObjectSystemLoaded = True

	def PreloadCollections()
		? "  Loading collection algorithms and data structures..."
		# Pre-allocate common data structures
		# Functional programming utilities ready
		bCollectionsLoaded = True

	def PreloadNLP()
		? "  Loading NLP models and knowledge graphs..."
		# Language models, if available
		# Knowledge bases for advanced text processing
		bNLPLoaded = True

	def IsReady()
		return bStringEngineLoaded and bObjectSystemLoaded and 
		       bCollectionsLoaded and bNLPLoaded


#========================================#
#  CONTEXT POOL - MEMORY MANAGEMENT
#========================================#

class stzContextPool
	aAvailable = []
	aActive = []
	nMaxContexts = 10

	def init()
		This.CreateInitialPool()

	def CreateInitialPool()
		for i = 1 to nMaxContexts
			aAvailable + new stzComputeContext()
		next

	def Acquire()
		if len(aAvailable) > 0
			oContext = aAvailable[1]
			del(aAvailable, 1)
			aActive + oContext
			return oContext
		else
			# Create new context if none available
			oContext = new stzComputeContext()
			aActive + oContext
			return oContext
		ok

	def Release(oContext)
		# Find and remove from active
		for i = 1 to len(aActive)
			if aActive[i] = oContext
				del(aActive, i)
				exit
			ok
		next
		
		# Reset context and return to available pool
		oContext.Reset()
		aAvailable + oContext

	def ActiveCount()
		return len(aActive)

	def AvailableCount()
		return len(aAvailable)


class stzComputeContext
	# Each context maintains its own Softanza workspace
	# while sharing the pre-loaded engine components

	def ExecuteHandler(fHandler, oRequest, oResponse)
		# Execute the handler with full Softanza context
		call fHandler(oRequest, oResponse)

	def Reset()
		# Clear any temporary state but keep engine loaded


#========================================#
#  USAGE EXAMPLES
#========================================#

/*--- Basic web application

app = new stzAppServer()

# Simple route
app.Get("/hello", func oRequest, oResponse {
    oResponse.Text("Hello from Softanza!")
})

# JSON API with Softanza string processing
app.Get("/api/process", func oRequest, oResponse {
    cText = oRequest.Query("text")
    if cText = ""
        oResponse.Status(400).Json([:error = "text parameter required"])
        return
    ok
    
    # Use Softanza's powerful string processing
    oStr = new stzString(cText)
    aResult = [
        :original = cText,
        :length = oStr.NumberOfChars(),
        :words = oStr.Words(),
        :reversed = oStr.Reversed(),
        :uppercase = oStr.Uppercased(),
        :character_analysis = oStr.CharsClassification()
    ]
    
    oResponse.Json(aResult)
})

# Start the server
app.Start(3000)

*/

/*--- Advanced computational API

app = new stzAppServer()

# Complex text analysis endpoint
app.Post("/api/analyze", func oRequest, oResponse {
    cText = oRequest.Body()
    
    # Leverage Softanza's rich text processing
    oText = new stzText(cText)
    
    aAnalysis = [
        :statistics = [
            :characters = oText.NumberOfChars(),
            :words = oText.NumberOfWords(),
            :sentences = oText.NumberOfSentences(),
            :paragraphs = oText.NumberOfParagraphs()
        ],
        :structure = [
            :headings = oText.Headings(),
            :quotes = oText.QuotedSubStrings(),
            :urls = oText.URLs(),
            :emails = oText.EmailAddresses()
        ],
        :linguistic = [
            :language = oText.Language(),
            :readability = oText.ReadabilityScore(),
            :sentiment = oText.SentimentAnalysis(),  # If NLP loaded
            :keywords = oText.Keywords()
        ]
    ]
    
    oResponse.Json(aAnalysis)
})

app.Start(8080)

*/