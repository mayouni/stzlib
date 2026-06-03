# Narrative
# --------
# Simple countdown timer with StopTimer()
#
# Extracted from stzreactivetimertest.ring, block #11.

load "../../stzBase.ring"


pr()

countdown = 5
timerId = NULL

Rs = new stzReactiveSystem()
Rs {
    # Start countdown timer
    timerId = RunEveryXT(1, :seconds, func {
        ? "Countdown: " + countdown
        countdown--
        
        if countdown <= 0
            ? "Time's up!"
            Rs.StopTimer(timerId)  # Natural stop action
            Rs.Stop()
        ok
    })
    
    Start()
}

#-->
# Countdown: 5
# Countdown: 4  
# Countdown: 3
# Countdown: 2
# Countdown: 1
# Time's up!

pf()
# Executed in 0.19 second(s) in Ring 1.23
