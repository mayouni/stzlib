# Narrative
# --------
# Timer-based data generation
#
# Extracted from stzreactivetest.ring, block #7.

load "../../../stzBase.ring"


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
