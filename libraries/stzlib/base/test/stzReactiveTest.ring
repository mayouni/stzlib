
load "../stzbase.ring"


#========================================#
#  REACTIVE FUNCTIONS - BASIC CONCEPTS   #
#========================================#

/*--- Making a regular function reactive

# Reactiveness transforms blocking functions into non-blocking operations.
# Instead of waiting for results, you provide "success workers" - functions that runs when ready.

# A callback is simply a function that gets called back with the result later.
# This allows multiple tasks to run simultaneously without blocking each other.

#
#     BLOCKING (Traditional)          NON-BLOCKING (Reactive)
#     ======================          =======================
#     
#     result1 = f1(5,3)   ──┐         f1.CallAsync(5,3, worker1)   ──┐
#                           │                                        │
#     result2 = f2(7)      ←┘         f2.CallAsync(7, worker2)       │ ← All queued
#                           │                                        │   instantly
#     result3 = f3(1:100)  ←┘         f3.CallAsync(1:100, worker3) ──┘
#                                    
#                                     Start() ← Process all in parallel

# Initializing the system (connects to libuv event loop infrastructure)

pr()

oRs = new stzReactive()
oRs {

    # Declaring simple functions

    f1 = func x, y { return x + y }
    f2 = func x { return x * x }
    f3 = func aList { 
        nSum = 0
        for i = 1 to len(aList) nSum += aList[i] next
        return nSum
    }

    # Making them reactive (wraps functions in async infrastructure)
    Rf1 = Reactivate(f1) # Or MakeReactive(f1)
    Rf2 = Reactivate(f2) 
    Rf3 = Reactivate(f3)

    # Launch them simultaneously - none blocks the others!
    # Each function is an asynchronous task to which we specify:
    # parameters, success function (executed when the task succeeds),
    # and error function (executed when the task fails).

    # Success and failer functions are also called "handlers".

    Rf1.CallAsync(
        [5, 3],     # Add 5 + 3
        func cResult { ? "Addition result: " + cResult },
        func cError { ? "Addition error: " + cError }
    )

    Rf2.CallAsync(
        [7],        # Square of 7
        func cResult { ? "Square result: " + cResult },
        func cError { ? "Square error: " + cError }
    )

    Rf3.CallAsync(
        [1:100],    # Sum of 1 to 100
        func cResult { ? "Sum result: " + cResult },
        func cError { ? "Sum error: " + cError }
    )

    # All three functions (actually: tasks) are now queued and
    # will execute concurrently 

    # Start the reactive system to process all queued tasks

    Start()
    #-->
    # Addition result: 8
    # Square result: 49
    # Sum result: 5050

    # What happened behind the scenes:
    # 1. libuv thread pool picked up the 3 functions and ran them in parallel
    # 2. As each function completed, its result was queued back to main program (thread)
    # 3. The event loop processed results and called the appropriate success/failure function
    # 4. Output appears in completion order (may vary between runs)
}

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*--- Reactive functions with complex data processing

# Reactive functions excel at CPU-intensive tasks that would block the main program thread.
# They automatically handle error propagation and result transformation.

pr()

Rs = new stzReactive()
Rs {

    # A more complex function that processes arrays
    f1 = func aList {

        nSum = 0
        nLen = len(aList)

        for i = 1 to nLen
            nSum += aList[i]
        next

        return nSum / nLen # Calculate average
    }

    Rf1 = Reactivate(f1) # Or MakeReactive(f1)

    # Process large dataset asynchronously
    aLargeData = 1:1000 # Array of numbers 1 to 1000
    
    Rf1.CallAsync(
        [aLargeData],
        func cResult { ? "Average of 1000 numbers: " + cResult },
        func cError { ? "Processing error: " + cError }
    )

    Start()
    #--> Average of 1000 numbers: 500.50
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

#========================================#
#  REACTIVE STREAMS - DATA FLOW CONTROL  #
#========================================#

/*--- Basic stream creation and consumption

# Streams represent continuous data flows that can be processed reactively.
# They support backpressure, filtering, and transformation operations.
# Ideal for handling real-time data, user inputs, or API responses.

pr()

Rs = new stzReactive()
Rs {
    
    # Creating a basic reactive stream
    St = CreateStream("data-stream", "manual")
    
    # Setting up stream processing pipeline
    St.Subscribe(func cData { # You can also sya OnData() instead of Subscribe()
        ? "Received: " + cData
    })
    
    St.OnError(func cError {
        ? "Stream error: " + cError
    })
    
    St.OnComplete(func() {
        ? "Stream completed"
    })
    
    # Start the stream
    St.Start()
    
    # Emitting data to the stream
    St.Emit("Hello")
    St.Emit("World")
    St.Emit("Reactive")
    
    # Complete the stream
    St.Complete()
    
    Start()
    #-->
    # Received: Hello
    # Received: World
    # Received: Reactive
    # Stream completed

 }

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Stream transformation and filtering

# Streams can be transformed using operators like Map, Filter, and Reduce.
# This enables powerful data processing pipelines with minimal code.

pr()

Rs = new stzReactive()
Rs {

    # Create source stream

    St = CreateStream("number-stream", "manual")
    St.Start()

    # Transform stream and add subscriber in one block

    St {

        Map(func x { return x * 2 })
        Filter(func x { return x > 10 and x % 2 = 0 })

        OnData(func cData { # You can also say Subscribe() instead of OnData()
            ? "Processed number: " + cData
        })
    }

    # Feed data to the stream

    for i = 1 to 10
        St.Emit(i)
    next

    # Finish the stream

    St.Complete()

    # Launch the tasks

    Start()
    #-->
    # Processed number: 12
    # Processed number: 14
    # Processed number: 16
    # Processed number: 18
    # Processed number: 20

}

pf()
# Executed in almost 0 second(s) in Ring 1.23

#========================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS   #
#========================================#

/*--- Basic timer operations

# Reactive timers execute callbacks after specified delays without blocking.
# They integrate with the event loop for precise timing control.
# Essential for animations, polling, and time-based operations.

pr()

# Define counter and intervalId at the module level or use object properties
nCounter = 0
cIntervalId = ""

Rs = new stzReactive()
Rs {
    # One-time timer
    SetTimeout(func() {
        ? "Timer fired after 1000ms"
    }, 1000)

    # Repeating timer - use global counter
    intervalId = SetInterval(:fRepeatCallback, 500)

    Start()
}

pf()

# Define the callback function separately
func fRepeatCallback()
    nCounter++
    ? "Repeating timer: " + nCounter + " at " + clock()
    
    # Stop after 5 executions
    if nCounter >= 5
        Rs.ClearInterval(cIntervalId)
        ? "Interval cancelled after 5 executions"
        Rs.Stop()
    ok

#-->
# Repeating timer: 1 at 3782
# Repeating timer: 2 at 3797
# Repeating timer: 3 at 3814
# Repeating timer: 4 at 3830
# Repeating timer: 5 at 3846
# Interval cancelled after 5 executions

# Executed in 0.58 second(s) in Ring 1.23

/*--- Timer-based data generation

# Timers can drive reactive streams, creating time-based data sources.
# Perfect for simulating real-time data feeds or periodic updates.

pr()

Rs = new stzReactive()
Rs {

    # Create a stream fed by timer
    oDataStream = CreateStream("timer-stream", "manual")
    
    oDataStream.OnData(func cData {
        ? "Time-based data: " + cData
    })

    # Generate data every 300ms
    nCounter = 0
    oIntervalTimer = SetInterval( func() {
        nCounter++
        # Access dataStream through the oRs object
        Rs.oDataStream.Emit("Data point #" + nCounter)
        
        if nCounter >= 5
            Rs.ClearInterval(oIntervalTimer)
            Rs.oDataStream.End_()
        ok
    }, 300)

    Start()
}
#-->
# Time-based data: Data point #1
# Time-based data: Data point #2
# Time-based data: Data point #3
# Time-based data: Data point #4
# Time-based data: Data point #5

pf()
# Executed in 0.40 second(s) in Ring 1.23

#========================================#
#  HTTP REQUESTS - NETWORK OPERATIONS    #
#========================================#

/*--- Basic HTTP requests

# Reactive HTTP requests prevent blocking during network operations.
# They provide clean error handling and response processing.
# Support for all HTTP methods with customizable headers and data.

pr()

Rs = new stzReactive()
Rs {

    # Simple GET request
    HttpGet("https://api.github.com/users/mayouni", 
        func cResponse {
            ? "GET Response received: " + len(cResponse) + " characters"
        },
        func cError {
            ? "GET Error: " + cError
        }
    )

    # POST request with data
    cPostData = '{"name": "test", "value": 123}'
    HttpPost("https://httpbin.org/post",
	cPostData,
        func cResponse {
            ? "POST Response: Success"
        },
        func cError {
            ? "POST Error: " + cError
        }
    )

    Start()
}
#-->
# GET Response received: 54 characters
# POST Response: Success

pf()
# Executed in almost 1.69 second(s) in Ring 1.23

/*--- HTTP request pipeline with stream processing

# Combining HTTP requests with streams creates powerful data processing pipelines.
# Results can be transformed and filtered before reaching the application.

pr()

Rs = new stzReactive()
Rs.Init()  # Add this initialization

# Store the stream in a variable first
oHttpStream = Rs.CreateStream("http-stream", "manual")

# Then configure the stream
oHttpStream {
    # TRANSFORM 1: Map - Convert response string to its length
    Map(func cResponse { return len(cResponse) })  
    
    # TRANSFORM 2: Filter - Only pass through responses longer than 10 characters
    Filter(func nLength { return nLength > 10 })
    
    # SUBSCRIBE: Define what happens when filtered data reaches the end
    Subscribe(func nLength {
        ? "Large response received: " + nLength + " bytes"
    })
}

# Make multiple HTTP requests
acUrls = [
    "https://api.github.com/users/mayouni",
    "https://httpbin.org/json", 
    "https://api.github.com/users/mayouni/repos/stzlib"
]

for i = 1 to len(acUrls)
    Rs.HttpGet(acUrls[i],
        func cResponse { 
            oHttpStream.Emit(cResponse) 
        },
        func cError { 
            ? "Request failed: " + cError 
        }
    )
next

# End stream after delay
Rs.SetTimeout(func() { oHttpStream.End_() }, 3000)

Rs.Start()
#-->
# Large response received: 1435 bytes
# Large response received: 429 bytes
# Large response received: 106 bytes

# WHAT HAPPENS STEP BY STEP:
# =========================
# 1. Three HTTP GET requests are made simultaneously
# 2. Each request returns a placeholder string (e.g., "GET response from https://...")
# 3. On success, each response is emitted to httpStream
# 4. Stream applies Map transform: string -> length (54, 42, 67)
# 5. Stream applies Filter: only lengths > 10 pass through (all pass)  
# 6. Stream calls OnData subscriber for each filtered value
# 7. Result: Three "Large response received: X bytes" messages printed

pf()
# Executed in 4.77 second(s) in Ring 1.23

#========================================#
#  FILE OPERATIONS - ASYNC I/O           #
#========================================#

/*--- Basic file operations
*/
# Reactive file operations prevent I/O blocking in applications.
# They handle large files efficiently with progress callbacks.
# Support for reading, writing, and monitoring file changes.

pr()

oRs = new stzReactive()
oRs {

    # Write file asynchronously
    WriteFile("reactive.txt", "Hello Reactive World!",
        func() {
            ? "File written successfully"
            
            # Read the file back
            ReadFile("reactive.txt",
                func content {
                    ? "File content: " + content
                },
                func error {
                    ? "Read error: " + error
                }
            )
        },
        func error {
            ? "Write error: " + error
        }
    )

    Start()
}

pf()

/*--- File streaming for large files

# File streams handle large files without loading everything into memory.
# Ideal for processing logs, data files, or media content.

pr()

oRs = new stzReactive()
oRs {

    # Create file read stream
    fs = CreateFileReadStream("large_data.txt")

    lineCount = 0
    fs.OnData(func chunk {
            # Process file chunks
            lines = split(chunk, nl)
            lineCount += len(lines)
            ? "Processed " + len(lines) + " lines, total: " + lineCount
        })

    fs.OnEnd(func() {
            ? "File processing complete. Total lines: " + lineCount
        })

    fs.OnError(func error {
            ? "File stream error: " + error
        })

    Start()
}

pf()

#========================================#
#  INTEGRATED REACTIVE SYSTEM            #
#========================================#

/*--- Complete reactive application example

# Demonstrates integration of all reactive components:
# - Functions for data processing
# - Streams for data flow
# - Timers for scheduling
# - HTTP for external data
# - File I/O for persistence

pr()

? "=== Complete Reactive Application Demo ==="

oRs = new stzReactive()
oRs {
    Init()

    # Data processing functions
    fCalculateStats = func numbers {
        if len(numbers) = 0 return [0, 0, 0] ok
        sum = 0
        min_val = numbers[1]
        max_val = numbers[1]
        
        for i = 1 to len(numbers)
            sum += numbers[i]
            if numbers[i] < min_val min_val = numbers[i] ok
            if numbers[i] > max_val max_val = numbers[i] ok
        next
        
        avg = sum / len(numbers)
        return [avg, min_val, max_val]
    }

    RfCalculateStats = Reactivate(fCalculateStats)

    # Data collection stream
    dataStream = CreateStream()
    collectedData = []

    dataStream.OnData(func data {
        add(collectedData, data)
        ? "Collected data point: " + data + " (total: " + len(collectedData) + ")"
        
        # Process data every 5 points
        if len(collectedData) % 5 = 0
            RfCalculateStats.CallAsync(
                [collectedData],
                func stats {
                    ? "Statistics - Avg: " + stats[1] + ", Min: " + stats[2] + ", Max: " + stats[3]
                    
                    # Save results to file
                    report = "Stats Report: Avg=" + stats[1] + ", Min=" + stats[2] + ", Max=" + stats[3] + nl
                    AppendFile("stats_report.txt", report,
                        func() { ? "Report saved" },
                        func error { ? "Save error: " + error }
                    )
                },
                func error { ? "Stats calculation error: " + error }
            )
        ok
    })

    # Simulate real-time data source
    dataCounter = 0
    SetInterval(func() {
        dataCounter++
        randomValue = random(100) + 1  # Random number 1-100
        dataStream.Emit(randomValue)
        
        if dataCounter >= 15
            dataStream.End()
            ? "Data collection complete"
        ok
    }, 500)

    # Fetch external configuration
    HttpGet("https://httpbin.org/json",
        func response {
            ? "External config loaded successfully"
        },
        func error {
            ? "Using default configuration due to: " + error
        }
    )

    # Cleanup timer
    SetTimeout(func() {
        ? "=== Reactive Application Demo Complete ==="
    }, 8000)

    Start()
}

pf()

/*--- Error handling and system monitoring

# Comprehensive error handling ensures robust reactive applications.
# System monitoring provides insights into performance and resource usage.

pr()

? "=== Error Handling & Monitoring Demo ==="

oRs = new stzReactive()
oRs {
    Init()

    # Global error handler
    OnError(func error {
        ? "Global error caught: " + error
        WriteFile("error.log", clock() + ": " + error + nl,
            func() { ? "Error logged" },
            func err { ? "Failed to log error: " + err }
        )
    })

    # System monitoring
    SetInterval(func() {
        ? "System status: " + GetSystemStatus()
    }, 2000)

    # Intentionally problematic operations for testing
    fProblematic = func x {
        if x = 0 
            raise("Division by zero!")
        else
            return 100 / x
        ok
    }

    RfProblematic = Reactivate(fProblematic)

    # Test error handling
    testValues = [10, 5, 0, 2]
    for i = 1 to len(testValues)
        RfProblematic.CallAsync(
            [testValues[i]],
            func result { ? "Result for " + testValues[i] + ": " + result },
            func error { ? "Expected error for " + testValues[i] + ": " + error }
        )
    next

    Start()
}

pf()
