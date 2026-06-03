# Narrative
# --------
# Robust error handling with reactive functions
#
# Extracted from stzreactivefunctest.ring, block #3.

load "../../stzBase.ring"


# Reactive functions can fail - network issues, invalid data, etc.
# Always provide error handlers to gracefully handle failures

pr()

oRs = new stzReactiveSystem()
oRs {

    # Function that might fail
    fRiskyDivision = func x, y {
        if y = 0
            raise("Division by zero!")
        ok
        return x / y
    }
    
    # Function that processes files
    fProcessFile = func filename {
        if not fexists(filename)
            raise("File not found: " + filename)
        ok
        content = read(filename)
        return "Processed " + len(content) + " characters"
    }

    RDiv = Reactivate(fRiskyDivision)
    RFile = Reactivate(fProcessFile)

    # Test successful operation
    RDiv.CallAsync(
        [10, 2],
        func result { ? "Safe division: " + result },
        func error { ? "Division error: " + error }
    )

    # Test error case
    RDiv.CallAsync(
        [10, 0],  # This will cause division by zero
        func result { ? "This won't print" },
        func error { ? "Caught error: " + error }
    )

    # Test file operation
    RFile.CallAsync(
        ["nonexistent.txt"],
        func result { ? "File result: " + result },
        func error { ? "File error: " + error }
    )

    Start()
    #-->
    # Safe division: 5
    # Caught error: Division by zero!
    # File error: File not found: nonexistent.txt
}

pf()
# Executed in 0.02 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 4: CHAINING OPERATIONS   #
#-----------------------------------#
