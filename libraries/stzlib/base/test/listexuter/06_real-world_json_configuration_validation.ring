# Narrative
# --------
# Real-world: JSON Configuration Validation
#
# Extracted from stzlistexutertest.ring, block #6.
#ERR Error (C8) : Parentheses ')' is missing

load "../../stzBase.ring"


pr()

lxu() {
    # Define patterns to validate configuration structure
    AddTrigger(:ServerConfig = "[@S, [@N1-65535], [@S+]]")  # hostname, port, endpoints
    AddTrigger(:DatabaseConfig = "[@S, @S, [@S, @S]]")        # db_name, host, [username, password]
    AddTrigger(:LoggingConfig = "[@S{debug;info;warning;error}, @N?]")  # level, retention days
    
    # Validate and normalize configs
    AddCode(:ServerConfig, func v {
        # Normalize hostname to lowercase
        v[1] = lower(v[1])
        
        # Validate endpoints begin with "/"
        _nList3Len_ = len(v[3])
        for i = 1 to _nList3Len_
            if not beginswith(v[3][i], "/")
                v[3][i] = "/" + v[3][i]
            ok
        next
        
        # Add validation stamp
        v + ["VALID_SERVER_CONFIG"]
        return v
    })
    
    AddCode(:DatabaseConfig, func v {
        # Validate DB connection
        v + ["CONNECTION_STRING: " + v[2] + "/" + v[1]]
        v + ["VALID_DB_CONFIG"]
        return v
    })
    
    AddCode(:LoggingConfig, func v {
        # Set default retention if missing
        if len(v) = 1
            v + [30]  # Default 30 days
        ok
        
        v + ["VALID_LOGGING_CONFIG"]
        return v
    })
    
    # Sample configuration to validate
    configData = [
        ["Server", [
            "Api.example.com",  # hostname
            8080,               # port
            ["api/users", "api/orders", "/status"]  # endpoints
        ]],
        
        ["Database", [
            "products_db",
            "db.example.com",
            ["admin", "Passw0rd!"]
        ]],
        
        ["Logging", [
            "info",  # level
            60       # retention days
        ]]
    ]
    
    # Process each section of the configuration
    _nConfigData1Len_ = len(configData)
    for _iLoopConfigData1_ = 1 to _nConfigData1Len_
    	section = configData[_iLoopConfigData1_]
        sectionName = section[1]
        sectionConfig = section[2]
        
        Process(sectionConfig)
    next
    
    # Display validated configurations
    ? "=== Validated Configuration ==="
    
    _nResultsLen_ = len(Results())
    for i = 1 to _nResultsLen_
        ? NL + "Section result " + i + ":"
        ? @@NL(Results()[i])
    next
    
    # Analyze which parts of the config were validated
    ? NL + "=== Validation Summary ==="
    
    _aState1_ = State()
    _nState1Len_ = len(_aState1_)
    for _iLoopState1_ = 1 to _nState1Len_
    	entry = _aState1_[_iLoopState1_]
        ? "- " + entry[:triggerName] + " validated successfully"
    next
}

proff()
#--> Executed in 0.06 second(s) in Ring 1.22

pf()
