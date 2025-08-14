load "../stzbase.ring"


#===========================================#
#         STZTIMER - COMPREHENSIVE TESTS    #
#===========================================#

# ✓ Basic timer operations
# ✓ Fluent interface methods
# ✓ Event handling and callbacks
# ✓ Tick counting and management
# ✓ Factory function patterns
# ✓ Reactive programming with observers
# ✓ State queries and utilities
# ✓ Timer comparison and copying
# ✓ Method chaining and fluent API
# ✓ Synchronous wait operations
# ✓ Advanced reactive scenarios
# ✓ Error handling and edge cases
# ✓ Performance and resource management


/*--- Basic timer creation and start/stop operations
*/
# The stzTimer class wraps Qt's QTimer with Softanza conventions.
# It provides fluent interface methods and reactive programming support.
# Basic operations include creating, starting, stopping, and configuring timers.

pr()

oTimer = new stzTimer(NULL)
? oTimer.toString()
#--> stzTimer(STOPPED, REPEATING, interval=0ms, ticks=0)

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
#--> Every 500ms: stzTimer(STOPPED, REPEATING, interval=500ms, ticks=0)

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

/*--- Timer event handling and timeout callbacks

# Timers can execute code when they timeout using event handlers.
# The onTimeout method sets up the callback function or code string.

pr()

# Simple timeout handler
nCount = 0
oEventTimer = new stzTimer(NULL)
oEventTimer {
    everyMilliseconds(100)
    onTimeout('
        nCount++
        ? "Tick " + nCount
        if nCount >= 3
            this.stop()
        ok
    ')
    start()
}

# Wait for timer to complete
while oEventTimer.isActive()
    # Process events
end

? "Timer completed. Final count: " + nCount
#--> Tick 1
#--> Tick 2  
#--> Tick 3
#--> Timer completed. Final count: 3

pf()

/*--- Tick counting and management

# stzTimer automatically counts timer ticks for monitoring purposes.
# Tick counting can be reset manually or automatically.

pr()

oTickTimer = new stzTimer(NULL)
oTickTimer {
    everyMilliseconds(50)
    setAutoResetTickCount(TRUE)
    
    onTimeout('
        ? "Tick count: " + this.tickCount()
        if this.tickCount() >= 5
            this.stop()
        ok
    ')
    
    start()
}

# Wait for completion
while oTickTimer.isActive()
    # Process events  
end

? "Final tick count: " + oTickTimer.tickCount()
#--> Tick count: 1
#--> Tick count: 2
#--> Tick count: 3
#--> Tick count: 4
#--> Tick count: 5
#--> Final tick count: 5

# Manual tick reset
oTickTimer.resetTickCount()
? "After reset: " + oTickTimer.tickCount()
#--> After reset: 0

pf()

/*--- Factory functions for quick timer creation

# Factory functions provide shortcuts for common timer patterns.
# They return pre-configured timer objects ready to start.

pr()

# Quick repeating timer
oQuickRepeating = stzRepeatingTimer(200, '? "Quick repeat: " + CurrentTime()')

# Quick single-shot timer  
oQuickSingle = stzSingleShotTimer(1000, '? "Single shot executed!"')

# Quick reactive timer
oQuickReactive = stzReactiveTimer(150)

? "Repeating timer: " + oQuickRepeating.toString()
#--> Repeating timer: stzTimer(STOPPED, REPEATING, interval=200ms, ticks=0)

? "Single shot timer: " + oQuickSingle.toString() 
#--> Single shot timer: stzTimer(STOPPED, SINGLE-SHOT, interval=1000ms, ticks=0)

? "Reactive timer: " + oQuickReactive.toString()
#--> Reactive timer: stzTimer(STOPPED, REPEATING, interval=150ms, ticks=0)

pf()

/*--- Reactive programming with observer pattern

# Reactive timers can notify observers of timer events.
# This enables decoupled, event-driven timer programming.

pr()

# Create a simple observer class
class TimerObserver
    cName
    
    def init(name)
        cName = name
    
    def onTimerEvent(cEvent, xData)
        ? cName + " received: " + cEvent + " with data: " + xData

# Create observers
oObserver1 = new TimerObserver("Observer-A")  
oObserver2 = new TimerObserver("Observer-B")

# Create reactive timer
oReactiveTimer = new stzTimer(NULL)
oReactiveTimer {
    makeReactive()
    everyMilliseconds(100)
    subscribe(oObserver1)
    subscribe(oObserver2)
    
    onTimeout('
        if this.tickCount() >= 3
            this.stop()
        ok
    ')
    
    start()
}

# Wait for completion
while oReactiveTimer.isActive()
    # Process events
end

? "Observers count: " + len(oReactiveTimer.observers())
#--> Observer-A received: timeout with data: 1
#--> Observer-B received: timeout with data: 1
#--> Observer-A received: timeout with data: 2  
#--> Observer-B received: timeout with data: 2
#--> Observer-A received: timeout with data: 3
#--> Observer-B received: timeout with data: 3
#--> Observers count: 2

pf()

/*--- Timer state queries and utility methods

# stzTimer provides various methods to query timer state.
# Utility methods help with timer control and information.

pr()

oStateTimer = new stzTimer(NULL)
oStateTimer {
    everySeconds(1)
    
    ? "Is running: " + isRunning()
    #--> Is running: 0
    
    ? "Is stopped: " + isStopped() 
    #--> Is stopped: 1
    
    ? "Is repeating: " + isRepeating()
    #--> Is repeating: 1
    
    start()
    
    ? "After start - Is running: " + isRunning()
    #--> After start - Is running: 1
    
    ? "Remaining time: " + remainingTime()
    #--> Remaining time: 1000
    
    pause()  # Same as stop()
    
    ? "After pause - Is running: " + isRunning()
    #--> After pause - Is running: 0
    
    resume() # Same as start()
    
    ? "After resume - Is running: " + isRunning()
    #--> After resume - Is running: 1
    
    stop()
}

pf()

/*--- Timer comparison and equality

# Timers can be compared for equality based on their configuration.
# Copy method creates identical timer with same settings.

pr()

oTimer1 = new stzTimer(NULL)
oTimer1.everySeconds(2).setSingleShot(TRUE)

oTimer2 = oTimer1.copy()

? "Timer1: " + oTimer1.toString()
#--> Timer1: stzTimer(STOPPED, SINGLE-SHOT, interval=2000ms, ticks=0)

? "Timer2: " + oTimer2.toString()  
#--> Timer2: stzTimer(STOPPED, SINGLE-SHOT, interval=2000ms, ticks=0)

? "Are equal: " + oTimer1.isEqualTo(oTimer2)
#--> Are equal: 1

# Different timer
oTimer3 = new stzTimer(NULL)
oTimer3.everySeconds(3)

? "Timer1 equals Timer3: " + oTimer1.isEqualTo(oTimer3)
#--> Timer1 equals Timer3: 0

pf()

/*--- Chaining methods with fluent interface

# The fluent interface allows method chaining for readable code.
# Chain connectors (then, and, but) improve code readability.

pr()

oFluentTimer = new stzTimer(NULL)

oFluentTimer {
    everyMilliseconds(300)
    .then()
    .onTimeout('? "Fluent timer tick: " + this.tickCount()')
    .and()
    .makeReactive()
    .but()
    .setSingleShot(FALSE)
}

? "Fluent timer configured: " + oFluentTimer.toString()
#--> Fluent timer configured: stzTimer(STOPPED, REPEATING, interval=300ms, ticks=0)

? "Is reactive: " + oFluentTimer.isReactive()
#--> Is reactive: 1

# Start and let it run briefly
oFluentTimer.start()
# Note: In real usage, you'd process events here
oFluentTimer.stop()

pf()

/*--- Wait operations and synchronous delays

# Wait operations provide synchronous timing functionality.
# Useful for creating delays in sequential code execution.

pr()

? "Starting wait test at: " + CurrentTime()

# Wait for specific duration
oWaitTimer = new stzTimer(NULL)
? "Waiting for 1 second..."
oWaitTimer.waitFor(1000)
? "Wait completed at: " + CurrentTime()

# Single-shot wait operation
oSyncTimer = new stzTimer(NULL)
oSyncTimer {
    onceAfterMilliseconds(500)
    onTimeout('? "Single shot completed at: " + CurrentTime()')
    wait() # Waits until single-shot completes
}

? "All wait operations completed"

pf()

/*--- Advanced reactive timer with multiple observers

# Complex reactive scenarios with multiple observers and events.
# Demonstrates observer management and event broadcasting.

pr()

# Advanced observer with multiple event handling
class AdvancedObserver
    cName
    nEventCount
    
    def init(name)
        cName = name
        nEventCount = 0
        
    def onTimerEvent(cEvent, xData)
        nEventCount++
        ? cName + " [" + nEventCount + "]: " + cEvent + " -> " + xData
        
    def eventCount()
        return nEventCount

oObserverX = new AdvancedObserver("ObserverX")
oObserverY = new AdvancedObserver("ObserverY")
oObserverZ = new AdvancedObserver("ObserverZ")

oAdvancedReactive = new stzTimer(NULL)
oAdvancedReactive {
    makeReactive()
    everyMilliseconds(200)
    setAutoResetTickCount(TRUE)
    
    # Subscribe multiple observers
    subscribe(oObserverX)
    subscribe(oObserverY) 
    subscribe(oObserverZ)
    
    onTimeout('
        if this.tickCount() >= 4
            this.stop()
        ok
    ')
    
    start()
}

# Wait for completion
while oAdvancedReactive.isActive()
    # Process events
end

? "Observer X events: " + oObserverX.eventCount()
? "Observer Y events: " + oObserverY.eventCount()  
? "Observer Z events: " + oObserverZ.eventCount()

# Test observer removal
oAdvancedReactive {
    unsubscribe(oObserverY)
    clearObservers() # Remove all observers
}

? "Observers after clear: " + len(oAdvancedReactive.observers())
#--> ObserverX [1]: timeout -> 1
#--> ObserverY [1]: timeout -> 1
#--> ObserverZ [1]: timeout -> 1
#--> ObserverX [2]: timeout -> 2
#--> ObserverY [2]: timeout -> 2
#--> ObserverZ [2]: timeout -> 2
#--> ObserverX [3]: timeout -> 3
#--> ObserverY [3]: timeout -> 3
#--> ObserverZ [3]: timeout -> 3
#--> ObserverX [4]: timeout -> 4
#--> ObserverY [4]: timeout -> 4
#--> ObserverZ [4]: timeout -> 4
#--> Observer X events: 4
#--> Observer Y events: 4
#--> Observer Z events: 4
#--> Observers after clear: 0

pf()

/*--- Error handling and edge cases

# Testing timer behavior with invalid inputs and edge cases.
# Proper error handling ensures robust timer operations.

pr()

# Test invalid interval
try
    oErrorTimer = new stzTimer(NULL)
    oErrorTimer.setInterval(-100) # Should raise error
catch cError
    ? "Caught expected error: " + cError
end

# Test with zero interval
oZeroTimer = new stzTimer(NULL)
oZeroTimer.setInterval(0)
? "Zero interval timer: " + oZeroTimer.toString()
#--> Zero interval timer: stzTimer(STOPPED, REPEATING, interval=0ms, ticks=0)

# Test restart operation
oRestartTimer = new stzTimer(NULL)
oRestartTimer {
    everyMilliseconds(100)
    start()
    ? "Before restart - Active: " + isActive()
    restart()
    ? "After restart - Active: " + isActive()
    stop()
}
#--> Before restart - Active: 1
#--> After restart - Active: 1

# Test observer with non-object
oReactiveTest = new stzTimer(NULL)
oReactiveTest {
    makeReactive()
    subscribe("invalid") # Should be ignored
    subscribe(123)       # Should be ignored
    ? "Observers count: " + len(observers())
}
#--> Observers count: 0

pf()

/*--- Performance and memory considerations

# Testing timer performance and resource management.
# Important for applications with many timers or long-running operations.

pr()

# Create multiple timers to test resource usage
aTimers = []
for i = 1 to 10
    oTimer = new stzTimer(NULL)
    oTimer.everyMilliseconds(50 + (i * 10))
    aTimers + oTimer
next

? "Created " + len(aTimers) + " timers"

# Start all timers
for oTimer in aTimers
    oTimer.start()
next

nActiveCount = 0
for oTimer in aTimers  
    if oTimer.isActive()
        nActiveCount++
    ok
next
? "Active timers: " + nActiveCount

# Stop all timers
for oTimer in aTimers
    oTimer.stop()
next

? "All timers stopped"

# Test large tick counts
oBigTickTimer = new stzTimer(NULL)
oBigTickTimer {
    everyMilliseconds(1)
    setAutoResetTickCount(FALSE) # No auto-reset
    
    nManualTicks = 0
    onTimeout('
        nManualTicks++
        if nManualTicks >= 1000
            this.stop()
        ok
    ')
    
    start()
}

# Wait for high tick count
while oBigTickTimer.isActive()
    # Process events rapidly
end

? "High tick count reached: " + oBigTickTimer.tickCount()

pf()

