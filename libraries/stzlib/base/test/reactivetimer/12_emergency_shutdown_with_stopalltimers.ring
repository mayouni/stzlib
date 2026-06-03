# Narrative
# --------
# Emergency shutdown with StopAllTimers()
#
# Extracted from stzreactivetimertest.ring, block #12.

load "../../stzBase.ring"

pr()

systemAlert = false
timer1 = NULL
timer2 = NULL  
timer3 = NULL

Rs = new stzReactiveSystem()
Rs {
    # Multiple concurrent timers
    timer1 = RunEveryXT(2, :seconds, func {
        ? "System monitor check"
    })
    
    timer2 = RunEveryXT(3, :seconds, func {
        ? "Data backup running"
    })
    
    timer3 = RunEveryXT(5, :seconds, func {
        ? "Network heartbeat"
        systemAlert = true  # Trigger emergency
    })
    
    # Emergency shutdown timer
    RunEveryXT(1, :second, func {
        if systemAlert
            ? "EMERGENCY: Stopping all operations!"
            Rs.StopAllTimers()  # Single call stops everything
            Rs.Stop()
        ok
    })
    
    RunLoop()
}

#-->
# System monitor check
# Data backup running  
# System monitor check
# Network heartbeat
# EMERGENCY: Stopping all operations!

pf()
# Executed in 0.19 second(s) in Ring 1.23
