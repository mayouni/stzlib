# Narrative
# --------
# Advanced reactive patterns for real-world applications
#
# Extracted from stzreactivefunctest.ring, block #6.
#ERR Error (R24) : Using uninitialized variable: transformeddata

load "../../stzBase.ring"


# Combining reactive functions with conditional logic,
# result transformation, and complex coordination

pr()

oRs = new stzReactiveSystem()
oRs {

    # Simulate database query
    queryDatabase = func table, filter {
        sleep(0.1)  # Simulate DB latency
        if table = "users"
            return [ "John", "Jane", "Bob", "Alice" ]
        but table = "products"
            return [ "Laptop", "Phone", "Tablet" ]
        else
            raise("Unknown table: " + table)
        ok
    }
    
    # Transform data
    transformData = func rawData {
        transformed = []
        for item in rawData
            transformed + "ITEM_" + upper(item)
        next
        return transformed
    }
    
    # Validate results
    validateResults = func data {
        if len(data) = 0
            raise("No data to validate")
        ok
        return "Validated " + len(data) + " items successfully"
    }

    # Make all functions reactive
    RQuery = MakeReactive(queryDatabase)
    RTransform = MakeReactive(transformData)
    RValidate = MakeReactive(validateResults)

    # Complex workflow with conditional branching
    ? "Starting complex data processing workflow..."
    
    # Query multiple tables simultaneously
    tables = ["users", "products", "invalid_table"]
    completedQueries = 0
    allResults = []
    
    for table in tables
        RQuery.CallAsync([table, ""], func queryResult {
            completedQueries++
            ? "Query " + completedQueries + " completed for table"
            
            # Transform the successful query result
            RTransform.CallAsync([queryResult], func transformedData {
                ? "Data transformed: " + len(transformedData) + " items"
                
                # Validate the transformed data
                RValidate.CallAsync([transformedData], func validationResult {
                    ? "Validation: " + validationResult
                    allResults + transformedData
                    
                    # Check if this is our final successful result
                    if len(allResults) >= 2  # We expect 2 successful queries
                        ? "Processing complete! Total items: " + len(allResults[1]) + len(allResults[2])
                    ok
                    
                }, func validationError {
                    ? "Validation failed: " + validationError
                })
                
            }, func transformError {
                ? "Transform failed: " + transformError
            })
            
        }, func queryError {
            completedQueries++
            ? "Query " + completedQueries + " failed: " + queryError
        })
    next

    Start()
    #-->
    # Starting complex data processing workflow...

    # Query 1 completed for table
    # Data transformed: 4 items

    # Query 2 completed for table  
    # Data transformed: 3 items

    # Query 3 failed: Query 3 failed: Unknown table: invalid_table

    # Validation: Validated 4 items successfully
    # Validation: Validated 3 items successfully
    # Processing complete! Total items: 43
}

pf()
# Executed in 1.27 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 7: REAL-WORLD USAGE      #
#-----------------------------------#
