# Narrative
# --------
# Multiple timers working together
#
# Extracted from stzreactivetimertest.ring, block #4.

load "../../stzBase.ring"


# You can have multiple timers running simultaneously
# Each timer operates independently

pr()

# Running fast timer (every 500ms) and slow timer (every 1500ms)

nFastCount = 0
nSlowCount = 0
cFastId = ""
cSowId = ""

Rs = new stzReactiveSystem()
Rs {
    # Fast timer - every 500ms
    cFastId = RunEvery(500, :fFastTick)
    
    # Slow timer - every 1500ms  
    cSowId = RunEvery(1500, :fSlowTick)
    
    # Stop everything after 4 seconds
    RunAfter(4000, :fStopAllTimers)
    
    ? "Multiple timers started!"

    Start()
}

pf()

func fFastTick()
    nFastCount++
    ? "⚡ Fast tick #" + nFastCount

func fSlowTick()
    nSlowCount++
    ? "🐌 Slow tick #" + nSlowCount
    
func fStopAllTimers()
    ? "⏹️  Stopping all timers..."
    Rs.StopTimer(cFastId)
    Rs.StopTimer(cSowId)
    Rs.Stop()  # This should now properly exit

#--> Output:
# Multiple timers started!
# ⚡ Fast tick #1
# ⚡ Fast tick #2
# ...
# ...
# ⚡ Fast tick #63
# 🐌 Slow tick #1
# ⚡ Fast tick #64
# 🐌 Slow tick #2
# ⚡ Fast tick #65
# ...
# ...
# ...
# ⚡ Fast tick #220
# 🐌 Slow tick #158
# ⏹️  Stopping all timers...

# Executed in 4.02 second(s) in Ring 1.23
