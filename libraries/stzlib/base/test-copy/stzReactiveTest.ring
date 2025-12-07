
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

# Initializing Softanza Reactive system
# (connects to libuv event loop infrastructure)

pr()

Rs = new stzReactiveSystem()
Rs {

    # Declaring simple functions

    f1 = func x, y { return x + y }
    f2 = func x { return x * x }
    f3 = func aList { 
        nSum = 0
        for i = 1 to len(aList) nSum += aList[i] next
        return nSum
    }

    # Making them reactive (wraps functions in async infrastructure)
    Xf1 = Reactivate(f1) # Or MakeReactive(f1)
    Xf2 = Reactivate(f2) 
    Xf3 = Reactivate(f3)

    # Launch them simultaneously - none blocks the others!
    # Each function is an asynchronous task to which we specify:
    # parameters, success function (executed when the task succeeds),
    # and error function (executed when the task fails).

    # Success and failer functions are also called "handlers".

    Xf1.CallAsync(
        [5, 3],     # Add 5 + 3
        func cResult { ? "Addition result: " + cResult },
        func cError { ? "Addition error: " + cError }
    )

    Xf2.CallAsync(
        [7],        # Square of 7
        func cResult { ? "Square result: " + cResult },
        func cError { ? "Square error: " + cError }
    )

    Xf3.CallAsync(
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

Rs = new stzReactiveSystem()
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

    Xf1 = Reactivate(f1) # Or MakeReactive(f1)

    # Process large dataset asynchronously
    aLargeData = 1:1000 # Array of numbers 1 to 1000
    
    Xf1.CallAsync(
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

Rs = new stzReactiveSystem()
Rs {

    # Creating a basic reactive stream
    oXStream = CreateStream("data-stream")
    oXStream {
	    # Setting up stream processing pipeline
	    OnRecieve( func cData { # You can also sya OnPassed() instead of OnPass()
	        ? "Received: " + cData
	    })
 
	    OnError( func cError {
	        ? "Stream error: " + cError
	    })
 
	    OnNoMore( func  {
	        ? "Stream completed"
	    })

	    # Start the stream
	    Start()

	    # Recieveting data to the stream
	    Recieve("Hello")
	    Recieve("World")
	    Recieve("Reactive")
	    # Or alternatively:
	    # RecieveMany([ "Hello", "World", "Reactive" ])

	    # Complete the stream
	    Conclude()
    }

    Run()
    #-->
    # Received: Hello
    # Received: World
    # Received: Reactive
    # Stream completed

 }

pf()
# Executed in almost 0.93 second(s) in Ring 1.23

/*--- Stream transformation and filtering

# Streams can be transformed using operations like Map, Filter, and Reduce.
# This enables powerful data processing pipelines with minimal code.

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create source stream

    oXStream = CreateStream("number-stream")

    # Transform stream and add subscriber in one block

    oXStream {

	# Starting the stream

	Start()	# Optional, for clarity, started automatically when invoqued

	# Defining the stream transformation

        Map( func x { return x * 2 })
        Filter( func x { return x > 10 and x % 2 = 0 })

	# Defining the reactive function to process the item that passes
	# the Map and Filter stels

        OnPassed( func cData {
            ? "Processed number: " + cData
        })

	# Defining the data that will fire the reactive functions above

	RecieveMany(1:10)

	# Cleaning the stream from memory by concluding any pending task (OPTIONAL)

	Conclude()
    }

    RunLoop()
    #-->
    # Processed number: 12
    # Processed number: 14
    # Processed number: 16
    # Processed number: 18
    # Processed number: 20

}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Same example as above with a Reduce() function

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create source stream

    oXStream = CreateStream("number-stream")

    # Transform stream and add subscriber in one block

    oXStream {

	# Defining the stream transformation

        Map(func x { return x * 2 })
        Filter(func x { return x > 10 and x % 2 = 0 })
	Reduce(func acc, x { return acc + x }, 0)

	# Defining the callback function

        OnPassed(func cData {
            ? "Processed number: " + cData
        })

	# Feeding data to the stream

	RecieveMany(1:10)

    }

    Start()
    #-->
    # Processed number: 80
}

pf()
# Executed in almost 0.94 second(s) in Ring 1.23

#========================================#
#  REACTIVE TIMERS - TIME-BASED EVENTS   #
#========================================#

/*--- Basic timer operations #TODO check output

# Reactive timers execute callbacks after specified delays without blocking.
# They integrate with the event loop for precise timing control.
# Essential for animations, polling, and time-based operations.

pr()

# Define counter and cTimerID at the module level or use object properties
nCounter = 0
cTimerId = ""

Rs = new stzReactiveSystem()
Rs {
    # One-time timer
    RunAfter(1000, func  {
        ? "Timer fired after 1000ms"
    })

    # Repeating timer - use global counter
    intervalId = RunEvery(500, func {
	    nCounter++
	    ? "Repeating timer: " + nCounter + " at " + clock()
	    
	    # Stop after 5 executions
	    if nCounter >= 5
	        Rs.StopTimer(cTimerId)
	        ? "Interval cancelled after 5 executions"
		Rs.Stop()
	    ok
    })

    Start()
}
#-->
# Repeating timer: 1 at 3125
# Repeating timer: 2 at 3141
# Repeating timer: 3 at 3157
# Repeating timer: 4 at 3173
# Repeating timer: 5 at 3189
# Interval cancelled after 5 executions

pf()
# Executed in 0.60 second(s) in Ring 1.23

/*--- Timer-based data generation

# Timers can drive reactive streams, creating time-based data sources.
# Perfect for simulating real-time data feeds or periodic updates.

pr()

Rs = new stzReactiveSystem()
Rs {

    # Create a stream fed by timer
    oDataStream = CreateStream("timer-stream")
    
    oDataStream.OnPassed(func cData {
        ? "Time-based data: " + cData
    })

    # Generate data every 300ms
    nCounter = 0
    oIntervalTimer = RunEvery( func() {
        nCounter++
        # Access dataStream through the Rs object
        Rs.oDataStream.Recieve("Data point #" + nCounter)
        
        if nCounter >= 5
            Rs.StopTimer(oIntervalTimer) #TODO //Review name
            Rs.oDataStream.Conclude()
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

Rs = new stzReactiveSystem()
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

Rs = new stzReactiveSystem()

# Store the stream in a variable first
oHttpStream = Rs.CreateStream("http-stream")

# Then configure the stream
oHttpStream {
    # Map - Convert response string to its length
    Map(func cResponse { return len(cResponse) })  
    
    # Filter - Only pass through responses longer than 10 characters
    Filter(func nLength { return nLength > 10 })
    
    # Define what happens when filtered data reaches the end
    OnPassed(func nLength {
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
            oHttpStream.Recieve(cResponse) 
        },
        func cError { 
            ? "Request failed: " + cError 
        }
    )
next

# End stream after delay
Rs.RunAfter(3000, func() { oHttpStream.Conclude() })

Rs.Start()
#-->
# Large response received: 1435 bytes
# Large response received: 429 bytes
# Large response received: 106 bytes

# WHAT HAPPENS STEP BY STEP:
# =========================
# 1. Three HTTP GET requests are made simultaneously
# 2. Each request returns a placeholder string (e.g., "GET response from https://...")
# 3. On success, each response is Recieveted to httpStream
# 4. Stream applies Map transform: string -> length (54, 42, 67)
# 5. Stream applies Filter: only lengths > 10 pass through (all pass)  
# 6. Stream calls OnPassed subscriber for each filtered value
# 7. Result: Three "Large response received: X bytes" messages printed

pf()
# Executed in 4.77 second(s) in Ring 1.23
