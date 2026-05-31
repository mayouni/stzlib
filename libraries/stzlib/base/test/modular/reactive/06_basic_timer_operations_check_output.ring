# Narrative
# --------
# Basic timer operations #TODO check output
#
# Extracted from stzreactivetest.ring, block #6.

load "../../../stzBase.ring"


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
