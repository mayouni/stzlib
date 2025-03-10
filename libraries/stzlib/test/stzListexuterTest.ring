load "../max/stzmax.ring"

/*--- ListEx Type Patterns in Listexuter
*/
pr()

lxu() {
    # Using basic type patterns from ListEx
    AddTrigger(:ListOfNumbers = "[@N3]")    # One or more numbers
    
    AddCode(:ListOfNumbers, '{
        @list + [ :Sum = @Sum(@list), :Mean = @Mean(@list)  ]
    }')
    
    Process([
        [42, "hello"],
        [10, 20, 30],
        [99, "world"],
        [1, 2, 3, 4, 5]
    ])
    
    ? @@NL( Results() )
    #--> [
    #   [ [42, "hello"], [84, "HELLO"] ],
    #   [ [10, 20, 30], [10, 20, 30, "Sum = 60"] ],
    #   [ [99, "world"], [198, "WORLD"] ],
    #   [ [1, 2, 3, 4, 5], [1, 2, 3, 4, 5, "Sum = 15"] ]
    # ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Quantifiers and Ranges

pr()

lxu() {
    # Using quantifiers and ranges from ListEx
    AddTrigger(:OneTwoNumbers = "[@N1-2, @S]")  # 1-2 numbers followed by string
    AddTrigger(:OptionalString = "[@N, @S?]")   # Number with optional string
    
    AddCode(:OneTwoNumbers, '{
        if len(@list) = 3  # Two numbers and a string
            @list = [ @list[1] + @list[2], @list[3] ]
        else  # One number and a string
            @list = [ @list[1], @list[2] ]
        ok
    }')
    
    AddCode(:OptionalString, '{
        if len(@list) = 2  # Has optional string
            @list = [ "WITH_STRING", @list ]
        else  # Just a number
            @list = [ "NUMBER_ONLY", @list ]
        ok
    }')
    
    Process([
        [10, "apple"],      # OneTwoNumbers with one number
        [20, 30, "banana"], # OneTwoNumbers with two numbers
        [42],               # OptionalString without string
        [99, "optional"]    # OptionalString with string
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ [10, "apple"], [10, "apple"] ],
    #   [ [20, 30, "banana"], [50, "banana"] ],
    #   [ [42], ["NUMBER_ONLY", [42]] ],
    #   [ [99, "optional"], ["WITH_STRING", [99, "optional"]] ]
    # ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Negation and Alternation

pr()

lxu() {
    # Using negation and alternation from ListEx
    AddTrigger(:NotNumber = "[@!N]")       # Anything but a number
    AddTrigger(:NumberOrString = "[@N|@S]") # Either number or string
    
    AddCode(:NotNumber, '{
        @list = [ "NOT_NUMBER", @list ]
    }')
    
    AddCode(:NumberOrString, '{
        if isNumber(@list)
            @list = @list * 2
        else
            @list = upper(@list)
        ok
    }')
    
    Process([
        "text",      # NotNumber and NumberOrString
        42,          # NumberOrString but not NotNumber
        [1, 2, 3],   # NotNumber but not NumberOrString
        ["a", "b"]   # NotNumber but not NumberOrString
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ "text", ["NOT_NUMBER", "text"] ],
    #   [ "text", "TEXT" ],
    #   [ 42, 84 ],
    #   [ [1, 2, 3], ["NOT_NUMBER", [1, 2, 3]] ],
    #   [ ["a", "b"], ["NOT_NUMBER", ["a", "b"]] ]
    # ]
}

proff()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Explicit Sets and Nested Patterns

pr()

lxu() {
    # Using explicit sets and nested patterns
    AddTrigger(:ValidStatusCode = "[@N{200;404;500}]")  # Only specific status codes
    AddTrigger(:ApiResponse = "[@S, [@N, @S]]")         # Response with nested details
    
    AddCode(:ValidStatusCode, '{
        codeMap = [
            200, "OK",
            404, "Not Found",
            500, "Server Error"
        ]
        
        for i = 1 to len(codeMap) step 2
            if @list = codeMap[i]
                @list = [ @list, codeMap[i+1] ]
                exit
            ok
        next
    }')
    
    AddCode(:ApiResponse, '{
        @list = [
            "API_RESPONSE",
            @list[1],  # Endpoint
            @list[2][1],  # Status code
            @list[2][2]   # Message
        ]
    }')
    
    Process([
        200,
        404,
        [ "/users", [200, "Success"] ],
        [ "/orders", [404, "Order not found"] ]
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ 200, [200, "OK"] ],
    #   [ 404, [404, "Not Found"] ],
    #   [ ["/users", [200, "Success"]], ["API_RESPONSE", "/users", 200, "Success"] ],
    #   [ ["/orders", [404, "Order not found"]], ["API_RESPONSE", "/orders", 404, "Order not found"] ]
    # ]
}

proff()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Advanced: Combining Multiple ListEx Features

pr()

lxu() {
    # Combining multiple ListEx features
    AddTrigger(:ComplexData = "[@S, [@N{1-100}+], @!N?]")  # String, list of nums 1-100, optional non-number
    
    AddCode(:ComplexData, '{
        # Process the name
        cName = @list[1]
        
        # Calculate statistics on the numbers
        aNumbers = @list[2]
        nSum = 0
        nMin = 999
        nMax = 0
        
        for num in aNumbers
            nSum += num
            if num < nMin nMin = num ok
            if num > nMax nMax = num ok
        next
        
        nAvg = nSum / len(aNumbers)
        
        # Check if we have the optional tag
        cTag = ""
        if len(@list) > 2
            cTag = @list[3]
        ok
        
        # Build result
        @list = [
            "ID: " + cName,
            "Stats: [min:" + nMin + ", max:" + nMax + ", avg:" + nAvg + "]"
        ]
        
        if cTag != ""
            @list + ["Tag: " + cTag]
        ok
    }')
    
    Process([
        ["temp_readings", [22, 24, 21, 25], "celsius"],
        ["stock_prices", [55, 62, 58, 63, 67]],
        ["test_scores", [85, 92, 78, 95, 88], "midterm"]
    ])
    
    ? @@NL( MatchesXT() )
    #--> [
    #   [ 
    #       ["temp_readings", [22, 24, 21, 25], "celsius"],
    #       ["ID: temp_readings", "Stats: [min:21, max:25, avg:23]", "Tag: celsius"]
    #   ],
    #   [ 
    #       ["stock_prices", [55, 62, 58, 63, 67]],
    #       ["ID: stock_prices", "Stats: [min:55, max:67, avg:61]"]
    #   ],
    #   [ 
    #       ["test_scores", [85, 92, 78, 95, 88], "midterm"],
    #       ["ID: test_scores", "Stats: [min:78, max:95, avg:87.6]", "Tag: midterm"]
    #   ]
    # ]
}

proff()
# Executed in 0.05 second(s) in Ring 1.22

/*--- Real-world: JSON Configuration Validation

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
        for i = 1 to len(@list[3])
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
    
    for i = 1 to len(Results())
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

/*--- Data Structure Transformation: Tree Processing

pr()

lxu() {
    # Define patterns for tree node types
    AddTrigger(:LeafNode = "[@S, @N]")         # Name, value
    AddTrigger(:InnerNode = "[@S, [@L+]]")     # Name, children
    AddTrigger(:RootNode = "[@S, [@L+], @N?]") # Name, children, optional total
    
    # Processing for different node types
    AddCode(:LeafNode, '{
        # Format leaf nodes consistently
        @list = {
            "type": "leaf",
            "name": @list[1],
            "value": @list[2]
        }
    }')
    
    AddCode(:InnerNode, '{
        # Calculate sum of child values
        nSum = 0
        
        for child in @list[2]
            if type(child) = "HASH" and child["type"] = "leaf"
                nSum += child["value"]
            ok
        next
        
        # Format inner node with calculated value
        @list = {
            "type": "inner",
            "name": @list[1],
            "children": @list[2],
            "childCount": len(@list[2]),
            "value": nSum
        }
    }')
    
    AddCode(:RootNode, '{
        # Calculate total value from children
        nSum = 0
        
        for child in @list[2]
            if type(child) = "HASH" and child["type"] = "inner"
                nSum += child["value"]
            ok
        next
        
        # Add provided total or calculated one
        nTotal = 0
        if len(@list) > 2
            nTotal = @list[3]
        else
            nTotal = nSum
        ok
        
        # Format root node
        @list = {
            "type": "root",
            "name": @list[1],
            "children": @list[2],
            "calculated": nSum,
            "total": nTotal,
            "accurate": (nSum = nTotal)
        }
    }')
    
    # Sample tree structure
    treeData = [
        "Expenses",
        [
            ["Food", [
                ["Groceries", 150],
                ["Dining", 120]
            ]],
            ["Housing", [
                ["Rent", 800],
                ["Utilities", 200]
            ]],
            ["Transportation", 300]
        ],
        1600  # Total (should equal calculated sum of 1570)
    ]
    
    # Process tree depth-first from bottom to top
    Process(treeData)
    
    # Display processed tree with calculated values
    ? "=== Processed Tree Structure ==="
    ? @@NL(Results()[1])
    
    # Verify tree transformation results
    ? NL + "=== Verification ==="
    isAccurate = Results()[1]["accurate"]
    
    if isAccurate
        ? "Tree totals match: " + Results()[1]["total"]
    else
        ? "Tree totals mismatch!"
        ? "Provided: " + Results()[1]["total"]
        ? "Calculated: " + Results()[1]["calculated"]
        ? "Difference: " + (Results()[1]["total"] - Results()[1]["calculated"])
    ok
}

proff()
# Executed in 0.05 second(s) in Ring 1.22
