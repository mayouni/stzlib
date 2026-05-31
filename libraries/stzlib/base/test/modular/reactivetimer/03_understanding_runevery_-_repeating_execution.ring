# Narrative
# --------
# Understanding RunEvery - Repeating execution
#
# Extracted from stzreactivetimertest.ring, block #3.

load "../../../stzBase.ring"


# RunEvery executes a function REPEATEDLY at regular intervals
# Like a metronome that keeps ticking until you stop it

pr()

# Creating a timer that fires every 1 second, 3 times total

# We need these variables at global level so the callback can access them
nCounter = 0
cIntervalID = ""

Rs = new stzReactiveSystem()
Rs {
    # RunEvery(function_name, interval_in_milliseconds)
    cIntervalID = RunEvery(1000, :fCallback)
    
    ? "Repeating timer set! Starting..."
    Start()
}

pf()

# The callback function - defined separately so variables are accessible
func fCallback()
    nCounter++
    ? "🔔 Tick #" + nCounter + " at time " + clock()
    
    # Stop after 3 ticks
    if nCounter >= 3
        ? "Stopping timer after 3 ticks..."
        Rs.StopTimer(cIntervalID)
        Rs.Stop()
    ok

#-->
'
Repeating timer set! Starting...
🔔 Tick #1 at time 3624
🔔 Tick #2 at time 3640
🔔 Tick #3 at time 3656
Stopping timer after 3 ticks...
'

# Executed in 1.06 second(s) in Ring 1.23
