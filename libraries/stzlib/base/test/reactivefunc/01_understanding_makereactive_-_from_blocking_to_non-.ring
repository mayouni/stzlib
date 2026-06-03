# Narrative
# --------
# Understanding MakeReactive - From blocking to non-blocking
#
# Extracted from stzreactivefunctest.ring, block #1.

load "../../stzBase.ring"


# Regular functions block execution until they finish
# Reactive functions run in the background and notify you when done

pr()

oRs = new stzReactiveSystem()
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
