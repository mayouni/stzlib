# Narrative
# --------
# Real-world: JSON Configuration Validation
#
# Extracted from stzlistexutertest.ring, block #6.

load "../../stzBase.ring"


pr()

lxu() {
    # Define patterns to validate configuration structure
    AddTrigger(:ServerConfig = "[@S, [@N{1-65535}], [@S+]]")  # hostname, port, endpoints
    AddTrigger(:DatabaseConfig = "[@S, @S, [@S, @S]]")        # db_name, host, [username, password]
    AddTrigger(:LoggingConfig = "[@S{debug;info;warning;error}, @N?]")  # level, retention days
    
    # Validate and normalize configs
    AddCode(:ServerConfig, '{
        # Normalize hostname to lowercase
        @list[1] = lower(@list[1])
        
        # Validate endpoints begin with "/"
        _nList3Len_ = ring_len(@list[3])
        for i = 1 to _nList3Len_
            if not beginswith(@list[3][i], "/")
                @list[3][i] = "/" + @list[3][i]
            ok
        next
        
        # Add validation stamp
        @list + ["VALID_SERVER_CONFIG"]
    }')
    
    AddCode(:DatabaseConfig, '{
        # Validate DB connection
        @list + ["CONNECTION_STRING: " + @list[2] + "/" + @list[1]]
        @list + ["VALID_DB_CONFIG"]
    }')
    
    AddCode(:LoggingConfig, '{
        # Set default retention if missing
        if len(@list) = 1
            @list + [30]  # Default 30 days
        ok
        
        @list + ["VALID_LOGGING_CONFIG"]
    }')
    
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
    for section in configData
        sectionName = section[1]
        sectionConfig = section[2]
        
        Process(sectionConfig)
    next
    
    # Display validated configurations
    ? "=== Validated Configuration ==="
    
    _nResultsLen_ = ring_len(Results()
    for i = 1 to _nResultsLen_)
        ? NL + "Section result " + i + ":"
        ? @@NL(Results()[i])
    next
    
    # Analyze which parts of the config were validated
    ? NL + "=== Validation Summary ==="
    
    for entry in State()
        ? "- " + entry[:triggerName] + " validated successfully"
    next
}

proff()
#--> Executed in 0.06 second(s) in Ring 1.22

pf()
