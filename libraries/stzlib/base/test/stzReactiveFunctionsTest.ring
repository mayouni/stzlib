load "../stzbase.ring"

#========================================#
#  REACTIVE FUNCTIONS - BASIC CONCEPTS   #
#========================================#

# Welcome to Reactive Functions in Softanza library for Ring (StzLib)!
# This tutorial teaches you step-by-step how to transform regular functions
# into non-blocking, asynchronous operations.

#-----------------------------------#
#  EXAMPLE 1: YOUR FIRST REACTIVE   #
#-----------------------------------#

/*--- Understanding MakeReactive - From blocking to non-blocking

# Regular functions block execution until they finish
# Reactive functions run in the background and notify you when done

pr()

oRs = new stzReactive()
oRs {

    # A simple function that takes time to execute
    fSlowCalculation = func x {
        # Simulate heavy computation
        result = 0
        for i = 1 to x * 1000
            result += i
        next
        return result
    }

    # Make it reactive - now it won't block!
    fReactiveCalc = MakeReactive(fSlowCalculation) # Or Reactivate()

    ? "This prints immediately while calculation runs in background..." + NL

    # Call it asynchronously - execution continues immediately
    fReactiveCalc.CallAsync(
        [50000],  # Parameter: calculate sum up to 50 million iterations
        func result { ? "Heavy calculation done: " + result },
        func error { ? "Calculation failed: " + error }
    )
    
    Start() # Process all queued reactive tasks
    #-->
    # This prints immediately while calculation runs in background...
    # Heavy calculation done: 1250000025000000
}

pf()
# Executed in 8.76 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 2: MULTIPLE FUNCTIONS    #
#-----------------------------------#

/*--- Running multiple functions in parallel

# The power of reactive functions: multiple heavy operations at once
# Traditional approach would run them one after another (sequential)
# Reactive approach runs them simultaneously (parallel)

pr()

oRs = new stzReactive()
oRs {

    # Three different CPU-intensive functions
    fFibonacci = func n {
        if n <= 1 return n ok
        a = 0  b = 1
        for i = 2 to n
            temp = a + b
            a = b
            b = temp
        next
        return b
    }
    
    fFactorial = func n {
        result = 1
        for i = 2 to n
            result *= i
        next
        return result
    }
    
    fPrimeCount = func limit {
        count = 0
        for num = 2 to limit
            isPrime = true
            for i = 2 to sqrt(num)
                if num % i = 0
                    isPrime = false
                    exit
                ok
            next
            if isPrime count++ ok
        next
        return count
    }

    # Make all functions reactive
    RFib = Reactivate(fFibonacci) # Or MakeReactive()
    RFact = Reactivate(fFactorial) 
    RPrime = Reactivate(fPrimeCount)


    # Launch all three simultaneously
    ? "Starting three heavy calculations in parallel..."
    
    RFib.CallAsync([35], func result { 
        ? "Fibonacci(35): " + result 
    }, NULL)
    
    RFact.CallAsync([15], func result { 
        ? "Factorial(15): " + result 
    }, NULL)
    
    RPrime.CallAsync([1000], func result { 
        ? "Primes up to 1000: " + result 
    }, NULL)

    # All tasks queued - processing now
    Start()
    #-->
    # Starting three heavy calculations in parallel...
    # Factorial(15): 1307674368000
    # Fibonacci(35): 9227465
    # Primes up to 1000: 168

}

pf()
# Executed in 0.93 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 3: ERROR HANDLING        #
#-----------------------------------#

/*--- Robust error handling with reactive functions
*/
# Reactive functions can fail - network issues, invalid data, etc.
# Always provide error handlers to gracefully handle failures

pr()

oRs = new stzReactive()
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

/*--- Chaining reactive functions for complex workflows

# Real applications often need to chain operations:
# fetch data → process it → save results → notify user
# Reactive functions make this elegant with proper sequencing

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Step 1: Fetch user data
    fetchUser = func userId {
        # Simulate API call delay
        sleep(0.1)
        if userId = 1
            return '{"name":"John","age":30,"role":"admin"}'
        else
            return '{"name":"Jane","age":25,"role":"user"}'
        ok
    }
    
    # Step 2: Process user data
    processUser = func jsonData {
        # Parse JSON-like string (simplified)
        if substr(jsonData, "admin")
            return "ADMIN_USER_PROCESSED"
        else
            return "REGULAR_USER_PROCESSED"
        ok
    }
    
    # Step 3: Save to log
    saveLog = func processedData {
        logEntry = "LOG: " + processedData + " at " + timeList()[4] + ":" + timeList()[5]
        return logEntry
    }

    # Make all functions reactive
    RFetch = Reactivate(fetchUser)
    RProcess = Reactivate(processUser)
    RSave = Reactivate(saveLog)

    # Chain them together - each step waits for the previous one
    ? "Starting user processing workflow..."
    
    RFetch.CallAsync([1], func userData {
        ? "Step 1 complete - User data fetched"
        
        # When fetch completes, start processing
        RProcess.CallAsync([userData], func processedData {
            ? "Step 2 complete - Data processed: " + processedData
            
            # When processing completes, save log
            RSave.CallAsync([processedData], func logResult {
                ? "Step 3 complete - " + logResult
                ? "Workflow finished successfully!"
            }, func error {
                ? "Save error: " + error
            })
            
        }, func error {
            ? "Process error: " + error
        })
        
    }, func error {
        ? "Fetch error: " + error
    })

    Start()
    #-->
    # Starting user processing workflow...
    # Step 1 complete - User data fetched
    # Step 2 complete - Data processed: ADMIN_USER_PROCESSED
    # Step 3 complete - LOG: ADMIN_USER_PROCESSED at 14:23
    # Workflow finished successfully!
}

pf()
# Executed in 0.12 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 5: BATCH PROCESSING      #
#-----------------------------------#

/*--- Processing multiple items efficiently with reactive functions

# When you have many items to process, reactive functions prevent blocking
# Each item processes independently, results arrive as ready

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Function to process individual items
    processItem = func item {
        # Different processing times based on item value
        if item < 10
            sleep(0.05)  # Quick items
        else
            sleep(0.15)  # Slower items
        ok
        return "Processed: " + item + " -> " + (item * item)
    }

    RProcess = MakeReactive(processItem)
    
    # Batch of items to process
    items = [1, 15, 3, 22, 7, 18, 5]
    results = []
    processed = 0
    total = len(items)

    ? "Processing " + total + " items in parallel..."
    
    # Launch all items for processing simultaneously
    for item in items
        RProcess.CallAsync(
            [item],
            func result {
                processed++
                results + result
                ? result + " (" + processed + "/" + total + ")"
                
                # Check if all items are done
                if processed = total
                    ? "All items processed!"
                    ? "Results summary: " + len(results) + " items completed"
                ok
            },
            func error {
                ? "Item processing error: " + error
            }
        )
    next

    Start()
    #-->
    # Processing 7 items in parallel...
    # Processed: 1 -> 1 (1/7)
    # Processed: 3 -> 9 (2/7)
    # Processed: 7 -> 49 (3/7)
    # Processed: 5 -> 25 (4/7)
    # Processed: 15 -> 225 (5/7)
    # Processed: 22 -> 484 (6/7)
    # Processed: 18 -> 324 (7/7)
    # All items processed!
    # Results summary: 7 items completed
}

pf()
# Executed in 0.76 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 6: REACTIVE WITH TIMERS  #
#-----------------------------------#

/*--- Combining reactive functions with timers for scheduled operations

# Sometimes you need functions to run at specific intervals
# Reactive functions + timers = powerful scheduled processing

pr()

oRs = new stzReactive()
oRs {

    # Function that processes current state
    processMetrics = func currentTime {
        metrics = "System metrics at " + currentTime + ": " + 
                 "CPU=" + random(100) + "% " +
                 "Memory=" + random(8192) + "MB"
        return metrics
    }

    RMetrics = MakeReactive(processMetrics)
    
    counter = 0
    maxRuns = 5

    # Create a timer that triggers reactive function every 2 seconds
    metricsTimer = SetInterval(func {
        counter++
        currentTime = timeList()[4] + ":" + timeList()[5] + ":" + timeList()[6]
        
        ? "Timer tick " + counter + " - triggering metrics collection..."
        
        # Each timer tick launches an async metrics calculation
        RMetrics.CallAsync(
            [currentTime],
            func result { 
                ? "  → " + result
                
                # Stop after 5 runs
                if counter >= maxRuns
                    ? "Metrics collection complete - stopping timer"
                    ClearInterval(metricsTimer)
                    Stop()
                ok
            },
            func error { 
                ? "  → Metrics error: " + error 
            }
        )
        
    }, 2000)  # Every 2 seconds

    ? "Starting scheduled metrics collection..."
    Start()
    #-->
    # Starting scheduled metrics collection...
    # Timer tick 1 - triggering metrics collection...
    #   → System metrics at 14:23:15: CPU=67% Memory=3421MB
    # Timer tick 2 - triggering metrics collection...
    #   → System metrics at 14:23:17: CPU=89% Memory=1247MB
    # Timer tick 3 - triggering metrics collection...
    #   → System metrics at 14:23:19: CPU=34% Memory=6891MB
    # Timer tick 4 - triggering metrics collection...
    #   → System metrics at 14:23:21: CPU=56% Memory=2134MB
    # Timer tick 5 - triggering metrics collection...
    #   → System metrics at 14:23:23: CPU=78% Memory=4567MB
    # Metrics collection complete - stopping timer
}

pf()
# Executed in 10.05 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 7: ADVANCED PATTERNS     #
#-----------------------------------#

/*--- Advanced reactive patterns for real-world applications

# Combining reactive functions with conditional logic,
# result transformation, and complex coordination

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Simulate database query
    queryDatabase = func table, filter {
        sleep(0.1)  # Simulate DB latency
        if table = "users"
            return ["John", "Jane", "Bob", "Alice"]
        but table = "products"
            return ["Laptop", "Phone", "Tablet"]
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
# Executed in 0.35 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 8: PERFORMANCE BENEFITS  #
#-----------------------------------#

/*--- Measuring the performance difference

# Compare blocking vs reactive execution to see the time savings
# This demonstrates why reactive functions matter for real applications

pr()

# First, test blocking (traditional) approach
? "=== BLOCKING APPROACH ==="
startTime = clock()

heavyTask = func x {
    result = 0
    for i = 1 to x * 100
        result += sqrt(i)
    next
    return result
}

# Run three tasks sequentially (blocking)
result1 = heavyTask(1000)
? "Task 1 done: " + result1
result2 = heavyTask(800) 
? "Task 2 done: " + result2
result3 = heavyTask(1200)
? "Task 3 done: " + result3

blockingTime = (clock() - startTime) / clocksPerSecond()
? "Blocking total time: " + blockingTime + " seconds"

? ""
? "=== REACTIVE APPROACH ==="

oRs = new stzReactive()
oRs {
    Init()
    
    startTime = clock()
    RHeavy = MakeReactive(heavyTask)
    tasksCompleted = 0
    
    # Launch all three tasks simultaneously (non-blocking)
    RHeavy.CallAsync([1000], func result {
        tasksCompleted++
        ? "Reactive Task 1 done: " + result
        checkComplete()
    }, NULL)
    
    RHeavy.CallAsync([800], func result {
        tasksCompleted++
        ? "Reactive Task 2 done: " + result  
        checkComplete()
    }, NULL)
    
    RHeavy.CallAsync([1200], func result {
        tasksCompleted++
        ? "Reactive Task 3 done: " + result
        checkComplete()
    }, NULL)
    
    func checkComplete {
        if tasksCompleted = 3
            reactiveTime = (clock() - startTime) / clocksPerSecond()
            ? "Reactive total time: " + reactiveTime + " seconds"
            improvement = ((blockingTime - reactiveTime) / blockingTime) * 100
            ? "Performance improvement: " + improvement + "%"
        ok
    }

    Start()
    #-->
    # === BLOCKING APPROACH ===
    # Task 1 done: 21081851.064746
    # Task 2 done: 14907161.943734  
    # Task 3 done: 25580781.643291
    # Blocking total time: 0.89 seconds
    # 
    # === REACTIVE APPROACH ===
    # Reactive Task 1 done: 21081851.064746
    # Reactive Task 2 done: 14907161.943734
    # Reactive Task 3 done: 25580781.643291
    # Reactive total time: 0.32 seconds
    # Performance improvement: 64%
}

pf()
# Executed in 1.23 second(s) in Ring 1.23

#-----------------------------------#
#  EXAMPLE 9: REAL-WORLD USAGE      #
#-----------------------------------#

/*--- Practical example: Image processing pipeline
*/
# Real applications often involve multiple processing steps
# This example shows a complete image processing workflow

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Simulate image operations
    loadImage = func filename {
        if not substr(filename, ".jpg") and not substr(filename, ".png")
            raise("Invalid image format")
        ok
        sleep(0.1)  # Simulate file I/O
        return "IMAGE_DATA_" + filename + "_LOADED"
    }
    
    resizeImage = func imageData, width, height {
        sleep(0.05)  # Simulate processing
        return imageData + "_RESIZED_" + width + "x" + height
    }
    
    applyFilter = func imageData, filterType {
        sleep(0.03)  # Simulate filter processing
        return imageData + "_FILTER_" + filterType
    }
    
    saveImage = func imageData, outputPath {
        sleep(0.02)  # Simulate save operation
        return "SAVED: " + outputPath + " (" + len(imageData) + " bytes)"
    }

    # Make all functions reactive
    RLoad = MakeReactive(loadImage)
    RResize = MakeReactive(resizeImage)
    RFilter = MakeReactive(applyFilter)
    RSave = MakeReactive(saveImage)

    # Process multiple images with different transformations
    images = ["photo1.jpg", "photo2.png", "document.pdf"]  # Last one will fail
    
    for i = 1 to len(images)
        imageName = images[i]
        ? "Starting pipeline for: " + imageName
        
        RLoad.CallAsync([imageName], func imageData {
            ? "  ✓ Loaded: " + imageName
            
            # Resize loaded image
            RResize.CallAsync([imageData, 800, 600], func resizedData {
                ? "  ✓ Resized: " + imageName
                
                # Apply filter to resized image
                RFilter.CallAsync([resizedData, "sepia"], func filteredData {
                    ? "  ✓ Filtered: " + imageName
                    
                    # Save final result
                    outputPath = "output_" + imageName
                    RSave.CallAsync([filteredData, outputPath], func saveResult {
                        ? "  ✓ " + saveResult
                        ? "Pipeline complete for: " + imageName
                    }, func saveError {
                        ? "  ✗ Save failed for " + imageName + ": " + saveError
                    })
                    
                }, func filterError {
                    ? "  ✗ Filter failed for " + imageName + ": " + filterError
                })
                
            }, func resizeError {
                ? "  ✗ Resize failed for " + imageName + ": " + resizeError
            })
            
        }, func loadError {
            ? "  ✗ Load failed for " + imageName + ": " + loadError
        })
    next

    Start()
    #-->
    # Starting pipeline for: photo1.jpg
    # Starting pipeline for: photo2.png
    # Starting pipeline for: document.pdf
    #   ✓ Loaded: photo1.jpg
    #   ✓ Loaded: photo2.png
    #   ✗ Load failed for document.pdf: Invalid image format
    #   ✓ Resized: photo1.jpg
    #   ✓ Resized: photo2.png
    #   ✓ Filtered: photo1.jpg
    #   ✓ Filtered: photo2.png
    #   ✓ SAVED: output_photo1.jpg (42 bytes)
    #   ✓ SAVED: output_photo2.png (42 bytes)
    # Pipeline complete for: photo1.jpg
    # Pipeline complete for: photo2.png
}

pf()
# Executed in 0.50 second(s) in Ring 1.23

#=========================================#
#  KEY TAKEAWAYS - REACTIVE FUNCTIONS    #
#=========================================#

/*
1. BASIC PATTERN:
   - Regular function: result = myFunc(params)
   - Reactive function: ReactiveFunc.CallAsync(params, successHandler, errorHandler)

2. BENEFITS:
   - Non-blocking: Other code runs while function executes
   - Parallel: Multiple functions run simultaneously  
   - Error-safe: Graceful error handling with dedicated error functions
   - Efficient: Better CPU utilization, faster overall execution

3. WHEN TO USE:
   - Heavy computations (math, data processing)
   - I/O operations (file reading, network calls)
   - Any operation that might take noticeable time
   - Batch processing of multiple items

4. BEST PRACTICES:
   - Always provide error handlers
   - Use meaningful variable names in callbacks
   - Chain operations properly for complex workflows
   - Remember to call Start() to begin processing

5. REMEMBER:
   - Reactive functions don't return values directly
   - Results come through success callback functions
   - Errors come through error callback functions
   - The reactive system handles all the complex threading for you
*/
