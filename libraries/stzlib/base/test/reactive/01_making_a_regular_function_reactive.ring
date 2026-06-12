# Narrative
# --------
# Making a regular function reactive
#
# Extracted from stzreactivetest.ring, block #1.

load "../../stzBase.ring"


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
        _nListLen_ = len(aList)
        for i = 1 to _nListLen_ nSum += aList[i] next
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
