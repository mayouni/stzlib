load "../appserver/stzAppServer.ring"

# Create server instance
oApp = new RingAppServer(8888)

# Enable debug mode
oApp.setDebug(_TRUE_)

# Add middleware for logging
oApp.use('
    ? "Request received: " + time()
')

# Add middleware for basic authentication
oApp.use('
    if oServer["auth"] != "secret"
        oApp.response("Unauthorized", "text/plain")
        return
    ok
')

# Define routes

oApp.gett("/", '
    oApp.html("<h1>Welcome to Softanza Application Server</h1>")
')

oApp.gett("/api/users", '
    aUsers = [
        [ :id = 1, :name = "John" ],
        [ :id = 2, :name = "Jane" ]
    ]
    oApp.json(aUsers)
')

oApp.postt("/api/users", '
    cName = oApp.getParam("name")
    oApp.json(["status": "success", "message": "User " + cName + " created"])
')

# Start the server
oApp.start()
