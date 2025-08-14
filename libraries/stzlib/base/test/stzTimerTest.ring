load "../stzbase.ring"


#===========================================#
#         STZTIMER - COMPREHENSIVE TESTS    #
#===========================================#

/*--- Basic timer creation and start/stop operations

# The stzTimer class wraps Qt's QTimer with Softanza conventions.
# It provides fluent interface methods and reactive programming support.
# Basic operations include creating, starting, stopping, and configuring timers.

pr()

oTimer = new stzTimer(NULL)
? oTimer.toString()
#--> stzTimer(STOPPED, REPEATING, interval=0ms)

oTimer {
    setInterval(1000)
    ? "Interval set to: " + interval() + "ms"
    #--> Interval set to: 1000ms
    
    ? "Is active: " + isActive()
    #--> Is active: 0
    
    ? "Is single shot: " + isSingleShot()
    #--> Is single shot: 0
    
    ? "Timer ID: " + timerId()
    #--> Timer ID: 0 (or some number)
    
    start()
    ? "Started. Is active: " + isActive()
    #--> Started. Is active: 1
    
    stop()
    ? "Stopped. Is active: " + isActive()
    #--> Stopped. Is active: 0
}

pf()
# Executed in almost 0 second(s) in Ring 1.23

/*--- Fluent interface configuration methods

# stzTimer provides intuitive fluent methods for common timer configurations.
# These methods make timer setup more readable and expressive.

pr()

# Repeating timer configurations
oTimer1 = new stzTimer(NULL)
oTimer1.everyMilliseconds(500)
? "Every 500ms: " + oTimer1.toString()
#--> Every 500ms: stzTimer(STOPPED, REPEATING, interval=500ms)

oTimer2 = new stzTimer(NULL) 
oTimer2.everySeconds(2)
? "Every 2 seconds: interval=" + oTimer2.interval() + "ms"
#--> Every 2 seconds: interval=2000ms

oTimer3 = new stzTimer(NULL)
oTimer3.everyMinutes(1)
? "Every 1 minute: interval=" + oTimer3.intervalInSeconds() + " seconds"
#--> Every 1 minute: interval=60 seconds

# Single-shot timer configurations
oSingleTimer = new stzTimer(NULL)
oSingleTimer.onceAfterSeconds(3)
? "Once after 3s: single shot=" + oSingleTimer.isSingleShot()
#--> Once after 3s: single shot=1

oSingleTimer2 = new stzTimer(NULL)
oSingleTimer2.onceAfterMinutes(1)
? "Once after 1 min: interval=" + oSingleTimer2.intervalInSeconds() + "s"
#--> Once after 1 min: interval=60s

pf()


/*--- Timer comparison and equality

# Timers can be compared for equality based on their configuration.
# Copy method creates identical timer with same settings.

pr()

oTimer1 = new stzTimer(NULL)
oTimer1.everySeconds(2).setSingleShot(TRUE)

oTimer2 = oTimer1.copy()

? "Timer1: " + oTimer1.toString()
#--> Timer1: stzTimer(STOPPED, SINGLE-SHOT, interval=2000ms)

? "Timer2: " + oTimer2.toString()  
#--> Timer2: stzTimer(STOPPED, SINGLE-SHOT, interval=2000ms)

? "Are equal: " + oTimer1.isEqualTo(oTimer2)
#--> Are equal: 1

# Different timer
oTimer3 = new stzTimer(NULL)
oTimer3.everySeconds(3)

? "Timer1 equals Timer3: " + oTimer1.isEqualTo(oTimer3)
#--> Timer1 equals Timer3: 0

pf()
