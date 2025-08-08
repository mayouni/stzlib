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

pr()

# Initializing the system (connects to libuv event loop infrastructure)

oRs = new stzReactive()
oRs {

    # Declaring simple functions

    f1 = func x, y { return x + y }
    f2 = func x { return x * x }
    f3 = func arr { 
        sum = 0
        for i = 1 to len(arr) sum += arr[i] next
        return sum
    }

    # Making them reactive (wraps functions in async infrastructure)
    Rf1 = MakeReactive(f1)
    Rf2 = MakeReactive(f2) 
    Rf3 = MakeReactive(f3)

    # Launch them simultaneously - none blocks the others!
    # Each function is an asynchronous task to which we specify:
    # parameters, success function (executed when the task succeeds),
    # and error function (executed when the task fails).

    # Success and failer functions are also called "handlers".
    
    Rf1.CallAsync(
        [5, 3],     # Add 5 + 3
        func result { ? "Addition result: " + result },
        func error { ? "Addition error: " + error }
    )
    
    Rf2.CallAsync(
        [7],        # Square of 7
        func result { ? "Square result: " + result },
        func error { ? "Square error: " + error }
    )
    
    Rf3.CallAsync(
        [1:100],    # Sum of 1 to 100
        func result { ? "Sum result: " + result },
        func error { ? "Sum error: " + error }
    )

    # All three functions (actually: tasks) are now queued and will execute concurrently
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

oRs = new stzReactive()
oRs {

    # A more complex function that processes arrays
    f1 = func aArr {

        nSum = 0
        nLen = len(aArr)

        for i = 1 to nLen
            nSum += aArr[i]
        next

        return nSum / nLen # Calculate average
    }

    Rf1 = MakeReactive(f1)

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

oRs = new stzReactive()
oRs {
    
    # Creating a basic reactive stream
    St = CreateStream("data-stream", "manual")
    
    # Setting up stream processing pipeline (note lowercase method names)
    St.Subscribe(func data {		# You can also sya OnData() instead of Subscribe()
        ? "Received: " + data
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

oRs = new stzReactive()
oRs {

    # Create source stream

    St = CreateStream("number-stream", "manual")
    St.Start()

    # Transform stream and add subscriber in one block

    St {

        Map(func x { return x * 2 })
        Filter(func x { return x > 10 and x % 2 = 0 })

        OnData(func data {			# You can also say Subscribe() instead of OnData()
            ? "Processed number: " + data
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

/*--- Combining multiple streams
*/
# Stream merging allows combining data from multiple sources.
# Useful for aggregating data from different APIs or user inputs.

pr()

oRs = new stzReactive()
oRs {

    # Create multiple source streams
    St1 = CreateStream("stream1", "manual")
    St2 = CreateStream("stream2", "manual")

    # Merge streams into one
    mergedStream = MergeStreams([ St1, St2 ])

    mergedStream.OnData(func data {
        ? "Merged data: " + data
    })

    # Emit data from different sources
    St1.Emit("From Stream 1")
    St2.Emit("From Stream 2")
    St1.Emit("More from Stream 1")
    
    St1.Complete()
    St2.Complete()

    Start()
}

pf()

#========================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS   #
#========================================#

/*--- Basic timer operations

# Reactive timers execute callbacks after specified delays without blocking.
# They integrate with the event loop for precise timing control.
# Essential for animations, polling, and time-based operations.

pr()

oRs = new stzReactive()
oRs {
    Init()

    # One-time timer (setTimeout equivalent)
    SetTimeout(func() {
        ? "Timer fired after 1000ms"
    }, 1000)

    # Repeating timer (setInterval equivalent)
    intervalId = SetInterval(func() {
        ? "Repeating timer: " + clock()
    }, 500)

    # Cancel the interval after 5 executions
    counter = 0
    SetTimeout(func() {
        ClearInterval(intervalId)
        ? "Interval cancelled"
    }, 2500)

    Start()
}

pf()

/*--- Timer-based data generation

# Timers can drive reactive streams, creating time-based data sources.
# Perfect for simulating real-time data feeds or periodic updates.

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Create a stream fed by timer
    dataStream = CreateStream()
    
    dataStream.OnData(func data {
        ? "Time-based data: " + data
    })

    # Generate data every 300ms
    counter = 0
    intervalId = SetInterval(func() {
        counter++
        dataStream.Emit("Data point #" + counter)
        
        if counter >= 5
            ClearInterval(intervalId)
            dataStream.End()
        ok
    }, 300)

    Start()
}

pf()

#========================================#
#  HTTP REQUESTS - NETWORK OPERATIONS    #
#========================================#

/*--- Basic HTTP requests

# Reactive HTTP requests prevent blocking during network operations.
# They provide clean error handling and response processing.
# Support for all HTTP methods with customizable headers and data.

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Simple GET request
    HttpGet("https://api.github.com/users/octocat", 
        func response {
            ? "GET Response received: " + len(response) + " characters"
        },
        func error {
            ? "GET Error: " + error
        }
    )

    # POST request with data
    postData = '{"name": "test", "value": 123}'
    HttpPost("https://httpbin.org/post", postData,
        func response {
            ? "POST Response: Success"
        },
        func error {
            ? "POST Error: " + error
        }
    )

    Start()
}

pf()

/*--- HTTP request pipeline with stream processing

# Combining HTTP requests with streams creates powerful data processing pipelines.
# Results can be transformed and filtered before reaching the application.

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Create stream for HTTP responses
    httpStream = CreateStream()

    # Process HTTP responses
    httpStream
        .Map(func response { return len(response) }) # Extract response length
        .Filter(func length { return length > 100 })  # Only large responses
        .OnData(func length {
            ? "Large response received: " + length + " bytes"
        })

    # Make multiple requests
    urls = [
        "https://api.github.com/users/octocat",
        "https://httpbin.org/json",
        "https://api.github.com/repos/octocat/Hello-World"
    ]

    for i = 1 to len(urls)
        HttpGet(urls[i],
            func response { httpStream.Emit(response) },
            func error { ? "Request failed: " + error }
        )
    next

    # End stream after delay
    SetTimeout(func() { httpStream.End() }, 3000)

    Start()
}

pf()

#========================================#
#  FILE OPERATIONS - ASYNC I/O           #
#========================================#

/*--- Basic file operations

# Reactive file operations prevent I/O blocking in applications.
# They handle large files efficiently with progress callbacks.
# Support for reading, writing, and monitoring file changes.

pr()

oRs = new stzReactive()
oRs {
    Init()

    # Write file asynchronously
    WriteFile("test.txt", "Hello Reactive World!",
        func() {
            ? "File written successfully"
            
            # Read the file back
            ReadFile("test.txt",
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
    Init()

    # Create file read stream
    fileStream = CreateFileReadStream("large_data.txt")

    lineCount = 0
    fileStream
        .OnData(func chunk {
            # Process file chunks
            lines = split(chunk, nl)
            lineCount += len(lines)
            ? "Processed " + len(lines) + " lines, total: " + lineCount
        })
        .OnEnd(func() {
            ? "File processing complete. Total lines: " + lineCount
        })
        .OnError(func error {
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

    RfCalculateStats = MakeReactive(fCalculateStats)

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

    RfProblematic = MakeReactive(fProblematic)

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
