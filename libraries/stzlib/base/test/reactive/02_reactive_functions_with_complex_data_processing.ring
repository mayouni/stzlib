# Narrative
# --------
# Reactive functions with complex data processing
#
# Extracted from stzreactivetest.ring, block #2.

load "../../stzBase.ring"


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
