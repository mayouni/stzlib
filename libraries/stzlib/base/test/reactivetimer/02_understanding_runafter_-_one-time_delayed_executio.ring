# Narrative
# --------
# Understanding RunAfter - One-time delayed execution
#
# Extracted from stzreactivetimertest.ring, block #2.

load "../../stzBase.ring"


# RunAfter executes a function ONCE after a specified delay
# Think of it like setting an alarm clock that goes off only once

pr()

# Creating a timer that fires once after 2 seconds

Rs = new stzReactiveSystem()
Rs {

    RunAfter( 2000, func() {
        ? "⏰ DING! Timer went off after 2000ms (2 seconds)"
        ? "This message appears exactly once"
    })
    
    ? "Timer set! Now starting the reactive engine..."
    Start()  # This starts the event loop and waits for timers
}
#-->
'
Timer set! Now starting the reactive engine...
⏰ DING! Timer went off after 2000ms (2 seconds)
This message appears exactly once
'

pf()
# Executed in 2.14 second(s) in Ring 1.23

#--> Output:
# Timer set! Now starting the reactive engine...
# ⏰ DING! Timer went off after 2000ms (2 seconds)
# This message appears exactly once
