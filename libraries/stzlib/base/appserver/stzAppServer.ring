#======================================================#
#  STZAPPSERVER - PERSISTENT COMPUTATIONAL WEB ENGINE  #
#======================================================#

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
		This.InitializeCore()
		This.LoadSoftanzaEngine()
		This.SetupDefaults()

	  #-------------------------#
	 #  SERVER INITIALIZATION  #
	#-------------------------#

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

		oComputeEngin.PreloadStringEngine()    # Unicode tables, patterns
		oComputeEngin.PreloadObjectSystem()    # Class definitions, methods
		oComputeEngin.PreloadCollections()     # Data structures, algorithms
		oComputeEngin.PreloadNLP()             # Language models (if available)

		? "✓ Softanza computational engine loaded"

	def SetupDefaults()
		# Default route handlers
		This.Get_("/", func oRequest, oResponse {

			oResponse.Json([
				:server = "stzAppServer",
				:version = "1.0.0",
				:engine = "Softanza Persistent Computational Engine",
				:status = "running",
				:uptime = This.Uptime(),
				:requests_served = nRequestCount
			])
		})
		
		This.Get_("/health", func oRequest, oResponse {
			oResponse.Json([
				:status = "healthy",
				:active_connections = nActiveConnections,
				:memory_usage = This.MemoryUsage(),
				:compute_contexts = oContextPool.ActiveCount()
			])
		})

	  #--------------------#
	 #  SERVER LIFECYCLE  #
	#--------------------#

	def Start(nPortNum, cHostAddr)

		if cHostAddr = ""
			cHostAddr = "127.0.0.1"
		ok

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

		oTcpServer.OnClientConnect(func oClient {
				This.HandleNewConnection(oClient)
			})
			
		oTcpServer.OnClientMessage(func oClient, cData {
				This.HandleHttpRequest(oClient, cData)
			})
			
		oTcpServer.OnClientDisconnect(func oClient {
				This.HandleClientDisconnect(oClient)
			})

		# Start listening

		if oTcpServer.Listen(nPort, cHost)

			bIsRunning = True
			? "✓ stzAppServer started successfully!"
			? '  Access your application at http://' + cHost + ":" + nPort
			
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

	  #--------------------#
	 #  REQUEST HANDLING  #
	#--------------------#

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
			RParse = Reactivate(func cData { 
				return This.ParseHttpRequest(cData) 
			})
			
			RParse.CallAsync([cRawRequest],
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

			RExecute = Reactivate(func fFunc, oReq, oRes, oCtx {
				# Handler runs with full Softanza power
				oCtx.ExecuteHandler(fFunc, oReq, oRes)
				return "executed"
			})
			
			RExecute.CallAsync([fHandler, oRequest, oResponse, oContext],
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

	  #---------------------#
	 #  ROUTING INTERFACE  #
	#---------------------#

	def Get_(cPath, fHandler)
		oRouter.AddRoute("GET", cPath, fHandler)
		return This

	def Post(cPath, fHandler)
		oRouter.AddRoute("POST", cPath, fHandler)
		return This

	def Put_(cPath, fHandler)
		oRouter.AddRoute("PUT", cPath, fHandler)
		return This

	def Delete(cPath, fHandler)
		oRouter.AddRoute("DELETE", cPath, fHandler)
		return This

	def Use(cPath, fMiddleware)
		oRouter.AddMiddleware(cPath, fMiddleware)
		return This

	#--- STATIC FILES ---

	  #----------------#
	 #  STATIC FILES  #
	#----------------#

	def Static(cPath, cDirectory)
		oRouter.AddStaticRoute(cPath, cDirectory)
		return This

	  #--------------#
	 #  UTILITILES  #
	#--------------#

	def ParseHttpRequest(cRawRequest)

		# HTTP request parser
		aLines = @split(cRawRequest, nl)
		if len(aLines) = 0
			raise("Empty request")
		ok
		
		# Parse request line
		cRequestLine = aLines[1]
		aParts = @split(cRequestLine, " ")
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
				cValue = trim(@substr(aLines[i], nColon + 1))
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
